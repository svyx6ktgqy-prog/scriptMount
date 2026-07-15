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
local ShopTab = Window:CreateTab("Tiendas y NPCs 🏪", 4483362458)
local NPCTab = Window:CreateTab("Clonador de NPCs 👥", 4483362458) -- ¡NUEVO APARTADO SOLICITADO!

-- ==========================================
-- FUNCIONES AUXILIARES DE BÚSQUEDA Y VOLCADO
-- ==========================================

-- Buscar la raíz del personaje (Model con Humanoid o el ancestro más alto antes de workspace)
local function GetCharacterRoot(part)
    if not part then return nil end
    local current = part
    local lastModel = nil
    while current and current ~= game and current ~= workspace do
        if current:IsA("Model") then
            lastModel = current
            if current:FindFirstChildOfClass("Humanoid") then
                return current
            end
        end
        current = current.Parent
    end
    return lastModel or (part:IsA("Model") and part or part.Parent)
end

-- Formatear argumentos de red
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

-- Volcar toda la información estructural del NPC en texto plano
local function DumpInstanceTree(instance)
    if not instance then return "No hay objeto seleccionado." end
    local dump = {}
    table.insert(dump, "==================================================")
    table.insert(dump, "   REPORTE DE ESTRUCTURA COMPLETA DE NPC / OBJETO  ")
    table.insert(dump, "==================================================")
    table.insert(dump, string.format("Nombre del Root: %s", instance.Name))
    table.insert(dump, string.format("Clase Base: %s", instance.ClassName))
    table.insert(dump, string.format("Ruta de Acceso: %s", instance:GetFullName()))
    
    if instance:IsA("Model") then
        local primary = instance.PrimaryPart
        table.insert(dump, string.format("PrimaryPart: %s", primary and primary.Name or "Ninguno"))
        if primary then
            table.insert(dump, string.format("Posición en el Mundo: %s", tostring(primary.Position)))
        end
        local hum = instance:FindFirstChildOfClass("Humanoid")
        if hum then
            table.insert(dump, string.format("Humanoid Encontrado: Sí [DisplayName: %s | Vida: %s/%s]", hum.DisplayName, tostring(hum.Health), tostring(hum.MaxHealth)))
        end
    end
    
    table.insert(dump, "\n[ARBOL JERÁRQUICO Y PROPIEDADES CLAVE]")
    
    local function recurse(parent, depth)
        local indent = string.rep("  ", depth)
        for _, child in ipairs(parent:GetChildren()) do
            local extraInfo = ""
            if child:IsA("BasePart") then
                extraInfo = string.format(" [Color: %s | Material: %s | Transp: %s | Colisión: %s]", tostring(child.Color), child.Material.Name, tostring(child.Transparency), tostring(child.CanCollide))
            elseif child:IsA("ValueBase") then
                extraInfo = string.format(" [Valor: %s]", tostring(child.Value))
            elseif child:IsA("ProximityPrompt") then
                extraInfo = string.format(" [Prompt: Acción='%s', Objeto='%s', Distancia=%s]", child.ActionText, child.ObjectText, tostring(child.MaxActivationDistance))
            elseif child:IsA("ClickDetector") then
                extraInfo = string.format(" [ClickDetector: Distancia=%s]", tostring(child.MaxActivationDistance))
            elseif child:IsA("Dialog") then
                extraInfo = string.format(" [Diálogo: Mensaje Inicial='%s', Propósito='%s']", child.InitialPrompt, child.Purpose)
            elseif child:IsA("DialogChoice") then
                extraInfo = string.format(" [Opción Diálogo: Pregunta='%s', Respuesta='%s']", child.UserDialog, child.ResponseDialog)
            elseif child:IsA("Shirt") or child:IsA("Pants") then
                extraInfo = string.format(" [Ropa: ID de Plantilla=%s]", tostring(child.ClassName == "Shirt" and child.ShirtTemplate or child.PantsTemplate))
            end
            
            table.insert(dump, string.format("%s• %s (%s)%s", indent, child.Name, child.ClassName, extraInfo))
            recurse(child, depth + 1)
        end
    end
    
    recurse(instance, 1)
    return table.concat(dump, "\n")
end

