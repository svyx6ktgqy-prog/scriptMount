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
    
    -- 1. SOLUCIÓN ANTI-ELEVACIÓN (Físicas y Anclaje Selectivo):
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            
            -- Solo anclamos el motor principal para evitar que el cuerpo se quede atrás
            if obj.Name == "HumanoidRootPart" then
                obj.Anchored = true
            else
                obj.Anchored = false
            end
            
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Weld") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- 2. Hacer invisible al jugador real correctamente (incluyendo caras y accesorios)
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
            part.Transparency = 1 
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local DummyRoot = Dummy:FindFirstChild("HumanoidRootPart")
    local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")
    local DummyHum = Dummy:FindFirstChild("Humanoid")

    -- Limpiamos la caché de animaciones previas
    LoadedAnimations = {}

    -- 3. SINCRONIZACIÓN DE POSICIÓN (RenderStepped)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        -- Al estar anclado solo el Root del Dummy, igualar el CFrame ya no causa repulsión física
        -- y el resto del cuerpo lo sigue gracias a que no está anclado.
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    -- 4. SOLUCIÓN DE ANIMACIONES (Optimizado para evitar lag/crasheos)
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not IsActive then return end
            
            local playingMyTracks = MyHum:GetPlayingAnimationTracks()
            local activeIds = {}

            -- Reproducir y sincronizar nuevas animaciones
            for _, track in pairs(playingMyTracks) do
                local animId = track.Animation.AnimationId
                activeIds[animId] = true

                -- Solo carga la animación si no se ha cargado antes
                if not LoadedAnimations[animId] then
                    LoadedAnimations[animId] = DummyHum:LoadAnimation(track.Animation)
                end
                
                local dummyTrack = LoadedAnimations[animId]
                if not dummyTrack.IsPlaying then
                    dummyTrack:Play()
                end
            end

            -- Detener las animaciones que el jugador ya no está reproduciendo
            for id, dummyTrack in pairs(LoadedAnimations) do
                if not activeIds[id] and dummyTrack.IsPlaying then
                    dummyTrack:Stop()
                end
            end
        end)
    end
end

local function StopCloning()
    IsActive = false
    
    -- Desconectar eventos para liberar memoria
    if Connection then Connection:Disconnect() end
    if AnimConnection then AnimConnection:Disconnect() end
    
    if Dummy then Dummy:Destroy() end
    LoadedAnimations = {}
    
    -- Restaurar la visibilidad original del jugador
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                part.Transparency = 0 
            elseif part:IsA("Decal") then
                part.Transparency = 0
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
