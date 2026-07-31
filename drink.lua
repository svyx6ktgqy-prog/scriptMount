-- ==========================================
-- TOWER OF CANS: SURGICAL ESP (Delta / Rayfield)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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

local Tab = Window:CreateTab("Visuales", 4483362458)

-- Variables de Estado
local espEnabled = false
local activeESPs = {}
local scanLoop = nil

-- Diccionario de Colores Base
local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

-- Función: Limpiar todos los ESPs
local function clearESP()
    for part, espObj in pairs(activeESPs) do
        if espObj then espObj:Destroy() end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Función: ESP del Rival (Solo Contorno)
local function createRivalESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = skinPart
    highlight.FillTransparency = 1 -- Transparente por dentro (SOLO CONTORNO)
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = baseColors[baseColorName] or Color3.fromRGB(255, 255, 255)
    highlight.Parent = espFolder
    
    activeESPs[skinPart] = highlight
end

-- Función: ESP de tu Jugador (Nombre de la Skin + Color Base)
local function createPlayerESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end

    local skinName = skinPart.Name -- Extrae si es "Union", "RedBull", etc.

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = skinPart
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0) -- Aparece arriba de la lata
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
    textLabel.Font = Enum.Font.Code -- Fuente técnica/quirúrgica

    billboard.Parent = espFolder
    activeESPs[skinPart] = billboard
end

-- Motor del ESP (Escaneo inteligente)
local function updateESP()
    -- Buscamos solo en carpetas que empiecen con "Training" para máxima eficiencia
    for _, trainingFolder in pairs(workspace:GetChildren()) do
        if string.match(trainingFolder.Name, "^Training") then
            
            for _, sodaFolder in pairs(trainingFolder:GetChildren()) do
                
                -- Detectar Rival (SodaM)
                local rivalBase = string.match(sodaFolder.Name, "^(%a+)SodaM$")
                if rivalBase then
                    for _, child in pairs(sodaFolder:GetChildren()) do
                        if child:IsA("BasePart") or child:IsA("UnionOperation") then
                            createRivalESP(rivalBase, child)
                        end
                    end
                end
                
                -- Detectar Player (SodaP)
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

-- Toggle en la Interfaz (Rayfield)
Tab:CreateToggle({
   Name = "Activar ESP Inteligente",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       
       if espEnabled then
           -- Loop optimizado a 0.5 segundos para no crashear Delta
           scanLoop = task.spawn(function()
               while espEnabled do
                   updateESP()
                   
                   -- Limpieza de latas destruidas/recogidas
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

Rayfield:Notify({
   Title = "Inyección Exitosa",
   Content = "El menú se ha cargado en estado quirúrgico.",
   Duration = 3,
   Image = 4483362458,
})
