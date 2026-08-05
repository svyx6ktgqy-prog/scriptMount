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
   Name = "Bandera y Outfit Definitivo",
   LoadingTitle = "Generando físicas y gorro...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

-- =========================================================
-- VARIABLES GLOBALES
-- =========================================================
local animConnection = nil
local customShirt = nil
local customHatModel = nil 
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
        local head = char:WaitForChild("Head") -- Referencia a la cabeza para soldar
        isSystemActive = Value 
        
        if isSystemActive then
            Rayfield:Notify({Title = "Procesando", Content = "Aplicando texturas y soldando gorro...", Duration = 2})
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

            -- 2. GORRO CUBETA (MÉTODO WELD - 100% SEGURO)
            if customHatModel then customHatModel:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustomSoldado" then v:Destroy() end
            end
            
            customHatModel = Instance.new("Model")
            customHatModel.Name = "GorroCustomSoldado"
            
            -- Copa (Parte superior)
            local copa = Instance.new("Part")
            copa.Name = "Copa"
            copa.Size = Vector3.new(1.2, 0.7, 1.2)
            copa.Color = Color3.fromRGB(20, 20, 20)
            copa.Material = Enum.Material.Fabric
            copa.Massless = true
            copa.CanCollide = false
            
            local meshCopa = Instance.new("SpecialMesh")
            meshCopa.MeshType = Enum.MeshType.Cylinder
            meshCopa.Parent = copa
            
            -- Ala (Borde)
            local ala = Instance.new("Part")
            ala.Name = "Ala"
            ala.Size = Vector3.new(2.5, 0.1, 2.5)
            ala.Color = Color3.fromRGB(15, 15, 15)
            ala.Material = Enum.Material.Fabric
            ala.Massless = true
            ala.CanCollide = false
            
            local meshAla = Instance.new("SpecialMesh")
            meshAla.MeshType = Enum.MeshType.Cylinder
            meshAla.Parent = ala
            
            -- Posicionar matemáticamente sobre la cabeza
            copa.CFrame = head.CFrame * CFrame.new(0, 0.65, 0) 
            ala.CFrame = copa.CFrame * CFrame.new(0, -0.35, 0)
            
            copa.Parent = customHatModel
            ala.Parent = customHatModel
            
            -- Soldar todo a la cabeza para que no se caiga
            local weldCopa = Instance.new("WeldConstraint")
            weldCopa.Part0 = head
            weldCopa.Part1 = copa
            weldCopa.Parent = copa
            
            local weldAla = Instance.new("WeldConstraint")
            weldAla.Part0 = copa
            weldAla.Part1 = ala
            weldAla.Parent = ala
            
            customHatModel.Parent = char

            -- 3. CREAR BANDERA 
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

            -- 5. ANIMACIÓN RECUPERADA (Respiración + Serpiente 3D)
            local RunService = game:GetService("RunService")
            local timePassed = 0
            
            if animConnection then animConnection:Disconnect() end
            
            animConnection = RunService.Heartbeat:Connect(function(dt)
                timePassed = timePassed + dt
                
                local banderasActivas = {}
                if flagTool and flagTool.Parent == char and handleFlag then table.insert(banderasActivas, handleFlag) end
                if backFlag and backFlag.Parent == char then table.insert(banderasActivas, backFlag) end
                
                -- Extraído de tu script antiguo (Movimiento global)
                local swayX = math.sin(timePassed * 3) * 0.15 
                local swayY = math.sin(timePassed * 5) * 0.08 
                local swayZ = math.sin(timePassed * 2) * 0.05 
                
                -- Agregamos inercia extra si el personaje camina
                local speed = humanoid.MoveDirection.Magnitude
                if speed > 0 then
                    swayX = swayX + (math.sin(timePassed * 8) * 0.15)
                end
                
                for _, activeHandle in ipairs(banderasActivas) do
                    local windSpeed = 6 + (speed * 0.5) -- Serpentea más rápido al correr
                    local waveFrequency = 1.2 
                    
                    for i = 1, numSegments do
                        local motor = activeHandle:FindFirstChild("Joint_" .. i)
                        if motor then
                            local angleY = math.sin((timePassed * windSpeed) - (i * waveFrequency)) 
                            local amplitude = 0.1 + (i * 0.05) 
                            
                            if i == 1 then
                                -- Base: Aplica toda la inercia (Arriba, Abajo, Lados) + inicio de la serpiente
                                motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(swayZ, swayX + (angleY * 0.1), swayY)
                            else
                                -- Tela: Sigue la onda de la serpiente
                                motor.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * amplitude, 0)
                            end
                        end
                    end
                end
            end)

            Rayfield:Notify({Title = "¡Éxito!", Content = "Gorro soldado y animación restaurada.", Duration = 3})

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

            if customHatModel then customHatModel:Destroy() end
            for _, v in pairs(char:GetChildren()) do
                if v.Name == "GorroCustomSoldado" then v:Destroy() end
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
