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
local isSystemActive = false

Tab:CreateToggle({
   Name = "Activar Outfit y Bandera",
   CurrentValue = false,
   Flag = "ToggleOutfit",
   Callback = function(Value)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")
        isSystemActive = Value 
        
        if isSystemActive then
            Rayfield:Notify({Title = "Procesando", Content = "Aplicando texturas y construyendo gorro...", Duration = 2})
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

            -- 2. GORRO CUBETA (Réplica manual basada en image.png usando Cilindros)
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustom" then v:Destroy() end
            end
            
            customHat = Instance.new("Accessory")
            customHat.Name = "GorroCustom"
            
            -- Parte superior del gorro (Copa)
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1.2, 0.7, 1.2)
            handle.Color = Color3.fromRGB(20, 20, 20) -- Negro realista
            handle.Material = Enum.Material.Fabric
            handle.Massless = true
            handle.CanCollide = false
            
            local handleMesh = Instance.new("SpecialMesh")
            handleMesh.MeshType = Enum.MeshType.Cylinder
            handleMesh.Parent = handle
            
            -- Anclaje a la cabeza
            local attachment = Instance.new("Attachment")
            attachment.Name = "HatAttachment"
            attachment.Position = Vector3.new(0, -0.15, 0) -- Ajuste fino de altura
            attachment.Parent = handle
            handle.Parent = customHat
            
            -- Ala del gorro (Borde inferior)
            local brim = Instance.new("Part")
            brim.Name = "Brim"
            brim.Size = Vector3.new(2.5, 0.1, 2.5)
            brim.Color = Color3.fromRGB(15, 15, 15)
            brim.Material = Enum.Material.Fabric
            brim.Massless = true
            brim.CanCollide = false
            
            local brimMesh = Instance.new("SpecialMesh")
            brimMesh.MeshType = Enum.MeshType.Cylinder
            brimMesh.Parent = brim
            
            -- Soldar el ala a la copa
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = brim
            weld.Parent = handle
            
            brim.CFrame = handle.CFrame * CFrame.new(0, -0.35, 0)
            brim.Parent = customHat
            
            humanoid:AddAccessory(customHat)

            -- 3. CREAR BANDERA (MÁSTIL Y SEGMENTOS)
            if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("Bandera Realista") then char:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end

            flagTool = Instance.new("Tool")
            flagTool.Name = "Bandera Realista"
            flagTool.RequiresHandle = true
            flagTool.Grip = CFrame.new(0, -2, 0) 

            local handleFlag = Instance.new("Part")
            handleFlag.Name = "Handle"
            handleFlag.Size = Vector3.new(0.15, 6, 0.15)
            handleFlag.Color = Color3.fromRGB(100, 100, 100)
            handleFlag.Material = Enum.Material.Metal
            handleFlag.Parent = flagTool

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

                local motor = Instance.new("Motor6D", handleFlag)
                motor.Name = "Joint_" .. i
                if i == 1 then
                    motor.Part0 = handleFlag
                    motor.Part1 = seg
                    motor.C0 = CFrame.new(0, 2, 0)
                    motor.C1 = CFrame.new(-segWidth/2, 0, 0)
                else
                    motor.Part0 = handleFlag:FindFirstChild("Seg_" .. (i-1))
                    motor.Part1 = seg
                    motor.C0 = CFrame.new(segWidth/2, 0, 0)
                    motor.C1 = CFrame.new(-segWidth/2, 0, 0)
                end
                
                seg.Name = "Seg_" .. i
                seg.Parent = handleFlag 
            end

            flagTool.Parent = player.Backpack

            -- 4. SISTEMA MOCHILA / ESPALDA
            local function createBackFlag()
                if backFlag then backFlag:Destroy() end
                if not handleFlag or not isSystemActive then return end
                
                backFlag = handleFlag:Clone()
                backFlag.Name = "BackFlagHandle"
                backFlag.Massless = true
                backFlag.CanCollide = false
                backFlag.Parent = char
                
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    backFlag.CFrame = torso.CFrame * CFrame.new(0, 0, 0.65) * CFrame.Angles(math.rad(15), 0, math.rad(-45))
                    local weldFlag = Instance.new("WeldConstraint")
                    weldFlag.Part0 = torso
                    weldFlag.Part1 = backFlag
                    weldFlag.Parent = backFlag
                end
            end

            flagTool.Equipped:Connect(function()
                if backFlag then backFlag:Destroy() end
            end)

            flagTool.Unequipped:Connect(function()
                if isSystemActive then createBackFlag() end
            end)

            createBackFlag()

            -- 5. ANIMACIONES FLUIDAS MEJORADAS (Idle y Caminando)
            local RunService = game:GetService("RunService")
            local timePassed = 0
            
            if animConnection then animConnection:Disconnect() end
            
            animConnection = RunService.Heartbeat:Connect(function(dt)
                timePassed = timePassed + dt
                
                local banderasActivas = {}
                if flagTool and flagTool.Parent == char and handleFlag then table.insert(banderasActivas, handleFlag) end
                if backFlag and backFlag.Parent == char then table.insert(banderasActivas, backFlag) end
                
                local speed = humanoid.MoveDirection.Magnitude
                local isMoving = speed > 0
                
                -- Movimiento natural base (Fluye siempre, incluso frenado)
                local baseIdleSway = math.sin(timePassed * 1.5) * 0.08
                local moveSway = isMoving and (math.sin(timePassed * 8) * 0.15) or 0
                local finalSway = moveSway + baseIdleSway 
                
                for _, activeHandle in ipairs(banderasActivas) do
                    -- El viento base siempre es 4. Sube a 10 si corres.
                    local windSpeed = 4 + (speed * 6)
                    local waveFrequency = 1.2 
                    
                    for i = 1, numSegments do
                        local motor = activeHandle:FindFirstChild("Joint_" .. i)
                        if motor then
                            local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                            local dynamicAmplitude = 0.1 + (i * 0.06) 
                            
                            if i == 1 then
                                -- Mástil: Combina la inercia del cuerpo con la brisa suave
                                motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(finalSway, angleY * 0.1, 0)
                            else
                                -- Tela: Aletea de forma constante y fluida
                                motor.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * dynamicAmplitude, 0)
                            end
                        end
                    end
                end
            end)

            Rayfield:Notify({Title = "¡Éxito!", Content = "Gorro replicado y animaciones fluidas.", Duration = 3})

        else
            -- APAGADO
            Rayfield:Notify({Title = "Restaurando", Content = "Removiendo todo...", Duration = 2})

            if animConnection then
                animConnection:Disconnect()
                animConnection = nil
            end

            if customShirt then customShirt:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("ShirtGraphic") then v:Destroy() end
            end

            if customHat then customHat:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustom" then v:Destroy() end
            end

            if flagTool then 
                flagTool:Destroy() 
                flagTool = nil 
            end
            if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
            if char:FindFirstChild("Bandera Realista") then char:FindFirstChild("Bandera Realista"):Destroy() end

            if backFlag then 
                backFlag:Destroy() 
                backFlag = nil 
            end
            if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end
        end
   end
})
