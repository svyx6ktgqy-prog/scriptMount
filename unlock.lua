-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Fix: Smart Welder & Cámara Silenciosa",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local OriginalAppearanceFolder = nil
local IsMorphed = false
local NPCTarget = nil

-- Carpeta para guardar la apariencia original
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
-- SISTEMA ANTI-BUG DE CÁMARA (MODO SILENCIOSO)
-- ==========================================
local function ToggleSilentMode(enabled)
    if enabled then
        -- BLOQUEO DE CÁMARA (Para evitar el giro infinito mientras cargamos)
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        -- DEVOLVER CONTROL Y RESETEAR OFFSET
        Camera.CameraType = Enum.CameraType.Custom
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            Camera.CameraSubject = humanoid
            -- FIX DEFINITIVO DE SENSIBILIDAD: Asegurar que el NPC no nos herede un offset raro
            humanoid.CameraOffset = Vector3.new(0, 0, 0)
        end
    end
end

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

    -- FORZAR EL BORRADO DE LA CABEZA DINÁMICA
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

    -- 3. Copiar Cara 2D y Letreros
    local npcHead = npc:FindFirstChild("Head")
    if npcHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
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

    -- 4. SMART WELDER (Decoraciones 3D custom)
    for _, item in ipairs(npc:GetDescendants()) do
        if item:IsA("BasePart") and not StandardLimbs[item.Name] then
            local fakeAccessory = item:Clone()
            fakeAccessory.Name = "FakeNPC_Decoration"
            
            fakeAccessory.CanCollide = false
            fakeAccessory.Massless = true
            fakeAccessory.Anchored = false
            fakeAccessory.CanQuery = false
            fakeAccessory.CanTouch = false
            -- Resetear su peso matemático
            fakeAccessory.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
            
            -- Limpiar basura del NPC
            for _, desc in ipairs(fakeAccessory:GetDescendants()) do
                if desc:IsA("JointInstance") or desc:IsA("Constraint") or desc:IsA("Script") or desc:IsA("LocalScript") then
                    desc:Destroy()
                end
            end
            
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
            
            local playerLimb = char:FindFirstChild(closestNpcLimb.Name)
            if playerLimb then
                fakeAccessory.Parent = char
                local offset = closestNpcLimb.CFrame:ToObjectSpace(item.CFrame)
                fakeAccessory.CFrame = playerLimb.CFrame * offset
                
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
        local thingsFolder = Workspace:FindFirstChild("Things")
        if thingsFolder then NPCTarget = thingsFolder:FindFirstChild("SellWorker") or Lighting:FindFirstChild("SellWorker") end
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se encontró a SellWorker.", Duration = 4})
            return
        end

        if IsMorphed then
            -- 1. Iniciamos el Cambio Mudo
            ToggleSilentMode(true) 
            
            -- 2. Ejecutamos el cambio de piezas
            MorphIntoNPC(NPCTarget)
            NPCTarget.Parent = Lighting
            
            -- 3. Pausa mínima para que el motor asimile el cambio
            task.wait(0.2) 
            
            -- 4. Devolvemos el control (con Fix de Sensibilidad)
            ToggleSilentMode(false) 
            
            StatusLabel:Set("Estado: Eres el vendedor.")
            Rayfield:Notify({Title = "¡Infiltrado!", Content = "Cámara estable. Morph exitoso.", Duration = 3})
        else
            -- 1. Cambio Mudo para la restauración
            ToggleSilentMode(true)
            
            if thingsFolder then NPCTarget.Parent = thingsFolder end
            RestorePlayerAppearance()
            
            -- 3. Pausa para restaurar
            task.wait(0.2)
            
            -- 4. Devolvemos control de cámara
            ToggleSilentMode(false)
            
            StatusLabel:Set("Estado: Eres tú mismo.")
            Rayfield:Notify({Title = "Restaurado", Content = "Disfraz quitado.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Resetear Avatar",
   Callback = function()
        local lostNPC = Lighting:FindFirstChild("SellWorker")
        if lostNPC and Workspace:FindFirstChild("Things") then lostNPC.Parent = Workspace.Things end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

LocalPlayer.CharacterAdded:Connect(function()
    if IsMorphed then task.wait(1); Rayfield:Notify({Title = "Muerto", Content = "Morph anulado.", Duration = 4}) end
end)
