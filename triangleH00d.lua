-- ==========================================
-- Mini chit Hood Argentino V4 (ROBUSTO) - iOS
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==========================================
-- 1. INTERFAZ TÁCTIL (DRAGGABLE)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuRobusto"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -166, 0.5, -100)
MainFrame.Size = UDim2.new(0, 332, 0, 190)
MainFrame.Active = true

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ HOOD ARG V4 (TANK MODE) ⚡"
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.TextScaled = true

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Position = UDim2.new(1, -25, 0, 10)
CloseBtn.Size = UDim2.new(0, 15, 0, 15)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function createButton(text, pos, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.BackgroundColor3 = color
    btn.Position = pos
    btn.Size = UDim2.new(0, 140, 0, 50)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    Instance.new("UICorner", btn)
    return btn
end

local BtnPlata = createButton("Repartos Automático", UDim2.new(0.05, 0, 0.25, 0), Color3.fromRGB(40, 160, 40))
local BtnPick = createButton("Auto-Agarrar Plata", UDim2.new(0.53, 0, 0.25, 0), Color3.fromRGB(180, 140, 10))
local LogText = Instance.new("TextLabel", MainFrame)
LogText.BackgroundTransparency = 1
LogText.Position = UDim2.new(0.05, 0, 0.6, 0)
LogText.Size = UDim2.new(0.9, 0, 0, 50)
LogText.Font = Enum.Font.Gotham
LogText.Text = "Estado: En espera..."
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.TextScaled = true

-- ==========================================
-- 2. FUNCIONES DE FUERZA BRUTA
-- ==========================================
local function updateLog(msg)
    LogText.Text = msg
    print("[V4] " .. msg)
end

-- Fuerza bruta para UIs de iOS
local function forceClick(btn)
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
        elseif firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
end

-- Teletransporte perfecto que evita que el personaje se atasque
local function robustTeleport(targetPart)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:PivotTo(targetPart.CFrame * CFrame.new(0, 2, 2)) -- Te pone un poco elevado y desplazado
        char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Frena caídas
        task.wait(0.5) -- Espera de sincronización de red
    end
end

-- Buscador dinámico de prompts activos
local function getActiveTarget(folder)
    if not folder then return nil, nil end
    for _, location in ipairs(folder:GetChildren()) do
        local prompt = location:FindFirstChildOfClass("ProximityPrompt") or location:FindFirstChild("ProximityPrompt", true)
        if prompt and prompt.Enabled then
            return location, prompt
        end
    end
    return nil, nil
end

-- ==========================================
-- 3. BUCLE PRINCIPAL DE FARMEO
-- ==========================================
getgenv().farmPlata = false

BtnPlata.MouseButton1Click:Connect(function()
    getgenv().farmPlata = not getgenv().farmPlata
    if getgenv().farmPlata then
        BtnPlata.Text = "Detener Farmeo"
        BtnPlata.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        
        task.spawn(function()
            while getgenv().farmPlata do
                task.wait(1.5) -- Bucle más relajado para evitar crasheos en móvil
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

                local mapJobs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs")
                local repartosFolder = mapJobs and mapJobs:FindFirstChild("RepartosYA")
                if not repartosFolder then updateLog("No se encuentra la carpeta del trabajo") continue end

                -- PASO 1: ¿Tengo que entregar algo?
                local target, prompt = getActiveTarget(repartosFolder:FindFirstChild("deliveryLocations"))
                if target then
                    updateLog("¡Yendo a entregar pedido!")
                    robustTeleport(target)
                    for i=1, 5 do -- Spameo seguro
                        if prompt.Enabled then fireproximityprompt(prompt, 1) end
                        task.wait(0.2)
                    end
                    continue
                end

                -- PASO 2: ¿Tengo que recoger comida?
                target, prompt = getActiveTarget(repartosFolder:FindFirstChild("restaurantLocations"))
                if target then
                    updateLog("¡Yendo a buscar comida!")
                    robustTeleport(target)
                    for i=1, 5 do
                        if prompt.Enabled then fireproximityprompt(prompt, 1) end
                        task.wait(0.2)
                    end
                    continue
                end

                -- PASO 3: Si no hay entregas ni recogidas, acepto una nueva.
                updateLog("Buscando nuevo pedido en App...")
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if phoneGui then
                    local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                    if appFrame then
                        local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                        if searchBtn then
                            forceClick(searchBtn)
                            task.wait(1) -- Damos tiempo a que aparezcan los frames de Order_
                        end

                        local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                        if ordersList then
                            for _, orderFrame in ipairs(ordersList:GetChildren()) do
                                if orderFrame:IsA("Frame") and string.match(orderFrame.Name, "^Order_") then
                                    local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                                    if acceptBtn then
                                        forceClick(acceptBtn)
                                        updateLog("¡Nuevo pedido aceptado!")
                                        task.wait(1)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        BtnPlata.Text = "Repartos Automático"
        BtnPlata.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
        updateLog("Farmeo Detenido.")
    end
end)

-- ==========================================
-- 4. RECOLECTOR DE DINERO DEFINITIVO
-- ==========================================
local recolectando = false
BtnPick.MouseButton1Click:Connect(function()
    recolectando = not recolectando
    
    if recolectando then
        BtnPick.Text = "Auto-Agarrar: ON"
        BtnPick.BackgroundColor3 = Color3.fromRGB(130, 140, 10)
        updateLog("Escaneando dinero tirado...")
        
        -- Función de captura global (Usa RunService para estar siempre atento sin laggear)
        getgenv().moneyLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                local function scanFolder(folder)
                    if not folder then return end
                    for _, drop in ipairs(folder:GetChildren()) do
                        local claimPrompt = drop:FindFirstChild("claim") or drop:FindFirstChildOfClass("ProximityPrompt")
                        if claimPrompt then
                            claimPrompt.HoldDuration = 0
                            fireproximityprompt(claimPrompt, 1)
                        end
                    end
                end
                
                scanFolder(workspace:FindFirstChild("Filter") and workspace.Filter:FindFirstChild("CashDrops"))
                scanFolder(workspace:FindFirstChild("CuerposMuertos") and workspace.CuerposMuertos:FindFirstChild("Filter") and workspace.CuerposMuertos.Filter:FindFirstChild("CashDrops"))
            end)
        end)
    else
        BtnPick.Text = "Auto-Agarrar Plata"
        BtnPick.BackgroundColor3 = Color3.fromRGB(180, 140, 10)
        if getgenv().moneyLoop then getgenv().moneyLoop:Disconnect() end
        updateLog("Recolector de plata desactivado.")
    end
end)
