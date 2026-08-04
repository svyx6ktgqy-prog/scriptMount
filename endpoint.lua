-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Quirúrgico + Imán Avanzado",
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

-- Función quirúrgica para neutralizar físicas
local function resetMomentum(hrp)
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

-- NUEVA FUNCIÓN MEJORADA: Magnetismo Fasma con Heurística de Rotación
local function collectFloatingCoins(hrp)
    if not hrp or not firetouchinterest then return end
    
    local count = 0
    -- Escaneamos todo el Workspace buscando objetos
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- 1. Debe ser una parte física (BasePart, MeshPart, Union, etc.)
        -- 2. No debe ser nuestro endpoint principal "10000"
        if obj:IsA("BasePart") and obj.Name ~= "10000" then
            
            -- Filtro de seguridad: Que no sea el cuerpo de otro jugador
            if not obj.Parent:FindFirstChildOfClass("Humanoid") then
                
                local isCoinTarget = false
                
                -- CONDICIÓN A: Detección estándar (Tiene TouchTransmitter)
                if obj:FindFirstChildOfClass("TouchTransmitter") then
                    isCoinTarget = true
                end
                
                -- CONDICIÓN B: Detección por comportamiento (Animación/Rotación)
                if not isCoinTarget then
                    for _, child in ipairs(obj:GetChildren()) do
                        -- Búsqueda de componentes físicos de rotación
                        if child:IsA("BodyAngularVelocity") or child:IsA("AngularVelocity") then
                            isCoinTarget = true
                            break
                        -- Búsqueda de scripts de animación de rotación
                        elseif child:IsA("Script") or child:IsA("LocalScript") then
                            local scriptName = string.lower(child.Name)
                            if scriptName:match("rot") or scriptName:match("spin") or scriptName:match("anim") then
                                isCoinTarget = true
                                break
                            end
                        end
                    end
                end
                
                -- Si cumple alguna de las condiciones, simulamos el toque
                if isCoinTarget then
                    pcall(function()
                        firetouchinterest(hrp, obj, 0)
                        task.wait(0.01) -- Micro pausa para que el servidor procese el toque
                        firetouchinterest(hrp, obj, 1)
                    end)
                    
                    count = count + 1
                    -- Ceder un frame al motor de Roblox cada 15 monedas para evitar tirones (Lag)
                    if count % 15 == 0 then task.wait(0.05) end
                end
            end
        end
    end
end

-- ========================================================
-- SECCIÓN DE SWITCHES (Toggles)
-- ========================================================

-- Switch Smart: Terreno -> Endpoint -> Salto (Jump) -> Caída -> 12s Descanso + RECOLECCIÓN AVANZADA
FarmTab:CreateToggle({
   Name = "⚡ Smart Switch (Terreno + Salto + 12s + Imán)",
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
               
               if hrp and humanoid and humanoid.Health > 0 then
                  resetMomentum(hrp)
                  -- 1. Saltar a un lado del endpoint para tocar el terreno físico
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                  
                  task.wait(0.4) 
                  
                  if not smartFarmActive or humanoid.Health <= 0 then break end
                  
                  -- 2. Inmediatamente saltar a gran altura justo sobre el endpoint
                  resetMomentum(hrp)
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 35, 0))
                  
                  -- 3. Esperar mientras cae e interceptar el salto.
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
                  
                  -- 4. Descanso de 12 segundos y Recolección de Monedas Flotantes/Rotatorias
                  if smartFarmActive then
                     local restStartTime = tick()
                     
                     -- EJECUCIÓN DEL IMÁN: Recoge todo el mapa mientras el personaje descansa
                     collectFloatingCoins(hrp)
                     
                     -- Consumimos el tiempo restante de los 12 segundos
                     while smartFarmActive and (tick() - restStartTime) < 12 do
                        task.wait(0.5)
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
                  resetMomentum(hrp)
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
                  pcall(function()
                     firetouchinterest(hrp, coinPart, 0)
                     task.wait(0.01)
                     firetouchinterest(hrp, coinPart, 1)
                  end)
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
         resetMomentum(hrp)
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
         pcall(function()
             firetouchinterest(hrp, coinPart, 0)
             task.wait(0.05)
             firetouchinterest(hrp, coinPart, 1)
         end)
      else
         warn("firetouchinterest no está soportado o falló en tu ejecutor.")
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
