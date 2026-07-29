-- =====================================================================
-- SHADERFORM AUDIO VISUALIZER 3.0 - Estela Orgánica Radiactiva
-- Solución de visibilidad y movimiento libre (Para Delta iOS)
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables Globales
local localPlayer = Players.LocalPlayer
local visualizerActive = false
local soundObj = nil
local renderConnection = nil
local bassSensitivity = 25 -- Sensibilidad de altura (Bass)

-- Configuración de la ESTELA
local trailCubes = {}
local numCubes = 30 -- Cantidad de segmentos de la estela
local cubeBaseSize = 1 -- Tamaño base
local spacing = 1.5 -- Espacio entre cada cubo hacia atrás

-- PALETA DE COLORES RADIACTIVA (Púrpura, Magenta, Rojo, Cian, Negro)
local radioactivePalette = {
    Color3.fromRGB(128, 0, 128),  -- Púrpura
    Color3.fromRGB(255, 0, 255),  -- Magenta
    Color3.fromRGB(255, 0, 0),    -- Rojo
    Color3.fromRGB(0, 255, 255),  -- Cian
    Color3.fromRGB(0, 0, 0)       -- Negro (Apaga el neón creando cortes oscuros)
}

-- Crear Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "✨ Delta | Estela Radiactiva",
   LoadingTitle = "Cargando Estela...",
   LoadingSubtitle = "Versión Orgánica",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false }
})

local Tab = Window:CreateTab("Trail Radiactivo", 4483362458) 

-- Limpiar cubos
local function cleanupTrail()
    for _, cube in ipairs(trailCubes) do 
        if cube then cube:Destroy() end 
    end
    trailCubes = {}
end

-- Generar los cubos
local function createTrailCubes()
    cleanupTrail()
    for i = 1, numCubes do
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(cubeBaseSize, cubeBaseSize, cubeBaseSize)
        cube.Anchored = true
        cube.CanCollide = false
        cube.Material = Enum.Material.Neon
        cube.CastShadow = false
        cube.Parent = workspace
        table.insert(trailCubes, cube)
    end
end

-- Lógica Central (Se ejecuta constantemente)
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

    for i, cube in ipairs(trailCubes) do
        -- 1. CÁLCULO DE MOVIMIENTO LIBRE Y ORGÁNICO
        -- math.noise nos da ese caos libre, y math.sin da la onda. Los combinamos para el movimiento a los lados (X)
        local swayChaos = math.noise(time * 1.5, i * 0.15, 0) * 4
        local waveSway = math.sin(time * 4 + (i * 0.3)) * 3
        local totalSwayX = swayChaos + waveSway -- Se moverán a la izquierda y derecha libremente
        
        -- Distancia hacia atrás (Z)
        local offsetZ = (i * spacing) + 2
        
        -- Altura por Bass
        local expressionChaos = math.abs(math.noise(time * 2, i * 0.1, 0))
        local rawWave = math.abs(math.sin(time * 6 + i * 0.4))
        
        -- Multiplicamos por el volumen para que reaccionen a la música
        local heightMultiplier = normalLoudness * bassSensitivity * rawWave * (expressionChaos + 0.5)
        local currentHeight = cubeBaseSize + heightMultiplier
        currentHeight = math.clamp(currentHeight, cubeBaseSize, 25) -- Limitar altura
        
        -- 2. ANIMACIÓN 360 DE COLORES RADIACTIVOS
        local colorSpeed = 2
        local baseOffset = (time * colorSpeed) + (i * 0.15)
        local colorIndex = (math.floor(baseOffset) % #radioactivePalette) + 1
        local nextColorIndex = (colorIndex % #radioactivePalette) + 1
        local colorFraction = baseOffset % 1
        
        local currentColor = radioactivePalette[colorIndex]
        local nextColor = radioactivePalette[nextColorIndex]
        local targetColor = currentColor:Lerp(nextColor, colorFraction)

        -- 3. APLICAR TRANSFORMACIONES
        local targetSize = Vector3.new(cubeBaseSize, currentHeight, cubeBaseSize)
        -- Posicionarlos relativos a tu espalda siempre
        local targetCFrame = rootPart.CFrame * CFrame.new(totalSwayX, -1 + (currentHeight / 2), offsetZ)

        -- Lerp suave
        cube.Size = cube.Size:Lerp(targetSize, 0.4)
        cube.CFrame = cube.CFrame:Lerp(targetCFrame, 0.4)
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
   Range = {5, 60},
   Increment = 1,
   CurrentValue = 25,
   Flag = "BassSlider",
   Callback = function(Value) bassSensitivity = Value end,
})

Tab:CreateSection("Estela")
Tab:CreateToggle({
   Name = "Activar Estela Orgánica",
   CurrentValue = false,
   Flag = "VisualizerToggle",
   Callback = function(Value)
       visualizerActive = Value
       if Value then
           createTrailCubes()
           -- USO DE HEARTBEAT EN LUGAR DE RENDERSTEPPED (Más estable en móviles)
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
