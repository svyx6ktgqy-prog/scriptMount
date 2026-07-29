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
   Name = "Activar Aura Sigma",
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
              local folder = Instance.new("Folder", character)
              folder.Name = auraName
              
              for _, item in ipairs(result:GetDescendants()) do
                  if item:IsA("ParticleEmitter") or item:IsA("PointLight") or item:IsA("Fire") then
                      local clone = item:Clone()
                      clone.Parent = rootPart
                  elseif item:IsA("Attachment") then
                      local clone = item:Clone()
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() 
              Rayfield:Notify({Title = "Aura", Content = "Partículas aplicadas con éxito.", Duration = 2})
          end
      else
          if character:FindFirstChild(auraName) then character[auraName]:Destroy() end
      end
   end,
})

-- ==========================================
-- PESTAÑA 2: ARSENAL MILITAR (ARMA + LÁSER)
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"

TabCombat:CreateButton({
   Name = "Generar Arma en Inventario",
   Callback = function()
       -- Fix: Obtenemos TODOS los objetos del ID, no solo el primero
       local success, objects = pcall(function()
           return game:GetObjects("rbxassetid://" .. weaponId)
       end)
       
       if success and objects then
           local herramientasEncontradas = 0
           
           for _, obj in ipairs(objects) do
               -- Si el objeto base es un Tool
               if obj:IsA("Tool") then
                   obj.Parent = LocalPlayer.Backpack
                   herramientasEncontradas = herramientasEncontradas + 1
               end
               
               -- Escaneamos dentro del objeto por si el Tool está escondido en un Modelo
               for _, child in ipairs(obj:GetDescendants()) do
                   if child:IsA("Tool") then
                       -- Clonamos el tool y lo ponemos en la mochila (selector de items)
                       local toolClone = child:Clone()
                       toolClone.Parent = LocalPlayer.Backpack
                       herramientasEncontradas = herramientasEncontradas + 1
                       
                       -- Opcional: Equiparlo automáticamente
                       local character = LocalPlayer.Character
                       if character and character:FindFirstChild("Humanoid") then
                           character.Humanoid:EquipTool(toolClone)
                       end
                   end
               end
           end
           
           if herramientasEncontradas > 0 then
               Rayfield:Notify({
                   Title = "Arma Equipada", 
                   Content = "Se añadió al selector de items (Inventario).", 
                   Duration = 3
               })
           else
               -- Failsafe: Si el ID no tiene un "Tool", creamos uno forzado para que aparezca en el inventario
               local fakeTool = Instance.new("Tool")
               fakeTool.Name = "Arma Táctica (Auto-Generada)"
               fakeTool.RequiresHandle = false
               
               for _, obj in ipairs(objects) do
                   obj.Parent = fakeTool
                   -- Buscamos algo que sirva de Handle (agarradera)
                   if obj:IsA("BasePart") and not fakeTool:FindFirstChild("Handle") then
                       obj.Name = "Handle"
                   end
               end
               
               fakeTool.Parent = LocalPlayer.Backpack
               Rayfield:Notify({
                   Title = "Tool Creado", 
                   Content = "El modelo fue convertido a un Item equipable.", 
                   Duration = 4
               })
           end
       else
           warn("Error: No se pudo descargar el ID. Puede estar parcheado o ser privado.")
           Rayfield:Notify({Title = "Error", Content = "Fallo al obtener el ID del arma.", Duration = 3})
       end
   end,
})

-- ==========================================
-- SISTEMA DE LÁSER Y ESP TÁCTICO MEJORADO
-- ==========================================
local laserPart = Instance.new("Part")
laserPart.Anchored = true
laserPart.CanCollide = false
laserPart.Material = Enum.Material.Neon
laserPart.Color = Color3.new(1, 0, 0) -- Rojo láser
laserPart.Size = Vector3.new(0.03, 0.03, 1) -- Más delgado y realista
laserPart.Transparency = 1 
laserPart.Parent = workspace

local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.new(1, 0, 0)
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local laserConnection
local currentEspTarget = nil

-- Función para buscar de dónde debe salir el láser
local function getLaserStartPoint(tool)
    -- Busca partes comunes del cañón de un arma
    local firePoint = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("FirePoint") or tool:FindFirstChild("Hole") or tool:FindFirstChild("Barrel") or tool:FindFirstChild("Handle")
    if firePoint and firePoint:IsA("BasePart") then
        return firePoint.Position
    elseif firePoint and firePoint:IsA("Attachment") then
        return firePoint.WorldPosition
    end
    
    -- Si no encuentra nada, usa cualquier parte del arma
    local fallback = tool:FindFirstChildWhichIsA("BasePart", true)
    return fallback and fallback.Position or LocalPlayer.Character.HumanoidRootPart.Position
end

TabCombat:CreateToggle({
   Name = "Activar Láser & Auto-ESP",
   CurrentValue = false,
   Flag = "LaserToggle",
   Callback = function(Value)
       if Value then
           Mouse.Icon = "rbxasset://textures/GunCursor.png"
           
           laserConnection = RunService.RenderStepped:Connect(function()
               local character = LocalPlayer.Character
               if not character then return end
               
               local tool = character:FindFirstChildOfClass("Tool")
               
               if tool then
                   laserPart.Transparency = 0.2 -- Ligeramente transparente para mejor efecto visual
                   local startPos = getLaserStartPoint(tool)
                   local endPos = Mouse.Hit.Position
                   local distance = (startPos - endPos).Magnitude
                   
                   -- Dibujar láser
                   laserPart.Size = Vector3.new(0.02, 0.02, distance)
                   laserPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
                   
                   -- Raycast para el ESP
                   local rayParams = RaycastParams.new()
                   rayParams.FilterDescendantsInstances = {character, laserPart}
                   local rayResult = workspace:Raycast(startPos, (endPos - startPos).Unit * 1000, rayParams)
                   
                   if rayResult and rayResult.Instance then
                       local hitModel = rayResult.Instance:FindFirstAncestorOfClass("Model")
                       if hitModel and hitModel:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(hitModel) then
                           if currentEspTarget ~= hitModel then
                               currentEspTarget = hitModel
                               highlight.Parent = hitModel
                           end
                       else
                           highlight.Parent = nil
                           currentEspTarget = nil
                       end
                   else
                       highlight.Parent = nil
                       currentEspTarget = nil
                   end
               else
                   -- Ocultar si guardas el arma
                   laserPart.Transparency = 1
                   highlight.Parent = nil
                   currentEspTarget = nil
               end
           end)
       else
           -- Apagar todo
           if laserConnection then laserConnection:Disconnect() end
           Mouse.Icon = ""
           laserPart.Transparency = 1
           highlight.Parent = nil
           currentEspTarget = nil
       end
   end,
})
