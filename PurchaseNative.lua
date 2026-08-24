--[[
    Catalog Native Buyer Menu
    - Floating black elegant UI (PC + Mobile)
    - Search via catalog.roblox.com / roproxy
    - 100% native MarketplaceService prompt (múltiples enfoques)
    - Robust error callbacks + pcalls
]]

local Players           = game:GetService("Players")
local MarketplaceService= game:GetService("MarketplaceService")
local HttpService       = game:GetService("HttpService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ===================== UTILIDADES =====================
local function protectGui(gui)
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
    local success, result = pcall(function()
        if syn and syn.request then
            local r = syn.request({Url = url, Method = "GET"})
            return r.Body
        elseif http and http.request then
            local r = http.request({Url = url, Method = "GET"})
            return r.Body
        elseif request then
            local r = request({Url = url, Method = "GET"})
            return r.Body
        else
            return game:HttpGet(url)
        end
    end)
    if success then return result end
    return nil
end

-- ===================== COMPRA NATIVA (MÚLTIPLES ENFOQUES) =====================
local function promptNativePurchase(assetId, itemType)
    assetId = tonumber(assetId)
    if not assetId then
        notify("Error", "ID inválido", 3)
        return false
    end

    local player = LocalPlayer
    local errors = {}

    -- Enfoque 1: PromptPurchase clásico (client-side funciona en la mayoría de ejecutores)
    local ok1, err1 = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId)
    end)
    if ok1 then
        notify("Éxito", "Prompt nativo abierto (método 1)", 3)
        return true
    end
    table.insert(errors, "Método1: " .. tostring(err1))

    -- Enfoque 2: con equipIfPurchased = true
    local ok2, err2 = pcall(function()
        MarketplaceService:PromptPurchase(player, assetId, true)
    end)
    if ok2 then
        notify("Éxito", "Prompt nativo abierto (método 2)", 3)
        return true
    end
    table.insert(errors, "Método2: " .. tostring(err2))

    -- Enfoque 3: Bundle (si es bundle)
    if itemType == "Bundle" or itemType == 2 then
        local ok3, err3 = pcall(function()
            MarketplaceService:PromptBundlePurchase(player, assetId)
        end)
        if ok3 then
            notify("Éxito", "Prompt Bundle abierto", 3)
            return true
        end
        table.insert(errors, "Método3 Bundle: " .. tostring(err3))
    end

    -- Enfoque 4: Intentamos forzar desde el servicio de avatar (fallback extra)
    local ok4, err4 = pcall(function()
        local AES = game:GetService("AvatarEditorService")
        if AES and AES.PromptPurchase then
            AES:PromptPurchase(assetId)
        end
    end)
    if ok4 then
        notify("Éxito", "Prompt AvatarEditor abierto", 3)
        return true
    end
    table.insert(errors, "Método4: " .. tostring(err4))

    -- Enfoque 5: Último recurso - GetProductInfo + Prompt
    local ok5, err5 = pcall(function()
        local info = MarketplaceService:GetProductInfo(assetId)
        if info then
            MarketplaceService:PromptPurchase(player, assetId)
        end
    end)
    if ok5 then
        notify("Éxito", "Prompt tras GetProductInfo", 3)
        return true
    end
    table.insert(errors, "Método5: " .. tostring(err5))

    -- Todo falló → callback robusto
    local fullError = table.concat(errors, " | ")
    warn("[CatalogBuyer] Todos los enfoques fallaron:\n" .. fullError)
    notify("Error de compra", "Ningún método de prompt nativo funcionó.\nRevisa consola.", 6)
    return false
end

-- ===================== BÚSQUEDA CATÁLOGO =====================
local function searchCatalog(keyword, limit)
    limit = limit or 30
    keyword = HttpService:UrlEncode(keyword or "")

    local urls = {
        "https://catalog.roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=1&IncludeNotForSale=false",
        "https://catalog.roblox.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=1",
        "https://catalog.roproxy.com/v1/search/items/details?keyword=" .. keyword .. "&limit=" .. limit .. "&Category=0",
    }

    for _, url in ipairs(urls) do
        local body = httpGet(url)
        if body then
            local success, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if success and data and data.data then
                return data.data
            end
        end
    end
    return nil
end

-- ===================== GUI ELEGANTE NEGRA =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatalogNativeBuyer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectGui(ScreenGui)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = isMobile and UDim2.new(0.92, 0, 0.78, 0) or UDim2.new(0, 420, 0, 520)
Main.Position = isMobile and UDim2.new(0.04, 0, 0.11, 0) or UDim2.new(0.5, -210, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1.2
UIStroke.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CATALOG • NATIVE BUY"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -18)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -24, 0, 38)
SearchBox.Position = UDim2.new(0, 12, 0, 58)
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SearchBox.PlaceholderText = "Buscar item (ej: Dominus, Valkyrie...)"
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 240)
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 9)

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(40, 40, 50)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

