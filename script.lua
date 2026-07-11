-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION
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
    LoadingTitle = "Cargando Herramientas...",
    LoadingSubtitle = "Script Optimizado",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- =====================================================================
-- 🖼️ INYECCIÓN DE WALLPAPER
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
-- PESTAÑA 1: ⛏️ MINERÍA
-- =====================================================================
local MiningTab = Window:CreateTab("Minería", 4483362458)

MiningTab:CreateButton({
    Name = "🧲 Atraer Diamantes/Items (Esparcidos)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        local count = 0
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                if item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin") then
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
                    if count % 20 == 0 then task.wait() end
                end
            end
        end
        Rayfield:Notify({Title = "Imán Activado", Content = "Atraídos " .. count .. " objetos.", Duration = 4})
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
        Rayfield:Notify({Title = "Extracción Masiva", Content = "Gigantes ("..count..") recolectados.", Duration = 4})
    end,
})

MiningTab:CreateButton({
    Name = "💣 Detonar Sitio (Explosive Trigger)",
    Callback = function()
        local found = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if string.match(obj.Name:lower(), "kill") or string.match(obj.Name:lower(), "explode") or string.match(obj.Name:lower(), "nuke") or string.match(obj.Name:lower(), "dynamite") then
                if obj:IsA("RemoteEvent") then
                    obj:FireServer()
                    found = true
                elseif obj:IsA("Tool") or obj:IsA("Model") then
                    pcall(function() obj.Parent = LocalPlayer.Character end)
                    found = true
                end
            end
        end
        if found then
            Rayfield:Notify({Title = "Explosión", Content = "Trigger activado.", Duration = 3})
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
                    if (rock.Position - root.Position).Magnitude < 100 then
                        rock:Destroy()
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Despejado", Content = "Rocas cercanas destruidas.", Duration = 3})
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
        Rayfield:Notify({Title = "Mejoras", Content = "Intentando mejorar pico...", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 2: 👁️ VISUALES Y ESP
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
    Name = "💎 ESP Diamantes y Rarezas",
    CurrentValue = false,
    Flag = "OreESP",
    Callback = function(Value) 
        oreEspEnabled = Value
        if not Value then
            for _, item in ipairs(workspace:GetDescendants()) do
                if item.Name == "OreESPGui" then item:Destroy() end
            end
            Rayfield:Notify({Title = "Visuales", Content = "ESP de Minerales limpiado.", Duration = 2})
        end
    end,
})

local selectedOre = "Ninguno"

local OreDropdown = VisualsTab:CreateDropdown({
    Name = "🔍 Seleccionar Mineral / Item",
    Options = {"Ninguno"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "OreTeleportSelector",
    Callback = function(Options)
        selectedOre = Options[1]
    end,
})

VisualsTab:CreateButton({
    Name = "🚀 Viajar al Mineral (To Go)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        if selectedOre and selectedOre ~= "Ninguno" and selectedOre ~= "" then
            local found = false
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == selectedOre then
                    local isCollectible = item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin")
                    if isCollectible then
                        root.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                        Rayfield:Notify({Title = "Teletransporte", Content = "Viajando a: " .. selectedOre, Duration = 2})
                        found = true
                        break
                    end
                end
            end
            if not found then Rayfield:Notify({Title = "Error", Content = "No encontrado.", Duration = 3}) end
        else
            Rayfield:Notify({Title = "Aviso", Content = "Selecciona un mineral primero.", Duration = 3})
        end
    end,
})

VisualsTab:CreateButton({
    Name = "🧲 Traer Mineral hacia Mí (Get)",
    Callback = function()
        local root = getRoot()
        if not root then return end
        if selectedOre and selectedOre ~= "Ninguno" and selectedOre ~= "" then
            local found = false
            for _, item in ipairs(workspace:GetDescendants()) do
                if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == selectedOre then
                    local isCollectible = item:FindFirstChild("TouchInterest") or string.match(item.Name:lower(), "gem") or string.match(item.Name:lower(), "diamond") or string.match(item.Name:lower(), "coin")
                    if isCollectible then
                        item.CFrame = root.CFrame * CFrame.new(0, 4, -3)
                        pcall(function() item.Anchored = false end)
                        Rayfield:Notify({Title = "Objeto Atraído", Content = "Traído hacia ti.", Duration = 2})
                        found = true
                        break
                    end
                end
            end
            if not found then Rayfield:Notify({Title = "Error", Content = "No se pudo traer.", Duration = 3}) end
        else
            Rayfield:Notify({Title = "Aviso", Content = "Selecciona un mineral primero.", Duration = 3})
        end
    end,
})

task.spawn(function()
    while task.wait(1.5) do
        local availableOres = {}
        local foundNames = {}
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local nameLower = item.Name:lower()
                local isMatch = item:FindFirstChild("TouchInterest") or string.match(nameLower, "gem") or string.match(nameLower, "diamond") or string.match(nameLower, "coin")
                if isMatch then
                    if not foundNames[item.Name] then
                        table.insert(availableOres, item.Name)
                        foundNames[item.Name] = true
                    end
                    if oreEspEnabled and not item:FindFirstChild("OreESPGui") then
                        local bill = Instance.new("BillboardGui", item)
                        bill.Name = "OreESPGui"
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0, 100, 0, 50)
                        local txt = Instance.new("TextLabel", bill)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.Text = "✨ " .. item.Name
                        txt.TextColor3 = Color3.fromRGB(255, 255, 0)
                        txt.BackgroundTransparency = 1
                    end
                end
            end
        end
        table.sort(availableOres)
        OreDropdown:Refresh(#availableOres > 0 and availableOres or {"Ninguno"})
    end
end)

VisualsTab:CreateButton({
    Name = "🔓 Unlock Total (Ropas/Secretos)",
    Callback = function()
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if string.match(name, "unlock") or string.match(name, "get") or string.match(name, "buy") or string.match(name, "grant") then
                    pcall(function() obj:FireServer("all") end)
                    pcall(function() obj:FireServer(true) end)
                end
            end
        end
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("GuiObject") and (gui.Name:lower():find("lock") or gui.Name:lower():find("padlock")) then
                gui.Visible = false
            end
        end
        Rayfield:Notify({Title = "Unlock", Content = "Desbloqueos forzados.", Duration = 4})
    end,
})

VisualsTab:CreateButton({
    Name = "🔓 Desbloquear Secretos del Mapa",
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
-- PESTAÑA 3: 🌌 MAPAS Y BARRERAS
-- =====================================================================
local MapTab = Window:CreateTab("Mapas & Zonas", 4483362458)
MapTab:CreateSection("Progresión Rápida")

MapTab:CreateButton({
    Name = "🚪 Forze TP ZONE SECRET",
    Callback = function()
        local root = getRoot()
        if not root then return end
        local found = false
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if string.match(n, "portal") and not string.match(n, "spawn") and not string.match(n, "lobby") then
                    root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                    found = true
                    local touch = part:FindFirstChild("TouchInterest")
                    if touch and firetouchinterest then
                        firetouchinterest(root, part, 0)
                        task.wait(0.1)
                        firetouchinterest(root, part, 1)
                    end
                    Rayfield:Notify({Title = "Salto de Mapa", Content = "Teletransportado.", Duration = 3})
                    return
                end
            end
        end
    end,
})

MapTab:CreateButton({
    Name = "🧱 Eliminar Muros Invisibles / Barreras VIP",
    Callback = function()
        local wallsRemoved = 0
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if string.match(n, "barrier") or string.match(n, "wall") or string.match(n, "border") or string.match(n, "vip") or part.Transparency == 1 then
                    if part.CanCollide == true and part.Name ~= "HumanoidRootPart" and part.Name ~= "Baseplate" then
                        part.CanCollide = false
                        wallsRemoved = wallsRemoved + 1
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Noclip", Content = wallsRemoved .. " barreras eliminadas.", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 4: 🚀 MOVIMIENTO Y #TROLL (ACTUALIZADA)
-- =====================================================================
local MoveTab = Window:CreateTab("Movimiento & Troll", 4483362458)

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

-- 🎭 APARTADO TROLL (MEJORADO CON ITERACIONES DE ENTORNO FÍSICO)
local TrollSection = MoveTab:CreateSection("#Troll") 

local selectedTrollPlayer = "Ninguno"
local trollFollowEnabled = false

local TrollDropdown = MoveTab:CreateDropdown({
    Name = "👤 Seleccionar Víctima (Jugador)",
    Options = {"Ninguno"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TrollPlayerSelector",
    Callback = function(Options)
        selectedTrollPlayer = Options[1]
    end,
})

MoveTab:CreateToggle({
    Name = "👣 Activar Modo Sombra Completo",
    CurrentValue = false,
    Flag = "TrollFollowToggle",
    Callback = function(Value)
        trollFollowEnabled = Value
        if Value then
            if selectedTrollPlayer == "Ninguno" or selectedTrollPlayer == "" then
                Rayfield:Notify({Title = "Aviso #Troll", Content = "Selecciona un jugador válido.", Duration = 3})
                return
            end
            
            -- 🌟 MEJORA 1: Teletransporte instantáneo detrás de la víctima al activar el botón
            pcall(function()
                local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and localRoot then
                        local behindPos = (targetRoot.CFrame * CFrame.new(0, 0, 4)).Position
                        localRoot.CFrame = CFrame.lookAt(behindPos, targetRoot.Position)
                    end
                end
            end)
            
            Rayfield:Notify({Title = "Modo Troll", Content = "Sincronizado con: " .. selectedTrollPlayer, Duration = 3})
            
            task.spawn(function()
                while trollFollowEnabled do
                    task.wait(0.02)
                    if selectedTrollPlayer and selectedTrollPlayer ~= "Ninguno" then
                        local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                        if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local localHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHum and localRoot and localHum then
                                -- 🌟 MEJORA 2: Movimiento real de joystick izquierdo a tope
                                local behindPosition = (targetRoot.CFrame * CFrame.new(0, 0, 4)).Position
                                local distanceToShadow = (localRoot.Position - behindPosition).Magnitude
                                localHum.WalkSpeed = targetHum.WalkSpeed
                                
                                if distanceToShadow > 1.5 then
                                    -- Calcula el vector exacto de dirección y empuja el joystick virtual al máximo (tope)
                                    local moveDirection = (behindPosition - localRoot.Position).Unit
                                    localHum:Move(moveDirection, false)
                                else
                                    -- Freno total e instantáneo únicamente si ya está acoplado detrás
                                    localHum:Move(Vector3.new(0,0,0), false)
                                end
                                
                                -- Mantener la orientación de la víctima
                                localRoot.CFrame = CFrame.lookAt(localRoot.Position, localRoot.Position + targetRoot.CFrame.LookVector)
                                
                                -- Replicar salto
                                local targetState = targetHum:GetState()
                                if targetHum.Jump or targetState == Enum.HumanoidStateType.Jumping or targetState == Enum.HumanoidStateType.Freefall then
                                    localHum.Jump = true
                                end
                                
                                -- 🌟 MEJORA 3: Escáner de golpes por toques de pantalla fuera de los botones
                                local isAttacking = false
                                pcall(function()
                                    for _, anim in ipairs(targetHum:GetPlayingAnimationTracks()) do
                                        local animName = anim.Name:lower()
                                        -- Filtro: Si ejecuta cualquier animación que no pertenezca a moverse o quedarse quieto, es un toque de pantalla (golpe)
                                        if animName:find("attack") or animName:find("swing") or animName:find("punch") or animName:find("slash") or animName:find("hit") or animName:find("tool") or animName:find("mine") or animName:find("pico") or (not animName:find("idle") and not animName:find("walk") and not animName:find("run") and not animName:find("jump") and not animName:find("fall")) then
                                            isAttacking = true 
                                            break
                                        end
                                    end
                                end)
                                
                                if isAttacking then
                                    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if localTool then localTool:Activate() end
                                end
                                
                                -- Absorción magnética automática
                                pcall(function()
                                    if firetouchinterest then
                                        local regionParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 8)
                                        for _, part in ipairs(regionParts) do
                                            local nameLower = part.Name:lower()
                                            if part:FindFirstChild("TouchInterest") or nameLower:find("gem") or nameLower:find("diamond") or nameLower:find("coin") or nameLower:find("ore") or nameLower:find("item") then
                                                firetouchinterest(localRoot, part, 0)
                                                task.wait()
                                                firetouchinterest(localRoot, part, 1)
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Modo Troll", Content = "Apagado.", Duration = 2})
        end
    end,
})

local function updateTrollDropdown()
    local currentPlayers = {"Ninguno"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(currentPlayers, p.Name) end
    end
    TrollDropdown:Refresh(currentPlayers)
    TpDropdown:Refresh(currentPlayers)
end
Players.PlayerAdded:Connect(updateTrollDropdown)
Players.PlayerRemoving:Connect(updateTrollDropdown)
updateTrollDropdown()
