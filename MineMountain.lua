-- =====================================================================
-- 💎 ALB8RAAQ SUPER HUB (Merged 6-in-1 Script)
-- UI: Rayfield | All features preserved & translated to English
-- =====================================================================

if _G.ALB8RAAQLoaded then
    warn("The menu is already running.")
    return
end
_G.ALB8RAAQLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

-- =====================================================================
-- GLOBAL SERVICES & UTILITIES
-- =====================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local function getHumanoid()
    if LocalPlayer.Character then return LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function getRoot()
    if LocalPlayer.Character then return LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- =====================================================================
-- RAYFIELD INITIALIZATION
-- =====================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Loading Ultimate Script...",
   LoadingSubtitle = "All-in-One Hub",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Wallpaper Injection for Rayfield
task.spawn(function()
    task.wait(2)
    for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if gui:IsA("Frame") and gui.Name == "Main" and gui.Parent and gui.Parent.Name == "Rayfield" then
            local wallpaper = Instance.new("ImageLabel")
            wallpaper.Name = "RayfieldWallpaper"
            wallpaper.Size = UDim2.new(1, 0, 1, 0)
            wallpaper.Position = UDim2.new(0, 0, 0, 0)
            wallpaper.BackgroundTransparency = 1
            wallpaper.Image = "rbxassetid://1378768007" 
            wallpaper.ImageTransparency = 0.65
            wallpaper.ScaleType = Enum.ScaleType.Crop
            wallpaper.ZIndex = 0 
            wallpaper.Parent = gui
            break
        end
    end
end)

-- =====================================================================
-- TAB 1: FIRE EFFECTS (From Source 1)
-- =====================================================================
local FireTab = Window:CreateTab("Fire Effects", 4483362458) 

local function clearFire(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "CustomFire" then
            child:Destroy()
        end
    end
end

local SectionTool = FireTab:CreateSection("Tool / Pickaxe")

FireTab:CreateButton({
   Name = "Burn Equipped Tool",
   Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            clearFire(handle) 
            
            local fire = Instance.new("Fire")
            fire.Name = "CustomFire"
            fire.Size = 5
            fire.Heat = 9
            fire.Parent = handle
            
            Rayfield:Notify({Title = "Success!", Content = "Fire embedded in: " .. tool.Name, Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "You must equip a tool in your hand first!", Duration = 3})
        end
   end,
})

FireTab:CreateButton({
   Name = "Extinguish Tool Fire",
   Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            clearFire(tool.Handle)
        end
   end,
})

local SectionHead = FireTab:CreateSection("Player")

FireTab:CreateButton({
   Name = "Burn Player Head",
   Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local head = character:FindFirstChild("Head")
        
        if head then
            clearFire(head) 
            local fire = Instance.new("Fire")
            fire.Name = "CustomFire"
            fire.Size = 6
            fire.Heat = 15
            fire.Parent = head
            
            Rayfield:Notify({Title = "Success!", Content = "Fire embedded in your head.", Duration = 3})
        end
   end,
})

FireTab:CreateButton({
   Name = "Extinguish Head Fire",
   Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local head = character:FindFirstChild("Head")
        if head then
            clearFire(head)
        end
   end,
})

-- =====================================================================
-- TAB 2: MINING & AUTOMATION (From Source 2)
-- =====================================================================
local MiningTab = Window:CreateTab("Mining Automation", 4483362458)

MiningTab:CreateButton({
    Name = "🧲 Attract Diamonds/Items (Scattered)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                if item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin") then
                    
                    local randomX = math.random(-15, 15)
                    local randomY = math.random(3, 8) 
                    local randomZ = math.random(-15, 15)
                    
                    pcall(function()
                        item.Anchored = false
                        item.Velocity = Vector3.new(0, -2, 0) 
                        item.RotVelocity = Vector3.zero
                    end)
                    
                    item.CFrame = CFrame.new(root.Position + Vector3.new(randomX, randomY, randomZ))
                    count = count + 1
                    
                    if count % 20 == 0 then task.wait() end
                end
            end
        end
        Rayfield:Notify({Title = "Safe Magnet Activated", Content = "Attracted " .. count .. " items. Scattered without lag.", Duration = 4})
    end,
})

MiningTab:CreateButton({
    Name = "💎 Collect/Equip Giant Diamonds (VIP)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local name = item.Name:lower()
                if string.match(name, "huge") or string.match(name, "big") or string.match(name, "giant") or string.match(name, "master") then
                    item.CFrame = root.CFrame
                    local touch = item:FindFirstChild("TouchInterest")
                    if touch and firetouchinterest then
                        firetouchinterest(root, item, 0)
                        task.wait(0.01)
                        firetouchinterest(root, item, 1)
                        count = count + 1
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Massive Extraction", Content = "Giant diamonds ("..count..") collected and equipped.", Duration = 4})
    end,
})

MiningTab:CreateButton({
    Name = "💣 Detonate Site (Explosive Trigger)",
    Callback = function()
        local found = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if string.match(obj.Name:lower(), "kill") or string.match(obj.Name:lower(), "explode") or string.match(obj.Name:lower(), "nuke") or string.match(obj.Name:lower(), "dynamite") then
                if obj:IsA("RemoteEvent") then
                    obj:FireServer()
                    found = true
                elseif obj:IsA("Tool") or obj:IsA("Model") then
                    pcall(function() obj.Parent = LocalPlayer.Character end)
                    found = true
                end
            end
        end
        if found then
            Rayfield:Notify({Title = "Explosion", Content = "Explosive trigger activated.", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "Functional detonator not found.", Duration = 3})
        end
    end,
})

