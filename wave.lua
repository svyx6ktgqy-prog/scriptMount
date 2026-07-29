-- =====================================================================
-- SHADERFORM AUDIO VISUALIZER - Para Delta Executor (iOS)
-- Creado usando Rayfield UI
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables Globales
local localPlayer = Players.LocalPlayer
local visualizerActive = false
local cubes = {}
local soundObj = nil
local renderConnection = nil
local bassSensitivity = 15 -- Multiplicador de altura de los cubos

-- Crear Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "✨ Delta iOS | Visualizador",
   LoadingTitle = "Cargando Shaderform...",
   LoadingSubtitle = "Siente el ritmo",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   }
})

-- Crear la Pestaña "Shaderform"
local Tab = Window:CreateTab("Shaderform", 4483362458) 

-- Función para limpiar cubos antiguos
local function cleanupCubes()
    for _, data in ipairs(cubes) do 
        if data.part then data.part:Destroy() end 
    end
    cubes = {}
end

-- Función para generar los cubos
local function createCubes()
    cleanupCubes()
    
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local rootPart = char:WaitForChild("HumanoidRootPart")
    
    local numCubes = 30 -- Cantidad de cubos
    local spacing = 2.5
    
    for i = 1, numCubes do
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(2, 2, 2)
        cube.Anchored = true
        cube.CanCollide = false
        cube.Material = Enum.Material.Neon
        cube.Color = Color3.fromRGB(0, 255, 255) -- Color inicial Cyan
        cube.Parent = workspace
        
        -- Posicionarlos en línea curva/recta frente al jugador
        local offset = Vector3.new((i - (numCubes/2)) * spacing, -3, -15)
        cube.CFrame = rootPart.CFrame * CFrame.new(offset)
        
        table.insert(cubes, {
            part = cube, 
            baseCFrame = cube.CFrame, 
            index = i,
            total = numCubes
        })
    end
end

-- Lógica del Visualizador (Se ejecuta cada frame)
local function updateVisualizer()
    if not visualizerActive or not soundObj or not soundObj.IsPlaying then return end

    -- PlaybackLoudness lee el volumen en tiempo real (los graves suelen dar los picos más altos)
    -- Lo dividimos entre 100 para normalizar el valor (suele ir de 0 a 1000)
    local loudness = soundObj.PlaybackLoudness / 100 
    local time = tick()

    for _, data in ipairs(cubes) do
        local cube = data.part
        local i = data.index
        
        -- Crear un efecto de onda combinando el tiempo, la posición del cubo y el loudness
        -- math.sin crea la "ola" y el loudness dicta la fuerza del pico.
        local wave = math.abs(math.sin(time * 3 + (i / 4))) 
        local targetHeight = 2 + (loudness * wave * bassSensitivity)
        
        -- Limitar altura máxima para que no sea infinito
        targetHeight = math.clamp(targetHeight, 2, 80)
        
        -- Interpolación (Lerp) para movimiento súper suave y elegante
        local targetSize = Vector3.new(2, targetHeight, 2)
        local targetCFrame = data.baseCFrame * CFrame.new(0, targetHeight/2 - 1, 0)
        
        -- Efecto de color Shader (Cambia de tono basado en la altura y el tiempo)
        local hue = (time * 0.1 + (i / data.total)) % 1
        local targetColor = Color3.fromHSV(hue, 1, math.clamp(targetHeight/20, 0.5, 1))

        -- El factor 0.2 controla la suavidad. Menos = más suave, Más = más agresivo
        cube.Size = cube.Size:Lerp(targetSize, 0.2)
        cube.CFrame = cube.CFrame:Lerp(targetCFrame, 0.2)
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
   Name = "Sensibilidad de los Graves (Bass)",
   Range = {5, 50},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 15,
   Flag = "BassSlider",
   Callback = function(Value)
       bassSensitivity = Value
   end,
})

Tab:CreateSection("Activar Efecto")

Tab:CreateToggle({
   Name = "Activar Shaderform",
   CurrentValue = false,
   Flag = "VisualizerToggle",
   Callback = function(Value)
       visualizerActive = Value
       if Value then
           createCubes()
           -- Conectar el renderizado
           if not renderConnection then
               renderConnection = RunService.RenderStepped:Connect(updateVisualizer)
           end
       else
           -- Desconectar el renderizado y limpiar
           if renderConnection then
               renderConnection:Disconnect()
               renderConnection = nil
           end
           cleanupCubes()
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
