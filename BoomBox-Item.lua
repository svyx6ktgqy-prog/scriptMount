-- Safely load the Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Loading Interface...",
   LoadingSubtitle = "Anti-Lag & Anti-Ban System: ENABLED",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Create an inventory tab
local Tab = Window:CreateTab("Inventory", 4483362458) 

-- Global variables for the tool
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320" -- The Radio ID you provided
local clonedTool = nil

-- Create the Toggle (Equip / Unequip)
Tab:CreateToggle({
   Name = "Equip Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           -- [ON] - Safely fetch and equip the radio (Anti-Lag/Crash)
           local success, errorMessage = pcall(function()
               -- GetObjects fetches the catalog ID securely via the executor
               local objects = game:GetObjects(assetId)
               
               if objects and #objects > 0 then
                   clonedTool = objects[1]
                   clonedTool.Name = toolName
                   
                   -- [NEW] 1. Save to StarterGear: Persists upon death and binds to core item selectors
                   if player:FindFirstChild("StarterGear") then
                       local gearClone = clonedTool:Clone()
                       gearClone.Parent = player.StarterGear
                   end

                   -- [NEW] 2. Parent to Backpack first, then force-equip it
                   clonedTool.Parent = player.Backpack 
                   
                   -- This forces the tool into the character's hands automatically,
                   -- preventing issues in games where the Backpack UI is disabled.
                   if humanoid then
                       humanoid:EquipTool(clonedTool)
                   end
                   
                   Rayfield:Notify({
                       Title = "Radio Equipped",
                       Content = "BoomBoxV3 is now in your hands and inventory.",
                       Duration = 2,
                   })
               end
           end)

           -- Error handling if the executor lacks GetObjects support
           if not success then
               Rayfield:Notify({
                   Title = "Executor Error",
                   Content = "Your executor doesn't support this asset load. Error hidden (Anti-BAN).",
                   Duration = 3,
               })
           end
           
       else
           -- [OFF] - Completely wipe the radio from all player directories
           pcall(function()
               -- 1. Search and destroy from StarterGear (Item Selector persistence)
               if player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName) then
                   player.StarterGear[toolName]:Destroy()
               end
               
               -- 2. Search and destroy from Backpack (Standard Inventory)
               if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName) then
                   player.Backpack[toolName]:Destroy()
               end
               
               -- 3. Search and destroy from Character (If currently held in hands)
               if character and character:FindFirstChild(toolName) then
                   character[toolName]:Destroy()
               end
               
               -- 4. Clear the memory reference to avoid memory leaks
               if clonedTool then
                   clonedTool:Destroy()
                   clonedTool = nil
               end
               
               Rayfield:Notify({
                   Title = "Radio Removed",
                   Content = "BoomBoxV3 has been completely cleared from your equipment.",
                   Duration = 2,
               })
           end)
       end
   end,
})
