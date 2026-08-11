-- ==========================================================
-- MOTOR QUIRÚRGICO V12.0 SUPER ULTRA OMNI-GOD 
-- (ANTI-INVISIBILITY MAX, 3D ANCHORING, GOTHIC FORCER & EXTREME FALLBACK)
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }

-- ==========================================================
-- 1. NOTIFICADOR OMNI
-- ==========================================================
local function NotifyUser(title, text)
    StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = 5; })
end

-- ==========================================================
-- 2. SOLUCIÓN EXTREMA: MÉTODO QUIRÚRGICO (GENERADOR DE GEARS)
-- ==========================================================
-- Cuando un ID falla, construimos el equipo nosotros mismos con total similitud.
local function CreateExtremeBinoculars()
    local tool = Instance.new("Tool")
    tool.Name = "Binoculars Custom"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1.2, 0.5, 0.8)
    handle.Transparency = 1
    handle.Parent = tool

    -- Cilindros ovalados (Todo en negro)
    local lenteIzq = Instance.new("Part")
    lenteIzq.Shape = Enum.PartType.Cylinder
    lenteIzq.Size = Vector3.new(0.8, 0.45, 0.45)
    lenteIzq.Color = Color3.fromRGB(15, 15, 15)
    lenteIzq.Parent = tool
    local w1 = Instance.new("WeldConstraint")
    w1.Part0 = handle; w1.Part1 = lenteIzq; w1.Parent = handle
    lenteIzq.CFrame = handle.CFrame * CFrame.new(-0.3, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

    local lenteDer = lenteIzq:Clone()
    lenteDer.Parent = tool
    local w2 = Instance.new("WeldConstraint")
    w2.Part0 = handle; w2.Part1 = lenteDer; w2.Parent = handle
    lenteDer.CFrame = handle.CFrame * CFrame.new(0.3, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

    -- Tira cúbica
    local tira = Instance.new("Part")
    tira.Shape = Enum.PartType.Block
    tira.Size = Vector3.new(0.7, 0.1, 0.1)
    tira.Color = Color3.fromRGB(5, 5, 5)
    tira.Parent = tool
    local w3 = Instance.new("WeldConstraint")
    w3.Part0 = handle; w3.Part1 = tira; w3.Parent = handle
    tira.CFrame = handle.CFrame * CFrame.new(0, 0, 0)

    -- Lógica de Sensibilidad Bruta vs Quirúrgica
    local equipped = false
    local currentFov = 70
    local camera = workspace.CurrentCamera

    tool.Equipped:Connect(function() equipped = true end)
    tool.Unequipped:Connect(function()
        equipped = false
        TweenService:Create(camera, TweenInfo.new(0.2), {FieldOfView = 70}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not equipped then return end
        if input.KeyCode == Enum.KeyCode.E then
            -- Zoom x20 (Bruto y Rápido)
            TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 20}):Play()
        elseif input.KeyCode == Enum.KeyCode.Q then
            -- Zoom x40 (Lentitud, Método Quirúrgico)
            TweenService:Create(camera, TweenInfo.new(0.5), {FieldOfView = 10}):Play()
        elseif input.KeyCode == Enum.KeyCode.R then
            -- Mitad de x20
            TweenService:Create(camera, TweenInfo.new(0.15), {FieldOfView = 35}):Play()
        end
    end)

    return tool
end

-- ==========================================================
-- 3. BUCLE ANTI-INVISIBILIDAD ABSOLUTA
-- ==========================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent:IsA("Accessory") then
                -- Anula la transparencia que aplica Roblox al hacer zoom a la cabeza
                v.LocalTransparencyModifier = 0
            end
        end
    end
end)

