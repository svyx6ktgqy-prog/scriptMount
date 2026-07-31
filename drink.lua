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
local customAnimators = {} -- NUEVO: Tabla para manejar animaciones de los clones

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
-- LÓGICA DE CUERPOS, CÁMARA Y ANIMACIONES
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

-- NUEVO: Sistema para extraer y preparar animaciones en los clones
local function setupAnimations(character)
    if customAnimators[character] then return end
    local hum = character:FindFirstChild("Humanoid")
    if not hum then return end
    
    local animator = hum:FindFirstChild("Animator") or Instance.new("Animator", hum)
    local animateScript = originalCharacter:FindFirstChild("Animate")
    
    -- IDs por defecto en caso de no encontrarlos
    local animIds = {
        idle = "rbxassetid://5077661410",
        walk = "rbxassetid://5077778266",
        run  = "rbxassetid://5077677153",
        jump = "rbxassetid://5077650008",
        fall = "rbxassetid://5077679680"
    }

    if animateScript then
        local function getAnimId(folderName)
            local folder = animateScript:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChildOfClass("Animation")
                if anim then return anim.AnimationId end
            end
            return nil
        end
        animIds.idle = getAnimId("idle") or animIds.idle
        animIds.walk = getAnimId("walk") or animIds.run or animIds.walk
        animIds.run  = getAnimId("run") or animIds.walk or animIds.run
        animIds.jump = getAnimId("jump") or animIds.jump
        animIds.fall = getAnimId("fall") or animIds.fall
    end

    local tracks = {}
    for name, id in pairs(animIds) do
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        tracks[name] = animator:LoadAnimation(anim)
        if name == "idle" then
            tracks[name].Priority = Enum.AnimationPriority.Idle
        else
            tracks[name].Priority = Enum.AnimationPriority.Movement
        end
    end

    customAnimators[character] = {
        tracks = tracks,
        currentState = "none"
    }
end

-- NUEVO: Motor de Animaciones Customizado (Corre en cada frame)
local function updateAnimations()
    local bodies = getAllBodies()
    
    for _, body in ipairs(bodies) do
        if body ~= originalCharacter then
            local animScript = body:FindFirstChild("Animate")
            if animScript and animScript:IsA("LocalScript") then animScript.Disabled = true end
        end

        if body ~= originalCharacter or (body == originalCharacter and body ~= LocalPlayer.Character) then
            if not customAnimators[body] then setupAnimations(body) end

            local animData = customAnimators[body]
            local root = body:FindFirstChild("HumanoidRootPart")
            local hum = body:FindFirstChild("Humanoid")
            
            if root and hum and animData then
                local flatVel = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                local speed = flatVel.Magnitude
                local isRotating = body:GetAttribute("IsRotating") or false

                local targetState = "idle"
                
                if speed > 11 then
                    targetState = "run"
                elseif speed > 0.5 or isRotating then
                    targetState = "walk"
                end
                
                local humState = hum:GetState()
                if humState == Enum.HumanoidStateType.Jumping then
                    targetState = "jump"
                elseif humState == Enum.HumanoidStateType.Freefall then
                    targetState = "fall"
                end

                if animData.currentState ~= targetState then
                    if animData.currentState ~= "none" and animData.tracks[animData.currentState] then
                        animData.tracks[animData.currentState]:Stop(0.2)
                    end
                    if targetState ~= "none" and animData.tracks[targetState] then
                        animData.tracks[targetState]:Play(0.2)
                    end
                    animData.currentState = targetState
                end
                
                if targetState == "walk" or targetState == "run" then
                    local track = animData.tracks[targetState]
                    if track then
                        local playbackSpeed = (speed > 0.5) and (speed / 16) or 0.8
                        track:AdjustSpeed(math.clamp(playbackSpeed, 0.5, 1.8))
                    end
                end
            end
        else
            -- [!] FIX: Apagar animaciones custom residuales antes de devolver el control nativo
            if customAnimators[body] and customAnimators[body].currentState ~= "none" then
                local track = customAnimators[body].tracks[customAnimators[body].currentState]
                if track then track:Stop(0.1) end
                customAnimators[body].currentState = "none"
            end

            local animScript = body:FindFirstChild("Animate")
            if animScript and animScript:IsA("LocalScript") and animScript.Disabled then
                animScript.Disabled = false
            end
        end
    end
