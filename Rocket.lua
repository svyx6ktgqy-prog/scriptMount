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

-- // Create Floating UI (iOS / Delta) //
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "MobileSpaceGui"
MobileGui.ResetOnSpawn = false
MobileGui.Parent = game.CoreGui

-- Floating Fly Button
local FlyButton = Instance.new("TextButton")
local FlyCorner = Instance.new("UICorner")
FlyButton.Parent = MobileGui
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.BackgroundTransparency = 0.3
FlyButton.Position = UDim2.new(0.8, 0, 0.65, 0)
FlyButton.Size = UDim2.new(0, 70, 0, 70)
FlyButton.Font = Enum.Font.GothamBold
FlyButton.Text = "HOLD\nFLY"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 14
FlyButton.Visible = false 
FlyCorner.CornerRadius = UDim.new(1, 0)
FlyCorner.Parent = FlyButton

-- Floating TP Button (Uranium)
local TpButton = Instance.new("TextButton")
local TpCorner = Instance.new("UICorner")
TpButton.Parent = MobileGui
TpButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
TpButton.BackgroundTransparency = 0.3
TpButton.Position = UDim2.new(0.8, 0, 0.5, 0) -- Placed just above the Fly button
TpButton.Size = UDim2.new(0, 70, 0, 70)
TpButton.Font = Enum.Font.GothamBold
TpButton.Text = "TP 2\nROCK"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.TextSize = 14
TpButton.Visible = false 
TpCorner.CornerRadius = UDim.new(1, 0)
TpCorner.Parent = TpButton


-- // Fly Logic (Natural & Ban-Safe) //
local function toggleFly(state)
    isFlying = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    
    if isFlying then
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Use natural gravity suspension
        local bv = Instance.new("BodyVelocity")
        bv.Name = "NaturalFly"
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        flyConnection = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- Calculates natural flight trajectory based on mobile joystick and camera angle
                local flatLook = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                local forwardDot = moveDir:Dot(flatLook) 
                
                -- Adjusts Y height only if you are moving forward/backward (Joystick Up/Down)
                local yVelocity = cam.CFrame.LookVector.Y * forwardDot
                local naturalDir = Vector3.new(moveDir.X, yVelocity, moveDir.Z).Unit
                
                -- Moves exactly at the character's original WalkSpeed (prevents speedhack ban)
                bv.Velocity = naturalDir * hum.WalkSpeed
            else
                -- Hover in place naturally
                bv.Velocity = Vector3.zero
            end
        end)
        
        -- Smooth Noclip (Pass through walls)
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        if hrp:FindFirstChild("NaturalFly") then hrp.NaturalFly:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

-- // Floating Button Events //
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

local function teleportToUranium()
    pcall(function()
        local asteroid = Workspace:FindFirstChild("UraniumAsteroid")
        if asteroid and asteroid:FindFirstChild("UraniumRock") and asteroid.UraniumRock:FindFirstChild("Core") then
            local core = asteroid.UraniumRock.Core
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleports you safely 3 studs above the rock to avoid getting stuck
                LocalPlayer.Character.HumanoidRootPart.CFrame = core.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end

TpButton.MouseButton1Click:Connect(teleportToUranium)


-- // Helper function to force ProximityPrompts //
local function forceFirePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 9e9
            prompt.HoldDuration = 0
            
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

FarmTab:CreateSection("Method 2: Teleport to Uranium")
FarmTab:CreateToggle({
   Name = "Show Floating TP Button",
   CurrentValue = false,
   Flag = "ShowTpButton",
   Callback = function(Value)
      TpButton.Visible = Value
   end,
})

FarmTab:CreateButton({
   Name = "Teleport to Uranium Rock Now",
   Callback = function()
      teleportToUranium()
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
