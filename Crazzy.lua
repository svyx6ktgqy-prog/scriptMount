-- ==========================================================
-- 🔪 AUTO-KNIFE BATTLE ROYALE - 100% AUTOMATION SCRIPT
-- ==========================================================

-- Variables Globales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local getGui = function()
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Funciones de Utilidad para simular clics
local function fireClick(button)
    if button then
        -- Compatible con exploits modernos (Synapse, Krnl, Fluxus, etc.)
        if firesignal then
            firesignal(button.MouseButton1Click)
        elseif getconnections then
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
        end
    end
end

-- ==========================================================
-- 🎨 CONFIGURACIÓN DE LA INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔪 Auto-Knife Battle Royale",
   LoadingTitle = "Loading Automation...",
   LoadingSubtitle = "100% Automated Script",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Pestañas (Tabs)
local CombatTab = Window:CreateTab("⚔️ Combat Auto", 4483362458)
local UtilityTab = Window:CreateTab("⚙️ Utility & Shop", 4483362458)

-- ==========================================================
-- ⚔️ COMBAT AUTO (Lanzar, Atrapar, Esquivar)
-- ==========================================================
local AutoCombat = {
    Throw = false,
    Catch = false,
    Dash = false,
    Jump = false
}

CombatTab:CreateToggle({
   Name = "Auto Throw (Spam Lanzar)",
   CurrentValue = false,
   Flag = "AutoThrow",
   Callback = function(Value)
        AutoCombat.Throw = Value
        if Value then
            task.spawn(function()
                while AutoCombat.Throw do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("HUD") and gui.HUD.MobileButtons.Throw:FindFirstChild("click") then
                        fireClick(gui.HUD.MobileButtons.Throw.click)
                    end
                    task.wait(0.1)
                end
            end)
        end
   end,
})

CombatTab:CreateToggle({
   Name = "Auto Catch (Spam Atrapar)",
   CurrentValue = false,
   Flag = "AutoCatch",
   Callback = function(Value)
        AutoCombat.Catch = Value
        if Value then
            task.spawn(function()
                while AutoCombat.Catch do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("HUD") and gui.HUD.MobileButtons.Catch:FindFirstChild("click") then
                        fireClick(gui.HUD.MobileButtons.Catch.click)
                    end
                    task.wait(0.05) -- Más rápido para reflejos
                end
            end)
        end
   end,
})

CombatTab:CreateToggle({
   Name = "Auto Dash & Crouch (Esquivar)",
   CurrentValue = false,
   Flag = "AutoDash",
   Callback = function(Value)
        AutoCombat.Dash = Value
        if Value then
            task.spawn(function()
                while AutoCombat.Dash do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("HUD") then
                        if gui.HUD.MobileButtons.Dash:FindFirstChild("click") then
                            fireClick(gui.HUD.MobileButtons.Dash.click)
                        end
                        if gui.HUD.MobileButtons.Crouch:FindFirstChild("click") then
                            fireClick(gui.HUD.MobileButtons.Crouch.click)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
   end,
})

CombatTab:CreateToggle({
   Name = "Auto Jump (Spam Salto)",
   CurrentValue = false,
   Flag = "AutoJump",
   Callback = function(Value)
        AutoCombat.Jump = Value
        if Value then
            task.spawn(function()
                while AutoCombat.Jump do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("TouchGui") and gui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton") then
                        fireClick(gui.TouchGui.TouchControlFrame.JumpButton)
                    end
                    task.wait(0.3)
                end
            end)
        end
   end,
})

-- ==========================================================
-- ⚙️ UTILITY & SHOP (Votación y Cajas)
-- ==========================================================
local AutoUtility = {
    Vote = false,
    BuyCrate = false
}

UtilityTab:CreateToggle({
   Name = "Auto Vote Classic Mode",
   CurrentValue = false,
   Flag = "AutoVote",
   Callback = function(Value)
        AutoUtility.Vote = Value
        if Value then
            task.spawn(function()
                while AutoUtility.Vote do
                    local gui = getGui()
                    if gui and gui:FindFirstChild("GameModeVote") then
                        local classicBtn = gui.GameModeVote.Frame.VoteCards.Classic:FindFirstChild("click")
                        if classicBtn and classicBtn.Parent.Visible then
                            fireClick(classicBtn)
                        end
                    end
                    task.wait(2) -- Chequea cada 2 segundos para no saturar
                end
            end)
        end
   end,
})

UtilityTab:CreateToggle({
   Name = "Auto Buy Common Crate",
   CurrentValue = false,
   Flag = "AutoCrate",
   Callback = function(Value)
        AutoUtility.BuyCrate = Value
        if Value then
            task.spawn(function()
                while AutoUtility.BuyCrate do
                    -- Busca la caja en el Workspace usando la ruta de tu log
                    local cratePrompt = Workspace:FindFirstChild("Scriptable") 
                        and Workspace.Scriptable:FindFirstChild("Crates")
                        and Workspace.Scriptable.Crates:FindFirstChild("CommonCrate")
                        and Workspace.Scriptable.Crates.CommonCrate:FindFirstChild("prompt")
                        and Workspace.Scriptable.Crates.CommonCrate.prompt:FindFirstChild("ProximityPrompt")
                    
                    if cratePrompt then
                        if fireproximityprompt then
                            fireproximityprompt(cratePrompt, 1)
                        else
                            -- Alternativa si fireproximityprompt no está soportado
                            cratePrompt:InputHoldBegin()
                            task.wait(cratePrompt.HoldDuration + 0.1)
                            cratePrompt:InputHoldEnd()
                        end
                    end
                    task.wait(1)
                end
            end)
        end
   end,
})

UtilityTab:CreateButton({
   Name = "Test Buy Product (3590406940)",
   Callback = function()
        -- Ejecuta la transacción registrada en el log
        local remote = ReplicatedStorage:FindFirstChild("Remote")
        if remote and remote:FindFirstChild("Warp") then
            local guiRemote = remote.Warp.Remotes:FindFirstChild("GUI")
            if guiRemote then
                guiRemote:InvokeServer("BuyProduct", 3590406940)
            end
        end
   end,
})

-- Notificación de carga exitosa
Rayfield:Notify({
   Title = "Injected Successfully",
   Content = "The automation script is ready to use.",
   Duration = 5,
   Image = 4483362458,
})
