-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

-- Función matemática para fluidez perfecta (Lerp)
local function lerp(a, b, t)
    return a + (b - a) * t
end

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

           local tool = Instance.new("Tool")
           tool.Name = "Binoculars"
           tool.RequiresHandle = false
           tool.CanBeDropped = false

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
           touchZone.Size = UDim2.new(6, 0, 1, 80) -- Zona táctil GIGANTE para que no falle el dedo
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

           -- ESTADO Y VARIABLES DE FLUIDEZ (LERP)
           local isAiming = false
           local defaultFOV = 70
           local targetZoomLevel = 2 
           local actualZoomLevel = 2 
           local maxZoomLevel = 25 
           
           local targetSliderY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
           local actualSliderY = targetSliderY

           local aimAnimConnection = nil
           local originalRightShoulderC0 = nil
           local draggingSlider = false
           local previousCameraMode = Player.CameraMode
           local binoVisual = nil 
           local BinoDOF = nil
           
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

           local function toggleAim(forceOff)
               if forceOff then isAiming = false else isAiming = not isAiming end
               local rightShoulder = getRightShoulder()

               if isAiming then
                   baseSensitivity = userSettings.MouseSensitivity 
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   
                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   if not Lighting:FindFirstChild("TacticalBinoDOF") then
                       BinoDOF = Instance.new("DepthOfFieldEffect")
                       BinoDOF.Name = "TacticalBinoDOF"
                       BinoDOF.FocusDistance = 100 
                       BinoDOF.InFocusRadius = 15 
                       BinoDOF.NearIntensity = 0.8 
                       BinoDOF.FarIntensity = 0.1 
                       BinoDOF.Parent = Lighting
                   end
                   
                   if rightShoulder then originalRightShoulderC0 = rightShoulder.C0 end

                   -- CORE BUCLE: Maneja Zoom Suave, Sensibilidad Suave y Posición del Modelo
                   aimAnimConnection = RunService.RenderStepped:Connect(function(deltaTime)
                       -- 1. Matemática Lerp para suavidad ultra-profesional (velocidad independiente de FPS)
                       local lerpSpeed = 12 * deltaTime
                       actualZoomLevel = lerp(actualZoomLevel, targetZoomLevel, lerpSpeed)
                       actualSliderY = lerp(actualSliderY, targetSliderY, lerpSpeed)

                       -- 2. Aplicar Zoom y Slider Suaves
                       Camera.FieldOfView = defaultFOV / actualZoomLevel
                       sliderKnob.Position = UDim2.new(0, 0, 0, actualSliderY)

                       -- 3. Escalar Sensibilidad proporcionalmente al zoom actual (Cero saltos)
                       pcall(function()
                           local currentRatio = (defaultFOV / actualZoomLevel) / defaultFOV
                           userSettings.MouseSensitivity = baseSensitivity * currentRatio
                       end)

                       -- 4. Animar Brazo
                       local char = Player.Character
                       if char and rightShoulder then
                           if char:FindFirstChild("RightUpperArm") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           elseif char:FindFirstChild("Torso") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           end
                       end

                       -- 5. FORZAR POSICIÓN DEL MODELO (Inmune a físicas)
                       if binoVisual and char then
                           local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                           if hand then
                               local isR15 = char:FindFirstChild("RightHand") ~= nil
                               local offset = isR15 and CFrame.new(0, -0.2, 0) or CFrame.new(0, -1, 0)
                               binoVisual.CFrame = hand.CFrame * offset * CFrame.Angles(math.rad(-90), 0, 0)
                           end
                       end
                   end)
               else
                   crosshair.Visible = false
                   sliderBg.Visible = false
                   if Lighting:FindFirstChild("TacticalBinoDOF") then Lighting.TacticalBinoDOF:Destroy() end
                   
                   -- Restaurar cámara suavemente
                   targetZoomLevel = 1
                   Camera.FieldOfView = defaultFOV
                   Player.CameraMode = previousCameraMode
                   pcall(function() userSettings.MouseSensitivity = baseSensitivity end)
                   
                   if aimAnimConnection then
                       aimAnimConnection:Disconnect()
                       aimAnimConnection = nil
                   end
                   if rightShoulder and originalRightShoulderC0 then
                       rightShoulder.C0 = originalRightShoulderC0
                   end
               end
           end

           -- GLOBAL INPUT TRACKING: Registra el dedo en toda la pantalla mientras arrastras
           local function updateTargetSlider(inputPos)
               local minY = 0
               local maxY = sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y
               local relativeY = math.clamp(inputPos.Y - sliderBg.AbsolutePosition.Y, minY, maxY)
               
               targetSliderY = relativeY -- Seteamos el objetivo (RenderStepped hace la suavidad)
               local percentage = relativeY / maxY
               targetZoomLevel = 2 + ((maxZoomLevel - 2) * (1 - percentage))
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

           aimButton.MouseButton1Click:Connect(function() toggleAim(false) end)

           -- CREAR MODELO 100% SEGURO
           tool.Equipped:Connect(function() 
               aimButton.Visible = true 
               
               binoVisual = Instance.new("Part")
               binoVisual.Name = "BinoVisual"
               binoVisual.Size = Vector3.new(0.8, 0.8, 1) -- Tamaño base garantizado
               binoVisual.Color = Color3.fromRGB(15, 15, 15) 
               binoVisual.Material = Enum.Material.SmoothPlastic
               binoVisual.Anchored = true -- ¡CRÍTICO! Ningún motor de físicas lo afectará
               binoVisual.CanCollide = false
               binoVisual.CanTouch = false
               binoVisual.CanQuery = false
               
               local mesh = Instance.new("SpecialMesh")
               mesh.MeshType = Enum.MeshType.FileMesh
               mesh.MeshId = "rbxassetid://13054174"
               mesh.TextureId = "rbxassetid://13054199"
               mesh.Scale = Vector3.new(1.3, 1.3, 1.3)
               mesh.Parent = binoVisual
               
               -- Emparentado a la cámara. Garantiza renderizado local sin réplica.
               binoVisual.Parent = Camera 
           end)

           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               toggleAim(true)
               if binoVisual then binoVisual:Destroy() binoVisual = nil end
           end)

           if not Player:FindFirstChild("Backpack") then error("No se encontró Backpack.") end
           tool.Parent = Player.Backpack
           Rayfield:Notify({Title = "Item Granted", Content = "ULTRA SYSTEM: Lerp Caliber & Core Model.", Duration = 4})
       end)

       if not success then
           warn("BINOCULARS ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "Script Error!", Content = tostring(errorMessage), Duration = 10 })
       end
   end,
})
