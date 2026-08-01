-- // Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ritual Demoniaco 666",
   LoadingTitle = "Invocando Manada...",
   LoadingSubtitle = "por Delta Executor",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Escena Épica", 4483362458)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs COMBINADOS
local ASSETS = {
    FuegoReal = 241907058,    
    Satan = 1221768461,       
    LetrasSangre = 226315259, 
    Slash = 422055101,
    SkinCultista = 75674585114952
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

-- // Función para construir un Espectro
local function GenerarPersonaje(targetCFrame, parentFolder)
    local model = Instance.new("Model", parentFolder)
    model.Name = "EspectroManada"
    local parts = {}
    
    local function crearParte(size, offset, name)
        local p = Instance.new("Part")
        p.Size = size
        p.CFrame = targetCFrame * CFrame.new(offset)
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 1 
        p.Color = Color3.fromRGB(15, 15, 15) 
        p.Material = Enum.Material.Neon
        p.Name = name
        p.Parent = model
        table.insert(parts, p)
        return p
    end
    
    local torso = crearParte(Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), "Torso")
    local head = crearParte(Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 1.5, 0), "Head")
    local leftArm = crearParte(Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0), "LeftArm")
    local rightArm = crearParte(Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0), "RightArm")
    local leftLeg = crearParte(Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0), "LeftLeg")
    local rightLeg = crearParte(Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0), "RightLeg")
    
    local auraOscura = Instance.new("ParticleEmitter")
    auraOscura.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
    auraOscura.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(40, 0, 0))
    auraOscura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)})
    auraOscura.Rate = 0 
    auraOscura.Speed = NumberRange.new(2, 4)
    auraOscura.Lifetime = NumberRange.new(1, 1.5)
    auraOscura.Parent = torso

    for _, p in ipairs(parts) do
        local decalFront = Instance.new("Decal")
        decalFront.Texture = "rbxassetid://" .. tostring(ASSETS.SkinCultista)
        decalFront.Face = Enum.NormalId.Front
        decalFront.Transparency = 1
        decalFront.Parent = p
        
        local decalBack = Instance.new("Decal")
        decalBack.Texture = "rbxassetid://" .. tostring(ASSETS.SkinCultista)
        decalBack.Face = Enum.NormalId.Back
        decalBack.Transparency = 1
        decalBack.Parent = p
    end
    
    return parts, auraOscura
end

local function CrearEscenaEpica()
    if isPlaying then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isPlaying = true
    local hrp = character.HumanoidRootPart
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 20) 
    
    local posOculta = spawnPos - Vector3.new(0, 25, 0) 
    local posFinal = spawnPos + Vector3.new(0, 2, 0)   

    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernalFusionada"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo
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
    FireEmitter.Parent = SueloFuego

    -- 2. Cubo de Invocación (AHORA CON SU FUEGO Y HUMO DE REGRESO)
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

    -- 3. Entidad Demoníaca
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

    -- (EFECTOS DE CORTES DE REGRESO)
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
    BloodLetters.Parent = Demonio

    -- 4. Letras 666 3D
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

    -- (FUEGO EN EL 666 DE REGRESO)
    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 120
    NumFire.Size = NumberSequence.new(4, 6)
    NumFire.LockedToPart = true
    NumFire.Parent = Numeros666

    -- 5. CREAR LA MANADA CIRCULAR (LOS 5 ESPECTROS)
    local TodasLasPartesEspectros = {}
    local EmisoresAuraEspectros = {}
    local radioEspectros = 14 

    for i = 1, 5 do
        local angulo = (i / 5) * math.pi * 2
        local offsetX = math.cos(angulo) * radioEspectros
        local offsetZ = math.sin(angulo) * radioEspectros
        
        local posEspectro = spawnPos + Vector3.new(offsetX, 3, offsetZ) 
        local lookCFrame = CFrame.lookAt(posEspectro, spawnPos + Vector3.new(0, 3, 0))
        
        local partes, aura = GenerarPersonaje(lookCFrame, SceneFolder)
        
        for _, p in ipairs(partes) do
            table.insert(TodasLasPartesEspectros, p)
        end
        table.insert(EmisoresAuraEspectros, aura)
    end

    -- // ANIMACIONES Y EFECTOS
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoFadeIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    -- Subir Cubo, Demonio y 666
    TweenService:Create(CuboRojo, tweenInfoSubir, {CFrame = CFrame.new(posFinal)}):Play()
    TweenService:Create(Demonio, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 15, 0))}):Play()

    -- Efecto Fade In (Aparición de la Manada)
    for _, aura in ipairs(EmisoresAuraEspectros) do
        aura.Rate = 50 
    end

    for _, part in ipairs(TodasLasPartesEspectros) do
        TweenService:Create(part, tweenInfoFadeIn, {Transparency = 0.1}):Play() 
        for _, obj in ipairs(part:GetChildren()) do
            if obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 0}):Play()
            end
        end
    end

    task.wait(7)

    -- // DESVANECER (El ritual termina)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    TweenService:Create(CuboRojo, tweenInfoBajar, {CFrame = CFrame.new(posOculta)}):Play()
    TweenService:Create(Demonio, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 15, 0))}):Play()

    -- Efecto Fade Out (Desaparición de la Manada)
    for _, aura in ipairs(EmisoresAuraEspectros) do
        aura.Enabled = false 
    end

    for _, part in ipairs(TodasLasPartesEspectros) do
        TweenService:Create(part, tweenInfoFadeIn, {Transparency = 1}):Play()
        for _, obj in ipairs(part:GetChildren()) do
            if obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 1}):Play()
            end
        end
    end
    
    -- Apagar flamas centrales gradualmente
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
   Name = "Activar Botón de Ritual",
   CurrentValue = false,
   Flag = "ToggleBoton", 
   Callback = function(Value)
        FloatingButton.Visible = Value
   end,
})

Tab:CreateLabel("Script Definitivo: Todo el Fuego + Manada")
