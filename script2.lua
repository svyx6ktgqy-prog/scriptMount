-- =====================================================================
-- 💎 MINE DIAMOND MASTER - MOD MENU (UNIVERSAL FIX)
-- Compatible con Delta, Fluxus, Krnl, etc.
-- =====================================================================

-- Esperar a que el juego cargue completamente
if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. Cargar la interfaz visual (LinoriaLib - Repositorio estable)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- 2. Crear Ventana Principal
local Window = Library:CreateWindow({
    Title = '💎 Mine Diamond Master | Universal Menu',
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

-- 4. Servicios y Variables Globales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function getHumanoid()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

-- =====================================================================
-- LÓGICA DE FUNCIONES UNIVERSALES
-- =====================================================================

-- Lógica para ESP de Jugadores (Universal)
local espEnabled = false
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("UniversalESP")
            
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UniversalESP"
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
                highlight.Enabled = true
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
end)

-- Lógica de Salto Infinito Real
local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Lógica de God Mode (Client-Sided)
local godModeEnabled = false
RunService.Stepped:Connect(function()
    if godModeEnabled then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- =====================================================================
-- CONFIGURACIÓN DE SECCIONES (UI ELEMENTS)
-- =====================================================================

-- Pestaña: Visuals
local visualsTab = Tabs.Main:AddLeftGroupbox("Visuales / ESP")

visualsTab:AddToggle("PlayerESP", {Text = "Activar Player ESP", Default = false, Callback = function(v)
    espEnabled = v
end})

-- Pestaña: Player Mods
local playerTab = Tabs.Player:AddLeftGroupbox("Modificaciones de Jugador")

playerTab:AddToggle("SuperJump", {Text = "Super Salto", Default = false, Callback = function(v)
    local humanoid = getHumanoid()
    if humanoid then
        if v then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 150
            -- Por si el juego usa JumpHeight en vez de JumpPower:
            if humanoid.JumpHeight then humanoid.JumpHeight = 50 end 
        else
            humanoid.JumpPower = 50
            if humanoid.JumpHeight then humanoid.JumpHeight = 7.2 end
        end
    end
end})

playerTab:AddToggle("InfJump", {Text = "Salto Infinito Real", Default = false, Callback = function(v)
    infJumpEnabled = v
end})

playerTab:AddSlider("Backpack", {Text = "Aumentar Mochila (Local)", Min = 1, Max = 100, Default = 1, Rounding = 0, Callback = function(v)
    local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats")
    if stats then
        local capacity = stats:FindFirstChild("MaxCapacity") or stats:FindFirstChild("BagSize") or stats:FindFirstChild("Mochila")
        if capacity and capacity:IsA("ValueBase") then
            capacity.Value = v
        end
    end
end})

-- Pestaña: Más Opciones (Misc)
local miscTab = Tabs.Misc:AddLeftGroupbox("Utilidades")

miscTab:AddToggle("GodMode", {Text = "God Mode (Anti-Daño Local)", Default = false, Callback = function(v)
    godModeEnabled = v
    if v then Library:Notify("God Mode Activado (Solo funciona si el daño es local)") end
end})

miscTab:AddButton({Text = "Auto Sell (Fuerza Bruta)", Func = function()
    local found = false
    -- Envolver en pcall para evitar que el script crashee si un remote está protegido
    for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "sell") or string.find(remote.Name:lower(), "deposit")) then
            pcall(function()
                remote:FireServer()
                found = true
            end)
        end
    end
    if found then
        Library:Notify("Intentando Auto Sell...")
    else
        Library:Notify("No se encontraron Remotes válidos de venta.", 3)
    end
end})

-- Interfaz Final
Library:SetWatermark('Mine Diamond Master | Universal')
Library:Notify("💎 Menú cargado correctamente. ¡Disfruta!")