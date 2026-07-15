-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía | Morph NPC 🕵️‍♂️",
   LoadingTitle = "Cargando Infiltración...",
   LoadingSubtitle = "Bypass Absoluto: No-Weld CFrame",
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
local Camera = Workspace.CurrentCamera
local OriginalAppearanceFolder = nil
local IsMorphed = false
local NPCTarget = nil

-- Variables para el Bypass CFrame
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

    -- 2. Copiar Ropa Base
    for _, item in ipairs(npc:GetChildren()) do
        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
        end
    end

    -- 3. Copiar Cara 2D
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

    -- 4. MÉTODO NO-WELD (El fin del giro infinito)
    FakeAccessoriesList = {} -- Reiniciamos la tabla
    
    for _, item in ipairs(npc:GetDescendants()) do
        if item:IsA("BasePart") and not StandardLimbs[item.Name] then
            local fakeAccessory = item:Clone()
            fakeAccessory.Name = "FakeNPC_Decoration"
            
            for _, child in ipairs(fakeAccessory:GetChildren()) do
                if child:IsA("BasePart") then child:Destroy() end
            end
            
            -- PROPIEDADES CLAVE: Anclado y sin colisión.
            fakeAccessory.Anchored = true -- ¡IMPORTANTE! Al estar anclado, las físicas no lo tocan.
            fakeAccessory.CanCollide = false
            fakeAccessory.Massless = true
            fakeAccessory.CanTouch = false
            fakeAccessory.CanQuery = false
            
            for _, desc in ipairs(fakeAccessory:GetDescendants()) do
                if desc:IsA("JointInstance") or desc:IsA("Constraint") or desc:IsA("Script") or desc:IsA("LocalScript") then
                    desc:Destroy()
                end
            end
            
            -- Buscar extremidad objetivo
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
                -- No usamos soldaduras. Guardamos el cálculo matemático en la tabla.
                local offset = closestNpcLimb.CFrame:ToObjectSpace(item.CFrame)
                fakeAccessory.Parent = char
                
                table.insert(FakeAccessoriesList, {
                    Clone = fakeAccessory,
                    Limb = playerLimb,
                    Offset = offset
                })
            end
        end
    end

    -- Iniciar bucle visual para mover las piezas (RenderStepped para máxima fluidez de cámara)
    if CFrameRenderConnection then CFrameRenderConnection:Disconnect() end
    CFrameRenderConnection = RunService.RenderStepped:Connect(function()
        for _, data in ipairs(FakeAccessoriesList) do
            if data.Clone and data.Limb then
                -- Pegamos la pieza matemáticamente cada milisegundo
                data.Clone.CFrame = data.Limb.CFrame * data.Offset
            end
        end
    end)
end

local function RestorePlayerAppearance()
    local char = LocalPlayer.Character
    local playerHead = char and char:FindFirstChild("Head")
    
    -- Apagar bucle visual
    if CFrameRenderConnection then 
        CFrameRenderConnection:Disconnect() 
        CFrameRenderConnection = nil 
    end
    FakeAccessoriesList = {}

    if not char then return end

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
            MorphIntoNPC(NPCTarget)
            NPCTarget.Parent = Lighting
            StatusLabel:Set("Estado: Eres el vendedor.")
            Rayfield:Notify({Title = "¡Infiltrado!", Content = "Bypass CFrame activado. Física intacta.", Duration = 3})
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

-- Limpieza si el jugador muere
LocalPlayer.CharacterAdded:Connect(function()
    if CFrameRenderConnection then 
        CFrameRenderConnection:Disconnect()
        CFrameRenderConnection = nil
    end
    FakeAccessoriesList = {}
    if IsMorphed then 
        task.wait(1)
        Rayfield:Notify({Title = "Muerto", Content = "Morph anulado y sistema CFrame limpio.", Duration = 4}) 
    end
end)
