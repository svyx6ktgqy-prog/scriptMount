-- ============================================================================
-- OMNI-NIGHTMARE "LEADERSTATS & MEMORY SPOOF" ENGINE v18.0 (100% GARANTIZADO)
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

-- NÚCLEO DE FUERZA BRUTA GLOBAL DE RED (Secundario)
local function ForceFireAll(keyword)
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                if v.Name:lower():find(keyword) then
                    v:FireServer()
                end
            end
        end
    end)
end

-- CREACIÓN DE LA VENTANA PRINCIPAL RAYFIELD
Window = Rayfield:CreateWindow({
   Name = "👑 [MEMORY SPOOF & VIP HUB] Motor de Datos v18.0 [iOS Delta]",
   LoadingTitle = "Inyectando Modificadores de Memoria Local...",
   LoadingSubtitle = "Enfoque 100% Basado en Modificación de Valores",
   ConfigurationSaving = { Enabled = false, FolderName = "MemoryV18", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: AUTO FARM & "GRASA"
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Auto Farm & Grasa", 4483362458)
FarmTab:CreateSection("Automatización de Ingesta y Fat-Clicks")

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

--------------------------------------------------------------------------------
-- APARTADO 2: PROGRESO EXTREMO (EXP, LEVEL, REBIRTH)
--------------------------------------------------------------------------------
local ProgTab = Window:CreateTab("Progreso & Rebirth", 4483362458)
ProgTab:CreateSection("Bypasses de Experiencia y Niveles")

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
            task.wait(0.01)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3 [MÉTODO MAESTRO]: LEADERSTATS, TÍTULOS, PODER MÁXIMO & VIP TOTAL
--------------------------------------------------------------------------------
local VIPTab = Window:CreateTab("👑 Leaderstats & VIP Total", 4483362458)
VIPTab:CreateSection("Modificación Avanzada de Valores, Memoria y Atributos Locales")

VIPTab:CreateButton({
   Name = "1. [LEADERSTATS] Multiplicar Grasa, Monedas y Niveles al Máximo",
   Callback = function()
      pcall(function()
         if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
               if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                  stat.Value = stat.Value * 10000 + 999999999
               end
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "2. [PODER AL MÁXIMO] Escanear y Multiplicar Cualquier Stat de Poder",
   Callback = function()
      pcall(function()
         -- Busca en TODO el jugador y carpetas de datos valores de fuerza, poder, damage o power
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) then
               local name = v.Name:lower()
               if name:find("power") or name:find("strength") or name:find("fuerza") or name:find("damage") or name:find("attack") then
                  v.Value = v.Value + 999999999
               end
            end
         end
         -- Revisa también en PlayerGui o contenedores de stats flotantes
         for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("IntValue") and (v.Name:lower():find("power") or v.Name:lower():find("fuerza")) then
               v.Value = 999999999
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "3. [TÍTULOS Y RANGOS] Desbloquear y Cambiar Títulos a Máximo Rango",
   Callback = function()
      pcall(function()
         -- Busca valores de texto (StringValue) relacionados con títulos, rangos o tags
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("StringValue") and (v.Name:lower():find("title") or v.Name:lower():find("rank") or v.Name:lower():find("tag") or v.Name:lower():find("rango")) then
               v.Value = "[👑 VIP ABSOLUTO / ADMIN 👑]"
            end
         end
         -- Inyecta Atributos de Título en el personaje
         LocalPlayer:SetAttribute("Title", "Ultimate God")
         LocalPlayer:SetAttribute("Rank", "Owner")
      end)
   end,
})

VIPTab:CreateButton({
   Name = "4. [VIP TOTAL & PASS] Inyección Masiva de Atributos VIP en el Cliente",
   Callback = function()
      pcall(function()
         -- Modifica bools de pases y VIP
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("BoolValue") and (v.Name:lower():find("vip") or v.Name:lower():find("pass") or v.Name:lower():find("premium") or v.Name:lower():find("gamepass")) then
               v.Value = true
            end
         end
         -- Fuerza atributos de motor a nivel de objeto
         LocalPlayer:SetAttribute("VIP", true)
         LocalPlayer:SetAttribute("IsVIP", true)
         LocalPlayer:SetAttribute("HasPass", true)
         LocalPlayer:SetAttribute("Admin", true)
         LocalPlayer:SetAttribute("Premium", true)
      end)
   end,
})

VIPTab:CreateButton({
   Name = "5. [UNLOCK MESAS & ZONAS VIP] Forzar Activación de Puertas y Objetos",
   Callback = function()
      pcall(function()
         -- Busca modelos de mesas, puertas VIP o zonas bloqueadas y altera sus propiedades físicas
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
               local name = obj.Name:lower()
               if name:find("mesa") or name:find("table") or name:find("vip") or name:find("door") or name:find("puerta") then
                  if obj:IsA("BasePart") then
                     obj.CanCollide = false
                     obj.Transparency = 0.3
                  elseif obj:IsA("Model") then
                     for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                           p.CanCollide = false
                        end
                     end
                  end
               end
            end
         end
      end)
   end,
})

VIPTab:CreateToggle({
   Name = "6. [BARRIDO CONSTANTE] Auto-Bloqueo y Mantenimiento de Valores al Máximo",
   CurrentValue = false,
   Flag = "LS_AutoMaxV18",
   Callback = function(Value)
      getgenv().AutoMaxV18 = Value
      task.spawn(function()
         while getgenv().AutoMaxV18 do
            pcall(function()
               -- Mantiene leaderstats al límite
               if LocalPlayer:FindFirstChild("leaderstats") then
                  for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                     if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                        stat.Value = 999999999
                     end
                  end
               end
               -- Mantiene cualquier stat de poder o grasa al límite
               for _, v in ipairs(LocalPlayer:GetDescendants()) do
                  if v:IsA("IntValue") or v:IsA("NumberValue") then
                     local n = v.Name:lower()
                     if n:find("power") or n:find("strength") or n:find("fat") or n:find("grasa") or n:find("fuerza") then
                        v.Value = 999999999
                     end
                  end
               end
            end)
            task.wait(0.2)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: VELOCIDAD Y TIEMPO
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("Velocidad & Tiempo", 4483362458)
TimeTab:CreateSection("Controles de Velocidad y Física")

TimeTab:CreateSlider({
   Name = "1. Velocidad de Movimiento Global (WalkSpeed)",
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
   Name = "2. Salto Hiper-Pesado (JumpPower)",
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

--------------------------------------------------------------------------------
-- APARTADO 5: GLITCHES DE FRAMES Y RENDIMIENTO
--------------------------------------------------------------------------------
local FrameTab = Window:CreateTab("Glitches & Frames", 4483362458)
FrameTab:CreateSection("Optimizaciones de Motor Gráfico")

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

--------------------------------------------------------------------------------
-- APARTADO 6 [NIGHTMARE]: DESTRUCCIÓN POR PESO
--------------------------------------------------------------------------------
local NightmareTab = Window:CreateTab("Nightmare: Fat-Crush Focus", 4483362458)
NightmareTab:CreateSection("Destrucción de Plataformas por Obesidad")

NightmareTab:CreateToggle({
   Name = "1. Fat-Crush Pro: Destrucción de Plataformas al Caer",
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
-- APARTADO 7: EXTRAS & SISTEMA
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Utilidades de Control")

ExtraTab:CreateButton({
   Name = "1. Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo v18 Memory Spoof", 
   Content = "Apartado VIP rediseñado por completo bajo el método de modificación directa de valores, stats de poder, títulos, atributos y desbloqueo de mesas."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
