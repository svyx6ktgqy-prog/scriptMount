-- ==========================================
-- Mini chit Hood Argentino V3 (EXPERT MODE) - Para iOS
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- ==========================================
-- 1. CREACIÓN DE INTERFAZ (DRAGGABLE TÁCTIL)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuExpert"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -166, 0.5, -100)
MainFrame.Size = UDim2.new(0, 332, 0, 190)
MainFrame.Active = true

-- Sistema de arrastre
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

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ HOOD ARG V3 (EXPERT) ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
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

-- Botones
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

local BtnPlata = createButton("Generador de Plata", UDim2.new(0.05, 0, 0.25, 0), Color3.fromRGB(40, 160, 40))
local BtnPick = createButton("Anti-Perder / Agarrar", UDim2.new(0.53, 0, 0.25, 0), Color3.fromRGB(180, 140, 10))
local BtnTiendas = createButton("Activar Captura Tiendas", UDim2.new(0.05, 0, 0.6, 0), Color3.fromRGB(50, 100, 200))
local LogText = Instance.new("TextLabel", MainFrame)
LogText.BackgroundTransparency = 1
LogText.Position = UDim2.new(0.53, 0, 0.6, 0)
LogText.Size = UDim2.new(0, 140, 0, 50)
LogText.Font = Enum.Font.Gotham
LogText.Text = "Estado: Esperando..."
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.TextScaled = true

-- ==========================================
-- 2. FUNCIONES EXPERTAS DE CONTROL
-- ==========================================

local function updateLog(msg)
    LogText.Text = msg
end

local function forceClick(button)
    if getconnections then
        for _, conn in ipairs(getconnections(button.MouseButton1Click)) do conn:Fire() end
    elseif firesignal then
        firesignal(button.MouseButton1Click)
    end
end

local function equipPhone()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if backpack and char then
        local phone = backpack:FindFirstChild("Phone")
        if phone then
            char:FindFirstChild("Humanoid"):EquipTool(phone)
            task.wait(0.5) -- Dar tiempo a que el server registre el celular en mano
        end
    end
end

local function interactWithTarget(folderPath)
    if not folderPath then return false end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    for _, location in ipairs(folderPath:GetChildren()) do
        local prompt = location:FindFirstChildOfClass("ProximityPrompt") or location:FindFirstChild("ProximityPrompt", true)
        
        if prompt and prompt.Enabled then
            -- Moverse y mirar directamente al objetivo (Evade anti-cheats de visión)
            root.CFrame = location.CFrame * CFrame.new(0, 2, 2)
            root.CFrame = CFrame.lookAt(root.Position, location.Position)
            task.wait(0.6) 

            -- Bucle agresivo: Intenta recoger/entregar hasta que el prompt desaparezca
            local attempts = 0
            while prompt and prompt.Enabled and attempts < 6 do
                fireproximityprompt(prompt)
                task.wait(0.3)
                attempts = attempts + 1
            end
            return true -- Retorna true si encontró e interactuó con un objetivo activo
        end
    end
    return false
end

-- ==========================================
-- 3. LÓGICA PRINCIPAL AUTOMATIZADA
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
                if not char or char:FindFirstChild("Humanoid").Health <= 0 then continue end

                local jobsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs") and workspace.Map.Jobs:FindFirstChild("RepartosYA")
                if not jobsFolder then continue end

                updateLog("Buscando Entregas...")
                -- 1. Intentar Entregar primero (por si nos mataron y aún tenemos la caja)
                if interactWithTarget(jobsFolder:FindFirstChild("deliveryLocations")) then
                    updateLog("¡Pedido Entregado!")
                    task.wait(1)
                    continue 
                end

                updateLog("Buscando Comida...")
                -- 2. Intentar Recoger comida (si ya aceptamos un pedido previamente)
                if interactWithTarget(jobsFolder:FindFirstChild("restaurantLocations")) then
                    updateLog("¡Comida Recogida!")
                    task.wait(1)
                    continue
                end

                -- 3. Si no hay nada que recoger ni entregar, usar el teléfono
                updateLog("Buscando en App...")
                equipPhone()
                
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if phoneGui then
                    local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                    if appFrame then
                        -- Refrescar la app
                        local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                        if searchBtn then
                            forceClick(searchBtn)
                            task.wait(0.7)
                        end

                        -- Buscar pedidos ("Order_")
                        local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                        if ordersList then
                            for _, orderFrame in ipairs(ordersList:GetChildren()) do
                                if orderFrame:IsA("Frame") and string.sub(orderFrame.Name, 1, 6) == "Order_" then
                                    local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                                    if acceptBtn then
                                        forceClick(acceptBtn)
                                        updateLog("¡Pedido Aceptado!")
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
        BtnPlata.Text = "Generador de Plata"
        BtnPlata.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
        updateLog("Farmeo Detenido")
    end
end)

-- ==========================================
-- 4. CAPTURADOR DE TIENDAS Y DINERO FALSO
-- ==========================================
local capturandoTiendas = false
BtnTiendas.MouseButton1Click:Connect(function()
    capturandoTiendas = not capturandoTiendas
    if capturandoTiendas then
        BtnTiendas.Text = "Capturando Tiendas"
        BtnTiendas.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
        updateLog("Capturando transacciones...")
        
        -- Conecta de forma natural con los ProximityPrompts del juego
        getgenv().shopLogger = ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
            if player == LocalPlayer and capturandoTiendas then
                -- Registra interacciones en tiendas u objetos
                print("[💰 CAPTURA TIENDA] Interactuaste con: " .. tostring(prompt.Parent and prompt.Parent.Name or "Objeto Desconocido") .. " | Acción: " .. tostring(prompt.ActionText))
            end
        end)
    else
        BtnTiendas.Text = "Activar Captura Tiendas"
        BtnTiendas.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        if getgenv().shopLogger then
            getgenv().shopLogger:Disconnect()
        end
        updateLog("Captura desactivada.")
    end
end)

-- Anti-Perder / Agarrar (Optimizado)
BtnPick.MouseButton1Click:Connect(function()
    BtnPick.Text = "Auto-Agarrar ON"
    BtnPick.BackgroundColor3 = Color3.fromRGB(130, 140, 10)
    
    local function autoClaim(folder)
        if not folder then return end
        folder.ChildAdded:Connect(function(v)
            task.wait(0.05)
            if v:FindFirstChild("claim") then
                v.claim.HoldDuration = 0
                fireproximityprompt(v.claim)
            end
        end)
        for _, v in ipairs(folder:GetChildren()) do
            if v:FindFirstChild("claim") then
                v.claim.HoldDuration = 0
                fireproximityprompt(v.claim)
            end
        end
    end
    
    autoClaim(workspace:FindFirstChild("Filter") and workspace.Filter:FindFirstChild("CashDrops"))
    autoClaim(workspace:FindFirstChild("CuerposMuertos") and workspace.CuerposMuertos:FindFirstChild("Filter") and workspace.CuerposMuertos.Filter:FindFirstChild("CashDrops"))
end)
