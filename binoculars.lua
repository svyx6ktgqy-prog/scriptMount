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
   Name = "Equip Invisible Binoculars",
   Callback = function()
       if Player.Backpack:FindFirstChild("Tactical Binoculars") or (Player.Character and Player.Character:FindFirstChild("Tactical Binoculars")) then
           Rayfield:Notify({Title = "Already Equipped", Content = "You already have the item.", Duration = 3})
           return
       end

       -- 1. Create the Tool (Invisible, no handle required)
       local tool = Instance.new("Tool")
       tool.Name = "Tactical Binoculars"
       tool.RequiresHandle = false -- Esto evita que el brazo se levante solo y lo mantiene "caído"
       tool.CanBeDropped = false

       -- 2. Create the GUI System
       local mainGui = Instance.new("ScreenGui")
       mainGui.Name = "BinocularsSystemUI"
       mainGui.ResetOnSpawn = false
       mainGui.Parent = Player:WaitForChild("PlayerGui")

       -- Floating Aim Button
       local aimButton = Instance.new("TextButton")
       aimButton.Size = UDim2.new(0, 80, 0, 80)
       aimButton.Position = UDim2.new(0.5, 100, 0.8, 0) -- Abajo al centro-derecha
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
       sliderBg.Position = UDim2.new(1, -60, 0.25, 0) -- Lado derecho
       sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
       sliderBg.BackgroundTransparency = 0.5
       sliderBg.Visible = false
       sliderBg.Parent = mainGui
       Instance.new("UICorner", sliderBg)

       -- Zoom Slider Knob (El calibrador)
       local sliderKnob = Instance.new("TextButton")
       sliderKnob.Size = UDim2.new(1, 0, 0, 20)
       sliderKnob.Position = UDim2.new(0, 0, 1, -20) -- Empieza abajo (Min Zoom)
       sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
       sliderKnob.Text = "|||"
       sliderKnob.TextColor3 = Color3.fromRGB(0, 0, 0)
       sliderKnob.Parent = sliderBg
       Instance.new("UICorner", sliderKnob)

       -- 3. Logic & State Variables
       local isAiming = false
       local defaultFOV = 70
       local currentZoomLevel = 2 -- Zoom base x2
       local aimAnimConnection = nil
       local originalC0 = nil
       local rightShoulder = nil
       local draggingSlider = false

       -- 4. Helper Function: Find Right Shoulder (Works for R6 and R15)
       local function getRightShoulder()
           local char = Player.Character
           if not char then return nil end
           if char:FindFirstChild("RightUpperArm") then
               return char.RightUpperArm:FindFirstChild("RightShoulder") -- R15
           elseif char:FindFirstChild("Torso") then
               return char.Torso:FindFirstChild("Right Shoulder") -- R6
           end
           return nil
       end

       -- 5. Toggle Aim Function
       local function toggleAim(forceOff)
           if forceOff then isAiming = false else isAiming = not isAiming end

           if isAiming then
               -- Activar UI
               crosshair.Visible = true
               sliderBg.Visible = true
               Camera.FieldOfView = defaultFOV / currentZoomLevel

               -- Animación Procedural (Levantar la mano a la cara)
               rightShoulder = getRightShoulder()
               if rightShoulder then
                   originalC0 = rightShoulder.C0
                   aimAnimConnection = RunService.RenderStepped:Connect(function()
                       if Player.Character:FindFirstChild("RightUpperArm") then
                           -- R15 Fix
                           rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(-30))
                       else
                           -- R6 Fix
                           rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.rad(120), 0, math.rad(-30))
                       end
                   end)
               end
           else
               -- Desactivar UI y Zoom
               crosshair.Visible = false
               sliderBg.Visible = false
               Camera.FieldOfView = defaultFOV

               -- Animación Procedural (Mano caída)
               if aimAnimConnection then
                   aimAnimConnection:Disconnect()
                   aimAnimConnection = nil
               end
               if rightShoulder and originalC0 then
                   rightShoulder.C0 = originalC0
               end
           end
       end

       -- 6. Events: Slider Logic (Arrastrar para Zoom x2, x3, x4...)
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
               
               -- Calcular Zoom (Abajo = 100% = x2, Arriba = 0% = x6)
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
           aimButton.Visible = true -- Muestra el boton flotante
           -- No levantamos el brazo todavía, mantenemos la "mano caída"
       end)

       tool.Unequipped:Connect(function()
           aimButton.Visible = false
           toggleAim(true) -- Fuerza apagar el modo aim si cambias de arma
       end)

       -- 8. Finalize
       tool.Parent = Player.Backpack
       Rayfield:Notify({Title = "Item Granted", Content = "Invisible Binoculars added.", Duration = 3})
   end,
})
