-- =======================================================
-- Rayfield Parasite Inspector + Modo Cazador (Delta iOS)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- 1. SETUP DEL ENTORNO SEGURO
local function GetGuiParent()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then return CoreGui
    else return CoreGui end
end
local GuiParent = GetGuiParent()

-- Variables Globales
local LogHistory = {}
local MaxLogs = 15
local TargetButton = nil
local Connections = {}
local HuntConnections = {}
local IsHunting = false
local LogParagraph = nil

-- Función de Loggear (Muestra en Rayfield y en Consola)
local function Log(category, message)
    local timestamp = os.date("[%H:%M:%S]")
    local entry = string.format("%s [%s] %s", timestamp, category, tostring(message))
    table.insert(LogHistory, 1, entry) -- Insertar al principio
    
    if #LogHistory > MaxLogs then
        table.remove(LogHistory, #LogHistory)
    end
    print(entry)
    
    if LogParagraph then
        LogParagraph:Set({
            Title = "Terminal de Monitoreo",
            Content = table.concat(LogHistory, "\n")
        })
    end
end

-- 2. LÓGICA DE MONITOREO DEL OBJETIVO
local function ClearMonitors()
    for _, conn in ipairs(Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    Connections = {}
end

local function AttachMonitors(btn)
    ClearMonitors()
    TargetButton = btn
    Log("🎯 LOCK", "Objetivo capturado: " .. btn:GetFullName())
    Log("📊 DUMP", "Clase: " .. btn.ClassName .. " | ZIndex: " .. tostring(btn.ZIndex))
    Log("📊 DUMP", "Parent: " .. tostring(btn.Parent))
    
    local propsToWatch = {"Visible", "Position", "AbsolutePosition", "Size", "ZIndex", "Active"}
    
    for _, prop in ipairs(propsToWatch) do
        pcall(function()
            table.insert(Connections, btn:GetPropertyChangedSignal(prop):Connect(function()
                Log("⚙️ PROP", prop .. " mutó a -> " .. tostring(btn[prop]))
            end))
        end)
    end

    table.insert(Connections, btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Log("🔴 TÁCTIL", "InputBegan detectado en el botón.")
        end
    end))
end

-- 3. MODO CAZADOR (BRUTE FORCE HOOKING)
local function StopHunt()
    IsHunting = false
    for _, conn in ipairs(HuntConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    HuntConnections = {}
    Log("🛡️ CAZA", "Modo Cazador desactivado.")
end

local function StartHunt()
    if IsHunting then return end
    IsHunting = true
    Log("🛡️ CAZA", "Modo Cazador ACTIVO. Toca el botón flotante de Rayfield AHORA.")
    
    -- Inyectar un hook a TODOS los objetos de interfaz gráfica existentes
    for _, obj in ipairs(GuiParent:GetDescendants()) do
        if obj:IsA("GuiObject") then
            -- Ignoramos nuestra propia ventana de Rayfield para no auto-capturarnos
            if not obj:GetFullName():match("Rayfield") then
                local conn = obj.InputBegan:Connect(function(input)
                    if not IsHunting then return end
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        StopHunt()
                        AttachMonitors(obj)
                    end
                end)
                table.insert(HuntConnections, conn)
            end
        end
    end
end

-- 4. INICIAR RAYFIELD Y CREAR LA PESTAÑA PARÁSITO
task.spawn(function()
    pcall(function()
        local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
        
        local Window = Rayfield:CreateWindow({
            Name = "Rayfield + Inspector",
            LoadingTitle = "Inyectando Parásito...",
            LoadingSubtitle = "Modificando menú...",
            ConfigurationSaving = { Enabled = false },
            KeySystem = false
        })

        -- CREAMOS LA PESTAÑA DENTRO DEL PROPIO RAYFIELD
        local InspectorTab = Window:CreateTab("🔬 Inspector", 4483362458)

        local HuntToggle = InspectorTab:CreateToggle({
            Name = "Activar Modo Cazador (Click to Catch)",
            CurrentValue = false,
            Flag = "HunterToggle",
            Callback = function(Value)
                if Value then
                    StartHunt()
                else
                    StopHunt()
                end
            end,
        })

        InspectorTab:CreateButton({
            Name = "Forzar Escaneo por Propiedades (Backup)",
            Callback = function()
                Log("🔍 SCAN", "Buscando botón por fuerza bruta...")
                local found = false
                for _, obj in ipairs(GuiParent:GetDescendants()) do
                    if obj:IsA("ImageButton") or obj:IsA("TextButton") then
                        -- El botón de Rayfield suele ser pequeño (menor a 80x80) y activo
                        if obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.X < 80 and obj.AbsoluteSize.Y < 80 then
                            if not obj:GetFullName():match("Rayfield") then
                                AttachMonitors(obj)
                                found = true
                                break
                            end
                        end
                    end
                end
                if not found then Log("❌ ERROR", "El escáner de backup no encontró nada.") end
            end,
        })

        InspectorTab:CreateButton({
            Name = "📋 Copiar Logs al Portapapeles",
            Callback = function()
                local fullText = table.concat(LogHistory, "\n")
                if setclipboard then setclipboard(fullText)
                elseif toclipboard then toclipboard(fullText)
                end
                Log("✅ COPIADO", "Logs copiados al portapapeles.")
            end,
        })

        InspectorTab:CreateSection("Terminal de Salida")

        LogParagraph = InspectorTab:CreateParagraph({
            Title = "Terminal de Monitoreo",
            Content = "Esperando acciones...\n1. Cierra este menú para que aparezca el botón flotante.\n2. Abre el menú de nuevo, ve a Inspector y activa el Modo Cazador.\n3. Toca el botón flotante."
        })

        Rayfield:Notify({
            Title = "Inspector Inyectado",
            Content = "Ve a la pestaña 🔬 Inspector para comenzar.",
            Duration = 4,
            Image = 4483362458
        })
        
        Log("SYSTEM", "Inspector parásito cargado con éxito en Rayfield.")
    end)
end)
