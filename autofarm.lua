-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Crystal Miner Hub PRO",
    LoadingTitle = "Cargando Script...",
    LoadingSubtitle = "Delta iOS",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, 
       FileName = "AutoMiner"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink", 
       RememberJoins = true 
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458) 

-- =======================================================================
-- VARIABLES Y SERVICIOS DEL JUEGO
-- =======================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser") -- Añadido para reforzar clicks
local player = Players.LocalPlayer

-- Variables controladas por la UI (Auto Mine)
local targetTiers = {"Common"}   
local mining = false          

-- Variables controladas por la UI (Manual Navigation)
local manualTier = "Common"
local manualIndex = 0
local manualNavActive = false
local ScreenGui = nil

local tierMapping = {
    ["Common"]    = "T1",
    ["Uncommon"]  = "T2",
    ["Rare"]      = "T3",
    ["Epic"]      = "T4",
    ["Legendary"] = "T5",
    ["Mythic"]    = "T6"
}

-- Mapeo de colores para el Escáner Cúbico por nivel
local colorMapping = {
    ["T1"] = Color3.fromRGB(0, 102, 255),   -- Common: Azul
    ["T2"] = Color3.fromRGB(0, 255, 255),   -- Uncommon: Celeste
    ["T3"] = Color3.fromRGB(0, 255, 0),     -- Rare: Verde
    ["T4"] = Color3.fromRGB(255, 0, 255),   -- Epic: Magenta/Rosa
    ["T5"] = Color3.fromRGB(255, 127, 0),   -- Legendary: Naranja
    ["T6"] = Color3.fromRGB(163, 73, 164)   -- Mythic: Purple
}

local stickConnection = nil
local noclipConnection = nil
local temporaryBlacklist = {} 
local maxTimePerCrystal = 4.0 
local autoEquip = true       

-- =======================================================================
-- FUNCIONES NUEVAS DE SOPORTE (NOCLIP & AUTO-EQUIP)
-- =======================================================================
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function verifyAndEquipTool()
    if not autoEquip then return end
    local char = player.Character
    if not char then return end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return end -- Ya tiene una herramienta en mano
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then 
            tool.Parent = char 
        end
    end
end

-- =======================================================================
-- FUNCIONES PRINCIPALES
-- =======================================================================
local function firePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif fire_proximity_prompt then
        fire_proximity_prompt(prompt)
    else
        warn("No prompt firing function available")
    end
end

