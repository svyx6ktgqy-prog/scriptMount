-- ==========================================
-- Mini chit Hood Argentino V8 (RAYFIELD EDITION)
-- + INTEGRACIONES EN INGLÉS (SCREEN FIX & BOOMBOX)
-- + BALACLAVA MASK & RAINBOW RADIO
-- + FIX ANTI-CONGELAMIENTO DE JOYSTICK
-- + COLA RADIACTIVA (AUDIO VISUALIZER) INTEGRADA A LA RADIO
-- + AURA SIGMA & ARMA MILITAR
-- + FIX INUSUAL RADIO & TEST VERIFICADO
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
    "Tr$xsh", "Alien", "nekoWhite", "supreme", "purpose", "kukumer", "☪️", "NPcEm0", "NPcEm1", "satan", "entityD", "joker", "BruuhMus", "IndigestGreen", "stilect", "halloV", "hacklord", "admin", "b3hemoop", "monsterV9", "shouldermane", "legomane", "necromancer", "girlGotic", "miniGirl", "4ktre", "gucciCat", "batman", "evil6", "%1", "freefire", "santa", "pim", "Everlasting", "TrashGang", "Goat", "Monster", "Reaper", "OnlyJdottt888", "SpyEffect", "DemonSuite",
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
    ["Tr$xsh"] = "12543836003", ["Alien"] = "11839952466", ["nekoWhite"] = "136458776272324", ["supreme"] = "96969627291940", ["purpose"] = "7573169400", ["kukumer"] = "16357188828", ["☪️"] = "5041376449", ["NPcEm0"] = "99659197120809", ["NPcEm1"] = "84231645446484", ["satan"] = "92539602189320", ["entityD"] = "4578704852", ["joker"] = "94800712097538", ["BruuhMus"] = "81688502972496", ["IndigestGreen"] = "1015035577", ["stilect"] = "924573788", ["halloV"] = "109572673499730", ["hacklord"] = "93542102611556", ["admin"] = "16989454582", ["b3hemoop"] = "4494148131", ["monsterV9"] = "420826307", ["shouldermane"] = "13481686732", ["legomane"] = "11451916092", ["necromancer"] = "5343724548", ["girlGotic"] = "14590012921", ["miniGirl"] = "85977847606610", ["4ktre"] = "14664678443", ["gucciCat"] = "9721010943", ["batman"] = "9377859627", ["evil6"] = "9902678384", ["%1"] = "4829776460", ["freefire"] = "17036729720", ["santa"] = "11764050424", ["pim"] = "4805457705", ["Everlasting"] = "95946418542389", ["TrashGang"] = "5339731779", ["Goat"] = "2415658611", ["Monster"] = "906155708", ["Reaper"] = "89659421394995", ["OnlyJdottt888"] = "16694425947",
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
local testearVerificadoUniversal = false -- VARIABLE PARA EL NUEVO SWITCH

-- ==========================================
-- FUNCIONES DE TRANSFORMACIÓN Y ROBUX
-- ==========================================

local function FormatearRobux(numero)
    if numero >= 1000000000 then
        return string.format("%.1fB", numero / 1000000000):gsub("%.0B", "B")
    elseif numero >= 1000000 then
        return string.format("%.1fM", numero / 1000000):gsub("%.0M", "M")
    elseif numero >= 1000 then
        return string.format("%.1fK", numero / 1000):gsub("%.0K", "K")
    else
        return tostring(math.floor(numero))
    end
end

local function CrearEfectoRobux(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    
    local player = Players:GetPlayerFromCharacter(char)
    local displayName = player and player.DisplayName or char.Name

    local oldAura = char:FindFirstChild("RobuxAura")
    if oldAura then oldAura:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "RobuxAura"
    folder.Parent = char

    -- Contenedor Principal Flotante
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.StudsOffset = Vector3.new(0, 2.8, 0)
    bb.AlwaysOnTop = true
    bb.Parent = folder
    bb.Adornee = head

    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1, 0, 1, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = bb
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Parent = mainContainer
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.FillDirection = Enum.FillDirection.Vertical
    mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mainLayout.Padding = UDim.new(0, 2)

    -- =======================================
    -- FILA 1: NOMBRE + VERIFICADO (TAMAÑO ORIGINAL)
    -- =======================================
    local topRow = Instance.new("Frame")
    topRow.Name = "TopRow"
    topRow.Size = UDim2.new(1, 0, 0, 20)
    topRow.BackgroundTransparency = 1
    topRow.LayoutOrder = 1
    topRow.Parent = mainContainer
    
    local topLayout = Instance.new("UIListLayout")
    topLayout.Parent = topRow
    topLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    topLayout.Padding = UDim.new(0, 5)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.BackgroundTransparency = 1
    nameLabel.AutomaticSize = Enum.AutomaticSize.X
    nameLabel.Size = UDim2.new(0, 0, 1, 0)
    nameLabel.Text = displayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.LayoutOrder = 1
    nameLabel.Parent = topRow

    local verifiedIcon = Instance.new("ImageLabel")
    verifiedIcon.Name = "VerifiedLogo"
    verifiedIcon.BackgroundTransparency = 1
    verifiedIcon.Size = UDim2.new(0, 18, 0, 18)
    verifiedIcon.Image = "rbxassetid://11478378840"
    verifiedIcon.LayoutOrder = 2
    verifiedIcon.Parent = topRow

    -- =======================================
    -- FILA 2: DINERO (ESTÁTICO CON VIBRACIÓN AISLADA)
    -- =======================================
    local robuxRow = Instance.new("Frame")
    robuxRow.Name = "RobuxRow"
    robuxRow.Size = UDim2.new(1, 0, 0, 30)
    robuxRow.BackgroundTransparency = 1
    robuxRow.LayoutOrder = 2
    robuxRow.Parent = mainContainer

    -- Contenedor con ancho fijo
    local counterWrapper = Instance.new("Frame")
    counterWrapper.Name = "CounterWrapper"
    counterWrapper.Size = UDim2.new(0, 95, 1, 0)
    counterWrapper.Position = UDim2.new(0.5, 0, 0.5, 0)
    counterWrapper.AnchorPoint = Vector2.new(0.5, 0.5)
    counterWrapper.BackgroundTransparency = 1
    counterWrapper.Parent = robuxRow
    
    local robuxLayout = Instance.new("UIListLayout")
    robuxLayout.Parent = counterWrapper
    robuxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    robuxLayout.FillDirection = Enum.FillDirection.Horizontal
    robuxLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    robuxLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    robuxLayout.Padding = UDim.new(0, 5)

    -- 🖼️ LOGO SECUNDARIO DE FONDO (Intacto y totalmente estático)
    local bgIconWrapper = Instance.new("Frame")
    bgIconWrapper.Name = "BackgroundLogoWrapper"
    bgIconWrapper.BackgroundTransparency = 1
    bgIconWrapper.Size = UDim2.new(0, 34, 0, 34)
    bgIconWrapper.LayoutOrder = 0
    bgIconWrapper.Parent = counterWrapper

    local bgIcon = Instance.new("ImageLabel")
    bgIcon.Name = "BackgroundLogo"
    bgIcon.BackgroundTransparency = 1
    bgIcon.Size = UDim2.new(1, 0, 1, 0)
    bgIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    bgIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    bgIcon.Image = "rbxassetid://11560341824"
    bgIcon.ImageTransparency = 0.25
    bgIcon.ZIndex = 1
    bgIcon.Parent = bgIconWrapper

    -- 🎨 LOGO R$ CUSTOM (Mantiene escala de 20x20px y vibrará)
    local iconWrapper = Instance.new("Frame")
    iconWrapper.Name = "CustomRobuxLogo"
    iconWrapper.Size = UDim2.new(0, 20, 0, 20)
    iconWrapper.BackgroundTransparency = 1
    iconWrapper.LayoutOrder = 1
    iconWrapper.ZIndex = 2
    iconWrapper.Parent = counterWrapper

    local iconShadow = Instance.new("Frame")
    iconShadow.Size = UDim2.new(1, 0, 1, 0)
    iconShadow.Position = UDim2.new(0, 1, 0, 1)
    iconShadow.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    iconShadow.ZIndex = 2
    iconShadow.Parent = iconWrapper
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = iconShadow

    local iconMain = Instance.new("Frame")
    iconMain.Size = UDim2.new(1, 0, 1, 0)
    iconMain.BackgroundColor3 = Color3.fromRGB(14, 185, 85)
    iconMain.ZIndex = 3
    iconMain.Parent = iconWrapper
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(1, 0)
    mainCorner.Parent = iconMain

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Parent = iconMain

    local rbxText = Instance.new("TextLabel")
    rbxText.Size = UDim2.new(1, 0, 1, 0)
    rbxText.Position = UDim2.new(0, 0, 0, 0)
    rbxText.BackgroundTransparency = 1
    rbxText.Text = "R$"
    rbxText.TextColor3 = Color3.fromRGB(255, 255, 255)
    rbxText.Font = Enum.Font.GothamBlack
    rbxText.TextSize = 12
    rbxText.Rotation = -18
    rbxText.ZIndex = 4
    rbxText.Parent = iconMain

    -- 🔢 NÚMEROS DEL CONTADOR (Ahora protegido con Wrapper para vibrar libre de errores de layout)
    local textWrapper = Instance.new("Frame")
    textWrapper.Name = "TextWrapper"
    textWrapper.Size = UDim2.new(0, 70, 1, 0) -- Mantiene el tamaño estático original
    textWrapper.BackgroundTransparency = 1
    textWrapper.LayoutOrder = 2
    textWrapper.Parent = counterWrapper

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "0"
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.TextSize = 18
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 50, 0)
    textLabel.ZIndex = 2
    textLabel.Parent = textWrapper

    -- =======================================
    -- LÓGICA DE ANIMACIÓN, VIBRACIÓN Y SONIDO
    -- =======================================
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1210852193"
    sound.Volume = 1.5
    sound.Parent = head

    local countValue = Instance.new("NumberValue")
    countValue.Value = 0
    countValue.Parent = folder

    countValue.Changed:Connect(function(val)
        textLabel.Text = FormatearRobux(val)
    end)

    task.spawn(function()
        while char and char.Parent and folder.Parent do
            countValue.Value = 0
            
            -- Activar la animación de vibración en el R$ y los Números
            local isCounting = true
            task.spawn(function()
                while isCounting and char and char.Parent do
                    local shakeX = math.random(-2, 2) 
                    local shakeY = math.random(-2, 2)
                    local rotShake = math.random(-4, 4)

                    -- Vibración en el R$
                    iconMain.Position = UDim2.new(0, shakeX, 0, shakeY)
                    iconMain.Rotation = rotShake

                    -- Vibración en los números (el Wrapper los protege del UIListLayout)
                    textLabel.Position = UDim2.new(0, shakeX, 0, shakeY)
                    textLabel.Rotation = rotShake

                    task.wait(0.04)
                end
                
                -- Resetear posiciones y rotación a su estado estático
                iconMain.Position = UDim2.new(0, 0, 0, 0)
                iconMain.Rotation = 0
                textLabel.Position = UDim2.new(0, 0, 0, 0)
                textLabel.Rotation = 0
            end)

            -- Animación de aumento de Robux
            local tween = TweenService:Create(countValue, TweenInfo.new(6, Enum.EasingStyle.Linear), {Value = 1000000000})
            tween:Play()
            tween.Completed:Wait()
            
            -- Desactivar vibración cuando el conteo se completa de forma segura
            isCounting = false
            iconMain.Position = UDim2.new(0, 0, 0, 0)
            iconMain.Rotation = 0
            textLabel.Position = UDim2.new(0, 0, 0, 0)
            textLabel.Rotation = 0

            if folder.Parent then
                textLabel.Text = "0"
                sound:Play()
                task.wait(1.5)
            end
        end
    end)
