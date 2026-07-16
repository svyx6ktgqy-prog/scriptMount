-- ==================================================
-- [ ALB8RAAQ ] - NATIVE UI WARPER (NO RAYFIELD)
-- ==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Crear Interfaz Nativa
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ALB8RAAQ_Menu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ALB8RAAQ WARPER"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)

-- Lógica de Zonas
local FoundZones = {}
local SelectedTarget = nil

local function RefreshList()
    for _, child in pairs(Scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    FoundZones = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "zone") or string.find(string.lower(obj.Name), "cave") then
            local targetPart = obj:IsA("BasePart") and obj or (obj:FindFirstChildWhichIsA("BasePart", true))
            if targetPart and not FoundZones[obj.Name] then
                FoundZones[obj.Name] = targetPart
                local btn = Instance.new("TextButton", Scroll)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Text = obj.Name
                btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.MouseButton1Click:Connect(function() SelectedTarget = targetPart; Title.Text = "Sel: " .. obj.Name end)
            end
        end
    end
end

-- Botones de Acción
local ScanBtn = Instance.new("TextButton", Frame)
ScanBtn.Size = UDim2.new(1, 0, 0, 30)
ScanBtn.Position = UDim2.new(0, 0, 1, 0)
ScanBtn.Text = "ESCANEAR"
ScanBtn.MouseButton1Click:Connect(RefreshList)

local WarpBtn = Instance.new("TextButton", Frame)
WarpBtn.Size = UDim2.new(1, 0, 0, 30)
WarpBtn.Position = UDim2.new(0, 0, 1, 30)
WarpBtn.Text = "VIAJAR (PRECISO)"
WarpBtn.MouseButton1Click:Connect(function()
    if not SelectedTarget then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(SelectedTarget.Position + Vector3.new(0, 5, 0))
        task.wait(0.5)
        hrp.Anchored = false
    end
end)
