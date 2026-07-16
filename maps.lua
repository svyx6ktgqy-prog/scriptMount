-- ==================================================
-- [ ALB8RAAQ ] - RECURSIVE K2 DEEP WARP & SCANNER
-- ==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("=========================================")
print("  INICIANDO PROTOCOLO ALB8RAAQ K2-WARP   ")
print("=========================================")

-- VECTO 1: Búsqueda Física y Teletransporte (CFrame)
local function TryPhysicalTeleport()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    print("[ALB8RAAQ] Fase 1: Escaneando Workspace por el mapa físico K2...")
    local k2_map = nil
    
    -- Búsqueda recursiva en el mapa
    for _, desc in ipairs(Workspace:GetDescendants()) do
        -- Si encontramos un modelo o carpeta que se llame exactamente K2
        if string.lower(desc.Name) == "k2" and (desc:IsA("Model") or desc:IsA("Folder")) then
            k2_map = desc
            break
        end
    end

    if k2_map then
        print("[ALB8RAAQ] ¡Mapa K2 encontrado en el mundo físico! Ruta: " .. k2_map:GetFullName())
        -- Buscar un lugar seguro para aterrizar
        local targetPart = k2_map:FindFirstChild("SpawnLocation", true) or k2_map:FindFirstChildWhichIsA("BasePart", true)
        
        if targetPart then
            -- Teletransportar forzadamente al jugador
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            print("[ALB8RAAQ] ✅ Viaje físico completado.")
            return true
        end
    end
    print("[ALB8RAAQ] Fase 1 Fallida: El mapa K2 no está cargado físicamente en el Workspace.")
    return false
end

-- VECTOR 2: Análisis Recursivo de la Interfaz y Fuerza Bruta Avanzada
local function DeepAnalyzeAndForceButton()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    local K2_Btn = PlayerGui:FindFirstChild("Mountains")
        and PlayerGui.Mountains:FindFirstChild("Main")
        and PlayerGui.Mountains.Main:FindFirstChild("MountainFrame")
        and PlayerGui.Mountains.Main.MountainFrame:FindFirstChild("Holder")
        and PlayerGui.Mountains.Main.MountainFrame.Holder:FindFirstChild("K2")

    if not K2_Btn then
        warn("[ALB8RAAQ] Fase 2 Fallida: La UI Mountains/K2 no está cargada actualmente en el PlayerGui.")
        return
    end

    print("\n[ALB8RAAQ] Fase 2: Analizando propiedades y valores ocultos de K2...")
    
    -- 2.1 Extraer Atributos
    for attr, val in pairs(K2_Btn:GetAttributes()) do
        print(string.format("   [Atributo] %s = %s", tostring(attr), tostring(val)))
    end

    -- 2.2 Extraer Valores Hijos (ValueBases)
    for _, child in ipairs(K2_Btn:GetChildren()) do
        if child:IsA("ValueBase") or string.find(child.ClassName, "Value") then
            print(string.format("   [Valor Interno] %s (%s) = %s", child.Name, child.ClassName, tostring(child.Value)))
        elseif child:IsA("LocalScript") then
            print(string.format("   [Script Detectado] %s - El viaje es procesado por este script.", child.Name))
        end
    end

    -- 2.3 Fuerza Bruta de Múltiples Señales (No solo Click)
    print("\n[ALB8RAAQ] Ejecutando ataque de sobrecarga de señales a K2...")
    local signalsToFire = {"MouseButton1Click", "MouseButton1Down", "Activated", "InputBegan", "SelectionGained"}
    local successCount = 0

    for _, sigName in ipairs(signalsToFire) do
        local ok, err = pcall(function()
            if K2_Btn[sigName] then
                if getconnections then
                    for _, conn in pairs(getconnections(K2_Btn[sigName])) do
                        conn:Fire()
                        successCount = successCount + 1
                    end
                elseif firesignal then
                    firesignal(K2_Btn[sigName])
                    successCount = successCount + 1
                end
            end
        end)
    end
    print(string.format("[ALB8RAAQ] Señales enviadas a la interfaz: %d", successCount))
end

-- VECTOR 3: Rastreo de Red (RemoteEvents) en ReplicatedStorage
local function SearchAndFireRemotes()
    print("\n[ALB8RAAQ] Fase 3: Escaneando RemoteEvents de viaje...")
    local keywords = {"teleport", "travel", "warp", "load", "map", "mountain", "k2"}
    local fired = 0

    for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
        if item:IsA("RemoteEvent") then
            local lowerName = string.lower(item.Name)
            for _, word in ipairs(keywords) do
                if string.find(lowerName, word) then
                    print("   [Inyectando Network] Disparando -> " .. item:GetFullName())
                    -- Disparamos el evento con diferentes variaciones lógicas que el servidor podría esperar
                    pcall(function() item:FireServer("K2") end)
                    pcall(function() item:FireServer("Mountains", "K2") end)
                    pcall(function() item:FireServer(item.Name, "K2") end)
                    fired = fired + 1
                    break -- Evitar disparar el mismo remote múltiples veces por diferentes palabras clave
                end
            end
        end
    end
    print(string.format("[ALB8RAAQ] Eventos de red manipulados: %d", fired))
end

-- Ejecución secuencial de los vectores
local phySuccess = TryPhysicalTeleport()
if not phySuccess then
    DeepAnalyzeAndForceButton()
    SearchAndFireRemotes()
end

print("=========================================")
print("  REVISAR CONSOLA (F9) PARA RESULTADOS   ")
print("=========================================")
