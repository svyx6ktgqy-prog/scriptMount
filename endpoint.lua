-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Filtro Exacto de Rutas",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458)
local LogTab = Window:CreateTab("Inspector / Logs", 4483362458)

-- Configuración y Estados
local targetPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local smartFarmActive = false
local mapCoinsActive = false
local guiClaimActive = false
local startPositionBeforeFarm = nil

-- RUTAS PERMITIDAS Y LISTA NEGRA BASADA EN TUS LOGS
local allowedFolders = {"coingivers", "wingivers", "coins"}
local blacklistedTargets = {"gold", "golden", "grouprewardwall", "slap", "carpet", "horns"}

-- Historial para el Inspector Móvil (Delta)
local logHistory = {}
local logTextBuffer = "Esperando inicio de recolección filtrada..."

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
-- FILTRADO QUIRÚRGICO DE RUTAS (CoinGivers, WinGivers, Coins)
-- ========================================================
local function isTargetCoinOrWin(obj)
    if not obj:IsA("BasePart") or obj.Parent:FindFirstChildOfClass("Humanoid") then
        return false
    end

    local name = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local grandParentName = (obj.Parent and obj.Parent.Parent) and string.lower(obj.Parent.Parent.Name) or ""

    -- 1. BLOQUEAR inmediatamente si pertenece a Golden Carpet, Slap, Horns, NPC o GroupRewardWall
    for _, badKw in ipairs(blacklistedTargets) do
        if name:find(badKw) or parentName:find(badKw) or grandParentName:find(badKw) then
            return false
        end
    end

    -- 2. ACEPTE ÚNICAMENTE si su carpeta padre o abuelo es CoinGivers, WinGivers o Coins
    for _, allowed in ipairs(allowedFolders) do
        if parentName == allowed or grandParentName == allowed then
            return true
        end
    end

    return false
end

-- ========================================================
-- RECOLECCIÓN FILTRADA Y REGISTRO EN LOGS
-- ========================================================
local LogParagraph = LogTab:CreateParagraph({
    Title = "📋 Objetos Objetivos Detectados",
    Content = logTextBuffer
})

local function addLogEntry(entryText)
    table.insert(logHistory, 1, entryText)
    if #logHistory > 15 then
        table.remove(logHistory, 16)
    end
    logTextBuffer = table.concat(logHistory, "\n")
    LogParagraph:Set({
        Title = "📋 Objetos Objetivos Detectados",
        Content = logTextBuffer
    })
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

    for index, obj in ipairs(targetCoins) do
        if not mapCoinsActive then break end

        hrp = getHRP()
        if hrp and obj and obj.Parent then
            resetMomentum(hrp)

            -- Posicionamiento sobre el objeto objetivo
            hrp.CFrame = obj.CFrame + Vector3.new(0, 3.8, 0)

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

-- Botón para copiar al portapapeles en Delta (iOS)
LogTab:CreateButton({
   Name = "📋 Copiar Logs al Portapapeles (Delta)",
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
                        task.wait(0.2)
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

-- Switch Recolectar Solo Monedas Reales (CoinGivers, WinGivers, Coins)
FarmTab:CreateToggle({
   Name = "🪙 Recolector Filtrado (CoinGivers, WinGivers, Coins)",
   CurrentValue = false,
   Flag = "ToggleMapCoins",
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
               for _ = 1, 30 do
                  if not guiClaimActive then break end
                  task.wait(0.1)
               end
            end
         end)
      end
   end,
})
