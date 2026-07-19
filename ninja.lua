-- Load the Rayfield library from the provided URL
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Loading DevTools Inspector...",
   LoadingSubtitle = "Developed for Delta",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
   Keybind = "RightShift" -- PRESIÓNA SHIFT DERECHO PARA OCULTAR/MOSTRAR EL MENÚ Y PODER COMPRAR
})

-- Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- State variables
local InspectorEnabled = false
local NPCInspectorEnabled = false
local CurrentTarget = nil
local CurrentNPCTarget = nil
local SpyEnabled = false
local ShopSpyEnabled = false
local InvSpyEnabled = false 

-- Forward Declarations
local InfoParagraph = nil

-- History logs
local ActionLogs = {}
local ShopLogs = {}
local InvLogs = {} 
local MaxLogs = 50

-- Floating "CLEAR" Button Setup
local ClearGui = nil
local ClearButton = nil

local function DestroyClearButton()
    if ClearGui then
        ClearGui:Destroy()
        ClearGui = nil
        ClearButton = nil
    end
end

local function CreateClearButton()
    DestroyClearButton() -- Clear any existing instance first
    
    ClearGui = Instance.new("ScreenGui")
    ClearGui.Name = "NinjaClearGui"
    ClearGui.ResetOnSpawn = false
    ClearGui.Parent = CoreGui
    
    ClearButton = Instance.new("TextButton")
    ClearButton.Name = "ClearButton"
    ClearButton.Size = UDim2.new(0, 90, 0, 35)
    ClearButton.Position = UDim2.new(0.5, -45, 0.82, 0) -- Centered horizontally, near the bottom area
    ClearButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ClearButton.BorderSizePixel = 0
    ClearButton.Text = "CLEAR"
    ClearButton.TextColor3 = Color3.fromRGB(255, 60, 60)
    ClearButton.Font = Enum.Font.SourceSansBold
    ClearButton.TextSize = 16
    ClearButton.Active = true
    ClearButton.Draggable = true -- Allows players on mobile or PC to easily reposition the button
    ClearButton.Parent = ClearGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ClearButton
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 60, 60)
    Stroke.Thickness = 1.5
    Stroke.Parent = ClearButton

    -- Click event logic to safely destroy the highlighted target
    ClearButton.MouseButton1Click:Connect(function()
        if CurrentTarget and CurrentTarget.Parent then
            local name = CurrentTarget.Name
            CurrentTarget:Destroy()
            CurrentTarget = nil
            Highlight.Adornee = nil
            if InfoParagraph then
                InfoParagraph:Set({Title = "Object Destroyed", Content = "The object " .. name .. " has been deleted from the client."})
            end
            Rayfield:Notify({Title = "Destroyed", Content = "Object " .. name .. " was cleared.", Duration = 2})
        else
            Rayfield:Notify({Title = "Error", Content = "No object selected to clear.", Duration = 2})
        end
    end)
end

-- Create the Highlight to see what we are touching
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(0, 255, 150)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0.2
Highlight.Parent = CoreGui 

-- ==========================================
-- MENU TABS
-- ==========================================
local MainTab = Window:CreateTab("DOM Inspector", 4483362458)
local ActionTab = Window:CreateTab("Actions", 4483362458)
local MonitorTab = Window:CreateTab("Network Monitor", 4483362458)
local ShopTab = Window:CreateTab("Shops & NPCs 🏪", 4483362458)
local InvTab = Window:CreateTab("Inventory & GUI 🎒", 4483362458) 
local NPCTab = Window:CreateTab("NPC Cloner 👥", 4483362458)
local DeepShopTab = Window:CreateTab("Shop Deep Scanner 🔎", 4483362458)

