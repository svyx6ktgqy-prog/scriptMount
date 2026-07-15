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
local LoadedAnimations = {} -- Se mantiene para compatibilidad al limpiar

local MorphTab = Window:CreateTab("Infiltración", 4483362458)

local function StartCloning(TargetNPC)
    if not TargetNPC or not LocalPlayer.Character then return end
    
    Dummy = TargetNPC:Clone()
    Dummy.Name = "ClonControl"
    
    -- Configuración de seguridad para el Humanoid del clon (Evita que muera y se rompa)
    local DummyHum = Dummy:FindFirstChildOfClass("Humanoid")
    if DummyHum then
        DummyHum.RequiresNeck = false -- Evita que muera si la cabeza se desfasa del torso
        DummyHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- Desactiva la muerte por físicas
    end
    
    -- Caché para las partes del clon, optimizando el rendimiento en el bucle anti-elevación
    local DummyParts = {}
    
    -- 1. SOLUCIÓN DE FÍSICAS (Evita salir volando y que el cuerpo se caiga al vacío)
    for _, obj in pairs(Dummy:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false 
            obj.Massless = true
            
            table.insert(DummyParts, obj) -- Guardamos la parte en la caché
            
            -- Solo anclamos el "HumanoidRootPart" para moverlo con CFrame sin resistencia.
            -- Dejamos las demás partes desancladas para que las uniones (Motor6D/Welds) funcionen y se animen.
            if obj.Name == "HumanoidRootPart" then
                obj.Anchored = true
            else
                obj.Anchored = false
            end
            
        -- ¡CLAVE!: Quitamos "Weld" de aquí para conservar la estructura del cuerpo intacta.
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("BodyMover") then
            obj:Destroy()
        end
    end
    Dummy.Parent = workspace
    
    -- 2. Hacer invisible al jugador real correctamente (EXCLUYENDO LAS HERRAMIENTAS)
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        -- Si la parte NO pertenece a un Tool (Pico, arma, etc), la hacemos invisible
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
    
    -- [NUEVO] Mapeo de articulaciones (Motor6D) entre tu personaje real y el clon
    local MotorMap = {}
    local function UpdateMotorMap()
        MotorMap = {}
        for _, motor in pairs(LocalPlayer.Character:GetDescendants()) do
            if motor:IsA("Motor6D") then
                local dummyMotor = Dummy:FindFirstChild(motor.Name, true)
                if dummyMotor and dummyMotor:IsA("Motor6D") then
                    MotorMap[motor] = dummyMotor
                end
            end
        end
    end
    UpdateMotorMap()

    -- 3. SINCRONIZACIÓN DE POSICIÓN (RenderStepped)
    Connection = RunService.RenderStepped:Connect(function()
        if not IsActive or not MyRoot or not DummyRoot then return end
        -- Al estar el Root del Dummy anclado, sigue tu CFrame perfectamente sin colisiones empujándote.
        DummyRoot.CFrame = MyRoot.CFrame
    end)
    
    -- 4. SINCRONIZACIÓN FÍSICA DE ARTICULACIONES (Motor6D) Y FIX ANTI-FLING
    AnimConnection = RunService.Stepped:Connect(function()
        if not IsActive then return end
        
        -- [FIX ANTI-FLING] Forzamos la eliminación de colisiones en cada frame
        for _, part in ipairs(DummyParts) do
            part.CanCollide = false
        end
        
        -- [NUEVO] Sincronización exacta de poses de articulaciones (brazos, piernas, cabeza)
        -- Esto copia exactamente el brazo levantado cuando equipas y corres con el pico.
        for realMotor, dummyMotor in pairs(MotorMap) do
            if realMotor and dummyMotor and realMotor.Parent and dummyMotor.Parent then
                dummyMotor.Transform = realMotor.Transform
            else
                -- Si tu personaje se reinicia o cambia de estado drásticamente, actualizamos el mapa
                UpdateMotorMap()
                break
            end
        end
    end)
end

local function StopCloning()
    IsActive = false
    
    -- Desconectar eventos para liberar memoria del juego (Anti-Lag)
    if Connection then Connection:Disconnect() end
    if AnimConnection then AnimConnection:Disconnect() end
    
    if Dummy then Dummy:Destroy() end
    LoadedAnimations = {}
    
    -- Restaurar la visibilidad original de tu personaje real (Excluyendo herramientas por seguridad)
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
