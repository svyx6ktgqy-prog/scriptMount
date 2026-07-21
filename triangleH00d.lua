-- ==========================================
-- Mini chit Hood Argentino V6 (ANTI-BUCLE) - iOS
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
ScreenGui.Name = "MenuAntiBucle"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
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
Title.Text = "⚡ HOOD ARG V6 (ANTI-BUCLE) ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
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
-- 2. FUNCIONES DE INTERACCIÓN Y NAVEGACIÓN
-- ==========================================
local function updateLog(msg)
    LogText.Text = msg
    print("[V6] " + msg)
end

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

local function forceMobilePrompt(prompt)
    pcall(function() fireproximityprompt(prompt, 1) end)
    pcall(function()
        local promptUI = LocalPlayer.PlayerGui:FindFirstChild("ProximityPrompts")
        if promptUI then
            local frame = promptUI:FindFirstChild("Prompt") and promptUI.Prompt:FindFirstChild("Frame")
            local btn = frame and frame:FindFirstChild("TextButton")
            if btn then forceClick(btn) end
        end
    end)
end

local function robustTeleport(targetObject)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local targetCFrame
    if targetObject:IsA("Model") then
        targetCFrame = targetObject:GetPivot()
    elseif targetObject:IsA("BasePart") then
        targetCFrame = targetObject.CFrame
    end
    
    if targetCFrame then
        char:PivotTo(targetCFrame * CFrame.new(0, 3, 2))
        char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        task.wait(0.6)
    end
end

-- ==========================================
-- 3. BUCLE PRINCIPAL DE FARMEO INTELIGENTE
-- ==========================================
getgenv().farmPlata = false

BtnPlata.MouseButton1Click:Connect(function()
    getgenv().farmPlata = not getgenv().farmPlata
    if getgenv().farmPlata then
        BtnPlata.Text = "Detener Farmeo"
        BtnPlata.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        
        task.spawn(function()
            while getgenv().farmPlata do
                task.wait(1)
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

                local mapJobs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs")
                local repartosFolder = mapJobs and mapJobs:FindFirstChild("RepartosYA")
                if not repartosFolder then continue end

                -- PASO 1: PRIORIDAD MÁXIMA -> Buscar destinos de Entrega activos
                local deliveryFolder = repartosFolder:FindFirstChild("deliveryLocations")
                local foundDelivery = false
                if deliveryFolder then
                    for _, loc in ipairs(deliveryFolder:GetChildren()) do
                        local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                        -- Si el prompt existe y está habilitado, significa que tenemos que entregar ahí YA
                        if prompt and prompt.Enabled then
                            foundDelivery = true
                            updateLog("Entregando en destino...")
                            local targetPart = (prompt.Parent and prompt.Parent:IsA("BasePart")) and prompt.Parent or loc
                            robustTeleport(targetPart)
                            
                            -- Spam de interacción hasta que se complete
                            local intentos = 0
                            while prompt.Enabled and intentos < 8 and getgenv().farmPlata do
                                forceMobilePrompt(prompt)
                                task.wait(0.25)
                                intentos = intentos + 1
                            end
                            break
                        end
                    end
                end

                if foundDelivery then continue end -- Si manejó una entrega, repite el ciclo

                -- PASO 2: PRIORIDAD SEGUNDA -> Buscar Restaurante para recoger comida
                local restFolder = repartosFolder:FindFirstChild("restaurantLocations")
                local foundRest = false
                if restFolder then
                    for _, loc in ipairs(restFolder:GetChildren()) do
                        local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            foundRest = true
                            updateLog("Recogiendo en restaurante...")
                            local targetPart = (prompt.Parent and prompt.Parent:IsA("BasePart")) and prompt.Parent or loc
                            robustTeleport(targetPart)
                            
                            local intentos = 0
                            while prompt.Enabled and intentos < 8 and getgenv().farmPlata do
                                forceMobilePrompt(prompt)
                                task.wait(0.25)
                                intentos = intentos + 1
                            end
                            break
                        end
                    end
                end

                if foundRest then continue end -- Si manejó el restaurante, repite el ciclo

                -- PASO 3: SI NO HAY NADA ACTIVO EN EL MAPA -> Aceptar pedido por Celular
                updateLog("Buscando pedido en el celular...")
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if phoneGui then
                    local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                    if appFrame then
                        local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                        if searchBtn then
                            forceClick(searchBtn)
                            task.wait(0.8)
                        end

                        local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                        if ordersList then
                            for _, orderFrame in ipairs(ordersList:GetChildren()) do
                                if orderFrame:IsA("Frame") and string.match(orderFrame.Name, "^Order_") then
                                    local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                                    if acceptBtn then
                                        forceClick(acceptBtn)
                                        updateLog("¡Pedido aceptado con éxito!")
                                        task.wait(1.5) -- Esperar a que el juego actualice las carpetas del mapa
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
-- 4. RECOLECTOR DE DINERO
-- ==========================================
local recolectando = false
BtnPick.MouseButton1Click:Connect(function()
    recolectando = not recolectando
    
    if recolectando then
        BtnPick.Text = "Auto-Agarrar: ON"
        BtnPick.BackgroundColor3 = Color3.fromRGB(130, 140, 10)
        updateLog("Escaneando dinero...")
        
        getgenv().moneyLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                local function scanFolder(folder)
                    if not folder then return end
                    for _, drop in ipairs(folder:GetChildren()) do
                        local claimPrompt = drop:FindFirstChild("claim") or drop:FindFirstChildOfClass("ProximityPrompt")
                        if claimPrompt then
                            claimPrompt.HoldDuration = 0
                            forceMobilePrompt(claimPrompt)
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
        updateLog("Recolector desactivado.")
    end
end)
