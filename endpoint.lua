-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Sequential Loop Engine",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Sequential TP System",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458)

-- Configuración y Estados
local targetPos10k = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local smartFarmActive = false
local magnetFarmActive = false
local sequentialFarmActive = false
local guiClaimActive = false

-- LISTA NEGRA (Solo para Switch 2 Magnet Base)
local allowedFolders = {"coingivers", "wingivers", "coins", "givers"}
local blacklistedTargets = {"gold", "golden", "grouprewardwall", "slap", "carpet", "horns", "sign", "board", "cartel", "wall", "banner", "npc"}

-- Funciones auxiliares de personaje
local function getCoinPart10k()
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

-- OBTENER Y ORDENAR GIVERS POR VALOR NUMÉRICO (De Menor a Mayor)
local function getOrderedCoinGivers()
    local givers = {}
    
    local coinGiversFolder = nil
    if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("CoinGivers") then
        coinGiversFolder = workspace.Map.CoinGivers
    elseif workspace:FindFirstChild("CoinGivers") then
        coinGiversFolder = workspace.CoinGivers
    end

    if coinGiversFolder then
        for _, child in ipairs(coinGiversFolder:GetChildren()) do
            local val = tonumber(child.Name) or tonumber(string.match(child.Name, "%d+"))
            
            -- Rango objetivo: de 500 a 9.999 (excluye el de 10k que usa el Switch 1)
            if val and val >= 500 and val <= 9999 then
                local part = child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildOfClass("BasePart")))
                if part then
                    table.insert(givers, {part = part, value = val})
                end
            end
        end
    end

    -- Ordenar la lista estrictamente de menor a mayor valor (ej: 500 -> 1000 -> 1250...)
    table.sort(givers, function(a, b)
        return a.value < b.value
    end)

    return givers
end

-- INTERACCIÓN FÍSICA DIRECTA + FIRETOUCH
local function collectGiverDirect(hrp, targetPart)
    if not hrp or not targetPart then return end

    -- Mover temporalmente al personaje a la moneda
    hrp.CFrame = targetPart.CFrame
    resetMomentum(hrp)

    -- Ejecutar evento de toque
    if firetouchinterest then
        firetouchinterest(hrp, targetPart, 0)
        firetouchinterest(hrp, targetPart, 1)
    end

    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt") or targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")
    if prompt and fireproximityprompt then
        fireproximityprompt(prompt)
    end
end

-- Filtro para Magnet Base (Coins genéricas y WinGivers)
local function isValidMagnetCoin(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid") then return false end

    local name = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local grandParentName = (obj.Parent and obj.Parent.Parent) and string.lower(obj.Parent.Parent.Name) or ""

    local numVal = tonumber(obj.Name) or tonumber(string.match(obj.Name, "%d+"))
    if numVal and numVal >= 500 then
        return false
    end

    for _, badKw in ipairs(blacklistedTargets) do
        if name:find(badKw) or parentName:find(badKw) or grandParentName:find(badKw) then
            return false
        end
    end

    for _, folder in ipairs(allowedFolders) do
        if parentName == folder or grandParentName == folder then
            return true
        end
    end

    return false
end

-- ========================================================
-- NÚCLEO MAGNET BASE (COINS Y WINGIVERS PEQUEÑAS)
-- ========================================================
local function fastMagnetCycle()
    local hrp = getHRP()
    if not hrp then return end

    local targetContainers = {}
    
    for _, desc in ipairs(workspace:GetChildren()) do
        local dName = string.lower(desc.Name)
        if dName == "map" or dName == "coins" or dName == "wingivers" then
            table.insert(targetContainers, desc)
        end
    end

    for _, container in ipairs(targetContainers) do
        if not magnetFarmActive then break end
        
        for _, obj in ipairs(container:GetDescendants()) do
            if not magnetFarmActive then break end

            if isValidMagnetCoin(obj) then
                task.spawn(function()
                    if firetouchinterest then
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                    end
                end)
            end
        end
    end
end

-- ========================================================
-- RECLAMO DE GUI SECUENCIAL
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
                        task.wait(0.08)
                    end
                end
            end
        end

        local coinsGui = mainGui:FindFirstChild("Coins")
        local coinsSlots = coinsGui and coinsGui:FindFirstChild("Slots")
        if coinsSlots then
            for _, slot in ipairs(coinsSlots:GetChildren()) do
                if not guiClaimActive then break end
                local btn = slot:FindFirstChild("Button") or slot:FindFirstChildOfClass("GuiButton")
                if btn then
                    clickGuiElement(btn)
                    task.wait(0.08)
                end
            end
        end
    end
end

-- ========================================================
-- SECCIÓN DE SWITCHES EN INTERFAZ
-- ========================================================

-- Switch 1: Smart Switch Original (10.000 + TP + Caída + 12s)
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch Original (Moneda 10k + Salto + 12s)",
   CurrentValue = false,
   Flag = "ToggleSmartOriginal",
   Callback = function(Value)
      smartFarmActive = Value
      if smartFarmActive then
         task.spawn(function()
            while smartFarmActive do
               local hrp = getHRP()
               local humanoid = getHumanoid()
               local coinPart = getCoinPart10k()
               local basePos = coinPart and coinPart.Position or targetPos10k
               
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

-- Switch 2: Magnet Farm Base (Coins genéricas + WinGivers / Sin TP)
FarmTab:CreateToggle({
   Name = "🚀 Magnet Farm Base (Coins + WinGivers / Sin TP)",
   CurrentValue = false,
   Flag = "ToggleMagnetNoTP",
   Callback = function(Value)
      magnetFarmActive = Value
      if magnetFarmActive then
         task.spawn(function()
            while magnetFarmActive do
               fastMagnetCycle()
               task.wait(0.05)
            end
         end)
      end
   end,
})

-- Switch 3: NUEVO ENFOQUE - Bucle Secuencial TP Ordenado (500 a 9.999)
FarmTab:CreateToggle({
   Name = "🔄 Sequential Loop Farm (500 a 9.999 Ordenados)",
   CurrentValue = false,
   Flag = "ToggleSequentialLoop",
   Callback = function(Value)
      sequentialFarmActive = Value
      if sequentialFarmActive then
         task.spawn(function()
            while sequentialFarmActive do
               local hrp = getHRP()
               local humanoid = getHumanoid()

               if hrp and humanoid and humanoid.Health > 0 then
                  local giversList = getOrderedCoinGivers()
                  local startPos = hrp.CFrame -- Guardar posición inicial

                  -- Recorrer uno por uno en orden de menor a mayor
                  for _, item in ipairs(giversList) do
                     if not sequentialFarmActive or humanoid.Health <= 0 then break end
                     
                     collectGiverDirect(hrp, item.part)
                     task.wait(0.06) -- Tiempo para que el servidor confirme la moneda
                  end

                  -- Volver a la posición de inicio al completar la ronda
                  if sequentialFarmActive and hrp then
                     hrp.CFrame = startPos
                     resetMomentum(hrp)
                  end
               end
               
               task.wait(0.1) -- Pequeña pausa antes de reiniciar la ronda completa
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
               for _ = 1, 20 do
                  if not guiClaimActive then break end
                  task.wait(0.1)
               end
            end
         end)
      end
   end,
})
