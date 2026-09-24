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
FlyButton.Position = UDim2.new(0.8, 0, 0.6, 0)
FlyButton.Size = UDim2.new(0, 70, 0, 70)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Text = "HOLD\nFLY"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14
FlyButton.Visible = false 

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
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                bv.Velocity = (cam.CFrame.LookVector * moveDir.Z * -50) + (cam.CFrame.RightVector * moveDir.X * 50)
            else
                bv.Velocity = Vector3.zero
            end
        end)
        
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

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

-- // Helper function to force ProximityPrompts (Bypasses distance & wait time) //
local function forceFirePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 9e9
            prompt.HoldDuration = 0
            
            -- Firing multiple ways to ensure Delta Executor catches it
            if fireproximityprompt then
                fireproximityprompt(prompt, 1, true)
                fireproximityprompt(prompt, 0)
                fireproximityprompt(prompt)
            end
        end)
    end
end


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
              forceFirePrompt(prompt)
          end)
      end
   end,
})

FarmTab:CreateSection("Method 2: Teleport to Uranium (Manual)")
FarmTab:CreateButton({
   Name = "Teleport to Uranium Rock",
   Callback = function()
      pcall(function()
          local asteroid = Workspace:FindFirstChild("UraniumAsteroid")
          if asteroid and asteroid:FindFirstChild("UraniumRock") and asteroid.UraniumRock:FindFirstChild("Core") then
              local core = asteroid.UraniumRock.Core
              if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                  -- Teleports you slightly above the core so you don't get stuck inside it
                  LocalPlayer.Character.HumanoidRootPart.CFrame = core.CFrame + Vector3.new(0, 3, 0)
              end
          end
      end)
   end,
})

FarmTab:CreateSection("Method 3: Anti-Steal Protection")
FarmTab:CreateToggle({
   Name = "Anti-Steal (Godspeed Collect)",
   CurrentValue = false,
   Flag = "AntiSteal",
   Callback = function(Value)
      antiStealUranium = Value
      local connection
      if antiStealUranium then
          connection = RunService.Heartbeat:Connect(function()
              pcall(function()
                  local prompt = Workspace.UraniumAsteroid.UraniumRock.Core.TakePrompt
                  if prompt then
                      forceFirePrompt(prompt)
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
          task.wait(0.1) 
          pcall(function()
              local glacius = Workspace.Planets.Glacius
              
              if glacius:FindFirstChild("NukePads") then
                  for _, pad in pairs(glacius.NukePads:GetDescendants()) do
                      if pad:IsA("ProximityPrompt") and pad.ActionText == "Launch" then
                          forceFirePrompt(pad)
                      end
                  end
              end
              
              if glacius:FindFirstChild("ExtraNukePads") then
                  for _, pad in pairs(glacius.ExtraNukePads:GetDescendants()) do
                      if pad:IsA("ProximityPrompt") and pad.ActionText == "Launch" then
                          forceFirePrompt(pad)
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
                    forceFirePrompt(pad)
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
