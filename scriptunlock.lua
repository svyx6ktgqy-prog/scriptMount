-- =====================================================================
-- 🔓 UNLOCK MINER - GLITCH & BYPASS EDITION
-- UI: Rayfield | Especializado en Desbloqueos, Economía y Portales
-- =====================================================================

if _G.UnlockMinerLoaded then
    warn("UNLOCK MINER ya está en ejecución.")
    return
end
_G.UnlockMinerLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔓 UNLOCK MINER | Glitch Edition",
    LoadingTitle = "Iniciando Motor de Desbloqueo...",
    LoadingSubtitle = "Bypasses & Glitches Activos",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- =====================================================================
-- PESTAÑA 1: 👕 DESBLOQUEO MASIVO Y EQUIPAMIENTO
-- =====================================================================
local UnlockTab = Window:CreateTab("Accesorios & Ropa", 4483362458)

UnlockTab:CreateSection("Desbloqueo Agresivo")

UnlockTab:CreateButton({
    Name = "🔓 Forzar Desbloqueo de TODO (Mascotas, Ropa, Cajas)",
    Callback = function()
        local count = 0
        local keywords = {"unlock", "open", "spin", "hatch", "claim", "buy", "purchase", "reward", "gift", "accessory", "skin", "pet", "crate", "box", "outfit", "equip"}
        
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                for _, word in ipairs(keywords) do
                    if string.match(n, word) then
                        -- Enviar múltiples argumentos comunes para forzar la respuesta del servidor
                        pcall(function() remote:FireServer() end)
                        pcall(function() remote:FireServer(true) end)
                        pcall(function() remote:FireServer(1) end)
                        pcall(function() remote:FireServer("UnlockAll") end)
                        pcall(function() remote:FireServer("Max") end)
                        count = count + 1
                        break -- Pasa al siguiente remote si ya hizo match
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Ataque de Desbloqueo", Content = "Se enviaron " .. count .. " peticiones de desbloqueo al servidor.", Duration = 4})
    end,
})

UnlockTab:CreateButton({
    Name = "🎒 Auto-Equipar Todo / Forzar Inventario",
    Callback = function()
        local equipKeywords = {"equip", "wear", "use", "select", "outfit"}
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                for _, word in ipairs(equipKeywords) do
                    if string.match(n, word) then
                        pcall(function() remote:FireServer("EquipAll") end)
                        pcall(function() remote:FireServer("EquipBest") end)
                        pcall(function() remote:FireServer(true) end)
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Auto-Equip", Content = "Intentando equipar los mejores accesorios/mascotas.", Duration = 3})
    end,
})

UnlockTab:CreateButton({
    Name = "👁️ Destruir Candados UI (Ver todo)",
    Callback = function()
        local destroyed = 0
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("GuiObject") then
                local n = gui.Name:lower()
                -- Busca elementos visuales de bloqueo y los borra
                if string.match(n, "lock") or string.match(n, "padlock") or string.match(n, "paywall") or string.match(n, "blur") or string.match(n, "premium") or string.match(n, "vip") then
                    gui.Visible = false
                    destroyed = destroyed + 1
                end
            end
        end
        Rayfield:Notify({Title = "UI Limpia", Content = destroyed .. " barreras visuales eliminadas.", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 2: 💸 GLITCHES DE ECONOMÍA Y BOMBAS
-- =====================================================================
local GlitchTab = Window:CreateTab("Glitches & Mejoras", 4483362458)

GlitchTab:CreateSection("Explotación de Precios")

GlitchTab:CreateButton({
    Name = "💣 Glitch: Intentar Costo Cero / Negativo (Mejoras/Bombas)",
    Callback = function()
        local count = 0
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local n = remote.Name:lower()
                if string.match(n, "upgrade") or string.match(n, "buy") or string.match(n, "bomb") or string.match(n, "tnt") or string.match(n, "level") then
                    -- Intento de Underflow/Overflow: Enviar valores negativos, infinitos o cero
                    pcall(function() remote:FireServer(0) end)
                    pcall(function() remote:FireServer(-999999999) end)
                    pcall(function() remote:FireServer(-math.huge) end)
                    pcall(function() remote:FireServer(nil) end)
                    count = count + 1
                end
            end
        end
        Rayfield:Notify({
            Title = "Price Glitch Ejecutado", 
            Content = count .. " remotos probados. Revisa si tus mejoras o bombas cuestan 0 o te dieron dinero.", 
            Duration = 5
        })
    end,
})

GlitchTab:CreateButton({
    Name = "⚙️ Maxear Stats Automáticamente (Fuerza Bruta)",
    Callback = function()
        -- Loop rápido para spamear compras normales asumiendo que cuestan 0 o tienes el dinero
        for i = 1, 50 do
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and string.match(remote.Name:lower(), "upgrade") then
                    pcall(function() remote:FireServer() end)
                    pcall(function() remote:FireServer(1) end)
                end
            end
            task.wait(0.05)
        end
        Rayfield:Notify({Title = "Upgrade Spammer", Content = "Ráfaga de mejoras finalizada.", Duration = 3})
    end,
})

-- =====================================================================
-- PESTAÑA 3: 🌌 MAPAS, PORTALES Y BARRERAS
-- =====================================================================
local MapTab = Window:CreateTab("Mapas & Zonas", 4483362458)

MapTab:CreateSection("Progresión Rápida")

MapTab:CreateButton({
    Name = "🚪 Forzar TP al Siguiente Mapa/Zona",
    Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local found = false
        local keywords = {"portal", "teleport", "nextmap", "nextzone", "gate", "door", "area", "zone", "world"}
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                for _, word in ipairs(keywords) do
                    -- Evitar teletransportarse a la zona de inicio si podemos evitarlo
                    if string.match(n, word) and not string.match(n, "spawn") and not string.match(n, "lobby") then
                        -- Lo movemos ligeramente arriba del portal para evitar bugs físicos
                        root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                        found = true
                        
                        -- Forzamos el evento touch por si el portal lo requiere
                        local touch = part:FindFirstChild("TouchInterest")
                        if touch and firetouchinterest then
                            firetouchinterest(root, part, 0)
                            task.wait(0.1)
                            firetouchinterest(root, part, 1)
                        end
                        
                        Rayfield:Notify({Title = "Salto de Mapa", Content = "Teletransportado a: " .. part.Name, Duration = 3})
                        return -- Nos salimos al encontrar el primer portal válido
                    end
                end
            end
        end
        
        if not found then
            Rayfield:Notify({Title = "Sin Portales", Content = "No se detectaron zonas nuevas en este momento.", Duration = 3})
        end
    end,
})

MapTab:CreateButton({
    Name = "🧱 Eliminar Muros Invisibles / Barreras VIP",
    Callback = function()
        local wallsRemoved = 0
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                -- Identifica muros de bloqueo de nivel, VIP o límites de zona
                if string.match(n, "barrier") or string.match(n, "wall") or string.match(n, "border") or string.match(n, "vip") or string.match(n, "requirement") or part.Transparency == 1 then
                    if part.CanCollide == true and part.Name ~= "HumanoidRootPart" and part.Name ~= "Baseplate" then
                        part.CanCollide = false
                        wallsRemoved = wallsRemoved + 1
                    end
                end
            end
        end
        Rayfield:Notify({Title = "Noclip de Mapa", Content = "Se eliminaron " .. wallsRemoved .. " muros/barreras.", Duration = 3})
    end,
})
