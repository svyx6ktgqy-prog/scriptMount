-- =====================================================================
-- SHADERFORM AUDIO VISUALIZER 4.0 - Cola Real Radiactiva (Al Suelo)
-- Movimiento elástico, escala pequeña y físicas de arrastre (Delta iOS)
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables Globales
local localPlayer = Players.LocalPlayer
local visualizerActive = false
local soundObj = nil
local renderConnection = nil
local bassSensitivity = 8 -- Ajustado para la nueva escala pequeña

-- Configuración de la COLA
local trailCubes = {}
local spinePoints = {} -- La "columna vertebral" invisible que calcula las físicas
local numCubes = 35 -- Más segmentos para una cola más larga y fluida
local cubeBaseSize = 0.35 -- ESCALA MUCHO MÁS PEQUEÑA
local spacing = 0.8 -- Distancia base entre vértebras de la cola

-- PALETA DE COLORES RADIACTIVA
local radioactivePalette = {
    Color3.fromRGB(128, 0, 128),  -- Púrpura
    Color3.fromRGB(255, 0, 255),  -- Magenta
    Color3.fromRGB(255, 0, 0),    -- Rojo
    Color3.fromRGB(0, 255, 255),  -- Cian
    Color3.fromRGB(0, 0, 0)       -- Negro (Cortes oscuros)
}

-- Crear Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "✨ Delta | Cola Radiactiva",
   LoadingTitle = "Cargando Físicas...",
   LoadingSubtitle = "Visualizador Orgánico",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false }
})

local Tab = Window:CreateTab("Trail Físico", 4483362458) 

-- Limpiar
local function cleanupTrail()
    for _, cube in ipairs(trailCubes) do 
        if cube then cube:Destroy() end 
    end
    trailCubes = {}
    spinePoints = {}
end

-- Generar los cubos
local function createTrailCubes()
    cleanupTrail()
    local char = localPlayer.Character
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
        
        -- Inicializar la columna vertebral (oculta)
        spinePoints[i] = startCFrame * CFrame.new(0, -2.8, i * spacing)
    end
end

-- Lógica Central (Físicas de la Cola y Audio)
local function updateTrailVisualizer()
    local char = localPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if not visualizerActive then return end

    -- Volumen
    local loudness = (soundObj and soundObj.IsPlaying) and soundObj.PlaybackLoudness or 0
    local normalLoudness = loudness / 200 
    local time = tick()

    -- 1. FÍSICAS DE LA COLUMNA VERTEBRAL (Elongación y Arrastre)
    for i = 1, numCubes do
        local targetSpineCFrame
        
        -- Caos y serpenteo libre
        local sway = math.sin(time * 5 + i * 0.4) * 0.3 + math.noise(time * 2, i * 0.2, 0) * 0.5

        if i == 1 then
            -- El primer segmento persigue tu espalda BAJANDO AL SUELO (-2.8 en Y)
            targetSpineCFrame = rootPart.CFrame * CFrame.new(0, -2.8, 1.2)
            -- Lerp rápido para la cabeza de la cola
            spinePoints[i] = spinePoints[i]:Lerp(targetSpineCFrame, 0.4)
        else
            -- Los demás segmentos persiguen al segmento anterior, creando la elongación al correr
            local prevSpine = spinePoints[i-1]
            -- Se posicionan detrás (Z = spacing) y se tambalean a los lados (X = sway)
            targetSpineCFrame = prevSpine * CFrame.new(sway, 0, spacing)
            -- Lerp más lento. Esto causa que la cola se ESTIRE al moverte y se ENCOJA al parar.
            spinePoints[i] = spinePoints[i]:Lerp(targetSpineCFrame, 0.35)
        end
    end

    -- 2. VISUALIZADOR Y ANIMACIÓN 360
    for i, cube in ipairs(trailCubes) do
        -- Altura por Bass (Reactividad)
        local rawWave = math.abs(math.sin(time * 6 + i * 0.3))
        local expressionChaos = math.abs(math.noise(time * 2.5, i * 0.15, 0))
        
        local heightMultiplier = normalLoudness * bassSensitivity * rawWave * (expressionChaos + 0.5)
        local currentHeight = cubeBaseSize + heightMultiplier
        currentHeight = math.clamp(currentHeight, cubeBaseSize, 12) -- Altura máxima reducida
        
        -- Color Animado 360
        local colorSpeed = 1.5
        local baseOffset = (time * colorSpeed) + (i * 0.12)
        local colorIndex = (math.floor(baseOffset) % #radioactivePalette) + 1
        local nextColorIndex = (colorIndex % #radioactivePalette) + 1
        local colorFraction = baseOffset % 1
        
        local targetColor = radioactivePalette[colorIndex]:Lerp(radioactivePalette[nextColorIndex], colorFraction)

        -- 3. APLICAR TRANSFORMACIONES AL CUBO VISUAL
        local targetSize = Vector3.new(cubeBaseSize, currentHeight, cubeBaseSize)
        
        -- Se ancla a la columna vertebral (que está en el piso) y crece HACIA ARRIBA
        local visualCFrame = spinePoints[i] * CFrame.new(0, currentHeight / 2, 0)

        cube.Size = cube.Size:Lerp(targetSize, 0.4)
        cube.CFrame = cube.CFrame:Lerp(visualCFrame, 0.4)
        cube.Color = targetColor
    end
end

-- ==========================================
-- INTERFAZ
-- ==========================================

Tab:CreateSection("Audio")
Tab:CreateInput({
   Name = "ID de la Canción (Sound ID)",
   PlaceholderText = "Ej: 142295308",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local id = tonumber(Text)
       if id then
           if soundObj then soundObj:Destroy() end
           soundObj = Instance.new("Sound")
           soundObj.SoundId = "rbxassetid://" .. tostring(id)
           soundObj.Parent = workspace
           soundObj.Volume = 1
           soundObj.Looped = true
           soundObj:Play()
           Rayfield:Notify({Title = "Reproduciendo", Content = "ID: " .. tostring(id), Duration = 3})
       end
   end,
})

Tab:CreateSlider({
   Name = "Sensibilidad de Graves (Bass)",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 8,
   Flag = "BassSlider",
   Callback = function(Value) bassSensitivity = Value end,
})

Tab:CreateSection("Estela Físicamente Animada")
Tab:CreateToggle({
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
           if soundObj then soundObj:Pause() end
       end
   end,
})

Tab:CreateButton({
   Name = "Detener Música",
   Callback = function()
       if soundObj then
           soundObj:Destroy()
           soundObj = nil
       end
   end,
})
