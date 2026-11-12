-- ============================================================================
-- ULTIMATE UNIVERSAL CLICKER & GLITCH CORE (DELTA iOS OPTIMIZED)
-- ============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- SISTEMA DE AUTO-DESCUBRIMIENTO GLOBAL DE REMOTES (Funciona en CUALQUIER juego)
local CachedRemotes = {
    Click = nil,
    Eat = nil,
    Quest = nil,
    Rebirth = nil,
    Level = nil,
    Booster = nil
}

task.spawn(function()
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
                local name = v.Name:lower()
                if (name:find("click") or name:find("tap") or name:find("train") or name:find("farm")) and not CachedRemotes.Click then
                    CachedRemotes.Click = v
                elseif (name:find("eat") or name:find("food") or name:find("feed") or name:find("consume")) and not CachedRemotes.Eat then
                    CachedRemotes.Eat = v
                elseif (name:find("quest") or name:find("mission")) and not CachedRemotes.Quest then
                    CachedRemotes.Quest = v
                elseif (name:find("rebirth") or name:find("prestige")) and not CachedRemotes.Rebirth then
                    CachedRemotes.Rebirth = v
                elseif (name:find("level") or name:find("rank") or name:find("up")) and not CachedRemotes.Level then
                    CachedRemotes.Level = v
                elseif (name:find("boost") or name:find("code")) and not CachedRemotes.Booster then
                    CachedRemotes.Booster = v
                end
            end
        end
    end)
end)

-- Función de seguridad global para disparar remotes encontrados o simular clic nativo
local function UniversalFire(remoteType, ...)
    if CachedRemotes[remoteType] then
        pcall(function()
            CachedRemotes[remoteType]:FireServer(...)
        end)
    else
        -- Fallback de emergencia: Simulación de toque/clic en pantalla si no hay remote detectado
        pcall(function()
            VirtualUser:Button1Down(Vector2.new(200, 200))
            task.wait()
            VirtualUser:Button1Up(Vector2.new(200, 200))
        end)
    end
end

