-- ==========================================
-- Mini chit Hood Argentino V8 (RAYFIELD EDITION)
-- + INTEGRACIONES EN INGLÉS (SCREEN FIX & BOOMBOX)
-- + BALACLAVA MASK & RAINBOW RADIO
-- + FIX ANTI-CONGELAMIENTO DE JOYSTICK
-- + COLA RADIACTIVA (AUDIO VISUALIZER) INTEGRADA A LA RADIO
-- + AURA SIGMA & ARMA MILITAR
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
local StarterGui = game:GetService("StarterGui")

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

local NombresPersonajes = {
    "Tr$xsh", "Alien", "Everlasting", "TrashGang", "Goat", "Monster", "Reaper", "OnlyJdottt888", "SpyEffect", "DemonSuite",
    "BearBlack", "KingV1", "KingV2", "Ninjaco80", "CJ", "MeKing",
    "JasonX", "PandiMan", "AppleJuice", "Tr$xshV2", "SuiteWhiteFF",
    "Otaku", "Halloween", "Zombie", "Blood", "HalloweenV4", "Anime",
    "Pet-Skyler", "Tattoo", "Necklace", "HellxCult", "Pepperm3n",
    "BattleCAT", "Yamal-Lamine", "NecroL", "Ninjaco99", "GasMask",
    "Assasin", "JeffKill", "Galaxy", "Guest 666", "Ninja",
    "Emo-no-head", "3luc1dator", "deathcore", "zzzz", "mark",
    "arabic", "ultra-DARK", "angelBlack"
}

local IDsPersonajes = {
    ["Tr$xsh"] = "12543836003", ["Alien"] = "11839952466", ["Everlasting"] = "95946418542389", ["TrashGang"] = "5339731779", ["Goat"] = "2415658611", ["Monster"] = "906155708", ["Reaper"] = "89659421394995", ["OnlyJdottt888"] = "16694425947",
    ["SpyEffect"] = "2614544836", ["DemonSuite"] = "14288252360", ["BearBlack"] = "10059678189",
    ["KingV1"] = "1502622602", ["KingV2"] = "10332438725", ["Ninjaco80"] = "10926342089",
    ["CJ"] = "110223007877573", ["MeKing"] = "49618066", ["JasonX"] = "17462621551",
    ["PandiMan"] = "2482936370", ["AppleJuice"] = "5231922649", ["Tr$xshV2"] = "17357198199",
    ["SuiteWhiteFF"] = "149649724", ["Otaku"] = "10066776256", ["Halloween"] = "14943840836",
    ["Zombie"] = "90944268", ["Blood"] = "181798652", ["HalloweenV4"] = "12533875804",
    ["Anime"] = "12620017502", ["Pet-Skyler"] = "16305734736", ["Tattoo"] = "2471099435",
    ["Necklace"] = "10253040", ["HellxCult"] = "6231360322", ["Pepperm3n"] = "5219495877",
    ["BattleCAT"] = "108399584052276", ["Yamal-Lamine"] = "73762465274540", ["NecroL"] = "5077070408",
    ["Ninjaco99"] = "17397372642", ["GasMask"] = "9416404023", ["Assasin"] = "117968424",
    ["JeffKill"] = "130976341611830", ["Galaxy"] = "119402454246397",
    ["Guest 666"] = "100522151681725", ["Ninja"] = "13372374109", ["Emo-no-head"] = "138953153245508",
    ["3luc1dator"] = "13488199451", ["deathcore"] = "17258275053", ["zzzz"] = "15483662986",  
    ["mark"] = "15273480838", ["arabic"] = "115260634647279", ["ultra-DARK"] = "113805405663467",
    ["angelBlack"] = "979928372"
}

local PersonajeSeleccionadoID = IDsPersonajes["Tr$xsh"]

local CharacterSpinner = StealthTab:CreateDropdown({
    Name = "Seleccionar Personaje de Sigilo",
    Options = NombresPersonajes,
    CurrentOption = {"Tr$xsh"},
    MultipleOptions = false,
    Flag = "DropdownPersonajes",
    Callback = function(Options)
        local seleccion = Options[1]
        PersonajeSeleccionadoID = IDsPersonajes[seleccion]
    end,
})

