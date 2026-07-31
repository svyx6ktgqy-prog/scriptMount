-- Librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🏆 World Cup Hub",
    LoadingTitle = "Cargando Caos Total...",
    LoadingSubtitle = "por Gemini",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Festejo", 4483362458)
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local isCelebrating = false
local celebrationAssets = {}

-- IDs
local CUP_MODEL_ID = "rbxassetid://118466807930342"
local FIREWORK_SOUNDS = {
    "rbxassetid://90779381422678", 
    "rbxassetid://136415610645234", 
    "rbxassetid://115500038019146", 
    "rbxassetid://9038466535"
}
local FESTEJO_PARTICLES_ID = "rbxassetid://79124632949757"

---------------------------------------------------------
-- FUNCIONES DE PARTÍCULAS CAÓTICAS Y EXPLOSIONES
---------------------------------------------------------
local function createChaoticConfetti(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "ConfettiCaotico"
    emitter.Texture = "rbxassetid://5860882195" 
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 255, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 0))
    })
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.1)})
    emitter.Rate = 200
    emitter.VelocitySpread = 360 -- Dispara hacia TODAS partes
    emitter.Speed = NumberRange.new(20, 40)
    emitter.Lifetime = NumberRange.new(3, 6)
    emitter.Acceleration = Vector3.new(0, -15, 0) -- Caen al suelo simulando gravedad
    emitter.RotSpeed = NumberRange.new(-300, 300)
    emitter.LightEmission = 0.8 -- Muy brillantes
    emitter.Parent = parent
    return emitter
end

local function createRibbons(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "Tiritas"
    emitter.Texture = "rbxassetid://14371490906" -- Textura de línea/rastro
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    emitter.Size = NumberSequence.new(1, 0)
    emitter.Rate = 150
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(30, 60)
    emitter.Acceleration = Vector3.new(0, -20, 0)
    emitter.Drag = 2 -- Frenan en el aire y caen suave
    emitter.Lifetime = NumberRange.new(4, 7)
    emitter.Parent = parent
    return emitter
end

local function explosionMasiva(position)
    local attachment = Instance.new("Attachment", workspace.Terrain)
    attachment.WorldPosition = position

    -- Partículas del estallido
    local sparks = Instance.new("ParticleEmitter", attachment)
    sparks.Texture = "rbxassetid://7369527715"
    sparks.Color = ColorSequence.new(Color3.fromHSV(math.random(), 1, 1)) -- Color aleatorio vibrante
    sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
    sparks.Speed = NumberRange.new(50, 100)
    sparks.VelocitySpread = 360
    sparks.Drag = 3
    sparks.Lifetime = NumberRange.new(1, 2)
    sparks.LightEmission = 1
    sparks.Rate = 0

    local confetiExplosion = createChaoticConfetti(attachment)
    confetiExplosion.Rate = 0
    confetiExplosion.Speed = NumberRange.new(60, 120)

    -- Emitir golpe masivo
    sparks:Emit(150)
    confetiExplosion:Emit(300)

    task.delay(5, function() attachment:Destroy() end)
end

local function spawnFirework(char)
    if not isCelebrating then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local firework = Instance.new("Part")
    firework.Size = Vector3.new(1, 1, 1)
    firework.Position = root.Position + Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
    firework.BrickColor = BrickColor.Random()
    firework.Material = Enum.Material.Neon
    firework.CanCollide = false
    firework.Parent = workspace

    local isDud = math.random(1, 100) <= 20
    local bv = Instance.new("BodyVelocity", firework)
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    
    if isDud then
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(10, 20), math.random(-15, 15))
    else
        bv.Velocity = Vector3.new(math.random(-10, 10), math.random(120, 180), math.random(-10, 10))
    end

    local launchSound = Instance.new("Sound", firework)
    launchSound.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
    launchSound.Volume = 2
    launchSound:Play()

    task.delay(isDud and 1 or 2.5, function()
        if firework.Parent then
            local exp = Instance.new("Explosion", workspace)
            exp.Position = firework.Position
            exp.BlastRadius = 0
            
            local bang = Instance.new("Sound", workspace)
            bang.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
            bang.Volume = 5
            bang.PlayOnRemove = true
            bang:Destroy()

            explosionMasiva(firework.Position)
            firework:Destroy()
        end
    end)
end