end

local function AplicarMorph(characterID)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid then return end

    pcall(function()
        -- 1. Limpiar ropa actual y auras previas
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("Hat") then
                v:Destroy()
            end
        end
        local oldAura = char:FindFirstChild("RobuxAura")
        if oldAura then oldAura:Destroy() end

        -- 2. Cargar el nuevo modelo
        local model = game:GetObjects("rbxassetid://" .. characterID)[1]
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

        -- 3. Inyectar efecto si es halloV O si el test general está activado
        if characterID == IDsPersonajes["halloV"] or testearVerificadoUniversal then
            CrearEfectoRobux(char)
        end
    end)
end

-- ==========================================
-- SWITCH TESTEAR VERIFICADO (NUEVO)
-- ==========================================
StealthTab:CreateToggle({
    Name = "Testear Verificado (En Todos los Personajes)",
    CurrentValue = false,
    Flag = "VerifiedTestToggle",
    Callback = function(Value)
        testearVerificadoUniversal = Value
        -- Al cambiar el switch, re-aplicamos el morph actual automáticamente para probarlo
        AplicarMorph(PersonajeSeleccionadoID)
    end,
})

local CharacterSpinner = StealthTab:CreateDropdown({
    Name = "Seleccionar Personaje de Sigilo",
    Options = NombresPersonajes,
    CurrentOption = {"Tr$xsh"},
    MultipleOptions = false,
    Flag = "DropdownPersonajes",
    Callback = function(Options)
        local seleccion = Options[1]
        PersonajeSeleccionadoID = IDsPersonajes[seleccion]
        AplicarMorph(PersonajeSeleccionadoID) -- <-- ¡Se aplica inmediatamente sin depender del Switch!
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
                AplicarMorph(PersonajeSeleccionadoID) -- Asegura el morfo en caso de que active esto tras resetear
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
                    
                    -- Limpiar aura robux por si se desactiva
                    local char = LocalPlayer.Character
                    local oldAura = char and char:FindFirstChild("RobuxAura")
                    if oldAura then oldAura:Destroy() end
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
    -- ⚙️ PARÁMETROS CONFIGURABLES DEL ARMA ⚙️
    -- ==========================================
    local ESCALA = 1.25
    
    local OFFSET_POSICION = CFrame.new(0, 0.50, -0.99) 
    
    local OFFSET_ROTACION = CFrame.Angles(math.rad(-41), math.rad(15), math.rad(0))
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

    local tempModel = Instance.new("Model")
    for _, p in ipairs(partes3D) do
        p.Parent = tempModel
    end
    if ESCALA ~= 1.0 then
        tempModel:ScaleTo(ESCALA)
    end

    local posSum = Vector3.new()
    for _, p in ipairs(partes3D) do
        posSum = posSum + p.Position
    end
    local centerPos = posSum / #partes3D

    local masterHandle = Instance.new("Part")
    masterHandle.Name = "Handle"
    masterHandle.Size = Vector3.new(0.2, 0.2, 0.2)
    masterHandle.Transparency = 1
    masterHandle.CanCollide = false
    masterHandle.Anchored = false
    masterHandle.Massless = true
    masterHandle.CFrame = CFrame.new(centerPos)
    masterHandle.Parent = newTool

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
    
    tempModel:Destroy()

    newTool.Equipped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local manoDerecha = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        
                if manoDerecha then
            task.defer(function()
                local rightGrip = manoDerecha:FindFirstChild("RightGrip")
                if rightGrip then rightGrip:Destroy() end
            end)

            masterHandle.CFrame = manoDerecha.CFrame * OFFSET_ROTACION * OFFSET_POSICION
            
            local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
            if oldGrip then oldGrip:Destroy() end
            
            local manualGrip = Instance.new("WeldConstraint")
            manualGrip.Name = "ManualGripAttachment"
            manualGrip.Part0 = manoDerecha
            manualGrip.Part1 = masterHandle
            manualGrip.Parent = masterHandle
        end

        local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
        if elbowJoint and elbowJoint:IsA("Motor6D") then
            if not originalElbowC0 then originalElbowC0 = elbowJoint.C0 end
            elbowJoint.C0 = originalElbowC0 * CFrame.new(0, -0.15, 0.1) * CFrame.Angles(math.rad(-60), 0, 0)
        end
        
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

local function updateTrailVisualizer()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if not visualizerActive then return end

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
                   
                   -- FIX INUSUAL: Saltar automáticamente IDs vacíos o nulos para evitar frenazos
                   while not id or id == "" do
                       boomboxCurrentTrackIndex = boomboxCurrentTrackIndex + 1
                       if boomboxCurrentTrackIndex > #boomboxPlaylist then boomboxCurrentTrackIndex = 1 end
                       id = boomboxPlaylist[boomboxCurrentTrackIndex]
                   end
                   
                   inputBox.Text = id
                   
                   -- FIX INUSUAL: Forzar la carga y el Play dentro de un nuevo hilo paralelo (Spawn) 
                   -- Esto evita por completo el lag o pausa del motor de Roblox entre canciones.
                   task.spawn(function()
                       radioSound.SoundId = "rbxassetid://" .. id
                       radioSound.TimePosition = 0
                       radioSound:Play()
                   end)
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
                   -- FIX INUSUAL: Llamamos al avance de canción usando un spawn
                   -- para que la transición sea instantánea en cuanto el motor termina de escuchar el beat final.
                   task.spawn(function()
                       boomboxCurrentTrackIndex = boomboxCurrentTrackIndex + 1
                       if boomboxCurrentTrackIndex > #boomboxPlaylist then boomboxCurrentTrackIndex = 1 end
                       playPlaylistTrack()
                   end)
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

-- ==========================================
-- 8. APARTADO: CLONES (ENJAMBRE & ANIMACIONES)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local CloneTab = Window:CreateTab("Clones Enjambre", 4483362458)

local originalCharacter = LocalPlayer.Character
local cloneList = {}
local activeIndex = 1 
local followingEnabled = true
local isSwarmJumping = false 
local cloneJumpDelays = {}   
local customAnimators = {} 

local MIN_SPACING = 3.5                
local GOLDEN_ANGLE = 2.3999632297286533 

-- ==========================================
-- INTERFAZ FLOTANTE PARA CLONES
-- ==========================================
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "CloneControlUI"
FloatingGui.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
FloatingGui.Enabled = false 

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 50) 
mainFrame.Position = UDim2.new(0.5, -130, 0.9, -60) 
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = FloatingGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 10)
layout.Parent = mainFrame

