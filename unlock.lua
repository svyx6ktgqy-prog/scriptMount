-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Modo SellWorker",
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
-- FUNCIONES DE TRANSFORMACIÓN
-- ==========================================

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Limpiar el almacenamiento anterior por si acaso
    OriginalAppearanceFolder:ClearAllChildren()

    -- 2. Guardar y ocultar la apariencia original del jugador
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item.Parent = OriginalAppearanceFolder
        end
    end

    -- Guardar la cara original
    local head = char:FindFirstChild("Head")
    if head then
        local originalFace = head:FindFirstChildOfClass("Decal")
        if originalFace then
            originalFace.Parent = OriginalAppearanceFolder
        end
    end

    -- 3. Copiar la apariencia del NPC al jugador
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
            item:Clone().Parent = char
        end
    end

    -- Copiar la cara y el cartel flotante (BillboardGui) del NPC
    local npcHead = npc:FindFirstChild("Head")
    if npcHead and head then
        local npcFace = npcHead:FindFirstChildOfClass("Decal")
        if npcFace then
            npcFace:Clone().Parent = head
        end
        
        -- Copiar el nombre flotante
        local npcGui = npcHead:FindFirstChild("gui")
        if npcGui then
            local clonedGui = npcGui:Clone()
            clonedGui.Name = "NPC_FakeGui"
            clonedGui.Parent = head
        end
    end
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Eliminar la ropa falsa (del NPC)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
    end

    local head = char:FindFirstChild("Head")
    if head then
        local fakeFace = head:FindFirstChildOfClass("Decal")
        if fakeFace then fakeFace:Destroy() end
        
        local fakeGui = head:FindFirstChild("NPC_FakeGui")
        if fakeGui then fakeGui:Destroy() end
    end

    -- 2. Restaurar la ropa original
    for _, item in ipairs(OriginalAppearanceFolder:GetChildren()) do
        item.Parent = char
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
            -- Intentar encontrarlo en workspace o si ya lo escondimos en Lighting
            NPCTarget = thingsFolder:FindFirstChild("SellWorker") or Lighting:FindFirstChild("SellWorker")
        end
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se pudo encontrar a SellWorker en el mapa.", Duration = 4})
            return
        end

        if IsMorphed then
            -- Convertirnos en el NPC
            MorphIntoNPC(NPCTarget)
            
            -- Esconder al NPC real enviándolo al Lighting (Fuera del mapa)
            NPCTarget.Parent = Lighting
            
            StatusLabel:Set("Estado: Eres el vendedor. NPC real oculto.")
            Rayfield:Notify({Title = "Transformación Exitosa", Content = "Has tomado el lugar del vendedor.", Duration = 3})
        else
            -- Devolver al NPC a la tienda
            if thingsFolder then
                NPCTarget.Parent = thingsFolder
            end
            
            -- Recuperar nuestro avatar
            RestorePlayerAppearance()
            
            StatusLabel:Set("Estado: Eres tú mismo. NPC restaurado.")
            Rayfield:Notify({Title = "Identidad Restaurada", Content = "El vendedor ha vuelto a la tienda.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Forzar Restauración (Si hay un bug)",
   Callback = function()
        -- Por si mueres o algo se bugea, este botón devuelve todo a la normalidad
        local thingsFolder = workspace:FindFirstChild("Things")
        local lostNPC = Lighting:FindFirstChild("SellWorker")
        if lostNPC and thingsFolder then
            lostNPC.Parent = thingsFolder
        end
        
        -- Reiniciar el personaje matándolo para cargar el avatar original de Roblox
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
            Rayfield:Notify({Title = "Reiniciando", Content = "Tu personaje reaparecerá con tu ropa normal.", Duration = 3})
        end
   end,
})

-- Si el jugador muere mientras está transformado, desactivar el sistema automáticamente para evitar bugs visuales
LocalPlayer.CharacterAdded:Connect(function()
    if IsMorphed then
        -- Esperar a que la ventana de Rayfield procese el apagado del toggle
        task.wait(1)
        Rayfield:Notify({Title = "Has Muerto", Content = "La transformación se ha anulado. Vuelve a activarla si lo deseas.", Duration = 4})
    end
end)
