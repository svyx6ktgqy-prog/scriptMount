-- ==========================================
-- CARGA DE LIBRERÍA RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Optimizada para móviles (Delta)",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- ==========================================
-- VARIABLES GLOBALES Y FUNCIONES BASE
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ProximityPromptService = game:GetService("ProximityPromptService")

local InvLogs = {}
local MaxLogs = 50
local InvSpyEnabled = false
local ShopSpyEnabled = false -- Lo defino para evitar errores con el ProximityPrompt

-- Función temporal por si usabas LogShopInteraction en otra pestaña
local function LogShopInteraction(interType, path, detailsTable)
    local timeStamp = os.date("%H:%M:%S")
    print(string.format("[SHOP SPY] [%s] %s -> %s", timeStamp, interType, path))
end

-- ==========================================
-- CREACIÓN DE PESTAÑA: INVENTORY AND GUI
-- ==========================================
local InvTab = Window:CreateTab("Inv & GUI Spy", 4483362458) -- El número es un icono por defecto

InvTab:CreateToggle({
   Name = "Enable Inventory and GUI Monitor",
   CurrentValue = false,
   Flag = "InvSpyToggle",
   Callback = function(Value)
        InvSpyEnabled = Value
        if Value then
            Rayfield:Notify({Title = "Monitor Activo", Content = "Escuchando mochilas, herramientas y clics de UI...", Duration = 4})
        end
   end,
})

local LastInvLabel = InvTab:CreateParagraph({
    Title = "Interacción Reciente",
    Content = "Equipa una herramienta, presiona un botón o recoge un objeto..."
})

InvTab:CreateButton({
   Name = "Copy GUI and Inventory Log",
   Callback = function()
        if not setclipboard then 
            Rayfield:Notify({Title = "Error", Content = "Tu ejecutor no soporta setclipboard.", Duration = 3})
            return 
        end
        
        if #InvLogs == 0 then 
            Rayfield:Notify({Title = "Vacío", Content = "No hay registros disponibles.", Duration = 3}) 
            return 
        end
        
        local clipboardText = "🎒 === PLAYER INVENTORY AND GUI LOG === 🎒\n\n"
        for i, log in ipairs(InvLogs) do
            clipboardText = clipboardText .. string.format(
                "[%d] Time: %s\nType: %s\nElement Path: %s\nAttributes: %s\n======================================\n", 
                i, log.Time, log.Type, log.Path, log.Details
            )
        end
        setclipboard(clipboardText)
        Rayfield:Notify({Title = "¡Copiado!", Content = "Registro copiado al portapapeles.", Duration = 3})
   end,
})

InvTab:CreateButton({
   Name = "Clear Inventory Log",
   Callback = function()
        InvLogs = {}
        LastInvLabel:Set({Title = "Interacción Reciente", Content = "Historial limpiado."})
   end,
})

-- ==========================================
-- LÓGICA DE DETECCIÓN (SIN NAMECALL)
-- ==========================================
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
            Content = string.format("Time: %s\nElement: %s%s", timeStamp, path, detailsStr)
        })
    end)
    print(string.format("[GUI/INV SPY] [%s] %s -> %s", timeStamp, interType, path))
end

-- 1. Detección de Mochila y Herramientas (Físico)
if LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        pcall(function()
            if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
                LogInventoryInteraction("Objeto Recibido / Desequipado", child:GetFullName(), {
                    ["Name"] = child.Name,
                    ["Class"] = child.ClassName,
                    ["Event Type"] = "Entró a la mochila"
                })
            end
        end)
    end)
end

local function HookCharacterInventory(char)
    char.ChildAdded:Connect(function(child)
        pcall(function()
            if InvSpyEnabled and (child:IsA("Tool") or child:IsA("HopperBin")) then
                LogInventoryInteraction("Objeto Equipado", child:GetFullName(), {
                    ["Name"] = child.Name,
                    ["Class"] = child.ClassName,
                    ["Event Type"] = "Herramienta activada en las manos"
                })
            end
        end)
    end)
end

if LocalPlayer.Character then HookCharacterInventory(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookCharacterInventory)

-- 2. Detección de Clics en la Interfaz (PlayerGui)
local function HookGUIElement(obj)
    pcall(function()
        if obj:IsA("GuiButton") then
            obj.MouseButton1Click:Connect(function()
                if InvSpyEnabled then
                    LogInventoryInteraction("Clic en Interfaz (GUI)", obj:GetFullName(), {
                        ["Button Name"] = obj.Name,
                        ["Text"] = obj:IsA("TextButton") and obj.Text or "(Es ImageButton)",
                        ["Parent Visibility"] = obj.Parent and tostring(obj.Parent.Visible) or "Desconocido"
                    })
                end
            end)
        end
    end)
end

task.spawn(function()
    for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do 
        HookGUIElement(desc) 
    end
end)

LocalPlayer.PlayerGui.DescendantAdded:Connect(HookGUIElement)

-- 3. Detección de ProximityPrompts (Interacciones físicas con el entorno)
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    pcall(function()
        if player == LocalPlayer and ShopSpyEnabled then
            LogShopInteraction("ProximityPrompt", prompt:GetFullName(), {["Action"] = prompt.ActionText})
        end
    end)
end)
