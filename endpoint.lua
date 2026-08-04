-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

-- Configuración y Coordenadas
local targetPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local autoFarmActive = false
local smartFarmActive = false
local ghostFarmActive = false

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

-- ========================================================
-- SECCIÓN DE SWITCHES (Toggles)
-- ========================================================

-- Switch Smart: Terreno -> Endpoint -> Salto (Jump) -> Caída -> 12s Descanso
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch (Terreno + Salto + 12s)",
   CurrentValue = false,
   Flag = "ToggleSmart",
   Callback = function(Value)
      smartFarmActive = Value
      if smartFarmActive then
         task.spawn(function()
            while smartFarmActive do
               local hrp = getHRP()
               local humanoid = getHumanoid()
               local coinPart = getCoinPart()
               local basePos = coinPart and coinPart.Position or targetPos
               
               if hrp and humanoid then
                  -- 1. Saltar a un lado del endpoint para tocar el terreno físico
                  -- Nos movemos 15 studs a un lado (eje X) y un poco arriba para asegurar que toque el suelo
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                  
                  -- Pausa para asegurar que toque el suelo y salga el mensaje de "has ganado"
                  task.wait(0.4) 
                  
                  if not smartFarmActive then break end
                  
                  -- 2. Inmediatamente saltar a gran altura justo sobre el endpoint
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 35, 0))
                  
                  -- 3. Esperar mientras cae. 
                  -- Justo cuando está a punto de tocar el bloque, forzamos un Salto natural.
                  local isJumping = false
                  repeat
                     task.wait(0.05)
                     hrp = getHRP()
                     
                     -- Si la posición Y está cerca del endpoint, forzar el salto
                     if not isJumping and hrp and hrp.Position.Y < (basePos.Y + 5) then
                         humanoid.Jump = true
                         isJumping = true
                     end
                     
                  -- Romper el bucle si el switch se apaga o si el personaje ya fue enviado abajo
                  until not smartFarmActive or (hrp and hrp.Position.Y < (basePos.Y - 50))
                  
                  -- 4. Descanso de 12 segundos en el mapa inicial
                  if smartFarmActive then
                     -- Bucle de 12 segundos comprobando cada 1 segundo.
                     for i = 1, 12 do
                        if not smartFarmActive then break end
                        task.wait(1)
                     end
                  end
               else
                  task.wait(0.1)
               end
            end
         end)
      end
   end,
})

-- Switch Continuo Masivo (Anclado/Spam)
FarmTab:CreateToggle({
   Name = "🔄 Switch Continuo (Spam TP)",
   CurrentValue = false,
   Flag = "ToggleContinuous",
   Callback = function(Value)
      autoFarmActive = Value
      if autoFarmActive then
         task.spawn(function()
            while autoFarmActive do
               task.wait(0.01)
               local hrp = getHRP()
               local coinPart = getCoinPart()
               if hrp then
                  hrp.CFrame = coinPart and coinPart.CFrame or CFrame.new(targetPos)
               end
            end
         end)
      end
   end,
})

-- Switch Ghost Touch (Bucle sin mover al personaje)
FarmTab:CreateToggle({
   Name = "👻 Ghost Switch (Reclamo en Bucle sin TP)",
   CurrentValue = false,
   Flag = "ToggleGhost",
   Callback = function(Value)
      ghostFarmActive = Value
      if ghostFarmActive then
         task.spawn(function()
            while ghostFarmActive do
               task.wait(0.05)
               local coinPart = getCoinPart()
               local hrp = getHRP()
               if coinPart and hrp and firetouchinterest then
                  firetouchinterest(hrp, coinPart, 0)
                  task.wait()
                  firetouchinterest(hrp, coinPart, 1)
               end
            end
         end)
      end
   end,
})

-- ========================================================
-- SECCIÓN DE BOTONES (Métodos Individuales)
-- ========================================================
FarmTab:CreateSection("Métodos de Reclamo Único (Botones)")

-- Botón 1: TP Directo Instantáneo
FarmTab:CreateButton({
   Name = "🎯 TP Único (Salto Instantáneo)",
   Callback = function()
      local hrp = getHRP()
      local coinPart = getCoinPart()
      if hrp then
         hrp.CFrame = coinPart and coinPart.CFrame or CFrame.new(targetPos)
      end
   end,
})

FarmTab:CreateButton({
   Name = "🛡️ Desactivar Anti-Cheat/TP del Endpoint",
   Callback = function()
      local coinPart = getCoinPart()
      if coinPart then
         -- Busca scripts locales dentro del endpoint y los desactiva
         for _, v in pairs(coinPart:GetDescendants()) do
            if v:IsA("LocalScript") then
               v.Disabled = true
               print("Script de teletransporte desactivado: " .. v.Name)
            end
         end
      end
   end,
})

-- Botón 2: Touch Interest Falso
FarmTab:CreateButton({
   Name = "👻 Ghost Touch Único (1-Shot sin Moverse)",
   Callback = function()
      local coinPart = getCoinPart()
      local hrp = getHRP()
      if coinPart and hrp and firetouchinterest then
         firetouchinterest(hrp, coinPart, 0)
         task.wait(0.05)
         firetouchinterest(hrp, coinPart, 1)
      end
   end,
})

-- Botón 3: Traer el Endpoint hacia el Jugador
FarmTab:CreateButton({
   Name = "🧲 Traer Parte a Mí (Bring Part)",
   Callback = function()
      local coinPart = getCoinPart()
      local hrp = getHRP()
      if coinPart and hrp then
         coinPart.CFrame = hrp.CFrame
      end
   end,
})

-- Botón 4: Teletransporte Suave por Desplazamiento (Tween)
FarmTab:CreateButton({
   Name = "🚀 TP Suave (Desplazamiento Anti-Cheat)",
   Callback = function()
      local hrp = getHRP()
      local coinPart = getCoinPart()
      if hrp then
         local targetCFrame = coinPart and coinPart.CFrame or CFrame.new(targetPos)
         local tween = game:GetService("TweenService"):Create(
            hrp, 
            TweenInfo.new(0.15, Enum.EasingStyle.Linear), 
            {CFrame = targetCFrame}
         )
         tween:Play()
      end
   end,
})
