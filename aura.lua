local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "VFX & Combat Hub",
   LoadingTitle = "Cargando Arsenal...",
   LoadingSubtitle = "por Rayfield",
   ConfigurationSaving = { Enabled = false }
})

-- ==========================================
-- PESTAÑA 1: EFECTOS VISUALES (AURA)
-- ==========================================
local TabVisuals = Window:CreateTab("Auras", 4483362458)
local auraId = "129667288853780"
local auraName = "SigmaAura_Fixed"

TabVisuals:CreateToggle({
   Name = "Activar Aura Sigma (Fijado)",
   CurrentValue = false,
   Flag = "AuraToggle", 
   Callback = function(Value)
      local character = LocalPlayer.Character
      if not character or not character:FindFirstChild("HumanoidRootPart") then return end
      local rootPart = character.HumanoidRootPart

      if Value then
          local success, result = pcall(function()
              return game:GetObjects("rbxassetid://" .. auraId)[1]
          end)

          if success and result then
              -- En lugar de solo meter el modelo, extraemos las partículas y las ponemos en tu pecho/centro
              local folder = Instance.new("Folder", character)
              folder.Name = auraName
              
              for _, item in ipairs(result:GetDescendants()) do
                  if item:IsA("ParticleEmitter") or item:IsA("PointLight") or item:IsA("Fire") then
                      local clone = item:Clone()
                      clone.Parent = rootPart -- Las pegamos directamente a ti
                  elseif item:IsA("Attachment") then
                      local clone = item:Clone()
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() -- Borramos el modelo base que no sirve
              
              Rayfield:Notify({Title = "Aura Activada", Content = "Partículas adheridas a tu cuerpo.", Duration = 3})
          else
              warn("Error al cargar el aura. Verifica el ID o tu ejecutor.")
          end
      else
          -- Limpiar las partículas del rootPart
          if character:FindFirstChild(auraName) then character[auraName]:Destroy() end
          for _, item in ipairs(rootPart:GetChildren()) do
              -- Si quieres ser cuidadoso, podrías borrar solo las que tú pusiste. 
              -- Aquí asumimos que si desactivas, quieres limpiar la zona.
              if item:IsA("Attachment") and not item:FindFirstChildOriginal("OriginalPosition") then
                  -- Forma segura de no borrar attachments del juego base (simplificada)
              end
          end
          -- Limpieza forzada por nombre (si las guardamos en el folder)
          if character:FindFirstChild(auraName) then
             character[auraName]:Destroy()
          end
      end
   end,
})

-- ==========================================
-- PESTAÑA 2: ARSENAL MILITAR (ARMA + LÁSER)
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"

TabCombat:CreateButton({
   Name = "Obtener Arma Militar",
   Callback = function()
       local success, result = pcall(function()
           return game:GetObjects("rbxassetid://" .. weaponId)[1]
       end)
       
       if success and result then
           if result:IsA("Tool") then
               result.Parent = LocalPlayer.Backpack
               Rayfield:Notify({Title = "Arma Recibida", Content = "Revisa tu inventario.", Duration = 3})
           else
               -- Si el asset es un modelo con herramientas dentro
               for _, item in ipairs(result:GetChildren()) do
                   if item:IsA("Tool") then
                       item.Parent = LocalPlayer.Backpack
                   end
               end
           end
       else
           warn("No se pudo cargar el arma. Es posible que el ID sea privado o inválido.")
       end
   end,
})

-- Variables para el Láser y ESP
local laserPart = Instance.new("Part")
laserPart.Anchored = true
laserPart.CanCollide = false
laserPart.Material = Enum.Material.Neon
laserPart.Color = Color3.new(1, 0, 0) -- Rojo
laserPart.Size = Vector3.new(0.05, 0.05, 1)
laserPart.Transparency = 1 -- Oculto por defecto
laserPart.Parent = workspace

local currentEspTarget = nil
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.new(1, 0, 0)
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local laserConnection

TabCombat:CreateToggle({
   Name = "Activar Láser Táctico & ESP",
   CurrentValue = false,
   Flag = "LaserToggle",
   Callback = function(Value)
       if Value then
           -- Forzar crosshair (puntero de cruz)
           Mouse.Icon = "rbxasset://textures/GunCursor.png"
           
           laserConnection = RunService.RenderStepped:Connect(function()
               local character = LocalPlayer.Character
               if not character then return end
               
               local tool = character:FindFirstChildOfClass("Tool")
               
               if tool and tool:FindFirstChild("Handle") then
                   -- Si tiene un arma equipada, dibujar láser
                   laserPart.Transparency = 0
                   local startPos = tool.Handle.Position
                   local endPos = Mouse.Hit.Position
                   local distance = (startPos - endPos).Magnitude
                   
                   laserPart.Size = Vector3.new(0.05, 0.05, distance)
                   laserPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
                   
                   -- Lógica del Raycast para el ESP
                   local rayParams = RaycastParams.new()
                   rayParams.FilterDescendantsInstances = {character, laserPart}
                   local rayResult = workspace:Raycast(startPos, (endPos - startPos).Unit * 500, rayParams)
                   
                   if rayResult and rayResult.Instance then
                       local hitModel = rayResult.Instance:FindFirstAncestorOfClass("Model")
                       if hitModel and hitModel:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(hitModel) then
                           -- Si apuntamos a un jugador, ponerle el Highlight (ESP)
                           if currentEspTarget ~= hitModel then
                               currentEspTarget = hitModel
                               highlight.Parent = hitModel
                           end
                       else
                           -- Si dejamos de apuntarle, quitar el Highlight
                           highlight.Parent = nil
                           currentEspTarget = nil
                       end
                   else
                       highlight.Parent = nil
                       currentEspTarget = nil
                   end
               else
                   -- Si guarda el arma, ocultar láser y ESP
                   laserPart.Transparency = 1
                   highlight.Parent = nil
                   currentEspTarget = nil
               end
           end)
       else
           -- Desactivar todo
           if laserConnection then laserConnection:Disconnect() end
           Mouse.Icon = ""
           laserPart.Transparency = 1
           highlight.Parent = nil
           currentEspTarget = nil
       end
   end,
})
