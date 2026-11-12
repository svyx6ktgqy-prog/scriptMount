-- Cargar la librería Rayfield (versión estable compatible con ejecutores móviles)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Servicios de Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Variables de estado
local SavedPosition = nil
local ClickSaveMode = false
local Waypoints = {}
local WaypointNames = {}
local SelectedWaypoint = nil
local NoclipFlyActive = false
local NoclipConnection = nil
local FlyConnection = nil

-- Crear la ventana principal de Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Delta iOS | TP, Noclip/Fly & Endpoints",
    LoadingTitle = "Cargando Interfaz...",
    LoadingSubtitle = "Compatible con Rayfield",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-------------------------------------------------------------------------
-- 1. INTERFAZ DEL BOTÓN FLOTANTE (TELETRANSPORTE RÁPIDO)
-------------------------------------------------------------------------
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "DeltaFloatingTP"
FloatingGui.ResetOnSpawn = false
FloatingGui.Parent = (gethui and gethui()) or CoreGui

local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "TPButton"
FloatingBtn.Size = UDim2.new(0, 65, 0, 65)
FloatingBtn.Position = UDim2.new(0.8, 0, 0.3, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.Text = "TP"
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 18
FloatingBtn.Visible = false 
FloatingBtn.Active = true
FloatingBtn.Draggable = true 
FloatingBtn.Parent = FloatingGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = FloatingBtn

-- Función general de teletransporte seguro
local function TeleportTo(targetCFrame)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") and targetCFrame then
        character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "No hay una posición válida o el personaje no está listo.",
            Duration = 3
        })
    end
end

FloatingBtn.MouseButton1Click:Connect(function()
    if SavedPosition then
        TeleportTo(SavedPosition)
    else
        Rayfield:Notify({
            Title = "Sin Posición",
            Content = "Primero guarda tu posición en el menú.",
            Duration = 3
        })
    end
end)

-------------------------------------------------------------------------
-- 2. INTERFAZ DEL BOTÓN FLOTANTE (ENDPOINT SELECCIONADO)
-------------------------------------------------------------------------
local EndpointGui = Instance.new("ScreenGui")
EndpointGui.Name = "DeltaEndpointGui"
EndpointGui.ResetOnSpawn = false
EndpointGui.Parent = (gethui and gethui()) or CoreGui

local EndpointBtn = Instance.new("TextButton")
EndpointBtn.Name = "EndpointButton"
EndpointBtn.Size = UDim2.new(0, 65, 0, 65)
EndpointBtn.Position = UDim2.new(0.8, 0, 0.48, 0)
EndpointBtn.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
EndpointBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
EndpointBtn.Text = "END"
EndpointBtn.Font = Enum.Font.GothamBold
EndpointBtn.TextSize = 16
EndpointBtn.Visible = false 
EndpointBtn.Active = true
EndpointBtn.Draggable = true
EndpointBtn.Parent = EndpointGui

local UICornerEnd = Instance.new("UICorner")
UICornerEnd.CornerRadius = UDim.new(1, 0)
UICornerEnd.Parent = EndpointBtn

local UIStrokeEnd = Instance.new("UIStroke")
UIStrokeEnd.Color = Color3.fromRGB(50, 255, 50)
UIStrokeEnd.Thickness = 2
UIStrokeEnd.Parent = EndpointBtn

EndpointBtn.MouseButton1Click:Connect(function()
    if SelectedWaypoint and Waypoints[SelectedWaypoint] then
        TeleportTo(Waypoints[SelectedWaypoint])
    else
        Rayfield:Notify({
            Title = "Sin Endpoint",
            Content = "Selecciona un endpoint válido de la lista en el menú.",
            Duration = 3
        })
    end
end)

-------------------------------------------------------------------------
-- 3. INTERFAZ DEL BOTÓN FLOTANTE (NOCLIP + FLY AL MANTENER)
-------------------------------------------------------------------------
local NoclipGui = Instance.new("ScreenGui")
NoclipGui.Name = "DeltaNoclipFlyGui"
NoclipGui.ResetOnSpawn = false
NoclipGui.Parent = (gethui and gethui()) or CoreGui

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Name = "NoclipFlyButton"
NoclipBtn.Size = UDim2.new(0, 65, 0, 65)
NoclipBtn.Position = UDim2.new(0.8, 0, 0.66, 0)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
NoclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
NoclipBtn.Text = "NC+FLY"
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 13
NoclipBtn.Visible = false 
NoclipBtn.Active = true
NoclipBtn.Draggable = true
NoclipBtn.Parent = NoclipGui

local UICornerNoclip = Instance.new("UICorner")
UICornerNoclip.CornerRadius = UDim.new(1, 0)
UICornerNoclip.Parent = NoclipBtn

local UIStrokeNoclip = Instance.new("UIStroke")
UIStrokeNoclip.Color = Color3.fromRGB(255, 50, 50)
UIStrokeNoclip.Thickness = 2
UIStrokeNoclip.Parent = NoclipBtn

local function StartNoclipFly()
    NoclipFlyActive = true
    
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local rootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCFrame = Camera.CFrame
                local targetVelocity = (camCFrame.RightVector * moveDir.X + camCFrame.LookVector * moveDir.Z) * 35 
                rootPart.CFrame = rootPart.CFrame + (targetVelocity * RunService.RenderStepped:Wait())
            end
        end
    end)
