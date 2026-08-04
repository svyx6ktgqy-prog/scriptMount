-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Recolección Estable",
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
local ghostFarmActive = false
local mapCoinsActive = false
local guiClaimActive = false

-- Palabras clave para reclamos secundarios
local claimKeywords = {"claim", "reclamar", "collect", "get", "take", "free", "reward", "recoger", "obtener"}

-- Lista negra estricta para ignorar menús molesto (Admin / TopMenu)
local blacklistedKeywords = {"admin", "fling", "explode", "topmenu", "currency"}

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

-- Activar / Desactivar Noclip completo en el personaje
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
-- NÚCLEO 1: RECOLECCIÓN DE MONEDAS DEL MAPA (Aventura + Altura)
-- ========================================================
local function collectMapCoinsClean()
    local hrp = getHRP()
    if not hrp then return end
    
    local originalCFrame = hrp.CFrame
    setNoclip(true) -- Noclip total para evitar atascos en superficies
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not mapCoinsActive then break end
        
        if obj:IsA("BasePart") and obj.Name ~= "10000" and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            local name = string.lower(obj.Name)
            local isCoin = name:find("coin") or name:find("moneda") or obj:FindFirstChildOfClass("TouchTransmitter")
            
            if isCoin then
                pcall(function()
                    resetMomentum(hrp)
                    
                    -- Posicionar 3.5 bloques ARRIBA de la moneda para pisar la baldosa y no quedar atrapado abajo
                    local targetCFrame = obj.CFrame + Vector3.new(0, 3.5, 0)
                    hrp.CFrame = targetCFrame
                    
                    -- Tiempo para permitir que la física del juego procese el toque
                    task.wait(0.12)
                    
                    if firetouchinterest then
                        firetouchinterest(hrp, obj, 0)
                        task.wait(0.02)
                        firetouchinterest(hrp, obj, 1)
                    end
                    
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                end)
            end
        end
    end
    
    setNoclip(false)
    if hrp and mapCoinsActive then
        resetMomentum(hrp)
        hrp.CFrame = originalCFrame
    end
end

-- ========================================================
-- NÚCLEO 2: RECLAMO DE GUI DIRECTO Y FILTRADO
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
    
    -- 1. Búsqueda Directa en PlayRewards y Coins (Ruta exacta del Log)
    if mainGui then
        local playRewards = mainGui:FindFirstChild("PlayRewards")
        if playRewards then
            for _, desc in ipairs(playRewards:GetDescendants()) do
                if desc:IsA("GuiButton") and (desc.Name == "Button" or desc.Name:lower():find("claim")) then
                    clickGuiElement(desc)
                end
            end
        end
        
        local coinsGui = mainGui:FindFirstChild("Coins")
        if coinsGui then
            for _, desc in ipairs(coinsGui:GetDescendants()) do
                if desc:IsA("GuiButton") and desc.Name == "Button" then
                    clickGuiElement(desc)
                end
            end
        end
    end
    
    -- 2. Búsqueda por Palabras Clave (Ignorando TopMenu y Admin)
    for _, guiObject in ipairs(player.PlayerGui:GetDescendants()) do
        if not guiClaimActive then break end
        if guiObject:IsA("GuiButton") then
            local btnName = string.lower(guiObject.Name)
            local btnText = guiObject:IsA("TextButton") and string.lower(guiObject.Text) or ""
            local parentName = guiObject.Parent and string.lower(guiObject.Parent.Name) or ""
            
            local isBlacklisted = false
            for _, badKw in ipairs(blacklistedKeywords) do
                if btnName:find(badKw) or btnText:find(badKw) or parentName:find(badKw) then
                    isBlacklisted = true
                    break
                end
            end
            
            if not isBlacklisted then
                for _, kw in ipairs(claimKeywords) do
                    if (btnName:find(kw) or btnText:find(kw)) and not btnName:find("close") then
                        clickGuiElement(guiObject)
                        task.wait(0.03)
                        break
                    end
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

-- Switch Recolectar Monedas del Mapa (Aventura Prolongada sin Colisión)
FarmTab:CreateToggle({
   Name = "🪙 Recolectar Monedas del Mapa (Exploración)",
   CurrentValue = false,
   Flag = "ToggleMapCoins",
   Callback = function(Value)
      mapCoinsActive = Value
      if mapCoinsActive then
         task.spawn(function()
            while mapCoinsActive do
               collectMapCoinsClean()
               -- Pausa antes de iniciar la siguiente ronda de exploración
               for _ = 1, 20 do
                  if not mapCoinsActive then break end
                  task.wait(0.1)
               end
            end
         end)
      end
   end,
})

-- Switch Auto Reclamar GUI Directo
GuiTab:CreateToggle({
   Name = "🎯 Auto Claimer GUI (PlayRewards & Coins)",
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
