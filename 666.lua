-- // Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ritual Monstruoso 666",
   LoadingTitle = "Cargando Escenario Infernal...",
   LoadingSubtitle = "por Delta Executor",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Escena Épica", 4483362458)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs COMBINADOS Y VALIDADOS
local ASSETS = {
    FuegoReal = 241907058,    -- Fuego intenso
    Satan = 1221768461,       -- Malla del Demonio Central y Manada
    LetrasSangre = 226315259, -- Partículas de sangre
    Slash = 422055101         -- Partículas de cortes
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
FloatingButton.Text = "🔥 RITUAL 🔥"
FloatingButton.TextColor3 = Color3.fromRGB(255, 50, 50)
FloatingButton.Font = Enum.Font.Creepster
FloatingButton.TextSize = 25
FloatingButton.Visible = false
FloatingButton.Active = true
FloatingButton.Draggable = true 
FloatingButton.Parent = ScreenGui

local isPlaying = false

-- // NUEVA Función: Generar Espectros usando directamente la malla de Satán (Evita el bug de skin/sin cabeza)
local function GenerarDemonioMinion(targetCFrame, parentFolder)
    local minion = Instance.new("Part")
    minion.Size = Vector3.new(4, 6, 4)
    minion.CFrame = targetCFrame
    minion.Anchored = true
    minion.CanCollide = false
    minion.Color = Color3.fromRGB(15, 0, 0)
    minion.Transparency = 1 -- Invisible al inicio
    minion.Name = "EspectroSatan"
    minion.Parent = parentFolder
    
    local minionMesh = Instance.new("SpecialMesh")
    minionMesh.MeshType = Enum.MeshType.FileMesh
    minionMesh.MeshId = "rbxassetid://" .. tostring(ASSETS.Satan)
    minionMesh.Scale = Vector3.new(0.08, 0.08, 0.08) -- Ligeramente más pequeños que el jefe central
    minionMesh.VertexColor = Vector3.new(1, 0.2, 0.2) 
    minionMesh.Parent = minion
    
    -- Aura oscura y fuego
    local auraOscura = Instance.new("ParticleEmitter")
    auraOscura.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
    auraOscura.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(80, 0, 0))
    auraOscura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 0)})
    auraOscura.Rate = 0 
    auraOscura.Speed = NumberRange.new(1, 3)
    auraOscura.Lifetime = NumberRange.new(1, 1.5)
    auraOscura.ZOffset = 1 
    auraOscura.Parent = minion
    
    return minion, auraOscura
end

