-- Cargar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ultimate Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Suite | Interceptador GUI",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local GuiTab = Window:CreateTab("Auto Recompensas", 4483362458) -- Nueva Pestaña

-- Configuración y Estados
local targetPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)
local autoFarmActive = false
local smartFarmActive = false
local ghostFarmActive = false
local guiFarmActive = false

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

-- Función para forzar Clics en la Interfaz (Bypass de GUI)
local function forceButtonClick(btn)
    if not btn or not btn:IsA("GuiButton") then return end
    
    pcall(function()
        -- 1. Forzar visibilidad para evitar comprobaciones anti-cheat del lado del cliente
        btn.Visible = true
        local parent = btn.Parent
        while parent and parent:IsA("GuiObject") do
            parent.Visible = true
            parent = parent.Parent
        end
        
        -- 2. Ejecutar el clic interceptando las conexiones (Soportado por casi todos los ejecutores)
        if getconnections then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do
                conn:Fire()
            end
        elseif firesignal then
            firesignal(btn.MouseButton1Click)
        end
    end)
end

-- Magnetismo físico corregido (Agregado el chequeo de nombre "Coin")
local function collectFloatingCoins(hrp)
    if not hrp or not firetouchinterest then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "10000" and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            local isCoinTarget = false
            local name = string.lower(obj.Name)
            
            if name:match("coin") or obj:FindFirstChildOfClass("TouchTransmitter") then
                isCoinTarget = true
            end
            
            if isCoinTarget then
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
        end
    end
end

-- ========================================================
-- SECCIÓN DE RECOMPENSAS GUI (NUEVO)
-- ========================================================
GuiTab:CreateToggle({
   Name = "🎁 Auto Reclamo de GUI (Coins & PlayRewards)",
   CurrentValue = false,
   Flag = "ToggleGUIRewards",
   Callback = function(Value)
      guiFarmActive = Value
      if guiFarmActive then
         task.spawn(function()
            while guiFarmActive do
               local player = game.Players.LocalPlayer
               if player and player:FindFirstChild("PlayerGui") then
                  local mainGui = player.PlayerGui:FindFirstChild("Main")
                  if mainGui then
                     
                     -- 1. Reclamar PlayRewards (Del 1 al 40)
                     local playRewardsSlots = mainGui:FindFirstChild("PlayRewards") and mainGui.PlayRewards:FindFirstChild("Slots")
                     if playRewardsSlots then
                        for i = 1, 40 do
                           local slot = playRewardsSlots:FindFirstChild(tostring(i))
                           if slot and slot:FindFirstChild("Button") then
                              forceButtonClick(slot.Button)
                           end
                        end
                     end
                     
                     -- 2. Reclamar Coins (Nombres variados como 500, 2000, 100000, etc.)
                     local coinsSlots = mainGui:FindFirstChild("Coins") and mainGui.Coins:FindFirstChild("Slots")
                     if coinsSlots then
                        -- Iteramos sobre TODOS los hijos, sin importar el número que tengan
                        for _, slot in ipairs(coinsSlots:GetChildren()) do
                           if slot:FindFirstChild("Button") then
                              forceButtonClick(slot.Button)
                           end
                        end
                     end
                     
                  end
               end
               
               -- Espera 10 segundos antes de volver a reclamar para evitar ban por spam de Remotes
               for i = 1, 100 do
                   if not guiFarmActive then break end
                   task.wait(0.1)
               end
            end
         end)
      end
   end,
})

GuiTab:CreateButton({
   Name = "🎒 Inspeccionar y Activar Botones (Una vez)",
   Callback = function()
       local player = game.Players.LocalPlayer
       if player and player:FindFirstChild("PlayerGui") then
           local mainGui = player.PlayerGui:FindFirstChild("Main")
           if mainGui then
               print("--- Forzando activación de interfaz ---")
               -- Abrir/Visibilizar los menús principales para destrabar si están ocultos
               if mainGui:FindFirstChild("PlayRewards") then mainGui.PlayRewards.Visible = true end
               if mainGui:FindFirstChild("Coins") then mainGui.Coins.Visible = true end
               print("Menús activados visualmente.")
           end
       end
   end,
})

-- ========================================================
-- SECCIÓN DE SWITCHES DE MAPA (Auto Farm Físico)
-- ========================================================

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
                     local restStartTime = tick()
                     collectFloatingCoins(hrp)
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
