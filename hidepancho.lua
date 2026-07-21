local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==========================================
-- SISTEMA DE SEGURIDAD Y LIMPIEZA DE GUI
-- ==========================================
pcall(function()
    if gethui then
        for _, v in ipairs(gethui():GetChildren()) do if v.Name == "HoodArgMobile" then v:Destroy() end end
    end
    for _, v in ipairs(CoreGui:GetChildren()) do if v.Name == "HoodArgMobile" then v:Destroy() end end
    for _, v in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do if v.Name == "HoodArgMobile" then v:Destroy() end end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodArgMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 99999 

local inyectado = false
pcall(function() if gethui then ScreenGui.Parent = gethui(); inyectado = true end end)
if not inyectado then pcall(function() ScreenGui.Parent = CoreGui; inyectado = true end) end
if not inyectado then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ==========================================
-- BOTÓN FLOTANTE
-- ==========================================
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.3, 0) 
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "👽"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 25
OpenBtn.ZIndex = 100
OpenBtn.Parent = ScreenGui

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenShadow = Instance.new("UIStroke")
OpenShadow.Thickness = 2
OpenShadow.Color = Color3.fromRGB(110, 211, 55)
OpenShadow.Parent = OpenBtn

-- ==========================================
-- VENTANA PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480) 
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "HOOD ARGENTINO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.ZIndex = 11
Title.Parent = MainFrame

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function CreateToggle(name, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -30, 0, 45)
    ToggleFrame.Position = UDim2.new(0, 15, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.ZIndex = 11
    ToggleFrame.Parent = MainFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 12
    Label.Parent = ToggleFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 46, 0, 24)
    Btn.Position = UDim2.new(1, -60, 0.5, -12)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = ""
    Btn.ZIndex = 12
    Btn.Parent = ToggleFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = UDim2.new(0, 2, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.ZIndex = 13
    Indicator.Parent = Btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local toggled = false
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Btn.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
        else
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
        callback(toggled)
    end)
end