-- Generar código ejecutable de Roblox Studio para reconstruir físicamente el objeto/NPC
local function GenerateStudioReconstructor(instance)
    if not instance then return "-- No hay objeto seleccionado." end
    local scriptLines = {}
    table.insert(scriptLines, "-- ==================================================")
    table.insert(scriptLines, "-- SCRIPT RECONSTRUCTOR GENERADO POR SPY INSPECTOR")
    table.insert(scriptLines, "-- Pega esto en la consola de Roblox Studio (F9 en Studio)")
    table.insert(scriptLines, "-- ==================================================\n")
    table.insert(scriptLines, "local root = Instance.new(\"Model\")")
    table.insert(scriptLines, string.format("root.Name = %q", instance.Name))
    table.insert(scriptLines, "root.Parent = workspace")
    
    local function process(parent, parentVar)
        for _, child in ipairs(parent:GetChildren()) do
            -- Solo filtramos clases constructivas útiles para no saturar el portapapeles
            if child:IsA("BasePart") or child:IsA("ValueBase") or child:IsA("ProximityPrompt") or child:IsA("ClickDetector") or child:IsA("Folder") or child:IsA("Configuration") or child:IsA("Dialog") or child:IsA("DialogChoice") then
                local varName = "obj_" .. tostring(math.random(100000, 999999))
                table.insert(scriptLines, string.format("\nlocal %s = Instance.new(%q)", varName, child.ClassName))
                table.insert(scriptLines, string.format("%s.Name = %q", varName, child.Name))
                
                if child:IsA("BasePart") then
                    table.insert(scriptLines, string.format("%s.Size = Vector3.new(%f, %f, %f)", varName, child.Size.X, child.Size.Y, child.Size.Z))
                    table.insert(scriptLines, string.format("%s.CFrame = CFrame.new(%f, %f, %f)", varName, child.CFrame.X, child.CFrame.Y, child.CFrame.Z))
                    table.insert(scriptLines, string.format("%s.Color = Color3.fromRGB(%d, %d, %d)", varName, child.Color.R*255, child.Color.G*255, child.Color.B*255))
                    table.insert(scriptLines, string.format("%s.Material = Enum.Material.%s", varName, child.Material.Name))
                    table.insert(scriptLines, string.format("%s.Anchored = %s", varName, tostring(child.Anchored)))
                    table.insert(scriptLines, string.format("%s.CanCollide = %s", varName, tostring(child.CanCollide)))
                    table.insert(scriptLines, string.format("%s.Transparency = %f", varName, child.Transparency))
                elseif child:IsA("ValueBase") then
                    local valStr = tostring(child.Value)
                    if child:IsA("StringValue") then valStr = string.format("%q", child.Value) end
                    table.insert(scriptLines, string.format("%s.Value = %s", varName, valStr))
                elseif child:IsA("ProximityPrompt") then
                    table.insert(scriptLines, string.format("%s.ActionText = %q", varName, child.ActionText))
                    table.insert(scriptLines, string.format("%s.ObjectText = %q", varName, child.ObjectText))
                    table.insert(scriptLines, string.format("%s.MaxActivationDistance = %f", varName, child.MaxActivationDistance))
                elseif child:IsA("Dialog") then
                    table.insert(scriptLines, string.format("%s.InitialPrompt = %q", varName, child.InitialPrompt))
                    table.insert(scriptLines, string.format("%s.Purpose = Enum.DialogPurpose.%s", varName, child.Purpose.Name))
                end
                
                table.insert(scriptLines, string.format("%s.Parent = %s", varName, parentVar))
                process(child, varName)
            end
        end
    end
    
    pcall(function()
        process(instance, "root")
    end)
    
    return table.concat(scriptLines, "\n")
end

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
            NPCInspectorEnabled = false -- Apagar el otro inspector para evitar bugs
            Highlight.Adornee = nil
            StatusLabel:Set("Estado: Activo. Haz clic en un objeto del mundo.")
        end
   end,
})

local InfoParagraph = MainTab:CreateParagraph({
    Title = "Datos del Elemento",
    Content = "Activa el inspector y haz clic en un objeto para analizar su información profunda."
})

-- ==========================================
-- SECCIÓN NUEVA: CLONADOR Y RAÍZ DE NPC 👥
-- ==========================================
local StatusNPCLabel = NPCTab:CreateLabel("Estado NPC: En espera...")

