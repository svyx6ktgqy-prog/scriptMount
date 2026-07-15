local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía Pro | Clonación Natural V4",
   LoadingTitle = "Iniciando Sincronización...",
   LoadingSubtitle = "Sistema Multiclón y Fix de Raíz",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Dummy = nil
local IsActive = false
local Connection = nil
local AnimConnection = nil
local LoadedAnimations = {} 
local AnimationOverrides = {} 

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

-- =========================================================
-- 🔍 BUSCADOR INTELIGENTE DE NPCs
-- =========================================================
local function FindNPC(name)
    if name == "ProClimber" then
        local things = workspace:FindFirstChild("Things")
        if things then
            local npc = things:FindFirstChild("ProClimber")
            if npc then return npc end
        end
        return workspace:FindFirstChild("ProClimber", true)
    elseif name == "Seller" then
        local npc = workspace:FindFirstChild("Seller", true)
        if not npc then
            npc = workspace:FindFirstChild("SellWorker", true)
        end
        return npc
    end
    return nil
end

-- =========================================================
-- 📂 MAPEO Y BYPASS DE ANIMACIONES ORIGINALES
-- =========================================================
local function MapNpcAnimations(MyChar, NpcChar)
    AnimationOverrides = {}
    local myAnimate = MyChar:FindFirstChild("Animate")
    local npcAnimate = NpcChar:FindFirstChild("Animate")
    
    if myAnimate and npcAnimate then
        for _, stateFolder in ipairs(myAnimate:GetChildren()) do
            local npcStateFolder = npcAnimate:FindFirstChild(stateFolder.Name)
            
            if npcStateFolder then
                for _, myAnim in ipairs(stateFolder:GetChildren()) do
                    if myAnim:IsA("Animation") then
                        local npcAnim = npcStateFolder:FindFirstChild(myAnim.Name)
                        if npcAnim and npcAnim:IsA("Animation") and npcAnim.AnimationId ~= "" then
                            AnimationOverrides[myAnim.AnimationId] = npcAnim.AnimationId
                        end
                    end
                end
            end
        end
    end
end

