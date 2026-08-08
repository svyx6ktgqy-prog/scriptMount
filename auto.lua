-- ==========================================
-- SCRIPT QUIRÚRGICO - AUTO AIM (RAYFIELD)
-- Modo: Anatomía TPS + Preservación de Offset + Predicción
-- Repo: svyx6ktgqy-prog/rayfield
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
local TargetPartName = "Cabeza"
local PredictionEnabled = true -- Predicción de movimiento
local PredictionIntensity = 0.045 -- Calibración de anticipación

-- Variables para Aim Específico
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-- Guardar C0s originales de las articulaciones anatomicas
local OriginalC0s = {}

-----------------------------------------------------
-- SELECCIÓN Y PREDICCIÓN DE OBJETIVO
-----------------------------------------------------

local function GetTargetBodyPart(character)
    if not character then return nil end
    
    if TargetPartName == "Cabeza" then
        return character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
    elseif TargetPartName == "Pecho" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    else
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    end
end

local function GetPredictedPosition(targetPart)
    if not targetPart then return nil end
    local pos = targetPart.Position
    
    if PredictionEnabled and targetPart.Parent then
        local hrp = targetPart.Parent:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Anticipación basada en la velocidad real del jugador rival
            local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity
            pos = pos + (velocity * PredictionIntensity)
        end
    end
    
    return pos
end

-----------------------------------------------------
-- ANATOMÍA REALISTA (CABEZA, CUELLO Y BRAZO)
-----------------------------------------------------

local function ApplyAnatomicalTilt(char, targetPos)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end

    local dir = (targetPos - head.Position).Unit
    local pitch = math.asin(math.clamp(dir.Y, -0.99, 0.99)) -- Ángulo vertical (Pitch)

    -- R15 Anatomy
    local neck = head:FindFirstChild("Neck")
    local upperTorso = char:FindFirstChild("UpperTorso")
    local waist = upperTorso and upperTorso:FindFirstChild("Waist")
    local rightShoulder = upperTorso and upperTorso:FindFirstChild("RightShoulder")

    if neck then
        if not OriginalC0s["Neck"] then OriginalC0s["Neck"] = neck.C0 end
        neck.C0 = OriginalC0s["Neck"] * CFrame.Angles(pitch * 0.4, 0, 0)
    end
    
    if waist then
        if not OriginalC0s["Waist"] then OriginalC0s["Waist"] = waist.C0 end
        waist.C0 = OriginalC0s["Waist"] * CFrame.Angles(pitch * 0.4, 0, 0)
    end

    if rightShoulder then
        if not OriginalC0s["RightShoulder"] then OriginalC0s["RightShoulder"] = rightShoulder.C0 end
        rightShoulder.C0 = OriginalC0s["RightShoulder"] * CFrame.Angles(pitch * 0.2, 0, 0)
    end

    -- R6 Anatomy Fallback
    local torso = char:FindFirstChild("Torso")
    if torso then
        local r6Neck = torso:FindFirstChild("Neck")
        local r6Arm = torso:FindFirstChild("Right Shoulder")
        if r6Neck then
            if not OriginalC0s["R6Neck"] then OriginalC0s["R6Neck"] = r6Neck.C0 end
            r6Neck.C0 = OriginalC0s["R6Neck"] * CFrame.Angles(pitch * 0.6, 0, 0)
        end
        if r6Arm then
            if not OriginalC0s["R6Arm"] then OriginalC0s["R6Arm"] = r6Arm.C0 end
            r6Arm.C0 = OriginalC0s["R6Arm"] * CFrame.Angles(pitch * 0.4, 0, 0)
        end
    end
end

local function RestoreAnatomy(char)
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    local upperTorso = char:FindFirstChild("UpperTorso")
    local torso = char:FindFirstChild("Torso")

    if head and head:FindFirstChild("Neck") and OriginalC0s["Neck"] then
        head.Neck.C0 = OriginalC0s["Neck"]
    end
    if upperTorso and upperTorso:FindFirstChild("Waist") and OriginalC0s["Waist"] then
        upperTorso.Waist.C0 = OriginalC0s["Waist"]
    end
    if upperTorso and upperTorso:FindFirstChild("RightShoulder") and OriginalC0s["RightShoulder"] then
        upperTorso.RightShoulder.C0 = OriginalC0s["RightShoulder"]
    end
    if torso and torso:FindFirstChild("Neck") and OriginalC0s["R6Neck"] then
        torso.Neck.C0 = OriginalC0s["R6Neck"]
    end
    if torso and torso:FindFirstChild("Right Shoulder") and OriginalC0s["R6Arm"] then
        torso["Right Shoulder"].C0 = OriginalC0s["R6Arm"]
    end
