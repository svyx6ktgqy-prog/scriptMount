-- Cargar la librería Rayfield desde la URL proporcionada
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Spy Inspector 🔎 | Ninja 2.0",
   LoadingTitle = "Cargando Inspector DevTools...",
   LoadingSubtitle = "Desarrollado para Delta",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables de estado
local InspectorEnabled = false
local CurrentTarget = nil
local SpyEnabled = false
local ActionLogs = {} -- Aquí guardaremos todo el historial de interacciones
local MaxLogs = 50 -- Límite para no saturar la memoria

-- Crear el "Resaltador" (Highlight) para ver qué estamos tocando
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(0, 255, 150) -- Verde neón estilo hacker/ninja
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0.2
Highlight.Parent = CoreGui 

-- ==========================================
-- PESTAÑAS DEL MENÚ
-- ==========================================
local MainTab = Window:CreateTab("Inspector DOM", 4483362458)
local ActionTab = Window:CreateTab("Acciones", 4483362458)
local MonitorTab = Window:CreateTab("Monitor de Red", 4483362458) -- NUEVA PESTAÑA

-- ==========================================
-- SECCIÓN 1: INSPECTOR PRINCIPAL (Original)
-- ==========================================

local StatusLabel = MainTab:CreateLabel("Estado: En espera...")

MainTab:CreateToggle({
   Name = "Activar Puntero Inspector",
   CurrentValue = false,
   Flag = "InspectorToggle",
   Callback = function(Value)
        InspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            StatusLabel:Set("Estado: Apagado")
        else
            StatusLabel:Set("Estado: Activo. Haz clic en un objeto del mundo.")
        end
   end,
})

local InfoParagraph = MainTab:CreateParagraph({
    Title = "Datos del Elemento",
    Content = "Activa el inspector y haz clic en un objeto para analizar su información profunda."
})

-- ==========================================
-- SECCIÓN 2: ACCIONES DE DESARROLLADOR
-- ==========================================

ActionTab:CreateButton({
   Name = "Copiar Ruta (Path) al Portapapeles",
   Callback = function()
        if CurrentTarget and setclipboard then
            setclipboard(CurrentTarget:GetFullName())
            Rayfield:Notify({
                Title = "Copiado",
                Content = "Ruta copiada: " .. CurrentTarget:GetFullName(),
                Duration = 3,
            })
        elseif not setclipboard then
            Rayfield:Notify({
                Title = "Error",
                Content = "Tu ejecutor no soporta setclipboard.",
                Duration = 3,
            })
        end
   end,
})

ActionTab:CreateButton({
   Name = "Destruir Objeto Inspeccionado",
   Callback = function()
        if CurrentTarget then
            local name = CurrentTarget.Name
            CurrentTarget:Destroy()
            CurrentTarget = nil
            Highlight.Adornee = nil
            InfoParagraph:Set({Title = "Objeto Eliminado", Content = "El objeto " .. name .. " ha sido borrado del cliente."})
        end
   end,
})

-- Lógica del Puntero
RunService.RenderStepped:Connect(function()
    if InspectorEnabled then
        local target = Mouse.Target
        if target then
            Highlight.Adornee = target
        else
            Highlight.Adornee = nil
        end
    end
end)

Mouse.Button1Down:Connect(function()
    if InspectorEnabled and Mouse.Target then
        CurrentTarget = Mouse.Target
        
        local name = CurrentTarget.Name
        local className = CurrentTarget.ClassName
        local parentName = CurrentTarget.Parent and CurrentTarget.Parent.Name or "Ninguno"
        local fullName = CurrentTarget:GetFullName()
        
        local deepData = ""
        if CurrentTarget:IsA("BasePart") then
            deepData = string.format(
                "\n\n[Datos Físicos]\nPosición: %s\nTamaño: %s\nColor (RGB): %s\nMaterial: %s\nTransparencia: %s\nAnclado: %s\nColisión: %s",
                tostring(CurrentTarget.Position), tostring(CurrentTarget.Size), tostring(CurrentTarget.Color),
                tostring(CurrentTarget.Material.Name), tostring(CurrentTarget.Transparency),
                tostring(CurrentTarget.Anchored), tostring(CurrentTarget.CanCollide)
            )
        end
        
        local finalContent = string.format("Nombre: %s\nClase (Type): %s\nPadre Directo: %s\nRuta Completa: %s%s", name, className, parentName, fullName, deepData)

        InfoParagraph:Set({Title = "Analizando: " .. name, Content = finalContent})
        StatusLabel:Set("Estado: Analizando [" .. name .. "]")
    end
end)

