local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 1. Crear el GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodArgMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- 2. Botón Flotante para Móviles
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0, 15)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "👽"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 22
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- 3. Ventana Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480) 
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "HOOD ARGENTINO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Lógica para arrastrar el menú
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

-- 4. Constructor de Toggles
local function CreateToggle(name, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -30, 0, 45)
    ToggleFrame.Position = UDim2.new(0, 15, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
    Label.Parent = ToggleFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 46, 0, 24)
    Btn.Position = UDim2.new(1, -60, 0.5, -12)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = ""
    Btn.Parent = ToggleFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = UDim2.new(0, 2, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
-- TOGGLE 1: AUTO REPARTOSYA (Corregido y Físico)
-- ==========================================
CreateToggle("Auto RepartosYa (Celular)", 60, function(Value)
    getgenv().a = Value
    
    task.spawn(function()
        while getgenv().a do
            task.wait(1)
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not playerGui or not hrp then return end
                
                -- FASE 1: Aceptar los pedidos desde el celular
                local repartosApp = playerGui:FindFirstChild("RepartosYaApp", true)
                if repartosApp then
                    local ordersFrame = repartosApp:FindFirstChild("OrdersFrame", true)
                    if ordersFrame then
                        for _, frame in ipairs(ordersFrame:GetChildren()) do
                            if string.match(frame.Name, "Order_") then
                                -- Buscar el botón azul mostrado en image.png
                                local btn = frame:FindFirstChildWhichIsA("TextButton", true) or frame:FindFirstChildWhichIsA("ImageButton", true)
                                if btn then
                                    if type(firesignal) == "function" then
                                        firesignal(btn.MouseButton1Click)
                                    elseif getconnections then
                                        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                                    end
                                end
                            end
                        end
                    end
                end

                -- FASE 2: Teletransporte e interacción física con los puntos de entrega/recogida
                -- Buscamos cualquier ProximityPrompt activo en el mapa relacionado al trabajo
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local parentName = string.lower(obj.Parent.Name)
                        local actionText = string.lower(obj.ActionText)
                        
                        if string.match(parentName, "pedido") or string.match(parentName, "delivery") or string.match(parentName, "restaurant") or string.match(actionText, "recoger") or string.match(actionText, "entregar") or string.match(actionText, "agarrar") then
                            
                            local oldCFrame = hrp.CFrame
                            -- Teletransporte al objetivo
                            hrp.CFrame = obj.Parent.CFrame
                            task.wait(0.3)
                            
                            -- Ignorar el tiempo de mantener presionado
                            obj.HoldDuration = 0
                            fireproximityprompt(obj)
                            
                            task.wait(0.5)
                            -- Regresar a la posición original (opcional, coméntalo si prefieres quedarte ahí)
                            hrp.CFrame = oldCFrame
                        end
                    end
                end
            end)
        end
    end)
end)

-- ==========================================
-- TOGGLE 2: AUTO AGARRAR DINERO (Escaneo Dinámico de Mapa)
-- ==========================================
CreateToggle("Auto-Agarrar Dinero", 115, function(Value)
    getgenv().autoGrab = Value
    
    task.spawn(function()
        while getgenv().autoGrab do
            task.wait(0.5)
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Escanea todo el mapa ignorando carpetas para evitar problemas si el dev cambia los nombres
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local parentName = string.lower(obj.Parent.Name)
                        local actionText = string.lower(obj.ActionText)
                        
                        -- Palabras clave comunes para el dinero en Hood Argentino
                        if string.match(parentName, "cash") or string.match(parentName, "dinero") or string.match(parentName, "plata") or string.match(parentName, "drop") or string.match(actionText, "claim") or string.match(actionText, "agarrar") then
                            
                            local oldPos = hrp.CFrame
                            -- Teletransporte seguro hacia el dinero
                            hrp.CFrame = obj.Parent.CFrame
                            task.wait(0.2)
                            
                            obj.HoldDuration = 0
                            fireproximityprompt(obj)
                            
                            task.wait(0.1)
                            -- Evita quedarte bugeado en el piso, vuelve a tu lugar original
                            hrp.CFrame = oldPos
                        end
                    end
                end
            end)
        end
    end)
end)

-- Inspector de Interfaz (Logs que me pasaste, minimizado para ahorrar espacio)
local GuiLogScroll = Instance.new("ScrollingFrame")
GuiLogScroll.Size = UDim2.new(1, -30, 0, 120)
GuiLogScroll.Position = UDim2.new(0, 15, 0, 175)
GuiLogScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GuiLogScroll.BorderSizePixel = 0
GuiLogScroll.ScrollBarThickness = 4
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
GuiLogTextLabel.Text = "Logs listos..."
GuiLogTextLabel.Parent = GuiLogScroll

local CopyLogsBtn = Instance.new("TextButton")
CopyLogsBtn.Size = UDim2.new(1, -30, 0, 30)
CopyLogsBtn.Position = UDim2.new(0, 15, 0, 305)
CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CopyLogsBtn.Text = "Copiar Datos Capturados"
CopyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyLogsBtn.Font = Enum.Font.GothamBold
CopyLogsBtn.TextSize = 13
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

-- Créditos
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.Position = UDim2.new(0, 0, 1, -30)
Credits.BackgroundTransparency = 1
Credits.Text = "ID: Gattoi | Auto-Físico Activado"
Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 11
Credits.Parent = MainFrame
