-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Crystal Miner Hub",
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
local currentPos = nil

-- =======================================================================
-- FUNCIONES PRINCIPALES
-- =======================================================================
local function firePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif fire_proximity_prompt then
        fire_proximity_prompt(prompt)
    else
        -- Fallback de seguridad en caso de que el exploit no tenga la función
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end
end

local function stopStick()
    if stickConnection then
        stickConnection:Disconnect()
        stickConnection = nil
    end
    currentPos = nil
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startStick(part)
    stopStick()
    -- Ajuste fino de la altura para no quedarse atascado en el suelo
    currentPos = part.Position + Vector3.new(0, 2, 0) 
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end
    end
    
    stickConnection = RunService.Heartbeat:Connect(function()
        if not mining or not currentPos then
            stopStick()
            return
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(currentPos)
            -- Matar la inercia para evitar rebotes o desincronización
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
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

    -- Teletransporte inicial y fijación
    local targetPos = part.Position + Vector3.new(0, 2, 0)
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0,0,0)
    
    startStick(part)
    
    -- Darle un microsegundo al servidor para registrar tu nueva posición
    task.wait(0.05)

    -- Loop dinámico: Golpeará sin parar hasta que el cristal deje de existir
    while mining and crystal and crystal.Parent and prompt and prompt.Parent do
        firePrompt(prompt)
        task.wait(0.05) -- Reacción ultrarrápida entre golpes
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
            task.wait(0.5) -- Reducido para mejor respuesta si el usuario cambia settings
            continue
        end

        local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
        if not crystalFolder then
            task.wait(0.5)
            continue
        end

        local char = player.Character
        if not char then
            task.wait(0.5)
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.5)
            continue
        end

        local bestCrystal = nil
        local bestDist = math.huge

        for _, crystal in ipairs(crystalFolder:GetChildren()) do
            local tierCode = string.upper(crystal.Name):match("(T[1-6])")
            if tierCode and table.find(codes, tierCode) then
                -- Solo considerar cristales que tengan un prompt activo para no quedarse bugeado
                local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
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
        end

        if bestCrystal then
            mineCrystal(bestCrystal)
        else
            -- ¡Clave para la rapidez! Si no hay cristales, busca casi al instante en vez de esperar 2s
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
            Rayfield:Notify({
                Title = "Auto Miner",
                Content = "Minería iniciada",
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

print("Rayfield Hub Cargado (Versión Optimizada). This is for you man!")
