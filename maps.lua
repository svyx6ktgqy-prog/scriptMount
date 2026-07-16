-- ==================================================
-- [ ALB8RAAQ ] - SAFE ZONE WARPER & ESP GUIDE
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: SAFE ZONE WARPER",
   LoadingTitle = "Starting Zone Scanner...",
   LoadingSubtitle = "Anti-Rubberband Protection Enabled",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local ZoneTab = Window:CreateTab("Physical Zones 📍", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService") -- Added for real-time calculation
local LocalPlayer = Players.LocalPlayer

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Status: Ready to scan the world.")

-- ==========================================
-- ESP SYSTEM VARIABLES
-- ==========================================
local isESPActive = false
local CurrentESP = {
    Beam = nil,
    AtchPlayer = nil,
    AtchTarget = nil,
    Highlight = nil,
    Billboard = nil,
    DistanceUpdater = nil -- New: To handle the distance loop
}

-- ==========================================
-- ZONE SCANNING ENGINE
-- ==========================================
local function ScanForZones()
    FoundZones = {}
    ZoneNames = {}
    
    local count = 0
    -- Recursive search throughout the Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        
        -- Filter: Must contain "zone", "cavezone", or "cave"
        if string.find(nameLower, "zone") or string.find(nameLower, "cave") then
            
            local targetPart = nil
            
            -- Extract the physical block we can teleport to
            if obj:IsA("BasePart") then
                targetPart = obj
            elseif obj:IsA("Model") or obj:IsA("Folder") then
                -- If it's a folder/model, look for the first physical part inside
                targetPart = obj:FindFirstChildWhichIsA("BasePart", true)
            end
            
            if targetPart then
                -- Avoid exact duplicates in the list
                if not FoundZones[obj.Name] then
                    FoundZones[obj.Name] = targetPart
                    table.insert(ZoneNames, obj.Name)
                    count = count + 1
                end
            end
        end
    end
    
    -- Sort alphabetically so CaveZone_1, CaveZone_2, etc., are in order
    table.sort(ZoneNames)
    
    return count
end

-- ==========================================
-- ESP GUIDE FUNCTIONS (ADDITIONAL)
-- ==========================================
local function ClearESP()
    -- Stop the distance calculation if it exists
    if CurrentESP.DistanceUpdater then
        CurrentESP.DistanceUpdater:Disconnect()
        CurrentESP.DistanceUpdater = nil
    end

    for key, instance in pairs(CurrentESP) do
        if typeof(instance) == "Instance" and instance.Parent then
            instance:Destroy()
        end
        CurrentESP[key] = nil
    end
end

local function ActivateESP(targetPart, zoneName)
    ClearESP() -- Clear any previously active ESP

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetPart then return end

    -- 1. Highlight (See through walls)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = targetPart
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = targetPart
    CurrentESP.Highlight = highlight

    -- 2. Guide Line (Beam)
    local atchPlayer = Instance.new("Attachment")
    atchPlayer.Parent = hrp
    CurrentESP.AtchPlayer = atchPlayer

    local atchTarget = Instance.new("Attachment")
    atchTarget.Parent = targetPart
    CurrentESP.AtchTarget = atchTarget

    local beam = Instance.new("Beam")
    beam.Attachment0 = atchPlayer
    beam.Attachment1 = atchTarget
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
    beam.FaceCamera = true
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = hrp
    CurrentESP.Beam = beam

    -- 3. Floating Text (BillboardGui)
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = targetPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "📍 " .. zoneName
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextScaled = true
    textLabel.Parent = billboard

    billboard.Parent = targetPart
    CurrentESP.Billboard = billboard

    -- 4. Real-Time Distance Updater
    CurrentESP.DistanceUpdater = RunService.RenderStepped:Connect(function()
        -- Verify that the player and target still exist
        if hrp and hrp.Parent and targetPart and targetPart.Parent then
            -- Calculate magnitude (distance) between the two points
            local distance = math.floor((hrp.Position - targetPart.Position).Magnitude)
            -- Update the billboard text
            textLabel.Text = "📍 " .. zoneName .. " [" .. tostring(distance) .. "m]"
        else
            -- If the player dies or the zone disappears, turn off the ESP to prevent errors
            ClearESP()
        end
    end)
end

-- ==========================================
-- SAFE TRAVEL PROTOCOL (ANTI-GLITCH)
-- ==========================================
local function SafeTeleport(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetPart then 
        Rayfield:Notify({Title = "Error", Content = "Could not find character or destination.", Duration = 3})
        return 
    end

    StatusLabel:Set("Status: Calculating safe landing...")

    -- 1. Calculate the top surface of the block so you don't get stuck in the ground
    local safeY = targetPart.Position.Y + (targetPart.Size.Y / 2) + 3.5
    local safeDest = CFrame.new(targetPart.Position.X, safeY, targetPart.Position.Z)

    -- 2. Anchor the player and reset physics (Prevents anticheat from detecting a sudden speed jump)
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero

    -- 3. Move the player
    hrp.CFrame = safeDest

    -- 4. Wait for the server to render the chunk (the map around you)
    task.wait(0.5) 

    -- 5. Safely release the player on solid ground
    hrp.Anchored = false
    
    StatusLabel:Set("Status: Landing completed successfully.")
    Rayfield:Notify({Title = "Warp Successful", Content = "You have arrived at " .. SelectedZoneName, Duration = 2})
end

-- ==========================================
-- INTERFACE
-- ==========================================

ZoneTab:CreateButton({
    Name = "🔍 Scan All Zones (CaveZones & Variants)",
    Callback = function()
        StatusLabel:Set("Status: Scanning Workspace...")
        local total = ScanForZones()
        
        if total > 0 then
            StatusLabel:Set("Status: Found " .. tostring(total) .. " physical zones.")
            _G.ZoneDropdown:Refresh(ZoneNames, true)
            Rayfield:Notify({Title = "Zones Found", Content = "Check the dropdown menu.", Duration = 3})
        else
            StatusLabel:Set("Status: No physical zones found.")
            Rayfield:Notify({Title = "No Results", Content = "No physical zones detected. They might be in another dimension.", Duration = 4})
        end
    end
})

ZoneTab:CreateLabel("--- DESTINATION SELECTION ---")

_G.ZoneDropdown = ZoneTab:CreateDropdown({
    Name = "📍 Select Zone",
    Options = {"Scan first..."},
    CurrentOption = {"Scan first..."},
    MultipleOptions = false,
    Flag = "ZoneSelector",
    Callback = function(Option)
        SelectedZoneName = Option[1]
        
        -- If ESP is active and we change zones, update the guide automatically
        if isESPActive and SelectedZoneName ~= "Scan first..." then
            local targetBlock = FoundZones[SelectedZoneName]
            if targetBlock then
                ActivateESP(targetBlock, SelectedZoneName)
            end
        end
    end,
})

-- NEW: ESP TOGGLE
ZoneTab:CreateToggle({
    Name = "👁️ Enable ESP Guide",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        isESPActive = Value
        if isESPActive then
            if SelectedZoneName and SelectedZoneName ~= "Scan first..." then
                local targetBlock = FoundZones[SelectedZoneName]
                if targetBlock then
                    ActivateESP(targetBlock, SelectedZoneName)
                    Rayfield:Notify({Title = "ESP Enabled", Content = "Visual tracker towards " .. SelectedZoneName, Duration = 2})
                end
            else
                Rayfield:Notify({Title = "Notice", Content = "Select a zone first.", Duration = 3})
            end
        else
            ClearESP()
            Rayfield:Notify({Title = "ESP Disabled", Content = "Visual tracker hidden.", Duration = 2})
        end
    end,
})

ZoneTab:CreateButton({
    Name = "⚡ SAFE TRAVEL (Anti-Fail / Anti-Rubberband)",
    Callback = function()
        if not SelectedZoneName or SelectedZoneName == "Scan first..." then
            Rayfield:Notify({Title = "Notice", Content = "Select a zone from the list.", Duration = 3})
            return
        end

        local targetBlock = FoundZones[SelectedZoneName]
        if targetBlock then
            SafeTeleport(targetBlock)
        else
            Rayfield:Notify({Title = "Error", Content = "The zone block no longer exists.", Duration = 3})
        end
    end
})

-- Copy current zone path (Useful for debugging)
ZoneTab:CreateButton({
    Name = "📋 Copy Selected Zone Path",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] and setclipboard then
            setclipboard(FoundZones[SelectedZoneName]:GetFullName())
            Rayfield:Notify({Title = "Path Copied", Content = "Block path copied to clipboard.", Duration = 2})
        end
    end
})
