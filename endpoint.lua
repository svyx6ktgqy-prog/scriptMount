-- Cargar la librería Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Auto Farm - Endpoint 10000",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "CoinGiver Teleport",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Crear Tab de Farm
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

-- Variables de control
local autoFarmActive = false
local targetPos = Vector3.new(-109.99999237060547, 482.2499084472656, 119.49998474121094)

-- Crear el Switch (Toggle)
local Toggle = FarmTab:CreateToggle({
   Name = "Super Switch 10K Farm",
   CurrentValue = false,
   Flag = "Toggle10kFarm",
   Callback = function(Value)
      autoFarmActive = Value
      
      if autoFarmActive then
         task.spawn(function()
            while autoFarmActive do
               task.wait(0.01) -- Ajusta el tiempo si quieres más estabilidad o más velocidad
               
               local player = game.Players.LocalPlayer
               local character = player.Character or player.CharacterAdded:Wait()
               local hrp = character:FindFirstChild("HumanoidRootPart")
               
               if hrp then
                  -- Intentar buscar la parte directamente en el mapa
                  local coinPart = workspace:FindFirstChild("Map") 
                     and workspace.Map:FindFirstChild("CoinGivers") 
                     and workspace.Map.CoinGivers:FindFirstChild("10000")
                  
                  if coinPart then
                     -- Teletransporte directo al CFrame de la parte
                     hrp.CFrame = coinPart.CFrame
                  else
                     -- Respaldo usando las coordenadas exactas si la parte no carga en el mapa
                     hrp.CFrame = CFrame.new(targetPos)
                  end
               end
            end
         end)
      end
   end,
})