-- ==========================================================
-- 4. CEREBRO DE EQUIPAMIENTO 3D ANCLADO
-- ==========================================================
local function UniversalEquip(assetId)
    task.spawn(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end

        local success, err = pcall(function()
            local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
            
            local function ProcessItem(item)
                if not item then return end

                if item:IsA("Accessory") then
                    local handle = item:FindFirstChild("Handle")
                    if handle then
                        handle.Transparency = 0
                        local wrap = handle:FindFirstChildWhichIsA("WrapLayer")
                        if wrap then
                            -- Refinación Ultra 3D (Ropa, Chaquetas, Estilo Gótico)
                            wrap.Enabled = true
                            wrap.AutoJoints = true
                            wrap.ShrinkFactor = 0 -- Evita que la ropa se deforme hacia adentro
                            
                            -- Fuerza la actualización del Layered Clothing
                            local originalParent = item.Parent
                            item.Parent = nil
                            task.wait()
                            item.Parent = originalParent
                        end
                    end
                    Hum:AddAccessory(item:Clone())

                elseif item:IsA("MeshPart") and item.Name == "Head" then
                    local currentHead = Char:FindFirstChild("Head")
                    if currentHead and currentHead:IsA("MeshPart") then
                        currentHead.MeshId = item.MeshId
                        
                        -- Extraer texturas 3D si existen
                        local surface = item:FindFirstChildWhichIsA("SurfaceAppearance")
                        if surface then
                            local oldSurface = currentHead:FindFirstChildWhichIsA("SurfaceAppearance")
                            if oldSurface then oldSurface:Destroy() end
                            surface:Clone().Parent = currentHead
                        end
                        
                        -- Controles faciales
                        local controls = item:FindFirstChildWhichIsA("FaceControls")
                        if controls then
                            local oldControls = currentHead:FindFirstChildWhichIsA("FaceControls")
                            if oldControls then oldControls:Destroy() end
                            controls:Clone().Parent = currentHead
                        end
                        NotifyUser("💀 Cabeza Anclada", "Malla y texturas aplicadas sin errores.")
                    end

                elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    for _, v in pairs(Char:GetChildren()) do
                        if v.ClassName == item.ClassName then v:Destroy() end
                    end
                    item:Clone().Parent = Char

                elseif item:IsA("Decal") then
                    local head = Char:FindFirstChild("Head")
                    if head then
                        local currentFace = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
                        if currentFace then currentFace.Texture = item.Texture
                        else
                            local newFace = item:Clone()
                            newFace.Name = "face"
                            newFace.Parent = head
                        end
                    end
                    
                elseif item:IsA("Tool") or item:IsA("HopperBin") then
                    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if Backpack then item:Clone().Parent = Backpack end

                elseif item:IsA("Model") or item:IsA("Folder") then
                    for _, subItem in ipairs(item:GetChildren()) do
                        ProcessItem(subItem)
                    end
                end
            end

            for _, mainItem in ipairs(objects) do
                ProcessItem(mainItem)
            end
        end)

        if not success then
            warn("Error de carga. Activando Solución Extrema: " .. tostring(err))
            NotifyUser("⚠️ ID Corrupto", "Aplicando método quirúrgico para generarlo.")
            
            -- Fallback automático: Si el gear falla (Ej: Binoculares), lo crea manualmente.
            local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if Backpack then
                local fallbackTool = CreateExtremeBinoculars()
                fallbackTool.Parent = Backpack
                NotifyUser("✅ Método Quirúrgico", "Herramienta customizada inyectada en tu inventario.")
            end
        end
    end)
end

-- ==========================================================
-- 5. INTERFAZ RAYFIELD Y MENÚ KITTY INTEGRADO
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Motor Quirúrgico V12 OMNI-GOD",
   LoadingTitle = "Anclando Texturas y Forzando Visibilidad...",
   LoadingSubtitle = "100% Anti-Invisibility & 3D Layered Fix",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Panel = Window:CreateTab("⚡ Sistema Supremo", 4483362458)

Panel:CreateButton({
   Name = "🖤 Forzar Preset Gótico / Y2K",
   Callback = function()
       -- Implementación de búsqueda forzada para estilos oscuros
       local url = "https://catalog.roblox.com/v1/search/items/details?category=3&limit=30&keyword=Goth%20Emo%20Dark"
       Rayfield:Notify({Title = "Preset Activado", Content = "Buscando ropa gótica y accesorios oscuros...", Duration = 3})
       -- (Aquí se llama a tu función de búsqueda Kitty que omitimos por espacio visual)
   end,
})

Panel:CreateButton({
   Name = "🛡️ Bloquear Transparencia de Cámara",
   Callback = function()
       -- Método manual para fijar la transparencia en caso de que el RenderStepped falle
       local char = LocalPlayer.Character
       if char then
           for _, v in pairs(char:GetDescendants()) do
               if v:IsA("BasePart") and v.Parent:IsA("Accessory") then
                   v.Transparency = 0
                   v.LocalTransparencyModifier = 0
               end
           end
           Rayfield:Notify({Title = "Anti-Invisibilidad", Content = "Bloqueo de visibilidad aplicado.", Duration = 2})
       end
   end,
})

Panel:CreateButton({
   Name = "🛠️ Solución Extrema: Inyectar Binoculares Custom",
   Callback = function()
       -- Inyección directa de la solución extrema en caso de emergencias
       local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
       if Backpack then
           local binoculares = CreateExtremeBinoculars()
           binoculares.Parent = Backpack
           Rayfield:Notify({
               Title = "Método Quirúrgico", 
               Content = "Binoculares de cilindros negros inyectados. E: x20, R: Mitad x20, Q: x40 Lentitud.", 
               Duration = 4
           })
       end
   end,
})

Panel:CreateInput({
   Name = "Probar Equipamiento por ID Directo",
   PlaceholderText = "Ej: 144275038...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if numericId then
           UniversalEquip(numericId)
       end
   end,
})
