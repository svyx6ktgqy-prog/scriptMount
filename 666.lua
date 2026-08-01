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
local InsertService = game:GetService("InsertService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs (Se asume que pueden ser Modelos de la Toolbox o Decals)
local ASSETS = {
    LetrasSangre = 88425869123525,
    Slash = 121659392958456,
    Satan = 86446020650559,
    FuegoReal = 241907058 -- Este es un ID de textura muy conocido, lo dejaremos como textura
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

-- Función para cargar modelos/partículas de forma segura
local function SafeLoadAsset(id)
    local success, result = pcall(function()
        return InsertService:LoadAsset(id)
    end)
    if success and result then
        -- Devuelve el primer objeto útil dentro del modelo cargado
        return result:GetChildren()[1]
    end
    return nil
end

local function CrearEscenaEpica()
    if isPlaying then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isPlaying = true
    local hrp = character.HumanoidRootPart
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 20) 
    local posOculta = spawnPos - Vector3.new(0, 20, 0) 
    local posFinal = spawnPos + Vector3.new(0, 3, 0)   

    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernal"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo (Usamos el ID clásico como textura)
    local SueloFuego = Instance.new("Part")
    SueloFuego.Size = Vector3.new(20, 1, 20)
    SueloFuego.Position = spawnPos - Vector3.new(0, 2, 0)
    SueloFuego.Anchored = true
    SueloFuego.CanCollide = false
    SueloFuego.Transparency = 1
    SueloFuego.Parent = SceneFolder

    local FireEmitter = Instance.new("ParticleEmitter")
    -- Intentamos forzar el ID como imagen
    FireEmitter.Texture = "rbxassetid://" .. tostring(ASSETS.FuegoReal) 
    FireEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)})
    FireEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 0, 0))
    FireEmitter.Rate = 200
    FireEmitter.Lifetime = NumberRange.new(1.5, 2.5)
    FireEmitter.Speed = NumberRange.new(5, 10)
    FireEmitter.LightEmission = 1 
    FireEmitter.ZOffset = 1 
    FireEmitter.Parent = SueloFuego

    -- 2. Cargar a Satán usando InsertService
    local SatanModel = SafeLoadAsset(ASSETS.Satan)
    local SatanRootPart = nil

    if SatanModel then
        SatanModel.Parent = SceneFolder
        
        -- Si es un modelo complejo con un PrimaryPart o partes dentro
        if SatanModel:IsA("Model") then
            SatanRootPart = SatanModel.PrimaryPart or SatanModel:FindFirstChildWhichIsA("BasePart")
            if not SatanRootPart then
                -- Si no tiene BasePart, creamos una para anclarlo
                SatanRootPart = Instance.new("Part", SatanModel)
                SatanRootPart.Transparency = 1
                SatanModel.PrimaryPart = SatanRootPart
            end
            SatanModel:MoveTo(posOculta)
            -- Anclar todas las partes del modelo
            for _, part in ipairs(SatanModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                    part.CanCollide = false
                end
            end
        elseif SatanModel:IsA("BasePart") then
            -- Si es solo una parte suelta
            SatanRootPart = SatanModel
            SatanRootPart.Position = posOculta
            SatanRootPart.Anchored = true
            SatanRootPart.CanCollide = false
        end
    end

    -- Si por alguna razón InsertService falla (ej. juego con restricciones estrictas), creamos un bloque de respaldo
    if not SatanRootPart then
        SatanRootPart = Instance.new("Part")
        SatanRootPart.Size = Vector3.new(6, 8, 6)
        SatanRootPart.Position = posOculta
        SatanRootPart.Anchored = true
        SatanRootPart.CanCollide = false
        SatanRootPart.Color = Color3.fromRGB(150, 0, 0)
        SatanRootPart.Material = Enum.Material.Neon
        SatanRootPart.Parent = SceneFolder
        SatanModel = SatanRootPart
    end

    -- 3. Efectos de Partículas (Intentar cargar como modelos si no son imágenes simples)
    local SlashEffect = SafeLoadAsset(ASSETS.Slash)
    if SlashEffect and SlashEffect:IsA("ParticleEmitter") then
        SlashEffect = SlashEffect:Clone()
    else
        -- Respaldo si no se puede descargar el modelo de partícula
        SlashEffect = Instance.new("ParticleEmitter")
        SlashEffect.Texture = "rbxassetid://" .. tostring(ASSETS.Slash)
    end
    SlashEffect.Rate = 50
    SlashEffect.Size = NumberSequence.new(8)
    SlashEffect.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    SlashEffect.LightEmission = 1
    SlashEffect.LockedToPart = true
    SlashEffect.ZOffset = 2
    SlashEffect.Parent = SatanRootPart

    local BloodLetters = SafeLoadAsset(ASSETS.LetrasSangre)
    if BloodLetters and BloodLetters:IsA("ParticleEmitter") then
        BloodLetters = BloodLetters:Clone()
    else
        BloodLetters = Instance.new("ParticleEmitter")
        BloodLetters.Texture = "rbxassetid://" .. tostring(ASSETS.LetrasSangre)
    end
    BloodLetters.EmissionDirection = Enum.NormalId.Top
    BloodLetters.Rate = 40
    BloodLetters.Speed = NumberRange.new(8, 12)
    BloodLetters.Size = NumberSequence.new(5)
    BloodLetters.LightEmission = 1
    BloodLetters.LockedToPart = true
    BloodLetters.ZOffset = 2
    BloodLetters.Parent = SatanRootPart

    -- 4. Letras 666 3D
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.Position = posOculta + Vector3.new(0, 8, 0)
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

    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 100
    NumFire.Size = NumberSequence.new(3, 5)
    NumFire.LockedToPart = true
    NumFire.Parent = Numeros666

    -- // ANIMACIONES
    -- TweenService no funciona bien con Modelos completos si no se usa SetPrimaryPartCFrame, 
    -- así que usaremos un bucle RunService suave o Tween en un CFrameValue
    
    local CFrameValue = Instance.new("CFrameValue")
    CFrameValue.Value = CFrame.new(posOculta)
    
    -- Actualizar la posición de SatanModel según el Tween
    CFrameValue.Changed:Connect(function(newCFrame)
        if SatanModel:IsA("Model") then
            SatanModel:SetPrimaryPartCFrame(newCFrame)
        else
            SatanRootPart.CFrame = newCFrame
        end
    end)

    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    local SubirSatan = TweenService:Create(CFrameValue, tweenInfoSubir, {Value = CFrame.new(posFinal)})
    local Subir666 = TweenService:Create(Numeros666, tweenInfoSubir, {Position = posFinal + Vector3.new(0, 10, 0)})
    
    SubirSatan:Play()
    Subir666:Play()

    task.wait(6)

    local BajarSatan = TweenService:Create(CFrameValue, tweenInfoBajar, {Value = CFrame.new(posOculta)})
    local Bajar666 = TweenService:Create(Numeros666, tweenInfoBajar, {Position = posOculta})
    
    BajarSatan:Play()
    Bajar666:Play()
    
    FireEmitter.Enabled = false
    SlashEffect.Enabled = false
    BloodLetters.Enabled = false
    NumFire.Enabled = false

    task.wait(4)
    SceneFolder:Destroy()
    CFrameValue:Destroy()
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

Tab:CreateLabel("Activa el switch para mostrar el botón.")
