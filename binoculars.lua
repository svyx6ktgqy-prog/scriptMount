-- Wait for the game to fully load
if not game:IsLoaded() then game.Loaded:Wait() end

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the Main Window
local Window = Rayfield:CreateWindow({
   Name = "Military Equipment Menu",
   LoadingTitle = "Loading System...",
   LoadingSubtitle = "Delta Executor",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Create a Tab
local Tab = Window:CreateTab("Armory", 4483362458) -- 4483362458 is a shield icon ID

-- Create the Button to grant the item
Tab:CreateButton({
   Name = "Equip Military Binoculars",
   Callback = function()
       local Players = game:GetService("Players")
       local Player = Players.LocalPlayer
       local Camera = workspace.CurrentCamera

       -- Prevent giving multiple binoculars
       if Player.Backpack:FindFirstChild("Military Binoculars") or (Player.Character and Player.Character:FindFirstChild("Military Binoculars")) then
           Rayfield:Notify({
               Title = "Already Equipped",
               Content = "You already have the binoculars in your inventory.",
               Duration = 3,
           })
           return
       end

       -- Create the Tool
       local tool = Instance.new("Tool")
       tool.Name = "Military Binoculars"
       tool.RequiresHandle = true
       tool.CanBeDropped = false

       -- Create the Handle
       local handle = Instance.new("Part")
       handle.Name = "Handle"
       handle.Size = Vector3.new(1, 1, 1)
       handle.Transparency = 0
       handle.CanCollide = false
       handle.Massless = true
       handle.Parent = tool

       -- Extract and apply the Mesh ID you provided
       local mesh = Instance.new("SpecialMesh")
       mesh.MeshType = Enum.MeshType.FileMesh
       mesh.MeshId = "rbxassetid://81667437077852"
       mesh.Scale = Vector3.new(1, 1, 1) -- You can change this if the model is too big/small
       mesh.Parent = handle

       -- Create the UI Overlay (Camera Cross Texture)
       local binocularGui = Instance.new("ScreenGui")
       binocularGui.Name = "BinocularsOverlay"
       binocularGui.IgnoreGuiInset = true -- Fills the entire screen, covering the Roblox topbar
       binocularGui.ResetOnSpawn = false

       local overlayImage = Instance.new("ImageLabel")
       overlayImage.Size = UDim2.new(1, 0, 1, 0)
       overlayImage.Position = UDim2.new(0, 0, 0, 0)
       overlayImage.BackgroundTransparency = 1
       overlayImage.Image = "rbxassetid://135303495630668"
       overlayImage.ScaleType = Enum.ScaleType.Stretch
       overlayImage.Parent = binocularGui

       -- Zoom Configuration
       local defaultFOV = 70
       local zoomFOV = 35 -- 2x Zoom (Half of normal Field of View)

       -- Events: When player equips the binoculars
       tool.Equipped:Connect(function()
           -- Activate Zoom
           Camera.FieldOfView = zoomFOV
           -- Show UI Texture
           binocularGui.Parent = Player:WaitForChild("PlayerGui")
           
           -- Note: The default Roblox tool animation (raising the arm) plays automatically.
           -- If you have a specific ID for putting it exactly to the eyes, add it here:
           -- local anim = Instance.new("Animation")
           -- anim.AnimationId = "rbxassetid://YOUR_ANIMATION_ID"
           -- local track = Player.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(anim)
           -- track:Play()
       end)

       -- Events: When player unequips the binoculars
       tool.Unequipped:Connect(function()
           -- Reset Zoom
           Camera.FieldOfView = defaultFOV
           -- Hide UI Texture
           binocularGui.Parent = nil
       end)

       -- Give the tool to the player
       tool.Parent = Player.Backpack
       
       Rayfield:Notify({
           Title = "Item Granted",
           Content = "Military Binoculars added to your inventory.",
           Duration = 3,
       })
   end,
})
