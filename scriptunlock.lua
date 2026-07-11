-- =====================================================================
-- 🔓 UNLOCK MINER - EXTREME BYPASS EDITION
-- UI: Rayfield | Metatable Hooking, Module Overwrite & Signal Firing
-- =====================================================================

if _G.UnlockMinerLoaded then
    warn("UNLOCK MINER ya está en ejecución.")
    return
end
_G.UnlockMinerLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔓 UNLOCK MINER | Extreme Bypass",
    LoadingTitle = "Inyectando Hooks de Memoria...",
    LoadingSubtitle = "Acceso Root - No Abusar",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- =====================================================================
-- PESTAÑA 1: ☠️ HACKEO DE ECONOMÍA Y MEMORIA (MODULES)
-- =====================================================================
local MemoryTab = Window:CreateTab("Memoria & Precios", 4483362458)

MemoryTab:CreateSection("Sobrescritura de Tablas (Client-Side)")

MemoryTab:CreateButton({
    Name = "📉 Forzar Todo a Costo $0 (Reescribir Modules)",
    Callback = function()
        local modulesHacked = 0
        -- Busca todos los scripts de configuración del juego
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                pcall(function()
                    -- Requiere el módulo para acceder a su tabla interna
                    local data = require(obj)
                    if type(data) == "table" then
                        -- Itera sobre la tabla y sobrescribe precios y estados
                        for k, v in pairs(data) do
                            if type(v) == "table" then
                                if v.Price then v.Price = 0; modulesHacked = modulesHacked + 1 end
                                if v.Cost then v.Cost = 0; modulesHacked = modulesHacked + 1 end
                                if v.UnlockCost then v.UnlockCost = 0 end
                                if v.IsOwned ~= nil then v.IsOwned = true end
                                if v.Unlocked ~= nil then v.Unlocked = true end
                                if v.LevelRequired then v.LevelRequired = 0 end
                            end
                        end
                    end
                end)
            end
        end
        Rayfield:Notify({
            Title = "Memoria Alterada", 
            Content = "Se alteraron " .. modulesHacked .. " valores. Abre la tienda, todo debería costar 0 visualmente. Intenta comprar.", 
            Duration = 5
        })
    end,
})

MemoryTab:CreateButton({
    Name = "💰 Spoofear Monedas Locales (Bypass de UI Check)",
    Callback = function()
        -- Engaña a la UI haciéndole creer que tienes dinero infinito para que te deje clickear "Comprar"
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("Stats") or LocalPlayer
        local altered = 0
        for _, val in ipairs(stats:GetDescendants()) do
            if val:IsA("NumberValue") or val:IsA("IntValue") then
                val.Value = 999999999999
                altered = altered + 1
            end
        end
        Rayfield:Notify({Title = "Spoofer Activo", Content = "Se falsificaron " .. altered .. " valores monetarios en tu cliente.", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 2: 👕 DESBLOQUEO POR SEÑALES (BYPASS DE BOTONES)
-- =====================================================================
local SignalTab = Window:CreateTab("Auto-Desbloqueo", 4483362458)

SignalTab:CreateSection("Ejecución Directa de Nodos")

SignalTab:CreateButton({
    Name = "⚡ Forzar Clic en TODOS los botones de Comprar/Reclamar",
    Callback = function()
        local clicks = 0
        local keywords = {"buy", "claim", "purchase", "unlock", "equip", "get", "upgrade", "max"}
        
        -- En vez de adivinar el remoto, buscamos los botones en tu pantalla
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local text = (gui:IsA("TextButton") and gui.Text:lower()) or gui.Name:lower()
                
                for _, word in ipairs(keywords) do
                    if string.match(text, word) then
                        -- Usamos getconnections para ejecutar el código que el desarrollador asignó al botón
                        pcall(function()
                            for _, connection in pairs(getconnections(gui.MouseButton1Click)) do
                                connection:Function()
                                clicks = clicks + 1
                            end
                            for _, connection in pairs(getconnections(gui.Activated)) do
                                connection:Function()
                                clicks = clicks + 1
                            end
                        end)
                        break
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Ataque de Interfaz", Content = "Se forzaron " .. clicks .. " clics invisibles en botones de compra/equipamiento.", Duration = 4})
    end,
})

-- =====================================================================
-- PESTAÑA 3: 👑 HOOKS & PERMISOS (VIP SPOOFER)
-- =====================================================================
local HookTab = Window:CreateTab("Privilegios (VIP)", 4483362458)

HookTab:CreateSection("Intercepción de Metatablas")

local hookEnabled = false
HookTab:CreateToggle({
    Name = "🛡️ Spoofear Posesión de Gamepasses / VIP",
    CurrentValue = false,
    Flag = "GamepassSpoof",
    Callback = function(Value)
        hookEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Hook Inyectado", Content = "El juego ahora creerá que tienes todos los Gamepasses comprados.", Duration = 4})
        else
            Rayfield:Notify({Title = "Hook Retirado", Content = "Verificación de Gamepasses restaurada a la normalidad.", Duration = 3})
        end
    end,
})

-- Hooking profesional de la Metatabla del juego
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if hookEnabled then
        -- Engaña las funciones oficiales de Roblox que verifican si compraste algo
        if method == "UserOwnsGamePassAsync" or method == "PlayerOwnsAsset" then
            return true
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- =====================================================================
-- PESTAÑA 4: 🌌 MAPAS, PORTALES Y BARRERAS
-- =====================================================================
local MapTab = Window:CreateTab("Mapas & TP", 4483362458)

MapTab:CreateButton({
    Name = "🚪 Forzar TP al Siguiente Mapa/Zona",
    Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local found = false
        local keywords = {"portal", "teleport", "nextmap", "nextzone", "gate", "door"}
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                for _, word in ipairs(keywords) do
                    if string.match(n, word) and not string.match(n, "spawn") then
                        root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                        found = true
                        
                        local touch = part:FindFirstChild("TouchInterest")
                        if touch and firetouchinterest then
                            firetouchinterest(root, part, 0)
                            task.wait(0.1)
                            firetouchinterest(root, part, 1)
                        end
                        
                        Rayfield:Notify({Title = "Salto de Mapa", Content = "Teletransportado a: " .. part.Name, Duration = 3})
                        return 
                    end
                end
            end
        end
        if not found then
            Rayfield:Notify({Title = "Sin Portales", Content = "No se detectaron zonas nuevas.", Duration = 3})
        end
    end,
})
