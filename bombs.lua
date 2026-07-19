-- =========================================================
-- MENU INDEPENDIENTE: ARSENAL DE BOMBAS INFINITAS 💣
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Bomb Arsenal Hack 💣",
   LoadingTitle = "Inyectando generador de arsenal...",
   LoadingSubtitle = "Menú Independiente",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = "RightControl" -- Usa Control Derecho para ocultar este menú
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local InfiniteBombActive = false
local SelectedBombName = "Thunder Bomb" -- Bomba por defecto

-- Lista de todas las bombas descubiertas en el escaneo
local BombTypes = {
    "Thunder Bomb",
    "Time Bomb",
    "Agony Bomb",
    "Poison Bomb",
    "Fire Bomb",
    "Ice Bomb",
    "Wind Bomb",
    "Classic Bomb"
}

local MainTab = Window:CreateTab("Generador", 4483362458)

MainTab:CreateParagraph({
    Title = "Ruta de Inyección Activa",
    Content = "Buscando en: ReplicatedStorage.Assets.Bombs\nNota: Los objetos clonados son 'Client-Sided'. Requieren bypass de red para lanzarse."
})

-- Menú desplegable para seleccionar la bomba
MainTab:CreateDropdown({
    Name = "Selecciona el Tipo de Bomba",
    Options = BombTypes,
    CurrentOption = {"Thunder Bomb"},
    MultipleOptions = false,
    Flag = "BombSelectorDropdown",
    Callback = function(Options)
        SelectedBombName = Options[1]
        print("Bomba seleccionada para clonar: " .. SelectedBombName)
    end,
})

-- Función central para inyectar la bomba seleccionada
local function InjectFreshBomb()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then return false end
    
    local bombsFolder = assets:FindFirstChild("Bombs")
    if not bombsFolder then return false end
    
    local originalBomb = bombsFolder:FindFirstChild(SelectedBombName)
    if not originalBomb then return false end

    local hasInBackpack = LocalPlayer.Backpack:FindFirstChild(SelectedBombName)
    local hasInHand = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(SelectedBombName)

    if not hasInBackpack and not hasInHand then
        local hackedClone = originalBomb:Clone()
        hackedClone.Parent = LocalPlayer.Backpack
        return true
    end
    
    return false
end

MainTab:CreateToggle({
   Name = "⚙️ Activar Munición Eterna (Bomba Seleccionada)",
   CurrentValue = false,
   Flag = "InfBomb",
   Callback = function(Value)
        InfiniteBombActive = Value
        
        if Value then
            Rayfield:Notify({Title = "Bucle Iniciado", Content = SelectedBombName .. " inyectada.", Duration = 3})
            InjectFreshBomb()
            
            task.spawn(function()
                while InfiniteBombActive do
                    task.wait(0.2)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                        InjectFreshBomb()
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Bucle Detenido", Content = "Generador automático apagado.", Duration = 3})
        end
   end,
})

MainTab:CreateButton({
   Name = "📦 Inyectar x1 Bomba Manualmente",
   Callback = function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local originalBomb = assets and assets:FindFirstChild("Bombs") and assets.Bombs:FindFirstChild(SelectedBombName)
        
        if originalBomb then
            local clone = originalBomb:Clone()
            clone.Parent = LocalPlayer.Backpack
            Rayfield:Notify({Title = "Bomba Clonada", Content = "Se añadió: " .. SelectedBombName, Duration = 2})
        else
            Rayfield:Notify({Title = "Error", Content = "No se encontró la bomba en el servidor.", Duration = 3})
        end
   end,
})
