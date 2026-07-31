-- Librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🏆 World Cup Hub",
    LoadingTitle = "Cargando Celebración...",
    LoadingSubtitle = "por Gemini",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Festejo", 4483362458)
local player = game.Players.LocalPlayer
local isCelebrating = false
local connections = {}
local celebrationAssets = {}

-- IDs Proporcionados
local CUP_MODEL_ID = "rbxassetid://118466807930342"
local FIREWORK_SOUNDS = {
    "rbxassetid://90779381422678", 
    "rbxassetid://136415610645234", 
    "rbxassetid://115500038019146", 
    "rbxassetid://9038466535"
}
local FESTEJO_PARTICLES_ID = "rbxassetid://79124632949757"

-- Función para crear confeti
local function createConfetti(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "Confetti"
    emitter.Texture = "rbxassetid://5860882195" -- Textura estándar de confeti
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
    })
    emitter.Size = NumberSequence.new(0.5, 0.2)
    emitter.Rate = 100
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(15, 30)
    emitter.Lifetime = NumberRange.new(3, 5)
    emitter.Parent = parent
    return emitter
end

-- Función de Fuegos Artificiales
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

    -- ¿Fuego artificial fallido? (20% de probabilidad)
    local isDud = math.random(1, 100) <= 20
    
    local bv = Instance.new("BodyVelocity")
    if isDud then
        bv.Velocity = Vector3.new(math.random(-10, 10), math.random(10, 30), math.random(-10, 10)) -- Vuela poco
    else
        bv.Velocity = Vector3.new(math.random(-5, 5), math.random(80, 150), math.random(-5, 5)) -- Vuela alto
    end
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Parent = firework

    -- Sonido de lanzamiento
    local launchSound = Instance.new("Sound")
    launchSound.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
    launchSound.Volume = 2
    launchSound.Parent = firework
    launchSound:Play()

    task.delay(isDud and 1 or 2.5, function()
        if firework.Parent then
            local exp = Instance.new("Explosion")
            exp.Position = firework.Position
            exp.BlastRadius = 0 -- Solo visual
            exp.Parent = workspace
            
            local bang = Instance.new("Sound")
            bang.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
            bang.Volume = 5
            bang.Parent = workspace
            bang.PlayOnRemove = true
            bang:Destroy()

            -- Partículas de explosión detalladas
            local attachment = Instance.new("Attachment", workspace.Terrain)
            attachment.WorldPosition = firework.Position
            local particles = createConfetti(attachment)
            particles.Rate = 1000
            task.delay(0.2, function() particles.Enabled = false end)
            task.delay(5, function() attachment:Destroy() end)

            firework:Destroy()
        end
    end)
end

-- Lógica Principal del Switch
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
            -- 1. CARGAR LA COPA Y EQUIPARLA
            pcall(function()
                -- Intentamos cargar el modelo (Nota: requiere que el ID sea público o un MeshId)
                local cupObjects = game:GetObjects(CUP_MODEL_ID)
                local cup = cupObjects[1]
                if cup then
                    cup.Parent = char
                    cup.Name = "WorldCup_Gemini"
                    -- Soldar a la mano o torso
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                    weld.Parent = cup
                    
                    if cup:IsA("Model") then
                        cup:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 3, -1.5))
                    else
                        cup.CFrame = root.CFrame * CFrame.new(0, 3, -1.5)
                    end
                    table.insert(celebrationAssets, cup)
                end
            end)

            -- 2. PARTÍCULAS DEL USUARIO (Confeti + Festejo custom)
            local festAttachment = Instance.new("Attachment", root)
            local customParticles = Instance.new("ParticleEmitter", festAttachment)
            customParticles.Texture = FESTEJO_PARTICLES_ID
            customParticles.Rate = 50
            table.insert(celebrationAssets, festAttachment)
            
            local confeti = createConfetti(root)
            table.insert(celebrationAssets, confeti)

            -- 3. BUCLE DE ACCIONES (Saltos, Fuegos Artificiales y Vibración)
            task.spawn(function()
                local cam = workspace.CurrentCamera
                local originalCamCFrame = cam.CFrame
                
                while isCelebrating and char and root and humanoid.Health > 0 do
                    -- El personaje salta constantemente
                    humanoid.Jump = true

                    -- Vibración de cámara (arriba hacia abajo brutal)
                    local shakeOffset = Vector3.new(
                        math.random(-5, 5)/10, 
                        math.random(-15, 15)/10, -- Mucha vibración vertical
                        math.random(-5, 5)/10
                    )
                    cam.CFrame = cam.CFrame * CFrame.new(shakeOffset)
                    
                    -- Generar un fuego artificial cada cierto tiempo
                    if math.random(1, 4) == 1 then
                        spawnFirework(char)
                    end
                    
                    task.wait(0.1)
                end
            end)
            
            -- 4. LEVANTAR LOS BRAZOS (Animación Procedural R15/R6)
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
