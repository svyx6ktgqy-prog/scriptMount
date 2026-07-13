-- =======================================================================
-- CARGAR RAYFIELD UI
-- =======================================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Crystal Miner Hub PRO MAX",
    LoadingTitle = "Cargando Sistema PRO...",
    LoadingSubtitle = "Ultra Reacción",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, 
       FileName = "AutoMiner"
    },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458) 

-- =======================================================================
-- VARIABLES GLOBALES
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
    ["T4"] = Color3.fromRGB(255, 0, 255),   -- Epic: Magenta
    ["T5"] = Color3.fromRGB(255, 127, 0),   -- Legendary: Naranja
    ["T6"] = Color3.fromRGB(163, 73, 164)   -- Mythic: Morado
}

local stickConnection = nil
local noclipConnection = nil
local temporaryBlacklist = {} 
local absoluteTimeout = 10.0 -- Controlado 100% por el slider
local autoEquip = true       

-- =======================================================================
-- SISTEMAS DE SOPORTE (NOCLIP & EQUIP)
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
        if tool then tool.Parent = char end
    end
end

local function firePrompt(prompt)
    if fireproximityprompt then fireproximityprompt(prompt)
    elseif fire_proximity_prompt then fire_proximity_prompt(prompt) end
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

-- =======================================================================
-- MOTOR DE MINERÍA PRO MAX
-- =======================================================================
local function mineCrystal(crystal)
    local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return false end

    -- Buscar el centro real del diamante para evitar errores de tamaño
    local targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or crystal.PrimaryPart
    if not targetPart then return false end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart

    verifyAndEquipTool()

    -- NUEVO POSICIONAMIENTO CENITAL (Diagonal desde arriba, imposible atascarse)
    local safeOffset = Vector3.new(2.5, 3.5, 2.5) 
    local targetCFrame = CFrame.new(targetPart.Position + safeOffset, targetPart.Position)
    
    hrp.CFrame = targetCFrame
    stopStick()
    enableNoclip()
    
    if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = true end
    stickConnection = RunService.Heartbeat:Connect(function()
        if not mining or not crystal.Parent then stopStick() return end
        hrp.CFrame = targetCFrame
        hrp.Velocity = Vector3.new(0,0,0)
    end)

    -- ESCÁNER VISUAL
    local tierCode = string.upper(crystal.Name):match("(T[1-6])")
    local scanColor = colorMapping[tierCode] or Color3.fromRGB(255, 255, 255)
    
    local scannerBox = Instance.new("SelectionBox")
    scannerBox.Name = "ScannerPRO"
    scannerBox.Color3 = scanColor
    scannerBox.LineThickness = 0.05 
    scannerBox.SurfaceColor3 = scanColor
    scannerBox.SurfaceTransparency = 0.8 
    scannerBox.Adornee = crystal
    scannerBox.Parent = crystal

    -- PREPARAR HACK DE DISTANCIA
    prompt.RequiresLineOfSight = false 
    prompt.MaxActivationDistance = 60 

    local startTime = os.clock()
    
    -- BUCLE DE REACCIÓN INSTANTÁNEA
    -- Se detiene en el MILISEGUNDO en que el prompt se desactiva o desaparece
    while mining and crystal and crystal.Parent and prompt and prompt.Parent and prompt.Enabled do
        
        -- EL SLIDER ES LEY: Si se pasa del tiempo exacto, lo abandona
        if os.clock() - startTime > absoluteTimeout then
            temporaryBlacklist[crystal] = os.clock() + 3.0 -- Solo lo ignora 3 segundos (Regreso rápido)
            break
        end
        
        firePrompt(prompt)

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        
        -- Clic de refuerzo super ligero
        VirtualUser:ClickButton1(Vector2.new(0, 0))

        task.wait(0.04) -- Velocidad perfecta: Super rápida pero sin saturar al servidor
    end

    if scannerBox then scannerBox:Destroy() end
    stopStick()
    return true
end

-- =======================================================================
-- CEREBRO DE BÚSQUEDA
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

        local crystalFolder = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if #codes == 0 or not crystalFolder or not hrp then
            task.wait(0.1) 
            continue
        end

        local bestCrystal = nil
        local bestDist = math.huge

        for _, crystal in ipairs(crystalFolder:GetChildren()) do
            -- Ignorar diamantes en blacklist temporal
            if temporaryBlacklist[crystal] and os.clock() < temporaryBlacklist[crystal] then continue end

            local tierCode = string.upper(crystal.Name):match("(T[1-6])")
            if tierCode and table.find(codes, tierCode) then
                local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then -- Solo apuntar a diamantes vivos
                    local part = prompt.Parent:IsA("BasePart") and prompt.Parent or crystal.PrimaryPart
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
            task.wait(0.1) -- Cero lag, busca sin parar
        end
    end
    isAutoMining = false
end

-- =======================================================================
-- INTERFAZ DE USUARIO (UI)
-- =======================================================================

MainTab:CreateToggle({
    Name = "Activar Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle", 
    Callback = function(Value)
        mining = Value
        if mining then
            table.clear(temporaryBlacklist)
            Rayfield:Notify({Title = "PRO MAX", Content = "Minería Láser Activada", Duration = 2})
            task.spawn(autoMine)
        else
            stopStick()
            Rayfield:Notify({Title = "PRO MAX", Content = "Minería Detenida", Duration = 2})
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Niveles de Diamante",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    CurrentOption = {"Common"},
    MultipleOptions = true,
    Flag = "TiersDropdown",
    Callback = function(Options)
        targetTiers = Options
        table.clear(temporaryBlacklist) -- Refresco instantáneo al cambiar opciones
    end,
})

MainTab:CreateToggle({
    Name = "Auto-Equipar Pico",
    CurrentValue = true,
    Flag = "AutoEquipToggle",
    Callback = function(Value)
        autoEquip = Value
    end,
})

MainTab:CreateSlider({
    Name = "Tiempo Máximo de Abandono (Exacto)",
    Info = "Si el diamante no se rompe en este tiempo, pasa al siguiente.",
    Range = {1, 60}, -- Aumentado a 60 segundos para míticos
    Increment = 1,
    Suffix = "s",
    CurrentValue = 10,
    Flag = "TimeoutSlider",
    Callback = function(Value)
        absoluteTimeout = Value -- Ahora respeta tu slider sin excusas
    end,
})

-- Botón extra para limpiar la memoria manualmente por si acaso
MainTab:CreateButton({
    Name = "Refrescar Inteligencia (Reset)",
    Callback = function()
        table.clear(temporaryBlacklist)
        Rayfield:Notify({Title = "Sistema", Content = "Memoria de diamantes reseteada", Duration = 1.5})
    end,
})

print("Crystal Miner PRO MAX Cargado. Reacción instantánea y slider absoluto en línea.")
