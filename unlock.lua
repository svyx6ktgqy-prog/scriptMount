-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Fix: Smart Welder & Dynamic Heads",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local OriginalAppearanceFolder = nil
local IsMorphed = false
local NPCTarget = nil

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
-- LISTA DE PARTES DEL CUERPO ESTÁNDAR
-- (Todo lo que no esté aquí, es un accesorio custom o decoración)
-- ==========================================
local StandardLimbs = {
    HumanoidRootPart=true, Head=true, UpperTorso=true, LowerTorso=true,
    LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
    CameraPart_DISABLED=true
}

-- ==========================================
-- FUNCIONES DE TRANSFORMACIÓN
-- ==========================================

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char or not playerHead then return end

    -- 1. Limpieza de tu avatar
    OriginalAppearanceFolder:ClearAllChildren()
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item.Parent = OriginalAppearanceFolder
        end
    end

    -- FORZAR EL BORRADO DE LA CABEZA DINÁMICA (Para que se vea la cara del NPC)
    local faceControls = playerHead:FindFirstChildOfClass("FaceControls")
    if faceControls then faceControls:Destroy() end

    for _, obj in ipairs(playerHead:GetChildren()) do
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("BillboardGui") then
            obj.Parent = OriginalAppearanceFolder
        end
    end

    -- 2. Copiar Ropa Base
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
        end
    end

    -- 3. Copiar Cara 2D y Letreros (SIN COPIAR SpecialMesh para evitar bugs de cámara)
    local npcHead = npc:FindFirstChild("Head")
    if npcHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
            -- Copiar ojos/bocas en formato Decal o Texture
            if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                obj:Clone().Parent = playerHead
            elseif obj:IsA("BillboardGui") then
                local cloneGui = obj:Clone()
                cloneGui.Name = "NPC_FakeGui"
                for _, guiElement in ipairs(cloneGui:GetDescendants()) do
                    if guiElement:IsA("GuiObject") then guiElement.Active = false end
                end
                cloneGui.Parent = playerHead
            end
        end
    end

    -- 4. SMART WELDER (Detectar y equipar decoraciones 3D custom, gorros, ojos, etc)
    for _, item in ipairs(npc:GetDescendants()) do
        if item:IsA("BasePart") and not StandardLimbs[item.Name] then
            -- ¡Encontramos una pieza 3D que es un accesorio!
            local fakeAccessory = item:Clone()
            fakeAccessory.Name = "FakeNPC_Decoration"
            
            -- Convertirla en fantasma absoluto para que tu cámara no colapse
            fakeAccessory.CanCollide = false
            fakeAccessory.Massless = true
            fakeAccessory.Anchored = false
            fakeAccessory.CanQuery = false
            fakeAccessory.CanTouch = false
            -- Resetear su peso matemático a cero (FIX DEFINITIVO DEL GIRO)
            fakeAccessory.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
            
            -- Limpiar basura del NPC original
            for _, desc in ipairs(fakeAccessory:GetDescendants()) do
                if desc:IsA("JointInstance") or desc:IsA("Constraint") or desc:IsA("Script") or desc:IsA("LocalScript") then
                    desc:Destroy()
                end
            end
            
            -- MATEMÁTICA: Buscar la extremidad más cercana en el NPC
            local closestNpcLimb = npcHead
            local minDistance = math.huge
            
            for limbName, _ in pairs(StandardLimbs) do
                local npcLimb = npc:FindFirstChild(limbName)
                if npcLimb and npcLimb:IsA("BasePart") then
                    local dist = (npcLimb.Position - item.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestNpcLimb = npcLimb
                    end
                end
            end
            
            -- MATEMÁTICA: Calcular la distancia exacta y replicarla en tu cuerpo
            local playerLimb = char:FindFirstChild(closestNpcLimb.Name)
            if playerLimb then
                fakeAccessory.Parent = char
                local offset = closestNpcLimb.CFrame:ToObjectSpace(item.CFrame)
                fakeAccessory.CFrame = playerLimb.CFrame * offset
                
                -- Soldadura industrial moderna
                local manualWeld = Instance.new("WeldConstraint")
                manualWeld.Part0 = playerLimb
                manualWeld.Part1 = fakeAccessory
                manualWeld.Parent = fakeAccessory
            end
        end
    end
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char then return end

    -- Borrar disfraces
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") or item.Name == "FakeNPC_Decoration" then
            item:Destroy()
        end
    end
    
    if playerHead then
        for _, obj in ipairs(playerHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj.Name == "NPC_FakeGui" or obj:IsA("WeldConstraint") then
                obj:Destroy()
            end
        end
    end

    -- Restaurar tus ropas
    for _, item in ipairs(OriginalAppearanceFolder:GetChildren()) do
        if item:IsA("Decal") or item:IsA("Texture") or item:IsA("BillboardGui") then
            if playerHead then item.Parent = playerHead end
        else
            item.Parent = char
        end
    end
end

-- ==========================================
-- UI DE RAYFIELD
-- ==========================================

MorphTab:CreateToggle({
   Name = "Activar Transformación (Identidad Absoluta)",
   CurrentValue = false,
   Flag = "MorphToggle",
   Callback = function(Value)
        IsMorphed = Value
        local thingsFolder = workspace:FindFirstChild("Things")
        if thingsFolder then NPCTarget = thingsFolder:FindFirstChild("SellWorker") or Lighting:FindFirstChild("SellWorker") end
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se encontró a SellWorker.", Duration = 4})
            return
        end

        if IsMorphed then
            MorphIntoNPC(NPCTarget)
            NPCTarget.Parent = Lighting
            StatusLabel:Set("Estado: Eres el vendedor.")
            Rayfield:Notify({Title = "¡Infiltrado!", Content = "Decoraciones y cara copiadas. Cámara estable.", Duration = 3})
        else
            if thingsFolder then NPCTarget.Parent = thingsFolder end
            RestorePlayerAppearance()
            StatusLabel:Set("Estado: Eres tú mismo.")
            Rayfield:Notify({Title = "Restaurado", Content = "Disfraz quitado.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Resetear Avatar",
   Callback = function()
        local lostNPC = Lighting:FindFirstChild("SellWorker")
        if lostNPC and workspace:FindFirstChild("Things") then lostNPC.Parent = workspace.Things end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

LocalPlayer.CharacterAdded:Connect(function()
    if IsMorphed then task.wait(1); Rayfield:Notify({Title = "Muerto", Content = "Morph anulado.", Duration = 4}) end
end)
