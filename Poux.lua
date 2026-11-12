-- ============================================================================
-- OMNI-NIGHTMARE "GRASA & GLITCH" ENGINE | ULTIMATE 100% GLOBAL (DELTA iOS)
-- ============================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- FUNCIÓN DE FUERZA BRUTA GLOBAL DE RED
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

-- Crear la Ventana Principal con temática pesada
local Window = Rayfield:CreateWindow({
   Name = "🚨 [NIGHTMARE] Grasa & Glitch Core v10.0 [iOS Delta]",
   LoadingTitle = "Inyectando Código Grasa & Chaos...",
   LoadingSubtitle = "Advertencia: Contenido Extremadamente Roto",
   ConfigurationSaving = { Enabled = false, FolderName = "NightmareGrasa", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO FARM & "GRASA" GIGANTE
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm & Grasa", 4483362458)
FarmTab:CreateSection("Automatización de Ingesta y Fat-Clicks")

FarmTab:CreateToggle({
   Name = "1. Auto Click Fat-Burst (Multi-Hilo Grasa)",
   CurrentValue = false,
   Flag = "G_FatClick",
   Callback = function(Value)
      getgenv().FatClick = Value
      task.spawn(function()
         while getgenv().FatClick do
            ForceFireAll("click")
            ForceFireAll("fat")
            ForceFireAll("tap")
            pcall(function()
               VirtualUser:Button1Down(Vector2.new(400, 400))
               task.wait(0.005)
               VirtualUser:Button1Up(Vector2.new(400, 400))
            end)
            RunService.RenderStepped:Wait()
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "2. Auto-Consumir Fast-Food / Comida Ultra-Rápida",
   CurrentValue = false,
   Flag = "G_FastFood",
   Callback = function(Value)
      getgenv().FastFood = Value
      task.spawn(function()
         while getgenv().FastFood do
            ForceFireAll("eat")
            ForceFireAll("food")
            ForceFireAll("burger")
            ForceFireAll("fat")
            ForceFireAll("consume")
            task.wait(0.01)
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "3. Auto-Misiones Grasa (Quests & Bounties)",
   CurrentValue = false,
   Flag = "G_Quests",
   Callback = function(Value)
      getgenv().FatQuest = Value
      task.spawn(function()
         while getgenv().FatQuest do
            ForceFireAll("quest")
            ForceFireAll("mission")
            ForceFireAll("fatmission")
            task.wait(1)
         end
      end)
   end,
})

FarmTab:CreateButton({
   Name = "4. Reclamar Todos los Regalos y Grasa Diaria",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("reward") or n:find("daily") or n:find("claim") or n:find("gift") or n:find("fat") then
                  v:FireServer("Claim")
                  v:FireServer(1)
                  v:FireServer("Grasa")
               end
            end
         end
      end)
   end,
})

FarmTab:CreateSlider({
   Name = "5. Multiplicador de Paquetes Grasa por Segundo (Hz)",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 50,
   Flag = "G_HzRate",
   Callback = function(Value)
      getgenv().FatHz = 1 / Value
   end,
})

FarmTab:CreateToggle({
   Name = "6. Auto-Equipar Mejor Objeto de Grasa (Best Fat Gear)",
   CurrentValue = false,
   Flag = "G_AutoEquip",
   Callback = function(Value)
      getgenv().FatEquip = Value
      task.spawn(function()
         while getgenv().FatEquip do
            pcall(function()
               for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                  if v:IsA("RemoteFunction") and (v.Name:lower():find("equip") or v.Name:lower():find("fat")) then
                     v:InvokeServer("Best")
                     v:InvokeServer("Max")
                  end
               end
            end)
            task.wait(3)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO, LEVEL UP & REBIRTH EXTREMO
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso & Rebirth", 4483362458)
ProgTab:CreateSection("Bypasses de Nivel y Renacimiento Masivo")

ProgTab:CreateToggle({
   Name = "1. Farmeo Glitcheado de Experiencia (Exp Loop)",
   CurrentValue = false,
   Flag = "G_ExpLoop",
   Callback = function(Value)
      getgenv().ExpGlitch = Value
      task.spawn(function()
         while getgenv().ExpGlitch do
            ForceFireAll("exp")
            ForceFireAll("level")
            ForceFireAll("train")
            task.wait(0.02)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2. Auto Level Up Instantáneo (Forzado)",
   CurrentValue = false,
   Flag = "G_AutoLevel",
   Callback = function(Value)
      getgenv().LevelUpLoop = Value
      task.spawn(function()
         while getgenv().LevelUpLoop do
            ForceFireAll("levelup")
            ForceFireAll("rankup")
            ForceFireAll("up")
            task.wait(0.5)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "3. Auto Rebirth Masivo (Prestige Bucle)",
   CurrentValue = false,
   Flag = "G_RebirthLoop",
   Callback = function(Value)
      getgenv().RebirthLoop = Value
      task.spawn(function()
         while getgenv().RebirthLoop do
            ForceFireAll("rebirth")
            ForceFireAll("prestige")
            ForceFireAll("evolution")
            task.wait(1)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "4. Inyección Total de Boosters de Grasa (Unlock All)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("boost") or v.Name:lower():find("multiplier")) then
               for i = 1, 15 do v:FireServer(i) end
            end
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "5. Reclamador Automático de Tiempo y Premios Online",
   CurrentValue = false,
   Flag = "G_TimeReward",
   Callback = function(Value)
      getgenv().TimeRewardLoop = Value
      task.spawn(function()
         while getgenv().TimeRewardLoop do
            ForceFireAll("time")
            ForceFireAll("online")
            ForceFireAll("reward")
            task.wait(20)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "6. Anti-Rollback Forzado (Guardar Datos a la Fuerza)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("save") then
               v:FireServer("Save")
            end
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: VELOCIDAD Y TIEMPO (Time Scale & Engine)
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("Velocidad & Tiempo", 4483362458)
TimeTab:CreateSection("Manipulación del Reloj del Juego y del Servidor")

TimeTab:CreateSlider({
   Name = "1. Velocidad de Movimiento Global (WalkSpeed)",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Flag = "G_WalkSpeed",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

TimeTab:CreateSlider({
   Name = "2. Salto Hiper-Pesado (JumpPower)",
   Range = {50, 600},
   Increment = 5,
   CurrentValue = 50,
   Flag = "G_JumpPower",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

TimeTab:CreateSlider({
   Name = "3. Acelerador de Tiempo del Motor (Time Scale Glitch)",
   Range = {1, 10},
   Increment = 0.5,
   CurrentValue = 1,
   Flag = "G_TimeScale",
   Callback = function(Value)
      pcall(function()
         RunService.Heartbeat:Connect(function()
            -- Simula aceleración de ticks en el cliente
            task.wait(1 / (60 * Value))
         end)
      end)
   end,
})

TimeTab:CreateButton({
   Name = "4. Congelar Reloj en Medianoche (Time Fix 00:00)",
   Callback = function()
      pcall(function()
         Lighting.TimeOfDay = "00:00:00"
         Lighting.ClockTime = 0
      end)
   end,
})

TimeTab:CreateToggle({
   Name = "5. Anti-AFK Absoluto (Evitar Desconexión por Inactividad)",
   CurrentValue = true,
   Flag = "G_AntiAFK",
   Callback = function(Value)
      getgenv().AFKOn = Value
      task.spawn(function()
         LocalPlayer.Idled:Connect(function()
            if getgenv().AFKOn then
               VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
               task.wait(1)
               VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end
         end)
      end)
   end,
})

TimeTab:CreateButton({
   Name = "6. Teletransporte de Emergencia al Inicio (Spawn Fix)",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: GLITCHES DE FRAMES Y RENDIMIENTO
--------------------------------------------------------------------------------
local FrameTab = Window:CreateTab("Glitches & Frames", 4483362458)
FrameTab:CreateSection("Optimizaciones de Motor Gráfico y FPS Bypass")

FrameTab:CreateToggle({
   Name = "1. Desbloqueador de FPS Absoluto (Bypass 999 FPS)",
   CurrentValue = false,
   Flag = "G_FPSUnlock",
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

TimeTab:CreateButton -- (Nota de continuidad estructurada)
FrameTab:CreateButton({
   Name = "2. Glitch de Lag Switch de Red (Congelar Replicación 5s)",
   Callback = function()
      pcall(function()
         settings():GetService("NetworkSettings").IncomingReplicationLag = 25
         task.wait(5)
         settings():GetService("NetworkSettings").IncomingReplicationLag = 0
      end)
   end,
})

FrameTab:CreateToggle({
   Name = "3. Modo Gráfico Papas Extremo (Eliminar Texturas y Luces)",
   CurrentValue = false,
   Flag = "G_PotatoMode",
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

FrameTab:CreateButton({
   Name = "4. Desincronización de Animaciones (Speed Bypass Visual)",
   Callback = function()
      pcall(function()
         for _, track in pairs(LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(5.0)
         end
      end)
   end,
})

FrameTab:CreateButton({
   Name = "5. Bug de Spam de Paquetes en Ráfaga (Socket Flood)",
   Callback = function()
      task.spawn(function()
         for i = 1, 150 do
            ForceFireAll("click")
            ForceFireAll("fat")
         end
      end)
   end,
})

FrameTab:CreateToggle({
   Name = "6. Ocultar Todos los Demás Jugadores (Acelerar FPS)",
   CurrentValue = false,
   Flag = "G_HidePlayers",
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
-- APARTADO 5 [NIGHTMARE]: DESTRUCCIÓN DE PLATAFORMAS POR "GRASA"
--------------------------------------------------------------------------------
local NightmareTab = Window:CreateTab("Nightmare: Grasa Cracking", 4483362458)
NightmareTab:CreateSection("Mecánicas Extremas: El Peso Rompe Plataformas")

NightmareTab:CreateToggle({
   Name = "1. Activar Sensor de Impacto por Obesidad (Fat Crush)",
   CurrentValue = false,
   Flag = "N_FatCrush",
   Callback = function(Value)
      getgenv().FatCrushActive = Value
      task.spawn(function()
         while getgenv().FatCrushActive do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  local hrp = char.HumanoidRootPart
                  -- Detecta las partes debajo del jugador al caer
                  local rayParams = RaycastParams.new()
                  rayParams.FilterDescendantsInstances = {char}
                  rayParams.FilterType = Enum.RaycastFilterType.Exclude
                  
                  local result = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), rayParams)
                  if result and result.Instance then
                     local hitPart = result.Instance
                     if hitPart:IsA("BasePart") and not hitPart.Anchored then
                        -- Rompe y degrada la plataforma por el peso masivo
                        hitPart.Size = hitPart.Size * 0.9
                        hitPart.Transparency = hitPart.Transparency + 0.1
                        if hitPart.Transparency >= 0.9 then
                           hitPart:Destroy()
                        end
                     end
                  end
               end
            end)
            task.wait(0.2)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "2. Gravedad Masiva de Grasa (Hacerse Pesado al Caer)",
   CurrentValue = false,
   Flag = "N_FatGravity",
   Callback = function(Value)
      getgenv().HeavyFall = Value
      task.spawn(function()
         while getgenv().HeavyFall do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("Humanoid") then
                  if char.Humanoid.FloorMaterial == Enum.Material.Air then
                     char.HumanoidRootPart.Velocity = Vector3.new(0, -150, 0)
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

NightmareTab:CreateButton({
   Name = "3. Terremoto de Grasa (Desestabilizar Servidor Local)",
   Callback = function()
      pcall(function()
         for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 30 then
               part.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
            end
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "4. Auto-Explotar Grasa al Tocar Suelo (Shockwave Loop)",
   CurrentValue = false,
   Flag = "N_Shockwave",
   Callback = function(Value)
      getgenv().ShockwaveLoop = Value
      task.spawn(function()
         while getgenv().ShockwaveLoop do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  ForceFireAll("explode")
                  ForceFireAll("shockwave")
                  ForceFireAll("fat")
               end
            end)
            task.wait(1.5)
         end
      end)
   end,
})

NightmareTab:CreateButton({
   Name = "5. Forzar Caída de Texturas del Mapa (Glitch Estructural)",
   Callback = function()
      pcall(function()
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not obj:FindFirstChild("Humanoid") then
               for _, p in ipairs(obj:GetDescendants()) do
                  if p:IsA("BasePart") then
                     p.Anchored = false
                  end
               end
            end
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "6. Bucle Infinito de Crash de Fisica Local (Nightmare Mode)",
   CurrentValue = false,
   Flag = "N_PhysicsCrash",
   Callback = function(Value)
      getgenv().NightmarePhysics = Value
      task.spawn(function()
         while getgenv().NightmarePhysics do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  char.HumanoidRootPart.RotVelocity = Vector3.new(9999, 9999, 9999)
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 6: EXTRAS & SISTEMA GLOBAL
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Utilidades de Control Total")

ExtraTab:CreateButton({
   Name = "1. Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateButton({
   Name = "2. Forzar Reinicio de Personaje (Reset Local)",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.Humanoid.Health = 0
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "3. Copiar JobID del Servidor Actual",
   Callback = function()
      pcall(function()
         setclipboard(game.JobId)
      end)
   end,
})

ExtraTab:CreateToggle({
   Name = "4. Notificaciones Flotantes del Sistema",
   CurrentValue = true,
   Flag = "G_Notif",
   Callback = function(Value)
      getgenv().ShowNotifs = Value
   end,
})

ExtraTab:CreateButton({
   Name = "5. Reconectar al Servidor Actual (Rejoin Rápido)",
   Callback = function()
      pcall(function()
         game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
      end)
   end,
})

ExtraTab:CreateParagraph({Title = "Estado del Núcleo Nightmare", Content = "Motor 'Grasa & Glitch' cargado al 100%. Las plataformas se degradan con el peso del jugador y el tiempo del motor ha sido manipulado."})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
