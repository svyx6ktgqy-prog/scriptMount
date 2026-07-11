-- =====================================================================
-- 💎 MINE DIAMOND MASTER - iOS STYLE MOD MENU
-- UI: Rayfield (Aspecto moderno, switches, adaptado a pantalla)
-- =====================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- =====================================================================
-- 1. CREAR EL BOTÓN FLOTANTE (ARRASTRABLE)
-- =====================================================================
local function createFloatingButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DiamondFloatUI"
    ScreenGui.ResetOnSpawn = false
    -- Ocultar de los anticheats si el ejecutor lo soporta
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "ToggleBtn"
    FloatBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatBtn.Position = UDim2.new(0, 15, 0.5, -25) -- Centro izquierda por defecto
    FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FloatBtn.Text = "💎"
    FloatBtn.TextSize = 25
    FloatBtn.Parent = ScreenGui

    -- Bordes redondos estilo iOS
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = FloatBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = FloatBtn

    -- Lógica para arrastrar el botón sin que se active accidentalmente
    local dragging, dragStart, startPos, dragDist
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
            dragDist = 0
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                dragDist = delta.Magnitude
                FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    FloatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            -- Si no lo moviste mucho, se cuenta como un "click" o "toque"
            if dragDist < 10 then
                local rayfieldGui = CoreGui:FindFirstChild("Rayfield") or (gethui and gethui():FindFirstChild("Rayfield"))
                if rayfieldGui then
                    rayfieldGui.Enabled = not rayfieldGui.Enabled -- Oculta/Muestra el menú
                end
            end
        end
    end)
end

createFloatingButton()

-- =====================================================================
-- 2. CARGAR INTERFAZ PRINCIPAL (RAYFIELD - iOS STYLE)
-- =====================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "💎 Mine Diamond Master",
    LoadingTitle = "Cargando Menu...",
    LoadingSubtitle = "Aspecto iOS - Optimizado",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local function getHumanoid()
    if LocalPlayer.Character then return LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
    return nil
end

-- =====================================================================
-- PESTAÑA 1: VISUALES
-- =====================================================================
local VisualsTab = Window:CreateTab("Visuales", 4483362458)
local espEnabled = false

VisualsTab:CreateToggle({
    Name = "Activar Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        espEnabled = Value
    end,
})

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("UniversalESP")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UniversalESP"
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
                highlight.Enabled = true
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
end)

-- =====================================================================
-- PESTAÑA 2: JUGADOR (PLAYER)
-- =====================================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
    Name = "Super Salto",
    CurrentValue = false,
    Flag = "SuperJump",
    Callback = function(Value)
        local humanoid = getHumanoid()
        if humanoid then
            if Value then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = 150
                if humanoid.JumpHeight then humanoid.JumpHeight = 50 end 
            else
                humanoid.JumpPower = 50
                if humanoid.JumpHeight then humanoid.JumpHeight = 7.2 end
            end
        end
    end,
})

local infJumpEnabled = false
PlayerTab:CreateToggle({
    Name = "Salto Infinito Real",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        infJumpEnabled = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local humanoid = getHumanoid()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

PlayerTab:CreateSlider({
    Name = "Aumentar Mochila (Local)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "Backpack",
    Callback = function(Value)
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
        if stats then
            local capacity = stats:FindFirstChild("MaxCapacity") or stats:FindFirstChild("BagSize") or stats:FindFirstChild("Mochila")
            if capacity and capacity:IsA("ValueBase") then capacity.Value = Value end
        end
    end,
})

-- =====================================================================
-- PESTAÑA 3: MISCELÁNEO (MISC)
-- =====================================================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

local godModeEnabled = false
MiscTab:CreateToggle({
    Name = "God Mode (Anti-Daño Local)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        godModeEnabled = Value
    end,
})

RunService.Stepped:Connect(function()
    if godModeEnabled then
        local humanoid = getHumanoid()
        if humanoid then humanoid.Health = humanoid.MaxHealth end
    end
end)

MiscTab:CreateButton({
    Name = "Auto Sell (Fuerza Bruta)",
    Callback = function()
        local found = false
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "sell") or string.find(remote.Name:lower(), "deposit")) then
                pcall(function()
                    remote:FireServer()
                    found = true
                end)
            end
        end
        if found then
            Rayfield:Notify({Title = "Notificación", Content = "Intentando Auto Sell...", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "No se encontraron Remotes de venta.", Duration = 3})
        end
    end,
})

Rayfield:Notify({
    Title = "💎 Cargado Exitosamente",
    Content = "Toca el botón flotante con el diamante para abrir y cerrar este menú.",
    Duration = 6,
    Image = 4483362458,
})