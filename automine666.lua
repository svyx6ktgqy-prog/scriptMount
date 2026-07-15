-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Ninja Harvester 💎 | V5 Economy",
   LoadingTitle = "Cargando Motor Económico...",
   LoadingSubtitle = "Especializado para Delta",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- =======================================================================
-- VARIABLES Y SERVICIOS
-- =======================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Variables de Control Global
local AutoFarmActive = false
local AutoSellActive = false
local SelectedTier = "Todos"
local MinPriceFilter = 0 -- FILTRO DE PRECIO MÍNIMO
local AutoEquipTool = true
local HitSpeed = 0.05 

-- Variables de Exploración Manual
local manualList = {}
local manualIndex = 1
local manualTarget = nil
local highlightBox = nil

-- Diccionarios y Conexiones (Solo para AutoFarm)
local temporaryBlacklist = {}
local stickConnection = nil
local noclipConnection = nil

local tierMapping = {
    ["Todos"]     = "Todos",
    ["Common"]    = "T1",
    ["Uncommon"]  = "T2",
    ["Rare"]      = "T3",
    ["Epic"]      = "T4",
    ["Legendary"] = "T5",
    ["Mythic"]    = "T6"
}

-- Pestañas
local FarmTab = Window:CreateTab("Auto-Minar ⛏️", 4483362458)
local ConfigTab = Window:CreateTab("Configuración ⚙️", 4483362458)

