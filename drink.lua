-- ==========================================
-- TOWER OF CANS: SURGICAL ESP & CLONE (Delta / Rayfield)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Crear un contenedor seguro para no saturar el Workspace
local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Surgical Mode",
   LoadingTitle = "Inyectando ESP...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

-- ==========================================
-- PESTAÑA: VISUALES (Tu código original)
-- ==========================================
local VisualTab = Window:CreateTab("Visuales", 4483362458)

local espEnabled = false
local activeESPs = {}
local scanLoop = nil

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
           scanLoop = task.spawn(function()
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
-- PESTAÑA: JUGADOR (Clonación)
-- ==========================================
local PlayerTab = Window:CreateTab("Jugador", 4483362458)

PlayerTab:CreateButton({
   Name = "Clonar y Cambiar Cuerpo",
   Callback = function()
       local oldChar = LocalPlayer.Character
       
       if oldChar and oldChar:FindFirstChild("HumanoidRootPart") then
           -- 1. Habilitar la clonación del personaje original
           oldChar.Archivable = true
           
           -- 2. Crear el clon
           local clone = oldChar:Clone()
           clone.Name = "NuevoJugador_" .. tostring(math.random(1000, 9999)) -- Nombre falso
           clone.Parent = workspace
           
           -- 3. Posicionar el clon un poco más adelante de donde estabas
           clone:SetPrimaryPartCFrame(oldChar.PrimaryPart.CFrame * CFrame.new(0, 0, -5))
           
           -- 4. Cambiar el control de la cámara al nuevo clon
           local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
           workspace.CurrentCamera.CameraSubject = cloneHumanoid
           
           -- 5. Cambiar el control del jugador local al nuevo clon
           LocalPlayer.Character = clone
           
           -- 6. Enviar un mensaje falso al chat (solo tú lo verás) para dar la ilusión
           game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
               Text = "[Sistema] " .. clone.Name .. " se ha unido a la experiencia.",
               Color = Color3.fromRGB(150, 150, 255)
           })
           
           Rayfield:Notify({
               Title = "Clonación Exitosa",
               Content = "Has transferido tu control al nuevo clon.",
               Duration = 3,
               Image = 4483362458,
           })
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "Tu personaje actual no está listo o está muerto.",
               Duration = 3,
               Image = 4483362458,
           })
       end
   end,
})

-- Notificación de inicio
Rayfield:Notify({
   Title = "Inyección Exitosa",
   Content = "El menú se ha cargado en estado quirúrgico.",
   Duration = 3,
   Image = 4483362458,
})