local function createBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    btn.Parent = mainFrame
    return btn
end

local btnPrev = createBtn("<")
local btnOrig = createBtn("O")
local btnNext = createBtn(">")
local btnJump = createBtn("^") 

btnJump.MouseButton1Down:Connect(function() isSwarmJumping = true end)
btnJump.MouseButton1Up:Connect(function() isSwarmJumping = false end)
btnJump.MouseLeave:Connect(function() isSwarmJumping = false end)

-- ==========================================
-- LÓGICA DE CUERPOS, CÁMARA Y ANIMACIONES
-- ==========================================
local function getAllBodies()
    local bodies = {originalCharacter}
    for _, clone in ipairs(cloneList) do
        if clone and clone.Parent then
            table.insert(bodies, clone)
        end
    end
    return bodies
end

local function applyAntiCollision(newBody)
    local bodies = getAllBodies()
    local coreParts = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"}
    
    for _, otherBody in ipairs(bodies) do
        if newBody ~= otherBody then
            for _, partName in ipairs(coreParts) do
                local p1 = newBody:FindFirstChild(partName)
                local p2 = otherBody:FindFirstChild(partName)
                if p1 and p2 then
                    local noCollision = Instance.new("NoCollisionConstraint")
                    noCollision.Part0 = p1
                    noCollision.Part1 = p2
                    noCollision.Parent = p1
                end
            end
        end
    end
end

local function setupAnimations(character)
    if customAnimators[character] then return end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return end
    
    local animator = hum:FindFirstChild("Animator") or Instance.new("Animator", hum)
    local animateScript = originalCharacter:FindFirstChild("Animate")
    
    local animIds = {
        idle = "rbxassetid://5077661410",
        walk = "rbxassetid://5077778266",
        run  = "rbxassetid://5077677153",
        jump = "rbxassetid://5077650008",
        fall = "rbxassetid://5077679680"
    }

    if animateScript then
        local function getAnimId(folderName)
            local folder = animateScript:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChildOfClass("Animation")
                if anim then return anim.AnimationId end
            end
            return nil
        end
        animIds.idle = getAnimId("idle") or animIds.idle
        animIds.walk = getAnimId("walk") or animIds.run or animIds.walk
        animIds.run  = getAnimId("run") or animIds.walk or animIds.run
        animIds.jump = getAnimId("jump") or animIds.jump
        animIds.fall = getAnimId("fall") or animIds.fall
    end

    local tracks = {}
    for name, id in pairs(animIds) do
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        tracks[name] = animator:LoadAnimation(anim)
        if name == "idle" then
            tracks[name].Priority = Enum.AnimationPriority.Idle
        else
            tracks[name].Priority = Enum.AnimationPriority.Movement
        end
    end

    customAnimators[character] = {
        tracks = tracks,
        currentState = "none"
    }
end

local function updateAnimations()
    local bodies = getAllBodies()
    
    for _, body in ipairs(bodies) do
        if body ~= originalCharacter then
            local animScript = body:FindFirstChild("Animate")
            if animScript and animScript:IsA("LocalScript") then animScript.Disabled = true end
        end

        if body ~= originalCharacter or (body == originalCharacter and body ~= LocalPlayer.Character) then
            if not customAnimators[body] then setupAnimations(body) end

            local animData = customAnimators[body]
            local root = body:FindFirstChild("HumanoidRootPart")
            local hum = body:FindFirstChild("Humanoid")
            
            if root and hum and animData then
                local flatVel = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                local speed = flatVel.Magnitude
                local isRotating = body:GetAttribute("IsRotating") or false

                local targetState = "idle"
                
                if speed > 11 then targetState = "run"
                elseif speed > 0.5 or isRotating then targetState = "walk" end
                
                local humState = hum:GetState()
                if humState == Enum.HumanoidStateType.Jumping then targetState = "jump"
                elseif humState == Enum.HumanoidStateType.Freefall then targetState = "fall" end

                if animData.currentState ~= targetState then
                    if animData.currentState ~= "none" and animData.tracks[animData.currentState] then
                        animData.tracks[animData.currentState]:Stop(0.2)
                    end
                    if targetState ~= "none" and animData.tracks[targetState] then
                        animData.tracks[targetState]:Play(0.2)
                    end
                    animData.currentState = targetState
                end
                
                if targetState == "walk" or targetState == "run" then
                    local track = animData.tracks[targetState]
                    if track then
                        local playbackSpeed = (speed > 0.5) and (speed / 16) or 0.8
                        track:AdjustSpeed(math.clamp(playbackSpeed, 0.5, 1.8))
                    end
                end
            end
        else
            if customAnimators[body] and customAnimators[body].currentState ~= "none" then
                local track = customAnimators[body].tracks[customAnimators[body].currentState]
                if track then track:Stop(0.1) end
                customAnimators[body].currentState = "none"
            end

            local animScript = body:FindFirstChild("Animate")
            if animScript and animScript:IsA("LocalScript") and animScript.Disabled then
                animScript.Disabled = false
            end
        end
    end
end

local function switchCharacter(newIndex)
    local bodies = getAllBodies()
    if newIndex > #bodies then newIndex = 1 end
    if newIndex < 1 then newIndex = #bodies end
    
    local oldChar = bodies[activeIndex]
    if oldChar and oldChar:FindFirstChild("Humanoid") then
        oldChar.Humanoid:MoveTo(oldChar.HumanoidRootPart.Position)
        oldChar:SetAttribute("IsRotating", false)
        
        local animator = oldChar.Humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
    
    activeIndex = newIndex
    local targetChar = bodies[activeIndex]
    
    if targetChar and targetChar:FindFirstChild("Humanoid") then
        LocalPlayer.Character = targetChar
        targetChar.Humanoid.AutoRotate = true 
        targetChar:SetAttribute("IsRotating", false)
        
        local targetAnimator = targetChar.Humanoid:FindFirstChild("Animator")
        if targetAnimator then
            for _, track in ipairs(targetAnimator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
        
        if customAnimators[targetChar] then
            customAnimators[targetChar].currentState = "none"
        end
        
        task.defer(function()
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = targetChar:FindFirstChild("Humanoid")
        end)
    end
end

btnPrev.MouseButton1Click:Connect(function() switchCharacter(activeIndex - 1) end)
btnNext.MouseButton1Click:Connect(function() switchCharacter(activeIndex + 1) end)
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) 

