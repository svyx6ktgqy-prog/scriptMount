-- =========================================================
-- CONFIGURACIÓN DE IMAGEN Y SEGURIDAD PARA iOS (DELTA)
-- =========================================================
local imageUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg"
local fileName = "delta_bandera_custom_final.jpeg"
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
   Name = "Bandera Definitiva",
   LoadingTitle = "Generando físicas y texturas...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

Tab:CreateButton({
   Name = "Equipar Bandera y Ropa",
   Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        
        Rayfield:Notify({Title = "Procesando", Content = "Aplicando arreglo de texturas...", Duration = 2})
        local textureId = getTextureId()
        
        if textureId == "" then
            Rayfield:Notify({Title = "Error", Content = "Fallo al procesar imagen en iOS.", Duration = 4})
            return
        end

        -- 1. APLICAR ROPA (T-Shirt / Graphic - YA FUNCIONA BIEN)
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("ShirtGraphic") then v:Destroy() end
        end
        local tShirt = Instance.new("ShirtGraphic", char)
        tShirt.Graphic = textureId

        -- 2. LIMPIAR HERRAMIENTAS ANTERIORES
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
        -- FÍSICAS DE TELA Y RECORTE PERFECTO DE IMAGEN
        -- ==========================================
        local numSegments = 6 
        local totalWidth = 3 
        local height = 2 
        local segWidth = totalWidth / numSegments
        local segments = {}
        local joints = {} -- Guardaremos los motores aquí para animarlos más fácil

        -- Función para aplicar la imagen perfectamente cortada
        local function applyPerfectTexture(part, index, isBack)
            local surface = Instance.new("SurfaceGui")
            surface.Face = isBack and Enum.NormalId.Back or Enum.NormalId.Front
            surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            surface.PixelsPerStud = 50
            surface.ClipsDescendants = true -- Esto es la magia: recorta lo que sobra
            surface.LightInfluence = 1 -- Para que le afecten las sombras del juego
            surface.Parent = part

            local img = Instance.new("ImageLabel")
            img.BackgroundTransparency = 1
            img.Image = textureId
            -- Hacemos la imagen del tamaño TOTAL de la bandera
            img.Size = UDim2.new(numSegments, 0, 1, 0)
            -- Y la desplazamos hacia la izquierda dependiendo del segmento actual
            img.Position = UDim2.new(-(index - 1), 0, 0, 0)
            img.Parent = surface
        end

        for i = 1, numSegments do
            local seg = Instance.new("Part")
            seg.Size = Vector3.new(segWidth, height, 0.05)
            seg.Massless = true 
            seg.CanCollide = false
            seg.Transparency = 1 -- Ocultamos el bloque gris
            
            -- Aplicamos la imagen por delante y por detrás
            applyPerfectTexture(seg, i, false)
            applyPerfectTexture(seg, i, true)

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
                
                -- Animación 1: "Respiración" / Movimiento global del viento
                local swayX = math.sin(timePassed * 3) * 0.15 
                local swayY = math.sin(timePassed * 5) * 0.08 
                local swayZ = math.sin(timePassed * 2) * 0.05 
                
                -- Animación 2: Onda de "Serpiente" en la tela
                local windSpeed = 6 
                local waveFrequency = 1.2 
                
                for i = 1, numSegments do
                    local motor = joints[i]
                    if motor then
                        local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                        local amplitude = 0.1 + (i * 0.05) 
                        
                        if i == 1 then
                            -- Al primer bloque le aplicamos TODO: La respiración global + el inicio de la serpiente
                            motor.C0 = CFrame.new(0, 2, 0) 
                                * CFrame.Angles(swayZ, swayX + (angleY * 0.1), swayY)
                        else
                            -- A los demás bloques solo les pasamos la onda de la serpiente
                            motor.C0 = CFrame.new(segWidth/2, 0, 0) 
                                * CFrame.Angles(0, angleY * amplitude, 0)
                        end
                    end
                end
            end
        end)

        Rayfield:Notify({
            Title = "¡Éxito!",
            Content = "Animaciones combinadas y textura reparada.",
            Duration = 5
        })
   end
})