-- ==========================================
-- STRICT NPC FILTERING AND EXTRACTION
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
    if not root then return "No NPC selected.", "Empty" end
    local humanoid = root:FindFirstChildOfClass("Humanoid")
    local partsList, accessoriesList, interactiveList, clothesList = {}, {}, {}, {}
    
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(partsList, string.format("  • %s [Material: %s]", child.Name, child.Material.Name))
        elseif child:IsA("Accessory") then
            table.insert(accessoriesList, string.format("  • %s (Accessory)", child.Name))
        elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            table.insert(clothesList, string.format("  • %s (%s)", child.Name, child.ClassName))
        elseif child:IsA("ProximityPrompt") or child:IsA("ClickDetector") or child:IsA("Dialog") then
            table.insert(interactiveList, string.format("  • %s (%s)", child.Name, child.ClassName))
        end
    end
    
    return string.format(
        "👤 NPC NAME: %s\n🆔 Root Path: %s\n\n⚙️ HUMANOID DATA:\n  - DisplayName: %s\n  - Current Health: %s / %s\n  - WalkSpeed: %s\n\n🧱 BODY PARTS:\n%s\n\n👕 CLOTHING & APPEARANCE:\n%s\n\n🎒 ACCESSORIES:\n%s\n\n⚡ INTERACTIVITY:\n%s",
        root.Name, root:GetFullName(),
        humanoid and humanoid.DisplayName or "None",
        humanoid and tostring(humanoid.Health) or "0",
        humanoid and tostring(humanoid.MaxHealth) or "0",
        humanoid and tostring(humanoid.WalkSpeed) or "0",
        #partsList > 0 and table.concat(partsList, "\n") or "  (No parts)",
        #clothesList > 0 and table.concat(clothesList, "\n") or "  (No clothes)",
        #accessoriesList > 0 and table.concat(accessoriesList, "\n") or "  (No accessories)",
        #interactiveList > 0 and table.concat(interactiveList, "\n") or "  (No interactivity)"
    )
end

local function GenerateFullNPCDump(root)
    if not root then return "No data." end
    local dump = {"==================================================", "      COMPLETE NPC EXTRACTION REPORT", "==================================================", string.format("Name: %s\nPath: %s", root.Name, root:GetFullName())}
    local hum = root:FindFirstChildOfClass("Humanoid")
    if hum then table.insert(dump, string.format("Humanoid:\n - DisplayName: %s\n - WalkSpeed: %s", hum.DisplayName, tostring(hum.WalkSpeed))) end
    table.insert(dump, "\n[DETAILED TREE]")
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
-- NPC CLONER INTERFACE
-- ==========================================
local StatusNPCLabel = NPCTab:CreateLabel("NPC Status: Waiting...")
local NPCParagraph = NPCTab:CreateParagraph({Title = "Selected NPC Data", Content = "Select a character."})

NPCTab:CreateToggle({
   Name = "Enable Character Scanner (NPCs)",
   CurrentValue = false,
   Flag = "NPCInspectorToggle",
   Callback = function(Value)
        NPCInspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            Highlight.FillColor = Color3.fromRGB(0, 255, 150)
            StatusNPCLabel:Set("NPC Status: Off")
        else
            InspectorEnabled = false
            DestroyClearButton() -- Destroys CLEAR button when shifting categories
            Highlight.Adornee = nil
            Highlight.FillColor = Color3.fromRGB(255, 50, 50)
            StatusNPCLabel:Set("NPC Status: Active. Click on an NPC.")
        end
   end,
})

NPCTab:CreateButton({
   Name = "📋 Copy Data Report to Clipboard",
   Callback = function()
        if CurrentNPCTarget and setclipboard then
            setclipboard(GenerateFullNPCDump(CurrentNPCTarget))
            Rayfield:Notify({Title = "Copied!", Content = "NPC structure copied.", Duration = 3})
        end
   end,
})

-- ==========================================
-- SECTION 1: MAIN INSPECTOR (DOM)
-- ==========================================
local StatusLabel = MainTab:CreateLabel("Status: Waiting...")
InfoParagraph = MainTab:CreateParagraph({Title = "Element Data", Content = "Click on an object to analyze it."})