-- ==========================================
-- LÓGICA DEL ENJAMBRE
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not followingEnabled then return end
    local activeChar = LocalPlayer.Character
    if not activeChar or not activeChar:FindFirstChild("HumanoidRootPart") then return end

    local activeHum = activeChar:FindFirstChild("Humanoid")
    if not activeHum then return end

    local activePos = activeChar.HumanoidRootPart.Position
    local isPlayerMoving = activeHum.MoveDirection.Magnitude > 0

    local bodies = getAllBodies()
    local movingClones = {}
    
    for _, body in ipairs(bodies) do
        if body ~= activeChar and body:FindFirstChild("Humanoid") and body:FindFirstChild("HumanoidRootPart") then
            local root = body.HumanoidRootPart
            local hum = body.Humanoid
            if not root.Anchored and hum.WalkSpeed > 0 then
                table.insert(movingClones, body)
            end
        end
    end
    
    local cloneCount = #movingClones
    if cloneCount > 0 then
        local maxRadius = math.max(6, math.sqrt(cloneCount) * 3.5)

        for i, body in ipairs(movingClones) do
            local hum = body.Humanoid
            local root = body.HumanoidRootPart
            
            local rFraction = math.sqrt(i / cloneCount) 
            local radius = rFraction * maxRadius
            local angle = i * GOLDEN_ANGLE
            
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local targetPosition = activePos + offset

            local separationVector = Vector3.new(0, 0, 0)
            for _, otherBody in ipairs(bodies) do
                if otherBody ~= body and otherBody:FindFirstChild("HumanoidRootPart") then
                    local otherPos = otherBody.HumanoidRootPart.Position
                    local dist = (root.Position - otherPos).Magnitude

                    if dist < MIN_SPACING and dist > 0.001 then
                        local pushDir = (root.Position - otherPos).Unit
                        local pushForce = (MIN_SPACING - dist)
                        separationVector = separationVector + (pushDir * pushForce)
                    end
                end
            end

            targetPosition = targetPosition + separationVector
            local flatRootPos = Vector3.new(root.Position.X, 0, root.Position.Z)
            local flatTargetPos = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distToTarget2D = (flatRootPos - flatTargetPos).Magnitude
            
            if isSwarmJumping then
                local now = tick()
                if not cloneJumpDelays[body] then
                    cloneJumpDelays[body] = now + (math.random(0, 40) / 100)
                end
                if now >= cloneJumpDelays[body] then
                    hum.Jump = true
                    cloneJumpDelays[body] = now + (math.random(50, 90) / 100)
                end
            else
                cloneJumpDelays[body] = nil
            end

            if distToTarget2D > 1.5 then
                hum.AutoRotate = true
                hum:MoveTo(targetPosition)
                body:SetAttribute("IsRotating", false) 
                
                local lookVector = root.CFrame.LookVector
                local rayOrigin = root.Position + Vector3.new(0, -0.5, 0) 
                local rayDirection = lookVector * 3.5 
                
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = bodies
                
                local hit = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                if hit and hit.Instance and hit.Instance.CanCollide then
                    hum.Jump = true
                end
            else
                if not isPlayerMoving then
                    hum.AutoRotate = false
                    local lookAtPos = Vector3.new(activePos.X, root.Position.Y, activePos.Z)
                    
                    local currentDir = root.CFrame.LookVector
                    local targetDir = (lookAtPos - root.Position).Unit
                    local dot = math.clamp(currentDir:Dot(targetDir), -1, 1)
                    local rotAngle = math.acos(dot)
                    
                    if rotAngle > 0.08 then 
                        root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, lookAtPos), 0.15)
                        body:SetAttribute("IsRotating", true) 
                    else
                        body:SetAttribute("IsRotating", false)
                    end
                else
                    hum.AutoRotate = true
                    body:SetAttribute("IsRotating", false)
                end
            end
        end
    end
    
    updateAnimations()
end)

-- ==========================================
-- BOTONES EN LA UI
-- ==========================================
CloneTab:CreateButton({
   Name = "Crear Nuevo Clon (Inteligente)",
   Callback = function()
       if not originalCharacter then originalCharacter = LocalPlayer.Character end
       
       if originalCharacter and originalCharacter:FindFirstChild("HumanoidRootPart") then
           originalCharacter.Archivable = true
           local clone = originalCharacter:Clone()
           clone.Name = "Clon_" .. tostring(#cloneList + 1)
           clone.Parent = workspace
           
           clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(3, 0, 0))
           table.insert(cloneList, clone)
           
           applyAntiCollision(clone)
           setupAnimations(clone) 
           
           FloatingGui.Enabled = true
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Inteligente Creado",
               Content = "Añadido a la formación. Animaciones fluidas listas.",
               Duration = 3,
           })
       end
   end,
})

CloneTab:CreateToggle({
   Name = "Clones siguen al jugador actual",
   CurrentValue = true,
   Flag = "FollowToggle",
   Callback = function(Value)
       followingEnabled = Value
   end,
})

CloneTab:CreateButton({
    Name = "☠️ Limpiar Todos los Clones",
    Callback = function()
        switchCharacter(1)
        for _, clone in ipairs(cloneList) do
            if clone and clone:FindFirstChild("Humanoid") then
                customAnimators[clone] = nil 
                clone.Humanoid.Health = 0
                task.delay(2, function()
                    if clone then clone:Destroy() end
                end)
            end
        end
        
        table.clear(cloneList)
        table.clear(cloneJumpDelays)
        FloatingGui.Enabled = false
        
        Rayfield:Notify({
            Title = "Limpieza Exitosa",
            Content = "Todos los clones han sido eliminados del servidor.",
            Duration = 3,
        })
    end,
})

--#WORLD CUP

---------------------------------------------------------
-- INICIO APARTADO: FESTEJO (Limpieza de Efectos Mejorada)
---------------------------------------------------------
local Tab = Window:CreateTab("Festejo")

local player = game:GetService("Players").LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local isCelebrating = false
local celebrationAssets = {}
local activeEffects = {} -- Rastreará fuegos artificiales y sonidos en curso
local originalJoints = {} -- Guardará la posición original de los brazos

-- IDs de Assets
local CUP_MODEL_ID = "rbxassetid://118466807930342"
local FIREWORK_SOUNDS = {
    "rbxassetid://90779381422678", 
    "rbxassetid://136415610645234", 
    "rbxassetid://115500038019146", 
    "rbxassetid://9038466535"
}
local FESTEJO_PARTICLES_ID = "rbxassetid://79124632949757"

---------------------------------------------------------
-- FUNCIONES DE EFECTOS Y LIMPIEZA
---------------------------------------------------------
local function cleanupCelebration()
    -- Destruir assets fijos (Copa, UI, Attachments)
    for _, asset in pairs(celebrationAssets) do
        if asset and asset.Parent then asset:Destroy() end
    end
    celebrationAssets = {}
    
    -- Destruir efectos dinámicos en vuelo (Fuegos artificiales, sonidos)
    for _, effect in pairs(activeEffects) do
        if effect and effect.Parent then effect:Destroy() end
    end
    activeEffects = {}

    -- Limpiar GUI por si acaso
    local orphanedGui = PlayerGui:FindFirstChild("SoccerSlideGUI")
    if orphanedGui then orphanedGui:Destroy() end

    -- Restaurar brazos a su posición original
    for joint, origC0 in pairs(originalJoints) do
        pcall(function() joint.C0 = origC0 end)
    end
    originalJoints = {}
end

