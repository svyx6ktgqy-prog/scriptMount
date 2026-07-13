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
local VirtualUser = game:GetService("VirtualUser") 
local player = Players.LocalPlayer

local targetTiers = {"Common"}   
local mining = false          

local tierMapping = {
    ["Common"]    = "T1",
    ["Uncommon"]  = "T2",
    ["Rare"]      = "T3",
    ["Epic"]      = "T4",
    ["Legendary"] = "T5",
    ["Mythic"]    = "T6"
}

local colorMapping = {
    ["T1"] = Color3.fromRGB(0, 102, 255),   -- Common: Azul
    ["T2"] = Color3.fromRGB(0, 255, 255),   -- Uncommon: Celeste
    ["T3"] = Color3.fromRGB(0, 255, 0),     -- Rare: Verde
    ["T4"] = Color3.fromRGB(255, 0, 255),   -- Epic: Magenta/Rosa
    ["T5"] = Color3.fromRGB(255, 127, 0),   -- Legendary: Naranja
    ["T6"] = Color3.fromRGB(163, 73, 164)   -- Mythic: Purple
}

-- Multiplicadores de tiempo especiales para que no abandone a los gigantes
local timeMultipliers = {
    ["T1"] = 1,
    ["T2"] = 1,
    ["T3"] = 1,
    ["T4"] = 1.5,
    ["T5"] = 6,  -- 6x más de tiempo para Legendarios
    ["T6"] = 12  -- 12x más de tiempo para Míticos
}

local stickConnection = nil
local noclipConnection = nil
local temporaryBlacklist = {} 
local maxTimePerCrystal = 4.0 
local autoEquip = true       

-- =======================================================================
-- FUNCIONES DE SOPORTE
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
    if currentTool then return end 
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then 
            tool.Parent = char 
        end
    end
end

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
        if not mining or not part or not part.Parent then
            stopStick()
            return
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end)
end

-- =======================================================================
-- FUNCIÓN PRINCIPAL DE MINERÍA (INTELIGENCIA MEJORADA)
-- =======================================================================
local function mineCrystal(crystal)
    local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    local part = prompt.Parent:IsA("BasePart") and prompt.Parent or (crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal)
    if not part then return false end

    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    verifyAndEquipTool() 

    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
    startStick(part)

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

    task.wait(0.15)
    local startTime = os.clock()
    
    -- SISTEMA DE INTELIGENCIA Y RESPIRO
    local isHighTier = (tierCode == "T5" or tierCode == "T6")
    local timeLimit = maxTimePerCrystal * (timeMultipliers[tierCode] or 1)
    local clickDelay = isHighTier and 0.05 or 0.03 -- Ritmo distinto para evitar saturación
    local hitCount = 0
    
    while mining and crystal and crystal.Parent do
        if os.clock() - startTime > timeLimit then
            temporaryBlacklist[crystal] = os.clock() + 10.0 -- Lo ignora un rato si en serio se bugeó
            break
        end
        
        if prompt and prompt.Parent then
            pcall(function()
                prompt.RequiresLineOfSight = false 
                if prompt.MaxActivationDistance < 50 then
                    prompt.MaxActivationDistance = 50 
                end
            end)
            firePrompt(prompt)
        end

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        
        VirtualUser:ClickButton1(Vector2.new(0, 0))

        -- EL "RESPIRO": Si es Mítico/Legendario, descansa un microsegundo cada 40 golpes
        hitCount = hitCount + 1
        if isHighTier and hitCount % 40 == 0 then
            task.wait(0.4) -- Deja que el servidor procese el daño
        else
            task.wait(clickDelay)
        end
    end

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
                local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
                local part = prompt and prompt.Parent or (crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal)
                
                if part and part:IsA("BasePart") then
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
-- ELEMENTOS DE LA INTERFAZ (UI)
-- =======================================================================

MainTab:CreateToggle({
    Name = "Enable Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle", 
    Callback = function(Value)
        mining = Value
        if mining then
            table.clear(temporaryBlacklist)
            Rayfield:Notify({
                Title = "Auto Miner PRO",
                Content = "Inteligencia para Míticos activada",
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
        table.clear(temporaryBlacklist) -- NUEVO: Refresca el mod y olvida los errores al cambiar de tier
    end,
})

MainTab:CreateToggle({
    Name = "Auto-Equip Tools",
    CurrentValue = true,
    Flag = "AutoEquipToggle",
    Callback = function(Value)
        autoEquip = Value
    end,
})

MainTab:CreateSlider({
    Name = "Base Timeout (T1-T4)",
    Info = "Tiempo base para abandonar. T5 y T6 tienen tiempo extendido automático.",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 4,
    Flag = "TimeoutSlider",
    Callback = function(Value)
        maxTimePerCrystal = Value
    end,
})

print("Rayfield Hub Cargado. Sistema de estamina y refresco dinámico implementado.")
