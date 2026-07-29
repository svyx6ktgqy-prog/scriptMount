-- =====================================================================
-- SHADERFORM AUDIO VISUALIZER 2.0 - Estela de Edificios Radiactivos
-- Para Delta Executor (iOS) | Usando Rayfield UI
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables Globales
local localPlayer = Players.LocalPlayer
local visualizerActive = false
local soundObj = nil
local renderConnection = nil
local bassSensitivity = 20 -- Sensibilidad de altura (Bass)

-- Configuración de la ESTELA (Trail)
local trailCubes = {}
local numCubes = 25 -- Cuántos cubos forman la estela
local cubeBaseSize = 0.8 -- Tamaño base pequeño para los cubos del trail
local positionHistory = {} -- Buffer para guardar la trayectoria del jugador
local trailOffset = Vector3.new(0, -1, 0) -- Desplazamiento respecto al suelo

-- Nueva PALETA DE COLORES (Púrpura, Magenta, Rojo, Cian, Negro)
local radioactivePalette = {
    Color3.fromRGB(128, 0, 128),  -- Púrpura
    Color3.fromRGB(255, 0, 255),  -- Magenta
    Color3.fromRGB(255, 0, 0),    -- Rojo
    Color3.fromRGB(0, 255, 255),  -- Cian
    Color3.fromRGB(0, 0, 0)       -- Negro (se verá como interrupciones oscuras en el neón)
}

-- Crear Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "✨ Delta iOS | Estela Radiactiva",
   LoadingTitle = "Cargando Estela Visual...",
   LoadingSubtitle = "Siente el rastro del ritmo",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   }
})

-- Crear la Pestaña "Visualizador"
local Tab = Window:CreateTab("Trail Visual", 4483362458) 

-- Función para limpiar cubos antiguos
local function cleanupTrail()
    for _, cube in ipairs(trailCubes) do 
        if cube then cube:Destroy() end 
    end
    trailCubes = {}
    positionHistory = {}
end

-- Función para generar los cubos del Trail
local function createTrailCubes()
    cleanupTrail()
    
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local rootPart = char:WaitForChild("HumanoidRootPart")
    
    for i = 1, numCubes do
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(cubeBaseSize, cubeBaseSize, cubeBaseSize)
        cube.Anchored = true
        cube.CanCollide = false
        cube.Material = Enum.Material.Neon -- Material Neón para que brille y parezca radiactivo
        cube.CastShadow = false -- No proyectar sombras para un efecto más limpio
        cube.Parent = workspace
        
        -- Añadir un ParticleEmitter para efecto radiactivo (opcional, aumenta el lag)
        --[[ 
        local particles = Instance.new("ParticleEmitter")
        particles.Texture = "rbxassetid://156294711" -- Una textura de humo/brillo
        particles.Rate = 5
        particles.Size = NumberSequence.new(0.5, 0.2)
        particles.Lifetime = NumberRange.new(0.3, 0.5)
        particles.Color = ColorSequence.new(radioactivePalette[1], radioactivePalette[2])
        particles.Transparency = NumberSequence.new(0.5, 1)
        particles.Speed = NumberRange.new(1)
        particles.VelocityInheritance = 0.5
        particles.Parent = cube
        ]]

        table.insert(trailCubes, cube)
        -- Inicializar el buffer de posición con la ubicación actual
        table.insert(positionHistory, rootPart.CFrame)
    end
end

