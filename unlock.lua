-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Fix Definitivo: Método Fantasma (0% Crash)",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local IsMorphed = false
local NPCTarget = nil

-- Carpeta segura para hologramas (se queda en Workspace para no tocar tu personaje)
local HologramFolder = Workspace:FindFirstChild("MorphHolograms_Local")
if not HologramFolder then
    HologramFolder = Instance.new("Folder")
    HologramFolder.Name = "MorphHolograms_Local"
    HologramFolder.Parent = Workspace
end

local CFrameRenderConnection = nil
local FakeAccessoriesList = {} 

local MorphTab = Window:CreateTab("Infiltración", 4483362458)
local StatusLabel = MorphTab:CreateLabel("Estado: Eres tú mismo.")

local StandardLimbs = {
    HumanoidRootPart=true, Head=true, UpperTorso=true, LowerTorso=true,
    LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
    Torso=true, ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true
}

-- ==========================================
-- SISTEMA FANTASMA (OCULTAR SIN DESTRUIR)
-- ==========================================

local function TogglePlayerOriginals(char, visible)
    for _, item in ipairs(char:GetDescendants()) do
        -- Ocultar accesorios volviéndolos transparentes
        if item:IsA("Accessory") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                if not visible then
                    handle:SetAttribute("OrigTrans", handle.Transparency)
                    handle.Transparency = 1
                elseif handle:GetAttribute("OrigTrans") then
                    handle.Transparency = handle:GetAttribute("OrigTrans")
                end
            end
        -- Ocultar ropa 2D vaciando la textura temporalmente
        elseif item:IsA("Shirt") and not string.match(item.Name, "FakeNPC_") then
            if not visible then
                item:SetAttribute("OrigTemp", item.ShirtTemplate)
                item.ShirtTemplate = ""
            elseif item:GetAttribute("OrigTemp") then
                item.ShirtTemplate = item:GetAttribute("OrigTemp")
            end
        elseif item:IsA("Pants") and not string.match(item.Name, "FakeNPC_") then
            if not visible then
                item:SetAttribute("OrigTemp", item.PantsTemplate)
                item.PantsTemplate = ""
            elseif item:GetAttribute("OrigTemp") then
                item.PantsTemplate = item:GetAttribute("OrigTemp")
            end
        elseif item:IsA("ShirtGraphic") and not string.match(item.Name, "FakeNPC_") then
            if not visible then
                item:SetAttribute("OrigTemp", item.Graphic)
                item.Graphic = ""
            elseif item:GetAttribute("OrigTemp") then
                item.Graphic = item:GetAttribute("OrigTemp")
            end
        -- Ocultar tu cara original
        elseif item:IsA("Decal") and item.Name == "face" then
            if not visible then
                item:SetAttribute("OrigTemp", item.Texture)
                item.Texture = ""
            elseif item:GetAttribute("OrigTemp") then
                item.Texture = item:GetAttribute("OrigTemp")
            end
        end
    end
    
    -- Mover los colores de cuerpo sin borrarlos
    local originalColors = char:FindFirstChild("OriginalBodyColors") or char:FindFirstChildOfClass("BodyColors")
    if originalColors then
        if not visible then
            originalColors.Name = "OriginalBodyColors"
            originalColors.Parent = HologramFolder 
        else
            originalColors.Parent = char
            originalColors.Name = "Body Colors"
        end
    end
end

