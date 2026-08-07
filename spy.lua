-- ==========================================
-- CARGA DE LIBRERÍA RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SPY MONITOR ULTIMATE",
   LoadingTitle = "Cargando Monitor Total...",
   LoadingSubtitle = "Captura de UI, Botones Móviles y 3D",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- ==========================================
-- SERVICIOS Y VARIABLES GLOBALES
-- ==========================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

local InvLogs = {}
local MaxLogs = 100
local InvSpyEnabled = false
local ShopSpyEnabled = false

local LastLoggedTime = {} -- Sistema Anti-Duplicados para toques móviles

-- ==========================================
-- CREACIÓN DE PESTAÑA RAYFIELD
-- ==========================================
local InvTab = Window:CreateTab("Total Spy Monitor", 4483362458)

InvTab:CreateToggle({
   Name = "Activar Monitor Global de Interacciones",
   CurrentValue = false,
   Flag = "InvSpyToggle",
   Callback = function(Value)
        InvSpyEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Monitor Total Activo", 
                Content = "Capturando botones de móvil, sprint, habilidades, UI y entorno 3D...", 
                Duration = 4
            })
        end
   end,
})

local LastInvLabel = InvTab:CreateParagraph({
    Title = "Interacción Reciente",
    Content = "Toca cualquier botón en pantalla, usa sprint, equipa objetos o interactúa..."
})

InvTab:CreateButton({
   Name = "Copiar Registro Completo al Portapapeles",
   Callback = function()
        if not setclipboard then 
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta setclipboard.", Duration = 3})
            return 
        end
        
        if #InvLogs == 0 then 
            Rayfield:Notify({Title = "Vacío", Content = "No hay registros guardados.", Duration = 3}) 
            return 
        end
        
        local clipboardText = "🎒 === REGISTRO COMPLETO DE BOTONES E INTERACCIONES === 🎒\n\n"
        for i, log in ipairs(InvLogs) do
            clipboardText = clipboardText .. string.format(
                "[%d] Hora: %s\nTipo: %s\nRuta / Origen: %s\nDetalles:%s\n======================================\n", 
                i, log.Time, log.Type, log.Path, log.Details
            )
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Copiado!", Content = "Historial copiado al portapapeles.", Duration = 3})
   end,
})

InvTab:CreateButton({
   Name = "Limpiar Registros",
   Callback = function()
        InvLogs = {}
        LastInvLabel:Set({Title = "Interacción Reciente", Content = "Historial limpiado."})
   end,
})

-- ==========================================
-- FUNCIÓN CENTRAL DE REGISTRO
-- ==========================================
local function LogInteraction(interType, path, detailsTable)
    if not InvSpyEnabled then return end
    
    -- Filtro anti-duplicados (evita registrar el mismo toque 3 veces por milisegundo)
    local debounceKey = path .. "_" .. interType
    if LastLoggedTime[debounceKey] and (os.clock() - LastLoggedTime[debounceKey] < 0.2) then
        return
    end
    LastLoggedTime[debounceKey] = os.clock()

    local timeStamp = os.date("%H:%M:%S")
    local detailsStr = ""
    for k, v in pairs(detailsTable) do
        detailsStr = detailsStr .. string.format("\n• %s: %s", tostring(k), tostring(v))
    end
    
    table.insert(InvLogs, { Time = timeStamp, Type = interType, Path = path, Details = detailsStr })
    if #InvLogs > MaxLogs then table.remove(InvLogs, 1) end
    
    task.spawn(function()
        LastInvLabel:Set({
            Title = "🎯 Captura: " .. interType,
            Content = string.format("Hora: %s\nElemento: %s%s", timeStamp, path, detailsStr)
        })
    end)
    print(string.format("[TOTAL SPY] [%s] %s -> %s", timeStamp, interType, path))
end

