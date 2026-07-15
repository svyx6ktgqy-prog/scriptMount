-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Sistema Holograma (0% Riesgo de Fling)",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local OriginalAppearanceFolder = nil
local IsMorphed = false
local NPCTarget = nil

-- Variables del Sistema Holograma
local HologramFolder = Workspace:FindFirstChild("MorphHolograms_Local")
if not HologramFolder then
    HologramFolder = Instance.new("Folder")
    HologramFolder.Name = "MorphHolograms_Local"
    HologramFolder.Parent = Workspace
end

local CFrameRenderConnection = nil
local FakeAccessoriesList = {} 

if not CoreGui:FindFirstChild("MyOriginalClothes") then
    OriginalAppearanceFolder = Instance.new("Folder")
    OriginalAppearanceFolder.Name = "MyOriginalClothes"
    OriginalAppearanceFolder.Parent = CoreGui
else
    OriginalAppearanceFolder = CoreGui.MyOriginalClothes
end

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
-- FUNCIONES DE TRANSFORMACIÓN
-- ==========================================

local function MorphIntoNPC(npc)
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    if not char or not playerHead then return end

    -- 1. Limpieza de tu avatar
    OriginalAppearanceFolder:ClearAllChildren()
    HologramFolder:ClearAllChildren()
    FakeAccessoriesList = {}
    
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item.Parent = OriginalAppearanceFolder
        end
    end

    local faceControls = playerHead:FindFirstChildOfClass("FaceControls")
    if faceControls then faceControls:Destroy() end

    for _, obj in ipairs(playerHead:GetChildren()) do
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("BillboardGui") then
            obj.Parent = OriginalAppearanceFolder
        end
    end

    -- 2. Copiar Ropa 2D y Texturas (Esto NO afecta colisiones)
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
        end
    end

    local npcHead = npc:FindFirstChild("Head")
    if npcHead then
        for _, obj in ipairs(npcHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                obj:Clone().Parent = playerHead
            end
        end
    end

    -- 3. MÉTODO HOLOGRAMA (El Fix Definitivo para el Giro)
    for _, item in ipairs(npc:GetDescendants()) do
        if item:IsA("BasePart") and not StandardLimbs[item.Name] then
            local fakeAccessory = item:Clone()
            fakeAccessory.Name = "Hologram_Decoration"
            
            -- ¡CRÍTICO! Enviamos la pieza al Workspace, LEJOS de tu personaje.
            fakeAccessory.Parent = HologramFolder
            
            -- Congelamos y neutralizamos la pieza principal
            fakeAccessory.Anchored = true 
            fakeAccessory.CanCollide = false
            fakeAccessory.Massless = true
            fakeAccessory.CanTouch = false
            fakeAccessory.CanQuery = false
            
            -- Limpiamos cualquier script o física residual que traiga el clon
            for _, desc in ipairs(fakeAccessory:GetDescendants()) do
                if desc:IsA("JointInstance") or desc:IsA("Constraint") or desc:IsA("BaseScript") or desc:IsA("BodyMover") then
                    desc:Destroy()
                elseif desc:IsA("BasePart") then
                    desc.Anchored = true
                    desc.CanCollide = false
                    desc.Massless = true
                end
            end
            
            -- Calcular a qué extremidad pertenece
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
            
            -- Guardamos el offset matemático en lugar de crear uniones físicas
            local offset = closestNpcLimb.CFrame:ToObjectSpace(item.CFrame)
            table.insert(FakeAccessoriesList, {
                Piece = fakeAccessory,
                TargetLimb = closestNpcLimb.Name,
                Offset = offset
            })
        end
    end

    -- 4. BUCLE DE RENDERIZADO VISUAL
    if CFrameRenderConnection then CFrameRenderConnection:Disconnect() end
    CFrameRenderConnection = RunService.RenderStepped:Connect(function()
        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        
        for _, data in ipairs(FakeAccessoriesList) do
            local playerLimb = currentChar:FindFirstChild(data.TargetLimb)
            if playerLimb and data.Piece then
                -- Actualizamos la posición de la pieza fantasma cada frame
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

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
    end
    
    if playerHead then
        for _, obj in ipairs(playerHead:GetChildren()) do
            if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
    end

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
   Name = "Activar Transformación (Holograma 100% Seguro)",
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
            MorphIntoNPC(NPCTarget)
            NPCTarget.Parent = Lighting
            StatusLabel:Set("Estado: Eres el vendedor.")
            Rayfield:Notify({Title = "¡Éxito!", Content = "Accesorios renderizados externamente. Físicas intactas.", Duration = 4})
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
        if lostNPC and Workspace:FindFirstChild("Things") then lostNPC.Parent = Workspace.Things end
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
        Rayfield:Notify({Title = "Muerto", Content = "Sistema Holograma apagado.", Duration = 4}) 
    end
end)
