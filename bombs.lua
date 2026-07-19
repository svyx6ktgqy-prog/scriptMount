-- =========================================================
-- MENU INDEPENDIENTE: THUNDER BOMB INFINITA ⚡
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Thunder Bomb Hack ⚡",
   LoadingTitle = "Inyectando generador de bombas...",
   LoadingSubtitle = "Menú Independiente - Munición Eterna",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
   Keybind = "RightControl" -- Usa Control Derecho para ocultar este menú
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local InfiniteBombActive = false
local BombName = "Thunder Bomb"

local MainTab = Window:CreateTab("Exploit de Bomba", 4483362458)

MainTab:CreateParagraph({
    Title = "Ruta del Objeto Localizada",
    Content = "ReplicatedStorage.Assets.Bombs.Thunder Bomb\nEstado: Listo para clonar y bypassear el consumo."
})

-- Función central para inyectar la bomba
local function InjectFreshBomb()
    -- Buscar la bomba original oculta en el servidor
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then return false end
    
    local bombsFolder = assets:FindFirstChild("Bombs")
    if not bombsFolder then return false end
    
    local originalBomb = bombsFolder:FindFirstChild(BombName)
    if not originalBomb then return false end

    -- Verificar si el jugador ya tiene una en la mano o en la mochila
    local hasInBackpack = LocalPlayer.Backpack:FindFirstChild(BombName)
    local hasInHand = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(BombName)

    -- Si no la tiene (porque se la gastó o la tiró), inyectar una nueva
    if not hasInBackpack and not hasInHand then
        local hackedClone = originalBomb:Clone()
        hackedClone.Parent = LocalPlayer.Backpack
        return true
    end
    
    return false
end

MainTab:CreateToggle({
   Name = "⚡ Activar Munición Eterna (Thunder Bomb)",
   CurrentValue = false,
   Flag = "InfBomb",
   Callback = function(Value)
        InfiniteBombActive = Value
        
        if Value then
            Rayfield:Notify({Title = "Activado", Content = "La Thunder Bomb ya no se agotará.", Duration = 3})
            
            -- Darle la bomba inicial inmediatamente
            InjectFreshBomb()
            
            -- Bucle en segundo plano: Vigila si el juego te quita la bomba y te la devuelve en milisegundos
            task.spawn(function()
                while InfiniteBombActive do
                    task.wait(0.1) -- Chequeo súper rápido para que sea imperceptible
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                        InjectFreshBomb()
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Desactivado", Content = "El reabastecimiento automático se ha apagado.", Duration = 3})
        end
   end,
})

MainTab:CreateButton({
   Name = "Darme x1 Thunder Bomb Manualmente",
   Callback = function()
        -- Inyecta forzosamente la bomba aunque el loop esté apagado
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local originalBomb = assets and assets:FindFirstChild("Bombs") and assets.Bombs:FindFirstChild(BombName)
        
        if originalBomb then
            local clone = originalBomb:Clone()
            clone.Parent = LocalPlayer.Backpack
            Rayfield:Notify({Title = "Bomba Clonada", Content = "Se ha inyectado 1 Thunder Bomb en tu inventario.", Duration = 2})
        else
            Rayfield:Notify({Title = "Error", Content = "No se pudo acceder a ReplicatedStorage.", Duration = 3})
        end
   end,
})

MainTab:CreateLabel("Nota: Equipa la bomba y úsala. Se regenerará al instante.")
