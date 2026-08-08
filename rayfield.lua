-- =======================================================
-- Rayfield Deep Surgical Inspector + Auto-Load (Delta iOS)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- 1. CARGAR RAYFIELD PARA FORZAR EL BOTÓN FLOTANTE
task.spawn(function()
    pcall(function()
        local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
        local Window = Rayfield:CreateWindow({
            Name = "🎯 Target Rayfield UI",
            LoadingTitle = "Rayfield Injectado",
            LoadingSubtitle = "Generando botón flotante...",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false
        })
        Rayfield:Notify({
            Title = "Inspector Listo",
            Content = "Rayfield ha sido cargado. Activa el escáner.",
            Duration = 3,
            Image = 4483362458
        })
    end)
end)

-- 2. SETUP DEL ENTORNO SEGURO
local function GetGuiParent()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then return CoreGui
    else return CoreGui end
end
local GuiParent = GetGuiParent()

-- Variables de estado
local LogHistory = {}
local MaxLogs = 500
local IsMonitoring = false
local TargetButton = nil
local Connections = {}

-- 3. SISTEMA DE LOGS
local function UpdateLogUI()
    if _G.LogBoxRef then
        _G.LogBoxRef.Text = table.concat(LogHistory, "\n")
    end
end

local function Log(category, message)
    if #LogHistory >= MaxLogs then
        table.remove(LogHistory, 1) -- Borrar el más viejo para no crashear iOS
    end
    local timestamp = os.date("[%H:%M:%S]")
    local entry = string.format("%s [%s] %s", timestamp, string.upper(category), tostring(message))
    table.insert(LogHistory, entry)
    print(entry)
    UpdateLogUI()
end

Log("SYSTEM", "Inspector Quirúrgico Iniciado. Esperando activación...")

-- 4. INTERFAZ DEL INSPECTOR
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Rayfield_Surgical_Inspector"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = GuiParent end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 300)
MainFrame.Position = UDim2.new(0.5, -180, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Logo y Título
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 24, 0, 24)
Logo.Position = UDim2.new(0, 10, 0, 8)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://6031280882" -- Icono de Ojo/Inspección
Logo.ImageColor3 = Color3.fromRGB(0, 255, 150)
Logo.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 40, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Deep Surgical Inspector"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Botón Switch (Monitor)
local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Size = UDim2.new(0, 100, 0, 26)
SwitchBtn.Position = UDim2.new(0, 10, 0, 40)
SwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
SwitchBtn.Text = "▶ INICIAR"
SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchBtn.Font = Enum.Font.GothamBold
SwitchBtn.TextSize = 12
SwitchBtn.Parent = MainFrame
Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 6)

-- Botón Copiar
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 26)
CopyBtn.Position = UDim2.new(1, -110, 0, 40)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
CopyBtn.Text = "📋 COPIAR LOG"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 12
CopyBtn.Parent = MainFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

-- Caja de Texto (Logs)
local LogBox = Instance.new("TextBox")
LogBox.Size = UDim2.new(1, -20, 1, -80)
LogBox.Position = UDim2.new(0, 10, 0, 72)
LogBox.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
LogBox.TextColor3 = Color3.fromRGB(150, 255, 150)
LogBox.TextSize = 11
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.MultiLine = true
LogBox.ClearTextOnFocus = false
LogBox.TextEditable = false
LogBox.TextWrapped = true
LogBox.Text = "Esperando acción..."
LogBox.Parent = MainFrame
Instance.new("UICorner", LogBox).CornerRadius = UDim.new(0, 6)
_G.LogBoxRef = LogBox

-- 5. LÓGICA QUIRÚRGICA
local function ClearConnections()
    for _, conn in ipairs(Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    Connections = {}
end

local function AttachSurgicalMonitors(btn)
    TargetButton = btn
    Log("TARGET_LOCKED", "Botón flotante anclado: " .. btn:GetFullName())
    
    -- Inspección inicial
    Log("DUMP", "Clase: " .. btn.ClassName .. " | ZIndex: " .. btn.ZIndex)
    Log("DUMP", "Pos: " .. tostring(btn.Position) .. " | AbsPos: " .. tostring(btn.AbsolutePosition))

    -- Propiedades Críticas a monitorear
    local props = {"Visible", "Position", "AbsolutePosition", "Size", "BackgroundTransparency", "Parent", "ZIndex"}
    for _, prop in ipairs(props) do
        table.insert(Connections, btn:GetPropertyChangedSignal(prop):Connect(function()
            if not IsMonitoring then return end
            Log("PROPERTY", prop .. " mutó a -> " .. tostring(btn[prop]))
        end))
    end

    -- Monitoreo de Eventos Táctiles/Clic (Muy importante en iPhone)
    if btn:IsA("GuiObject") then
        table.insert(Connections, btn.InputBegan:Connect(function(input)
            if not IsMonitoring then return end
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                Log("INPUT", "🔴 TOQUE/CLIC INICIADO. Posición táctil: " .. tostring(input.Position))
            end
        end))
        
        table.insert(Connections, btn.InputEnded:Connect(function(input)
            if not IsMonitoring then return end
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                Log("INPUT", "🟢 TOQUE/CLIC FINALIZADO.")
            end
        end))
    end

    -- Monitoreo si Rayfield le inyecta animaciones o elementos hijos dinámicamente
    table.insert(Connections, btn.ChildAdded:Connect(function(child)
        if not IsMonitoring then return end
        Log("HIERARCHY", "Elemento inyectado en el botón: " .. child.Name .. " [" .. child.ClassName .. "]")
    end))
end

local function ScanForTarget()
    Log("SCAN", "Buscando botón de Rayfield en memoria...")
    for _, gui in ipairs(GuiParent:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "Rayfield_Surgical_Inspector" then
            for _, desc in ipairs(gui:GetDescendants()) do
                -- Patrones comunes del botón móvil de Rayfield
                local name = string.lower(desc.Name)
                if desc:IsA("GuiObject") and (name:find("open") or name:find("toggle") or name:find("sirius") or name:find("rayfield")) then
                    -- Confirmar que es interactivo o tiene tamaño de un botón flotante
                    if desc:IsA("TextButton") or desc:IsA("ImageButton") or (desc.Size.X.Offset > 0 and desc.Size.Y.Offset > 0) then
                        AttachSurgicalMonitors(desc)
                        return true
                    end
                end
            end
        end
    end
    Log("ERROR", "No se encontró el botón. Asegúrate de que Rayfield terminó de cargar.")
    return false
end

-- 6. BOTONES DE LA UI
SwitchBtn.MouseButton1Click:Connect(function()
    IsMonitoring = not IsMonitoring
    if IsMonitoring then
        SwitchBtn.Text = "⏹ DETENER"
        SwitchBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        Log("SYSTEM", "Monitoreo ACTIVO. Toca el botón de Rayfield.")
        
        if not TargetButton then
            ScanForTarget()
        end
    else
        SwitchBtn.Text = "▶ INICIAR"
        SwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        Log("SYSTEM", "Monitoreo PAUSADO.")
    end
end)

CopyBtn.MouseButton1Click:Connect(function()
    local fullText = table.concat(LogHistory, "\n")
    local success = false
    
    pcall(function()
        if setclipboard then
            setclipboard(fullText)
            success = true
        elseif toclipboard then
            toclipboard(fullText)
            success = true
        end
    end)
    
    if success then
        CopyBtn.Text = "✅ COPIADO"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        CopyBtn.Text = "❌ MANTÉN PRESIONADO ABAJO"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    task.delay(2, function()
        CopyBtn.Text = "📋 COPIAR LOG"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end)
end)
