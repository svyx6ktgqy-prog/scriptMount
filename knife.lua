-- =====================================================================
-- 🔪 BATTLE SNIFE - REFLEX ENGINE (OPTIMIZADO PARA DELTA iOS)
-- UI: Rayfield (sirius.menu/rayfield)
-- =====================================================================

-- 1. PREVENCIÓN DE CRASHES EN iOS: Esperar a que el juego cargue completamente
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- 2. CARGA SEGURA DE RAYFIELD
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Delta Executor: Error al cargar Rayfield. Intenta ejecutar de nuevo.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 3. INICIALIZACIÓN DE LA VENTANA (Sin guardado para evitar errores de permisos en iOS)
local Window = Rayfield:CreateWindow({
   Name = "Battle Snife 🔪",
   LoadingTitle = "Reflex Engine...",
   LoadingSubtitle = "Delta iOS Version",
   ConfigurationSaving = { Enabled = false }, -- Mantenlo en false en iOS
   KeySystem = false
})

-- =====================================================================
-- VARIABLES GLOBALES
-- =====================================================================
local AutoPingPong = false
local CatchRadius = 12
local AutoAim = true

-- Función para simular toques en la pantalla (Touch/Click) adaptada para Delta
local function ClickMobileButton(buttonName)
    pcall(function()
        local guiPath = LocalPlayer.PlayerGui.HUD.MobileButtons[buttonName]
        if guiPath and guiPath:FindFirstChild("click") then
            local btn = guiPath.click
            -- Delta soporta getconnections, disparamos los eventos táctiles/clics
            for _, connection in pairs(getconnections(btn.MouseButton1Click) or {}) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(btn.MouseButton1Down) or {}) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(btn.TouchTap) or {}) do
                connection:Fire()
            end
        end
    end)
end

-- =====================================================================
-- PESTAÑA: MOTOR DE REFLEJOS
-- =====================================================================
local CombatTab = Window:CreateTab("Reflex Combat", 4483362458)

CombatTab:CreateSection("Auto Ping-Pong")

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

               -- FASE OFFENSIVA: Tienes el cuchillo
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
                           -- Apuntado suave para no marear la cámara en móvil
                           myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(closestEnemy.HumanoidRootPart.Position.X, myRoot.Position.Y, closestEnemy.HumanoidRootPart.Position.Z))
                       end
                       ClickMobileButton("Throw")
                       task.wait(0.15) -- Pausa táctil
                   end

               -- FASE DEFENSIVA: Esperando el cuchillo
               else
                   for _, obj in pairs(workspace:GetDescendants()) do
                       if obj:IsA("BasePart") and (obj.Name:lower():match("knife") or obj.Name:lower():match("blade")) then
                           local dist = (myRoot.Position - obj.Position).Magnitude
                           
                           if dist <= CatchRadius and obj.Velocity.Magnitude > 5 then
                               ClickMobileButton("Catch")
                               task.wait(0.1) 
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
   Name = "🎯 Auto-Apuntado (Aimbot)",
   CurrentValue = true,
   Flag = "AutoAim",
   Callback = function(Value)
       AutoAim = Value
   end,
})

Rayfield:Notify({
    Title = "Inyectado Correctamente",
    Content = "El menú está listo para usarse en Delta.",
    Duration = 3,
    Image = 4483362458
})
