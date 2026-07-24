-- Cargamos la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Bypass de Inventario: ACTIVADO",
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
       
       if Value then
           local success, errorMessage = pcall(function()
               
               -- 1. Descargamos el asset directamente
               local objects = game:GetObjects(assetId)
               local realTool = nil
               
               -- 2. Buscamos el 'Tool' de forma segura
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
               
               -- 3. ANTI-FREEZE: Desanclamos todas las piezas para evitar bloqueos físicos
               for _, part in pairs(clonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false
                       part.CanCollide = false 
                   end
               end
               
               -- 4. Guardamos en StarterGear (Solo por si el juego reinicia tu personaje)
               if player:FindFirstChild("StarterGear") then
                   local gearClone = clonedTool:Clone()
                   gearClone.Parent = player.StarterGear
               end

               -- ==========================================
               -- 5. [SOLUCIÓN DEFINITIVA]: BYPASS DE MOCHILA
               -- Ignoramos Backpack y EquipTool(). Metemos la herramienta
               -- directamente al Character. Esto fuerza a Roblox a pegarla a tu mano.
               -- ==========================================
               clonedTool.Parent = character
               
               Rayfield:Notify({
                   Title = "Éxito (Bypass Activo)",
                   Content = "Radio soldada directamente a tus manos.",
                   Duration = 3,
               })
           end)

           -- Captura de errores transparente
           if not success then
               Rayfield:Notify({
                   Title = "Error del Ejecutor",
                   Content = tostring(errorMessage), 
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
               
               -- Destrucción directa desde el personaje (donde ahora reside la radio)
               if character and character:FindFirstChild(toolName) then
                   character[toolName]:Destroy()
               end
               
               if clonedTool then
                   clonedTool:Destroy()
                   clonedTool = nil
               end
               
               Rayfield:Notify({
                   Title = "Radio Eliminada",
                   Content = "Equipamiento eliminado limpiamente.",
                   Duration = 2,
               })
           end)
       end
   end,
})
