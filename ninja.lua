-- Cargar la librería Rayfield desde la URL proporcionada
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
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
local InvSpyEnabled = false -- Nueva variable para la GUI de inventario

-- Historiales
local ActionLogs = {}
local ShopLogs = {}
local InvLogs = {} -- Nuevo historial
local MaxLogs = 50

-- Crear el "Resaltador" (Highlight) para ver qué estamos tocando
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(0, 255, 150)
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
local InvTab = Window:CreateTab("Inventario y GUI 🎒", 4483362458) -- NUEVA PESTAÑA
local NPCTab = Window:CreateTab("Clonador de NPCs 👥", 4483362458)

-- ==========================================
-- FILTRADO Y EXTRACCIÓN ESTRICTA DE NPCs
-- ==========================================
local function GetCharacterRoot(part)
    if not part then return nil end
    local current = part
    while current and current ~= game and current ~= workspace do
        if current:IsA("Model") then
            if current:FindFirstChildOfClass("Humanoid") then
                return current
            end
        end
        current = current.Parent
    end
    return nil
end

local function AnalyzeNPCDetails(root)
    if not root then return "Ningún NPC seleccionado.", "Vacío" end
    local humanoid = root:FindFirstChildOfClass("Humanoid")
    local partsList, accessoriesList, interactiveList, clothesList = {}, {}, {}, {}
    
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
    
    return string.format(
        "👤 NOMBRE DEL NPC: %s\n🆔 Ruta del Root: %s\n\n⚙️ DATOS DEL HUMANOIDE:\n  - DisplayName: %s\n  - Vida actual: %s / %s\n  - WalkSpeed: %s\n\n🧱 PIEZAS DEL CUERPO:\n%s\n\n👕 ROPA Y APARIENCIA:\n%s\n\n🎒 ACCESORIOS:\n%s\n\n⚡ INTERACTIVIDAD:\n%s",
        root.Name, root:GetFullName(),
        humanoid and humanoid.DisplayName or "No tiene",
        humanoid and tostring(humanoid.Health) or "0",
        humanoid and tostring(humanoid.MaxHealth) or "0",
        humanoid and tostring(humanoid.WalkSpeed) or "0",
        #partsList > 0 and table.concat(partsList, "\n") or "  (Ninguna parte)",
        #clothesList > 0 and table.concat(clothesList, "\n") or "  (Sin ropa)",
        #accessoriesList > 0 and table.concat(accessoriesList, "\n") or "  (Sin accesorios)",
        #interactiveList > 0 and table.concat(interactiveList, "\n") or "  (Sin interactividad)"
    )
end

local function GenerateFullNPCDump(root)
    if not root then return "No hay datos." end
    local dump = {"==================================================", "      REPORTE DE EXTRACCIÓN DE NPC COMPLETO", "==================================================", string.format("Nombre: %s\nRuta: %s", root.Name, root:GetFullName())}
    local hum = root:FindFirstChildOfClass("Humanoid")
    if hum then table.insert(dump, string.format("Humanoid:\n - DisplayName: %s\n - WalkSpeed: %s", hum.DisplayName, tostring(hum.WalkSpeed))) end
    table.insert(dump, "\n[ARBOL DETALLADO]")
    local function recurse(parent, depth)
        local indent = string.rep("  ", depth)
        for _, child in ipairs(parent:GetChildren()) do
            table.insert(dump, string.format("%s• %s (%s)", indent, child.Name, child.ClassName))
            recurse(child, depth + 1)
        end
    end
    recurse(root, 1)
    return table.concat(dump, "\n")
end

-- ==========================================
-- INTERFAZ DEL CLONADOR DE NPCs
-- ==========================================
local StatusNPCLabel = NPCTab:CreateLabel("Estado NPC: En espera...")
local NPCParagraph = NPCTab:CreateParagraph({Title = "Datos del NPC Seleccionado", Content = "Selecciona un personaje."})

