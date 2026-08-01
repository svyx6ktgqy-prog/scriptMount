-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService") 
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tactical Gear Menu",
   LoadingTitle = "Loading System...",
   LoadingSubtitle = "Delta Executor",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Armory", 4483362458)

Tab:CreateButton({
   Name = "Equip Official Binoculars",
   Callback = function()
       local success, errorMessage = pcall(function()
           local character = Player.Character or Player.CharacterAdded:Wait()
           local playerGui = Player:WaitForChild("PlayerGui", 5)
           
           if not playerGui then error("PlayerGui no encontrado.") end

           if Player.Backpack:FindFirstChild("Binoculars") or character:FindFirstChild("Binoculars") then
               Rayfield:Notify({Title = "Already Equipped", Content = "You already have the item.", Duration = 3})
               return
           end

           -- 1. CREAR EL TOOL SIN HANDLE
           local tool = Instance.new("Tool")
           tool.Name = "Binoculars"
           tool.RequiresHandle = false
           tool.CanBeDropped = false

           -- 2. Create the GUI System
           if playerGui:FindFirstChild("BinocularsSystemUI") then
               playerGui.BinocularsSystemUI:Destroy()
           end

           local mainGui = Instance.new("ScreenGui")
           mainGui.Name = "BinocularsSystemUI"
           mainGui.ResetOnSpawn = false
           mainGui.Parent = playerGui

           local aimButton = Instance.new("TextButton")
           aimButton.Size = UDim2.new(0, 80, 0, 80)
           aimButton.Position = UDim2.new(0.5, 100, 0.8, 0)
           aimButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
           aimButton.BackgroundTransparency = 0.3
           aimButton.Text = "AIM"
           aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
           aimButton.Font = Enum.Font.GothamBold
           aimButton.TextSize = 24
           Instance.new("UICorner", aimButton).CornerRadius = UDim.new(1, 0)
           aimButton.Visible = false
           aimButton.Parent = mainGui

           local crosshair = Instance.new("ImageLabel")
           crosshair.Size = UDim2.new(1, 0, 1, 0)
           crosshair.Position = UDim2.new(0, 0, 0, 0)
           crosshair.BackgroundTransparency = 1
           crosshair.Image = "rbxassetid://9036711587" 
           crosshair.ScaleType = Enum.ScaleType.Stretch
           crosshair.Visible = false
           crosshair.Parent = mainGui

           local sliderBg = Instance.new("Frame")
           sliderBg.Size = UDim2.new(0, 30, 0.5, 0)
           sliderBg.Position = UDim2.new(1, -60, 0.25, 0)
           sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
           sliderBg.BackgroundTransparency = 0.5
           sliderBg.Visible = false
           sliderBg.Parent = mainGui
           Instance.new("UICorner", sliderBg)

           local touchZone = Instance.new("TextButton")
           touchZone.Size = UDim2.new(4, 0, 1, 40)
           touchZone.Position = UDim2.new(0.5, 0, 0.5, 0)
           touchZone.AnchorPoint = Vector2.new(0.5, 0.5)
           touchZone.BackgroundTransparency = 1
           touchZone.Text = ""
           touchZone.Parent = sliderBg

           local sliderKnob = Instance.new("Frame")
           sliderKnob.Size = UDim2.new(1, 0, 0, 20)
           sliderKnob.Position = UDim2.new(0, 0, 1, -20)
           sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
           sliderKnob.Parent = sliderBg
           Instance.new("UICorner", sliderKnob)

           -- 3. Logic & State Variables
           local isAiming = false
           local defaultFOV = 70
           local currentZoomLevel = 2 
           local maxZoomLevel = 20 
           local aimAnimConnection = nil
           local originalRightShoulderC0 = nil
           local draggingSlider = false
           local previousCameraMode = Player.CameraMode
           local binoVisual = nil 
           local BinoDOF = nil
           
           -- Sistema de Sensibilidad
           local userSettings = UserSettings():GetService("UserGameSettings")
           local baseSensitivity = userSettings.MouseSensitivity

           local function getRightShoulder()
               local char = Player.Character
               if not char then return nil end
               local rightUpper = char:FindFirstChild("RightUpperArm")
               local torso = char:FindFirstChild("Torso")
               if rightUpper then return rightUpper:FindFirstChild("RightShoulder")
               elseif torso then return torso:FindFirstChild("Right Shoulder") end
               return nil
           end

           -- 4. Función de Apuntado
           local function toggleAim(forceOff)
               if forceOff then isAiming = false else isAiming = not isAiming end

               local rightShoulder = getRightShoulder()

               if isAiming then
                   baseSensitivity = userSettings.MouseSensitivity -- Guardar sensibilidad original
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   
                   TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = defaultFOV / currentZoomLevel}):Play()
                   
                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   -- Crear Efecto de Profundidad (DOF)
                   BinoDOF = Instance.new("DepthOfFieldEffect")
                   BinoDOF.Name = "TacticalBinoDOF"
                   BinoDOF.FocusDistance = 100 -- Enfoca lejos
                   BinoDOF.InFocusRadius = 15 -- Radio claro
                   BinoDOF.NearIntensity = 0.8 -- Borroso cerca
                   BinoDOF.FarIntensity = 0.1 -- Borroso al fondo
                   BinoDOF.Parent = Lighting
                   
                   if rightShoulder then
                       originalRightShoulderC0 = rightShoulder.C0
                       aimAnimConnection = RunService.RenderStepped:Connect(function()
                           -- 1. Animación del brazo
                           local char = Player.Character
                           if not char then return end
                           if char:FindFirstChild("RightUpperArm") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           elseif char:FindFirstChild("Torso") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           end
                           
                           -- 2. Actualización Robusta del Modelo Binocular (No usa Welds, no puede fallar)
                           if binoVisual then
                               local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                               if hand then
                                   local isR15 = char:FindFirstChild("RightHand") ~= nil
                                   local offset = isR15 and CFrame.new(0, -0.2, 0) or CFrame.new(0, -1, 0)
                                   -- Forzamos la posición frame a frame
                                   binoVisual.CFrame = hand.CFrame * offset * CFrame.Angles(math.rad(-90), 0, 0)
                               end
                           end
                       end)
                   end
               else
                   crosshair.Visible = false
                   sliderBg.Visible = false
                   
                   if BinoDOF then BinoDOF:Destroy() end -- Quitar borrosidad
                   
                   TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = defaultFOV}):Play()
                   
                   Player.CameraMode = previousCameraMode
                   
                   if aimAnimConnection then
                       aimAnimConnection:Disconnect()
                       aimAnimConnection = nil
                   end
                   if rightShoulder and originalRightShoulderC0 then
                       rightShoulder.C0 = originalRightShoulderC0
                   end
                   
                   -- Restaurar Sensibilidad Normal
                   pcall(function() userSettings.MouseSensitivity = baseSensitivity end)
               end
           end

           -- 5. Eventos del Slider
           local function updateSlider(inputPos)
               local relativeY = math.clamp(inputPos.Y - sliderBg.AbsolutePosition.Y, 0, sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y)
               local percentage = relativeY / (sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y)
               
               TweenService:Create(sliderKnob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, relativeY)}):Play()
               
               currentZoomLevel = 2 + ((maxZoomLevel - 2) * (1 - percentage))
               local targetFOV = defaultFOV / currentZoomLevel
               
               if isAiming then
                   TweenService:Create(Camera, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = targetFOV}):Play()
                   
                   -- AJUSTE DE SENSIBILIDAD PROFESIONAL
                   -- Al máximo zoom (FOV pequeño), la sensibilidad disminuye drásticamente
                   pcall(function()
                       local zoomRatio = targetFOV / defaultFOV
                       userSettings.MouseSensitivity = baseSensitivity * zoomRatio
                   end)
               end
           end

           touchZone.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSlider = true
                   updateSlider(input.Position)
               end
           end)
           
           UserInputService.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSlider = false
               end
           end)
           
           UserInputService.InputChanged:Connect(function(input)
               if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   updateSlider(input.Position)
               end
           end)

           aimButton.MouseButton1Click:Connect(function() toggleAim(false) end)

           -- 6. FABRICAR EL MODELO (MÉTODO CÁMARA/RENDERSTEPPED)
           tool.Equipped:Connect(function() 
               aimButton.Visible = true 
               
               binoVisual = Instance.new("Part")
               binoVisual.Name = "BinoVisual"
               binoVisual.Size = Vector3.new(0.6, 0.6, 0.8)
               binoVisual.Color = Color3.fromRGB(30, 30, 30) 
               binoVisual.CanCollide = false
               binoVisual.Massless = true
               binoVisual.Anchored = true -- ¡CRÍTICO! Esto evita que caiga o tenga bugs de físicas
               binoVisual.Transparency = 0 

               local mesh = Instance.new("SpecialMesh")
               mesh.MeshType = Enum.MeshType.FileMesh
               mesh.MeshId = "rbxassetid://13054174"
               mesh.TextureId = "rbxassetid://13054199"
               mesh.Scale = Vector3.new(1.1, 1.1, 1.1)
               mesh.Parent = binoVisual
               
               -- Lo emparentamos a la cámara local para que las físicas del servidor lo ignoren
               binoVisual.Parent = Camera 
           end)

           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               toggleAim(true)
               if binoVisual then
                   binoVisual:Destroy()
                   binoVisual = nil
               end
               if BinoDOF then BinoDOF:Destroy() BinoDOF = nil end
           end)

           if not Player:FindFirstChild("Backpack") then error("No se encontró Backpack.") end
           tool.Parent = Player.Backpack
           Rayfield:Notify({Title = "Item Granted", Content = "Pro Binoculars (DOF + Smooth Fix) added.", Duration = 3})
       end)

       if not success then
           warn("BINOCULARS ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "Script Error!", Content = tostring(errorMessage), Duration = 10 })
       end
   end,
})
