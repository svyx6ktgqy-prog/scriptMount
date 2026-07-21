-- ==========================================
-- Mini chit Hood Argentino V19 (VECTOR WALK & UNLOCK) - iOS
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
ScreenGui.Name = "MiniChitHoodV19"
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
Title.Text = "Mini chit Hood Argentino (V19 Vectorial)"
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

-- Botón 1: Repartos Ya (Modo Movimiento Vectorial Natural)
local BtnPlata = Instance.new("TextButton", MainFrame)
BtnPlata.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
BtnPlata.BorderSizePixel = 0
BtnPlata.Position = UDim2.new(0.065, 0, 0.35, 0)
BtnPlata.Size = UDim2.new(0, 130, 0, 60)
BtnPlata.Font = Enum.Font.Unknown
BtnPlata.Text = "Repartos Ya (Vectorial)"
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
-- 2. FUNCIONES DE CLICS Y CONTROL VECTORIAL DE MOVIMIENTO
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

local function triggerMobilePromptSafe(prompt)
    pcall(function()
        fireproximityprompt(prompt, 0)
        fireproximityprompt(prompt, 1)
    end)
    pcall(function()
        local promptUI = LocalPlayer.PlayerGui:FindFirstChild("ProximityPrompts")
        if promptUI then
            local frame = promptUI:FindFirstChild("Prompt") and promptUI.Prompt:FindFirstChild("Frame")
            local btn = frame and frame:FindFirstChild("TextButton")
            if btn then forceClick(btn) end
        end
    end)
end

-- ==========================================
-- 3. BUCLE PRINCIPAL DE REPARTOS YA (V19 VECTORIAL)
-- ==========================================
getgenv().repartosActive = false

BtnPlata.MouseButton1Down:Connect(function()
    getgenv().repartosActive = not getgenv().repartosActive
    
    if getgenv().repartosActive then
        BtnPlata.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnPlata.Text = "Detener Vectorial"
        
        task.spawn(function()
            while getgenv().repartosActive do
                task.wait(0.2)
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
                local hrp = char.HumanoidRootPart
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                local mapJobs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs")
                local repartosFolder = mapJobs and mapJobs:FindFirstChild("RepartosYA")
                
                local taskExecuted = false

                if repartosFolder then
                    for _, descendant in ipairs(repartosFolder:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
                            taskExecuted = true
                            
                            local targetPos = nil
                            local parent = descendant.Parent
                            pcall(function()
                                if parent:IsA("BasePart") then
                                    targetPos = parent.Position
                                elseif parent:IsA("Model") then
                                    targetPos = parent:GetPivot().Position
                                else
                                    local p = parent:FindFirstChildWhichIsA("BasePart", true)
                                    if p then targetPos = p.Position end
                                end
                            end)

                            if targetPos and humanoid then
                                local tickCounter = 0
                                -- Bucle de aproximación mediante control de dirección vectorial
                                while (hrp.Position - targetPos).Magnitude > 6 and descendant.Enabled and getgenv().repartosActive do
                                    pcall(function()
                                        humanoid.WalkSpeed = 16
                                        -- Calculamos la dirección hacia el objetivo ignorando la altura para evitar bloqueos
                                        local direction = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit
                                        humanoid:Move(direction, false)
                                    end)
                                    
                                    tickCounter = tickCounter + 1
                                    -- Si se traba más de 2 segundos en el mismo rango, salta para destrabar físicas
                                    if tickCounter > 10 then
                                        pcall(function() humanoid.Jump = true end)
                                        tickCounter = 0
                                    end
                                    
                                    task.wait(0.1)
                                end
                                
                                -- Detener movimiento al llegar y activar el prompt
                                pcall(function() humanoid:Move(Vector3.new(0, 0, 0), false) end)
                                
                                local attempts = 0
                                while descendant.Enabled and attempts < 6 and getgenv().repartosActive do
                                    triggerMobilePromptSafe(descendant)
                                    task.wait(0.15)
                                    attempts = attempts + 1
                                end
                            end
                            break
                        end
                    end
                end

                -- Si no hay endpoints activos, automatizamos el celular para buscar pedidos
                if not taskExecuted then
                    local phoneGui = LocalPlayer.PlayerGui:FindFirstChild("Phone")
                    if phoneGui then
                        local appFrame = phoneGui:FindFirstChild("PhoneBorder") and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp")
                        if appFrame then
                            local searchBtn = appFrame:FindFirstChild("Head") and appFrame.Head:FindFirstChild("SearchOrders") and appFrame.Head.SearchOrders:FindFirstChild("btn")
                            if searchBtn then
                                forceClick(searchBtn)
                                task.wait(0.4)
                            end

                            local ordersList = appFrame:FindFirstChild("OrdersFrame") and appFrame.OrdersFrame:FindFirstChild("orders") and appFrame.OrdersFrame.orders:FindFirstChild("ScrollingFrame")
                            if ordersList then
                                for _, orderFrame in ipairs(ordersList:GetChildren()) do
                                    if orderFrame:IsA("Frame") and string.match(orderFrame.Name, "^Order_") then
                                        local acceptBtn = orderFrame:FindFirstChild("AcceptOrderBtn")
                                        if acceptBtn then
                                            forceClick(acceptBtn)
                                            task.wait(0.8)
                                            break
                                        end
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
        BtnPlata.Text = "Repartos Ya (Vectorial)"
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
                for _, v in ipairs(cFilter.CuerposMuertos:GetChildren()) do setupClaim(v) end
            end
        end
    end)
    BtnPick.Text = "¡Auto-Agarrar Activado!"
    BtnPick.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
end)
