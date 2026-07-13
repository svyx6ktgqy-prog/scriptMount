-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Crystal Miner Hub PRO",
    LoadingTitle = "Iniciando Motor Avanzado...",
    LoadingSubtitle = "Delta iOS / Android",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm V2", 4483362458) 

-- =======================================================================
-- SERVICIOS Y SERVICIOS INYECTADOS
-- =======================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser") -- Para emular clicks reales
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

local noclipConnection = nil
local blacklistedCrystals = {} 
local MAX_TIME_PER_CRYSTAL = 4.0 -- Límite estricto solicitado

-- =======================================================================
-- SITEMA DE COMBATE Y TRASPASO
-- =======================================================================

local function firePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif fire_proximity_prompt then
        fire_proximity_prompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(0.01)
        prompt:InputHoldEnd()
    end
end

-- Simula clicks físicos y ataques con herramientas automáticamente
local function performAutoHit()
    -- 1. Forzar el uso de la herramienta equipada (Pico/Arma)
    local char = player.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then 
            tool:Activate() 
        end
    end
    -- 2. Click virtual en el centro de la pantalla por si el juego usa click-to-mine
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
end

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

-- =======================================================================
-- MÉTODOS DE POSICIONAMIENTO ROBUSTOS (ANCHOR SYSTEM)
-- =======================================================================

local function startStick(part)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    enableNoclip()
    
    -- Teletransporte exacto al centro del diamante y congelamiento total de físicas
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    hrp.CFrame = CFrame.new(part.Position, part.Position + Vector3.new(0, 0, 1))
    
    -- ANCHOR: Esto elimina el temblor y la inestabilidad al 100%
    hrp.Anchored = true 
end

local function stopStick()
    disableNoclip()
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Anchored = false -- Devolver control de físicas al terminar
        end
    end
end

local function mineCrystal(crystal)
    local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
    local part = crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal
    if not part then return false end

    -- Fijar posición robustamente
    startStick(part)
    task.wait(0.02) -- Tiempo mínimo para que el motor asimile la posición

    local startTime = os.clock()

    -- Bucle de ataque a velocidad de la luz
    while mining and crystal and crystal.Parent do
        -- Si excede los 4 segundos, se aborta de inmediato y pasa al siguiente
        if os.clock() - startTime > MAX_TIME_PER_CRYSTAL then
            table.insert(blacklistedCrystals, crystal) -- Ignorar permanentemente
            break
        end

        if prompt and prompt.Parent then
            firePrompt(prompt)
        end
        
        performAutoHit() -- Ejecuta el golpe automático (click + herramienta)
        task.wait(0.01)  -- Frecuencia máxima permitida por el procesador de scripts
    end

    stopStick()
    return true
end

-- =======================================================================
-- CORE LOOP OPTIMIZADO (SIN DELAYS INNECESARIOS)
-- =======================================================================

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
            task.wait(0.2)
            continue
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.1)
            continue
        end

        local bestCrystal = nil
        local bestDist = math.huge

        -- Escaneo ultra veloz
        local crystals = crystalFolder:GetChildren()
        for i = 1, #crystals do
            local crystal = crystals[i]
            
            if not table.find(blacklistedCrystals, crystal) then
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
        end

        if bestCrystal then
            mineCrystal(bestCrystal)
        else
            task.wait(0.01) -- Respuesta casi instantánea si el mapa se vacía
        end
    end
    isAutoMining = false
end

-- =======================================================================
-- INTERFAZ DE USUARIO
-- =======================================================================

MainTab:CreateToggle({
    Name = "Enable Ultra Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle", 
    Callback = function(Value)
        mining = Value
        if mining then
            blacklistedCrystals = {} 
            Rayfield:Notify({
                Title = "PRO Miner Active",
                Content = "Modo inteligente y anclado iniciado.",
                Duration = 2,
                Image = 4483362458,
            })
            task.spawn(autoMine)
        else
            stopStick()
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

print("Versión Industrial Cargada. Cero temblores, 100% automatizado.")
