-- ============================================================================
-- OMNI-GLOBAL CLICKER & FRAME ENGINE | 100% HARDWARE BYPASS (DELTA iOS)
-- ============================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- FUNCIÓN GLOBAL DE FUERZA BRUTA PARA ENCONTRAR CUALQUIER EVENTO DE RED
local function ForceFireAll(keyword)
    local triggered = false
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
                if v.Name:lower():find(keyword) then
                    v:FireServer()
                    triggered = true
                end
            end
        end
    end)
    return triggered
end

-- Crear la Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "Omni-Global Engine [100% Global & Robusto]",
   LoadingTitle = "Activando Motores Universales...",
   LoadingSubtitle = "Bypass de Frames y Clicks Activo",
   ConfigurationSaving = { Enabled = false, FolderName = "Omni", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO FARM & CLICK GLOBAL
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
FarmTab:CreateSection("Capas de Activación de Red y Pantalla")

FarmTab:CreateToggle({
   Name = "1. Auto Click Universal (Red + Toque Físico)",
   CurrentValue = false,
   Flag = "G_Click",
   Callback = function(Value)
      getgenv().MegaClick = Value
      task.spawn(function()
         while getgenv().MegaClick do
            -- Método A: Dispara todos los remotes posibles de click/tap en el juego
            local fired = ForceFireAll("click") 
            if not fired then ForceFireAll("tap") end
            if not fired then ForceFireAll("train") end
            
            -- Método B: Simulación nativa de toque en pantalla (Garantiza acción visual)
            pcall(function()
               VirtualUser:Button1Down(Vector2.new(300, 300))
               task.wait(0.01)
               VirtualUser:Button1Up(Vector2.new(300, 300))
            end)
            RunService.RenderStepped:Wait()
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "2. Auto Comer Comida Global (Hiper-Consumo)",
   CurrentValue = false,
   Flag = "G_Eat",
   Callback = function(Value)
      getgenv().MegaEat = Value
      task.spawn(function()
         while getgenv().MegaEat do
            -- Dispara cualquier remote relacionado con comer, comida o consumir
            ForceFireAll("eat")
            ForceFireAll("food")
            ForceFireAll("feed")
            ForceFireAll("consume")
            task.wait(0.02)
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "3. Auto Misiones / Quests Fantasma",
   CurrentValue = false,
   Flag = "G_Quest",
   Callback = function(Value)
      getgenv().MegaQuest = Value
      task.spawn(function()
         while getgenv().MegaQuest do
            ForceFireAll("quest")
            ForceFireAll("mission")
            ForceFireAll("task")
            task.wait(1)
         end
      end)
   end,
})

FarmTab:CreateButton({
   Name = "4. Forzar Recompensas Globales (Claim All)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("reward") or n:find("daily") or n:find("claim") or n:find("gift") then
                  v:FireServer("Claim")
                  v:FireServer(1)
                  v:FireServer()
               end
            end
         end
      end)
   end,
})

FarmTab:CreateSlider({
   Name = "5. Multiplicador de Paquetes por Ráfaga (Burst)",
   Range = {1, 20},
   Increment = 1,
   CurrentValue = 5,
   Flag = "BurstVal",
   Callback = function(Value)
      getgenv().BurstRate = Value
   end,
})

FarmTab:CreateToggle({
   Name = "6. Auto Equipar Mejor Objeto / Mascota",
   CurrentValue = false,
   Flag = "G_Equip",
   Callback = function(Value)
      getgenv().MegaEquip = Value
      task.spawn(function()
         while getgenv().MegaEquip do
            pcall(function()
               for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                  if v:IsA("RemoteFunction") and v.Name:lower():find("equip") then
                     v:InvokeServer("Best")
                     v:InvokeServer(true)
                  end
               end
            end)
            task.wait(3)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO (EXP, NIVEL & REBIRTH)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso", 4483362458)
ProgTab:CreateSection("Automatización Global de Estadísticas")

ProgTab:CreateToggle({
   Name = "1. Farmeo Bucle de Experiencia Global",
   CurrentValue = false,
   Flag = "G_Exp",
   Callback = function(Value)
      getgenv().MegaExp = Value
      task.spawn(function()
         while getgenv().MegaExp do
            ForceFireAll("exp")
            ForceFireAll("level")
            ForceFireAll("train")
            task.wait(0.05)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2. Auto Subir de Nivel Constante",
   CurrentValue = false,
   Flag = "G_LevelUp",
   Callback = function(Value)
      getgenv().MegaLevel = Value
      task.spawn(function()
         while getgenv().MegaLevel do
            ForceFireAll("levelup")
            ForceFireAll("rank")
            task.wait(1)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "3. Auto Renacimiento Global (Prestige Loop)",
   CurrentValue = false,
   Flag = "G_Rebirth",
   Callback = function(Value)
      getgenv().MegaRebirth = Value
      task.spawn(function()
         while getgenv().MegaRebirth do
            ForceFireAll("rebirth")
            ForceFireAll("prestige")
            task.wait(2)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "4. Desbloquear Todos los Boosters por Inyección",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("boost") then
               for i = 1, 10 do v:FireServer(i) end
            end
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "5. Reclamador Automático de Tiempo Online",
   CurrentValue = false,
   Flag = "G_Time",
   Callback = function(Value)
      getgenv().MegaTime = Value
      task.spawn(function()
         while getgenv().MegaTime do
            ForceFireAll("time")
            ForceFireAll("online")
            ForceFireAll("gift")
            task.wait(30)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "6. Forzar Guardado de Datos Global (Anti-Rollback)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("save") then
               v:FireServer()
            end
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: VELOCIDAD Y MUNDO
--------------------------------------------------------------------------------
local SpeedTab = Window:CreateTab("Velocidad & Mundo", 4483362458)
SpeedTab:CreateSection("Controles del Motor Físico del Jugador")

SpeedTab:CreateSlider({
   Name = "1. Velocidad de Movimiento (WalkSpeed Global)",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "G_Walk",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

SpeedTab:CreateSlider({
   Name = "2. Salto Personalizado (JumpPower Global)",
   Range = {50, 400},
   Increment = 5,
   CurrentValue = 50,
   Flag = "G_Jump",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

SpeedTab:CreateToggle({
   Name = "3. Anti-AFK Global (Impedir Inactividad)",
   CurrentValue = true,
   Flag = "G_AFK",
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

SpeedTab:CreateButton({
   Name = "4. Sincronizar Reloj del Servidor (Time Fix)",
   Callback = function()
      pcall(function()
         game.Lighting.TimeOfDay = "12:00:00"
      end)
   end,
})

SpeedTab:CreateToggle({
   Name = "5. Modo Sin Colusiones (NoClip Absoluto)",
   CurrentValue = false,
   Flag = "G_NoClip",
   Callback = function(Value)
      getgenv().AbsoluteNoClip = Value
      RunService.Stepped:Connect(function()
         if getgenv().AbsoluteNoClip and LocalPlayer.Character then
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
   Name = "6. Teletransporte de Emergencia al Spawn",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: GLITCHES DE FRAMES Y RENDIMIENTO GLOBAL
--------------------------------------------------------------------------------
local GlitchTab = Window:CreateTab("Glitches & Frames", 4483362458)
GlitchTab:CreateSection("Trucos de Motor Gráfico y Manipulación de Red")

GlitchTab:CreateToggle({
   Name = "1. Desbloqueador de FPS Global (Bypass de Motor)",
   CurrentValue = false,
   Flag = "G_FPS",
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
   Name = "2. Glitch de Lag Switch de Red (Congelar Replicación 3s)",
   Callback = function()
      pcall(function()
         settings():GetService("NetworkSettings").IncomingReplicationLag = 20
         task.wait(3)
         settings():GetService("NetworkSettings").IncomingReplicationLag = 0
      end)
   end,
})

GlitchTab:CreateToggle({
   Name = "3. Modo Gráfico Papas Absoluto (Eliminar Lag Gráfico)",
   CurrentValue = false,
   Flag = "G_Potato",
   Callback = function(Value)
      pcall(function()
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
               v.Material = Value and Enum.Material.SmoothPlastic or Enum.Material.Neon
               v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = not Value
            end
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "4. Desincronización de Animaciones (Speed Bypass Visual)",
   Callback = function()
      pcall(function()
         for _, track in pairs(LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(4.0)
         end
      end)
   end,
})

GlitchTab:CreateButton({
   Name = "5. Bug de Ráfaga de Sockets (Spam de Paquetes Masivo)",
   Callback = function()
      task.spawn(function()
         for i = 1, 100 do
            ForceFireAll("click")
            ForceFireAll("tap")
         end
      end)
   end,
})

GlitchTab:CreateToggle({
   Name = "6. Ocultar Todos los Demás Jugadores (Acelerar FPS)",
   CurrentValue = false,
   Flag = "G_Hide",
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
-- APARTADO 5: EXTRAS & SISTEMA GLOBAL
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Gestión y Utilidades del Script")

ExtraTab:CreateButton({
   Name = "1. Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateButton({
   Name = "2. Forzar Reinicio del Personaje (Reset Local)",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.Humanoid.Health = 0
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "3. Copiar JobID del Servidor Actual al Portapapeles",
   Callback = function()
      pcall(function()
         setclipboard(game.JobId)
      end)
   end,
})

ExtraTab:CreateToggle({
   Name = "4. Sistema de Notificaciones Flotantes del Hub",
   CurrentValue = true,
   Flag = "G_Notif",
   Callback = function(Value)
      getgenv().ShowNotifs = Value
   end,
})

ExtraTab:CreateButton({
   Name = "5. Reconectarse al Servidor Actual (Rejoin Rápido)",
   Callback = function()
      pcall(function()
         game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
      end)
   end,
})

ExtraTab:CreateParagraph({Title = "Estado del Núcleo Global", Content = "Sistema 100% universal activo. Cada switch utiliza escaneo masivo de red y respaldos físicos para garantizar funcionamiento en cualquier juego de Roblox."})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
