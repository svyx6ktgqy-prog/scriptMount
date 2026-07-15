-- Cargar la librería Rayfield desde la URL proporcionada
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Spy Inspector 🔎 | Ninja 2.0 Pro",
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
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables de estado
local InspectorEnabled = false
local CurrentTarget = nil
local SpyEnabled = false
local ShopSpyEnabled = false

-- Historiales
local ActionLogs = {}
local ShopLogs = {}
local MaxLogs = 50

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
local MonitorTab = Window:CreateTab("Monitor de Red", 4483362458)
local ShopTab = Window:CreateTab("Tiendas y NPCs 🏪", 4483362458) -- NUEVA PESTAÑA ESPECIALIZADA

-- ==========================================
-- SECCIÓN 1: INSPECTOR PRINCIPAL (DOM)
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
-- SECCIÓN 2: ACCIONES DE DESARROLLADOR
-- ==========================================
ActionTab:CreateButton({
   Name = "Copiar Ruta (Path) al Portapapeles",
   Callback = function()
        if CurrentTarget and setclipboard then
            setclipboard(CurrentTarget:GetFullName())
            Rayfield:Notify({Title = "Copiado", Content = "Ruta copiada: " .. CurrentTarget:GetFullName(), Duration = 3})
        elseif not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta setclipboard.", Duration = 3})
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

-- ==========================================
-- SECCIÓN 3: MONITOR DE RED (General)
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
   Name = "Copiar Historial General (Formulario)",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta copiado.", Duration = 3})
            return
        end
        if #ActionLogs == 0 then
            Rayfield:Notify({Title = "Vacío", Content = "No hay interacciones registradas.", Duration = 3})
            return
        end
        
        local clipboardText = "--- HISTORIAL GENERAL DE RED (NINJA 2.0) ---\n\n"
        for i, log in ipairs(ActionLogs) do
            clipboardText = clipboardText .. string.format("[%d] Hora: %s\nRuta: %s\nMétodo: %s\nArgumentos: %s\n----------------------\n", 
                i, log.Time, log.Path, log.Method, log.Args)
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Éxito!", Content = "Copiado al portapapeles.", Duration = 3})
   end,
})

MonitorTab:CreateButton({
   Name = "Limpiar Historial General",
   Callback = function()
        ActionLogs = {}
        LastActionLabel:Set({Title = "Última Interacción Detectada", Content = "Historial limpiado."})
   end,
})

-- ==========================================
-- SECCIÓN 4: TIENDAS Y NPCS (NUEVO APARTADO)
-- ==========================================
ShopTab:CreateToggle({
   Name = "Activar Rastreador de Comercio y Diálogos",
   CurrentValue = false,
   Flag = "ShopSpyToggle",
   Callback = function(Value)
        ShopSpyEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Rastreador de Comercio Activo",
                Content = "Escuchando diálogos, clics en NPCs y compras en tiendas...",
                Duration = 4
            })
        end
   end,
})

local LastShopLabel = ShopTab:CreateParagraph({
    Title = "Interacción de Comercio Reciente",
    Content = "Interactúa con un vendedor, presiona 'E' en un objeto o realiza una compra para analizarla."
})

ShopTab:CreateButton({
   Name = "Copiar Registro Comercial (Formulario de Compra)",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta copiado.", Duration = 3})
            return
        end
        if #ShopLogs == 0 then
            Rayfield:Notify({Title = "Vacío", Content = "Aún no se han capturado transacciones comerciales.", Duration = 3})
            return
        end
        
        local clipboardText = "=== INFORME DE INTERACCIONES COMERCIALES Y NPCS ===\n\n"
        for i, log in ipairs(ShopLogs) do
            clipboardText = clipboardText .. string.format(
                "[%d] Hora: %s\nOrigen: %s\nElemento: %s\nDetalles / Parámetros: %s\n======================================\n", 
                i, log.Time, log.Type, log.Path, log.Details
            )
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Copiado!", Content = "Informe de compras copiado al portapapeles.", Duration = 3})
   end,
})

ShopTab:CreateButton({
   Name = "Limpiar Registro Comercial",
   Callback = function()
        ShopLogs = {}
        LastShopLabel:Set({Title = "Interacción de Comercio Reciente", Content = "Esperando interacciones comerciales..."})
   end,
})

-- ==========================================
-- FUNCIONES AUXILIARES
-- ==========================================
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local argType = typeof(v)
        if argType == "string" then
            result = result .. '"' .. v .. '"'
        elseif argType == "Instance" then
            result = result .. v:GetFullName()
        elseif argType == "table" then
            -- Intentar formatear tablas simples
            local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(v) end)
            result = result .. (ok and json or "{Tabla Compleja}")
        else
            result = result .. tostring(v)
        end
        if i < #args then result = result .. ", " end
    end
    if result == "" then return "Ninguno" end
    return result
