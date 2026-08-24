--[[
    Catalog Native Buyer v4
    - Búsqueda estable (roblox.com → roproxy)
    - Prompt nativo reforzado
    - Alerta emergente + Copiar Log (iPhone compatible)
    - Botón flotante + cierre
]]

local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local GuiService         = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ===================== CONFIG =====================
local DEFAULT_CATEGORY = 1
local DEFAULT_LIMIT    = 30

-- ===================== UTILIDADES =====================
local function protectGui(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        elseif get_hidden_gui then
            gui.Parent = get_hidden_gui()
        else
            gui.Parent = CoreGui
        end
    end)
end

local function notify(title, text, duration)
    duration = duration or 4
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

local function setClipboard(text)
    local ok = false
    pcall(function()
        if setclipboard then setclipboard(text) ok = true end
    end)
    if not ok then pcall(function() if toclipboard then toclipboard(text) ok = true end end) end
    if not ok then pcall(function() if syn and syn.setclipboard then syn.setclipboard(text) ok = true end end) end
    if not ok then pcall(function() if Clipboard and Clipboard.set then Clipboard.set(text) ok = true end end) end
    if not ok then pcall(function() if writeclipboard then writeclipboard(text) ok = true end end) end
    return ok
end

-- ===================== ALERTA EMERGENTE + COPIAR LOG =====================
local function showErrorAlert(fullLog, assetId)
    -- Evitar múltiples alertas
    if ScreenGui:FindFirstChild("ErrorAlert") then
        ScreenGui.ErrorAlert:Destroy()
    end

    local alert = Instance.new("Frame")
    alert.Name = "ErrorAlert"
    alert.Size = isMobile and UDim2.new(0.92, 0, 0, 320) or UDim2.new(0, 380, 0, 340)
    alert.Position = isMobile and UDim2.new(0.04, 0, 0.5, -160) or UDim2.new(0.5, -190, 0.5, -170)
    alert.BackgroundColor3 = Color3.fromRGB(18, 14, 16)
    alert.BorderSizePixel = 0
    alert.ZIndex = 50
    alert.Parent = ScreenGui
    Instance.new("UICorner", alert).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 60, 70)
    stroke.Thickness = 1.5
    stroke.Parent = alert

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "⚠ NINGÚN PROMPT NATIVO FUNCIONÓ"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 160, 160)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = alert

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -20, 0, 20)
    idLabel.Position = UDim2.new(0, 10, 0, 42)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "Asset ID: " .. tostring(assetId)
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 12
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = alert

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 180)
    scroll.Position = UDim2.new(0, 10, 0, 68)
    scroll.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = alert
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -10, 0, 0)
    logLabel.Position = UDim2.new(0, 6, 0, 6)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = fullLog
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 11
    logLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextWrapped = true
    logLabel.Parent = scroll

    -- Ajustar altura del texto
    local textSize = game:GetService("TextService"):GetTextSize(fullLog, 11, Enum.Font.Code, Vector2.new(scroll.AbsoluteSize.X - 20, 9999))
    logLabel.Size = UDim2.new(1, -12, 0, textSize.Y + 10)
    scroll.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 20)

    -- Botones
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.48, -6, 0, 40)
    copyBtn.Position = UDim2.new(0, 10, 1, -52)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
    copyBtn.Text = "📋 COPIAR LOG"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 13
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Parent = alert
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 9)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.48, -6, 0, 40)
    closeBtn.Position = UDim2.new(0.52, 0, 1, -52)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
    closeBtn.Text = "CERRAR"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    closeBtn.Parent = alert
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 9)

    copyBtn.MouseButton1Click:Connect(function()
        local success = setClipboard(fullLog)
        if success then
            copyBtn.Text = "✅ COPIADO"
            copyBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
            notify("Copiado", "Log copiado al portapapeles", 3)
        else
            copyBtn.Text = "❌ FALLÓ"
            notify("Error", "No se pudo copiar (ejecutor sin setclipboard)", 3)
        end
        task.wait(1.5)
        copyBtn.Text = "📋 COPIAR LOG"
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alert:Destroy()
    end)
end

