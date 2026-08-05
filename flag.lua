-- =========================================================
-- CONFIGURACIÓN DE IMAGEN Y SEGURIDAD PARA iOS (DELTA) - VERSIÓN FINAL
-- =========================================================
local imageUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg"
local fileName = "delta_bandera_completa_final.jpeg"
local customAssetId = ""

-- Función segura para descargar y cargar texturas en iOS (Delta)
local function getTextureId()
    if customAssetId ~= "" then return customAssetId end
    
    local getAsset = getcustomasset or getsynasset
    if not getAsset then
        return ""
    end
    
    local fetchSuccess, imageData = pcall(function()
        return game:HttpGet(imageUrl)
    end)

    if not fetchSuccess or not imageData then
        return ""
    end

    local writeSuccess = pcall(function()
        writefile(fileName, imageData)
    end)

    if not writeSuccess then
        return ""
    end
    
    local assetSuccess, id = pcall(function()
        return getAsset(fileName)
    end)

    if assetSuccess and id then
        customAssetId = id
        return customAssetId
    else
        return ""
    end
end

-- =========================================================
-- INTERFAZ RAYFIELD
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bandera Definitiva V2",
   LoadingTitle = "Generando físicas y texturas...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

Tab:CreateButton({
   Name = "Equipar Bandera Doble Cara y Ropa",
   Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        
        Rayfield:Notify({Title = "Procesando", Content = "Aplicando texturas finales...", Duration = 2})
        
        local textureId = getTextureId()
        
        if textureId == "" then
            Rayfield:Notify({Title = "Error", Content = "Fallo al procesar imagen en iOS.", Duration = 4})
            return
        end

        -- 1. APLICAR ROPA (GraphicTShirt/Logo - YA FUNCIONA BIEN)
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("ShirtGraphic") then v:Destroy() end
        end
        local tShirt = Instance.new("ShirtGraphic", char)
        tShirt.Graphic = textureId

        -- 2. LIMPIAR HERRAMIENTAS ANTERIORES
        if player.Backpack:FindFirstChild("Bandera 3D Final") then
            player.Backpack:FindFirstChild("Bandera 3D Final"):Destroy()
        end
        if char:FindFirstChild("Bandera 3D Final") then
            char:FindFirstChild("Bandera 3D Final"):Destroy()
        end

        local tool = Instance.new("Tool")
        tool.Name = "Bandera 3D Final"
        tool.RequiresHandle = true
        tool.Grip = CFrame.new(0, -2, 0) 

        -- Mástil
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.15, 6, 0.15)
        handle.Color = Color3.fromRGB(120, 120, 120)
        handle.Material = Enum.Material.Metal
        handle.Parent = tool

        -- ==========================================
        -- FÍSICAS DE TELA Y RECORTE PERFECTO DOBLE CARA
        -- ==========================================
        local numSegments = 6 
        local totalWidth = 3 
        local height = 2 
        local segWidth = totalWidth / numSegments
        local segments = {}
        local joints = {}

        -- Función para aplicar la imagen perfectamente cortada, ahora con soporte para ambas caras
        local function applyTextureBothFaces(part, index)
            -- CONFIGURACIÓN DE LA CARA FRONTAL
            local surfaceFront = Instance.new("SurfaceGui")
            surfaceFront.Name = "FrontGui"
            surfaceFront.Face = Enum.NormalId.Front -- CARA FRONTAL
            surfaceFront.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            surfaceFront.PixelsPerStud = 50
            surfaceFront.ClipsDescendants = true
            surfaceFront.LightInfluence = 1
            surfaceFront.Parent = part

            local imgFront = Instance.new("ImageLabel")
            imgFront.BackgroundTransparency = 1
            imgFront.Image = textureId
            imgFront.Size = UDim2.new(numSegments, 0, 1, 0)
            imgFront.Position = UDim2.new(-(index - 1), 0, 0, 0)
            imgFront.Parent = surfaceFront

            -- CONFIGURACIÓN DE LA CARA TRASERA
            local surfaceBack = Instance.new("SurfaceGui")
            surfaceBack.Name = "BackGui"
            surfaceBack.Face = Enum.NormalId.Back -- CARA TRASERA
            surfaceBack.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            surfaceBack.PixelsPerStud = 50
            surfaceBack.ClipsDescendants = true
            surfaceBack.LightInfluence = 1
            surfaceBack.Parent = part

            local imgBack = Instance.new("ImageLabel")
            imgBack.BackgroundTransparency = 1
            imgBack.Image = textureId -- MISMA IMAGEN
            imgBack.Size = UDim2.new(numSegments, 0, 1, 0)
            -- Desplazamiento ajustado para la perspectiva trasera
            imgBack.Position = UDim2.new(-(numSegments - index), 0, 0, 0)
            imgBack.Parent = surfaceBack
        end

        for i = 1, numSegments do
            local seg = Instance.new("Part")
            seg.Size = Vector3.new(segWidth, height, 0.05)
            seg.Massless = true 
            seg.CanCollide = false
            seg.Transparency = 1 
            
            -- APLICAMOS LA MAGIA DOBLE CARA AQUÍ
            applyTextureBothFaces(seg, i)

            -- Articulaciones
            local motor = Instance.new("Motor6D", handle)
            if i == 1 then
                motor.Part0 = handle
                motor.Part1 = seg
                motor.C0 = CFrame.new(0, 2, 0)
                motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            else
                motor.Part0 = segments[i-1]
                motor.Part1 = seg
                motor.C0 = CFrame.new(segWidth/2, 0, 0)
                motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            end
            
            segments[i] = seg
            joints[i] = motor
            seg.Parent = tool
        end

        tool.Parent = player.Backpack

        -- ==========================================
        -- 3. ANIMACIÓN COMBINADA (RESPIRACIÓN + SERPIENTE)
        -- ==========================================
        local RunService = game:GetService("RunService")
        local timePassed = 0
        
        RunService.Heartbeat:Connect(function(dt)
            if tool.Parent == char then
                timePassed = timePassed + dt
                
                -- Variables de la brisa
                local windSpeed = 6 
                local waveFrequency = 1.2 
                local dynamicWaviness = 0.1 -- Cuánto se mueve hacia los lados
                
                for i = 1, numSegments do
                    local motor = joints[i]
                    if motor then
                        local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                        local dynamicAmplitude = dynamicWaviness + (i * 0.05) 
                        
                        if i == 1 then
                            -- El primer bloque anclado al palo tiene balanceo extra y el inicio de la serpiente
                            local breathSway = math.sin(timePassed * 2) * 0.05
                            motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, (angleY * 0.1) + breathSway, 0)
                        else
                            -- Los demás bloques siguen la onda serpenteante
                            motor.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * dynamicAmplitude, 0)
                        end
                    end
                end
            end
        end)

        Rayfield:Notify({
            Title = "¡Completado!",
            Content = "Bandera doble cara y ropa aplicadas.",
            Duration = 5
        })
   end
})
