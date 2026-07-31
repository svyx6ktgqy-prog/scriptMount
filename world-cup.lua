-- Librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🏆 World Cup Hub",
    LoadingTitle = "Cargando Celebración Máxima...",
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
-- FUNCIONES DE CONFETI (2D DENSO Y 3D CILÍNDRICO)
---------------------------------------------------------
local function createDenseConfetti(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "ConfettiDenso"
    emitter.Texture = "rbxassetid://243660364" 
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(50, 255, 50)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 50))
    })
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0.5)})
    emitter.Rate = 500
    emitter.VelocitySpread = 360
    emitter.Speed = NumberRange.new(30, 50)
    emitter.Lifetime = NumberRange.new(2, 4)
    emitter.Acceleration = Vector3.new(0, -25, 0)
    emitter.RotSpeed = NumberRange.new(-500, 500)
    emitter.LightEmission = 1
    emitter.ZOffset = 1
    emitter.Parent = parent
    return emitter
end

local function createRibbons(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "Tiritas"
    emitter.Texture = "rbxassetid://14371490906"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    emitter.Size = NumberSequence.new(2, 0.5)
    emitter.Rate = 150
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(40, 70)
    emitter.Acceleration = Vector3.new(0, -30, 0)
    emitter.Drag = 1
    emitter.Lifetime = NumberRange.new(3, 5)
    emitter.ZOffset = 1
    emitter.Parent = parent
    return emitter
end

local function spawn3DCylinderConfetti(root)
    if not isCelebrating then return end
    for i = 1, 3 do
        local cylinder = Instance.new("Part")
        cylinder.Shape = Enum.PartType.Cylinder
        cylinder.Size = Vector3.new(0.1, 0.4, 0.1)
        cylinder.Color = Color3.fromHSV(math.random(), 1, 1)
        cylinder.Material = Enum.Material.Neon
        cylinder.CanCollide = true 
        cylinder.Position = root.Position + Vector3.new(math.random(-8, 8), math.random(5, 12), math.random(-8, 8))
        
        local bv = Instance.new("BodyVelocity", cylinder)
        bv.MaxForce = Vector3.new(100, 100, 100)
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(10, 25), math.random(-15, 15))
        
        local rot = Instance.new("BodyAngularVelocity", cylinder)
        rot.AngularVelocity = Vector3.new(math.random(-30,30), math.random(-30,30), math.random(-30,30))
        
        cylinder.Parent = workspace
        task.delay(4, function() if cylinder then cylinder:Destroy() end end)
    end
end

---------------------------------------------------------
-- FUEGOS ARTIFICIALES MASIVOS
---------------------------------------------------------
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

    local isDud = math.random(1, 100) <= 15
    local bv = Instance.new("BodyVelocity", firework)
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    
    if isDud then
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(15, 30), math.random(-15, 15))
    else
        bv.Velocity = Vector3.new(math.random(-10, 10), math.random(150, 220), math.random(-10, 10))
    end

    local launchSound = Instance.new("Sound", firework)
    launchSound.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
    launchSound.Volume = 3
    launchSound:Play()

    task.delay(isDud and 1.2 or 3, function()
        if firework.Parent then
            local exp = Instance.new("Explosion", workspace)
            exp.Position = firework.Position
            exp.BlastRadius = 0
            
            local bang = Instance.new("Sound", workspace)
            bang.SoundId = FIREWORK_SOUNDS[math.random(1, #FIREWORK_SOUNDS)]
            bang.Volume = 6
            bang.PlayOnRemove = true
            bang:Destroy()

            local attachment = Instance.new("Attachment", workspace.Terrain)
            attachment.WorldPosition = firework.Position
            local sparks = Instance.new("ParticleEmitter", attachment)
            sparks.Texture = "rbxassetid://7369527715"
            sparks.Color = ColorSequence.new(Color3.fromHSV(math.random(), 1, 1))
            sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 0)})
            sparks.Speed = NumberRange.new(80, 150)
            sparks.VelocitySpread = 360
            sparks.Drag = 5
            sparks.Lifetime = NumberRange.new(1.5, 3)
            sparks.LightEmission = 1
            sparks:Emit(300)
            task.delay(4, function() attachment:Destroy() end)
            
            firework:Destroy()
        end
    end)
end

