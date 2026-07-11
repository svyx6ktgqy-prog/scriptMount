-- =====================================================================
-- 💎 ALB8RAAQ - MINE MASTER PRO V5 (ANTI-FREEZE MOTOR)
-- UI: Rayfield | Movimiento Suave (No más estático) | Sync Real
-- =====================================================================

if _G.MineDiamondLoaded then
    warn("El menú ya está en ejecución.")
    return
end
_G.MineDiamondLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "💎 ALB8RAAQ | V5 Anti-Congelamiento",
    LoadingTitle = "Iniciando Motor V5...",
    LoadingSubtitle = "Joystick y Anti-Freeze Activos",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- =====================================================================
-- MODO SOMBRA V5 (ANTI-CONGELAMIENTO)
-- =====================================================================
local MoveTab = Window:CreateTab("Movimiento", 4483362458)
local selectedTrollPlayer = "Ninguno"
local trollFollowEnabled = false

local TrollDropdown = MoveTab:CreateDropdown({
    Name = "👤 Seleccionar Víctima",
    Options = {"Ninguno"},
    Callback = function(Options) selectedTrollPlayer = Options[1] end
})

MoveTab:CreateToggle({
    Name = "👣 Activar Modo Sombra V5 (No se congela)",
    CurrentValue = false,
    Callback = function(Value)
        trollFollowEnabled = Value
        if Value then
            task.spawn(function()
                while trollFollowEnabled do
                    task.wait(0.05)
                    local target = Players:FindFirstChild(selectedTrollPlayer)
                    local root = getRoot()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    
                    if target and target.Character and root and hum then
                        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
                        
                        -- Verificación Anti-Estático: Si el jugador mueve el joystick, el script se relaja
                        if hum.MoveDirection.Magnitude > 0 then
                            task.wait(0.2)
                            continue
                        end
                        
                        -- Movimiento Suave (Lerp) en lugar de fuerza bruta
                        local targetPos = (targetRoot.CFrame * CFrame.new(0, 0, 2.5)).Position
                        root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, targetRoot.Position), 0.2)
                        
                        -- Sincronizar Salto
                        if targetHum:GetState() == Enum.HumanoidStateType.Jumping then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                        
                        -- Sincronizar Pico (Golpe)
                        if target.Character:FindFirstChildOfClass("Tool") then
                            local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if myTool then myTool:Activate() end
                        end
                    end
                end
            end)
        end
    end,
})

-- Actualizar lista de jugadores
local function updatePlayers()
    local names = {"Ninguno"}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    TrollDropdown:Refresh(names)
end
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)
updatePlayers()