MainTab:CreateToggle({
   Name = "Enable Inspector Pointer",
   CurrentValue = false,
   Flag = "InspectorToggle",
   Callback = function(Value)
        InspectorEnabled = Value
        if not Value then
            Highlight.Adornee = nil
            StatusLabel:Set("Status: Off")
            DestroyClearButton() -- Safely removes the button when disabled
        else
            NPCInspectorEnabled = false
            Highlight.FillColor = Color3.fromRGB(0, 255, 150)
            StatusLabel:Set("Status: Active.")
            CreateClearButton() -- Instantiates and mounts the CLEAR button
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
        local deepData = CurrentTarget:IsA("BasePart") and string.format("\n\nPosition: %s\nSize: %s", tostring(CurrentTarget.Position), tostring(CurrentTarget.Size)) or ""
        InfoParagraph:Set({Title = "Analyzing: " .. CurrentTarget.Name, Content = string.format("Name: %s\nClass: %s\nPath: %s%s", CurrentTarget.Name, CurrentTarget.ClassName, CurrentTarget:GetFullName(), deepData)})
    elseif NPCInspectorEnabled and Mouse.Target then
        local root = GetCharacterRoot(Mouse.Target)
        if root then
            CurrentNPCTarget = root
            NPCParagraph:Set({Title = "DATA FOR: " .. root.Name, Content = AnalyzeNPCDetails(root)})
        end
    end
end)

-- ==========================================
-- SECTION 2: DEVELOPER ACTIONS
-- ==========================================
ActionTab:CreateButton({
   Name = "Copy Path to Clipboard",
   Callback = function() if CurrentTarget and setclipboard then setclipboard(CurrentTarget:GetFullName()) end end,
})
ActionTab:CreateButton({
   Name = "Destroy Inspected Object",
   Callback = function() if CurrentTarget then CurrentTarget:Destroy(); Highlight.Adornee = nil end end,
})

-- ==========================================
-- SECTION 3: NETWORK MONITOR (General)
-- ==========================================
local LastActionLabel = MonitorTab:CreateParagraph({Title = "Last Interaction", Content = "Waiting..."})
MonitorTab:CreateToggle({Name = "Enable Network Spy", CurrentValue = false, Flag = "SpyToggle", Callback = function(V) SpyEnabled = V end})
MonitorTab:CreateButton({
   Name = "Copy General History",
   Callback = function()
        if setclipboard then
            local text = "--- HISTORY ---\n"
            for i, log in ipairs(ActionLogs) do text = text .. string.format("[%d] %s | %s | %s\n", i, log.Time, log.Path, log.Method) end
            setclipboard(text)
        end
   end,
})

-- ==========================================
-- SECTION 4: SHOPS AND NPCS
-- ==========================================
local LastShopLabel = ShopTab:CreateParagraph({Title = "Recent Trade", Content = "Waiting..."})
ShopTab:CreateToggle({Name = "Enable Trade Tracker", CurrentValue = false, Flag = "ShopSpyToggle", Callback = function(V) ShopSpyEnabled = V end})
ShopTab:CreateButton({
   Name = "Copy Trade Log",
   Callback = function()
        if setclipboard then
            local text = "=== TRADE REPORT ===\n"
            for i, log in ipairs(ShopLogs) do text = text .. string.format("[%d] %s | %s\nDetails: %s\n\n", i, log.Path, log.Type, log.Details) end
            setclipboard(text)
        end
   end,
})

local function LogShopInteraction(interType, path, detailsTable)
    local timeStamp = os.date("%H:%M:%S")
    local detailsStr = ""
    for k, v in pairs(detailsTable) do detailsStr = detailsStr .. string.format("\n• %s: %s", tostring(k), tostring(v)) end
    table.insert(ShopLogs, {Time = timeStamp, Type = interType, Path = path, Details = detailsStr})
    task.spawn(function() LastShopLabel:Set({Title = "🛒 Trade Capture", Content = string.format("Time: %s\nPath: %s%s", timeStamp, path, detailsStr)}) end)
end

-- ==========================================
-- SECTION 5: INVENTORY AND GUI
-- ==========================================
InvTab:CreateToggle({
   Name = "Enable Inventory and GUI Monitor",
   CurrentValue = false,
   Flag = "InvSpyToggle",
   Callback = function(Value)
        InvSpyEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Monitor Active", Content = "Listening to backpacks, tools, selectors, and UI clicks...", Duration = 4})
        end
   end,
})

local LastInvLabel = InvTab:CreateParagraph({
    Title = "Recent GUI / Inventory Interaction",
    Content = "Equip a pickaxe, press an inventory button, or pick up a diamond..."
})

InvTab:CreateButton({
   Name = "Copy GUI and Inventory Log",
   Callback = function()
        if not setclipboard then return end
        if #InvLogs == 0 then Rayfield:Notify({Title = "Empty", Content = "No logs available.", Duration = 3}) return end
        
        local clipboardText = "🎒 === PLAYER INVENTORY AND GUI LOG === 🎒\n\n"
        for i, log in ipairs(InvLogs) do
            clipboardText = clipboardText .. string.format(
                "[%d] Time: %s\nType: %s\nElement Path: %s\nAttributes: %s\n======================================\n", 
                i, log.Time, log.Type, log.Path, log.Details
            )
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "Copied!", Content = "Inventory log copied to clipboard.", Duration = 3})
   end,
})

