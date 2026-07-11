-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION
-- UI: Rayfield | Anti-Double Execute | Funciones de Minería
-- =====================================================================

-- Evitar que el script se ejecute dos veces
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

local function getHumanoid()
    if LocalPlayer.Character then return LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function getRoot()
    if LocalPlayer.Character then return LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- =====================================================================
-- PESTAÑA 1: ⛏️ MINERÍA Y AUTOMATIZACIÓN
-- =====================================================================
local MiningTab = Window:CreateTab("Minería", 4483362458)

local magnetEnabled = false
MiningTab:CreateToggle({
    Name = "🧲 Imán de Diamantes/Items",
    CurrentValue = false,
    Flag = "Magnet",
    Callback = function(Value)
        magnetEnabled = Value
        while magnetEnabled do
            local root = getRoot()
            if root then
                for _, item in ipairs(workspace:GetDescendants()) do
                    -- Busca partes que se puedan recoger (tienen TouchInterest o nombres clave)
                    if item:IsA("Part") or item:IsA("MeshPart") then
                        if item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin") then
                            item.CFrame = root.CFrame
                        end
                    end
                end
            end
            task.wait(1) -- Espera un segundo para no crashear el juego
        end
    end,
})

MiningTab:CreateButton({
    Name = "💥 Super Punch / Nuke Rocks (Local)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, rock in ipairs(workspace:GetDescendants()) do
            if rock:IsA("Part") or rock:IsA("MeshPart") then
                local name = rock.Name:lower()
                if string.match(name, "rock") or string.match(name, "stone") or string.match(name, "ore") or string.match(name, "mountain") then
                    -- Si estás cerca, destruye la roca localmente
                    if (rock.Position - root.Position).Magnitude < 100 then
                        rock:Destroy()
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Montañas Despejadas", Content = "Rocas cercanas destruidas (Client-Side).", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "🎁 Reclamar Todos los Regalos",
    Callback = function()
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if string.match(name, "claim") or string.match(name, "gift") or string.match(name, "reward") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
        Rayfield:Notify({Title = "Regalos", Content = "Se intentó reclamar todo.", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "⬆️ Auto Upgrade (Fuerza Bruta)",
    Callback = function()
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if string.match(name, "upgrade") or string.match(name, "buy") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
        Rayfield:Notify({Title = "Mejoras", Content = "Intentando mejorar el pico...", Duration = 3})
    end,
})

MiningTab:CreateButton({
    Name = "☄️ Hacer Caer Meteoritos (Si es posible)",
    Callback = function()
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                if string.match(remote.Name:lower(), "meteor") or string.match(remote.Name:lower(), "event") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
        Rayfield:Notify({Title = "Evento", Content = "Buscando remotes de meteoritos...", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 1: VISUALES
-- =====================================================================
local VisualsTab = Window:CreateTab("EspVIP", 4483362458)
local espEnabled = false

VisualsTab:CreateToggle({
    Name = "Activar Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        espEnabled = Value
    end,
})

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

-- =====================================================================
-- PESTAÑA 2: 👁️ VISUALES Y ESP (Ores & Jugadores)
-- =====================================================================
local VisualsTab = Window:CreateTab("Visuales", 4483362458)

local oreEspEnabled = false
VisualsTab:CreateToggle({
    Name = "💎 ESP Diamantes y Minerales",
    CurrentValue = false,
    Flag = "OreESP",
    Callback = function(Value)
        oreEspEnabled = Value
        if not Value then
            for _, esp in ipairs(workspace:GetDescendants()) do
                if esp.Name == "OreESPGui" then esp:Destroy() end
            end
        end
    end,
})

-- Bucle constante para buscar minerales nuevos y ponerles ESP
task.spawn(function()
    while task.wait(2) do
        if oreEspEnabled then
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and (string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "ore") or string.match(item.Name:lower(), "gem")) then
                    if not item:FindFirstChild("OreESPGui") then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "OreESPGui"
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 100, 0, 50)
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = "💎 " .. item.Name .. "\n[Valor Oculto]"
                        txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                        txt.TextStrokeTransparency = 0
                        txt.Parent = bill
                        
                        -- Intentar buscar si tiene un valor numérico asignado
                        local val = item:FindFirstChildOfClass("NumberValue") or item:FindFirstChildOfClass("IntValue")
                        if val then txt.Text = "💎 " .. item.Name .. "\nValor: $" .. tostring(val.Value) end
                        
                        bill.Parent = item
                    end
                end
            end
        end
    end
end)

VisualsTab:CreateButton({
    Name = "🔓 Desbloquear/Ver Secretos",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if string.match(part.Name:lower(), "secret") or string.match(part.Name:lower(), "hidden") then
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = false
                end
            end
        end
        Rayfield:Notify({Title = "Secretos", Content = "Objetos ocultos revelados.", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 3: 🚀 MOVIMIENTO Y MAPA
-- =====================================================================
local MoveTab = Window:CreateTab("Movimiento", 4483362458)

local flying = false
MoveTab:CreateToggle({
    Name = "🦅 Fly (Volar)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        flying = Value
        local root = getRoot()
        if not root then return end
        
        if flying then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            
            -- Lógica básica de vuelo con cámara
            RunService.RenderStepped:Connect(function()
                if flying and root:FindFirstChild("FlyVelocity") then
                    local cam = workspace.CurrentCamera
                    local moveDir = getHumanoid().MoveDirection
                    root.FlyVelocity.Velocity = moveDir * 50
                end
            end)
        else
            if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        end
    end,
})

-- Selector de Jugadores para Teleport
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
end

local TpDropdown = MoveTab:CreateDropdown({
    Name = "🎯 Teletransportarse a Jugador",
    Options = playerNames,
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TpPlayer",
    Callback = function(Options)
        local targetName = Options[1]
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                Rayfield:Notify({Title = "Teleport", Content = "Viajaste a " .. targetName, Duration = 2})
            end
        end
    end,
})

-- Actualizar lista de jugadores si alguien entra o sale
Players.PlayerAdded:Connect(function(p)
    table.insert(playerNames, p.Name)
    TpDropdown:Refresh(playerNames)
end)
Players.PlayerRemoving:Connect(function(p)
    for i, name in ipairs(playerNames) do
        if name == p.Name then table.remove(playerNames, i) break end
    end
    TpDropdown:Refresh(playerNames)
end)

MoveTab:CreateButton({
    Name = "🚪 Teleport al Siguiente Mapa/Portal",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") and (string.match(part.Name:lower(), "portal") or string.match(part.Name:lower(), "teleport") or string.match(part.Name:lower(), "nextmap")) then
                root.CFrame = part.CFrame
                Rayfield:Notify({Title = "Portal Encontrado", Content = "Teletransportando...", Duration = 3})
                return
            end
        end
        Rayfield:Notify({Title = "Error", Content = "No se encontraron portales en el mapa.", Duration = 3})
    end,
})

MoveTab:CreateButton({
    Name = "🔄 Server Hop (Cambiar de Servidor)",
    Callback = function()
        Rayfield:Notify({Title = "Server Hop", Content = "Buscando un nuevo servidor...", Duration = 3})
        local serversUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(serversUrl)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end,
})