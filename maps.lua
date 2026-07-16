-- ==================================================
-- [ ALB8RAAQ ] - GLOBAL NAVIGATOR & MAP WARP ENGINE
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: GLOBAL NAVIGATOR",
   LoadingTitle = "Iniciando Escáner Universal...",
   LoadingSubtitle = "Indexando coordenadas y remotos...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local NavTab = Window:CreateTab("Global Navigator 🌍", 4483362458)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local DiscoveredMaps = {}
local CurrentMapIndex = 1

-- ==========================================
-- MOTOR DE DESCUBRIMIENTO PROFUNDO
-- ==========================================
local function DeepDiscovery()
    DiscoveredMaps = {} -- Reset
    
    -- 1. Escanear Workspace (Mapas Físicos)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (string.find(string.lower(obj.Name), "mountain") or string.find(string.lower(obj.Name), "map") or string.find(string.lower(obj.Name), "zone")) 
           and (obj:IsA("Model") or obj:IsA("Folder")) then
            
            local spawn = obj:FindFirstChild("SpawnLocation", true) or obj:FindFirstChildWhichIsA("BasePart", true)
            if spawn then
                table.insert(DiscoveredMaps, {Name = obj.Name, Path = obj:GetFullName(), Type = "PHYSICAL", Target = spawn})
            end
        end
    end
    
    -- 2. Escanear UI (Botones de Viaje)
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("GuiButton") and (string.find(string.lower(obj.Name), "k") or string.find(string.lower(obj.Name), "mountain")) then
            table.insert(DiscoveredMaps, {Name = obj.Name, Path = obj:GetFullName(), Type = "UI", Target = obj})
        end
    end
    
    Rayfield:Notify({Title = "Escaneo Finalizado", Content = string.format("Encontrados %d puntos de interés.", #DiscoveredMaps), Duration = 3})
end

-- ==========================================
-- LÓGICA DE VIAJE UNIVERSAL
-- ==========================================
local function TravelTo(index)
    local map = DiscoveredMaps[index]
    if not map then return end
    
    Rayfield:Notify({Title = "Viajando...", Content = "Destino: " .. map.Name, Duration = 2})
    
    if map.Type == "PHYSICAL" then
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = map.Target.CFrame + Vector3.new(0, 5, 0) end
    elseif map.Type == "UI" then
        if firesignal then
            firesignal(map.Target.MouseButton1Click)
        elseif getconnections then
            for _, conn in pairs(getconnections(map.Target.MouseButton1Click)) do conn:Fire() end
        end
    end
end

-- ==========================================
-- INTERFAZ RAYFIELD (NAVEGADOR)
-- ==========================================
local StatusLabel = NavTab:CreateLabel("Mapa seleccionado: Ninguno")

NavTab:CreateButton({
    Name = "🔄 Rescanear Todo el Mundo",
    Callback = function() DeepDiscovery() end
})

NavTab:CreateButton({
    Name = "🚀 VIAJAR A ESTE MAPA",
    Callback = function() TravelTo(CurrentMapIndex) end
})

NavTab:CreateButton({
    Name = "➡️ Siguiente Mapa",
    Callback = function()
        if CurrentMapIndex < #DiscoveredMaps then
            CurrentMapIndex = CurrentMapIndex + 1
            StatusLabel:Set("Mapa seleccionado: " .. DiscoveredMaps[CurrentMapIndex].Name)
        end
    end
})

NavTab:CreateButton({
    Name = "⬅️ Mapa Anterior",
    Callback = function()
        if CurrentMapIndex > 1 then
            CurrentMapIndex = CurrentMapIndex - 1
            StatusLabel:Set("Mapa seleccionado: " .. DiscoveredMaps[CurrentMapIndex].Name)
        end
    end
})

-- ==========================================
-- BYPASS GLOBAL (REFORZADO)
-- ==========================================
local BypassTab = Window:CreateTab("Global Bypass 🛡️", 4483362458)

BypassTab:CreateToggle({
    Name = "🔒 Forzar Bypass Universal de Compra",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            -- Bucle de defensa de valores (Heartbeat)
            _G.AntiLock = RunService.Heartbeat:Connect(function()
                for _, obj in ipairs(PlayerGui:GetDescendants()) do
                    if obj:IsA("BoolValue") and (string.find(obj.Name, "Locked") or string.find(obj.Name, "Owned")) then
                        obj.Value = true
                    elseif obj:IsA("NumberValue") and (string.find(obj.Name, "Price") or string.find(obj.Name, "Cost")) then
                        obj.Value = 0
                    end
                end
            end)
        else
            if _G.AntiLock then _G.AntiLock:Disconnect() end
        end
    end
})

-- Ejecución inicial automática
DeepDiscovery()
