--[[
    Catalog Native Buyer v18 (Delta/Mobile Ultimate Fix)
    - Fix: Evita que el juego se congele ("No responde") al descargar usando hilos asíncronos puros.
    - Fix: Resuelto el error de "archivo vacío" obteniendo la imagen directamente desde rbxcdn.
    - Nuevo: Prioridad a openurl() para abrir Safari/Chrome directamente al tocar, sin necesidad de copiar.
    - Mantiene el navegador nativo de Roblox como segunda opción automática.
]]

local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local GuiService         = game:GetService("GuiService")
local VirtualUser        = game:GetService("VirtualUser")
local TextService        = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled

local DEFAULT_CATEGORY = 1
local DEFAULT_LIMIT = 30

-- Detectar peticiones HTTP robustas
local http_request = (request or http_request or (syn and syn.request) or (fluxus and fluxus.request))

-- ===================== UTILIDADES =====================
local function protectGui(gui)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    pcall(function()
        if gethui then gui.Parent = gethui()
        elseif get_hidden_gui then gui.Parent = get_hidden_gui()
        else gui.Parent = CoreGui end
    end)
end

local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title), Text = tostring(text), Duration = duration or 4
        })
    end)
end

local function setClipboard(text)
    local list = {
        function() if setclipboard then setclipboard(text) return true end end,
        function() if toclipboard then toclipboard(text) return true end end,
        function() if syn and syn.setclipboard then syn.setclipboard(text) return true end end,
    }
    for _, f in ipairs(list) do
        local ok, res = pcall(f)
        if ok and res then return true end
    end
    return false
end

-- ===================== SMART BROWSER V18 =====================
local function openSmartBrowser(url)
    -- 1. Intentar navegador externo del celular (Safari/Chrome) al instante
    if type(openurl) == "function" then
        local ok = pcall(function() openurl(url) end)
        if ok then return "EXTERNAL" end
    end
    if type(open_url) == "function" then
        local ok = pcall(function() open_url(url) end)
        if ok then return "EXTERNAL" end
    end

    -- 2. Si el externo falla, usar el navegador de Roblox (In-Game)
    local inGameOk = pcall(function() GuiService:OpenBrowserWindow(url) end)
    if inGameOk then return "INGAME" end

    -- 3. Si todo falla, copiar al portapapeles (Copiar es fallback aparte)
    setClipboard(url)
    return "CLIPBOARD"
end

-- ===================== DESCARGA DE IMAGEN HD (ANTI-CONGELAMIENTO) =====================
local function fetchUrl(url)
    local result = nil
    pcall(function()
        if http_request then
            local res = http_request({
                Url = url, 
                Method = "GET",
                Headers = { ["User-Agent"] = "Roblox/WinInet" }
            })
            if res and res.StatusCode == 200 then result = res.Body end
        else
            result = game:HttpGet(url, true)
        end
    end)
    return result
end

local function saveImageHD(assetId, itemName)
    if not writefile then return false, "Tu ejecutor no permite guardar archivos" end

    -- 1. Obtener la URL pura de la imagen (rbxcdn) sin descargarla aún para evitar lag
    local apiUrl = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. tostring(assetId) .. "&size=420x420&format=Png&isCircular=false"
    local proxyApiUrl = "https://thumbnails.roproxy.com/v1/assets?assetIds=" .. tostring(assetId) .. "&size=420x420&format=Png&isCircular=false"
    
    local finalImageUrl = nil
    
    -- Intentar API normal, si falla intentar Proxy
    for _, url in ipairs({apiUrl, proxyApiUrl}) do
        local data = fetchUrl(url)
        if data and data:find("imageUrl") then
            local ok, json = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and json and json.data and json.data[1] and json.data[1].imageUrl then
                finalImageUrl = json.data[1].imageUrl
                break
            end
        end
    end

    if not finalImageUrl then
        return false, "No se encontró la imagen en el servidor (Bloqueo de red o ID inválido)"
    end

    -- 2. Descargar la imagen real (los links rbxcdn rara vez son bloqueados por los ejecutores)
    local imageData = fetchUrl(finalImageUrl)

    if not imageData or #imageData < 100 then
        return false, "Archivo vacío o error de descarga."
    end

    -- 3. Guardar archivo
    local safeName = tostring(itemName or "Item"):gsub("[^%w%-_]", "_"):sub(1, 20)
    local fileName = "CatalogHD_" .. tostring(assetId) .. "_" .. safeName .. ".png"

    local ok, err = pcall(function() writefile(fileName, imageData) end)
    if ok then return true, fileName else return false, tostring(err) end
