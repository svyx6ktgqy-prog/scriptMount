-- Cargar librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Mini chit Hood Argentino",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "por Gattoi | Delta iOS",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "HoodArgentinoHub"
   },
   Discord = {
      Enabled = true,
      Invite = "no-invite", -- Puedes poner tu link aquí si tienes server
      RememberJoins = true 
   },
   KeySystem = false
})

-- Notificación de inicio
Rayfield:Notify({
   Title = "¡Script Cargado!",
   Content = "Discord ID: Gattoi",
   Duration = 5,
   Image = 4483362458
})

-- Crear Pestaña Principal
local MainTab = Window:CreateTab("Inicio", 4483362458) 

-- Toggle: Generador de plata
MainTab:CreateToggle({
   Name = "Generador de plata (PedidosYa)",
   CurrentValue = false,
   Flag = "GeneradorPlata", 
   Callback = function(Value)
      getgenv().a = Value
      
      if Value then
         -- Teletransportarse y agarrar el trabajo inicial
         local p = workspace.map.map_jobs.pedidosYaJOB.pedidosYaNPC.Trigger
         local player = game.Players.LocalPlayer
         local v = player.Character.HumanoidRootPart.Position
         
         player.Character.HumanoidRootPart.Position = p.Position
         task.wait(0.5)
         fireproximityprompt(p.ProximityPrompt)
         task.wait(0.5)
         player.Character.HumanoidRootPart.Position = v
         
         -- Bucle infinito para farmear
         task.spawn(function()
            while getgenv().a do
               task.wait(0.001)
               pcall(function() -- pcall evita que el script crashee en Delta si no encuentra el GUI
                  firesignal(player.PlayerGui.pedidosYaGUI.screenFrame.acceptButton.MouseButton1Click)
                  local r = player.PlayerGui.pedidosYaGUI
                  local d = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("pedidosya")
                  
                  d:WaitForChild("attemptPickup"):FireServer(r.restaurantLocation.Value)
                  d:WaitForChild("attemptDelivery"):FireServer(r.deliveryLocation.Value)
               end)
            end
         end)
      end
   end,
})

-- Variable global para el auto-agarrar
getgenv().autoGrab = false

-- Eventos de ChildAdded configurados afuera para evitar duplicar conexiones
workspace.Filter.CashDrops.ChildAdded:Connect(function(v)
   if getgenv().autoGrab and v:FindFirstChild("claim") then
      v.claim.HoldDuration = 0
      fireproximityprompt(v.claim)
   end
end)

workspace.CuerposMuertos.Filter.CashDrops.ChildAdded:Connect(function(v)
   if getgenv().autoGrab and v:FindFirstChild("claim") then
      v.claim.HoldDuration = 0
      fireproximityprompt(v.claim)
   end
end)

-- Toggle: Anti-perder plata + agarrar automático
MainTab:CreateToggle({
   Name = "Anti-perder plata + Agarrar automático",
   CurrentValue = false,
   Flag = "AutoAgarrar",
   Callback = function(Value)
      getgenv().autoGrab = Value
   end,
})

-- Información extra
local InfoTab = Window:CreateTab("Créditos", 4483362458)
InfoTab:CreateLabel("Discord ID: Gattoi")
InfoTab:CreateLabel("Optimizado para Delta iOS / iPhone")