local function createDenseConfetti(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "ConfettiDenso"
    emitter.Texture = "rbxassetid://243660364" 
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(50, 255, 50)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 50))
    })
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0.5)})
    emitter.Rate = 500
    emitter.VelocitySpread = 360
    emitter.Speed = NumberRange.new(30, 50)
    emitter.Lifetime = NumberRange.new(2, 4)
    emitter.Acceleration = Vector3.new(0, -25, 0)
    emitter.RotSpeed = NumberRange.new(-500, 500)
    emitter.LightEmission = 1
    emitter.ZOffset = 1
    emitter.Parent = parent
    return emitter
end

local function createRibbons(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "Tiritas"
    emitter.Texture = "rbxassetid://14371490906"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    emitter.Size = NumberSequence.new(2, 0.5)
    emitter.Rate = 150
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(40, 70)
    emitter.Acceleration = Vector3.new(0, -30, 0)
    emitter.Drag = 1
    emitter.Lifetime = NumberRange.new(3, 5)
    emitter.ZOffset = 1
    emitter.Parent = parent
    return emitter
end

local function spawn3DCylinderConfetti(root)
    if not isCelebrating then return end
    for i = 1, 3 do
        local cylinder = Instance.new("Part")
        cylinder.Shape = Enum.PartType.Cylinder
        cylinder.Size = Vector3.new(0.1, 0.4, 0.1)
        cylinder.Color = Color3.fromHSV(math.random(), 1, 1)
        cylinder.Material = Enum.Material.Neon
        cylinder.CanCollide = true 
        cylinder.Position = root.Position + Vector3.new(math.random(-8, 8), math.random(5, 12), math.random(-8, 8))
        
        local bv = Instance.new("BodyVelocity", cylinder)
        bv.MaxForce = Vector3.new(100, 100, 100)
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(10, 25), math.random(-15, 15))
        
        local rot = Instance.new("BodyAngularVelocity", cylinder)
        rot.AngularVelocity = Vector3.new(math.random(-30,30), math.random(-30,30), math.random(-30,30))
        
        cylinder.Parent = workspace
        table.insert(activeEffects, cylinder)
        task.delay(4, function() if cylinder then cylinder:Destroy() end end)
    end
end

local function spawnFirework(char)
    if not isCelebrating then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local firework = Instance.new("Part")
    firework.Size = Vector3.new(1, 1, 1)
    firework.Position = root.Position + Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
    firework.BrickColor = BrickColor.Random()
    firework.Material = Enum.Material.Neon
    firework.CanCollide = false
    firework.Parent = workspace
    table.insert(activeEffects, firework)

    local isDud = math.random(1, 100) <= 15
    local bv = Instance.new("BodyVelocity", firework)
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    
    if isDud then
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(15, 30), math.random(-15, 15))
    else
        bv.Velocity = Vector3.new(math.random(-10, 10), math.random(150, 220), math.random(-10, 10))
    end

    local launchSound = Instance.new("Sound", firework)
    launchSound.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
    launchSound.Volume = 3
    launchSound:Play()

    task.delay(isDud and 1.2 or 3, function()
        -- FRENO: Si el switch se apagó mientras el cohete volaba, no explotes
        if not isCelebrating then return end 

        if firework.Parent then
            local exp = Instance.new("Explosion", workspace)
            exp.Position = firework.Position
            exp.BlastRadius = 0
            
            local bang = Instance.new("Sound", workspace)
            bang.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
            bang.Volume = 6
            bang.PlayOnRemove = true
            table.insert(activeEffects, bang)
            bang:Destroy()

            local attachment = Instance.new("Attachment", workspace.Terrain)
            attachment.WorldPosition = firework.Position
            table.insert(activeEffects, attachment)

            local sparks = Instance.new("ParticleEmitter", attachment)
            sparks.Texture = "rbxassetid://7369527715"
            sparks.Color = ColorSequence.new(Color3.fromHSV(math.random(), 1, 1))
            sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 0)})
            sparks.Speed = NumberRange.new(80, 150)
            sparks.VelocitySpread = 360
            sparks.Drag = 5
            sparks.Lifetime = NumberRange.new(1.5, 3)
            sparks.LightEmission = 1
            sparks:Emit(300)
            task.delay(4, function() if attachment then attachment:Destroy() end end)
            
            firework:Destroy()
        end
    end)
end

---------------------------------------------------------
-- BOTÓN DE DESLIZAMIENTO
---------------------------------------------------------
local function createSlideButton()
    if PlayerGui:FindFirstChild("SoccerSlideGUI") then
        PlayerGui.SoccerSlideGUI:Destroy()
    end

    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "SoccerSlideGUI"
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0, 20, 0.5, -35)
    btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    btn.Text = "⚽"
    btn.TextSize = 40
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255,255,255)

    local isSliding = false

    btn.MouseButton1Click:Connect(function()
        if isSliding then return end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end

        isSliding = true
        hum.PlatformStand = true

        local trailA0 = Instance.new("Attachment", root)
        trailA0.Position = Vector3.new(-1, -1.5, 0)
        local trailA1 = Instance.new("Attachment", root)
        trailA1.Position = Vector3.new(1, -1.5, 0)
        
        local slideTrail = Instance.new("Trail", root)
        slideTrail.Attachment0 = trailA0
        slideTrail.Attachment1 = trailA1
        slideTrail.Lifetime = 0.6
        slideTrail.Color = ColorSequence.new(Color3.fromRGB(200, 255, 200))
        slideTrail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})

        local dustEmitter = Instance.new("ParticleEmitter", root)
        dustEmitter.Texture = "rbxassetid://243662281"
        dustEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 4)})
        dustEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
        dustEmitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
        dustEmitter.Speed = NumberRange.new(5, 10)
        dustEmitter.VelocitySpread = 45
        dustEmitter.EmissionDirection = Enum.NormalId.Back
        dustEmitter.Rate = 50

        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(400000, 400000, 400000)
        bg.CFrame = CFrame.new(root.Position, root.Position + root.CFrame.LookVector) * CFrame.Angles(math.rad(-80), 0, 0)
        
        local initialSpeed = 70 
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = root.CFrame.LookVector * initialSpeed 

        local rightJoint = char:FindFirstChild("RightShoulder", true) or char:FindFirstChild("Right Shoulder", true)
        local leftJoint = char:FindFirstChild("LeftShoulder", true) or char:FindFirstChild("Left Shoulder", true)
        local rOriginalSlideC0, lOriginalSlideC0
        local cupWeld
        local head = char:FindFirstChild("Head")
        
        pcall(function()
            if rightJoint then rOriginalSlideC0 = rightJoint.C0 rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(20)) end
            if leftJoint then lOriginalSlideC0 = leftJoint.C0 leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(-20)) end

            local cup = char:FindFirstChild("WorldCup_Gemini")
            if cup then
                cupWeld = cup:FindFirstChild("CupWeld_Gemini")
                if cupWeld then
                    if head then
                        cupWeld.C0 = CFrame.new(0, (head.Size.Y / 2) + 0.5, 2.5) * CFrame.Angles(math.rad(90), 0, 0)
                    else
                        cupWeld.C0 = CFrame.new(0, 0.5, 2.5) * CFrame.Angles(math.rad(90), 0, 0)
                    end
                end
            end
        end)

        for i = initialSpeed, 0, -3 do
            if bv and bv.Parent then
                bv.Velocity = root.CFrame.LookVector * i
            end
            task.wait(0.1)
        end

        task.wait(0.3) 

        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        
        dustEmitter.Enabled = false
        game.Debris:AddItem(dustEmitter, 2)
        game.Debris:AddItem(slideTrail, 1)
        game.Debris:AddItem(trailA0, 1)
        game.Debris:AddItem(trailA1, 1)
        
        pcall(function()
            if rightJoint and rOriginalSlideC0 then rightJoint.C0 = rOriginalSlideC0 end
            if leftJoint and lOriginalSlideC0 then leftJoint.C0 = lOriginalSlideC0 end
            
            if cupWeld then
                if head then
                    cupWeld.C0 = CFrame.new(0, (head.Size.Y / 2) + 1.5, -0.5)
                else
                    cupWeld.C0 = CFrame.new(0, 3.5, -1)
                end
            end
        end)

        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(1) 
        isSliding = false
    end)
    
    return gui
end

