--[[
    Catalog Native Buyer v2 - Mejorado
    - AvatarEditorService nativo (prioridad) + multi-proxy fallback
    - Botón flotante toggle + cierre
    - PC + iPhone
    - Prompt nativo multi-enfoque + errores robustos
]]

local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local CoreGui            = game:GetService("CoreGui")
local AvatarEditorService= game:GetService("AvatarEditorService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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

-- ===================== HTTP ROBUSTO =====================
local function httpGet(url)
    local methods = {
        function()
            if syn and syn.request then
                local r = syn.request({Url = url, Method = "GET"})
                return r.Body
            end
        end,
        function()
            if http and http.request then
                local r = http.request({Url = url, Method = "GET"})
                return r.Body
            end
        end,
        function()
            if request then
                local r = request({Url = url, Method = "GET"})
                return r.Body
            end
        end,
        function()
            return game:HttpGet(url)
        end
    }

    for _, method in ipairs(methods) do
        local ok, body = pcall(method)
        if ok and body and #body > 10 then
            return body
        end
    end
    return nil
end

-- ===================== COMPRA NATIVA (MULTI-ENFOQUE) =====================
local function promptNativePurchase(assetId, itemType)
    assetId = tonumber(assetId)
    if not assetId then
        notify("Error", "ID inválido", 3)
        return false
    end

    local errors = {}
    local player = LocalPlayer

    -- 1. PromptPurchase clásico
    local ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId)
    end)
    if ok then
        notify("Éxito", "Prompt nativo abierto", 3)
        return true
    end
    table.insert(errors, "1: " .. tostring(err))

    -- 2. Con equip
    ok, err = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId, true)
    end)
    if ok then
        notify("Éxito", "Prompt nativo (equip)", 3)
        return true
    end
    table.insert(errors, "2: " .. tostring(err))

    -- 3. Bundle
    if tostring(itemType):lower():find("bundle") or itemType == 2 then
        ok, err = pcall(function()
            MarketplaceService:PromptBundlePurchase(player, assetId)
        end)
        if ok then
            notify("Éxito", "Prompt Bundle", 3)
            return true
        end
        table.insert(errors, "3 Bundle: " .. tostring(err))
    end

    -- 4. GetProductInfo + reintento
    ok, err = pcall(function()
        local info = MarketplaceService:GetProductInfo(assetId)
        if info then
            MarketplaceService:PromptPurchase(player, assetId)
        end
    end)
    if ok then
        notify("Éxito", "Prompt tras GetProductInfo", 3)
        return true
    end
    table.insert(errors, "4: " .. tostring(err))

    warn("[CatalogBuyer] Fallos:\n" .. table.concat(errors, "\n"))
    notify("Error compra", "Ningún método nativo funcionó. Mira consola.", 5)
    return false
end

-- ===================== BÚSQUEDA (NATIVO + PROXIES) =====================
local function searchNative(keyword, limit)
    limit = limit or 30
    local params = CatalogSearchParams.new()
    params.SearchKeyword = keyword
    params.Limit = limit
    params.IncludeOffSale = false

    local ok, pages = pcall(function()
        return AvatarEditorService:SearchCatalogAsync(params)
    end)

    if not ok or not pages then return nil end

    local results = {}
    local page = pages:GetCurrentPage()
    for _, item in ipairs(page) do
        table.insert(results, {
            id = item.Id,
            name = item.Name,
            price = item.Price or item.LowestPrice or 0,
            itemType = item.ItemType or "Asset",
            description = item.Description
        })
    end
    return results
end

local function searchProxy(keyword, limit)
    limit = limit or 30
    keyword = HttpService:UrlEncode(keyword or "")

    local urls = {
        -- FastFront (actualmente más estable)
        "https://catalog.ff-roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=1",
        "https://catalog.ff-roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=0",
        -- Roproxy clásico
        "https://catalog.roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=1",
        "https://catalog.roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=0",
        -- Fallback extra
        "https://catalog.roblox.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=1",
    }

    for _, url in ipairs(urls) do
        local body = httpGet(url)
        if body then
            local success, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if success and data and data.data and #data.data > 0 then
                return data.data
            end
        end
    end
    return nil
end

local function searchCatalog(keyword)
    -- 1. Intento nativo (sin red externa)
    local items = searchNative(keyword, 40)
    if items and #items > 0 then
        return items, "Nativo (AvatarEditorService)"
    end

    -- 2. Proxies
    items = searchProxy(keyword, 40)
    if items and #items > 0 then
        return items, "Proxy"
    end

    return nil, "Ninguno"
end

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatalogNativeBuyerV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectGui(ScreenGui)

-- ========== BOTÓN FLOTANTE TOGGLE ==========
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

-- Drag del botón flotante
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

-- ========== MENÚ PRINCIPAL ==========
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

-- Header
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

-- Botón Cierre (X)
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

-- Search
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

-- Status label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -28, 0, 20)
Status.Position = UDim2.new(0, 14, 0, 108)
Status.BackgroundTransparency = 1
Status.Text = "Listo • Usa AvatarEditor nativo + proxies"
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextColor3 = Color3.fromRGB(140, 140, 160)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

-- Results
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

-- Drag del menú
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

-- Toggle menú
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ===================== RENDER =====================
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
            promptNativePurchase(item.id, item.itemType)
            task.wait(0.7)
            buy.Text = "COMPRAR"
            buy.BackgroundColor3 = Color3.fromRGB(40, 95, 185)
        end)
    end)
end

-- ===================== BÚSQUEDA =====================
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
    Status.Text = "Buscando... (nativo → proxies)"
    Status.TextColor3 = Color3.fromRGB(180, 180, 100)
    SearchBtn.Text = "..."
    SearchBtn.BackgroundColor3 = Color3.fromRGB(25, 55, 110)

    task.spawn(function()
        local items, source = searchCatalog(keyword)
        if items and #items > 0 then
            for _, item in ipairs(items) do
                createItemCard(item)
            end
            Status.Text = #items .. " resultados • " .. source
            Status.TextColor3 = Color3.fromRGB(130, 200, 140)
            notify("Éxito", #items .. " items encontrados (" .. source .. ")", 3)
        else
            Status.Text = "Nada encontrado • Error de red / sin resultados"
            Status.TextColor3 = Color3.fromRGB(220, 120, 120)
            notify("Sin resultados", "Prueba otra palabra o revisa conexión", 4)
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

print("[Catalog Native Buyer v2] Cargado | Botón flotante + multi-fuente + prompt nativo")
notify("Listo", "Menú cargado • Toca el botón flotante 🛒", 4)
