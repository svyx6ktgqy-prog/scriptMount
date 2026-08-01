-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

           -- 1. CREAR EL TOOL SIN HANDLE (Evita el brazo levantado de la image.png)
           local tool = Instance.new("Tool")
           tool.Name = "Binoculars"
           tool.RequiresHandle = false -- ¡CRUCIAL! Mantiene la mano caída
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

           local sliderKnob = Instance.new("TextButton")
           sliderKnob.Size = UDim2.new(1, 0, 0, 20)
           sliderKnob.Position = UDim2.new(0, 0, 1, -20)
           sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
           sliderKnob.Text = "|||"
           sliderKnob.TextColor3 = Color3.fromRGB(0, 0, 0)
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
           local binoVisual = nil -- Guardará el modelo 3D físico

           -- Función para encontrar el hombro (R6 o R15)
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
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   Camera.FieldOfView = defaultFOV / currentZoomLevel
                   
                   -- Primera Persona Asegurada
                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   -- Animar el brazo hacia los ojos
                   if rightShoulder then
                       originalRightShoulderC0 = rightShoulder.C0
                       aimAnimConnection = RunService.RenderStepped:Connect(function()
                           local char = Player.Character
                           if not char then return end
                           if char:FindFirstChild("RightUpperArm") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           elseif char:FindFirstChild("Torso") then
                               rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                           end
                       end)
                   end
               else
                   crosshair.Visible = false
                   sliderBg.Visible = false
                   Camera.FieldOfView = defaultFOV
                   
                   -- Restaurar Cámara
                   Player.CameraMode = previousCameraMode
                   
                   -- Restaurar Brazo
                   if aimAnimConnection then
                       aimAnimConnection:Disconnect()
                       aimAnimConnection = nil
                   end
                   if rightShoulder and originalRightShoulderC0 then
                       rightShoulder.C0 = originalRightShoulderC0
                   end
               end
           end

           -- 5. Eventos del Slider de Zoom
           sliderKnob.MouseButton1Down:Connect(function() draggingSlider = true end)
           UserInputService.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingSlider = false
               end
           end)
           UserInputService.InputChanged:Connect(function(input)
               if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   local mousePos = UserInputService:GetMouseLocation()
                   local relativeY = math.clamp(mousePos.Y - sliderBg.AbsolutePosition.Y, 0, sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y)
                   local percentage = relativeY / (sliderBg.AbsoluteSize.Y - sliderKnob.AbsoluteSize.Y)
                   
                   sliderKnob.Position = UDim2.new(0, 0, 0, relativeY)
                   currentZoomLevel = 2 + ((maxZoomLevel - 2) * (1 - percentage))
                   
                   if isAiming then
                       Camera.FieldOfView = defaultFOV / currentZoomLevel
                   end
               end
           end)

           aimButton.MouseButton1Click:Connect(function() toggleAim(false) end)

           -- 6. FABRICAR EL MODELO AL EQUIPAR (WELD MANUAL)
           tool.Equipped:Connect(function() 
               aimButton.Visible = true 
               local char = Player.Character
               if not char then return end

               local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
               if not hand then return end

               -- Crear la pieza base (Si falla el Mesh, verás este bloque gris oscuro táctico)
               binoVisual = Instance.new("Part")
               binoVisual.Name = "BinoVisual"
               binoVisual.Size = Vector3.new(0.6, 0.6, 0.8)
               binoVisual.Color = Color3.fromRGB(30, 30, 30) 
               binoVisual.CanCollide = false
               binoVisual.Massless = true
               binoVisual.Locked = true

               -- Cargar la malla oficial
               local mesh = Instance.new("SpecialMesh")
               mesh.MeshType = Enum.MeshType.FileMesh
               mesh.MeshId = "rbxassetid://13054174"
               mesh.TextureId = "rbxassetid://13054199"
               mesh.Scale = Vector3.new(1, 1, 1)
               mesh.Parent = binoVisual

               -- Soldarlo directamente a la mano
               local weld = Instance.new("Weld")
               weld.Part0 = hand
               weld.Part1 = binoVisual
               
               -- Ajuste de posición preciso para R15 y R6
               if char:FindFirstChild("RightHand") then
                   weld.C0 = CFrame.new(0, -0.15, 0) * CFrame.Angles(math.rad(-90), 0, 0) -- R15
               else
                   weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0) -- R6
               end
               weld.Parent = binoVisual
               
               binoVisual.Parent = char
           end)

           -- DESTRUIR MODELO AL DESEQUIPAR
           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               toggleAim(true)
               if binoVisual then
                   binoVisual:Destroy()
                   binoVisual = nil
               end
           end)

           if not Player:FindFirstChild("Backpack") then error("No se encontró Backpack.") end
           tool.Parent = Player.Backpack
           Rayfield:Notify({Title = "Item Granted", Content = "Official Binoculars Fixed added.", Duration = 3})
       end)

       if not success then
           warn("BINOCULARS ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({ Title = "Script Error!", Content = tostring(errorMessage), Duration = 10 })
       end
   end,
})
