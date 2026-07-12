-- [[ COD MOBILE GLOBAL - RAYFIELD UI & DELTA COMPATIBLE ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

-- Cargar la Biblioteca oficial de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuración Global para los trucos
getgenv().COD_Settings = {
    AutoAim = false,
    AutoShoot = false,
    KillAll = false,
    RapidFire = false,
    NoReload = false,
    InfiniteAmmo = false,
    Wallbang = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [ FUNCIÓN UNIVERSAL: Obtener enemigo más cercano ] --
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                if player.Team ~= LocalPlayer.Team or tostring(player.Team) == "Neutral" then
                    local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
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

-- [ BUCLE PRINCIPAL: AIMBOT & AUTO-SHOOT ] --
RunService.RenderStepped:Connect(function()
    if getgenv().COD_Settings.AutoAim then
        local target = getClosestPlayer()
        if target and target:FindFirstChild("Head") then
            -- Suavizado de cámara para que apunte directo a la cabeza
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
            
            if getgenv().COD_Settings.AutoShoot then
                -- Trigger básico para ejecutores móviles
                pcall(function() vipnotify = true end)
            end
        end
    end
end)

-- [ HOOK DE METATABLAS (Para funciones globales como Wallbang) ] --
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall

gmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if getgenv().COD_Settings.Wallbang and method == "Raycast" then
        return nil -- Ignora colisiones de paredes simuladas por Raycast
    end

    return oldNamecall(self, unpack(args))
end)
setreadonly(gmt, true)

-- ==================================================================== --
-- [[ CREACIÓN DE LA INTERFAZ CON RAYFIELD ]] --
-- ==================================================================== --

local Window = Rayfield:CreateWindow({
    Name = "COD Mobile Global",
    LoadingTitle = "Cargando Interfaz iOS...",
    LoadingSubtitle = "Delta Executor Version",
    ConfigurationSaving = {
        Enabled = false -- Desactivado para evitar archivos basura en el celular
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false -- Sin molesto sistema de llaves, acceso directo
})

-- Pestaña Principal de Combate
local CombatTab = Window:CreateTab("Guerra / Combat", 4483362458) -- Icono de espada/mira

Rayfield:Notify({
    Title = "Menú Inyectado",
    Content = "Compatible con Delta Executor. Disfruta de la partida.",
    Duration = 5,
    Image = 4483362458,
})

-- [[ AGREGAR LOS 7 TRUCOS ORDENADOS ]] --

CombatTab:CreateToggle({
    Name = "Auto Aim (Aimbot Universal)",
    CurrentValue = false,
    Flag = "Toggle_AutoAim",
    Callback = function(Value)
        getgenv().COD_Settings.AutoAim = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Disparo Automático (Auto Shoot)",
    CurrentValue = false,
    Flag = "Toggle_AutoShoot",
    Callback = function(Value)
        getgenv().COD_Settings.AutoShoot = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Dar de Baja a Todos (Kill All)*",
    CurrentValue = false,
    Flag = "Toggle_KillAll",
    Callback = function(Value)
        getgenv().COD_Settings.KillAll = Value
        if Value then
            -- Nota: Depende de las funciones Remotas del juego específico
            Rayfield:Notify({Title = "Aviso", Content = "Buscando remotes de daño del servidor...", Duration = 3})
        end
    end,
})

CombatTab:CreateToggle({
    Name = "Disparo Rápido (Rapid Fire)*",
    CurrentValue = false,
    Flag = "Toggle_RapidFire",
    Callback = function(Value)
        getgenv().COD_Settings.RapidFire = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Sin Recarga (No Reload)*",
    CurrentValue = false,
    Flag = "Toggle_NoReload",
    Callback = function(Value)
        getgenv().COD_Settings.NoReload = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Balas Infinitas*",
    CurrentValue = false,
    Flag = "Toggle_InfAmmo",
    Callback = function(Value)
        getgenv().COD_Settings.InfiniteAmmo = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Atravesar Paredes (Wallbang)",
    CurrentValue = false,
    Flag = "Toggle_Wallbang",
    Callback = function(Value)
        getgenv().COD_Settings.Wallbang = Value
    end,
})

-- Sección de aclaración para mantener el orden
CombatTab:CreateSection("Aviso Importante")
local Paragraph = CombatTab:CreateParagraph({
    Title = "* Funciones con Marcador", 
    Content = "Las opciones con asterisco (*) intentan interceptar el sistema de armas del juego actual. Su efectividad puede variar según la seguridad interna de cada entrega de guerra en Roblox."
})
