--[[
    Catalog Native Buyer v5
    - Menú forzado visible + botón flotante grande
    - Prompt nativo ultra-robusto
    - Alerta de error completa con log + copiar (iPhone)
    - Búsqueda estable (roblox.com → roproxy)
]]

local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")
local TextService        = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled

-- ===================== CONFIG =====================
local DEFAULT_CATEGORY = 1
local DEFAULT_LIMIT    = 30

-- ===================== UTILIDADES =====================
local function protectGui(gui)
    local success = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
    
    pcall(function()
        if gethui then
            gui.Parent = gethui()
        elseif get_hidden_gui then
            gui.Parent = get_hidden_gui()
        elseif CoreGui then
            gui.Parent = CoreGui
        else
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
end

local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 4
        })
    end)
end

local function setClipboard(text)
    local funcs = {
        function() if setclipboard then setclipboard(text) return true end end,
        function() if toclipboard then toclipboard(text) return true end end,
        function() if syn and syn.setclipboard then syn.setclipboard(text) return true end end,
        function() if Clipboard and Clipboard.set then Clipboard.set(text) return true end end,
        function() if writeclipboard then writeclipboard(text) return true end end,
    }
    for _, f in ipairs(funcs) do
        local ok, res = pcall(f)
        if ok and res then return true end
    end
    return false
end

-- ===================== ALERTA DE ERROR (COMPLETA) =====================
local ScreenGui -- se declara después

local function showErrorAlert(fullLog, assetId)
    pcall(function()
        if ScreenGui:FindFirstChild("ErrorAlert") then
            ScreenGui.ErrorAlert:Destroy()
        end
    end)

    local alert = Instance.new("Frame")
    alert.Name = "ErrorAlert"
    alert.Size = isMobile and UDim2.new(0.94, 0, 0, 340) or UDim2.new(0, 400, 0, 360)
    alert.Position = isMobile and UDim2.new(0.03, 0, 0.5, -170) or UDim2.new(0.5, -200, 0.5, -180)
    alert.BackgroundColor3 = Color3.fromRGB(16, 12, 14)
    alert.BorderSizePixel = 0
    alert.ZIndex = 100
    alert.Parent = ScreenGui
    Instance.new("UICorner", alert).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 50, 60)
    stroke.Thickness = 2
    stroke.Parent = alert

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 34)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "⚠ NINGÚN PROMPT NATIVO FUNCIONÓ"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 150, 150)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = alert

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -20, 0, 18)
    idLabel.Position = UDim2.new(0, 10, 0, 40)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "Asset ID: " .. tostring(assetId or "?")
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 12
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.ZIndex = 101
    idLabel.Parent = alert

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 200)
    scroll.Position = UDim2.new(0, 10, 0, 64)
    scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 101
    scroll.Parent = alert
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -12, 0, 0)
    logLabel.Position = UDim2.new(0, 6, 0, 6)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = fullLog or "Sin log"
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 11
    logLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextWrapped = true
    logLabel.ZIndex = 102
    logLabel.Parent = scroll

    local textSize = TextService:GetTextSize(fullLog or "", 11, Enum.Font.Code, Vector2.new(360, 9999))
    logLabel.Size = UDim2.new(1, -12, 0, math.max(textSize.Y + 20, 180))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textSize.Y + 30, 200))

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.48, -8, 0, 42)
    copyBtn.Position = UDim2.new(0, 10, 1, -54)
    copyBtn.BackgroundColor3 = Color3.fromRGB(35, 90, 170)
    copyBtn.Text = "📋 COPIAR LOG"
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 13
    copyBtn.TextColor3 = Color3.new(1,1,1)
    copyBtn.ZIndex = 101
    copyBtn.Parent = alert
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 9)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.48, -8, 0, 42)
    closeBtn.Position = UDim2.new(0.52, 0, 1, -54)
    closeBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 35)
    closeBtn.Text = "CERRAR"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    closeBtn.ZIndex = 101
    closeBtn.Parent = alert
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 9)

    copyBtn.MouseButton1Click:Connect(function()
        local ok = setClipboard(fullLog)
        if ok then
            copyBtn.Text = "✅ COPIADO"
            copyBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 60)
            notify("Copiado", "Log copiado al portapapeles", 3)
        else
            copyBtn.Text = "❌ FALLÓ"
            notify("Error", "Tu ejecutor no soporta setclipboard", 3)
        end
        task.delay(1.8, function()
            copyBtn.Text = "📋 COPIAR LOG"
            copyBtn.BackgroundColor3 = Color3.fromRGB(35, 90, 170)
        end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alert:Destroy()
    end)