---------------------------------------------------------
-- BOTÓN FLOTANTE: DESLIZAMIENTO DE PINGÜINO
---------------------------------------------------------
local function createPenguinButton()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PenguinSlideGUI"
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0, 20, 0.5, -35) -- Izquierda centrada
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btn.Text = "🐧"
    btn.TextSize = 40
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0) -- Botón redondo
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(255,255,255)

    local isSliding = false

    btn.MouseButton1Click:Connect(function()
        if isSliding then return end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end

        isSliding = true
        hum.PlatformStand = true -- Tira al jugador

        -- Girar de pecho al suelo
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(400000, 400000, 400000)
        bg.CFrame = root.CFrame * CFrame.Angles(math.rad(-85), 0, 0)
        
        -- Impulso hacia adelante
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(100000, 0, 100000) -- Solo impulsa en X y Z
        bv.Velocity = root.CFrame.LookVector * 60

        -- Echar brazos atrás
        local rightJoint, leftJoint
        local rOriginalC0, lOriginalC0
        pcall(function()
            if hum.RigType == Enum.HumanoidRigType.R15 then
                rightJoint = char.RightUpperArm.RightShoulder
                leftJoint = char.LeftUpperArm.LeftShoulder
            else
                rightJoint = char.Torso["Right Shoulder"]
                leftJoint = char.Torso["Left Shoulder"]
            end
            rOriginalC0 = rightJoint.C0
            lOriginalC0 = leftJoint.C0
            
            -- Brazos hacia atrás
            rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(180), 0, math.rad(20))
            leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(180), 0, math.rad(-20))
        end)

        task.wait(2.5) -- Tiempo que dura deslizando

        -- Levantarse
        bg:Destroy()
        bv:Destroy()
        pcall(function()
            if rightJoint and rOriginalC0 then rightJoint.C0 = rOriginalC0 end
            if leftJoint and lOriginalC0 then leftJoint.C0 = lOriginalC0 end
        end)
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        isSliding = false
    end)
end

-- Generar el botón de pingüino al cargar el script
createPenguinButton()

---------------------------------------------------------
-- LÓGICA PRINCIPAL (Levantar Copa)
---------------------------------------------------------
Tab:CreateToggle({
    Name = "🏆 Levantar la Copa (Celebración Épica)",
    CurrentValue = false,
    Flag = "CupToggle",
    Callback = function(Value)
        isCelebrating = Value
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        if isCelebrating then
            -- 1. CARGAR LA COPA
            pcall(function()
                local cupObjects = game:GetObjects(CUP_MODEL_ID)
                local cup = cupObjects[1]
                if cup then
                    cup.Parent = char
                    local weld = Instance.new("WeldConstraint", cup)
                    weld.Part0 = root
                    weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                    
                    local offset = CFrame.new(0, 3.5, -1)
                    if cup:IsA("Model") then
                        cup:SetPrimaryPartCFrame(root.CFrame * offset)
                    else
                        cup.CFrame = root.CFrame * offset
                    end
                    table.insert(celebrationAssets, cup)
                end
            end)

            -- 2. PARTÍCULAS CAÓTICAS EN EL CUERPO
            local chaosAttachment = Instance.new("Attachment", root)
            table.insert(celebrationAssets, chaosAttachment)
            
            table.insert(celebrationAssets, createChaoticConfetti(root))
            table.insert(celebrationAssets, createRibbons(root))
            
            local festejoEmitter = Instance.new("ParticleEmitter", chaosAttachment)
            festejoEmitter.Texture = FESTEJO_PARTICLES_ID
            festejoEmitter.Rate = 60
            table.insert(celebrationAssets, festejoEmitter)

            -- 3. BUCLE DE ACCIONES
            task.spawn(function()
                local cam = workspace.CurrentCamera
                while isCelebrating and char and root and humanoid.Health > 0 do
                    if not humanoid.PlatformStand then -- Solo salta si no está haciendo de pingüino
                        humanoid.Jump = true
                    end

                    -- Terremoto de cámara
                    cam.CFrame = cam.CFrame * CFrame.new(
                        math.random(-10, 10)/15, 
                        math.random(-25, 25)/15, 
                        math.random(-10, 10)/15
                    )
                    
                    if math.random(1, 3) == 1 then
                        spawnFirework(char)
                    end
                    task.wait(0.1)
                end
            end)
            
            -- 4. BRAZOS ARRIBA
            pcall(function()
                if humanoid.RigType == Enum.HumanoidRigType.R15 then
                    char.RightUpperArm.RightShoulder.C0 = char.RightUpperArm.RightShoulder.C0 * CFrame.Angles(math.rad(150), 0, math.rad(-20))
                    char.LeftUpperArm.LeftShoulder.C0 = char.LeftUpperArm.LeftShoulder.C0 * CFrame.Angles(math.rad(150), 0, math.rad(20))
                else
                    char.Torso["Right Shoulder"].C0 = char.Torso["Right Shoulder"].C0 * CFrame.Angles(math.rad(150), 0, math.rad(-20))
                    char.Torso["Left Shoulder"].C0 = char.Torso["Left Shoulder"].C0 * CFrame.Angles(math.rad(150), 0, math.rad(20))
                end
            end)

        else
            -- APAGAR TODO
            isCelebrating = false
            for _, asset in pairs(celebrationAssets) do
                if asset and asset.Parent then asset:Destroy() end
            end
            celebrationAssets = {}
            
            -- Restaurar brazos
            pcall(function()
                if humanoid.RigType == Enum.HumanoidRigType.R15 then
                    char.RightUpperArm.RightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
                    char.LeftUpperArm.LeftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                else
                    char.Torso["Right Shoulder"].C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
                    char.Torso["Left Shoulder"].C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
                end
            end)
        end
    end,
})
