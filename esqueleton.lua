-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO CUSTOM (AGONY POSE) 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto Agony V3 💀",
   LoadingTitle = "Cargando Asset ID: 16689486257...",
   LoadingSubtitle = "Menú Independiente (Pose Original)",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = "RightControl"
})

-- Servicios de Roblox[span_1](start_span)[span_1](end_span)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SkeletonTab = Window:CreateTab("Esqueleto", 4483362458)

SkeletonTab:CreateParagraph({
    Title = "Método 100% Eficaz (Pose Reference Image)",
    Content = "Descarga el modelo 3D directamente desde Roblox. Suelda los huesos a tu cuerpo real invisible, reemplaza la cabeza con la Agony Bomb a la mitad de su tamaño y FUERZA la postura original encorvada y asimétrica de la imagen de referencia."
})

local function TransformToCustomSkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local realHead = char:FindFirstChild("Head")
    if not hum or not hrp or not realHead then return end

    -- =========================================================
    -- AJUSTE DE ALTURA / ELEVACIÓN GLOBAL[span_2](start_span)[span_2](end_span)
    -- =========================================================
    local offsetElevacion = CFrame.new(0, 1.5, 0)

    -- =========================================================
    -- DEFINICIÓN DE CFrames PARA LA POSE ORIGINAL (Relativos al HRP)
    -- Ajustados basándose en "image_2.png": Encorvado, brazo derecho
    -- adelantado/abierto, brazo izquierdo colgando.
    -- =========================================================
    local agonyPoseCframos = {
        -- Torso encorvado fuertemente hacia adelante
        ["Torso"] = CFrame.new(0, 1.5, -1) * CFrame.Angles(math.rad(-40), 0, 0), 
        -- Brazo derecho adelantado, algo flexionado hacia afuera
        ["Right Arm"] = CFrame.new(1.8, 1.2, -1.5) * CFrame.Angles(math.rad(-30), math.rad(-20), math.rad(25)), 
        -- Brazo izquierdo colgando más recto hacia abajo y ligeramente atrás
        ["Left Arm"] = CFrame.new(-1.8, 0.8, -0.8) * CFrame.Angles(math.rad(-10), 0, math.rad(-10)),
        -- Piernas compensando el peso hacia adelante
        ["Right Leg"] = CFrame.new(0.8, -1.2, -0.5) * CFrame.Angles(math.rad(10), 0, 0),
        ["Left Leg"] = CFrame.new(-0.8, -1.2, -0.5) * CFrame.Angles(math.rad(10), 0, 0),
    }

    -- Mapeo para soporte R15 usando el Torso R6 como base
    local mapR15toR6Parts = {
        ["UpperTorso"] = "Torso",
        ["LowerTorso"] = "Torso",
        ["RightUpperArm"] = "Right Arm",
        ["RightLowerArm"] = "Right Arm",
        ["RightHand"] = "Right Arm",
        ["LeftUpperArm"] = "Left Arm",
        ["LeftLowerArm"] = "Left Arm",
        ["LeftHand"] = "Left Arm",
        ["RightUpperLeg"] = "Right Leg",
        ["RightLowerLeg"] = "Right Leg",
        ["RightFoot"] = "Right Leg",
        ["LeftUpperLeg"] = "Left Leg",
        ["LeftLowerLeg"] = "Left Leg",
        ["LeftFoot"] = "Left Leg",
    }

    -- 1. ELIMINAR ACCESORIOS Y ROPA[span_3](start_span)[span_3](end_span)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. HACER EL CUERPO REAL INVISIBLE (Conservando colisiones y animaciones)[span_4](start_span)[span_4](end_span)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end

    -- 3. CARGAR EL MODELO DEL ESQUELETO DESDE EL ASSET ID[span_5](start_span)[span_5](end_span)
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://127994220189422")
    end)

    if success and objects and objects[1] then
        local skeletonModel = objects[1]
        skeletonModel.Name = "CustomSkeletonRig"
        skeletonModel.Parent = char

        -- Limpiamos scripts o humanoides residuales dentro del modelo[span_6](start_span)[span_6](end_span)
        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") then
                item:Destroy()
            end
        end

        -- Soldamos cada parte del esqueleto forzando la pose de la imagen
        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                skelPart.CanCollide = false
                skelPart.Massless = true
                skelPart.Anchored = false

                -- Destruimos la cabeza del esqueleto para la Agony Bomb[span_7](start_span)[span_7](end_span)
                if skelPart.Name == "Head" then
                    skelPart:Destroy()
                    continue
                end

                -- Determinar la pose correspondiente
                local targetCframe = agonyPoseCframos[skelPart.Name]
                
                -- Adaptación R15 / R6[span_8](start_span)[span_8](end_span)
                if not targetCframe and hum.RigType == Enum.HumanoidRigType.R15 then
                    local r6PartName = mapR15toR6Parts[skelPart.Name]
                    if r6PartName then
                        targetCframe = agonyPoseCframos[r6PartName]
                    end
                end

                -- Posicionar aplicando la pose de Agony, luego soldarla al HRP
                if targetCframe then
                    local finalPoseCframe = (hrp.CFrame * offsetElevacion) * targetCframe
                    skelPart.CFrame = finalPoseCframe
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = hrp
                    weld.Part1 = skelPart
                    weld.Parent = skelPart
                end
            end
        end
    else
        warn("No se pudo cargar el Asset ID. Asegúrate de que tu ejecutor soporte game:GetObjects()")
    end

    -- 4. CABEZA DE AGONY BOMB (Centrada sobre la gran masa de la espalda)[span_9](start_span)[span_9](end_span)
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
            
            -- Encogemos la bomba al 50%[span_10](start_span)[span_10](end_span)
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 1.0 
            end
            
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            -- =========================================================
            -- AJUSTE DE CABEZA / MASA TUMORAL
            -- Posicionada justo encima/atrás del torso encorvado
            -- =========================================================
            local posCabezaAgony = agonyPoseCframos["Torso"] * CFrame.new(0, 1.8, 0.5)

            customHead.Parent = char
            local finalHeadCframe = (hrp.CFrame * offsetElevacion) * posCabezaAgony
            customHead.CFrame = finalHeadCframe
            customHead.CanCollide = false
            customHead.Massless = true

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hrp 
            weld.Part1 = customHead
            weld.Parent = customHead
        end
    else
        warn("No se encontró la Agony Bomb en ReplicatedStorage.Assets.Bombs.")
    end
end

SkeletonTab:CreateButton({
   Name = "💀 Aplicar Esqueleto (Pose Original Agony)",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Transformación Exitosa", 
            Content = "Modelo cargado con su postura encorvada original.", 
            Duration = 4
        })
   end,
})
