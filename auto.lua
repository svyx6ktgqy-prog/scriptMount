-- ==========================================
-- SCRIPT QUIRÚRGICO - AUTO AIM (RAYFIELD)
-- Optimizado para Delta iOS / Mobile
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables de Estado
local AutoAimEnabled = false
local AimMode = "Mas Cercano"
local SpecificTargetEnabled = false

-- Variables para el Aim Específico
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-----------------------------------------------------
-- LÓGICA MATEMÁTICA Y ROTACIÓN
-----------------------------------------------------

local function AimAtPosition(targetPosition)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    -- 1. Fijar la cámara hacia el objetivo
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
    
    -- 2. Rotar el cuerpo en el plano horizontal (Eje Y)
    local direction = targetPosition - hrp.Position
    local flatDirection = Vector3.new(direction.X, 0, direction.Z)
    
    -- Evitar vectores nulos (división por cero) si el enemigo está directamente arriba/abajo
    if flatDirection.Magnitude > 0.1 then
        humanoid.AutoRotate = false -- Previene que Roblox sobrescriba la rotación
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flatDirection)
    end
end

local function ResetCharacterRotation()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

-- Función para buscar jugador cercano/lejano
local function GetAutonomousTarget()
    local target = nil
    local dist = (AimMode == "Mas Cercano") and math.huge or 0
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

    if not myPos then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pPos = p.Character.HumanoidRootPart.Position
            local d = (myPos - pPos).Magnitude
            
            if AimMode == "Mas Cercano" and d < dist then
                dist = d
                target = p
            elseif AimMode == "Mas Lejano" and d > dist then
                dist = d
                target = p
            end
        end
    end
    return target
end

-- Bucle principal de apuntado
RunService.RenderStepped:Connect(function()
    local aimed = false

    -- Prioridad 1: Aim Específico
    if SpecificTargetEnabled and SelectedTargetPlayer then
        local targetChar = SelectedTargetPlayer.Character
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
            AimAtPosition(targetChar.HumanoidRootPart.Position)
            aimed = true
        else
            SelectedTargetPlayer = nil
        end
    -- Prioridad 2: Aim Autónomo
    elseif AutoAimEnabled then
        local target = GetAutonomousTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            AimAtPosition(target.Character.HumanoidRootPart.Position)
            aimed = true
        end
    end

    -- Restaurar control de rotación normal cuando no se esté apuntando
    if not aimed then
        ResetCharacterRotation()
    end
end)

-----------------------------------------------------
-- INTERFAZ FLOTANTE (COMPATIBLE CON DELTA)
-----------------------------------------------------

--gethui() previene errores de permisos en Delta iOS
local targetGuiParent = (gethui and gethui()) or game:GetService("CoreGui")

local FloatingGUI = Instance.new("ScreenGui")
FloatingGUI.Name = "QuirurgicoGUI"
FloatingGUI.ResetOnSpawn = false
FloatingGUI.Parent = targetGuiParent
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
   Name = "🎯 Quirúrgico Aim (Delta iOS)",
   LoadingTitle = "Cargando Aimbot...",
   LoadingSubtitle = "Optimizado",
   ConfigurationSaving = {
      Enabled = false
   }
})

local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateSection("Auto-Aim Autónomo")

TabAim:CreateToggle({
   Name = "Activar Auto-Mira (Autónoma)",
   CurrentValue = false,
   Flag = "ToggleAutoAim", 
   Callback = function(Value)
        AutoAimEnabled = Value
        if not Value and not SpecificTargetEnabled then
            ResetCharacterRotation()
        end
   end,
})

TabAim:CreateDropdown({
   Name = "Prioridad de Objetivo",
   Options = {"Mas Cercano", "Mas Lejano"},
   CurrentOption = {"Mas Cercano"},
   MultipleOptions = false,
   Flag = "DropPrioridad",
   Callback = function(Option)
        AimMode = Option[1]
   end,
})

TabAim:CreateSection("Aim Específico (Quirúrgico)")

TabAim:CreateToggle({
   Name = "Activar Selector de Jugador",
   CurrentValue = false,
   Flag = "ToggleSpecific", 
   Callback = function(Value)
        SpecificTargetEnabled = Value
        FloatingGUI.Enabled = Value
        if Value then
            UpdateTargetList()
        else
            ResetCharacterRotation()
        end
   end,
})

Rayfield:LoadConfiguration()
