-- // Rayfield Setup & Booting //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Delta iOS | Space Hub",
   LoadingTitle = "Loading Scripts...",
   LoadingSubtitle = "by Rayfield",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

-- // Variables //
local autoUraniumRemote = false
local autoUraniumTP = false
local antiStealUranium = false
local nukeSpam = false
local isFlying = false
local flyConnection = nil
local noclipConnection = nil

-- // Create Floating Fly Button for Mobile (iOS / Delta) //
local FlyGui = Instance.new("ScreenGui")
local FlyButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

FlyGui.Name = "MobileFlyGui"
FlyGui.ResetOnSpawn = false
FlyGui.Parent = game.CoreGui

FlyButton.Parent = FlyGui
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.BackgroundTransparency = 0.3
FlyButton.Position = UDim2.new(0.8, 0, 0.6, 0) -- Placed on the right side for easy thumb access
FlyButton.Size = UDim2.new(0, 70, 0, 70)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Text = "HOLD\nFLY"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14
FlyButton.Visible = false -- Hidden by default, toggled in UI

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FlyButton

-- Fly Logic
local function toggleFly(state)
    isFlying = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if isFlying then
        -- Enable Fly & Noclip
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        -- Fly movement loop based on mobile joystick (MoveDirection)
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                bv.Velocity = (cam.CFrame.LookVector * moveDir.Z * -50) + (cam.CFrame.RightVector * moveDir.X * 50)
            else
                bv.Velocity = Vector3.zero
            end
        end)
        
        -- Noclip loop (passes through walls smoothly)
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        -- Disable Fly & Noclip
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

-- iOS Touch Events for Floating Button
FlyButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleFly(true)
    end
end)

FlyButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleFly(false)
    end
end)


-- // TABS //
local FarmTab = Window:CreateTab("Uranium Farm", 4483362458)
local NukeTab = Window:CreateTab("Weapons & Nukes", 4483362458)
local PlayerTab = Window:CreateTab("Player / Fly", 4483362458)

-- // URANIUM FARMING METHODS //

FarmTab:CreateSection("Method 1: Remote Aura (Safest)")
FarmTab:CreateToggle({
   Name = "Auto Collect Uranium (Remote)",
   CurrentValue = false,
   Flag = "AutoUranium1",
   Callback = function(Value)
      autoUraniumRemote = Value
      while autoUraniumRemote do
          task.wait(0.2)
          pcall(function()
              local prompt = Workspace.UraniumAsteroid.UraniumRock.Core.TakePrompt
              if prompt then
                  fireproximityprompt(prompt, 1, true)
              end
          end)
      end
   end,
})

FarmTab:CreateSection("Method 2: Teleport & Grab (If Remote is Patched)")
FarmTab:CreateToggle({
   Name = "Auto Teleport to Uranium",
   CurrentValue = false,
   Flag = "AutoUranium2",
   Callback = function(Value)
      autoUraniumTP = Value
      while autoUraniumTP do
          task.wait(0.1)
          pcall(function()
              local core = Workspace.UraniumAsteroid.UraniumRock.Core
              local prompt = core.TakePrompt
              if prompt and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                  local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                  -- TP to rock
                  LocalPlayer.Character.HumanoidRootPart.CFrame = core.CFrame
                  task.wait(0.1)
                  fireproximityprompt(prompt, 1, true)
                  task.wait(0.1)
                  -- TP back
                  LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
              end
          end)
      end
   end,
})

FarmTab:CreateSection("Method 3: Anti-Steal Protection")
FarmTab:CreateToggle({
   Name = "Anti-Steal (Godspeed Collect)",
   CurrentValue = false,
   Flag = "AntiSteal",
   Callback = function(Value)
      antiStealUranium = Value
      -- Uses heartbeat to check every single frame, securing it before anyone else can react
      local connection
      if antiStealUranium then
          connection = RunService.Heartbeat:Connect(function()
              pcall(function()
                  local prompt = Workspace.UraniumAsteroid.UraniumRock.Core.TakePrompt
                  if prompt then
                      fireproximityprompt(prompt, 0, true)
                  end
              end)
          end)
      else
          if connection then connection:Disconnect() end
      end
   end,
})


-- // NUKES & WEAPONS //
NukeTab:CreateSection("Rocket Control")
NukeTab:CreateToggle({
   Name = "Spam Launch Rockets (No Cooldown)",
   CurrentValue = false,
   Flag = "NukeSpam",
   Callback = function(Value)
      nukeSpam = Value
      while nukeSpam do
          task.wait(0.1) -- Fast loop
          pcall(function()
              local glacius = Workspace.Planets.Glacius
              
              -- Fire Main Nuke Pads
              if glacius:FindFirstChild("NukePads") then
                  for _, pad in pairs(glacius.NukePads:GetDescendants()) do
                      if pad:IsA("ProximityPrompt") and pad.ActionText == "Launch" then
                          fireproximityprompt(pad, 1, true)
                      end
                  end
              end
              
              -- Fire Extra Nuke Pads
              if glacius:FindFirstChild("ExtraNukePads") then
                  for _, pad in pairs(glacius.ExtraNukePads:GetDescendants()) do
                      if pad:IsA("ProximityPrompt") and pad.ActionText == "Launch" then
                          fireproximityprompt(pad, 1, true)
                      end
                  end
              end
          end)
      end
   end,
})

NukeTab:CreateButton({
   Name = "Launch ALL Rockets ONCE",
   Callback = function()
        pcall(function()
            local glacius = Workspace.Planets.Glacius
            for _, pad in pairs(glacius:GetDescendants()) do
                if pad:IsA("ProximityPrompt") and pad.ActionText == "Launch" then
                    fireproximityprompt(pad, 1, true)
                end
            end
        end)
   end,
})


-- // PLAYER & FLY CONTROLS //
PlayerTab:CreateSection("Mobile Flight Control")
PlayerTab:CreateToggle({
   Name = "Show Floating Fly Button",
   CurrentValue = false,
   Flag = "ShowFly",
   Callback = function(Value)
      FlyButton.Visible = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- // Load Rayfield //
Rayfield:LoadConfiguration()
