-- =======================================================
-- Rayfield Text-Scanner + iOS Clipboard Fix (Delta iOS)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local function GetGuiParent()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then return CoreGui
    else return CoreGui end
end
local GuiParent = GetGuiParent()

local LogHistory = {}
local MaxLogs = 20
local TargetButton = nil
local Connections = {}
local LogParagraph = nil

local function Log(category, message)
    local timestamp = os.date("[%H:%M:%S]")
    local entry = string.format("%s [%s] %s", timestamp, category, tostring(message))
    table.insert(LogHistory, 1, entry)
    if #LogHistory > MaxLogs then table.remove(LogHistory, #LogHistory) end
    print(entry)
    if LogParagraph then
        LogParagraph:Set({ Title = "Terminal", Content = table.concat(LogHistory, "\n") })
    end
end

local function AttachMonitors(btn)
    for _, conn in ipairs(Connections) do if conn.Connected then conn:Disconnect() end end
    Connections = {}
    TargetButton = btn
    
    Log("🎯 LOCK", "Objetivo encontrado: " .. btn:GetFullName())
    Log("📊 DUMP", "Clase: " .. btn.ClassName .. " | ZIndex: " .. tostring(btn.ZIndex))
    Log("📊 DUMP", "Posición Absolute: " .. tostring(btn.AbsolutePosition))
    Log("📊 DUMP", "Contenedor Padre: " .. tostring(btn.Parent))
    
    local props = {"Visible", "Position", "AbsolutePosition", "ZIndex"}
    for _, prop in ipairs(props) do
        pcall(function()
            table.insert(Connections, btn:GetPropertyChangedSignal(prop):Connect(function()
                Log("⚙️ MUTACIÓN", prop .. " cambió a -> " .. tostring(btn[prop]))
            end))
        end)
    end
end

-- Búsqueda directa por el texto de tu imagen
local function ScanByText()
    Log("🔍 SCAN", "Buscando elemento con texto 'Show Rayfield'...")
    local found = false
    
    for _, obj in ipairs(GuiParent:GetDescendants()) do
        pcall(function()
            -- Si es un objeto de texto y contiene la frase
            if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Text then
                if string.match(string.lower(obj.Text), "show rayfield") then
                    
                    -- A menudo el texto está dentro de un Frame, así que monitoreamos al "Padre"
                    local target = obj
                    if obj.Parent and (obj.Parent:IsA("GuiObject") or obj.Parent:IsA("Frame") or obj.Parent:IsA("TextButton")) then
                        target = obj.Parent
                    end
                    
                    AttachMonitors(target)
                    found = true
                end
            end
        end)
    end
    
    if not found then Log("❌ ERROR", "No se encontró el texto. Asegúrate de que el botón esté visible en pantalla.") end
end

-- Solución al bloqueo de portapapeles de iOS
local function ShowManualCopyUI(text)
    local sg = Instance.new("ScreenGui")
    sg.Name = "ManualCopyUI_iOS"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = GuiParent end)
    if not sg.Parent then pcall(function() sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end) end

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.7, 0)
    frame.Position = UDim2.new(0.05, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Active = true
    frame.Draggable = true

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -60, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.Text = "Selecciona todo el texto de abajo y cópialo"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 1, -60)
    box.Position = UDim2.new(0, 10, 0, 50)
    box.Text = text
    box.MultiLine = true
    box.ClearTextOnFocus = false
    box.TextEditable = false
    box.TextWrapped = true
    box.Font = Enum.Font.Code
    box.TextSize = 11
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    box.TextColor3 = Color3.fromRGB(150, 255, 150)
end

-- Setup de Rayfield
task.spawn(function()
    pcall(function()
        local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
        local Window = Rayfield:CreateWindow({
            Name = "Radar iOS",
            LoadingTitle = "Inyectando Radar...",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false
        })

        local Tab = Window:CreateTab("🔬 Radar", 4483362458)

        Tab:CreateButton({
            Name = "🔍 1. Buscar botón 'Show Rayfield'",
            Callback = function() ScanByText() end,
        })

        Tab:CreateButton({
            Name = "📋 2. Obtener Logs (Manual para iOS)",
            Callback = function()
                local fullText = table.concat(LogHistory, "\n")
                local success = false
                pcall(function()
                    if setclipboard then setclipboard(fullText) success = true
                    elseif toclipboard then toclipboard(fullText) success = true
                    end
                end)
                
                if success then
                    Log("✅ COPIADO", "Se usó portapapeles automático.")
                else
                    Log("⚠️ AVISO", "Portapapeles bloqueado. Abriendo modo manual...")
                    ShowManualCopyUI(fullText)
                end
            end,
        })

        LogParagraph = Tab:CreateParagraph({
            Title = "Terminal",
            Content = "1. Cierra este menú para ver el botón 'Show Rayfield'.\n2. Vuelve a abrirlo.\n3. Presiona 'Buscar botón'."
        })
        Log("SYSTEM", "Radar cargado. Listo para escanear.")
    end)
end)
