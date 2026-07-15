-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Ninja Harvester 💎 | Ultra",
   LoadingTitle = "Cargando Motor Híbrido...",
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
local VirtualUser = game:GetService("VirtualUser") -- Motor de clics forzados
local LocalPlayer = Players.LocalPlayer

-- Variables de Control
local AutoFarmActive = false
local AutoSellActive = false
local SelectedTierOption = "Todos"
local AutoEquipTool = true
local MaxTimePerCrystal = 4.0 -- Tiempo antes de ignorar un cristal bugeado
local HitSpeed = 0.05 -- Velocidad ametralladora

-- Diccionarios y Tablas
local temporaryBlacklist = {}
local stickConnection = nil
local noclipConnection = nil

local tierMapping = {
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
-- FUNCIONES DE MOTOR FÍSICO (NOCLIP & STICK)
-- =======================================================================
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
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
        if hum then hum.PlatformStand = true end -- Congela las piernas
    end
    
    stickConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmActive or not part or not part.Parent then
            stopStick()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Se posiciona atrás y mira de frente al cristal
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

-- =======================================================================
-- FUNCIONES AUXILIARES Y DE PROCESAMIENTO
-- =======================================================================
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

local function verifyAndEquipTool()
    if not AutoEquipTool then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    if char:FindFirstChildOfClass("Tool") then return end
    
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then 
        tool.Parent = char 
    end
end

local function GetSelectedTierCode()
    if SelectedTierOption == "Todos" then return "Todos" end
    return string.split(SelectedTierOption, " ")[1] 
end

local function GetClosestCrystal()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return nil end

    local closestCrystal = nil
    local shortestDistance = math.huge
    local targetTier = GetSelectedTierCode()

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
        -- Ignorar cristales en lista negra
        local cooldown = temporaryBlacklist[crystal]
        if cooldown and os.clock() < cooldown then continue end

        local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt.Enabled then
            local matches = false
            if targetTier == "Todos" then
                matches = true
            elseif string.find(crystal.Name, targetTier) then
                matches = true
            end

            if matches then
                local part = crystal:IsA("BasePart") and crystal or crystal:FindFirstChildOfClass("BasePart") or crystal.PrimaryPart
                if part then
                    local distance = (root.Position - part.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCrystal = {
                            Instance = crystal,
                            Part = part,
                            Prompt = prompt,
                            Distance = distance
                        }
                    end
                end
            end
        end
    end
    return closestCrystal
end

-- =======================================================================
-- INTERFAZ UI
-- =======================================================================
FarmTab:CreateToggle({
   Name = "Activar Minado Automático Ultra",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmActive = Value
        if not Value then
            stopStick()
            Rayfield:Notify({Title = "Pausado", Content = "Auto-farm desactivado.", Duration = 3})
        end
   end,
})

FarmTab:CreateDropdown({
   Name = "Filtrar por Categoría",
   Options = {"Todos", "T1 (Common)", "T2 (Uncommon)", "T3 (Rare)", "T4 (Epic)", "T5 (Legendary)", "T6 (Mythic)"},
   CurrentOption = "Todos",
   Flag = "TierSelector",
   Callback = function(Option)
        SelectedTierOption = Option
   end,
})

local InfoParagraph = FarmTab:CreateParagraph({
    Title = "Panel de Escaneo",
    Content = "Esperando objetivo..."
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
-- BUCLE PRINCIPAL DE MINADO (EL MOTOR HÍBRIDO)
-- =======================================================================
task.spawn(function()
    while true do
        task.wait(0.05)
        
        if AutoFarmActive then
            local target = GetClosestCrystal()
            if target then
                local char = LocalPlayer.Character
                if char then
                    -- 1. Analizar texto y actualizar UI
                    local rawText = target.Prompt.ObjectText
                    local cName, cWeight, cPrice = ParseCrystalDetails(rawText)
                    
                    InfoParagraph:Set({
                        Title = "💎 Objetivo: " .. cName,
                        Content = string.format("⚖️ Peso: %s\n💰 Precio: %s\n📏 Distancia: %d studs", cWeight, cPrice, math.floor(target.Distance))
                    })
                    
                    -- 2. Equipar Pico y Pegarse al cristal (Stick + Noclip)
                    verifyAndEquipTool()
                    startStick(target.Part)
                    
                    -- Margen para que el servidor registre tu posición antes de atacar
                    task.wait(0.15) 
                    
                    -- 3. Bucle de Ataque Extremo
                    local startTime = os.clock()
                    while AutoFarmActive and target.Instance:IsDescendantOf(Workspace) and target.Prompt.Enabled do
                        
                        -- Si pasa mucho tiempo, es un cristal bugeado. Lo metemos a la lista negra por 8 seg.
                        if os.clock() - startTime > MaxTimePerCrystal then
                            temporaryBlacklist[target.Instance] = os.clock() + 8.0
                            break
                        end
                        
                        -- A. Activar Prompt de recogida
                        if fireproximityprompt then
                            fireproximityprompt(target.Prompt)
                        end
                        
                        -- B. Activar herramienta de Roblox
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        -- C. Fuerza bruta: Clic Virtual para romper la seguridad del juego
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                        
                        task.wait(HitSpeed)
                    end
                    
                    stopStick() -- Liberar físicas al terminar
                end
            else
                InfoParagraph:Set({Title = "Buscando...", Content = "No hay cristales disponibles de esta categoría."})
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
                stopStick() -- Pausar físicas de minado
                
                local oldPos = hrp.CFrame
                hrp.CFrame = Workspace.Things.SellProx.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.3)
                
                if fireproximityprompt then
                    fireproximityprompt(sellPrompt)
                end
                
                task.wait(0.3)
                hrp.CFrame = oldPos -- Regresar
            end
        end
    end
end)