NPCTab:CreateToggle({
   Name = "Activar Escáner de Personajes (NPCs)",
   CurrentValue = false,
   Flag = "NPCInspectorToggle",
   Callback = function(Value)
        NPCInspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            Highlight.FillColor = Color3.fromRGB(0, 255, 150)
            StatusNPCLabel:Set("Estado NPC: Apagado")
        else
            InspectorEnabled = false
            Highlight.Adornee = nil
            Highlight.FillColor = Color3.fromRGB(255, 50, 50)
            StatusNPCLabel:Set("Estado NPC: Activo. Haz clic sobre un NPC.")
        end
   end,
})

NPCTab:CreateButton({
   Name = "📋 Copiar Reporte de Datos al Portapapeles",
   Callback = function()
        if CurrentNPCTarget and setclipboard then
            setclipboard(GenerateFullNPCDump(CurrentNPCTarget))
            Rayfield:Notify({Title = "Copiado!", Content = "Estructura del NPC copiada.", Duration = 3})
        end
   end,
})

-- ==========================================
-- SECCIÓN 1: INSPECTOR PRINCIPAL (DOM)
-- ==========================================
local StatusLabel = MainTab:CreateLabel("Estado: En espera...")
local InfoParagraph = MainTab:CreateParagraph({Title = "Datos del Elemento", Content = "Haz clic en un objeto para analizarlo."})

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
            NPCInspectorEnabled = false
            Highlight.FillColor = Color3.fromRGB(0, 255, 150)
            StatusLabel:Set("Estado: Activo.")
        end
   end,
})

RunService.RenderStepped:Connect(function()
    if InspectorEnabled then
        Highlight.Adornee = Mouse.Target
    elseif NPCInspectorEnabled then
        local target = Mouse.Target
        Highlight.Adornee = target and GetCharacterRoot(target) or nil
    end
end)

Mouse.Button1Down:Connect(function()
    if InspectorEnabled and Mouse.Target then
        CurrentTarget = Mouse.Target
        local deepData = CurrentTarget:IsA("BasePart") and string.format("\n\nPosición: %s\nTamaño: %s", tostring(CurrentTarget.Position), tostring(CurrentTarget.Size)) or ""
        InfoParagraph:Set({Title = "Analizando: " .. CurrentTarget.Name, Content = string.format("Nombre: %s\nClase: %s\nRuta: %s%s", CurrentTarget.Name, CurrentTarget.ClassName, CurrentTarget:GetFullName(), deepData)})
    elseif NPCInspectorEnabled and Mouse.Target then
        local root = GetCharacterRoot(Mouse.Target)
        if root then
            CurrentNPCTarget = root
            NPCParagraph:Set({Title = "DATOS DE: " .. root.Name, Content = AnalyzeNPCDetails(root)})
        end
    end
end)

-- ==========================================
-- SECCIÓN 2: ACCIONES DE DESARROLLADOR
-- ==========================================
ActionTab:CreateButton({
   Name = "Copiar Ruta (Path) al Portapapeles",
   Callback = function() if CurrentTarget and setclipboard then setclipboard(CurrentTarget:GetFullName()) end end,
})
ActionTab:CreateButton({
   Name = "Destruir Objeto Inspeccionado",
   Callback = function() if CurrentTarget then CurrentTarget:Destroy(); Highlight.Adornee = nil end end,
})

-- ==========================================
-- SECCIÓN 3: MONITOR DE RED (General)
-- ==========================================
local LastActionLabel = MonitorTab:CreateParagraph({Title = "Última Interacción", Content = "Esperando..."})
MonitorTab:CreateToggle({Name = "Activar Network Spy", CurrentValue = false, Flag = "SpyToggle", Callback = function(V) SpyEnabled = V end})
MonitorTab:CreateButton({
   Name = "Copiar Historial General",
   Callback = function()
        if setclipboard then
            local text = "--- HISTORIAL ---\n"
            for i, log in ipairs(ActionLogs) do text = text .. string.format("[%d] %s | %s | %s\n", i, log.Time, log.Path, log.Method) end
            setclipboard(text)
        end
   end,
})

