-- =====================================================================
-- 💎 MINE DIAMOND MASTER - MOD MENU
-- Compatible con Delta Executor (Android / Windows)
-- =====================================================================

-- 1. Cargar la interfaz visual (LinoriaLib)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- 2. Crear Ventana Principal
local Window = Library:CreateWindow({
    Title = '💎 Mine Diamond Master | Menu',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuKeybind = Enum.KeyCode.LeftControl
})

-- 3. Definición de pestañas (Tabs)
local Tabs = {
    Main = Window:AddTab('Visuals'),
    Player = Window:AddTab('Player'),
    Misc = Window:AddTab('Misc')
}

-- 4. Servicios y Variables Globales (Evitan errores cuando el jugador muere)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getHumanoid()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- Lógica para aumentar mochila (Adaptable según el juego)
local function increaseBackpack(v)
    local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
    if stats then
        local capacity = stats:FindFirstChild("MaxCapacity") or stats:FindFirstChild("BagSize") or stats:FindFirstChild("Mochila")
        if capacity and capacity:IsA("ValueBase") then
            capacity.Value = v
        end
    end
end

-- Lógica de bucle seguro para Super Salto
local superJumpEnabled = false
local function superJump()
    while superJumpEnabled do
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 150 -- Cambia este valor si quieres saltar más alto
        end
        task.wait(0.3)
    end
    -- Restablecer al apagar el toggle
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = 50
    end
end

-- =====================================================================
-- CONFIGURACIÓN DE SECCIONES (UI ELEMENTS)
-- =====================================================================

-- Pestaña: Visuals (Aquí se arregló tu fragmento inicial cortado)
local visualsTab = Tabs.Main:AddLeftGroupbox("Visuales / ESP")
visualsTab:AddToggle("EspHighlight", {Text = "Activar Highlight", Default = false, Callback = function(v)
    for _, object in ipairs(game.Workspace:GetDescendants()) do
        if object:IsA("Highlight") then
            object.FillColor = Color3.fromRGB(0, 255, 255)
            object.Enabled = v
        end
    end
end})

-- Pestaña: Player Mods
local playerTab = Tabs.Player:AddLeftGroupbox("Player Mods")

playerTab:AddSlider("Backpack", {Text = "Aumentar Mochila (x)", Min = 1, Max = 100, Default = 1, Rounding = 0, Callback = function(v)
    increaseBackpack(v)
end})

playerTab:AddToggle("SuperJump", {Text = "Super Salto", Default = false, Callback = function(v)
    superJumpEnabled = v
    if v then task.spawn(superJump) end
end})

playerTab:AddButton({Text = "Infinite Jump (Power 500)", Func = function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 500
        Library:Notify("Súper Salto a 500 Activado")
    else
        Library:Notify("Error: No se detectó al personaje", 3)
    end
end})

-- Pestaña: Más Opciones (Misc)
local miscTab = Tabs.Misc:AddLeftGroupbox("Más Opciones")

miscTab:AddButton({Text = "Auto Sell (si existe Remote)", Func = function()
    local found = false
    for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "sell") or string.find(remote.Name:lower(), "deposit")) then
            remote:FireServer()
            found = true
        end
    end
    if found then
        Library:Notify("Intentando Auto Sell...")
    else
        Library:Notify("No se encontraron Remotes válidos de venta")
    end
end})

miscTab:AddButton({Text = "God Mode / No Freeze", Func = function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        Library:Notify("God Mode Activado (contra frío en la cima)")
    else
        Library:Notify("Error: No se pudo aplicar el God Mode", 3)
    end
end})

-- Notificación final de carga exitosa
Library:Notify("💎 Mine Diamond Master cargado! Usa en Mine a Mountain u otros mining games.")
