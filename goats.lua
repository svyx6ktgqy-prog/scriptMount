-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ | Advanced Shop Exploiter",
   LoadingTitle = "Initializing Protocols...",
   LoadingSubtitle = "Delta iOS V2",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("UI Manipulation", "box")

-- Control Variables
local uiLoopActive = false
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local targetValue = 2000000000 -- Overriding the 0 to 2 Billion

-- Global keywords intercepted in English
local keywordsSoldOut = {"sold out", "out of stock", "max", "full", "bought", "unavailable", "depleted"}
local keywordsPrice = {"price", "cost", "value", "fee"}
local keywordsStock = {"stock", "amount", "left", "remaining", "quantity", "capacity"}

-- Brute Force UI Function
local function ReinforceUI()
    local modifiedCount = 0
    
    for _, v in pairs(PlayerGui:GetDescendants()) do
        
        -- 1. Force Texts (Prices and Sold Out to 2 Billion)
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            local txt = string.lower(v.Text)
            local isSoldOut = false
            
            for _, word in ipairs(keywordsSoldOut) do
                if string.find(txt, word) then isSoldOut = true break end
            end
            
            if isSoldOut or string.find(txt, "%$") or tonumber(txt) then
                if v.Text ~= tostring(targetValue) then
                    v.Text = tostring(targetValue)
                    v.TextColor3 = Color3.fromRGB(0, 255, 0) -- Bright green for visual confirmation
                    modifiedCount = modifiedCount + 1
                end
            end
        end
        
        -- 2. Rehabilitate Button Interaction
        if v:IsA("GuiButton") then
            if not v.Active or not v.Interactable or not v.Visible then
                v.Active = true
                v.Interactable = true
                v.Visible = true
                v.AutoButtonColor = true
                modifiedCount = modifiedCount + 1
            end
        end

        -- 3. Remove "Sold Out" image filters (Darkened/Transparent Images)
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            if v.ImageColor3.R < 0.6 and v.ImageColor3.G < 0.6 and v.ImageColor3.B < 0.6 then
                v.ImageColor3 = Color3.fromRGB(255, 255, 255)
                v.ImageTransparency = 0
            end
        end

        -- 4. Internal Value Manipulation (Bypassing local checks)
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local valName = string.lower(v.Name)
            
            for _, word in ipairs(keywordsPrice) do
                if string.find(valName, word) and v.Value ~= targetValue then
                    v.Value = targetValue
                end
            end
            
            for _, word in ipairs(keywordsStock) do
                if string.find(valName, word) and v.Value ~= targetValue then
                    v.Value = targetValue
                end
            end
        end
        
        -- 5. Attribute Interception
        local attributes = v:GetAttributes()
        for attrName, attrValue in pairs(attributes) do
            local lName = string.lower(attrName)
            if string.find(lName, "price") or string.find(lName, "cost") or string.find(lName, "stock") then
                v:SetAttribute(attrName, targetValue)
            end
        end
    end
    
    return modifiedCount
end

-- Streamlined Rayfield Interface (Removed unnecessary manual buttons)
Tab:CreateToggle({
   Name = "Loop: Force 2 Billion & Availability",
   CurrentValue = false,
   Flag = "UI_Loop", 
   Callback = function(Value)
       uiLoopActive = Value
       
       if uiLoopActive then
           Rayfield:Notify({Title = "Loop Enabled", Content = "Freezing values to 2 Billion...", Duration = 3})
           task.spawn(function()
               while uiLoopActive do
                   ReinforceUI()
                   task.wait(0.5)
               end
           end)
       else
           Rayfield:Notify({Title = "Loop Disabled", Content = "UI is no longer frozen.", Duration = 3})
       end
   end,
})

-- NPC Tab
local NpcTab = Window:CreateTab("NPC & Network", "cpu")

NpcTab:CreateButton({
   Name = "Open Bomber Barry",
   Callback = function()
       local player = game.Players.LocalPlayer
       local promptPath = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("BomberBarry") and workspace.Things.BomberBarry:FindFirstChild("Torso") and workspace.Things.BomberBarry.Torso:FindFirstChild("BombPrompt")

       if promptPath then
           if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.CFrame = workspace.Things.BomberBarry.Torso.CFrame * CFrame.new(0, 0, 3)
               task.wait(0.2)
           end
           fireproximityprompt(promptPath)
       else
           Rayfield:Notify({Title = "Error", Content = "Bomber Barry not found.", Duration = 3})
       end
   end,
})

NpcTab:CreateButton({
   Name = "Force BombShopQuery",
   Callback = function()
       local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("BombShopQuery")

       if remote and remote:IsA("RemoteFunction") then
           task.spawn(function()
               local success, result = pcall(function() return remote:InvokeServer() end)
               if success then
                   print("[ALB8RAAQ] Server response:", result)
               end
           end)
       end
   end,
})
