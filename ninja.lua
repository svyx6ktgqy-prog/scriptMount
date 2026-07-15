-- Cargar la librería Rayfield desde la URL proporcionada
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Spy Inspector 🔎 | Ninja 3.0 Ultra",
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
local NPCInspectorEnabled = false
local CurrentTarget = nil
local CurrentNPCTarget = nil
local SpyEnabled = false
local ShopSpyEnabled = false

-- Historiales
local ActionLogs = {}
local ShopLogs = {}
local MaxLogs = 50

-- Crear el "Resaltador" (Highlight) para ver qué estamos tocando
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Rojo neón para enfoque preciso de NPCs
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.4
Highlight.OutlineTransparency = 0.1
Highlight.Parent = CoreGui 

-- ==========================================
-- PESTAÑAS DEL MENÚ
-- ==========================================
local MainTab = Window:CreateTab("Inspector DOM", 4483362458)
local ActionTab = Window:CreateTab("Acciones", 4483362458)
local MonitorTab = Window:CreateTab("Monitor de Red", 4483362458)
local ShopTab = Window:CreateTab("Tiendas y NPCs 🏪", 4483362458)
local NPCTab = Window:CreateTab("Clonador de NPCs 👥", 4483362458) -- APARTADO MEJORADO

-- ==========================================
-- FILTRADO Y EXTRACCIÓN ESTRICTA DE NPCs
-- ==========================================

-- Asegura que SÓLO se detecten modelos que sean personajes o NPCs reales (con Humanoid)
local function GetCharacterRoot(part)
    if not part then return nil end
    local current = part
    while current and current ~= game and current ~= workspace do
        if current:IsA("Model") then
            -- Validación estricta de NPC/Personaje
            if current:FindFirstChildOfClass("Humanoid") then
                return current
            end
        end
        current = current.Parent
    end
    return nil
end

-- Analizar y formatear toda la estructura interna del personaje para mostrar en la interfaz
local function AnalyzeNPCDetails(root)
    if not root then return "Ningún NPC seleccionado.", "Vacío" end
    
    local humanoid = root:FindFirstChildOfClass("Humanoid")
    local rootPart = root:FindFirstChild("HumanoidRootPart") or root.PrimaryPart
    
    local partsList = {}
    local accessoriesList = {}
    local interactiveList = {}
    local clothesList = {}
    
    -- Escaneo manual únicamente de los descendientes del personaje seleccionado (Cero impacto en el rendimiento general)
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(partsList, string.format("  • %s [Material: %s]", child.Name, child.Material.Name))
        elseif child:IsA("Accessory") then
            table.insert(accessoriesList, string.format("  • %s (Accesorio)", child.Name))
        elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            table.insert(clothesList, string.format("  • %s (%s)", child.Name, child.ClassName))
        elseif child:IsA("ProximityPrompt") or child:IsA("ClickDetector") or child:IsA("Dialog") then
            table.insert(interactiveList, string.format("  • %s (%s)", child.Name, child.ClassName))
        end
    end
    
    -- Construir reporte legible para la interfaz
    local uiReport = string.format(
        "👤 NOMBRE DEL NPC: %s\n" ..
        "🆔 Ruta del Root: %s\n\n" ..
        "⚙️ DATOS DEL HUMANOIDE:\n" ..
        "  - DisplayName: %s\n" ..
        "  - Vida actual: %s / %s\n" ..
        "  - WalkSpeed: %s\n\n" ..
        "🧱 PIEZAS DEL CUERPO (FÍSICO):\n%s\n\n" ..
        "👕 ROPA Y APARIENCIA:\n%s\n\n" ..
        "🎒 ACCESORIOS / OBJETOS EQUIPADOS:\n%s\n\n" ..
        "⚡ INTERACTIVIDAD (Prompts/Clicks):\n%s",
        root.Name,
        root:GetFullName(),
        humanoid and humanoid.DisplayName or "No tiene",
        humanoid and tostring(humanoid.Health) or "0",
        humanoid and tostring(humanoid.MaxHealth) or "0",
        humanoid and tostring(humanoid.WalkSpeed) or "0",
        #partsList > 0 and table.concat(partsList, "\n") or "  (Ninguna parte física directa)",
        #clothesList > 0 and table.concat(clothesList, "\n") or "  (Sin ropa/camisas)",
        #accessoriesList > 0 and table.concat(accessoriesList, "\n") or "  (Sin accesorios)",
        #interactiveList > 0 and table.concat(interactiveList, "\n") or "  (Sin componentes interactivos)"
    )
    
    return uiReport
end

