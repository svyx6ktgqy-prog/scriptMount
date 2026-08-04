-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Extreme Suite",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Filtro Exacto + Multi-Endpoint",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Creación de Apartados (Tabs)
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458)
local LogTab = Window:CreateTab("Inspector / Logs", 4483362458)

-- Configuración y Estados Globales
local targetPos10k = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local smartFarmActive = false
local magnetFarmActive = false
local highGiversActive = false
local mapCoinsActive = false
local guiClaimActive = false
local startPositionBeforeFarm = nil

-- LISTA NEGRA Y BLANCA (Combinadas para mayor precisión)
local allowedFolders = {"coingivers", "wingivers", "coins", "givers"}
local blacklistedTargets = {"gold", "golden", "grouprewardwall", "slap", "carpet", "horns", "sign", "board", "cartel", "wall", "banner", "npc"}

-- Historial para el Inspector Móvil (Logs)
local logHistory = {}
local logTextBuffer = "Esperando inicio de recolección filtrada..."

-- ========================================================
-- FUNCIONES AUXILIARES BASE
-- ========================================================
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

local function setNoclip(enabled)
    local player = game.Players.LocalPlayer
    if player and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    elseif Synapse and Synapse.set_clipboard then
        Synapse.set_clipboard(text)
    end
end

-- ========================================================
-- RÁFAGA DE INTERACCIÓN HIPER RÁPIDA
-- ========================================================
local function hyperInteract(hrp, target)
    if not hrp or not target then return end
    
    local touchPart = target:IsA("BasePart") and target or target:FindFirstChildOfClass("BasePart")
    if not touchPart then return end

    -- Ejecutar ráfaga instantánea de 3 pulsos
    for _ = 1, 3 do
        if firetouchinterest then
            firetouchinterest(hrp, touchPart, 0)
            firetouchinterest(hrp, touchPart, 1)
        end

        local prompt = touchPart:FindFirstChildOfClass("ProximityPrompt") 
            or (target:IsA("Model") and target:FindFirstChildOfClass("ProximityPrompt"))
        
        if prompt and fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end
end

-- ========================================================
-- SISTEMA DE LOGS / INSPECTOR
-- ========================================================
local LogParagraph = LogTab:CreateParagraph({
    Title = "📋 Objetos Objetivos Detectados",
    Content = logTextBuffer
})

local function addLogEntry(entryText)
    table.insert(logHistory, 1, entryText)
    if #logHistory > 15 then
        table.remove(logHistory, 16) -- Limitar a 15 entradas para evitar lag en GUI
    end
    logTextBuffer = table.concat(logHistory, "\n")
    LogParagraph:Set({
        Title = "📋 Objetos Objetivos Detectados",
        Content = logTextBuffer
    })
end

LogTab:CreateButton({
   Name = "📋 Copiar Logs al Portapapeles",
   Callback = function()
      copyToClipboard(logTextBuffer)
      Rayfield:Notify({
         Title = "Copiado",
         Content = "Se copiaron los logs filtrados al portapapeles.",
         Duration = 3,
         Image = 4483362458
      })
   end,
})

LogTab:CreateButton({
   Name = "🗑️ Limpiar Historial de Logs",
   Callback = function()
      logHistory = {}
      logTextBuffer = "Historial limpiado."
      LogParagraph:Set({ Title = "📋 Objetos Objetivos Detectados", Content = logTextBuffer })
   end,
})

-- ========================================================
-- LÓGICA DE FILTRADO Y ESCANEO DE ENDPOINTS
-- ========================================================
local function getSmartEndpoints()
    local endpoints = {}
    local searched = {}

    local function checkAndAdd(obj)
        if searched[obj] then return end
        searched[obj] = true

        local rawName = tostring(obj.Name):gsub("[%.,_]", "")
        local val = tonumber(rawName) or tonumber(string.match(rawName, "%d+"))

        if val and val >= 500 and val <= 9999 and val ~= 10000 then
            table.insert(endpoints, obj)
        end
    end

    local function scanFolder(folder)
        if not folder then return end
        for _, child in ipairs(folder:GetChildren()) do
            checkAndAdd(child)
            if child:IsA("Model") or child:IsA("Folder") then
                for _, subChild in ipairs(child:GetChildren()) do
                    checkAndAdd(subChild)
                end
            end
        end
    end

    if workspace:FindFirstChild("Map") then
        scanFolder(workspace.Map:FindFirstChild("CoinGivers"))
        scanFolder(workspace.Map:FindFirstChild("Givers"))
    end
    scanFolder(workspace:FindFirstChild("CoinGivers"))
    scanFolder(workspace:FindFirstChild("Givers"))
    scanFolder(workspace:FindFirstChild("Coins"))

    return endpoints
