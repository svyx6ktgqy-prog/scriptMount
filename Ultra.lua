-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Ultimate Clicker Hub | Delta iOS",
   LoadingTitle = "Cargando Cheat Hub...",
   LoadingSubtitle = "por IA Collaborator",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UltimateClickerConfig",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO FARM & CLICK (6 Elementos)
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateSection("Automatización Principal")

FarmTab:CreateToggle({
   Name = "Auto Click Pantalla (Ultra Rápido)",
   CurrentValue = false,
   Flag = "AutoClick",
   Callback = function(Value)
      getgenv().AutoClick = Value
      task.spawn(function()
         while getgenv().AutoClick do
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ClickEvent"):FireServer()
            task.wait(0.01) -- Velocidad máxima de clics
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Comer Comida (Fast Eating)",
   CurrentValue = false,
   Flag = "AutoEat",
   Callback = function(Value)
      getgenv().AutoEat = Value
      task.spawn(function()
         while getgenv().AutoEat do
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("EatFood"):FireServer()
            task.wait(0.05)
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Misiones / Quests",
   CurrentValue = false,
   Flag = "AutoQuest",
   Callback = function(Value)
      getgenv().AutoQuest = Value
      task.spawn(function()
         while getgenv().AutoQuest do
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ClaimQuest"):FireServer()
            task.wait(1)
         end
      end)
   end,
})

FarmTab:CreateButton({
   Name = "Recoger Todas las Recompensas Diarias",
   Callback = function()
      local args = { [1] = "ClaimDaily" }
      game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RewardEvent"):FireServer(unpack(args))
   end,
})

FarmTab:CreateSlider({
   Name = "Multiplicador de Clics (Visual/Simulado)",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 1,
   Flag = "ClickMulti",
   Callback = function(Value)
      print("Multiplicador ajustado a: " .. Value)
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Equipar Mejor Mascota/Objeto",
   CurrentValue = false,
   Flag = "AutoBestGear",
   Callback = function(Value)
      getgenv().AutoBest = Value
      while getgenv().AutoBest do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("EquipBest"):InvokeServer()
         task.wait(5)
      end
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO (EXP, NIVEL & REBIRTH) (6 Elementos)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso", 4483362458)

ProgTab:CreateSection("Mejoras de Estadísticas")

ProgTab:CreateToggle({
   Name = "Farmeo Automático de Experiencia",
   CurrentValue = false,
   Flag = "AutoExp",
   Callback = function(Value)
      getgenv().AutoExp = Value
      while getgenv().AutoExp do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AddExp"):FireServer()
         task.wait(0.1)
      end
   end,
})

ProgTab:CreateToggle({
   Name = "Auto Subir de Nivel (Level Up)",
   CurrentValue = false,
   Flag = "AutoLevel",
   Callback = function(Value)
      getgenv().AutoLevel = Value
      while getgenv().AutoLevel do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("LevelUp"):FireServer()
         task.wait(1)
      end
   end,
})

ProgTab:CreateToggle({
   Name = "Auto Renacimiento (Rebirth Automático)",
   CurrentValue = false,
   Flag = "AutoRebirth",
   Callback = function(Value)
      getgenv().AutoRebirth = Value
      while getgenv().AutoRebirth do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Rebirth"):FireServer()
         task.wait(2)
      end
   end,
})

ProgTab:CreateButton({
   Name = "Desbloquear Todos los Boosters (Gratis)",
   Callback = function()
      for i = 1, 5 do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("BuyBooster"):FireServer(i)
      end
   end,
})

ProgTab:CreateToggle({
   Name = "Bucle de Reclamar Boost de Tiempo",
   CurrentValue = false,
   Flag = "TimeBoost",
   Callback = function(Value)
      getgenv().TimeBoost = Value
      while getgenv().TimeBoost do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ClaimTimeReward"):FireServer()
         task.wait(60)
      end
   end,
})

ProgTab:CreateButton({
   Name = "Forzar Guardado de Datos (Anti-Rollback)",
   Callback = function()
      game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("SaveData"):FireServer()
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: VELOCIDAD Y MUNDO (6 Elementos)
--------------------------------------------------------------------------------
local SpeedTab = Window:CreateTab("Velocidad & Mundo", 4483362458)

SpeedTab:CreateSection("Control de Entorno")

SpeedTab:CreateSlider({
   Name = "Velocidad de Movimiento (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

SpeedTab:CreateSlider({
   Name = "Salto (JumpPower)",
   Range = {50, 300},
   Increment = 5,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

SpeedTab:CreateToggle({
   Name = "Anti-AFK (Evitar Desconexión)",
   CurrentValue = true,
   Flag = "AntiAFK",
   Callback = function(Value)
      local vu = game:GetService("VirtualUser")
      game:GetService("Players").LocalPlayer.Idled:Connect(function()
         if Value then
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
         end
      end)
   end,
})

SpeedTab:CreateButton({
   Name = "Acelerar Reloj del Juego (Time Skip)",
   Callback = function()
      pcall(function()
         game.Lighting.TimeOfDay = "12:00:00"
      end)
   end,
})

SpeedTab:CreateToggle({
   Name = "Modo Sin Colusiones (NoClip)",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      getgenv().NoClip = Value
      game:GetService("RunService").Stepped:Connect(function()
         if getgenv().NoClip then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = false
               end
            end
         end
      end)
   end,
})

SpeedTab:CreateButton({
   Name = "Teletransporte a Zona Segura / Spawn",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: GLITCHES & FRAMES (6 Elementos)
--------------------------------------------------------------------------------
local GlitchTab = Window:CreateTab("Glitches & Frames", 4483362458)

GlitchTab:CreateSection("Optimizaciones y Trucos de Rendimiento")

GlitchTab:CreateToggle({
   Name = "Glitch de Framerate (FPS Unlocker interno)",
   CurrentValue = false,
   Flag = "FPSUnlock",
   Callback = function(Value)
      if Value then
         setfpscap(999)
      else
         setfpscap(60)
      end
   end,
})

GlitchTab:CreateButton({
   Name = "Aplicar Lag Switch Simulado (Congelar Red)",
   Callback = function()
      settings():GetService("NetworkSettings").IncomingReplicationLag = 10
      task.wait(3)
      settings():GetService("NetworkSettings").IncomingReplicationLag = 0
   end,
})

GlitchTab:CreateToggle({
   Name = "Modo Ultra Bajo de Gráficos (Boost FPS)",
   CurrentValue = false,
   Flag = "PotatoMode",
   Callback = function(Value)
      for _, v in pairs(workspace:GetDescendants()) do
         if v:IsA("BasePart") then
            v.Material = Value and Enum.Material.SmoothPlastic or Enum.Material.Neon
            v.Reflectance = 0
         end
      end
   end,
})

GlitchTab:CreateButton({
   Name = "Glitch de Velocidad de Animación (Speed Bypass)",
   Callback = function()
      pcall(function()
         for _, anim in pairs(game.Players.LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            anim:AdjustSpeed(2.5)
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "Duplicar Efectos Visuales de Clic (Bug Visual)",
   Callback = function()
      for i = 1, 50 do
         game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ClickEvent"):FireServer()
      end
   end,
})

GlitchTab:CreateToggle({
   Name = "Ocultar Jugadores (Reducir Lag de Carga)",
   CurrentValue = false,
   Flag = "HidePlayers",
   Callback = function(Value)
      for _, p in pairs(game.Players:GetPlayers()) do
         if p ~= game.Players.LocalPlayer and p.Character then
            for _, part in pairs(p.Character:GetDescendants()) do
               if part:IsA("BasePart") or part:IsA("Decal") then
                  part.Transparency = Value and 1 or 0
               end
            end
         end
      end
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 5: EXTRAS & CONFIGURACIÓN (6 Elementos)
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & UI", 4483362458)

ExtraTab:CreateSection("Ajustes del Script")

ExtraTab:CreateButton({
   Name = "Destruir Interfaz (Unload)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateColorPicker({
   Name = "Color Principal del Tema",
   Color = Color3.fromRGB(44, 120, 240),
   Flag = "ThemeColor",
   Callback = function(Value)
      -- Rayfield actualiza colores automáticamente mediante flags si está configurado
   end,
})

ExtraTab:CreateButton({
   Name = "Copiar Enlace de Soporte",
   Callback = function()
      setclipboard("https://roblox.com")
   end,
})

ExtraTab:CreateToggle({
   Name = "Notificaciones de Eventos en Pantalla",
   CurrentValue = true,
   Flag = "Notifs",
   Callback = function(Value)
      getgenv().ShowNotifs = Value
   end,
})

ExtraTab:CreateButton({
   Name = "Reconectar al Servidor Actual",
   Callback = function()
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end,
})

ExtraTab:CreateParagraph({Title = "Información de Versión", Content = "Ejecutándose en Delta (iOS) - Rayfield UI Engine v2.5. Totalmente optimizado para rendimiento móvil."})

-- Cargar configuración inicial
Rayfield:LoadConfiguration()
