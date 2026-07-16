-- ==================================================
-- [ ALB8RAAQ ] - SAFE ZONE WARPER & ESP GUIDE
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
local RunService = game:GetService("RunService") -- Agregado para el cálculo en tiempo real
local LocalPlayer = Players.LocalPlayer

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Estado: Listo para escanear el mundo.")

-- ==========================================
-- VARIABLES DEL SISTEMA ESP
-- ==========================================
local isESPActive = false
local CurrentESP = {
    Beam = nil,
    AtchPlayer = nil,
    AtchTarget = nil,
    Highlight = nil,
    Billboard = nil,
    DistanceUpdater = nil -- Nuevo: Para manejar el bucle de distancia
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
-- FUNCIONES DE LA GUÍA ESP (ADICIONAL)
-- ==========================================
local function ClearESP()
    -- Detener el cálculo de distancia si existe
    if CurrentESP.DistanceUpdater then
        CurrentESP.DistanceUpdater:Disconnect()
        CurrentESP.DistanceUpdater = nil
    end

    for key, instance in pairs(CurrentESP) do
        if typeof(instance) == "Instance" and instance.Parent then
            instance:Destroy()
        end
        CurrentESP[key] = nil
    end
end

local function ActivateESP(targetPart, zoneName)
    ClearESP() -- Limpiar cualquier ESP activo previamente

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetPart then return end

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
    billboard.Size = UDim2.new(0, 200, 0, 50)
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

    -- 4. Actualizador de Distancia en Tiempo Real
    CurrentESP.DistanceUpdater = RunService.RenderStepped:Connect(function()
        -- Verificamos que el jugador y el objetivo sigan existiendo
        if hrp and hrp.Parent and targetPart and targetPart.Parent then
            -- Calcular magnitud (distancia) entre los dos puntos
            local distance = math.floor((hrp.Position - targetPart.Position).Magnitude)
            -- Actualizar el texto del cartel
            textLabel.Text = "📍 " .. zoneName .. " [" .. tostring(distance) .. "m]"
        else
            -- Si el jugador muere o la zona desaparece, apagamos el ESP para evitar errores
            ClearESP()
        end
    end)
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
        
        -- Si el ESP está activo y cambiamos de zona, actualizar la guía automáticamente
        if isESPActive and SelectedZoneName ~= "Escanea primero..." then
            local targetBlock = FoundZones[SelectedZoneName]
            if targetBlock then
                ActivateESP(targetBlock, SelectedZoneName)
            end
        end
    end,
})

-- NUEVO: INTERRUPTOR PARA ESP
ZoneTab:CreateToggle({
    Name = "👁️ Activar Guía ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        isESPActive = Value
        if isESPActive then
            if SelectedZoneName and SelectedZoneName ~= "Escanea primero..." then
                local targetBlock = FoundZones[SelectedZoneName]
                if targetBlock then
                    ActivateESP(targetBlock, SelectedZoneName)
                    Rayfield:Notify({Title = "ESP Activado", Content = "Rastreador visual hacia " .. SelectedZoneName, Duration = 2})
                end
            else
                Rayfield:Notify({Title = "Aviso", Content = "Selecciona una zona primero.", Duration = 3})
            end
        else
            ClearESP()
            Rayfield:Notify({Title = "ESP Desactivado", Content = "Rastreador visual oculto.", Duration = 2})
        end
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
