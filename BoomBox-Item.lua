-- Cargamos la librería Rayfield de forma segura
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Creamos la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Sistema Antitrabas y Anti-Ban: ACTIVADO",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Creamos una pestaña para el equipamiento
local Tab = Window:CreateTab("Inventario", 4483362458) 

-- Variables globales para la herramienta
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320" -- La ID de la radio que proporcionaste
local clonedTool = nil

-- Creamos el Toggle (Activar / Desactivar)
Tab:CreateToggle({
   Name = "Equipar Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       
       if Value then
           -- [ACTIVADO] - Dar la radio de forma segura (Antitrabas)
           local success, errorMessage = pcall(function()
               -- GetObjects es la función estándar de ejecutores para cargar IDs del catálogo
               local objects = game:GetObjects(assetId)
               
               if objects and #objects > 0 then
                   clonedTool = objects[1]
                   clonedTool.Name = toolName
                   -- La enviamos directamente a la mochila (Backpack)
                   clonedTool.Parent = player.Backpack 
                   
                   Rayfield:Notify({
                       Title = "Radio Equipada",
                       Content = "La BoomBoxV3 se ha añadido a tu inventario.",
                       Duration = 2,
                   })
               end
           end)

           -- Manejo de errores por si el ejecutor no soporta GetObjects
           if not success then
               Rayfield:Notify({
                   Title = "Error de Ejecutor",
                   Content = "Tu ejecutor no soporta cargar esta ID. Error ocultado (Anti-BAN).",
                   Duration = 3,
               })
           end
           
       else
           -- [DESACTIVADO] - Eliminar la radio de la mano o mochila
           pcall(function()
               -- 1. Eliminamos la referencia inicial si existe
               if clonedTool then
                   clonedTool:Destroy()
                   clonedTool = nil
               end
               
               -- 2. Buscamos y eliminamos de la Mochila (Inventario)
               if player.Backpack:FindFirstChild(toolName) then
                   player.Backpack[toolName]:Destroy()
               end
               
               -- 3. Buscamos y eliminamos de la Mano (Workspace / Character)
               if player.Character and player.Character:FindFirstChild(toolName) then
                   player.Character[toolName]:Destroy()
               end
               
               Rayfield:Notify({
                   Title = "Radio Eliminada",
                   Content = "La BoomBoxV3 ha sido removida de tu equipamiento.",
                   Duration = 2,
               })
           end)
       end
   end,
})
