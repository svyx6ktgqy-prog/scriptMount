-- // Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Escena Monstruosa 666",
   LoadingTitle = "Cargando Escenario Infernal...",
   LoadingSubtitle = "por Delta Executor",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Escena Épica", 4483362458)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // IDs de Assets
local ASSETS = {
    Guest666 = 84901624633443,
    FuegoReal = 241907058
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
    local spawnPos = hrp.Position + (hrp.CFrame.LookVector * 20) 
    local posOculta = spawnPos - Vector3.new(0, 25, 0) 
    local posFinal = spawnPos + Vector3.new(0, 2, 0)   

    local SceneFolder = Instance.new("Folder")
    SceneFolder.Name = "EscenaInfernal"
    SceneFolder.Parent = workspace

    -- 1. Fuego del Suelo Infernal (Suelo dinámico)
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

    -- 2. El Cubo Rojo Adicional (Saliendo de la tierra)
    local CuboRojo = Instance.new("Part")
    CuboRojo.Size = Vector3.new(8, 6, 8)
    CuboRojo.Position = posOculta
    CuboRojo.Anchored = true
    CuboRojo.CanCollide = false
    CuboRojo.Color = Color3.fromRGB(180, 0, 0)
    CuboRojo.Material = Enum.Material.Neon
    CuboRojo.Parent = SceneFolder

    -- Fuego extra rodeando el cubo rojo
    local CuboFire = FireEmitter:Clone()
    CuboFire.Rate = 80
    CuboFire.LockedToPart = true
    CuboFire.Parent = CuboRojo

    -- 3. Cargar al Personaje GUEST 666 (con accesorios, ropa y todo lo que traiga)
    local GuestModel = nil
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(ASSETS.Guest666))[1]
    end)

    if success and result then
        GuestModel = result
        GuestModel.Parent = SceneFolder
        
        -- Si es un modelo completo, asegurarnos de configurarlo bien sobre el cubo
        if GuestModel:IsA("Model") then
            local primary = GuestModel.PrimaryPart or GuestModel:FindFirstChildWhichIsA("BasePart")
            if not primary then
                primary = Instance.new("Part", GuestModel)
                primary.Transparency = 1
                GuestModel.PrimaryPart = primary
            end
            
            for _, part in ipairs(GuestModel:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                    part.CanCollide = false
                end
            end
            GuestModel:SetPrimaryPartCFrame(CFrame.new(posOculta + Vector3.new(0, 6, 0)))
        end
    end

    -- Respaldo por si el ID del Guest falla
    if not GuestModel then
        GuestModel = Instance.new("Part")
        GuestModel.Size = Vector3.new(4, 5, 2)
        GuestModel.Color = Color3.fromRGB(50, 0, 0)
        GuestModel.Material = Enum.Material.Slate
        GuestModel.Anchored = true
        GuestModel.CanCollide = false
        GuestModel.CFrame = CFrame.new(posOculta + Vector3.new(0, 6, 0))
        GuestModel.Parent = SceneFolder
    end

    -- Partículas de Horror/Sangre adicionales encima del Guest 666
    local HorrorSmoke = Instance.new("ParticleEmitter")
    HorrorSmoke.Texture = "rbxassetid://241907058"
    HorrorSmoke.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(80, 0, 0))
    HorrorSmoke.Size = NumberSequence.new(4, 8)
    HorrorSmoke.Rate = 30
    HorrorSmoke.LockedToPart = true
    HorrorSmoke.ZOffset = 3
    HorrorSmoke.Parent = CuboRojo

    -- 4. Letras 666 3D con Fuego Intenso y Efectos de Horror
    local Numeros666 = Instance.new("Part")
    Numeros666.Size = Vector3.new(4, 2, 1)
    Numeros666.CFrame = CFrame.new(posOculta + Vector3.new(0, 12, 0))
    Numeros666.Anchored = true
    Numeros666.CanCollide = false
    Numeros666.Transparency = 1
    Numeros666.Parent = SceneFolder

    local Billboard666 = Instance.new("BillboardGui")
    Billboard666.Size = UDim2.new(0, 600, 0, 300)
    Billboard666.StudsOffset = Vector3.new(0, 6, 0)
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

    -- Flama intensa directo en el texto 666
    local NumFire = FireEmitter:Clone()
    NumFire.Rate = 150
    NumFire.Size = NumberSequence.new(4, 7)
    NumFire.LockedToPart = true
    NumFire.Parent = Numeros666

    -- // ANIMACIONES (Tweening coordinado para que todo suba unido)
    local tweenInfoSubir = TweenInfo.new(4.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tweenInfoBajar = TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    local targetCuboPos = posFinal
    local targetGuestPos = posFinal + Vector3.new(0, 6, 0)
    local target666Pos = posFinal + Vector3.new(0, 12, 0)

    local SubirCubo = TweenService:Create(CuboRojo, tweenInfoSubir, {Position = targetCuboPos})
    local Subir666 = TweenService:Create(Numeros666, tweenInfoSubir, {CFrame = CFrame.new(target666Pos)})
    
    SubirCubo:Play()
    Subir666:Play()

    -- Movimiento especial para el modelo del Guest 666
    local GuestCFrameValue = Instance.new("CFrameValue")
    GuestCFrameValue.Value = CFrame.new(posOculta + Vector3.new(0, 6, 0))
    GuestCFrameValue.Changed:Connect(function(val)
        if GuestModel:IsA("Model") and GuestModel.PrimaryPart then
            GuestModel:SetPrimaryPartCFrame(val)
        elseif GuestModel:IsA("BasePart") then
            GuestModel.CFrame = val
        end
    end)

    local SubirGuest = TweenService:Create(GuestCFrameValue, tweenInfoSubir, {Value = CFrame.new(targetGuestPos)})
    SubirGuest:Play()

    -- Mantener la escena en pantalla
    task.wait(6)

    -- Animación de regreso a la tierra
    local BajarCubo = TweenService:Create(CuboRojo, tweenInfoBajar, {Position = posOculta})
    local Bajar666 = TweenService:Create(Numeros666, tweenInfoBajar, {CFrame = CFrame.new(posOculta + Vector3.new(0, 12, 0))})
    local BajarGuest = TweenService:Create(GuestCFrameValue, tweenInfoBajar, {Value = CFrame.new(posOculta + Vector3.new(0, 6, 0))})

    BajarCubo:Play()
    Bajar666:Play()
    BajarGuest:Play()
    
    -- Apagar flamas progresivamente
    FireEmitter.Enabled = false
    CuboFire.Enabled = false
    NumFire.Enabled = false
    HorrorSmoke.Enabled = false

    task.wait(4)
    SceneFolder:Destroy()
    GuestCFrameValue:Destroy()
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

Tab:CreateLabel("Activa el switch para ver el botón flotante.")
