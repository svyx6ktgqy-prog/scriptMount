-- Cargamos la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Sistema Reforzado: Activado",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Inventory", 4483362458) 

-- Variables globales
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320"
local clonedTool = nil

Tab:CreateToggle({
   Name = "Equip Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           -- Sin seguros que oculten errores. Si falla, capturamos el error real.
           local success, errorMessage = pcall(function()
               
               -- 1. Descargamos el asset directamente
               local objects = game:GetObjects(assetId)
               local realTool = nil
               
               -- 2. Buscamos inteligentemente el 'Tool' por si viene dentro de un 'Model'
               for _, obj in pairs(objects) do
                   if obj:IsA("Tool") then
                       realTool = obj
                       break
                   elseif obj:IsA("Model") then
                       local foundTool = obj:FindFirstChildWhichIsA("Tool")
                       if foundTool then
                           realTool = foundTool
                           break
                       end
                   end
               end
               
               if not realTool then
                   error("El Asset ID descargado no contiene un Tool (Objeto equipable).")
               end
               
               clonedTool = realTool
               clonedTool.Name = toolName
               
               -- 3. [NUEVO] ANTI-FREEZE: Desanclamos todas las piezas para que no te trabes al equiparlo
               for _, part in pairs(clonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false
                       part.CanCollide = false -- Evita que la radio choque con paredes
                   end
               end
               
               -- 4. Guardamos en StarterGear (para cuando reaparezcas)
               if player:FindFirstChild("StarterGear") then
                   local gearClone = clonedTool:Clone()
                   gearClone.Parent = player.StarterGear
               end

               -- 5. Lo metemos a la mochila PRIMERO
               clonedTool.Parent = player.Backpack 
               
               -- 6. [NUEVO] Sincronización: Esperamos un instante antes de forzar el equipamiento
               task.wait(0.15) 
               
               -- 7. Forzamos el agarre en la mano
               if humanoid then
                   humanoid:EquipTool(clonedTool)
               end
               
               Rayfield:Notify({
                   Title = "Éxito",
                   Content = "Radio forzada en tus manos correctamente.",
                   Duration = 2,
               })
           end)

           -- Si hay error, te mostramos EXACTAMENTE cuál fue el problema del ejecutor
           if not success then
               Rayfield:Notify({
                   Title = "Error del Ejecutor",
                   Content = tostring(errorMessage), -- Muestra el error real
                   Duration = 6,
               })
           end
           
       else
           -- [DESACTIVADO] - Limpieza absoluta
           pcall(function()
               if player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName) then
                   player.StarterGear[toolName]:Destroy()
               end
               if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName) then
                   player.Backpack[toolName]:Destroy()
               end
               if character and character:FindFirstChild(toolName) then
                   character[toolName]:Destroy()
               end
               if clonedTool then
                   clonedTool:Destroy()
                   clonedTool = nil
               end
               
               Rayfield:Notify({
                   Title = "Radio Eliminada",
                   Content = "Inventario y manos limpias.",
                   Duration = 2,
               })
           end)
       end
   end,
})