local function ToggleNPCSafely(npc, visible)
    -- El secreto está aquí: NUNCA movemos al NPC, solo lo hacemos fantasma
    for _, obj in ipairs(npc:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            if not visible then
                if obj:IsA("BasePart") then
                    obj:SetAttribute("OrigTrans", obj.Transparency)
                    obj.Transparency = 1
                    obj:SetAttribute("OrigCollide", obj.CanCollide)
                    obj.CanCollide = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:SetAttribute("OrigTrans", obj.Transparency)
                    obj.Transparency = 1
                end
            else
                if obj:GetAttribute("OrigTrans") then
                    obj.Transparency = obj:GetAttribute("OrigTrans")
                end
                if obj:IsA("BasePart") and obj:GetAttribute("OrigCollide") ~= nil then
                    obj.CanCollide = obj:GetAttribute("OrigCollide")
                end
            end
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ProximityPrompt") then
            if not visible then
                obj:SetAttribute("OrigEnabled", obj.Enabled)
                obj.Enabled = false
            else
                if obj:GetAttribute("OrigEnabled") ~= nil then
                    obj.Enabled = obj:GetAttribute("OrigEnabled")
                end
            end
        end
    end
end

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char or not playerHead then return end

    HologramFolder:ClearAllChildren()
    FakeAccessoriesList = {}

    -- 1. Ocultar tu cuerpo sin romper el código de la cámara
    TogglePlayerOriginals(char, false)

    -- 2. Copiar texturas del NPC
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            local clone = item:Clone()
            clone.Name = "FakeNPC_" .. item.ClassName
            clone.Parent = char
        elseif item:IsA("BodyColors") then
            local clone = item:Clone()
            clone.Name = "FakeNPC_BodyColors"
            clone.Parent = char
        end
    end

    local npcHead = npc:FindFirstChild("Head")
    if npcHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                local clone = obj:Clone()
                clone.Name = "FakeNPC_Face"
                clone.Parent = playerHead
            end
        end
    end

    -- 3. Crear el Holograma de los accesorios en Workspace
    for _, item in ipairs(npc:GetDescendants()) do
        if item:IsA("BasePart") and not StandardLimbs[item.Name] then
            local fakeAccessory = item:Clone()
            fakeAccessory.Name = "Hologram_Decoration"
            fakeAccessory.Parent = HologramFolder
            
            fakeAccessory.Anchored = true 
            fakeAccessory.CanCollide = false
            fakeAccessory.Massless = true
            fakeAccessory.CanTouch = false
            fakeAccessory.CanQuery = false
            
            for _, desc in ipairs(fakeAccessory:GetDescendants()) do
                if desc:IsA("JointInstance") or desc:IsA("Constraint") or desc:IsA("BaseScript") or desc:IsA("BodyMover") then
                    desc:Destroy()
                elseif desc:IsA("BasePart") then
                    desc.Anchored = true
                    desc.CanCollide = false
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
            
            local offset = closestNpcLimb.CFrame:ToObjectSpace(item.CFrame)
            table.insert(FakeAccessoriesList, {
                Piece = fakeAccessory,
                TargetLimb = closestNpcLimb.Name,
                Offset = offset
            })
        end
    end

    -- 4. Bucle que ata el holograma a tus movimientos
    if CFrameRenderConnection then CFrameRenderConnection:Disconnect() end
    CFrameRenderConnection = RunService.RenderStepped:Connect(function()
        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        
        for _, data in ipairs(FakeAccessoriesList) do
            local playerLimb = currentChar:FindFirstChild(data.TargetLimb)
            if playerLimb and data.Piece then
                data.Piece.CFrame = playerLimb.CFrame * data.Offset
            end
        end
    end)
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    
    if CFrameRenderConnection then 
        CFrameRenderConnection:Disconnect() 
        CFrameRenderConnection = nil 
    end
    HologramFolder:ClearAllChildren()
    FakeAccessoriesList = {}

    if not char then return end

    -- Borrar las copias cosméticas
    for _, item in ipairs(char:GetChildren()) do
        if string.match(item.Name, "FakeNPC_") then item:Destroy() end
    end
    if playerHead then
        for _, item in ipairs(playerHead:GetChildren()) do
            if string.match(item.Name, "FakeNPC_") then item:Destroy() end
        end
    end

    -- Devolverte tu ropa original
    TogglePlayerOriginals(char, true)
end

-- ==========================================
-- UI DE RAYFIELD
-- ==========================================

MorphTab:CreateToggle({
   Name = "Activar Infiltración",
   CurrentValue = false,
   Flag = "MorphToggle",
   Callback = function(Value)
        IsMorphed = Value
        -- Usamos búsqueda recursiva para encontrarlo donde sea sin moverlo
        NPCTarget = Workspace:FindFirstChild("SellWorker", true) 
        
        if not NPCTarget then
            Rayfield:Notify({Title = "Error", Content = "No se encontró a SellWorker.", Duration = 4})
            return
        end

        if IsMorphed then
            MorphIntoNPC(NPCTarget)
            -- En lugar de moverlo al Lighting, lo hacemos invisible
            ToggleNPCSafely(NPCTarget, false) 
            
            StatusLabel:Set("Estado: Eres el vendedor.")
            Rayfield:Notify({Title = "¡Infiltrado!", Content = "Método Fantasma. Sistema de cámara estable.", Duration = 4})
        else
            ToggleNPCSafely(NPCTarget, true) 
            RestorePlayerAppearance()
            
            StatusLabel:Set("Estado: Eres tú mismo.")
            Rayfield:Notify({Title = "Restaurado", Content = "Avatar devuelto a la normalidad.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "⚠️ Resetear Avatar",
   Callback = function()
        if NPCTarget then ToggleNPCSafely(NPCTarget, true) end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

LocalPlayer.CharacterAdded:Connect(function()
    if CFrameRenderConnection then 
        CFrameRenderConnection:Disconnect()
        CFrameRenderConnection = nil
    end
    HologramFolder:ClearAllChildren()
    FakeAccessoriesList = {}
    if IsMorphed then 
        task.wait(1)
        Rayfield:Notify({Title = "Muerto", Content = "Transformación limpiada de emergencia.", Duration = 4}) 
    end
end)
