-- ==================================================
-- [ ALB8RAAQ ] - SAFE ZONE WARPER (PHYSICAL MAP)
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: SAFE ZONE WARPER",
   LoadingTitle = "Iniciando Escáner de Zonas...",
   LoadingSubtitle = "Protección Anti-Rubberband Activada",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local ZoneTab = Window:CreateTab("Zonas Físicas 📍", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Estado: Listo para escanear el mundo.")

-- ==========================================
-- MOTOR DE ESCANEO DE ZONAS
-- ==========================================
local function ScanForZones()
    FoundZones = {}
    ZoneNames = {}
    
    local count = 0
    -- Búsqueda recursiva en todo el Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        
        -- Filtro: Que contenga "zone", "cavezone", o "cave"
        if string.find(nameLower, "zone") or string.find(nameLower, "cave") then
            
            local targetPart = nil
            
            -- Extraer el bloque físico al que podemos teletransportarnos
            if obj:IsA("BasePart") then
                targetPart = obj
            elseif obj:IsA("Model") or obj:IsA("Folder") then
                -- Si es una carpeta, buscamos la primera pieza física dentro de ella
                targetPart = obj:FindFirstChildWhichIsA("BasePart", true)
            end
            
            if targetPart then
                -- Evitar duplicados exactos en la lista
                if not FoundZones[obj.Name] then
                    FoundZones[obj.Name] = targetPart
                    table.insert(ZoneNames, obj.Name)
                    count = count + 1
                end
            end
        end
    end
    
    -- Ordenar alfabéticamente para que CaveZone_1, CaveZone_2, etc., estén en orden
    table.sort(ZoneNames)
    
    return count
end

-- ==========================================
-- PROTOCOLO DE VIAJE SEGURO (ANTI-GLITCH)
-- ==========================================
local function SafeTeleport(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetPart then 
        Rayfield:Notify({Title = "Error", Content = "No se pudo encontrar el personaje o el destino.", Duration = 3})
        return 
    end

    StatusLabel:Set("Estado: Calculando aterrizaje seguro...")

    -- 1. Calcular la superficie superior del bloque para no quedar atrapado en el suelo
    local safeY = targetPart.Position.Y + (targetPart.Size.Y / 2) + 3.5
    local safeDest = CFrame.new(targetPart.Position.X, safeY, targetPart.Position.Z)

    -- 2. Anclar al jugador y resetear físicas (Evita que el anticheat lea un salto brusco de velocidad)
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero

    -- 3. Mover al jugador
    hrp.CFrame = safeDest

    -- 4. Esperar a que el servidor renderice el chunk (el mapa a tu alrededor)
    task.wait(0.5) 

    -- 5. Liberar al jugador de forma segura en tierra firme
    hrp.Anchored = false
    
    StatusLabel:Set("Estado: Aterrizaje completado con éxito.")
    Rayfield:Notify({Title = "Warp Exitoso", Content = "Has llegado a " .. SelectedZoneName, Duration = 2})
end

-- ==========================================
-- INTERFAZ
-- ==========================================

ZoneTab:CreateButton({
    Name = "🔍 Escanear Todas las Zonas (CaveZones & Variantes)",
    Callback = function()
        StatusLabel:Set("Estado: Escaneando Workspace...")
        local total = ScanForZones()
        
        if total > 0 then
            StatusLabel:Set("Estado: Se encontraron " .. tostring(total) .. " zonas físicas.")
            _G.ZoneDropdown:Refresh(ZoneNames, true)
            Rayfield:Notify({Title = "Zonas Encontradas", Content = "Revisa el menú desplegable.", Duration = 3})
        else
            StatusLabel:Set("Estado: No se encontraron zonas físicas.")
            Rayfield:Notify({Title = "Sin resultados", Content = "No se detectaron zonas físicas. Quizás estén en otra dimensión.", Duration = 4})
        end
    end
})

ZoneTab:CreateLabel("--- SELECCIÓN DE DESTINO ---")

_G.ZoneDropdown = ZoneTab:CreateDropdown({
    Name = "📍 Seleccionar Zona",
    Options = {"Escanea primero..."},
    CurrentOption = {"Escanea primero..."},
    MultipleOptions = false,
    Flag = "ZoneSelector",
    Callback = function(Option)
        SelectedZoneName = Option[1]
    end,
})

ZoneTab:CreateButton({
    Name = "⚡ VIAJE SEGURO (Anti-Fallo / Anti-Retorno)",
    Callback = function()
        if not SelectedZoneName or SelectedZoneName == "Escanea primero..." then
            Rayfield:Notify({Title = "Aviso", Content = "Selecciona una zona de la lista.", Duration = 3})
            return
        end

        local targetBlock = FoundZones[SelectedZoneName]
        if targetBlock then
            SafeTeleport(targetBlock)
        else
            Rayfield:Notify({Title = "Error", Content = "El bloque de la zona ya no existe.", Duration = 3})
        end
    end
})

-- Copiar ruta de la zona actual (Útil para depurar)
ZoneTab:CreateButton({
    Name = "📋 Copiar ruta de la Zona Seleccionada",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] and setclipboard then
            setclipboard(FoundZones[SelectedZoneName]:GetFullName())
            Rayfield:Notify({Title = "Ruta Copiada", Content = "La ruta del bloque se copió al portapapeles.", Duration = 2})
        end
    end
})
