-- ==========================================
-- SCRIPT QUIRÚRGICO V2 - AUTO AIM (RAYFIELD)
-- Corregido: Registro de daño y Cámara en 3ra Persona
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables de Estado
local AutoAimEnabled = false
local AimMode = "Mas Cercano"
local SpecificTargetEnabled = false
local Smoothness = 0.5 -- Suavidad por defecto (50%)

-- Variables para el Aim Específico
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-----------------------------------------------------
-- LÓGICA MATEMÁTICA (MOTOR CORREGIDO)
-----------------------------------------------------

-- Función para apuntar suavemente (Evita primera persona y registra daño)
local function AimAtPosition(targetPosition)
    -- 1. Obtenemos a dónde debería mirar la cámara, manteniendo su posición actual en el espacio
    local currentPosition = Camera.CFrame.Position
    local targetCFrame = CFrame.lookAt(currentPosition, targetPosition)
    
    -- 2. Usamos Lerp para hacer una transición suave. 
    -- Esto evita que nuestro script rompa la cámara en tercera persona del juego.
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Smoothness)
    
    -- NOTA: Ya no forzamos la rotación del HumanoidRootPart. 
    -- El juego lo rotará naturalmente al mover la cámara, solucionando el problema de que no cuente el daño.
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

-- Bucle de renderizado
RunService.RenderStepped:Connect(function()
    if SpecificTargetEnabled and SelectedTargetPlayer then
        if SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") and SelectedTargetPlayer.Character.Humanoid.Health > 0 then
            AimAtPosition(SelectedTargetPlayer.Character.HumanoidRootPart.Position)
        else
            SelectedTargetPlayer = nil
        end
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
FloatingGUI.Enabled = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0)
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

Players.PlayerAdded:Connect(UpdateTargetList)
Players.PlayerRemoving:Connect(UpdateTargetList)

-----------------------------------------------------
-- MENÚ RAYFIELD
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "🎯 Quirúrgico Aim V2",
   LoadingTitle = "Inyectando Quirúrgico...",
   LoadingSubtitle = "Anti-Desync",
   ConfigurationSaving = { Enabled = false }
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

TabAim:CreateSlider({
   Name = "Suavidad (Evitar bug de cámara)",
   Range = {1, 10},
   Increment = 1,
   Suffix = "Fuerza",
   CurrentValue = 5,
   Flag = "SliderSmooth",
   Callback = function(Value)
        -- Convertimos el 1-10 en 0.1 a 1.0 para el Lerp matemático
        Smoothness = Value / 10
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
        end
   end,
})

Rayfield:LoadConfiguration()