-- ==========================================
-- SECCIÓN 3: MONITOR DE RED (NUEVO)
-- ==========================================

MonitorTab:CreateToggle({
   Name = "Activar Monitor de Interacciones (Network Spy)",
   CurrentValue = false,
   Flag = "SpyToggle",
   Callback = function(Value)
        SpyEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Monitor Activo", Content = "Escuchando compras e interacciones...", Duration = 3})
        end
   end,
})

local LastActionLabel = MonitorTab:CreateParagraph({
    Title = "Última Interacción Detectada",
    Content = "Esperando que realices alguna acción en el juego..."
})

MonitorTab:CreateButton({
   Name = "Copiar TODO el Historial (Formulario)",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta copiado.", Duration = 3})
            return
        end
        
        if #ActionLogs == 0 then
            Rayfield:Notify({Title = "Vacío", Content = "No hay interacciones registradas aún.", Duration = 3})
            return
        end
        
        -- Formatear todo el historial como un gran bloque de texto
        local clipboardText = "--- HISTORIAL DE INTERACCIONES (NINJA 2.0) ---\n\n"
        for i, log in ipairs(ActionLogs) do
            clipboardText = clipboardText .. string.format("[%d] Hora: %s\nRuta: %s\nMétodo: %s\nArgumentos: %s\n----------------------\n", 
                i, log.Time, log.Path, log.Method, log.Args)
        end
        
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Éxito!", Content = "Historial completo copiado al portapapeles.", Duration = 3})
   end,
})

MonitorTab:CreateButton({
   Name = "Limpiar Historial",
   Callback = function()
        ActionLogs = {}
        LastActionLabel:Set({Title = "Última Interacción Detectada", Content = "Historial limpiado. Esperando acciones..."})
   end,
})

-- Función de ayuda para convertir los argumentos interceptados a texto legible
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local argType = typeof(v)
        if argType == "string" then
            result = result .. '"' .. v .. '"'
        elseif argType == "Instance" then
            result = result .. v:GetFullName()
        elseif argType == "table" then
            result = result .. "{Tabla (oculta)}"
        else
            result = result .. tostring(v)
        end
        
        if i < #args then
            result = result .. ", "
        end
    end
    if result == "" then return "Ninguno" end
    return result
end

-- ==========================================
-- MOTOR DEL SPY DE INTERACCIONES (HOOKING)
-- ==========================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Si el espía está activo, y la llamada viene del juego (no del propio ejecutor)
    if SpyEnabled and not checkcaller() then
        -- Las interacciones (compras, botones, skills) usan FireServer o InvokeServer
        if method == "FireServer" or method == "InvokeServer" then
            
            -- Guardar los datos de forma segura
            local path = self:GetFullName()
            local formattedArgs = FormatArguments(args)
            local timeStamp = os.date("%H:%M:%S")

            -- Agregarlo al historial en memoria
            table.insert(ActionLogs, {
                Time = timeStamp,
                Path = path,
                Method = method,
                Args = formattedArgs
            })

            -- Si hay más de 'MaxLogs', borramos el más viejo para no dar lag
            if #ActionLogs > MaxLogs then
                table.remove(ActionLogs, 1)
            end

            -- Actualizar el panel visualmente (usamos task.spawn para evitar lag en el juego)
            task.spawn(function()
                local content = string.format("Acción detectada a las %s\n\nDestino (Remote): %s\nTipo: %s\nDatos Enviados: %s", 
                    timeStamp, path, method, formattedArgs)
                
                LastActionLabel:Set({
                    Title = "Interacción Capturada!",
                    Content = content
                })
            end)
        end
    end

    -- Retornar la llamada original para que el juego no se rompa y la compra funcione
    return oldNamecall(self, ...)
end)
