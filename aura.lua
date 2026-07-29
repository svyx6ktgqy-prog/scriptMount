local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "VFX & Combat Hub",
   LoadingTitle = "Cargando Sistema Avanzado...",
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
          local success, result = pcall(function() return game:GetObjects("rbxassetid://" .. auraId)[1] end)
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
-- PESTAÑA 2: ARSENAL MILITAR (SOLUCIÓN ROBUSTA)
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"
local weaponToolName = "ArmaMilitar_Equipable"
local loadedAnimTrack = nil -- Guardará la animación de agarre

-- FUNCIÓN ROBUSTA PARA CONSTRUIR EL ARMA
local function construirArmaRobusta(objetosDescargados)
    -- 1. Crear la herramienta desde cero
    local newTool = Instance.new("Tool")
    newTool.Name = weaponToolName
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    -- 2. Recopilar todas las piezas 3D (Meshes, Parts, etc.)
    local partes3D = {}
    for _, obj in ipairs(objetosDescargados) do
        if obj:IsA("BasePart") then table.insert(partes3D, obj) end
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(partes3D, desc) end
        end
    end
    
    if #partes3D == 0 then return nil end -- Si no hay modelo 3D, fallar
    
    -- 3. Crear un HANDLE ARTIFICIAL PERFECTO (Invisible y central)
    local masterHandle = Instance.new("Part")
    masterHandle.Name = "Handle"
    masterHandle.Size = Vector3.new(0.5, 0.5, 0.5)
    masterHandle.Transparency = 1 -- Invisible
    masterHandle.CanCollide = false
    masterHandle.Massless = true -- SIN PESO
    masterHandle.CFrame = partes3D[1].CFrame -- Ubicarlo donde está el modelo
    masterHandle.Parent = newTool
    
    -- Ajustar el agarre para que quede bien en la mano
    newTool.Grip = CFrame.new(0, 0, 0)
    
    -- 4. Reparar y soldar todas las partes al Handle Artificial
    for _, parte in ipairs(partes3D) do
        -- Ignorar si la parte es nuestro nuevo handle
        if parte ~= masterHandle then
            parte.Anchored = false      -- Evitar que se quede flotando en el mapa
            parte.CanCollide = false    -- Evitar que te empuje o salgas volando
            parte.Massless = true       -- Quitarle el peso para no romper tu brazo
            
            -- Crear soldadura inquebrantable
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = masterHandle
            weld.Part1 = parte
            weld.Parent = masterHandle
            
            parte.Parent = newTool
        end
    end
    
    -- 5. Programar Animación de Agarre al Equipar
    newTool.Equipped:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator") or hum
            -- Usamos una animación genérica de sostener herramienta/arma de Roblox
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507768375" 
            loadedAnimTrack = animator:LoadAnimation(anim)
            loadedAnimTrack.Priority = Enum.AnimationPriority.Action
            loadedAnimTrack:Play()
        end
    end)
    
    newTool.Unequipped:Connect(function()
        if loadedAnimTrack then
            loadedAnimTrack:Stop()
            loadedAnimTrack = nil
        end
    end)
    
    return newTool
end

-- SWITCH DEL ARMA
TabCombat:CreateToggle({
   Name = "Obtener / Equipar Arma",
   CurrentValue = false,
   Flag = "WeaponSwitch",
   Callback = function(Value)
      if Value then
          local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. weaponId) end)
          
          if success and objects then
              -- Usar nuestro constructor infalible
              local armaLista = construirArmaRobusta(objects)
              
              if armaLista then
                  armaLista.Parent = LocalPlayer.Backpack
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChildOfClass("Humanoid") then
                      character:FindFirstChildOfClass("Humanoid"):EquipTool(armaLista)
                  end
                  Rayfield:Notify({Title = "Arma Operativa", Content = "Modelo reparado y fijado a la mano.", Duration = 3})
              else
                  warn("El ID descargado no contiene partes 3D (Modelos).")
              end
          else
              Rayfield:Notify({Title = "Error", Content = "ID del arma fallido o privado.", Duration = 3})
          end
      else
          local weaponInBackpack = LocalPlayer.Backpack:FindFirstChild(weaponToolName)
          if weaponInBackpack then weaponInBackpack:Destroy() end
          
          if LocalPlayer.Character then
              local weaponInChar = LocalPlayer.Character:FindFirstChild(weaponToolName)
              if weaponInChar then weaponInChar:Destroy() end
          end
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
    -- Buscar partes realistas para que salga el láser
    local firePoint = tool:FindFirstChild("Muzzle", true) or tool:FindFirstChild("FirePoint", true) or tool:FindFirstChild("Barrel", true) or tool:FindFirstChild("Handle")
    if firePoint and firePoint:IsA("BasePart") then
        return firePoint.Position
    end
    return LocalPlayer.Character.HumanoidRootPart.Position
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
