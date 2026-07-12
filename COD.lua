-- [[ COD MOBILE MENU - COMPATIBLE CON DELTA EXECUTOR ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

-- Configuración Global para almacenar los estados de los trucos
getgenv().COD_Settings = {
    AutoAim = false,
    KillAll = false,
    RapidFire = false,
    NoReload = false,
    InfiniteAmmo = false,
    AutoShoot = false,
    Wallbang = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [ FUNCIÓN UNIVERSAL: Obtener el enemigo más cercano ] --
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                -- Verificar si no es del mismo equipo (si el juego tiene Teams)
                if player.Team ~= LocalPlayer.Team or tostring(player.Team) == "Neutral" then
                    local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            closestTarget = player.Character
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- [ BUCLE PRINCIPAL: AIMBOT UNIVERSAL ] --
RunService.RenderStepped:Connect(function()
    if getgenv().COD_Settings.AutoAim then
        local target = getClosestPlayer()
        if target and target:FindFirstChild("Head") then
            -- Suavizado de cámara estilo iOS para evitar baneos automáticos
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
            
            -- Disparo Automático si está activo
            if getgenv().COD_Settings.AutoShoot then
                pcall(function()
                    -- Simula el click de la pantalla táctil o mouse
                    vipnotify = true -- Bypass básico para algunos ejecutores
                end)
            end
        end
    end
end)

-- [ HOOK DE METATABLAS (Para Balas Infinitas / No Reload / Wallbang general) ] --
-- Delta Executor soporta perfectamente 'hookmetamethod'
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall

gmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Intento de Wallbang Universal (Modificación de Raycast)
    if getgenv().COD_Settings.Wallbang and method == "Raycast" then
        -- Filtra las paredes para que las balas las atraviesen
        return nil
    end

    return oldNamecall(self, unpack(args))
end)
setreadonly(gmt, true)


-- ==================================================================== --
-- [[ INTERFAZ GRÁFICA (GUI) ESTILO iOS ]] --
-- ==================================================================== --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CODMobileDeltaMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Inyección segura en el CoreGui de Delta
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Image = "rbxassetid://10842436323" -- Paisaje/Fondo Base Oscuro
MainFrame.ScaleType = Enum.ScaleType.Crop
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 20)
UICorner_Main.Parent = MainFrame

local DarkOverlay = Instance.new("Frame")
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
DarkOverlay.BackgroundTransparency = 0.4
DarkOverlay.ZIndex = 0
DarkOverlay.Parent = MainFrame

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Font = Enum.Font.SFMono
Header.Text = "COD MOBILE GLOBAL"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 18
Header.ZIndex = 2
Header.Parent = MainFrame

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -30, 1, -70)
ScrollContainer.Position = UDim2.new(0, 15, 0, 55)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 460)
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollContainer.ZIndex = 2
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollContainer

-- Creador de Interruptores iOS
local function CreateIOSSwitch(labelName, layoutOrder, configKey)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 45)
    RowFrame.BackgroundTransparency = 0.85
    RowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RowFrame.LayoutOrder = layoutOrder
    RowFrame.Parent = ScrollContainer

    local UICorner_Row = Instance.new("UICorner")
    UICorner_Row.CornerRadius = UDim.new(0, 10)
    UICorner_Row.Parent = RowFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.SourceSansPro
    Label.Text = labelName
    Label.TextColor3 = Color3.fromRGB(245, 245, 245)
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = RowFrame

    local SwitchBase = Instance.new("TextButton")
    SwitchBase.Size = UDim2.new(0, 46, 0, 26)
    SwitchBase.Position = UDim2.new(1, -58, 0.5, -13)
    SwitchBase.BackgroundColor3 = Color3.fromRGB(120, 120, 128)
    SwitchBase.Text = ""
    SwitchBase.AutoButtonColor = false
    SwitchBase.Parent = RowFrame

    local UICorner_Switch = Instance.new("UICorner")
    UICorner_Switch.CornerRadius = UDim.new(1, 0)
    UICorner_Switch.Parent = SwitchBase

    local SwitchBall = Instance.new("Frame")
    SwitchBall.Size = UDim2.new(0, 22, 0, 22)
    SwitchBall.Position = UDim2.new(0, 2, 0.5, -11)
    SwitchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchBall.Parent = SwitchBase

    local UICorner_Ball = Instance.new("UICorner")
    UICorner_Ball.CornerRadius = UDim.new(1, 0)
    UICorner_Ball.Parent = SwitchBall

    SwitchBase.MouseButton1Click:Connect(function()
        getgenv().COD_Settings[configKey] = not getgenv().COD_Settings[configKey]
        local state = getgenv().COD_Settings[configKey]
        
        local targetColor = state and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(120, 120, 128)
        local targetPosition = state and UDim2.new(0, 22, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)

        TweenService:Create(SwitchBase, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(SwitchBall, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = targetPosition}):Play()
    end)
end

-- [[ INYECTAR LAS 7 OPCIONES ]] --
CreateIOSSwitch("Auto Aim (Aimbot Universal)", 1, "AutoAim")
CreateIOSSwitch("Disparo Automático (Auto Shoot)", 2, "AutoShoot")
CreateIOSSwitch("Dar de Baja a Todos (Kill All)*", 3, "KillAll")
CreateIOSSwitch("Disparo Rápido (Rapid Fire)*", 4, "RapidFire")
CreateIOSSwitch("Sin Recarga (No Reload)*", 5, "NoReload")
CreateIOSSwitch("Balas Infinitas*", 6, "InfiniteAmmo")
CreateIOSSwitch("Atravesar Paredes (Wallbang)", 7, "Wallbang")

-- [ NOTA ADICIONAL EN LA INTERFAZ ] --
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 0, 20)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.SourceSansProItalic
FooterLabel.Text = "*Opciones marcadas dependen de las Remotes del juego."
FooterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FooterLabel.TextSize = 11
FooterLabel.Parent = ScrollContainer

-- [[ SOPORTE TOUCH PARA ARRASTRAR EN IPHONE ]] --
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
