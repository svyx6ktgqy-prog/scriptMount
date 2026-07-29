local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "VFX & Combat Hub",
   LoadingTitle = "Cargando Sistema...",
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
                  if item:IsA("ParticleEmitter") or item:IsA("PointLight") or item:IsA("Fire") or item:IsA("Attachment") then
                      local clone = item:Clone()
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() 
              Rayfield:Notify({Title = "Aura", Content = "Partículas activadas.", Duration = 2})
          end
      else
          if character:FindFirstChild(auraName) then character[auraName]:Destroy() end
      end
   end,
})

-- ==========================================
-- PESTAÑA 2: ARSENAL MILITAR
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"
local weaponToolName = "ArmaMilitar_Equipable"

-- FUNCIÓN PARA REPARAR Y PEGAR CUALQUIER MODELO DE ARMA A LA MANO
local function fijarArmaAMano(tool)
    tool.Name = weaponToolName
    
    local partes = {}
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false      -- ¡SOLUCIÓN 1! Desanclar para que se mueva con la mano
            desc.CanCollide = false    -- ¡SOLUCIÓN 2! Quitar colisión para no chocar con el jugador
            table.insert(partes, desc)
        end
    end
    
    -- Buscar o definir el Handle (pieza de agarre)
    local handle = tool:FindFirstChild("Handle")
    if not handle and #partes > 0 then
        handle = partes[1]
        handle.Name = "Handle"
    end
    
    if handle then
        -- ¡SOLUCIÓN 3! Soldar (Weld) todas las demás piezas al Handle
        for _, parte in ipairs(partes) do
            if parte ~= handle then
                local yaSoldado = false
                for _, child in ipairs(parte:GetChildren()) do
                    if child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("Motor6D") then
                        yaSoldado = true
                        break
                    end
                end
                
                if not yaSoldado then
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = handle
                    weld.Part1 = parte
                    weld.Parent = handle
                end
            end
        end
        
        -- Centrar agarre a la mano del jugador
        tool.Grip = CFrame.new(0, 0, 0)
    end
    
    return tool
end

-- SWITCH/TOGGLE DEL ARMA
TabCombat:CreateToggle({
   Name = "Obtener / Equipar Arma Militar",
   CurrentValue = false,
   Flag = "WeaponSwitch",
   Callback = function(Value)
      if Value then
          -- ACTIVAR: Cargar, reparar posicionamiento y equipar
          local success, objects = pcall(function()
              return game:GetObjects("rbxassetid://" .. weaponId)
          end)
          
          if success and objects then
              local toolEncontrado = nil
              
              -- 1. Intentar encontrar un Tool existente
              for _, obj in ipairs(objects) do
                  if obj:IsA("Tool") then
                      toolEncontrado = obj
                      break
                  end
              end
              
              -- 2. Buscar dentro de folders o modelos
              if not toolEncontrado then
                  for _, obj in ipairs(objects) do
                      local childTool = obj:FindFirstChildWhichIsA("Tool", true)
                      if childTool then
                          toolEncontrado = childTool
                          break
                      end
                  end
              end
              
              -- 3. Si no hay Tool, crear uno empaquetando todo el modelo
              if not toolEncontrado then
                  toolEncontrado = Instance.new("Tool")
                  for _, obj in ipairs(objects) do
                      obj.Parent = toolEncontrado
                  end
              else
                  toolEncontrado = toolEncontrado:Clone()
              end
              
              -- Aplicar arreglos de físicas y soldaduras
              local armaLista = fijarArmaAMano(toolEncontrado)
              armaLista.Parent = LocalPlayer.Backpack
              
              -- Auto-equipar en la mano inmediatamente
              local character = LocalPlayer.Character
              if character and character:FindFirstChildOfClass("Humanoid") then
                  character:FindFirstChildOfClass("Humanoid"):EquipTool(armaLista)
              end
              
              Rayfield:Notify({
                  Title = "Arma Equipada",
                  Content = "Arma ajustada y pegada a la mano correctamente.",
                  Duration = 3
              })
          else
              Rayfield:Notify({Title = "Error", Content = "No se pudo obtener el ID del arma.", Duration = 3})
          end
      else
          -- DESACTIVAR: Eliminar el arma del inventario y de la mano
          local weaponInBackpack = LocalPlayer.Backpack:FindFirstChild(weaponToolName)
          if weaponInBackpack then weaponInBackpack:Destroy() end
          
          if LocalPlayer.Character then
              local weaponInChar = LocalPlayer.Character:FindFirstChild(weaponToolName)
              if weaponInChar then weaponInChar:Destroy() end
          end
          
          Rayfield:Notify({
              Title = "Arma Desactivada",
              Content = "El arma ha sido removida por completo.",
              Duration = 2
          })
      end
   end,
})

-- ==========================================
-- SISTEMA DE LÁSER TÁCTICO & ESP
-- ==========================================
local laserPart = Instance.new("Part")
laserPart.Anchored = true
laserPart.CanCollide = false
laserPart.Material = Enum.Material.Neon
laserPart.Color = Color3.new(1, 0, 0)
laserPart.Size = Vector3.new(0.03, 0.03, 1)
laserPart.Transparency = 1 
laserPart.Parent = workspace

local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.new(1, 0, 0)
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0

local laserConnection
local currentEspTarget = nil

local function getLaserStartPoint(tool)
    local firePoint = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("FirePoint") or tool:FindFirstChild("Hole") or tool:FindFirstChild("Barrel") or tool:FindFirstChild("Handle")
    if firePoint and firePoint:IsA("BasePart") then
        return firePoint.Position
    elseif firePoint and firePoint:IsA("Attachment") then
        return firePoint.WorldPosition
    end
    
    local fallback = tool:FindFirstChildWhichIsA("BasePart", true)
    return fallback and fallback.Position or LocalPlayer.Character.HumanoidRootPart.Position
end

TabCombat:CreateToggle({
   Name = "Activar Láser Táctico & Auto-ESP",
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
                   laserPart.Transparency = 0.2
                   local startPos = getLaserStartPoint(tool)
                   local endPos = Mouse.Hit.Position
                   local distance = (startPos - endPos).Magnitude
                   
                   laserPart.Size = Vector3.new(0.02, 0.02, distance)
                   laserPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
                   
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
                   laserPart.Transparency = 1
                   highlight.Parent = nil
                   currentEspTarget = nil
               end
           end)
       else
           if laserConnection then laserConnection:Disconnect() end
           Mouse.Icon = ""
           laserPart.Transparency = 1
           highlight.Parent = nil
           currentEspTarget = nil
       end
   end,
})
