-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tactical Gear: ULTRA V3",
   LoadingTitle = "Fixing Physics Engine...",
   LoadingSubtitle = "Surgical Zoom System",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Armory", 4483362458)

-- ==========================================
-- MATH UTILITIES
-- ==========================================
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- ==========================================
-- BUILD CUSTOM MODEL FUNCTION (Dual Mode)
-- ==========================================
-- isViewModel nos dice si creamos la versión para la mano (con físicas) o para la cámara (sin físicas)
local function buildBinocularModel(parent, isViewModel)
    -- 1. Pieza Central (Handle)
    local handle = Instance.new("Part")
    handle.Name = isViewModel and "PrimaryPart" or "Handle"
    handle.Size = Vector3.new(0.3, 0.2, 0.6)
    handle.Color = Color3.fromRGB(15, 15, 15)
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Massless = true -- CRÍTICO: Evita alterar el peso del personaje
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Anchored = isViewModel -- Solo lo anclamos si es para la cámara
    handle.Parent = parent

    -- 2. Cilindro Izquierdo
    local leftCyl = Instance.new("Part")
    leftCyl.Name = "LeftBarrel"
    leftCyl.Shape = Enum.PartType.Cylinder
    leftCyl.Size = Vector3.new(1.2, 0.4, 0.4)
    leftCyl.Color = Color3.fromRGB(5, 5, 5)
    leftCyl.Material = Enum.Material.Plastic
    leftCyl.CFrame = handle.CFrame * CFrame.new(0, 0, -0.35)
    leftCyl.CanCollide = false
    leftCyl.Massless = true
    leftCyl.CanTouch = false
    leftCyl.CanQuery = false
    leftCyl.Anchored = isViewModel
    leftCyl.Parent = parent

    -- 3. Cilindro Derecho
    local rightCyl = Instance.new("Part")
    rightCyl.Name = "RightBarrel"
    rightCyl.Shape = Enum.PartType.Cylinder
    rightCyl.Size = Vector3.new(1.2, 0.4, 0.4)
    rightCyl.Color = Color3.fromRGB(5, 5, 5)
    rightCyl.Material = Enum.Material.Plastic
    rightCyl.CFrame = handle.CFrame * CFrame.new(0, 0, 0.35)
    rightCyl.CanCollide = false
    rightCyl.Massless = true
    rightCyl.CanTouch = false
    rightCyl.CanQuery = false
    rightCyl.Anchored = isViewModel
    rightCyl.Parent = parent

    -- Solo soldamos el modelo de la mano. El ViewModel no requiere soldaduras porque PivotTo mueve todo el Modelo junto.
    if not isViewModel then
        local w1 = Instance.new("WeldConstraint")
        w1.Part0 = handle
        w1.Part1 = leftCyl
        w1.Parent = handle

        local w2 = Instance.new("WeldConstraint")
        w2.Part0 = handle
        w2.Part1 = rightCyl
        w2.Parent = handle
    end

    return handle
end

