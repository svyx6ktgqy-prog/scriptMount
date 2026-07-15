local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía Pro | Clonación Natural",
   LoadingTitle = "Iniciando...",
   LoadingSubtitle = "Sistema de Clonación Independiente",
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

-- Función para limpiar al personaje y clonar
local function StartCloning(TargetNPC)
    if not TargetNPC then return end
    
    -- 1. Clonar el NPC original
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
    -- Limpiar el clon de cualquier script que cause lag o errores
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Weld") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- 2. Hacer invisible al jugador REAL (tu personaje sigue ahí, solo que oculto)
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    -- 3. Sincronizar posición sin soldar (esto evita el giro de cámara)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not LocalPlayer.Character then return end
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if Root and Dummy:FindFirstChild("HumanoidRootPart") then
            Dummy.HumanoidRootPart.CFrame = Root.CFrame
        end
    end)
end

local function StopCloning()
    IsActive = false
    if Connection then Connection:Disconnect() end
    if Dummy then Dummy:Destroy() end
    
    -- Hacer visible al jugador
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

MorphTab:CreateToggle({
   Name = "Activar Clonación (NPC)",
   CurrentValue = false,
   Callback = function(Value)
        IsActive = Value
        local Target = workspace:FindFirstChild("SellWorker", true) -- Busca en todo el mapa
        
        if IsActive then
            if Target then
                StartCloning(Target)
            else
                Rayfield:Notify({Title = "Error", Content = "No se encontró a SellWorker", Duration = 3})
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
        LocalPlayer.Character.Humanoid.Health = 0
   end,
})
