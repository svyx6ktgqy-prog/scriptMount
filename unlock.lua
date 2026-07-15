local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía Pro | Clonación Natural V2",
   LoadingTitle = "Iniciando Sincronización...",
   LoadingSubtitle = "Sistema Anti-Elevación y Animación",
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
local AnimationOverrides = {} -- [NUEVO] Tabla para guardar las animaciones del NPC

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

-- [NUEVO] Función para extraer y mapear las animaciones del NPC
local function MapNpcAnimations(MyChar, NpcChar)
    AnimationOverrides = {}
    local myAnimate = MyChar:FindFirstChild("Animate")
    local npcAnimate = NpcChar:FindFirstChild("Animate")
    
    if myAnimate and npcAnimate then
        -- Recorremos las carpetas de estado (run, walk, idle, etc.)
        for _, stateFolder in ipairs(myAnimate:GetChildren()) do
            local npcStateFolder = npcAnimate:FindFirstChild(stateFolder.Name)
            
            if npcStateFolder then
                -- Comparamos las animaciones dentro de cada estado
                for _, myAnim in ipairs(stateFolder:GetChildren()) do
                    if myAnim:IsA("Animation") then
                        local npcAnim = npcStateFolder:FindFirstChild(myAnim.Name)
                        if npcAnim and npcAnim:IsA("Animation") and npcAnim.AnimationId ~= "" then
                            -- Mapeamos Tu ID de Animación -> ID de Animación del NPC
                            AnimationOverrides[myAnim.AnimationId] = npcAnim.AnimationId
                        end
                    end
                end
            end
        end
    end
end

local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    
    -- Mapear las animaciones originales del NPC antes de clonar
    MapNpcAnimations(LocalPlayer.Character, TargetNPC)
    
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
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
    
    -- =========================================================
    -- 🛠️ GUARDAR POSTURA ORIGINAL
    -- =========================================================
    local DummyOriginalJoints = {}
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("Motor6D") then
            DummyOriginalJoints[obj] = {C0 = obj.C0, C1 = obj.C1}
        end
    end
    -- =========================================================
    
    -- 1. SOLUCIÓN DE FÍSICAS
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            table.insert(DummyParts, obj) 
            
            if obj.Name == "HumanoidRootPart" then
                obj.Anchored = true
            else
                obj.Anchored = false
            end
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("BodyMover") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- 2. HACER INVISIBLE AL JUGADOR
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
    local DummyRoot = Dummy:FindFirstChild("HumanoidRootPart")
    local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")

    LoadedAnimations = {}

    -- 3. SINCRONIZACIÓN DE POSICIÓN
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    -- 4. SINCRONIZACIÓN DE ANIMACIONES Y FIX DE BRAZO SEGURO
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

                -- =========================================================
                -- 🛠️ SINCRONIZACIÓN CON PRIORIDAD DE ANIMACIÓN DEL NPC
                -- =========================================================
                for _, track in pairs(playingMyTracks) do
                    if track.Animation and track.Animation.AnimationId then
                        local originalId = track.Animation.AnimationId
                        
                        -- [NUEVO] Verifica si el NPC tiene una animación equivalente, si no, usa la tuya
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

                -- =========================================================
                -- 🛠️ FIX DE DEFORMACIÓN DEL BRAZO 
                -- =========================================================
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
                -- =========================================================
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

MorphTab:CreateToggle({
   Name = "Activar Clonación (Sincronizada)",
   CurrentValue = false,
   Callback = function(Value)
        IsActive = Value
        local Target = workspace:FindFirstChild("SellWorker", true)
        
        if IsActive then
            if Target then 
                StartCloning(Target)
            else 
                Rayfield:Notify({Title = "Error", Content = "No se encontró al NPC.", Duration = 3}) 
                IsActive = false
            end
        else 
            StopCloning() 
        end
   end,
})

MorphTab:CreateButton({
   Name = "Limpiar Todo (Reset)",
   Callback = function()
        StopCloning()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})