end

-- ===================== PROMPT NATIVO ULTRA-ROBUSTO =====================
local function promptNativePurchase(assetId, itemType)
    assetId = tonumber(assetId)
    if not assetId then
        notify("Error", "ID inválido", 3)
        return false
    end

    local log = {}
    local player = LocalPlayer
    table.insert(log, "=== LOG PROMPT NATIVO v5 ===")
    table.insert(log, "Asset ID: " .. tostring(assetId))
    table.insert(log, "ItemType pasado: " .. tostring(itemType))
    table.insert(log, "Player: " .. tostring(player and player.Name or "nil"))
    table.insert(log, "Character existe: " .. tostring(player and player.Character ~= nil))
    table.insert(log, "Hora: " .. os.date("%H:%M:%S"))
    table.insert(log, "--------------------------------")

    local methodsTried = 0
    local methodsOk = 0

    -- Método 1
    methodsTried = methodsTried + 1
    local ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId)
    end)
    table.insert(log, "1. PromptPurchase: " .. (ok and "sin error" or tostring(err)))
    if ok then methodsOk = methodsOk + 1 end
    task.wait(0.12)

    -- Método 2
    methodsTried = methodsTried + 1
    ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId, true)
    end)
    table.insert(log, "2. PromptPurchase(equip): " .. (ok and "sin error" or tostring(err)))
    if ok then methodsOk = methodsOk + 1 end
    task.wait(0.12)

    -- Método 3 - Bundle
    methodsTried = methodsTried + 1
    if tostring(itemType):lower():find("bundle") or itemType == 2 then
        ok, err = pcall(function()
            MarketplaceService:PromptBundlePurchase(player, assetId)
        end)
        table.insert(log, "3. PromptBundlePurchase: " .. (ok and "sin error" or tostring(err)))
        if ok then methodsOk = methodsOk + 1 end
    else
        table.insert(log, "3. PromptBundlePurchase: omitido")
    end
    task.wait(0.12)

    -- Método 4 - GetProductInfo primero
    methodsTried = methodsTried + 1
    local info
    ok, err = pcall(function()
        info = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
    end)
    table.insert(log, "4. GetProductInfo: " .. (ok and ("OK → " .. tostring(info and info.Name)) or tostring(err)))
    
    if ok and info then
        ok, err = pcall(function()
            MarketplaceService:PromptPurchase(player, assetId)
        end)
        table.insert(log, "4b. Prompt después de GetProductInfo: " .. (ok and "sin error" or tostring(err)))
        if ok then methodsOk = methodsOk + 1 end
    end
    task.wait(0.15)

    -- Método 5 - Intento extra con pcall anidado
    methodsTried = methodsTried + 1
    ok, err = pcall(function()
        local ms = game:GetService("MarketplaceService")
        ms:PromptPurchase(game.Players.LocalPlayer, assetId)
    end)
    table.insert(log, "5. PromptPurchase (re-get service): " .. (ok and "sin error" or tostring(err)))
    if ok then methodsOk = methodsOk + 1 end

    task.wait(0.5)

    -- Detectar si el prompt realmente apareció
    local promptVisible = false
    pcall(function()
        for _, obj in pairs(CoreGui:GetDescendants()) do
            local n = string.lower(obj.Name)
            if (n:find("purchase") or n:find("prompt") or n:find("buy")) and (obj:IsA("Frame") or obj:IsA("ScreenGui") or obj:IsA("TextButton")) then
                if obj.Visible then
                    promptVisible = true
                    break
                end
            end
        end
    end)

    table.insert(log, "--------------------------------")
    table.insert(log, "Métodos intentados: " .. methodsTried)
    table.insert(log, "Métodos sin error de Lua: " .. methodsOk)
    table.insert(log, "Prompt visible en CoreGui: " .. tostring(promptVisible))
    table.insert(log, "")
    table.insert(log, "Posibles causas si no aparece:")
    table.insert(log, "- Item offsale / no disponible en tu región")
    table.insert(log, "- Ya lo posees")
    table.insert(log, "- Limited / Collectible restringido")
    table.insert(log, "- El ejecutor bloquea el prompt nativo")
    table.insert(log, "- Character no cargado (algunos casos)")

    local fullLog = table.concat(log, "\n")
    warn(fullLog)

    if not promptVisible then
        showErrorAlert(fullLog, assetId)
        notify("Prompt no visible", "Se abrió el log de error. Usa COPIAR LOG.", 5)
        return false
    else
        notify("Prompt detectado", "El menú nativo debería estar visible", 3)
        return true
    end
