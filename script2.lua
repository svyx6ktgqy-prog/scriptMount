-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION v2.0
-- UI: Rayfield | Anti-Double Execute | Funciones de Minería Avanzadas
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

-- =====================================================================
-- 🖼️ INYECCIÓN DE WALLPAPER (PAISAJE) EN RAYFIELD
-- =====================================================================
task.spawn(function()
    task.wait(2)
    for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if gui:IsA("Frame") and gui.Name == "Main" and gui.Parent and gui.Parent.Name == "Rayfield" then
            local wallpaper = Instance.new("ImageLabel")
            wallpaper.Name = "RayfieldWallpaper"
            wallpaper.Size = UDim2.new(1, 0, 1, 0)
            wallpaper.Position = UDim2.new(0, 0, 0, 0)
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

MiningTab:CreateButton({
    Name = "🧲 Atraer Diamantes/Items (Esparcidos)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") then
                local n = item.Name:lower()
                if item:FindFirstChild("TouchInterest") or string.match(n, "gem") or string.match(n, "diamond") or string.match(n, "coin") then
                    
                    local randomX = math.random(-15, 15)
                    local randomY = math.random(3, 8) 
                    local randomZ = math.random(-15, 15)
                    
                    pcall(function()
                        item.Anchored = false
                        item.Velocity = Vector3.new(0, -2, 0) 
                        item.RotVelocity = Vector3.zero
                    end)
                    
                    item.CFrame = CFrame.new(root.Position + Vector3.new(randomX, randomY, randomZ))
                    
                    count = count + 1
                    
                    if count % 20 == 0 then 
                        task.wait() 
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Imán Seguro Activado", Content = "Atraídos " .. count .. " objetos. Esparcidos sin lag.", Duration = 4})
    end,
})

MiningTab:CreateButton({
    Name = "💎 Recolectar/Equipar Diamantes Gigantes (VIP)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") then
                local name = item.Name:lower()
                if string.match(name, "huge") or string.match(name, "big") or string.match(name, "giant") or string.match(name, "master") then
                    item.CFrame = root.CFrame
                    local touch = item:FindFirstChild("TouchInterest")
                    if touch and firetouchinterest then
                        firetouchinterest(root, item, 0)
                        task.wait(0.01)
                        firetouchinterest(root, item, 1)
                        count = count + 1
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Extracción Masiva", Content = "Diamantes gigantes ("..count..") recolectados y equipados.", Duration = 4})
    end,
})

MiningTab:CreateButton({
    Name = "💥 Super Punch / Nuke Rocks (Local)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        for _, rock in ipairs(workspace:GetDescendants()) do
            if rock:IsA("BasePart") then
                local name = rock.Name:lower()
                if string.match(name, "rock") or string.match(name, "stone") or string.match(name, "ore") or string.match(name, "mountain") then
                    if (rock.Position - root.Position).Magnitude < 100 then
                        rock:Destroy()
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Montañas Despejadas", Content = "Rocas cercanas destruidas (Client-Side).", Duration = 3})
    end,
})

