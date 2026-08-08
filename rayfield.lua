-- =======================================================
-- Rayfield Deep Button Inspector & Logger (Delta iOS)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Obtener la raíz correcta de la interfaz (Compatible con gethui)
local function GetGuiParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        return CoreGui
    else
        return CoreGui
    end
end

local GuiParent = GetGuiParent()
local LogHistory = {}

-- Función para añadir logs
local function Log(category, message)
    local timestamp = os.date("[%H:%M:%S]")
    local entry = string.format("%s [%s] %s", timestamp, string.upper(category), tostring(message))
    table.insert(LogHistory, entry)
    print(entry)
    
    if _G.UpdateInspectorUI then
        _G.UpdateInspectorUI()
    end
end

Log("SYSTEM", "Iniciando Inspector Profundo de Rayfield...")

-- =======================================================
-- CREACIÓN DE LA INTERFAZ DE MONITOREO EN PANTALLA
-- =======================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Rayfield_Deep_Inspector"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = GuiParent
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🔍 Rayfield Button Inspector"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Botón Copiar Log
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 110, 0, 25)
CopyBtn.Position = UDim2.new(1, -120, 0, 5)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
CopyBtn.Text = "📋 Copiar Log"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.TextSize = 12
CopyBtn.Parent = MainFrame

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- Contenedor de Texto para Logs (TextBox para selección manual en iOS)
local LogBox = Instance.new("TextBox")
LogBox.Size = UDim2.new(1, -20, 1, -45)
LogBox.Position = UDim2.new(0, 10, 0, 35)
LogBox.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
LogBox.TextColor3 = Color3.fromRGB(0, 255, 150)
LogBox.TextSize = 11
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.MultiLine = true
LogBox.ClearTextOnFocus = false
LogBox.TextEditable = false
LogBox.TextWrapped = true
LogBox.Text = "Esperando eventos..."
LogBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = LogBox

_G.UpdateInspectorUI = function()
    LogBox.Text = table.concat(LogHistory, "\n")
end

-- Función de copiado al portapapeles (compatible con Delta iOS)
CopyBtn.MouseButton1Click:Connect(function()
    local fullText = table.concat(LogHistory, "\n")
    if setclipboard then
        setclipboard(fullText)
        CopyBtn.Text = "✅ ¡Copiado!"
    elseif toclipboard then
        toclipboard(fullText)
        CopyBtn.Text = "✅ ¡Copiado!"
    else
        CopyBtn.Text = "❌ Usa selección manual"
    end
    task.delay(2, function()
        CopyBtn.Text = "📋 Copiar Log"
    end)
end)

-- =======================================================
-- LÓGICA DE INSPECCIÓN PROFUNDA DE RAYFIELD
-- =======================================================

local TargetButton = nil

local function FullInspectInstance(obj)
    Log("INSPECT", "--- ANÁLISIS DE OBJETO ---")
    Log("INFO", "Nombre: " .. obj.Name)
    Log("INFO", "Clase: " .. obj.ClassName)
    Log("INFO", "Ruta completa: " .. obj:GetFullName())
    Log("INFO", "Padre actual: " .. tostring(obj.Parent and obj.Parent:GetFullName() or "Sin Padre"))
    Log("INFO", "Visible: " .. tostring(obj.Visible))
    
    if obj:IsA("GuiObject") then
        Log("INFO", "Posición UDim2: " .. tostring(obj.Position))
        Log("INFO", "Posición Absoluta: " .. tostring(obj.AbsolutePosition))
        Log("INFO", "Tamaño Absoluto: " .. tostring(obj.AbsoluteSize))
        Log("INFO", "ZIndex: " .. tostring(obj.ZIndex))
        Log("INFO", "Transparency: " .. tostring(obj.BackgroundTransparency))
    end

    Log("INFO", "Hijos directos (" .. #obj:GetChildren() .. "):")
    for _, child in ipairs(obj:GetChildren()) do
        Log("CHILD", "  -> " .. child.Name .. " [" .. child.ClassName .. "]")
    end
end

local function AttachMonitors(btn)
    TargetButton = btn
    Log("FOUND", "¡Botón Flotante/Open localizado en: " .. btn:GetFullName())
    FullInspectInstance(btn)

    -- Monitor de cambios de visibilidad
    btn:GetPropertyChangedSignal("Visible"):Connect(function()
        Log("EVENT", "Cambio de VISIBILIDAD -> Visible = " .. tostring(btn.Visible))
    end)

    -- Monitor de cambios de posición
    btn:GetPropertyChangedSignal("Position"):Connect(function()
        Log("EVENT", "Cambio de POSICIÓN -> " .. tostring(btn.Position) .. " (Abs: " .. tostring(btn.AbsolutePosition) .. ")")
    end)

    -- Monitor de cambios de Padre (donde se esconde/mueve)
    btn:GetPropertyChangedSignal("Parent"):Connect(function()
        Log("EVENT", "Cambio de PADRE -> Nuevo Padre: " .. tostring(btn.Parent and btn.Parent:GetFullName() or "NIL"))
    end)

    -- Monitor si el botón es destruido o alterado
    btn.AncestryChanged:Connect(function(child, parent)
        Log("EVENT", "Cambio en Jerarquía Ancestral -> Nuevo Padre: " .. tostring(parent and parent:GetFullName() or "NIL"))
    end)

    -- Si es un botón interactivo, monitorear clics
    if btn:IsA("GuiButton") then
        btn.MouseButton1Click:Connect(function()
            Log("USER_INPUT", "El usuario hizo clic en el Botón Flotante")
        end)
    end
end

-- Buscar en las GUIs de Rayfield
local function ScanForRayfieldButton()
    Log("SEARCH", "Escaneando jerarquía en busca del botón de Rayfield...")
    
    local candidates = {}
    
    for _, gui in ipairs(GuiParent:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Rayfield suele llamarse "Rayfield" o crear un ScreenGui con elementos interactivos
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("GuiObject") then
                    local nameLower = string.lower(desc.Name)
                    -- Criterios de búsqueda habituales en Rayfield V2 / V3
                    if nameLower:find("open") or nameLower:find("toggle") or nameLower:find("rayfield") or nameLower:find("floating") or nameLower:find("icon") then
                        table.insert(candidates, desc)
                    end
                end
            end
        end
    end

    if #candidates > 0 then
        Log("SEARCH", "Se encontraron " .. #candidates .. " posibles candidatos a botón.")
        for i, candidate in ipairs(candidates) do
            Log("CANDIDATE", string.format("#%d: %s [%s]", i, candidate:GetFullName(), candidate.ClassName))
        end
        
        -- Asignar el monitor al primer candidato relevante (habitualmente el Open/Toggle button)
        AttachMonitors(candidates[1])
    else
        Log("WARN", "No se encontró un botón flotante con nombres estándar. Analizando todos los ScreenGuis activos...")
        for _, gui in ipairs(GuiParent:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "Rayfield_Deep_Inspector" then
                Log("GUI_FOUND", "ScreenGui: " .. gui.Name .. " | Hijos: " .. #gui:GetChildren())
            end
        end
    end
end

-- Ejecutar escaneo inicial
task.spawn(function()
    task.wait(1)
    ScanForRayfieldButton()
end)
