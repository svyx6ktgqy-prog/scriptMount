-- =====================================================================
-- 🔪 BATTLE SNIFE - REFLEX ENGINE V2 (ANTI-PING & OPTIMIZADO)
-- UI: Rayfield (sirius.menu/rayfield)
-- =====================================================================

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Delta: Error al cargar Rayfield.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Battle Snife 🔪 V2",
   LoadingTitle = "Reflex Engine V2...",
   LoadingSubtitle = "Optimizado para Delta iOS",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- =====================================================================
-- VARIABLES GLOBALES
-- =====================================================================
local AutoPingPong = false
local CatchRadius = 25 -- Aumentado por defecto para compensar el ping móvil
local AutoAim = true

local function ClickMobileButton(buttonName)
    pcall(function()
        local guiPath = LocalPlayer.PlayerGui.HUD.MobileButtons[buttonName]
        if guiPath and guiPath:FindFirstChild("click") then
            local btn = guiPath.click
            for _, connection in pairs(getconnections(btn.MouseButton1Click) or {}) do connection:Fire() end
            for _, connection in pairs(getconnections(btn.MouseButton1Down) or {}) do connection:Fire() end
            for _, connection in pairs(getconnections(btn.TouchTap) or {}) do connection:Fire() end
        end
    end)
end

-- =====================================================================
-- PESTAÑA: MOTOR DE REFLEJOS
-- =====================================================================
local CombatTab = Window:CreateTab("Reflex Combat", 4483362458)
CombatTab:CreateSection("Auto Ping-Pong V2 (Defensa Mejorada)")

CombatTab:CreateToggle({
   Name = "⚡ Activar Auto-Catch & Throw Perfecto",
   CurrentValue = false,
   Flag = "AutoPingPong",
   Callback = function(Value)
       AutoPingPong = Value
       
       if AutoPingPong then
           RunService.RenderStepped:Connect(function()
               if not AutoPingPong then return end
               
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("HumanoidRootPart") then return end
               
               local myRoot = character.HumanoidRootPart
               local hasKnife = character:FindFirstChildOfClass("Tool") ~= nil

               -- FASE OFFENSIVA: Tienes el cuchillo en la mano
               if hasKnife then
                   local closestEnemy = nil
                   local shortestDist = math.huge
                   
                   for _, p in ipairs(Players:GetPlayers()) do
                       if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                           local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                           if dist < shortestDist then
                               shortestDist = dist
                               closestEnemy = p.Character
                           end
                       end
                   end
                   
                   if closestEnemy then
                       if AutoAim then
                           myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(closestEnemy.HumanoidRootPart.Position.X, myRoot.Position.Y, closestEnemy.HumanoidRootPart.Position.Z))
                       end
                       ClickMobileButton("Throw")
                       task.wait(0.15)
                   end

               -- FASE DEFENSIVA: Escáner Ligero (Esperando el cuchillo)
               else
                   -- Usamos GetChildren (NO Descendants) para evitar lag en iPhone
                   for _, obj in pairs(workspace:GetChildren()) do
                       local targetPart = nil
                       
                       -- Identificamos si el objeto es la parte directa o un modelo/herramienta
                       if obj:IsA("BasePart") then
                           targetPart = obj
                       elseif obj:IsA("Model") or obj:IsA("Tool") then
                           targetPart = obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                       end
                       
                       if targetPart then
                           local name = obj.Name:lower()
                           -- Ampliamos los nombres detectables a cualquier cosa que parezca un proyectil
                           if name:match("knife") or name:match("blade") or name:match("handle") or name:match("throw") or name:match("tool") then
                               
                               local dist = (myRoot.Position - targetPart.Position).Magnitude
                               
                               -- Eliminamos la restricción de Velocity. Solo importa si está cerca.
                               if dist <= CatchRadius then
                                   ClickMobileButton("Catch")
                                   task.wait(0.1) -- Pausa corta para no bloquear el script tras intentar atrapar
                                   break -- Salimos del loop para ahorrar batería/CPU una vez presionado
                               end
                           end
                       end
                   end
               end
           end)
       end
   end,
})

CombatTab:CreateSlider({
   Name = "Radio de Captura (Studs) - SÚBELO SI HAY LAG",
   Range = {10, 60},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 25,
   Flag = "CatchRadius",
   Callback = function(Value)
       CatchRadius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "🎯 Auto-Apuntado (Aimbot)",
   CurrentValue = true,
   Flag = "AutoAim",
   Callback = function(Value)
       AutoAim = Value
   end,
})
