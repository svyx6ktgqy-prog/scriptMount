-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO CUSTOM 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto V3 💀",
   LoadingTitle = "Cargando Asset ID: 16689486257...",
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
    Title = "Método 100% Eficaz (GetObjects)",
    Content = "Descarga el modelo 3D directamente desde Roblox. Suelda los huesos a tu cuerpo real invisible y reemplaza la cabeza con la Agony Bomb a la mitad de su tamaño."
})

local function TransformToCustomSkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local realHead = char:FindFirstChild("Head")
    if not hum or not realHead then return end

    -- =========================================================
    -- AJUSTE DE ALTURA / ELEVACIÓN
    -- Incrementa o disminuye el valor Y (1.5) si necesitas ajustar la altura.
    -- =========================================================
    local offsetElevacion = CFrame.new(0, 1.5, 0)

    -- 1. ELIMINAR ACCESORIOS Y ROPA
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. HACER EL CUERPO REAL INVISIBLE (Conservando colisiones y animaciones)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end

    -- 3. CARGAR EL MODELO DEL ESQUELETO DESDE EL ASSET ID
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://14596777035")
    end)

    if success and objects and objects[1] then
        local skeletonModel = objects[1]
        skeletonModel.Name = "CustomSkeletonRig"
        skeletonModel.Parent = char

        -- Limpiamos scripts o humanoides residuales dentro del modelo
        for _, item in ipairs(skeletonModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Humanoid") then
                item:Destroy()
            end
        end

        -- Soldamos cada parte del esqueleto aplicando la elevación
        for _, skelPart in ipairs(skeletonModel:GetDescendants()) do
            if skelPart:IsA("BasePart") then
                skelPart.CanCollide = false
                skelPart.Massless = true
                skelPart.Anchored = false

                -- Destruimos la cabeza del esqueleto para la Agony Bomb
                if skelPart.Name == "Head" then
                    skelPart:Destroy()
                    continue
                end

                -- Buscar la contraparte en el cuerpo real
                local realPart = char:FindFirstChild(skelPart.Name)
                
                -- Adaptación R15 / R6
                if not realPart and hum.RigType == Enum.HumanoidRigType.R15 then
                    if skelPart.Name == "Torso" then realPart = char:FindFirstChild("UpperTorso") end
                    if skelPart.Name == "Left Arm" then realPart = char:FindFirstChild("LeftUpperArm") end
                    if skelPart.Name == "Right Arm" then realPart = char:FindFirstChild("RightUpperArm") end
                    if skelPart.Name == "Left Leg" then realPart = char:FindFirstChild("LeftUpperLeg") end
                    if skelPart.Name == "Right Leg" then realPart = char:FindFirstChild("RightUpperLeg") end
                end

                -- Posicionar elevando la parte y soldarla
                if realPart then
                    skelPart.CFrame = realPart.CFrame * offsetElevacion
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = realPart
                    weld.Part1 = skelPart
                    weld.Parent = skelPart
                end
            end
        end
    else
        warn("No se pudo cargar el Asset ID. Asegúrate de que tu ejecutor soporte game:GetObjects()")
    end

    -- 4. CABEZA DE AGONY BOMB (Elevada a la misma proporción)
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
            
            -- Encogemos la bomba al 50%
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 0.5 
            end
            
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            -- Soldamos la Agony Bomb aplicando la misma elevación
            customHead.Parent = char
            customHead.CFrame = realHead.CFrame * offsetElevacion
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
   Name = "💀 Aplicar Esqueleto Custom (ID: 16689486257)",
   Callback = function()
        TransformToCustomSkeleton()
        Rayfield:Notify({
            Title = "Transformación Exitosa", 
            Content = "Modelo cargado y elevado correctamente.", 
            Duration = 4
        })
   end,
})