-- ==========================================
-- SECCIÓN 4: TIENDAS Y NPCS
-- ==========================================
local LastShopLabel = ShopTab:CreateParagraph({Title = "Comercio Reciente", Content = "Esperando..."})
ShopTab:CreateToggle({Name = "Activar Rastreador de Comercio", CurrentValue = false, Flag = "ShopSpyToggle", Callback = function(V) ShopSpyEnabled = V end})
ShopTab:CreateButton({
   Name = "Copiar Registro Comercial",
   Callback = function()
        if setclipboard then
            local text = "=== INFORME DE COMERCIO ===\n"
            for i, log in ipairs(ShopLogs) do text = text .. string.format("[%d] %s | %s\nDetalles: %s\n\n", i, log.Path, log.Type, log.Details) end
            setclipboard(text)
        end
   end,
})

local function LogShopInteraction(interType, path, detailsTable)
    local timeStamp = os.date("%H:%M:%S")
    local detailsStr = ""
    for k, v in pairs(detailsTable) do detailsStr = detailsStr .. string.format("\n• %s: %s", tostring(k), tostring(v)) end
    table.insert(ShopLogs, {Time = timeStamp, Type = interType, Path = path, Details = detailsStr})
    task.spawn(function() LastShopLabel:Set({Title = "🛒 Captura Comercial", Content = string.format("Hora: %s\nRuta: %s%s", timeStamp, path, detailsStr)}) end)
end

-- ==========================================
-- SECCIÓN 5: INVENTARIO Y GUI (NUEVO)
-- ==========================================
InvTab:CreateToggle({
   Name = "Activar Monitor de Inventario y GUI",
   CurrentValue = false,
   Flag = "InvSpyToggle",
   Callback = function(Value)
        InvSpyEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Monitor Activo", Content = "Escuchando mochilas, herramientas, selectores y clicks en la UI...", Duration = 4})
        end
   end,
})

local LastInvLabel = InvTab:CreateParagraph({
    Title = "Interacción de GUI / Inventario Reciente",
    Content = "Equipa un pico, pulsa un botón del inventario o recoge un diamante..."
})

InvTab:CreateButton({
   Name = "Copiar Registro de GUI e Inventario",
   Callback = function()
        if not setclipboard then return end
        if #InvLogs == 0 then Rayfield:Notify({Title = "Vacío", Content = "No hay registros.", Duration = 3}) return end
        
        local clipboardText = "🎒 === REGISTRO DE INVENTARIO Y GUI DEL JUGADOR === 🎒\n\n"
        for i, log in ipairs(InvLogs) do
            clipboardText = clipboardText .. string.format(
                "[%d] Hora: %s\nTipo: %s\nRuta del Elemento: %s\nAtributos: %s\n======================================\n", 
                i, log.Time, log.Type, log.Path, log.Details
            )
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Copiado!", Content = "Registro de inventario copiado al portapapeles.", Duration = 3})
   end,
})

InvTab:CreateButton({
   Name = "Limpiar Registro de Inventario",
   Callback = function()
        InvLogs = {}
        LastInvLabel:Set({Title = "Interacción Reciente", Content = "Historial limpiado."})
   end,
})

-- Función de Logística para el Inventario
local function LogInventoryInteraction(interType, path, detailsTable)
    local timeStamp = os.date("%H:%M:%S")
    local detailsStr = ""
    for k, v in pairs(detailsTable) do
        detailsStr = detailsStr .. string.format("\n• %s: %s", tostring(k), tostring(v))
    end
    
    table.insert(InvLogs, { Time = timeStamp, Type = interType, Path = path, Details = detailsStr })
    if #InvLogs > MaxLogs then table.remove(InvLogs, 1) end
    
    task.spawn(function()
        LastInvLabel:Set({
            Title = "🎒 Captura: " .. interType,
            Content = string.format("Hora: %s\nElemento: %s%s", timeStamp, path, detailsStr)
        })
    end)
    print(string.format("[GUI/INV SPY] [%s] %s -> %s", timeStamp, interType, path))
end