end

-----------------------------------------------------
-- APUNTADO QUIRÚRGICO TPS
-----------------------------------------------------

local function AimAtPosition(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    -- 1. Orientación de Cámara (Se respeta la posición exacta TPS con offset del hombro)
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    
    -- 2. Rotación Horizontal del Cuerpos (Pies en la tierra)
    local hrpPos = hrp.Position
    local targetFlat = Vector3.new(targetPos.X, hrpPos.Y, targetPos.Z)
    
    if (targetFlat - hrpPos).Magnitude > 0.05 then
        humanoid.AutoRotate = false
        hrp.CFrame = CFrame.lookAt(hrpPos, targetFlat)
    end

    -- 3. Inclinación Anatómica (Cabeza y Armas)
    ApplyAnatomicalTilt(char, targetPos)
end

local function ResetCharacterState()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
        RestoreAnatomy(char)
    end
end

-- Búsqueda Autónoma
local function GetAutonomousTarget()
    local target = nil
    local dist = (AimMode == "Mas Cercano") and math.huge or 0
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

    if not myPos then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetPart = GetTargetBodyPart(p.Character)
            if targetPart then
                local d = (myPos - targetPart.Position).Magnitude
                if AimMode == "Mas Cercano" and d < dist then
                    dist = d
                    target = p
                elseif AimMode == "Mas Lejano" and d > dist then
                    dist = d
                    target = p
                end
            end
        end
    end
    return target
end

-- Render Loop Principal
RunService.RenderStepped:Connect(function()
    local isAiming = false

    if SpecificTargetEnabled and SelectedTargetPlayer then
        local targetChar = SelectedTargetPlayer.Character
        if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
            local targetPart = GetTargetBodyPart(targetChar)
            if targetPart then
                local finalPos = GetPredictedPosition(targetPart)
                AimAtPosition(finalPos)
                isAiming = true
            end
        else
            SelectedTargetPlayer = nil
        end
    elseif AutoAimEnabled then
        local target = GetAutonomousTarget()
        if target and target.Character then
            local targetPart = GetTargetBodyPart(target.Character)
            if targetPart then
                local finalPos = GetPredictedPosition(targetPart)
                AimAtPosition(finalPos)
                isAiming = true
            end
        end
    end

    if not isAiming then
        ResetCharacterState()
    end
end)

-----------------------------------------------------
-- INTERFAZ FLOTANTE
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
   Name = "🎯 Quirúrgico Aim (Delta iOS)",
   LoadingTitle = "Cargando Aimbot...",
   LoadingSubtitle = "Calibración TPS + Anatomía",
   ConfigurationSaving = {
      Enabled = false
   }
})

local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateSection("Calibración de Precisión")

TabAim:CreateDropdown({
   Name = "Parte del Cuerpo Target",
   Options = {"Cabeza", "Pecho", "Centro"},
   CurrentOption = {"Cabeza"},
   MultipleOptions = false,
   Flag = "DropBodyPart",
   Callback = function(Option)
        TargetPartName = Option[1]
   end,
})

TabAim:CreateToggle({
   Name = "Predicción de Movimiento (Anticipación)",
   CurrentValue = true,
   Flag = "TogglePrediction",
   Callback = function(Value)
        PredictionEnabled = Value
   end,
})

TabAim:CreateSection("Auto-Aim Autónomo")

TabAim:CreateToggle({
   Name = "Activar Auto-Mira (Autónoma)",
   CurrentValue = false,
   Flag = "ToggleAutoAim", 
   Callback = function(Value)
        AutoAimEnabled = Value
        if not Value and not SpecificTargetEnabled then
            ResetCharacterState()
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
            ResetCharacterState()
        end
   end,
})

Rayfield:LoadConfiguration()
