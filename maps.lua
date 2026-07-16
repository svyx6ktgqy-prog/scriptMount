-- ==================================================
-- [ ALB8RAAQ ] - PERFECT SAFE ZONE WARPER (PRECISION)
-- ==================================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ: ANTI-RUBBERBAND",
   LoadingTitle = "Iniciando Motor de Teletransporte Perfecto...",
   LoadingSubtitle = "Protección Anti-Rubberband y Precisión activada",
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
-- MÉTODO 3: RAYCAST DE PRECISIÓN (SOLUCIÓN FINAL)
-- ==========================================
local function GroundImpactWarp(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    StatusLabel:Set("Estado: Buscando suelo real en la cueva...")

    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPart.Position) end)
    task.wait(0.5)

    -- Lanzar rayo hacia abajo para detectar el suelo real
    local rayOrigin = targetPart.Position + Vector3.new(0, 50, 0)
    local rayDirection = Vector3.new(0, -150, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {targetPart.Parent, Workspace}
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local finalPosition = raycastResult and (raycastResult.Position + Vector3.new(0, 3, 0)) or (targetPart.Position + Vector3.new(0, 5, 0))

    hrp.Anchored = true
    hrp.CFrame = CFrame.new(finalPosition)
    task.wait(0.8) 
    hrp.Anchored = false
    
    StatusLabel:Set("Estado: Aterrizaje preciso logrado.")
    Rayfield:Notify({Title = "Impacto Preciso", Content = "Detectada geometría sólida: Aterrizaje exitoso.", Duration = 3})
end

-- ==========================================
-- MÉTODO 2: BYPASS DE MAGNITUD (TWEENING)
-- ==========================================
local function TweenBypassWarp(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    StatusLabel:Set("Estado: Volando a destino (Bypass)...")
    local targetCFrame = CFrame.new(targetPart.Position.X, targetPart.Position.Y + 4, targetPart.Position.Z)

    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetCFrame.Position) end)

    hrp.Anchored = true
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end

    local tween = TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()

    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    hrp.Anchored = false
    StatusLabel:Set("Estado: Aterrizaje Tween completado.")
end

-- ==========================================
-- INTERFAZ
-- ==========================================
ZoneTab:CreateButton({
    Name = "🔍 Escanear Zonas",
    Callback = function()
        local total = ScanForZones()
        if total > 0 then
            StatusLabel:Set("Estado: " .. tostring(total) .. " zonas detectadas.")
            _G.ZoneDropdown:Refresh(ZoneNames, true)
            Rayfield:Notify({Title = "Escaneo", Content = "Zonas mapeadas.", Duration = 2})
        end
    end
})

_G.ZoneDropdown = ZoneTab:CreateDropdown({
    Name = "📍 Seleccionar Zona",
    Options = {"Escanea primero..."},
    CurrentOption = {"Escanea primero..."},
    Callback = function(Option) SelectedZoneName = Option[1] end,
})

ZoneTab:CreateLabel("--- MÉTODOS DE VIAJE ---")

ZoneTab:CreateButton({
    Name = "🎯 VIAJE DE IMPACTO PRECISO (Recomendado)",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] then
            GroundImpactWarp(FoundZones[SelectedZoneName])
        end
    end
})

ZoneTab:CreateButton({
    Name = "🛸 VIAJE ANTICHEAT (Método Tween)",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] then
            TweenBypassWarp(FoundZones[SelectedZoneName])
        end
    end
})
