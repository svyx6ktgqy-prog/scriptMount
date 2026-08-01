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
   Name = "Equip Visible Binoculars",
   Callback = function()
       -- 0. Prevención de errores con el Player y Character
       local character = Player.Character or Player.CharacterAdded:Wait()
       local playerGui = Player:WaitForChild("PlayerGui")
       
       if Player.Backpack:FindFirstChild("Military Binoculars") or character:FindFirstChild("Military Binoculars") then
           Rayfield:Notify({Title = "Already Equipped", Content = "You already have the item.", Duration = 3})
           return
       end

       -- 1. Create the Tool (VISIBLE y listo)
       local tool = Instance.new("Tool")
       tool.Name = "Military Binoculars"
       tool.RequiresHandle = true -- Requerido para que sea visible en la mano
       tool.CanBeDropped = false
       tool.Grip = CFrame.new(0, 0, 0) -- Ajusta cómo lo sostiene en la mano caída

       local handle = Instance.new("Part")
       handle.Name = "Handle"
       handle.Size = Vector3.new(1, 1, 1)
       handle.Transparency = 0 -- 0 para que se vea
       handle.CanCollide = false
       handle.Massless = true
       handle.Parent = tool

       local mesh = Instance.new("SpecialMesh")
       mesh.MeshType = Enum.MeshType.FileMesh
       mesh.MeshId = "rbxassetid://81667437077852"
       mesh.Scale = Vector3.new(1, 1, 1) -- Ajusta la escala si es muy grande/chico
       mesh.Parent = handle

       -- 2. Create the GUI System
       local mainGui = Instance.new("ScreenGui")
       mainGui.Name = "BinocularsSystemUI"
       mainGui.ResetOnSpawn = false
       mainGui.Parent = playerGui

       -- Floating Aim Button
       local aimButton = Instance.new("TextButton")
       aimButton.Size = UDim2.new(0, 80, 0, 80)
       aimButton.Position = UDim2.new(0.5, 100, 0.8, 0)
       aimButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
       aimButton.BackgroundTransparency = 0.3
       aimButton.Text = "AIM"
       aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
       aimButton.Font = Enum.Font.GothamBold
       aimButton.TextSize = 24
       aimButton.UICorner = Instance.new("UICorner", aimButton)
       aimButton.UICorner.CornerRadius = UDim.new(1, 0)
       aimButton.Visible = false
       aimButton.Parent = mainGui

       -- Crosshair Overlay
       local crosshair = Instance.new("ImageLabel")
       crosshair.Size = UDim2.new(1, 0, 1, 0)
       crosshair.Position = UDim2.new(0, 0, 0, 0)
       crosshair.BackgroundTransparency = 1
       crosshair.Image = "rbxassetid://135303495630668"
       crosshair.ScaleType = Enum.ScaleType.Stretch
       crosshair.Visible = false
       crosshair.Parent = mainGui

       -- Zoom Slider Background
       local sliderBg = Instance.new("Frame")
       sliderBg.Size = UDim2.new(0, 30, 0.5, 0)
       sliderBg.Position = UDim2.new(1, -60, 0.25, 0)
       sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
       sliderBg.BackgroundTransparency = 0.5
       sliderBg.Visible = false
       sliderBg.Parent = mainGui
       Instance.new("UICorner", sliderBg)

       -- Zoom Slider Knob
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
       local aimAnimConnection = nil
       local originalRightShoulderC0 = nil
       local originalGrip = tool.Grip
       local draggingSlider = false

       -- 4. Helper Function: Find Right Shoulder
       local function getRightShoulder()
           local char = Player.Character
           if not char then return nil end
           if char:FindFirstChild("RightUpperArm") then
               return char.RightUpperArm:FindFirstChild("RightShoulder")
           elseif char:FindFirstChild("Torso") then
               return char.Torso:FindFirstChild("Right Shoulder")
           end
           return nil
       end

       -- 5. Toggle Aim Function
       local function toggleAim(forceOff)
           if forceOff then isAiming = false else isAiming = not isAiming end

           local rightShoulder = getRightShoulder()

           if isAiming then
               crosshair.Visible = true
               sliderBg.Visible = true
               Camera.FieldOfView = defaultFOV / currentZoomLevel

               -- Animación al ojo (Grip adjustment + Procedural)
               tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0) -- Rota el modelo para que apunte al frente
               
               if rightShoulder then
                   originalRightShoulderC0 = rightShoulder.C0
                   aimAnimConnection = RunService.RenderStepped:Connect(function()
                       local char = Player.Character
                       if char and char:FindFirstChild("RightUpperArm") then
                           rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                       elseif char and char:FindFirstChild("Torso") then
                           rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.rad(110), 0, math.rad(-20))
                       end
                   end)
               end
           else
               crosshair.Visible = false
               sliderBg.Visible = false
               Camera.FieldOfView = defaultFOV

               -- Vuelve a la mano caída
               tool.Grip = originalGrip 
               
               if aimAnimConnection then
                   aimAnimConnection:Disconnect()
                   aimAnimConnection = nil
               end
               if rightShoulder and originalRightShoulderC0 then
                   rightShoulder.C0 = originalRightShoulderC0
               end
           end
       end

       -- 6. Events: Slider Logic
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
               currentZoomLevel = 2 + (4 * (1 - percentage))
               
               if isAiming then
                   Camera.FieldOfView = defaultFOV / currentZoomLevel
               end
           end
       end)

       -- 7. Events: Tool Equip/Unequip & Button Press
       aimButton.MouseButton1Click:Connect(function()
           toggleAim(false)
       end)

       tool.Equipped:Connect(function()
           aimButton.Visible = true
       end)

       tool.Unequipped:Connect(function()
           aimButton.Visible = false
           toggleAim(true)
       end)

       -- 8. Limpiar GUI si el jugador muere
       Player.CharacterAdded:Connect(function()
           if mainGui and mainGui.Parent then
               mainGui:Destroy()
           end
       end)

       -- 9. Finalize
       tool.Parent = Player.Backpack
       Rayfield:Notify({Title = "Item Granted", Content = "Military Binoculars added.", Duration = 3})
   end,
})
