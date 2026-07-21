-- ==========================================
-- Mini chit Hood Argentino V2 - Adaptado para Móvil
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Crear Interfaz Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MenuActualizado"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
MainFrame.Position = UDim2.new(0.5, -166, 0.5, -58)
MainFrame.Size = UDim2.new(0, 332, 0, 117)
MainFrame.Active = true

-- Sistema de arrastre táctil (Mobile Friendly)
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

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.ArialBold
Title.Text = "Mini chit Hood Argentino V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

-- Botón Cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Position = UDim2.new(1, -20, 0, 5)
CloseBtn.Size = UDim2.new(0, 15, 0, 15)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Botón Generador de Plata
local BtnPlata = Instance.new("TextButton")
BtnPlata.Parent = MainFrame
BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
BtnPlata.Position = UDim2.new(0.065, 0, 0.299, 0)
BtnPlata.Size = UDim2.new(0, 93, 0, 60)
BtnPlata.Font = Enum.Font.SourceSansBold
BtnPlata.Text = "Generador de plata"
BtnPlata.TextColor3 = Color3.fromRGB(5, 2, 18)
BtnPlata.TextScaled = true
Instance.new("UICorner", BtnPlata)

-- Botón Anti-Perder Plata
local BtnPick = Instance.new("TextButton")
BtnPick.Parent = MainFrame
BtnPick.BackgroundColor3 = Color3.fromRGB(180, 189, 13)
BtnPick.Position = UDim2.new(0.673, 0, 0.299, 0)
BtnPick.Size = UDim2.new(0, 93, 0, 60)
BtnPick.Font = Enum.Font.SourceSansBold
BtnPick.Text = "Anti-perder plata + agarrar"
BtnPick.TextColor3 = Color3.fromRGB(5, 2, 18)
BtnPick.TextScaled = true
Instance.new("UICorner", BtnPick)

-- ==========================================
-- LÓGICA DE LAS FUNCIONES
-- ==========================================

-- Función auxiliar para forzar clics ignorando interfaces bloqueadas (Shield/MenuMessageGui)
local function forceClick(button)
    if getconnections then
        for _, conn in ipairs(getconnections(button.MouseButton1Click)) do
            conn:Fire()
        end
    elseif firesignal then
        firesignal(button.MouseButton1Click)
    end
end

-- Función auxiliar para teletransportarse y activar un prompt
local function teleportAndInteract(folderPath)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not folderPath then return end

    for _, location in ipairs(folderPath:GetChildren()) do
        local prompt = location:FindFirstChildOfClass("ProximityPrompt") or location:FindFirstChild("ProximityPrompt", true)
        if prompt and prompt.Enabled then
            -- Teletransportarse justo encima del objetivo
            root.CFrame = location.CFrame + Vector3.new(0, 3, 0)
            
            -- Esperar a que el servidor registre nuestra posición física
            task.wait(0.6) 
            
            -- Disparar el prompt
            fireproximityprompt(prompt)
            task.wait(0.5)
        end
    end
end

getgenv().farmPlata = false

-- 1. Función: Generador de Plata (RepartosYa) Mejorado
BtnPlata.MouseButton1Click:Connect(function()
    getgenv().farmPlata = not getgenv().farmPlata
    if getgenv().farmPlata then
        BtnPlata.Text = "Generando..."
        BtnPlata.BackgroundColor3 = Color3.fromRGB(80, 180, 40)
        
        task.spawn(function()
            while getgenv().farmPlata do
                task.wait(1)
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if not phoneGui then continue end

                local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                if not appFrame then continue end

                -- PASO A: Click en el botón de recargar/buscar pedidos
                local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                if searchBtn then
                    forceClick(searchBtn)
                    task.wait(0.5) -- Esperar a que carguen los "Order_XXXX"
                end

                -- PASO B: Buscar y aceptar un pedido disponible
                local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                if ordersList then
                    for _, orderFrame in ipairs(ordersList:GetChildren()) do
                        -- Identificar frames que empiecen con "Order_" según los logs
                        if orderFrame:IsA("Frame") and string.sub(orderFrame.Name, 1, 6) == "Order_" then
                            local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                            if acceptBtn then
                                forceClick(acceptBtn)
                                task.wait(0.5)
                                break -- Salir del loop tras aceptar uno para ir a entregarlo
                            end
                        end
                    end
                end

                task.wait(1)
                
                local jobsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs") and workspace.Map.Jobs:FindFirstChild("RepartosYA")
                if jobsFolder then
                    -- PASO C: Teletransportarse y Recoger (La esquina - Rotiseria, etc.)
                    teleportAndInteract(jobsFolder:FindFirstChild("restaurantLocations"))
                    
                    task.wait(1)
                    
                    -- PASO D: Teletransportarse y Entregar (Las coimas, etc.)
                    teleportAndInteract(jobsFolder:FindFirstChild("deliveryLocations"))
                end
            end
        end)
    else
        BtnPlata.Text = "Generador de plata"
        BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
    end
end)

-- 2. Función: Anti-Perder Plata / Auto-Agarrar
BtnPick.MouseButton1Click:Connect(function()
    BtnPick.Text = "Activado"
    BtnPick.BackgroundColor3 = Color3.fromRGB(130, 140, 10)
    
    local function autoClaim(folder)
        if not folder then return end
        folder.ChildAdded:Connect(function(v)
            task.wait(0.1)
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
