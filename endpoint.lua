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

-- ========================================================
-- SECCIÓN DE SWITCHES (Toggles)
-- ========================================================

-- Switch Smart: Terreno -> Endpoint -> Caída -> 10s Descanso
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch (Terreno + Caída + 10s)",
   CurrentValue = false,
   Flag = "ToggleSmart",
   Callback = function(Value)
      smartFarmActive = Value
      if smartFarmActive then
         task.spawn(function()
            while smartFarmActive do
               local hrp = getHRP()
               local coinPart = getCoinPart()
               local basePos = coinPart and coinPart.Position or targetPos
               
               if hrp then
                  -- 1. Saltar a un lado del endpoint para tocar el terreno físico
                  -- Nos movemos 15 studs a un lado (eje X) y un poco arriba para asegurar que toque el suelo
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                  
                  -- Pequeña pausa para asegurar que el personaje toque el suelo y salga el mensaje de "has ganado"
                  task.wait(0.4) 
                  
                  if not smartFarmActive then break end
                  
                  -- 2. Inmediatamente saltar a gran altura justo sobre el endpoint
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 35, 0))
                  
                  -- 3. Esperar a que caiga naturalmente, toque el endpoint, 
                  -- y el juego lo devuelva automáticamente al mapa inicial (abajo).
                  repeat
                     task.wait(0.1)
                     hrp = getHRP()
                  until not smartFarmActive or (hrp and hrp.Position.Y < (basePos.Y - 50))
                  
                  -- 4. Descanso de 10 segundos en el mapa inicial
                  if smartFarmActive then
                     -- Bucle de 10 segundos comprobando cada 1 segundo.
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