InvTab:CreateButton({
   Name = "Clear Inventory Log",
   Callback = function()
        InvLogs = {}
        LastInvLabel:Set({Title = "Recent Interaction", Content = "History cleared."})
   end,
})

-- Logistics Function for Inventory
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
            Title = "🎒 Capture: " .. interType,
            Content = string.format("Time: %s\nElement: %s%s", timeStamp, path, detailsStr)
        })
    end)
    print(string.format("[GUI/INV SPY] [%s] %s -> %s", timeStamp, interType, path))
end

-- Physical Detection for Backpack and Equipment (Tools, Pickaxes, Diamonds)
LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
        LogInventoryInteraction("Item Received / Unequipped", child:GetFullName(), {
            ["Name"] = child.Name,
            ["Class"] = child.ClassName,
            ["Event Type"] = "Entered Backpack"
        })
    end
end)

local function HookCharacterInventory(char)
    char.ChildAdded:Connect(function(child)
        if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
            LogInventoryInteraction("Item Equipped", child:GetFullName(), {
                ["Name"] = child.Name,
                ["Class"] = child.ClassName,
                ["Event Type"] = "Tool activated in player's hands"
            })
        end
    end)
end

if LocalPlayer.Character then HookCharacterInventory(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookCharacterInventory)

-- Detection for GUI Clicks (PlayerGui)
local function HookGUIElement(obj)
    if obj:IsA("GuiButton") then
        obj.MouseButton1Click:Connect(function()
            if InvSpyEnabled then
                LogInventoryInteraction("Interface Click (GUI)", obj:GetFullName(), {
                    ["Button Name"] = obj.Name,
                    ["Text"] = obj:IsA("TextButton") and obj.Text or "(Is ImageButton)",
                    ["Parent Visibility"] = obj.Parent and tostring(obj.Parent.Visible) or "Unknown"
                })
            end
        end)
    end
end

-- Connect all existing UI buttons and future ones (Item menus, selectors)
for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do pcall(HookGUIElement, desc) end
LocalPlayer.PlayerGui.DescendantAdded:Connect(function(desc) pcall(HookGUIElement, desc) end)

-- ==========================================
-- SECTION 6: DEEP SHOP SCANNER (PICOS, BOMBAS, ETC) 🔎
-- ==========================================
local DeepShopStatus = DeepShopTab:CreateParagraph({
    Title = "Datos de Tienda Extraídos",
    Content = "Inicia un escaneo para buscar picos, bombas, armas y catálogos ocultos en el juego."
})