end

-- MEJORADO: Arreglo de bug de cámara y corrida estática
local function switchCharacter(newIndex)
    local bodies = getAllBodies()
    if newIndex > #bodies then newIndex = 1 end
    if newIndex < 1 then newIndex = #bodies end
    
    local oldChar = bodies[activeIndex]
    if oldChar and oldChar:FindFirstChild("Humanoid") then
        oldChar.Humanoid:MoveTo(oldChar.HumanoidRootPart.Position)
        oldChar:SetAttribute("IsRotating", false) -- [!] FIX: Limpiar flag de rotación
        
        local animator = oldChar.Humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
    
    activeIndex = newIndex
    local targetChar = bodies[activeIndex]
    
    if targetChar and targetChar:FindFirstChild("Humanoid") then
        LocalPlayer.Character = targetChar
        
        -- [!] FIX: Restablecer AutoRotate para solucionar el bug de correr en diagonal
        targetChar.Humanoid.AutoRotate = true 
        targetChar:SetAttribute("IsRotating", false)
        
        -- [!] FIX: Detener cualquier animación pegada en el nuevo personaje (Evita manos estáticas)
        local targetAnimator = targetChar.Humanoid:FindFirstChild("Animator")
        if targetAnimator then
            for _, track in ipairs(targetAnimator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
        
        if customAnimators[targetChar] then
            customAnimators[targetChar].currentState = "none"
        end
        
        -- [!] FIX: Diferir la cámara un frame para que asimile el cambio sin descalibrarse
        task.defer(function()
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = targetChar:FindFirstChild("Humanoid")
        end)
    end
end

btnPrev.MouseButton1Click:Connect(function() switchCharacter(activeIndex - 1) end)
btnNext.MouseButton1Click:Connect(function() switchCharacter(activeIndex + 1) end)
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) 

-- ==========================================
-- LÓGICA DEL ENJAMBRE 
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

            -- Movimiento y Lógica de Rotación Realista
            if distToTarget2D > 1.5 then
                hum.AutoRotate = true
                hum:MoveTo(targetPosition)
                body:SetAttribute("IsRotating", false) -- Se mueve, la animación lo cubre
                
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
                if not isPlayerMoving then
                    hum.AutoRotate = false
                    local lookAtPos = Vector3.new(activePos.X, root.Position.Y, activePos.Z)
                    
                    -- Detectar si necesita rotar para mirarte
                    local currentDir = root.CFrame.LookVector
                    local targetDir = (lookAtPos - root.Position).Unit
                    local dot = math.clamp(currentDir:Dot(targetDir), -1, 1)
                    local rotAngle = math.acos(dot)
                    
                    if rotAngle > 0.08 then -- Si el ángulo es suficientemente grande para rotar
                        root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, lookAtPos), 0.15)
                        body:SetAttribute("IsRotating", true) -- Activa la animación de caminar
                    else
                        body:SetAttribute("IsRotating", false)
                    end
                else
                    hum.AutoRotate = true
                    body:SetAttribute("IsRotating", false)
                end
            end
        end
    end
    
    -- Llamamos a la actualización de animaciones al final de cada frame
    updateAnimations()
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
           setupAnimations(clone) -- Inicializa sus animaciones extraídas
           
           FloatingGui.Enabled = true
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Inteligente Creado",
               Content = "Añadido a la formación. Animaciones fluidas listas.",
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
            if clone and clone:FindFirstChild("Humanoid") then
                customAnimators[clone] = nil -- Limpiar de la caché de animaciones
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
            Content = "Todos los clones han sido eliminados del servidor.",
            Duration = 3,
        })
    end,
})

Rayfield:Notify({
   Title = "Parche de Animaciones + Cámara",
   Content = "Clones ahora caminan, corren y saltan. Rotación realista y cámara arreglada.",
   Duration = 4,
   Image = 4483362458,
})