-- Detección Física de Mochila y Equipamiento (Tools, Picos, Diamantes)
LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
        LogInventoryInteraction("Objeto Recibido / Desequipado", child:GetFullName(), {
            ["Nombre"] = child.Name,
            ["Clase"] = child.ClassName,
            ["Tipo de Evento"] = "Entró a la Mochila"
        })
    end
end)

local function HookCharacterInventory(char)
    char.ChildAdded:Connect(function(child)
        if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
            LogInventoryInteraction("Objeto Equipado", child:GetFullName(), {
                ["Nombre"] = child.Name,
                ["Clase"] = child.ClassName,
                ["Tipo de Evento"] = "Herramienta activada en manos del jugador"
            })
        end
    end)
end

if LocalPlayer.Character then HookCharacterInventory(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookCharacterInventory)

-- Detección de Clicks en la GUI del Jugador (PlayerGui)
local function HookGUIElement(obj)
    if obj:IsA("GuiButton") then
        obj.MouseButton1Click:Connect(function()
            if InvSpyEnabled then
                LogInventoryInteraction("Clic en Interfaz (GUI)", obj:GetFullName(), {
                    ["Nombre del Botón"] = obj.Name,
                    ["Texto"] = obj:IsA("TextButton") and obj.Text or "(Es ImageButton)",
                    ["Visibilidad Padre"] = obj.Parent and tostring(obj.Parent.Visible) or "Desconocido"
                })
            end
        end)
    end
end

-- Conectar todos los botones existentes de la UI y los futuros (Menús de items, selectores)
for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do pcall(HookGUIElement, desc) end
LocalPlayer.PlayerGui.DescendantAdded:Connect(function(desc) pcall(HookGUIElement, desc) end)

-- ==========================================
-- HOOKING GENERAL DE RED (__namecall)
-- ==========================================
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local argType = typeof(v)
        if argType == "string" then result = result .. '"' .. v .. '"'
        elseif argType == "Instance" then result = result .. v:GetFullName()
        elseif argType == "table" then
            local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(v) end)
            result = result .. (ok and json or "{Tabla}")
        else result = result .. tostring(v) end
        if i < #args then result = result .. ", " end
    end
    return result == "" and "Ninguno" or result
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local path = self:GetFullName()
        local formattedArgs = FormatArguments(args)
        local timeStamp = os.date("%H:%M:%S")

        -- 1. Red General
        if SpyEnabled then
            table.insert(ActionLogs, {Time = timeStamp, Path = path, Method = method, Args = formattedArgs})
            task.spawn(function() LastActionLabel:Set({Title = "Interacción!", Content = path .. "\n" .. formattedArgs}) end)
        end

        -- 2. Filtro de Tienda
        if ShopSpyEnabled then
            local strData = string.lower(path .. formattedArgs)
            local keywords = {"buy", "shop", "store", "sell", "npc", "comprar"}
            for _, w in ipairs(keywords) do
                if string.find(strData, w) then
                    LogShopInteraction("Transacción", path, {["Args"] = formattedArgs})
                    break
                end
            end
        end
        
        -- 3. Filtro de Inventario/GUI (NUEVO)
        if InvSpyEnabled then
            local strData = string.lower(path .. formattedArgs)
            -- Palabras clave relacionadas a selectores, mochilas, equipamiento y herramientas
            local invKeywords = {"equip", "unequip", "inventory", "backpack", "tool", "select", "slot", "hotbar", "item", "drop", "pickup", "inv"}
            for _, w in ipairs(invKeywords) do
                if string.find(strData, w) then
                    LogInventoryInteraction("Evento de Red (Inventario/GUI)", path, {
                        ["Método"] = method,
                        ["Argumentos"] = formattedArgs,
                        ["Palabra Clave Detonante"] = w
                    })
                    break
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

-- Eventos Físicos de Interacción
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player == LocalPlayer and ShopSpyEnabled then
        LogShopInteraction("ProximityPrompt", prompt:GetFullName(), {["Acción"] = prompt.ActionText})
    end
end)
