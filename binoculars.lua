-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
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

           -- 1. Cargar el Tool Oficial desde el Catálogo de Roblox
           local tool = nil
           local successLoad, loadError = pcall(function()
               -- 34918681 es el ID oficial de los Binoculars de Roblox
               local loadedModel = InsertService:LoadAsset(34918681)
               tool = loadedModel:FindFirstChildOfClass("Tool")
           end)

           if not successLoad or not tool then
               error("Fallo al cargar el modelo 3D del catálogo. Intenta de nuevo.")
           end

           -- Limpiamos scripts viejos o inútiles que traiga el modelo oficial
           for _, v in pairs(tool:GetDescendants()) do
               if v:IsA("Script") or v:IsA("LocalScript") then
                   v:Destroy()
               end
           end

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
           crosshair.Image = "rbxassetid://135303495630668"
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
           local currentZoomLevel = 2 -- Base zoom x2
           local maxZoomLevel = 20 -- Zoom máximo x20
           local aimAnimConnection = nil
           local originalRightShoulderC0 = nil
           local originalGrip = tool.Grip
           local draggingSlider = false
           local previousCameraMode = Player.CameraMode

           local function getRightShoulder()
               local char = Player.Character
               if not char then return nil end
               local rightUpper = char:FindFirstChild("RightUpperArm")
               local torso = char:FindFirstChild("Torso")
               
               if rightUpper then
                   return rightUpper:FindFirstChild("RightShoulder")
               elseif torso then
                   return torso:FindFirstChild("Right Shoulder")
               end
               return nil
           end

           local function toggleAim(forceOff)
               if forceOff then isAiming = false else isAiming = not isAiming end

               local rightShoulder = getRightShoulder()

               if isAiming then
                   crosshair.Visible = true
                   sliderBg.Visible = true
                   Camera.FieldOfView = defaultFOV / currentZoomLevel
                   
                   -- Forzar Primera Persona
                   previousCameraMode = Player.CameraMode
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   
                   -- Animación de brazo
                   tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0)
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
                   
                   -- Quitar Primera Persona
                   Player.CameraMode = previousCameraMode
                   
                   -- Restaurar brazo
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

           -- 6. Eventos del Calibrador (Slider x2 a x20)
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
                   
                   -- Calcular Zoom (Abajo = 100% = x2, Arriba = 0% = x20)
                   currentZoomLevel = 2 + ((maxZoomLevel - 2) * (1 - percentage))
                   
                   if isAiming then
                       Camera.FieldOfView = defaultFOV / currentZoomLevel
                   end
               end
           end)

           aimButton.MouseButton1Click:Connect(function() toggleAim(false) end)

           tool.Equipped:Connect(function() aimButton.Visible = true end)

           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               toggleAim(true)
           end)

           if not Player:FindFirstChild("Backpack") then
               error("No se encontró Backpack.")
           end
           
           tool.Parent = Player.Backpack
           Rayfield:Notify({Title = "Item Granted", Content = "Official Binoculars added.", Duration = 3})

       end)

       if not success then
           warn("BINOCULARS ERROR: " .. tostring(errorMessage))
           Rayfield:Notify({
               Title = "Script Error!",
               Content = tostring(errorMessage),
               Duration = 10,
           })
       end
   end,
})