---------------------------------------------------------
-- LÓGICA PRINCIPAL: SETUP DINÁMICO
---------------------------------------------------------
local function applyCelebrationToCharacter(char)
    if not isCelebrating or not char then return end
    
    local humanoid = char:WaitForChild("Humanoid", 3)
    local root = char:WaitForChild("HumanoidRootPart", 3)
    local head = char:WaitForChild("Head", 3)
    if not (humanoid and root) then return end

    cleanupCelebration()

    local slideGui = createSlideButton()
    table.insert(celebrationAssets, slideGui)

    pcall(function()
        local cupObjects = game:GetObjects(CUP_MODEL_ID)
        local cup = cupObjects[1]
        if cup then
            cup.Parent = char
            cup.Name = "WorldCup_Gemini" 
            
            for _, p in pairs(cup:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            if cup:IsA("BasePart") then cup.CanCollide = false end
            
            local weld = Instance.new("Weld", cup)
            weld.Name = "CupWeld_Gemini"
            
            if head then
                weld.Part0 = head
                weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                weld.C0 = CFrame.new(0, (head.Size.Y / 2) + 1.5, -0.5) 
            else
                weld.Part0 = root
                weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                weld.C0 = CFrame.new(0, 3.5, -1) 
            end
            
            table.insert(celebrationAssets, cup)
        end
    end)

    local chaosAttachment = Instance.new("Attachment", root)
    table.insert(celebrationAssets, chaosAttachment)
    
    table.insert(celebrationAssets, createDenseConfetti(root))
    table.insert(celebrationAssets, createRibbons(root))
    
    local festejoEmitter = Instance.new("ParticleEmitter", chaosAttachment)
    festejoEmitter.Texture = FESTEJO_PARTICLES_ID
    festejoEmitter.Rate = 100
    festejoEmitter.Size = NumberSequence.new(3)
    table.insert(celebrationAssets, festejoEmitter)

    pcall(function()
        local rightJoint = char:FindFirstChild("RightShoulder", true) or char:FindFirstChild("Right Shoulder", true)
        local leftJoint = char:FindFirstChild("LeftShoulder", true) or char:FindFirstChild("Left Shoulder", true)
        
        -- Guardar la pose original para restaurarla limpia al apagar
        if rightJoint and not originalJoints[rightJoint] then originalJoints[rightJoint] = rightJoint.C0 end
        if leftJoint and not originalJoints[leftJoint] then originalJoints[leftJoint] = leftJoint.C0 end

        if rightJoint then rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(150), 0, math.rad(-20)) end
        if leftJoint then leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(150), 0, math.rad(20)) end
    end)
end

---------------------------------------------------------
-- CONTROL DEL TOGGLE CON REAPLICACIÓN AUTOMÁTICA
---------------------------------------------------------
Tab:CreateToggle({
    Name = "🏆 Levantar la Copa (Celebración Épica)",
    CurrentValue = false,
    Callback = function(Value)
        isCelebrating = Value

        if isCelebrating then
            applyCelebrationToCharacter(player.Character)

            task.spawn(function()
                local cam = workspace.CurrentCamera
                local lastCharacter = player.Character

                while isCelebrating do
                    local currentChar = player.Character
                    
                    if currentChar and currentChar ~= lastCharacter then
                        lastCharacter = currentChar
                        task.wait(0.5) 
                        if isCelebrating then
                            applyCelebrationToCharacter(currentChar)
                        end
                    end
                    
                    if currentChar then
                        local root = currentChar:FindFirstChild("HumanoidRootPart")
                        local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
                        
                        if root and humanoid and humanoid.Health > 0 then
                            if not humanoid.PlatformStand then 
                                humanoid.Jump = true
                            end
                            spawn3DCylinderConfetti(root)
                            
                            cam.CFrame = cam.CFrame * CFrame.new(
                                math.random(-15, 15)/15, 
                                math.random(-30, 30)/15, 
                                math.random(-15, 15)/15
                            )
                            
                            if math.random(1, 4) == 1 then
                                spawnFirework(currentChar)
                            end
                        end
                    end
                    
                    task.wait(0.1)
                end
            end)
        else
            -- APAGADO: Limpia copa, brazos y efectos instantáneamente sin matarte
            isCelebrating = false
            cleanupCelebration()
        end
    end,
})

-- ==========================================
-- 🔭 APARTADO: BINOCULARES TÁCTICOS + ESCÁNER ADV.
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Si tu variable de ventana no es 'Window', cámbiala aquí
local BinoTab = Window:CreateTab("Binoculares", 4483362458)

-- ==========================================
-- UTILIDADES Y MODELADO
-- ==========================================
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function buildBinocularModel(parent, isViewModel)
    local handle = Instance.new("Part")
    handle.Name = isViewModel and "PrimaryPart" or "Handle"
    handle.Size = Vector3.new(0.3, 0.2, 0.6)
    handle.Color = Color3.fromRGB(15, 15, 15)
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Massless = true 
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Anchored = isViewModel 
    handle.Parent = parent

    local leftCyl = Instance.new("Part")
    leftCyl.Name = "LeftBarrel"
    leftCyl.Shape = Enum.PartType.Cylinder
    leftCyl.Size = Vector3.new(1.2, 0.4, 0.4)
    leftCyl.Color = Color3.fromRGB(5, 5, 5)
    leftCyl.Material = Enum.Material.Plastic
    leftCyl.CFrame = handle.CFrame * CFrame.new(0, 0, -0.35)
    leftCyl.CanCollide = false
    leftCyl.Massless = true
    leftCyl.CanTouch = false
    leftCyl.CanQuery = false
    leftCyl.Anchored = isViewModel
    leftCyl.Parent = parent

    local rightCyl = Instance.new("Part")
    rightCyl.Name = "RightBarrel"
    rightCyl.Shape = Enum.PartType.Cylinder
    rightCyl.Size = Vector3.new(1.2, 0.4, 0.4)
    rightCyl.Color = Color3.fromRGB(5, 5, 5)
    rightCyl.Material = Enum.Material.Plastic
    rightCyl.CFrame = handle.CFrame * CFrame.new(0, 0, 0.35)
    rightCyl.CanCollide = false
    rightCyl.Massless = true
    rightCyl.CanTouch = false
    rightCyl.CanQuery = false
    rightCyl.Anchored = isViewModel
    rightCyl.Parent = parent

    if not isViewModel then
        local w1 = Instance.new("WeldConstraint")
        w1.Part0 = handle
        w1.Part1 = leftCyl
        w1.Parent = handle
        local w2 = Instance.new("WeldConstraint")
        w2.Part0 = handle
        w2.Part1 = rightCyl
        w2.Parent = handle
    else
        handle.Transparency = 1
        leftCyl.Transparency = 1
        rightCyl.Transparency = 1
    end

    return handle
end

