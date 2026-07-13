-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Crystal Miner Hub PREMIUM V3",
    LoadingTitle = "Iniciando Motor Físico Pro...",
    LoadingSubtitle = "Delta iOS / Android",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm Pro", 4483362458) 

-- =======================================================================
-- CONFIGURACIÓN GLOBAL Y CONTROL DE ESTADO
-- =======================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Config = {
    Mining = false,
    TargetTiers = {"Common"},
    MaxTimePerCrystal = 4.0, -- Límite estricto para pasar al siguiente
    AutoEquip = true
}

local tierMapping = {
    ["Common"]    = "T1",
    ["Uncommon"]  = "T2",
    ["Rare"]      = "T3",
    ["Epic"]      = "T4",
    ["Legendary"] = "T5",
    ["Mythic"]    = "T6"
}

-- Lista de espera temporal para regresar a los diamantes después
local temporaryBlacklist = {} 
local noclipConnection = nil

-- =======================================================================
-- SISTEMA DE TRASPASO (NOCLIP) Y HERRAMIENTAS
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
    if not Config.AutoEquip then return end
    local char = player.Character
    if not char then return end
    
    if char:FindFirstChildOfClass("Tool") then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.1) -- Micro-pausa para asegurar que el servidor registre el arma
        end
    end
end

-- =======================================================================
-- DISPARADOR ORIGINAL (EL QUE SÍ FUNCIONA)
-- =======================================================================
local function firePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    elseif fire_proximity_prompt then
        fire_proximity_prompt(prompt)
    end
end

-- =======================================================================
-- ESTABILIZACIÓN FÍSICA AVANZADA (SIN ANCLAR)
-- =======================================================================
local function lockCharacter(part)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    enableNoclip()
    
    -- Teletransporte inicial directo al centro exacto
    hrp.CFrame = CFrame.new(part.Position)
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)

    -- Usamos fuerzas en lugar de .Anchored para mantener activos los golpes y prompts
    local bp = hrp:FindFirstChild("MinerBodyPos") or Instance.new("BodyPosition")
    bp.Name = "MinerBodyPos"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 60000
    bp.Position = part.Position -- Centrado absoluto
    bp.Parent = hrp

    local bg = hrp:FindFirstChild("MinerBodyGyro") or Instance.new("BodyGyro")
    bg.Name = "MinerBodyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 60000
    bg.CFrame = CFrame.new(hrp.Position, part.Position + Vector3.new(0, 0, 1))
    bg.Parent = hrp
end

local function unlockCharacter()
    disableNoclip()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then 
        local bp = hrp:FindFirstChild("MinerBodyPos")
        local bg = hrp:FindFirstChild("MinerBodyGyro")
        if bp then bp:Destroy() end
        if bg then bg:Destroy() end
    end
end

-- =======================================================================
-- LOGICA DE MINADO CON RETORNO INTELIGENTE
-- =======================================================================
local function mineCrystal(crystal)
    local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
    local part = crystal:IsA("Model") and (crystal.PrimaryPart or crystal:FindFirstChildWhichIsA("BasePart")) or crystal
    if not part then return false end

    -- Asegurar herramienta antes de empezar a contar el tiempo
    verifyAndEquipTool()

    lockCharacter(part)
    task.wait(0.03) 

    local startTime = os.clock()

    -- Bucle de minado limpio (Usa el disparador original de vuelta)
    while Config.Mining and crystal and crystal.Parent and prompt and prompt.Parent do
        -- Regla estricta de tiempo (Si pasa del límite por alertas o tamaño, salta)
        if os.clock() - startTime > Config.MaxTimePerCrystal then
            -- Lo añade a la lista de espera por 8 segundos (luego volverá a intentar destruirlo)
            temporaryBlacklist[crystal] = os.clock() + 8.0 
            break
        end

        firePrompt(prompt)
        task.wait(0.05) -- Velocidad máxima de spam del prompt original
    end

    unlockCharacter()
    return true
end

-- =======================================================================
-- MOTOR DE BÚSQUEDA FLUIDO
-- =======================================================================
local isAutoMining = false
local function autoMine()
    if isAutoMining then return end
    isAutoMining = true

    while Config.Mining do
        local codes = {}
        for _, name in ipairs(Config.TargetTiers) do
            local code = tierMapping[name]
            if code then table.insert(codes, code) end
        end
        
        if #codes == 0 then task.wait(0.2) continue end

        local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if not crystalFolder or not hrp then 
            task.wait(0.2) 
            continue 
        end

        local bestCrystal = nil
        local bestDist = math.huge
        local crystals = crystalFolder:GetChildren()

        for i = 1, #crystals do
            local crystal = crystals[i]
            
            -- CONTROL DE COOLDOWN: Verifica si ya pasó el tiempo para volver al diamante anterior
            local cooldownTime = temporaryBlacklist[crystal]
            if cooldownTime and os.clock() < cooldownTime then
                continue -- Sigue ignorándolo si aún no expira el cooldown
            end

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
            task.wait(0.01) 
        end
    end
    isAutoMining = false
end

-- =======================================================================
-- INTERFAZ DE USUARIO (RAYFIELD)
-- =======================================================================

MainTab:CreateToggle({
    Name = "Enable Ultra Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle", 
    Callback = function(Value)
        Config.Mining = Value
        if Config.Mining then
            table.clear(temporaryBlacklist) 
            Rayfield:Notify({
                Title = "Physics Engine Active",
                Content = "Modo físico centrado y retorno inteligente activado.",
                Duration = 3,
                Image = 4483362458,
            })
            task.spawn(autoMine)
        else
            unlockCharacter()
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
        Config.TargetTiers = Options
    end,
})

MainTab:CreateToggle({
    Name = "Auto-Equip Tools",
    CurrentValue = true,
    Flag = "AutoEquipToggle",
    Callback = function(Value)
        Config.AutoEquip = Value
    end,
})

MainTab:CreateSlider({
    Name = "Max Attack Time per Crystal",
    Info = "Tiempo en segundos antes de pasar temporalmente al siguiente diamante.",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 4,
    Flag = "TimeoutSlider",
    Callback = function(Value)
        Config.MaxTimePerCrystal = Value
    end,
})

print("V3 Cargada. Golpes originales restaurados con estabilidad física.")
