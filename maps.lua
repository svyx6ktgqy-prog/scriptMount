-- ==================================================
-- [ ALB8RAAQ ] - PERFECT SAFE ZONE WARPER
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: ANTI-RUBBERBAND",
   LoadingTitle = "Iniciando Motor de Teletransporte Perfecto...",
   LoadingSubtitle = "Bypass de Servidor Activado",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local ZoneTab = Window:CreateTab("Zonas Físicas 📍", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local FoundZones = {}
local ZoneNames = {}
local SelectedZoneName = nil

local StatusLabel = ZoneTab:CreateLabel("Estado: Esperando escaneo...")

-- ==========================================
-- MOTOR DE ESCANEO DE ZONAS
-- ==========================================
local function ScanForZones()
    FoundZones = {}
    ZoneNames = {}
    local count = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "zone") or string.find(nameLower, "cave") then
            local targetPart = nil
            if obj:IsA("BasePart") then
                targetPart = obj
            elseif obj:IsA("Model") or obj:IsA("Folder") then
                targetPart = obj:FindFirstChildWhichIsA("BasePart", true)
            end
            
            if targetPart and not FoundZones[obj.Name] then
                FoundZones[obj.Name] = targetPart
                table.insert(ZoneNames, obj.Name)
                count = count + 1
            end
        end
    end
    
    table.sort(ZoneNames)
    return count
end

-- ==========================================
-- MÉTODO 1: INSTANTÁNEO PERFECTO (PIVOT + STREAM)
-- ==========================================
local function PerfectInstantWarp(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return end
    StatusLabel:Set("Estado: Forzando carga del servidor...")

    local safeY = targetPart.Position.Y + (targetPart.Size.Y / 2) + 4
    local targetCFrame = CFrame.new(targetPart.Position.X, safeY, targetPart.Position.Z)

    -- 1. Obligar al servidor a cargar el mapa de destino
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position)
    end)
    task.wait(0.2) -- Breve pausa para la respuesta del servidor

    -- 2. Preparar el personaje
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    char:SetPrimaryPartCFrame(targetCFrame) -- Compatibilidad legacy
    char:PivotTo(targetCFrame) -- Nuevo método de ensamblaje de Roblox

    -- 3. Consolidación de memoria
    task.wait(0.5)
    hrp.Anchored = false
    
    StatusLabel:Set("Estado: Viaje Instantáneo Completado.")
end

-- ==========================================
-- MÉTODO 2: BYPASS DE MAGNITUD (TWEENING)
-- ==========================================
local function TweenBypassWarp(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return end
    StatusLabel:Set("Estado: Calculando ruta de vuelo (Bypass)...")

    local safeY = targetPart.Position.Y + (targetPart.Size.Y / 2) + 4
    local targetCFrame = CFrame.new(targetPart.Position.X, safeY, targetPart.Position.Z)

    -- Obligar al servidor a cargar el mapa
    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position) end)

    -- Calcular tiempo de vuelo para engañar al Anti-Cheat (Velocidad alta pero no infinita)
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 250 -- Ajusta esto si te devuelven (menor es más seguro, mayor es más rápido)
    local tweenTime = distance / speed
    if tweenTime < 0.2 then tweenTime = 0.2 end

    -- Preparar estado fantasma (Noclip temporal)
    hrp.Anchored = true
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    -- Ejecutar el vuelo
    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    StatusLabel:Set("Estado: Volando a destino... Evadiendo Anticheat.")
    tween.Completed:Wait()

    -- Restaurar físicas
    task.wait(0.2)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
    hrp.Anchored = false
    
    StatusLabel:Set("Estado: Aterrizaje Tween Completado.")
end

-- ==========================================
-- INTERFAZ DE CONTROL
-- ==========================================
ZoneTab:CreateButton({
    Name = "🔍 Escanear Zonas",
    Callback = function()
        local total = ScanForZones()
        if total > 0 then
            StatusLabel:Set("Estado: " .. tostring(total) .. " zonas listas.")
            _G.ZoneDropdown:Refresh(ZoneNames, true)
            Rayfield:Notify({Title = "Completado", Content = "Zonas mapeadas exitosamente.", Duration = 2})
        end
    end
})

_G.ZoneDropdown = ZoneTab:CreateDropdown({
    Name = "📍 Seleccionar Zona Destino",
    Options = {"Escanea primero..."},
    CurrentOption = {"Escanea primero..."},
    MultipleOptions = false,
    Flag = "ZoneSelector",
    Callback = function(Option) SelectedZoneName = Option[1] end,
})

ZoneTab:CreateLabel("--- MÉTODOS DE VIAJE ---")

ZoneTab:CreateButton({
    Name = "🚀 VIAJE INSTANTÁNEO (Método PivotTo)",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] then
            PerfectInstantWarp(FoundZones[SelectedZoneName])
        else
            Rayfield:Notify({Title = "Error", Content = "Selecciona una zona válida.", Duration = 2})
        end
    end
})

ZoneTab:CreateButton({
    Name = "🛸 VIAJE ANTICHEAT (Método Tween / Vuelo Rápido)",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] then
            TweenBypassWarp(FoundZones[SelectedZoneName])
        else
            Rayfield:Notify({Title = "Error", Content = "Selecciona una zona válida.", Duration = 2})
        end
    end
})