end

-- Registrar interacción de forma visual y en caché
local function LogShopInteraction(interType, path, detailsTable)
    local timeStamp = os.date("%H:%M:%S")
    local detailsStr = ""
    for k, v in pairs(detailsTable) do
        detailsStr = detailsStr .. string.format("\n• %s: %s", tostring(k), tostring(v))
    end
    
    table.insert(ShopLogs, {
        Time = timeStamp,
        Type = interType,
        Path = path,
        Details = detailsStr
    })
    
    if #ShopLogs > MaxLogs then table.remove(ShopLogs, 1) end
    
    task.spawn(function()
        LastShopLabel:Set({
            Title = "🛒 Captura Comercial (" .. interType .. ")",
            Content = string.format("Hora: %s\nInteractuaste con: %s%s", timeStamp, path, detailsStr)
        })
    end)
    
    -- Print en consola de desarrollo (F9) para debug
    print(string.format("[SHOP SPY] [%s] %s -> %s %s", timeStamp, interType, path, detailsStr))
end

-- ==========================================
-- DETECTORES DE INTERACCIONES FÍSICAS (NPCs)
-- ==========================================

-- 1. Capturar ProximityPrompts (Cuando pulsas 'E' para hablar con un NPC, abrir puertas/cofres, etc.)
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player == LocalPlayer and ShopSpyEnabled then
        LogShopInteraction("ProximityPrompt (Acción Física)", prompt:GetFullName(), {
            ["Texto de Acción"] = prompt.ActionText,
            ["Texto de Objeto"] = prompt.ObjectText,
            ["Teclado / Botón"] = tostring(prompt.KeyboardKeyCode.Name),
            ["Distancia Máxima"] = tostring(prompt.MaxActivationDistance)
        })
    end
end)

-- 2. Capturar ClickDetectors (Cuando haces clic directamente sobre un NPC o botón del mapa)
local function HookClickDetector(obj)
    if obj:IsA("ClickDetector") then
        obj.MouseClick:Connect(function(player)
            if player == LocalPlayer and ShopSpyEnabled then
                LogShopInteraction("ClickDetector (Clic Físico)", obj:GetFullName(), {
                    ["Distancia de Activación"] = tostring(obj.MaxActivationDistance),
                    ["Padre del Objeto"] = obj.Parent and obj.Parent.Name or "Ninguno"
                })
            end
        end)
    end
end

-- Escuchar objetos interactivos que ya existen y los nuevos que aparezcan en el mapa
for _, desc in ipairs(game:GetDescendants()) do
    pcall(HookClickDetector, desc)
end
game.DescendantAdded:Connect(function(desc)
    pcall(HookClickDetector, desc)
end)

-- ==========================================
-- MOTOR DEL SPY DE RED / HOOKING GENERAL
-- ==========================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() then
        if method == "FireServer" or method == "InvokeServer" then
            local path = self:GetFullName()
            local formattedArgs = FormatArguments(args)
            local timeStamp = os.date("%H:%M:%S")

            -- A: Registro en el Monitor de Red General
            if SpyEnabled then
                table.insert(ActionLogs, {
                    Time = timeStamp,
                    Path = path,
                    Method = method,
                    Args = formattedArgs
                })
                if #ActionLogs > MaxLogs then table.remove(ActionLogs, 1) end

                task.spawn(function()
                    LastActionLabel:Set({
                        Title = "Interacción Capturada!",
                        Content = string.format("Acción detectada a las %s\n\nDestino (Remote): %s\nTipo: %s\nDatos: %s", 
                            timeStamp, path, method, formattedArgs)
                    })
                end)
            end

            -- B: Filtro Inteligente de Comercio (NPCs, Dinero, Compras, Tienda)
            if ShopSpyEnabled then
                local lowerPath = string.lower(path)
                local lowerArgs = string.lower(formattedArgs)
                
                -- Palabras clave que delatan una transacción o interacción comercial
                local isShopEvent = false
                local keywords = {"buy", "purchase", "shop", "store", "sell", "upgrade", "item", "transaction", "coin", "cash", "money", "gem", "spend", "vendor", "npc", "dialogue", "dialog", "hablar", "comprar", "tienda"}
                
                for _, word in ipairs(keywords) do
                    if string.find(lowerPath, word) or string.find(lowerArgs, word) then
                        isShopEvent = true
                        break
                    end
                end

                if isShopEvent then
                    LogShopInteraction("Transacción / Red", path, {
                        ["Método de Red"] = method,
                        ["Argumentos Enviados"] = formattedArgs,
                        ["Clasificación"] = "Posible acción de compra o diálogo con NPC"
                    })
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)
