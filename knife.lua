-- =====================================================================
-- 🔪 BATTLE SNIFE - REFLEX ENGINE
-- Lógica adaptada para atrapar y lanzar (Estilo "Papa Caliente")
-- =====================================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Battle Snife UI 🔪",
   LoadingTitle = "Cargando Reflex Engine...",
   LoadingSubtitle = "Precisión de milisegundos",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- =====================================================================
-- VARIABLES GLOBALES Y UTILIDADES
-- =====================================================================
local AutoPingPong = false
local CatchRadius = 12 -- Distancia en studs para activar el Catch
local AutoAim = true

-- Función para simular clics en tu HUD móvil
local function ClickMobileButton(buttonName)
    pcall(function()
        local guiPath = LocalPlayer.PlayerGui.HUD.MobileButtons[buttonName]
        if guiPath and guiPath:FindFirstChild("click") then
            local btn = guiPath.click
            for _, connection in pairs(getconnections(btn.MouseButton1Click) or getconnections(btn.MouseButton1Down)) do
                connection:Fire()
            end
        end
    end)
end

-- =====================================================================
-- PESTAÑA: MOTOR DE REFLEJOS (COMBATE)
-- =====================================================================
local CombatTab = Window:CreateTab("Reflex Combat", 4483362458)

CombatTab:CreateSection("Auto Ping-Pong (Defensa y Ataque)")

CombatTab:CreateToggle({
   Name = "⚡ Activar Auto-Catch & Throw Perfecto",
   CurrentValue = false,
   Flag = "AutoPingPong",
   Callback = function(Value)
       AutoPingPong = Value
       
       if AutoPingPong then
           -- Loop ultrarrápido atado a los frames del juego para no perder ni un milisegundo
           RunService.RenderStepped:Connect(function()
               if not AutoPingPong then return end
               
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("HumanoidRootPart") then return end
               
               local myRoot = character.HumanoidRootPart
               local hasKnife = character:FindFirstChildOfClass("Tool") ~= nil

               -- FASE 1: OFFENSIVA (Tengo el cuchillo)
               if hasKnife then
                   local closestEnemy = nil
                   local shortestDist = math.huge
                   
                   -- Buscar enemigo
                   for _, p in ipairs(Players:GetPlayers()) do
                       if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                           local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                           if dist < shortestDist then
                               shortestDist = dist
                               closestEnemy = p.Character
                           end
                       end
                   end
                   
                   -- Apuntar y Lanzar
                   if closestEnemy then
                       if AutoAim then
                           -- Girar al personaje físicamente hacia el enemigo
                           myRoot.CFrame = CFrame.lookAt(myRoot.Position, closestEnemy.HumanoidRootPart.Position)
                       end
                       ClickMobileButton("Throw")
                       task.wait(0.1) -- Pequeña pausa para evitar spam extremo del botón
                   end

               -- FASE 2: DEFENSIVA (No tengo el cuchillo, debo atraparlo)
               else
                   -- Escanear el mapa por cuchillos voladores
                   for _, obj in pairs(workspace:GetDescendants()) do
                       -- Buscamos partes que se parezcan al cuchillo o se muevan rápido
                       if obj:IsA("BasePart") and (obj.Name:lower():match("knife") or obj.Name:lower():match("blade")) then
                           local dist = (myRoot.Position - obj.Position).Magnitude
                           
                           -- Si el cuchillo está dentro de nuestro radio de captura y NO está quieto (Velocity > 0)
                           if dist <= CatchRadius and obj.Velocity.Magnitude > 5 then
                               ClickMobileButton("Catch")
                               -- Pausa brevísima tras intentar atrapar para no trabar la GUI
                               task.wait(0.2) 
                           end
                       end
                   end
               end
           end)
       end
   end,
})

CombatTab:CreateSlider({
   Name = "Radio de Captura (Studs)",
   Range = {5, 30},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 12,
   Flag = "CatchRadius",
   Callback = function(Value)
       CatchRadius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "🎯 Auto-Apuntado al Lanzar (Aimbot Cuchillo)",
   CurrentValue = true,
   Flag = "AutoAim",
   Callback = function(Value)
       AutoAim = Value
   end,
})
