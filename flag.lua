-- =========================================================
-- CONFIGURACIÓN DE IMAGEN Y SEGURIDAD PARA iOS (DELTA)
-- =========================================================
local imageUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg"
local fileName = "delta_bandera_custom.jpeg"
local customAssetId = ""

-- Función segura para descargar en la sandbox de iPhone
local function getTextureId()
    if customAssetId ~= "" then return customAssetId end
    
    local getAsset = getcustomasset or getsynasset
    if not getAsset then
        return ""
    end
    
    -- 1. Descarga protegida para evitar crashes en iOS
    local fetchSuccess, imageData = pcall(function()
        return game:HttpGet(imageUrl)
    end)

    if not fetchSuccess or not imageData then
        return ""
    end

    -- 2. Escritura de archivo protegida
    local writeSuccess = pcall(function()
        writefile(fileName, imageData)
    end)

    if not writeSuccess then
        return ""
    end
    
    -- 3. Carga de asset
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
-- INTERFAZ RAYFIELD (TÁCTIL)
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Bandera 3D (Delta iOS)",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Por favor espera",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

-- =========================================================
-- CREADOR DE MÁSTIL, ROPA Y ANIMACIÓN
-- =========================================================
Tab:CreateButton({
   Name = "Crear y Equipar Todo",
   Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        
        -- Notificación de proceso
        Rayfield:Notify({Title = "Procesando", Content = "Descargando imagen en tu iPhone...", Duration = 2})
        
        local textureId = getTextureId()
        
        if textureId == "" then
            Rayfield:Notify({Title = "Error de Delta", Content = "iOS bloqueó la descarga o tu versión de Delta no soporta getcustomasset.", Duration = 4})
            return
        end

        -- 1. Aplicar Ropa
        local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
        local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
        shirt.ShirtTemplate = textureId
        pants.PantsTemplate = textureId

        -- 2. Crear Herramienta (Mástil)
        if player.Backpack:FindFirstChild("Bandera Delta") then
            player.Backpack:FindFirstChild("Bandera Delta"):Destroy()
        end
        if char:FindFirstChild("Bandera Delta") then
            char:FindFirstChild("Bandera Delta"):Destroy()
        end

        local tool = Instance.new("Tool")
        tool.Name = "Bandera Delta"
        tool.RequiresHandle = true
        tool.Grip = CFrame.new(0, -2, 0) 

        -- Mástil
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.15, 6, 0.15)
        handle.Color = Color3.fromRGB(120, 120, 120)
        handle.Material = Enum.Material.Metal
        handle.Parent = tool

        -- Tela
        local flagCloth = Instance.new("Part")
        flagCloth.Name = "Tela"
        flagCloth.Size = Vector3.new(3, 2, 0.05)
        flagCloth.Massless = true 
        flagCloth.CanCollide = false
        flagCloth.Parent = tool

        -- Texturas (Ambas caras)
        local decalFront = Instance.new("Decal", flagCloth)
        decalFront.Face = Enum.NormalId.Front
        decalFront.Texture = textureId

        local decalBack = Instance.new("Decal", flagCloth)
        decalBack.Face = Enum.NormalId.Back
        decalBack.Texture = textureId

        -- Motor de movimiento
        local motor = Instance.new("Motor6D")
        motor.Part0 = handle
        motor.Part1 = flagCloth
        motor.Parent = handle

        tool.Parent = player.Backpack

        -- 3. Físicas de Viento Optimizadas para Móvil
        local RunService = game:GetService("RunService")
        local timePassed = 0
        
        RunService.Heartbeat:Connect(function(dt)
            if tool.Parent == char then
                timePassed = timePassed + dt
                
                local waveX = math.sin(timePassed * 3) * 0.15 
                local waveY = math.sin(timePassed * 5) * 0.08 
                local waveZ = math.sin(timePassed * 2) * 0.05 
                
                motor.C0 = CFrame.new(0, 2, 0) 
                    * CFrame.Angles(waveZ, waveX, waveY) 
                    * CFrame.new(1.5, 0, 0) 
            end
        end)

        Rayfield:Notify({
            Title = "¡Completado!",
            Content = "Revisa tu inventario táctil.",
            Duration = 4
        })
   end
})
