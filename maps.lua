-- ==================================================
-- [ ALB8RAAQ ] - SAFE ZONE ESP GUIDE
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: ZONE ESP GUIDE",
   LoadingTitle = "Iniciando Escáner de Zonas...",
   LoadingSubtitle = "Sistema de Rastreo Visual Activado",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local ZoneTab = Window:CreateTab("Rastreador ESP 📍", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Estado: Listo para escanear el mundo.")

-- Variables para almacenar los objetos ESP actuales
local CurrentESP = {
    Beam = nil,
    AtchPlayer = nil,
    AtchTarget = nil,
    Highlight = nil,
    Billboard = nil
}

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
            
            -- Extraer el bloque físico que servirá como ancla para el ESP
            if obj:IsA("BasePart") then
                targetPart = obj
            elseif obj:IsA("Model") or obj:IsA("Folder") then
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
    
    -- Ordenar alfabéticamente
    table.sort(ZoneNames)
    
    return count
end

-- ==========================================
-- PROTOCOLO DE GUÍA ESP VISUAL
-- ==========================================
local function ClearESP()
    for key, instance in pairs(CurrentESP) do
        if instance and instance.Parent then
            instance:Destroy()
        end
        CurrentESP[key] = nil
    end
end

local function ActivateESP(targetPart, zoneName)
    ClearESP() -- Limpiar cualquier ESP activo previamente

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetPart then 
        Rayfield:Notify({Title = "Error", Content = "No se pudo encontrar el personaje o el destino.", Duration = 3})
        return 
    end

    StatusLabel:Set("Estado: Trazando ruta hacia la zona...")

    -- 1. Resaltador (Ver a través de las paredes)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = targetPart
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = targetPart
    CurrentESP.Highlight = highlight

    -- 2. Línea Guía (Beam)
    local atchPlayer = Instance.new("Attachment")
    atchPlayer.Parent = hrp
    CurrentESP.AtchPlayer = atchPlayer

    local atchTarget = Instance.new("Attachment")
    atchTarget.Parent = targetPart
    CurrentESP.AtchTarget = atchTarget

    local beam = Instance.new("Beam")
    beam.Attachment0 = atchPlayer
    beam.Attachment1 = atchTarget
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
    beam.FaceCamera = true
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = hrp
    CurrentESP.Beam = beam

    -- 3. Texto Flotante (BillboardGui)
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = targetPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "📍 " .. zoneName
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextScaled = true
    textLabel.Parent = billboard

    billboard.Parent = targetPart
    CurrentESP.Billboard = billboard
    
    StatusLabel:Set("Estado: Guía visual activa. Sigue la línea.")
    Rayfield:Notify({Title = "Guía Activada", Content = "Sigue la línea rastreadora hacia " .. zoneName, Duration = 3})
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
            Rayfield:Notify({Title = "Sin resultados", Content = "No se detectaron zonas físicas.", Duration = 4})
        end
    end
})

ZoneTab:CreateLabel("--- SELECCIÓN DE OBJETIVO ---")

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
    Name = "👁️ ACTIVAR GUÍA ESP",
    Callback = function()
        if not SelectedZoneName or SelectedZoneName == "Escanea primero..." then
            Rayfield:Notify({Title = "Aviso", Content = "Selecciona una zona de la lista.", Duration = 3})
            return
        end

        local targetBlock = FoundZones[SelectedZoneName]
        if targetBlock then
            ActivateESP(targetBlock, SelectedZoneName)
        else
            Rayfield:Notify({Title = "Error", Content = "El bloque de la zona ya no existe.", Duration = 3})
        end
    end
})

ZoneTab:CreateButton({
    Name = "❌ DESACTIVAR GUÍA",
    Callback = function()
        ClearESP()
        StatusLabel:Set("Estado: Rastreador desactivado.")
        Rayfield:Notify({Title = "Desactivado", Content = "Se ha limpiado el rastreador visual de la pantalla.", Duration = 2})
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
