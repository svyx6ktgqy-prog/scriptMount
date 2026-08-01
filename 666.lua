-- // Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Escena Monstruosa 666",
   LoadingTitle = "Cargando Escenario...",
   LoadingSubtitle = "por Delta Executor",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Escena Épica", 4483362458)

-- // Variables
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs
local ASSETS = {
    LetrasSangre = "rbxassetid://88425869123525",
    Slash = "rbxassetid://121659392958456",
    Satan = "rbxassetid://86446020650559",
    FuegoReal = "rbxassetid://241907058"
}

-- // Interfaz Flotante
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
FloatingButton.Draggable = true 
FloatingButton.Parent = ScreenGui

local isPlaying = false

local function CrearEscenaEpica()
    if isPlaying then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isPlaying = true
    local hrp = character.HumanoidRootPart
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 20) -- Un poco más lejos para verlo mejor
    local posOculta = spawnPos - Vector3.new(0, 20, 0) 
    local posFinal = spawnPos + Vector3.new(0, 3, 0)   

    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernal"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo (Hellfire)
    local SueloFuego = Instance.new("Part")
    SueloFuego.Size = Vector3.new(20, 1, 20)
    SueloFuego.Position = spawnPos - Vector3.new(0, 2, 0)
    SueloFuego.Anchored = true
    SueloFuego.CanCollide = false
    SueloFuego.Transparency = 1
    SueloFuego.Parent = SceneFolder

    local FireEmitter = Instance.new("ParticleEmitter")
    FireEmitter.Texture = ASSETS.FuegoReal
    FireEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)})
    FireEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 0, 0))
    FireEmitter.Rate = 150
    FireEmitter.Lifetime = NumberRange.new(1.5, 2.5)
    FireEmitter.Speed = NumberRange.new(5, 10)
    FireEmitter.LightEmission = 1 -- Hace que el fuego brille y sea visible en la oscuridad
    FireEmitter.ZOffset = 1 -- Evita que se superponga con el suelo
    FireEmitter.Parent = SueloFuego

    -- 2. Personaje Satán
    local Satan = Instance.new("Part")
    Satan.Size = Vector3.new(6, 8, 6)
    Satan.Position = posOculta
    Satan.Anchored = true
    Satan.CanCollide = false
    Satan.Color = Color3.fromRGB(150, 0, 0) -- Respaldo visual
    Satan.Material = Enum.Material.Neon -- Si falla la malla, brillará en rojo demoníaco
    Satan.Transparency = 0
    Satan.Parent = SceneFolder
    
    -- OBLIGAR a cargar como FileMesh
    local SatanMesh = Instance.new("SpecialMesh")
    SatanMesh.MeshType = Enum.MeshType.FileMesh 
    SatanMesh.MeshId = ASSETS.Satan
    SatanMesh.Scale = Vector3.new(2, 2, 2) -- Aumentamos la escala drásticamente
    SatanMesh.Parent = Satan

    -- Slash Effect
    local SlashEmitter = Instance.new("ParticleEmitter")
    SlashEmitter.Texture = ASSETS.Slash
    SlashEmitter.Rate = 30
    SlashEmitter.Size = NumberSequence.new(6)
    SlashEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    SlashEmitter.LightEmission = 1
    SlashEmitter.LockedToPart = true -- Se mueve fluido con Satán
    SlashEmitter.ZOffset = 2
    SlashEmitter.Parent = Satan

    -- Letras Matrix Blood Effect
    local BloodLetters = Instance.new("ParticleEmitter")
    BloodLetters.Texture = ASSETS.LetrasSangre
    BloodLetters.EmissionDirection = Enum.NormalId.Top
    BloodLetters.Rate = 25
    BloodLetters.Speed = NumberRange.new(8, 12)
    BloodLetters.Size = NumberSequence.new(4)
    BloodLetters.LightEmission = 0.8
    BloodLetters.LockedToPart = true
    BloodLetters.ZOffset = 2
    BloodLetters.Parent = Satan

    -- 3. Letras 666 3D
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.Position = posOculta + Vector3.new(0, 6, 0)
    Numeros666.Anchored = true
    Numeros666.CanCollide = false
    Numeros666.Transparency = 1
    Numeros666.Parent = SceneFolder

    local Billboard666 = Instance.new("BillboardGui")
    Billboard666.Size = UDim2.new(0, 500, 0, 250)
    Billboard666.StudsOffset = Vector3.new(0, 5, 0)
    Billboard666.AlwaysOnTop = true
    Billboard666.Parent = Numeros666

    local Text666 = Instance.new("TextLabel")
    Text666.Size = UDim2.new(1, 0, 1, 0)
    Text666.BackgroundTransparency = 1
    Text666.Text = "666"
    Text666.TextColor3 = Color3.fromRGB(255, 0, 0)
    Text666.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Text666.TextStrokeTransparency = 0
    Text666.Font = Enum.Font.Creepster
    Text666.TextScaled = true
    Text666.Parent = Billboard666

    -- Fuego en el 666
    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 80
    NumFire.Size = NumberSequence.new(3, 5)
    NumFire.LockedToPart = true
    NumFire.Parent = Numeros666

    -- // ANIMACIONES
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    local SubirSatan = TweenService:Create(Satan, tweenInfoSubir, {Position = posFinal})
    local Subir666 = TweenService:Create(Numeros666, tweenInfoSubir, {Position = posFinal + Vector3.new(0, 8, 0)})
    
    SubirSatan:Play()
    Subir666:Play()

    task.wait(6)

    local BajarSatan = TweenService:Create(Satan, tweenInfoBajar, {Position = posOculta})
    local Bajar666 = TweenService:Create(Numeros666, tweenInfoBajar, {Position = posOculta})
    
    BajarSatan:Play()
    Bajar666:Play()
    
    FireEmitter.Enabled = false
    SlashEmitter.Enabled = false
    BloodLetters.Enabled = false
    NumFire.Enabled = false

    task.wait(4)
    SceneFolder:Destroy()
    isPlaying = false
end

FloatingButton.MouseButton1Click:Connect(CrearEscenaEpica)

Tab:CreateToggle({
   Name = "Activar Botón de Invocación",
   CurrentValue = false,
   Flag = "ToggleBoton", 
   Callback = function(Value)
        FloatingButton.Visible = Value
   end,
})

Tab:CreateLabel("Activa el switch para mostrar el botón flotante.")
Tab:CreateLabel("¡Disfruta los efectos arreglados!")
