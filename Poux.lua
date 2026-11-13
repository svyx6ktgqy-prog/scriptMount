-- ============================================================================
-- OMNI-NIGHTMARE "VIP & EXTREME HYBRID" BYPASS CORE v19.0 (100% EXCLUSIVO)
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

-- BANCO MASIVO DE MÁS DE 100 PALABRAS CLAVE EXISTENCIALES DE VULNERABILIDAD
local KeywordsBank = {
    "vip", "premium", "gamepass", "pass", "admin", "owner", "mod", "moderator", "developer", "dev",
    "power", "strength", "fuerza", "damage", "attack", "speed", "walkspeed", "jump", "jumpower", "health",
    "fat", "grease", "grasa", "food", "eat", "burger", "consume", "feed", "weight", "mass", "body",
    "exp", "experience", "level", "levelup", "rank", "tier", "prestige", "rebirth", "evolution", "transcend",
    "boost", "multiplier", "x2", "x5", "x10", "x100", "potion", "elixir", "brew", "bottle", "magic",
    "money", "cash", "coins", "gems", "diamonds", "tokens", "credits", "points", "score", "clicks",
    "tap", "train", "gym", "workout", "muscle", "bicep", "chest", "abs", "legs", "stamina", "energy",
    "reward", "daily", "claim", "gift", "free", "code", "promo", "box", "chest", "crate", "unlock",
    "buy", "purchase", "shop", "store", "market", "trade", "exchange", "sale", "deal", "discount",
    "table", "mesa", "chair", "seat", "furniture", "kitchen", "restaurant", "cook", "chef", "server",
    "door", "gate", "portal", "teleport", "spawn", "zone", "area", "map", "world", "server", "client"
}

-- FUNCIÓN DE BARRIDO Y FUERZA BRUTA HÍBRIDA MASIVA
local function HybridBruteForce(actionType)
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
                local name = v.Name:lower()
                for _, kw in ipairs(KeywordsBank) do
                    if name:find(kw) then
                        if actionType == "fire" then
                            v:FireServer()
                            v:FireServer(true)
                            v:FireServer(1)
                            v:FireServer(999999999)
                        elseif actionType == "args" then
                            v:FireServer("VIP", "Admin", "UnlockAll", true, 999999999)
                        end
                    end
                end
            elseif v:IsA("RemoteFunction") then
                local name = v.Name:lower()
                for _, kw in ipairs(KeywordsBank) do
                    if name:find(kw) then
                        pcall(function() v:InvokeServer(true) end)
                        pcall(function() v:InvokeServer("VIP") end)
                        pcall(function() v:InvokeServer(999999999) end)
                    end
                end
            end
        end
    end)
end

