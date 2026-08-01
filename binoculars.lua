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
   Name = "Tactical Gear: ULTRA",
   LoadingTitle = "Loading ViewModel Framework...",
   LoadingSubtitle = "AAA System",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Armory", 4483362458)

-- ==========================================
-- MATH & PROCEDURAL UTILITIES
-- ==========================================
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- ==========================================
-- CORE SCRIPT
-- ==========================================
Tab:CreateButton({
   Name = "Equip ULTRA Binoculars",
   Callback = function()
       local success, errorMessage = pcall(function()
           local character = Player.Character or Player.CharacterAdded:Wait()
           local playerGui = Player:WaitForChild("PlayerGui", 5)
           if not playerGui then error("PlayerGui no encontrado.") end
           
           if Player.Backpack:FindFirstChild("Binoculars_ULTRA") or character:FindFirstChild("Binoculars_ULTRA") then
               Rayfield:Notify({Title = "Error", Content = "Already equipped.", Duration = 3})
               return
           end

           local tool = Instance.new("Tool")
           tool.Name = "Binoculars_ULTRA"
           tool.RequiresHandle = false
           tool.CanBeDropped = false

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
           local targetZoomLevel = 1.5 
           local maxZoomLevel = 30
           
           local targetSliderY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
           local actualSliderY = targetSliderY
           local draggingSlider = false
           
           local previousCameraMode = Player.CameraMode
           local renderConnection = nil
           local viewModel = nil
           local BinoDOF = nil
           
           local userSettings = UserSettings():GetService("UserGameSettings")
           local baseSensitivity = userSettings.MouseSensitivity

           -- PROCEDURAL ANIMATION VARIABLES (El peso del arma)
           local swayOffset = CFrame.new()
           local bobOffset = CFrame.new()
           local springSpeed = 15
           
           -- GLOBAL INPUT TRACKING PARA ZOOM
           local function updateTargetSlider(inputPos)
               local minY = 0
               local maxY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
               local relativeY = math.clamp(inputPos.Y - sliderBg.AbsolutePosition.Y, minY, maxY)
               
               targetSliderY = relativeY
               local percentage = relativeY / maxY
               targetZoomLevel = 1.5 + ((maxZoomLevel - 1.5) * (1 - percentage))
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

           -- FUNCION DE APUNTADO
           local function toggleAim()
               isAiming = not isAiming

               if isAiming then
                   baseSensitivity = userSettings.MouseSensitivity 
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   if not Lighting:FindFirstChild("UltraDOF") then
                       BinoDOF = Instance.new("DepthOfFieldEffect")
                       BinoDOF.Name = "UltraDOF"
                       BinoDOF.FocusDistance = 200 
                       BinoDOF.InFocusRadius = 25 
                       BinoDOF.NearIntensity = 1 
                       BinoDOF.FarIntensity = 0.1 
                       BinoDOF.Parent = Lighting
                   end
               else
                   crosshair.Visible = false
                   sliderBg.Visible = false
                   if Lighting:FindFirstChild("UltraDOF") then Lighting.UltraDOF:Destroy() end
                   targetZoomLevel = 1
                   Player.CameraMode = previousCameraMode
                   pcall(function() userSettings.MouseSensitivity = baseSensitivity end)
               end
           end

           aimButton.MouseButton1Click:Connect(function() toggleAim() end)

           -- LOGICA DE EQUIPADO (CREACION DEL VIEWMODEL)
           tool.Equipped:Connect(function()
               aimButton.Visible = true 
               
               -- 1. Crear el ViewModel
               viewModel = Instance.new("Model")
               viewModel.Name = "TacticalViewModel"
               
               local binoPart = Instance.new("Part")
               binoPart.Name = "MainPart"
               binoPart.Size = Vector3.new(0.5, 0.5, 1)
               binoPart.Color = Color3.fromRGB(20, 20, 20)
               binoPart.Material = Enum.Material.Metal
               binoPart.Anchored = true -- Inmune a físicas
               binoPart.CanCollide = false
               binoPart.Parent = viewModel
               
               local mesh = Instance.new("SpecialMesh")
               mesh.MeshType = Enum.MeshType.FileMesh
               mesh.MeshId = "rbxassetid://13054174"
               mesh.TextureId = "rbxassetid://13054199"
               mesh.Scale = Vector3.new(1.2, 1.2, 1.2)
               mesh.Parent = binoPart

               viewModel.PrimaryPart = binoPart
               viewModel.Parent = Camera -- Se ancla a la cámara localmente

               -- 2. RenderStepped LOOP (El núcleo pesado del script)
               renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
                   -- COMPENSACIÓN DE FPS
                   local frameRatio = 60 * deltaTime
                   local smoothSpeed = math.clamp(12 * deltaTime, 0, 1)

                   -- A. MATEMATICA DE ZOOM (CALIBRE)
                   local targetFOV = isAiming and (defaultFOV / targetZoomLevel) or defaultFOV
                   currentFOV = lerp(currentFOV, targetFOV, smoothSpeed)
                   Camera.FieldOfView = currentFOV
                   
                   if isAiming then
                       actualSliderY = lerp(actualSliderY, targetSliderY, smoothSpeed)
                       sliderKnob.Position = UDim2.new(0, 0, 0, actualSliderY)
                       
                       -- Sensibilidad dinámica perfecta
                       pcall(function()
                           userSettings.MouseSensitivity = baseSensitivity * (currentFOV / defaultFOV)
                       end)
                   end

                   -- B. ANIMACIONES PROCEDURALES (SWAY Y BOBBING)
                   local mouseDelta = UserInputService:GetMouseDelta()
                   local char = Player.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   local humanoid = char and char:FindFirstChild("Humanoid")

                   -- Cálculo de Sway (Inercia al mirar)
                   local swayMult = isAiming and 0.001 or 0.003
                   local targetSway = CFrame.Angles(0, 0, 0)
                   if not isAiming then -- Solo sway libre si no está en la mira telescópica
                       targetSway = CFrame.Angles(mouseDelta.Y * swayMult, mouseDelta.X * swayMult, 0)
                   end
                   swayOffset = swayOffset:Lerp(targetSway, 0.1 * frameRatio)

                   -- Cálculo de Bobbing (Inercia al caminar)
                   local targetBob = CFrame.new()
                   if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                       local speed = rootPart.Velocity.Magnitude
                       local bobFreq = speed * 0.5
                       local bobAmp = isAiming and 0.02 or 0.08
                       local bobX = math.cos(tick() * bobFreq) * bobAmp
                       local bobY = math.abs(math.sin(tick() * bobFreq)) * bobAmp
                       targetBob = CFrame.new(bobX, bobY, 0)
                   end
                   bobOffset = bobOffset:Lerp(targetBob, 0.1 * frameRatio)

                   -- C. APLICAR TRANSFORMACIONES AL VIEWMODEL
                   if viewModel and viewModel.PrimaryPart then
                       local baseOffset = isAiming and CFrame.new(0, -0.5, -1.2) or CFrame.new(0.6, -1, -1.5)
                       -- Posición = Camara + Offset Base + Inercia de Movimiento + Inercia de Cámara
                       local finalCFrame = Camera.CFrame * baseOffset * swayOffset * bobOffset
                       viewModel:SetPrimaryPartCFrame(finalCFrame)
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
           Rayfield:Notify({Title = "ULTRA SYSTEM ACTIVE", Content = "Procedural ViewModel & DeltaTime Zoom Injected.", Duration = 5})
       end)

       if not success then
           warn("ULTRA ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "CRITICAL ERROR", Content = tostring(errorMessage), Duration = 10 })
       end
   end,
})