end

-- ===================== BÚSQUEDA ESTABLE =====================
local function searchCatalog(keyword, category, limit)
    category = category or DEFAULT_CATEGORY
    limit = limit or DEFAULT_LIMIT

    local url = "https://catalog.roblox.com/v1/search/items/details?category=" 
        .. tostring(category) 
        .. "&limit=" .. tostring(limit) 
        .. "&keyword=" .. HttpService:UrlEncode(keyword or "")

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not response or #response < 10 then
        url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
        success, response = pcall(function()
            return game:HttpGet(url)
        end)
    end

    if not success or not response then
        return nil, "Error de red (ambos fallaron)"
    end

    local decoded
    local ok = pcall(function()
        decoded = HttpService:JSONDecode(response)
    end)

    if not ok or not decoded or not decoded.data then
        return nil, "Error JSON"
    end

    return decoded.data, "OK"
end

-- ===================== CREACIÓN DEL MENÚ (FORZADO) =====================
local function createMenu()
    -- Limpiar anterior si existe
    pcall(function()
        if game:GetService("CoreGui"):FindFirstChild("CatalogNativeBuyerV5") then
            game:GetService("CoreGui").CatalogNativeBuyerV5:Destroy()
        end
        if gethui and gethui():FindFirstChild("CatalogNativeBuyerV5") then
            gethui().CatalogNativeBuyerV5:Destroy()
        end
    end)

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CatalogNativeBuyerV5"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.IgnoreGuiInset = true
    protectGui(ScreenGui)

    -- ===== BOTÓN FLOTANTE GRANDE =====
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleFloat"
    ToggleBtn.Size = UDim2.new(0, 58, 0, 58)
    ToggleBtn.Position = isMobile and UDim2.new(1, -75, 0.45, 0) or UDim2.new(1, -75, 0.3, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    ToggleBtn.Text = "🛒"
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 26
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.ZIndex = 50
    ToggleBtn.Parent = ScreenGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Color3.fromRGB(80, 80, 120)
    tStroke.Thickness = 2
    tStroke.Parent = ToggleBtn

    -- Drag botón
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
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- ===== MENÚ PRINCIPAL =====
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = isMobile and UDim2.new(0.95, 0, 0.8, 0) or UDim2.new(0, 450, 0, 550)
    Main.Position = isMobile and UDim2.new(0.025, 0, 0.1, 0) or UDim2.new(0.5, -225, 0.5, -275)
    Main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Main.BorderSizePixel = 0
    Main.Visible = true          -- <-- FORZADO VISIBLE
    Main.ZIndex = 10
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    local mStroke = Instance.new("UIStroke")
    mStroke.Color = Color3.fromRGB(50, 50, 70)
    mStroke.Thickness = 1.5
    mStroke.Parent = Main

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Header.BorderSizePixel = 0
    Header.ZIndex = 11
    Header.Parent = Main
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "CATALOG • NATIVE BUY v5"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Color3.fromRGB(240, 240, 250)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -48, 0.5, -20)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 35)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
    CloseBtn.ZIndex = 12
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)

    -- Search
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -120, 0, 42)
    SearchBox.Position = UDim2.new(0, 14, 0, 64)
    SearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    SearchBox.PlaceholderText = "Buscar item..."
    SearchBox.Text = ""
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.TextColor3 = Color3.fromRGB(235, 235, 245)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 11
    SearchBox.Parent = Main
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local SearchBtn = Instance.new("TextButton")
    SearchBtn.Size = UDim2.new(0, 90, 0, 42)
    SearchBtn.Position = UDim2.new(1, -104, 0, 64)
    SearchBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 180)
    SearchBtn.Text = "BUSCAR"
    SearchBtn.Font = Enum.Font.GothamBold
    SearchBtn.TextSize = 13
    SearchBtn.TextColor3 = Color3.new(1,1,1)
    SearchBtn.ZIndex = 11
    SearchBtn.Parent = Main
    Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 10)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -28, 0, 20)
    Status.Position = UDim2.new(0, 14, 0, 112)
    Status.BackgroundTransparency = 1
    Status.Text = "Menú forzado visible • Listo"
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextColor3 = Color3.fromRGB(140, 200, 140)
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.ZIndex = 11
    Status.Parent = Main

    local Results = Instance.new("ScrollingFrame")
    Results.Size = UDim2.new(1, -28, 1, -145)
    Results.Position = UDim2.new(0, 14, 0, 138)
    Results.BackgroundTransparency = 1
    Results.BorderSizePixel = 0
    Results.ScrollBarThickness = 5
    Results.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110)
    Results.CanvasSize = UDim2.new(0, 0, 0, 0)
    Results.ZIndex = 11
    Results.Parent = Main

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Results

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Results.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
    end)

    -- Drag menú
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
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- Toggle
    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    -- Render items
    local function clearResults()
        for _, c in ipairs(Results:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
    end

    local function createItemCard(item)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 70)
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        card.BorderSizePixel = 0
        card.ZIndex = 12
        card.Parent = Results
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 11)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(40, 40, 55)
        stroke.Thickness = 1
        stroke.Parent = card

        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.new(0, 56, 0, 56)
        thumb.Position = UDim2.new(0, 7, 0.5, -28)
        thumb.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
        thumb.ZIndex = 13
        thumb.Parent = card
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -155, 0, 22)
        name.Position = UDim2.new(0, 72, 0, 12)
        name.BackgroundTransparency = 1
        name.Text = item.name or "Sin nombre"
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 13
        name.TextColor3 = Color3.fromRGB(240, 240, 250)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.ZIndex = 13
        name.Parent = card

        local price = Instance.new("TextLabel")
        price.Size = UDim2.new(1, -155, 0, 18)
        price.Position = UDim2.new(0, 72, 0, 38)
        price.BackgroundTransparency = 1
        local p = item.price or item.lowestPrice or item.highestPrice or 0
        price.Text = (tonumber(p) == 0 and "Gratis / Offsale") or (tostring(p) .. " R$")
        price.Font = Enum.Font.Gotham
        price.TextSize = 12
        price.TextColor3 = Color3.fromRGB(140, 210, 150)
        price.TextXAlignment = Enum.TextXAlignment.Left
        price.ZIndex = 13
        price.Parent = card

        local buy = Instance.new("TextButton")
        buy.Size = UDim2.new(0, 74, 0, 36)
        buy.Position = UDim2.new(1, -84, 0.5, -18)
        buy.BackgroundColor3 = Color3.fromRGB(45, 100, 190)
        buy.Text = "COMPRAR"
        buy.Font = Enum.Font.GothamBold
        buy.TextSize = 12
        buy.TextColor3 = Color3.new(1,1,1)
        buy.ZIndex = 13
        buy.Parent = card
        Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 8)

        buy.MouseButton1Click:Connect(function()
            buy.Text = "..."
            buy.BackgroundColor3 = Color3.fromRGB(30, 70, 140)
            task.spawn(function()
                local itemType = item.itemType or (item.bundleId and "Bundle") or "Asset"
                promptNativePurchase(item.id, itemType)
                task.wait(0.9)
                buy.Text = "COMPRAR"
                buy.BackgroundColor3 = Color3.fromRGB(45, 100, 190)
            end)
        end)
    end

    -- Búsqueda
    local searching = false
    local function doSearch()
        if searching then return end
        local keyword = SearchBox.Text:gsub("^%s*(.-)%s*$", "%1")
        if keyword == "" then
            Status.Text = "Escribe un término"
            Status.TextColor3 = Color3.fromRGB(220, 160, 100)
            return
        end

        searching = true
        clearResults()
        Status.Text = "Buscando..."
        Status.TextColor3 = Color3.fromRGB(200, 200, 100)
        SearchBtn.Text = "..."

        task.spawn(function()
            local items, msg = searchCatalog(keyword)
            if items and #items > 0 then
                for _, item in ipairs(items) do
                    createItemCard(item)
                end
                Status.Text = #items .. " resultados • " .. msg
                Status.TextColor3 = Color3.fromRGB(130, 210, 140)
                notify("Éxito", #items .. " items", 3)
            else
                Status.Text = "Nada • " .. (msg or "Error")
                Status.TextColor3 = Color3.fromRGB(220, 120, 120)
                notify("Sin resultados", msg or "Error de red", 4)
            end
            searching = false
            SearchBtn.Text = "BUSCAR"
        end)
    end

    SearchBtn.MouseButton1Click:Connect(doSearch)
    SearchBox.FocusLost:Connect(function(enter)
        if enter then doSearch() end
    end)

    -- Forzar visible cada cierto tiempo por si algún anti-cheat lo oculta
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            if not Main.Visible then
                -- no forzar siempre, solo el botón
            end
            ToggleBtn.Visible = true
            task.wait(2)
        end
    end)

    print("[Catalog Native Buyer v5] Menú creado y forzado visible")
    notify("Menú listo", "Botón flotante 🛒 activo • Menú abierto", 4)
end

-- Crear el menú
createMenu()
