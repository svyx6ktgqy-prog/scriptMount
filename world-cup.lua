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
-- FUNCIONES DE PARTÍCULAS CAÓTICAS Y EXPLOSIONES
---------------------------------------------------------

-- Función mejorada para crear confeti denso y visible
local function createDenseConfetti(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "ConfettiDenso"
    -- Usamos texturas de partículas base de Roblox para asegurar visibilidad
    emitter.Texture = "rbxassetid://243660364" 
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(50, 255, 50)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 50))
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5), -- Más grandes
        NumberSequenceKeypoint.new(1, 0.5)
    })
    emitter.Rate = 500 -- Tasa mucho más alta
    emitter.VelocitySpread = 360
    emitter.Speed = NumberRange.new(30, 50)
    emitter.Lifetime = NumberRange.new(2, 4)
    emitter.Acceleration = Vector3.new(0, -25, 0) -- Caen más rápido
    emitter.RotSpeed = NumberRange.new(-500, 500)
    emitter.LightEmission = 1
    emitter.ZOffset = 1 -- Para que se renderice delante del personaje
    emitter.Parent = parent
    return emitter
end

local function createRibbons(parent)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "Tiritas"
    emitter.Texture = "rbxassetid://14371490906"
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    emitter.Size = NumberSequence.new(2, 0.5) -- Más anchas
    emitter.Rate = 200
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(40, 70)
    emitter.Acceleration = Vector3.new(0, -30, 0)
    emitter.Drag = 1
    emitter.Lifetime = NumberRange.new(3, 5)
    emitter.ZOffset = 1
    emitter.Parent = parent
    return emitter
end

local function explosionMasiva(position)
    local attachment = Instance.new("Attachment", workspace.Terrain)
    attachment.WorldPosition = position

    local sparks = Instance.new("ParticleEmitter", attachment)
    sparks.Texture = "rbxassetid://7369527715"
    sparks.Color = ColorSequence.new(Color3.fromHSV(math.random(), 1, 1))
    sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 0)})
    sparks.Speed = NumberRange.new(80, 150)
    sparks.VelocitySpread = 360
    sparks.Drag = 5
    sparks.Lifetime = NumberRange.new(1.5, 3)
    sparks.LightEmission = 1
    sparks.Rate = 0

    local confetiExplosion = createDenseConfetti(attachment)
    confetiExplosion.Rate = 0
    confetiExplosion.Speed = NumberRange.new(80, 150)

    sparks:Emit(200)
    confetiExplosion:Emit(400)

    task.delay(6, function() attachment:Destroy() end)
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

            explosionMasiva(firework.Position)
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
    btn.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Verde césped
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

        -- Inclinación suave hacia el suelo (simulando deslizarse de pecho/rodillas)
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(400000, 400000, 400000)
        bg.CFrame = root.CFrame * CFrame.Angles(math.rad(-75), 0, 0) 
        
        -- Impulso suave y corto
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = root.CFrame.LookVector * 25 -- Velocidad reducida

        -- Variables para restaurar la posición original de los brazos y la copa
        local rightJoint, leftJoint
        local rOriginalC0, lOriginalC0
        local cupWeld
        local originalCupC0

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
            
            -- Mover brazos hacia atrás
            rightJoint.C0 = rightJoint.C0 * CFrame.Angles(math.rad(160), 0, math.rad(30))
            leftJoint.C0 = leftJoint.C0 * CFrame.Angles(math.rad(160), 0, math.rad(-30))

            -- Buscar si el jugador tiene la copa soldada
            local cup = char:FindFirstChild("WorldCup_Gemini")
            if cup then
                -- Buscar el WeldConstraint que une la copa al HumanoidRootPart
                for _, child in ipairs(cup:GetChildren()) do
                    if child:IsA("WeldConstraint") and child.Part0 == root then
                        cupWeld = child
                        -- Deshabilitar el WeldConstraint temporalmente
                        cupWeld.Enabled = false
                        
                        -- Crear un Weld normal para poder manipular la posición relativa
                        local tempWeld = Instance.new("Weld", cup)
                        tempWeld.Name = "TempCupWeld"
                        tempWeld.Part0 = root
                        tempWeld.Part1 = cup:IsA("Model") and cup.PrimaryPart or cup
                        -- Posicionar la copa detrás del jugador (hacia arriba)
                        tempWeld.C0 = CFrame.new(0, 1, 2) * CFrame.Angles(math.rad(45), 0, 0)
                        
                        break
                    end
                end
            end
        end)

        -- Desaceleración suave
        for i = 25, 0, -2.5 do
            if bv and bv.Parent then
                bv.Velocity = root.CFrame.LookVector * i
            end
            task.wait(0.15)
        end

        task.wait(0.5) -- Pausa final en el suelo

        -- Levantarse y restaurar
        if bg and bg.Parent then bg:Destroy() end
        if bv and bv.Parent then bv:Destroy() end
        
        pcall(function()
            if rightJoint and rOriginalC0 then rightJoint.C0 = rOriginalC0 end
            if leftJoint and lOriginalC0 then leftJoint.C0 = lOriginalC0 end
            
            -- Restaurar la posición de la copa
            local cup = char:FindFirstChild("WorldCup_Gemini")
            if cup then
                local tempWeld = cup:FindFirstChild("TempCupWeld")
                if tempWeld then tempWeld:Destroy() end
                if cupWeld then cupWeld.Enabled = true end
            end
        end)

        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(1) -- Tiempo de enfriamiento
        isSliding = false
    end)
end

-- Generar el botón al cargar el script
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
            -- 1. CARGAR LA COPA
            pcall(function()
                local cupObjects = game:GetObjects(CUP_MODEL_ID)
                local cup = cupObjects[1]
                if cup then
                    cup.Parent = char
                    cup.Name = "WorldCup_Gemini" -- Nombrada para poder encontrarla durante el deslizamiento
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

            -- 2. PARTÍCULAS MASIVAS EN EL CUERPO
            local chaosAttachment = Instance.new("Attachment", root)
            table.insert(celebrationAssets, chaosAttachment)
            
            -- Añadimos múltiples emisores para asegurar que se vea
            local confeti1 = createDenseConfetti(root)
            local confeti2 = createDenseConfetti(root)
            confeti2.Acceleration = Vector3.new(10, -20, 10) -- Variación en la caída
            table.insert(celebrationAssets, confeti1)
            table.insert(celebrationAssets, confeti2)
            
            table.insert(celebrationAssets, createRibbons(root))
            
            local festejoEmitter = Instance.new("ParticleEmitter", chaosAttachment)
            festejoEmitter.Texture = FESTEJO_PARTICLES_ID
            festejoEmitter.Rate = 100
            festejoEmitter.Size = NumberSequence.new(2)
            table.insert(celebrationAssets, festejoEmitter)

            -- 3. BUCLE DE ACCIONES
            task.spawn(function()
                local cam = workspace.CurrentCamera
                while isCelebrating and char and root and humanoid.Health > 0 do
                    if not humanoid.PlatformStand then 
                        humanoid.Jump = true
                    end

                    cam.CFrame = cam.CFrame * CFrame.new(
                        math.random(-15, 15)/15, 
                        math.random(-30, 30)/15, 
                        math.random(-15, 15)/15
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
