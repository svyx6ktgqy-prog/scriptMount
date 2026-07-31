-- ==========================================
-- TOWER OF CANS: MÉTODO FUERTE POR RUTA EXACTA (V6)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local CoreGui = game:GetService("CoreGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_V6"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Método Fuerte V6",
   LoadingTitle = "Inyectando Filtro Estricto...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Visuales", 4483362458)

local espEnabled = false
local activeESPs = {}
local scanLoop = nil

-- Colores base estrictos para el rival
local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

local function clearESP()
    for part, highlight in pairs(activeESPs) do
        if highlight then highlight:Destroy() end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Método Fuerte: Rastreo estrictamente por la jerarquía "SodaM" del rival
local function strongScan()
    for _, trainingArea in pairs(workspace:GetChildren()) do
        if string.match(trainingArea.Name, "^Training") then
            
            for _, descendant in pairs(trainingArea:GetDescendants()) do
                -- Verificamos que sea una pieza física de lata
                if descendant:IsA("UnionOperation") or descendant:IsA("BasePart") then
                    
                    -- Analizar su ruta ascendente de manera estricta
                    local isRivalCan = false
                    local detectedColorName = "Red" -- Color por defecto si pierde el rastro en la torre
                    
                    local current = descendant
                    while current and current ~= trainingArea and current ~= workspace do
                        -- Si la lata está en una carpeta del rival (terminada en SodaM)
                        if string.match(current.Name, "SodaM$") then
                            isRivalCan = true
                            -- Extraer el color base del nombre de la carpeta (Ej: "RedSodaM" -> "Red")
                            for colorKey, _ in pairs(baseColors) do
                                if string.find(current.Name, colorKey) then
                                    detectedColorName = colorKey
                                    break
                                end
                            end
                            break
                        -- Si pertenece a tus rutas (SodaP), lo ignoramos por completo para proteger tus skins
                        elseif string.match(current.Name, "SodaP$") then
                            isRivalCan = false
                            break
                        end
                        current = current.Parent
                    end
                    
                    -- Si confirmamos que es del rival y aún no tiene ESP
                    if isRivalCan and not activeESPs[descendant] then
                        local targetColor = baseColors[detectedColorName] or baseColors.Red
                        
                        -- Forzar propiedades físicas para que la lata del rival deje de verse pálida/blanca
                        pcall(function()
                            descendant.UsePartColor = true
                            descendant.Color = targetColor
                            descendant.Transparency = 0
                        end)
                        
                        -- Aplicar Highlight de Contorno Único para el Rival
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = descendant
                        highlight.FillTransparency = 1 -- 100% transparente por dentro, solo silueta
                        highlight.OutlineTransparency = 0
                        highlight.OutlineColor = targetColor
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = espFolder
                        
                        activeESPs[descendant] = highlight
                    end
                    
                end
            end
            
        end
    end
end

-- Toggle de Control
Tab:CreateToggle({
   Name = "Activar ESP Fuerte (Solo Rival)",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   strongScan()
                   
                   -- Limpieza de referencias muertas (latas usadas o destruidas)
                   for part, highlight in pairs(activeESPs) do
                       if not part or not part.Parent then
                           if highlight then highlight:Destroy() end
                           activeESPs[part] = nil
                       end
                   end
                   
                   task.wait(0.2)
               end
           end)
       else
           clearESP()
       end
   end,
})

Rayfield:Notify({
   Title = "Método Fuerte Aplicado",
   Content = "Filtro estricto por ruta SodaM activado.",
   Duration = 4,
   Image = 4483362458,
})
