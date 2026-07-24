-- Cargamos la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Bypass & Auto-Forjado: ACTIVADO",
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
               local obj = objects[1]
               local realTool = nil
               
               -- ==========================================
               -- 2. [NUEVO] SISTEMA DE AUTO-FORJADO
               -- ==========================================
               if obj:IsA("Tool") then
                   realTool = obj -- Si ya es un Tool, perfecto.
               else
                   -- Buscamos por si el Tool está escondido dentro del modelo
                   local innerTool = obj:FindFirstChildWhichIsA("Tool", true)
                   if innerTool then
                       realTool = innerTool
                   else
                       -- 🚨 CONVERSIÓN FORZADA 🚨
                       -- Creamos el cascarón del Tool artificialmente
                       realTool = Instance.new("Tool")
                       realTool.RequiresHandle = true
                       
                       if obj:IsA("BasePart") then
                           obj.Name = "Handle"
                           obj.Parent = realTool
                       elseif obj:IsA("Model") or obj:IsA("Folder") then
                           -- Movemos todos los scripts, mallas y partes al nuevo Tool
                           for _, child in pairs(obj:GetChildren()) do
                               child.Parent = realTool
                           end
                           
                           -- Buscamos una parte física para que sirva de agarre (Handle)
                           local handle = realTool:FindFirstChild("Handle") or realTool:FindFirstChildWhichIsA("BasePart")
                           if handle then
                               handle.Name = "Handle"
                           else
                               -- Si por algún motivo no hay piezas físicas, creamos una invisible
                               handle = Instance.new("Part")
                               handle.Name = "Handle"
                               handle.Size = Vector3.new(1, 1, 1)
                               handle.Transparency = 1
                               handle.Parent = realTool
                           end
                       end
                   end
               end
               
               if not realTool then
                   error("Fallo crítico en el Auto-Forjado: No se pudo generar la herramienta.")
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
               
               -- 4. Guardamos en StarterGear
               if player:FindFirstChild("StarterGear") then
                   local gearClone = clonedTool:Clone()
                   gearClone.Parent = player.StarterGear
               end

               -- 5. BYPASS DE MOCHILA (Directo a la mano)
               clonedTool.Parent = character
               
               Rayfield:Notify({
                   Title = "Éxito (Auto-Forjado)",
                   Content = "Modelo convertido a Tool y soldado a tus manos.",
                   Duration = 3,
               })
           end)

           -- Captura de errores
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
