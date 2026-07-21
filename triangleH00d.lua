-- ==========================================
-- Mini chit Hood Argentino - Adaptado para Móvil
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
Title.Text = "Mini chit Hood Argentino"
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

-- Botón Generador de Plata (Actualizado)
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

-- Botón Anti-Perder Plata (Actualizado)
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

-- Variables de Estado
getgenv().farmPlata = false

-- 1. Función: Generador de Plata (RepartosYa)
BtnPlata.MouseButton1Click:Connect(function()
    getgenv().farmPlata = not getgenv().farmPlata
    if getgenv().farmPlata then
        BtnPlata.Text = "Generando..."
        task.spawn(function()
            while getgenv().farmPlata do
                task.wait(0.5)
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end

                -- Aceptar orden en la app RepartosYa
                local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                if phoneGui then
                    local ordersFrame = phoneGui:FindFirstChild("PhoneBorder") 
                        and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp") 
                        and phoneGui.PhoneBorder.RepartosYaApp:FindFirstChild("OrdersFrame")
                        and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame:FindFirstChild("orders")
                        and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                        
                    if ordersFrame then
                        for _, order in ipairs(ordersFrame:GetChildren()) do
                            if order:IsA("Frame") and order:FindFirstChild("AcceptOrderBtn") then
                                if getconnections then
                                    for _, conn in ipairs(getconnections(order.AcceptOrderBtn.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                elseif firesignal then
                                    firesignal(order.AcceptOrderBtn.MouseButton1Click)
                                end
                            end
                        end
                    end
                end

                task.wait(1)
                
                -- Teletransportarse y Recoger Pedido (restaurantLocations)
                local jobsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs") and workspace.Map.Jobs:FindFirstChild("RepartosYA")
                if jobsFolder and jobsFolder:FindFirstChild("restaurantLocations") then
                    for _, rest in ipairs(jobsFolder.restaurantLocations:GetChildren()) do
                        local prompt = rest:FindFirstChild("ProximityPrompt")
                        if prompt and prompt.Enabled then
                            root.CFrame = rest.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            fireproximityprompt(prompt)
                        end
                    end
                end
                
                task.wait(1)
                
                -- Teletransportarse y Entregar Pedido (deliveryLocations)
                if jobsFolder and jobsFolder:FindFirstChild("deliveryLocations") then
                    for _, dev in ipairs(jobsFolder.deliveryLocations:GetChildren()) do
                        local prompt = dev:FindFirstChild("ProximityPrompt")
                        if prompt and prompt.Enabled then
                            root.CFrame = dev.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end)
    else
        BtnPlata.Text = "Generador de plata"
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
        -- Agarrar el dinero que ya esté tirado
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
