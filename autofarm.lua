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
local currentPos = nil
local blacklistedCrystals = {} -- Lista para ignorar cristales que den error/alerta
local MAX_TIME_PER_CRYSTAL = 10 -- Segundos antes de saltar a otro diamante si da alerta

-- =======================================================================
-- FUNCIONES PRINCIPALES E INTELIGENCIA
-- =======================================================================

local function firePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif fire_proximity_prompt then
        fire_proximity_prompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration or 0.1)
        prompt:InputHoldEnd()
    end
end

-- Activa Noclip para traspasar paredes y obstáculos
local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
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

local function stopStick()
    if stickConnection then
        stickConnection:Disconnect()
        stickConnection = nil
    end
    currentPos = nil
    disableNoclip()
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startStick(part)
    stopStick()
    enableNoclip() -- Traspasar paredes activado
    
    -- Centrado absoluto: Misma posición exacta del diamante
    currentPos = part.Position 
    
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

    -- Teletransporte inicial con centrado exacto
    hrp.CFrame = CFrame.new(part.Position)
    hrp.Velocity = Vector3.new(0,0,0)
    
    startStick(part)
    task.wait(0.05)

    local startTime = os.clock()

    -- Loop de minado con Inteligencia Anti-Stuck
    while mining and crystal and crystal.Parent and prompt and prompt.Parent do
        firePrompt(prompt)
        task.wait(0.05) 
        
        -- Si lleva más del tiempo máximo, significa que hay una ventana de alerta o no tienes nivel
        if os.clock() - startTime > MAX_TIME_PER_CRYSTAL then
            table.insert(blacklistedCrystals, crystal)
            break -- Rompe el ciclo y salta al siguiente
        end
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
            task.wait(0.5) 
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
            -- Ignorar cristales en la lista negra (los que dieron alerta)
            if table.find(blacklistedCrystals, crystal) then continue end

            local tierCode = string.upper(crystal.Name):match("(T[1-6])")
            if tierCode and table.find(codes, tierCode) then
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
            -- Limpiamos la lista negra al iniciar para darle otra oportunidad a los cristales
            blacklistedCrystals = {} 
            Rayfield:Notify({
                Title = "Smart Miner",
                Content = "Minería inteligente iniciada",
                Duration = 2,
                Image = 4483362458,
            })
            task.spawn(autoMine)
        else
            stopStick()
            Rayfield:Notify({
                Title = "Smart Miner",
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

print("Smart Miner Cargado. ¡Disfruta el farmeo rápido!")