---------------------------------------------------------
-- BOTÓN FLOTANTE: DESLIZAMIENTO CON RASTRO Y COPA ATRÁS
---------------------------------------------------------
local function createSlideButton()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "SoccerSlideGUI"
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0, 20, 0.5, -35)
    btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    btn.Text = "⚽"
    btn.TextSize = 40
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
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
        hum.PlatformStand = true

        -- CREAR RASTROS (Trail + Polvo)
        local trailA0 = Instance.new("Attachment", root)
        trailA0.Position = Vector3.new(-1, -1.5, 0)
        local trailA1 = Instance.new("Attachment", root)
        trailA1.Position = Vector3.new(1, -1.5, 0)
        
        local slideTrail = Instance.new("Trail", root)
        slideTrail.Attachment0 = trailA0
        slideTrail.Attachment1 = trailA1
        slideTrail.Lifetime = 0.6
        slideTrail.Color = ColorSequence.new(Color3.fromRGB(200, 255, 200))
        slideTrail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})

        local dustEmitter = Instance.new("ParticleEmitter", root)
        dustEmitter.Texture = "rbxassetid://243662281" -- Textura de humo/polvo
        dustEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 4)})
        dustEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
        dustEmitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
        dustেম্বর.Speed = NumberRange.new(5, 10)
        dustEmitter.VelocitySpread = 45
        dustEmitter.EmissionDirection = Enum.NormalId.Back -- Sale hacia atrás
        dustEmitter.Rate = 50

        -- INCLINACIÓN Y VELOCIDAD
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(400000, 400000, 400000)
        bg.CFrame = CFrame.new(root.Position, root.Position + root.CFrame.LookVector) * CFrame.Angles(math.rad(-80), 0, 0)
        
        local initialSpeed = 70 
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = root.CFrame.LookVector * initialSpeed 

        -- MOVER BRAZOS Y LA COPA HACIA LA ESPALDA
        local rightJoint, leftJoint
        local rOriginalC0, lOriginalC0
        local cupWeld
        
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
            
            -- Brazos para atrás
            rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(20))
            leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(-20))

            -- Copa detrás de la espalda (Z = 2.5 mueve la copa hacia atrás relativo al Root)
            local cup = char:FindFirstChild("WorldCup_Gemini")
            if cup then
                cupWeld = cup:FindFirstChild("CupWeld_Gemini")
                if cupWeld then
                    -- Posición: 0.5 arriba, 2.5 studs hacia atrás, rotada para que apunte bien
                    cupWeld.C0 = CFrame.new(0, 0.5, 2.5) * CFrame.Angles(math.rad(90), 0, 0)
                end
            end
        end)

        -- Bucle de Desaceleración
        for i = initialSpeed, 0, -3 do
            if bv and bv.Parent then
                bv.Velocity = root.CFrame.LookVector * i
            end
            task.wait(0.1)
        end

        task.wait(0.3) -- Pausa corta en el césped

        -- RESTAURACIÓN
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        
        dustEmitter.Enabled = false
        game.Debris:AddItem(dustEmitter, 2)
        game.Debris:AddItem(slideTrail, 1)
        game.Debris:AddItem(trailA0, 1)
        game.Debris:AddItem(trailA1, 1)
        
        pcall(function()
            if rightJoint and rOriginalC0 then rightJoint.C0 = rOriginalC0 end
            if leftJoint and lOriginalC0 then leftJoint.C0 = lOriginalC0 end
            
            -- Volver la copa arriba
            if cupWeld then
                cupWeld.C0 = CFrame.new(0, 3.5, -1)
            end
        end)

        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(1) 
        isSliding = false
    end)
end

createSlideButton()

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
            -- 1. CARGAR LA COPA (Con Colisiones Desactivadas para no arruinar las físicas)
            pcall(function()
                local cupObjects = game:GetObjects(CUP_MODEL_ID)
                local cup = cupObjects[1]
                if cup then
                    cup.Parent = char
                    cup.Name = "WorldCup_Gemini" 
                    
                    -- Desactivar colisiones para evitar fallos físicos al deslizarse
                    for _, p in pairs(cup:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                    if cup:IsA("BasePart") then cup.CanCollide = false end
                    
                    local weld = Instance.new("Weld", cup)
                    weld.Name = "CupWeld_Gemini"
                    weld.Part0 = root
                    weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                    weld.C0 = CFrame.new(0, 3.5, -1) 
                    
                    table.insert(celebrationAssets, cup)
                end
            end)

            -- 2. CARGAR TODOS LOS CONFETIS (2D y Adicionales)
            local chaosAttachment = Instance.new("Attachment", root)
            table.insert(celebrationAssets, chaosAttachment)
            
            table.insert(celebrationAssets, createDenseConfetti(root))
            table.insert(celebrationAssets, createRibbons(root))
            
            local festejoEmitter = Instance.new("ParticleEmitter", chaosAttachment)
            festejoEmitter.Texture = FESTEJO_PARTICLES_ID
            festejoEmitter.Rate = 100
            festejoEmitter.Size = NumberSequence.new(3)
            table.insert(celebrationAssets, festejoEmitter)

            -- 3. BUCLE PRINCIPAL (Saltos, Terremoto y Confeti 3D)
            task.spawn(function()
                local cam = workspace.CurrentCamera
                while isCelebrating and char and root and humanoid.Health > 0 do
                    if not humanoid.PlatformStand then 
                        humanoid.Jump = true
                    end

                    -- Confeti físico 3D
                    spawn3DCylinderConfetti(root)

                    cam.CFrame = cam.CFrame * CFrame.new(
                        math.random(-15, 15)/15, 
                        math.random(-30, 30)/15, 
                        math.random(-15, 15)/15
                    )
                    
                    if math.random(1, 4) == 1 then
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
