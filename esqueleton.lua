-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO CUSTOM 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto V4 💀",
   LoadingTitle = "Reparando proporciones y físicas...",
   LoadingSubtitle = "Menú Independiente",
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
    Title = "Corrección de Físicas (Fijado)",
    Content = "El esqueleto ahora detectará el tamaño de tu cuerpo y se encogerá proporcionalmente. Se desanclará para fluir con tus animaciones."
})

local function TransformToCustomSkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local realHead = char:FindFirstChild("Head")
    if not hum or not realHead then return end

    -- 1. LIMPIEZA TOTAL DE ACCESORIOS Y ROPA
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. INVISIBILIZAR CUERPO REAL
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

        -- Purgar elementos que rompan las físicas (Scripts, Humanoides internos, RootParts duplicados)
        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") then
                item:Destroy()
            end
            if item:IsA("BasePart") and item.Name == "HumanoidRootPart" then
                item:Destroy()
            end
        end

        -- Adaptar, escalar y soldar cada hueso
        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                -- DESANCLAR IMPORTANTÍSIMO: Evita que te quedes congelado en el aire o bajo tierra
                skelPart.Anchored = false
                skelPart.CanCollide = false
                skelPart.Massless = true

                -- Borrar cualquier Motor6D o Weld que traiga el modelo para que no pelee con tus animaciones reales
                for _, joint in ipairs(skelPart:GetChildren()) do
                    if joint:IsA("JointInstance") then joint:Destroy() end
                end

                -- Destruir la cabeza original del modelo (Busca palabras clave por si tiene nombres raros)
                local partName = string.lower(skelPart.Name)
                if string.match(partName, "head") or string.match(partName, "skull") then
                    skelPart:Destroy()
                    continue
                end

                -- Buscar la contraparte en tu cuerpo real
                local realPart = char:FindFirstChild(skelPart.Name)
                
                -- Si tu avatar es R15, adaptamos los nombres
                if not realPart and hum.RigType == Enum.HumanoidRigType.R15 then
                    local r15Map = {
                        ["Torso"] = "UpperTorso",
                        ["Left Arm"] = "LeftUpperArm",
                        ["Right Arm"] = "RightUpperArm",
                        ["Left Leg"] = "LeftUpperLeg",
                        ["Right Leg"] = "RightUpperLeg"
                    }
                    realPart = char:FindFirstChild(r15Map[skelPart.Name] or "")
                end

                if realPart then
                    -- ESCALADO DINÁMICO: Reduce el hueso al tamaño exacto de tu extremidad real
                    local sizeRatio = realPart.Size.Y / skelPart.Size.Y
                    skelPart.Size = skelPart.Size * sizeRatio
                    
                    local mesh = skelPart:FindFirstChildWhichIsA("DataModelMesh")
                    if mesh then
                        mesh.Scale = mesh.Scale * sizeRatio
                    end

                    -- Posicionar exactamente y soldar
                    skelPart.CFrame = realPart.CFrame
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = realPart
                    weld.Part1 = skelPart
                    weld.Parent = skelPart
                end
            end
        end
    else
        warn("Error al descargar el Asset ID.")
    end

    -- 4. CABEZA DE AGONY BOMB (bombs.lua[span_1](start_span)[span_1](end_span))
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
            
            -- Encogemos la Agony Bomb al 50%
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 0.5 
            end
            
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            -- Soldamos a la cabeza real (que ya es invisible)
            customHead.Parent = char
            customHead.CFrame = realHead.CFrame
            customHead.CanCollide = false
            customHead.Massless = true

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = realHead
            weld.Part1 = customHead
            weld.Parent = customHead
        end
    end
end

SkeletonTab:CreateButton({
   Name = "💀 Aplicar Esqueleto Custom (Corregido)",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Físicas Corregidas", 
            Content = "Esqueleto escalado a tu tamaño real y con animaciones conectadas.", 
            Duration = 4
        })
   end,
})
