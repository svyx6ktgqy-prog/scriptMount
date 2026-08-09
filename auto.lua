-- ==========================================
-- SCRIPT QUIRÚRGICO (DELTA IOS)
-- Modo: Aim Autónomo + Pegado Espalda + Auto-Equip + Multi-Bypass Fire
-- Repo: svyx6ktgqy-prog/rayfield
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables de Estado
local AutoAimEnabled = false
local AimMode = "Mas Cercano"
local SpecificTargetEnabled = false
local TargetPartName = "Cabeza"
local AutoTeleportEnabled = true
local TeleportDistance = 3.0

local AutoEquipEnabled = true
local TargetWeaponName = "Crossbow"
local AutoFireTouchEnabled = true
local IsTouchingScreen = false

-- Variables para Selector
local PlayerList = {}
local CurrentTargetIndex = 1
local SelectedTargetPlayer = nil

-----------------------------------------------------
-- LÓGICA DE AUTO-EQUIPAMIENTO DE ARMA
-----------------------------------------------------

local function EnsureWeaponEquipped()
    if not AutoEquipEnabled then return nil end

    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    -- 1. Verificar si ya está equipada
    local equippedTool = char:FindFirstChild(TargetWeaponName)
    if equippedTool and equippedTool:IsA("Tool") then
        return equippedTool
    end

    -- 2. Buscar en Mochila (Backpack)
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local backpackTool = backpack:FindFirstChild(TargetWeaponName)
        if backpackTool and backpackTool:IsA("Tool") then
            humanoid:EquipTool(backpackTool)
            return backpackTool
        end
    end

    -- 3. Fallback a cualquier Tool
    local fallbackTool = char:FindFirstChildOfClass("Tool")
    if fallbackTool then return fallbackTool end

    if backpack then
        local anyTool = backpack:FindFirstChildOfClass("Tool")
        if anyTool then
            humanoid:EquipTool(anyTool)
            return anyTool
        end
    end

    return nil
end

-----------------------------------------------------
-- OBTENCIÓN DE OBJETIVO Y PARTE
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

-----------------------------------------------------
-- APUNTADO AUTÓNOMO Y TELEPORT
-----------------------------------------------------