-- Lógica del Visualizador y Trail (Se ejecuta cada frame)
local function updateTrailVisualizer()
    local char = localPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Guardar la posición actual en el buffer e intentar que siempre haya numCubes posiciones guardadas
    table.insert(positionHistory, 1, rootPart.CFrame)
    if #positionHistory > numCubes then
        table.remove(positionHistory)
    end

    if not visualizerActive then return end

    -- PlaybackLoudness lee el volumen en tiempo real
    local loudness = (soundObj and soundObj.IsPlaying) and soundObj.PlaybackLoudness or 0
    local normalLoudness = loudness / 200 -- Normalizar a un rango útil
    local time = tick()

    -- Parámetros de animación 360 (Rotación de color a lo largo de la estela)
    local colorCycleSpeed = 1 -- Velocidad de rotación del color (Hz)
    local baseColorOffset = (time * colorCycleSpeed) % #radioactivePalette

    for i, cube in ipairs(trailCubes) do
        -- Obtener la posición histórica correspondiente del jugador
        local targetHistoryIndex = i
        local playerHistoryCFrame = positionHistory[targetHistoryIndex]

        if not playerHistoryCFrame then playerHistoryCFrame = rootPart.CFrame end -- Fallback si el buffer está vacío

        -- --- CÁLCULO DE MOVIMIENTO LIBRE ("Waves" Expresivas) ---
        -- Usamos una combinación de math.sin y math.noise (un ruido Perlin) para un movimiento "menos redondo", más caótico y orgánico.
        
        -- Factor de expresión (caos): Math.noise crea una señal aleatoria suave
        local expressionChaos = math.abs(math.noise(time * 3, i * 0.2, 0)) * 5
        
        -- Onda rítmica pero distorsionada
        local rawWave = math.abs(math.sin(time * 5 + i * 0.3) * expressionChaos)
        
        -- Altura final basada en Volumen (loudness) * Expresión Caótica
        local heightMultiplier = normalLoudness * bassSensitivity * rawWave
        local currentHeight = cubeBaseSize + heightMultiplier
        
        -- Limitar altura máxima para evitar edificios gigantes
        currentHeight = math.clamp(currentHeight, cubeBaseSize, 20)

        -- --- CÁLCULO DE COLOR (Paleta Radiactiva & Animación 360) ---
        -- Índice de color que rota alrededor de la estela en 360 grados
        local colorIndex = (math.floor(baseColorOffset + i) % #radioactivePalette) + 1
        local currentColor = radioactivePalette[colorIndex]
        local nextColorIndex = (colorIndex % #radioactivePalette) + 1
        local nextColor = radioactivePalette[nextColorIndex]

        -- Interpolación suave entre los colores de la paleta basado en la fracción de baseColorOffset
        local colorFraction = baseColorOffset % 1
        local targetColor = currentColor:Lerp(nextColor, colorFraction)

        -- Ajustar el brillo interno (Brillo Neón) basado en la altura y un factor aleatorio
        local intensityFactor = math.clamp(currentHeight / 10, 0.5, 1) + (math.random() * 0.1)
        
        -- --- APLICACIÓN DE TRANSFORMACIONES ---
        local targetSize = Vector3.new(cubeBaseSize, currentHeight, cubeBaseSize)
        -- Posición histórica + Desplazamiento + Elevación basada en la altura (para que crezcan hacia arriba)
        local targetCFrame = playerHistoryCFrame * trailOffset * CFrame.new(0, currentHeight / 2 - cubeBaseSize / 2, 0)

        -- Interpolación (Lerp) para movimiento súper suave y elegante
        -- El factor 0.3 controla la suavidad. Menos = más suave, Más = más agresivo
        cube.Size = cube.Size:Lerp(targetSize, 0.3)
        cube.CFrame = cube.CFrame:Lerp(targetCFrame, 0.3)
        cube.Color = targetColor
    end
end

-- ==========================================
-- ELEMENTOS DE LA INTERFAZ (UI)
-- ==========================================

Tab:CreateSection("Configuración de Audio")

Tab:CreateInput({
   Name = "ID de la Canción (Sound ID)",
   PlaceholderText = "Ej: 142295308",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local id = tonumber(Text)
       if id then
           -- Destruir audio anterior si existe
           if soundObj then soundObj:Destroy() end
           
           -- Crear y reproducir nuevo audio
           soundObj = Instance.new("Sound")
           soundObj.SoundId = "rbxassetid://" .. tostring(id)
           soundObj.Parent = workspace
           soundObj.Volume = 1
           soundObj.Looped = true
           soundObj:Play()
           
           Rayfield:Notify({
               Title = "Reproduciendo",
               Content = "Audio ID: " .. tostring(id),
               Duration = 3
           })
       end
   end,
})

Tab:CreateSlider({
   Name = "Sensibilidad de Graves (Bass)",
   Range = {5, 60},
   Increment = 1,
   Suffix = "x",
   CurrentValue = bassSensitivity,
   Flag = "BassSlider",
   Callback = function(Value)
       bassSensitivity = Value
   end,
})

Tab:CreateSection("Activar Estela")

Tab:CreateToggle({
   Name = "Activar Estela Radiactiva",
   CurrentValue = false,
   Flag = "VisualizerToggle",
   Callback = function(Value)
       visualizerActive = Value
       if Value then
           createTrailCubes()
           -- Conectar el renderizado
           if not renderConnection then
               renderConnection = RunService.RenderStepped:Connect(updateTrailVisualizer)
           end
       else
           -- Desconectar el renderizado y limpiar
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
