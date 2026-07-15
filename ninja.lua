-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Spy Inspector 🔎 | Ninja 2.0",
   LoadingTitle = "Cargando Inspector DevTools...",
   LoadingSubtitle = "Soporte 3D y UI Integrado",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables Globales
local Inspector3DEnabled = false
local InspectorUIEnabled = false
local CurrentTarget = nil
local HoldingMouse = false

-- ==========================================
-- ELEMENTOS VISUALES DEL INSPECTOR
-- ==========================================

-- Resaltador 3D
local Highlight3D = Instance.new("Highlight")
Highlight3D.FillColor = Color3.fromRGB(0, 255, 150)
Highlight3D.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight3D.FillTransparency = 0.5
Highlight3D.Parent = CoreGui

-- Interfaz del Puntero UI (2D)
local SpyGui = Instance.new("ScreenGui")
SpyGui.Name = "SpyUIPointer"
SpyGui.Parent = CoreGui
SpyGui.DisplayOrder = 9999999 -- Por encima de todo
SpyGui.IgnoreGuiInset = true

-- La mira (Puntero flotante)
local Pointer = Instance.new("Frame")
Pointer.Size = UDim2.new(0, 14, 0, 14)
Pointer.Position = UDim2.new(0, 0, 0, 0)
Pointer.AnchorPoint = Vector2.new(0.5, 0.5)
Pointer.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
Pointer.BackgroundTransparency = 0.5
Pointer.Parent = SpyGui
Pointer.Visible = false
local PointerCorner = Instance.new("UICorner", Pointer)
PointerCorner.CornerRadius = UDim.new(1, 0)

-- Caja de selección UI (Bounding Box)
local UIBox = Instance.new("Frame")
UIBox.BackgroundTransparency = 1
UIBox.Visible = false
UIBox.Parent = SpyGui
local UIStroke = Instance.new("UIStroke", UIBox)
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Thickness = 2

-- ==========================================
-- FUNCIONES DE EXTRACCIÓN DE DATOS UI
-- ==========================================

-- Extrae todas las propiedades posibles de un elemento UI
local function DumpUIProperties(uiElement)
    local props = {}
    table.insert(props, "=== DATOS DEL ELEMENTO UI ===")
    table.insert(props, "Nombre: " .. tostring(uiElement.Name))
    table.insert(props, "Clase: " .. tostring(uiElement.ClassName))
    table.insert(props, "Ruta (Path): " .. tostring(uiElement:GetFullName()))
    
    -- Usamos pcall porque no todos los UI tienen las mismas propiedades
    pcall(function() table.insert(props, "Posición Absoluta: " .. tostring(uiElement.AbsolutePosition)) end)
    pcall(function() table.insert(props, "Tamaño Absoluto: " .. tostring(uiElement.AbsoluteSize)) end)
    pcall(function() table.insert(props, "ZIndex: " .. tostring(uiElement.ZIndex)) end)
    pcall(function() table.insert(props, "Visible: " .. tostring(uiElement.Visible)) end)
    pcall(function() table.insert(props, "Transparencia Fondo: " .. tostring(uiElement.BackgroundTransparency)) end)
    
    -- Propiedades específicas de Texto o Imagen
    pcall(function() table.insert(props, "Texto: '" .. tostring(uiElement.Text) .. "'") end)
    pcall(function() table.insert(props, "Color del Texto: " .. tostring(uiElement.TextColor3)) end)
    pcall(function() table.insert(props, "ID de Imagen: " .. tostring(uiElement.Image)) end)

    return table.concat(props, "\n")
end

-- ==========================================
-- CONSTRUCCIÓN DEL MENÚ
-- ==========================================

local MainTab = Window:CreateTab("Inspector DOM", 4483362458)
local ActionTab = Window:CreateTab("Acciones", 4483362458)

local StatusLabel = MainTab:CreateLabel("Estado: En espera...")

MainTab:CreateToggle({
   Name = "Activar Inspector de Mundo (3D)",
   CurrentValue = false,
   Flag = "Toggle3D",
   Callback = function(Value)
        Inspector3DEnabled = Value
        if not Value then Highlight3D.Adornee = nil end
        StatusLabel:Set(Value and "Estado: Inspector 3D Activo" or "Estado: En espera...")
   end,
})

MainTab:CreateToggle({
   Name = "Activar Inspector de Menús (UI 2D)",
   CurrentValue = false,
   Flag = "ToggleUI",
   Callback = function(Value)
        InspectorUIEnabled = Value
        Pointer.Visible = Value
        UIBox.Visible = false
        StatusLabel:Set(Value and "Estado: Inspector UI Activo. Mantén presionado en un menú." or "Estado: En espera...")
   end,
})

local InfoParagraph = MainTab:CreateParagraph({
    Title = "Datos del Elemento",
    Content = "Selecciona un objeto o mantén clic en una UI para volcar sus datos aquí."
})

-- ==========================================
-- LÓGICA DEL MOTOR 3D Y 2D
-- ==========================================

-- Bucle de renderizado para seguir el ratón
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    -- Lógica 3D
    if Inspector3DEnabled then
        local target = Mouse.Target
        Highlight3D.Adornee = target
    end

    -- Lógica 2D (UI)
    if InspectorUIEnabled then
        Pointer.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        
        -- Obtener interfaces debajo del ratón (Excluimos nuestra propia UI de Spy)
        SpyGui.Enabled = false -- Apagamos la UI espía un microsegundo para no detectarla a ella misma
        local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
        SpyGui.Enabled = true
        
        if #guis > 0 then
            local topGui = guis[1]
            UIBox.Visible = true
            UIBox.Position = UDim2.new(0, topGui.AbsolutePosition.X, 0, topGui.AbsolutePosition.Y)
            UIBox.Size = UDim2.new(0, topGui.AbsoluteSize.X, 0, topGui.AbsoluteSize.Y)
        else
            UIBox.Visible = false
        end
    end
end)

-- Sistema de Detección de Clics y "Mantener Presionado"
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        HoldingMouse = true
        
        -- Si estamos en modo UI y mantenemos presionado
        if InspectorUIEnabled then
            local mousePos = UserInputService:GetMouseLocation()
            SpyGui.Enabled = false
            local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
            SpyGui.Enabled = true
            
            if #guis > 0 then
                local targetUI = guis[1]
                
                -- Esperar 0.5 segundos para confirmar que se "Mantuvo presionado"
                task.delay(0.5, function()
                    if HoldingMouse and InspectorUIEnabled then
                        local dumpedData = DumpUIProperties(targetUI)
                        
                        -- Actualizar información en el menú
                        InfoParagraph:Set({
                            Title = "Formulario UI Volcado: " .. targetUI.Name,
                            Content = dumpedData
                        })
                        StatusLabel:Set("Estado: UI Capturada y Copiada")

                        -- Copiar al portapapeles
                        if setclipboard then
                            setclipboard(dumpedData)
                            Rayfield:Notify({
                                Title = "¡Datos Copiados!",
                                Content = "El formulario completo de la UI se copió al portapapeles.",
                                Duration = 3,
                            })
                        end
                    end
                end)
            end
        
        -- Si estamos en modo 3D (clic normal)
        elseif Inspector3DEnabled and Mouse.Target then
            CurrentTarget = Mouse.Target
            local content = string.format("Nombre: %s\nClase: %s\nRuta: %s", CurrentTarget.Name, CurrentTarget.ClassName, CurrentTarget:GetFullName())
            InfoParagraph:Set({Title = "Analizando: " .. CurrentTarget.Name, Content = content})
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        HoldingMouse = false
    end
end)
