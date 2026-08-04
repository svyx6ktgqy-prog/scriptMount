-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Caminata & Claimer",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458)

-- Configuración y Estados
local targetPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local autoFarmActive = false
local smartFarmActive = false
local organicWalkActive = false
local guiClaimActive = false

-- Listas de filtrado GUI
local blacklistedKeywords = {"admin", "fling", "explode", "topmenu", "currency", "shop", "store"}

-- Funciones auxiliares
local function getCoinPart()
    return workspace:FindFirstChild("Map") 
       and workspace.Map:FindFirstChild("CoinGivers") 
       and workspace.Map.CoinGivers:FindFirstChild("10000")
end

local function getHRP()
    local player = game.Players.LocalPlayer
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local player = game.Players.LocalPlayer
    return player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function resetMomentum(hrp)
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

-- ========================================================
-- NÚCLEO 1: CAMINATA REAL Y ORGÁNICA POR EL MAPA
-- ========================================================
local function startOrganicCoinWalk()
    local hrp = getHRP()
    local humanoid = getHumanoid()
    if not hrp or not humanoid then return end

    -- 1. Buscar todas las monedas válidas en el Workspace
    local coinsList = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "10000" and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            local name = string.lower(obj.Name)
            if name:find("coin") or name:find("moneda") or obj:FindFirstChildOfClass("TouchTransmitter") then
                -- Filtro de seguridad: Evitar monedas caídas al vacío (Y < 200) para no morir
                if obj.Position.Y > 200 then
                    table.insert(coinsList, obj)
                end
            end
        end
    end

    -- 2. Recorrer las monedas ordenadas por cercanía (Caminata continua sin vueltas)
    while #coinsList > 0 and organicWalkActive do
        hrp = getHRP()
        humanoid = getHumanoid()
        if not hrp or not humanoid or humanoid.Health <= 0 then break end

        -- Encontrar la moneda más cercana desde la posición actual
        local closestIndex = 1
        local closestDistance = (hrp.Position - coinsList[1].Position).Magnitude

        for i = 2, #coinsList do
            local dist = (hrp.Position - coinsList[i].Position).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestIndex = i
            end
        end

        local targetCoin = coinsList[closestIndex]
        table.remove(coinsList, closestIndex) -- Remover de la lista para no repetir

        if targetCoin and targetCoin.Parent then
            -- Mover al personaje usando el sistema de físicas natural de Roblox
            humanoid:MoveTo(targetCoin.Position)
            
            local walkStartTime = tick()
            local reached = false

            -- Monitorear la caminata en tiempo real
            repeat
                task.wait(0.1)
                hrp = getHRP()
                humanoid = getHumanoid()

                if hrp and targetCoin and targetCoin.Parent then
                    local currentDist = (hrp.Position - targetCoin.Position).Magnitude
                    
                    -- Si está muy cerca, simular el toque para asegurar el cobro
                    if currentDist <= 8 then
                        if firetouchinterest then
                            firetouchinterest(hrp, targetCoin, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, targetCoin, 1)
                        end
                        reached = true
                    end
                    
                    -- Detección de traba: Si tarda mucho en avanzar, hacer un salto natural
                    if (tick() - walkStartTime) > 3 and not reached then
                        humanoid.Jump = true
                    end
                end
            -- Salir si llegó, si se apagó el switch o si excedió 7 segundos de camino
            until reached or not organicWalkActive or (tick() - walkStartTime > 7) or not humanoid or humanoid.Health <= 0
        end
    end
end

