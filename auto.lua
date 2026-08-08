-- ==========================================
-- SCRIPT QUIRÚRGICO (DELTA IOS)
-- Modo: Filtro Terrain/Bus + Autofire Forzado
-- Repo: svyx6ktgqy-prog/rayfield
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuración de Filtro del BUS y TERRAIN
local BUS_Y_THRESHOLD = 255.19400024414062 -- Altura máxima de la losa
local MIN_TERRAIN_Y = -100 -- Límite inferior para evitar caídas al vacío

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
-- LÓGICA DE DETECCIÓN: TERRAIN A LOSA DEL BUS
-----------------------------------------------------

local function IsTargetInValidZone(targetChar)
    if not targetChar then return false end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local pos = hrp.Position

    -- 1. Verificar límites de altura (Debajo de la losa del Bus y sobre el Terrain)
    if pos.Y >= BUS_Y_THRESHOLD or pos.Y <= MIN_TERRAIN_Y then
        return false
    end

    -- 2. Raycast hacia abajo para verificar que hay Terrain o suelo debajo del jugador
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {targetChar}

    local rayResult = Workspace:Raycast(pos, Vector3.new(0, -50, 0), raycastParams)
    
    if rayResult then
        -- Si colisiona con el Terrain o una parte debajo de la losa, la zona es válida
        return rayResult.Instance:IsA("Terrain") or rayResult.Position.Y < BUS_Y_THRESHOLD
    end

    return false
end

-----------------------------------------------------
-- AUTO-EQUIPAR
-----------------------------------------------------

local function EnsureWeaponEquipped()
    if not AutoEquipEnabled then return nil end

    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    -- Buscar en Personaje
    local equippedTool = char:FindFirstChild(TargetWeaponName) or char:FindFirstChildOfClass("Tool")
    if equippedTool then return equippedTool end

    -- Buscar en Mochila
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local backpackTool = backpack:FindFirstChild(TargetWeaponName) or backpack:FindFirstChildOfClass("Tool")
        if backpackTool then
            humanoid:EquipTool(backpackTool)
            return backpackTool
        end
    end

    return nil
end

-----------------------------------------------------
-- DISPARO FORZADO (BYPASS MÉTODOS DE ARMA)
-----------------------------------------------------

local function ForceFireWeapon(tool)
    if not tool then return end

    -- Método 1: Activación estándar de Tool
    tool:Activate()

    -- Método 2: Forzar RemoteEvents internos del arma si existen
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local name = child.Name:lower()
            if name:find("fire") or name:find("shoot") or name:find("use") or name:find("activate") or name:find("bullet") then
                child:FireServer(Camera.CFrame.LookVector)
            end
        end
    end

    -- Método 3: Simular disparo mediante VirtualUser
    VirtualUser:Button1Down(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
    task.delay(0.01, function()
        VirtualUser:Button1Up(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
    end)
end

-----------------------------------------------------
-- OBTENCIÓN Y MIRA DE OBJETIVO
-----------------------------------------------------

local function GetTargetBodyPart(character)
    if not character then return nil end
    if TargetPartName == "Cabeza" then
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    elseif TargetPartName == "Pecho" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    else
        return character:FindFirstChild("HumanoidRootPart")
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
            -- Solo considerar objetivos dentro de la zona válida
            if IsTargetInValidZone(p.Character) then
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
    end
    return target
end

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

    -- VERIFICACIÓN ESTRECHA DE ZONA
    if AutoTeleportEnabled and IsTargetInValidZone(targetPlayer.Character) then
        local backCFrame = targetHrp.CFrame * CFrame.new(0, 0, TeleportDistance)
        myHrp.CFrame = CFrame.new(backCFrame.Position, targetHrp.Position)
    else
        -- Apuntado rotacional sin teleport si no cumple los requisitos de terreno
        local hrpPos = myHrp.Position
        local targetFlat = Vector3.new(targetPos.X, hrpPos.Y, targetPos.Z)
        if (targetFlat - hrpPos).Magnitude > 0.05 then
            myHumanoid.AutoRotate = false
            myHrp.CFrame = CFrame.lookAt(hrpPos, targetFlat)
        end
    end

    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

local function ResetCharacterState()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.AutoRotate = true end
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
-- BUCLE DE DISPARO RÁPIDO
-----------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not AutoFireTouchEnabled then return end

    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsTouchingScreen = true
        
        task.spawn(function()
            while IsTouchingScreen and AutoFireTouchEnabled do
                local tool = EnsureWeaponEquipped()
                if tool then
                    ForceFireWeapon(tool)
                end
                task.wait(0.01) -- Cadencia ultrarrápida
            end
        end)
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
    if CurrentTargetIndex > #PlayerList then CurrentTargetIndex = #PlayerList end
    UpdateTargetList()
end)

Players.PlayerAdded:Connect(UpdateTargetList)
Players.PlayerRemoving:Connect(UpdateTargetList)

-----------------------------------------------------
-- MENÚ RAYFIELD
-----------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "🎯 Quirúrgico Terrain + Rapid Fire",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "Detección Terrain y Touch Fire Bypass",
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

TabMain:CreateSection("Teleport Filtro Terrain/Bus")

TabMain:CreateToggle({
   Name = "Activar Teleport (Solo Terrain < Bus)",
   CurrentValue = true,
   Flag = "ToggleTeleport",
   Callback = function(Value)
        AutoTeleportEnabled = Value
   end,
})

TabMain:CreateToggle({
   Name = "Activar Selector Específico GUI",
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

TabMain:CreateSection("Control de Arma y Auto-Fire")

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
   Name = "Disparo Ultra-Rápido por Toque",
   CurrentValue = true,
   Flag = "ToggleAutofireTouch",
   Callback = function(Value)
        AutoFireTouchEnabled = Value
   end,
})

Rayfield:LoadConfiguration()