end

-- ===================== ALERTA ERROR =====================
local ScreenGui

local function showErrorAlert(fullLog, assetId, catalogLink)
    pcall(function() if ScreenGui and ScreenGui:FindFirstChild("ErrorAlert") then ScreenGui.ErrorAlert:Destroy() end end)

    local alert = Instance.new("Frame")
    alert.Name = "ErrorAlert"
    alert.Size = isMobile and UDim2.new(0.94, 0, 0, 460) or UDim2.new(0, 460, 0, 480)
    alert.Position = isMobile and UDim2.new(0.03, 0, 0.5, -230) or UDim2.new(0.5, -230, 0.5, -240)
    alert.BackgroundColor3 = Color3.fromRGB(14, 10, 12)
    alert.BorderSizePixel = 0
    alert.ZIndex = 500
    alert.Parent = ScreenGui
    Instance.new("UICorner", alert).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "⚠ PROMPT NATIVO NO APARECIÓ"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 140, 140)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 501
    title.Parent = alert

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 230)
    scroll.Position = UDim2.new(0, 10, 0, 78)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ZIndex = 501
    scroll.Parent = alert
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -12, 0, 0)
    logLabel.Position = UDim2.new(0, 6, 0, 6)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = fullLog
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 11
    logLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextWrapped = true
    logLabel.ZIndex = 502
    logLabel.Parent = scroll
    
    local textSize = TextService:GetTextSize(fullLog, 11, Enum.Font.Code, Vector2.new(420, 9999))
    logLabel.Size = UDim2.new(1, -12, 0, math.max(textSize.Y + 20, 210))
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(textSize.Y + 30, 230))

    local openLinkBtn = Instance.new("TextButton")
    openLinkBtn.Size = UDim2.new(0.32, -6, 0, 42)
    openLinkBtn.Position = UDim2.new(0, 10, 1, -100)
    openLinkBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 20)
    openLinkBtn.Text = "🌐 ABRIR WEB"
    openLinkBtn.Font = Enum.Font.GothamBold
    openLinkBtn.TextSize = 11
    openLinkBtn.TextColor3 = Color3.new(1,1,1)
    openLinkBtn.ZIndex = 501
    openLinkBtn.Parent = alert
    Instance.new("UICorner", openLinkBtn).CornerRadius = UDim.new(0, 9)

    local copyLinkBtn = Instance.new("TextButton")
    copyLinkBtn.Size = UDim2.new(0.32, -6, 0, 42)
    copyLinkBtn.Position = UDim2.new(0.34, 4, 1, -100)
    copyLinkBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 70)
    copyLinkBtn.Text = "📋 COPIAR LINK"
    copyLinkBtn.Font = Enum.Font.GothamBold
    copyLinkBtn.TextSize = 11
    copyLinkBtn.TextColor3 = Color3.new(1,1,1)
    copyLinkBtn.ZIndex = 501
    copyLinkBtn.Parent = alert
    Instance.new("UICorner", copyLinkBtn).CornerRadius = UDim.new(0, 9)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -20, 0, 40)
    closeBtn.Position = UDim2.new(0, 10, 1, -50)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
    closeBtn.Text = "CERRAR"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    closeBtn.ZIndex = 501
    closeBtn.Parent = alert
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 9)

    openLinkBtn.MouseButton1Click:Connect(function()
        local result = openSmartBrowser(catalogLink)
        if result == "EXTERNAL" then openLinkBtn.Text = "🌍 SAFARI/CHROME"
        elseif result == "INGAME" then openLinkBtn.Text = "✅ ABRIENDO..."
        else openLinkBtn.Text = "❌ FALLÓ (COPIADO)" end
        task.delay(2, function() openLinkBtn.Text = "🌐 ABRIR WEB" end)
    end)

    copyLinkBtn.MouseButton1Click:Connect(function()
        if setClipboard(catalogLink) then copyLinkBtn.Text = "✅ COPIADO" else copyLinkBtn.Text = "❌ FALLÓ" end
        task.delay(2, function() copyLinkBtn.Text = "📋 COPIAR LINK" end)
    end)

    closeBtn.MouseButton1Click:Connect(function() alert:Destroy() end)
end

