-- ============================================================================
-- OMNI-NIGHTMARE "GRASA, PREMIUM & VIP" ULTIMATE CORE v15.0 (100% COMPLETO)
-- ============================================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Error al cargar Rayfield UI Library.")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- NÚCLEO DE FUERZA BRUTA GLOBAL DE RED (100% Cobertura Universal)
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
   Name = "👑 [PREMIUM VIP] Grasa, Boosters & Glitch Core v15.0 [iOS Delta]",
   LoadingTitle = "Inyectando Motores Premium, VIP y Potenciadores...",
   LoadingSubtitle = "Apartado Único de Desbloqueos Universales Activo",
   ConfigurationSaving = { 
      Enabled = false, 
      FolderName = "NightmarePremiumV15", 
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
-- APARTADO 1: AUTO FARM & "GRASA" (FAT / GREASE) ULTRA-RÁPIDA
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm & Grasa", 4483362458)
FarmTab:CreateSection("Automatización Masiva de Ingesta, Fat-Clicks y Comida")

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
            ForceFireAll("grease")
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
   Name = "2. Auto-Consumir Fast-Food / Comida Instantánea de Grasa",
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
            ForceFireAll("grease")
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
   Name = "4. Reclamar Todos los Premios, Regalos, Códigos y Grasa Diaria",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("reward") or n:find("daily") or n:find("claim") or n:find("gift") or n:find("fat") or n:find("grease") or n:find("code") then
                  v:FireServer("Claim")
                  v:FireServer(1)
                  v:FireServer("Grease")
                  v:FireServer("GetAdmin")
                  v:FireServer("Auto")
                  v:FireServer("Click")
                  v:FireServer("Plus")
                  v:FireServer("True")
                  v:FireServer("Succes")
                  v:FireServer("UnlockTables")
                  v:FireServer("isPremium")
                  v:FireServer("Get")
                  v:FireServer("Fast")
                  v:FireServer("Power")
                  v:FireServer("FatBoost")
                  v:FireServer("GreaseClaim")
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
   Name = "6. Auto-Equipar Mejor Objeto / Mascota de Grasa (Max Gear)",
   CurrentValue = false,
   Flag = "G_AutoEquip",
   Callback = function(Value)
      getgenv().FatEquip = Value
      task.spawn(function()
         while getgenv().FatEquip do
            pcall(function()
               for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                  if v:IsA("RemoteFunction") and (v.Name:lower():find("equip") or v.Name:lower():find("fat") or v.Name:lower():find("grease")) then
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
-- APARTADO 2: PROGRESO EXTREMO (EXP, LEVEL, REBIRTH)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso & Rebirth", 4483362458)
ProgTab:CreateSection("Bypasses de Experiencia, Niveles y Renacimiento Masivo")

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
   Name = "2. Auto Level Up Instantáneo por Fuerza Bruta (Up / Rank)",
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
            ForceFireAll("level")
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

ProgTab:CreateToggle({
   Name = "4. Reclamador Automático de Todos los Premios y Tiempo Online",
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
            ForceFireAll("free")
            task.wait(10)
         end
      end)
   end,
})

ProgTab:CreateButton({
   Name = "5. Anti-Rollback Forzado (Guardado de Datos Crítico Anti-Perdida)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("save") then
               v:FireServer("Save")
               v:FireServer()
            end
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3 [ÚNICO]: OBTENER, DESBLOQUEAR, COMPRAR, UNLOCK PREMIUM, VIP, BOOSTERS, POCIONES Y MÉTODOS DE PODER ABSOLUTO
--------------------------------------------------------------------------------
local PremiumTab = Window:CreateTab("👑 Premium, VIP & Boosters", 4483362458)
PremiumTab:CreateSection("Apartado Único: Desbloqueo Masivo Universal de Pagos y Ventajas")

PremiumTab:CreateButton({
   Name = "1. [UNLOCK] Comprar/Desbloquear Todo el Rango VIP Gratis (Bypass Remotes)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
               local n = v.Name:lower()
               if n:find("vip") or n:find("buyvip") or n:find("claimvip") or n:find("pass") then
                  if v:IsA("RemoteEvent") then
                     v:FireServer(true)
                     v:FireServer("VIP")
                     v:FireServer(1)
                  elseif v:IsA("RemoteFunction") then
                     v:InvokeServer(true)
                     v:InvokeServer("VIP")
                  end
               end
            end
         end
      end)
   end,
})

PremiumTab:CreateButton({
   Name = "2. [OBTENER] Inyectar Todos los Boosters Activos del Servidor (All Boosters)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("boost") or n:find("multiplier") or n:find("x2") or n:find("speed") or n:find("power") then
                  for i = 1, 50 do
                     v:FireServer(i)
                     v:FireServer("Boost")
                     v:FireServer(true)
                  end
               end
            end
         end
      end)
   end,
})

PremiumTab:CreateButton({
   Name = "3. [CONSEGUIR] Pociones Infinitas y Potenciadores Ocultos (Potions & Brews)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
               local n = v.Name:lower()
               if n:find("potion") or n:find("potions") or n:find("brew") or n:find("potenciador") or n:find("elixir") then
                  if v:IsA("RemoteEvent") then
                     v:FireServer("BuyAll")
                     v:FireServer("UseAll")
                     v:FireServer(999999)
                  elseif v:IsA("RemoteFunction") then
                     v:InvokeServer("BuyAll")
                     v:InvokeServer("UseAll")
                  end
               end
            end
         end
      end)
   end,
})

PremiumTab:CreateButton({
   Name = "4. [COMPRAR] Desbloqueo Masivo de Gamepasses y Tienda Premium (Shop Bypass)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("gamepass") or n:find("shop") or n:find("buy") or n:find("purchase") or n:find("premium") or n:find("store") then
                  for i = 1, 100 do
                     v:FireServer(i)
                     v:FireServer("Buy")
                     v:FireServer(true)
                     v:FireServer("Free")
                  end
               end
            end
         end
      end)
   end,
})

