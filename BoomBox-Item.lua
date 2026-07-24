-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Loading Interface...",
   LoadingSubtitle = "Gangster Posture & Engine: ACTIVATED",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Inventory", 4483362458) 

-- Global Variables
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320"
local clonedTool = nil
local customUI = nil

-- Playlist (Includes your predefined IDs and 2 empty slots for production)
local playlist = {
    "136674057014960",
    "133761848795389",
    "138950692714324",
    "91563677636564",
    "103409297553965",
    "", -- Production Slot 1 (Add ID here later)
    ""  -- Production Slot 2 (Add ID here later)
}
local currentTrackIndex = 1

Tab:CreateToggle({
   Name = "Equip Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           local success, errorMessage = pcall(function()
               
               -- 1. Safely force the backpack GUI to be enabled
               local StarterGui = game:GetService("StarterGui")
               pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
               
               -- 2. Download the asset and auto-forge the tool
               local objects = game:GetObjects(assetId)
               local obj = objects[1]
               local realTool = nil
               
               if obj:IsA("Tool") then
                   realTool = obj 
               else
                   local innerTool = obj:FindFirstChildWhichIsA("Tool", true)
                   if innerTool then
                       realTool = innerTool
                   else
                       realTool = Instance.new("Tool")
                       realTool.RequiresHandle = true
                       if obj:IsA("BasePart") then
                           obj.Name = "Handle"
                           obj.Parent = realTool
                       elseif obj:IsA("Model") or obj:IsA("Folder") then
                           for _, child in pairs(obj:GetChildren()) do child.Parent = realTool end
                           local handle = realTool:FindFirstChild("Handle") or realTool:FindFirstChildWhichIsA("BasePart")
                           if handle then handle.Name = "Handle"
                           else
                               handle = Instance.new("Part")
                               handle.Name = "Handle"
                               handle.Size = Vector3.new(1, 1, 1)
                               handle.Transparency = 1
                               handle.Parent = realTool
                           end
                       end
                   end
               end
               
               if not realTool then error("Auto-Forge Error.") end
               
               clonedTool = realTool
               clonedTool.Name = toolName
               
               local handle = clonedTool:FindFirstChild("Handle")
               
               -- ==========================================
               -- [ANTI-FALL & ANTI-DESPAWN SYSTEM (AUTO-WELD)]
               -- ==========================================
               for _, part in pairs(clonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false
                       part.CanCollide = false 
                       part.Massless = true 
                       
                       if part ~= handle then
                           local weld = Instance.new("WeldConstraint")
                           weld.Part0 = handle
                           weld.Part1 = part
                           weld.Parent = handle
                       end
                   end
               end
               
               -- ==========================================
               -- [POSTURE CORRECTION]: PERFECT HAND FIT
               -- ==========================================
               clonedTool.Grip = CFrame.new(0, -0.8, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(15))
               
               -- ==========================================
               -- CUSTOM AUDIO ENGINE & UI
               -- ==========================================
               local radioSound = Instance.new("Sound")
               radioSound.Name = "CustomMusicPlayer"
               radioSound.Volume = 1
               radioSound.Looped = true
               radioSound.Parent = handle
               
               customUI = Instance.new("ScreenGui")
               customUI.Name = "ExploitRadioUI"
               customUI.ResetOnSpawn = false
               customUI.Parent = player:WaitForChild("PlayerGui")
               
               local frame = Instance.new("Frame", customUI)
               frame.Size = UDim2.new(0, 250, 0, 170)
               frame.Position = UDim2.new(0.5, -125, 0.8, -170)
               frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
               frame.BorderSizePixel = 2
               frame.BorderColor3 = Color3.fromRGB(0, 255, 128)
               frame.Visible = false
               
               -- ==========================================
               -- [NEW]: INVISIBLE 3D TOUCH ZONE
               -- ==========================================
               -- Creates an invisible button hovering directly over the radio.
               -- This bypasses body collision and prevents accidental screen taps.
               local touchZone = Instance.new("BillboardGui")
               touchZone.Name = "RadioTouchZone"
               touchZone.Size = UDim2.new(3, 0, 3, 0) -- Size of the tap area (3x3 studs)
               touchZone.Adornee = handle
               touchZone.AlwaysOnTop = true -- Player's arm won't block the tap
               touchZone.Parent = customUI 
               
               local touchBtn = Instance.new("TextButton")
               touchBtn.Size = UDim2.new(1, 0, 1, 0)
               touchBtn.BackgroundTransparency = 1 -- 100% Invisible
               touchBtn.Text = ""
               touchBtn.Parent = touchZone
               
               touchBtn.MouseButton1Click:Connect(function()
                   frame.Visible = not frame.Visible
               end)
               -- ==========================================
               
               local title = Instance.new("TextLabel", frame)
               title.Size = UDim2.new(1, 0, 0, 25)
               title.Text = "📻 RADIO MENU 📻"
               title.TextColor3 = Color3.new(1, 1, 1)
               title.BackgroundTransparency = 1
               title.Font = Enum.Font.SourceSansBold
               title.TextSize = 18
               
               local inputBox = Instance.new("TextBox", frame)
               inputBox.Size = UDim2.new(0.9, 0, 0, 30)
               inputBox.Position = UDim2.new(0.05, 0, 0.22, 0)
               inputBox.PlaceholderText = "Paste ID here (Ex: 142376088)"
               inputBox.Text = ""
               inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
               inputBox.TextColor3 = Color3.new(1, 1, 1)
               inputBox.TextScaled = true
               
               -- ROW 1: Play & Stop
               local playBtn = Instance.new("TextButton", frame)
               playBtn.Size = UDim2.new(0.4, 0, 0, 35)
               playBtn.Position = UDim2.new(0.05, 0, 0.48, 0)
               playBtn.Text = "▶ PLAY"
               playBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
               playBtn.TextColor3 = Color3.new(1, 1, 1)
               playBtn.Font = Enum.Font.SourceSansBold
               
               local stopBtn = Instance.new("TextButton", frame)
               stopBtn.Size = UDim2.new(0.4, 0, 0, 35)
               stopBtn.Position = UDim2.new(0.55, 0, 0.48, 0)
               stopBtn.Text = "⏹ STOP"
               stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
               stopBtn.TextColor3 = Color3.new(1, 1, 1)
               stopBtn.Font = Enum.Font.SourceSansBold

               -- ROW 2: Previous & Next
               local prevBtn = Instance.new("TextButton", frame)
               prevBtn.Size = UDim2.new(0.4, 0, 0, 35)
               prevBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
               prevBtn.Text = "⏪ PREV"
               prevBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
               prevBtn.TextColor3 = Color3.new(1, 1, 1)
               prevBtn.Font = Enum.Font.SourceSansBold

               local nextBtn = Instance.new("TextButton", frame)
               nextBtn.Size = UDim2.new(0.4, 0, 0, 35)
               nextBtn.Position = UDim2.new(0.55, 0, 0.74, 0)
               nextBtn.Text = "NEXT ⏩"
               nextBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
               nextBtn.TextColor3 = Color3.new(1, 1, 1)
               nextBtn.Font = Enum.Font.SourceSansBold
               
               -- Track Navigation Function
               local function playPlaylistTrack()
                   local id = playlist[currentTrackIndex]
                   if id and id ~= "" then
                       inputBox.Text = id
                       radioSound.SoundId = "rbxassetid://" .. id
                       radioSound:Play()
                   else
                       inputBox.Text = "[Empty Slot]"
                       radioSound:Stop()
                   end
               end

               playBtn.MouseButton1Click:Connect(function()
                   local id = inputBox.Text:match("%d+")
                   if id then
                       radioSound.SoundId = "rbxassetid://" .. id
                       radioSound:Play()
                   end
               end)
               
               stopBtn.MouseButton1Click:Connect(function()
                   radioSound:Stop()
               end)

               prevBtn.MouseButton1Click:Connect(function()
                   currentTrackIndex = currentTrackIndex - 1
                   if currentTrackIndex < 1 then
                       currentTrackIndex = #playlist
                   end
                   playPlaylistTrack()
               end)

               nextBtn.MouseButton1Click:Connect(function()
                   currentTrackIndex = currentTrackIndex + 1
                   if currentTrackIndex > #playlist then
                       currentTrackIndex = 1
                   end
                   playPlaylistTrack()
               end)
               
               clonedTool.Parent = player.Backpack 
               task.wait(0.1) 
               if humanoid then humanoid:EquipTool(clonedTool) end
               
               Rayfield:Notify({
                   Title = "Radio Operational",
                   Content = "Invisible touch zone applied. Tap the radio to open the menu.",
                   Duration = 4,
               })
           end)

           if not success then
               Rayfield:Notify({Title = "Error", Content = tostring(errorMessage), Duration = 6})
           end
           
       else
           pcall(function()
               if customUI then customUI:Destroy() customUI = nil end
               if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName) then player.Backpack[toolName]:Destroy() end
               if character and character:FindFirstChild(toolName) then character[toolName]:Destroy() end
               if clonedTool then clonedTool:Destroy() clonedTool = nil end
               
               Rayfield:Notify({Title = "Radio Off", Content = "Inventory and UI cleared.", Duration = 2})
           end)
       end
   end,
})
