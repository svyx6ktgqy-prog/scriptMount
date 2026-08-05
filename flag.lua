-- =========================================================
-- CONFIGURACIÓN DE IMAGEN Y SEGURIDAD PARA iOS (DELTA)
-- =========================================================
local imageUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg"
local fileName = "delta_bandera_custom2.jpeg"
local customAssetId = ""

local function getTextureId()
    if customAssetId ~= "" then return customAssetId end
    
    local getAsset = getcustomasset or getsynasset
    if not getAsset then return "" end
    
    local fetchSuccess, imageData = pcall(function() return game:HttpGet(imageUrl) end)
    if not fetchSuccess or not imageData then return "" end

    local writeSuccess = pcall(function() writefile(fileName, imageData) end)
    if not writeSuccess then return "" end
    
    local assetSuccess, id = pcall(function() return getAsset(fileName) end)
    if assetSuccess and id then
        customAssetId = id
        return customAssetId
    end
    return ""
end

-- =========================================================
-- INTERFAZ RAYFIELD
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bandera Ultra Realista",
   LoadingTitle = "Generando físicas...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

Tab:CreateButton({
   Name = "Equipar Bandera Orgánica y Estampado",
   Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        
        Rayfield:Notify({Title = "Procesando", Content = "Aplicando texturas y físicas...", Duration = 2})
        local textureId = getTextureId()
        
        if textureId == "" then
            Rayfield:Notify({Title = "Error", Content = "Fallo al procesar imagen en iOS.", Duration = 4})
            return
        end

        -- 1. APLICAR ROPA SIN DEFORMAR (T-Shirt / Graphic)
        -- Eliminamos ropa anterior si estorba visualmente
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("ShirtGraphic") then v:Destroy() end
        end
        
        -- Colocamos la imagen como un logo en el pecho para no estirarla
        local tShirt = Instance.new("ShirtGraphic", char)
        tShirt.Graphic = textureId

        -- 2. CREAR EL MÁSTIL Y LA BANDERA SEGMENTADA
        if player.Backpack:FindFirstChild("Bandera Realista") then
            player.Backpack:FindFirstChild("Bandera Realista"):Destroy()
        end
        if char:FindFirstChild("Bandera Realista") then
            char:FindFirstChild("Bandera Realista"):Destroy()
        end

        local tool = Instance.new("Tool")
        tool.Name = "Bandera Realista"
        tool.RequiresHandle = true
        tool.Grip = CFrame.new(0, -2, 0) 

        -- Mástil
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.15, 6, 0.15)
        handle.Color = Color3.fromRGB(100, 100, 100)
        handle.Material = Enum.Material.Metal
        handle.Parent = tool

        -- ==========================================
        -- FÍSICAS DE TELA: CREACIÓN DE SEGMENTOS
        -- ==========================================
        local numSegments = 6 -- Cantidad de divisiones de la bandera
        local totalWidth = 3 -- Largo total de la bandera
        local height = 2 -- Alto de la bandera
        local segWidth = totalWidth / numSegments
        local segments = {}

        for i = 1, numSegments do
            local seg = Instance.new("Part")
            seg.Size = Vector3.new(segWidth, height, 0.05)
            seg.Massless = true 
            seg.CanCollide = false
            seg.Transparency = 1 -- Ocultamos el bloque en sí para que solo se vea la textura
            
            -- Textura Frontal (Mapeada para que continúe en el siguiente segmento)
            local texFront = Instance.new("Texture", seg)
            texFront.Texture = textureId
            texFront.Face = Enum.NormalId.Front
            texFront.StudsPerTileU = totalWidth
            texFront.StudsPerTileV = height
            texFront.OffsetStudsU = (i - 1) * segWidth 

            -- Textura Trasera
            local texBack = Instance.new("Texture", seg)
            texBack.Texture = textureId
            texBack.Face = Enum.NormalId.Back
            texBack.StudsPerTileU = totalWidth
            texBack.StudsPerTileV = height
            texBack.OffsetStudsU = -((i - 1) * segWidth) 

            -- Articulaciones (Uniendo cada segmento como una cadena)
            local motor = Instance.new("Motor6D", handle)
            if i == 1 then
                motor.Part0 = handle
                motor.Part1 = seg
                motor.C0 = CFrame.new(0, 2, 0) -- Se pega arriba en el mástil
                motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            else
                motor.Part0 = segments[i-1]
                motor.Part1 = seg
                motor.C0 = CFrame.new(segWidth/2, 0, 0) -- Se pega a la derecha del segmento anterior
                motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            end
            
            segments[i] = seg
            seg.Parent = tool
        end

        tool.Parent = player.Backpack

        -- 3. ANIMACIÓN ONDULANTE "SERPIENTE"
        local RunService = game:GetService("RunService")
        local timePassed = 0
        
        RunService.Heartbeat:Connect(function(dt)
            if tool.Parent == char then
                timePassed = timePassed + dt
                
                -- Variables de la brisa (puedes jugar con estos números)
                local windSpeed = 6 -- Qué tan rápido viaja la ola
                local waveFrequency = 1.2 -- Qué tan pronunciada es la curva de la serpiente
                
                for i, seg in ipairs(segments) do
                    -- Buscamos el Motor que controla este segmento específico
                    local motor = handle:GetChildren()
                    for _, m in pairs(motor) do
                        if m:IsA("Motor6D") and m.Part1 == seg then
                            -- Matemáticas de onda que se desplaza: Restar el índice (i) crea el efecto de serpiente
                            local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                            
                            -- La amplitud crece hacia la punta (la punta se mueve más, cerca del palo se mueve menos)
                            local amplitude = 0.1 + (i * 0.05) 
                            
                            if i == 1 then
                                m.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, angleY * 0.1, 0) 
                            else
                                m.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * amplitude, 0)
                            end
                        end
                    end
                end
            end
        end)

        Rayfield:Notify({
            Title = "¡Completado!",
            Content = "Ropa ajustada y Bandera ondulante lista.",
            Duration = 5
        })
   end
})
