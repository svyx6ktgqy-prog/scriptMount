local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "VFX & Combat Hub",
   LoadingTitle = "Optimizando Armamento...",
   LoadingSubtitle = "por Rayfield",
   ConfigurationSaving = { Enabled = false }
})

-- ==========================================
-- PESTAÑA 1: EFECTOS VISUALES (AURA)
-- ==========================================
local TabVisuals = Window:CreateTab("Auras", 4483362458)
local auraId = "129667288853780"
local auraTag = "SigmaAura_Particle"

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
              for _, item in ipairs(result:GetDescendants()) do
                  if item:IsA("ParticleEmitter") or item:IsA("PointLight") or item:IsA("Fire") or item:IsA("Attachment") then
                      local clone = item:Clone()
                      clone:SetAttribute(auraTag, true)
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() 
              Rayfield:Notify({Title = "Aura", Content = "Partículas activadas.", Duration = 2})
          end
      else
          -- DESACTIVACIÓN LIMPIA
          for _, child in ipairs(rootPart:GetChildren()) do
              if child:GetAttribute(auraTag) then
                  child:Destroy()
              end
          end
          Rayfield:Notify({Title = "Aura", Content = "Partículas removidas.", Duration = 2})
      end
   end,
})

-- ==========================================
-- PESTAÑA 2: ARSENAL MILITAR (POSTURA Y ENCAJE)
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"
local weaponToolName = "ArmaMilitar_Equipable"
local loadedAnimTrack = nil
local originalElbowC0 = nil

local function crearArmaAjustada(objetosDescargados)
    local newTool = Instance.new("Tool")
    newTool.Name = weaponToolName
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    local partes3D = {}
    for _, obj in ipairs(objetosDescargados) do
        if obj:IsA("BasePart") then table.insert(partes3D, obj) end
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(partes3D, desc) end
        end
    end
    
    if #partes3D == 0 then return nil end

    -- Handle base sin peso
    local masterHandle = Instance.new("Part")
    masterHandle.Name = "Handle"
    masterHandle.Size = Vector3.new(0.2, 0.2, 0.2)
    masterHandle.Transparency = 1
    masterHandle.CanCollide = false
    masterHandle.Anchored = false
    masterHandle.Massless = true
    masterHandle.Parent = newTool

    for _, parte in ipairs(partes3D) do
        for _, child in ipairs(parte:GetChildren()) do
            if child:IsA("JointInstance") or child:IsA("WeldConstraint") then child:Destroy() end
        end
        parte.Anchored = false
        parte.CanCollide = false
        parte.Massless = true
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = masterHandle
        weld.Part1 = parte
        weld.Parent = masterHandle
        parte.Parent = newTool
    end

    -- AL EQUIPAR: AJUSTE DE CODO MAS DOBLADO Y ENCAJE EN EL MANGO
    newTool.Equipped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local manoDerecha = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        
        if manoDerecha then
            -- Posicionar el masterHandle desplazado para que la mano calce exacto en la empuñadura
            masterHandle.CFrame = manoDerecha.CFrame * CFrame.new(0, -0.15, -0.45) * CFrame.Angles(math.rad(-10), 0, 0)
            
            local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
            if oldGrip then oldGrip:Destroy() end
            
            local manualGrip = Instance.new("WeldConstraint")
            manualGrip.Name = "ManualGripAttachment"
            manualGrip.Part0 = manoDerecha
            manualGrip.Part1 = masterHandle
            manualGrip.Parent = masterHandle
        end

        -- DOBLAR MÁS EL CODO (Ajuste profundo de -40 grados hacia atrás y leve caída en Y)
        local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
        if elbowJoint and elbowJoint:IsA("Motor6D") then
            if not originalElbowC0 then originalElbowC0 = elbowJoint.C0 end
            elbowJoint.C0 = originalElbowC0 * CFrame.new(0, -0.1, 0) * CFrame.Angles(math.rad(-40), 0, 0)
        end
        
        -- Cargar animación de sostener
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator") or hum
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507768375" 
            loadedAnimTrack = animator:LoadAnimation(anim)
            loadedAnimTrack.Priority = Enum.AnimationPriority.Action
            loadedAnimTrack:Play()
        end
    end)

    newTool.Unequipped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            -- Restaurar codo a su estado original
            local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
            if elbowJoint and elbowJoint:IsA("Motor6D") and originalElbowC0 then
                elbowJoint.C0 = originalElbowC0
                originalElbowC0 = nil
            end
        end
        
        local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
        if oldGrip then oldGrip:Destroy() end
        
        if loadedAnimTrack then
            loadedAnimTrack:Stop()
            loadedAnimTrack = nil
        end
    end)

    return newTool
end

TabCombat:CreateToggle({
   Name = "Obtener / Equipar Arma",
   CurrentValue = false,
   Flag = "WeaponSwitch",
   Callback = function(Value)
      if Value then
          local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. weaponId) end)
          if success and objects then
              local armaListo = crearArmaAjustada(objects)
              if armaListo then
                  armaListo.Parent = LocalPlayer.Backpack
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChildOfClass("Humanoid") then
                      character:FindFirstChildOfClass("Humanoid"):EquipTool(armaListo)
                  end
              end
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
-- LÁSER ANCLADO A LA MANO & ELEVADO AL CAÑÓN
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

-- Calcula el origen del láser directamente desde la mano cargando la elevación vertical
local function getLaserStartPoint(character)
    local manoDerecha = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if manoDerecha then
        -- Elevamos +0.4 en Y (arriba) y adelantamos -1.8 en Z (frente del arma) desde la mano
        local laserOriginCF = manoDerecha.CFrame * CFrame.new(0, 0.4, -1.8)
        return laserOriginCF.Position
    end
    return character.HumanoidRootPart.Position
end

TabCombat:CreateToggle({
   Name = "Activar Láser Táctico & Auto-ESP",
   CurrentValue = false,
   Flag = "LaserToggle",
   Callback = function(Value)
       if Value then
           Mouse.Icon = "rbxasset://textures/GunCursor.png"
           
           -- RenderStepped hace que el láser camine y corra junto con la mano en cada frame
           laserConnection = RunService.RenderStepped:Connect(function()
               local character = LocalPlayer.Character
               if not character then return end
               local tool = character:FindFirstChildOfClass("Tool")
               
               if tool then
                   laserPart.Transparency = 0.2
                   local startPos = getLaserStartPoint(character)
                   local endPos = Mouse.Hit.Position
                   local distance = (startPos - endPos).Magnitude
                   
                   -- Trazado dinámico del láser
                   laserPart.Size = Vector3.new(0.02, 0.02, distance)
                   laserPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
                   
                   local rayParams = RaycastParams.new()
                   rayParams.FilterDescendantsInstances = {character, laserPart, tool}
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