-- 📍 NUEVA ADICIÓN: Botón robusto para detonar explosivos en el juego
MiningTab:CreateButton({
    Name = "💣 Detonar/Lanzar Explosivos",
    Callback = function()
        local count = 0
        local root = getRoot()
        
        -- 1. Intentar disparar eventos remotos de explosiones
        for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                if string.match(n, "explod") or string.match(n, "bomb") or string.match(n, "detonat") or string.match(n, "tnt") or string.match(n, "c4") or string.match(n, "nuke") or string.match(n, "dynamite") or string.match(n, "blast") then
                    pcall(function() remote:FireServer() end)
                    pcall(function() remote:FireServer(true) end)
                    count = count + 1
                end
            end
        end
        
        -- 2. Si hay explosivos físicos en el mapa, traerlos y tocarlos
        if root then
            for _, item in ipairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") then
                    local iname = item.Name:lower()
                    if string.match(iname, "tnt") or string.match(iname, "bomb") or string.match(iname, "explosive") or string.match(iname, "c4") or string.match(iname, "dynamite") or string.match(iname, "missile") then
                        -- Los trae al frente del jugador
                        item.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                        local touch = item:FindFirstChild("TouchInterest")
                        if touch and firetouchinterest then
                            firetouchinterest(root, item, 0)
                            task.wait(0.01)
                            firetouchinterest(root, item, 1)
                        end
                        count = count + 1
                    end
                end
            end
        end
        
        Rayfield:Notify({Title = "Fuego en el hoyo", Content = "Comandos explosivos enviados: " .. count, Duration = 4})
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

-- =====================================================================
-- PESTAÑA 2: 👁️ VISUALES Y ESP (Jugadores Animados, Tracers & Ores)
-- =====================================================================
local VisualsTab = Window:CreateTab("Visuales & ESP", 4483362458)

local espEnabled = false
local Tracers = {}

VisualsTab:CreateToggle({
    Name = "🌈 Activar Player ESP (Rainbow + Tracers)",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            for _, tracer in pairs(Tracers) do tracer:Remove() end
            Tracers = {}
        end
    end,
})

RunService.RenderStepped:Connect(function()
    local hue = tick() % 3 / 3
    local rainbowColor = Color3.fromHSV(hue, 1, 1)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local highlight = player.Character:FindFirstChild("UniversalESP")
            
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UniversalESP"
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
                highlight.Enabled = true
                highlight.FillColor = rainbowColor
                highlight.OutlineColor = rainbowColor

                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if not Tracers[player] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    line.Transparency = 1
                    Tracers[player] = line
                end
                
                if onScreen then
                    Tracers[player].Visible = true
                    Tracers[player].From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    Tracers[player].To = Vector2.new(vector.X, vector.Y)
                    Tracers[player].Color = rainbowColor
                else
                    Tracers[player].Visible = false
                end
            else
                if highlight then highlight.Enabled = false end
                if Tracers[player] then
                    Tracers[player]:Remove()
                    Tracers[player] = nil
                end
            end
        else
            if Tracers[player] then
                Tracers[player]:Remove()
                Tracers[player] = nil
            end
        end
    end
end)

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

local OreDropdown = VisualsTab:CreateDropdown({
    Name = "🧲 Trasladar Mineral Seleccionado",
    Options = {"Ninguno"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "OreTeleportSelector",
    Callback = function(Options)
        local targetName = Options[1]
        local root = getRoot()
        if root and targetName and targetName ~= "" and targetName ~= "Ninguno" then
            for _, item in ipairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and item.Name == targetName then
                    item.CFrame = root.CFrame * CFrame.new(0, 4, -2)
                    pcall(function()
                        item.Anchored = false
                    end)
                    Rayfield:Notify({
                        Title = "Mineral Trasladado",
                        Content = "El objeto '" .. targetName .. "' ha caído a tus pies.",
                        Duration = 3
                    })
                    break
                end
            end
        end
    end,
})

-- 📍 MODIFICACIÓN: Detector de nombres universal super robusto
task.spawn(function()
    while task.wait(2) do
        local availableOres = {}
        local checkedNames = {}
        
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") then
                local n = item.Name:lower()
                
                -- Palabras clave masivas para captar cualquier tipo de mineral o gema sin importar el juego
                if string.match(n, "diamond") or string.match(n, "ore") or string.match(n, "gem") or string.match(n, "crystal") or string.match(n, "mineral") or string.match(n, "gold") or string.match(n, "iron") or string.match(n, "ruby") or string.match(n, "emerald") or string.match(n, "sapphire") or string.match(n, "rock") or string.match(n, "stone") or string.match(n, "coal") then
                    
                    if not item:FindFirstChild("OreESPGui") and oreEspEnabled then
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
                        
                        local val = item:FindFirstChildOfClass("NumberValue") or item:FindFirstChildOfClass("IntValue")
                        if val then txt.Text = "💎 " .. item.Name .. "\nValor: $" .. tostring(val.Value) end
                        
                        bill.Parent = item
                    end

                    if not checkedNames[item.Name] then
                        checkedNames[item.Name] = true
                        table.insert(availableOres, item.Name)
                    end
                end
            end
        end
        
        if #availableOres > 0 then
            OreDropdown:Refresh(availableOres)
        else
            OreDropdown:Refresh({"Ninguno"})
        end
    end
end)

-- 📍 MODIFICACIÓN: Desbloqueador supremo que fusiona UI Bypass, Remotos y Secretos del Mapa
VisualsTab:CreateButton({
    Name = "👕🔓 Desbloqueo Supremo (Outfits & Secretos)",
    Callback = function()
        -- 1. Inyección de remotos (Wardrobes, Skins, VIP)
        for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if string.match(n, "outfit") or string.match(n, "skin") or string.match(n, "equip") or string.match(n, "unlock") or string.match(n, "buy") or string.match(n, "purchase") or string.match(n, "secret") or string.match(n, "wardrobe") or string.match(n, "costume") then
                    pcall(function() obj:FireServer(true) end)
                    pcall(function() obj:FireServer("EquipAll") end)
                    pcall(function() obj:FireServer("UnlockAll") end)
                end
            end
        end
        
        -- 2. Eliminar candados de UI (Bypass Visual)
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("GuiObject") then
                local n = gui.Name:lower()
                if string.match(n, "lock") or string.match(n, "padlock") or string.match(n, "paywall") or string.match(n, "robux") then
                    gui.Visible = false
                end
            end
        end
        
        -- 3. Revelar secretos del mapa y atravesar paredes falsas
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if string.match(n, "secret") or string.match(n, "hidden") or string.match(n, "invisible") or string.match(n, "barrier") then
                    part.Transparency = 0.5 -- Lo vuelve semi-transparente para que sepas dónde está el secreto
                    part.CanCollide = false
                    part.Color = Color3.fromRGB(255, 0, 0) -- Lo tiñe de rojo
                end
            end
        end
        
        Rayfield:Notify({Title = "Desbloqueo Completado", Content = "Ropa, barreras ocultas y candados UI forzados.", Duration = 4})
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
            
            RunService.RenderStepped:Connect(function()
                if flying and root:FindFirstChild("FlyVelocity") then
                    local moveDir = getHumanoid().MoveDirection
                    root.FlyVelocity.Velocity = moveDir * 50
                end
            end)
        else
            if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        end
    end,
})

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
            if part:IsA("BasePart") and (string.match(part.Name:lower(), "portal") or string.match(part.Name:lower(), "teleport") or string.match(part.Name:lower(), "nextmap")) then
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
