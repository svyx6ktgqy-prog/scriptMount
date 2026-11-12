-- ============================================================================
-- OMNI-NIGHTMARE "GRASA & FAT-CRUSH" ENGINE v11.0 (100% GLOBAL & ROBUSTO)
-- ============================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- NÚCLEO DE FUERZA BRUTA GLOBAL DE RED (100% Cobertura de Eventos)
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

-- CREACIÓN DE LA VENTANA PRINCIPAL RAYFIELD
local Window = Rayfield:CreateWindow({
   Name = "🚨 [NIGHTMARE] Grasa, Time & Fat-Crush Engine v11.0 [iOS Delta]",
   LoadingTitle = "Inyectando Motores de Grasa Absoluta...",
   LoadingSubtitle = "Robustez Máxima: Clics, Exp, Tiempo y Destrucción",
   ConfigurationSaving = { Enabled = false, FolderName = "NightmareGrasaV11", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO FARM & "GRASA" ULTRARRÁPIDA (Clicks & Fast-Food)
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm & Grasa", 4483362458)
FarmTab:CreateSection("Automatización Masiva de Ingesta y Fat-Clicks")

FarmTab:CreateToggle({
   Name = "1. Fat-Click Hiper-Veloz (Multi-Hilo de Red + Toque)",
   CurrentValue = false,
   Flag = "G_FatClick",
   Callback = function(Value)
      getgenv().FatClick = Value
      task.spawn(function()
         while getgenv().FatClick do
            ForceFireAll("click")
            ForceFireAll("fat")
            ForceFireAll("tap")
            ForceFireAll("train")
            pcall(function()
               VirtualUser:Button1Down(Vector2.new(400, 400))
               task.wait(0.001)
               VirtualUser:Button1Up(Vector2.new(400, 400))
            end)
            RunService.RenderStepped:Wait()
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "2. Auto-Consumir Fast-Food / Comida Instantánea",
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
            ForceFireAll("feed")
            task.wait(0.005)
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "3. Auto-Misiones de Grasa y Recompensas (Quests)",
   CurrentValue = false,
   Flag = "G_Quests",
   Callback = function(Value)
      getgenv().FatQuest = Value
      task.spawn(function()
         while getgenv().FatQuest do
            ForceFireAll("quest")
            ForceFireAll("mission")
            ForceFireAll("fatmission")
            ForceFireAll("bounty")
            task.wait(0.5)
         end
      end)
   end,
})

FarmTab:CreateButton({
   Name = "4. Reclamar Todos los Regalos, Códigos y Grasa Diaria",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("reward") or n:find("daily") or n:find("claim") or n:find("gift") or n:find("fat") or n:find("code") then
                  v:FireServer("Claim")
                  v:FireServer(1)
                  v:FireServer("Grasa")
                  v:FireServer("FatBoost")
               end
            end
         end
      end)
   end,
})

FarmTab:CreateSlider({
   Name = "5. Multiplicador de Ráfaga de Paquetes Grasa (Hz)",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 80,
   Flag = "G_HzRate",
   Callback = function(Value)
      getgenv().FatHz = 1 / Value
   end,
})

FarmTab:CreateToggle({
   Name = "6. Auto-Equipar Mejor Objeto de Grasa (Max Gear)",
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
            task.wait(2)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO ROBUSTO (EXP, LEVEL UP & REBIRTH)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso Robusto", 4483362458)
ProgTab:CreateSection("Bypasses Absolutos de Experiencia y Niveles")

ProgTab:CreateToggle({
   Name = "1. Farmeo Glitcheado de Experiencia Extrema (Exp Loop)",
   CurrentValue = false,
   Flag = "G_ExpLoop",
   Callback = function(Value)
      getgenv().ExpGlitch = Value
      task.spawn(function()
         while getgenv().ExpGlitch do
            ForceFireAll("exp")
            ForceFireAll("experience")
            ForceFireAll("level")
            ForceFireAll("train")
            task.wait(0.01)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2. Auto Level Up Instantáneo por Fuerza Bruta",
   CurrentValue = false,
   Flag = "G_AutoLevel",
   Callback = function(Value)
      getgenv().LevelUpLoop = Value
      task.spawn(function()
         while getgenv().LevelUpLoop do
            ForceFireAll("levelup")
            ForceFireAll("rankup")
            ForceFireAll("tierup")
            ForceFireAll("up")
            task.wait(0.2)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "3. Auto Rebirth / Prestige Masivo Constante",
   CurrentValue = false,
   Flag = "G_RebirthLoop",
   Callback = function(Value)
      getgenv().RebirthLoop = Value
      task.spawn(function()
         while getgenv().RebirthLoop do
            ForceFireAll("rebirth")
            ForceFireAll("prestige")
            ForceFireAll("evolution")
            ForceFireAll("transcend")
            task.wait(0.5)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "4. Inyección Total de Boosters de Exp y Grasa (Unlock All)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("boost") or v.Name:lower():find("multiplier") or v.Name:lower():find("x2")) then
               for i = 1, 20 do v:FireServer(i) end
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
            ForceFireAll("gift")
            task.wait(10)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "6. Anti-Rollback Forzado (Guardado de Datos Crítico)",
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
-- APARTADO 3: VELOCIDAD Y TIEMPO (Time Scale & Motor Control)
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("Velocidad & Tiempo", 4483362458)
TimeTab:CreateSection("Manipulación Total del Reloj del Servidor y Física")

TimeTab:CreateSlider({
   Name = "1. Velocidad de Movimiento Global (WalkSpeed)",
   Range = {16, 600},
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
   Name = "2. Salto Hiper-Pesado (JumpPower Glitch)",
   Range = {50, 700},
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
   Range = {1, 20},
   Increment = 0.5,
   CurrentValue = 1,
   Flag = "G_TimeScale",
   Callback = function(Value)
      pcall(function()
         RunService.Heartbeat:Connect(function()
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
   Name = "5. Anti-AFK Absoluto (Evitar Inactividad y Kick)",
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
   Name = "6. Teletransporte de Emergencia al Spawn",
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
   Name = "3. Modo Gráfico Papas Extremo (Eliminar Texturas)",
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
   Name = "4. Desincronización de Animaciones (Speed Bypass)",
   Callback = function()
      pcall(function()
         for _, track in pairs(LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(6.0)
         end
      end)
   end,
})

FrameTab:CreateButton({
   Name = "5. Bug de Spam de Paquetes en Ráfaga (Socket Flood)",
   Callback = function()
      task.spawn(function()
         for i = 1, 200 do
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
-- APARTADO 5 [NIGHTMARE]: ENFOQUE TOTAL EN PESO Y DESTRUCCIÓN POR CAÍDA
--------------------------------------------------------------------------------
local NightmareTab = Window:CreateTab("Nightmare: Fat-Crush Focus", 4483362458)
NightmareTab:CreateSection("Método Potenciado: Destrucción Masiva por Gravedad y Grasa")

NightmareTab:CreateToggle({
   Name = "1. Fat-Crush Pro: Degradación y Destrucción Masiva de Suelos",
   CurrentValue = false,
   Flag: "N_FatCrushPro",
   Callback = function(Value)
      getgenv().FatCrushProActive = Value
      task.spawn(function()
         while getgenv().FatCrushProActive do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  local hrp = char.HumanoidRootPart
                  local rayParams = RaycastParams.new()
                  rayParams.FilterDescendantsInstances = {char}
                  rayParams.FilterType = Enum.RaycastFilterType.Exclude
                  
                  local result = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), rayParams)
                  if result and result.Instance then
                     local hitPart = result.Instance
                     if hitPart:IsA("BasePart") then
                        -- Hace la plataforma increíblemente frágil y la desvanece al instante con el peso
                        hitPart.Size = hitPart.Size * 0.8
                        hitPart.Transparency = hitPart.Transparency + 0.2
                        hitPart.CanCollide = false
                        task.delay(0.5, function()
                           if hitPart and hitPart.Transparency >= 0.95 then
                              hitPart:Destroy()
                           else
                              if hitPart then hitPart.CanCollide = true end
                           end
                        end)
                     end
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "2. Gravedad Hiper-Pesada de Grasa (Imán de Caída Letal)",
   CurrentValue = false,
   Flag = "N_MegaHeavyFall",
   Callback = function(Value)
      getgenv().MegaHeavy = Value
      task.spawn(function()
         while getgenv().MegaHeavy do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                  if char.Humanoid.FloorMaterial == Enum.Material.Air then
                     char.HumanoidRootPart.Velocity = Vector3.new(0, -300, 0)
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "3. Auto-Impacto Sísmico (Generar Ondas de Grasa al Aterrizar)",
   CurrentValue = false,
   Flag = "N_SeismicWave",
   Callback = function(Value)
      getgenv().SeismicActive = Value
      task.spawn(function()
         while getgenv().SeismicActive do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("Humanoid") then
                  if char.Humanoid.FloorMaterial ~= Enum.Material.Air then
                     ForceFireAll("explode")
                     ForceFireAll("shockwave")
                     ForceFireAll("fatimpact")
                     ForceFireAll("stomp")
                     task.wait(0.5)
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

NightmareTab:CreateButton({
   Name = "4. Terremoto de Grasa Inmediato (Destruir Soportes Cercanos)",
   Callback = function()
      pcall(function()
         local hrp = LocalPlayer.Character.HumanoidRootPart
         for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and (part.Position - hrp.Position).Magnitude < 40 then
               part.Velocity = Vector3.new(math.random(-100, 100), 200, math.random(-100, 100))
               part.Transparency = 0.5
            end
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "5. Bucle de Colapso Estructural (Desanclar Mapa por Peso)",
   CurrentValue = false,
   Flag = "N_MapCollapse",
   Callback = function(Value)
      getgenv().MapCollapse = Value
      task.spawn(function()
         while getgenv().MapCollapse do
            pcall(function()
               for _, obj in ipairs(workspace:GetDescendants()) do
                  if obj:IsA("Model") and not obj:FindFirstChild("Humanoid") then
                     for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") and (p.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 25 then
                           p.Anchored = false
                        end
                     end
                  end
               end
            end)
            task.wait(0.5)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "6. Torbellino de Gravedad Absoluta (Chaos Spin Physics)",
   CurrentValue = false,
   Flag = "N_ChaosSpin",
   Callback = function(Value)
      getgenv().ChaosSpin = Value
      task.spawn(function()
         while getgenv().ChaosSpin do
            pcall(function()
               local char = LocalPlayer.Character
               if char and char:FindFirstChild("HumanoidRootPart") then
                  char.HumanoidRootPart.RotVelocity = Vector3.new(0, 5000, 0)
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

ExtraTab:CreateParagraph({Title = "Estado del Núcleo Nightmare v11", Content = "Apartado Nightmare enfocado 100% en el sistema avanzado de destrucción de plataformas por peso y gravedad. Experiencia, clics y tiempo optimizados al máximo."})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