local function stopStick()
    if stickConnection then
        stickConnection:Disconnect()
        stickConnection = nil
    end
    disableNoclip()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startStick(part)
    stopStick()
    enableNoclip() 
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
    end
    
    stickConnection = RunService.Heartbeat:Connect(function()
        -- Modificado para que no se apague si la navegación manual está activa
        if (not mining and not manualNavActive) or not part or not part.Parent then
            stopStick()
            return
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Posicionado atrás (2.2 studs) y mirando de frente
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function mineCrystal(crystal)
    local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    local part = crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal
    if not part then return false end

    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    verifyAndEquipTool() 

    -- Teletransporte inicial por detrás
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
    startStick(part)

    -- CREACIÓN DEL ESCÁNER CÚBICO VISUAL
    local tierCode = string.upper(crystal.Name):match("(T[1-6])")
    local scanColor = colorMapping[tierCode] or Color3.fromRGB(255, 255, 255)
    
    local scannerBox = Instance.new("SelectionBox")
    scannerBox.Name = "LiveCrystalScanner"
    scannerBox.Color3 = scanColor
    scannerBox.LineThickness = 0.04 
    scannerBox.SurfaceColor3 = scanColor
    scannerBox.SurfaceTransparency = 0.85 
    scannerBox.Adornee = crystal
    scannerBox.Parent = crystal

    -- MICRO-PAUSA CLAVE: Dejamos que el servidor registre el pico en la mano antes de spamear
    task.wait(0.15)

    local startTime = os.clock()
    
    -- BUCLE DE ATAQUE REFORZADO Y ULTRA RÁPIDO
    while mining and crystal and crystal.Parent do
        if os.clock() - startTime > maxTimePerCrystal then
            temporaryBlacklist[crystal] = os.clock() + 8.0 
            break
        end
        
        -- 1. Dispara la interacción normal del cristal
        if prompt and prompt.Parent then
            firePrompt(prompt)
        end

        -- 2. Activa forzadamente el pico para asegurar que el daño empiece siempre
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        -- 3. Click virtual de respaldo (opcional, extra seguridad para algunos juegos)
        VirtualUser:ClickButton1(Vector2.new(0, 0))

        -- Reducido de 0.3 a 0.03 para velocidad ametralladora
        task.wait(0.03)
    end

    -- LIMPIEZA AUTOMÁTICA DEL ESCÁNER AL TERMINAR
    if scannerBox then
        scannerBox:Destroy()
    end

    stopStick()
    return true
end

local isAutoMining = false
local function autoMine()
    if isAutoMining then return end
    isAutoMining = true

    while mining do
        local codes = {}
        for _, name in ipairs(targetTiers) do
            local code = tierMapping[name]
            if code then table.insert(codes, code) end
        end
        if #codes == 0 then
            task.wait(0.1) 
            continue
        end

        local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
        if not crystalFolder then
            task.wait(0.1) 
            continue
        end

        local char = player.Character
        if not char then
            task.wait(0.1)
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.1)
            continue
        end

        local bestCrystal = nil
        local bestDist = math.huge

        for _, crystal in ipairs(crystalFolder:GetChildren()) do
            local cooldown = temporaryBlacklist[crystal]
            if cooldown and os.clock() < cooldown then continue end

            local tierCode = string.upper(crystal.Name):match("(T[1-6])")
            if tierCode and table.find(codes, tierCode) then
                local part = crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal
                if part then
                    local dist = (hrp.Position - part.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestCrystal = crystal
                    end
                end
            end
        end

        if bestCrystal then
            mineCrystal(bestCrystal)
        else
            task.wait(0.1) 
        end
    end
    isAutoMining = false
end

-- =======================================================================
-- LÓGICA DE NAVEGACIÓN MANUAL (BOTONES FLOTANTES)
-- =======================================================================
local function getCrystalsOfManualTier()
    local code = tierMapping[manualTier]
    local list = {}
    local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
    
    if crystalFolder then
        for _, crystal in ipairs(crystalFolder:GetChildren()) do
            local tierCode = string.upper(crystal.Name):match("(T[1-6])")
            if tierCode == code then
                table.insert(list, crystal)
            end
        end
    end
    
    -- Clasificación por posición X fija para que la lista mantenga un orden estable al navegar
    table.sort(list, function(a, b)
        local pA = a:IsA("Model") and (a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")) or a
        local pB = b:IsA("Model") and (b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")) or b
        if pA and pB then return pA.Position.X < pB.Position.X end
        return false
    end)
    
    return list
end

local function navigateManualCrystal(direction)
    if not manualNavActive then return end
    local list = getCrystalsOfManualTier()
    
    if #list == 0 then
        Rayfield:Notify({
            Title = "Manual Nav",
            Content = "No hay cristales de esta categoría en el mapa.",
            Duration = 2,
            Image = 4483362458
        })
        stopStick()
        return
    end

    if manualIndex == 0 then
        manualIndex = 1
    else
        manualIndex = manualIndex + direction
        if manualIndex > #list then
            manualIndex = 1
        elseif manualIndex < 1 then
            manualIndex = #list
        end
    end

    local targetCrystal = list[manualIndex]
    if targetCrystal and targetCrystal.Parent then
        local part = targetCrystal:IsA("Model") and (targetCrystal.PrimaryPart or targetCrystal:FindFirstChildWhichIsA("BasePart")) or targetCrystal
        local char = player.Character
        if part and char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                verifyAndEquipTool()
                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
                startStick(part)
                
                -- Efecto visual temporal para saber cuál estás minando manualmente
                local tierCode = string.upper(targetCrystal.Name):match("(T[1-6])")
                local scanColor = colorMapping[tierCode] or Color3.fromRGB(255, 255, 255)
                
                local mBox = Instance.new("SelectionBox")
                mBox.Name = "ManualCrystalScanner"
                mBox.Color3 = scanColor
                mBox.LineThickness = 0.04
                mBox.SurfaceColor3 = scanColor
                mBox.SurfaceTransparency = 0.85
                mBox.Adornee = targetCrystal
                mBox.Parent = targetCrystal
                
                task.spawn(function()
                    while manualNavActive and targetCrystal and targetCrystal.Parent and stickConnection do
                        task.wait(0.2)
                    end
                    if mBox then mBox:Destroy() end
                end)
            end
        end
    end
end

local function createFloatingUI()
    if ScreenGui then ScreenGui:Destroy() end
    
    local targetParent = game:GetService("CoreGui") or player:FindFirstChildOfClass("PlayerGui")
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManualNavUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = targetParent
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 55)
    Frame.Position = UDim2.new(0.5, -110, 0.82, -27)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Frame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 102, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = Frame
    
    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 95, 0, 38)
    BackBtn.Position = UDim2.new(0, 10, 0.5, -19)
    BackBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    BackBtn.Text = "◀ Atrás"
    BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackBtn.Font = Enum.Font.SourceSansBold
    BackBtn.TextSize = 15
    BackBtn.BorderSizePixel = 0
    BackBtn.Parent = Frame
    
    local UICornerBack = Instance.new("UICorner")
    UICornerBack.CornerRadius = UDim.new(0, 6)
    UICornerBack.Parent = BackBtn
    
    local NextBtn = Instance.new("TextButton")
    NextBtn.Size = UDim2.new(0, 95, 0, 38)
    NextBtn.Position = UDim2.new(1, -105, 0.5, -19)
    NextBtn.BackgroundColor3 = Color3.fromRGB(0, 102, 255)
    NextBtn.Text = "Siguiente ▶"
    NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NextBtn.Font = Enum.Font.SourceSansBold
    NextBtn.TextSize = 15
    NextBtn.BorderSizePixel = 0
    NextBtn.Parent = Frame
    
    local UICornerNext = Instance.new("UICorner")
    UICornerNext.CornerRadius = UDim.new(0, 6)
    UICornerNext.Parent = NextBtn
    
    BackBtn.MouseButton1Click:Connect(function()
        navigateManualCrystal(-1)
    end)
    
    NextBtn.MouseButton1Click:Connect(function()
        navigateManualCrystal(1)
    end)
end

local function removeFloatingUI()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
end

-- =======================================================================
-- ELEMENTOS DE LA INTERFAZ (UI)
-- =======================================================================

MainTab:CreateSection("Automatic Farming")

MainTab:CreateToggle({
    Name = "Enable Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle", 
    Callback = function(Value)
        mining = Value
        if mining then
            if manualNavActive then manualNavActive = false end -- Evitar conflictos de fijación
            table.clear(temporaryBlacklist)
            Rayfield:Notify({
                Title = "Auto Miner PRO",
                Content = "Modo ráfaga activado",
                Duration = 2,
                Image = 4483362458,
            })
            task.spawn(autoMine)
        else
            stopStick()
            Rayfield:Notify({
                Title = "Auto Miner",
                Content = "Minería pausada",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Select Crystal Tiers",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    CurrentOption = {"Common"},
    MultipleOptions = true,
    Flag = "TiersDropdown",
    Callback = function(Options)
        targetTiers = Options
    end,
})

-- =======================================================================
-- NUEVA SECCIÓN: NAVEGACIÓN MANUAL (SIN AUTO-CLICK)
-- =======================================================================
MainTab:CreateSection("Manual Navigation (No Auto Click)")

MainTab:CreateToggle({
    Name = "Enable Manual Navigation UI",
    CurrentValue = false,
    Flag = "ManualNavToggle",
    Callback = function(Value)
        manualNavActive = Value
        if manualNavActive then
            if mining then mining = false end -- Pausar automine si está encendido
            manualIndex = 0
            createFloatingUI()
            Rayfield:Notify({
                Title = "Manual Nav PRO",
                Content = "Botones flotantes creados en pantalla.",
                Duration = 3,
                Image = 4483362458,
            })
        else
            removeFloatingUI()
            stopStick()
            Rayfield:Notify({
                Title = "Manual Nav",
                Content = "Botones flotantes removidos.",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Manual Target Tier",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    CurrentOption = "Common",
    MultipleOptions = false,
    Flag = "ManualTierDropdown",
    Callback = function(Option)
        -- Manejar tanto si Rayfield devuelve una string directa o una tabla
        manualTier = type(Option) == "table" and Option[1] or Option
        manualIndex = 0 -- Resetear la secuencia de avance si cambias de categoría
    end,
})

MainTab:CreateSection("Global Settings")

MainTab:CreateToggle({
    Name = "Auto-Equip Tools",
    CurrentValue = true,
    Flag = "AutoEquipToggle",
    Callback = function(Value)
        autoEquip = Value
    end,
})

MainTab:CreateSlider({
    Name = "Max Time per Crystal (Alert Skip)",
    Info = "Segundos para ignorar y pasar al siguiente si sale una alerta.",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 4,
    Flag = "TimeoutSlider",
    Callback = function(Value)
        maxTimePerCrystal = Value
    end,
})

print("Rayfield Hub Cargado Completamente. Sistema Manual Integrado de forma fluida.")
