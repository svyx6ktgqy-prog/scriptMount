-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Modo SellWorker (Físicas Corregidas)",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Variables de Estado
local OriginalAppearanceFolder = nil
local IsMorphed = false
local NPCTarget = nil

-- Crear carpeta segura para guardar la ropa original del jugador
if not CoreGui:FindFirstChild("MyOriginalClothes") then
    OriginalAppearanceFolder = Instance.new("Folder")
    OriginalAppearanceFolder.Name = "MyOriginalClothes"
    OriginalAppearanceFolder.Parent = CoreGui
else
    OriginalAppearanceFolder = CoreGui.MyOriginalClothes
end

-- Pestaña del Menú
local MorphTab = Window:CreateTab("Infiltración", 4483362458)
local StatusLabel = MorphTab:CreateLabel("Estado: Eres tú mismo.")

-- ==========================================
-- FUNCIONES DE TRANSFORMACIÓN Y FÍSICAS
-- ==========================================

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not char or not hum then return end

    -- 1. Limpiar el almacenamiento anterior por si acaso
    OriginalAppearanceFolder:ClearAllChildren()

    -- 2. Guardar y quitar la apariencia original del jugador
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item.Parent = OriginalAppearanceFolder
        end
    end

    local playerHead = char:FindFirstChild("Head")
    if playerHead then
        -- Guardar cara y otras cosas de la cabeza original
        for _, obj in ipairs(playerHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") then
                obj.Parent = OriginalAppearanceFolder
            end
        end
    end

    -- 3. Copiar la ropa, accesorios y gorros antiguos del NPC
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
            
        elseif item:IsA("Accessory") or item:IsA("Hat") then
            local clonedAcc = item:Clone()
            
            -- FIX ANTI-VUELTAS DE CÁMARA: Desactivar colisiones y peso en las partes del accesorio
            for _, desc in ipairs(clonedAcc:GetDescendants()) do
                if desc:IsA("BasePart") then
                    desc.CanCollide = false
                    desc.Massless = true
                    desc.Anchored = false
                end
            end
            
            -- Forzar al Humanoide a equiparlo para que no se caiga
            if item:IsA("Accessory") then
                hum:AddAccessory(clonedAcc)
            else
                clonedAcc.Parent = char -- Para "Hat" antiguo
            end
        end
    end

    -- 4. Copiar profundamente la cabeza (Para atrapar el Ojo de Dinero, Caras, Carteles y Forma)
    local npcHead = npc:FindFirstChild("Head")
    if npcHead and playerHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
            -- Copiamos: Decals (Caras), Meshes (Forma base), GUI (Nombres/Carteles), y Efectos (Ojo de dinero)
            if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("Trail") then
                local clonedHeadItem = obj:Clone()
                clonedHeadItem.Parent = playerHead
            end
        end
    end
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Eliminar absolutamente todo lo falso (del NPC)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
    end

    local head = char:FindFirstChild("Head")
    if head then
        for _, obj in ipairs(head:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("Trail") then
                -- Omitir borrar la cara original de Roblox si se generó sola
                if obj.Name ~= "face" or (obj.Name == "face" and OriginalAppearanceFolder:FindFirstChild("face")) then
                    obj:Destroy()
                end
            end
        end
    end

    -- 2. Restaurar nuestra ropa original
    for _, item in ipairs(OriginalAppearanceFolder:GetChildren()) do
        item.Parent = head and (item:IsA("Decal") or item:IsA("SpecialMesh") or item:IsA("BillboardGui")) and head or char
    end
end

-- ==========================================
-- BOTONES DE INTERFAZ
-- ==========================================

MorphTab:CreateToggle({
   Name = "Activar Transformación (Robar Identidad)",
   CurrentValue = false,
   Flag = "MorphToggle",
   Callback = function(Value)
        IsMorphed = Value
        
        -- Buscar al NPC en la ruta proporcionada en tu reporte
        local thingsFolder = workspace:FindFirstChild("Things")
        if thingsFolder then
            NPCTarget = thingsFolder:FindFirstChild("SellWorker") or Lighting:FindFirstChild("SellWorker")
        end
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se pudo encontrar a SellWorker en el mapa.", Duration = 4})
            return
        end

        if IsMorphed then
            MorphIntoNPC(NPCTarget)
            
            -- Esconder al NPC real enviándolo al Lighting (Fuera del mapa)
            NPCTarget.Parent = Lighting
            
            StatusLabel:Set("Estado: Eres el vendedor. NPC real oculto.")
            Rayfield:Notify({Title = "Transformación Exitosa", Content = "Apariencia y accesorios copiados sin bugs.", Duration = 3})
        else
            -- Devolver al NPC a la tienda
            if thingsFolder then
                NPCTarget.Parent = thingsFolder
            end
            
            RestorePlayerAppearance()
            
            StatusLabel:Set("Estado: Eres tú mismo. NPC restaurado.")
            Rayfield:Notify({Title = "Identidad Restaurada", Content = "El vendedor ha vuelto a la tienda.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Forzar Restauración (Si hay un bug)",
   Callback = function()
        local thingsFolder = workspace:FindFirstChild("Things")
        local lostNPC = Lighting:FindFirstChild("SellWorker")
        if lostNPC and thingsFolder then
            lostNPC.Parent = thingsFolder
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
            Rayfield:Notify({Title = "Reiniciando", Content = "Tu personaje reaparecerá con tu ropa normal.", Duration = 3})
        end
   end,
})

-- Auto-desactivar si mueres
LocalPlayer.CharacterAdded:Connect(function()
    if IsMorphed then
        task.wait(1)
        Rayfield:Notify({Title = "Has Muerto", Content = "La transformación se ha anulado.", Duration = 4})
    end
end)