MiningTab:CreateButton({
    Name = "💥 Super Punch / Nuke Rocks (Local)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, rock in ipairs(workspace:GetDescendants()) do
            if rock:IsA("Part") or rock:IsA("MeshPart") then
                local name = rock.Name:lower()
                if string.match(name, "rock") or string.match(name, "stone") or string.match(name, "ore") or string.match(name, "mountain") then
                    if (rock.Position - root.Position).Magnitude < 100 then
                        rock:Destroy()
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Mountains Cleared", Content = "Nearby rocks destroyed (Client-Side).", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "🎁 Claim All Gifts",
    Callback = function()
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if string.match(name, "claim") or string.match(name, "gift") or string.match(name, "reward") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
        Rayfield:Notify({Title = "Gifts", Content = "Attempted to claim everything.", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "⬆️ Auto Upgrade (Brute Force)",
    Callback = function()
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if string.match(name, "upgrade") or string.match(name, "buy") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
        Rayfield:Notify({Title = "Upgrades", Content = "Attempting to upgrade pickaxe...", Duration = 3})
    end,
})

-- =====================================================================
-- TAB 3: VISUALS & ESP (Merged from Source 2)
-- =====================================================================
local VisualsTab = Window:CreateTab("Visuals & ESP", 4483362458)
local oreEspEnabled = false
local espEnabled = false
local Tracers = {}

VisualsTab:CreateToggle({
    Name = "💎 ESP Diamonds and Rarities",
    CurrentValue = false,
    Flag = "OreESP",
    Callback = function(Value) 
        oreEspEnabled = Value
        if not Value then
            for _, item in ipairs(workspace:GetDescendants()) do
                if item.Name == "OreESPGui" then item:Destroy() end
            end
            Rayfield:Notify({Title = "Visuals", Content = "Mineral ESP disabled and cleared.", Duration = 2})
        end
    end,
})

local selectedOre = "None" 
local OreDropdown = VisualsTab:CreateDropdown({
    Name = "🔍 Select Mineral / Item",
    Options = {"None"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "OreTeleportSelector",
    Callback = function(Options)
        selectedOre = Options[1]
    end,
})

VisualsTab:CreateButton({
    Name = "🚀 Travel to Mineral (To Go)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        if selectedOre and selectedOre ~= "None" and selectedOre ~= "" then
            local found = false
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == selectedOre then
                    local isCollectible = item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin")
                    if isCollectible then
                        root.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                        Rayfield:Notify({Title = "Teleport", Content = "Traveling to: " .. selectedOre, Duration = 2})
                        found = true
                        break
                    end
                end
            end
            if not found then Rayfield:Notify({Title = "Error", Content = selectedOre .. " not found on the map.", Duration = 3}) end
        else
            Rayfield:Notify({Title = "Notice", Content = "Please select a mineral from the list first.", Duration = 3})
        end
    end,
})

VisualsTab:CreateButton({
    Name = "🧲 Bring Mineral to Me (Get)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        if selectedOre and selectedOre ~= "None" and selectedOre ~= "" then
            local found = false
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == selectedOre then
                    local isCollectible = item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin")
                    if isCollectible then
                        item.CFrame = root.CFrame * CFrame.new(0, 4, -3)
                        pcall(function() item.Anchored = false end) 
                        Rayfield:Notify({Title = "Object Attracted", Content = selectedOre .. " has been brought to you.", Duration = 2})
                        found = true
                        break
                    end
                end
            end
            if not found then Rayfield:Notify({Title = "Error", Content = "Could not bring object " .. selectedOre, Duration = 3}) end
        else
            Rayfield:Notify({Title = "Notice", Content = "Please select a mineral from the list first.", Duration = 3})
        end
    end,
})

-- Background ESP mapping loop for OreDropdown
task.spawn(function()
    while task.wait(1.5) do
        local availableOres = {}
        local foundNames = {}
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local nameLower = item.Name:lower()
                local isMatch = item:FindFirstChild("TouchInterest") or string.match(nameLower, "gem") or string.match(nameLower, "diamond") or string.match(nameLower, "coin") or nameLower:find("ore")
                
                if isMatch then
                    if not foundNames[item.Name] then
                        table.insert(availableOres, item.Name)
                        foundNames[item.Name] = true
                    end
                    
                    if oreEspEnabled and not item:FindFirstChild("OreESPGui") then
                        local bill = Instance.new("BillboardGui", item)
                        bill.Name = "OreESPGui"
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 100, 0, 50)
                        local txt = Instance.new("TextLabel", bill)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.Text = "✨ " .. item.Name
                        txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                        txt.BackgroundTransparency = 1
                    end
                end
            end
        end
        table.sort(availableOres)
        OreDropdown:Refresh(#availableOres > 0 and availableOres or {"None"})
    end
end)

VisualsTab:CreateToggle({
    Name = "🌈 Enable Player ESP (Rainbow + Tracers)",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            for _, tracer in pairs(Tracers) do tracer:Remove() end
            Tracers = {}
        end
    end,
})

RunService.RenderStepped:Connect(function()
    local hue = tick() % 3 / 3
    local rainbowColor = Color3.fromHSV(hue, 1, 1)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local highlight = player.Character:FindFirstChild("UniversalESP")
            
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UniversalESP"
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
                highlight.Enabled = true
                highlight.FillColor = rainbowColor
                highlight.OutlineColor = rainbowColor

                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if not Tracers[player] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Transparency = 1
                    Tracers[player] = line
                end
                
                if onScreen then
                    Tracers[player].Visible = true
                    Tracers[player].From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    Tracers[player].To = Vector2.new(vector.X, vector.Y)
                    Tracers[player].Color = rainbowColor
                else
                    Tracers[player].Visible = false
                end
            else
                if highlight then highlight.Enabled = false end
                if Tracers[player] then
                    Tracers[player]:Remove()
                    Tracers[player] = nil
                end
            end
        else
            if Tracers[player] then
                Tracers[player]:Remove()
                Tracers[player] = nil
            end
        end
    end
end)

VisualsTab:CreateButton({
    Name = "🔓 Total Unlock (Clothes/Secrets)",
    Callback = function()
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if string.match(name, "unlock") or string.match(name, "get") or string.match(name, "buy") or string.match(name, "grant") then
                    pcall(function() obj:FireServer("all") end)
                    pcall(function() obj:FireServer(true) end)
                end
            end
        end
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("GuiObject") and (gui.Name:lower():find("lock") or gui.Name:lower():find("padlock")) then
                gui.Visible = false
            end
        end
        Rayfield:Notify({Title = "Complete Unlock", Content = "Unlocks forced and UI cleared.", Duration = 4})
    end,
})

VisualsTab:CreateButton({
    Name = "🔓 Unlock/View Map Secrets",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if string.match(part.Name:lower(), "secret") or string.match(part.Name:lower(), "hidden") then
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = false
                end
            end
        end
        Rayfield:Notify({Title = "Secrets", Content = "Hidden objects revealed.", Duration = 3})
    end,
})

VisualsTab:CreateButton({
    Name = "👕 Unlock Outfits & Skins (Visual Bypass)",
    Callback = function()
        for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (string.match(obj.Name:lower(), "outfit") or string.match(obj.Name:lower(), "skin") or string.match(obj.Name:lower(), "equip") or string.match(obj.Name:lower(), "unlock")) then
                pcall(function() obj:FireServer(true) end)
                pcall(function() obj:FireServer("EquipAll") end)
            end
        end
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") or gui:IsA("Frame") then
                if string.match(gui.Name:lower(), "lock") or string.match(gui.Name:lower(), "padlock") then
                    gui.Visible = false
                end
            end
        end
        Rayfield:Notify({Title = "Outfits", Content = "Hidden skin padlocks and remotes executed.", Duration = 4})
    end,
})

-- =====================================================================
-- TAB 4: MOVEMENT, MAPS & TROLL (Merged from Source 2)
-- =====================================================================
local MoveMapTab = Window:CreateTab("Movement, Maps & Troll", 4483362458)

MoveMapTab:CreateSection("Rapid Progression")

MoveMapTab:CreateButton({
    Name = "🚪 Force TP ZONE SECRET",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local found = false
        local keywords = {"portal", "teleport", "nextmap", "nextzone", "gate", "door", "area", "zone", "world"}
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                for _, word in ipairs(keywords) do
                    if string.match(n, word) and not string.match(n, "spawn") and not string.match(n, "lobby") then
                        root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                        found = true
                        local touch = part:FindFirstChild("TouchInterest")
                        if touch and firetouchinterest then
                            firetouchinterest(root, part, 0)
                            task.wait(0.1)
                            firetouchinterest(root, part, 1)
                        end
                        Rayfield:Notify({Title = "Map Jump", Content = "Teleported to: " .. part.Name, Duration = 3})
                        return 
                    end
                end
            end
        end
        if not found then Rayfield:Notify({Title = "No Portals", Content = "No new zones detected at this time.", Duration = 3}) end
    end,
})

MoveMapTab:CreateButton({
    Name = "🧱 Remove Invisible Walls / VIP Barriers",
    Callback = function()
        local wallsRemoved = 0
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if string.match(n, "barrier") or string.match(n, "wall") or string.match(n, "border") or string.match(n, "vip") or string.match(n, "requirement") or part.Transparency == 1 then
                    if part.CanCollide == true and part.Name ~= "HumanoidRootPart" and part.Name ~= "Baseplate" then
                        part.CanCollide = false
                        wallsRemoved = wallsRemoved + 1
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Map Noclip", Content = wallsRemoved .. " walls/barriers removed.", Duration = 3})
    end,
})

MoveMapTab:CreateSection("Movement & Troll Options")

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
end

local TpDropdown = MoveMapTab:CreateDropdown({
    Name = "🎯 Teleport to Player",
    Options = playerNames,
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TpPlayer",
    Callback = function(Options)
        local targetName = Options[1]
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end
        end
    end,
})

local selectedTrollPlayer = "None"
local trollFollowEnabled = false

local TrollDropdown = MoveMapTab:CreateDropdown({
    Name = "👤 Select Victim (Player)",
    Options = {"None"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TrollPlayerSelector",
    Callback = function(Options) selectedTrollPlayer = Options[1] end
})

MoveMapTab:CreateToggle({
    Name = "👣 Enable Full Shadow Mode",
    CurrentValue = false,
    Flag = "TrollFollowToggle",
    Callback = function(Value)
        trollFollowEnabled = Value
        if Value then
            if selectedTrollPlayer == "None" or selectedTrollPlayer == "" then
                Rayfield:Notify({Title = "Troll Notice", Content = "Select a valid player.", Duration = 3})
                return
            end
            
            pcall(function()
                local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and localRoot then
                        local behindPos = (targetRoot.CFrame * CFrame.new(0, 0, 3)).Position
                        localRoot.CFrame = CFrame.lookAt(behindPos, targetRoot.Position)
                    end
                end
            end)
            
            Rayfield:Notify({Title = "Shadow Mode V3", Content = "Physical link active with: " .. selectedTrollPlayer, Duration = 3})
            
            task.spawn(function()
                while trollFollowEnabled do
                    task.wait(0.01) 
                    if selectedTrollPlayer and selectedTrollPlayer ~= "None" then
                        local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                        if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local localHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHum and localRoot and localHum then
                                local bg = localRoot:FindFirstChild("TrollGyro")
                                if not bg then
                                    bg = Instance.new("BodyGyro")
                                    bg.Name = "TrollGyro"
                                    bg.maxTorque = Vector3.new(0, 999999, 0) 
                                    bg.P = 60000 
                                    bg.D = 400
                                    bg.Parent = localRoot
                                end
                                bg.CFrame = CFrame.lookAt(Vector3.zero, targetRoot.CFrame.LookVector)

                                local behindPosition = (targetRoot.CFrame * CFrame.new(0, 0, 2.8)).Position
                                local bp = localRoot:FindFirstChild("TrollPosition")
                                if not bp then
                                    bp = Instance.new("BodyPosition")
                                    bp.Name = "TrollPosition"
                                    bp.maxForce = Vector3.new(600000, 0, 600000) 
                                    bp.P = 40000
                                    bp.D = 1000
                                    bp.Parent = localRoot
                                end
                                bp.Position = behindPosition
                                
                                localHum.WalkSpeed = targetHum.WalkSpeed
                                local targetState = targetHum:GetState()
                                if targetHum.Jump or targetState == Enum.HumanoidStateType.Jumping or targetState == Enum.HumanoidStateType.Freefall then
                                    localHum.Jump = true
                                end
                                
                                local targetHasTool = targetPlayer.Character:FindFirstChildOfClass("Tool") ~= nil
                                local nearOre = false
                                pcall(function()
                                    local nearbyParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 7)
                                    for _, part in ipairs(nearbyParts) do
                                        local n = part.Name:lower()
                                        if string.match(n, "gem") or string.match(n, "diamond") or string.match(n, "coin") or string.match(n, "ore") or string.match(n, "rock") or string.match(n, "stone") then
                                            nearOre = true
                                            break
                                        end
                                    end
                                end)
                                
                                local isAttacking = false
                                if targetHasTool and nearOre then
                                    isAttacking = true
                                else
                                    pcall(function()
                                        for _, anim in ipairs(targetHum:GetPlayingAnimationTracks()) do
                                            if anim.IsPlaying then
                                                local id = anim.Animation.AnimationId
                                                if not id:find("252654100") and not id:find("180426354") and not id:find("507766388") then
                                                    isAttacking = true
                                                    break
                                                end
                                            end
                                        end
                                    end)
                                end
                                
                                if isAttacking then
                                    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if not localTool then
                                        local toolInBackpack = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                        if toolInBackpack then
                                            localHum:EquipTool(toolInBackpack)
                                            localTool = toolInBackpack
                                        end
                                    end
                                    if localTool then localTool:Activate() end
                                end
                                
                                pcall(function()
                                    if firetouchinterest then
                                        local collectParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 10)
                                        for _, part in ipairs(collectParts) do
                                            local nameLower = part.Name:lower()
                                            if part:FindFirstChild("TouchInterest") or nameLower:find("gem") or nameLower:find("diamond") or nameLower:find("coin") then
                                                firetouchinterest(localRoot, part, 0)
                                                task.wait()
                                                firetouchinterest(localRoot, part, 1)
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        else
            local root = getRoot()
            if root then
                if root:FindFirstChild("TrollGyro") then root.TrollGyro:Destroy() end
                if root:FindFirstChild("TrollPosition") then root.TrollPosition:Destroy() end
            end
            Rayfield:Notify({Title = "Shadow Mode", Content = "Disabled. Physics restored.", Duration = 2})
        end
    end,
})

local function updateTrollDropdown()
    local currentPlayers = {"None"}
    local currentNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            table.insert(currentPlayers, p.Name)
            table.insert(currentNames, p.Name) 
        end
    end
    TrollDropdown:Refresh(currentPlayers)
    TpDropdown:Refresh(currentNames)
end
Players.PlayerAdded:Connect(updateTrollDropdown)
Players.PlayerRemoving:Connect(updateTrollDropdown)
updateTrollDropdown()

local flying = false
MoveMapTab:CreateToggle({
    Name = "🦅 Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        flying = Value
        local root = getRoot()
        if not root then return end
        
        if flying then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            
            RunService.RenderStepped:Connect(function()
                if flying and root:FindFirstChild("FlyVelocity") then
                    local moveDir = getHumanoid().MoveDirection
                    root.FlyVelocity.Velocity = moveDir * 50
                end
            end)
        else
            if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        end
    end,
})

MoveMapTab:CreateButton({
    Name = "🚪 Teleport to Next Map/Portal",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") and (string.match(part.Name:lower(), "portal") or string.match(part.Name:lower(), "teleport") or string.match(part.Name:lower(), "nextmap")) then
                root.CFrame = part.CFrame
                Rayfield:Notify({Title = "Portal Found", Content = "Teleporting...", Duration = 3})
                return
            end
        end
        Rayfield:Notify({Title = "Error", Content = "No portals found on the map.", Duration = 3})
    end,
})

MoveMapTab:CreateButton({
    Name = "🔄 Server Hop",
    Callback = function()
        Rayfield:Notify({Title = "Server Hop", Content = "Searching for a new server...", Duration = 3})
        local serversUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(serversUrl)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end,
})

-- =====================================================================
-- TAB 5: AUTO-HARVEST (From Source 3)
-- =====================================================================
local HarvestTab = Window:CreateTab("Auto-Mine ⛏️", 4483362458)
local ConfigTab = Window:CreateTab("Configuration ⚙️", 4483362458)

local AutoFarmActive = false
local SelectedTier = "All"
local MinPriceFilter = 0 
local AutoEquipTool = true
local HitSpeed = 0.05 
local manualList = {}
local manualIndex = 1
local manualTarget = nil
local ESPGuideActive = false

local ESPElements = {Beam = nil, AttPlayer = nil, AttTarget = nil, BillGui = nil, Text = nil, MeshBox = nil, Loop = nil}
local temporaryBlacklist = {}
local stickConnection = nil
local noclipConnection = nil

local tierMapping = {
    ["All"]       = "All",
    ["Common"]    = "T1",
    ["Uncommon"]  = "T2",
    ["Rare"]      = "T3",
    ["Epic"]      = "T4",
    ["Legendary"] = "T5",
    ["Mythic"]    = "T6"
}

local function ClearHarvestESP()
    for key, element in pairs(ESPElements) do
        if element then
            if typeof(element) == "RBXScriptConnection" then element:Disconnect() else element:Destroy() end
        end
    end
    ESPElements = {Beam = nil, AttPlayer = nil, AttTarget = nil, BillGui = nil, Text = nil, MeshBox = nil, Loop = nil}
end

local function CreateHarvestESP(target)
    ClearHarvestESP()
    if not target or not ESPGuideActive then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local part = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) or target
    
    if not hrp or not part then return end

    local att0 = Instance.new("Attachment", hrp)
    local att1 = Instance.new("Attachment", part)
    
    local beam = Instance.new("Beam", part)
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.FaceCamera = true
    beam.Width0 = 0.4
    beam.Width1 = 0.4
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    beam.LightEmission = 1
    
    local meshBox = Instance.new("BoxHandleAdornment", part)
    meshBox.Adornee = part
    meshBox.Size = part.Size + Vector3.new(0.5, 0.5, 0.5) 
    meshBox.Color3 = Color3.fromRGB(0, 255, 255)
    meshBox.Transparency = 0.6
    meshBox.AlwaysOnTop = true

    local bgui = Instance.new("BillboardGui", part)
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    
    local txt = Instance.new("TextLabel", bgui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold

    ESPElements.AttPlayer = att0; ESPElements.AttTarget = att1
    ESPElements.Beam = beam; ESPElements.MeshBox = meshBox
    ESPElements.BillGui = bgui; ESPElements.Text = txt
    
    ESPElements.Loop = RunService.Heartbeat:Connect(function()
        if hrp and part then
            local dist = (hrp.Position - part.Position).Magnitude
            txt.Text = string.format("💎 %d Meters", math.floor(dist))
        else
            ClearHarvestESP()
        end
    end)
end

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function stopStick()
    if stickConnection then stickConnection:Disconnect(); stickConnection = nil end
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startStick(part)
    stopStick()
    enableNoclip() 
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end 
    end
    stickConnection = RunService.Heartbeat:Connect(function()
        if not part or not part.Parent then stopStick() return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function verifyAndEquipTool()
    if not AutoEquipTool then return end
    local char = LocalPlayer.Character
    if char and not char:FindFirstChildOfClass("Tool") then
        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool then tool.Parent = char end
    end
end

local function ParseCrystalDetails(text)
    local name, kg, price = "Unknown", "N/A", "N/A"
    if text and text ~= "" then
        local parts = {}
        for part in string.gmatch(text, "[^•]+") do
            local cleaned = string.match(part, "^%s*(.-)%s*$")
            if cleaned then table.insert(parts, cleaned) end
        end
        name = parts[1] or name; kg = parts[2] or kg; price = parts[3] or price
    end
    return name, kg, price
end

local function GetPriceNumber(priceText)
    if not priceText then return 0 end
    local cleanNum = string.gsub(priceText, "[^%d]", "") 
    return tonumber(cleanNum) or 0
end

local function UpdateManualList()
    manualList = {}
    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return end

    local targetCode = tierMapping[SelectedTier]

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
        local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt.Enabled then
            local matchCode = string.match(crystal.Name, "(T[1-6])")
            local _, _, priceStr = ParseCrystalDetails(prompt.ObjectText)
            local actualPrice = GetPriceNumber(priceStr)

            if (targetCode == "All" or matchCode == targetCode) and actualPrice >= MinPriceFilter then
                table.insert(manualList, crystal)
            end
        end
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(manualList, function(a, b)
            local posA = (a:IsA("Model") and a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart") or a).Position
            local posB = (b:IsA("Model") and b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart") or b).Position
            return (hrp.Position - posA).Magnitude < (hrp.Position - posB).Magnitude
        end)
    end
end

HarvestTab:CreateSection("⛏️ Global Controls (Auto & Manual)")

HarvestTab:CreateDropdown({
   Name = "Rarity Filter",
   Options = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
   CurrentOption = "All",
   Flag = "TierSelector",
   Callback = function(Option)
        SelectedTier = type(Option) == "table" and Option[1] or Option
        manualIndex = 0 
   end,
})

HarvestTab:CreateInput({
   Name = "💰 Minimum Price ($)",
   PlaceholderText = "Clear text to search All",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        if Text == "" or Text == nil then
            MinPriceFilter = 0
            Rayfield:Notify({Title = "Filter Reset", Content = "Searching all prices (Default).", Duration = 3})
        else
            MinPriceFilter = tonumber(Text) or 0
            Rayfield:Notify({Title = "Filter Applied", Content = "Searching diamonds of $" .. MinPriceFilter .. " or more.", Duration = 3})
        end
        manualIndex = 0
        ClearHarvestESP()
        manualTarget = nil
   end,
})

HarvestTab:CreateToggle({
   Name = "Enable Continuous Auto-Farm",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
        AutoFarmActive = Value
        if Value then table.clear(temporaryBlacklist) else stopStick() end
   end,
})

HarvestTab:CreateSection("🔍 Manual Explorer (Natural Physics)")

HarvestTab:CreateToggle({
   Name = "Enable Tracking ESP (Guide, Line & Mesh)",
   CurrentValue = false,
   Flag = "ESPGuideToggle",
   Callback = function(Value)
        ESPGuideActive = Value
        if Value and manualTarget then CreateHarvestESP(manualTarget) else ClearHarvestESP() end
   end,
})

local ManualInfoParagraph = HarvestTab:CreateParagraph({
    Title = "Crystal Data",
    Content = "Press 'Next' to scan the map..."
})

local function CycleManual(direction)
    UpdateManualList()
    if #manualList == 0 then
        ManualInfoParagraph:Set({Title = "Error", Content = "No crystals meet the current filters."})
        ClearHarvestESP()
        manualTarget = nil
        return
    end

    manualIndex = manualIndex + direction
    if manualIndex > #manualList then manualIndex = 1 end
    if manualIndex < 1 then manualIndex = #manualList end

    manualTarget = manualList[manualIndex]
    
    local prompt = manualTarget:FindFirstChildOfClass("ProximityPrompt")
    local rawText = prompt and prompt.ObjectText or ""
    local name, kg, price = ParseCrystalDetails(rawText)
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pos = (manualTarget:IsA("Model") and manualTarget.PrimaryPart or manualTarget:FindFirstChildWhichIsA("BasePart") or manualTarget).Position
    local dist = hrp and math.floor((hrp.Position - pos).Magnitude) or 0

    ManualInfoParagraph:Set({
        Title = string.format("📌 %s [%d/%d]", name, manualIndex, #manualList),
        Content = string.format("⚖️ Weight: %s\n💰 Price: %s\n📏 Distance: %d studs", kg, price, dist)
    })
    
    CreateHarvestESP(manualTarget)
end

HarvestTab:CreateButton({ Name = "◀ Previous", Callback = function() CycleManual(-1) end })
HarvestTab:CreateButton({ Name = "Next ▶", Callback = function() CycleManual(1) end })

HarvestTab:CreateButton({
   Name = "🚀 TELEPORT AND EXTRACT (Natural)",
   Callback = function()
        if not manualTarget or not manualTarget.Parent then
            Rayfield:Notify({Title = "Error", Content = "Select a crystal first.", Duration = 2})
            return
        end
        
        if AutoFarmActive then AutoFarmActive = false; task.wait(0.2) end

        local part = manualTarget:IsA("Model") and (manualTarget.PrimaryPart or manualTarget:FindFirstChildWhichIsA("BasePart")) or manualTarget
        local prompt = manualTarget:FindFirstChildOfClass("ProximityPrompt")
        
        if part and prompt then
            task.spawn(function()
                verifyAndEquipTool()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    hrp.Anchored = false 
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 1.5), part.Position)
                    hrp.Velocity = Vector3.new(0, -10, 0) 
                end
                
                task.wait(0.25)
                
                local startTime = os.clock()
                while manualTarget and manualTarget:IsDescendantOf(Workspace) and prompt.Enabled do
                    if os.clock() - startTime > 8 then break end 
                    
                    if fireproximityprompt then fireproximityprompt(prompt) end
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                    
                    task.wait(HitSpeed)
                end
                
                ClearHarvestESP() 
                ManualInfoParagraph:Set({Title = "✅ Extraction Completed", Content = "Crystal collected. Look for the next one."})
                manualTarget = nil
            end)
        end
   end,
})

local function GetClosestCrystalForAuto()
    local root = getRoot()
    if not root then return nil end
    local crystalsFolder = Workspace:FindFirstChild("Things") and Workspace.Things:FindFirstChild("Crystals")
    if not crystalsFolder then return nil end

    local closestCrystal = nil
    local shortestDist = math.huge
    local targetCode = tierMapping[SelectedTier]

    for _, crystal in ipairs(crystalsFolder:GetChildren()) do
        local cooldown = temporaryBlacklist[crystal]
        if cooldown and os.clock() < cooldown then continue end

        local prompt = crystal:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt.Enabled then
            local matchCode = string.match(crystal.Name, "(T[1-6])")
            local _, _, priceStr = ParseCrystalDetails(prompt.ObjectText)
            local actualPrice = GetPriceNumber(priceStr)

            if (targetCode == "All" or matchCode == targetCode) and actualPrice >= MinPriceFilter then
                local part = crystal:IsA("BasePart") and crystal or crystal:FindFirstChildOfClass("BasePart") or crystal.PrimaryPart
                if part then
                    local dist = (root.Position - part.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestCrystal = { Instance = crystal, Part = part, Prompt = prompt }
                    end
                end
            end
        end
    end
    return closestCrystal
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmActive then
            local target = GetClosestCrystalForAuto()
            if target then
                local char = LocalPlayer.Character
                if char then
                    verifyAndEquipTool()
                    startStick(target.Part) 
                    task.wait(0.15) 
                    
                    local startTime = os.clock()
                    while AutoFarmActive and target.Instance:IsDescendantOf(Workspace) and target.Prompt.Enabled do
                        if os.clock() - startTime > 4.0 then
                            temporaryBlacklist[target.Instance] = os.clock() + 8.0
                            break
                        end
                        if fireproximityprompt then fireproximityprompt(target.Prompt) end
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                        task.wait(HitSpeed)
                    end
                    stopStick() 
                end
            end
        end
    end
end)

-- =====================================================================
-- TAB 6: INFILTRATION (From Source 4)
-- =====================================================================
local MorphTab = Window:CreateTab("Infiltration", 4483362458)

local Dummy = nil
local isSpyActive = false
local Connection = nil
local AnimConnection = nil
local LoadedAnimations = {} 
local AnimationOverrides = {} 

local function FindNPC(name)
    if name == "ProClimber" then
        local things = workspace:FindFirstChild("Things")
        if things then
            local npc = things:FindFirstChild("ProClimber")
            if npc then return npc end
        end
        return workspace:FindFirstChild("ProClimber", true)
    elseif name == "Seller" then
        local npc = workspace:FindFirstChild("Seller", true)
        if not npc then
            npc = workspace:FindFirstChild("SellWorker", true)
        end
        return npc
    end
    return nil
end

local function MapNpcAnimations(MyChar, NpcChar)
    AnimationOverrides = {}
    local myAnimate = MyChar:FindFirstChild("Animate")
    local npcAnimate = NpcChar:FindFirstChild("Animate")
    
    if myAnimate and npcAnimate then
        for _, stateFolder in ipairs(myAnimate:GetChildren()) do
            local npcStateFolder = npcAnimate:FindFirstChild(stateFolder.Name)
            if npcStateFolder then
                for _, myAnim in ipairs(stateFolder:GetChildren()) do
                    if myAnim:IsA("Animation") then
                        local npcAnim = npcStateFolder:FindFirstChild(myAnim.Name)
                        if npcAnim and npcAnim:IsA("Animation") and npcAnim.AnimationId ~= "" then
                            AnimationOverrides[myAnim.AnimationId] = npcAnim.AnimationId
                        end
                    end
                end
            end
        end
    end
end

local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    isSpyActive = true
    MapNpcAnimations(LocalPlayer.Character, TargetNPC)
    
    local originalArchivables = {}
    TargetNPC.Archivable = true
    for _, obj in pairs(TargetNPC:GetDescendants()) do
        originalArchivables[obj] = obj.Archivable
        obj.Archivable = true
    end
    
    Dummy = TargetNPC:Clone()
    
    for obj, val in pairs(originalArchivables) do
        if obj and obj.Parent then obj.Archivable = val end
    end
    
    if not Dummy then return end
    Dummy.Name = "ClonControl"
    local DummyRoot = Dummy:FindFirstChild("HumanoidRootPart") or Dummy:FindFirstChild("LowerTorso") or Dummy:FindFirstChild("Torso")
    local DummyHum = Dummy:FindFirstChildOfClass("Humanoid")
    
    if DummyHum then
        DummyHum.RequiresNeck = false 
        DummyHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if not DummyHum:FindFirstChildOfClass("Animator") then
            local Animator = Instance.new("Animator")
            Animator.Parent = DummyHum
        end
    end
    
    local DummyParts = {}
    local DummyOriginalJoints = {}
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("Motor6D") then DummyOriginalJoints[obj] = {C0 = obj.C0, C1 = obj.C1} end
    end
    
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            if obj.Name ~= "HumanoidRootPart" then obj.Transparency = 0 end
            table.insert(DummyParts, obj) 
            obj.Anchored = false
        elseif obj:IsA("Decal") then
            obj.Transparency = 0
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("BodyMover") then
            obj:Destroy()
        end
    end
    
    if DummyRoot then DummyRoot.Anchored = true end
    Dummy.Parent = workspace
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if not part:FindFirstAncestorWhichIsA("Tool") then
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1 
            elseif part:IsA("Decal") then part.Transparency = 1 end
        end
    end
    
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")
    LoadedAnimations = {}

    Connection = RunService.RenderStepped:Connect(function()
        if not isSpyActive or not MyRoot or not DummyRoot then return end
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not isSpyActive then return end
            for _, part in ipairs(DummyParts) do
                if part and part.Parent then part.CanCollide = false end
            end
            
            pcall(function()
                local playingMyTracks = MyHum:GetPlayingAnimationTracks()
                local activeIds = {}

                for _, track in pairs(playingMyTracks) do
                    if track.Animation and track.Animation.AnimationId then
                        local originalId = track.Animation.AnimationId
                        local targetId = AnimationOverrides[originalId] or originalId
                        activeIds[targetId] = true

                        if not LoadedAnimations[targetId] then
                            local newAnim = Instance.new("Animation")
                            newAnim.AnimationId = targetId
                            local success, loadedAnim = pcall(function() return DummyHum:LoadAnimation(newAnim) end)
                            if success and loadedAnim then LoadedAnimations[targetId] = loadedAnim end
                        end
                        
                        local dummyTrack = LoadedAnimations[targetId]
                        if dummyTrack then
                            if not dummyTrack.IsPlaying then dummyTrack:Play() end
                            pcall(function()
                                dummyTrack:AdjustWeight(track.Weight)
                                dummyTrack:AdjustSpeed(track.Speed)
                                if math.abs(dummyTrack.TimePosition - track.TimePosition) > 0.05 then
                                    dummyTrack.TimePosition = track.TimePosition
                                end
                            end)
                        end
                    end
                end

                for id, dummyTrack in pairs(LoadedAnimations) do
                    if not activeIds[id] and dummyTrack.IsPlaying then dummyTrack:Stop() end
                end

                local MiChar = LocalPlayer.Character
                if not MiChar then return end
                local TieneHerramienta = MiChar:FindFirstChildOfClass("Tool") ~= nil
                
                local function CalcarArticulacion(NombreParte, NombreArticulacion)
                    local MiPart = MiChar:FindFirstChild(NombreParte)
                    local ClonPart = Dummy:FindFirstChild(NombreParte)
                    if MiPart and ClonPart then
                        local MiJoint = MiPart:FindFirstChild(NombreArticulacion)
                        local ClonJoint = ClonPart:FindFirstChild(NombreArticulacion)
                        if MiJoint and ClonJoint then
                            pcall(function()
                                if TieneHerramienta then
                                    if MiJoint:IsA("Motor6D") and ClonJoint:IsA("Motor6D") then
                                        ClonJoint.Transform = MiJoint.Transform
                                        ClonJoint.CurrentAngle = MiJoint.CurrentAngle
                                        ClonJoint.DesiredAngle = MiJoint.DesiredAngle
                                    end
                                    ClonJoint.C0 = MiJoint.C0
                                    ClonJoint.C1 = MiJoint.C1
                                else
                                    if DummyOriginalJoints[ClonJoint] then
                                        ClonJoint.C0 = DummyOriginalJoints[ClonJoint].C0
                                        ClonJoint.C1 = DummyOriginalJoints[ClonJoint].C1
                                    end
                                end
                            end)
                        end
                    end
                end
                
                if MiChar:FindFirstChild("Torso") and Dummy:FindFirstChild("Torso") then
                    CalcarArticulacion("Torso", "Right Shoulder")
                elseif MiChar:FindFirstChild("RightUpperArm") and Dummy:FindFirstChild("RightUpperArm") then
                    CalcarArticulacion("RightUpperArm", "RightShoulder")
                    CalcarArticulacion("RightLowerArm", "RightElbow")
                    CalcarArticulacion("RightHand", "RightWrist")
                end
            end)
        end)
    end
end

local function StopCloning()
    isSpyActive = false
    if Connection then Connection:Disconnect() end
    if AnimConnection then AnimConnection:Disconnect() end
    if Dummy then Dummy:Destroy() end
    LoadedAnimations = {}
    AnimationOverrides = {}
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if not part:FindFirstAncestorWhichIsA("Tool") then
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 0 
                elseif part:IsA("Decal") then part.Transparency = 0 end
            end
        end
    end
end

MorphTab:CreateButton({
   Name = "Unlock | Character Pro Climber 🧗‍♂️",
   Callback = function()
        StopCloning() 
        local Target = FindNPC("ProClimber")
        if Target then
            StartCloning(Target)
            Rayfield:Notify({Title = "Unlock 🎉", Content = "Use Character: Pro Climber", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "Not Local to Pro Climber to Map.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "Unlock | Character Seller 💰",
   Callback = function()
        StopCloning() 
        local Target = FindNPC("Seller")
        if Target then
            StartCloning(Target)
            Rayfield:Notify({Title = "Successful Synchronization", Content = "Use Character: Seller", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "Not Local to Seller/SellWorker to Map.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "Reset Character (Normal)",
   Callback = function()
        StopCloning()
        Rayfield:Notify({Title = "Disabled", Content = "You have returned to your original form.", Duration = 3})
   end,
})

MorphTab:CreateButton({
   Name = "Kill|Clear (Reset all Object)",
   Callback = function()
        StopCloning()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

-- =====================================================================
-- TAB 8: UI MANIPULATION & NPC SHOP BYPASS (ORCHESTRATOR VERSION)
-- =====================================================================
local UITab = Window:CreateTab("UI Manipulation", "box")

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Estado Global de los Filtros
local ActiveFilters = {
    Price = {},
    Stock = {},
    Equip = {},
    SoldOut = {},
    RevealMenus = false
}

-- Configuración Base
local targetNumber = 9999999999
local freeCost = 0
local targetTimer = "99:99"
local targetEquippedText = "Equipped"

-- =====================================================================
-- MOTOR CENTRAL (ORQUESTADOR)
-- =====================================================================
task.spawn(function()
    while true do
        task.wait(0.5) -- Velocidad constante optimizada
        
        -- 1. Revelado de Menús (Si está activo)
        if ActiveFilters.RevealMenus then
            for _, v in pairs(PlayerGui:GetDescendants()) do
                if v:IsA("GuiObject") and not string.find(v.Name:lower(), "template") then
                    if not v.Visible then v.Visible = true end
                    if v:IsA("CanvasGroup") then v.GroupTransparency = 0 end
                    if v:IsA("ScrollingFrame") then v.ScrollingEnabled = true end
                end
            end
        end

        -- 2. Bypass de elementos (Busca solo lo que está activo)
        for _, v in pairs(PlayerGui:GetDescendants()) do
            pcall(function()
                local name = v.Name:lower()
                local txt = (v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox")) and v.Text:lower() or ""

                -- Chequeo de Price
                for kw, enabled in pairs(ActiveFilters.Price) do
                    if enabled and (string.find(txt, kw) or string.find(name, kw)) then
                        v.Text = "0"
                        v.TextColor3 = Color3.fromRGB(85, 255, 127)
                        if v:IsA("IntValue") or v:IsA("NumberValue") then v.Value = freeCost end
                    end
                end

                -- Chequeo de Equip
                for kw, enabled in pairs(ActiveFilters.Equip) do
                    if enabled and (string.find(txt, kw) or string.find(name, kw)) then
                        v.Text = targetEquippedText
                        v.TextColor3 = Color3.fromRGB(255, 215, 0)
                        if v:IsA("BoolValue") then v.Value = true end
                    end
                end

                -- Chequeo de Stock
                for kw, enabled in pairs(ActiveFilters.Stock) do
                    if enabled and string.find(name, kw) then
                        if v:IsA("IntValue") or v:IsA("NumberValue") then v.Value = targetNumber end
                    end
                end

                -- Chequeo de SoldOut
                for kw, enabled in pairs(ActiveFilters.SoldOut) do
                    if enabled and (string.find(txt, kw) or string.find(name, kw)) then
                        v.Text = "Available"
                        v.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end
            end)
        end
    end
end)

-- =====================================================================
-- CREACIÓN DE INTERFAZ
-- =====================================================================
UITab:CreateSection("--- SISTEMA MAESTRO ---")
UITab:CreateToggle({
    Name = "FORCE REVEAL ALL UI PANELS",
    CurrentValue = false,
    Callback = function(Value) ActiveFilters.RevealMenus = Value end
})

local function CreateToggle(sectionName, category, kw)
    UITab:CreateToggle({
        Name = "Toggle [" .. category .. "]: " .. kw,
        CurrentValue = false,
        Callback = function(Value)
            ActiveFilters[category][kw] = Value
        end
    })
end

UITab:CreateSection("--- PRECIOS (0 Cost) ---")
for _, kw in ipairs({"price", "premium", "cost", "value", "gem", "diamond", "robux", "currency", "tokens", "required", "pay"}) do CreateToggle("Precios", "Price", kw) end

UITab:CreateSection("--- EQUIPAMIENTO ---")
for _, kw in ipairs({"equip", "own", "unlock", "buy", "purchas", "claim", "tier", "has", "inventory"}) do CreateToggle("Equip", "Equip", kw) end

UITab:CreateSection("--- STATS (Max) ---")
for _, kw in ipairs({"stock", "backpack", "capacity", "depth", "power", "multiplier", "speed", "luck", "yield", "durability", "storage", "weight", "level"}) do CreateToggle("Stock", "Stock", kw) end

UITab:CreateSection("--- BLOQUEOS (Sold Out) ---")
for _, kw in ipairs({"sold out", "lucky", "vip", "time", "out of stock", "max", "all", "locked", "cooldown", "unavailable", "depleted", "requires", "premium_only"}) do CreateToggle("SoldOut", "SoldOut", kw) end

-- =====================================================================
-- TAB 8: PHYSICAL ZONES (From Source 6)
-- =====================================================================
local ZoneTab = Window:CreateTab("Physical Zones 📍", 4483362458)

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Status: Ready to scan the world.")

local isZoneESPActive = false
local CurrentZoneESP = {Beam = nil, AtchPlayer = nil, AtchTarget = nil, Highlight = nil, Billboard = nil, DistanceUpdater = nil}

local function ScanForZones()
    FoundZones = {}
    ZoneNames = {}
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "zone") or string.find(nameLower, "cave") then
            local targetPart = nil
            if obj:IsA("BasePart") then targetPart = obj
            elseif obj:IsA("Model") or obj:IsA("Folder") then
                targetPart = obj:FindFirstChildWhichIsA("BasePart", true)
            end
            
            if targetPart then
                if not FoundZones[obj.Name] then
                    FoundZones[obj.Name] = targetPart
                    table.insert(ZoneNames, obj.Name)
                    count = count + 1
                end
            end
        end
    end
    table.sort(ZoneNames)
    return count
end

local function ClearZoneESP()
    if CurrentZoneESP.DistanceUpdater then
        CurrentZoneESP.DistanceUpdater:Disconnect()
        CurrentZoneESP.DistanceUpdater = nil
    end
    for key, instance in pairs(CurrentZoneESP) do
        if typeof(instance) == "Instance" and instance.Parent then instance:Destroy() end
        CurrentZoneESP[key] = nil
    end
end

local function ActivateZoneESP(targetPart, zoneName)
    ClearZoneESP() 
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = targetPart; highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255); highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.Parent = targetPart
    CurrentZoneESP.Highlight = highlight

    local atchPlayer = Instance.new("Attachment", hrp)
    local atchTarget = Instance.new("Attachment", targetPart)
    CurrentZoneESP.AtchPlayer = atchPlayer; CurrentZoneESP.AtchTarget = atchTarget

    local beam = Instance.new("Beam", hrp)
    beam.Attachment0 = atchPlayer; beam.Attachment1 = atchTarget
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
    beam.FaceCamera = true; beam.Width0 = 0.5; beam.Width1 = 0.5
    beam.Transparency = NumberSequence.new(0.2)
    CurrentZoneESP.Beam = beam

    local billboard = Instance.new("BillboardGui", targetPart)
    billboard.AlwaysOnTop = true; billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.Adornee = targetPart
    
    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1
    textLabel.Text = "📍 " .. zoneName; textLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    textLabel.TextStrokeTransparency = 0.2; textLabel.TextScaled = true
    CurrentZoneESP.Billboard = billboard

    CurrentZoneESP.DistanceUpdater = RunService.RenderStepped:Connect(function()
        if hrp and hrp.Parent and targetPart and targetPart.Parent then
            local distance = math.floor((hrp.Position - targetPart.Position).Magnitude)
            textLabel.Text = "📍 " .. zoneName .. " [" .. tostring(distance) .. "m]"
        else
            ClearZoneESP()
        end
    end)
end

local function SafeTeleport(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart then 
        Rayfield:Notify({Title = "Error", Content = "Could not find character or destination.", Duration = 3}) return 
    end

    StatusLabel:Set("Status: Calculating safe landing...")
    local safeY = targetPart.Position.Y + (targetPart.Size.Y / 2) + 3.5
    local safeDest = CFrame.new(targetPart.Position.X, safeY, targetPart.Position.Z)

    hrp.Anchored = true; hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
    hrp.CFrame = safeDest
    task.wait(0.5) 
    hrp.Anchored = false
    
    StatusLabel:Set("Status: Landing completed successfully.")
    Rayfield:Notify({Title = "Warp Successful", Content = "You have arrived at " .. SelectedZoneName, Duration = 2})
end

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
        if isZoneESPActive and SelectedZoneName ~= "Scan first..." then
            local targetBlock = FoundZones[SelectedZoneName]
            if targetBlock then ActivateZoneESP(targetBlock, SelectedZoneName) end
        end
    end,
})

ZoneTab:CreateToggle({
    Name = "👁️ Enable ESP Guide",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        isZoneESPActive = Value
        if isZoneESPActive then
            if SelectedZoneName and SelectedZoneName ~= "Scan first..." then
                local targetBlock = FoundZones[SelectedZoneName]
                if targetBlock then
                    ActivateZoneESP(targetBlock, SelectedZoneName)
                    Rayfield:Notify({Title = "ESP Enabled", Content = "Visual tracker towards " .. SelectedZoneName, Duration = 2})
                end
            else
                Rayfield:Notify({Title = "Notice", Content = "Select a zone first.", Duration = 3})
            end
        else
            ClearZoneESP()
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
        if targetBlock then SafeTeleport(targetBlock)
        else Rayfield:Notify({Title = "Error", Content = "The zone block no longer exists.", Duration = 3}) end
    end
})

ZoneTab:CreateButton({
    Name = "📋 Copy Selected Zone Path",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] and setclipboard then
            setclipboard(FoundZones[SelectedZoneName]:GetFullName())
            Rayfield:Notify({Title = "Path Copied", Content = "Block path copied to clipboard.", Duration = 2})
        end
    end
})