local function ProcessAimAndTeleport(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    if not myHrp or not myHumanoid then return end

    local targetPart = GetTargetBodyPart(targetPlayer.Character)
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart or not targetHrp then return end

    local targetPos = targetPart.Position

    -- 1. Teleport a la Espalda (si está activo)
    if AutoTeleportEnabled then
        local backCFrame = targetHrp.CFrame * CFrame.new(0, 0, TeleportDistance)
        myHrp.CFrame = CFrame.new(backCFrame.Position, targetHrp.Position)
    else
        local hrpPos = myHrp.Position
        local targetFlat = Vector3.new(targetPos.X, hrpPos.Y, targetPos.Z)
        if (targetFlat - hrpPos).Magnitude > 0.05 then
            myHumanoid.AutoRotate = false
            myHrp.CFrame = CFrame.lookAt(hrpPos, targetFlat)
        end
    end

    -- 2. Aim CÁMARA (Mira orientada directamente a la parte elegida)
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

local function ResetCharacterState()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

-- Bucle Principal
RunService.RenderStepped:Connect(function()
    EnsureWeaponEquipped()

    local targetToProcess = nil

    if SpecificTargetEnabled and SelectedTargetPlayer then
        targetToProcess = SelectedTargetPlayer
    elseif AutoAimEnabled then
        targetToProcess = GetAutonomousTarget()
    end

    if targetToProcess and targetToProcess.Character and targetToProcess.Character:FindFirstChild("Humanoid") and targetToProcess.Character.Humanoid.Health > 0 then
        ProcessAimAndTeleport(targetToProcess)
    else
        ResetCharacterState()
    end
end)

-----------------------------------------------------
-- SISTEMA MULTI-BYPASS PARA ARMAS ESPECIALES Y REMOTAS
-----------------------------------------------------

local function ExecuteWeaponFire(tool, touchPosition)
    if not tool then return end

    -- MÉTODO 1: Activación nativa de Tool
    tool:Activate()

    -- MÉTODO 2: Búsqueda y ejecución de RemoteEvents / RemoteFunctions del arma
    for _, item in ipairs(tool:GetDescendants()) do
        if item:IsA("RemoteEvent") then
            local name = item.Name:lower()
            if name:find("fire") or name:find("shoot") or name:find("use") or name:find("activate") or name:find("bullet") or name:find("attack") then
                item:FireServer(Camera.CFrame.LookVector, touchPosition or Camera.CFrame.Position)
            end
        elseif item:IsA("RemoteFunction") then
            local name = item.Name:lower()
            if name:find("fire") or name:find("shoot") or name:find("use") then
                pcall(function()
                    item:InvokeServer(Camera.CFrame.LookVector, touchPosition or Camera.CFrame.Position)
                end)
            end
        end
    end

    -- MÉTODO 3: Simulación de Clic Físico con VirtualUser en la coordenada del toque
    local clickPos = touchPosition and Vector2.new(touchPosition.X, touchPosition.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    VirtualUser:Button1Down(clickPos)
    task.delay(0.01, function()
        VirtualUser:Button1Up(clickPos)
    end)
end

-----------------------------------------------------
-- AUTOCLICK DE DISPARO AL TOCAR FORA DE BOTONES
-----------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Descarta el toque si fue realizado sobre un botón o elemento del juego / executor
    if gameProcessed then return end
    if not AutoFireTouchEnabled then return end

    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsTouchingScreen = true
        local currentTouchPos = input.Position

        -- Bucle rápido de disparo continuo mientras se mantenga presionada la pantalla
        task.spawn(function()
            while IsTouchingScreen and AutoFireTouchEnabled do
                local tool = EnsureWeaponEquipped()
                if tool then
                    ExecuteWeaponFire(tool, currentTouchPos)
                end
                task.wait(0.01) -- Velocidad ultrarrápida
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsTouchingScreen and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        -- Actualizar posición por si el usuario arrastra el dedo por la pantalla
        input = input
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsTouchingScreen = false
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
   Name = "🎯 Quirúrgico Aim + Teleport",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "Auto Aim + Auto Equip",
   ConfigurationSaving = {
      Enabled = false
   }
})

local TabMain = Window:CreateTab("Principal", 4483362458)

TabMain:CreateSection("Auto-Aim Autónomo")

TabMain:CreateToggle({
   Name = "Activar Auto-Aim (Mira Autónoma)",
   CurrentValue = false,
   Flag = "ToggleAutoAim", 
   Callback = function(Value)
        AutoAimEnabled = Value
        if not Value and not SpecificTargetEnabled then
            ResetCharacterState()
        end
   end,
})

TabMain:CreateDropdown({
   Name = "Parte del Cuerpo Target",
   Options = {"Cabeza", "Pecho", "Centro"},
   CurrentOption = {"Cabeza"},
   MultipleOptions = false,
   Flag = "DropBodyPart",
   Callback = function(Option)
        TargetPartName = Option[1]
   end,
})

TabMain:CreateDropdown({
   Name = "Prioridad de Objetivo",
   Options = {"Mas Cercano", "Mas Lejano"},
   CurrentOption = {"Mas Cercano"},
   MultipleOptions = false,
   Flag = "DropPrioridad",
   Callback = function(Option)
        AimMode = Option[1]
   end,
})

TabMain:CreateSection("Teleport & Selector")

TabMain:CreateToggle({
   Name = "Activar Pegado a Espalda",
   CurrentValue = true,
   Flag = "ToggleTeleport",
   Callback = function(Value)
        AutoTeleportEnabled = Value
   end,
})

TabMain:CreateToggle({
   Name = "Activar Selector Especifico GUI",
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

TabMain:CreateSlider({
   Name = "Distancia a Espalda",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = " studs",
   CurrentValue = 3,
   Flag = "SliderDist",
   Callback = function(Value)
        TeleportDistance = Value
   end,
})

TabMain:CreateSection("Control de Arma e Inventario")

TabMain:CreateToggle({
   Name = "Auto-Equipar Arma Siempre",
   CurrentValue = true,
   Flag = "ToggleAutoEquip",
   Callback = function(Value)
        AutoEquipEnabled = Value
   end,
})

TabMain:CreateInput({
   Name = "Nombre del Arma Objetiva",
   PlaceholderText = "Crossbow",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        if Text and #Text > 0 then
            TargetWeaponName = Text
        end
   end,
})

TabMain:CreateToggle({
   Name = "Disparar al Tocar Pantalla",
   CurrentValue = true,
   Flag = "ToggleAutofireTouch",
   Callback = function(Value)
        AutoFireTouchEnabled = Value
   end,
})

Rayfield:LoadConfiguration()
