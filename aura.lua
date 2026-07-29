-- Cargar la librería de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VFX Aura Hub",
   LoadingTitle = "Cargando Efectos...",
   LoadingSubtitle = "por Rayfield",
   ConfigurationSaving = {
      Enabled = false
   }
})

local Tab = Window:CreateTab("Efectos Visuales", 4483362458) -- Icono genérico
local Section = Tab:CreateSection("Auras del Personaje")

-- Variables principales
local assetId = "129667288853780"
local auraName = "SigmaVFX_CustomAura" -- Nombre identificador para poder borrarlo
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Tab:CreateToggle({
   Name = "Activar Aura Sigma",
   CurrentValue = false,
   Flag = "AuraToggle", 
   Callback = function(Value)
      local character = LocalPlayer.Character
      
      if Value then
          -- SI SE ACTIVA: Cargar y aplicar el aura
          if character then
              -- Evitar duplicados si ya existe
              if character:FindFirstChild(auraName) then return end
              
              -- Usamos pcall para evitar que el script se rompa si el ejecutor no soporta GetObjects
              local success, result = pcall(function()
                  return game:GetObjects("rbxassetid://" .. assetId)[1]
              end)

              if success and result then
                  local auraClone = result:Clone()
                  auraClone.Name = auraName
                  
                  -- Insertamos el modelo en el personaje. 
                  -- Si el modelo tiene sus propios LocalScripts de posicionamiento, se ejecutarán aquí.
                  auraClone.Parent = character
                  
                  Rayfield:Notify({
                      Title = "Aura Activada",
                      Content = "El efecto de partículas se ha aplicado a tu personaje.",
                      Duration = 3
                  })
              else
                  warn("Error al cargar el asset. Tu ejecutor podría no soportar GetObjects.")
              end
          end
      else
          -- SI SE DESACTIVA: Buscar el aura en el personaje y eliminarla
          if character then
              local existingAura = character:FindFirstChild(auraName)
              if existingAura then
                  existingAura:Destroy()
                  
                  Rayfield:Notify({
                      Title = "Aura Desactivada",
                      Content = "El efecto de partículas ha sido removido.",
                      Duration = 3
                  })
              end
          end
      end
   end,
})
