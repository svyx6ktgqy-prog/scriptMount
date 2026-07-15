local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Espía Pro | Clonación Natural V4",
   LoadingTitle = "Iniciando Sincronización...",
   LoadingSubtitle = "Espejo de Articulaciones 100% Preciso",
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
    if not TargetNPC or not LocalPlayer.Character then return end
    
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
    local DummyHum = Dummy:FindFirstChildOfClass("Humanoid")
    if DummyHum then
        DummyHum.RequiresNeck = false 
        DummyHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    
    local DummyParts = {}
    
    -- 1. SOLUCIÓN DE FÍSICAS (Desactivar colisiones y gravedad en el Clon)
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
    
    -- 2. HACER INVISIBLE AL JUGADOR (El pico se queda visible en tu mano)
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

    -- =========================================================
    -- 3. BUCLE PRINCIPAL DE SINCRONIZACIÓN (RenderStepped)
    -- =========================================================
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        
        -- Sincronizar posición del cuerpo en el mapa
        DummyRoot.CFrame = MyRoot.CFrame
        
        -- Forzar colisiones apagadas para evitar tirones de físicas de Roblox
        for _, part in ipairs(DummyParts) do
            if part and part.Parent then
                part.CanCollide = false
            end
        end
        
        -- SINCRONIZACIÓN "ESPEJO" DE ARTICULACIONES
        local MiChar = LocalPlayer.Character
        if MiChar then
            for _, MiJoint in ipairs(MiChar:GetDescendants()) do
                if MiJoint:IsA("Motor6D") and MiJoint.Name ~= "RightGrip" then
                    local ParentPart = MiJoint.Parent
                    if ParentPart then
                        -- Encontramos la extremidad/parte equivalente en el clon
                        local ClonParent = Dummy:FindFirstChild(ParentPart.Name, true)
                        if ClonParent then
                            -- Buscamos la articulación correspondiente
                            local ClonJoint = ClonParent:FindFirstChild(MiJoint.Name)
                            if ClonJoint and ClonJoint:IsA("Motor6D") then
                                -- Copiamos rotación, ángulo base y offset (C0/C1 maneja la pose del pico automáticamente)
                                ClonJoint.Transform = MiJoint.Transform
                                ClonJoint.C0 = MiJoint.C0
                                ClonJoint.C1 = MiJoint.C1
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function StopCloning()
    IsActive = false
    
    if Connection then Connection:Disconnect() end
    if Dummy then Dummy:Destroy() end
    
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