-- ==========================================
-- SWITCH MÁSCARA BALACLAVA 
-- ==========================================
StealthTab:CreateToggle({
    Name = "Equipar Máscara Balaclava (#MASK)",
    CurrentValue = false,
    Flag = "BalaclavaToggle",
    Callback = function(Value)
        local char = LocalPlayer.Character
        if not char then return end
        
        if Value then
            pcall(function()
                local maskModel = game:GetObjects("rbxassetid://13604588959")[1]
                if maskModel then
                    local accessory = maskModel:IsA("Accessory") and maskModel or maskModel:FindFirstChildOfClass("Accessory")
                    if accessory then
                        local accClone = accessory:Clone()
                        accClone.Name = "BalaclavaMask"
                        
                        for _, v in ipairs(accClone:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Anchored = false
                                v.CanCollide = false
                                v.Massless = true
                            end
                        end
                        
                        local head = char:FindFirstChild("Head")
                        if head then
                            for _, v in ipairs(head:GetChildren()) do
                                if v:IsA("Decal") then v.Transparency = 1 end
                            end
                            
                            accClone.Parent = char
                            
                            local handle = accClone:FindFirstChild("Handle")
                            if handle then
                                local att = handle:FindFirstChildOfClass("Attachment")
                                local targetAtt = att and head:FindFirstChild(att.Name)
                                
                                if att and targetAtt then
                                    handle.CFrame = head.CFrame * targetAtt.CFrame * att.CFrame:Inverse()
                                else
                                    handle.CFrame = head.CFrame
                                end
                                
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = head
                                weld.Part1 = handle
                                weld.Parent = handle
                            else
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then hum:AddAccessory(accClone) end
                            end
                        end
                    end
                end
            end)
            Rayfield:Notify({Title = "Balaclava", Content = "Máscara equipada y soldada a la cabeza.", Duration = 3})
        else
            local mask = char:FindFirstChild("BalaclavaMask")
            if mask then mask:Destroy() end
            
            local head = char:FindFirstChild("Head")
            if head then
                for _, v in ipairs(head:GetChildren()) do
                    if v:IsA("Decal") then v.Transparency = 0 end
                end
            end
            Rayfield:Notify({Title = "Balaclava", Content = "Máscara removida.", Duration = 3})
        end
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
            if char and humanoid then
                pcall(function()
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("Hat") then
                            v:Destroy()
                        end
                    end
                    
                    local model = game:GetObjects("rbxassetid://" .. PersonajeSeleccionadoID)[1]
                    if model then
                        for _, item in ipairs(model:GetChildren()) do
                            if item:IsA("Accessory") or item:IsA("Hat") then
                                local acc = item:Clone()
                                
                                for _, v in ipairs(acc:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        v.Anchored = false
                                        v.CanCollide = false
                                        v.Massless = true
                                    end
                                end

                                local handle = acc:FindFirstChild("Handle")
                                if handle then
                                    handle.Anchored = false 
                                    handle.CanCollide = false
                                    handle.Massless = true
                                    
                                    local att = handle:FindFirstChildOfClass("Attachment")
                                    local targetBodyPart = char:FindFirstChild("Head") 
                                    local targetAtt = nil
                                    
                                    if att then
                                        for _, part in ipairs(char:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                local foundAtt = part:FindFirstChild(att.Name)
                                                if foundAtt and foundAtt:IsA("Attachment") then
                                                    targetBodyPart = part 
                                                    targetAtt = foundAtt
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    
                                    if targetBodyPart then
                                        if att and targetAtt then
                                            handle.CFrame = targetBodyPart.CFrame * targetAtt.CFrame * att.CFrame:Inverse()
                                        else
                                            handle.CFrame = targetBodyPart.CFrame
                                        end
                                        
                                        acc.Parent = char
                                        local weld = Instance.new("WeldConstraint")
                                        weld.Part0 = targetBodyPart
                                        weld.Part1 = handle
                                        weld.Parent = handle
                                    end
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
            
            espFolder = Instance.new("Folder")
            espFolder.Name = "StealthESP_Folder"
            espFolder.Parent = workspace
            
            for _, player in ipairs(Players:GetPlayers()) do
                createPlayerESP(player)
            end
            espConn = Players.PlayerAdded:Connect(createPlayerESP)
            
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

-- ==========================================
-- AURA SIGMA INTEGRADA EN SIGILO
-- ==========================================
local auraId = "129667288853780"
local auraTag = "SigmaAura_Particle"

StealthTab:CreateToggle({
   Name = "Activar Aura Sigma",
   CurrentValue = false,
   Flag = "AuraToggle", 
   Callback = function(Value)
      local character = LocalPlayer.Character
      if not character or not character:FindFirstChild("HumanoidRootPart") then return end
      local rootPart = character.HumanoidRootPart

      if Value then
          local success, result = pcall(function() return game:GetObjects("rbxassetid://" .. auraId)[1] end)
          if success and result then
              for _, item in ipairs(result:GetDescendants()) do
                  if item:IsA("ParticleEmitter") or item:IsA("PointLight") or item:IsA("Fire") or item:IsA("Attachment") then
                      local clone = item:Clone()
                      clone:SetAttribute(auraTag, true)
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() 
              Rayfield:Notify({Title = "Aura", Content = "Partículas activadas.", Duration = 2})
          end
      else
          -- DESACTIVACIÓN LIMPIA
          for _, child in ipairs(rootPart:GetChildren()) do
              if child:GetAttribute(auraTag) then
                  child:Destroy()
              end
          end
          Rayfield:Notify({Title = "Aura", Content = "Partículas removidas.", Duration = 2})
      end
   end,
})

-- ==========================================
-- ARMA MILITAR INTEGRADA EN SIGILO (SIN LÁSER)
-- ==========================================
local weaponId = "86551486545687"
local weaponToolName = "ArmaMilitar_Equipable"
local loadedAnimTrack = nil
local originalElbowC0 = nil

local function crearArmaAjustada(objetosDescargados)
                                    -- ==========================================
        -- ==========================================
    -- ⚙️ PARÁMETROS CONFIGURABLES DEL ARMA ⚙️
    -- ==========================================
    local ESCALA = 1.25 -- Tamaño ideal
    
    -- Mover: Usaremos el CFrame de desplazamiento global para asegurar que se mueva al frente real.
    -- X = Izq/Der, Y = Arriba/Abajo, Z = Adelante/Atrás (Usa este valor para empujarla al frente)
    local OFFSET_POSICION = Vector3.new(0, 0.15, -0.5) 
    
    -- Rotar (Grados): Mantenemos la rotación exacta que ya logró la posición correcta de la mano
    local OFFSET_ROTACION = CFrame.Angles(math.rad(-75), math.rad(15), math.rad(0))
    -- ==========================================

    local newTool = Instance.new("Tool")
    newTool.Name = weaponToolName
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    local partes3D = {}
    for _, obj in ipairs(objetosDescargados) do
        if obj:IsA("BasePart") then table.insert(partes3D, obj) end
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(partes3D, desc) end
        end
    end
    
    if #partes3D == 0 then return nil end

    -- APLICAR ESCALA: Agrupamos en un modelo temporal para escalar perfecto sin romper piezas
    local tempModel = Instance.new("Model")
    for _, p in ipairs(partes3D) do
        p.Parent = tempModel
    end
    if ESCALA ~= 1.0 then
        tempModel:ScaleTo(ESCALA)
    end

    -- 1. Calcular el centro exacto del modelo 3D descargado (ya escalado)
    local posSum = Vector3.new()
    for _, p in ipairs(partes3D) do
        posSum = posSum + p.Position
    end
    local centerPos = posSum / #partes3D

    -- 2. Posicionar el Handle exactamente en el centro ANTES de crear los welds
    local masterHandle = Instance.new("Part")
    masterHandle.Name = "Handle"
    masterHandle.Size = Vector3.new(0.2, 0.2, 0.2)
    masterHandle.Transparency = 1
    masterHandle.CanCollide = false
    masterHandle.Anchored = false
    masterHandle.Massless = true
    masterHandle.CFrame = CFrame.new(centerPos)
    masterHandle.Parent = newTool

    -- 3. Soldar cada parte al Handle manteniendo su alineación real
    for _, parte in ipairs(partes3D) do
        for _, child in ipairs(parte:GetChildren()) do
            if child:IsA("JointInstance") or child:IsA("WeldConstraint") then child:Destroy() end
        end
        parte.Anchored = false
        parte.CanCollide = false
        parte.Massless = true
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = masterHandle
        weld.Part1 = parte
        weld.Parent = masterHandle
        parte.Parent = newTool
    end
    
    -- Destruimos el modelo temporal porque ya pasamos todo a la Tool
    tempModel:Destroy()

    -- AL EQUIPAR: Forzar alineación y aplicar los parámetros configurables
    newTool.Equipped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local manoDerecha = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        
        if manoDerecha then
            -- Borrar el RightGrip automático
            task.defer(function()
                local rightGrip = manoDerecha:FindFirstChild("RightGrip")
                if rightGrip then rightGrip:Destroy() end
            end)

            -- APLICAR LOS PARÁMETROS DE POSICIÓN Y ROTACIÓN AQUÍ
            masterHandle.CFrame = manoDerecha.CFrame * OFFSET_POSICION * OFFSET_ROTACION
            
            local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
            if oldGrip then oldGrip:Destroy() end
            
            local manualGrip = Instance.new("WeldConstraint")
            manualGrip.Name = "ManualGripAttachment"
            manualGrip.Part0 = manoDerecha
            manualGrip.Part1 = masterHandle
            manualGrip.Parent = masterHandle
        end

        -- Ajustar doblez del codo
        local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
        if elbowJoint and elbowJoint:IsA("Motor6D") then
            if not originalElbowC0 then originalElbowC0 = elbowJoint.C0 end
            elbowJoint.C0 = originalElbowC0 * CFrame.new(0, -0.15, 0.1) * CFrame.Angles(math.rad(-60), 0, 0)
        end
        
        -- Animación de sostener
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator") or hum
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507768375" 
            loadedAnimTrack = animator:LoadAnimation(anim)
            loadedAnimTrack.Priority = Enum.AnimationPriority.Action
            loadedAnimTrack:Play()
        end
    end)

    newTool.Unequipped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
            if elbowJoint and elbowJoint:IsA("Motor6D") and originalElbowC0 then
                elbowJoint.C0 = originalElbowC0
                originalElbowC0 = nil
            end
        end
        
        local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
        if oldGrip then oldGrip:Destroy() end
        
        if loadedAnimTrack then
            loadedAnimTrack:Stop()
            loadedAnimTrack = nil
        end
    end)

    return newTool
end

StealthTab:CreateToggle({
   Name = "Obtener / Equipar Arma",
   CurrentValue = false,
   Flag = "WeaponSwitch",
   Callback = function(Value)
      if Value then
          local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. weaponId) end)
          if success and objects then
              local armaListo = crearArmaAjustada(objects)
              if armaListo then
                  armaListo.Parent = LocalPlayer.Backpack
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChildOfClass("Humanoid") then
                      character:FindFirstChildOfClass("Humanoid"):EquipTool(armaListo)
                  end
              end
          end
      else
          local weaponInBackpack = LocalPlayer.Backpack:FindFirstChild(weaponToolName)
          if weaponInBackpack then weaponInBackpack:Destroy() end
          
          if LocalPlayer.Character then
              local weaponInChar = LocalPlayer.Character:FindFirstChild(weaponToolName)
              if weaponInChar then weaponInChar:Destroy() end
          end
      end
   end,
})

-- ==========================================
-- 4. APARTADO: REPRODUCTOR WARZONE
-- ==========================================
local MusicTab = Window:CreateTab("Música Warzone", 4483362458) 

local playlist = {
    "rbxassetid://9112893134",
    "rbxassetid://9112892993",
    "rbxassetid://9112893131"
}

local currentTrackIndex = 1
local isPlaying = false

local audioPlayer = Instance.new("Sound")
audioPlayer.Name = "WarzoneAudioPlayer"
audioPlayer.Volume = 1
audioPlayer.Looped = false 

pcall(function()
    local coreGui = game:GetService("CoreGui")
    audioPlayer.Parent = pcall(function() return coreGui.Name end) and coreGui or workspace
end)
if not audioPlayer.Parent then
    audioPlayer.Parent = workspace
end

local function playNextTrack()
    currentTrackIndex = currentTrackIndex + 1
    
    if currentTrackIndex > #playlist then
        currentTrackIndex = 1 
    end
    
    audioPlayer:Stop()
    audioPlayer.SoundId = playlist[currentTrackIndex]
    
    if isPlaying then
        task.spawn(function()
            task.wait(0.15) 
            audioPlayer.TimePosition = 0
            audioPlayer:Play()
        end)
    end
end

audioPlayer.Ended:Connect(function()
    if isPlaying then
        playNextTrack()
    end
end)

local PlayToggle = MusicTab:CreateToggle({
    Name = "Play / Pause (Música y Disparos)",
    CurrentValue = false,
    Flag = "ToggleWarzoneMusic",
    Callback = function(Value)
        isPlaying = Value
        
        if isPlaying then
            if audioPlayer.SoundId == "" then
                audioPlayer.SoundId = playlist[currentTrackIndex]
            end
            
            task.spawn(function()
                task.wait(0.1)
                audioPlayer:Play() 
            end)
        else
            audioPlayer:Pause() 
        end
    end,
})

local SkipButton = MusicTab:CreateButton({
    Name = "Forzar siguiente pista",
    Callback = function()
        playNextTrack()
        
        if not isPlaying then
            task.spawn(function()
                task.wait(0.2)
                audioPlayer:Pause()
            end)
        end
    end,
})

-- ==========================================
-- 5. TAB: SCREEN & UI SETTINGS (IN ENGLISH)
-- ==========================================
local ScreenTab = Window:CreateTab("Screen & UI Settings", 4483362458)

local forceLoopConnection = nil
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function SetScreenOrientation(mode)
    pcall(function()
        if PlayerGui then
            PlayerGui.ScreenOrientation = mode
        end
        if StarterGui then
            StarterGui.ScreenOrientation = mode
        end
    end)
end

ScreenTab:CreateSection("Definitive Method (Anti-Reversion)")

ScreenTab:CreateToggle({
   Name = "Brute Force (Prevent game overriding)",
   CurrentValue = false,
   Flag = "ForceLoop",
   Callback = function(Value)
      if Value then
          forceLoopConnection = RunService.RenderStepped:Connect(function()
              pcall(function()
                  if PlayerGui.ScreenOrientation ~= Enum.ScreenOrientation.LandscapeSensor then
                      PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
                      StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
                  end
              end)
          end)
          Rayfield:Notify({Title = "Brute Force ON", Content = "The game can no longer force portrait screen.", Duration = 4})
      else
          if forceLoopConnection then
              forceLoopConnection:Disconnect()
              forceLoopConnection = nil
          end
          Rayfield:Notify({Title = "Brute Force OFF", Content = "Loop stopped.", Duration = 2})
      end
   end,
})

ScreenTab:CreateSection("One-Time Force Methods")

ScreenTab:CreateButton({
   Name = "Force Landscape (Left)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeLeft)
      Rayfield:Notify({Title = "Applied", Content = "Landscape Left forced.", Duration = 2})
   end,
})

ScreenTab:CreateButton({
   Name = "Force Landscape (Right)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeRight)
      Rayfield:Notify({Title = "Applied", Content = "Landscape Right forced.", Duration = 2})
   end,
})

ScreenTab:CreateButton({
   Name = "Force Landscape (Auto Sensor)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeSensor)
      Rayfield:Notify({Title = "Applied", Content = "Landscape Sensor forced.", Duration = 2})
   end,
})

ScreenTab:CreateButton({
   Name = "Restore Normal (Unlock)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.Sensor)
      Rayfield:Notify({Title = "Restored", Content = "Free orientation enabled.", Duration = 2})
   end,
})

ScreenTab:CreateSection("Broken UI Fixes")

ScreenTab:CreateButton({
   Name = "Destroy Size Locks (UI Constraints)",
   Callback = function()
      local destroyedCount = 0
      for _, element in pairs(PlayerGui:GetDescendants()) do
          if element:IsA("UIAspectRatioConstraint") or element:IsA("UISizeConstraint") then
              element:Destroy()
              destroyedCount = destroyedCount + 1
          end
      end
      Rayfield:Notify({Title = "Cleanup Complete", Content = destroyedCount .. " UI locks destroyed.", Duration = 4})
   end,
})

ScreenTab:CreateSlider({
   Name = "Adjust Zoom / FOV (Field of View)",
   Range = {10, 120},
   Increment = 1,
   Suffix = " FOV",
   CurrentValue = 70,
   Flag = "CameraFOV",
   Callback = function(Value)
      pcall(function()
          workspace.CurrentCamera.FieldOfView = Value
      end)
   end,
})


-- ==========================================
-- COLA RADIACTIVA LÓGICA INTERNA Y VARIABLES (ADAPTACIÓN)
-- ==========================================
local trailCubes = {}
local spinePoints = {}
local numCubes = 35 
local cubeBaseSize = 0.35 
local spacing = 0.8 

local radioactivePalette = {
    Color3.fromRGB(128, 0, 128),  -- Púrpura
    Color3.fromRGB(255, 0, 255),  -- Magenta
    Color3.fromRGB(255, 0, 0),    -- Rojo
    Color3.fromRGB(0, 255, 255),  -- Cian
    Color3.fromRGB(0, 0, 0)       -- Negro 
}

local visualizerActive = false
local renderConnection = nil
local bassSensitivity = 8 

-- Referencias dinámicas de la radio
local boomboxClonedTool = nil

local function cleanupTrail()
    for _, cube in ipairs(trailCubes) do 
        if cube then cube:Destroy() end 
    end
    trailCubes = {}
    spinePoints = {}
end

local function createTrailCubes()
    cleanupTrail()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local startCFrame = root and root.CFrame or CFrame.new()

    for i = 1, numCubes do
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(cubeBaseSize, cubeBaseSize, cubeBaseSize)
        cube.Anchored = true
        cube.CanCollide = false
        cube.Material = Enum.Material.Neon
        cube.CastShadow = false
        cube.Parent = workspace
        table.insert(trailCubes, cube)
        
        spinePoints[i] = startCFrame * CFrame.new(0, -2.8, i * spacing)
    end
end

-- LA COLA SE PEGA A TU ESPALDA, PERO ESCUCHA EL HANDLE DEL BOOMBOX
local function updateTrailVisualizer()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if not visualizerActive then return end

    -- 1. ADAPTACIÓN DE SONIDO: Buscar el sonido en el BoomBox 
    local soundObj = nil
    if boomboxClonedTool then
        local handle = boomboxClonedTool:FindFirstChild("Handle")
        if handle then
            soundObj = handle:FindFirstChild("CustomMusicPlayer")
        end
    end

    local loudness = (soundObj and soundObj.IsPlaying) and soundObj.PlaybackLoudness or 0
    local normalLoudness = loudness / 200 
    local time = tick()

    -- 2. FÍSICAS DE LA COLUMNA VERTEBRAL (Elongación en la espalda/suelo)
    for i = 1, numCubes do
        local targetSpineCFrame
        local sway = math.sin(time * 5 + i * 0.4) * 0.3 + math.noise(time * 2, i * 0.2, 0) * 0.5

        if i == 1 then
            targetSpineCFrame = rootPart.CFrame * CFrame.new(0, -2.8, 1.2)
            spinePoints[i] = spinePoints[i]:Lerp(targetSpineCFrame, 0.4)
        else
            local prevSpine = spinePoints[i-1]
            targetSpineCFrame = prevSpine * CFrame.new(sway, 0, spacing)
            spinePoints[i] = spinePoints[i]:Lerp(targetSpineCFrame, 0.35)
        end
    end

    -- 3. VISUALIZADOR 
    for i, cube in ipairs(trailCubes) do
        local rawWave = math.abs(math.sin(time * 6 + i * 0.3))
        local expressionChaos = math.abs(math.noise(time * 2.5, i * 0.15, 0))
        
        local heightMultiplier = normalLoudness * bassSensitivity * rawWave * (expressionChaos + 0.5)
        local currentHeight = cubeBaseSize + heightMultiplier
        currentHeight = math.clamp(currentHeight, cubeBaseSize, 12) 
        
        local colorSpeed = 1.5
        local baseOffset = (time * colorSpeed) + (i * 0.12)
        local colorIndex = (math.floor(baseOffset) % #radioactivePalette) + 1
        local nextColorIndex = (colorIndex % #radioactivePalette) + 1
        local colorFraction = baseOffset % 1
        
        local targetColor = radioactivePalette[colorIndex]:Lerp(radioactivePalette[nextColorIndex], colorFraction)
        local targetSize = Vector3.new(cubeBaseSize, currentHeight, cubeBaseSize)
        local visualCFrame = spinePoints[i] * CFrame.new(0, currentHeight / 2, 0)

        cube.Size = cube.Size:Lerp(targetSize, 0.4)
        cube.CFrame = cube.CFrame:Lerp(visualCFrame, 0.4)
        cube.Color = targetColor
    end
end


-- ==========================================
-- 6. TAB: BOOMBOX ITEM (ALIENWARE 3D EDITION + CUSTOM MODELS)
-- ==========================================
local BoomboxTab = Window:CreateTab("BoomBox Item", 4483362458) 

local boomboxToolName = "BoomBoxV3"
local boomboxCustomUI = nil
local boomboxSeleccionada = "Alienware (Textura + Partículas)"

local OpcionesRadios = {
    "Alienware (Textura + Partículas)",
    "Default (Original con Partículas)",
    "Mochila (Equipada y Vibratoria)",
    "Rainbow (Mano Vibratoria)",
    "Giratorio (360 sobre la Cabeza)"
}

BoomboxTab:CreateDropdown({
    Name = "Seleccionar Modelo de Radio",
    Options = OpcionesRadios,
    CurrentOption = {"Alienware (Textura + Partículas)"},
    MultipleOptions = false,
    Flag = "BoomboxDropdown",
    Callback = function(Options)
        boomboxSeleccionada = Options[1]
    end,
})

local boomboxPlaylist = {
    "1847733588", "9042281328", "7215629038596", "135992805356761",
    "9040608027", "128563409090413", "123441580729534", "91708959103436",
    "139580603372223", "86994715837320", "89711658931291", "92764139239354",
    "70968010284997", "78559808226136", "1837113614", "9045007759",
    "136674057014960", "133761848795389", "138950692714324", "91563677636564",
    "134727517541596", "136651974045498", "111253513488600", "80957235547859",
    "132770464260876", "90005076194066", "98046995880242", "140511755680557",
    "140509080917186", "138831051422752", ""
}
local boomboxCurrentTrackIndex = 1

local function create3DButton(parent, name, text, pos, size, baseColor)
    local btnContainer = Instance.new("Frame", parent)
    btnContainer.Name = name .. "Container"
    btnContainer.Position = pos
    btnContainer.Size = size
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 3

    local shadow = Instance.new("Frame", btnContainer)
    shadow.Size = UDim2.new(1, 0, 1, 4) 
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundColor3 = Color3.new(baseColor.R * 0.4, baseColor.G * 0.4, baseColor.B * 0.4) 
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 3
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", btnContainer)
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = baseColor
    btn.ZIndex = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local grad = Instance.new("UIGradient", btn)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), 
        ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
    }
    grad.Rotation = -90

    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(15, 15, 15)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(baseColor.R * 1.3, baseColor.G * 1.3, baseColor.B * 1.3)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 4)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)

    return btn
