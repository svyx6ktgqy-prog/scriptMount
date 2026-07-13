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
local player = Players.LocalPlayer

-- Variables controladas por la UI
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

local stickConnection = nil
local noclipConnection = nil
local temporaryBlacklist = {} -- Lista de espera para regresar a diamantes bugeados
local maxTimePerCrystal = 4.0 -- Tiempo de escape configurable
local autoEquip = true       -- Equipar herramienta automáticamente

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
    if char:FindFirstChildOfClass("Tool") then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then 
            tool.Parent = char 
        end
    end
end

-- =======================================================================
-- FUNCIONES PRINCIPALES (SISTEMA ORIGINAL OPTIMIZADO)
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
    enableNoclip() -- Activamos noclip para el nuevo posicionamiento
    
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
            -- NUEVO: Posicionado un poco atrás (2.2 studs) y mirando de frente al diamante
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

    verifyAndEquipTool() -- Asegurar herramienta antes de viajar

    -- Teletransporte inicial respetando la distancia prudente por detrás
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 1.2, 2.2), part.Position)
    startStick(part)

    local startTime = os.clock()
    local attempts = 0
    
    -- METODO DE GOLPEO ORIGINAL INTACTO
    while attempts < 5 and mining and crystal and crystal.Parent do
        -- NUEVO: Si sale una alerta o tarda demasiado, lo salta temporalmente para no trabarse
        if os.clock() - startTime > maxTimePerCrystal then
            temporaryBlacklist[crystal] = os.clock() + 8.0 -- Reintentar en 8 segundos
            break
        end
        
        firePrompt(prompt)
        attempts += 1
        task.wait(0.3)
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
            task.wait(0.1) -- Reducido de 2s a 0.1s para evitar congelamientos
            continue
        end

        local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
        if not crystalFolder then
            task.wait(0.1) -- Reducido de 1s a 0.1s
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
            -- NUEVO: Filtro para ignorar temporalmente los diamantes con alertas
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
            task.wait(0.1) -- Reducido de 2s a 0.1s para fluidez instantánea
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
                Title = "Auto Miner",
                Content = "Minería iniciada a distancia segura",
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

-- NUEVOS CONTROLES AGREGADOS EN LA INTERFAZ
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

print("Rayfield Hub Cargado. Versión Híbrida Optimizada.")
