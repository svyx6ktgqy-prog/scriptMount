-- ==========================================
-- TOWER OF CANS: SURGICAL ESP & SMART SWARM AI + KILL CLEANUP
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
local isSwarmJumping = false -- Variable para el salto masivo mantenido
local cloneJumpDelays = {}   -- NUEVO: Tabla para rastrear los tiempos de salto orgánicos

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
-- INTERFAZ FLOTANTE (Ampliada para el salto)
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

-- Eventos del botón de salto masivo
btnJump.MouseButton1Down:Connect(function()
    isSwarmJumping = true
end)
btnJump.MouseButton1Up:Connect(function()
    isSwarmJumping = false
end)
btnJump.MouseLeave:Connect(function()
    isSwarmJumping = false
end)

-- ==========================================
-- LÓGICA DE CUERPOS Y FÍSICAS (ANTI-COLISIÓN)
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

local function switchCharacter(newIndex)
    local bodies = getAllBodies()
    if newIndex > #bodies then newIndex = 1 end
    if newIndex < 1 then newIndex = #bodies end
    
    activeIndex = newIndex
    local targetChar = bodies[activeIndex]
    
    if targetChar and targetChar:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = targetChar:FindFirstChild("Humanoid")
        LocalPlayer.Character = targetChar
    end
end

btnPrev.MouseButton1Click:Connect(function() switchCharacter(activeIndex - 1) end)
btnNext.MouseButton1Click:Connect(function() switchCharacter(activeIndex + 1) end)
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) 

-- ==========================================
-- LÓGICA DEL ENJAMBRE (Formación, Mirada y Salto Orgánico)
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
        
        -- ==========================================
        -- 3. SALTO MASIVO ORGÁNICO Y DESINCRONIZADO
        -- ==========================================
        if isSwarmJumping then
            local now = tick()
            -- Si es la primera vez que se presiona el botón, le damos un retraso inicial aleatorio (0.0 a 0.4 seg)
            if not cloneJumpDelays[body] then
                cloneJumpDelays[body] = now + (math.random(0, 40) / 100)
            end
            
            -- Si ya pasó el tiempo de espera calculado para este clon, salta
            if now >= cloneJumpDelays[body] then
                hum.Jump = true
                -- Si se mantiene presionado el botón, calculamos el siguiente salto con un cooldown aleatorio 
                -- (Esto evita que se sincronicen después del primer salto)
                cloneJumpDelays[body] = now + (math.random(50, 90) / 100)
            end
        else
            -- Reseteamos el delay cuando el usuario suelta el botón
            cloneJumpDelays[body] = nil
        end

        -- 4. MOVIMIENTO, ROTACIÓN Y AUTO-SALTO INTELIGENTE (Obstáculos)
        if distToTarget2D > 1.5 then
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
            if not isPlayerMoving then
                hum.AutoRotate = false
                local lookAtPos = Vector3.new(activePos.X, root.Position.Y, activePos.Z)
                root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, lookAtPos), 0.15)
            else
                hum.AutoRotate = true
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
           
           FloatingGui.Enabled = true
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Inteligente Creado",
               Content = "Añadido a la formación. Proximity Jump activado.",
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
        -- Limpiar los delays acumulados
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
   Title = "Manada AI Mejorada",
   Content = "Salto masivo orgánico activado. Los clones ya no saltan robóticamente al mismo tiempo.",
   Duration = 4,
   Image = 4483362458,
})