-- =======================================================================
-- FUNCIONES DE MOTOR FÍSICO Y UTILIDADES
-- =======================================================================
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function stopStick()
    if stickConnection then
        stickConnection:Disconnect()
        stickConnection = nil
    end
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- Este "Stick" es el modo fantasma (se usa solo para el AutoFarm)
local function startStick(part)
    stopStick()
    enableNoclip() 
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end 
    end
    
    stickConnection = RunService.Heartbeat:Connect(function()
        if not part or not part.Parent then
            stopStick()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function verifyAndEquipTool()
    if not AutoEquipTool then return end
    local char = LocalPlayer.Character
    if not char then return end
    if char:FindFirstChildOfClass("Tool") then return end
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then tool.Parent = char end
end

local function ParseCrystalDetails(text)
    local name, kg, price = "Desconocido", "N/A", "N/A"
    if text and text ~= "" then
        local parts = {}
        for part in string.gmatch(text, "[^•]+") do
            local cleaned = string.match(part, "^%s*(.-)%s*$")
            if cleaned then table.insert(parts, cleaned) end
        end
        name = parts[1] or name
        kg = parts[2] or kg
        price = parts[3] or price
    end
    return name, kg, price
end

-- Limpia el texto del precio (ej: "$1,000,000") y lo convierte en un número real (1000000)
local function GetPriceNumber(priceText)
    if not priceText then return 0 end
    local cleanNum = string.gsub(priceText, "[^%d]", "") -- Elimina todo lo que no sean números
    return tonumber(cleanNum) or 0
end

-- =======================================================================
-- LÓGICA DE NAVEGACIÓN MANUAL (ESCÁNER ECONÓMICO)
-- =======================================================================
local function HighlightTarget(target)
    if highlightBox then highlightBox:Destroy() end
    if not target then return end
    
    highlightBox = Instance.new("SelectionBox")
    highlightBox.Name = "ManualHighlight"
    highlightBox.Color3 = Color3.fromRGB(0, 255, 100)
    highlightBox.LineThickness = 0.08
    highlightBox.SurfaceColor3 = Color3.fromRGB(0, 255, 100)
    highlightBox.SurfaceTransparency = 0.7
    highlightBox.Adornee = target
    highlightBox.Parent = target
end

local function UpdateManualList()
    manualList = {}
    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return end

    local targetCode = tierMapping[SelectedTier]

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
        local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt.Enabled then
            local matchCode = string.match(crystal.Name, "(T[1-6])")
            
            -- Extraemos el precio real para el filtro
            local _, _, priceStr = ParseCrystalDetails(prompt.ObjectText)
            local actualPrice = GetPriceNumber(priceStr)

            -- Verifica que cumpla con la categoría Y con el precio mínimo
            if (targetCode == "Todos" or matchCode == targetCode) and actualPrice >= MinPriceFilter then
                table.insert(manualList, crystal)
            end
        end
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(manualList, function(a, b)
            local posA = (a:IsA("Model") and a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart") or a).Position
            local posB = (b:IsA("Model") and b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart") or b).Position
            return (hrp.Position - posA).Magnitude < (hrp.Position - posB).Magnitude
        end)
    end
end

-- =======================================================================
-- INTERFAZ: PESTAÑA AUTO-MINAR & MANUAL
-- =======================================================================
FarmTab:CreateSection("⛏️ Controles Globales (Aplica a Auto y Manual)")

FarmTab:CreateDropdown({
   Name = "Filtro de Rareza",
   Options = {"Todos", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
   CurrentOption = "Todos",
   Flag = "TierSelector",
   Callback = function(Option)
        SelectedTier = type(Option) == "table" and Option[1] or Option
        manualIndex = 0 
   end,
})

-- NUEVO: FILTRO DE DINERO
FarmTab:CreateInput({
   Name = "💰 Precio Mínimo ($)",
   PlaceholderText = "Ej: 1000000",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        MinPriceFilter = tonumber(Text) or 0
        manualIndex = 0
        HighlightTarget(nil)
        manualTarget = nil
        Rayfield:Notify({Title = "Filtro Aplicado", Content = "Buscando diamantes de $" .. MinPriceFilter .. " o más.", Duration = 3})
   end,
})

FarmTab:CreateToggle({
   Name = "Activar Auto-Farm Continuo",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmActive = Value
        if Value then
            table.clear(temporaryBlacklist)
        else
            stopStick()
        end
   end,
})

FarmTab:CreateSection("🔍 Explorador Manual (Económico)")

local ManualInfoParagraph = FarmTab:CreateParagraph({
    Title = "Datos del Cristal",
    Content = "Presiona 'Siguiente' para escanear el mapa..."
})

local function CycleManual(direction)
    UpdateManualList()
    if #manualList == 0 then
        ManualInfoParagraph:Set({Title = "Error", Content = "No hay cristales que superen los $"..MinPriceFilter})
        HighlightTarget(nil)
        manualTarget = nil
        return
    end

    manualIndex = manualIndex + direction
    if manualIndex > #manualList then manualIndex = 1 end
    if manualIndex < 1 then manualIndex = #manualList end

    manualTarget = manualList[manualIndex]
    
    local prompt = manualTarget:FindFirstChildOfClass("ProximityPrompt")
    local rawText = prompt and prompt.ObjectText or ""
    local name, kg, price = ParseCrystalDetails(rawText)
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pos = (manualTarget:IsA("Model") and manualTarget.PrimaryPart or manualTarget:FindFirstChildWhichIsA("BasePart") or manualTarget).Position
    local dist = hrp and math.floor((hrp.Position - pos).Magnitude) or 0

    ManualInfoParagraph:Set({
        Title = string.format("📌 %s [%d/%d]", name, manualIndex, #manualList),
        Content = string.format("⚖️ Peso: %s\n💰 Precio: %s\n📏 Distancia: %d studs", kg, price, dist)
    })
    
    HighlightTarget(manualTarget)
end

FarmTab:CreateButton({ Name = "◀ Anterior", Callback = function() CycleManual(-1) end })
FarmTab:CreateButton({ Name = "Siguiente ▶", Callback = function() CycleManual(1) end })

-- NUEVA EXTRACCIÓN: NATURAL (SIN FLY, ANCLADO ARRIBA)
FarmTab:CreateButton({
   Name = "🚀 TELETRANSPORTAR Y EXTRAER (Natural)",
   Callback = function()
        if not manualTarget or not manualTarget.Parent then
            Rayfield:Notify({Title = "Error", Content = "Selecciona un cristal primero.", Duration = 2})
            return
        end
        
        if AutoFarmActive then AutoFarmActive = false; task.wait(0.2) end

        local part = manualTarget:IsA("Model") and (manualTarget.PrimaryPart or manualTarget:FindFirstChildWhichIsA("BasePart")) or manualTarget
        local prompt = manualTarget:FindFirstChildOfClass("ProximityPrompt")
        
        if part and prompt then
            task.spawn(function()
                verifyAndEquipTool()
                
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    -- TELETRANSPORTE NATURAL: Lo pone exactamente arriba del cristal y lo mira hacia abajo
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0), part.Position)
                    -- ANCLAJE: Evita que resbale de la montaña o ruede por las físicas
                    hrp.Anchored = true
                end
                
                task.wait(0.15)
                
                local startTime = os.clock()
                
                while manualTarget and manualTarget:IsDescendantOf(Workspace) and prompt.Enabled do
                    if os.clock() - startTime > 8 then break end 
                    
                    if fireproximityprompt then fireproximityprompt(prompt) end
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                    
                    task.wait(HitSpeed)
                end
                
                -- Desanclar una vez que el diamante se rompe
                if hrp then hrp.Anchored = false end
                
                HighlightTarget(nil)
                ManualInfoParagraph:Set({Title = "✅ Extracción Completada", Content = "Cristal recolectado. Busca el siguiente."})
                manualTarget = nil
            end)
        end
   end,
})

-- =======================================================================
-- BUCLE PRINCIPAL DE AUTO-MINADO
-- =======================================================================
local function GetClosestCrystalForAuto()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return nil end

    local closestCrystal = nil
    local shortestDist = math.huge
    local targetCode = tierMapping[SelectedTier]

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
        local cooldown = temporaryBlacklist[crystal]
        if cooldown and os.clock() < cooldown then continue end

        local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt.Enabled then
            local matchCode = string.match(crystal.Name, "(T[1-6])")
            
            local _, _, priceStr = ParseCrystalDetails(prompt.ObjectText)
            local actualPrice = GetPriceNumber(priceStr)

            -- Respetar categoría Y precio mínimo en AutoFarm también
            if (targetCode == "Todos" or matchCode == targetCode) and actualPrice >= MinPriceFilter then
                local part = crystal:IsA("BasePart") and crystal or crystal:FindFirstChildOfClass("BasePart") or crystal.PrimaryPart
                if part then
                    local dist = (root.Position - part.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestCrystal = { Instance = crystal, Part = part, Prompt = prompt }
                    end
                end
            end
        end
    end
    return closestCrystal
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmActive then
            local target = GetClosestCrystalForAuto()
            if target then
                local char = LocalPlayer.Character
                if char then
                    verifyAndEquipTool()
                    startStick(target.Part) -- AutoFarm sí usa Stick (más eficiente y seguro para gran escala)
                    task.wait(0.15) 
                    
                    local startTime = os.clock()
                    while AutoFarmActive and target.Instance:IsDescendantOf(Workspace) and target.Prompt.Enabled do
                        if os.clock() - startTime > 4.0 then
                            temporaryBlacklist[target.Instance] = os.clock() + 8.0
                            break
                        end
                        if fireproximityprompt then fireproximityprompt(target.Prompt) end
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                        task.wait(HitSpeed)
                    end
                    stopStick() 
                end
            end
        end
    end
end)