-- ===================== PROMPT =====================
local function promptNativePurchase(assetId, itemType, itemName)
    assetId = tonumber(assetId)
    if not assetId then return false end

    local catalogLink = "https://www.roblox.com/catalog/" .. tostring(assetId)
    local log = {}
    table.insert(log, "=== LOG PROMPT NATIVO v18 (Delta Fix) ===")
    table.insert(log, "Asset ID: " .. tostring(assetId))

    -- Intentar MarketPlace
    pcall(function()
        if setthreadidentity then setthreadidentity(2) end
        MarketplaceService:PromptPurchase(LocalPlayer, assetId)
    end)
    task.wait(0.5)

    local promptVisible = false
    pcall(function()
        local realNames = { "purchaseprompt", "productpurchase", "robuxpurchase", "purchasedialog", "promptpurchase" }
        for _, obj in pairs(CoreGui:GetDescendants()) do
            local n = string.lower(tostring(obj.Name))
            for _, real in ipairs(realNames) do
                if n:find(real) and obj.Visible ~= false then
                    promptVisible = true
                    break
                end
            end
            if promptVisible then break end
        end
    end)

    if not promptVisible then
        showErrorAlert(table.concat(log, "\n"), assetId, catalogLink)
        return false
    else
        notify("Prompt detectado", "Compra lista", 4)
        return true
    end
end

-- ===================== BÚSQUEDA =====================
local function searchCatalog(keyword)
    local url = "https://catalog.roblox.com/v1/search/items/details?category=" .. tostring(DEFAULT_CATEGORY) .. "&limit=" .. tostring(DEFAULT_LIMIT) .. "&keyword=" .. HttpService:UrlEncode(keyword or "")
    local data = fetchUrl(url)
    
    if not data or #data < 10 then
        -- Usar proxy si roblox.com bloquea
        url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
        data = fetchUrl(url)
    end
    
    if not data then return nil, "Error de red" end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok or not decoded or not decoded.data then return nil, "Error JSON" end
    return decoded.data, "OK"
end

