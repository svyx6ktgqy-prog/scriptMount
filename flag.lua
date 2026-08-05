-- =========================================================
-- CONFIGURACIÓN DE IMAGEN Y SEGURIDAD PARA iOS (DELTA)
-- =========================================================
local imageUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg"
local fileName = "delta_bandera_completa_mochila.jpeg"
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
   Name = "Bandera y Outfit Definitivo",
   LoadingTitle = "Cargando accesorios...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

-- =========================================================
-- VARIABLES DE CONTROL GLOBALES
-- =========================================================
local animConnection = nil
local customShirt = nil
local customHat = nil
local flagTool = nil
local backFlag = nil
local isSystemActive = false -- Variable vital para saber si el switch está ON u OFF

Tab:CreateToggle({
   Name = "Activar Outfit y Bandera",
   CurrentValue = false,
   Flag = "ToggleOutfit",
   Callback = function(Value)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        isSystemActive = Value -- Actualizamos el estado del sistema
        
        if isSystemActive then
            -- ==========================================
            -- ESTADO: ENCENDIDO (CREAR TODO)
            -- ==========================================
            Rayfield:Notify({Title = "Procesando", Content = "Aplicando texturas y modelos...", Duration = 2})
            local textureId = getTextureId()
            
            if textureId == "" then
                Rayfield:Notify({Title = "Error", Content = "Fallo al procesar imagen en iOS.", Duration = 4})
                return
            end

            -- 1. ROPA
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("ShirtGraphic") then v:Destroy() end
            end
            customShirt = Instance.new("ShirtGraphic", char)
            customShirt.Graphic = textureId

            -- 2. GORRO CUBETA (Corregido para anclarse a la cabeza)
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustom" then v:Destroy() end
            end
            
            local successHat, hatObj = pcall(function()
                return game:GetObjects("rbxassetid://107578491217628")[1]
            end)
            
            if successHat and hatObj then
                customHat = hatObj
                customHat.Name = "GorroCustom"
                
                local hatHandle = customHat:FindFirstChild("Handle")
                if hatHandle then
                    if hatHandle:IsA("MeshPart") then
                        hatHandle.TextureID = textureId
                    else
                        local mesh = hatHandle:FindFirstChildOfClass("SpecialMesh")
                        if mesh then mesh.TextureId = textureId end
                    end
                end
                
                -- METODO CORRECTO PARA EQUIPAR SOMBREROS
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and customHat:IsA("Accessory") then
                    humanoid:AddAccessory(customHat)
                else
                    customHat.Parent = char
                end
            end

            -- 3. CREAR BANDERA (MÁSTIL Y SEGMENTOS)
            if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("Bandera Realista") then char:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end

            flagTool = Instance.new("Tool")
            flagTool.Name = "Bandera Realista"
            flagTool.RequiresHandle = true
            flagTool.Grip = CFrame.new(0, -2, 0) 

            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(0.15, 6, 0.15)
            handle.Color = Color3.fromRGB(100, 100, 100)
            handle.Material = Enum.Material.Metal
            handle.Parent = flagTool

            local numSegments = 6 
            local totalWidth = 3 
            local height = 2 
            local segWidth = totalWidth / numSegments

            local function applyPerfectTexture(part, index, isBack)
                local surface = Instance.new("SurfaceGui")
                surface.Face = isBack and Enum.NormalId.Back or Enum.NormalId.Front
                surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
                surface.PixelsPerStud = 50
                surface.ClipsDescendants = true
                surface.LightInfluence = 1 
                surface.Parent = part

                local img = Instance.new("ImageLabel")
                img.BackgroundTransparency = 1
                img.Image = textureId
                img.Size = UDim2.new(numSegments, 0, 1, 0)
                
                if isBack then
                    img.Position = UDim2.new(-(index - 1), 0, 0, 0)
                else
                    img.Position = UDim2.new(-(numSegments - index), 0, 0, 0)
                end
                img.Parent = surface
            end

            for i = 1, numSegments do
                local seg = Instance.new("Part")
                seg.Size = Vector3.new(segWidth, height, 0.05)
                seg.Massless = true 
                seg.CanCollide = false
                seg.Transparency = 1 
                
                applyPerfectTexture(seg, i, false)
                applyPerfectTexture(seg, i, true)

                local motor = Instance.new("Motor6D", handle)
                motor.Name = "Joint_" .. i
                if i == 1 then
                    motor.Part0 = handle
                    motor.Part1 = seg
                    motor.C0 = CFrame.new(0, 2, 0)
                    motor.C1 = CFrame.new(-segWidth/2, 0, 0)
                else
                    motor.Part0 = handle:FindFirstChild("Seg_" .. (i-1))
                    motor.Part1 = seg
                    motor.C0 = CFrame.new(segWidth/2, 0, 0)
                    motor.C1 = CFrame.new(-segWidth/2, 0, 0)
                end
                
                seg.Name = "Seg_" .. i
                seg.Parent = handle 
            end

            flagTool.Parent = player.Backpack

            -- 4. SISTEMA MOCHILA / ESPALDA (Corregido para el Switch Off)
            local function createBackFlag()
                if backFlag then backFlag:Destroy() end
                if not handle or not isSystemActive then return end -- Bloqueo de seguridad si está apagado
                
                backFlag = handle:Clone()
                backFlag.Name = "BackFlagHandle"
                backFlag.Massless = true
                backFlag.CanCollide = false
                backFlag.Parent = char
                
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    backFlag.CFrame = torso.CFrame * CFrame.new(0, 0, 0.65) * CFrame.Angles(math.rad(15), 0, math.rad(-45))
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = torso
                    weld.Part1 = backFlag
                    weld.Parent = backFlag
                end
            end

            flagTool.Equipped:Connect(function()
                if backFlag then backFlag:Destroy() end
            end)

            flagTool.Unequipped:Connect(function()
                if isSystemActive then -- Solo crear en la espalda si NO estamos apagando el script
                    createBackFlag()
                end
            end)

            createBackFlag()

            -- 5. INICIAR ANIMACIONES FUSIONADAS (Mano y Espalda seguras)
            local RunService = game:GetService("RunService")
            local timePassed = 0
            
            if animConnection then animConnection:Disconnect() end
            
            animConnection = RunService.Heartbeat:Connect(function(dt)
                timePassed = timePassed + dt
                
                -- Busca todas las banderas que existan actualmente (Mano o Espalda)
                local banderasActivas = {}
                if flagTool and flagTool.Parent == char and handle then table.insert(banderasActivas, handle) end
                if backFlag and backFlag.Parent == char then table.insert(banderasActivas, backFlag) end
                
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local moveSpeed = rootPart and rootPart.Velocity.Magnitude or 0
                local moveSway = math.sin(timePassed * 8) * (moveSpeed / 20) * 0.1 -- Animación por caminar
                
                for _, activeHandle in ipairs(banderasActivas) do
                    local windSpeed = 6 + (moveSpeed / 5) -- Más viento si el jugador corre
                    local waveFrequency = 1.2 
                    local dynamicWaviness = 0.1
                    
                    for i = 1, numSegments do
                        local motor = activeHandle:FindFirstChild("Joint_" .. i)
                        if motor then
                            local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                            local dynamicAmplitude = dynamicWaviness + (i * 0.05) 
                            
                            if i == 1 then
                                -- Fusiona oscilación natural + respiración
                                local breathSway = math.sin(timePassed * 2) * 0.05
                                motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(moveSway, (angleY * 0.1) + breathSway, 0)
                            else
                                -- Aleteo de la bandera
                                motor.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * dynamicAmplitude, 0)
                            end
                        end
                    end
                end
            end)

            Rayfield:Notify({Title = "¡Todo Listo!", Content = "Outfit y animaciones equipados.", Duration = 3})

        else
            -- ==========================================
            -- ESTADO: APAGADO (RESTAURAR A LA NORMALIDAD)
            -- ==========================================
            Rayfield:Notify({Title = "Restaurando", Content = "Removiendo outfit y accesorios...", Duration = 2})

            -- 1. Detener animaciones inmediatamente
            if animConnection then
                animConnection:Disconnect()
                animConnection = nil
            end

            -- 2. Eliminar Ropa
            if customShirt then customShirt:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("ShirtGraphic") then v:Destroy() end
            end

            -- 3. Eliminar Gorro
            if customHat then customHat:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustom" then v:Destroy() end
            end

            -- 4. Eliminar Bandera del Inventario/Mano 
            -- (Gracias a isSystemActive = false, el Unequipped ya no creará un clon en la espalda)
            if flagTool then 
                flagTool:Destroy() 
                flagTool = nil 
            end
            if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("Bandera Realista") then char:FindFirstChild("Bandera Realista"):Destroy() end

            -- 5. Eliminar Bandera que esté en la Espalda
            if backFlag then 
                backFlag:Destroy() 
                backFlag = nil 
            end
            if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end
        end
   end
})
