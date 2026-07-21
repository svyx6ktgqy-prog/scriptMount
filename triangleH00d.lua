-- ==========================================
-- Mini chit Hood Argentino V8 (RAYFIELD EDITION)
-- ==========================================

-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Mini chit Hood Argentino (V8 Pro)",
    LoadingTitle = "Cargando Script...",
    LoadingSubtitle = "por Mini chit",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "MiniChitHub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ==========================================
-- 1. FUNCIONES DE UTILIDAD
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
-- 2. PESTAÑA: FARMING
-- ==========================================
local MainTab = Window:CreateTab("Farming", 4483362458) 

getgenv().repartosActive = false

local RepartosToggle = MainTab:CreateToggle({
    Name = "Repartos Ya (Auto GPS + Celular)",
    CurrentValue = false,
    Flag = "ToggleRepartos", 
    Callback = function(Value)
        getgenv().repartosActive = Value
        
        if getgenv().repartosActive then
            task.spawn(function()
                while getgenv().repartosActive do
                    task.wait(1)
                    
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

                    local mapJobs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jobs")
                    local repartosFolder = mapJobs and mapJobs:FindFirstChild("RepartosYA")
                    if not repartosFolder then continue end

                    -- PASO 1: Entregar
                    local deliveryFolder = repartosFolder:FindFirstChild("deliveryLocations")
                    local handledDelivery = false
                    if deliveryFolder then
                        for _, loc in ipairs(deliveryFolder:GetChildren()) do
                            local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                handledDelivery = true
                                local targetPart = (prompt.Parent and prompt.Parent:IsA("BasePart")) and prompt.Parent or loc
                                robustTeleport(targetPart)
                                
                                local intentos = 0
                                while prompt.Enabled and intentos < 6 and getgenv().repartosActive do
                                    forceMobilePrompt(prompt)
                                    task.wait(0.3)
                                    intentos = intentos + 1
                                end
                                break
                            end
                        end
                    end
                    if handledDelivery then continue end

                    -- PASO 2: Recoger
                    local restFolder = repartosFolder:FindFirstChild("restaurantLocations")
                    local handledRest = false
                    if restFolder then
                        for _, loc in ipairs(restFolder:GetChildren()) do
                            local prompt = loc:FindFirstChildOfClass("ProximityPrompt") or loc:FindFirstChild("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                handledRest = true
                                local targetPart = (prompt.Parent and prompt.Parent:IsA("BasePart")) and prompt.Parent or loc
                                robustTeleport(targetPart)
                                
                                local intentos = 0
                                while prompt.Enabled and intentos < 6 and getgenv().repartosActive do
                                    forceMobilePrompt(prompt)
                                    task.wait(0.3)
                                    intentos = intentos + 1
                                end
                                break
                            end
                        end
                    end
                    if handledRest then continue end

                    -- PASO 3: Aceptar pedido
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
                                            task.wait(1.5)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})

local PickButton = MainTab:CreateButton({
    Name = "Activar Anti-perder plata + Agarrar auto",
    Callback = function()
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
        
        Rayfield:Notify({
            Title = "Activado",
            Content = "El recolector automático de dinero ya está funcionando.",
            Duration = 5,
            Image = 4483362458,
        })
    end,
})

-- ==========================================
-- 3. NUEVO APARTADO: COMBATE Y SIGILO
-- ==========================================
local StealthTab = Window:CreateTab("Combate & Sigilo", 10057404170)

-- Variables de Estado
local flyConn = nil
local stealthGui = nil
local camera = workspace.CurrentCamera

local StealthToggle = StealthTab:CreateToggle({
    Name = "Modo Silencioso Avanzado (Cauteloso)",
    CurrentValue = false,
    Flag = "StealthModeToggle",
    Callback = function(Value)
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if Value then
            -- 1. APLICAR AVATAR SIN ALERTAR ANTI-CHEAT
            if char then
                pcall(function()
                    -- Limpiar accesorios y ropa actual
                    for _, v in ipairs(char:GetChildren()) do
                        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
                            v:Destroy()
                        end
                    end
                    
                    -- Obtener el modelo del Ninja directamente de los servidores y robar su ropa
                    local model = game:GetObjects("rbxassetid://13372374109")[1]
                    if model then
                        for _, item in ipairs(model:GetChildren()) do
                            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") then
                                item:Clone().Parent = char
                            end
                        end
                    end
                end)
            end
            
            -- 2. ACTIVAR FLY Y NOCLIP CAUTELOSO (Evita bans por velocidad)
            flyConn = RunService.RenderStepped:Connect(function()
                local currentChar = LocalPlayer.Character
                local hrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                local hum = currentChar and currentChar:FindFirstChild("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    -- Noclip: Desactivar colisiones
                    for _, part in ipairs(currentChar:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- Anti-Ban: Forzar velocidad a 0 para que el servidor no detecte que estás volando
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    
                    -- Movimiento estilo Fly basado en CFrame (Indetectable para muchos anti-cheats)
                    local moveDir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                    
                    if moveDir.Magnitude > 0 then
                        -- Velocidad cautelosa (0.35 studs por frame equivale aprox a la velocidad normal de caminar)
                        hrp.CFrame = hrp.CFrame + (moveDir.Unit * 0.35)
                    end
                end
            end)
            
            -- 3. CREAR GUI DE ALERTA SANGRE
            stealthGui = Instance.new("ScreenGui")
            stealthGui.Name = "SilentAlertGui"
            stealthGui.IgnoreGuiInset = true
            
            local coreGui = game:GetService("CoreGui")
            stealthGui.Parent = pcall(function() return coreGui.Name end) and coreGui or LocalPlayer.PlayerGui
            
            local alertLabel = Instance.new("TextLabel")
            alertLabel.Parent = stealthGui
            alertLabel.BackgroundTransparency = 1
            alertLabel.Position = UDim2.new(0.5, 0, 0.15, 0) -- Centrado y pequeño
            alertLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            alertLabel.Size = UDim2.new(0, 300, 0, 40)
            alertLabel.Font = Enum.Font.GothamBold
            alertLabel.Text = "!Atravesar paredes de forma silenciosa!"
            alertLabel.TextColor3 = Color3.fromRGB(170, 0, 0) -- Rojo sangre
            alertLabel.TextSize = 16
            alertLabel.TextStrokeTransparency = 0
            alertLabel.TextStrokeColor3 = Color3.fromRGB(20, 0, 0)
            
            -- Animación latente
            local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local tween = TweenService:Create(alertLabel, tweenInfo, {
                TextTransparency = 0.8, 
                TextStrokeTransparency = 0.8
            })
            tween:Play()
            
        else
            -- ==========================
            -- DESACTIVAR MODO SILENCIOSO
            -- ==========================
            
            -- Desconectar Fly / Noclip
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end
            
            -- Restaurar el avatar base del jugador usando su UserID real
            if humanoid then
                pcall(function()
                    local realDesc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                    humanoid:ApplyDescription(realDesc)
                end)
            end
            
            -- Eliminar GUI
            if stealthGui then
                stealthGui:Destroy()
                stealthGui = nil
            end
        end
    end,
})
