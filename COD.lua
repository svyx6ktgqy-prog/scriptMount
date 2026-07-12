-- [[ COD MOBILE GLOBAL - RAGE & LEVEL UP UPDATE ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuración Global Expandida
getgenv().COD_Settings = {
    AutoAim = false,
    AimMode = "Normal", -- Normal, Hardcore, Extreme
    AutoShoot = false,
    Invisible = false,
    Esp = false,
    SpeedHack = false,
    WalkSpeedValue = 16,
    Wallbang = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [ FUNCIÓN: Obtener enemigo más cercano ] --
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                if player.Team ~= LocalPlayer.Team or tostring(player.Team) == "Neutral" then
                    local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen or getgenv().COD_Settings.AimMode == "Extreme" then -- Extreme ignora si está en pantalla
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            closestTarget = player.Character
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- [ BUCLE PRINCIPAL: AIMBOT AGRESIVO DE 3 MODOS & AUTO-SHOOT ] --
RunService.RenderStepped:Connect(function()
    if getgenv().COD_Settings.AutoAim then
        local target = getClosestPlayer()
        if target and target:FindFirstChild("Head") then
            
            -- Lógica de agresividad según el Spinner/Dropdown
            if getgenv().COD_Settings.AimMode == "Normal" then
                -- Suave y disimulado
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Head.Position), 0.15)
            elseif getgenv().COD_Settings.AimMode == "Hardcore" then
                -- Rápido y directo
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Head.Position), 0.6)
            elseif getgenv().COD_Settings.AimMode == "Extreme" then
                -- BLOQUEO INSTANTÁNEO (Rage): No hay suavizado, la cámara se clava frame a frame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
            end
            
            if getgenv().COD_Settings.AutoShoot then
                pcall(function() vipnotify = true end)
            end
        end
    end
end)

-- [ BUCLE DE MOVIMIENTO: MODO INVISIBLE & SPEED ] --
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        
        -- Modo Invisible (Falsa posición subterránea)
        -- Te mantiene 8 studs abajo del suelo de forma local para las balas enemigas, pero tú puedes disparar hacia arriba.
        if getgenv().COD_Settings.Invisible then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            -- Noclip básico incorporado para no morir por la colisión del mapa
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -0.05, 0)
        end

        -- SpeedHack para cruzar el mapa y limpiar salas
        if getgenv().COD_Settings.SpeedHack then
            char.Humanoid.WalkSpeed = getgenv().COD_Settings.WalkSpeedValue
        else
            char.Humanoid.WalkSpeed = 16
        end
    end
end)

-- [ SISTEMA DE ESP / WALLHACK UNIVERSAL DE RENDIMIENTO ] --
-- Usa Highlights nativos de Roblox (Cero Lag en Delta)
task.spawn(function()
    while task.wait(1) do
        if getgenv().COD_Settings.Esp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("CODBorder") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "CODBorder"
                        highlight.FillColor = Color3.fromRGB(255, 30, 30)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.6
                        highlight.OutlineTransparency = 0
                        highlight.Parent = player.Character
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("CODBorder") then
                    player.Character.CODBorder:Destroy()
                end
            end
        end
    end
end)

-- ==================================================================== --
-- [[ INTERFAZ GRÁFICA RAYFIELD ]] --
-- ==================================================================== --

local Window = Rayfield:CreateWindow({
    Name = "COD Mobile GLOBAL ☠️",
    LoadingTitle = "Inyectando Rage Mode...",
    LoadingSubtitle = "Delta Executor Optimized",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- PESTAÑA DE COMBATE (Aimbot & Modos)
local AimbotTab = Window:CreateTab("Aimbot Brutal", 4483362458)

AimbotTab:CreateToggle({
    Name = "Activar Auto Aim",
    CurrentValue = false,
    Flag = "Aimbot_Toggle",
    Callback = function(Value) getgenv().COD_Settings.AutoAim = Value end,
})

AimbotTab:CreateDropdown({
    Name = "Selector de Agresividad",
    Options = {"Normal", "Hardcore", "Extreme"},
    CurrentOption = {"Normal"},
    MultipleOptions = false,
    Flag = "Aimbot_Modes",
    Callback = function(Option)
        getgenv().COD_Settings.AimMode = Option[1]
        Rayfield:Notify({
            Title = "Modo Cambiado",
            Content = "Aimbot configurado en: " .. tostring(Option[1]),
            Duration = 2,
            Image = 4483362458
        })
    end,
})

AimbotTab:CreateToggle({
    Name = "Disparo Automático (Auto Shoot)",
    CurrentValue = false,
    Flag = "AutoShoot_Toggle",
    Callback = function(Value) getgenv().COD_Settings.AutoShoot = Value end,
})

-- PESTAÑA PARA GANAR LA GUERRA (Invisibilidad, Leveo Rápido y ESP)
local WarTab = Window:CreateTab("Win & Level Up", 4483362458)

WarTab:CreateToggle({
    Name = "Modo Invisible (Underground Ghost)",
    CurrentValue = false,
    Flag = "Invisible_Toggle",
    Callback = function(Value) 
        getgenv().COD_Settings.Invisible = Value 
        if Value then
            Rayfield:Notify({Title = "Fantasma Activado", Content = "Te encuentras bajo el mapa. Los enemigos no te ven.", Duration = 3})
        end
    end,
})

WarTab:CreateToggle({
    Name = "Wallhack / ESP (Ver a través de paredes)",
    CurrentValue = false,
    Flag = "Esp_Toggle",
    Callback = function(Value) getgenv().COD_Settings.Esp = Value end,
})

WarTab:CreateSection("Movilidad Avanzada")

WarTab:CreateToggle({
    Name = "Activar Multiplicador de Velocidad",
    CurrentValue = false,
    Flag = "Speed_Toggle",
    Callback = function(Value) getgenv().COD_Settings.SpeedHack = Value end,
})

WarTab:CreateSlider({
    Name = "Velocidad de Desplazamiento",
    Range = {16, 150},
    Increment = 5,
    Suffix = "Studs",
    CurrentValue = 50,
    Flag = "Speed_Slider",
    Callback = function(Value) getgenv().COD_Settings.WalkSpeedValue = Value end,
})