-- ===================== PROMPT NATIVO REFORZADO =====================
local function promptNativePurchase(assetId, itemType)
    assetId = tonumber(assetId)
    if not assetId then
        notify("Error", "ID inválido", 3)
        return false
    end

    local log = {}
    local player = LocalPlayer
    local successCount = 0

    table.insert(log, "=== LOG DE COMPRA NATIVA ===")
    table.insert(log, "Asset ID: " .. tostring(assetId))
    table.insert(log, "ItemType: " .. tostring(itemType))
    table.insert(log, "Player: " .. tostring(player and player.Name))
    table.insert(log, "Character: " .. tostring(player and player.Character and "existe" or "NO existe"))
    table.insert(log, "Hora: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(log, "--------------------------------")

    -- Método 1: PromptPurchase estándar
    local ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId)
    end)
    table.insert(log, "1. PromptPurchase: " .. (ok and "OK (sin error)" or tostring(err)))
    if ok then successCount = successCount + 1 end

    task.wait(0.15)

    -- Método 2: con equipIfPurchased = true
    ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId, true)
    end)
    table.insert(log, "2. PromptPurchase(equip=true): " .. (ok and "OK" or tostring(err)))
    if ok then successCount = successCount + 1 end

    task.wait(0.15)

    -- Método 3: Bundle
    if tostring(itemType):lower():find("bundle") or itemType == 2 then
        ok, err = pcall(function()
            MarketplaceService:PromptBundlePurchase(player, assetId)
        end)
        table.insert(log, "3. PromptBundlePurchase: " .. (ok and "OK" or tostring(err)))
        if ok then successCount = successCount + 1 end
    else
        table.insert(log, "3. PromptBundlePurchase: omitido (no es bundle)")
    end

    task.wait(0.15)

    -- Método 4: GetProductInfo + Prompt
    local info
    ok, err = pcall(function()
        info = MarketplaceService:GetProductInfo(assetId)
    end)
    table.insert(log, "4. GetProductInfo: " .. (ok and ("OK - Name: " .. tostring(info and info.Name)) or tostring(err)))

    if ok and info then
        ok, err = pcall(function()
            MarketplaceService:PromptPurchase(player, assetId)
        end)
        table.insert(log, "4b. Prompt tras GetProductInfo: " .. (ok and "OK" or tostring(err)))
        if ok then successCount = successCount + 1 end
    end

    task.wait(0.2)

    -- Método 5: Intentar forzar desde el servicio de avatar (algunos ejecutores)
    ok, err = pcall(function()
        local AES = game:GetService("AvatarEditorService")
        if AES then
            -- Algunos builds tienen métodos internos
            if AES.PromptPurchase then
                AES:PromptPurchase(assetId)
            end
        end
    end)
    table.insert(log, "5. AvatarEditorService: " .. (ok and "OK" or tostring(err)))

    -- Método 6: Verificar si el prompt apareció en CoreGui
    task.wait(0.4)
    local promptFound = false
    pcall(function()
        for _, gui in pairs(CoreGui:GetDescendants()) do
            if gui.Name:lower():find("purchase") or gui.Name:lower():find("prompt") then
                if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                    promptFound = true
                    break
                end
            end
        end
    end)
    table.insert(log, "6. Prompt visible en CoreGui: " .. tostring(promptFound))

    table.insert(log, "--------------------------------")
    table.insert(log, "Métodos que no lanzaron error: " .. successCount)
    table.insert(log, "Si el prompt no apareció visualmente, el item puede estar:")
    table.insert(log, "- Offsale / No disponible en tu región")
    table.insert(log, "- Ya lo posees")
    table.insert(log, "- Es Limited / Collectible con restricciones")
    table.insert(log, "- El ejecutor bloquea el prompt nativo")

    local fullLog = table.concat(log, "\n")
    warn(fullLog)

    -- Si no se detectó el prompt visualmente, mostrar alerta
    if not promptFound then
        showErrorAlert(fullLog, assetId)
        notify("Prompt falló", "Se abrió el log de error. Copia el log si necesitas ayuda.", 5)
        return false
    else
        notify("Prompt abierto", "El menú nativo debería estar visible", 3)
        return true
    end
end

-- ===================== BÚSQUEDA (MÉTODO ESTABLE) =====================
local function searchCatalog(keyword, category, limit, cursor)
    category = category or DEFAULT_CATEGORY
    limit    = limit or DEFAULT_LIMIT
    cursor   = cursor or ""

    local url = "https://catalog.roblox.com/v1/search/items/details?category=" 
        .. tostring(category) 
        .. "&limit=" .. tostring(limit) 
        .. "&keyword=" .. HttpService:UrlEncode(keyword or "")

    if cursor ~= "" then
        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
    end

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not response or response == "" then
        url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
        success, response = pcall(function()
            return game:HttpGet(url)
        end)
    end

    if not success or not response or response == "" then
        return nil, "Error de red (ambos dominios fallaron)"
    end

    local decoded
    local decodeOk = pcall(function()
        decoded = HttpService:JSONDecode(response)
    end)

    if not decodeOk or not decoded or not decoded.data then
        return nil, "Error al decodificar JSON"
    end

    return decoded.data, "OK"
end

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatalogNativeBuyerV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectGui(ScreenGui)

