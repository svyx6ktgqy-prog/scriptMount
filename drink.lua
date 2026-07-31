-- ==========================================
-- TOWER OF CANS: SURGICAL ESP + OMNI-TRACKING V3
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_V3"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Surgical Mode V3",
   LoadingTitle = "Rastreando Torre Total...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Visuales", 4483362458)

local espEnabled = false
local activeESPs = {}
local scanLoop = nil

local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

-- Lista de nombres válidos de latas
local validSkins = {
    Union = true, RedBull = true, Fanta = true, 
    CocaCola = true, Sprite = true, Pepsi = true
}

local function clearESP()
    for part, data in pairs(activeESPs) do
        if data.espObject then data.espObject:Destroy() end
        if data.connections then
            for _, conn in ipairs(data.connections) do conn:Disconnect() end
        end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Deduce el color físico si el juego intentó borrarlo
local function getNearestColor(c3)
    local r, g, b = c3.R * 255, c3.G * 255, c3.B * 255
    if r > 150 and g > 150 and b < 100 then return "Yellow", baseColors.Yellow end
    if r > 150 and g < 100 and b < 100 then return "Red", baseColors.Red end
    if g > 150 and r < 100 and b < 100 then return "Green", baseColors.Green end
    if b > 150 and r < 100 and g < 150 then return "Blue", baseColors.Blue end
    return "Unknown", Color3.fromRGB(255, 255, 255)
end

-- Función Maestra de ESP y Bloqueo
local function processCan(part)
    if activeESPs[part] then return end

    -- Determinar si es de Player o Rival analizando sus carpetas superiores
    local owner = "Rival"
    local current = part
    while current and current ~= workspace do
        if string.match(current.Name, "P$") or string.match(current.Name, "SodaP") then
            owner = "Player"
            break
        elseif string.match(current.Name, "M$") or string.match(current.Name, "SodaM") then
            owner = "Rival"
            break
        end
        current = current.Parent
    end

    -- Determinar el Color Base
    local baseColorName = "Unknown"
    local tColor = part.Color

    -- Si está en la mesa, sacamos el color del nombre de la carpeta
    local folderMatch = part.Parent and string.match(part.Parent.Name, "^(%a+)Soda")
    if folderMatch then
        baseColorName = folderMatch
        tColor = baseColors[baseColorName] or tColor
    else
        -- Si está en la torre (apilada), deducimos su color por sus propiedades residuales
        baseColorName, tColor = getNearestColor(part.Color)
    end

    if baseColorName == "Unknown" then return end -- Ignorar si no detectamos color

    local espObj, conns = nil, {}

    if owner == "Player" then
        -- ESP TEXTO PARA JUGADOR
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 150, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = string.format("[%s] %s", baseColorName, part.Name)
        textLabel.TextColor3 = tColor
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.Code 
        billboard.Parent = espFolder
        espObj = billboard
    else
        -- ESP CONTORNO PARA RIVAL
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillTransparency = 1 
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = tColor
        highlight.Parent = espFolder
        espObj = highlight
    end

    -- ==========================================
    -- SISTEMA ANTI-BLANCO Y PRESERVACIÓN DE TEXTURA
    -- ==========================================
    
    -- Solo forzamos UsePartColor y Color si es una lata básica ("Union").
    -- Esto arregla las torres blancas del rival sin arruinar las texturas de Fanta/Pepsi/etc.
    if part.Name == "Union" and part:IsA("UnionOperation") then
        part.UsePartColor = true
        part.Color = tColor
        
        table.insert(conns, part:GetPropertyChangedSignal("UsePartColor"):Connect(function()
            if espEnabled and not part.UsePartColor then part.UsePartColor = true end
        end))
        table.insert(conns, part:GetPropertyChangedSignal("Color"):Connect(function()
            if espEnabled and part.Color ~= tColor then part.Color = tColor end
        end))
    end

    -- Forzamos a que nunca se vuelva invisible por culpa del Anti-Lag del servidor
    part.Transparency = 0
    table.insert(conns, part:GetPropertyChangedSignal("Transparency"):Connect(function()
        if espEnabled and part.Transparency > 0 then part.Transparency = 0 end
    end))

    activeESPs[part] = { espObject = espObj, connections = conns }
end

-- Escáner Dinámico de Todo el Área de Entrenamiento
local function updateESP()
    for _, trainingArea in pairs(workspace:GetChildren()) do
        if string.match(trainingArea.Name, "^Training") then
            -- Rastrear TODOS los descendientes (mesas y torres enteras)
            for _, descendant in pairs(trainingArea:GetDescendants()) do
                if (descendant:IsA("BasePart") or descendant:IsA("UnionOperation")) and validSkins[descendant.Name] then
                    processCan(descendant)
                end
            end
        end
    end
end

-- Toggle UI
Tab:CreateToggle({
   Name = "Activar ESP Omni-Rastreador",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   updateESP()
                   
                   -- Limpieza segura si la lata es destruida
                   for part, data in pairs(activeESPs) do
                       if not part or not part.Parent then
                           if data.espObject then data.espObject:Destroy() end
                           if data.connections then
                               for _, conn in ipairs(data.connections) do conn:Disconnect() end
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
   Title = "Sistema V3 Activo",
   Content = "Anti-Blanqueamiento activado. Rastreando latas en la torre y mesas.",
   Duration = 4,
   Image = 4483362458,
})
