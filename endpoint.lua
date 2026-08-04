-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Recorrido Continuo",
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
local mapCoinsActive = false
local guiClaimActive = false
local startPositionBeforeFarm = nil

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

-- Noclip total durante el viaje para evitar atascamientos físicos
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

-- ========================================================
-- NÚCLEO 1: RECORRIDO COMPLETO Y CONTINUO POR EL MAPA
-- ========================================================
local function collectMapCoinsTeleport()
    local hrp = getHRP()
    if not hrp then return end

    setNoclip(true)

    -- 1. Buscar todas las monedas válidas del mapa
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "10000" and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            local name = string.lower(obj.Name)
            if (name:find("coin") or name:find("moneda") or obj:FindFirstChildOfClass("TouchTransmitter")) and obj.Position.Y > 150 then
                table.insert(coins, obj)
            end
        end
    end

    -- 2. Viajar moneda por moneda sin regresar al inicio
    for _, coin in ipairs(coins) do
        if not mapCoinsActive then break end
        
        hrp = getHRP()
        if hrp and coin and coin.Parent then
            resetMomentum(hrp)
            
            -- Posicionar +3.8 bloques arriba para pisar la baldosa perfectamente
            hrp.CFrame = coin.CFrame + Vector3.new(0, 3.8, 0)
            
            -- Activar el toque
            if firetouchinterest then
                firetouchinterest(hrp, coin, 0)
                task.wait(0.01)
                firetouchinterest(hrp, coin, 1)
            end
            
            local prompt = coin:FindFirstChildOfClass("ProximityPrompt") or coin.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt and fireproximityprompt then
                fireproximityprompt(prompt)
            end
            
            -- Pausa de viaje (0.15s) para un recorrido fluido y visible
            task.wait(0.15)
        end
    end

    setNoclip(false)
end

-- ========================================================
-- NÚCLEO 2: RECLAMO DE GUI SECUENCIAL
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
        -- PlayRewards Slots (del 1 al 40)
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

        -- Coins Slots
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

-- Switch Recolectar Monedas del Mapa (Viaje Continuo por CFrame)
FarmTab:CreateToggle({
   Name = "🪙 Viaje de Monedas por el Mapa (Sin Regreso Prematuro)",
   CurrentValue = false,
   Flag = "ToggleMapCoins",
   Callback = function(Value)
      mapCoinsActive = Value
      if mapCoinsActive then
         local hrp = getHRP()
         if hrp then startPositionBeforeFarm = hrp.CFrame end
         
         task.spawn(function()
            while mapCoinsActive do
               collectMapCoinsTeleport()
               task.wait(0.5)
            end
            
            -- Solo regresa al punto inicial cuando APAGAS el switch
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