local function CrearEscenaEpica()
    if isPlaying then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isPlaying = true
    local hrp = character.HumanoidRootPart
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 20) 
    
    -- Posiciones de animación
    local posOculta = spawnPos - Vector3.new(0, 25, 0) 
    local posFinal = spawnPos + Vector3.new(0, 2, 0)   

    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernalFusionada"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo Infernal
    local SueloFuego = Instance.new("Part")
    SueloFuego.Size = Vector3.new(22, 1, 22)
    SueloFuego.Position = spawnPos - Vector3.new(0, 2, 0)
    SueloFuego.Anchored = true
    SueloFuego.CanCollide = false
    SueloFuego.Transparency = 1
    SueloFuego.Parent = SceneFolder

    local FireEmitter = Instance.new("ParticleEmitter")
    FireEmitter.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
    FireEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 12), NumberSequenceKeypoint.new(1, 0)})
    FireEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 40, 0), Color3.fromRGB(150, 0, 0))
    FireEmitter.Rate = 250
    FireEmitter.Lifetime = NumberRange.new(1.5, 3)
    FireEmitter.Speed = NumberRange.new(6, 12)
    FireEmitter.LightEmission = 1 
    FireEmitter.ZOffset = 1 
    FireEmitter.Parent = SueloFuego

    -- 2. El Cubo Rojo de Invocación
    local CuboRojo = Instance.new("Part")
    CuboRojo.Size = Vector3.new(8, 6, 8)
    CuboRojo.CFrame = CFrame.new(posOculta)
    CuboRojo.Anchored = true
    CuboRojo.CanCollide = false
    CuboRojo.Color = Color3.fromRGB(180, 0, 0)
    CuboRojo.Material = Enum.Material.Neon
    CuboRojo.Parent = SceneFolder

    local CuboFire = FireEmitter:Clone()
    CuboFire.Rate = 80
    CuboFire.LockedToPart = true
    CuboFire.Parent = CuboRojo

    local HorrorSmoke = Instance.new("ParticleEmitter")
    HorrorSmoke.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
    HorrorSmoke.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(50, 0, 0))
    HorrorSmoke.Size = NumberSequence.new(4, 9)
    HorrorSmoke.Rate = 40
    HorrorSmoke.LockedToPart = true
    HorrorSmoke.ZOffset = 3
    HorrorSmoke.Parent = CuboRojo

    -- 3. Entidad Demoníaca visible (Jefe Satán sobre el Cubo)
    local Demonio = Instance.new("Part")
    Demonio.Size = Vector3.new(6, 8, 6)
    Demonio.Anchored = true
    Demonio.CanCollide = false
    Demonio.Color = Color3.fromRGB(20, 0, 0)
    Demonio.CFrame = CFrame.new(posOculta + Vector3.new(0, 7, 0))
    Demonio.Parent = SceneFolder
    
    local DemonioMesh = Instance.new("SpecialMesh")
    DemonioMesh.MeshType = Enum.MeshType.FileMesh
    DemonioMesh.MeshId = "rbxassetid://" .. tostring(ASSETS.Satan)
    DemonioMesh.Scale = Vector3.new(0.12, 0.12, 0.12) 
    DemonioMesh.VertexColor = Vector3.new(1.5, 0.1, 0.1) 
    DemonioMesh.Parent = Demonio

    local SlashEffect = Instance.new("ParticleEmitter")
    SlashEffect.Texture = "rbxassetid://" .. tostring(ASSETS.Slash)
    SlashEffect.Rate = 50
    SlashEffect.Size = NumberSequence.new(8)
    SlashEffect.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    SlashEffect.LightEmission = 1
    SlashEffect.LockedToPart = true
    SlashEffect.ZOffset = 2
    SlashEffect.Parent = Demonio

    local BloodLetters = Instance.new("ParticleEmitter")
    BloodLetters.Texture = "rbxassetid://" .. tostring(ASSETS.LetrasSangre)
    BloodLetters.EmissionDirection = Enum.NormalId.Top
    BloodLetters.Rate = 40
    BloodLetters.Speed = NumberRange.new(8, 12)
    BloodLetters.Size = NumberSequence.new(5)
    BloodLetters.LightEmission = 1
    BloodLetters.LockedToPart = true
    BloodLetters.ZOffset = 2
    BloodLetters.Parent = Demonio

    -- 4. Letras 666 3D con Fuego
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.CFrame = CFrame.new(posOculta + Vector3.new(0, 15, 0))
    Numeros666.Anchored = true
    Numeros666.CanCollide = false
    Numeros666.Transparency = 1
    Numeros666.Parent = SceneFolder

    local Billboard666 = Instance.new("BillboardGui")
    Billboard666.Size = UDim2.new(0, 600, 0, 300)
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

    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 120
    NumFire.Size = NumberSequence.new(4, 6)
    NumFire.LockedToPart = true
    NumFire.Parent = Numeros666

    -- // 5. CREAR LA MANADA CIRCULAR (LOS 5 ESPECTROS SATÁNICOS)
    local TodasLasPartesEspectros = {}
    local EmisoresAuraEspectros = {}
    local radioEspectros = 14 

    for i = 1, 5 do
        local angulo = (i / 5) * math.pi * 2
        local offsetX = math.cos(angulo) * radioEspectros
        local offsetZ = math.sin(angulo) * radioEspectros
        
        -- Elevados un poco (+4) para que no se queden bajo tierra
        local posEspectro = spawnPos + Vector3.new(offsetX, 4, offsetZ) 
        local lookCFrame = CFrame.lookAt(posEspectro, spawnPos + Vector3.new(0, 4, 0))
        
        local minion, aura = GenerarDemonioMinion(lookCFrame, SceneFolder)
        table.insert(TodasLasPartesEspectros, minion)
        if aura then table.insert(EmisoresAuraEspectros, aura) end
    end

    -- // ANIMACIONES
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local tweenInfoFadeIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    -- Invocación del Demonio Jefe (Sube desde el cubo rojo)
    TweenService:Create(CuboRojo, tweenInfoSubir, {CFrame = CFrame.new(posFinal)}):Play()
    TweenService:Create(Demonio, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 15, 0))}):Play()
    
    -- Aparición de la manada (Fade In estilo fantasma)
    for _, aura in ipairs(EmisoresAuraEspectros) do
        aura.Rate = 50 
    end

    for _, minion in ipairs(TodasLasPartesEspectros) do
        -- Transparencia a 0.2 para que se vean un poco traslúcidos y aterradores
        TweenService:Create(minion, tweenInfoFadeIn, {Transparency = 0.2}):Play()
    end

    -- Mantener la escena en pantalla
    task.wait(6)

    -- Animación de regreso al inframundo (El Jefe baja)
    TweenService:Create(CuboRojo, tweenInfoBajar, {CFrame = CFrame.new(posOculta)}):Play()
    TweenService:Create(Demonio, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 15, 0))}):Play()

    -- Desvanecimiento de la manada (Fade Out)
    for _, minion in ipairs(TodasLasPartesEspectros) do
        TweenService:Create(minion, tweenInfoFadeIn, {Transparency = 1}):Play()
    end
    
    -- Apagar flamas gradualmente
    for _, obj in pairs(SceneFolder:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = false
        end
    end

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

Tab:CreateLabel("Script Final: Manada de Demonios Fixeada 😈")