-- ==========================================
-- 1. CAPTURA DE BOTONES DE INTERFAZ (UI, TouchGui, Sprint, Lanzar, etc.)
-- ==========================================
local function HookGuiElement(obj)
    pcall(function()
        if not obj:IsA("GuiObject") then return end

        -- Detectar si es un botón tradicional (TextButton, ImageButton)
        if obj:IsA("GuiButton") then
            -- Evento 1: Activated (El estándar para móviles y PC)
            obj.Activated:Connect(function()
                LogInteraction("Botón Activado (Activated)", obj:GetFullName(), {
                    ["Nombre Botón"] = obj.Name,
                    ["Tipo"] = obj.ClassName,
                    ["Texto"] = obj:IsA("TextButton") and obj.Text or "(ImageButton)",
                    ["Visible"] = tostring(obj.Visible)
                })
            end)

            -- Evento 2: Clic Clásico (MouseButton1Click)
            obj.MouseButton1Click:Connect(function()
                LogInteraction("Clic en Interfaz (GUI)", obj:GetFullName(), {
                    ["Nombre Botón"] = obj.Name,
                    ["Tipo"] = obj.ClassName,
                    ["Texto"] = obj:IsA("TextButton") and obj.Text or "(ImageButton)"
                })
            end)
        end

        -- Evento 3: TouchTap (Para cualquier Frame/Label/Botón usado en pantallas táctiles)
        obj.TouchTap:Connect(function()
            LogInteraction("Toque Táctil (TouchTap)", obj:GetFullName(), {
                ["Elemento"] = obj.Name,
                ["Clase"] = obj.ClassName
            })
        end)

        -- Evento 4: InputBegan (Captura imágenes o contenedores que funcionan como botones)
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not obj:IsA("GuiButton") then -- Solo lo registra si no es un GuiButton para no repetir
                    LogInteraction("Toque en Elemento Personalizado", obj:GetFullName(), {
                        ["Nombre"] = obj.Name,
                        ["Clase"] = obj.ClassName,
                        ["Tipo Entrada"] = input.UserInputType.Name
                    })
                end
            end
        end)
    end)
end

-- Escanear UI actual y futura (incluye PlayerGui y pantallas dinámicas de habilidades/sprint)
task.spawn(function()
    for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do 
        HookGuiElement(desc) 
    end
end)
LocalPlayer.PlayerGui.DescendantAdded:Connect(HookGuiElement)

-- ==========================================
-- 2. CAPTURA DE BOTONES Y TECLAS DE ENTRADA (Móvil / Teclado / Mandos)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not InvSpyEnabled then return end

    -- Capturar teclas o botones de control (Ej: Sprint con Shift o Botones de Gamepad)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        LogInteraction("Acción de Teclado / Atajo", "Entrada Física", {
            ["Tecla Presionada"] = input.KeyCode.Name,
            ["Procesado por Juego"] = tostring(gameProcessed)
        })
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
        LogInteraction("Botón de Mando / Gamepad", "Entrada Control", {
            ["Botón Presionado"] = input.KeyCode.Name
        })
    end
end)

-- ==========================================
-- 3. CAPTURA DE OBJETOS E INVENTARIO (Backpack / Personaje)
-- ==========================================
if LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        pcall(function()
            if child:IsA("Tool") or child:IsA("HopperBin") then
                LogInteraction("Objeto Recibido / Desequipado", child:GetFullName(), {
                    ["Nombre"] = child.Name,
                    ["Clase"] = child.ClassName
                })
            end
        end)
    end)
end

local function HookCharacterInventory(char)
    char.ChildAdded:Connect(function(child)
        pcall(function()
            if child:IsA("Tool") or child:IsA("HopperBin") then
                LogInteraction("Objeto Equipado en Mano", child:GetFullName(), {
                    ["Nombre"] = child.Name,
                    ["Clase"] = child.ClassName
                })
            end
        end)
    end)
end

if LocalPlayer.Character then HookCharacterInventory(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookCharacterInventory)

-- ==========================================
-- 4. CAPTURA DE OBJETOS INTERACTIVOS EN EL MAPA 3D (ClickDetectors / Prompts)
-- ==========================================
local function HookClickDetector(cd)
    pcall(function()
        if cd:IsA("ClickDetector") then
            cd.MouseClick:Connect(function(player)
                if player == LocalPlayer then
                    LogInteraction("Clic en Objeto 3D (ClickDetector)", cd:GetFullName(), {
                        ["Objeto Padre"] = cd.Parent and cd.Parent.Name or "Desconocido",
                        ["Distancia Máxima"] = tostring(cd.MaxActivationDistance)
                    })
                end
            end)
        end
    end)
end

task.spawn(function()
    for _, v in ipairs(workspace:GetDescendants()) do HookClickDetector(v) end
end)
workspace.DescendantAdded:Connect(HookClickDetector)

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    pcall(function()
        if player == LocalPlayer then
            LogInteraction("Interacción de Proximidad (E / Tap)", prompt:GetFullName(), {
                ["Acción"] = prompt.ActionText,
                ["Objeto"] = prompt.ObjectText
            })
        end
    end)
end)
