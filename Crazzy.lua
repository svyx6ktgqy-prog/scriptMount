-- ==========================================================
-- 🔪 AUTONOMOUS KNIFE BATTLE ROYALE - VIM & ANTI-LAG EDITION
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local getGui = function()
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

-- ==========================================================
-- 🎯 VIRTUAL INPUT MANAGER (SIMULADOR DE CLICS HARDWARE)
-- ==========================================================
local function fireGuiButton(button)
    if not button then return end
    
    -- Calcula el centro exacto del botón en la pantalla
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local centerX = absPos.X + (absSize.X / 2)
    local centerY = absPos.Y + (absSize.Y / 2)
    
    -- Ignora el offset de la barra superior (GuiInset)
    centerY = centerY + 36 

    -- Simula el hardware: Clic Abajo -> Clic Arriba
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    task.wait(0.01) -- Micro retardo humanoide
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
end

-- ==========================================================
-- 🎨 RAYFIELD UI SETUP
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔪 Tactical Autonomous System",
   LoadingTitle = "Bypassing GUI Protections...",
   LoadingSubtitle = "VIM Engine Active",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("⚔️ Combat Mastery", 4483362458)
local UtilityTab = Window:CreateTab("🎁 Autonomous Rewards", 4483362458)
local OptimizationTab = Window:CreateTab("⚡ Extreme Optimization", 4483362458)

-- ==========================================================
-- ⚔️ MASTER SWITCH 1: BATTLE AUTONOMA
-- ==========================================================
local AutonomousCombat = false

CombatTab:CreateToggle({
   Name = "Enable Autonomous Battle (VIM Method)",
   CurrentValue = false,
   Flag = "AutoBattleMaster",
   Callback = function(Value)
        AutonomousCombat = Value
        
        if AutonomousCombat then
            task.spawn(function()
                while AutonomousCombat do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("HUD") then
                        local mobileBtns = gui.HUD:FindFirstChild("MobileButtons")
                        local touchCtrl = gui:FindFirstChild("TouchGui") and gui.TouchGui:FindFirstChild("TouchControlFrame")
                        
                        if mobileBtns then
                            -- 1. Atrapar
                            if mobileBtns:FindFirstChild("Catch") and mobileBtns.Catch:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Catch.click)
                            end
                            
                            task.wait(0.02)
                            
                            -- 2. Esquivar y Saltar
                            if mobileBtns:FindFirstChild("Dash") and mobileBtns.Dash:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Dash.click)
                            end
                            if touchCtrl and touchCtrl:FindFirstChild("JumpButton") then
                                fireGuiButton(touchCtrl.JumpButton)
                            end
                            
                            task.wait(0.02)
                            
                            -- 3. Lanzar
                            if mobileBtns:FindFirstChild("Throw") and mobileBtns.Throw:FindFirstChild("click") then
                                fireGuiButton(mobileBtns.Throw.click)
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)

            -- Undetectable Speed Buff
            task.spawn(function()
                while AutonomousCombat do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        if char.Humanoid.WalkSpeed == 16 then
                            char.Humanoid.WalkSpeed = 17 
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
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
                    local cratesFolder = Workspace:FindFirstChild("Scriptable") and Workspace.Scriptable:FindFirstChild("Crates")
                    if cratesFolder then
                        for _, crate in pairs(cratesFolder:GetChildren()) do
                            local prompt = crate:FindFirstChild("prompt") and crate.prompt:FindFirstChild("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt, 1)
                            end
                        end
                    end
                    
                    local standsFolder = Workspace:FindFirstChild("Scriptable") and Workspace.Scriptable:FindFirstChild("DonateStands")
                    if standsFolder then
                        for _, stand in pairs(standsFolder:GetChildren()) do
                            local prompt = stand:FindFirstChild("propmt") and stand.propmt:FindFirstChild("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt, 1)
                            end
                        end
                    end

                    local remote = ReplicatedStorage:FindFirstChild("Remote")
                    if remote and remote:FindFirstChild("Warp") and remote.Warp:FindFirstChild("Remotes") then
                        local guiRemote = remote.Warp.Remotes:FindFirstChild("GUI")
                        if guiRemote then
                            pcall(function() guiRemote:InvokeServer("BuyProduct", 3590406940) end)
                        end
                    end
                    task.wait(3)
                end
            end)
        end
   end,
})

-- ==========================================================
-- ⚡ MASTER SWITCH 3: EXTREME ANTI-LAG (POTATO MODE)
-- ==========================================================
local AntiLagActive = false

OptimizationTab:CreateToggle({
   Name = "Extreme Anti-Lag (Zero Shaders & Potato Mode)",
   CurrentValue = false,
   Flag = "ExtremeAntiLag",
   Callback = function(Value)
        AntiLagActive = Value
        if AntiLagActive then
            task.spawn(function()
                -- Forza la calidad gráfica mínima en la configuración del cliente
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                
                -- Bucle continuo para asegurar que los objetos nuevos también se degraden
                while AntiLagActive do
                    -- Apagar motor de iluminación y sombras
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9e9
                    Lighting.Brightness = 1
                    
                    -- Destruir Shaders y Post-Procesado
                    for _, v in pairs(Lighting:GetDescendants()) do
                        if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                            v.Enabled = false
                        end
                    end
                    
                    -- Modo "Todo Pelado" (SmoothPlastic sin texturas)
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Material = Enum.Material.SmoothPlastic
                            v.Reflectance = 0
                            v.CastShadow = false
                        elseif v:IsA("Decal") or v:IsA("Texture") then
                            v.Transparency = 1
                        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                            v.Enabled = false
                        end
                    end
                    
                    -- Detener animaciones del agua
                    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
                    if Terrain then
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.WaterTransparency = 1
                    end

                    task.wait(5) -- Refresca cada 5 segundos para mantener el mapa pelado
                end
            end)
        end
   end,
})

Rayfield:Notify({
   Title = "System Online",
   Content = "VIM Bypass and Anti-Lag successfully loaded.",
   Duration = 5,
   Image = 4483362458,
})