-- ===================== MENÚ =====================
local function createMenu()
    pcall(function()
        local old = CoreGui:FindFirstChild("CatalogNativeBuyerV18")
        if old then old:Destroy() end
        if gethui then
            local h = gethui():FindFirstChild("CatalogNativeBuyerV18")
            if h then h:Destroy() end
        end
    end)

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CatalogNativeBuyerV18"
    ScreenGui.ResetOnSpawn = false
    protectGui(ScreenGui)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
    ToggleBtn.Position = isMobile and UDim2.new(1, -78, 0.42, 0) or UDim2.new(1, -78, 0.28, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    ToggleBtn.Text = "🛒"
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 28
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.ZIndex = 100
    ToggleBtn.Parent = ScreenGui
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Main = Instance.new("Frame")
    Main.Size = isMobile and UDim2.new(0.95, 0, 0.82, 0) or UDim2.new(0, 460, 0, 560)
    Main.Position = isMobile and UDim2.new(0.025, 0, 0.09, 0) or UDim2.new(0.5, -230, 0.5, -280)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Main.Visible = false
    Main.ZIndex = 20
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 54)
    Header.BackgroundColor3 = Color3.fromRGB(17, 17, 25)
    Header.Parent = Main
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "CATALOG • NATIVE BUY v18"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Color3.fromRGB(240, 240, 250)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 42, 0, 42)
    CloseBtn.Position = UDim2.new(1, -50, 0.5, -21)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(55, 28, 32)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -120, 0, 44)
    SearchBox.Position = UDim2.new(0, 14, 0, 66)
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SearchBox.PlaceholderText = "Buscar item..."
    SearchBox.Text = ""
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.TextColor3 = Color3.fromRGB(235, 235, 245)
    SearchBox.Parent = Main
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local SearchBtn = Instance.new("TextButton")
    SearchBtn.Size = UDim2.new(0, 90, 0, 44)
    SearchBtn.Position = UDim2.new(1, -104, 0, 66)
    SearchBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 185)
    SearchBtn.Text = "BUSCAR"
    SearchBtn.Font = Enum.Font.GothamBold
    SearchBtn.TextColor3 = Color3.new(1,1,1)
    SearchBtn.Parent = Main
    Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 10)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -28, 0, 20)
    Status.Position = UDim2.new(0, 14, 0, 116)
    Status.BackgroundTransparency = 1
    Status.Text = "🌐 = Safari/Chrome (Directo) o Roblox Browser"
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextColor3 = Color3.fromRGB(140, 210, 150)
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Main

    local Results = Instance.new("ScrollingFrame")
    Results.Size = UDim2.new(1, -28, 1, -148)
    Results.Position = UDim2.new(0, 14, 0, 142)
    Results.BackgroundTransparency = 1
    Results.BorderSizePixel = 0
    Results.ScrollBarThickness = 5
    Results.Parent = Main

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.Parent = Results
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Results.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
    end)

    local function createItemCard(item)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 72)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        card.Parent = Results
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 11)

        local thumb = Instance.new("ImageButton")
        thumb.Size = UDim2.new(0, 58, 0, 58)
        thumb.Position = UDim2.new(0, 7, 0.5, -29)
        thumb.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
        thumb.Parent = card
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

        thumb.MouseButton1Click:Connect(function()
            notify("Descargando...", "Extrayendo imagen en 2do plano...", 3)
            -- Spawn para no congelar el juego ("No responde")
            task.spawn(function()
                local ok, result = saveImageHD(item.id, item.name)
                if ok then
                    notify("Imagen guardada", "Archivo: " .. tostring(result), 5)
                else
                    notify("Error", tostring(result), 4)
                end
            end)
        end)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -160, 0, 22)
        name.Position = UDim2.new(0, 74, 0, 12)
        name.BackgroundTransparency = 1
        name.Text = item.name or "Sin nombre"
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 13
        name.TextColor3 = Color3.fromRGB(240, 240, 250)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.Parent = card

        local browserBtn = Instance.new("TextButton")
        browserBtn.Size = UDim2.new(0, 32, 0, 38)
        browserBtn.Position = UDim2.new(1, -40, 0.5, -19)
        browserBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        browserBtn.Text = "🌐"
        browserBtn.Font = Enum.Font.GothamBold
        browserBtn.TextSize = 16
        browserBtn.TextColor3 = Color3.new(1,1,1)
        browserBtn.Parent = card
        Instance.new("UICorner", browserBtn).CornerRadius = UDim.new(0, 8)

        browserBtn.MouseButton1Click:Connect(function()
            local link = "https://www.roblox.com/catalog/" .. tostring(item.id)
            local result = openSmartBrowser(link)
            
            if result == "EXTERNAL" then notify("Abriendo...", "Dirigiendo a Safari/Chrome...", 3)
            elseif result == "INGAME" then notify("Abriendo...", "Cargando en Roblox...", 3)
            else notify("Copiado", "Se copió el link para que lo pegues.", 4) end
        end)

        local buy = Instance.new("TextButton")
        buy.Size = UDim2.new(0, 76, 0, 38)
        buy.Position = UDim2.new(1, -122, 0.5, -19) 
        buy.BackgroundColor3 = Color3.fromRGB(45, 105, 195)
        buy.Text = "COMPRAR"
        buy.Font = Enum.Font.GothamBold
        buy.TextColor3 = Color3.new(1,1,1)
        buy.Parent = card
        Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 8)

        buy.MouseButton1Click:Connect(function()
            if buy.Text == "..." then return end
            buy.Text = "..."
            task.spawn(function()
                promptNativePurchase(item.id, item.itemType, item.name)
                buy.Text = "COMPRAR"
            end)
        end)
    end

    local searching = false
    local function doSearch()
        if searching then return end
        local keyword = SearchBox.Text:gsub("^%s*(.-)%s*$", "%1")
        if keyword == "" then return end
        
        searching = true
        for _, c in ipairs(Results:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        
        Status.Text = "Buscando..."
        SearchBtn.Text = "..."

        task.spawn(function()
            local items, msg = searchCatalog(keyword)
            if items and #items > 0 then
                for _, item in ipairs(items) do createItemCard(item) end
                Status.Text = #items .. " resultados"
            else
                Status.Text = "Nada encontrado o red lenta"
            end
            searching = false
            SearchBtn.Text = "BUSCAR"
        end)
    end

    SearchBtn.MouseButton1Click:Connect(doSearch)
    SearchBox.FocusLost:Connect(function(enter) if enter then doSearch() end end)

    print("[Catalog Native Buyer v18] Sistema Anti-Lag y Navegador Híbrido Activos")
    notify("v18 Listo", "Directo a Safari/Chrome + Anti Lag Integrado", 5)
end

createMenu()
