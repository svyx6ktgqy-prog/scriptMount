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
   Name = "Tactical Gear: ULTRA V5.6",
   LoadingTitle = "Actualizando Sensibilidad...",
   LoadingSubtitle = "Calibrador de Precisión Ajustado",
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
-- BUILD CUSTOM MODEL FUNCTION
-- ==========================================
local function buildBinocularModel(parent, isViewModel)
    local handle = Instance.new("Part")
    handle.Name = isViewModel and "PrimaryPart" or "Handle"
    handle.Size = Vector3.new(0.3, 0.2, 0.6)
    handle.Color = Color3.fromRGB(15, 15, 15)
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Massless = true 
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Anchored = isViewModel 
    handle.Parent = parent

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

    if not isViewModel then
        local w1 = Instance.new("WeldConstraint")
        w1.Part0 = handle
        w1.Part1 = leftCyl
        w1.Parent = handle

        local w2 = Instance.new("WeldConstraint")
        w2.Part0 = handle
        w2.Part1 = rightCyl
        w2.Parent = handle
    else
        handle.Transparency = 1
        leftCyl.Transparency = 1
        rightCyl.Transparency = 1
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

           local tool = Instance.new("Tool")
           tool.Name = "Binoculars_ULTRA"
           tool.RequiresHandle = true
           tool.CanBeDropped = false
           tool.Grip = CFrame.new(0, -0.2, 0) * CFrame.Angles(0, math.pi/2, 0)

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

           -- SLIDER ZOOM
           local sliderZoomBg = Instance.new("TextButton")
           sliderZoomBg.Size = UDim2.new(0, 50, 0.6, 0)
           sliderZoomBg.Position = UDim2.new(1, -90, 0.2, 0)
           sliderZoomBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
           sliderZoomBg.BackgroundTransparency = 0.4
           sliderZoomBg.Text = ""
           sliderZoomBg.AutoButtonColor = false
           sliderZoomBg.Visible = false
           sliderZoomBg.Parent = mainGui
           Instance.new("UICorner", sliderZoomBg)

           local sliderZoomKnob = Instance.new("Frame")
           sliderZoomKnob.Size = UDim2.new(1, 0, 0, 35)
           sliderZoomKnob.Position = UDim2.new(0, 0, 1, -35)
           sliderZoomKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
           sliderZoomKnob.Active = false 
           sliderZoomKnob.Parent = sliderZoomBg
           Instance.new("UICorner", sliderZoomKnob)

           -- SLIDER SENSIBILIDAD
           local sliderSensBg = Instance.new("TextButton")
           sliderSensBg.Size = UDim2.new(0.3, 0, 0, 40)
           sliderSensBg.Position = UDim2.new(0.65, -20, 0.05, 0)
           sliderSensBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
           sliderSensBg.BackgroundTransparency = 0.4
           sliderSensBg.Text = "PRECISION x1"
           sliderSensBg.TextColor3 = Color3.fromRGB(255, 255, 255)
           sliderSensBg.Font = Enum.Font.GothamBold
           sliderSensBg.TextSize = 14
           sliderSensBg.AutoButtonColor = false
           sliderSensBg.Visible = false
           sliderSensBg.Parent = mainGui
           Instance.new("UICorner", sliderSensBg)

           local sliderSensKnob = Instance.new("Frame")
           sliderSensKnob.Size = UDim2.new(0, 35, 1, 0)
           sliderSensKnob.Position = UDim2.new(0, 0, 0, 0)
           sliderSensKnob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
           sliderSensKnob.Active = false 
           sliderSensKnob.Parent = sliderSensBg
           Instance.new("UICorner", sliderSensKnob)

           -- SYSTEM VARIABLES
           local isAiming = false
           local defaultFOV = 70
           local currentFOV = 70
           local minZoomLevel = 1.5
           local maxZoomLevel = 40 
           local targetZoomLevel = minZoomLevel 
           
           local targetZoomSliderY = 0
           local actualZoomSliderY = 0
           local draggingZoom = false
           
           -- [NUEVAS VARIABLES DE SENSIBILIDAD]
           -- Viene por default en x1 (10% de la barra)
           local targetSensPercentage = 0.1 
           local actualSensPercentage = 0.1 
           local precisionLevel = 1 
           local draggingSens = false
           
           local targetCamRotation = Vector2.new(0, 0)
           local currentCamRotation = Vector2.new(0, 0)
           
           local previousCameraMode = Player.CameraMode
           local previousCameraType = Camera.CameraType
           local renderConnection = nil
           local viewModel = nil
           local BinoDOF = nil
           
           local swayOffset = CFrame.identity
           local bobOffset = CFrame.identity
           
           -- INPUT HANDLERS
           local function updateZoomSlider(inputPos)
               local maxY = sliderZoomBg.AbsoluteSize.Y - sliderZoomKnob.AbsoluteSize.Y
               if maxY <= 0 then return end
               local relativeY = math.clamp(inputPos.Y - sliderZoomBg.AbsolutePosition.Y, 0, maxY)
               
               targetZoomSliderY = relativeY
               local percentage = relativeY / maxY
               targetZoomLevel = minZoomLevel + ((maxZoomLevel - minZoomLevel) * (1 - percentage))
           end

           local function updateSensSlider(inputPos)
               local maxX = sliderSensBg.AbsoluteSize.X - sliderSensKnob.AbsoluteSize.X
               if maxX <= 0 then return end
               
               local relativeX = math.clamp(inputPos.X - sliderSensBg.AbsolutePosition.X, 0, maxX)
               local rawPercentage = relativeX / maxX
               
               -- Snapping del x0 al x10
               precisionLevel = math.floor(rawPercentage * 10 + 0.5) 
               targetSensPercentage = precisionLevel / 10 -- Bloquea la barra en los escalones
               
               sliderSensBg.Text = "PRECISION x" .. precisionLevel
           end

           sliderZoomBg.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingZoom = true
                   updateZoomSlider(input.Position)
               end
           end)
           
           sliderSensBg.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSens = true
                   updateSensSlider(input.Position)
               end
           end)

           UserInputService.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingZoom = false
                   draggingSens = false
               end
           end)
           
           UserInputService.InputChanged:Connect(function(input)
               if draggingZoom and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   updateZoomSlider(input.Position)
               elseif draggingSens and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   updateSensSlider(input.Position)
               end

               -- LOGICA DE CAMARA CORREGIDA
               if isAiming and not draggingZoom and not draggingSens then
                   if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                       local delta = input.Delta
                       local fovRatio = currentFOV / defaultFOV
                       
                       local baseTurnSpeed = 0.005 
                       local finalMultiplier
                       
                       if precisionLevel == 0 then
                           -- [NUEVO] X0: Movimiento original, ignora la compensación de zoom y la precisión extra.
                           finalMultiplier = baseTurnSpeed
                       else
                           -- [NUEVO] X1 a X10: Multiplica el zoom y divide por la precisión.
                           finalMultiplier = (baseTurnSpeed * fovRatio) / precisionLevel
                       end
                       
                       -- Restamos el movimiento a la rotación objetivo
                       targetCamRotation -= Vector2.new(delta.Y * finalMultiplier, delta.X * finalMultiplier)
                       
                       -- Clamp al pitch (arriba/abajo) para no romper el cuello (80 grados)
                       targetCamRotation = Vector2.new(math.clamp(targetCamRotation.X, -math.rad(80), math.rad(80)), targetCamRotation.Y)
                   end
               end
           end)

           -- APUNTADO
           local function toggleAim()
               isAiming = not isAiming

               if isAiming then
                   crosshair.Visible = true
                   sliderZoomBg.Visible = true
                   sliderSensBg.Visible = true
                   
                   local maxY = sliderZoomBg.AbsoluteSize.Y - sliderZoomKnob.AbsoluteSize.Y
                   targetZoomSliderY = maxY
                   actualZoomSliderY = maxY
                   targetZoomLevel = minZoomLevel
                   
                   local pitch, yaw, roll = Camera.CFrame:ToOrientation()
                   targetCamRotation = Vector2.new(pitch, yaw)
                   currentCamRotation = Vector2.new(pitch, yaw)

                   previousCameraMode = Player.CameraMode
                   previousCameraType = Camera.CameraType
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   Camera.CameraType = Enum.CameraType.Scriptable 
                   
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
                   end
                   if viewModel then
                       for _, part in pairs(viewModel:GetDescendants()) do
                           if part:IsA("BasePart") then part.Transparency = 0 end
                       end
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
                   sliderZoomBg.Visible = false
                   sliderSensBg.Visible = false
                   if Lighting:FindFirstChild("UltraDOF") then Lighting.UltraDOF:Destroy() end
                   targetZoomLevel = 1
                   
                   Player.CameraMode = previousCameraMode
                   Camera.CameraType = previousCameraType 
                   
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
                   end
                   if viewModel then
                       for _, part in pairs(viewModel:GetDescendants()) do
                           if part:IsA("BasePart") then part.Transparency = 1 end
                       end
                   end
               end
           end

           aimButton.MouseButton1Click:Connect(function() toggleAim() end)

           local function createViewModel()
               if viewModel then viewModel:Destroy() end
               viewModel = Instance.new("Model")
               viewModel.Name = "SurgicalViewModel"

               local primary = buildBinocularModel(viewModel, true)
               viewModel.PrimaryPart = primary
               viewModel.Parent = Camera
               
               return viewModel
           end

           -- RENDER LOOP
           tool.Equipped:Connect(function()
               aimButton.Visible = true 
               createViewModel()

               renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
                   local smoothSpeed = math.clamp(15 * deltaTime, 0, 1)

                   local targetFOV = isAiming and (defaultFOV / targetZoomLevel) or defaultFOV
                   currentFOV = lerp(currentFOV, targetFOV, smoothSpeed)
                   Camera.FieldOfView = currentFOV
                   
                   local fovRatio = currentFOV / defaultFOV 

                   if isAiming then
                       -- Zoom Slider visual update
                       actualZoomSliderY = lerp(actualZoomSliderY, targetZoomSliderY, smoothSpeed)
                       sliderZoomKnob.Position = UDim2.new(0, 0, 0, actualZoomSliderY)
                       
                       -- [NUEVO] Sens Slider visual update basado en porcentaje
                       actualSensPercentage = lerp(actualSensPercentage, targetSensPercentage, smoothSpeed)
                       local maxSensX = sliderSensBg.AbsoluteSize.X - sliderSensKnob.AbsoluteSize.X
                       if maxSensX > 0 then
                           sliderSensKnob.Position = UDim2.new(0, actualSensPercentage * maxSensX, 0, 0)
                       end
                       
                       local camSmoothSpeed = math.clamp(20 * deltaTime, 0, 1)
                       currentCamRotation = currentCamRotation:Lerp(targetCamRotation, camSmoothSpeed)
                       
                       local char = Player.Character
                       if char and char:FindFirstChild("Head") then
                           local headPos = char.Head.Position + Vector3.new(0, 0.5, 0)
                           
                           Camera.CFrame = CFrame.new(headPos) * CFrame.fromOrientation(currentCamRotation.X, currentCamRotation.Y, 0)
                           
                           local rootPart = char:FindFirstChild("HumanoidRootPart")
                           if rootPart then
                               rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
                           end
                       end
                   end

                   local mouseDelta = UserInputService:GetMouseDelta()
                   local char = Player.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   local humanoid = char and char:FindFirstChild("Humanoid")

                   local swayMult = isAiming and (0.001 * fovRatio) or 0.0015
                   local targetSway = CFrame.Angles(-mouseDelta.Y * swayMult, -mouseDelta.X * swayMult, 0)
                   swayOffset = swayOffset:Lerp(targetSway, smoothSpeed)

                   local targetBob = CFrame.identity
                   if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                       local speed = rootPart.AssemblyLinearVelocity.Magnitude
                       local bobFreq = speed * 0.4
                       local bobAmp = isAiming and (0.015 * fovRatio) or 0.03
                       local bobX = math.cos(os.clock() * bobFreq) * bobAmp
                       local bobY = math.abs(math.sin(os.clock() * bobFreq)) * bobAmp
                       targetBob = CFrame.new(bobX, bobY, 0)
                   end
                   bobOffset = bobOffset:Lerp(targetBob, smoothSpeed)

                   if viewModel and viewModel.PrimaryPart then
                       local baseOffset = isAiming 
                           and CFrame.new(0, -0.4, -0.7) * CFrame.Angles(0, math.pi/2, 0)
                           or CFrame.new(0.5, -0.8, -1.2) * CFrame.Angles(0, (math.pi/12) + (math.pi/2), 0)
                           
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
           Rayfield:Notify({Title = "V5.6 ACTIVE", Content = "Calibrador de Sensibilidad x0-x10 Instalado.", Duration = 4})
       end)

       if not success then
           warn("SURGICAL ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "CRITICAL ERROR", Content = tostring(errorMessage), Duration = 6 })
       end
   end,
})
