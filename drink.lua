-- ==========================================
-- TOWER OF CANS: SURGICAL ESP & SMART SWARM AI + FULL ANIMATIONS
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Contenedor del ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Surgical Mode",
   LoadingTitle = "Inyectando ESP...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ==========================================
-- VARIABLES GLOBALES (Clonación y Enjambre)
-- ==========================================
local originalCharacter = LocalPlayer.Character
local cloneList = {}
local activeIndex = 1 
local followingEnabled = true
local isSwarmJumping = false 
local cloneJumpDelays = {}   
local cloneConnections = {} -- Almacena conexiones de eventos para limpieza limpia

-- ==========================================
-- PESTAÑA: VISUALES (ESP Original)
-- ==========================================
local VisualTab = Window:CreateTab("Visuales", 4483362458)
local espEnabled = false
local activeESPs = {}

local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

local function clearESP()
    for part, espObj in pairs(activeESPs) do
        if espObj then espObj:Destroy() end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

local function createRivalESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = skinPart
    highlight.FillTransparency = 1 
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = baseColors[baseColorName] or Color3.fromRGB(255, 255, 255)
    highlight.Parent = espFolder
    activeESPs[skinPart] = highlight
end

local function createPlayerESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end
    local skinName = skinPart.Name 
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = skinPart
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0) 
    billboard.AlwaysOnTop = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = string.format("[%s] %s", baseColorName, skinName)
    textLabel.TextColor3 = baseColors[baseColorName] or Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Code 
    billboard.Parent = espFolder
    activeESPs[skinPart] = billboard
end

local function updateESP()
    for _, trainingFolder in pairs(workspace:GetChildren()) do
        if string.match(trainingFolder.Name, "^Training") then
            for _, sodaFolder in pairs(trainingFolder:GetChildren()) do
                local rivalBase = string.match(sodaFolder.Name, "^(%a+)SodaM$")
                if rivalBase then
                    for _, child in pairs(sodaFolder:GetChildren()) do
                        if child:IsA("BasePart") or child:IsA("UnionOperation") then
                            createRivalESP(rivalBase, child)
                        end
                    end
                end
                local playerBase = string.match(sodaFolder.Name, "^(%a+)SodaP$")
                if playerBase then
                    for _, child in pairs(sodaFolder:GetChildren()) do
                        if child:IsA("BasePart") or child:IsA("UnionOperation") then
                            createPlayerESP(playerBase, child)
                        end
                    end
                end
            end
        end
    end
end

VisualTab:CreateToggle({
   Name = "Activar ESP Inteligente",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           task.spawn(function()
               while espEnabled do
                   updateESP()
                   for part, espObj in pairs(activeESPs) do
                       if not part or not part.Parent then
                           espObj:Destroy()
                           activeESPs[part] = nil
                       end
                   end
                   task.wait(0.5)
               end
           end)
       else
           clearESP()
       end
   end,
})

-- ==========================================
-- INTERFAZ FLOTANTE
-- ==========================================
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "CloneControlUI"
FloatingGui.Parent = CoreGui
FloatingGui.Enabled = false 

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 50) 
mainFrame.Position = UDim2.new(0.5, -130, 0.9, -60) 
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = FloatingGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 10)
layout.Parent = mainFrame

local function createBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    btn.Parent = mainFrame
    return btn
end

local btnPrev = createBtn("<")
local btnOrig = createBtn("O")
local btnNext = createBtn(">")
local btnJump = createBtn("^") 

btnJump.MouseButton1Down:Connect(function() isSwarmJumping = true end)
btnJump.MouseButton1Up:Connect(function() isSwarmJumping = false end)
btnJump.MouseLeave:Connect(function() isSwarmJumping = false end)

-- ==========================================
-- LÓGICA DE CUERPOS Y COLISIONES
-- ==========================================
local function getAllBodies()
    local bodies = {originalCharacter}
    for _, clone in ipairs(cloneList) do
        if clone and clone.Parent then
            table.insert(bodies, clone)
        end
    end
    return bodies
end

local function applyAntiCollision(newBody)
    local bodies = getAllBodies()
    local coreParts = {"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"}
    
    for _, otherBody in ipairs(bodies) do
        if newBody ~= otherBody then
            for _, partName in ipairs(coreParts) do
                local p1 = newBody:FindFirstChild(partName)
                local p2 = otherBody:FindFirstChild(partName)
                if p1 and p2 then
                    local noCollision = Instance.new("NoCollisionConstraint")
                    noCollision.Part0 = p1
                    noCollision.Part1 = p2
                    noCollision.Parent = p1
                end
            end
        end
    end
end

