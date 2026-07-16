-- ==================================================
-- [ ALB8RAAQ ] - K2 BYPASS, TIME GLITCH & DUMPER
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local DumpData = {}
local function LogData(text)
    table.insert(DumpData, text)
    print(text)
end

LogData("🎒 === REPORTE PROFUNDO: MAPA K2 === 🎒\n")

-- ==========================================
-- 1. EXTRACCIÓN Y BÚSQUEDA RECURSIVA
-- ==========================================
local function ScanAndDump()
    LogData("--- BÚSQUEDA EN INTERFAZ (PlayerGui) ---")
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        for _, desc in ipairs(gui:GetDescendants()) do
            if string.lower(desc.Name) == "k2" or string.find(string.lower(desc.Name), "k2") then
                LogData(string.format("Encontrado en GUI: %s (%s)", desc.Name, desc.ClassName))
                LogData("  Ruta: " .. desc:GetFullName())
                -- Extraer Atributos
                for attr, val in pairs(desc:GetAttributes()) do
                    LogData(string.format("  [Atributo] %s = %s", tostring(attr), tostring(val)))
                end
                -- Extraer Valores Hijos
                for _, child in ipairs(desc:GetChildren()) do
                    if child:IsA("ValueBase") or string.find(child.ClassName, "Value") then
                        LogData(string.format("  [Valor Interno] %s = %s", child.Name, tostring(child.Value)))
                    end
                end
            end
        end
    end

    LogData("\n--- BÚSQUEDA FÍSICA (Workspace) ---")
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if string.lower(desc.Name) == "k2" then
            LogData(string.format("Encontrado en Mundo: %s (%s) | Ruta: %s", desc.Name, desc.ClassName, desc:GetFullName()))
        end
    end

    LogData("\n--- BÚSQUEDA DE RED (ReplicatedStorage) ---")
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if string.find(string.lower(desc.Name), "k2") then
            LogData(string.format("Encontrado en Servidor: %s (%s) | Ruta: %s", desc.Name, desc.ClassName, desc:GetFullName()))
        end
    end

    -- Copiar todo al portapapeles
    if setclipboard then
        setclipboard(table.concat(DumpData, "\n"))
        print("[ALB8RAAQ] ✅ Datos de K2 copiados al portapapeles.")
    end
end

-- ==========================================
-- 2. GLITCH DE PROPIEDAD Y TIEMPO (SPOOFING)
-- ==========================================
local function SpoofAndGlitch()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    local MountainsUI = PlayerGui:FindFirstChild("Mountains")
    if not MountainsUI then return end

    print("[ALB8RAAQ] Iniciando inyección de Bypass (Spoofing)...")

    local modifiedValues = 0
    local timersHacked = 0

    for _, desc in ipairs(MountainsUI:GetDescendants()) do
        -- A) Manipulación de Propiedad (Bypass de Compra)
        if desc:IsA("BoolValue") then
            local lowerName = string.lower(desc.Name)
            if string.find(lowerName, "own") or string.find(lowerName, "buy") or string.find(lowerName, "unlocked") then
                desc.Value = true -- Engañar diciendo que ya lo compramos
                modifiedValues = modifiedValues + 1
            elseif string.find(lowerName, "lock") then
                desc.Value = false -- Quitar el candado
                modifiedValues = modifiedValues + 1
            end
        end

        if desc:IsA("NumberValue") or desc:IsA("IntValue") then
            local lowerName = string.lower(desc.Name)
            -- B) Manipulación de Precios
            if string.find(lowerName, "price") or string.find(lowerName, "cost") then
                desc.Value = 0
                modifiedValues = modifiedValues + 1
            end
            -- C) Aceleración de Tiempos/Rotaciones de mapas
            if string.find(lowerName, "time") or string.find(lowerName, "count") or string.find(lowerName, "wait") then
                desc.Value = 0 -- Forzar el tiempo a 0 para que el mapa aparezca o esté disponible de inmediato
                timersHacked = timersHacked + 1
            end
        end
    end

    print(string.format("[ALB8RAAQ] Bypasses de propiedad aplicados: %d", modifiedValues))
    print(string.format("[ALB8RAAQ] Tiempos/Cooldowns acelerados: %d", timersHacked))

    -- Intentar presionar K2 después de engañar al juego
    local K2_Btn = MountainsUI:FindFirstChild("Main")
        and MountainsUI.Main:FindFirstChild("MountainFrame")
        and MountainsUI.Main.MountainFrame:FindFirstChild("Holder")
        and MountainsUI.Main.MountainFrame.Holder:FindFirstChild("K2")

    if K2_Btn then
        print("[ALB8RAAQ] Re-enviando señal de viaje a K2 con el bypass activo...")
        if getconnections then
            for _, conn in pairs(getconnections(K2_Btn.MouseButton1Click)) do conn:Fire() end
        elseif firesignal then
            firesignal(K2_Btn.MouseButton1Click)
        end
    end
end

-- ==========================================
-- EJECUCIÓN
-- ==========================================
ScanAndDump()
task.wait(0.5) -- Pequeña pausa para asegurar la memoria
SpoofAndGlitch()
