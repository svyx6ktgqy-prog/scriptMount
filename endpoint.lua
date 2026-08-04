-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite (Versión Quirúrgica)",
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
local blockClientTP = false

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Funciones auxiliares dinámicas (Resistentes a Respawn)
local function getCoinPart()
    return workspace:FindFirstChild("Map") 
       and workspace.Map:FindFirstChild("CoinGivers") 
       and workspace.Map.CoinGivers:FindFirstChild("10000")
end

local function getCharacterData()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 2)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
    return char, hrp, hum
end

-- ========================================================
-- SISTEMA QUIRÚRGICO ANTI-TELEPORT (Hook de Metamétodos)
-- ========================================================
local oldNewIndex
if hookmetamethod then
    pcall(function()
        oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if blockClientTP and not checkcaller() and key == "CFrame" then
                local _, hrp = getCharacterData()
                if self == hrp then
                    -- Intercepta y bloquea cualquier intento del juego de cambiar tu posición
                    return
                end
            end
            return oldNewIndex(self, key, value)
        end)
    end)
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
               local _, hrp, humanoid = getCharacterData()
               local coinPart = getCoinPart()
               local basePos = coinPart and coinPart.Position or targetPos
               
               if hrp and humanoid then
                  -- 1. Saltar a un lado del endpoint para tocar el terreno físico
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(15, 5, 0))
                  task.wait(0.4) 
                  
                  if not smartFarmActive then break end
                  
                  -- 2. Saltar a gran altura sobre el endpoint
                  hrp.CFrame = CFrame.new(basePos + Vector3.new(0, 35, 0))
                  
                  -- 3. Forzar salto al caer cerca del bloque
                  local isJumping = false
                  repeat
                     task.wait(0.05)
                     _, hrp, humanoid = getCharacterData()
                     
                     if not isJumping and hrp and hrp.Position.Y < (basePos.Y + 5) then
                         humanoid.Jump = true
                         isJumping = true
                     end
                  until not smartFarmActive or (hrp and hrp.Position.Y < (basePos.Y - 50))
                  
                  -- 4. Descanso de 12 segundos
                  if smartFarmActive then
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
               local _, hrp = getCharacterData()
               local coinPart = getCoinPart()
               if hrp then
                  hrp.CFrame = coinPart and coinPart.CFrame or CFrame.new(targetPos)
               end
            end
         end)
      end
   end,
})

-- Switch Ghost Touch Avanzado (Anti-TP Hook Integrado)
FarmTab:CreateToggle({
   Name = "👻 Ghost Switch (Reclamo Bucle + Interceptor TP)",
   CurrentValue = false,
   Flag = "ToggleGhost",
   Callback = function(Value)
      ghostFarmActive = Value
      blockClientTP = Value -- Activa el bloqueo de teletransporte local
      
      if ghostFarmActive then
         task.spawn(function()
            while ghostFarmActive do
               task.wait(0.05)
               local coinPart = getCoinPart()
               local _, hrp = getCharacterData()
               
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
      local _, hrp = getCharacterData()
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
      local _, hrp = getCharacterData()
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
      local _, hrp = getCharacterData()
      if coinPart and hrp then
         coinPart.CFrame = hrp.CFrame
      end
   end,
})

-- Botón 4: Teletransporte Suave por Desplazamiento (Tween)
FarmTab:CreateButton({
   Name = "🚀 TP Suave (Desplazamiento Anti-Cheat)",
   Callback = function()
      local _, hrp = getCharacterData()
      local coinPart = getCoinPart()
      if hrp then
         local targetCFrame = coinPart and coinPart.CFrame or CFrame.new(targetPos)
         local tween = TweenService:Create(
            hrp, 
            TweenInfo.new(0.15, Enum.EasingStyle.Linear), 
            {CFrame = targetCFrame}
         )
         tween:Play()
      end
   end,
})

-- Botón 5: Desconectar Scripts de Colisión/Touch del Mapa
FarmTab:CreateButton({
   Name = "🛠️ Neutralizar Conexiones Touch del Endpoint",
   Callback = function()
      local coinPart = getCoinPart()
      if coinPart and getconnections then
         for _, connection in pairs(getconnections(coinPart.Touched)) do
            connection:Disable()
         end
         Rayfield:Notify({
            Title = "Éxito",
            Content = "Se han desactivado las conexiones del evento Touched en la parte.",
            Duration = 3
         })
      end
   end,
})
