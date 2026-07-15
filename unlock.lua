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

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

local function StartCloning(TargetNPC)
    if not TargetNPC then return end
    
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
    -- Limpiar scripts físicos que causan el "fling" o error
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Weld") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- Hacer invisible al jugador real
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.Transparency = 1 end
    end
    
    -- Bucle de sincronización de movimiento y animaciones
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not LocalPlayer.Character or not Dummy then return end
        
        local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local DummyRoot = Dummy:FindFirstChild("HumanoidRootPart")
        
        if MyRoot and DummyRoot then
            -- Sincronización posicional con bloqueo de altura (Anti-Elevación)
            DummyRoot.CFrame = MyRoot.CFrame
            DummyRoot.Velocity = Vector3.new(0, 0, 0)
            DummyRoot.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        -- Sincronización de animaciones básica
        local MyHum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local DummyHum = Dummy:FindFirstChild("Humanoid")
        if MyHum and DummyHum then
            for _, track in pairs(DummyHum:GetPlayingAnimationTracks()) do track:Stop() end
            for _, track in pairs(MyHum:GetPlayingAnimationTracks()) do
                local newTrack = DummyHum:LoadAnimation(track.Animation)
                newTrack:Play()
                newTrack:AdjustSpeed(track.Speed)
                newTrack.TimePosition = track.TimePosition
            end
        end
    end)
end

local function StopCloning()
    IsActive = false
    if Connection then Connection:Disconnect() end
    if Dummy then Dummy:Destroy() end
    
    -- Restaurar visibilidad
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0 end
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
            if Target then StartCloning(Target)
            else Rayfield:Notify({Title = "Error", Content = "No se encontró al NPC.", Duration = 3}) end
        else StopCloning() end
   end,
})

MorphTab:CreateButton({
   Name = "Limpiar Todo (Reset)",
   Callback = function()
        StopCloning()
        LocalPlayer.Character.Humanoid.Health = 0
   end,
})