-- ========================================================
-- NÚCLEO 2: RECLAMO DE GUI SECUENCIAL (TODAS LAS FILAS)
-- ========================================================
local function clickGuiElement(btn)
    pcall(function()
        if getconnections then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
            for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do conn:Fire() end
            for _, conn in ipairs(getconnections(btn.Activated)) do conn:Fire() end
        elseif firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
end

local function autoClaimAllGuiRewards()
    local player = game.Players.LocalPlayer
    if not player or not player:FindFirstChild("PlayerGui") then return end
    local mainGui = player.PlayerGui:FindFirstChild("Main")
    
    if mainGui then
        -- 1. Reclamar PlayRewards Slots (del 1 al 40 con delay para evitar bloqueo del servidor)
        local playRewards = mainGui:FindFirstChild("PlayRewards")
        local playSlots = playRewards and playRewards:FindFirstChild("Slots")
        
        if playSlots then
            for i = 1, 40 do
                if not guiClaimActive then break end
                local slot = playSlots:FindFirstChild(tostring(i))
                if slot then
                    local btn = slot:FindFirstChild("Button") or slot:FindFirstChildOfClass("GuiButton")
                    if btn then
                        clickGuiElement(btn)
                        task.wait(0.2) -- Pausa crítica para que el servidor registre la recompensa actual antes de pedir la siguiente
                    end
                end
            end
        end

        -- 2. Reclamar Coins Slots (Todas las opciones de monedas)
        local coinsGui = mainGui:FindFirstChild("Coins")
        local coinsSlots = coinsGui and coinsGui:FindFirstChild("Slots")
        
        if coinsSlots then
            for _, slot in ipairs(coinsSlots:GetChildren()) do
                if not guiClaimActive then break end
                local btn = slot:FindFirstChild("Button") or slot:FindFirstChildOfClass("GuiButton")
                if btn then
                    clickGuiElement(btn)
                    task.wait(0.2)
                end
            end
        end
    end
end

-- ========================================================
-- SECCIÓN DE SWITCHES EN INTERFAZ
-- ========================================================

-- Switch Smart Original
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch Original (Terreno + Salto + 12s)",
   CurrentValue = false,
   Flag = "ToggleSmartOriginal",
   Callback = function(Value)
      smartFarmActive = Value
      if smartFarmActive then
         task.spawn(function()
            while smartFarmActive do
               local hrp = getHRP()
               local humanoid = getHumanoid()
               local coinPart = getCoinPart()
               local basePos = coinPart and coinPart.Position or targetPos
               
               if hrp and humanoid and humanoid.Health > 0 then
                  resetMomentum(hrp)
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                  task.wait(0.4) 
                  
                  if not smartFarmActive or humanoid.Health <= 0 then break end
                  
                  resetMomentum(hrp)
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 35, 0))
                  
                  local isJumping = false
                  local fallTimeout = tick()
                  
                  repeat
                     task.wait(0.05)
                     hrp = getHRP()
                     humanoid = getHumanoid()
                     
                     if not isJumping and hrp and humanoid and hrp.Position.Y < (basePos.Y + 5) then
                         humanoid.Jump = true
                         isJumping = true
                     end
                     
                  until not smartFarmActive or not hrp or (hrp.Position.Y < (basePos.Y - 50)) or (tick() - fallTimeout > 5)
                  
                  if smartFarmActive then
                     for _ = 1, 12 do
                        if not smartFarmActive then break end
                        task.wait(1)
                     end
                  end
               else
                  task.wait(0.5)
               end
            end
         end)
      end
   end,
})

-- Switch Nuevo: Caminata Orgánica por el Mapa
FarmTab:CreateToggle({
   Name = "🚶 Caminata Orgánica (Recolectar Monedas en Vivo)",
   CurrentValue = false,
   Flag = "ToggleOrganicWalk",
   Callback = function(Value)
      organicWalkActive = Value
      if organicWalkActive then
         task.spawn(function()
            while organicWalkActive do
               startOrganicCoinWalk()
               task.wait(1)
            end
         end)
      end
   end,
})

-- Switch Auto Reclamar GUI Secuencial
GuiTab:CreateToggle({
   Name = "🎯 Auto Claimer GUI (Fila por Fila Secuencial)",
   CurrentValue = false,
   Flag = "ToggleFilteredClaim",
   Callback = function(Value)
      guiClaimActive = Value
      if guiClaimActive then
         task.spawn(function()
            while guiClaimActive do
               autoClaimAllGuiRewards()
               -- Pausa antes de volver a escanear toda la interfaz
               for _ = 1, 30 do
                  if not guiClaimActive then break end
                  task.wait(0.1)
               end
            end
         end)
      end
   end,
})
