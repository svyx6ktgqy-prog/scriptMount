-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO V2 💀
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto V2 💀",
   LoadingTitle = "Inyectando modificador visual...",
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
    Title = "Transformación Avanzada",
    Content = "Elimina todo el pelo/mochilas. Forzará el esqueleto manualmente y la cabeza será encogida para un ajuste perfecto."
})

local function TransformToAgonySkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hum or not head then return end

    -- 1. ELIMINAR PELO, MOCHILAS, SOMBREROS Y ROPA
    -- Destruimos cualquier objeto tipo Accessory (Mochilas, pelo, gorras) y ropa
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Destroy()
        end
    end

    -- 2. NUEVO MÉTODO PARA EL ESQUELETO (Más confiable)
    -- Primero pintamos el cuerpo de blanco
    local bodyColors = char:FindFirstChildWhichIsA("BodyColors")
    if bodyColors then
        local boneColor = BrickColor.new("Institutional white")
        bodyColors.HeadColor = boneColor
        bodyColors.TorsoColor = boneColor
        bodyColors.LeftArmColor = boneColor
        bodyColors.RightArmColor = boneColor
        bodyColors.LeftLegColor = boneColor
        bodyColors.RightLegColor = boneColor
    end

    -- Aplicamos las mallas oficiales del Esqueleto de Roblox dependiendo de tu tipo de avatar (R6 o R15)
    if hum.RigType == Enum.HumanoidRigType.R6 then
        -- Insertamos las mallas individuales del esqueleto para R6
        local skeletonMeshes = {
            {BodyPart = Enum.BodyPart.Torso, MeshId = "rbxassetid://36780113"},
            {BodyPart = Enum.BodyPart.LeftArm, MeshId = "rbxassetid://36780156"},
            {BodyPart = Enum.BodyPart.RightArm, MeshId = "rbxassetid://36780032"},
            {BodyPart = Enum.BodyPart.LeftLeg, MeshId = "rbxassetid://36780292"},
            {BodyPart = Enum.BodyPart.RightLeg, MeshId = "rbxassetid://36780224"}
        }
        for _, data in ipairs(skeletonMeshes) do
            local cm = Instance.new("CharacterMesh")
            cm.BodyPart = data.BodyPart
            cm.MeshId = data.MeshId
            cm.Parent = char
        end
    else
        -- Para R15, forzamos el Bundle oficial del Esqueleto (Bundle ID: 266)
        pcall(function()
            local skeletonDesc = Players:GetHumanoidDescriptionFromBundleId(266)
            hum:ApplyDescription(skeletonDesc)
            
            -- Volvemos a limpiar accesorios en caso de que el ApplyDescription los intente cargar de nuevo
            task.wait(0.5)
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    item:Destroy()
                end
            end
        end)
    end

    -- 3. CABEZA DE AGONY BOMB (Búsqueda en bombs.lua y Reducción de Tamaño)
    -- Buscamos en la ruta indicada en el script base: ReplicatedStorage.Assets.Bombs[span_1](start_span)[span_1](end_span)
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local bombsFolder = assets and assets:FindFirstChild("Bombs")
    local agonyBomb = bombsFolder and bombsFolder:FindFirstChild("Agony Bomb")

    if agonyBomb then
        local bombPart = agonyBomb:FindFirstChild("Handle") or agonyBomb:FindFirstChildWhichIsA("BasePart")
        
        if bombPart then
            -- Hacer cabeza original completamente invisible
            head.Transparency = 1
            if head:FindFirstChild("face") then head.face.Transparency = 1 end
            if head:FindFirstChild("Decal") then head.Decal.Transparency = 1 end

            -- Eliminar cabezas anteriores si tocas el botón múltiples veces
            local oldCustomHead = char:FindFirstChild("AgonyHead_Custom")
            if oldCustomHead then oldCustomHead:Destroy() end

            -- Clonamos la parte
            local customHead = bombPart:Clone()
            customHead.Name = "AgonyHead_Custom"
            
            -- ¡NUEVO!: ENCOGER LA BOMBA
            -- Reducimos el tamaño de la parte física a la mitad (50%)
            if customHead:IsA("BasePart") then
                customHead.Size = customHead.Size * 0.5 
            end
            
            -- Si la bomba usa una malla gráfica interna (SpecialMesh/Mesh), la escalamos a la mitad también
            local mesh = customHead:FindFirstChildWhichIsA("DataModelMesh")
            if mesh then
                mesh.Scale = mesh.Scale * 0.5
            end

            -- Configuramos y soldamos la cabeza encogida
            customHead.Parent = char
            customHead.CFrame = head.CFrame
            customHead.CanCollide = false
            customHead.Massless = true

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = head
            weld.Part1 = customHead
            weld.Parent = customHead
        else
            warn("La Agony Bomb existe, pero no tiene una parte física válida.")
        end
    else
        warn("No se pudo encontrar la Agony Bomb en el servidor.")
    end
end

SkeletonTab:CreateButton({
   Name = "💀 Transformar a Esqueleto Agony",
   Callback = function()
        TransformToAgonySkeleton()
        Rayfield:Notify({
            Title = "Mutación Completada", 
            Content = "Ropa eliminada. Cabeza de Agony encogida y soldada al esqueleto.", 
            Duration = 4
        })
   end,
})
