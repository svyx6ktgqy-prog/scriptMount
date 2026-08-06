-- =========================================================
-- CONFIGURACIÓN DE IMÁGENES, COLORES Y SEGURIDAD PARA iOS (DELTA)
-- =========================================================
local texturePresets = {
    ["NEGRON"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/IMG_8066.jpeg",
    ["Spyder550"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8088.jpeg",
    ["Glade"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8089.jpeg",
    ["Darkwole"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8090.jpeg",
    ["Camufla"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8091.jpeg",
    ["CatOnge"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8094.jpeg",
    ["Panic-Attack"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8071.jpeg",
    ["3-Ladys"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8101.jpeg",
    ["GirlGENTAI"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8104.jpeg",
    ["BobJHOD"] = "https://raw.githubusercontent.com/svyx6ktgqy-prog/scriptMount/refs/heads/main/flags/IMG_8105.jpeg"
}

local presetColors = {
    ["NEGRON"] = Color3.fromRGB(25, 25, 25),          
    ["Spyder550"] = Color3.fromRGB(180, 180, 180),    
    ["Glade"] = Color3.fromRGB(34, 139, 34),          
    ["Darkwole"] = Color3.fromRGB(30, 30, 45),        
    ["Camufla"] = Color3.fromRGB(85, 107, 47),        
    ["CatOnge"] = Color3.fromRGB(255, 140, 0),        
    ["Panic-Attack"] = Color3.fromRGB(178, 34, 34),
    ["3-Ladys"] = Color3.fromRGB(255, 105, 180),      
    ["GirlGENTAI"] = Color3.fromRGB(138, 43, 226),    
    ["BobJHOD"] = Color3.fromRGB(70, 130, 180)        
}

local currentTextureUrl = texturePresets["NEGRON"]
local currentPreset = "NEGRON" 
local customInputUrl = ""
local customAssetId = ""
local cachedTextures = {} 
local customPoleColor = Color3.fromRGB(150, 150, 150) 
local fileCounter = 0

local function getTextureId()
    if customAssetId ~= "" then return customAssetId end
    if cachedTextures[currentTextureUrl] then
        customAssetId = cachedTextures[currentTextureUrl]
        return customAssetId
    end
    
    local getAsset = getcustomasset or getsynasset
    if not getAsset then return "" end
    
    local fetchSuccess, imageData = pcall(function() return game:HttpGet(currentTextureUrl) end)
    if not fetchSuccess or not imageData then return "" end

    fileCounter = fileCounter + 1
    local fileName = "delta_tex_" .. tostring(fileCounter) .. ".jpeg"

    local writeSuccess = pcall(function() writefile(fileName, imageData) end)
    if not writeSuccess then return "" end
    
    local assetSuccess, id = pcall(function() return getAsset(fileName) end)
    if assetSuccess and id then
        customAssetId = id
        cachedTextures[currentTextureUrl] = id 
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
   LoadingTitle = "Generando físicas y gorro vóxel...",
   LoadingSubtitle = "Delta iOS",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Equipamiento", 4483362458) 

local animConnection = nil
local customShirt = nil
local customHatModel = nil 
local flagTool = nil
local backFlag = nil
local isSystemActive = false

local aplicarOutfitYBandera

-- =========================================================
-- INYECCIÓN QUIRÚRGICA: PALITO EN LA BOCA
-- =========================================================
local function equiparPalitoBoca(char)
    local head = char:WaitForChild("Head")
    for _, v in pairs(char:GetChildren()) do
        if v.Name == "PalitoBoca" then v:Destroy() end
    end
    
    local palito = Instance.new("Part")
    palito.Name = "PalitoBoca"
    palito.Size = Vector3.new(0.05, 0.7, 0.05) 
    palito.Color = Color3.fromRGB(240, 240, 240) 
    palito.Material = Enum.Material.Wood 
    palito.Massless = true
    palito.CanCollide = false
    
    local mesh = Instance.new("CylinderMesh", palito)
    palito.Parent = char
    
    local weld = Instance.new("Weld")
    weld.Name = "WeldPalito"
    weld.Part0 = head
    weld.Part1 = palito
    weld.C0 = CFrame.new(0.12, -0.26, -0.55) * CFrame.Angles(math.rad(-110), math.rad(25), math.rad(10))
    weld.Parent = palito
end

-- =========================================================
-- CONTROLES DE TEXTURA
-- =========================================================
Tab:CreateDropdown({
   Name = "Texturas Predeterminadas",
   Options = {"NEGRON", "Spyder550", "Glade", "Darkwole", "Camufla", "CatOnge", "Panic-Attack", "3-Ladys", "GirlGENTAI", "BobJHOD"},
   CurrentOption = {"NEGRON"},
   MultipleOptions = false,
   Flag = "DropdownTexturas",
   Callback = function(Option)
        local selected = type(Option) == "table" and Option[1] or Option
        if texturePresets[selected] then
            currentTextureUrl = texturePresets[selected]
            currentPreset = selected
            customAssetId = "" 
            Rayfield:Notify({Title = "Textura Cambiada", Content = "Seleccionado: " .. selected, Duration = 2})
            if isSystemActive then aplicarOutfitYBandera(true) end
        end
   end,
})

Tab:CreateInput({
   Name = "URL Custom (Raw Link)",
   PlaceholderText = "Pegar link raw de imagen aquí...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        customInputUrl = Text
   end,
})

Tab:CreateButton({
   Name = "Cargar URL Custom",
   Callback = function()
        if customInputUrl ~= "" and (customInputUrl:sub(1,4) == "http") then
            currentTextureUrl = customInputUrl
            currentPreset = nil 
            customAssetId = "" 
            Rayfield:Notify({Title = "Procesando", Content = "Descargando textura custom...", Duration = 2})
            if isSystemActive then aplicarOutfitYBandera(true) end
        end
   end,
})

Tab:CreateColorPicker({
    Name = "Color del Palo (Solo para Custom URL)",
    Color = Color3.fromRGB(150, 150, 150),
    Flag = "ColorPaloPicker",
    Callback = function(Value)
        customPoleColor = Value
        if isSystemActive and not currentPreset then
            local char = game.Players.LocalPlayer.Character
            if char then
                local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Bandera Realista") or char:FindFirstChild("Bandera Realista")
                if tool and tool:FindFirstChild("Handle") then tool.Handle.Color = Value end
                if char:FindFirstChild("BackFlagHandle") then char.BackFlagHandle.Color = Value end
            end
        end
    end
})

-- =========================================================
-- LÓGICA PRINCIPAL (EQUIPAMIENTO DEFINITIVO)
-- =========================================================
aplicarOutfitYBandera = function(Value)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local head = char:WaitForChild("Head") 
    isSystemActive = Value 
    
    if isSystemActive then
        Rayfield:Notify({Title = "Procesando", Content = "Aplicando modificaciones corporales...", Duration = 2})
        
        -- =========================================================
        -- INYECCIÓN: PRE-EQUIPADO (EL ENFORCER)
        -- =========================================================
        local function equiparBaseDefault()
            -- 1. Intentar aplicar un perfil totalmente limpio desde cero
            pcall(function()
                local desc = Instance.new("HumanoidDescription")
                
                -- Limpiar todos los accesorios, pelo y ropa 3D
                desc.HatAccessory = ""; desc.HairAccessory = ""; desc.FaceAccessory = ""
                desc.NeckAccessory = ""; desc.ShoulderAccessory = ""; desc.FrontAccessory = ""
                desc.BackAccessory = ""; desc.WaistAccessory = ""
                desc.ShirtAccessory = ""; desc.PantsAccessory = ""; desc.TShirtAccessory = ""
                desc.SweaterAccessory = ""; desc.JacketAccessory = ""
                
                -- Ropa y Cara Default
                desc.Shirt = 144071012 
                desc.Pants = 144076358 
                desc.Face = 0 
                desc.Head = 0 
                
                -- Partes del cuerpo (Mujer arriba, Chico piernas)
                desc.Torso = 86500008 
                desc.LeftArm = 86500036
                desc.RightArm = 86500054
                desc.LeftLeg = 81069695
                desc.RightLeg = 81069704

                humanoid:ApplyDescription(desc)
            end)
            
            task.wait(0.5) -- Pausa para que el motor cargue
            
            -- 2. FUERZA BRUTA (Correcciones por si el exploit falla)
            
            -- Arrancar Pelo y sombreros residuales
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("ShirtGraphic") then v:Destroy() end
            end

            -- Forzar Ropa
            local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
            shirt.ShirtTemplate = "rbxassetid://144071011"
            local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
            pants.PantsTemplate = "rbxassetid://144076357"

            -- Forzar Cara (Matar texturas dinámicas que bloquean la sonrisa)
            if head then
                for _, v in pairs(head:GetChildren()) do
                    -- Destruye SurfaceAppearances (Cabezas modernas)
                    if v:IsA("SurfaceAppearance") or v:IsA("FaceControls") or v:IsA("WrapTarget") then
                        v:Destroy()
                    end
                end
                
                -- Resetear mallas especiales
                if head:FindFirstChildOfClass("SpecialMesh") then
                    head:FindFirstChildOfClass("SpecialMesh").MeshType = Enum.MeshType.Head
                end

                -- Aplicar la cara clásica de Noob
                local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
                if face then
                    face.Texture = "rbxasset://textures/face.png"
                else
                    face = Instance.new("Decal", head)
                    face.Name = "face"
                    face.Texture = "rbxasset://textures/face.png"
                end
            end

            -- Forzar Cuerpos si estás en juego R6
            if humanoid.RigType == Enum.HumanoidRigType.R6 then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("CharacterMesh") then v:Destroy() end
                end
                
                local meshes = {
                    {Enum.BodyPart.Torso, "rbxassetid://86500008"},
                    {Enum.BodyPart.LeftArm, "rbxassetid://86500036"},
                    {Enum.BodyPart.RightArm, "rbxassetid://86500054"},
                    {Enum.BodyPart.LeftLeg, "rbxassetid://81069695"},
                    {Enum.BodyPart.RightLeg, "rbxassetid://81069704"}
                }
                for _, m in ipairs(meshes) do
                    local cm = Instance.new("CharacterMesh", char)
                    cm.BodyPart = m[1]
                    cm.MeshId = m[2]
                end
            end
        end
        
        equiparBaseDefault()
        task.wait(0.2)
        -- =========================================================

        local textureId = getTextureId()
        local flagPoleColor = currentPreset and presetColors[currentPreset] or customPoleColor
        
        -- 1. T-Shirt de Bandera
        if textureId ~= "" then
            customShirt = Instance.new("ShirtGraphic", char)
            customShirt.Graphic = textureId
        end

        -- 2. GORRO CUBETA
        if customHatModel then customHatModel:Destroy() end
        for _, v in pairs(char:GetChildren()) do if v.Name == "GorroCustomSoldado" then v:Destroy() end end
        
        customHatModel = Instance.new("Model")
        customHatModel.Name = "GorroCustomSoldado"
        local elevacionGorro = 0.08 

        local function crearLoseta(nombre, tamano, alturaY)
            local bloque = Instance.new("Part")
            bloque.Name = nombre; bloque.Shape = Enum.PartType.Block
            bloque.Size = tamano; bloque.Material = Enum.Material.Fabric
            bloque.Massless = true; bloque.CanCollide = false
            
            if textureId ~= "" then
                bloque.Color = Color3.fromRGB(255, 255, 255)
                local caras = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}
                for _, cara in ipairs(caras) do
                    local texturaCara = Instance.new("Decal")
                    texturaCara.Texture = textureId; texturaCara.Face = cara; texturaCara.Parent = bloque
                end
            else
                bloque.Color = Color3.fromRGB(18, 18, 18)
            end
            bloque.CFrame = head.CFrame * CFrame.new(0, alturaY + elevacionGorro, 0)
            bloque.Parent = customHatModel
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = head; weld.Part1 = bloque; weld.Parent = bloque
        end

        crearLoseta("Copa1_Pequena", Vector3.new(1.0, 0.25, 1.0), 0.75) 
        crearLoseta("Copa2_Mediana", Vector3.new(1.1, 0.25, 1.1), 0.50)
        crearLoseta("Copa3_Base",    Vector3.new(1.2, 0.25, 1.2), 0.25)
        crearLoseta("Caida1", Vector3.new(1.5, 0.1, 1.5), 0.15)
        crearLoseta("Caida2", Vector3.new(1.8, 0.1, 1.8), 0.05)
        crearLoseta("Caida3", Vector3.new(2.1, 0.1, 2.1), -0.05)
        customHatModel.Parent = char

        equiparPalitoBoca(char)

        -- 3. BANDERA
        local wasEquipped = false
        if char:FindFirstChild("Bandera Realista") then wasEquipped = true; char:FindFirstChild("Bandera Realista"):Destroy() end
        if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
        if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end

        flagTool = Instance.new("Tool")
        flagTool.Name = "Bandera Realista"
        flagTool.RequiresHandle = true
        flagTool.Grip = CFrame.new(0, -2, 0) 

        local handleFlag = Instance.new("Part")
        handleFlag.Name = "Handle"
        handleFlag.Size = Vector3.new(0.15, 6, 0.15)
        handleFlag.Color = flagPoleColor 
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
            surface.Parent = part

            local img = Instance.new("ImageLabel")
            img.BackgroundTransparency = 1
            img.Image = textureId
            img.Size = UDim2.new(numSegments, 0, 1, 0)
            img.Position = isBack and UDim2.new(-(index - 1), 0, 0, 0) or UDim2.new(-(numSegments - index), 0, 0, 0)
            img.Parent = surface
        end

        for i = 1, numSegments do
            local seg = Instance.new("Part")
            seg.Size = Vector3.new(segWidth, height, 0.05)
            seg.Massless = true; seg.CanCollide = false; seg.Transparency = 1 
            
            if textureId ~= "" then
                applyPerfectTexture(seg, i, false)
                applyPerfectTexture(seg, i, true)
            end

            local motor = Instance.new("Motor6D", handleFlag)
            motor.Name = "Joint_" .. i
            if i == 1 then
                motor.Part0 = handleFlag; motor.Part1 = seg
                motor.C0 = CFrame.new(0, 2, 0); motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            else
                motor.Part0 = handleFlag:FindFirstChild("Seg_" .. (i-1)); motor.Part1 = seg
                motor.C0 = CFrame.new(segWidth/2, 0, 0); motor.C1 = CFrame.new(-segWidth/2, 0, 0)
            end
            
            seg.Name = "Seg_" .. i
            seg.Parent = handleFlag 
        end

        local function createBackFlag()
            if backFlag then backFlag:Destroy() end
            if not handleFlag or not isSystemActive then return end
            
            backFlag = handleFlag:Clone()
            backFlag.Name = "BackFlagHandle"
            backFlag.Massless = true
            backFlag.CanCollide = false
            backFlag.Parent = char
            
            for i = 1, numSegments do
                local joint = backFlag:FindFirstChild("Joint_" .. i)
                local seg = backFlag:FindFirstChild("Seg_" .. i)
                if joint and seg then
                    joint.Part0 = (i == 1) and backFlag or backFlag:FindFirstChild("Seg_" .. (i-1))
                    joint.Part1 = seg
                end
            end
            
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if torso then
                backFlag.CFrame = torso.CFrame * CFrame.new(0, 0, 0.65) * CFrame.Angles(math.rad(15), 0, math.rad(-45))
                local weldFlag = Instance.new("WeldConstraint")
                weldFlag.Part0 = torso; weldFlag.Part1 = backFlag; weldFlag.Parent = backFlag
            end
        end

        flagTool.Equipped:Connect(function() if backFlag then backFlag:Destroy() end end)
        flagTool.Unequipped:Connect(function() if isSystemActive then createBackFlag() end end)
        flagTool.Parent = player.Backpack

        if wasEquipped then humanoid:EquipTool(flagTool) else createBackFlag() end

        local RunService = game:GetService("RunService")
        local timePassed = 0
        if animConnection then animConnection:Disconnect() end
        
        animConnection = RunService.Heartbeat:Connect(function(dt)
            timePassed = timePassed + dt
            local banderasActivas = {}
            if flagTool and flagTool.Parent == char and handleFlag then table.insert(banderasActivas, handleFlag) end
            if backFlag and backFlag.Parent == char then table.insert(banderasActivas, backFlag) end
            
            local swayX = math.sin(timePassed * 3) * 0.15 
            local swayY = math.sin(timePassed * 5) * 0.08 
            local swayZ = math.sin(timePassed * 2) * 0.05 
            local speed = humanoid.MoveDirection.Magnitude
            if speed > 0 then swayX = swayX + (math.sin(timePassed * 8) * 0.15) end
            
            for _, activeHandle in ipairs(banderasActivas) do
                local windSpeed = 6 + (speed * 0.5) 
                for i = 1, numSegments do
                    local motor = activeHandle:FindFirstChild("Joint_" .. i)
                    if motor then
                        local angleY = math.sin((timePassed * windSpeed) - (i * 1.2)) 
                        if i == 1 then
                            motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(swayZ, swayX + (angleY * 0.1), swayY)
                        else
                            motor.C0 = CFrame.new(segWidth/2, 0, 0) * CFrame.Angles(0, angleY * (0.1 + (i * 0.05)), 0)
                        end
                    end
                end
            end
        end)

    else
        if animConnection then animConnection:Disconnect(); animConnection = nil end
        if customShirt then customShirt:Destroy() end
        for _, v in pairs(char:GetChildren()) do if v:IsA("ShirtGraphic") then v:Destroy() end end
        if customHatModel then customHatModel:Destroy() end
        for _, v in pairs(char:GetChildren()) do if v.Name == "GorroCustomSoldado" or v.Name == "PalitoBoca" then v:Destroy() end end
        if flagTool then flagTool:Destroy(); flagTool = nil end
        if player.Backpack:FindFirstChild("Bandera Realista") then player.Backpack:FindFirstChild("Bandera Realista"):Destroy() end
        if char:FindFirstChild("Bandera Realista") then char:FindFirstChild("Bandera Realista"):Destroy() end
        if backFlag then backFlag:Destroy(); backFlag = nil end
        if char:FindFirstChild("BackFlagHandle") then char:FindFirstChild("BackFlagHandle"):Destroy() end
    end
end

Tab:CreateToggle({
   Name = "Activar Outfit y Bandera",
   CurrentValue = false,
   Flag = "ToggleOutfit",
   Callback = function(Value)
        aplicarOutfitYBandera(Value)
   end
})