end

local function isValidMagnetCoin(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid") then return false end

    local name = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local grandParentName = (obj.Parent and obj.Parent.Parent) and string.lower(obj.Parent.Parent.Name) or ""

    local rawName = name:gsub("[%.,_]", "")
    local numVal = tonumber(rawName) or tonumber(string.match(rawName, "%d+"))
    if numVal and numVal >= 500 then return false end -- Excluir endpoints grandes para magnet

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

local function isTargetCoinOrWin(obj)
    if not obj:IsA("BasePart") or (obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid")) then
        return false
    end

    local name = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local grandParentName = (obj.Parent and obj.Parent.Parent) and string.lower(obj.Parent.Parent.Name) or ""

    for _, badKw in ipairs(blacklistedTargets) do
        if name:find(badKw) or parentName:find(badKw) or grandParentName:find(badKw) then
            return false
        end
    end

    for _, allowed in ipairs(allowedFolders) do
        if parentName == allowed or grandParentName == allowed then
            return true
        end
    end
    return false
end

-- ========================================================
-- FUNCIONES DE FARMING CORE
-- ========================================================
local function fastMagnetCycle()
    local hrp = getHRP()
    if not hrp then return end
    local targetContainers = {}
    
    for _, desc in ipairs(workspace:GetChildren()) do
        local dName = string.lower(desc.Name)
        if dName == "map" or dName == "coins" or dName == "wingivers" or dName == "givers" then
            table.insert(targetContainers, desc)
        end
    end

    for _, container in ipairs(targetContainers) do
        if not magnetFarmActive then break end
        for _, obj in ipairs(container:GetDescendants()) do
            if not magnetFarmActive then break end
            if isValidMagnetCoin(obj) then
                task.spawn(function()
                    hyperInteract(hrp, obj)
                end)
            end
        end
    end
end

local function collectMapCoinsDirect()
    local hrp = getHRP()
    if not hrp then return end

    setNoclip(true)
    local targetCoins = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isTargetCoinOrWin(obj) then
            table.insert(targetCoins, obj)
        end
    end

    for _, obj in ipairs(targetCoins) do
        if not mapCoinsActive then break end
        hrp = getHRP()
        
        if hrp and obj and obj.Parent then
            resetMomentum(hrp)
            hrp.CFrame = obj.CFrame + Vector3.new(0, 3.8, 0) -- TP Encima del objetivo

            local logMsg = "[" .. os.date("%X") .. "] " .. obj.Name .. " | Ruta: " .. obj.Parent.Name
            addLogEntry(logMsg)

            if firetouchinterest then
                firetouchinterest(hrp, obj, 0)
                task.wait(0.01)
                firetouchinterest(hrp, obj, 1)
            end

            local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
            end

            task.wait(0.12)
        end
    end
    setNoclip(false)
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
-- SECCIÓN DE SWITCHES (PESTAÑA AUTO FARM)
-- ========================================================

FarmTab:CreateToggle({
   Name = "⚡ Smart Switch Original (Moneda 10k + TP + 12s)",
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

FarmTab:CreateToggle({
   Name = "⚡ Extreme Endpoints (500 a 9.999 / Sin TP / Ráfaga)",
   CurrentValue = false,
   Flag = "ToggleExtremeEndpoints",
   Callback = function(Value)
      highGiversActive = Value
      if highGiversActive then
         task.spawn(function()
            while highGiversActive do
               local hrp = getHRP()
               if hrp then
                  local endpoints = getSmartEndpoints()
                  for _, target in ipairs(endpoints) do
                     if not highGiversActive then break end
                     task.spawn(function()
                        hyperInteract(hrp, target)
                     end)
                  end
               end
               task.wait(0.01)
            end
         end)
      end
   end,
})

FarmTab:CreateToggle({
   Name = "🪙 Recolector Filtrado con Logs (TP a Objetivos)",
   CurrentValue = false,
   Flag = "ToggleMapCoinsFiltered",
   Callback = function(Value)
      mapCoinsActive = Value
      if mapCoinsActive then
         local hrp = getHRP()
         if hrp then startPositionBeforeFarm = hrp.CFrame end
         
         task.spawn(function()
            while mapCoinsActive do
               collectMapCoinsDirect()
               task.wait(0.3)
            end
            
            local currentHRP = getHRP()
            if currentHRP and startPositionBeforeFarm then
               resetMomentum(currentHRP)
               currentHRP.CFrame = startPositionBeforeFarm
               startPositionBeforeFarm = nil
            end
         end)
      end
   end,
})

-- ========================================================
-- SECCIÓN DE SWITCHES (PESTAÑA GUI)
-- ========================================================

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