-- Botón flotante
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleFloat"
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = isMobile and UDim2.new(1, -70, 0.5, -26) or UDim2.new(1, -70, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
ToggleBtn.Text = "🛒"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(60, 60, 80)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = ToggleBtn

do
    local dragging, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    ToggleBtn.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Menú principal
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = isMobile and UDim2.new(0.94, 0, 0.82, 0) or UDim2.new(0, 440, 0, 540)
Main.Position = isMobile and UDim2.new(0.03, 0, 0.09, 0) or UDim2.new(0.5, -220, 0.5, -270)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(40, 40, 55)
mainStroke.Thickness = 1.2
mainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CATALOG • NATIVE BUY"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(235, 235, 245)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -19)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(220, 180, 180)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 9)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -110, 0, 40)
SearchBox.Position = UDim2.new(0, 14, 0, 62)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
SearchBox.PlaceholderText = "Buscar (Dominus, Valkyrie, etc.)"
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 240)
SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 80, 0, 40)
SearchBtn.Position = UDim2.new(1, -94, 0, 62)
SearchBtn.BackgroundColor3 = Color3.fromRGB(35, 85, 170)
SearchBtn.Text = "BUSCAR"
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 13
SearchBtn.TextColor3 = Color3.new(1, 1, 1)
SearchBtn.Parent = Main
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 10)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -28, 0, 20)
Status.Position = UDim2.new(0, 14, 0, 108)
Status.BackgroundTransparency = 1
Status.Text = "Listo • Método estable + prompt reforzado"
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextColor3 = Color3.fromRGB(140, 140, 160)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Results = Instance.new("ScrollingFrame")
Results.Size = UDim2.new(1, -28, 1, -140)
Results.Position = UDim2.new(0, 14, 0, 132)
Results.BackgroundTransparency = 1
Results.BorderSizePixel = 0
Results.ScrollBarThickness = 4
Results.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
Results.CanvasSize = UDim2.new(0, 0, 0, 0)
Results.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Results

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Results.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Render
local function clearResults()
    for _, c in ipairs(Results:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function createItemCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 68)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    card.BorderSizePixel = 0
    card.Parent = Results
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 11)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(32, 32, 42)
    stroke.Thickness = 1
    stroke.Parent = card

    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 54, 0, 54)
    thumb.Position = UDim2.new(0, 7, 0.5, -27)
    thumb.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
    thumb.Parent = card
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -150, 0, 22)
    name.Position = UDim2.new(0, 70, 0, 12)
    name.BackgroundTransparency = 1
    name.Text = item.name or "Sin nombre"
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 13
    name.TextColor3 = Color3.fromRGB(235, 235, 245)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = card

    local price = Instance.new("TextLabel")
    price.Size = UDim2.new(1, -150, 0, 18)
    price.Position = UDim2.new(0, 70, 0, 36)
    price.BackgroundTransparency = 1
    local p = item.price or item.lowestPrice or item.highestPrice or 0
    price.Text = (tonumber(p) == 0 and "Gratis / Offsale") or (tostring(p) .. " R$")
    price.Font = Enum.Font.Gotham
    price.TextSize = 12
    price.TextColor3 = Color3.fromRGB(130, 200, 140)
    price.TextXAlignment = Enum.TextXAlignment.Left
    price.Parent = card

    local buy = Instance.new("TextButton")
    buy.Size = UDim2.new(0, 72, 0, 34)
    buy.Position = UDim2.new(1, -82, 0.5, -17)
    buy.BackgroundColor3 = Color3.fromRGB(40, 95, 185)
    buy.Text = "COMPRAR"
    buy.Font = Enum.Font.GothamBold
    buy.TextSize = 11
    buy.TextColor3 = Color3.new(1, 1, 1)
    buy.Parent = card
    Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 8)

    buy.MouseButton1Click:Connect(function()
        buy.Text = "..."
        buy.BackgroundColor3 = Color3.fromRGB(30, 65, 130)
        task.spawn(function()
            local itemType = item.itemType or (item.bundleId and "Bundle") or "Asset"
            promptNativePurchase(item.id, itemType)
            task.wait(0.8)
            buy.Text = "COMPRAR"
            buy.BackgroundColor3 = Color3.fromRGB(40, 95, 185)
        end)
    end)
end

-- Búsqueda
local searching = false
local function doSearch()
    if searching then return end
    local keyword = SearchBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if keyword == "" then
        Status.Text = "Escribe un término de búsqueda"
        notify("Aviso", "Escribe algo para buscar", 2)
        return
    end

    searching = true
    clearResults()
    Status.Text = "Buscando... (roblox.com → roproxy)"
    Status.TextColor3 = Color3.fromRGB(180, 180, 100)
    SearchBtn.Text = "..."
    SearchBtn.BackgroundColor3 = Color3.fromRGB(25, 55, 110)

    task.spawn(function()
        local items, msg = searchCatalog(keyword, DEFAULT_CATEGORY, DEFAULT_LIMIT)

        if items and #items > 0 then
            for _, item in ipairs(items) do
                createItemCard(item)
            end
            Status.Text = #items .. " resultados • " .. (msg or "OK")
            Status.TextColor3 = Color3.fromRGB(130, 200, 140)
            notify("Éxito", #items .. " items encontrados", 3)
        else
            Status.Text = "Nada encontrado • " .. (msg or "Error de red")
            Status.TextColor3 = Color3.fromRGB(220, 120, 120)
            notify("Sin resultados", msg or "Error de red / sin resultados", 4)
        end

        searching = false
        SearchBtn.Text = "BUSCAR"
        SearchBtn.BackgroundColor3 = Color3.fromRGB(35, 85, 170)
    end)
end

SearchBtn.MouseButton1Click:Connect(doSearch)
SearchBox.FocusLost:Connect(function(enter)
    if enter then doSearch() end
end)

print("[Catalog Native Buyer v4] Cargado | Prompt reforzado + alerta con copiar log")
notify("Listo", "Menú cargado • Toca el botón flotante 🛒", 4)
