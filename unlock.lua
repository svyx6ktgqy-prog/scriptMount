-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Anti-Spin & Force-Weld",
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

-- Crear carpeta segura para guardar tu apariencia
if not CoreGui:FindFirstChild("MyOriginalClothes") then
    OriginalAppearanceFolder = Instance.new("Folder")
    OriginalAppearanceFolder.Name = "MyOriginalClothes"
    OriginalAppearanceFolder.Parent = CoreGui
else
    OriginalAppearanceFolder = CoreGui.MyOriginalClothes
end

local MorphTab = Window:CreateTab("Infiltración", 4483362458)
local StatusLabel = MorphTab:CreateLabel("Estado: Eres tú mismo.")

-- ==========================================
-- FUNCIONES DE TRANSFORMACIÓN PERFECTA
-- ==========================================

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char or not playerHead then return end

    -- 1. Limpiar el almacenamiento anterior
    OriginalAppearanceFolder:ClearAllChildren()

    -- 2. Guardar y desequipar tu ropa y cara original
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item.Parent = OriginalAppearanceFolder
        end
    end
    for _, obj in ipairs(playerHead:GetChildren()) do
        if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") then
            obj.Parent = OriginalAppearanceFolder
        end
    end

    -- 3. Copiar la ropa básica del NPC
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
        end
    end

    -- 4. Copiar Cara, Ojos y Carteles (Gui) del NPC
    local npcHead = npc:FindFirstChild("Head")
    if npcHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") then
                obj:Clone().Parent = playerHead
            end
        end
    end

    -- 5. SISTEMA ANTI-SPIN Y SOLDADURA FORZADA PARA EL GORRO / ACCESORIOS
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") then
            local clone = item:Clone()
            local handle = clone:FindFirstChild("Handle")
            
            if handle then
                -- Quitar físicas que causan bugs
                handle.CanCollide = false
                handle.Massless = true
                handle.Anchored = false
                
                -- ELIMINAR EL WELD BUGUEADO (Solución al giro de cámara)
                for _, desc in ipairs(handle:GetDescendants()) do
                    if desc:IsA("JointInstance") or desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Motor6D") then
                        desc:Destroy()
                    end
                end

                clone.Parent = char

                -- SOLDADURA MANUAL MATEMÁTICA (Solución a que no agarra el gorro)
                local npcHandle = item:FindFirstChild("Handle")
                if npcHandle and npcHead then
                    -- Calculamos la posición del gorro en el NPC
                    local offset = npcHead.CFrame:ToObjectSpace(npcHandle.CFrame)
                    
                    -- Movemos el gorro clonado exactamente a esa posición en TU cabeza
                    handle.CFrame = playerHead.CFrame * offset
                    
                    -- Los pegamos con soldadura moderna de bloque
                    local manualWeld = Instance.new("WeldConstraint")
                    manualWeld.Part0 = playerHead
                    manualWeld.Part1 = handle
                    manualWeld.Parent = handle
                end
            end
        end
    end
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char then return end

    -- 1. Destruir absolutamente todo lo falso
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
    end
    if playerHead then
        for _, obj in ipairs(playerHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("SpecialMesh") or obj:IsA("BillboardGui") or obj:IsA("WeldConstraint") then
                obj:Destroy()
            end
        end
    end

    -- 2. Restaurar tu ropa original intacta
    for _, item in ipairs(OriginalAppearanceFolder:GetChildren()) do
        if item:IsA("Decal") or item:IsA("SpecialMesh") or item:IsA("BillboardGui") then
            if playerHead then item.Parent = playerHead end
        else
            item.Parent = char
        end
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
        
        local thingsFolder = workspace:FindFirstChild("Things")
        if thingsFolder then
            NPCTarget = thingsFolder:FindFirstChild("SellWorker") or Lighting:FindFirstChild("SellWorker")
        end
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se pudo encontrar a SellWorker.", Duration = 4})
            return
        end

        if IsMorphed then
            MorphIntoNPC(NPCTarget)
            NPCTarget.Parent = Lighting
            
            StatusLabel:Set("Estado: Eres el vendedor. NPC real oculto.")
            Rayfield:Notify({Title = "¡Infiltrado!", Content = "Gorro soldado y sin giros de cámara.", Duration = 3})
        else
            if thingsFolder then
                NPCTarget.Parent = thingsFolder
            end
            RestorePlayerAppearance()
            
            StatusLabel:Set("Estado: Eres tú mismo. NPC restaurado.")
            Rayfield:Notify({Title = "Restaurado", Content = "Todo a la normalidad.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Forzar Restauración (Si hay un bug)",
   Callback = function()
        local thingsFolder = workspace:FindFirstChild("Things")
        local lostNPC = Lighting:FindFirstChild("SellWorker")
        if lostNPC and thingsFolder then lostNPC.Parent = thingsFolder end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
            Rayfield:Notify({Title = "Reiniciando", Content = "Reaparecerás normal.", Duration = 3})
        end
   end,
})

-- Auto-desactivar al morir
LocalPlayer.CharacterAdded:Connect(function()
    if IsMorphed then
        task.wait(1)
        Rayfield:Notify({Title = "Has Muerto", Content = "El Morph se ha anulado.", Duration = 4})
    end
end)