end

local function StopNoclipFly()
    NoclipFlyActive = false
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

NoclipBtn.MouseButton1Down:Connect(function()
    StartNoclipFly()
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
end)

NoclipBtn.MouseButton1Up:Connect(function()
    StopNoclipFly()
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
end)

NoclipBtn.MouseLeave:Connect(function()
    if NoclipFlyActive then
        StopNoclipFly()
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
    end
end)

-------------------------------------------------------------------------
-- PESTAÑA 1: TELETRANSPORTE RÁPIDO Y BOTÓN FLOTANTE
-------------------------------------------------------------------------
local MainTab = Window:CreateTab("TP Rápido", 4483362458)

MainTab:CreateSection("Posición Actual")

MainTab:CreateButton({
    Name = "Guardar Posición Actual",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = character.HumanoidRootPart.CFrame
            Rayfield:Notify({
                Title = "Posición Guardada",
                Content = "Coordenadas almacenadas correctamente.",
                Duration = 2.5
            })
        end
    end,
})

MainTab:CreateToggle({
    Name = "Mostrar Botón Flotante de TP",
    CurrentValue = false,
    Flag = "FloatingToggle",
    Callback = function(Value)
        FloatingBtn.Visible = Value
    end,
})

-------------------------------------------------------------------------
-- PESTAÑA 2: MÓDULO DE NOCLIP + FLY NATURAL
-------------------------------------------------------------------------
local NoclipTab = Window:CreateTab("Atravesar & Fly", 4483362458)

NoclipTab:CreateSection("Control de Noclip + Fly")

NoclipTab:CreateToggle({
    Name = "Mostrar Botón Flotante (NC+FLY)",
    CurrentValue = false,
    Flag = "NoclipFlyFloatingToggle",
    Callback = function(Value)
        NoclipBtn.Visible = Value
        if not Value then
            StopNoclipFly()
        end
    end,
})

NoclipTab:CreateParagraph({
    Title = "Modo de Uso Seguro (NC+FLY)",
    Content = "Mantén presionado el botón flotante 'NC+FLY' para suspenderte en el aire y atravesar paredes sin gravedad ni riesgos de baneo."
})

-------------------------------------------------------------------------
-- PESTAÑA 3: ENDPOINTS CLICKEABLES (WAYPOINTS)
-------------------------------------------------------------------------
local WaypointTab = Window:CreateTab("Endpoints (Mapa)", 4483362458)

WaypointTab:CreateSection("Crear Endpoint al Tocar")

local WaypointDropdown 

WaypointTab:CreateToggle({
    Name = "Modo Guardar Endpoint (Toca el suelo/objeto)",
    CurrentValue = false,
    Flag = "ClickSaveToggle",
    Callback = function(Value)
        ClickSaveMode = Value
        if Value then
            Rayfield:Notify({
                Title = "Modo Selección Activo",
                Content = "Toca cualquier parte del suelo u objeto en la pantalla para guardarlo.",
                Duration = 4
            })
        end
    end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not ClickSaveMode then return end

    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = Mouse.Target
        local hitPos = Mouse.Hit

        if target and hitPos then
            local count = #WaypointNames + 1
            local pointName = "Punto #" .. count .. " (" .. target.Name .. ")"
            
            Waypoints[pointName] = hitPos
            table.insert(WaypointNames, pointName)
            SelectedWaypoint = pointName

            if WaypointDropdown then
                WaypointDropdown:Refresh(WaypointNames, true)
            end

            Rayfield:Notify({
                Title = "Endpoint Guardado",
                Content = "Guardado: " .. pointName,
                Duration = 2.5
            })
        end
    end
end)

WaypointTab:CreateSection("Lista de Endpoints y Botón Flotante")

WaypointDropdown = WaypointTab:CreateDropdown({
    Name = "Seleccionar Endpoint",
    Options = WaypointNames,
    CurrentOption = "",
    Flag = "WaypointDropdown",
    Callback = function(Option)
        SelectedWaypoint = type(Option) == "table" and Option[1] or Option
    end,
})

WaypointTab:CreateToggle({
    Name = "Mostrar Botón Flotante de Endpoint (END)",
    CurrentValue = false,
    Flag = "EndpointFloatingToggle",
    Callback = function(Value)
        EndpointBtn.Visible = Value
    end,
})

WaypointTab:CreateButton({
    Name = "Teletransportar al Endpoint Seleccionado (Menú)",
    Callback = function()
        if SelectedWaypoint and Waypoints[SelectedWaypoint] then
            TeleportTo(Waypoints[SelectedWaypoint])
        else
            Rayfield:Notify({
                Title = "Aviso",
                Content = "Selecciona un endpoint válido de la lista primero.",
                Duration = 3
            })
        end
    end,
})

WaypointTab:CreateButton({
    Name = "Limpiar Todos los Endpoints",
    Callback = function()
        Waypoints = {}
        WaypointNames = {}
        SelectedWaypoint = nil
        WaypointDropdown:Refresh({}, true)
        Rayfield:Notify({
            Title = "Lista Limpia",
            Content = "Se han eliminado todos los puntos guardados.",
            Duration = 2.5
        })
    end,
})