end

BoomboxTab:CreateToggle({
   Name = "Equip Radio (Alienware UI)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           local success, errorMessage = pcall(function()
               
               pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
               
               local bgAssetId = ""
               pcall(function()
                   local url = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/DJ-bg.jpg"
                   local fileName = "DJ-bg-alienware.jpg"
                   if writefile and readfile and isfile and getcustomasset then
                       if not isfile(fileName) then writefile(fileName, game:HttpGet(url)) end
                       bgAssetId = getcustomasset(fileName)
                   end
               end)
               
               local idToLoad = "9004999866"
               if boomboxSeleccionada == "Alienware (Textura + Partículas)" then idToLoad = "9004999866"
               elseif boomboxSeleccionada == "Default (Original con Partículas)" then idToLoad = "15876467320"
               elseif boomboxSeleccionada == "Mochila (Equipada y Vibratoria)" then idToLoad = "72553230980127"
               elseif boomboxSeleccionada == "Rainbow (Mano Vibratoria)" then idToLoad = "99961136627124"
               elseif boomboxSeleccionada == "Giratorio (360 sobre la Cabeza)" then idToLoad = "80384876408333"
               end

               local objects = game:GetObjects("rbxassetid://" .. idToLoad)
               local obj = objects[1]
               local realTool = nil
               
               if obj:IsA("Tool") then
                   realTool = obj 
               else
                   local innerTool = obj:FindFirstChildWhichIsA("Tool", true)
                   if innerTool then 
                       realTool = innerTool
                   else
                       realTool = Instance.new("Tool")
                       realTool.RequiresHandle = true
                       if obj:IsA("BasePart") then
                           obj.Name = "Handle"
                           obj.Parent = realTool
                       elseif obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Accessory") or obj:IsA("Accoutrement") then
                           for _, child in pairs(obj:GetChildren()) do child.Parent = realTool end
                           local handle = realTool:FindFirstChild("Handle") or realTool:FindFirstChildWhichIsA("BasePart")
                           if handle then 
                               handle.Name = "Handle"
                           else
                               handle = Instance.new("Part")
                               handle.Name = "Handle"
                               handle.Size = Vector3.new(1, 1, 1)
                               handle.Transparency = 1
                               handle.Parent = realTool
                           end
                       end
                   end
               end
               
               if not realTool then error("No se pudo generar la radio.") end
               
               boomboxClonedTool = realTool
               boomboxClonedTool.Name = boomboxToolName
               local handle = boomboxClonedTool:FindFirstChild("Handle")
               
               if boomboxSeleccionada == "Giratorio (360 sobre la Cabeza)" then
                   for _, part in pairs(boomboxClonedTool:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.Size = part.Size * 0.3
                       end
                       if part:IsA("SpecialMesh") then
                           part.Scale = part.Scale * 0.3
                       end
                   end
               end

               for _, part in pairs(boomboxClonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false; part.CanCollide = false; part.Massless = true 
                       if part ~= handle then
                           local weld = Instance.new("WeldConstraint", handle)
                           weld.Part0 = handle; weld.Part1 = part
                       end
                   end
               end
               
               boomboxClonedTool.Grip = CFrame.new(0, -0.8, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(15))

               if boomboxSeleccionada == "Alienware (Textura + Partículas)" or boomboxSeleccionada == "Default (Original con Partículas)" then
                   pcall(function()
                       local defObj = game:GetObjects("rbxassetid://15876467320")[1]
                       if defObj then
                           for _, v in ipairs(defObj:GetDescendants()) do
                               if v:IsA("ParticleEmitter") then
                                   v:Clone().Parent = handle
                               end
                           end
                       end
                   end)
               end
               
               local radioSound = Instance.new("Sound", handle)
               radioSound.Name = "CustomMusicPlayer"
               radioSound.Volume = 1
               radioSound.Looped = false 
               
               boomboxCustomUI = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
               boomboxCustomUI.Name = "ExploitRadioUI"
               boomboxCustomUI.ResetOnSpawn = false
               boomboxCustomUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
               
               local frame = Instance.new("Frame", boomboxCustomUI)
               frame.Size = UDim2.new(0, 1, 0, 1)
               frame.Position = UDim2.new(0.5, 0, 0.8, -100)
               frame.AnchorPoint = Vector2.new(0.5, 0.5)
               frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
               frame.ClipsDescendants = true
               frame.Visible = false
               
               local uiScale = Instance.new("UIScale", frame)
               uiScale.Scale = 1 
               
               local frameCorner = Instance.new("UICorner", frame)
               frameCorner.CornerRadius = UDim.new(0, 12)
               
               local frameStroke = Instance.new("UIStroke", frame)
               frameStroke.Thickness = 3 
               frameStroke.Color = Color3.fromRGB(255, 255, 255) 
               frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

               local strokeGradient = Instance.new("UIGradient", frameStroke)
               strokeGradient.Color = ColorSequence.new({
                   ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                   ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 100, 255)), 
                   ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 10, 50)), 
                   ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
               })
               strokeGradient.Rotation = 0

               task.spawn(function()
                   while strokeGradient and strokeGradient.Parent do
                       strokeGradient.Rotation = (strokeGradient.Rotation + 1.5) % 360 
                       task.wait(0.01)
                   end
               end)

               local bgImage = Instance.new("ImageLabel", frame)
               bgImage.Size = UDim2.new(1, 0, 1, 0)
               bgImage.BackgroundTransparency = 1
               bgImage.Image = bgAssetId
               bgImage.ScaleType = Enum.ScaleType.Crop
               bgImage.ZIndex = 1 
               Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12) 
               
               local title = Instance.new("TextLabel", frame)
               title.Size = UDim2.new(1, 0, 0, 30)
               title.Position = UDim2.new(0, 0, 0, 5)
               title.Text = "📻 R A D I O 📻"
               title.TextColor3 = Color3.fromRGB(0, 255, 204)
               title.BackgroundTransparency = 1
               title.Font = Enum.Font.GothamBlack
               title.TextSize = 16
               title.ZIndex = 3
               
               local titleGlow = Instance.new("UIStroke", title)
               titleGlow.Thickness = 1
               titleGlow.Color = Color3.fromRGB(0, 255, 204)
               titleGlow.Transparency = 0.6
               
               local inputBox = Instance.new("TextBox", frame)
               inputBox.Size = UDim2.new(0.88, 0, 0, 32)
               inputBox.Position = UDim2.new(0.06, 0, 0.22, 0)
               inputBox.PlaceholderText = "ASSET ID (Ex: 140511755680557)"
               inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
               inputBox.Text = ""
               inputBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
               inputBox.BackgroundTransparency = 0.5
               inputBox.TextColor3 = Color3.fromRGB(0, 255, 204)
               inputBox.Font = Enum.Font.GothamBold
               inputBox.TextSize = 13
               inputBox.ZIndex = 3
               Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
               
               local inputStroke = Instance.new("UIStroke", inputBox)
               inputStroke.Color = Color3.fromRGB(0, 150, 120)
               inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
               
               local playBtn = create3DButton(frame, "PlayBtn", "▶️ PLAY", UDim2.new(0.06, 0, 0.45, 0), UDim2.new(0.42, 0, 0, 35), Color3.fromRGB(0, 120, 60))
               local pauseBtn = create3DButton(frame, "PauseBtn", "⏸ PAUSE", UDim2.new(0.52, 0, 0.45, 0), UDim2.new(0.42, 0, 0, 35), Color3.fromRGB(150, 100, 0))
               local prevBtn = create3DButton(frame, "PrevBtn", "⏪ PREV", UDim2.new(0.06, 0, 0.70, 0), UDim2.new(0.42, 0, 0, 35), Color3.fromRGB(15, 60, 120))
               local nextBtn = create3DButton(frame, "NextBtn", "NEXT ⏩", UDim2.new(0.52, 0, 0.70, 0), UDim2.new(0.42, 0, 0, 35), Color3.fromRGB(15, 60, 120))

               local touchZone = Instance.new("BillboardGui", boomboxCustomUI)
               touchZone.Size = UDim2.new(3, 0, 3, 0) 
               touchZone.Adornee = handle
               touchZone.AlwaysOnTop = true 
               
               local touchBtn = Instance.new("TextButton", touchZone)
               touchBtn.Size = UDim2.new(1, 0, 1, 0)
               touchBtn.BackgroundTransparency = 1
               touchBtn.Text = ""
               
               local isMenuOpen = false
               local isAnimating = false 
               
               local function toggleMenu()
                   if isAnimating then return end 
                   isAnimating = true
                   
                   isMenuOpen = not isMenuOpen
                   
                   if isMenuOpen then
                       frame.Visible = true
                       local openTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                           Size = UDim2.new(0, 270, 0, 190)
                       })
                       openTween:Play()
                       openTween.Completed:Wait() 
                   else
                       local closeTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                           Size = UDim2.new(0, 1, 0, 1) 
                       })
                       closeTween:Play()
                       closeTween.Completed:Wait() 
                       frame.Visible = false
                   end
                   
                   isAnimating = false 
               end
               
               touchBtn.MouseButton1Click:Connect(toggleMenu)
               touchBtn.Activated:Connect(toggleMenu)
               boomboxClonedTool.Activated:Connect(toggleMenu) 

               local function playPlaylistTrack()
                   local id = boomboxPlaylist[boomboxCurrentTrackIndex]
                   if id and id ~= "" then
                       inputBox.Text = id
                       radioSound.SoundId = "rbxassetid://" .. id
                       radioSound.TimePosition = 0
                       radioSound:Play()
                   else
                       inputBox.Text = "[Empty Slot]"
                       radioSound:Stop()
                   end
               end

               playBtn.MouseButton1Click:Connect(function()
                   local id = inputBox.Text:match("%d+")
                   if id then
                       local currentPlayingId = ""
                       if radioSound.SoundId then
                           currentPlayingId = radioSound.SoundId:match("%d+")
                       end
                       
                       if currentPlayingId == id then
                           if not radioSound.IsPlaying then 
                               radioSound:Resume() 
                           end
                       else
                           radioSound.SoundId = "rbxassetid://" .. id
                           radioSound.TimePosition = 0
                           radioSound:Play()
                       end
                   end
               end)
               
               pauseBtn.MouseButton1Click:Connect(function() radioSound:Pause() end)

               prevBtn.MouseButton1Click:Connect(function()
                   boomboxCurrentTrackIndex = boomboxCurrentTrackIndex - 1
                   if boomboxCurrentTrackIndex < 1 then boomboxCurrentTrackIndex = #boomboxPlaylist end
                   playPlaylistTrack()
               end)

               nextBtn.MouseButton1Click:Connect(function()
                   boomboxCurrentTrackIndex = boomboxCurrentTrackIndex + 1
                   if boomboxCurrentTrackIndex > #boomboxPlaylist then boomboxCurrentTrackIndex = 1 end
                   playPlaylistTrack()
               end)

               radioSound.Ended:Connect(function()
                   boomboxCurrentTrackIndex = boomboxCurrentTrackIndex + 1
                   if boomboxCurrentTrackIndex > #boomboxPlaylist then boomboxCurrentTrackIndex = 1 end
                   playPlaylistTrack()
               end)

               boomboxClonedTool.Equipped:Connect(function()
                   local char = LocalPlayer.Character
                   if not char then return end
                   
                   task.wait(0.1)
                   
                   local currentHandle = boomboxClonedTool:FindFirstChild("Handle")
                   if not currentHandle then return end
                   
                   local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
                   local rightHand = char:FindFirstChild("RightHand")
                   local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                   local head = char:FindFirstChild("Head")
                   
                   local isHandheld = (boomboxSeleccionada == "Alienware (Textura + Partículas)" or boomboxSeleccionada == "Default (Original con Partículas)")
                   
                   if isHandheld then return end
                   
                   local function clearGrip()
                       if rightArm and rightArm:FindFirstChild("RightGrip") then rightArm.RightGrip:Destroy() end
                       if rightHand and rightHand:FindFirstChild("RightGrip") then rightHand.RightGrip:Destroy() end
                   end
                   
                   clearGrip()
                   
                   if boomboxSeleccionada == "Mochila (Equipada y Vibratoria)" then
                       if torso then
                           if not boomboxClonedTool:GetAttribute("MochilaEscalada") then
                               local escala = 2.0 
                               for _, part in pairs(boomboxClonedTool:GetDescendants()) do
                                   if part:IsA("BasePart") then part.Size = part.Size * escala end
                                   if part:IsA("SpecialMesh") then part.Scale = part.Scale * escala end
                               end
                               boomboxClonedTool:SetAttribute("MochilaEscalada", true)
                           end

                           currentHandle.Anchored = true
                           currentHandle.CFrame = torso.CFrame
                           
                           local w = currentHandle:FindFirstChild("MochilaWeld") or Instance.new("Weld")
                           w.Name = "MochilaWeld"
                           w.Part0 = torso
                           w.Part1 = currentHandle
                           w.C0 = CFrame.new(0, 0.1, 0.9) * CFrame.Angles(0, math.rad(180), 0)
                           w.Parent = currentHandle
                           
                           currentHandle.Anchored = false
                           
                           local rs
                           rs = RunService.RenderStepped:Connect(function()
                               if not w.Parent or boomboxClonedTool.Parent ~= char then rs:Disconnect() return end
                               clearGrip()
                               w.C1 = CFrame.new(math.random(-10,10)*0.003, math.random(-10,10)*0.003, math.random(-10,10)*0.003)
                           end)
                       end
                       
                   elseif boomboxSeleccionada == "Rainbow (Mano Vibratoria)" then
                       local gripPart = rightHand or rightArm
                       if gripPart then
                           currentHandle.Anchored = true
                           currentHandle.CFrame = gripPart.CFrame
                           
                           local w = currentHandle:FindFirstChild("RainbowWeld") or Instance.new("Weld")
                           w.Name = "RainbowWeld"
                           w.Part0 = gripPart
                           w.Part1 = currentHandle
                           
                           if gripPart.Name == "RightHand" then
                               w.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                           else
                               w.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                           end
                           w.Parent = currentHandle
                           
                           currentHandle.Anchored = false
                           
                           local rs
                           rs = RunService.RenderStepped:Connect(function()
                               if not w.Parent or boomboxClonedTool.Parent ~= char then rs:Disconnect() return end
                               clearGrip()
                               w.C1 = CFrame.new(math.random(-10,10)*0.003, math.random(-10,10)*0.003, math.random(-10,10)*0.003)
                           end)
                       end
                       
                   elseif boomboxSeleccionada == "Giratorio (360 sobre la Cabeza)" then
                       if head then
                           currentHandle.Anchored = true
                           currentHandle.CFrame = head.CFrame
                           
                           local w = currentHandle:FindFirstChild("GiratorioWeld") or Instance.new("Weld")
                           w.Name = "GiratorioWeld"
                           w.Part0 = head
                           w.Part1 = currentHandle
                           w.C0 = CFrame.new(0, 3.5, 0) 
                           w.Parent = currentHandle
                           
                           if (rightArm or char:FindFirstChild("RightUpperArm")) and torso then
                               local targetArm = char:FindFirstChild("RightUpperArm") or rightArm
                               local armWeld = currentHandle:FindFirstChild("ArmPoseWeld") or Instance.new("Weld")
                               armWeld.Name = "ArmPoseWeld"
                               armWeld.Part0 = torso
                               armWeld.Part1 = targetArm
                               armWeld.C0 = CFrame.new(1.2, 1.2, -0.2) * CFrame.Angles(math.rad(150), 0, math.rad(-25))
                               armWeld.Parent = currentHandle
                           end
                           
                           currentHandle.Anchored = false
                           
                           local angle = 0
                           local rs
                           rs = RunService.RenderStepped:Connect(function(dt)
                               if not w.Parent or boomboxClonedTool.Parent ~= char then rs:Disconnect() return end
                               clearGrip()
                               angle = angle + dt * 4
                               w.C1 = CFrame.Angles(0, angle, 0)
                           end)
                       end
                   end
               end)

               boomboxClonedTool.Parent = LocalPlayer.Backpack 
               task.wait(0.1) 
               if humanoid then humanoid:EquipTool(boomboxClonedTool) end
               
               Rayfield:Notify({
                   Title = "📻Radio System📻",
                   Content = "Terminal interface injected. Tap radio to deploy.",
                   Duration = 4,
               })
           end)

           if not success then
               Rayfield:Notify({Title = "Error", Content = tostring(errorMessage), Duration = 6})
           end
       else
           pcall(function()
               if boomboxCustomUI then boomboxCustomUI:Destroy() boomboxCustomUI = nil end
               if LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild(boomboxToolName) then LocalPlayer.Backpack[boomboxToolName]:Destroy() end
               if character and character:FindFirstChild(boomboxToolName) then character[boomboxToolName]:Destroy() end
               if boomboxClonedTool then boomboxClonedTool:Destroy() boomboxClonedTool = nil end
           end)
       end
   end,
})

