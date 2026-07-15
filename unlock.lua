local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía Pro | Clonación Natural V3",
   LoadingTitle = "Iniciando Sincronización...",
   LoadingSubtitle = "Fix de Animación de Herramientas",
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

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    
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
    
    -- 2. HACER INVISIBLE AL JUGADOR (Mantiene el Pico Visible)
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

    -- =========================================================
    -- 3. SINCRONIZACIÓN DE POSICIÓN Y MOVIMIENTO DEL BRAZO (RenderStepped)
    -- =========================================================
    -- Se ejecuta al final del frame para evitar que Roblox sobrescriba nuestro brazo
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        
        -- Sincronizar posición del cuerpo
        DummyRoot.CFrame = MyRoot.CFrame
        
        -- Sincronizar el brazo (El golpe del pico)
        local MiChar = LocalPlayer.Character
        if MiChar then
            local TieneHerramienta = MiChar:FindFirstChildOfClass("Tool") ~= nil
            
            local function CalcarArticulacion(NombreParte, NombreArticulacion)
                local MiPart = MiChar:FindFirstChild(NombreParte)
                local ClonPart = Dummy:FindFirstChild(NombreParte)
                
                if MiPart and ClonPart then
                    local MiJoint = MiPart:FindFirstChild(NombreArticulacion)
                    local ClonJoint = ClonPart:FindFirstChild(NombreArticulacion)
                    
                    if MiJoint and ClonJoint and MiJoint:IsA("Motor6D") and ClonJoint:IsA("Motor6D") then
                        if TieneHerramienta then
                            -- Fuerza absoluta: Copiamos exactamente la animación de golpe de tu brazo invisible
                            ClonJoint.Transform = MiJoint.Transform
                            ClonJoint.CurrentAngle = MiJoint.CurrentAngle
                            ClonJoint.DesiredAngle = MiJoint.DesiredAngle
                            ClonJoint.C0 = MiJoint.C0
                            ClonJoint.C1 = MiJoint.C1
                        else
                            -- Si guardamos la herramienta, regresamos a la postura normal para evitar deformaciones
                            if DummyOriginalJoints[ClonJoint] then
                                ClonJoint.C0 = DummyOriginalJoints[ClonJoint].C0
                                ClonJoint.C1 = DummyOriginalJoints[ClonJoint].C1
                            end
                        end
                    end
                end
            end
            
            -- Detectar si somos R6 o R15 y calcar solo los brazos
            if MiChar:FindFirstChild("Torso") and Dummy:FindFirstChild("Torso") then
                CalcarArticulacion("Torso", "Right Shoulder") -- R6
            elseif MiChar:FindFirstChild("RightUpperArm") and Dummy:FindFirstChild("RightUpperArm") then
                CalcarArticulacion("RightUpperArm", "RightShoulder") -- R15
                CalcarArticulacion("RightLowerArm", "RightElbow")
                CalcarArticulacion("RightHand", "RightWrist")
            end
        end
    end)
    
    -- =========================================================
    -- 4. SINCRONIZACIÓN DE ANIMACIONES BASE (Stepped)
    -- =========================================================
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not IsActive then return end
            
            -- Mantener las físicas sin colisión
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
                        local animId = track.Animation.AnimationId
                        activeIds[animId] = true

                        if not LoadedAnimations[animId] then
                            local success, loadedAnim = pcall(function()
                                return DummyHum:LoadAnimation(track.Animation)
                            end)
                            if success and loadedAnim then
                                LoadedAnimations[animId] = loadedAnim
                            end
                        end
                        
                        local dummyTrack = LoadedAnimations[animId]
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
