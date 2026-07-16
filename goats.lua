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

-- Target values for bypass
local targetNumber = 2000000000
local targetText = "2,000,000,000"
local targetTimer = "99:99"

-- Global keywords intercepted
local keywordsSoldOut = {"sold out", "out of stock", "max", "full", "bought", "unavailable", "depleted"}
local keywordsPrice = {"price", "cost", "value", "fee"}
local keywordsStock = {"stock", "amount", "left", "remaining", "quantity", "capacity"}

-- Brute Force UI Function
local function ReinforceUI()
    for _, v in pairs(PlayerGui:GetDescendants()) do
        
        -- 1. Force Texts (Timers, Prices, and Sold Out)
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            local txt = string.lower(v.Text)
            
            -- Timer Bypass: Look for 00:00, 0:00, or 00:00:00
            if string.match(txt, "^00?:00$") or string.match(txt, "^00?:00:00$") then
                if v.Text ~= targetTimer then
                    v.Text = targetTimer
                    v.TextColor3 = Color3.fromRGB(0, 255, 0) -- Keeps text bright green
                end
            else
                -- Sold Out & Price Bypass
                local isSoldOut = false
                
                for _, word in ipairs(keywordsSoldOut) do
                    if string.find(txt, word) then isSoldOut = true break end
                end
                
                if isSoldOut or string.find(txt, "%$") or tonumber(txt) then
                    if v.Text ~= targetText then
                        v.Text = targetText
                        v.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
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
            end
        end

        -- 3. Remove "Sold Out" image filters
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            if v.ImageColor3.R < 0.6 and v.ImageColor3.G < 0.6 and v.ImageColor3.B < 0.6 then
                v.ImageColor3 = Color3.fromRGB(255, 255, 255)
                v.ImageTransparency = 0 -- Keep at 0 so the image doesn't turn invisible
            end
        end

        -- 4. Internal Value Manipulation
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local valName = string.lower(v.Name)
            
            for _, word in ipairs(keywordsPrice) do
                if string.find(valName, word) and v.Value ~= targetNumber then
                    v.Value = targetNumber
                end
            end
            
            for _, word in ipairs(keywordsStock) do
                if string.find(valName, word) and v.Value ~= targetNumber then
                    v.Value = targetNumber
                end
            end
        end
        
        -- 5. Attribute Interception
        local attributes = v:GetAttributes()
        for attrName, _ in pairs(attributes) do
            local lName = string.lower(attrName)
            if string.find(lName, "price") or string.find(lName, "cost") or string.find(lName, "stock") then
                v:SetAttribute(attrName, targetNumber)
            end
        end
    end
end

-- Streamlined Rayfield Interface
Tab:CreateToggle({
   Name = "Loop: Force 2 Billion & 99:99 Timers",
   CurrentValue = false,
   Flag = "UI_Loop", 
   Callback = function(Value)
       uiLoopActive = Value
       
       if uiLoopActive then
           Rayfield:Notify({Title = "Loop Enabled", Content = "Freezing values to 2 Billion and resetting timers...", Duration = 3})
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
