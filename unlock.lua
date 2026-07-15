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
local LoadedAnimations = {} -- Caché para evitar saturar la memoria cargando animaciones

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
    -- Configuración de seguridad para el Humanoid del clon
    local DummyHum = Dummy:FindFirstChildOfClass("Humanoid")
    if DummyHum then
        DummyHum.RequiresNeck = false 
        DummyHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) 
    end
    
    local DummyParts = {}
    
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
    
    -- 2. Hacer invisible al jugador real correctamente (EXCLUYENDO LAS HERRAMIENTAS)
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

    -- 3. SINCRONIZACIÓN DE POSICIÓN (RenderStepped)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    -- 4. SINCRONIZACIÓN DE ANIMACIONES Y FIX DE ELEVACIÓN OPTIMIZADO
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not IsActive then return end
            
            for _, part in ipairs(DummyParts) do
                part.CanCollide = false
            end
            
            local playingMyTracks = MyHum:GetPlayingAnimationTracks()
            local activeIds = {}

            -- Reproducir y sincronizar nuevas animaciones
            for _, track in pairs(playingMyTracks) do
                local animId = track.Animation.AnimationId
                activeIds[animId] = true

                if not LoadedAnimations[animId] then
                    LoadedAnimations[animId] = DummyHum:LoadAnimation(track.Animation)
                end
                
                local dummyTrack = LoadedAnimations[animId]
                if not dummyTrack.IsPlaying then
                    dummyTrack:Play()
                end
            end

            -- Detener las animaciones que el jugador ya no está usando
            for id, dummyTrack in pairs(LoadedAnimations) do
                if not activeIds[id] and dummyTrack.IsPlaying then
                    dummyTrack:Stop()
                end
            end

            -- =========================================================
            -- 🛠️ FIX: FORZAR POSTURA DE LA MANO DERECHA (PICO)
            -- =========================================================
            local MiChar = LocalPlayer.Character
            
            -- Soporte para Avatares R6
            if MiChar:FindFirstChild("Torso") and Dummy:FindFirstChild("Torso") then
                local MiHombro = MiChar.Torso:FindFirstChild("Right Shoulder")
                local ClonHombro = Dummy.Torso:FindFirstChild("Right Shoulder")
                
                if MiHombro and ClonHombro then
                    ClonHombro.Transform = MiHombro.Transform
                end
                
            -- Soporte para Avatares R15
            elseif MiChar:FindFirstChild("RightUpperArm") and Dummy:FindFirstChild("RightUpperArm") then
                local function SincronizarArticulacion(NombreParte, NombreMotor)
                    local MiPart = MiChar:FindFirstChild(NombreParte)
                    local ClonPart = Dummy:FindFirstChild(NombreParte)
                    if MiPart and ClonPart then
                        local MiMotor = MiPart:FindFirstChild(NombreMotor)
                        local ClonMotor = ClonPart:FindFirstChild(NombreMotor)
                        if MiMotor and ClonMotor then
                            ClonMotor.Transform = MiMotor.Transform
                        end
                    end
                end
                
                -- Sincronizamos todo el brazo derecho (Hombro, codo y muñeca)
                SincronizarArticulacion("RightUpperArm", "RightShoulder")
                SincronizarArticulacion("RightLowerArm", "RightElbow")
                SincronizarArticulacion("RightHand", "RightWrist")
            end
            -- =========================================================
            
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