-- ==========================================
-- LÓGICA PRINCIPAL
-- ==========================================
BinoTab:CreateButton({
   Name = "Equipar Binoculares [SCANNER]",
   Callback = function()
       local success, errorMessage = pcall(function()
           local character = Player.Character or Player.CharacterAdded:Wait()
           local playerGui = Player:WaitForChild("PlayerGui", 5)
           
           if Player.Backpack:FindFirstChild("Binoculars_ULTRA") or character:FindFirstChild("Binoculars_ULTRA") then
               if typeof(Rayfield) ~= "nil" then Rayfield:Notify({Title = "Error", Content = "Ya tienes los binoculares equipados.", Duration = 3}) end
               return
           end

           local tool = Instance.new("Tool")
           tool.Name = "Binoculars_ULTRA"
           tool.RequiresHandle = true
           tool.CanBeDropped = false
           tool.Grip = CFrame.new(0, -0.2, 0) * CFrame.Angles(0, math.pi/2, 0)

           buildBinocularModel(tool, false)

           -- UI SETUP
           if playerGui:FindFirstChild("BinoUltraUI") then playerGui.BinoUltraUI:Destroy() end
           local mainGui = Instance.new("ScreenGui")
           mainGui.Name = "BinoUltraUI"
           mainGui.ResetOnSpawn = false
           mainGui.Parent = playerGui

           local aimButton = Instance.new("TextButton")
           aimButton.Size = UDim2.new(0, 80, 0, 80)
           aimButton.Position = UDim2.new(0.5, 120, 0.75, 0)
           aimButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
           aimButton.BackgroundTransparency = 0.2
           aimButton.Text = "AIM"
           aimButton.TextColor3 = Color3.fromRGB(255, 200, 0)
           aimButton.Font = Enum.Font.GothamBlack
           aimButton.TextSize = 22
           Instance.new("UICorner", aimButton).CornerRadius = UDim.new(1, 0)
           aimButton.Visible = false
           aimButton.Parent = mainGui

           -- NUEVA MIRA CENTRAL PERFECTA
           local crosshair = Instance.new("ImageLabel")
           crosshair.Size = UDim2.new(0, 100, 0, 100) -- Tamaño ajustable para que no se estire
           crosshair.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centrado perfecto X y Y
           crosshair.AnchorPoint = Vector2.new(0.5, 0.5) -- Punto de anclaje exacto en el medio
           crosshair.BackgroundTransparency = 1
           crosshair.Image = "rbxassetid://18420284001"
           crosshair.Visible = false
           crosshair.Parent = mainGui

           -- PANEL DE ESCANEO TELEMÉTRICO
           local scanPanel = Instance.new("Frame")
           scanPanel.Size = UDim2.new(0, 300, 0, 200)
           scanPanel.Position = UDim2.new(0, 20, 0.5, -100)
           scanPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
           scanPanel.BackgroundTransparency = 0.3
           scanPanel.Visible = false
           scanPanel.Parent = mainGui
           Instance.new("UICorner", scanPanel).CornerRadius = UDim.new(0, 6)
           
           local scanText = Instance.new("TextLabel")
           scanText.Size = UDim2.new(1, -20, 1, -20)
           scanText.Position = UDim2.new(0, 10, 0, 10)
           scanText.BackgroundTransparency = 1
           scanText.TextXAlignment = Enum.TextXAlignment.Left
           scanText.TextYAlignment = Enum.TextYAlignment.Top
           scanText.TextColor3 = Color3.fromRGB(0, 255, 100)
           scanText.Font = Enum.Font.Code
           scanText.TextSize = 14
           scanText.TextWrapped = true
           scanText.Parent = scanPanel

           -- EFECTOS VISUALES DEL ESCÁNER
           local scannerHighlight = Instance.new("Highlight")
           scannerHighlight.FillColor = Color3.fromRGB(255, 0, 0)
           scannerHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
           scannerHighlight.FillTransparency = 0.4
           scannerHighlight.OutlineTransparency = 0
           scannerHighlight.Enabled = false
           scannerHighlight.Parent = mainGui

           local scanLine = Instance.new("Part")
           scanLine.Name = "TacticalScanLine"
           scanLine.Material = Enum.Material.Neon
           scanLine.Color = Color3.fromRGB(0, 150, 255)
           scanLine.Transparency = 1
           scanLine.Anchored = true
           scanLine.CanCollide = false
           scanLine.CanQuery = false
           scanLine.CastShadow = false
           scanLine.Parent = workspace

           -- SLIDERS
           local sliderZoomBg = Instance.new("TextButton")
           sliderZoomBg.Size = UDim2.new(0, 50, 0.6, 0)
           sliderZoomBg.Position = UDim2.new(1, -90, 0.2, 0)
           sliderZoomBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
           sliderZoomBg.BackgroundTransparency = 0.4
           sliderZoomBg.Text = ""
           sliderZoomBg.AutoButtonColor = false
           sliderZoomBg.Visible = false
           sliderZoomBg.Parent = mainGui
           Instance.new("UICorner", sliderZoomBg)

           local sliderZoomKnob = Instance.new("Frame")
           sliderZoomKnob.Size = UDim2.new(1, 0, 0, 35)
           sliderZoomKnob.Position = UDim2.new(0, 0, 1, -35)
           sliderZoomKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
           sliderZoomKnob.Active = false 
           sliderZoomKnob.Parent = sliderZoomBg
           Instance.new("UICorner", sliderZoomKnob)

           -- SYSTEM VARIABLES
           local isAiming = false
           local defaultFOV = 70
           local currentFOV = 70
           local minZoomLevel = 1.5
           local maxZoomLevel = 40 
           local targetZoomLevel = minZoomLevel 
           
           local targetZoomSliderY = 0
           local actualZoomSliderY = 0
           local draggingZoom = false
           
           local targetCamRotation = Vector2.new(0, 0)
           local currentCamRotation = Vector2.new(0, 0)
           
           local previousCameraMode = Player.CameraMode
           local previousCameraType = Camera.CameraType
           local renderConnection = nil
           local viewModel = nil
           local BinoDOF = nil
           
           local swayOffset = CFrame.identity
           local bobOffset = CFrame.identity
           
           -- INPUT HANDLERS
           local function updateZoomSlider(inputPos)
               local maxY = sliderZoomBg.AbsoluteSize.Y - sliderZoomKnob.AbsoluteSize.Y
               if maxY <= 0 then return end
               local relativeY = math.clamp(inputPos.Y - sliderZoomBg.AbsolutePosition.Y, 0, maxY)
               
               targetZoomSliderY = relativeY
               local percentage = relativeY / maxY
               targetZoomLevel = minZoomLevel + ((maxZoomLevel - minZoomLevel) * (1 - percentage))
           end

           sliderZoomBg.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingZoom = true
                   updateZoomSlider(input.Position)
               end
           end)

           UserInputService.InputEnded:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                   draggingZoom = false
               end
           end)
           
           UserInputService.InputChanged:Connect(function(input)
               if draggingZoom and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                   updateZoomSlider(input.Position)
               end

               if isAiming and not draggingZoom then
                   if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                       local delta = input.Delta
                       local fovRatio = currentFOV / defaultFOV
                       local finalMultiplier = (0.005 * fovRatio)
                       
                       targetCamRotation -= Vector2.new(delta.Y * finalMultiplier, delta.X * finalMultiplier)
                       targetCamRotation = Vector2.new(math.clamp(targetCamRotation.X, -math.rad(80), math.rad(80)), targetCamRotation.Y)
                   end
               end
           end)

           -- DESACTIVADOR DEL SCANNER
           local function clearScanner()
               scannerHighlight.Enabled = false
               scannerHighlight.Adornee = nil
               scanPanel.Visible = false
               scanLine.Transparency = 1
           end

           -- APUNTADO
           local function toggleAim()
               isAiming = not isAiming

               if isAiming then
                   crosshair.Visible = true
                   sliderZoomBg.Visible = true
                   
                   local maxY = sliderZoomBg.AbsoluteSize.Y - sliderZoomKnob.AbsoluteSize.Y
                   targetZoomSliderY = maxY
                   actualZoomSliderY = maxY
                   targetZoomLevel = minZoomLevel
                   
                   local pitch, yaw, roll = Camera.CFrame:ToOrientation()
                   targetCamRotation = Vector2.new(pitch, yaw)
                   currentCamRotation = Vector2.new(pitch, yaw)

                   previousCameraMode = Player.CameraMode
                   previousCameraType = Camera.CameraType
                   Player.CameraMode = Enum.CameraMode.LockFirstPerson
                   Camera.CameraType = Enum.CameraType.Scriptable 
                   
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
                   end
                   if viewModel then
                       for _, part in pairs(viewModel:GetDescendants()) do
                           if part:IsA("BasePart") then part.Transparency = 0 end
                       end
                   end

                   if not Lighting:FindFirstChild("UltraDOF") then
                       BinoDOF = Instance.new("DepthOfFieldEffect")
                       BinoDOF.Name = "UltraDOF"
                       BinoDOF.FocusDistance = 300 
                       BinoDOF.InFocusRadius = 15 
                       BinoDOF.NearIntensity = 0.9 
                       BinoDOF.FarIntensity = 0.2 
                       BinoDOF.Parent = Lighting
                   end
               else
                   crosshair.Visible = false
                   sliderZoomBg.Visible = false
                   clearScanner()
                   
                   if Lighting:FindFirstChild("UltraDOF") then Lighting.UltraDOF:Destroy() end
                   targetZoomLevel = 1
                   
                   Player.CameraMode = previousCameraMode
                   Camera.CameraType = previousCameraType 
                   
                   for _, part in pairs(tool:GetDescendants()) do
                       if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
                   end
                   if viewModel then
                       for _, part in pairs(viewModel:GetDescendants()) do
                           if part:IsA("BasePart") then part.Transparency = 1 end
                       end
                   end
               end
           end

           aimButton.MouseButton1Click:Connect(function() toggleAim() end)

           local function createViewModel()
               if viewModel then viewModel:Destroy() end
               viewModel = Instance.new("Model")
               viewModel.Name = "SurgicalViewModel"
               local primary = buildBinocularModel(viewModel, true)
               viewModel.PrimaryPart = primary
               viewModel.Parent = Camera
               return viewModel
           end

           -- RENDER LOOP (Animaciones de Cámara y Raycast Scanner)
           tool.Equipped:Connect(function()
               aimButton.Visible = true 
               createViewModel()

               renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
                   local smoothSpeed = math.clamp(15 * deltaTime, 0, 1)

                   local targetFOV = isAiming and (defaultFOV / targetZoomLevel) or defaultFOV
                   currentFOV = lerp(currentFOV, targetFOV, smoothSpeed)
                   Camera.FieldOfView = currentFOV
                   
                   local fovRatio = currentFOV / defaultFOV 

                   if isAiming then
                       actualZoomSliderY = lerp(actualZoomSliderY, targetZoomSliderY, smoothSpeed)
                       sliderZoomKnob.Position = UDim2.new(0, 0, 0, actualZoomSliderY)
                       
                       local camSmoothSpeed = math.clamp(20 * deltaTime, 0, 1)
                       currentCamRotation = currentCamRotation:Lerp(targetCamRotation, camSmoothSpeed)
                       
                       local char = Player.Character
                       if char and char:FindFirstChild("Head") then
                           local headPos = char.Head.Position + Vector3.new(0, 0.5, 0)
                           Camera.CFrame = CFrame.new(headPos) * CFrame.fromOrientation(currentCamRotation.X, currentCamRotation.Y, 0)
                           
                           local rootPart = char:FindFirstChild("HumanoidRootPart")
                           if rootPart then
                               rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
                           end
                       end

                       -- ==========================================
                       -- SISTEMA DE ESCANEO AVANZADO
                       -- ==========================================
                       -- Solo escanea si se ha aplicado zoom (desactivado si el zoom está al máximo alejamiento)
                       if targetZoomLevel > (minZoomLevel + 0.5) then
                           local rayParams = RaycastParams.new()
                           rayParams.FilterType = Enum.RaycastFilterType.Exclude
                           rayParams.FilterDescendantsInstances = {Player.Character, viewModel, tool, scanLine}

                           local ray = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 2000, rayParams)

                           if ray and ray.Instance then
                               local hitPart = ray.Instance
                               local model = hitPart:FindFirstAncestorOfClass("Model")
                               local targetPlayer = model and Players:GetPlayerFromCharacter(model)

                               if targetPlayer then
                                   -- ESP ROJO EN LA PARTE EXACTA
                                   scannerHighlight.Adornee = hitPart
                                   scannerHighlight.Enabled = true

                                   -- LÍNEA DE ESCANEO AZUL ANIMADA
                                   scanLine.Transparency = 0.2
                                   local maxScale = math.max(hitPart.Size.X, hitPart.Size.Z) + 0.3
                                   scanLine.Size = Vector3.new(maxScale, 0.05, maxScale)
                                   
                                   local oscSpeed = 10
                                   local yOffset = math.sin(os.clock() * oscSpeed) * (hitPart.Size.Y / 2)
                                   scanLine.CFrame = hitPart.CFrame * CFrame.new(0, yOffset, 0)

                                   -- ACTUALIZACIÓN DE TELEMETRÍA (UI)
                                   scanPanel.Visible = true
                                   local dist = math.floor((Camera.CFrame.Position - hitPart.Position).Magnitude)
                                   
                                   local itemId = "Desconocido (Base Part)"
                                   local catalogName = "N/A"
                                   
                                   if hitPart:IsA("MeshPart") and hitPart.MeshId ~= "" then
                                       itemId = hitPart.MeshId
                                       catalogName = "MeshPart/Accessory"
                                   elseif hitPart.Parent:IsA("Accessory") then
                                       catalogName = hitPart.Parent.Name
                                       local handle = hitPart.Parent:FindFirstChild("Handle")
                                       if handle and handle:FindFirstChildWhichIsA("SpecialMesh") then
                                           itemId = handle:FindFirstChildWhichIsA("SpecialMesh").MeshId
                                       end
                                   end

                                   local posX, posY, posZ = math.floor(hitPart.Position.X), math.floor(hitPart.Position.Y), math.floor(hitPart.Position.Z)
                                   
                                   scanText.Text = string.format(
                                       "[ SYSTEM SCAN ACTIVE ]\n\nJUGADOR: %s\nDISTANCIA: %d metros\nPARTE APUNTADA: %s\nID TIENDA: %s\nCATÁLOGO: %s\nPOSICIÓN (XYZ): %d, %d, %d\n\nRUTA WORKSPACE:\n%s",
                                       targetPlayer.Name, dist, hitPart.Name, itemId, catalogName, posX, posY, posZ, hitPart:GetFullName()
                                   )
                               else
                                   clearScanner()
                               end
                           else
                               clearScanner()
                           end
                       else
                           clearScanner() -- Se desactiva el escáner si alejas la cámara al máximo
                       end
                   end

                   local mouseDelta = UserInputService:GetMouseDelta()
                   local char = Player.Character
                   local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                   local humanoid = char and char:FindFirstChild("Humanoid")

                   local swayMult = isAiming and (0.001 * fovRatio) or 0.0015
                   local targetSway = CFrame.Angles(-mouseDelta.Y * swayMult, -mouseDelta.X * swayMult, 0)
                   swayOffset = swayOffset:Lerp(targetSway, smoothSpeed)

                   local targetBob = CFrame.identity
                   if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                       local speed = rootPart.AssemblyLinearVelocity.Magnitude
                       local bobFreq = speed * 0.4
                       local bobAmp = isAiming and (0.015 * fovRatio) or 0.03
                       local bobX = math.cos(os.clock() * bobFreq) * bobAmp
                       local bobY = math.abs(math.sin(os.clock() * bobFreq)) * bobAmp
                       targetBob = CFrame.new(bobX, bobY, 0)
                   end
                   bobOffset = bobOffset:Lerp(targetBob, smoothSpeed)

                   if viewModel and viewModel.PrimaryPart then
                       local baseOffset = isAiming 
                           and CFrame.new(0, -0.4, -0.7) * CFrame.Angles(0, math.pi/2, 0)
                           or CFrame.new(0.5, -0.8, -1.2) * CFrame.Angles(0, (math.pi/12) + (math.pi/2), 0)
                           
                       local finalCFrame = Camera.CFrame * baseOffset * swayOffset * bobOffset
                       viewModel:PivotTo(finalCFrame)
                   end
               end)
           end)

           tool.Unequipped:Connect(function()
               aimButton.Visible = false
               if isAiming then toggleAim() end
               if renderConnection then renderConnection:Disconnect() renderConnection = nil end
               if viewModel then viewModel:Destroy() viewModel = nil end
               if scanLine then scanLine:Destroy() end -- Destruir escáner físico por seguridad
               Camera.FieldOfView = defaultFOV
           end)

           tool.Parent = Player.Backpack
           if typeof(Rayfield) ~= "nil" then
               Rayfield:Notify({Title = "SISTEMA INSTALADO", Content = "Binoculares con Escáner Térmico Integrado listos.", Duration = 4})
           end
       end)

       if not success then
           warn("SCANNER ERROR: " .. tostring(errorMessage))
           if typeof(Rayfield) ~= "nil" then
               Rayfield:Notify({ Title = "ERROR CRÍTICO", Content = tostring(errorMessage), Duration = 6 })
           end
       end
   end,
})