-- ==========================================
-- TOGGLE 1: AUTO REPARTOSYA (MOTOR ROBUSTO HÍBRIDO)
-- ==========================================
CreateToggle("Auto RepartosYa (Celular)", 60, function(Value)
    getgenv().autoPedidos = Value
    
    task.spawn(function()
        while getgenv().autoPedidos do
            task.wait(0.8)
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not playerGui or not hrp then return end
                
                -- MÉTODO A: Buscador y clicker masivo en la App del Celular (RepartosYaApp)
                local repartosApp = playerGui:FindFirstChild("RepartosYaApp", true)
                if repartosApp then
                    local ordersFrame = repartosApp:FindFirstChild("OrdersFrame", true) or repartosApp
                    for _, descendant in ipairs(ordersFrame:GetDescendants()) do
                        if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                            local textName = string.lower(descendant.Name)
                            local parentName = string.lower(descendant.Parent.Name)
                            if string.match(textName, "acept") or string.match(parentName, "order") or descendant.Visible then
                                pcall(function()
                                    if firesignal then firesignal(descendant.MouseButton1Click) end
                                    if getconnections then
                                        for _, conn in ipairs(getconnections(descendant.MouseButton1Click)) do conn:Fire() end
                                    end
                                end)
                            end
                        end
                    end
                end

                -- MÉTODO B: Disparar eventos de red del juego directamente si existen
                pcall(function()
                    for _, ev in ipairs(ReplicatedStorage:GetDescendants()) do
                        if ev:IsA("RemoteEvent") and (string.match(string.lower(ev.Name), "pedidos") or string.match(string.lower(ev.Name), "delivery") or string.match(string.lower(ev.Name), "order")) then
                            ev:FireServer("Accept")
                            ev:FireServer("Claim")
                        end
                    end
                end)

                -- MÉTODO C: Barrido y Teletransporte físico a cualquier punto de entrega activo en Workspace
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if (obj:IsA("ProximityPrompt") or obj:IsA("TouchTransmitter") or obj.Name == "HumanoidRootPart" or obj.Name == "Part") then
                        local ancestor = obj.Parent
                        if ancestor and ancestor:IsA("Model") then
                            local nameLower = string.lower(ancestor.Name)
                            if string.match(nameLower, "pedido") or string.match(nameLower, "delivery") or string.match(nameLower, "restaurant") or string.match(nameLower, "house") or string.match(nameLower, "casa") then
                                local targetPart = ancestor.PrimaryPart or ancestor:FindFirstChild("HumanoidRootPart") or ancestor:FindFirstChildWhichIsA("BasePart")
                                if targetPart then
                                    local oldPos = hrp.CFrame
                                    hrp.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                                    task.wait(0.2)
                                    
                                    -- Forzar interacciones físicas y por teclado
                                    if obj:IsA("ProximityPrompt") then
                                        obj.HoldDuration = 0
                                        pcall(function() fireproximityprompt(obj) end)
                                    end
                                    
                                    for _, key in ipairs({Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.ButtonX}) do
                                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                                        task.wait(0.02)
                                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                                    end
                                    
                                    task.wait(0.3)
                                    hrp.CFrame = oldPos
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- ==========================================
-- TOGGLE 2: AUTO AGARRAR DINERO (MOTOR ROBUSTO)
-- ==========================================
CreateToggle("Auto-Agarrar Dinero", 115, function(Value)
    getgenv().autoGrabCash = Value
    
    task.spawn(function()
        while getgenv().autoGrabCash do
            task.wait(0.4)
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Escaneo masivo en todo el Workspace de cualquier objeto que sea dinero o drop
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = string.lower(obj.Name)
                        if string.match(nameLower, "cash") or string.match(nameLower, "dinero") or string.match(nameLower, "plata") or string.match(nameLower, "drop") or string.match(nameLower, "billete") then
                            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part then
                                local oldPos = hrp.CFrame
                                hrp.CFrame = part.CFrame + Vector3.new(0, 1, 0)
                                task.wait(0.15)
                                
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    prompt.HoldDuration = 0
                                    pcall(function() fireproximityprompt(prompt) end)
                                end
                                
                                for _, key in ipairs({Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G}) do
                                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                                    task.wait(0.01)
                                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                                end
                                
                                task.wait(0.1)
                                hrp.CFrame = oldPos
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- ==========================================
-- INTERFAZ DE LOGS
-- ==========================================
local GuiLogScroll = Instance.new("ScrollingFrame")
GuiLogScroll.Size = UDim2.new(1, -30, 0, 120)
GuiLogScroll.Position = UDim2.new(0, 15, 0, 175)
GuiLogScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GuiLogScroll.BorderSizePixel = 0
GuiLogScroll.ScrollBarThickness = 4
GuiLogScroll.ZIndex = 11
GuiLogScroll.Parent = MainFrame
Instance.new("UICorner", GuiLogScroll).CornerRadius = UDim.new(0, 6)

local GuiLogTextLabel = Instance.new("TextLabel")
GuiLogTextLabel.Size = UDim2.new(1, -10, 0, 0)
GuiLogTextLabel.Position = UDim2.new(0, 5, 0, 5)
GuiLogTextLabel.BackgroundTransparency = 1
GuiLogTextLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
GuiLogTextLabel.Font = Enum.Font.Code
GuiLogTextLabel.TextSize = 12
GuiLogTextLabel.TextXAlignment = Enum.TextXAlignment.Left
GuiLogTextLabel.TextYAlignment = Enum.TextYAlignment.Top
GuiLogTextLabel.TextWrapped = true
GuiLogTextLabel.AutomaticSize = Enum.AutomaticSize.Y
GuiLogTextLabel.ZIndex = 12
GuiLogTextLabel.Text = "Sistema Robusto Iniciado..."
GuiLogTextLabel.Parent = GuiLogScroll

local CopyLogsBtn = Instance.new("TextButton")
CopyLogsBtn.Size = UDim2.new(1, -30, 0, 30)
CopyLogsBtn.Position = UDim2.new(0, 15, 0, 305)
CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CopyLogsBtn.Text = "Copiar Datos Capturados"
CopyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyLogsBtn.Font = Enum.Font.GothamBold
CopyLogsBtn.TextSize = 13
CopyLogsBtn.ZIndex = 11
CopyLogsBtn.Parent = MainFrame
Instance.new("UICorner", CopyLogsBtn).CornerRadius = UDim.new(0, 6)

CopyLogsBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GuiLogTextLabel.Text)
        CopyLogsBtn.Text = "¡Registros copiados!"
        task.wait(1.5)
        CopyLogsBtn.Text = "Copiar Datos Capturados"
    end
end)

local guiConnections = {}
local guiLogHistory = ""
local function addLog(prefix, text)
    local timestamp = os.date("%H:%M:%S")
    guiLogHistory = "["..timestamp.."] " .. prefix .. " " .. text .. "\n" .. guiLogHistory
    if #guiLogHistory > 5000 then guiLogHistory = string.sub(guiLogHistory, 1, 5000) end
    GuiLogTextLabel.Text = guiLogHistory
end

CreateToggle("Inspector Celular/GUI", 345, function(Value)
    if Value then
        addLog("[SISTEMA]", "Capturando...")
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        table.insert(guiConnections, playerGui.DescendantAdded:Connect(function(desc)
            task.wait(0.1) 
            if desc:IsA("ScreenGui") and desc.Enabled then addLog("[📱 NUEVO]", desc.Name)
            elseif desc:IsA("Frame") and desc.Visible then addLog("[🪟 NUEVO]", desc.Name) end
        end))
    else
        addLog("[SISTEMA]", "Captura detenida.")
        for _, conn in ipairs(guiConnections) do if conn.Connected then conn:Disconnect() end end
        guiConnections = {}
    end
end)

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.Position = UDim2.new(0, 0, 1, -30)
Credits.BackgroundTransparency = 1
Credits.Text = "ID: Gattoi | Motor Híbrido Robusto"
Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 11
Credits.ZIndex = 11
Credits.Parent = MainFrame