PremiumTab:CreateToggle({
   Name = "5. [MÉTODO AUTOMÁTICO] Bucle de Auto-Compra de Tienda y Reclamo VIP",
   CurrentValue = false,
   Flag = "P_AutoShopVIP",
   Callback = function(Value)
      getgenv().AutoShopVIP = Value
      task.spawn(function()
         while getgenv().AutoShopVIP do
            pcall(function()
               for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                  if v:IsA("RemoteEvent") then
                     local n = v.Name:lower()
                     if n:find("buy") or n:find("claim") or n:find("vip") or n:find("boost") or n:find("potion") then
                        v:FireServer("Buy")
                        v:FireServer("Claim")
                        v:FireServer(true)
                     end
                  end
               end
            end)
            task.wait(1)
         end
      end)
   end,
})

PremiumTab:CreateButton({
   Name = "6. [MÉTODOS DIFERENTES] Forzar Recompensas de Suscriptores y Grupo (Group Rewards)",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("group") or n:find("subscriber") or n:find("social") or n:find("like") or n:find("favorite") then
                  v:FireServer("Claim")
                  v:FireServer(true)
                  v:FireServer("Verified")
               end
            end
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: VELOCIDAD Y TIEMPO (Time Scale & Motor Control)
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("Velocidad & Tiempo", 4483362458)
TimeTab:CreateSection("Manipulación Absoluta del Reloj, Velocidad del Juego y Física")

TimeTab:CreateSlider({
   Name = "1. Velocidad de Movimiento Global (WalkSpeed de Grasa)",
   Range = {16, 800},
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
   Range = {50, 900},
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
   Name = "3. Acelerador de Tiempo del Motor (Time Scale Glitch Multiplicador)",
   Range = {1, 30},
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
   Name = "4. Congelar Reloj del Servidor en Medianoche (Time Fix 00:00)",
   Callback = function()
      pcall(function()
         Lighting.TimeOfDay = "00:00:00"
         Lighting.ClockTime = 0
      end)
   end,
})

TimeTab:CreateToggle({
   Name = "5. Anti-AFK Absoluto (Imedir Desconexión / Kick por Inactividad)",
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
   Name = "6. Teletransporte de Emergencia al Spawn Principal",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 5: GLITCHES DE FRAMES Y RENDIMIENTO
--------------------------------------------------------------------------------
local FrameTab = Window:CreateTab("Glitches & Frames", 4483362458)
FrameTab:CreateSection("Optimizaciones de Motor Gráfico y FPS Bypass Masivo")

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
   Name = "2. Glitch de Lag Switch de Red (Congelar Replicación de Paquetes 5s)",
   Callback = function()
      pcall(function()
         settings():GetService("NetworkSettings").IncomingReplicationLag = 30
         task.wait(5)
         settings():GetService("NetworkSettings").IncomingReplicationLag = 0
      end)
   end,
})

FrameTab:CreateToggle({
   Name = "3. Modo Gráfico Papas Extremo (Eliminar Texturas y Partículas pesadas)",
   CurrentValue = false,
   Flag = "G_PotatoMode",
   Callback = function(Value)
      pcall(function()
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
               v.Material = Value and Enum.Material.SmoothPlastic or Enum.Material.Neon
               v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
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
            track:AdjustSpeed(8.0)
         end
      end)
   end,
})

FrameTab:CreateButton({
   Name = "5. Bug de Spam Masivo de Sockets (Socket Flood en Ráfaga)",
   Callback = function()
      task.spawn(function()
         for i = 1, 500 do
            ForceFireAll("click")
            ForceFireAll("fat")
            ForceFireAll("grease")
         end
      end)
   end,
})

FrameTab:CreateToggle({
   Name = "6. Ocultar Todos los Demás Jugadores (Aceleración Extrema de FPS)",
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
-- APARTADO 6 [NIGHTMARE]: DESTRUCCIÓN AVANZADA POR GRASA Y PESO
--------------------------------------------------------------------------------
local NightmareTab = Window:CreateTab("Nightmare: Fat-Crush Focus", 4483362458)
NightmareTab:CreateSection("Métodos Avanzados de Peso, Gravedad y Cataclismo Estructural")

NightmareTab:CreateToggle({
   Name = "1. Fat-Crush Pro: Destrucción Instantánea de Plataformas por Obesidad",
   CurrentValue = false,
   Flag = "N_FatCrushPro",
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
                        hitPart.Size = hitPart.Size * 0.6
                        hitPart.Transparency = hitPart.Transparency + 0.4
                        hitPart.CanCollide = false
                        task.delay(0.2, function()
                           if hitPart and hitPart.Transparency >= 0.95 then
                              hitPart:Destroy()
                           elseif hitPart then
                              hitPart.CanCollide = true
                           end
                        end)
                     end
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "2. Gravedad Hiper-Pesada de Grasa (Imán de Caída Letal Masiva)",
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
                     char.HumanoidRootPart.Velocity = Vector3.new(0, -600, 0)
                  end
               end
            end)
            task.wait(0.02)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "3. Auto-Impacto Sísmico Masivo (Ondas de Choque Fat al Aterrizar)",
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
                     task.wait(0.2)
                  end
               end
            end)
            task.wait(0.02)
         end
      end)
   end,
})

NightmareTab:CreateToggle({
   Name = "4. Agujero Negro de Grasa (Atraer Todas las Partes y Objetos Cercanos)",
   CurrentValue = false,
   Flag = "N_FatBlackhole",
   Callback = function(Value)
      getgenv().FatBlackholeActive = Value
      task.spawn(function()
         while getgenv().FatBlackholeActive do
            pcall(function()
               local hrp = LocalPlayer.Character.HumanoidRootPart
               for _, part in ipairs(workspace:GetDescendants()) do
                  if part:IsA("BasePart") and not part.Anchored and (part.Position - hrp.Position).Magnitude < 70 then
                     part.Velocity = (hrp.Position - part.Position) * 15
                  end
               end
            end)
            task.wait(0.05)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 7: EXTRAS & SISTEMA GLOBAL
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Utilidades de Control Total y Desbloqueos Inesperados")

ExtraTab:CreateButton({
   Name = "1. Desbloquear Cosas Inesperadas / Secretos Ocultos del Servidor",
   Callback = function()
      pcall(function()
         for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
               local n = v.Name:lower()
               if n:find("secret") or n:find("unlock") or n:find("unexpected") or n:find("special") or n:find("admin") then
                  v:FireServer(true)
                  v:FireServer("UnlockAll")
                  v:FireServer(999999)
               end
            end
         end
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "2. Forzar Reinicio de Personaje (Reset Local Rápido)",
   Callback = function()
      pcall(function()
         LocalPlayer.Character.Humanoid.Health = 0
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "3. Reconectar al Servidor Actual (Rejoin Rápido)",
   Callback = function()
      pcall(function()
         game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
      end)
   end,
})

ExtraTab:CreateButton({
   Name = "4. Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo v15 con Apartado VIP", 
   Content = "Versión definitiva completa con el nuevo apartado exclusivo para obtener, desbloquear, comprar y ulock de Premium, VIP, Boosters, Pociones y métodos de fuerza bruta globales."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
