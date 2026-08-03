-- Load the Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "Delta Executor",
   LoadingTitle = "Injecting script...",
   LoadingSubtitle = "Surgical Reload Method",
   Theme = "Default", 
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = false
   }
})

-- Create a single main tab
local MainTab = Window:CreateTab("Loader", 4483362458) 

-- Create Toggle with Auto-Reload on Switch
local Toggle = MainTab:CreateToggle({
   Name = "Gamepass Gifter (Toggle to Restart)",
   CurrentValue = false,
   Flag = "LoadScriptToggle", 
   Callback = function(Value)
      if Value then
         -- [ STATE: ON ]
         -- Re-executes the loadstring every time you turn the switch back ON
         loadstring(game:HttpGet('https://raw.githubusercontent.com/Makuscripts/MakuHub/refs/heads/main/GamepassGifter'))()
         
         Rayfield:Notify({
            Title = "Script Loaded",
            Content = "Gamepass Gifter re-executed successfully.",
            Duration = 3,
            Image = 4483362458
         })
      else
         -- [ STATE: OFF ]
         -- Attempts cleanup if a destructor function exists in global environment
         if _G.MyRunningScript and type(_G.MyRunningScript.DestroyAll) == "function" then
            _G.MyRunningScript:DestroyAll()
            _G.MyRunningScript = nil
         end

         Rayfield:Notify({
            Title = "Deactivated",
            Content = "Toggle switched off. Turn ON again to restart.",
            Duration = 3,
            Image = 4483362458
         })
      end
   end,
})
