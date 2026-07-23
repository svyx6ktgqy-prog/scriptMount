-- ==========================================
-- Mini chit Hood Argentino V8 (RAYFIELD EDITION)
-- ==========================================

-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "ALB8RAAQ",
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
-- 3. APARTADO: COMBATE Y SIGILO + ESP INTEGRADO
-- ==========================================
local StealthTab = Window:CreateTab("Combate & Sigilo", 10057404170)

local flyConn = nil
local espConn = nil
local stealthGui = nil
local camera = workspace.CurrentCamera
local espFolder = nil

local function clearESP()
    if espFolder then
        espFolder:Destroy()
        espFolder = nil
    end
end

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    
    local function applyVisuals(char)
        if not espFolder then return end
        if char:FindFirstChild("StealthESP_Highlight") or char:FindFirstChild("StealthESP_Billboard") then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "StealthESP_Highlight"
        highlight.FillColor = Color3.fromRGB(170, 0, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "StealthESP_Billboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 13
        
        billboard.Parent = char
        
        task.spawn(function()
            while char and char.Parent and espFolder and billboard and textLabel do
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local targetHrp = char:FindFirstChild("HumanoidRootPart")
                
                if myHrp and targetHrp then
                    local distanceStuds = (myHrp.Position - targetHrp.Position).Magnitude
                    local distanceMeters = math.floor(distanceStuds / 3.57)
                    textLabel.Text = string.format("%s\n[%d m]", player.Name, distanceMeters)
                else
                    textLabel.Text = player.Name
                end
                task.wait(0.1)
            end
        end)
    end
    
    if player.Character then applyVisuals(player.Character) end
    player.CharacterAdded:Connect(applyVisuals)
end

-- Configuración del Spinner de Personajes
local NombresPersonajes = {
    "Reaper",
    "OnlyJdottt888",
    "Anime",
    "Pet-Skyler",
    "Tattoo",
    "Necklace",
    "HellxCult",
    "NecroL",
    "Ninjaco99",
    "GasMask",
    "Assasin",
    "JeffKill",
    "Alien",
    "Galaxy",
    "Guest 666",
    "Ninja",
    "Emo-no-head",
    "3luc1dator",
    "deathcore",
    "zzzz",
    "mark",
    "arabic",
    "ultra-DARK",
    "angelBlack"
}

local IDsPersonajes = {
    ["Reaper"] = "89659421394995",
    ["OnlyJdottt888"] = "16694425947",
    ["Anime"] = "12620017502",
    ["Pet-Skyler"] = "16305734736",
    ["Tattoo"] = "2471099435",
    ["Necklace"] = "10253040",
    ["HellxCult"] = "6231360322",
    ["NecroL"] = "5077070408",
    ["Ninjaco99"] = "55605200",
    ["GasMask"] = "9416404023",
    ["Assasin"] = "117968424",
    ["JeffKill"] = "130976341611830",
    ["Alien"] = "11839952466",
    ["Galaxy"] = "119402454246397",
    ["Guest 666"] = "100522151681725",
    ["Ninja"] = "13372374109",
    ["Emo-no-head"] = "138953153245508",   -- Reemplazar con ID real en producción
    ["3luc1dator"] = "13488199451", -- Reemplazar con ID real en producción
    ["deathcore"] = "123474825340087",     -- Reemplazar con ID real en producción
    ["zzzz"] = "15483662986",  
    ["mark"] = "15273480838",
    ["arabic"] = "115260634647279",
    ["ultra-DARK"] = "113805405663467",
    ["angelBlack"] = "979928372"
}

local PersonajeSeleccionadoID = IDsPersonajes["Reaper"]

local CharacterSpinner = StealthTab:CreateDropdown({
    Name = "Seleccionar Personaje de Sigilo",
    Options = NombresPersonajes,
    CurrentOption = {"Reaper"},
    MultipleOptions = false,
    Flag = "DropdownPersonajes",
    Callback = function(Options)
        local seleccion = Options[1]
        PersonajeSeleccionadoID = IDsPersonajes[seleccion]
    end,
})

local StealthToggle = StealthTab:CreateToggle({
    Name = "Modo Silencioso Avanzado (Cauteloso)",
    CurrentValue = false,
    Flag = "StealthModeToggle",
    Callback = function(Value)
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if Value then
            -- 1. CAMBIAR APARIENCIA COMPLETA (Transformación Natural Anti-Ban)
            if char and humanoid then
                pcall(function()
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("Hat") then
                            v:Destroy()
                        end
                    end
                    
                    -- Se llama dinámicamente al ID del personaje seleccionado
                    local model = game:GetObjects("rbxassetid://" .. PersonajeSeleccionadoID)[1]
                    if model then
                        for _, item in ipairs(model:GetChildren()) do
                            if item:IsA("Accessory") or item:IsA("Hat") then
                                local acc = item:Clone()
                                local handle = acc:FindFirstChild("Handle")
                                local head = char:FindFirstChild("Head")
                                
                                if handle and head then
                                    handle.CanCollide = false
                                    handle.Massless = true
                                    
                                    -- 1. Alinear el objeto antes de soldar
                                    local att = handle:FindFirstChildOfClass("Attachment")
                                    local headAtt = att and head:FindFirstChild(att.Name)
                                    
                                    if att and headAtt then
                                        handle.CFrame = head.CFrame * headAtt.CFrame * att.CFrame:Inverse()
                                    else
                                        handle.CFrame = head.CFrame
                                    end
                                    
                                    -- 2. Emparentar al personaje
                                    acc.Parent = char
                                    
                                    -- 3. Soldar DESPUÉS de alinear.
                                    local weld = Instance.new("WeldConstraint")
                                    weld.Part0 = head
                                    weld.Part1 = handle
                                    weld.Parent = handle
                                end
                            elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") or item:IsA("CharacterMesh") then
                                item:Clone().Parent = char
                            elseif item.Name == "Head" and item:IsA("BasePart") then
                                local myHead = char:FindFirstChild("Head")
                                if myHead then
                                    for _, sub in ipairs(item:GetChildren()) do
                                        if sub:IsA("Decal") or sub:IsA("SpecialMesh") or sub:IsA("Mesh") then
                                            for _, mySub in ipairs(myHead:GetChildren()) do
                                                if mySub.ClassName == sub.ClassName then mySub:Destroy() end
                                            end
                                            sub:Clone().Parent = myHead
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            
            -- 2. ACTIVAR SISTEMA VISUAL ESP
            espFolder = Instance.new("Folder")
            espFolder.Name = "StealthESP_Folder"
            espFolder.Parent = workspace
            
            for _, player in ipairs(Players:GetPlayers()) do
                createPlayerESP(player)
            end
            espConn = Players.PlayerAdded:Connect(createPlayerESP)
            
            -- 3. GUI DE ALERTA SANGRE LATENTE Y BOTÓN FLOTANTE
            stealthGui = Instance.new("ScreenGui")
            stealthGui.Name = "SilentAlertGui"
            stealthGui.IgnoreGuiInset = true
            
            local coreGui = game:GetService("CoreGui")
            stealthGui.Parent = pcall(function() return coreGui.Name end) and coreGui or LocalPlayer.PlayerGui
            
            local alertLabel = Instance.new("TextLabel")
            alertLabel.Parent = stealthGui
            alertLabel.BackgroundTransparency = 1
            alertLabel.Position = UDim2.new(0.5, 0, 0.15, 0)
            alertLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            alertLabel.Size = UDim2.new(0, 300, 0, 40)
            alertLabel.Font = Enum.Font.GothamBold
            alertLabel.Text = "!Modo Sigilo: ESP Activo!"
            alertLabel.TextColor3 = Color3.fromRGB(170, 0, 0)
            alertLabel.TextSize = 16
            alertLabel.TextStrokeTransparency = 0
            alertLabel.TextStrokeColor3 = Color3.fromRGB(20, 0, 0)
            
            local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local tween = TweenService:Create(alertLabel, tweenInfo, {
                TextTransparency = 0.8, 
                TextStrokeTransparency = 0.8
            })
            tween:Play()

            -- Botón Flotante Seguro para Muros (MANTENER PRESIONADO)
            local tpButton = Instance.new("TextButton")
            tpButton.Name = "WallTPButton"
            tpButton.Parent = stealthGui
            tpButton.Size = UDim2.new(0, 160, 0, 50)
            tpButton.Position = UDim2.new(0.85, 0, 0.6, 0)
            tpButton.AnchorPoint = Vector2.new(0.5, 0.5)
            tpButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            tpButton.BorderColor3 = Color3.fromRGB(170, 0, 0)
            tpButton.BorderSizePixel = 2
            tpButton.TextColor3 = Color3.fromRGB(255, 50, 50)
            tpButton.Font = Enum.Font.GothamBold
            tpButton.TextSize = 14
            tpButton.Text = "Mantener para\nTraspasar (Sigilo)"
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = tpButton

            -- LÓGICA DE MANTENER PRESIONADO (NUEVO SISTEMA MÓVIL/PC SEGURO)
            local isHolding = false

            local function startNoclip()
                if isHolding then return end
                isHolding = true
                tpButton.BackgroundColor3 = Color3.fromRGB(70, 0, 0) 
                
                local controlModule = nil
                pcall(function()
                    local playerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                    if playerModule then
                        controlModule = require(playerModule:FindFirstChild("ControlModule"))
                    end
                end)

                flyConn = RunService.RenderStepped:Connect(function()
                    local currentChar = LocalPlayer.Character
                    local hrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                    local hum = currentChar and currentChar:FindFirstChild("Humanoid")
                    
                    if hrp and hum and hum.Health > 0 then
                        for _, part in ipairs(currentChar:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        
                        local moveDir = Vector3.new(0, 0, 0)
                        
                        if controlModule then
                            local rawVector = controlModule:GetMoveVector()
                            moveDir = (camera.CFrame.LookVector * -rawVector.Z) + (camera.CFrame.RightVector * rawVector.X)
                        end
                        
                        if moveDir.Magnitude == 0 then
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                        end
                        
                        if moveDir.Magnitude > 0 then
                            local moveUnit = moveDir.Unit
                            local nuevaPosicion = hrp.Position + (moveUnit * 0.35)
                            local orientacionVisual = Vector3.new(moveUnit.X, 0, moveUnit.Z)
                            
                            if orientacionVisual.Magnitude > 0.001 then
                                hrp.CFrame = CFrame.lookAt(nuevaPosicion, nuevaPosicion + orientacionVisual.Unit)
                            else
                                hrp.CFrame = CFrame.new(nuevaPosicion) * hrp.CFrame.Rotation
                            end
                        end
                    end
                end)
            end

            local function stopNoclip()
                if not isHolding then return end
                isHolding = false
                tpButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) 
                
                if flyConn then
                    flyConn:Disconnect()
                    flyConn = nil
                end

                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum.AutoRotate = true end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local head = char:FindFirstChild("Head")
                    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    
                    if hrp then hrp.CanCollide = true end
                    if head then head.CanCollide = true end
                    if torso then torso.CanCollide = true end
                end
            end

            tpButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    startNoclip()
                end
            end)

            tpButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    stopNoclip()
                end
            end)
            
        else
            -- ==========================================
            -- APAGADO Y RESTAURACIÓN ABSOLUTA
            -- ==========================================
            if flyConn then
                flyConn:Disconnect()
                flyConn = nil
            end
            
            if humanoid then
                humanoid.AutoRotate = true
            end
            
            if espConn then
                espConn:Disconnect()
                espConn = nil
            end
            clearESP()
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("StealthESP_Highlight")
                    local bb = p.Character:FindFirstChild("StealthESP_Billboard")
                    if hl then hl:Destroy() end
                    if bb then bb:Destroy() end
                end
            end
            
            if humanoid then
                pcall(function()
                    local realDesc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                    humanoid:ApplyDescription(realDesc)
                end)
            end
            
            if stealthGui then
                stealthGui:Destroy()
                stealthGui = nil
            end
        end
    end,
})
