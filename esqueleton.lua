-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO CUSTOM 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto V5 💀",
   LoadingTitle = "Sistema Anti-Caídas activado...",
   LoadingSubtitle = "Menú Independiente",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = "RightControl"
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SkeletonTab = Window:CreateTab("Esqueleto", 4483362458)

SkeletonTab:CreateParagraph({
    Title = "Corrección Crítica (V5)",
    Content = "Se corrigió el error donde el esqueleto caía al vacío. Ahora se fuerza la soldadura antes de aplicar físicas y usa un mapeo inteligente de huesos."
})

local function TransformToCustomSkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local realHead = char:FindFirstChild("Head")
    if not hum or not rootPart or not realHead then return end

    -- 1. LIMPIEZA DE ACCESORIOS Y ROPA
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. INVISIBILIZAR CUERPO REAL (Sin borrarlo para no romper el personaje)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end

    -- 3. DESCARGAR ESQUELETO (ID: 16689486257)
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://16689486257")
    end)

    if success and objects and objects[1] then
        local skeletonModel = objects[1]
        skeletonModel.Name = "CustomSkeletonRig"
        skeletonModel.Parent = char

        -- Limpieza de scripts internos del modelo
        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") then
                item:Destroy()
            end
            if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
                item:Destroy() -- Borramos el RootPart falso del modelo
            end
        end

        -- DICCIONARIO DE MAPEO (R6 a R15)
        local r15Map = {
            ["Torso"] = "UpperTorso",
            ["Left Arm"] = "LeftUpperArm",
            ["Right Arm"] = "RightUpperArm",
            ["Left Leg"] = "LeftUpperLeg",
            ["Right Leg"] = "RightUpperLeg"
        }

        -- PROCESAR CADA PARTE DEL ESQUELETO
        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                -- Asegurarnos de que esté anclado MIENTRAS trabajamos con él
                skelPart.Anchored = true 
                skelPart.CanCollide = false
                skelPart.Massless = true

                -- Borrar uniones originales (Motor6D, Welds) que lo mantienen en Pose T
                for _, joint in ipairs(skelPart:GetChildren()) do
                    if joint:IsA("JointInstance") then joint:Destroy() end
                end

                -- Destruir la cabeza original del modelo 3D
                local partName = string.lower(skelPart.Name)
                if string.match(partName, "head") or string.match(partName, "skull") then
                    skelPart:Destroy()
                    continue
                end

                -- 3.1 BUSCAR EL HUESO CORRESPONDIENTE EN TU CUERPO
                local realPart = char:FindFirstChild(skelPart.Name)
                
                -- Si no lo encuentra directo y eres R15, usa el mapa
                if not realPart and hum.RigType == Enum.HumanoidRigType.R15 then
                    realPart = char:FindFirstChild(r15Map[skelPart.Name] or "")
                end

                -- Respaldo: Si de plano no encuentra qué brazo o pierna es, lo pega al Torso (RootPart)
                -- para asegurar que JAMÁS desaparezca.
                if not realPart then
                    realPart = rootPart
                end

                -- 3.2 ESCALAR, POSICIONAR Y SOLDAR
                if realPart then
                    -- Escalar limitando los valores extremos para evitar que se vuelva microscópico
                    local sizeRatio = math.clamp(realPart.Size.Y / skelPart.Size.Y, 0.3, 1.5)
                    skelPart.Size = skelPart.Size * sizeRatio
                    
                    local mesh = skelPart:FindFirstChildWhichIsA("DataModelMesh")
                    if mesh then
                        mesh.Scale = mesh.Scale * sizeRatio
                    end

                    -- Posicionar igual que la parte real
                    skelPart.CFrame = realPart.CFrame
                    
                    -- Soldar FIRMEMENTE
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = realPart
                    weld.Part1 = skelPart
                    weld.Parent = skelPart

                    -- ¡CRÍTICO!: Solo desanclamos DESPUÉS de que la soldadura está creada
                    skelPart.Anchored = false
                end
            end
        end
    else
        warn("El ejecutor no pudo descargar el modelo o no hay conexión.")
    end

    -- 4. CABEZA DE AGONY BOMB (Referencia al archivo bombs.lua[span_0](start_span)[span_0](end_span))
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local bombsFolder = assets and assets:FindFirstChild("Bombs")
    local agonyBomb = bombsFolder and bombsFolder:FindFirstChild("Agony Bomb")

    if agonyBomb then
        local bombPart = agonyBomb:FindFirstChild("Handle") or agonyBomb:FindFirstChildWhichIsA("BasePart")
        
        if bombPart then
            local oldCustomHead = char:FindFirstChild("AgonyHead_Custom")
            if oldCustomHead then oldCustomHead:Destroy() end

            local customHead = bombPart:Clone()
            customHead.Name = "AgonyHead_Custom"
            
            -- Encogemos la bomba a la mitad
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 0.5 
            end
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            -- Proceso seguro: Anclar -> Mover -> Soldar -> Desanclar
            customHead.Anchored = true
            customHead.Parent = char
            customHead.CFrame = realHead.CFrame
            customHead.CanCollide = false
            customHead.Massless = true

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = realHead
            weld.Part1 = customHead
            weld.Parent = customHead

            customHead.Anchored = false
        end
    end
end

SkeletonTab:CreateButton({
   Name = "💀 Aplicar Esqueleto V5 (Anti-Caída)",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Esqueleto Fijado", 
            Content = "Soldadura segura completada. Ya no debería desaparecer.", 
            Duration = 4
        })
   end,
})
