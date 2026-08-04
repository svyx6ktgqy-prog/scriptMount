-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Dynamic CoinGiver",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Detección Dinámica de 1k a 999k",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458)

-- Configuración y Estados
local fallbackPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local smartFarmActive = false
local magnetFarmActive = false
local guiClaimActive = false

-- RUTAS Y LISTA NEGRA PARA MAGNET
local allowedFolders = {"coingivers", "wingivers", "coins"}
local blacklistedTargets = {"gold", "golden", "grouprewardwall", "slap", "carpet", "horns", "sign", "board", "cartel", "wall", "banner", "npc"}

-- Funciones auxiliares de personaje
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

-- DETECCIÓN DINÁMICA DE COINGIVERS (1000 hasta 999999, con 10000 al final)
local function getOrderedCoinGivers()
    local targets = {}
    local part10k = nil
    
    local coinGivers = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("CoinGivers")
    if coinGivers then
        for _, child in ipairs(coinGivers:GetChildren()) do
            if child:IsA("BasePart") then
                local val = tonumber(child.Name)
                if val then
                    if val == 10000 then
                        part10k = child
                    elseif val >= 1000 and val <= 999999 then
                        table.insert(targets, child)
                    end
                end
            end
        end
    end
    
    -- Colocar la moneda de 10.000 al final del recorrido
    if part10k then
        table.insert(targets, part10k)
    end
    
    return targets
end

-- Disparo de interacción física/proximidad virtual
local function interactWithPart(hrp, obj)
    if not hrp or not obj or not obj.Parent then return end
    
    pcall(function()
        if firetouchinterest then
            firetouchinterest(hrp, obj, 0)
            task.wait()
            firetouchinterest(hrp, obj, 1)
        end

        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
        if prompt and fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end)
end

-- Verificar si el objeto es válido para el Magnet
local function isValidCoin(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid") then return false end

    local name = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    local grandParentName = (obj.Parent and obj.Parent.Parent) and string.lower(obj.Parent.Parent.Name) or ""

    -- Excluir de Magnet cualquier número mayor o igual a 1000 para que los maneje el Smart Switch
    local numVal = tonumber(obj.Name)
    if numVal and numVal >= 1000 then
        return false
    end

    -- Filtrar Lista Negra
    for _, badKw in ipairs(blacklistedTargets) do
        if name:find(badKw) or parentName:find(badKw) or grandParentName:find(badKw) then
            return false
        end
    end

    -- Permitir por pertenencia a Carpeta
    for _, folder in ipairs(allowedFolders) do
        if parentName == folder or grandParentName == folder then
            return true
        end
    end

    return false
end

-- ========================================================
-- NÚCLEO MAGNET ULTRA-RÁPIDO (RUTAS COINS Y WINGIVERS)
-- ========================================================
local function fastMagnetCycle()
    local hrp = getHRP()
    if not hrp then return end

    local targetContainers = {}
    
    for _, desc in ipairs(workspace:GetChildren()) do
        local dName = string.lower(desc.Name)
        if dName == "map" or dName == "coins" or dName == "coingivers" or dName == "wingivers" then
            table.insert(targetContainers, desc)
        end
    end

    for _, container in ipairs(targetContainers) do
        if not magnetFarmActive then break end
        
        for _, obj in ipairs(container:GetDescendants()) do
            if not magnetFarmActive then break end

            if isValidCoin(obj) then
                task.spawn(function()
                    interactWithPart(hrp, obj)
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
                        task.wait(0.15)
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
                    task.wait(0.15)
                end
            end
        end
    end
end

-- ========================================================
-- SECCIÓN DE SWITCHES EN INTERFAZ
-- ========================================================

-- Switch Smart Dinámico (Secuencia: 1k -> N -> 10k + Espera 12s)
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch (CoinGivers: 1k a 999k -> 10k Final)",
   CurrentValue = false,
   Flag = "ToggleSmartOriginal",
   Callback = function(Value)
      smartFarmActive = Value
      if smartFarmActive then
         task.spawn(function()
            while smartFarmActive do
               local hrp = getHRP()
               local humanoid = getHumanoid()
               local targets = getOrderedCoinGivers()
               
               if #targets == 0 then
                   targets = {{Position = fallbackPos, Name = "Fallback"}}
               end

               if hrp and humanoid and humanoid.Health > 0 then
                  -- Recorrer iterativamente todas las monedas detectadas
                  for _, targetPart in ipairs(targets) do
                     if not smartFarmActive or humanoid.Health <= 0 then break end
                     
                     local basePos = targetPart.Position
                     
                     resetMomentum(hrp)
                     hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                     task.wait(0.3) 
                     
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
                        
                     until not smartFarmActive or not hrp or (hrp.Position.Y < (basePos.Y - 50)) or (tick() - fallTimeout > 4)
                  end
                  
                  -- Esperar 12 segundos únicamente tras finalizar toda la cadena (con la de 10k al final)
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

-- Switch Magnet Ultra-Rápido (Coins + WinGivers / Sin TP)
FarmTab:CreateToggle({
   Name = "🚀 Magnet Farm (Coins + WinGivers / Sin TP)",
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
