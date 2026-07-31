-- ==========================================
-- TOWER OF CANS: SURGICAL ESP & SMART SWARM AI + KILL CLEANUP + ANIMATIONS
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
-- VARIABLES GLOBALES (Clonación, Animaciones y Enjambre)
-- ==========================================
local originalCharacter = LocalPlayer.Character
local cloneList = {}
local activeIndex = 1 
local followingEnabled = true
local isSwarmJumping = false 
local cloneJumpDelays = {}   
local cloneAnimData = {}     -- Almacena las animaciones cargadas de cada clon

-- ==========================================
-- SISTEMA DE ANIMACIONES DINÁMICAS
-- ==========================================
local function setupCloneAnimations(clone)
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

    -- IDs por defecto para R15 y R6
    local walkId = (hum.RigType == Enum.RigType.R6) and "rbxassetid://180436334" or "rbxassetid://913403217"
    local runId  = (hum.RigType == Enum.RigType.R6) and "rbxassetid://180426354" or "rbxassetid://913384386"

    -- Intentar obtener las animaciones exactas que usa el jugador original
    local origAnimate = originalCharacter and originalCharacter:FindFirstChild("Animate")
    if origAnimate then
        local wFolder = origAnimate:FindFirstChild("walk")
        local rFolder = origAnimate:FindFirstChild("run")
        if wFolder then
            local wAnim = wFolder:FindFirstChildOfClass("Animation")
            if wAnim then walkId = wAnim.AnimationId end
        end
        if rFolder then
            local rAnim = rFolder:FindFirstChildOfClass("Animation")
            if rAnim then runId = rAnim.AnimationId end
        end
    end

    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = walkId
    local runAnim = Instance.new("Animation")
    runAnim.AnimationId = runId

    local walkTrack = animator:LoadAnimation(walkAnim)
    local runTrack = animator:LoadAnimation(runAnim)

    cloneAnimData[clone] = {
        walk = walkTrack,
        run = runTrack,
        currentState = "idle"
    }
end

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
-- LÓGICA DE CUERPOS Y FÍSICAS (CÁMARA FIX & ANTI-COLISIÓN)
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

-- FIX DE CÁMARA Y ORIENTACIÓN AL CAMBIAR DE PERSONAJE
local function switchCharacter(newIndex)
    local bodies = getAllBodies()
    if #bodies == 0 then return end
    if newIndex > #bodies then newIndex = 1 end
    if newIndex < 1 then newIndex = #bodies end

    -- Detener movimiento del personaje anterior
    local oldChar = bodies[activeIndex]
    if oldChar and oldChar:FindFirstChild("Humanoid") then
        oldChar.Humanoid:Move(Vector3.zero)
    end
    
    activeIndex = newIndex
    local targetChar = bodies[activeIndex]
    
    if targetChar and targetChar:FindFirstChild("Humanoid") and targetChar:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character = targetChar
        
        -- Reset de Cámara Limpio
        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = targetChar:FindFirstChild("Humanoid")

        -- Limpiar inercias y enderezar el ángulo vertical del RootPart
        local root = targetChar.HumanoidRootPart
        local _, ry, _ = root.CFrame:ToOrientation()
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, ry, 0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

btnPrev.MouseButton1Click:Connect(function() switchCharacter(activeIndex - 1) end)
btnNext.MouseButton1Click:Connect(function() switchCharacter(activeIndex + 1) end)
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) 

-- ==========================================
-- LÓGICA DEL ENJAMBRE (Formación, Mirada, Animaciones y Salto Orgánico)
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
    if cloneCount == 0 then return end

    local maxRadius = math.max(6, math.sqrt(cloneCount) * 3.5)

    for i, body in ipairs(movingClones) do
        local hum = body.Humanoid
        local root = body.HumanoidRootPart
        
        -- Cargar animaciones si no existen en el clon
        if not cloneAnimData[body] then
            setupCloneAnimations(body)
        end
        local anims = cloneAnimData[body]

        -- 1. DISTRIBUCIÓN INTERIOR
        local rFraction = math.sqrt(i / cloneCount) 
        local radius = rFraction * maxRadius
        local angle = i * GOLDEN_ANGLE
        
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local targetPosition = activePos + offset

        -- 2. FUERZA DE SEPARACIÓN
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
        
        -- 3. SALTO MASIVO ORGÁNICO Y DESINCRONIZADO
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

        -- 4. MOVIMIENTO, ROTACIÓN Y ESTADOS DE ANIMACIÓN
        local isTurningToLook = false

        if distToTarget2D > 1.5 then
            hum.AutoRotate = true
            hum:MoveTo(targetPosition)
            
            -- Proximity Jump (Raycast)
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
                local targetCFrame = CFrame.lookAt(root.Position, lookAtPos)
                
                -- Detectar si se está moviendo el cuerpo para rotar
                local angleDiff = math.abs(root.CFrame.LookVector:Dot(targetCFrame.LookVector))
                if angleDiff < 0.99 then
                    isTurningToLook = true
                end

                root.CFrame = root.CFrame:Lerp(targetCFrame, 0.15)
            else
                hum.AutoRotate = true
            end
        end

        -- 5. REPRODUCTOR DE ANIMACIONES (WALK / RUN / TURNING / IDLE)
        if anims then
            local flatVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
            local newState = "idle"

            if flatVelocity > 10 then
                newState = "run"
            elseif flatVelocity > 0.5 or isTurningToLook then
                newState = "walk"
            end

            if anims.currentState ~= newState then
                anims.currentState = newState
                if newState == "run" then
                    if anims.walk.IsPlaying then anims.walk:Stop(0.2) end
                    if not anims.run.IsPlaying then anims.run:Play(0.2) end
                elseif newState == "walk" then
                    if anims.run.IsPlaying then anims.run:Stop(0.2) end
                    if not anims.walk.IsPlaying then anims.walk:Play(0.2) end
                else
                    if anims.walk.IsPlaying then anims.walk:Stop(0.2) end
                    if anims.run.IsPlaying then anims.run:Stop(0.2) end
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
           setupCloneAnimations(clone)
           
           FloatingGui.Enabled = true
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Inteligente Creado",
               Content = "Añadido con soporte de animaciones y seguimiento.",
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
                clone.Humanoid.Health = 0
                task.delay(2, function()
                    if clone then clone:Destroy() end
                end)
            end
        end
        
        table.clear(cloneList)
        table.clear(cloneJumpDelays)
        table.clear(cloneAnimData)
        FloatingGui.Enabled = false
        
        Rayfield:Notify({
            Title = "Limpieza Exitosa",
            Content = "Todos los clones han sido eliminados del servidor.",
            Duration = 3,
        })
    end,
})

Rayfield:Notify({
   Title = "Manada AI Mejorada",
   Content = "Animaciones de caminata/rotación activadas y bug de cámara corregido.",
   Duration = 4,
   Image = 4483362458,
})
