-- ==========================================
-- TOWER OF CANS: GLOBAL SURGICAL ESP (V5)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_V5"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Global Surgical V5",
   LoadingTitle = "Inyectando Motor Global...",
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

local function clearESP()
    for part, data in pairs(activeESPs) do
        if data.espObj then data.espObj:Destroy() end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Motor Global Quirúrgico
local function globalScan()
    -- 1. Barrer todo el Workspace buscando latas de tipo Union u objetos de torre
    for _, trainingArea in pairs(workspace:GetChildren()) do
        if string.match(trainingArea.Name, "^Training") then
            
            for _, descendant in pairs(trainingArea:GetDescendants()) do
                if descendant:IsA("UnionOperation") or descendant:IsA("BasePart") then
                    local name = descendant.Name
                    
                    -- Si es una lata de la torre del rival (pálidas / genéricas llamadas "Union")
                    -- O si forma parte de un contenedor de ordenamiento del rival
                    if name == "Union" or string.find(trainingArea.Name, "MasterSort") or descendant.Parent.Name:match("M$") then
                        
                        -- Determinar si es del rival o player basándose en la jerarquía superior
                        local isRival = false
                        local parentCheck = descendant
                        while parentCheck and parentCheck ~= workspace do
                            if string.match(parentCheck.Name, "M$") or string.match(parentCheck.Name, "SodaM") or string.match(parentCheck.Name, "MasterSort") then
                                isRival = true
                                break
                            elseif string.match(parentCheck.Name, "P$") or string.match(parentCheck.Name, "SodaP") then
                                isRival = false
                                break
                            end
                            parentCheck = parentCheck.Parent
                        end

                        if isRival and not activeESPs[descendant] then
                            -- Asignar un color base por defecto o rotativo si está en la torre blanca
                            local targetColor = baseColors.Red -- Color por defecto de rescate para latas pálidas
                            
                            -- Forzar propiedades físicas para quitar lo pálido/blanco
                            descendant.UsePartColor = true
                            descendant.Color = targetColor
                            descendant.Transparency = 0

                            -- Crear Highlight de Contorno para el Rival
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = descendant
                            highlight.FillTransparency = 1
                            highlight.OutlineTransparency = 0
                            highlight.OutlineColor = targetColor
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = espFolder

                            activeESPs[descendant] = { espObj = highlight }
                        end
                    end
                end
            end
            
        end
    end
end

-- Toggle UI
Tab:CreateToggle({
   Name = "Activar ESP Global Anti-Pálidas",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   globalScan()
                   
                   -- Limpieza de referencias muertas
                   for part, data in pairs(activeESPs) do
                       if not part or not part.Parent then
                           if data.espObj then data.espObj:Destroy() end
                           activeESPs[part] = nil
                       end
                   end
                   
                   task.wait(0.3)
               end
           end)
       else
           clearESP()
       end
   end,
})

Rayfield:Notify({
   Title = "Modo Global Activo",
   Content = "Filtro de latas pálidas aplicado correctamente.",
   Duration = 4,
   Image = 4483362458,
})
