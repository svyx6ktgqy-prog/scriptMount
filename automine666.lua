-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Ninja Harvester 💎 | V4 Ultra",
   LoadingTitle = "Cargando Sistema Híbrido...",
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
local AutoEquipTool = true
local HitSpeed = 0.05 

-- Variables de Exploración Manual
local manualList = {}
local manualIndex = 1
local manualTarget = nil
local highlightBox = nil

-- Diccionarios y Conexiones
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

-- =======================================================================
-- LÓGICA DE NAVEGACIÓN MANUAL (ESCÁNER)
-- =======================================================================
local function HighlightTarget(target)
    if highlightBox then highlightBox:Destroy() end
    if not target then return end
    
    highlightBox = Instance.new("SelectionBox")
    highlightBox.Name = "ManualHighlight"
    highlightBox.Color3 = Color3.fromRGB(0, 255, 255)
    highlightBox.LineThickness = 0.08
    highlightBox.SurfaceColor3 = Color3.fromRGB(0, 255, 255)
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
            -- Mapeo estricto para que lea T1, T5, T6 correctamente
            local matchCode = string.match(crystal.Name, "(T[1-6])")
            if targetCode == "Todos" or matchCode == targetCode then
                table.insert(manualList, crystal)
            end
        end
    end

    -- Ordenar por distancia actual para navegar de forma lógica
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
-- INTERFAZ: PESTAÑA AUTO-MINAR
-- =======================================================================
FarmTab:CreateSection("⛏️ Auto-Farm Global")

FarmTab:CreateToggle({
   Name = "Activar Minado Automático Continuo",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmActive = Value
        if Value then
            -- SOLUCIÓN AL BUG DE ATASCO: Limpiar lista negra al encender
            table.clear(temporaryBlacklist)
        else
            stopStick()
        end
   end,
})

FarmTab:CreateDropdown({
   Name = "Filtro de Rareza (Global y Manual)",
   Options = {"Todos", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
   CurrentOption = "Todos",
   Flag = "TierSelector",
   Callback = function(Option)
        -- Si Rayfield devuelve una tabla, sacamos el string
        SelectedTier = type(Option) == "table" and Option[1] or Option
        manualIndex = 0 -- Reinicia la lista manual al cambiar
   end,
})

FarmTab:CreateToggle({
   Name = "Auto-Vender Cristales",
   CurrentValue = false,
   Flag = "AutoSellToggle",
   Callback = function(Value)
        AutoSellActive = Value
   end,
})

-- =======================================================================
-- INTERFAZ: EXPLORACIÓN MANUAL
-- =======================================================================
FarmTab:CreateSection("🔍 Explorador Manual de Cristales")

local ManualInfoParagraph = FarmTab:CreateParagraph({
    Title = "Datos del Cristal",
    Content = "Presiona 'Siguiente' para escanear diamantes en el mapa..."
})

local function CycleManual(direction)
    UpdateManualList()
    if #manualList == 0 then
        ManualInfoParagraph:Set({Title = "Error", Content = "No se encontraron cristales de la categoría: " .. SelectedTier})
        HighlightTarget(nil)
        manualTarget = nil
        return
    end

    manualIndex = manualIndex + direction
    if manualIndex > #manualList then manualIndex = 1 end
    if manualIndex < 1 then manualIndex = #manualList end

    manualTarget = manualList[manualIndex]
    
    -- Extraer datos y mostrar en pantalla
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

FarmTab:CreateButton({
   Name = "◀ Anterior Cristal",
   Callback = function() CycleManual(-1) end,
})

FarmTab:CreateButton({
   Name = "Siguiente Cristal ▶",
   Callback = function() CycleManual(1) end,
})

FarmTab:CreateButton({
   Name = "🚀 TELETRANSPORTAR Y EXTRAER",
   Callback = function()
        if not manualTarget or not manualTarget.Parent then
            Rayfield:Notify({Title = "Error", Content = "Selecciona un cristal primero.", Duration = 2})
            return
        end
        
        -- Si el auto farm estaba encendido, lo pausamos para evitar conflictos
        if AutoFarmActive then
            Rayfield:Notify({Title = "Aviso", Content = "Pausando Auto-Farm para realizar extracción manual...", Duration = 3})
            AutoFarmActive = false 
            task.wait(0.2)
        end

        local part = manualTarget:IsA("Model") and (manualTarget.PrimaryPart or manualTarget:FindFirstChildWhichIsA("BasePart")) or manualTarget
        local prompt = manualTarget:FindFirstChildOfClass("ProximityPrompt")
        
        if part and prompt then
            task.spawn(function()
                verifyAndEquipTool()
                startStick(part)
                task.wait(0.15)
                
                local char = LocalPlayer.Character
                local startTime = os.clock()
                
                -- Bucle de ataque forzado sólo para ESTE cristal
                while manualTarget:IsDescendantOf(Workspace) and prompt.Enabled do
                    if os.clock() - startTime > 6 then break end -- timeout
                    
                    if fireproximityprompt then fireproximityprompt(prompt) end
                    
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                    task.wait(HitSpeed)
                end
                
                stopStick()
                HighlightTarget(nil)
                ManualInfoParagraph:Set({Title = "✅ Extracción Completada", Content = "Cristal recolectado con éxito."})
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
            if targetCode == "Todos" or matchCode == targetCode then
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
                    startStick(target.Part)
                    task.wait(0.15) 
                    
                    local startTime = os.clock()
                    while AutoFarmActive and target.Instance:IsDescendantOf(Workspace) and target.Prompt.Enabled do
                        
                        -- Si tarda mucho, a lista negra
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

-- Hilo Secundario: Auto-Venta
task.spawn(function()
    while true do
        task.wait(20)
        if AutoSellActive and AutoFarmActive then
            local sellPrompt = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("SellProx") and Workspace.Things.SellProx:FindFirstChild("ProximityPrompt")
            local char = LocalPlayer.Character
            
            if sellPrompt and char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                stopStick() 
                
                local oldPos = hrp.CFrame
                hrp.CFrame = Workspace.Things.SellProx.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.3)
                
                if fireproximityprompt then fireproximityprompt(sellPrompt) end
                
                task.wait(0.3)
                hrp.CFrame = oldPos 
            end
        end
    end
end)