-- ==========================================
-- CORE SCRIPT
-- ==========================================
Tab:CreateButton({
   Name = "Equip SURGICAL Binoculars",
   Callback = function()
       local success, errorMessage = pcall(function()
           local character = Player.Character or Player.CharacterAdded:Wait()
           local playerGui = Player:WaitForChild("PlayerGui", 5)
           
           if Player.Backpack:FindFirstChild("Binoculars_ULTRA") or character:FindFirstChild("Binoculars_ULTRA") then
               Rayfield:Notify({Title = "Error", Content = "Already equipped.", Duration = 3})
               return
           end

           -- CREACIÓN DE TOOL FÍSICA PARA LA MANO
           local tool = Instance.new("Tool")
           tool.Name = "Binoculars_ULTRA"
           tool.RequiresHandle = true
           tool.CanBeDropped = false
           tool.Grip = CFrame.new(0, -0.2, 0) * CFrame.Angles(0, math.pi/2, 0)

           -- Construimos modelo de la mano (isViewModel = false)
           buildBinocularModel(tool, false)

           -- UI SETUP
           if playerGui:FindFirstChild("BinoUltraUI") then playerGui.BinoUltraUI:Destroy() end
           local mainGui = Instance.new("ScreenGui")
           mainGui.Name = "BinoUltraUI"
           mainGui.ResetOnSpawn = false
           mainGui.Parent = playerGui

           local aimButton = Instance.new("TextButton")
           aimButton.Size = UDim2.new(0, 80, 0, 80)
           aimButton.Position = UDim2.new(0.5, 120, 0.75, 0)
           aimButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
           aimButton.BackgroundTransparency = 0.2
           aimButton.Text = "AIM"
           aimButton.TextColor3 = Color3.fromRGB(255, 200, 0)
           aimButton.Font = Enum.Font.GothamBlack
           aimButton.TextSize = 22
           Instance.new("UICorner", aimButton).CornerRadius = UDim.new(1, 0)
           aimButton.Visible = false
           aimButton.Parent = mainGui

           local crosshair = Instance.new("ImageLabel")
           crosshair.Size = UDim2.new(1, 0, 1, 0)
           crosshair.BackgroundTransparency = 1
           crosshair.Image = "rbxassetid://9036711587"
           crosshair.ScaleType = Enum.ScaleType.Stretch
           crosshair.Visible = false
           crosshair.Parent = mainGui

           local sliderBg = Instance.new("Frame")
           sliderBg.Size = UDim2.new(0, 40, 0.6, 0)
           sliderBg.Position = UDim2.new(1, -80, 0.2, 0)
           sliderBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
           sliderBg.BackgroundTransparency = 0.4
           sliderBg.Visible = false
           sliderBg.Parent = mainGui
           Instance.new("UICorner", sliderBg)

           local touchZone = Instance.new("TextButton")
           touchZone.Size = UDim2.new(4, 0, 1, 100)
           touchZone.Position = UDim2.new(0.5, 0, 0.5, 0)
           touchZone.AnchorPoint = Vector2.new(0.5, 0.5)
           touchZone.BackgroundTransparency = 1
           touchZone.Text = ""
           touchZone.Parent = sliderBg

           local sliderKnob = Instance.new("Frame")
           sliderKnob.Size = UDim2.new(1, 0, 0, 25)
           sliderKnob.Position = UDim2.new(0, 0, 1, -25)
           sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
           sliderKnob.Parent = sliderBg
           Instance.new("UICorner", sliderKnob)

           -- SYSTEM VARIABLES
           local isAiming = false
           local defaultFOV = 70
           local currentFOV = 70
           local minZoomLevel = 1.5
           local maxZoomLevel = 40 
           local targetZoomLevel = minZoomLevel 
           
           local targetSliderY = 0
           local actualSliderY = 0
           local draggingSlider = false
           
           local previousCameraMode = Player.CameraMode
           local renderConnection = nil
           local viewModel = nil
           local BinoDOF = nil
           
           local userSettings = UserSettings():GetService("UserGameSettings")
           local baseSensitivity = userSettings.MouseSensitivity

           -- PROCEDURAL ANIMATIONS
           local swayOffset = CFrame.identity
           local bobOffset = CFrame.identity
           
           -- INPUT SLIDER
           local function updateTargetSlider(inputPos)
               local maxY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
               if maxY <= 0 then return end
               local relativeY = math.clamp(inputPos.Y - sliderBg.AbsolutePosition.Y, 0, maxY)
               
               targetSliderY = relativeY
               local percentage = relativeY / maxY
               targetZoomLevel = minZoomLevel + ((maxZoomLevel - minZoomLevel) * (1 - percentage))
           end

           touchZone.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSlider = true
                   updateTargetSlider(input.Position)
               end
           end)
           
           UserInputService.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSlider = false
               end
           end)
           
           UserInputService.InputChanged:Connect(function(input)
               if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   updateTargetSlider(input.Position)
               end
           end)

           -- APUNTADO & SENSIBILIDAD
           local function toggleAim()
               isAiming = not isAiming

               if isAiming then
                   baseSensitivity = userSettings.MouseSensitivity 
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   
                   local maxY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
                   targetSliderY = maxY
                   actualSliderY = maxY
                   targetZoomLevel = minZoomLevel

                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   -- Ocultamos el modelo de tu mano (Modo FPS)
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
                   end

                   if not Lighting:FindFirstChild("UltraDOF") then
                       BinoDOF = Instance.new("DepthOfFieldEffect")
                       BinoDOF.Name = "UltraDOF"
                       BinoDOF.FocusDistance = 300 
                       BinoDOF.InFocusRadius = 15 
                       BinoDOF.NearIntensity = 0.9 
                       BinoDOF.FarIntensity = 0.2 
                       BinoDOF.Parent = Lighting
                   end
               else
                   crosshair.Visible = false
                   sliderBg.Visible = false
                   if Lighting:FindFirstChild("UltraDOF") then Lighting.UltraDOF:Destroy() end
                   targetZoomLevel = 1
                   Player.CameraMode = previousCameraMode
                   
                   -- Restauramos la visibilidad del modelo en tu mano (Modo 3ra persona)
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
                   end

                   pcall(function() userSettings.MouseSensitivity = baseSensitivity end)
               end
           end

           aimButton.MouseButton1Click:Connect(function() toggleAim() end)

           -- CREAR VIEWMODEL (Reescrito: totalmente independiente, sin clonar piezas)
           local function createViewModel()
               if viewModel then viewModel:Destroy() end
               viewModel = Instance.new("Model")
               viewModel.Name = "SurgicalViewModel"

               -- Construimos modelo para cámara (isViewModel = true)
               local primary = buildBinocularModel(viewModel, true)
               viewModel.PrimaryPart = primary
               viewModel.Parent = Camera
               
               return viewModel
           end

           -- LOGICA DE EQUIPADO
           tool.Equipped:Connect(function()
               aimButton.Visible = true 
               createViewModel()

               renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
                   local smoothSpeed = math.clamp(12 * deltaTime, 0, 1)

                   -- FOV & SURGICAL SENSITIVITY
                   local targetFOV = isAiming and (defaultFOV / targetZoomLevel) or defaultFOV
                   currentFOV = lerp(currentFOV, targetFOV, smoothSpeed)
                   Camera.FieldOfView = currentFOV
                   
                   if isAiming then
                       actualSliderY = lerp(actualSliderY, targetSliderY, smoothSpeed)
                       sliderKnob.Position = UDim2.new(0, 0, 0, actualSliderY)
                       
                       local fovRatio = currentFOV / defaultFOV 
                       local surgicalFactor = math.pow(fovRatio, 1.25)
                       
                       pcall(function()
                           userSettings.MouseSensitivity = math.clamp(baseSensitivity * surgicalFactor, 0.001, baseSensitivity)
                       end)
                   end

                   -- PROCEDURAL SWAY & BOBBING
                   local mouseDelta = UserInputService:GetMouseDelta()
                   local char = Player.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   local humanoid = char and char:FindFirstChild("Humanoid")

                   local swayMult = isAiming and 0.0003 or 0.0015
                   local targetSway = CFrame.Angles(-mouseDelta.Y * swayMult, -mouseDelta.X * swayMult, 0)
                   swayOffset = swayOffset:Lerp(targetSway, smoothSpeed)

                   local targetBob = CFrame.identity
                   if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                       local speed = rootPart.AssemblyLinearVelocity.Magnitude
                       local bobFreq = speed * 0.4
                       local bobAmp = isAiming and 0.003 or 0.03
                       local bobX = math.cos(os.clock() * bobFreq) * bobAmp
                       local bobY = math.abs(math.sin(os.clock() * bobFreq)) * bobAmp
                       targetBob = CFrame.new(bobX, bobY, 0)
                   end
                   bobOffset = bobOffset:Lerp(targetBob, smoothSpeed)

                   -- RENDERIZADO DEL VIEWMODEL
                   if viewModel and viewModel.PrimaryPart then
                       local baseOffset = isAiming and CFrame.new(0, -0.3, -0.6) or CFrame.new(0.5, -0.8, -1.2) * CFrame.Angles(0, math.pi/12, 0)
                       local finalCFrame = Camera.CFrame * baseOffset * swayOffset * bobOffset
                       viewModel:PivotTo(finalCFrame)
                   end
               end)
           end)

           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               if isAiming then toggleAim() end
               if renderConnection then renderConnection:Disconnect() renderConnection = nil end
               if viewModel then viewModel:Destroy() viewModel = nil end
               Camera.FieldOfView = defaultFOV
           end)

           tool.Parent = Player.Backpack
           Rayfield:Notify({Title = "PHYSICS PATCHED", Content = "Stable Tool + ViewModel generated independently.", Duration = 4})
       end)

       if not success then
           warn("SURGICAL ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "CRITICAL ERROR", Content = tostring(errorMessage), Duration = 6 })
       end
   end,
})
