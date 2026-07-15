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
    
    -- 1. SOLUCIÓN ANTI-ELEVACIÓN (Físicas):
    -- Hacemos que el clon no tenga colisiones, no tenga masa y esté anclado.
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            obj.Anchored = true -- Permite que el CFrame lo mueva sin interferencia de físicas
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Weld") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- Hacer invisible al jugador real correctamente (incluyendo caras y accesorios)
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

    -- 2. SINCRONIZACIÓN DE POSICIÓN (RenderStepped)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        -- Al estar anclado el Dummy, igualar el CFrame ya no causa repulsión física
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    -- 3. SOLUCIÓN DE ANIMACIONES (Optimizado para evitar lag/crasheos)
    if MyHum and DummyHum then
        AnimConnection = RunService.Stepped:Connect(function()
            if not IsActive then return end
            
            local playingMyTracks = MyHum:GetPlayingAnimationTracks()
            local activeIds = {}

            -- Reproducir y sincronizar nuevas animaciones
            for _, track in pairs(playingMyTracks) do
                local animId = track.Animation.AnimationId
                activeIds[animId] = true

                -- Solo carga la animación si no se ha cargado antes (evita la fuga de memoria)
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
                IsActive = false -- Forzar apagado lógico si no hay NPC
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