-- Results Scrolling
local Results = Instance.new("ScrollingFrame")
Results.Size = UDim2.new(1, -24, 1, -110)
Results.Position = UDim2.new(0, 12, 0, 106)
Results.BackgroundTransparency = 1
Results.BorderSizePixel = 0
Results.ScrollBarThickness = 4
Results.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Results.CanvasSize = UDim2.new(0, 0, 0, 0)
Results.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Results

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Results.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
end)

-- Drag (PC + Mobile)
local dragging, dragStart, startPos
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end
makeDraggable(Header)
makeDraggable(Main)

-- ===================== RENDER RESULTADOS =====================
local function clearResults()
    for _, child in ipairs(Results:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function createItemCard(item)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BorderSizePixel = 0
    card.Parent = Results
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 45)
    stroke.Thickness = 1
    stroke.Parent = card

    -- Thumbnail
    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 52, 0, 52)
    thumb.Position = UDim2.new(0, 6, 0.5, -26)
    thumb.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
    thumb.Parent = card
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

    -- Name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -140, 0, 22)
    name.Position = UDim2.new(0, 66, 0, 10)
    name.BackgroundTransparency = 1
    name.Text = item.name or "Sin nombre"
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 13
    name.TextColor3 = Color3.fromRGB(235, 235, 245)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = card

    -- Price
    local price = Instance.new("TextLabel")
    price.Size = UDim2.new(1, -140, 0, 18)
    price.Position = UDim2.new(0, 66, 0, 32)
    price.BackgroundTransparency = 1
    local p = item.price or item.lowestPrice or item.highestPrice or 0
    price.Text = (p == 0 and "Gratis / Offsale") or (tostring(p) .. " R$")
    price.Font = Enum.Font.Gotham
    price.TextSize = 12
    price.TextColor3 = Color3.fromRGB(140, 200, 140)
    price.TextXAlignment = Enum.TextXAlignment.Left
    price.Parent = card

    -- Buy button
    local buy = Instance.new("TextButton")
    buy.Size = UDim2.new(0, 68, 0, 32)
    buy.Position = UDim2.new(1, -76, 0.5, -16)
    buy.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
    buy.Text = "COMPRAR"
    buy.Font = Enum.Font.GothamBold
    buy.TextSize = 11
    buy.TextColor3 = Color3.new(1, 1, 1)
    buy.Parent = card
    Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 7)

    buy.MouseButton1Click:Connect(function()
        buy.Text = "..."
        buy.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
        task.spawn(function()
            local itemType = item.itemType or (item.bundleId and "Bundle") or "Asset"
            promptNativePurchase(item.id, itemType)
            task.wait(0.6)
            buy.Text = "COMPRAR"
            buy.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
        end)
    end)
end

-- ===================== BÚSQUEDA =====================
local searching = false
local function doSearch()
    if searching then return end
    searching = true
    clearResults()

    local keyword = SearchBox.Text
    if keyword == "" then
        notify("Aviso", "Escribe algo para buscar", 2)
        searching = false
        return
    end

    notify("Buscando...", keyword, 2)

    task.spawn(function()
        local items = searchCatalog(keyword, 40)
        if items and #items > 0 then
            for _, item in ipairs(items) do
                createItemCard(item)
            end
            notify("Resultados", #items .. " items encontrados", 3)
        else
            notify("Sin resultados", "No se encontraron items o error de red", 4)
        end
        searching = false
    end)
end

SearchBox.FocusLost:Connect(function(enter)
    if enter then doSearch() end
end)

-- Botón buscar extra (opcional, puedes tocar Enter)
local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 70, 0, 38)
SearchBtn.Position = UDim2.new(1, -82, 0, 58)
SearchBtn.BackgroundColor3 = Color3.fromRGB(35, 80, 160)
SearchBtn.Text = "BUSCAR"
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 12
SearchBtn.TextColor3 = Color3.new(1,1,1)
SearchBtn.Parent = Main
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 9)
SearchBtn.MouseButton1Click:Connect(doSearch)

-- Ajuste de SearchBox para que no choque con el botón
SearchBox.Size = UDim2.new(1, -100, 0, 38)

print("[Catalog Native Buyer] Cargado | PC + Mobile | Prompt nativo multi-fallback")
notify("Listo", "Menú de compra nativa cargado", 3)
