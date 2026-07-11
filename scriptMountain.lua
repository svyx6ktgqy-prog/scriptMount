-- === Mine Diamond Master - Mod Menu for Delta Executor ===
-- Enfocado en Mine a Mountain y juegos similares (mining pickaxe, diamonds/crystals)
-- Autor: Grok (custom para ti)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))() -- UI Library común
local Window = Library:CreateWindow({
    Title = "💎 Mine Diamond Master | Delta Executor",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Player = Window:AddTab("Player"),
    Farm = Window:AddTab("Farm"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc")
}

local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Variables globales
local autoMineEnabled = false
local autoPickEnabled = false
local superJumpEnabled = false
local backpackMultiplier = 1
local mountainVisible = true

-- === FUNCIONES GENÉRICAS PARA MINING GAMES ===

-- Encontrar cristales/diamantes grandes (por valor o tamaño)
local function findBestDiamonds()
    local best = nil
    local maxValue = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if string.find(obj.Name:lower(), "diamond") or string.find(obj.Name:lower(), "crystal") or string.find(obj.Name:lower(), "ore") then
                local value = 0
                if obj:FindFirstChild("Value") then value = obj.Value.Value end
                if value > maxValue then
                    maxValue = value
                    best = obj
                end
            end
        end
    end
    return best
end

-- Auto Mine (simula picar cerca de ores)
local function autoMine()
    while autoMineEnabled do
        local best = findBestDiamonds()
        if best and root then
            root.CFrame = best.CFrame + Vector3.new(0, 5, 0) -- Tele a ore
            -- Simular clic/pick (ajusta según RemoteEvent del juego)
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name:lower(), "pick") then
                    tool:Activate() -- O FireServer si hay Remote
                end
            end
        end
        task.wait(0.5)
    end
end

-- Auto Pick / Collect
local function autoPick()
    while autoPickEnabled do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (string.find(obj.Name:lower(), "diamond") or string.find(obj.Name:lower(), "crystal")) and obj:FindFirstChild("TouchInterest") then
                firetouchinterest(root, obj, 0)
                task.wait(0.1)
                firetouchinterest(root, obj, 1)
            end
        end
        task.wait(1)
    end
end

-- Desaparecer montañas (Toggle visibility)
local function toggleMountains(visible)
    mountainVisible = visible
    for _, part in ipairs(workspace:GetDescendants()) do
        if string.find(part.Name:lower(), "mountain") or string.find(part.Name:lower(), "rock") or string.find(part.Name:lower(), "terrain") then
            if part:IsA("BasePart") then
                part.Transparency = visible and 0 or 1
                part.CanCollide = visible
            end
        end
    end
end

-- Aumentar Backpack (multiplicador)
local function increaseBackpack(mult)
    backpackMultiplier = mult
    -- Muchos juegos tienen Leaderstats o Backpack value
    if localPlayer:FindFirstChild("leaderstats") then
        local bp = localPlayer.leaderstats:FindFirstChild("Backpack") or localPlayer.leaderstats:FindFirstChild("Capacity")
        if bp then bp.Value = bp.Value * mult end
    end
    -- Intento genérico en Data
    for _, v in ipairs(localPlayer:GetDescendants()) do
        if v.Name == "BackpackCapacity" or v.Name == "MaxBackpack" then
            v.Value = v.Value * mult
        end
    end
end

-- Super Jump
local function superJump()
    while superJumpEnabled do
        if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            humanoid.JumpPower = 200
        end
        task.wait(0.1)
    end
end

-- === UI TOGGLES ===

-- Tab Main / Farm
local farmTab = Tabs.Farm:AddLeftGroupbox("Auto Farm")
farmTab:AddToggle("AutoMine", {Text = "Auto Minar", Default = false, Callback = function(v)
    autoMineEnabled = v
    if v then task.spawn(autoMine) end
end})

farmTab:AddToggle("AutoPick", {Text = "Auto Picar / Recolectar Diamantes", Default = false, Callback = function(v)
    autoPickEnabled = v
    if v then task.spawn(autoPick) end
end})

farmTab:AddButton("Recolectar Todos los Diamantes", function()
    autoPick()
end)

farmTab:AddButton("Buscar Diamante Más Grande", function()
    local best = findBestDiamonds()
    if best then
        root.CFrame = best.CFrame + Vector3.new(0, 10, 0)
        Library:Notify("¡Diamante grande encontrado! Valor aprox: " .. (best:FindFirstChild("Value") and best.Value.Value or "Alto"))
    else
        Library:Notify("No se encontró diamante grande")
    end
end})

-- Tab Visuals
local visualsTab = Tabs.Visuals:AddLeftGroupbox("Visuals")
visualsTab:AddToggle("NoMountains", {Text = "Desaparecer Montañas", Default = false, Callback = function(v)
    toggleMountains(not v)
end})

visualsTab:AddToggle("CrystalESP", {Text = "ESP Diamantes / Cristales", Default = false, Callback = function(v)
    -- Simple ESP (puedes expandir)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name:lower(), "diamond") or string.find(obj.Name:lower(), "crystal") then
            local highlight = obj:FindFirstChild("Highlight") or Instance.new("Highlight")
            highlight.Parent = obj
            highlight.FillColor = Color3.fromRGB(0, 255, 255)
            highlight.Enabled = v
        end
    end
end})

-- Tab Player
local playerTab = Tabs.Player:AddLeftGroupbox("Player Mods")
playerTab:AddSlider("Backpack", {Text = "Aumentar Mochila (x)", Min = 1, Max = 100, Default = 1, Rounding = 0, Callback = function(v)
    increaseBackpack(v)
end})

playerTab:AddToggle("SuperJump", {Text = "Super Salto", Default = false, Callback = function(v)
    superJumpEnabled = v
    if v then task.spawn(superJump) end
end})

playerTab:AddButton("Infinite Jump", function()
    humanoid.JumpPower = 500
    Library:Notify("Super Salto Activado")
end})

-- Misc
local miscTab = Tabs.Misc:AddLeftGroupbox("Más Opciones")
miscTab:AddButton("Auto Sell (si existe Remote)", function()
    -- Busca Remotes comunes
    for _, remote in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(remote.Name:lower(), "sell") or string.find(remote.Name:lower(), "deposit")) then
            remote:FireServer()
            Library:Notify("Intentando Auto Sell...")
        end
    end
end})

miscTab:AddButton("God Mode / No Freeze", function()
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
    Library:Notify("God Mode Activado (contra frío en la cima)")
end})

Library:Notify("💎 Mine Diamond Master cargado! Usa en Mine a Mountain u otros mining games.")