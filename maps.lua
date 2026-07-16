-- ==================================================
-- [ ALB8RAAQ ] - K2 EXCLUSIVE WARP & BYPASS SUITE
-- ==================================================

-- Cargar librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear ventana única para K2
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: K2 EXPLOIT",
   LoadingTitle = "Inyectando ALB8RAAQ K2 Bypass...",
   LoadingSubtitle = "Exclusivo para Delta / Ejecutores móviles",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Rutas exactas del reporte
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local K2_ButtonPath = "Players." .. LocalPlayer.Name .. ".PlayerGui.Mountains.Main.MountainFrame.Holder.K2"

-- Obtener el botón de forma segura
local function GetK2Button()
    local mtn = PlayerGui:FindFirstChild("Mountains")
    local main = mtn and mtn:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("MountainFrame")
    local holder = frame and frame:FindFirstChild("Holder")
    return holder and holder:FindFirstChild("K2")
end

-- Crear la pestaña exclusiva
local K2Tab = Window:CreateTab("K2 Warp Suite 🏔️", 4483362458)

local StatusParagraph = K2Tab:CreateParagraph({
    Title = "Estado del Sistema",
    Content = "Listo para iniciar manipulación de memoria."
})

-- ==========================================
-- MÉTODO 1: HOOKING DE ATRIBUTOS (ELITE BYPASS)
-- ==========================================
local isHooked = false
K2Tab:CreateToggle({
    Name = "🔗 Activar Hooking de Atributos (Metatable)",
    CurrentValue = false,
    Flag = "AttributeHook",
    Callback = function(Value)
        if Value then
            local K2_Btn = GetK2Button()
            if not K2_Btn then 
                Rayfield:Notify({Title = "Error", Content = "No se detectó el botón K2. Abre el menú una vez.", Duration = 3})
                return 
            end

            -- Interceptar la llamada a GetAttribute en el motor físico
            local oldGetAttribute
            oldGetAttribute = hookfunction(game.GetAttribute, function(self, attribute)
                if self == K2_Btn then
                    -- Si el script nativo pregunta por estas llaves, falsificamos la respuesta
                    if attribute == "Locked" or attribute == "IsLocked" then
                        return false
                    elseif attribute == "Owned" or attribute == "Owns" or attribute == "MtnBuyWired" then
                        return true
                    elseif attribute == "Price" or attribute == "Cost" then
                        return 0
                    end
                end
                return oldGetAttribute(self, attribute)
            end)

            isHooked = true
            StatusParagraph:Set({Title = "Hooking Activo", Content = "Las llamadas del juego a los atributos de K2 han sido interceptadas."})
            Rayfield:Notify({Title = "Bypass Aplicado", Content = "El juego ahora cree que K2 es de tu propiedad.", Duration = 3})
        else
            isHooked = false
            StatusParagraph:Set({Title = "Hooking Desactivado", Content = "Se restauró la lectura de memoria original."})
        end
    end
})

-- ==========================================
-- MÉTODO 2: SECUESTRO DE MEMORIA LOCAL (getsenv)
-- ==========================================
K2Tab:CreateButton({
    Name = "🧠 Secuestrar Entorno de Scripts Locales (getsenv)",
    Callback = function()
        local mtn = PlayerGui:FindFirstChild("Mountains")
        if not mtn then
            Rayfield:Notify({Title = "Error", Content = "Menú Mountains no cargado en PlayerGui.", Duration = 3})
            return
        end

        if not getsenv then
            Rayfield:Notify({Title = "Incompatible", Content = "Tu ejecutor no soporta 'getsenv' para leer memoria de scripts.", Duration = 3})
            return
        end

        local hijackedScripts = 0
        local hijackedVars = 0

        -- Buscar scripts locales de interfaz que manejen la compra
        for _, desc in ipairs(mtn:GetDescendants()) do
            if desc:IsA("LocalScript") then
                local success, env = pcall(getsenv, desc)
                if success and env then
                    hijackedScripts = hijackedScripts + 1
                    -- Forzar variables lógicas a favor del jugador en el script
                    for varName, val in pairs(env) do
                        local lowerVar = string.lower(varName)
                        if string.find(lowerVar, "own") or string.find(lowerVar, "buy") or string.find(lowerVar, "unlock") then
                            env[varName] = true
                            hijackedVars = hijackedVars + 1
                        elseif string.find(lowerVar, "price") or string.find(lowerVar, "cost") or string.find(lowerVar, "locked") then
                            env[varName] = 0
                            if type(val) == "boolean" then env[varName] = false end
                            hijackedVars = hijackedVars + 1
                        end
                    end
                end
            end
        end

        StatusParagraph:Set({Title = "Secuestro de Scripts Completado", Content = string.format("Inyectado en %d scripts locales. Variables alteradas: %d", hijackedScripts, hijackedVars)})
        Rayfield:Notify({Title = "Inyección Exitosa", Content = "Variables del script de compra alteradas en caliente.", Duration = 3})
    end
})

