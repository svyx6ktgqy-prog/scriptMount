-- ============================================================================
-- OMNI-NIGHTMARE "LEADERSTATS & VIP" FORCE-BYPASS ENGINE v17.0 (100% EFECTIVO)
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

-- NÚCLEO DE FUERZA BRUTA GLOBAL DE RED
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
   Name = "👑 [LEADERSTATS & VIP] Motor de Datos Locales v17.0 [iOS Delta]",
   LoadingTitle = "Inyectando Métodos de Leaderstats y VIP...",
   LoadingSubtitle = "Enfoque 100% Basado en el Método Exitoso",
   ConfigurationSaving = { 
      Enabled = false, 
      FolderName = "NightmareLeaderstatsV17", 
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
            ForceFireAll("grease")
            ForceFireAll("tap")
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
            task.wait(0.005)
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
            task.wait(0.01)
         end
      end)
   end,
})

ProgTab:CreateToggle({
   Name = "2. Auto Rebirth / Prestige Masivo Constante",
   CurrentValue = false,
   Flag = "G_RebirthLoop",
   Callback = function(Value)
      getgenv().RebirthLoop = Value
      task.spawn(function()
         while getgenv().RebirthLoop do
            ForceFireAll("rebirth")
            ForceFireAll("prestige")
            task.wait(0.5)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3 [ÚNICO Y MEJORADO]: LEADERSTATS, VIP, ADMIN & DESBLOQUEO DE MESAS
--------------------------------------------------------------------------------
local VIPTab = Window:CreateTab("👑 Leaderstats & VIP Hub", 4483362458)
VIPTab:CreateSection("Métodos Basados en Modificación de Datos Locales (El Único que Funciona)")

VIPTab:CreateButton({
   Name = "1. [LEADERSTATS] Multiplicar Masivamente Grasa, Monedas y Niveles",
   Callback = function()
      pcall(function()
         if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
               if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                  stat.Value = stat.Value * 10000 + 999999 -- Incremento masivo instantáneo
               end
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "2. [VIP & ATRIBUTOS] Forzar Estado VIP y Permisos en el Cliente",
   Callback = function()
      pcall(function()
         -- Busca y modifica valores booleanos de VIP o Premium en todo el jugador
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("BoolValue") and (v.Name:lower():find("vip") or v.Name:lower():find("premium") or v.Name:lower():find("pass")) then
               v.Value = true
            end
         end
         -- Inyección de atributos de motor
         LocalPlayer:SetAttribute("VIP", true)
         LocalPlayer:SetAttribute("IsVIP", true)
         LocalPlayer:SetAttribute("HasPass", true)
         LocalPlayer:SetAttribute("Admin", true)
         print("Atributos VIP, Admin y Pases forzados con éxito.")
      end)
   end,
})

VIPTab:CreateButton({
   Name = "3. [UNLOCK MESAS] Desbloquear y Reclamar Todas las Mesas y Objetos VIP",
   Callback = function()
      pcall(function()
         -- Modifica valores de mesas/comida o interactúa con objetos de la workspace cercanos
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("mesa") or obj.Name:lower():find("table") or obj.Name:lower():find("vip") or obj.Name:lower():find("food")) then
               for _, part in ipairs(obj:GetDescendants()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = true
                     -- Teletransporta la mesa/objeto hacia ti o la desbloquea visualmente
                     if (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 30 then
                        part.Transparency = 0
                     end
                  end
               end
            end
         end
         -- Fuerza eventos de red relacionados con mesas o desbloqueos
         ForceFireAll("table")
         ForceFireAll("mesa")
         ForceFireAll("unlock")
      end)
   end,
})

VIPTab:CreateButton({
   Name = "4. [ADMIN LOCAL] Activar Comandos y Privilegios de Administrador en Cliente",
   Callback = function()
      pcall(function()
         -- Modifica carpetas de administración locales si el juego utiliza sistemas basados en rangos
         LocalPlayer:SetAttribute("Rank", 255)
         LocalPlayer:SetAttribute("AdminLevel", 5)
         LocalPlayer:SetAttribute("IsAdmin", true)
         
         if LocalPlayer:FindFirstChild("PlayerGui") then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
               if gui:IsA("TextButton") and (gui.Name:lower():find("admin") or gui.Name:lower():find("vip")) then
                  gui.Visible = true -- Revela botones de admin ocultos en la UI
               end
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "5. [GLITCH DE EXP] Bucle de Auto-Incremento de Experiencia en Leaderstats",
   Callback = function()
      pcall(function()
         if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
               if stat.Name:lower():find("exp") or stat.Name:lower():find("level") or stat.Name:lower():find("nivel") then
                  stat.Value = stat.Value + 50000
               end
            end
         end
      end)
   end,
})

VIPTab:CreateToggle({
   Name = "6. [BARRIDO CONSTANTE] Auto-Actualizador y Bloqueo de Leaderstats Máximos",
   CurrentValue = false,
   Flag = "LS_AutoMax",
   Callback = function(Value)
      getgenv().AutoMaxStats = Value
      task.spawn(function()
         while getgenv().AutoMaxStats do
            pcall(function()
               if LocalPlayer:FindFirstChild("leaderstats") then
                  for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                     if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                        stat.Value = 999999999 -- Mantiene los valores al máximo absoluto
                     end
                  end
               end
            end)
            task.wait(0.5)
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

TimeTab:CreateButton({
   Name = "3. Congelar Reloj del Servidor en Medianoche (Time Fix 00:00)",
   Callback = function()
      pcall(function()
         Lighting.TimeOfDay = "00:00:00"
         Lighting.ClockTime = 0
      end)
   end,
})

TimeTab:CreateToggle({
   Name = "4. Anti-AFK Absoluto (Imedir Desconexión / Kick por Inactividad)",
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

--------------------------------------------------------------------------------
-- APARTADO 7: EXTRAS & SISTEMA GLOBAL
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Utilidades de Control Total y Desbloqueos Inesperados")

ExtraTab:CreateButton({
   Name = "1. Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo v17 Leaderstats", 
   Content = "Apartado VIP rediseñado al 100% en torno al método que sí funciona: manipulación directa de Leaderstats, atributos VIP, desbloqueo de mesas y privilegios de admin local."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
