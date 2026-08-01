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
    Satan = 1221768461,       -- Malla del Demonio Central
    LetrasSangre = 226315259, -- Partículas de sangre
    Slash = 422055101,        -- Partículas de cortes
    SkinManada = 92539602189320 -- ID para los clones de la manada
}

-- Precargar la ropa de la manada para que aparezcan al instante sin lag
local ManadaDesc = nil
task.spawn(function()
    pcall(function() ManadaDesc = Players:GetHumanoidDescriptionFromUserId(ASSETS.SkinManada) end)
end)

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

-- // Función: Clonar tu personaje, aplicar la skin translúcida "Ghost" y superponer el Satán Boss Gigante Vibrante
local function GenerarPersonaje(targetCFrame, parentFolder)
    local char = LocalPlayer.Character
    char.Archivable = true
    local model = char:Clone()
    model.Name = "EspectroGhost"
    model.Parent = parentFolder
    
    -- Limpiar scripts internos
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end
    
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    
    if hrp then
        hrp.Anchored = true
        model:SetPrimaryPartCFrame(targetCFrame)
    end
    
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    end
    
    -- Aplicar transparencia "Ghost" casi translúcida (0.75 de transparencia inicial) a todo el cuerpo/skin intacto
    for _, obj in ipairs(model:GetDescendants()) do
        if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
            obj.Transparency = 1 -- Empieza invisible para el efecto de Fade In
        end
    end

    -- // SATÁN BOSS GIGANTE Y EN LLAMAS VIBRANTE (ARRIBA DE CADA CUBO / ESPECTRO)
    local SatanOverlay = nil
    if hrp then
        SatanOverlay = Instance.new("Part")
        SatanOverlay.Name = "SatanBossVibrante"
        -- Talla grande para el Boss
        SatanOverlay.Size = Vector3.new(12, 16, 12)
        -- Posicionado exactamente arriba del cubo/espectro (desplazado hacia arriba)
        SatanOverlay.CFrame = targetCFrame + Vector3.new(0, 10, 0)
        SatanOverlay.Anchored = true
        SatanOverlay.CanCollide = false
        SatanOverlay.Color = Color3.fromRGB(255, 0, 0)
        SatanOverlay.Material = Enum.Material.Neon
        SatanOverlay.Transparency = 1 -- Inicia invisible para la animación
        SatanOverlay.Parent = model
        
        local DemonioMesh = Instance.new("SpecialMesh")
        DemonioMesh.MeshType = Enum.MeshType.FileMesh
        DemonioMesh.MeshId = "rbxassetid://" .. tostring(ASSETS.Satan)
        DemonioMesh.Scale = Vector3.new(0.25, 0.25, 0.25) -- Más grande
        DemonioMesh.VertexColor = Vector3.new(3, 0.2, 0.2) -- Rojo en flama ultra brillante
        DemonioMesh.Parent = SatanOverlay

        -- Fuego intenso rodeando al Boss
        local BossFire = Instance.new("ParticleEmitter")
        BossFire.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
        BossFire.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 0)})
        BossFire.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 0, 0))
        BossFire.Rate = 100
        BossFire.Speed = NumberRange.new(4, 8)
        BossFire.Lifetime = NumberRange.new(1, 2)
        BossFire.LightEmission = 1
        BossFire.LockedToPart = true
        BossFire.Parent = SatanOverlay
    end
    
    -- Aura oscura fantasmagórica
    local auraOscura = nil
    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or hrp
    if torso then
        auraOscura = Instance.new("ParticleEmitter")
        auraOscura.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal)
        auraOscura.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(40, 0, 0))
        auraOscura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)})
        auraOscura.Rate = 0 
        auraOscura.Speed = NumberRange.new(2, 4)
        auraOscura.Lifetime = NumberRange.new(1, 1.5)
        auraOscura.ZOffset = 1 
        auraOscura.Parent = torso
    end
    
    return model, auraOscura, SatanOverlay
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

    -- 2. El Cubo Rojo de Invocación Principal
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

    -- 3. Entidad Demoníaca Central
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

    -- // 5. CREAR LA MANADA MANUALMENTE CON CUBOS GHOST CASI TRASLÚCIDOS + SATÁN BOSS VIBRANTE ARRIBA
    local TodasLasPartesEspectros = {}
    local SatanBossesList = {}
    local EmisoresAuraEspectros = {}
    local radioEspectros = 14 

    for i = 1, 5 do
        local angulo = (i / 5) * math.pi * 2
        local offsetX = math.cos(angulo) * radioEspectros
        local offsetZ = math.sin(angulo) * radioEspectros
        
        local posEspectro = spawnPos + Vector3.new(offsetX, 1.5, offsetZ) 
        local lookCFrame = CFrame.lookAt(posEspectro, spawnPos + Vector3.new(0, 1.5, 0))
        
        -- Generar clon ghost con skin intacta y cabeza sin tocar + Satán boss gigante arriba
        local modeloNPC, aura, satanBoss = GenerarPersonaje(lookCFrame, SceneFolder)
        table.insert(TodasLasPartesEspectros, modeloNPC)
        if satanBoss then table.insert(SatanBossesList, satanBoss) end
        if aura then table.insert(EmisoresAuraEspectros, aura) end
    end

    -- // ANIMACIONES Y VIBRACIÓN DEL SATÁN BOSS
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local tweenInfoFadeIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    TweenService:Create(CuboRojo, tweenInfoSubir, {CFrame = CFrame.new(posFinal)}):Play()
    TweenService:Create(Demonio, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 15, 0))}):Play()
    
    for _, aura in ipairs(EmisoresAuraEspectros) do
        aura.Rate = 50 
    end

    -- Fade In de los espectros ghost y los bosses rojos en flama
    for _, npc in ipairs(TodasLasPartesEspectros) do
        for _, obj in ipairs(npc:GetDescendants()) do
            if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "SatanBossVibrante") or obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 0.75}):Play() -- Ghost style casi traslúcido
            end
        end
    end

    for _, boss in ipairs(SatanBossesList) do
        TweenService:Create(boss, tweenInfoFadeIn, {Transparency = 0}):Play()
    end

    -- Bucle de vibración intensa para los Satán Bosses
    local vibrarActivo = true
    task.spawn(function()
        while vibrarActivo do
            for _, boss in ipairs(SatanBossesList) do
                if boss and boss.Parent then
                    local offsetVib = Vector3.new(math.random(-3, 3) * 0.1, math.random(-3, 3) * 0.1, math.random(-3, 3) * 0.1)
                    boss.CFrame = boss.CFrame + offsetVib
                end
            end
            task.wait(0.05)
        end
    end)

    task.wait(6)

    -- Fin del ritual: Detener vibración y desvanecer
    vibrarActivo = false

    TweenService:Create(CuboRojo, tweenInfoBajar, {CFrame = CFrame.new(posOculta)}):Play()
    TweenService:Create(Demonio, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 7, 0))}):Play()
    TweenService:Create(Numeros666, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 15, 0))}):Play()

    for _, npc in ipairs(TodasLasPartesEspectros) do
        for _, obj in ipairs(npc:GetDescendants()) do
            if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 1}):Play()
            end
        end
    end
    
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

Tab:CreateLabel("Script Final: Manada Ghost Traslúcida + Satán Boss Vibrante")
