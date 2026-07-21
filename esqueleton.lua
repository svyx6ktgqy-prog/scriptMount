-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN AGONY (ANIMADO + VISIBLE) 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Agony Animado V4 💀",
   LoadingTitle = "Cargando Asset ID: 127994220189422...",
   LoadingSubtitle = "Cuerpo Invisible + Animaciones Heredadas",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = "RightControl"
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local SkeletonTab = Window:CreateTab("Esqueleto", 4483362458)

SkeletonTab:CreateParagraph({
    Title = "Método Animado y Deformación Rígida",
    Content = "Carga el modelo T-Pose. Suelda las partes a las extremidades de tu cuerpo REAL (que ahora es INVISIBLE) aplicando deformaciones rígidas. La masa tumoral se suelda a la cabeza para conservar sus animaciones."
})

local function TransformToCustomSkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local realHead = char:FindFirstChild("Head")
    if not hum or not realHead then return end

    -- =========================================================
    -- DEFORMACIÓN RÍGIDA Y OFFSETS (Relativos al cuerpo animado)
    -- =========================================================
    local deformOffsets = {
        ["Torso"] = CFrame.new(0, 0.5, -0.6) * CFrame.Angles(math.rad(-20), 0, 0),
        ["Right Arm"] = CFrame.new(0.6, 0.2, -0.4) * CFrame.Angles(math.rad(-15), math.rad(-10), math.rad(20)),
        ["Left Arm"] = CFrame.new(-0.2, 0, 0.2) * CFrame.Angles(math.rad(5), 0, math.rad(-5)),
        ["Right Leg"] = CFrame.new(0.2, 0, 0),
        ["Left Leg"] = CFrame.new(-0.2, 0, 0),
    }

    local deformScales = {
        ["Torso"] = Vector3.new(1.3, 1.3, 1.4),
        ["Right Arm"] = Vector3.new(1.4, 1.4, 1.4), 
        ["Left Arm"] = Vector3.new(1.0, 1.0, 1.0),
        ["Right Leg"] = Vector3.new(1.1, 1.1, 1.1),
        ["Left Leg"] = Vector3.new(1.1, 1.1, 1.1),
    }

    local mapR15toR6Parts = {
        ["UpperTorso"] = "Torso",
        ["RightUpperArm"] = "Right Arm",
        ["LeftUpperArm"] = "Left Arm",
        ["RightUpperLeg"] = "Right Leg",
        ["LeftUpperLeg"] = "Left Leg",
    }

    -- 1. ELIMINAR ACCESORIOS Y ROPA
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. HACER EL CUERPO ORIGINAL (NOOB) INVISIBLE
    -- Como esto se ejecuta ANTES de cargar el esqueleto y la cabeza Agony, 
    -- solo ocultará el cuerpo original.
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1 -- Hace invisible el bloque
            
            -- Ocultar la cara (Decal) original para evitar la sonrisa flotante
            local face = part:FindFirstChild("face") or part:FindFirstChild("Face")
            if face and face:IsA("Decal") then
                face.Transparency = 1
            end
        end
    end

    -- 3. CARGAR EL MODELO DEL ESQUELETO DESDE EL ASSET ID SOLICITADO
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://127994220189422")
    end)

    if success and objects and objects[1] then
        local skeletonModel = objects[1]
        skeletonModel.Name = "CustomSkeletonRig_Animado"
        skeletonModel.Parent = char

        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") then
                item:Destroy()
            end
        end

        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                skelPart.CanCollide = false
                skelPart.Massless = true
                skelPart.Anchored = false

                if skelPart.Name == "Head" then
                    skelPart:Destroy()
                    continue
                end

                local realPart = char:FindFirstChild(skelPart.Name)
                
                if not realPart and hum.RigType == Enum.HumanoidRigType.R15 then
                    for r15Name, r6Name in pairs(mapR15toR6Parts) do
                        if r6Name == skelPart.Name then
                            realPart = char:FindFirstChild(r15Name)
                            break
                        end
                    end
                end

                if realPart then
                    local scaleMulti = deformScales[skelPart.Name] or Vector3.new(1,1,1)
                    local mesh = skelPart:FindFirstChildWhichIsA("DataModelMesh")
                    if mesh and typeof(mesh.Scale) == "Vector3" then
                        mesh.Scale = mesh.Scale * scaleMulti
                    else
                        skelPart.Size = skelPart.Size * scaleMulti
                    end

                    local offsetCFrame = deformOffsets[skelPart.Name] or CFrame.new()
                    skelPart.CFrame = realPart.CFrame * offsetCFrame

                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = realPart
                    weld.Part1 = skelPart
                    weld.Parent = skelPart
                end
            end
        end
    else
        warn("No se pudo cargar el Asset ID 127994220189422. Revisa la conexión o el ID.")
    end

    -- 4. CABEZA DE AGONY BOMB 
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
            
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 1.0 
                customHead.Transparency = 0 -- Aseguramos que la masa tumoral sea visible
            end
            
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            local posCabezaAgony = CFrame.new(0, 1.2, 0.8) * CFrame.Angles(math.rad(15), 0, 0)

            customHead.Parent = char
            customHead.CFrame = realHead.CFrame * posCabezaAgony
            customHead.CanCollide = false
            customHead.Massless = true

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = realHead 
            weld.Part1 = customHead
            weld.Parent = customHead
        end
    else
        warn("No se encontró la Agony Bomb en ReplicatedStorage.Assets.Bombs.")
    end
end

SkeletonTab:CreateButton({
   Name = "💀 Aplicar Deformación y Animaciones",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Transformación Exitosa", 
            Content = "Cuerpo invisible, deformación aplicada y animaciones vinculadas.", 
            Duration = 5
        })
   end,
})
