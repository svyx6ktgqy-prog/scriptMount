-- Librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🏆 World Cup Hub",
    LoadingTitle = "Cargando Celebración Épica...",
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
-- SISTEMA DE CONFETI CILÍNDRICO 3D
---------------------------------------------------------
local function spawn3DCylinderConfetti(root)
    if not isCelebrating then return end
    
    -- Creamos de a 3 cilindros por ciclo para que sea denso pero optimizado
    for i = 1, 3 do
        local cylinder = Instance.new("Part")
        cylinder.Shape = Enum.PartType.Cylinder
        cylinder.Size = Vector3.new(0.1, 0.4, 0.1) -- Tamaño del confeti
        cylinder.Color = Color3.fromHSV(math.random(), 1, 1) -- Colores muy variados y vivos
        cylinder.Material = Enum.Material.Neon
        cylinder.CanCollide = true -- Para que choquen con el suelo
        cylinder.Position = root.Position + Vector3.new(math.random(-8, 8), math.random(5, 12), math.random(-8, 8))
        
        -- Impulso inicial
        local bv = Instance.new("BodyVelocity", cylinder)
        bv.MaxForce = Vector3.new(100, 100, 100) -- Poca fuerza para que actúe la gravedad
        bv.Velocity = Vector3.new(math.random(-15, 15), math.random(10, 25), math.random(-15, 15))
        
        -- Rotación aleatoria
        local rot = Instance.new("BodyAngularVelocity", cylinder)
        rot.AngularVelocity = Vector3.new(math.random(-30,30), math.random(-30,30), math.random(-30,30))
        
        cylinder.Parent = workspace
        
        -- Se destruyen a los 4 segundos para evitar lag
        task.delay(4, function()
            if cylinder then cylinder:Destroy() end
        end)
    end
end

---------------------------------------------------------
-- EXPLOSIONES DE FUEGOS ARTIFICIALES
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

            -- Explosión de partículas visuales
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
-- BOTÓN FLOTANTE: DESLIZAMIENTO DE FÚTBOL
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

        -- Inclinación pronunciada hacia adelante
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(400000, 400000, 400000)
        -- Usamos el LookVector para asegurarnos de que mire hacia donde iba caminando
        bg.CFrame = CFrame.new(root.Position, root.Position + root.CFrame.LookVector) * CFrame.Angles(math.rad(-80), 0, 0)
        
        -- IMPULSO DE ALTA VELOCIDAD (Se notará mucho más el desplazamiento)
        local initialSpeed = 70 
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = root.CFrame.LookVector * initialSpeed 

        -- Mover brazos y copa para atrás
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
            
            -- Brazos brutalmente para atrás
            rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(20))
            leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(-110), 0, math.rad(-20))

            -- Buscar la copa y moverla
            local cup = char:FindFirstChild("WorldCup_Gemini")
            if cup then
                cupWeld = cup:FindFirstChild("CupWeld_Gemini")
                if cupWeld then
                    -- La colocamos detrás de la espalda del jugador
                    cupWeld.C0 = CFrame.new(0, -1, 1.5) * CFrame.Angles(math.rad(90), 0, 0)
                end
            end
        end)

        -- Desaceleración en bucle (Desliza por más de 2 segundos)
        for i = initialSpeed, 0, -3 do
            if bv and bv.Parent then
                bv.Velocity = root.CFrame.LookVector * i
            end
            task.wait(0.1)
        end

        task.wait(0.3) -- Pausa corta totalmente detenido en el césped

        -- Restauración
        if bg and bg.Parent then bg:Destroy() end
        if bv and bv.Parent then bv:Destroy() end
        
        pcall(function()
            if rightJoint and rOriginalC0 then rightJoint.C0 = rOriginalC0 end
            if leftJoint and lOriginalC0 then leftJoint.C0 = lOriginalC0 end
            
            -- Restaurar copa arriba
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
            -- 1. CARGAR LA COPA (Usando Weld en lugar de WeldConstraint)
            pcall(function()
                local cupObjects = game:GetObjects(CUP_MODEL_ID)
                local cup = cupObjects[1]
                if cup then
                    cup.Parent = char
                    cup.Name = "WorldCup_Gemini" 
                    
                    local weld = Instance.new("Weld", cup)
                    weld.Name = "CupWeld_Gemini"
                    weld.Part0 = root
                    weld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                    weld.C0 = CFrame.new(0, 3.5, -1) -- Posición sobre la cabeza
                    
                    table.insert(celebrationAssets, cup)
                end
            end)

            -- 2. PARTÍCULAS EXTRA DE FESTEJO
            local chaosAttachment = Instance.new("Attachment", root)
            local festejoEmitter = Instance.new("ParticleEmitter", chaosAttachment)
            festejoEmitter.Texture = FESTEJO_PARTICLES_ID
            festejoEmitter.Rate = 100
            festejoEmitter.Size = NumberSequence.new(3)
            table.insert(celebrationAssets, chaosAttachment)
            table.insert(celebrationAssets, festejoEmitter)

            -- 3. BUCLE PRINCIPAL DE ACCIONES (Saltos, Terremoto y Confeti 3D)
            task.spawn(function()
                local cam = workspace.CurrentCamera
                while isCelebrating and char and root and humanoid.Health > 0 do
                    if not humanoid.PlatformStand then 
                        humanoid.Jump = true
                    end

                    -- Confeti físico cayendo
                    spawn3DCylinderConfetti(root)

                    -- Terremoto de cámara
                    cam.CFrame = cam.CFrame * CFrame.new(
                        math.random(-15, 15)/15, 
                        math.random(-30, 30)/15, 
                        math.random(-15, 15)/15
                    )
                    
                    -- Generación de fuegos artificiales
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
