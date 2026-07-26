-- ==========================================================
-- 🔪 AUTONOMOUS KNIFE BATTLE ROYALE - ADVANCED EDITION
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local getGui = function()
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

-- Función universal para inyección de clics en GUI
local function fireGuiButton(button)
    if not button then return end
    if firesignal then
        firesignal(button.MouseButton1Click)
    elseif getconnections then
        for _, connection in pairs(getconnections(button.MouseButton1Click)) do
            connection:Fire()
        end
    end
end

-- ==========================================================
-- 🎨 RAYFIELD UI SETUP (Inglés por solicitud previa)
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔪 Autonomous Battle System",
   LoadingTitle = "Initializing Tactical Modules...",
   LoadingSubtitle = "Advanced Automation",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("⚔️ Combat Mastery", 4483362458)
local UtilityTab = Window:CreateTab("🎁 Autonomous Rewards", 4483362458)

-- ==========================================================
-- ⚔️ MASTER SWITCH 1: BATTLE AUTONOMA
-- ==========================================================
local AutonomousCombat = false

CombatTab:CreateToggle({
   Name = "Enable Autonomous Battle (Catch -> Dash/Jump -> Throw)",
   CurrentValue = false,
   Flag = "AutoBattleMaster",
   Callback = function(Value)
        AutonomousCombat = Value
        
        if AutonomousCombat then
            -- Hilo de Combate de Alta Frecuencia
            task.spawn(function()
                while AutonomousCombat do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("HUD") then
                        local mobileBtns = gui.HUD:FindFirstChild("MobileButtons")
                        local touchCtrl = gui:FindFirstChild("TouchGui") and gui.TouchGui:FindFirstChild("TouchControlFrame")
                        
                        if mobileBtns then
                            -- 1. INSTANT CATCH (Spam de guardia activa)
                            if mobileBtns:FindFirstChild("Catch") and mobileBtns.Catch:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Catch.click)
                            end
                            
                            -- Micro-delay simulando el frame de atrape (evita desincronización)
                            task.wait(0.01) 
                            
                            -- 2. SECUENCIA OFENSIVA (Dash + Jump)
                            if mobileBtns:FindFirstChild("Dash") and mobileBtns.Dash:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Dash.click)
                            end
                            
                            if touchCtrl and touchCtrl:FindFirstChild("JumpButton") then
                                fireGuiButton(touchCtrl.JumpButton)
                            end
                            
                            -- Micro-delay para posicionamiento aéreo
                            task.wait(0.02)
                            
                            -- 3. INSTANT THROW (Devolución)
                            if mobileBtns:FindFirstChild("Throw") and mobileBtns.Throw:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Throw.click)
                            end
                        end
                    end
                    -- Loop ultrarrápido (aprox 30-60 checks por segundo según FPS)
                    task.wait(0.03)
                end
            end)

            -- Hilo de Inyección de Velocidad (Undetectable +1)
            task.spawn(function()
                while AutonomousCombat do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        -- La velocidad base normal de Roblox es 16.
                        -- Mantenemos 17 para un buff indetectable por el servidor (Anti-Cheat Bypass)
                        if char.Humanoid.WalkSpeed == 16 then
                            char.Humanoid.WalkSpeed = 17 
                        end
                    end
                    task.wait(0.5) -- No requiere alta frecuencia
                end
            end)
        else
            -- Restaurar velocidad al desactivar
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
        end
   end,
})

-- ==========================================================
-- 🎁 MASTER SWITCH 2: RECOMPENSAS Y LOTERÍA
-- ==========================================================
local AutonomousRewards = false

UtilityTab:CreateToggle({
   Name = "Enable Autonomous Rewards & Lottery",
   CurrentValue = false,
   Flag = "AutoRewardsMaster",
   Callback = function(Value)
        AutonomousRewards = Value
        
        if AutonomousRewards then
            task.spawn(function()
                while AutonomousRewards do
                    -- 1. LOTERÍA / CAJAS COMUNES (ProximityPrompt)
                    local cratesFolder = Workspace:FindFirstChild("Scriptable") and Workspace.Scriptable:FindFirstChild("Crates")
                    if cratesFolder then
                        for _, crate in pairs(cratesFolder:GetChildren()) do
                            local prompt = crate:FindFirstChild("prompt") and crate.prompt:FindFirstChild("ProximityPrompt")
                            if prompt then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt, 1)
                                else
                                    prompt:InputHoldBegin()
                                    task.wait(prompt.HoldDuration + 0.1)
                                    prompt:InputHoldEnd()
                                end
                            end
                        end
                    end
                    
                    -- 2. RECLAMO DE PREMIOS EXTRA / DONATE STANDS
                    local standsFolder = Workspace:FindFirstChild("Scriptable") and Workspace.Scriptable:FindFirstChild("DonateStands")
                    if standsFolder then
                        for _, stand in pairs(standsFolder:GetChildren()) do
                            local prompt = stand:FindFirstChild("propmt") and stand.propmt:FindFirstChild("ProximityPrompt")
                            if prompt then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt, 1)
                                end
                            end
                        end
                    end

                    -- 3. TRANSACCIONES AUTOMÁTICAS REGISTRADAS (RemoteEvents)
                    local remote = ReplicatedStorage:FindFirstChild("Remote")
                    if remote and remote:FindFirstChild("Warp") and remote.Warp:FindFirstChild("Remotes") then
                        local guiRemote = remote.Warp.Remotes:FindFirstChild("GUI")
                        if guiRemote then
                            -- Simula el trigger de compra de producto extraído del log
                            pcall(function()
                                guiRemote:InvokeServer("BuyProduct", 3590406940)
                            end)
                        end
                    end

                    -- Bucle de comprobación cada 3 segundos para no saturar la red (Rate Limit)
                    task.wait(3)
                end
            end)
        end
   end,
})

-- Inicialización completada
Rayfield:Notify({
   Title = "System Online",
   Content = "Master switches are ready for execution.",
   Duration = 5,
   Image = 4483362458,
})
