-- ==========================================
-- Mini chit Hood Argentino V7 (FIX TOTAL) - iOS
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ==========================================
-- 1. INTERFAZ TÁCTIL (ESTILO ANTIGUO ADAPTADO A DELTA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MiniChitHoodV7"
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
Title.Text = "Mini chit Hood Argentino (V7 Fix)"
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

-- Botón 1: Generador de plata / Repartos Ya Automático
local BtnPlata = Instance.new("TextButton", MainFrame)
BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
BtnPlata.BorderSizePixel = 0
BtnPlata.Position = UDim2.new(0.065, 0, 0.35, 0)
BtnPlata.Size = UDim2.new(0, 130, 0, 60)
BtnPlata.Font = Enum.Font.Unknown
BtnPlata.Text = "Generador de Repartos (Auto)"
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
-- 2. LÓGICA DE REPARTOS YA (MOTOR RESTAURADO)
-- ==========================================
getgenv().repartosActive = false

BtnPlata.MouseButton1Down:Connect(function()
    getgenv().repartosActive = not getgenv().repartosActive
    
    if getgenv().repartosActive then
        BtnPlata.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnPlata.Text = "Detener Repartos"
        
        task.spawn(function()
            -- Paso inicial: Teletransporte al NPC de RepartosYa para iniciar el trabajo si no está activo
            pcall(function()
                local npcTrigger = workspace:FindFirstChild("map") and workspace.map.map_jobs.pedidosYaJOB.pedidosYaNPC.Trigger
                if not npcTrigger then
                    -- Intento con la ruta alternativa de workspace.Map si la estructura varía
                    npcTrigger = workspace.Map.Jobs.RepartosYA.pedidosYaNPC.Trigger
                end
                
                if npcTrigger and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local oldPos = hrp.Position
                    hrp.CFrame = npcTrigger.CFrame
                    task.wait(0.5)
                    if npcTrigger:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(npcTrigger.ProximityPrompt)
                    end
                    task.wait(0.5)
                    hrp.CFrame = CFrame.new(oldPos)
                end
            end)

            -- Bucle principal del trabajo utilizando los eventos nativos del juego
            while getgenv().repartosActive do
                task.wait(0.5)
                pcall(function()
                    local playerGui = LocalPlayer.PlayerGui
                    local pedidosGui = playerGui:FindFirstChild("pedidosYaGUI")
                    
                    if pedidosGui then
                        -- 1. Aceptar pedido automáticamente si está disponible el botón
                        local acceptBtn = pedidosGui:FindFirstChild("screenFrame") and pedidosGui.screenFrame:FindFirstChild("acceptButton")
                        if acceptBtn and acceptBtn.Visible then
                            if firesignal then
                                firesignal(acceptBtn.MouseButton1Click)
                            else
                                acceptBtn.MouseButton1Click:Fire()
                            end
                            task.wait(1)
                        end
                        
                        -- 2. Conectar de forma directa con los eventos del ReplicatedStorage que usaba tu script viejo
                        local events = ReplicatedStorage:FindFirstChild("Events")
                        local pedidosEvent = events and events:FindFirstChild("pedidosya")
                        
                        if pedidosEvent then
                            -- Si hay restaurante asignado, forzar recogida mediante RemoteEvent
                            if pedidosGui:FindFirstChild("restaurantLocation") and pedidosGui.restaurantLocation.Value then
                                local restVal = pedidosGui.restaurantLocation.Value
                                if typeof(restVal) == "Instance" then
                                    pedidosEvent:WaitForChild("attemptPickup"):FireServer(restVal)
                                    -- Teletransporte de seguridad hacia el restaurante
                                    if restVal:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = restVal.CFrame + Vector3.new(0, 3, 0)
                                    elseif restVal:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = restVal:GetPivot() + Vector3.new(0, 3, 0)
                                    end
                                end
                            end
                            
                            -- Si hay entrega asignada, forzar entrega mediante RemoteEvent y teletransporte al endpoint
                            if pedidosGui:FindFirstChild("deliveryLocation") and pedidosGui.deliveryLocation.Value then
                                local delivVal = pedidosGui.deliveryLocation.Value
                                if typeof(delivVal) == "Instance" then
                                    pedidosEvent:WaitForChild("attemptDelivery"):FireServer(delivVal)
                                    -- Teletransporte de seguridad directo al endpoint de entrega
                                    if delivVal:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = delivVal.CFrame + Vector3.new(0, 3, 0)
                                    elseif delivVal:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = delivVal:GetPivot() + Vector3.new(0, 3, 0)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
        BtnPlata.Text = "Generador de Repartos (Auto)"
    end
end)

-- ==========================================
-- 3. RECOLECTOR AUTOMÁTICO DE DINERO
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
