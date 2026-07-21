-- ==========================================
-- Mini chit Hood Argentino V11 (ROBUST FIX) - iOS
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==========================================
-- 1. INTERFAZ TÁCTIL (ESTILO DELTA iOS)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniChitHoodV11"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainFrame.Position = UDim2.new(0.108, 0, 0.265, 0)
MainFrame.Size = UDim2.new(0, 332, 0, 130)
MainFrame.Active = true

-- Sistema de arrastre táctil para iPhone
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
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(0, 332, 0, 30)
Title.Font = Enum.Font.ArialBold
Title.Text = "Mini chit Hood Argentino (V11 Robusto)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
CloseBtn.Size = UDim2.new(0, 15, 0, 15)
CloseBtn.Font = Enum.Font.Unknown
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.TextScaled = true
CloseBtn.MouseButton1Down:Connect(function() ScreenGui:Destroy() end)

-- Botón 1: Repartos Ya (Modo Ultra Robusto con Forzado de Render)
local BtnPlata = Instance.new("TextButton", MainFrame)
BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
BtnPlata.BorderSizePixel = 0
BtnPlata.Position = UDim2.new(0.065, 0, 0.35, 0)
BtnPlata.Size = UDim2.new(0, 130, 0, 60)
BtnPlata.Font = Enum.Font.Unknown
BtnPlata.Text = "Repartos Ya (Ultra Auto)"
BtnPlata.TextColor3 = Color3.fromRGB(5, 2, 18)
BtnPlata.TextScaled = true
BtnPlata.TextWrapped = true
Instance.new("UICorner", BtnPlata)

-- Botón 2: Anti-perder plata + Agarrar automático
local BtnPick = Instance.new("TextButton", MainFrame)
BtnPick.BackgroundColor3 = Color3.fromRGB(180, 189, 13)
BtnPick.BorderSizePixel = 0
BtnPick.Position = UDim2.new(0.55, 0, 0.35, 0)
BtnPick.Size = UDim2.new(0, 130, 0, 60)
BtnPick.Font = Enum.Font.Unknown
BtnPick.Text = "Anti-perder plata + Agarrar auto"
BtnPick.TextColor3 = Color3.fromRGB(5, 2, 18)
BtnPick.TextScaled = true
BtnPick.TextWrapped = true
Instance.new("UICorner", BtnPick)

-- ==========================================
-- 2. FUNCIONES DE CLICS Y TELETRANSPORTE ANTI-STREAMING
-- ==========================================
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

-- Teletransporte con carga forzada de posición remota
local function robustTeleportToTarget(targetObject)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local targetCFrame = nil
    
    if targetObject:IsA("Model") then
        targetCFrame = targetObject:GetPivot()
    elseif targetObject:IsA("BasePart") then
        targetCFrame = targetObject.CFrame
    elseif targetObject:IsA("Attachment") then
        targetCFrame = targetObject.WorldCFrame
    end
    
    if targetCFrame then
        -- Forzar la carga de la zona si el juego usa StreamingEnabled
        pcall(function()
            if LocalPlayer.RequestStreamAsync then
                LocalPlayer:RequestStreamAsync(targetCFrame.Position)
            end
        end)
        
        local hrp = char.HumanoidRootPart
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        -- Teletransporte directo al punto exacto con ligera altura para evitar trabarse en el piso
        hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.4)
    end
end

-- ==========================================
-- 3. BUCLE INTELIGENTE DE REPARTOS YA (V11)
-- ==========================================
getgenv().repartosActive = false

BtnPlata.MouseButton1Down:Connect(function()
    getgenv().repartosActive = not getgenv().repartosActive
    
    if getgenv().repartosActive then
        BtnPlata.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnPlata.Text = "Detener Repartos"
        
        task.spawn(function()
            while getgenv().repartosActive do
                task.wait(0.8)
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

                local mapJobs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs")
                local repartosFolder = mapJobs and mapJobs:FindFirstChild("RepartosYA")
                if not repartosFolder then continue end

                -- PASO 1: Verificar si hay que ENTREGAR (deliveryLocations)
                local deliveryFolder = repartosFolder:FindFirstChild("deliveryLocations")
                local handledDelivery = false
                if deliveryFolder then
                    for _, loc in ipairs(deliveryFolder:GetChildren()) do
                        local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            handledDelivery = true
                            -- Buscar la parte padre o el objeto raíz del prompt para asegurar coordenadas reales
                            local targetPart = prompt.Parent or loc
                            robustTeleportToTarget(targetPart)
                            
                            local intentos = 0
                            while prompt.Enabled and intentos < 10 and getgenv().repartosActive do
                                forceMobilePrompt(prompt)
                                task.wait(0.25)
                                intentos = intentos + 1
                            end
                            break
                        end
                    end
                end
                if handledDelivery then continue end

                -- PASO 2: Verificar si hay que RECOGER en el restaurante (restaurantLocations)
                local restFolder = repartosFolder:FindFirstChild("restaurantLocations")
                local handledRest = false
                if restFolder then
                    for _, loc in ipairs(restFolder:GetChildren()) do
                        local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            handledRest = true
                            local targetPart = prompt.Parent or loc
                            robustTeleportToTarget(targetPart)
                            
                            local intentos = 0
                            while prompt.Enabled and intentos < 10 and getgenv().repartosActive do
                                forceMobilePrompt(prompt)
                                task.wait(0.25)
                                intentos = intentos + 1
                            end
                            break
                        end
                    end
                end
                if handledRest then continue end

                -- PASO 3: SI NO HAY ENDPOINTS ACTIVOS -> Aceptar pedido desde la app del Celular
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if phoneGui then
                    local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                    if appFrame then
                        -- Buscar pedidos nuevos
                        local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                        if searchBtn then
                            forceClick(searchBtn)
                            task.wait(0.6)
                        end

                        -- Aceptar de la lista Order_xx
                        local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                        if ordersList then
                            for _, orderFrame in ipairs(ordersList:GetChildren()) do
                                if orderFrame:IsA("Frame") and string.match(orderFrame.Name, "^Order_") then
                                    local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                                    if acceptBtn then
                                        forceClick(acceptBtn)
                                        task.wait(1.2)
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
        BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
        BtnPlata.Text = "Repartos Ya (Ultra Auto)"
    end
end)

-- ==========================================
-- 4. RECOLECTOR AUTOMÁTICO DE DINERO
-- ==========================================
BtnPick.MouseButton1Down:Connect(function()
    pcall(function()
        local function setupClaim(drop)
            local claim = drop:FindFirstChild("claim")
            if claim then
                claim.HoldDuration = 0
                fireproximityprompt(claim)
            end
        end

        if workspace:FindFirstChild("Filter") and workspace.Filter:FindFirstChild("CashDrops") then
            workspace.Filter.CashDrops.ChildAdded:Connect(setupClaim)
            for _, v in ipairs(workspace.Filter.CashDrops:GetChildren()) do setupClaim(v) end
        end

        if workspace:FindFirstChild("CuerposMuertos") then
            local cFilter = workspace.CuerposMuertos:FindFirstChild("Filter")
            if cFilter and cFilter:FindFirstChild("CashDrops") then
                cFilter.CashDrops.ChildAdded:Connect(setupClaim)
                for _, v in ipairs(cFilter.CashDrops:GetChildren()) do setupClaim(v) end
            end
        end
    end)
    BtnPick.Text = "¡Auto-Agarrar Activado!"
    BtnPick.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
end)
