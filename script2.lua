-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION
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
                    if item:IsA("Part") or item:IsA("MeshPart") then
                        if item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin") then
                            item.CFrame = root.CFrame
                        end
                    end
                end
            end
            task.wait(1)
        end
    end,
})

MiningTab:CreateButton({
    Name = "💎 Recolectar/Equipar Diamantes Gigantes (VIP)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
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
            if rock:IsA("Part") or rock:IsA("MeshPart") then
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

-- 📍 NUEVA ADICIÓN: Selector para trasladar y dejar caer minerales a los pies
local OreDropdown = VisualsTab:CreateDropdown({
    Name = "🧲 Trasladar Mineral Seleccionado (Caída Natural)",
    Options = {"Ninguno"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "OreTeleportSelector",
    Callback = function(Options)
        local targetName = Options[1]
        local root = getRoot()
        if root and targetName and targetName ~= "" and targetName ~= "Ninguno" then
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == targetName then
                    -- Lo posiciona un poco arriba y enfrente para que caiga fluidamente
                    item.CFrame = root.CFrame * CFrame.new(0, 4, -2)
                    
                    -- Asegurar caída natural desanclando la pieza localmente si el juego la fijó
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

-- Bucle constante mapeando los nombres y actualizando el Dropdown dinámicamente
task.spawn(function()
    while task.wait(2) do
        local availableOres = {}
        local checkedNames = {}
        
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item:IsA("Part") or item:IsA("MeshPart")) and (string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "ore") or string.match(item.Name:lower(), "gem")) then
                -- Lógica ESP existente
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

                -- Alimentar la lista del selector (evitando duplicados en el menú)
                if not checkedNames[item.Name] then
                    checkedNames[item.Name] = true
                    table.insert(availableOres, item.Name)
                end
            end
        end
        
        -- Refrescar las opciones del selector en tiempo real
        if #availableOres > 0 then
            OreDropdown:Refresh(availableOres)
        else
            OreDropdown:Refresh({"Ninguno"})
        end
    end
end)

VisualsTab:CreateButton({
    Name = "🔓 Desbloquear/Ver Secretos del Mapa",
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

VisualsTab:CreateButton({
    Name = "👕 Unlock Outfits & Skins (Bypass visual)",
    Callback = function()
        for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (string.match(obj.Name:lower(), "outfit") or string.match(obj.Name:lower(), "skin") or string.match(obj.Name:lower(), "equip") or string.match(obj.Name:lower(), "unlock")) then
                pcall(function() obj:FireServer(true) end)
                pcall(function() obj:FireServer("EquipAll") end)
            end
        end
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") or gui:IsA("Frame") then
                if string.match(gui.Name:lower(), "lock") or string.match(gui.Name:lower(), "padlock") then
                    gui.Visible = false
                end
            end
        end
        Rayfield:Notify({Title = "Outfits", Content = "Candados de skins ocultos y remotos ejecutados.", Duration = 4})
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