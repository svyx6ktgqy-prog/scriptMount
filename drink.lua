-- ==========================================
-- TOWER OF CANS: SURGICAL ESP + COLOR LOCK
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_V2"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Surgical Mode V2",
   LoadingTitle = "Inyectando ESP y Bloqueo de Color...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Visuales", 4483362458)

-- Variables
local espEnabled = false
local activeESPs = {} -- Ahora guardará la UI y las conexiones de eventos
local scanLoop = nil

local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

-- Función: Limpiar ESPs y desconectar bloqueos
local function clearESP()
    for part, data in pairs(activeESPs) do
        if data.espObject then data.espObject:Destroy() end
        if data.connections then
            for _, conn in ipairs(data.connections) do
                conn:Disconnect()
            end
        end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Función: Forzar permanentemente el color físico de la lata
local function lockCanColor(skinPart, targetColor)
    local connections = {}
    
    -- 1. Forzar color inicial
    skinPart.Color = targetColor
    
    if skinPart:IsA("UnionOperation") then
        skinPart.UsePartColor = true
        
        -- Si el juego intenta apagar UsePartColor, lo encendemos de nuevo
        local connUsePart = skinPart:GetPropertyChangedSignal("UsePartColor"):Connect(function()
            if espEnabled and skinPart.UsePartColor == false then
                skinPart.UsePartColor = true
            end
        end)
        table.insert(connections, connUsePart)
    end
    
    -- Si el juego intenta cambiar el Color, lo revertimos
    local connColor = skinPart:GetPropertyChangedSignal("Color"):Connect(function()
        if espEnabled and skinPart.Color ~= targetColor then
            skinPart.Color = targetColor
        end
    end)
    table.insert(connections, connColor)

    return connections
end

-- Función: ESP del Rival (Contorno y Color Lock)
local function createRivalESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end

    local tColor = baseColors[baseColorName] or Color3.fromRGB(255, 255, 255)

    local highlight = Instance.new("Highlight")
    highlight.Adornee = skinPart
    highlight.FillTransparency = 1 
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = tColor
    highlight.Parent = espFolder
    
    -- Aplicar Bloqueo de Color Físico
    local conns = lockCanColor(skinPart, tColor)
    
    activeESPs[skinPart] = { espObject = highlight, connections = conns }
end

-- Función: ESP de tu Jugador (Nombre + Color Lock)
local function createPlayerESP(baseColorName, skinPart)
    if activeESPs[skinPart] then return end

    local tColor = baseColors[baseColorName] or Color3.fromRGB(255, 255, 255)
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
    textLabel.TextColor3 = tColor
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Code 
    billboard.Parent = espFolder
    
    -- Aplicar Bloqueo de Color Físico
    local conns = lockCanColor(skinPart, tColor)

    activeESPs[skinPart] = { espObject = billboard, connections = conns }
end

-- Escáner Principal
local function updateESP()
    for _, trainingFolder in pairs(workspace:GetChildren()) do
        if string.match(trainingFolder.Name, "^Training") then
            for _, sodaFolder in pairs(trainingFolder:GetChildren()) do
                
                -- Rival
                local rivalBase = string.match(sodaFolder.Name, "^(%a+)SodaM$")
                if rivalBase then
                    for _, child in pairs(sodaFolder:GetChildren()) do
                        if child:IsA("BasePart") or child:IsA("UnionOperation") then
                            createRivalESP(rivalBase, child)
                        end
                    end
                end
                
                -- Player
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

-- Toggle UI
Tab:CreateToggle({
   Name = "Activar ESP y Forzado de Color",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   updateESP()
                   
                   -- Limpieza segura
                   for part, data in pairs(activeESPs) do
                       if not part or not part.Parent then
                           if data.espObject then data.espObject:Destroy() end
                           if data.connections then
                               for _, conn in ipairs(data.connections) do
                                   conn:Disconnect()
                               end
                           end
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
   Title = "Sistema Actualizado",
   Content = "Anti-borrado de colores activado. Las latas están bloqueadas.",
   Duration = 3,
   Image = 4483362458,
})
