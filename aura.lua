local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Window = Rayfield:CreateWindow({
   Name = "VFX & Combat Hub",
   LoadingTitle = "Ajustando Armamento...",
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
                      clone:SetAttribute(auraTag, true) -- Etiqueta para borrado exacto
                      clone.Parent = rootPart
                  end
              end
              result:Destroy() 
              Rayfield:Notify({Title = "Aura", Content = "Efectos aplicados.", Duration = 2})
          end
      else
          -- DESACTIVACIÓN LIMPIA: Remueve únicamente los elementos del aura
          for _, child in ipairs(rootPart:GetChildren()) do
              if child:GetAttribute(auraTag) then
                  child:Destroy()
              end
          end
          Rayfield:Notify({Title = "Aura", Content = "Efectos removidos.", Duration = 2})
      end
   end,
})

-- ==========================================
-- PESTAÑA 2: ARSENAL MILITAR (AJUSTE DE CODO)
-- ==========================================
local TabCombat = Window:CreateTab("Combate", 4370318685)
local weaponId = "86551486545687"
local weaponToolName = "ArmaMilitar_Equipable"
local loadedAnimTrack = nil

local function crearArmaConAjusteDeCodo(objetosDescargados)
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

    local minPos = Vector3.new(math.huge, math.huge, math.huge)
    local maxPos = Vector3.new(-math.huge, -math.huge, -math.huge)
    for _, parte in ipairs(partes3D) do
        minPos = Vector3.new(math.min(minPos.X, parte.Position.X), math.min(minPos.Y, parte.Position.Y), math.min(minPos.Z, parte.Position.Z))
        maxPos = Vector3.new(math.max(maxPos.X, parte.Position.X), math.max(maxPos.Y, parte.Position.Y), math.max(maxPos.Z, parte.Position.Z))
    end
    local centroModelo = (minPos + maxPos) / 2

    local masterHandle = Instance.new("Part")
    masterHandle.Name = "Handle"
    masterHandle.Size = Vector3.new(0.2, 0.2, 0.2)
    masterHandle.Transparency = 1
    masterHandle.CanCollide = false
    masterHandle.Anchored = false
    masterHandle.Massless = true
    masterHandle.CFrame = CFrame.new(centroModelo)
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

    -- AL EQUIPAR: RETROCEDER CODO Y PEGAR MANO
    newTool.Equipped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local manoDerecha = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        if manoDerecha then
            local oldGrip = masterHandle:FindFirstChild("ManualGripAttachment")
            if oldGrip then oldGrip:Destroy() end
            
            local manualGrip = Instance.new("WeldConstraint")
            manualGrip.Name = "ManualGripAttachment"
            manualGrip.Part0 = manoDerecha
            manualGrip.Part1 = masterHandle
            manualGrip.Parent = masterHandle
        end

        -- AJUSTE DE CODO (Ajuste leve del ángulo del codo hacia atrás)
        local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
        if elbowJoint and elbowJoint:IsA("Motor6D") then
            elbowJoint.C0 = elbowJoint.C0 * CFrame.Angles(math.rad(-15), 0, 0) -- Retrocede el codo 15 grados
        end
        
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
            -- Restablecer el codo a su posición original al desequipar
            local elbowJoint = char:FindFirstChild("RightElbow", true) or char:FindFirstChild("Right Elbow", true)
            if elbowJoint and elbowJoint:IsA("Motor6D") then
                elbowJoint.C0 = elbowJoint.C0 * CFrame.Angles(math.rad(15), 0, 0)
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
              local armaListo = crearArmaConAjusteDeCodo(objects)
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
-- SISTEMA DE LÁSER ALINEADO AL CAÑÓN
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

-- Obtiene la punta del arma y su orientación frontal
local function getMuzzleCFrame(tool)
    local muzzle = tool:FindFirstChild("Muzzle", true) or tool:FindFirstChild("FirePoint", true) or tool:FindFirstChild("Barrel", true)
    if muzzle and muzzle:IsA("BasePart") then
        return muzzle.CFrame
    end
    local handle = tool:FindFirstChild("Handle")
    if handle then
        return handle.CFrame * CFrame.new(0, 0, -1.5) -- Proyección frontal desde el mango
    end
    return LocalPlayer.Character.HumanoidRootPart.CFrame
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
                   local muzzleCF = getMuzzleCFrame(tool)
                   local startPos = muzzleCF.Position
                   local endPos = Mouse.Hit.Position
                   local distance = (startPos - endPos).Magnitude
                   
                   -- Dibujar láser orientado exactamente hacia la mira
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
