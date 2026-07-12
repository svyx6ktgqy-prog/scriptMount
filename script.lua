-- =====================================================================
-- 💎 MINE DIAMOND MASTER - PRO EDITION V3 (FINAL MOBILE FIX)
-- UI: Rayfield | Movimiento por BodyPosition | Auto-Swing por Proximidad
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

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "💎 Mine Diamond Master | Pro V3",
    LoadingTitle = "Cargando Motor Físico...",
    LoadingSubtitle = "Joystick y Auto-Golpe Corregidos",
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
    Callback = function(Options) selectedOre = Options[1] end,
})

VisualsTab:CreateButton({
    Name = "🚀 Viajar al Mineral (To Go)",
    Callback = function()
        local root = getRoot()
        if not root or selectedOre == "Ninguno" or selectedOre == "" then return end
        for _, item in ipairs(workspace:GetDescendants()) do
            if (item:IsA("Part") or item:IsA("MeshPart")) and item.Name == selectedOre then
                root.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                break
            end
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

-- =====================================================================
-- PESTAÑA 3: 🌌 MAPAS Y BARRERAS
-- =====================================================================
local MapTab = Window:CreateTab("Mapas & Zonas", 4483362458)

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
-- PESTAÑA 4: 🚀 MOVIMIENTO Y #TROLL (REDISEÑO DE MODO SOMBRA)
-- =====================================================================
local MoveTab = Window:CreateTab("Movimiento & Troll", 4483362458)

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
            if root then root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end
        end
    end,
})

MoveTab:CreateSection("#Troll") 

local selectedTrollPlayer = "Ninguno"
local trollFollowEnabled = false

local TrollDropdown = MoveTab:CreateDropdown({
    Name = "👤 Seleccionar Víctima (Jugador)",
    Options = {"Ninguno"},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TrollPlayerSelector",
    Callback = function(Options) selectedTrollPlayer = Options[1] end
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
            
            -- Teletransporte inicial exacto detrás del objetivo
            pcall(function()
                local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and localRoot then
                        local behindPos = (targetRoot.CFrame * CFrame.new(0, 0, 3)).Position
                        localRoot.CFrame = CFrame.lookAt(behindPos, targetRoot.Position)
                    end
                end
            end)
            
            Rayfield:Notify({Title = "Modo Sombra V3", Content = "Enlazado físico activo con: " .. selectedTrollPlayer, Duration = 3})
            
            task.spawn(function()
                while trollFollowEnabled do
                    task.wait(0.01) -- Ciclo de refresco de físicas ultra veloz
                    if selectedTrollPlayer and selectedTrollPlayer ~= "Ninguno" then
                        local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                        if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local localHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHum and localRoot and localHum then
                                
                                -- 🌟 1. ROTACIÓN INTEGRAL (BodyGyro)
                                local bg = localRoot:FindFirstChild("TrollGyro")
                                if not bg then
                                    bg = Instance.new("BodyGyro")
                                    bg.Name = "TrollGyro"
                                    bg.maxTorque = Vector3.new(0, 999999, 0) -- Forzado exclusivo en eje Y horizontal
                                    bg.P = 60000 
                                    bg.D = 400
                                    bg.Parent = localRoot
                                end
                                bg.CFrame = CFrame.lookAt(Vector3.zero, targetRoot.CFrame.LookVector)

                                -- 🌟 2. ARRASTRE FÍSICO MAGNÉTICO (BodyPosition) -> CORRIGE JOYSTICK Y PIES
                                local behindPosition = (targetRoot.CFrame * CFrame.new(0, 0, 2.8)).Position
                                
                                local bp = localRoot:FindFirstChild("TrollPosition")
                                if not bp then
                                    bp = Instance.new("BodyPosition")
                                    bp.Name = "TrollPosition"
                                    -- ¡CLAVE! MaxForce en Y es 0. Permite caídas, gravedad y saltos nativos sin romper el control
                                    bp.maxForce = Vector3.new(600000, 0, 600000) 
                                    bp.P = 40000
                                    bp.D = 1000
                                    bp.Parent = localRoot
                                end
                                bp.Position = behindPosition
                                
                                -- Sincronización nativa de WalkSpeed
                                localHum.WalkSpeed = targetHum.WalkSpeed

                                -- Sincronización real de saltos por estados del motor
                                local targetState = targetHum:GetState()
                                if targetHum.Jump or targetState == Enum.HumanoidStateType.Jumping or targetState == Enum.HumanoidStateType.Freefall then
                                    localHum.Jump = true
                                end
                                
                                -- 🌟 3. DETECTOR DE MINERÍA POR PROXIMIDAD (CORRIGE GOLPE DE PICO)
                                local targetHasTool = targetPlayer.Character:FindFirstChildOfClass("Tool") ~= nil
                                local nearOre = false
                                
                                -- Escanea si el objetivo está a rango de minar un mineral
                                pcall(function()
                                    local nearbyParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 7)
                                    for _, part in ipairs(nearbyParts) do
                                        local n = part.Name:lower()
                                        if string.match(n, "gem") or string.match(n, "diamond") or string.match(n, "coin") or string.match(n, "ore") or string.match(n, "rock") or string.match(n, "stone") then
                                            nearOre = true
                                            break
                                        end
                                    end
                                end)
                                
                                local isAttacking = false
                                if targetHasTool and nearOre then
                                    isAttacking = true
                                else
                                    -- Verificación de respaldo por si el juego usa IDs de animación alternas
                                    pcall(function()
                                        for _, anim in ipairs(targetHum:GetPlayingAnimationTracks()) do
                                            if anim.IsPlaying then
                                                local id = anim.Animation.AnimationId
                                                -- Si no es animación core de caminar o estar quieto, está usando la herramienta
                                                if not id:find("252654100") and not id:find("180426354") and not id:find("507766388") then
                                                    isAttacking = true
                                                    break
                                                end
                                            end
                                        end
                                    end)
                                end
                                
                                -- Auto-Equipado y activación forzada del pico
                                if isAttacking then
                                    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if not localTool then
                                        local toolInBackpack = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                        if toolInBackpack then
                                            localHum:EquipTool(toolInBackpack)
                                            localTool = toolInBackpack
                                        end
                                    end
                                    if localTool then 
                                        localTool:Activate() -- Golpea exactamente al mismo tiempo
                                    end
                                end
                                
                                -- 🌟 4. ABSORCIÓN INSTANTÁNEA DE RECOMPENSAS
                                pcall(function()
                                    if firetouchinterest then
                                        local collectParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 10)
                                        for _, part in ipairs(collectParts) do
                                            local nameLower = part.Name:lower()
                                            if part:FindFirstChild("TouchInterest") or nameLower:find("gem") or nameLower:find("diamond") or nameLower:find("coin") then
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
            -- Limpieza absoluta de fuerzas para restaurar el control manual de pantalla al 100%
            local root = getRoot()
            if root then
                if root:FindFirstChild("TrollGyro") then root.TrollGyro:Destroy() end
                if root:FindFirstChild("TrollPosition") then root.TrollPosition:Destroy() end
            end
            Rayfield:Notify({Title = "Modo Sombra", Content = "Desactivado. Físicas restauradas.", Duration = 2})
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