-- CREACIÓN DE LA VENTANA PRINCIPAL RAYFIELD (EXCLUSIVO APARTADO VIP)
local Window = Rayfield:CreateWindow({
   Name = "👑 [VIP & EXTREME HYBRID] Núcleo Exclusivo de Poder v19.0 [iOS Delta]",
   LoadingTitle = "Inyectando 6 Vulnerabilidades Híbridas VIP...",
   LoadingSubtitle = "Apartado VIP Extremo: Desbloqueo Absoluto",
   ConfigurationSaving = { Enabled = false, FolderName = "ExtremeVIPV19", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO ÚNICO EXCLUSIVO: VIP, PREMIUM, PODER, TÍTULOS Y DESBLOQUEOS
--------------------------------------------------------------------------------
local VIPTab = Window:CreateTab("👑 Apartado VIP Extremo", 4483362458)
VIPTab:CreateSection("6 Métodos Híbridos Dedicados Basados en Vulnerabilidades de Datos y Memoria")

VIPTab:CreateButton({
   Name = "1. [VULNERABILIDAD #1: LEADERSTATS SPONSOR] Multiplicar Stats, Grasa y Monedas",
   Callback = function()
      pcall(function()
         if LocalPlayer:FindFirstChild("leaderstats") then
            for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
               if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                  stat.Value = stat.Value * 50000 + 999999999
               end
            end
         end
         -- Escaneo profundo de valores numéricos en todo el jugador
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
               v.Value = 999999999
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "2. [VULNERABILIDAD #2: MEMORY SPOOF] Poder al Máximo, Fuerza y Stats Ocultas",
   Callback = function()
      pcall(function()
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
               local n = v.Name:lower()
               for _, kw in ipairs(KeywordsBank) do
                  if n:find(kw) then
                     v.Value = 999999999
                  end
               end
            end
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "3. [VULNERABILIDAD #3: ATRIBUTOS DE MOTOR] Inyección de VIP Total y Admin Local",
   Callback = function()
      pcall(function()
         -- Modifica bools locales de pases y VIP
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("BoolValue") then
               v.Value = true
            end
         end
         -- Inyección de atributos de motor críticos
         LocalPlayer:SetAttribute("VIP", true)
         LocalPlayer:SetAttribute("IsVIP", true)
         LocalPlayer:SetAttribute("HasPass", true)
         LocalPlayer:SetAttribute("Admin", true)
         LocalPlayer:SetAttribute("Premium", true)
         LocalPlayer:SetAttribute("Rank", 255)
         LocalPlayer:SetAttribute("Power", 999999999)
      end)
   end,
})

VIPTab:CreateButton({
   Name = "4. [VULNERABILIDAD #4: TÍTULOS Y TAGS] Desbloquear Rango Máximo y Títulos de Creador",
   Callback = function()
      pcall(function()
         for _, v in ipairs(LocalPlayer:GetDescendants()) do
            if v:IsA("StringValue") then
               v.Value = "[👑 VIP OWNER / ADMIN ABSOLUTO 👑]"
            end
         end
         LocalPlayer:SetAttribute("Title", "Ultimate God Creator")
         LocalPlayer:SetAttribute("Tag", "[VIP EXTREME]")
      end)
   end,
})

VIPTab:CreateButton({
   Name = "5. [VULNERABILIDAD #5: DESBLOQUEO FÍSICO] Unlock Mesas, Puertas VIP y Zonas Ocultas",
   Callback = function()
      pcall(function()
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
               local name = obj.Name:lower()
               for _, kw in ipairs(KeywordsBank) do
                  if name:find(kw) then
                     if obj:IsA("BasePart") then
                        obj.CanCollide = false
                        obj.Transparency = 0.2
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
         end
      end)
   end,
})

VIPTab:CreateButton({
   Name = "6. [VULNERABILIDAD #6: RED HÍBRIDA MASIVA] Disparar +100 Keywords de Remotes",
   Callback = function()
      HybridBruteForce("fire")
      HybridBruteForce("args")
   end,
})

VIPTab:CreateToggle({
   Name = "7. [BARRIDO EXTREMO CONSTANTE] Auto-Bloqueo de Poder Máximo e Inmunidad VIP",
   CurrentValue = false,
   Flag = "VIP_ExtremeAuto",
   Callback = function(Value)
      getgenv().ExtremeVIPLoop = Value
      task.spawn(function()
         while getgenv().ExtremeVIPLoop do
            pcall(function()
               -- Mantiene leaderstats y valores al límite absoluto
               if LocalPlayer:FindFirstChild("leaderstats") then
                  for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
                     if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                        stat.Value = 999999999
                     end
                  end
               end
               for _, v in ipairs(LocalPlayer:GetDescendants()) do
                  if v:IsA("IntValue") or v:IsA("NumberValue") then
                     v.Value = 999999999
                  end
               end
               -- Refresca red híbrida suavemente
               HybridBruteForce("fire")
            end)
            task.wait(0.3)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO DE CONTROL Y EXTRAS
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Utilidades del Núcleo VIP")

ExtraTab:CreateButton({
   Name = "Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo Exclusivo v19", 
   Content = "Apartado VIP con 6 métodos híbridos basados en vulnerabilidades de memoria, Leaderstats, atributos de motor, títulos y un banco de más de 100 palabras clave existenciales."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
