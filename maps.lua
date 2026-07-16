-- ==================================================
-- [ ALB8RAAQ ] - CAVEZONES ARCHITECTURE SCANNER
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: CAVEZONES",
   LoadingTitle = "Analizando ADN de CaveZones...",
   LoadingSubtitle = "Indexando mapas hermanos y atributos",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CaveTab = Window:CreateTab("CaveZones Scanner 🦇", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local StatusLabel = CaveTab:CreateLabel("Estado: Esperando escaneo...")

-- Variables para almacenar los mapas descubiertos
local DiscoveredSiblings = {}
local SiblingTargets = {} -- Guarda las referencias a los objetos para poder viajar a ellos

-- ==========================================
-- MOTOR DE EXTRACCIÓN Y PARENTESCO
-- ==========================================
local function ExtractData(obj, dumpTable, prefix)
    table.insert(dumpTable, prefix .. "Nombre: " .. obj.Name .. " | Clase: " .. obj.ClassName)
    table.insert(dumpTable, prefix .. "Ruta: " .. obj:GetFullName())
    
    -- Extraer atributos
    local attrs = obj:GetAttributes()
    local hasAttrs = false
    for k, v in pairs(attrs) do
        table.insert(dumpTable, prefix .. "  [Atributo] " .. tostring(k) .. " = " .. tostring(v))
        hasAttrs = true
    end
    if not hasAttrs then table.insert(dumpTable, prefix .. "  (Sin atributos)") end

    -- Extraer Valores internos (ValueBases)
    local hasValues = false
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("ValueBase") or string.find(child.ClassName, "Value") then
            table.insert(dumpTable, prefix .. "  [Valor Interno] " .. child.Name .. " = " .. tostring(child.Value))
            hasValues = true
        end
    end
    if not hasValues then table.insert(dumpTable, prefix .. "  (Sin valores internos)") end
end

local function DeepCaveScan()
    local DumpData = {"🎒 === ALB8RAAQ REPORTE: CAVEZONES Y SUS HERMANOS === 🎒\n"}
    DiscoveredSiblings = {}
    SiblingTargets = {}
    
    local searchAreas = {
        {Name = "INTERFAZ (PlayerGui)", Area = PlayerGui},
        {Name = "MUNDO FÍSICO (Workspace)", Area = Workspace},
        {Name = "SERVIDOR (ReplicatedStorage)", Area = ReplicatedStorage}
    }

    local foundCaveZones = false

    for _, area in ipairs(searchAreas) do
        table.insert(DumpData, "\n--- BUSCANDO EN " .. area.Name .. " ---")
        
        for _, obj in ipairs(area.Area:GetDescendants()) do
            -- Buscar coincidencia exacta o muy cercana a CaveZones
            if string.lower(obj.Name) == "cavezones" or string.find(string.lower(obj.Name), "cavezone") then
                foundCaveZones = true
                table.insert(DumpData, "\n[🎯 OBJETIVO ENCONTRADO]")
                ExtractData(obj, DumpData, "")
                
                -- EL SECRETO: Buscar mapas "hermanos" (siguientes zonas) en la misma carpeta/interfaz
                local parent = obj.Parent
                if parent then
                    table.insert(DumpData, "\n  [📦 EXPLORANDO CONTENEDOR HERMANOS: " .. parent.Name .. "]")
                    for _, sibling in ipairs(parent:GetChildren()) do
                        if sibling ~= obj then
                            -- Filtramos para no añadir scripts basura, solo objetos similares al objetivo
                            if sibling.ClassName == obj.ClassName or sibling:IsA("Model") or sibling:IsA("GuiButton") or sibling:IsA("Folder") then
                                table.insert(DumpData, "\n    [🗺️ POSIBLE SIGUIENTE MAPA: " .. sibling.Name .. "]")
                                ExtractData(sibling, DumpData, "    ")
                                
                                -- Añadir a nuestra lista dinámica para el menú desplegable
                                table.insert(DiscoveredSiblings, sibling.Name)
                                SiblingTargets[sibling.Name] = sibling
                            end
                        end
                    end
                end
            end
        end
    end

    if not foundCaveZones then
        table.insert(DumpData, "❌ No se encontró 'CaveZones' en el juego en este momento.")
    end

    -- Copiar al portapapeles
    if setclipboard then
        setclipboard(table.concat(DumpData, "\n"))
        Rayfield:Notify({Title = "Escaneo Completado", Content = "ADN de CaveZones y mapas hermanos copiado al portapapeles.", Duration = 4})
    else
        print(table.concat(DumpData, "\n"))
    end

    return foundCaveZones
end

-- ==========================================
-- INTERFAZ Y CONTROLES
-- ==========================================

CaveTab:CreateButton({
    Name = "🔍 Escanear 'CaveZones' y extraer Siguientes Mapas",
    Callback = function()
        StatusLabel:Set("Estado: Escaneando rutas y atributos...")
        local success = DeepCaveScan()
        
        if success then
            StatusLabel:Set("Estado: ¡CaveZones analizado con éxito!")
            -- Actualizar el menú desplegable con los mapas hermanos encontrados
            if #DiscoveredSiblings > 0 then
                _G.SiblingDropdown:Refresh(DiscoveredSiblings, true)
                Rayfield:Notify({Title = "Mapas Siguientes Detectados", Content = "Se encontraron " .. tostring(#DiscoveredSiblings) .. " posibles destinos nuevos.", Duration = 4})
            else
                Rayfield:Notify({Title = "Aviso", Content = "Se analizó CaveZones, pero no se encontraron mapas agrupados junto a él.", Duration = 4})
            end
        else
            StatusLabel:Set("Estado: No se detectó CaveZones.")
        end
    end
})

-- Botón para viajar directamente al CaveZones (ya que sabemos que funciona)
CaveTab:CreateButton({
    Name = "⚡ Viaje Rápido Directo: CAVEZONES",
    Callback = function()
        local success = false
        -- Intentar por Interfaz primero
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if string.lower(obj.Name) == "cavezones" and obj:IsA("GuiButton") then
                if getconnections then
                    for _, conn in pairs(getconnections(obj.MouseButton1Click)) do conn:Fire(); success = true end
                elseif firesignal then
                    firesignal(obj.MouseButton1Click); success = true
                end
            end
        end
        
        if not success then
            Rayfield:Notify({Title = "Aviso", Content = "No se pudo disparar el botón de CaveZones automáticamente.", Duration = 3})
        end
    end
})

-- ==========================================
-- MENÚ DINÁMICO DE MAPAS SIGUIENTES
-- ==========================================
CaveTab:CreateLabel("--- VIAJE A MAPAS HERMANOS ---")

local selectedSibling = nil

_G.SiblingDropdown = CaveTab:CreateDropdown({
    Name = "Seleccionar Siguiente Mapa (Hermano)",
    Options = {"Escanea primero..."},
    CurrentOption = {"Escanea primero..."},
    MultipleOptions = false,
    Flag = "SiblingDropdown",
    Callback = function(Option)
        selectedSibling = Option[1]
    end,
})

CaveTab:CreateButton({
    Name = "🚀 Forzar Viaje al Mapa Seleccionado",
    Callback = function()
        if not selectedSibling or selectedSibling == "Escanea primero..." then
            Rayfield:Notify({Title = "Error", Content = "Selecciona un mapa de la lista primero.", Duration = 3})
            return
        end

        local targetObj = SiblingTargets[selectedSibling]
        if not targetObj then return end

        StatusLabel:Set("Estado: Forzando viaje a " .. selectedSibling)

        -- 1. Si es un botón de interfaz (UI)
        if targetObj:IsA("GuiButton") then
            local fired = false
            if getconnections then
                for _, conn in pairs(getconnections(targetObj.MouseButton1Click)) do conn:Fire(); fired = true end
            elseif firesignal then
                firesignal(targetObj.MouseButton1Click); fired = true
            end
            if fired then Rayfield:Notify({Title = "Warp Iniciado", Content = "Señal de interfaz enviada a " .. selectedSibling, Duration = 3}) end

        -- 2. Si es un mapa físico (Workspace)
        elseif targetObj:IsA("Model") or targetObj:IsA("Folder") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local spawnPoint = targetObj:FindFirstChild("SpawnLocation", true) or targetObj:FindFirstChildWhichIsA("BasePart", true)
            
            if hrp and spawnPoint then
                hrp.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
                Rayfield:Notify({Title = "Teletransporte", Content = "Viaje físico completado a " .. selectedSibling, Duration = 3})
            else
                Rayfield:Notify({Title = "Fallo Físico", Content = "No se encontró un suelo sólido en ese mapa.", Duration = 3})
            end
        end
    end
})