-- Crear la Ventana Principal de Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Omni-Global Clicker & Glitch Engine [iOS Delta]",
   LoadingTitle = "Inicializando Motores Universales...",
   LoadingSubtitle = "Bypass Global Activo",
   ConfigurationSaving = { Enabled = true, FolderName = "OmniCore", FileName = "GlobalConfig" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO-FARMEO & CLIC GLOBAL (Mecanismo de Fuerza Bruta de Red)
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm & Click", 4483362458)
FarmTab:CreateSection("Capas de Activación de Clics")

FarmTab:CreateToggle({
   Name = "1.1 Clic Ultra-Global (Multi-Hilo de Red)",
   CurrentValue = false,
   Flag = "GlobalClick",
   Callback = function(Value)
      getgenv().GClick = Value
      task.spawn(function()
         while getgenv().GClick do
            UniversalFire("Click")
            -- Bucle ultra rápido de alta frecuencia sin saturar el hilo principal
            RunService.RenderStepped:Wait()
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "1.2 Auto-Comer Comida Extrema (Hiper-Velocidad)",
   CurrentValue = false,
   Flag = "GlobalEat",
   Callback = function(Value)
      getgenv().GEat = Value
      task.spawn(function()
         while getgenv().GEat do
            UniversalFire("Eat")
            task.wait(0.01)
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "1.3 Auto-Misiones / Quests Fantasma",
   CurrentValue = false,
   Flag = "GlobalQuest",
   Callback = function(Value)
      getgenv().GQuest = Value
      task.spawn(function()
         while getgenv().GQuest do
            UniversalFire("Quest", 1)
            task.wait(2)
         end
      end)
   end,
})

FarmTab:CreateSlider({
   Name = "1.4 Frecuencia de Clics por Segundo (Hz)",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 50,
   Flag = "ClickHz",
   Callback = function(Value)
      getgenv().HzRate = 1 / Value
   end,
})

FarmTab:CreateButton({
   Name = "1.5 Forzar Sincronización de Recompensas Ocultas",
   Callback = function()
      for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
         if remote:IsA("RemoteEvent") and (remote.Name:lower():find("reward") or remote.Name:lower():find("daily")) then
            pcall(function() remote:FireServer("Claim") end)
         end
      end
   end,
})

FarmTab:CreateToggle({
   Name = "1.6 Auto-Equipador Universal Inteligente",
   CurrentValue = false,
   Flag = "AutoEquipAll",
   Callback = function(Value)
      getgenv().GEquip = Value
      task.spawn(function()
         while getgenv().GEquip do
            pcall(function()
               for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                  if remote:IsA("RemoteFunction") and remote.Name:lower():find("equip") then
                     remote:InvokeServer("Best")
                  end
               end
            end)
            task.wait(3)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO Y MULTIPLICADORES (EXP, NIVEL, REBIRTH)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso Global", 4483362458)
ProgTab:CreateSection("Automatización de Niveles y Renacimientos")

ProgTab:CreateToggle({
   Name = "2.1 Farmeo Bucle de Experiencia Global",
   CurrentValue = false,
   Flag = "GExp",
   Callback = function(Value)
      getgenv().GExp = Value
      task.spawn(function()
         while getgenv().GExp do
            UniversalFire("Level")
            task.wait(0.1)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2.2 Auto-Renacimiento Automático Global",
   CurrentValue = false,
   Flag = "GRebirth",
   Callback = function(Value)
      getgenv().GRebirth = Value
      task.spawn(function()
         while getgenv().GRebirth do
            UniversalFire("Rebirth", 1)
            task.wait(1)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "2.3 Desbloquear Boosters Globales (Inyección Directa)",
   Callback = function()
      pcall(function()
         for i = 1, 10 do
            UniversalFire("Booster", i)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2.4 Auto-Reclamador de Tiempo Online",
   CurrentValue = false,
   Flag = "GTime",
   Callback = function(Value)
      getgenv().GTime = Value
      task.spawn(function()
         while getgenv().GTime do
            UniversalFire("Booster", "OnlineTime")
            task.wait(30)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "2.5 Forzar Guardado de Estado (Evita Rollback)",
   Callback = function()
      pcall(function()
         for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote.Name:lower():find("save") then
               remote:FireServer()
            end
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2.6 Multiplicador de Paquetes Fantasma",
   CurrentValue = false,
   Flag = "GhostMult",
   Callback = function(Value)
      getgenv().GhostM = Value
      task.spawn(function()
         while getgenv().GhostM do
            -- Envía múltiples pings de red simulando ráfagas de datos
            pcall(function()
               if CachedRemotes.Click then
                  for i=1, 5 do CachedRemotes.Click:FireServer() end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: VELOCIDAD Y MOVIMIENTO (Motor Global del Player)
--------------------------------------------------------------------------------
local SpeedTab = Window:CreateTab("Velocidad & Mundo", 4483362458)
SpeedTab:CreateSection("Controles Físicos del Personaje")

SpeedTab:CreateSlider({
   Name = "3.1 Velocidad de Movimiento Global",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "GWalk",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

SpeedTab:CreateSlider({
   Name = "3.2 Potencia de Salto Global",
   Range = {50, 400},
   Increment = 5,
   CurrentValue = 50,
   Flag = "GJump",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

SpeedTab:CreateToggle({
   Name = "3.3 Anti-AFK Universal Avanzado",
   CurrentValue = true,
   Flag = "GAntiAFK",
   Callback = function(Value)
      getgenv().AntiAFKActive = Value
      task.spawn(function()
         LocalPlayer.Idled:Connect(function()
             if getgenv().AntiAFKActive then
                 VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                 task.wait(1)
                 VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
             end
         end)
      end)
   end,
})

SpeedTab:CreateToggle({
   Name = "3.4 NoClip Global (Atravesar Paredes)",
   CurrentValue = false,
   Flag = "GNoClip",
   Callback = function(Value)
      getgenv().NoClipGlobal = Value
      RunService.Stepped:Connect(function()
         if getgenv().NoClipGlobal and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end
      end)
   end,
})

SpeedTab:CreateButton({
   Name = "3.5 Teletransporte a Zona de Spawn Segura",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 20, 0)
      end)
   end,
})

SpeedTab:CreateButton({
   Name = "3.6 Bypasser de Velocidad de Vuelo (Fly Mini)",
   Callback = function()
      pcall(function()
         local hrp = LocalPlayer.Character.HumanoidRootPart
         hrp.Velocity = Vector3.new(0, 100, 0)
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: GLITCHES DE FRAMES Y RENDIMIENTO GLOBAL
--------------------------------------------------------------------------------
local GlitchTab = Window:CreateTab("Glitches & Frames", 4483362458)
GlitchTab:CreateSection("Trucos de Motor Gráfico y Red")

GlitchTab:CreateToggle({
   Name = "4.1 Desbloqueador de FPS Global (Bypass Límite)",
   CurrentValue = false,
   Flag = "GFPS",
   Callback = function(Value)
      pcall(function()
         if Value then
            setfpscap(999)
         else
            setfpscap(60)
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "4.2 Glitch de Lag Switch de Red (Congelamiento Temporal)",
   Callback = function()
      pcall(function()
         settings():GetService("NetworkSettings").IncomingReplicationLag = 15
         task.wait(3)
         settings():GetService("NetworkSettings").IncomingReplicationLag = 0
      end)
   end,
})

GlitchTab:CreateToggle({
   Name = "4.3 Modo Gráfico Papas Ultra (Optimización de FPS)",
   CurrentValue = false,
   Flag = "GPotato",
   Callback = function(Value)
      pcall(function()
         for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
               obj.Material = Value and Enum.Material.SmoothPlastic or Enum.Material.Neon
               obj.Reflectance = 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
               obj.Enabled = not Value
            end
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "4.4 Truco de Desincronización de Animaciones (Speed Visual)",
   Callback = function()
      pcall(function()
         for _, track in pairs(LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(3.0)
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "4.5 Bug de Paquete Masivo (Spam de Sockets)",
   Callback = function()
      task.spawn(function()
         for i = 1, 100 do
            UniversalFire("Click")
         end
      end)
   end,
})

GlitchTab:CreateToggle({
   Name = "4.6 Ocultar Entidades Cercanas (Reducir Lag Masivo)",
   CurrentValue = false,
   Flag = "GHide",
   Callback = function(Value)
      pcall(function()
         for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
               for _, part in pairs(p.Character:GetDescendants()) do
                  if part:IsA("BasePart") or part:IsA("Decal") then
                     part.Transparency = Value and 1 or 0
                  end
               end
            end
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 5: EXTRAS Y UTILIDADES GLOBALES
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Gestión de Interfaz Global")

ExtraTab:CreateButton({
   Name = "5.1 Destruir Completamente la UI (Unload)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateButton({
   Name = "5.2 Forzar Reinicio de Personaje (Reset Local)",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.Humanoid.Health = 0
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "5.3 Reconectarse al Servidor Actual (Rejoin)",
   Callback = function()
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
   end,
})

ExtraTab:CreateToggle({
   Name = "5.4 Sistema de Notificaciones Flotantes",
   CurrentValue = true,
   Flag = "GNotif",
   Callback = function(Value)
      getgenv().NotifsOn = Value
   end,
})

ExtraTab:CreateButton({
   Name = "5.5 Copiar JobID del Servidor Actual",
   Callback = function()
      pcall(function()
         setclipboard(game.JobId)
      end)
   end,
})

ExtraTab:CreateParagraph({Title = "Estado del Núcleo Global", Content = "Motor de Auto-Detección Activo. Diseñado con mecanismos independientes y robustos para evitar bloqueos en Delta iOS."})

-- Cargar configuración final
Rayfield:LoadConfiguration()
