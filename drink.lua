-- ==========================================
-- TOWER OF CANS: SURGICAL ESP & MULTI-CLONE SWARM
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
local activeIndex = 1 -- 1 = Original, 2+ = Clones
local followingEnabled = true

-- ==========================================
-- PESTAÑA: VISUALES (Tu ESP Original)
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
-- INTERFAZ FLOTANTE (Botones Rápidos)
-- ==========================================
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "CloneControlUI"
FloatingGui.Parent = CoreGui
FloatingGui.Enabled = false -- Se activa al crear el primer clon

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 50)
mainFrame.Position = UDim2.new(0.5, -100, 0.9, -60) -- Abajo al centro
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

-- ==========================================
-- LÓGICA DE CONTROL DE CUERPOS
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
btnOrig.MouseButton1Click:Connect(function() switchCharacter(1) end) -- 1 siempre es el original

-- ==========================================
-- LÓGICA DEL ENJAMBRE (Seguimiento y Saltos)
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not followingEnabled then return end
    local activeChar = LocalPlayer.Character
    if not activeChar or not activeChar:FindFirstChild("HumanoidRootPart") then return end

    local activePos = activeChar.HumanoidRootPart.Position

    local bodies = getAllBodies()
    for _, body in ipairs(bodies) do
        if body ~= activeChar and body:FindFirstChild("Humanoid") and body:FindFirstChild("HumanoidRootPart") then
            
            -- CONDICIÓN: Si el personaje está comprando/interactuando 
            -- (Detectado si el juego lo ancla o le quita la velocidad de caminar)
            local root = body.HumanoidRootPart
            local hum = body.Humanoid
            
            if not root.Anchored and hum.WalkSpeed > 0 then
                local dist = (root.Position - activePos).Magnitude
                -- Si está muy lejos, lo sigue (mantiene una distancia de 4 studs para no empujarte)
                if dist > 4 then
                    hum:MoveTo(activePos)
                end
            end
        end
    end
end)

-- Copiar Saltos
UserInputService.JumpRequest:Connect(function()
    if not followingEnabled then return end
    local bodies = getAllBodies()
    for _, body in ipairs(bodies) do
        if body ~= LocalPlayer.Character and body:FindFirstChild("Humanoid") then
            -- Solo salta si no está anclado (no está en una tienda)
            if body:FindFirstChild("HumanoidRootPart") and not body.HumanoidRootPart.Anchored then
                body.Humanoid.Jump = true
            end
        end
    end
end)

-- ==========================================
-- PESTAÑA: JUGADOR (Clonación)
-- ==========================================
local PlayerTab = Window:CreateTab("Jugador", 4483362458)

PlayerTab:CreateButton({
   Name = "Crear Nuevo Clon",
   Callback = function()
       if not originalCharacter then originalCharacter = LocalPlayer.Character end
       
       if originalCharacter and originalCharacter:FindFirstChild("HumanoidRootPart") then
           originalCharacter.Archivable = true
           local clone = originalCharacter:Clone()
           clone.Name = "Clon_" .. tostring(#cloneList + 1)
           clone.Parent = workspace
           
           -- Lo posicionamos a tu lado
           clone:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(3, 0, 0))
           table.insert(cloneList, clone)
           
           -- Mostrar la UI flotante la primera vez
           FloatingGui.Enabled = true
           
           -- Cambiamos el control al nuevo clon automáticamente
           switchCharacter(#getAllBodies())
           
           Rayfield:Notify({
               Title = "Clon Creado",
               Content = "Tienes un nuevo clon. Usa los botones inferiores para cambiar.",
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

Rayfield:Notify({
   Title = "Inyección Exitosa",
   Content = "El modo enjambre está listo.",
   Duration = 3,
   Image = 4483362458,
})