-- Generar árbol jerárquico superdetallado para el portapapeles
local function GenerateFullNPCDump(root)
    if not root then return "No hay datos." end
    local dump = {}
    table.insert(dump, "==================================================")
    table.insert(dump, "      REPORTE DE EXTRACCIÓN DE NPC COMPLETO")
    table.insert(dump, "==================================================")
    table.insert(dump, string.format("Nombre del Root: %s", root.Name))
    table.insert(dump, string.format("Ruta Completa: %s", root:GetFullName()))
    
    local hum = root:FindFirstChildOfClass("Humanoid")
    if hum then
        table.insert(dump, string.format("Configuración Humanoid:\n - DisplayName: %s\n - WalkSpeed: %s\n - HipHeight: %s", hum.DisplayName, tostring(hum.WalkSpeed), tostring(hum.HipHeight)))
    end
    
    table.insert(dump, "\n[ARBOL DETALLADO DE MIEMBROS, PROPIEDADES Y VALORES]")
    
    local function recurse(parent, depth)
        local indent = string.rep("  ", depth)
        for _, child in ipairs(parent:GetChildren()) do
            local extra = ""
            if child:IsA("BasePart") then
                extra = string.format(" [Size: %s | Color: %s | Material: %s | Anchored: %s]", tostring(child.Size), tostring(child.Color), child.Material.Name, tostring(child.Anchored))
            elseif child:IsA("ValueBase") then
                extra = string.format(" [Valor: %s]", tostring(child.Value))
            elseif child:IsA("ProximityPrompt") then
                extra = string.format(" [Prompt: Acción='%s', Objeto='%s', Botón=%s]", child.ActionText, child.ObjectText, tostring(child.KeyboardKeyCode.Name))
            elseif child:IsA("ClickDetector") then
                extra = string.format(" [ClickDetector: MaxDist=%s]", tostring(child.MaxActivationDistance))
            elseif child:IsA("Dialog") then
                extra = string.format(" [Diálogo Inicial: %q]", child.InitialPrompt)
            elseif child:IsA("DialogChoice") then
                extra = string.format(" [Opción: %q -> Respuesta: %q]", child.UserDialog, child.ResponseDialog)
            end
            
            table.insert(dump, string.format("%s• %s (%s)%s", indent, child.Name, child.ClassName, extra))
            recurse(child, depth + 1)
        end
    end
    
    recurse(root, 1)
    return table.concat(dump, "\n")
end

-- ==========================================
-- INTERFAZ Y CONTROLES DEL CLONADOR DE NPCs
-- ==========================================
local StatusNPCLabel = NPCTab:CreateLabel("Estado NPC: En espera...")

NPCTab:CreateToggle({
   Name = "Activar Escáner de Personajes (NPCs)",
   CurrentValue = false,
   Flag = "NPCInspectorToggle",
   Callback = function(Value)
        NPCInspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            StatusNPCLabel:Set("Estado NPC: Apagado")
        else
            InspectorEnabled = false -- Apagar el otro inspector general
            Highlight.Adornee = nil
            StatusNPCLabel:Set("Estado NPC: Activo. Pasa el cursor y haz clic sobre un NPC.")
            Rayfield:Notify({
                Title = "Escáner Listo",
                Content = "Solo se iluminarán modelos con un Humanoid válido. Haz clic para analizar.",
                Duration = 4
            })
        end
   end,
})

local NPCParagraph = NPCTab:CreateParagraph({
    Title = "Datos del NPC Seleccionado",
    Content = "Activa el escáner y selecciona un personaje del juego para ver sus partes y propiedades detalladas aquí."
})

NPCTab:CreateButton({
   Name = "📋 Copiar Reporte de Datos al Portapapeles",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta copiado.", Duration = 3})
            return
        end
        if not CurrentNPCTarget then
            Rayfield:Notify({Title = "Error", Content = "Primero debes seleccionar un NPC.", Duration = 3})
            return
        end
        
        local fullReport = GenerateFullNPCDump(CurrentNPCTarget)
        setclipboard(fullReport)
        Rayfield:Notify({
            Title = "¡Copiado!",
            Content = "Estructura física y lógica copiada al portapapeles con éxito.",
            Duration = 3
        })
   end,
})

-- ==========================================
-- RENDERING Y DETECCIÓN DEL CURSOR
-- ==========================================
RunService.RenderStepped:Connect(function()
    if InspectorEnabled then
        local target = Mouse.Target
        if target then
            Highlight.Adornee = target
        else
            Highlight.Adornee = nil
        end
    elseif NPCInspectorEnabled then
        local target = Mouse.Target
        if target then
            local root = GetCharacterRoot(target)
            -- Únicamente resalta si el modelo tiene un Humanoid
            if root then
                Highlight.Adornee = root
            else
                Highlight.Adornee = nil
            end
        else
            Highlight.Adornee = nil
        end
    end
end)

-- Clic para capturar información
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
        
    elseif NPCInspectorEnabled and Mouse.Target then
        local root = GetCharacterRoot(Mouse.Target)
        if root then
            CurrentNPCTarget = root
            StatusNPCLabel:Set("Estado NPC: Cargando datos de [" .. root.Name .. "]...")
            
            -- Extraer datos detallados e imprimirlos directamente en la interfaz Rayfield
            local detailedText = AnalyzeNPCDetails(root)
            NPCParagraph:Set({
                Title = "DATOS DE: " .. root.Name,
                Content = detailedText
            })
            
            StatusNPCLabel:Set("Estado NPC: Listo. Datos de [" .. root.Name .. "] cargados en pantalla.")
        else
            StatusNPCLabel:Set("Estado NPC: Selección inválida. Solo puedes elegir Personajes/NPCs.")
        end
    end
end)

-- ==========================================
-- SECCIÓN 1: INSPECTOR DOM GENERAL (OPCIONAL)
-- ==========================================
local StatusLabel = MainTab:CreateLabel("Estado: En espera...")

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
-- SECCIÓN 4: TIENDAS Y NPCS (Detección de Acciones)
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
-- DETECTORES DE INTERACCIONES FÍSICAS (NPCs)
-- ==========================================
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
end

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

for _, desc in ipairs(game:GetDescendants()) do
    pcall(HookClickDetector, desc)
end
game.DescendantAdded:Connect(function(desc)
    pcall(HookClickDetector, desc)
end)

-- ==========================================
-- MOTOR DEL SPY DE RED / HOOKING GENERAL
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

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() then
        if method == "FireServer" or method == "InvokeServer" then
            local path = self:GetFullName()
            local formattedArgs = FormatArguments(args)
            local timeStamp = os.date("%H:%M:%S")

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

            if ShopSpyEnabled then
                local lowerPath = string.lower(path)
                local lowerArgs = string.lower(formattedArgs)
                
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