-- ==========================================
-- NUEVO: SISTEMA DE ANIMACIÓN EVENT-DRIVEN
-- ==========================================
local function setupCloneAnimations(clone)
    local hum = clone:FindFirstChild("Humanoid")
    if not hum then return end

    -- 1. Eliminar el script Animate original porque no funciona dentro del Workspace para NPCs
    local oldAnimate = clone:FindFirstChild("Animate")
    local sourceAnimate = originalCharacter:FindFirstChild("Animate")
    if oldAnimate then
        oldAnimate.Disabled = true
        oldAnimate:Destroy()
    end

    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    
    -- 2. Extraer las animaciones REALES que usa tu personaje (R6, R15 o paquetes personalizados)
    local function loadTrackFromSource(animName, defaultId)
        local animId = defaultId
        if sourceAnimate then
            local container = sourceAnimate:FindFirstChild(animName)
            if container then
                local animObj = container:FindFirstChildOfClass("Animation")
                if animObj and animObj.AnimationId ~= "" then
                    animId = animObj.AnimationId
                end
            end
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        return animator:LoadAnimation(anim)
    end

    local idleTrack = loadTrackFromSource("idle", "rbxassetid://5077661410")
    local walkTrack = loadTrackFromSource("walk", "rbxassetid://5077778266")
    local runTrack  = loadTrackFromSource("run",  "rbxassetid://5077677153")
    local jumpTrack = loadTrackFromSource("jump", "rbxassetid://5077650008")
    local fallTrack = loadTrackFromSource("fall", "rbxassetid://5077679680")

    idleTrack.Priority = Enum.AnimationPriority.Idle
    walkTrack.Priority = Enum.AnimationPriority.Movement
    runTrack.Priority = Enum.AnimationPriority.Movement
    jumpTrack.Priority = Enum.AnimationPriority.Action
    fallTrack.Priority = Enum.AnimationPriority.Action

    local currentTrack = nil
    local function playTrack(track, fade)
        if currentTrack == track and track.IsPlaying then return end
        if currentTrack then currentTrack:Stop(fade or 0.2) end
        currentTrack = track
        if track then track:Play(fade or 0.2) end
    end

    -- 3. Conexiones nativas de Roblox (Se activan SOLAS cuando el Humanoid se mueve de verdad)
    local connections = {}

    table.insert(connections, hum.Running:Connect(function(speed)
        if speed > 10 then
            playTrack(runTrack, 0.2)
            runTrack:AdjustSpeed(math.clamp(speed / 16, 0.8, 1.5))
        elseif speed > 0.5 then
            playTrack(walkTrack, 0.2)
            walkTrack:AdjustSpeed(math.clamp(speed / 12, 0.6, 1.3))
        else
            playTrack(idleTrack, 0.3)
        end
    end))

    table.insert(connections, hum.Jumping:Connect(function()
        playTrack(jumpTrack, 0.1)
    end))

    table.insert(connections, hum.FreeFalling:Connect(function()
        playTrack(fallTrack, 0.2)
    end))

    cloneConnections[clone] = connections
    playTrack(idleTrack, 0.1)
end

-- ==========================================
-- CONTROL DE CÁMARA Y CAMBIO DE JUGADOR
-- ==========================================
local function switchCharacter(newIndex)
    local bodies = getAllBodies()
    if newIndex > #bodies then newIndex = 1 end
    if newIndex < 1 then newIndex = #bodies end
    
    local oldChar = bodies[activeIndex]
    if oldChar and oldChar:FindFirstChild("Humanoid") then
        oldChar.Humanoid:MoveTo(oldChar.HumanoidRootPart.Position)
    end
    
    activeIndex = newIndex
    local targetChar = bodies[activeIndex]
    
    if targetChar and targetChar:FindFirstChild("Humanoid") then
        LocalPlayer.Character = targetChar
        
        -- Si volvemos al personaje original, reactivamos su Animate nativo
        if targetChar == originalCharacter then
            local animScript = targetChar:FindFirstChild("Animate")
            if animScript then animScript.Disabled = false end
        end

        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = targetChar:FindFirstChild("Humanoid")
    end
end

btnPrev.MouseButton1Click:Connect(function() switchCharacter(activeIndex - 1) end)
btnNext.MouseButton1Click:Connect(function() switchCharacter(activeIndex + 1) end)
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) 

-- ==========================================
-- LÓGICA DEL ENJAMBRE (FÍSICAS LIMPIAS)
-- ==========================================
local MIN_SPACING = 3.5                
local GOLDEN_ANGLE = 2.3999632297286533 

