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
local AimMode = "Mas Cercano" -- o "Mas Lejano"
local SpecificTargetEnabled = false

-- Variables para el Aim Específico
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-----------------------------------------------------
-- LÓGICA MATEMÁTICA (EL MOTOR QUIRÚRGICO)
-----------------------------------------------------

-- Función para rotar la cámara y el cuerpo del jugador
local function AimAtPosition(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    -- 1. Fijar la cámara (Ultra fijo)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    
    -- 2. Rotar el cuerpo del personaje (Para que el arma en el hombro apunte al rival)
    -- Mantenemos el eje Y igual para que el personaje no se incline hacia el suelo o cielo
    local lookVector = (targetPosition - hrp.Position).Unit
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
end

-- Función para buscar jugador cercano/lejano
local function GetAutonomousTarget()
    local target = nil
    local dist = (AimMode == "Mas Cercano") and math.huge or 0
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

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

-- Bucle de renderizado (Apunta en cada frame)
RunService.RenderStepped:Connect(function()
    -- Prioridad al Aim Específico
    if SpecificTargetEnabled and SelectedTargetPlayer then
        if SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") and SelectedTargetPlayer.Character.Humanoid.Health > 0 then
            -- Apunta al pecho/cabeza
            AimAtPosition(SelectedTargetPlayer.Character.HumanoidRootPart.Position)
        else
            -- Si muere, buscamos al siguiente o pausamos
            SelectedTargetPlayer = nil
        end
    -- Si no hay específico, usa el Autónomo
    elseif AutoAimEnabled then
        local target = GetAutonomousTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            AimAtPosition(target.Character.HumanoidRootPart.Position)
        end
    end
end)

-----------------------------------------------------
-- INTERFAZ FLOTANTE (BOTONES SIGUIENTE / ATRÁS)
-----------------------------------------------------
local FloatingGUI = Instance.new("ScreenGui")
FloatingGUI.Name = "QuirurgicoGUI"
FloatingGUI.Parent = game.CoreGui
FloatingGUI.Enabled = false -- Se activa con el Switch 2

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0) -- Arriba en el centro
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.5
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
        SelectedTargetPlayer = PlayerList[CurrentTargetIndex]
        TargetNameLabel.Text = SelectedTargetPlayer.DisplayName
    else
        TargetNameLabel.Text = "Nadie en sala"
        SelectedTargetPlayer = nil
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
    CurrentTargetIndex = CurrentTargetIndex + 1
    if CurrentTargetIndex > #PlayerList then CurrentTargetIndex = 1 end
    UpdateTargetList()
end)

-- Actualizar lista si entra/sale alguien
Players.PlayerAdded:Connect(UpdateTargetList)
Players.PlayerRemoving:Connect(UpdateTargetList)

-----------------------------------------------------
-- MENÚ RAYFIELD
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "🎯 Quirúrgico Aim (Delta iOS)",
   LoadingTitle = "Cargando Aimbot...",
   LoadingSubtitle = "por IA",
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
        FloatingGUI.Enabled = Value -- Muestra/Oculta los botones flotantes
        if Value then
            UpdateTargetList()
        end
   end,
})

Rayfield:LoadConfiguration()
