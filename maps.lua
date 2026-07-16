-- ==================================================
-- [ ALB8RAAQ ] - PRECISION GROUND IMPACT WARPER
-- ==================================================

-- (Mantén la estructura anterior de Rayfield, aquí la lógica refinada)

local function GroundImpactWarp(targetPart)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    StatusLabel:Set("Estado: Buscando suelo real...")

    -- 1. Forzar carga de la región específica
    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPart.Position) end)
    task.wait(0.5)

    -- 2. RAYCASTING DE PRECISIÓN: Lanza un rayo hacia abajo desde un punto alto
    -- Esto garantiza que aterrices sobre la malla real de la cueva y no en coordenadas vacías.
    local rayOrigin = targetPart.Position + Vector3.new(0, 50, 0) -- Comienza 50 studs arriba
    local rayDirection = Vector3.new(0, -100, 0) -- Busca 100 studs hacia abajo
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {targetPart.Parent} -- Solo buscamos el mapa destino
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    local finalPosition
    if raycastResult then
        -- Aterriza exactamente 3 studs sobre el punto de impacto detectado
        finalPosition = raycastResult.Position + Vector3.new(0, 3, 0)
    else
        -- Fallback: Si el rayo falla (cueva muy oculta), usa el centro del bloque
        finalPosition = targetPart.Position + Vector3.new(0, 5, 0)
    end

    -- 3. MOVIMIENTO BLOQUEADO (Anti-Caída)
    hrp.Anchored = true
    hrp.CFrame = CFrame.new(finalPosition)
    
    -- 4. ESPERA DE ESTABILIZACIÓN FÍSICA
    task.wait(0.8) 
    hrp.Anchored = false
    
    StatusLabel:Set("Estado: Aterrizaje preciso logrado.")
    Rayfield:Notify({Title = "Precisión Real", Content = "Aterrizaste en la geometría sólida de la cueva.", Duration = 3})
end

-- Reemplaza el botón de viaje anterior en el script con este nuevo método:
ZoneTab:CreateButton({
    Name = "🎯 VIAJE DE IMPACTO PRECISO (Raycast)",
    Callback = function()
        if SelectedZoneName and FoundZones[SelectedZoneName] then
            GroundImpactWarp(FoundZones[SelectedZoneName])
        else
            Rayfield:Notify({Title = "Error", Content = "Selecciona zona primero.", Duration = 2})
        end
    end
})
