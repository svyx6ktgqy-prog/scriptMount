-- Cargar la librería Rayfield para una interfaz limpia y profesional
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal del Minador
local Window = Rayfield:CreateWindow({
   Name = "Ninja Harvester Pro 💎 V3",
   LoadingTitle = "Cargando Motor de Minado por Golpes...",
   LoadingSubtitle = "Especializado para Delta",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Variables de Control del Script
local AutoFarmActive = false
local AutoSellActive = false
local AutoEquipTool = true -- Equipar pico automáticamente
local SelectedTierOption = "Todos" -- Filtro por defecto
local TeleportDelay = 0.12 -- Margen para evitar kick por velocidad de teleport
local HitSpeed = 0.1 -- Velocidad de los golpes al cristal

-- Mapeo de Tiers
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

-- ==========================================
-- FUNCIONES AUXILIARES DE PROCESAMIENTO
-- ==========================================

-- Separar y limpiar los datos del texto del ProximityPrompt
local function ParseCrystalDetails(text)
    local name = "Desconocido"
    local kg = "N/A"
    local price = "N/A"
    
    if text and text ~= "" then
        local parts = {}
        for part in string.gmatch(text, "[^•]+") do
            local cleaned = string.match(part, "^%s*(.-)%s*$")
            if cleaned then
                table.insert(parts, cleaned)
            end
        end
        name = parts[1] or name
        kg = parts[2] or kg
        price = parts[3] or price
    end
    return name, kg, price
end

-- Traduce la selección visual al formato del juego ("T1", "T2", etc.)
local function GetSelectedTierCode()
    if SelectedTierOption == "Todos" then return "Todos" end
    return string.split(SelectedTierOption, " ")[1] 
end

-- Busca el cristal más cercano que coincida con el Tier seleccionado
local function GetClosestCrystal()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return nil end

    local closestCrystal = nil
    local shortestDistance = math.huge
    local targetTier = GetSelectedTierCode()

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
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
                            Prompt = prompt,
                            Position = part.CFrame,
                            Distance = distance
                        }
                    end
                end
            end
        end
    end
    return closestCrystal
end

-- Equipar herramienta automáticamente (pico, espada, etc.)
local function EquipMiningTool()
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Si ya tiene una herramienta equipada, no hace nada
    if character:FindFirstChildOfClass("Tool") then return end
    
    -- Busca cualquier herramienta en la mochila y la equipa
    local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = character
    end
end

-- Golpear/Activar la herramienta equipada
local function StrikeCrystal()
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate() -- Simula el clic/golpe de la herramienta
    end
end

-- ==========================================
-- INTERFAZ: PESTAÑA AUTO-MINAR
-- ==========================================

FarmTab:CreateToggle({
   Name = "Activar Minado Perfecto Automático",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmActive = Value
        if Value then
            Rayfield:Notify({Title = "Minado Iniciado", Content = "Teletransportando, golpeando y recogiendo...", Duration = 3})
        else
            Rayfield:Notify({Title = "Minado Pausado", Content = "Auto-farm desactivado.", Duration = 3})
        end
   end,
})

FarmTab:CreateDropdown({
   Name = "Filtrar por Poder / Tier",
   Options = {"Todos", "T1 (Common)", "T2 (Uncommon)", "T3 (Rare)", "T4 (Epic)", "T5 (Legendary)", "T6 (Mythic)"},
   CurrentOption = "Todos",
   Flag = "TierSelector",
   Callback = function(Option)
        SelectedTierOption = Option
        Rayfield:Notify({Title = "Filtro Cambiado", Content = "Buscando categoría: " .. Option, Duration = 2})
   end,
})

-- Panel dinámico de información
local InfoParagraph = FarmTab:CreateParagraph({
    Title = "Estado del Minador",
    Content = "Esperando activación..."
})

FarmTab:CreateToggle({
   Name = "Auto-Vender Cristales (Crystal Buyer)",
   CurrentValue = false,
   Flag = "AutoSellToggle",
   Callback = function(Value)
        AutoSellActive = Value
        if Value then
            Rayfield:Notify({Title = "Auto-Venta Activa", Content = "Se venderá periódicamente al llenar la mochila.", Duration = 3})
        end
   end,
})

-- ==========================================
-- INTERFAZ: PESTAÑA CONFIGURACIÓN
-- ==========================================

ConfigTab:CreateToggle({
   Name = "Auto-Equipar Herramienta",
   CurrentValue = true,
   Flag = "AutoEquipToggle",
   Callback = function(Value)
        AutoEquipTool = Value
   end,
})

ConfigTab:CreateSlider({
   Name = "Velocidad de Golpes (Segundos)",
   Min = 0.05,
   Max = 0.5,
   Default = 0.1,
   Color = Color3.fromRGB(255, 100, 100),
   Increment = 0.01,
   ValueName = "s",
   Callback = function(Value)
        HitSpeed = Value
   end,
})

ConfigTab:CreateSlider({
   Name = "Delay de Seguridad (Bypass Teleport)",
   Min = 0.05,
   Max = 0.5,
   Default = 0.12,
   Color = Color3.fromRGB(0, 255, 150),
   Increment = 0.01,
   ValueName = "s",
   Callback = function(Value)
        TeleportDelay = Value
   end,
})

-- ==========================================
-- BUCLE PRINCIPAL DE EJECUCIÓN (LÓGICA PERFECTA)
-- ==========================================

task.spawn(function()
    while true do
        task.wait(0.05)
        
        if AutoFarmActive then
            local target = GetClosestCrystal()
            if target then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- 1. Separar y leer datos del cristal
                    local rawText = target.Prompt.ObjectText
                    local crystalName, crystalWeight, crystalPrice = ParseCrystalDetails(rawText)
                    local distance = math.floor(target.Distance)
                    
                    InfoParagraph:Set({
                        Title = "💎 Minando: " .. crystalName,
                        Content = string.format(
                            "⚖️ Peso: %s\n💰 Precio: %s\n📏 Distancia: %d studs\n⚡ Estado: Rompiendo cristal...",
                            crystalWeight, crystalPrice, distance
                        )
                    })
                    
                    -- 2. Teletransporte seguro al cristal (justo arriba para golpearlo cómodamente)
                    root.CFrame = target.Position * CFrame.new(0, 2.2, 0)
                    task.wait(TeleportDelay)
                    
                    -- 3. Equipar herramienta si está activado
                    if AutoEquipTool then
                        EquipMiningTool()
                    end
                    
                    -- 4. Bucle de Minado Perfecto (Golpear y Recoger al mismo tiempo)
                    local maxWaitTime = tick()
                    while AutoFarmActive and target.Instance:IsDescendantOf(Workspace) and target.Prompt.Enabled do
                        
                        -- Golpear el cristal (Herramienta / Pico)
                        StrikeCrystal()
                        
                        -- Intentar recogerlo (Pickup) mediante el ProximityPrompt
                        if fireproximityprompt then
                            fireproximityprompt(target.Prompt)
                        else
                            target.Prompt:InputHoldBegin()
                            task.wait(target.Prompt.HoldDuration + 0.02)
                            target.Prompt:InputHoldEnd()
                        end
                        
                        -- Pequeño delay ajustable de golpeo para no dar lag
                        task.wait(HitSpeed)
                        
                        -- Romper bucle si el cristal se bugea (máximo 4 segundos por cristal)
                        if tick() - maxWaitTime > 4 then 
                            break 
                        end
                    end
                    
                    -- En cuanto el cristal es destruido y recogido, el bucle termina e instantáneamente salta al siguiente.
                end
            else
                InfoParagraph:Set({
                    Title = "Buscando...",
                    Content = "No se encontraron cristales de esta categoría en el mapa."
                })
            end
        end
    end
end)

-- Hilo Secundario: Auto-Venta Periódica
task.spawn(function()
    while true do
        task.wait(20)
        if AutoSellActive and AutoFarmActive then
            local sellPrompt = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("SellProx") and Workspace.Things.SellProx:FindFirstChild("ProximityPrompt")
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if sellPrompt and root then
                local oldPos = root.CFrame
                
                -- Viaje rápido al vendedor
                root.CFrame = Workspace.Things.SellProx.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.25)
                
                if fireproximityprompt then
                    fireproximityprompt(sellPrompt)
                end
                task.wait(0.2)
                
                -- Regreso instantáneo al punto de minado
                root.CFrame = oldPos
            end
        end
    end
end)