DeepShopTab:CreateButton({
    Name = "Escanear Catálogos de Tienda (Storage/Gui)",
    Callback = function()
        local foundItems = {}
        -- Términos clave a buscar en las entrañas del juego
        local searchTerms = {"pico", "pickaxe", "bomba", "bomb", "shop", "store", "price", "precio", "weapon", "item", "stats"}
        
        -- Función de búsqueda profunda en los archivos del cliente
        local function scanDirectory(dir, label)
            for _, obj in ipairs(dir:GetDescendants()) do
                for _, term in ipairs(searchTerms) do
                    if string.find(string.lower(obj.Name), term) then
                        if obj:IsA("Tool") or obj:IsA("Folder") or obj:IsA("Configuration") then
                            table.insert(foundItems, string.format("[%s] %s (%s)", label, obj:GetFullName(), obj.ClassName))
                            break
                        elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            -- Captura valores exactos (como precios o daño)
                            table.insert(foundItems, string.format("[%s Valor Numérico] %s = %s", label, obj:GetFullName(), tostring(obj.Value)))
                            break
                        elseif obj:IsA("ModuleScript") then
                            -- Los ModuleScripts suelen contener las tablas de precios e items
                            table.insert(foundItems, string.format("[%s CATÁLOGO MÓDULO] %s", label, obj:GetFullName()))
                            break
                        end
                    end
                end
            end
        end

        -- Escaneamos las dos áreas donde los juegos guardan la info de las tiendas
        scanDirectory(game:GetService("ReplicatedStorage"), "ServerStorage")
        scanDirectory(LocalPlayer.PlayerGui, "LocalGUI")
        scanDirectory(game:GetService("Workspace"), "Mundo (Workspace)")
        
        if #foundItems > 0 then
            local resultText = table.concat(foundItems, "\n")
            if setclipboard then 
                setclipboard("=== CATÁLOGO PROFUNDO DE TIENDA ===\n\n" .. resultText) 
            end
            
            DeepShopStatus:Set({
                Title = "¡Escaneo Completado! (" .. #foundItems .. " elementos)",
                Content = "Se encontraron picos, bombas y catálogos. Se ha copiado toda la ruta y valores al portapapeles. Pégalo en un bloc de notas para analizar las carpetas ocultas."
            })
            Rayfield:Notify({Title="Escaneo Exitoso", Content="Datos profundos copiados al portapapeles.", Duration=4})
        else
            DeepShopStatus:Set({Title = "Resultado", Content = "No se encontraron picos, bombas ni catálogos con esos términos."})
        end
    end,
})

DeepShopTab:CreateButton({
    Name = "Destrabar GUI Manualmente",
    Callback = function()
        -- Por si algo se queda bugeado en la pantalla
        InspectorEnabled = false
        NPCInspectorEnabled = false
        Highlight.Adornee = nil
        Rayfield:Notify({Title="GUI Liberada", Content="El inspector está apagado. Usa el Keybind (RightShift) para ocultar el menú y comprar.", Duration=5})
    end,
})


-- ==========================================
-- GENERAL NETWORK HOOKING (__namecall)
-- ==========================================
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local argType = typeof(v)
        if argType == "string" then result = result .. '"' .. v .. '"'
        elseif argType == "Instance" then result = result .. v:GetFullName()
        elseif argType == "table" then
            local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(v) end)
            result = result .. (ok and json or "{Table}")
        else result = result .. tostring(v) end
        if i < #args then result = result .. ", " end
    end
    return result == "" and "None" or result
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local path = self:GetFullName()
        local formattedArgs = FormatArguments(args)
        local timeStamp = os.date("%H:%M:%S")

        -- 1. General Network
        if SpyEnabled then
            table.insert(ActionLogs, {Time = timeStamp, Path = path, Method = method, Args = formattedArgs})
            task.spawn(function() LastActionLabel:Set({Title = "Interaction!", Content = path .. "\n" .. formattedArgs}) end)
        end

        -- 2. Shop Filter
        if ShopSpyEnabled then
            local strData = string.lower(path .. formattedArgs)
            local keywords = {"buy", "shop", "store", "sell", "npc", "comprar"}
            for _, w in ipairs(keywords) do
                if string.find(strData, w) then
                    LogShopInteraction("Transaction", path, {["Args"] = formattedArgs})
                    break
                end
            end
        end
        
        -- 3. Inventory/GUI Filter
        if InvSpyEnabled then
            local strData = string.lower(path .. formattedArgs)
            local invKeywords = {"equip", "unequip", "inventory", "backpack", "tool", "select", "slot", "hotbar", "item", "drop", "pickup", "inv"}
            for _, w in ipairs(invKeywords) do
                if string.find(strData, w) then
                    LogInventoryInteraction("Network Event (Inventory/GUI)", path, {
                        ["Method"] = method,
                        ["Arguments"] = formattedArgs,
                        ["Trigger Keyword"] = w
                    })
                    break
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

-- Physical Interaction Events
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player == LocalPlayer and ShopSpyEnabled then
        LogShopInteraction("ProximityPrompt", prompt:GetFullName(), {["Action"] = prompt.ActionText})
    end
end)