local rainbowRadioLoop = nil
local originalRadioProps = {}

BoomboxTab:CreateToggle({
    Name = "Efecto Radio RAINBOW (Modelo Completo)",
    CurrentValue = false,
    Flag = "RainbowRadioToggle",
    Callback = function(Value)
        if not boomboxClonedTool then
            Rayfield:Notify({Title = "Aviso", Content = "Primero equipa una radio para aplicar el efecto.", Duration = 4})
            return
        end
        
        if Value then
            originalRadioProps = {}
            
            for _, part in ipairs(boomboxClonedTool:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalRadioProps[part] = {
                        Color = part.Color,
                        Material = part.Material
                    }
                    if part:IsA("MeshPart") then
                        originalRadioProps[part].TextureID = part.TextureID
                        part.TextureID = "" 
                    end
                elseif part:IsA("SpecialMesh") then
                    originalRadioProps[part] = {
                        TextureId = part.TextureId
                    }
                    part.TextureId = ""
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    originalRadioProps[part] = {
                        Transparency = part.Transparency
                    }
                    part.Transparency = 1 
                end
            end
            
            local hue = 0
            rainbowRadioLoop = RunService.RenderStepped:Connect(function(dt)
                if boomboxClonedTool and boomboxClonedTool.Parent then
                    hue = (hue + dt * 0.4) % 1
                    local currentRGB = Color3.fromHSV(hue, 1, 1)
                    
                    for _, part in ipairs(boomboxClonedTool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = currentRGB
                            part.Material = Enum.Material.Neon
                        end
                    end
                else
                    if rainbowRadioLoop then rainbowRadioLoop:Disconnect() end
                end
            end)
            Rayfield:Notify({Title = "Rainbow Activado", Content = "Efecto de color sólido aplicado a toda la radio.", Duration = 3})
        else
            if rainbowRadioLoop then
                rainbowRadioLoop:Disconnect()
                rainbowRadioLoop = nil
            end
            
            for part, props in pairs(originalRadioProps) do
                if part and part.Parent then
                    if part:IsA("BasePart") then
                        part.Color = props.Color
                        part.Material = props.Material
                        if props.TextureID then
                            part.TextureID = props.TextureID
                        end
                    elseif part:IsA("SpecialMesh") then
                        part.TextureId = props.TextureId
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = props.Transparency
                    end
                end
            end
            originalRadioProps = {}
            
            Rayfield:Notify({Title = "Rainbow Desactivado", Content = "Apariencia original de la radio restaurada.", Duration = 3})
        end
    end,
})

-- ==========================================
-- INTERFAZ INTEGRADA DEL VISUALIZADOR
-- ==========================================
BoomboxTab:CreateSection("Visualizador de Audio (Cola Radiactiva)")

BoomboxTab:CreateSlider({
   Name = "Sensibilidad de Graves (Bass)",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 8,
   Flag = "BassSlider",
   Callback = function(Value) bassSensitivity = Value end,
})

BoomboxTab:CreateToggle({
   Name = "Activar Cola Radiactiva",
   CurrentValue = false,
   Flag = "VisualizerToggle",
   Callback = function(Value)
       visualizerActive = Value
       if Value then
           createTrailCubes()
           if not renderConnection then
               renderConnection = RunService.Heartbeat:Connect(updateTrailVisualizer)
           end
       else
           if renderConnection then
               renderConnection:Disconnect()
               renderConnection = nil
           end
           cleanupTrail()
       end
   end,
})
