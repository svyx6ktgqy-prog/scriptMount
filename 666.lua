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
    FuegoReal = 241907058,        -- Fuego intenso
    Satan = 1221768461,           -- Malla del Demonio Central
    LetrasSangre = 226315259,     -- Partículas de sangre
    Slash = 422055101,            -- Partículas de cortes
    SkinManada = 92539602189320   -- ID oficial de Satanás para la manada y el extra superior
}

-- Precargar la descripción de Satanás globalmente para que se aplique perfecto y sin fallos
local SatanDescription = nil
task.spawn(function()
    pcall(function()
        SatanDescription = Players:GetHumanoidDescriptionFromUserId(ASSETS.SkinManada)
    end)
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

-- // Función corregida para forzar la skin real de Satanás en los avatares clonados
local function GenerarPersonaje(targetCFrame, parentFolder)
    local char = LocalPlayer.Character
    char.Archivable = true
    local model = char:Clone()
    model.Name = "EspectroManada"
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
        
        -- Aplicar de forma segura la descripción exacta de Satanás
        task.spawn(function()
            -- Si la precarga falló, intentamos descargarla de nuevo en el momento
            local desc = SatanDescription
            if not desc then
                pcall(function()
                    desc = Players:GetHumanoidDescriptionFromUserId(ASSETS.SkinManada)
                end)
            end
            if desc then
                pcall(function()
                    hum:ApplyDescription(desc)
                end)
            end
        end)
    end
    
    -- Hacerlo completamente invisible al inicio para el efecto Ghost Style
    for _, obj in ipairs(model:GetDescendants()) do
        if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
            obj.Transparency = 1
        end
    end
    
    -- Aura de los espectros
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
    
    return model, auraOscura
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

    -- 1. Fuego del Suelo Infernal (INTACTO)
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

    -- 2. El Cubo Rojo de Invocación (INTACTO)
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

    -- 3. Entidad Demoníaca visible central (INTACTO)
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

    -- 3.5 NUEVO: OTRO SATÁN NPC FLOTANDO ARRIBA DEL CUBO
    local posOcultaSatanExtra = posOculta + Vector3.new(0, 14, 0)
    local _, SatanExtraHRP = GenerarPersonaje(CFrame.new(posOcultaSatanExtra), SceneFolder)

    -- 4. Letras 666 3D con Fuego (INTACTO)
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.CFrame = CFrame.new(posOculta + Vector3.new(0, 21, 0)) -- Subido un poco más para que no choque con el Satán extra
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

    -- // 5. CREAR LA MANADA CIRCULAR (LOS 5 ESPECTROS NPC)
    local TodasLasPartesEspectros = {}
    local EmisoresAuraEspectros = {}
    local radioEspectros = 14 

    for i = 1, 5 do
        local angulo = (i / 5) * math.pi * 2
        local offsetX = math.cos(angulo) * radioEspectros
        local offsetZ = math.sin(angulo) * radioEspectros
        
        local posEspectro = spawnPos + Vector3.new(offsetX, 1.5, offsetZ) 
        local lookCFrame = CFrame.lookAt(posEspectro, spawnPos + Vector3.new(0, 1.5, 0))
        
        local modeloNPC, aura = GenerarPersonaje(lookCFrame, SceneFolder)
        table.insert(TodasLasPartesEspectros, modeloNPC)
        if aura then table.insert(EmisoresAuraEspectros, aura) end
    end
    
    -- Agregar también el Satán extra a la lista de la manada para que sufra el mismo efecto fantasma
    if SatanExtraHRP then
        local modeloExtraNPC = SatanExtraHRP.Parent
        table.insert(TodasLasPartesEspectros, modeloExtraNPC)
    end

    -- // ANIMACIONES
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local tweenInfoFadeIn = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    -- Subida de elementos centrales
    TweenService:Create(CuboRojo, tweenInfoSubir, {CFrame = CFrame.new(posFinal)}):Play()
    TweenService:Create(Demonio, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 7, 0))}):Play()
    
    if SatanExtraHRP then
        TweenService:Create(SatanExtraHRP, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 14, 0))}):Play()
    end
    
    TweenService:Create(Numeros666, tweenInfoSubir, {CFrame = CFrame.new(posFinal + Vector3.new(0, 21, 0))}):Play()
    
    -- Aparición fantasmal de la manada y el Satán extra (Ghost Style)
    for _, aura in ipairs(EmisoresAuraEspectros) do
        aura.Rate = 50 
    end

    for _, npc in ipairs(TodasLasPartesEspectros) do
        for _, obj in ipairs(npc:GetDescendants()) do
            if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 0.1}):Play()
            end
        end
    end

    -- Mantener la escena en pantalla
    task.wait(6)

    -- Animación de regreso al inframundo y desvanecimiento
    TweenService:Create(CuboRojo, tweenInfoBajar, {CFrame = CFrame.new(posOculta)}):Play()
    TweenService:Create(Demonio, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 7, 0))}):Play()
    
    if SatanExtraHRP then
        TweenService:Create(SatanExtraHRP, tweenInfoBajar, {CFrame = CFrame.new(posOcultaSatanExtra)}):Play()
    end
    
    TweenService:Create(Numeros666, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 21, 0))}):Play()

    for _, npc in ipairs(TodasLasPartesEspectros) do
        for _, obj in ipairs(npc:GetDescendants()) do
            if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
                TweenService:Create(obj, tweenInfoFadeIn, {Transparency = 1}):Play()
            end
        end
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

Tab:CreateLabel("Script Final: Satán Extra Arriba del Cubo + Manada NPC Fix")
