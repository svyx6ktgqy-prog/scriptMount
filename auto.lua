-- ==========================================
-- SCRIPT QUIRÚRGICO (DELTA IOS)
-- Modo: Teleport a Espalda + Autofire en Pantalla
-- Repo: svyx6ktgqy-prog/rayfield
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local SpecificTargetEnabled = false
local TeleportDistance = 3.0 -- Distancia exacta a la espalda
local AutoFireTouchEnabled = true

-- Variables para Selector
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-----------------------------------------------------
-- LÓGICA DE TELEPORT A LA ESPALDA
-----------------------------------------------------

local function TeleportToBack(targetPlayer)
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end

    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")

    if targetHrp and targetHumanoid and targetHumanoid.Health > 0 then
        -- Calcula la posición justo detrás del rival orientando a tu personaje hacia él
        local backCFrame = targetHrp.CFrame * CFrame.new(0, 0, TeleportDistance)
        myHrp.CFrame = CFrame.new(backCFrame.Position, targetHrp.Position)
    else
        SelectedTargetPlayer = nil
    end
end

-- Bucle de pegado continuo a la espalda
RunService.RenderStepped:Connect(function()
    if SpecificTargetEnabled and SelectedTargetPlayer then
        TeleportToBack(SelectedTargetPlayer)
    end
end)

-----------------------------------------------------
-- LÓGICA DE DISPARO AL TOCAR LA PANTALLA
-----------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- gameProcessed es true si el toque fue dentro de un botón/UI del juego o executor
    if gameProcessed then return end

    if not AutoFireTouchEnabled then return end

    -- Detectar Toque en Pantalla (Móvil) o Clic Izquierdo (PC)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                -- Activar disparo del arma equipada
                tool:Activate()
            end
        end
    end
end)

-----------------------------------------------------
-- INTERFAZ FLOTANTE (SELECTOR DE OBJETIVOS)
-----------------------------------------------------
local targetParent = (gethui and gethui()) or game:GetService("CoreGui")

local FloatingGUI = Instance.new("ScreenGui")
FloatingGUI.Name = "QuirurgicoGUI"
FloatingGUI.ResetOnSpawn = false
FloatingGUI.Parent = targetParent
FloatingGUI.Enabled = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Position = UDim2.new(0.5, -100, 0.08, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = FloatingGUI

local TargetNameLabel = Instance.new("TextLabel")
TargetNameLabel.Size = UDim2.new(1, -60, 1, 0)
TargetNameLabel.Position = UDim2.new(0, 30, 0, 0)
TargetNameLabel.BackgroundTransparency = 1
TargetNameLabel.TextColor3 = Color3.new(1, 1, 1)
TargetNameLabel.TextScaled = true
TargetNameLabel.Text = "Buscando..."
TargetNameLabel.Parent = Frame

local function UpdateTargetList()
    PlayerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p) end
    end
    if #PlayerList > 0 then
        if CurrentTargetIndex > #PlayerList then CurrentTargetIndex = 1 end
        if CurrentTargetIndex < 1 then CurrentTargetIndex = #PlayerList end
        SelectedTargetPlayer = PlayerList[CurrentTargetIndex]
        TargetNameLabel.Text = SelectedTargetPlayer.DisplayName or SelectedTargetPlayer.Name
    else
        TargetNameLabel.Text = "Nadie en sala"
        SelectedTargetPlayer = nil
        CurrentTargetIndex = 1
    end
end

local BtnPrev = Instance.new("TextButton")
BtnPrev.Size = UDim2.new(0, 30, 1, 0)
BtnPrev.Text = "<"
BtnPrev.TextScaled = true
BtnPrev.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnPrev.TextColor3 = Color3.new(1, 1, 1)
BtnPrev.Parent = Frame
BtnPrev.MouseButton1Click:Connect(function()
    if #PlayerList == 0 then return end
    CurrentTargetIndex = CurrentTargetIndex - 1
    if CurrentTargetIndex < 1 then CurrentTargetIndex = #PlayerList end
    UpdateTargetList()
end)

local BtnNext = Instance.new("TextButton")
BtnNext.Size = UDim2.new(0, 30, 1, 0)
BtnNext.Position = UDim2.new(1, -30, 0, 0)
BtnNext.Text = ">"
BtnNext.TextScaled = true
BtnNext.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnNext.TextColor3 = Color3.new(1, 1, 1)
BtnNext.Parent = Frame
BtnNext.MouseButton1Click:Connect(function()
    if #PlayerList == 0 then return end
    CurrentTargetIndex = CurrentTargetIndex + 1
    if CurrentTargetIndex > #PlayerList then CurrentTargetIndex = 1 end
    UpdateTargetList()
end)

Players.PlayerAdded:Connect(UpdateTargetList)
Players.PlayerRemoving:Connect(UpdateTargetList)

-----------------------------------------------------
-- MENÚ RAYFIELD
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "🎯 Pegado a Espalda + Autofire",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "Selector de Objetivo + Touch Trigger",
   ConfigurationSaving = {
      Enabled = false
   }
})

local TabMain = Window:CreateTab("Principal", 4483362458)

TabMain:CreateSection("Pegado a Rival")

TabMain:CreateToggle({
   Name = "Activar Pegado a la Espalda",
   CurrentValue = false,
   Flag = "ToggleSpecific", 
   Callback = function(Value)
        SpecificTargetEnabled = Value
        FloatingGUI.Enabled = Value
        if Value then
            UpdateTargetList()
        end
   end,
})

TabMain:CreateSlider({
   Name = "Distancia de Pegado",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = " studs",
   CurrentValue = 3,
   Flag = "SliderDist",
   Callback = function(Value)
        TeleportDistance = Value
   end,
})

TabMain:CreateSection("Disparo por Toque")

TabMain:CreateToggle({
   Name = "Disparar al Tocar la Pantalla",
   CurrentValue = true,
   Flag = "ToggleAutofireTouch",
   Callback = function(Value)
        AutoFireTouchEnabled = Value
   end,
})

Rayfield:LoadConfiguration()