NPCTab:CreateToggle({
   Name = "Activar Rastreador de Raíz de NPC",
   CurrentValue = false,
   Flag = "NPCInspectorToggle",
   Callback = function(Value)
        NPCInspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            StatusNPCLabel:Set("Estado NPC: Apagado")
        else
            InspectorEnabled = false -- Desactiva el inspector normal
            Highlight.Adornee = nil
            StatusNPCLabel:Set("Estado NPC: Activo. Pasa el cursor y haz clic sobre un NPC.")
            Rayfield:Notify({
                Title = "Buscador de Raíz",
                Content = "Pasa el mouse sobre un vendedor para iluminarlo por completo y haz clic para copiarlo.",
                Duration = 4
            })
        end
   end,
})

local NPCParagraph = NPCTab:CreateParagraph({
    Title = "NPC Capturado",
    Content = "Aquí se mostrará el resumen del personaje raíz una vez hagas clic en él."
})

NPCTab:CreateButton({
   Name = "📋 Copiar Estructura Completa al Portapapeles",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta setclipboard.", Duration = 3})
            return
        end
        if not CurrentNPCTarget then
            Rayfield:Notify({Title = "Error", Content = "Primero debes seleccionar un NPC con el puntero.", Duration = 3})
            return
        end
        
        local treeDump = DumpInstanceTree(CurrentNPCTarget)
        setclipboard(treeDump)
        Rayfield:Notify({
            Title = "¡Copiado con Éxito!",
            Content = "Se ha copiado el árbol de jerarquía completo del NPC al portapapeles.",
            Duration = 4
        })
   end,
})

NPCTab:CreateButton({
   Name = "🛠️ Copiar Script de Reconstrucción para Studio",
   Callback = function()
        if not setclipboard then
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta setclipboard.", Duration = 3})
            return
        end
        if not CurrentNPCTarget then
            Rayfield:Notify({Title = "Error", Content = "Primero debes seleccionar un NPC con el puntero.", Duration = 3})
            return
        end
        
        local rebuildScript = GenerateStudioReconstructor(CurrentNPCTarget)
        setclipboard(rebuildScript)
        Rayfield:Notify({
            Title = "¡Script Generado!",
            Content = "Pega el código en la Consola de Comandos de Studio para recrear el vendedor.",
            Duration = 5
        })
   end,
})

NPCTab:CreateButton({
   Name = "⚡ Teletransportarse al NPC Seleccionado",
   Callback = function()
        if CurrentNPCTarget then
            local primary = CurrentNPCTarget.PrimaryPart or CurrentNPCTarget:FindFirstChild("HumanoidRootPart") or CurrentNPCTarget:FindFirstChildOfClass("BasePart")
            if primary and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = primary.CFrame * CFrame.new(0, 0, -3)
                Rayfield:Notify({Title = "Teletransporte", Content = "Te has movido frente al NPC.", Duration = 2})
            end
        else
            Rayfield:Notify({Title = "Error", Content = "Ningún NPC seleccionado actualmente.", Duration = 3})
        end
   end,
})

-- ==========================================
-- BUCLE DE RENDER Y LOGICA DE CLICS
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
            Highlight.Adornee = root
        else
            Highlight.Adornee = nil
        end
    end
end)

Mouse.Button1Down:Connect(function()
    -- Lógica de Clic para el Inspector Normal
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
    
    -- Lógica de Clic para el Buscador de NPCs y Raíz Completa
    elseif NPCInspectorEnabled and Mouse.Target then
        local root = GetCharacterRoot(Mouse.Target)
        if root then
            CurrentNPCTarget = root
            local name = root.Name
            local className = root.ClassName
            local childCount = #root:GetDescendants()
            local hum = root:FindFirstChildOfClass("Humanoid")
            local details = string.format(
                "Nombre del Vendedor: %s\nTipo de Objeto: %s\nCantidad Total de Objetos Adentro: %d\nTiene Humanoide: %s\n\nPresiona los botones de abajo para copiar su jerarquía o generar su script de Roblox Studio.",
                name, className, childCount,
                hum and "Sí (Display: '" .. hum.DisplayName .. "')" or "No"
            )
            
            NPCParagraph:Set({Title = "Seleccionado: " .. name, Content = details})
            StatusNPCLabel:Set("Estado NPC: Analizando raíz de [" .. name .. "]")
        else
            StatusNPCLabel:Set("Estado NPC: No se pudo identificar una raíz para este objeto.")
        end
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
-- SECCIÓN 4: TIENDAS Y NPCS
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
    
    print(string.format("[SHOP SPY] [%s] %s -> %s %s", timeStamp, interType, path, detailsStr))
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