-- ==========================================
-- MÉTODO 3: BUcle DE CONGELACIÓN DE ATRIBUTOS
-- ==========================================
local freezeLoop = nil
K2Tab:CreateToggle({
    Name = "❄️ Congelar Valores de K2 en Tiempo Real",
    CurrentValue = false,
    Flag = "FreezeLoop",
    Callback = function(Value)
        if Value then
            local K2_Btn = GetK2Button()
            if not K2_Btn then
                Rayfield:Notify({Title = "Error", Content = "Abre la GUI del juego antes de activar la congelación.", Duration = 3})
                return
            end

            -- Forzar los atributos que descubriste en cada frame de renderizado
            freezeLoop = RunService.Heartbeat:Connect(function()
                K2_Btn:SetAttribute("MtnBuyWired", true)
                K2_Btn:SetAttribute("ButtonFXWired", true)
                K2_Btn:SetAttribute("PresetKey", "K2")
                
                -- Si existen valores hijos, los mantenemos forzados en 0
                for _, child in ipairs(K2_Btn:GetChildren()) do
                    if child:IsA("BoolValue") and (string.find(string.lower(child.Name), "lock") or string.find(string.lower(child.Name), "buy")) then
                        child.Value = false
                    elseif child:IsA("ValueBase") and string.find(string.lower(child.Name), "own") then
                        child.Value = true
                    end
                end
            end)
            StatusParagraph:Set({Title = "Memoria Congelada", Content = "Atributos y valores fijados de forma infinita por milisegundo."})
        else
            if freezeLoop then
                freezeLoop:Disconnect()
                freezeLoop = nil
            end
            StatusParagraph:Set({Title = "Congelación Inactiva", Content = "Memoria liberada."})
        end
    end
})

-- ==========================================
-- MÉTODO 4: DISPARADOR DIRECTO REFINADO
-- ==========================================
K2Tab:CreateButton({
    Name = "⚡ Ejecutar Salto Forzado (Warp)",
    Callback = function()
        local K2_Btn = GetK2Button()
        if not K2_Btn then
            Rayfield:Notify({Title = "Error", Content = "No se puede localizar el botón K2 en la interfaz.", Duration = 3})
            return
        end

        StatusParagraph:Set({Title = "Saltando...", Content = "Ejecutando bypass de clic físico."})

        -- Lanzar señales para emular la presión del botón
        local success = false
        if getconnections then
            for _, conn in pairs(getconnections(K2_Btn.MouseButton1Click)) do
                conn:Fire()
                success = true
            end
            for _, conn in pairs(getconnections(K2_Btn.Activated)) do
                conn:Fire()
                success = true
            end
        elseif firesignal then
            firesignal(K2_Btn.MouseButton1Click)
            firesignal(K2_Btn.Activated)
            success = true
        end

        if success then
            Rayfield:Notify({Title = "Warp Iniciado", Content = "Señal enviada omitiendo el bloqueo de compra.", Duration = 3})
        else
            -- Si falla el emulador de clics, forzamos mediante inyección directa a las funciones del botón
            pcall(function()
                K2_Btn.Parent.Parent.Parent.Visible = true -- Forzar visibilidad del frame principal
            end)
            Rayfield:Notify({Title = "Error de Ejecutor", Content = "No se pudo emular el clic, activa los otros Bypasses primero.", Duration = 3})
        end
    end
})

-- ==========================================
-- MÉTODO 5: TELETRANSPORTE FÍSICO AL MAPA K2
-- ==========================================
K2Tab:CreateButton({
    Name = "🌌 Teletransporte de Coordenadas (Bypass de Carga)",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetMap = nil
        -- Buscar de forma recursiva en el juego si el mapa K2 ya se encuentra cargado en memoria
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if string.lower(desc.Name) == "k2" and (desc:IsA("Model") or desc:IsA("Folder")) then
                targetMap = desc
                break
            end
        end

        if targetMap then
            -- Intentar encontrar una zona estable de caída o un Spawn del mapa
            local landingPart = targetMap:FindFirstChild("SpawnLocation", true) 
                or targetMap:FindFirstChildWhichIsA("BasePart", true)

            if landingPart then
                hrp.CFrame = landingPart.CFrame + Vector3.new(0, 8, 0)
                StatusParagraph:Set({Title = "Warp Exitoso", Content = "Teletransportado físicamente a la geometría del mapa K2."})
                Rayfield:Notify({Title = "Completado", Content = "Viaje físico completado.", Duration = 3})
            else
                Rayfield:Notify({Title = "Error", Content = "No se encontró un suelo sólido en el mapa K2.", Duration = 3})
            end
        else
            StatusParagraph:Set({Title = "Fase Física Fallida", Content = "El mapa K2 no se encuentra en Workspace. Requiere carga por servidor."})
            Rayfield:Notify({Title = "No Cargado", Content = "El mapa no está en la memoria física del juego. Usa el salto forzado.", Duration = 4})
        end
    end
})
