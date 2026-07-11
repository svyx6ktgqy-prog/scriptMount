-- =====================================================================
-- 💎 ALB8RAAQ - MINE MASTER PRO V4 (PERFECT SYNC)
-- UI: Rayfield | Físicas Libres | Clonador de Animator (Saltos y Golpes)
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
    Name = "💎 ALB8RAAQ | Mine Master V4",
    LoadingTitle = "Iniciando Proyecto ALB8RAAQ...",
    LoadingSubtitle = "Sincronización Total de Saltos y Golpes",
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
                    pcall(function()
                        item.Anchored = false
                        item.Velocity = Vector3.new(0, -2, 0)
                        item.RotVelocity = Vector3.zero
                    end)
                    item.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-15, 15), math.random(3, 8), math.random(-15, 15)))
                    count = count + 1
                    if count % 20 == 0 then task.wait() end
                end
            end
        end
        Rayfield:Notify({Title = "ALB8RAAQ", Content = "Atraídos " .. count .. " objetos.", Duration = 4})
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
                    highlight = Instance.new("Highlight", player.Character)
                    highlight.Name = "UniversalESP"
                    highlight.FillTransparency = 0.5
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
                if Tracers[player] then Tracers[player]:Remove(); Tracers[player] = nil end
            end
        else
            if Tracers[player] then Tracers[player]:Remove(); Tracers[player] = nil end
        end
    end
end)

-- =====================================================================
-- PESTAÑA 3: 🚀 MOVIMIENTO Y #TROLL (MODO SOMBRA V4)
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
        local targetPlayer = Players:FindFirstChild(Options[1])
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end
        end
    end,
})

MoveTab:CreateSection("Sincronización Total - ALB8RAAQ") 

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
    Name = "👣 Activar Modo Sombra V4 (Perfect Sync)",
    CurrentValue = false,
    Flag = "TrollFollowToggle",
    Callback = function(Value)
        trollFollowEnabled = Value
        if Value then
            if selectedTrollPlayer == "Ninguno" or selectedTrollPlayer == "" then
                Rayfield:Notify({Title = "Error", Content = "Selecciona un jugador.", Duration = 3})
                return
            end
            
            pcall(function()
                local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and localRoot then
                        localRoot.CFrame = CFrame.lookAt((targetRoot.CFrame * CFrame.new(0, 0, 3)).Position, targetRoot.Position)
                    end
                end
            end)
            
            task.spawn(function()
                while trollFollowEnabled do
                    task.wait(0.01)
                    if selectedTrollPlayer and selectedTrollPlayer ~= "Ninguno" then
                        local targetPlayer = Players:FindFirstChild(selectedTrollPlayer)
                        if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local localHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHum and localRoot and localHum then
                                
                                -- 1. MOVIMIENTO HORIZONTAL Y ROTACIÓN (Mantiene Joystick libre)
                                local bg = localRoot:FindFirstChild("TrollGyro")
                                if not bg then
                                    bg = Instance.new("BodyGyro")
                                    bg.Name = "TrollGyro"
                                    bg.maxTorque = Vector3.new(0, 999999, 0)
                                    bg.P = 60000; bg.D = 400
                                    bg.Parent = localRoot
                                end
                                bg.CFrame = CFrame.lookAt(Vector3.zero, targetRoot.CFrame.LookVector)

                                local bp = localRoot:FindFirstChild("TrollPosition")
                                if not bp then
                                    bp = Instance.new("BodyPosition")
                                    bp.Name = "TrollPosition"
                                    bp.maxForce = Vector3.new(600000, 0, 600000) -- Fuerza Y en 0 para permitir saltos
                                    bp.P = 40000; bp.D = 1000
                                    bp.Parent = localRoot
                                end
                                bp.Position = (targetRoot.CFrame * CFrame.new(0, 0, 2.8)).Position
                                
                                localHum.WalkSpeed = targetHum.WalkSpeed

                                -- 🌟 2. CLONADOR DE SALTOS FORZADO (CORRECCIÓN)
                                local targetState = targetHum:GetState()
                                local isJumping = targetHum.Jump or targetState == Enum.HumanoidStateType.Jumping or targetRoot.AssemblyLinearVelocity.Y > 5
                                
                                if isJumping then
                                    localHum.Jump = true
                                    -- Si el motor físico local intenta suprimir el salto, lo forzamos.
                                    if localHum:GetState() ~= Enum.HumanoidStateType.Jumping and localHum:GetState() ~= Enum.HumanoidStateType.Freefall then
                                        localHum:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end
                                end
                                
                                -- 🌟 3. CLONADOR DE GOLPES (ANIMATOR NATIVO)
                                local targetTool = targetPlayer.Character:FindFirstChildOfClass("Tool")
                                if targetTool then
                                    -- Equipamos nuestra herramienta si él tiene una
                                    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if not localTool then
                                        local toolInBackpack = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                        if toolInBackpack then
                                            localHum:EquipTool(toolInBackpack)
                                            localTool = toolInBackpack
                                        end
                                    end
                                    
                                    -- Leemos directamente las animaciones que se reproducen en su esqueleto
                                    local isSwinging = false
                                    local targetAnimator = targetHum:FindFirstChildOfClass("Animator")
                                    if targetAnimator then
                                        for _, animTrack in ipairs(targetAnimator:GetPlayingAnimationTracks()) do
                                            local n = animTrack.Name:lower()
                                            -- Si la animación está activa y NO es caminar, correr, saltar o estar quieto = Está golpeando
                                            if not n:find("idle") and not n:find("walk") and not n:find("run") and not n:find("jump") and not n:find("fall") and not n:find("toolnone") then
                                                if animTrack.IsPlaying and animTrack.Weight > 0 then
                                                    isSwinging = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    
                                    -- ¡Golpeamos exactamente al mismo tiempo que la animación!
                                    if isSwinging and localTool then
                                        localTool:Activate()
                                    end
                                else
                                    -- Si él guarda el pico, nosotros lo guardamos.
                                    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                    if localTool then
                                        localHum:UnequipTools()
                                    end
                                end
                                
                                -- 4. RECOLECCIÓN MAGNÉTICA INVISIBLE
                                pcall(function()
                                    if firetouchinterest then
                                        local collectParts = workspace:GetPartBoundsInRadius(targetRoot.Position, 10)
                                        for _, part in ipairs(collectParts) do
                                            local n = part.Name:lower()
                                            if part:FindFirstChild("TouchInterest") or n:find("gem") or n:find("diamond") or n:find("coin") then
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
            -- Limpieza física al apagar
            local root = getRoot()
            if root then
                if root:FindFirstChild("TrollGyro") then root.TrollGyro:Destroy() end
                if root:FindFirstChild("TrollPosition") then root.TrollPosition:Destroy() end
            end
            Rayfield:Notify({Title = "ALB8RAAQ", Content = "Control manual restaurado.", Duration = 2})
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
