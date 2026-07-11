-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION (VERSION FINAL INTEGRADA)
-- UI: Rayfield | Anti-Double Execute | Funciones de Minería Avanzadas
-- =====================================================================

if _G.MineDiamondLoaded then
    warn("El menú ya está en ejecución.")
    return
end
_G.MineDiamondLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "💎 Mine Diamond Master | Pro",
    LoadingTitle = "Cargando Herramientas de Minería...",
    LoadingSubtitle = "Aspecto iOS - Universal",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Wallpaper
task.spawn(function()
    task.wait(2)
    for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if gui:IsA("Frame") and gui.Name == "Main" and gui.Parent and gui.Parent.Name == "Rayfield" then
            local wallpaper = Instance.new("ImageLabel")
            wallpaper.Name = "RayfieldWallpaper"
            wallpaper.Size = UDim2.new(1, 0, 1, 0)
            wallpaper.BackgroundTransparency = 1
            wallpaper.Image = "rbxassetid://1378768007" 
            wallpaper.ImageTransparency = 0.65
            wallpaper.ScaleType = Enum.ScaleType.Crop
            wallpaper.ZIndex = 0 
            wallpaper.Parent = gui
            break
        end
    end
end)

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- =====================================================================
-- PESTAÑA 1: ⛏️ MINERÍA
-- =====================================================================
local MiningTab = Window:CreateTab("Minería", 4483362458)
local minValue = 5000000

MiningTab:CreateSlider({
    Name = "💰 Filtro Valor Mínimo ($)",
    Range = {5000000, 5000000000},
    Increment = 1000000,
    Suffix = "$",
    CurrentValue = 5000000,
    Callback = function(Value) minValue = Value end,
})

MiningTab:CreateButton({
    Name = "🧲 Atraer Diamantes Seleccionados (Filtro Activo)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item:IsA("Part") or item:IsA("MeshPart")) then
                local valObj = item:FindFirstChildOfClass("NumberValue") or item:FindFirstChildOfClass("IntValue")
                local val = valObj and valObj.Value or 0
                local n = item.Name:lower()
                if (string.match(n, "diamond") or string.match(n, "gem") or string.match(n, "ore")) and val >= minValue then
                    item.CFrame = root.CFrame * CFrame.new(math.random(-10,10), 5, math.random(-10,10))
                    pcall(function() item.Anchored = false end)
                    count = count + 1
                    if count % 20 == 0 then task.wait() end
                end
            end
        end
        Rayfield:Notify({Title = "Imán", Content = "Atraídos " .. count .. " items (Valor >= $"..minValue..")", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "💣 Detonar / Explotar Sitio (Explosive Mode)",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if string.match(n, "explosive") or string.match(n, "nuke") or string.match(n, "bomb") or string.match(n, "tnt") then
                if obj:IsA("BasePart") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        Rayfield:Notify({Title = "BOOM!", Content = "Sitio despejado de explosivos.", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "💎 Recolectar/Equipar Diamantes Gigantes (VIP)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, item in ipairs(workspace:GetDescendants()) do
            local name = item.Name:lower()
            if string.match(name, "huge") or string.match(name, "big") or string.match(name, "giant") or string.match(name, "master") then
                item.CFrame = root.CFrame
                if item:FindFirstChild("TouchInterest") and firetouchinterest then
                    firetouchinterest(root, item, 0)
                    firetouchinterest(root, item, 1)
                end
            end
        end
    end,
})

-- =====================================================================
-- PESTAÑA 2: 👁️ VISUALES
-- =====================================================================
local VisualsTab = Window:CreateTab("Visuales & ESP", 4483362458)
local oreEspEnabled = false

VisualsTab:CreateToggle({
    Name = "💎 ESP Diamantes y Rarezas",
    CurrentValue = false,
    Callback = function(Value) oreEspEnabled = Value end,
})

local OreDropdown = VisualsTab:CreateDropdown({
    Name = "💎 Spinner de Diamantes Disponibles",
    Options = {"Buscando..."},
    Callback = function(Option)
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == Option then
                item.CFrame = getRoot().CFrame * CFrame.new(0, 4, -2)
                pcall(function() item.Anchored = false end)
                break
            end
        end
    end,
})

-- Bucle robusto de actualización
task.spawn(function()
    while task.wait(3) do
        local found = {}
        for _, item in ipairs(workspace:GetDescendants()) do
            local n = item.Name:lower()
            -- Detección robusta de rarezas y tipos
            if (string.match(n, "diamond") or string.match(n, "legendary") or string.match(n, "mythic") or string.match(n, "common") or string.match(n, "rare") or string.match(n, "epic")) then
                if not table.find(found, item.Name) then table.insert(found, item.Name) end
            end
        end
        OreDropdown:Refresh(#found > 0 and found or {"No encontrado"})
    end
end)

-- =====================================================================
-- PESTAÑA 3: 🚀 MOVIMIENTO
-- =====================================================================
local MoveTab = Window:CreateTab("Movimiento", 4483362458)

MoveTab:CreateButton({
    Name = "🚪 Teleport al Siguiente Portal",
    Callback = function()
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("Part") and (string.match(p.Name:lower(), "portal") or string.match(p.Name:lower(), "teleport")) then
                getRoot().CFrame = p.CFrame
                return
            end
        end
    end,
})

MoveTab:CreateButton({
    Name = "🔄 Server Hop",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
    end,
})