-- =========================================================
-- 🔄 LÓGICA DE CLONACIÓN CORREGIDA
-- =========================================================
local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    
    IsActive = true
    MapNpcAnimations(LocalPlayer.Character, TargetNPC)
    
    -- [NUEVO FIX] Asegurar que el NPC permita ser clonado
    local oldArchivable = TargetNPC.Archivable
    TargetNPC.Archivable = true
    Dummy = TargetNPC:Clone()
    TargetNPC.Archivable = oldArchivable
    
    if not Dummy then return end
    Dummy.Name = "ClonControl"
    
    -- [NUEVO FIX] Si no tiene HumanoidRootPart (Como ProClimber), usa su LowerTorso
    local DummyRoot = Dummy:FindFirstChild("HumanoidRootPart") or Dummy:FindFirstChild("LowerTorso") or Dummy:FindFirstChild("Torso")
    
    local DummyHum = Dummy:FindFirstChildOfClass("Humanoid")
    if DummyHum then
        DummyHum.RequiresNeck = false 
        DummyHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        if not DummyHum:FindFirstChildOfClass("Animator") then
            local Animator = Instance.new("Animator")
            Animator.Parent = DummyHum
        end
    end
    
    local DummyParts = {}
    local DummyOriginalJoints = {}
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("Motor6D") then
            DummyOriginalJoints[obj] = {C0 = obj.C0, C1 = obj.C1}
        end
    end
    
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            table.insert(DummyParts, obj) 
            
            -- Desanclar todo primero
            obj.Anchored = false
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("BodyMover") then
            obj:Destroy()
        end
    end
    
    -- [NUEVO FIX] Anclar únicamente la raíz que hayamos encontrado
    if DummyRoot then
        DummyRoot.Anchored = true
    end
    
    Dummy.Parent = workspace
    
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if not part:FindFirstAncestorWhichIsA("Tool") then
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                part.Transparency = 1 
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end
    end
    
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")

    LoadedAnimations = {}

    -- [NUEVO FIX] Sincronizar usando la raíz detectada (DummyRoot)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not IsActive then return end
            
            for _, part in ipairs(DummyParts) do
                if part and part.Parent then
                    part.CanCollide = false
                end
            end
            
            pcall(function()
                local playingMyTracks = MyHum:GetPlayingAnimationTracks()
                local activeIds = {}

                for _, track in pairs(playingMyTracks) do
                    if track.Animation and track.Animation.AnimationId then
                        local originalId = track.Animation.AnimationId
                        local targetId = AnimationOverrides[originalId] or originalId
                        activeIds[targetId] = true

                        if not LoadedAnimations[targetId] then
                            local newAnim = Instance.new("Animation")
                            newAnim.AnimationId = targetId
                            
                            local success, loadedAnim = pcall(function()
                                return DummyHum:LoadAnimation(newAnim)
                            end)
                            if success and loadedAnim then
                                LoadedAnimations[targetId] = loadedAnim
                            end
                        end
                        
                        local dummyTrack = LoadedAnimations[targetId]
                        if dummyTrack then
                            if not dummyTrack.IsPlaying then
                                dummyTrack:Play()
                            end
                            
                            pcall(function()
                                dummyTrack:AdjustWeight(track.Weight)
                                dummyTrack:AdjustSpeed(track.Speed)
                                
                                if math.abs(dummyTrack.TimePosition - track.TimePosition) > 0.05 then
                                    dummyTrack.TimePosition = track.TimePosition
                                end
                            end)
                        end
                    end
                end

                for id, dummyTrack in pairs(LoadedAnimations) do
                    if not activeIds[id] and dummyTrack.IsPlaying then
                        dummyTrack:Stop()
                    end
                end

                local MiChar = LocalPlayer.Character
                if not MiChar then return end
                
                local TieneHerramienta = MiChar:FindFirstChildOfClass("Tool") ~= nil
                
                local function CalcarArticulacion(NombreParte, NombreArticulacion)
                    local MiPart = MiChar:FindFirstChild(NombreParte)
                    local ClonPart = Dummy:FindFirstChild(NombreParte)
                    
                    if MiPart and ClonPart then
                        local MiJoint = MiPart:FindFirstChild(NombreArticulacion)
                        local ClonJoint = ClonPart:FindFirstChild(NombreArticulacion)
                        
                        if MiJoint and ClonJoint then
                            pcall(function()
                                if TieneHerramienta then
                                    if MiJoint:IsA("Motor6D") and ClonJoint:IsA("Motor6D") then
                                        ClonJoint.Transform = MiJoint.Transform
                                        ClonJoint.CurrentAngle = MiJoint.CurrentAngle
                                        ClonJoint.DesiredAngle = MiJoint.DesiredAngle
                                    end
                                    ClonJoint.C0 = MiJoint.C0
                                    ClonJoint.C1 = MiJoint.C1
                                else
                                    if DummyOriginalJoints[ClonJoint] then
                                        ClonJoint.C0 = DummyOriginalJoints[ClonJoint].C0
                                        ClonJoint.C1 = DummyOriginalJoints[ClonJoint].C1
                                    end
                                end
                            end)
                        end
                    end
                end
                
                if MiChar:FindFirstChild("Torso") and Dummy:FindFirstChild("Torso") then
                    CalcarArticulacion("Torso", "Right Shoulder")
                elseif MiChar:FindFirstChild("RightUpperArm") and Dummy:FindFirstChild("RightUpperArm") then
                    CalcarArticulacion("RightUpperArm", "RightShoulder")
                    CalcarArticulacion("RightLowerArm", "RightElbow")
                    CalcarArticulacion("RightHand", "RightWrist")
                end
            end)
        end)
    end
end

local function StopCloning()
    IsActive = false
    
    if Connection then Connection:Disconnect() end
    if AnimConnection then AnimConnection:Disconnect() end
    
    if Dummy then Dummy:Destroy() end
    LoadedAnimations = {}
    AnimationOverrides = {}
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if not part:FindFirstAncestorWhichIsA("Tool") then
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                    part.Transparency = 0 
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end
end

-- =========================================================
-- 🖱️ MENÚ DE BOTONES DE INTERFAZ
-- =========================================================

MorphTab:CreateButton({
   Name = "Clonar Pro Climber 🧗‍♂️",
   Callback = function()
        StopCloning() 
        local Target = FindNPC("ProClimber")
        
        if Target then
            StartCloning(Target)
            Rayfield:Notify({Title = "Sincronización Exitosa", Content = "Infiltrado como Pro Climber", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "No se encontró a Pro Climber en el mapa.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "Clonar Seller 💰",
   Callback = function()
        StopCloning() 
        local Target = FindNPC("Seller")
        
        if Target then
            StartCloning(Target)
            Rayfield:Notify({Title = "Sincronización Exitosa", Content = "Infiltrado como Seller", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "No se encontró a Seller/SellWorker en el mapa.", Duration = 3})
        end
   end,
})

MorphTab:CreateButton({
   Name = "Detener Clonación (Volver a Normal)",
   Callback = function()
        StopCloning()
        Rayfield:Notify({Title = "Desactivado", Content = "Has vuelto a tu forma original.", Duration = 3})
   end,
})

MorphTab:CreateButton({
   Name = "Limpiar Todo (Reset de Personaje)",
   Callback = function()
        StopCloning()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})