RunService.Heartbeat:Connect(function()
    if not followingEnabled then return end
    local activeChar = LocalPlayer.Character
    if not activeChar or not activeChar:FindFirstChild("HumanoidRootPart") then return end

    local activeHum = activeChar:FindFirstChild("Humanoid")
    if not activeHum then return end

    local activePos = activeChar.HumanoidRootPart.Position
    local isPlayerMoving = activeHum.MoveDirection.Magnitude > 0

    local bodies = getAllBodies()
    local movingClones = {}
    
    for _, body in ipairs(bodies) do
        if body ~= activeChar and body:FindFirstChild("Humanoid") and body:FindFirstChild("HumanoidRootPart") then
            local root = body.HumanoidRootPart
            local hum = body.Humanoid
            if not root.Anchored and hum.WalkSpeed > 0 then
                table.insert(movingClones, body)
            end
        end
    end
    
    local cloneCount = #movingClones
    if cloneCount > 0 then
        local maxRadius = math.max(6, math.sqrt(cloneCount) * 3.5)

        for i, body in ipairs(movingClones) do
            local hum = body.Humanoid
            local root = body.HumanoidRootPart
            
            local rFraction = math.sqrt(i / cloneCount) 
            local radius = rFraction * maxRadius
            local angle = i * GOLDEN_ANGLE
            
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local targetPosition = activePos + offset

            local separationVector = Vector3.new(0, 0, 0)
            for _, otherBody in ipairs(bodies) do
                if otherBody ~= body and otherBody:FindFirstChild("HumanoidRootPart") then
                    local otherPos = otherBody.HumanoidRootPart.Position
                    local dist = (root.Position - otherPos).Magnitude

                    if dist < MIN_SPACING and dist > 0.001 then
                        local pushDir = (root.Position - otherPos).Unit
                        local pushForce = (MIN_SPACING - dist)
                        separationVector = separationVector + (pushDir * pushForce)
                    end
                end
            end

            targetPosition = targetPosition + separationVector
            local flatRootPos = Vector3.new(root.Position.X, 0, root.Position.Z)
            local flatTargetPos = Vector3.new(targetPosition.X, 0, targetPosition.Z)
            local distToTarget2D = (flatRootPos - flatTargetPos).Magnitude
            
            if isSwarmJumping then
                local now = tick()
                if not cloneJumpDelays[body] then
                    cloneJumpDelays[body] = now + (math.random(0, 40) / 100)
                end
                if now >= cloneJumpDelays[body] then
                    hum.Jump = true
                    cloneJumpDelays[body] = now + (math.random(50, 90) / 100)
                end
            else
                cloneJumpDelays[body] = nil
            end

            -- ==========================================
            -- NAVEGACIÓN Y ROTACIÓN REALISTA
            -- ==========================================
            if distToTarget2D > 2.2 then
                hum.AutoRotate = true
                hum:MoveTo(targetPosition)
                
                local lookVector = root.CFrame.LookVector
                local rayOrigin = root.Position + Vector3.new(0, -0.5, 0) 
                local rayDirection = lookVector * 3.5 
                
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = bodies
                
                local hit = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                if hit and hit.Instance and hit.Instance.CanCollide then
                    hum.Jump = true
                end
            else
                -- Frena de manera limpia al llegar al objetivo para activar el evento Idle
                if hum.WalkToPoint ~= Vector3.zero then
                    hum:MoveTo(root.Position)
                end
                
                if not isPlayerMoving then
                    hum.AutoRotate = true
                    local lookAtPos = Vector3.new(activePos.X, root.Position.Y, activePos.Z)
                    local targetDir = (lookAtPos - root.Position).Unit
                    if root.CFrame.LookVector:Dot(targetDir) < 0.92 then
                        root.CFrame = CFrame.lookAt(root.Position, root.Position + targetDir)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- PESTAÑA: JUGADOR (Clonación y Limpieza)
-- ==========================================
local PlayerTab = Window:CreateTab("Jugador", 4483362458)

PlayerTab:CreateButton({
   Name = "Crear Nuevo Clon (Inteligente)",
   Callback = function()
       if not originalCharacter then originalCharacter = LocalPlayer.Character end
       
       if originalCharacter and originalCharacter:FindFirstChild("HumanoidRootPart") then
           originalCharacter.Archivable = true
           local clone = originalCharacter:Clone()
           clone.Name = "Clon_" .. tostring(#cloneList + 1)
           clone.Parent = workspace
           
           clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(3, 0, 0))
           table.insert(cloneList, clone)
           
           applyAntiCollision(clone)
           setupCloneAnimations(clone) -- Inicialización Event-Driven nativa
           
           FloatingGui.Enabled = true
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Inteligente Creado",
               Content = "Añadido a la formación con animaciones nativas clonadas.",
               Duration = 3,
           })
       end
   end,
})

PlayerTab:CreateToggle({
   Name = "Clones siguen al jugador actual",
   CurrentValue = true,
   Flag = "FollowToggle",
   Callback = function(Value)
       followingEnabled = Value
   end,
})

PlayerTab:CreateButton({
    Name = "☠️ Limpiar Todos los Clones",
    Callback = function()
        switchCharacter(1)
        for _, clone in ipairs(cloneList) do
            if cloneConnections[clone] then
                for _, conn in ipairs(cloneConnections[clone]) do
                    conn:Disconnect()
                end
                cloneConnections[clone] = nil
            end
            if clone and clone:FindFirstChild("Humanoid") then
                clone.Humanoid.Health = 0
                task.delay(2, function()
                    if clone then clone:Destroy() end
                end)
            end
        end
        
        table.clear(cloneList)
        table.clear(cloneJumpDelays)
        FloatingGui.Enabled = false
        
        Rayfield:Notify({
            Title = "Limpieza Exitosa",
            Content = "Todos los clones y eventos han sido eliminados.",
            Duration = 3,
        })
    end,
})

Rayfield:Notify({
   Title = "Sistema Event-Driven Activo",
   Content = "Animaciones clonadas directamente de tu avatar y vinculadas al Humanoid.",
   Duration = 4,
   Image = 4483362458,
})
