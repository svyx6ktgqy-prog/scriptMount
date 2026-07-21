-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO V6 (FIX VISIBILIDAD)
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto V6 💀",
   LoadingTitle = "Aplicando fix de visibilidad...",
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
    Title = "Fix Definitivo de Visibilidad",
    Content = "Se rediseñó el sistema de inyección para evitar que el modelo colapse o se vuelva microscópico. Forzamos proporciones estables."
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
        skeletonModel.Name = "CustomSkeletonRig_V6"
        skeletonModel.Parent = char

        -- Limpieza de scripts o basura interna
        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") or (item:IsA("BasePart") and item.Name == "HumanoidRootPart") then
                item:Destroy()
            end
        end

        -- Mapeo R15 seguro
        local r15Map = {
            ["Torso"] = "UpperTorso",
            ["Left Arm"] = "LeftUpperArm",
            ["Right Arm"] = "RightUpperArm",
            ["Left Leg"] = "LeftUpperLeg",
            ["Right Leg"] = "RightUpperLeg"
        }

        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                skelPart.Anchored = true
                skelPart.CanCollide = false
                skelPart.Massless = true

                -- Borrar uniones viejas
                for _, joint in ipairs(skelPart:GetChildren()) do
                    if joint:IsA("JointInstance") then joint:Destroy() end
                end

                -- Eliminar cabeza del esqueleto
                local partName = string.lower(skelPart.Name)
                if string.match(partName, "head") or string.match(partName, "skull") then
                    skelPart:Destroy()
                    continue
                end

                -- Buscar parte real
                local realPart = char:FindFirstChild(skelPart.Name)
                if not realPart and hum.RigType == Enum.HumanoidRigType.R15 then
                    realPart = char:FindFirstChild(r15Map[skelPart.Name] or "")
                end

                -- Si encuentra la parte real, la adaptamos con escala fija segura (Evita que desaparezca)
                if realPart then
                    skelPart.CFrame = realPart.CFrame
                    
                    -- Forzar tamaño visible estándar basado en la parte real sin romper texturas
                    skelPart.Size = realPart.Size * 1.05
                    
                    local mesh = skelPart:FindFirstChildWhichIsA("DataModelMesh")
                    if mesh then
                        mesh.Scale = Vector3.new(1, 1, 1) -- Resetea la escala deforme del asset
                    end

                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = realPart
                    weld.Part1 = skelPart
                    weld.Parent = skelPart

                    skelPart.Anchored = false
                else
                    -- Si no encuentra la parte, eliminamos el objeto sobrante para evitar que flote invisible
                    skelPart:Destroy()
                end
            end
        end
    else
        warn("No se pudo descargar el modelo del esqueleto.")
    end

    -- 4. CABEZA DE AGONY BOMB (Ruta de bombs.lua[span_0](start_span)[span_0](end_span))
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
            
            -- Encogemos la bomba a la mitad de forma segura
            if customHead:IsA("BasePart") then
                customHead.Size = Vector3.new(1.2, 1.2, 1.2)
            end
            
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = Vector3.new(0.6, 0.6, 0.6)
            end

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
   Name = "💀 Aplicar Esqueleto V6 (Fix Visibilidad)",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Esqueleto Aplicado", 
            Content = "Filtro de escala forzada completado con éxito.", 
            Duration = 4
        })
   end,
})
