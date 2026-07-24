-- Cargamos la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Fix UI & Auto-Forjado: ACTIVADO",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Inventario", 4483362458) 

-- Variables globales
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320"
local clonedTool = nil
local clonedGui = nil -- [NUEVO] Variable para guardar la interfaz de la radio

Tab:CreateToggle({
   Name = "Equipar Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           local success, errorMessage = pcall(function()
               
               -- Forzamos a mostrar siempre la barra de inventario
               local StarterGui = game:GetService("StarterGui")
               pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
               
               -- Descargamos el asset
               local objects = game:GetObjects(assetId)
               local obj = objects[1]
               local realTool = nil
               
               -- SISTEMA DE AUTO-FORJADO
               if obj:IsA("Tool") then
                   realTool = obj 
               else
                   local innerTool = obj:FindFirstChildWhichIsA("Tool", true)
                   if innerTool then
                       realTool = innerTool
                   else
                       realTool = Instance.new("Tool")
                       realTool.RequiresHandle = true
                       if obj:IsA("BasePart") then
                           obj.Name = "Handle"
                           obj.Parent = realTool
                       elseif obj:IsA("Model") or obj:IsA("Folder") then
                           for _, child in pairs(obj:GetChildren()) do child.Parent = realTool end
                           local handle = realTool:FindFirstChild("Handle") or realTool:FindFirstChildWhichIsA("BasePart")
                           if handle then handle.Name = "Handle"
                           else
                               handle = Instance.new("Part")
                               handle.Name = "Handle"
                               handle.Size = Vector3.new(1, 1, 1)
                               handle.Transparency = 1
                               handle.Parent = realTool
                           end
                       end
                   end
               end
               
               if not realTool then error("Error en Auto-Forjado.") end
               
               clonedTool = realTool
               clonedTool.Name = toolName
               
               -- ANTI-FREEZE
               for _, part in pairs(clonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false
                       part.CanCollide = false 
                   end
               end
               
               -- ==========================================
               -- [FIX 3]: INYECCIÓN MANUAL DE INTERFAZ (UI)
               -- ==========================================
               -- Buscamos la interfaz del buscador de IDs dentro de la radio
               local hiddenGui = clonedTool:FindFirstChildWhichIsA("ScreenGui", true)
               if hiddenGui then
                   -- La clonamos y la enviamos a la pantalla del jugador
                   clonedGui = hiddenGui:Clone()
                   clonedGui.Parent = player:WaitForChild("PlayerGui")
                   clonedGui.Enabled = false -- La ocultamos por defecto
                   
                   -- Programamos el clic izquierdo para abrir/cerrar el menú
                   clonedTool.Activated:Connect(function()
                       if clonedGui then
                           clonedGui.Enabled = not clonedGui.Enabled
                       end
                   end)
               else
                   Rayfield:Notify({
                       Title = "Advertencia",
                       Content = "No se encontró una UI (Buscador) dentro del código de esta radio.",
                       Duration = 4,
                   })
               end
               
               -- Persistencia al morir
               if player:FindFirstChild("StarterGear") then
                   local gearClone = clonedTool:Clone()
                   gearClone.Parent = player.StarterGear
               end

               -- CICLO DE EQUIPAMIENTO NATURAL
               clonedTool.Parent = player.Backpack 
               task.wait(0.2) 
               if humanoid then humanoid:EquipTool(clonedTool) end
               
               Rayfield:Notify({
                   Title = "Equipamiento Exitoso",
                   Content = "Radio lista. Haz clic para abrir el buscador de IDs.",
                   Duration = 3,
               })
           end)

           if not success then
               Rayfield:Notify({Title = "Error", Content = tostring(errorMessage), Duration = 6})
           end
           
       else
           -- Limpieza al desactivar (Incluyendo la UI)
           pcall(function()
               if clonedGui then clonedGui:Destroy() clonedGui = nil end -- Eliminamos el buscador de IDs de la pantalla
               if player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName) then player.StarterGear[toolName]:Destroy() end
               if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName) then player.Backpack[toolName]:Destroy() end
               if character and character:FindFirstChild(toolName) then character[toolName]:Destroy() end
               if clonedTool then clonedTool:Destroy() clonedTool = nil end
               
               Rayfield:Notify({Title = "Radio Eliminada", Content = "Equipamiento y UI removidos limpiamente.", Duration = 2})
           end)
       end
   end,
})
