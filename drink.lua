-- ==========================================
-- TOWER OF CANS: SURGICAL ESP + MEMORY TRACKING (V4)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_V4"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Memory Tracker V4",
   LoadingTitle = "Inyectando Rastreador...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Visuales", 4483362458)

local espEnabled = false
local canMemory = {} -- Aquí guardaremos la "Identidad" de la lata para siempre
local activeESPs = {}
local scanLoop = nil

local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

-- Deduce el color mirando el nombre de la carpeta de origen
local function getColorFromFolderName(folderName)
    if string.find(folderName, "Red") then return "Red" end
    if string.find(folderName, "Green") then return "Green" end
    if string.find(folderName, "Blue") then return "Blue" end
    if string.find(folderName, "Yellow") then return "Yellow" end
    return nil
end

local function clearESP()
    for part, data in pairs(activeESPs) do
        if data.espObj then data.espObj:Destroy() end
    end
    table.clear(activeESPs)
    table.clear(canMemory)
    espFolder:ClearAllChildren()
end

-- PASO 1: Fichar latas en la mesa antes de que las muevan
local function registerCansOnTables()
    for _, trainingFolder in pairs(workspace:GetChildren()) do
        if string.match(trainingFolder.Name, "^Training") then
            for _, folder in pairs(trainingFolder:GetChildren()) do
                
                -- Si es la mesa del RIVAL
                if string.match(folder.Name, "SodaM$") then
                    local colorBase = getColorFromFolderName(folder.Name)
                    if colorBase then
                        for _, part in pairs(folder:GetChildren()) do
                            if (part:IsA("BasePart") or part:IsA("UnionOperation")) and not canMemory[part] then
                                canMemory[part] = { owner = "Rival", color = colorBase, skin = "Union" }
                            end
                        end
                    end
                end

                -- Si es la mesa del PLAYER (Tus latas con Skin comprada)
                if string.match(folder.Name, "SodaP$") then
                    local colorBase = getColorFromFolderName(folder.Name)
                    if colorBase then
                        for _, part in pairs(folder:GetChildren()) do
                            if (part:IsA("BasePart") or part:IsA("UnionOperation")) and not canMemory[part] then
                                -- Guardamos el nombre de tu Skin (Fanta, RedBull, etc.)
                                canMemory[part] = { owner = "Player", color = colorBase, skin = part.Name }
                            end
                        end
                    end
                end

            end
        end
    end
end

-- PASO 2: Aplicar visuales y forzar colores en base a la memoria
local function applyESP()
    for part, memoryData in pairs(canMemory) do
        
        -- Si la lata fue recogida o destruida, limpiamos la memoria
        if not part or not part.Parent then
            if activeESPs[part] and activeESPs[part].espObj then
                activeESPs[part].espObj:Destroy()
            end
            activeESPs[part] = nil
            canMemory[part] = nil
            continue
        end

        local rgbColor = baseColors[memoryData.color] or Color3.fromRGB(255, 255, 255)

        -- =========================================
        -- FORZAR COLOR DE LA LATA BASE DEL RIVAL
        -- =========================================
        if memoryData.owner == "Rival" and part:IsA("UnionOperation") then
            -- El juego intenta volverla blanca al apilarla en MasterSort, se lo impedimos
            if part.UsePartColor == false then part.UsePartColor = true end
            if part.Color ~= rgbColor then part.Color = rgbColor end
            if part.Transparency > 0 then part.Transparency = 0 end
        end

        -- =========================================
        -- DIBUJAR ESP SI NO EXISTE
        -- =========================================
        if not activeESPs[part] then
            
            if memoryData.owner == "Player" then
                -- ESP PARA TUS LATAS: Solo Texto (Ej: [Red] CocaCola)
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = part
                billboard.Size = UDim2.new(0, 150, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                billboard.AlwaysOnTop = true

                local textLabel = Instance.new("TextLabel")
                textLabel.Parent = billboard
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = string.format("[%s] %s", memoryData.color, memoryData.skin)
                textLabel.TextColor3 = rgbColor
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.TextSize = 12
                textLabel.Font = Enum.Font.Code 
                billboard.Parent = espFolder
                
                activeESPs[part] = { espObj = billboard }

            elseif memoryData.owner == "Rival" then
                -- ESP PARA EL RIVAL: Solo Contorno, basado en su color base
                local highlight = Instance.new("Highlight")
                highlight.Adornee = part
                highlight.FillTransparency = 1 -- Vacío por dentro
                highlight.OutlineTransparency = 0
                highlight.OutlineColor = rgbColor
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = espFolder
                
                activeESPs[part] = { espObj = highlight }
            end

        end
    end
end

-- Toggle UI
Tab:CreateToggle({
   Name = "Activar ESP (Memoria Activa)",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   -- Primero ficha las latas nuevas
                   registerCansOnTables()
                   -- Luego aplica el ESP y fuerza los colores
                   applyESP()
                   task.wait(0.2) -- Ciclo rápido pero optimizado
               end
           end)
       else
           clearESP()
       end
   end,
})

Rayfield:Notify({
   Title = "Modo Memoria Inyectado",
   Content = "Latas fichadas. El rival ya no podrá blanquear su torre.",
   Duration = 4,
   Image = 4483362458,
})
