-- // Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Escena Monstruosa 666",
   LoadingTitle = "Cargando Escenario...",
   LoadingSubtitle = "por Delta Executor",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false, -- Sin sistema de keys
})

local Tab = Window:CreateTab("Escena Épica", 4483362458)

-- // Variables de Servicios y Jugador
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs de los recursos (Assets)
local ASSETS = {
    LetrasSangre = "rbxassetid://88425869123525",
    Slash = "rbxassetid://121659392958456",
    Satan = "rbxassetid://86446020650559",
    FuegoReal = "rbxassetid://241907058"
}

-- // Crear Botón Flotante (Oculto por defecto)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotonFlotanteEscena"
ScreenGui.Parent = CoreGui

local FloatingButton = Instance.new("TextButton")
FloatingButton.Size = UDim2.new(0, 150, 0, 50)
FloatingButton.Position = UDim2.new(0.8, 0, 0.8, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
FloatingButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
FloatingButton.BorderSizePixel = 2
FloatingButton.Text = "🔥 INVOCAR 🔥"
FloatingButton.TextColor3 = Color3.fromRGB(255, 50, 50)
FloatingButton.Font = Enum.Font.Creepster
FloatingButton.TextSize = 25
FloatingButton.Visible = false
FloatingButton.Active = true
FloatingButton.Draggable = true -- Permite mover el botón por la pantalla
FloatingButton.Parent = ScreenGui

-- // Lógica de la Escena
local isPlaying = false

local function CrearEscenaEpica()
    if isPlaying then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isPlaying = true
    local hrp = character.HumanoidRootPart
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 15) -- 15 studs frente al jugador
    local posOculta = spawnPos - Vector3.new(0, 15, 0) -- Posición bajo tierra
    local posFinal = spawnPos + Vector3.new(0, 2, 0)   -- Posición en la superficie

    -- Carpeta para limpiar fácil después
    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernal"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo (Hellfire)
    local SueloFuego = Instance.new("Part")
    SueloFuego.Size = Vector3.new(15, 1, 15)
    SueloFuego.Position = spawnPos - Vector3.new(0, 3, 0)
    SueloFuego.Anchored = true
    SueloFuego.CanCollide = false
    SueloFuego.Transparency = 1
    SueloFuego.Parent = SceneFolder

    local FireEmitter = Instance.new("ParticleEmitter")
    FireEmitter.Texture = ASSETS.FuegoReal
    FireEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 0)})
    FireEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 0, 0))
    FireEmitter.Rate = 100
    FireEmitter.Lifetime = NumberRange.new(1, 2)
    FireEmitter.Parent = SueloFuego

    -- 2. Personaje Satán
    local Satan = Instance.new("Part")
    Satan.Size = Vector3.new(5, 5, 5)
    Satan.Position = posOculta
    Satan.Anchored = true
    Satan.CanCollide = false
    Satan.Transparency = 0
    Satan.Parent = SceneFolder
    
    local SatanMesh = Instance.new("SpecialMesh")
    SatanMesh.MeshId = ASSETS.Satan
    SatanMesh.Scale = Vector3.new(0.05, 0.05, 0.05) -- Ajusta la escala si el ID es muy grande
    SatanMesh.Parent = Satan

    -- Slash Effect en Satán
    local SlashEmitter = Instance.new("ParticleEmitter")
    SlashEmitter.Texture = ASSETS.Slash
    SlashEmitter.Rate = 20
    SlashEmitter.Size = NumberSequence.new(5)
    SlashEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    SlashEmitter.Parent = Satan

    -- Letras Matrix Blood Effect (Arriba de la cabeza)
    local BloodLetters = Instance.new("ParticleEmitter")
    BloodLetters.Texture = ASSETS.LetrasSangre
    BloodLetters.EmissionDirection = Enum.NormalId.Top
    BloodLetters.Rate = 15
    BloodLetters.Speed = NumberRange.new(5, 10)
    BloodLetters.Size = NumberSequence.new(3)
    BloodLetters.Parent = Satan

    -- 3. Letras 666 3D con Fuego
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.Position = posOculta + Vector3.new(0, 5, 0)
    Numeros666.Anchored = true
    Numeros666.CanCollide = false
    Numeros666.Transparency = 1
    Numeros666.Parent = SceneFolder

    local Billboard666 = Instance.new("BillboardGui")
    Billboard666.Size = UDim2.new(0, 400, 0, 200)
    Billboard666.StudsOffset = Vector3.new(0, 3, 0)
    Billboard666.AlwaysOnTop = true
    Billboard666.Parent = Numeros666

    local Text666 = Instance.new("TextLabel")
    Text666.Size = UDim2.new(1, 0, 1, 0)
    Text666.BackgroundTransparency = 1
    Text666.Text = "666"
    Text666.TextColor3 = Color3.fromRGB(180, 0, 0)
    Text666.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Text666.TextStrokeTransparency = 0
    Text666.Font = Enum.Font.Creepster
    Text666.TextScaled = true
    Text666.Parent = Billboard666

    -- Fuego en el 666
    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 50
    NumFire.Size = NumberSequence.new(3)
    NumFire.Parent = Numeros666

    -- // ANIMACIONES (Tween)
    local tweenInfoSubir = TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    -- Animación de salida (Hacia arriba)
    local SubirSatan = TweenService:Create(Satan, tweenInfoSubir, {Position = posFinal})
    local Subir666 = TweenService:Create(Numeros666, tweenInfoSubir, {Position = posFinal + Vector3.new(0, 6, 0)})
    
    SubirSatan:Play()
    Subir666:Play()

    -- Esperar a que la escena se luzca
    task.wait(6)

    -- Animación de hundimiento (Hacia abajo)
    local BajarSatan = TweenService:Create(Satan, tweenInfoBajar, {Position = posOculta})
    local Bajar666 = TweenService:Create(Numeros666, tweenInfoBajar, {Position = posOculta})
    
    BajarSatan:Play()
    Bajar666:Play()
    
    -- Apagar el fuego del suelo progresivamente
    FireEmitter.Enabled = false

    -- Limpiar la memoria
    task.wait(3.5)
    SceneFolder:Destroy()
    isPlaying = false
end

-- Asignar la función al botón flotante
FloatingButton.MouseButton1Click:Connect(CrearEscenaEpica)

-- // Toggle en Rayfield para el botón flotante
Tab:CreateToggle({
   Name = "Activar Botón de Invocación",
   CurrentValue = false,
   Flag = "ToggleBoton", 
   Callback = function(Value)
        FloatingButton.Visible = Value
   end,
})

Tab:CreateLabel("Activa el switch para mostrar el botón flotante.")
Tab:CreateLabel("Toca el botón flotante para iniciar la escena.")
