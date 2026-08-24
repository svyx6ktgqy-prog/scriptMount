--[[




























    Catalog Native Buyer v14 (Delta optimized)
    - Al tocar la miniatura → guarda imagen HD en Delta
    - Siempre copia el link del catálogo
    - OpenBrowserWindow con mejor manejo de error
    - Menú se abre solo
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
        function() if Clipboard and Clipboard.set then Clipboard.set(text) return true end end,
    }
    for _, f in ipairs(list) do
        local ok, res = pcall(f)
        if ok and res then return true end
    end
    return false
end

local function runWithTimeout(fn, timeout)
    timeout = timeout or 1.3
    local finished = false
    local result, err
    task.spawn(function()
        local ok, res = pcall(fn)
        finished = true
        result = ok
        err = res
    end)
    local start = tick()
    while not finished and (tick() - start) < timeout do
        task.wait(0.05)
    end
    if not finished then return false, "TIMEOUT" end
    return result, err
end

-- Guardar imagen HD en Delta
local function saveImageHD(assetId, itemName)
    if not writefile then
        return false, "writefile no disponible"
    end

    -- Mejores URLs de thumbnail en alta calidad
    local urls = {
        "https://thumbnails.roblox.com/v1/assets?assetIds=" .. tostring(assetId) .. "&size=420x420&format=Png&isCircular=false",
        "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(assetId) .. "&width=420&height=420&format=png",
        "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(assetId) .. "&width=512&height=512&format=png",
        "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=420&h=420"
    }

    local imageData = nil
    local usedUrl = nil

    for _, url in ipairs(urls) do
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and #data > 500 then
            -- Si es JSON de thumbnails.roblox.com, extraemos la URL real
            if data:sub(1,1) == "{" then
                local success, json = pcall(function() return HttpService:JSONDecode(data) end)
                if success and json and json.data and json.data[1] and json.data[1].imageUrl then
                    local imgOk, imgData = pcall(function()
                        return game:HttpGet(json.data[1].imageUrl)
                    end)
                    if imgOk and imgData and #imgData > 500 then
                        imageData = imgData
                        usedUrl = json.data[1].imageUrl
                        break
                    end
                end
            else
                imageData = data
                usedUrl = url
                break
            end
        end
    end

    if not imageData then
        return false, "No se pudo descargar la imagen"
    end

    local safeName = tostring(itemName or "Item"):gsub("[^%w%-_]", "_"):sub(1, 40)
    local fileName = "CatalogHD_" .. tostring(assetId) .. "_" .. safeName .. ".png"

    local ok, err = pcall(function()
        writefile(fileName, imageData)
    end)

    if ok then
        return true, fileName
    else
        return false, tostring(err)
    end
end

-- ===================== ALERTA =====================
local ScreenGui

local function showErrorAlert(fullLog, assetId, catalogLink)
    pcall(function()
        if ScreenGui and ScreenGui:FindFirstChild("ErrorAlert") then
            ScreenGui.ErrorAlert:Destroy()
        end
    end)

    local alert = Instance.new("Frame")
    alert.Name = "ErrorAlert"
    alert.Size = isMobile and UDim2.new(0.94, 0, 0, 460) or UDim2.new(0, 460, 0, 480)
    alert.Position = isMobile and UDim2.new(0.03, 0, 0.5, -230) or UDim2.new(0.5, -230, 0.5, -240)
    alert.BackgroundColor3 = Color3.fromRGB(14, 10, 12)
    alert.BorderSizePixel = 0
    alert.ZIndex = 500
    alert.Parent = ScreenGui
    Instance.new("UICorner", alert).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(210, 40, 50)
    stroke.Thickness = 2
    stroke.Parent = alert

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

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -20, 0, 18)
    idLabel.Position = UDim2.new(0, 10, 0, 36)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "Asset ID: " .. tostring(assetId)
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 12
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.ZIndex = 501
    idLabel.Parent = alert

    local linkInfo = Instance.new("TextLabel")
    linkInfo.Size = UDim2.new(1, -20, 0, 18)
    linkInfo.Position = UDim2.new(0, 10, 0, 54)
    linkInfo.BackgroundTransparency = 1
    linkInfo.Text = "Link copiado • Toca la miniatura para guardar imagen HD"
    linkInfo.Font = Enum.Font.Gotham
    linkInfo.TextSize = 12
    linkInfo.TextColor3 = Color3.fromRGB(130, 200, 140)
    linkInfo.TextXAlignment = Enum.TextXAlignment.Left
    linkInfo.ZIndex = 501
    linkInfo.Parent = alert

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 230)
    scroll.Position = UDim2.new(0, 10, 0, 78)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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

    local copyLinkBtn = Instance.new("TextButton")
    copyLinkBtn.Size = UDim2.new(0.48, -8, 0, 42)
    copyLinkBtn.Position = UDim2.new(0, 10, 1, -100)
    copyLinkBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 70)
    copyLinkBtn.Text = "📋 COPIAR LINK"
    copyLinkBtn.Font = Enum.Font.GothamBold
    copyLinkBtn.TextSize = 13
    copyLinkBtn.TextColor3 = Color3.new(1,1,1)
    copyLinkBtn.ZIndex = 501
    copyLinkBtn.Parent = alert
    Instance.new("UICorner", copyLinkBtn).CornerRadius = UDim.new(0, 9)

    local copyLogBtn = Instance.new("TextButton")
    copyLogBtn.Size = UDim2.new(0.48, -8, 0, 42)
    copyLogBtn.Position = UDim2.new(0.52, 0, 1, -100)
    copyLogBtn.BackgroundColor3 = Color3.fromRGB(35, 90, 170)
    copyLogBtn.Text = "📋 COPIAR LOG"
    copyLogBtn.Font = Enum.Font.GothamBold
    copyLogBtn.TextSize = 13
    copyLogBtn.TextColor3 = Color3.new(1,1,1)
    copyLogBtn.ZIndex = 501
    copyLogBtn.Parent = alert
    Instance.new("UICorner", copyLogBtn).CornerRadius = UDim.new(0, 9)

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

    copyLinkBtn.MouseButton1Click:Connect(function()
        if setClipboard(catalogLink) then
            copyLinkBtn.Text = "✅ COPIADO"
            notify("Link copiado", "Listo", 3)
        else
            copyLinkBtn.Text = "❌ FALLÓ"
        end
        task.delay(1.8, function() copyLinkBtn.Text = "📋 COPIAR LINK" end)
    end)

    copyLogBtn.MouseButton1Click:Connect(function()
        if setClipboard(fullLog) then
            copyLogBtn.Text = "✅ LOG COPIADO"
            notify("Log copiado", "Listo", 3)
        else
            copyLogBtn.Text = "❌ FALLÓ"
        end
        task.delay(1.8, function() copyLogBtn.Text = "📋 COPIAR LOG" end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alert:Destroy()
    end)
end

----
--a
---
-- ===================== PROMPT =====================
local function promptNativePurchase(assetId, itemType, itemName)
    assetId = tonumber(assetId)
    if not assetId then
        notify("Error", "ID inválido", 3)
        return false
    end

    local catalogLink = "https://www.roblox.com/catalog/" .. tostring(assetId)
    local linkCopied = setClipboard(catalogLink)

    local log = {}
    table.insert(log, "=== LOG PROMPT NATIVO v14 (Delta) ===")
    table.insert(log, "Asset ID: " .. tostring(assetId))
    table.insert(log, "Link: " .. catalogLink)
    table.insert(log, "Link copiado: " .. tostring(linkCopied))
    table.insert(log, "Player: " .. tostring(LocalPlayer and LocalPlayer.Name))
    table.insert(log, "Hora: " .. os.date("%H:%M:%S"))
    table.insert(log, "--------------------------------")

    local methodsOk = 0
    local promptVisible = false

    local function try(name, fn, timeout)
        local ok, err = runWithTimeout(fn, timeout or 1.3)
        table.insert(log, name .. ": " .. (ok and "sin error" or tostring(err)))
        if ok then methodsOk = methodsOk + 1 end
    end

    try("1. VirtualUser", function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "Bypass_" .. math.random(10000,99999)
        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.Position = UDim2.new(0, 5, 0, 5)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = gui

        btn.MouseButton1Click:Connect(function()
            pcall(function()
                if setthreadidentity then setthreadidentity(2) end
                MarketplaceService:PromptPurchase(LocalPlayer, assetId)
            end)
        end)

        VirtualUser:ClickButton1(Vector2.new(25, 25))
        task.wait(0.12)
        VirtualUser:ClickButton1(Vector2.new(25, 25))
        task.wait(0.4)
        pcall(function() gui:Destroy() end)
    end, 1.6)

    try("2. BindableEvent", function()
        local b = Instance.new("BindableEvent")
        b.Event:Connect(function()
            task.defer(function()
                pcall(function()
                    if setthreadidentity then setthreadidentity(2) end
                    MarketplaceService:PromptPurchase(LocalPlayer, assetId)
                end)
            end)
        end)
        b:Fire()
        task.wait(0.4)
        b:Destroy()
    end, 1.2)

    try("3. getrenv", function()
        local renv = getrenv and getrenv()
        if not renv then error("nil") end
        renv.game:GetService("MarketplaceService"):PromptPurchase(renv.game.Players.LocalPlayer, assetId)
    end, 1.0)

    try("4. LocalScript", function()
        local ls = Instance.new("LocalScript")
        ls.Source = string.format([[
            pcall(function()
                if setthreadidentity then setthreadidentity(2) end
                game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, %d)
            end)
            task.wait(0.3)
            script:Destroy()
        ]], assetId)
        local parent = LocalPlayer:FindFirstChild("PlayerScripts") or LocalPlayer.PlayerGui
        if parent then ls.Parent = parent end
        task.wait(0.5)
        pcall(function() ls:Destroy() end)
    end, 1.2)

    task.wait(0.6)

    -- Detección estricta
    pcall(function()
        local realNames = {
            "purchaseprompt", "productpurchase", "robuxpurchase",
            "purchasedialog", "purchaseframe", "promptpurchase"
        }
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

    table.insert(log, "--------------------------------")
    table.insert(log, "Métodos sin error: " .. methodsOk)
    table.insert(log, "Prompt real detectado: " .. tostring(promptVisible))
    table.insert(log, "Link copiado: " .. tostring(linkCopied))
    table.insert(log, "")
    table.insert(log, "Toca la miniatura del item para guardar imagen HD en Delta")

    local fullLog = table.concat(log, "\n")
    warn(fullLog)

    if not promptVisible then
        showErrorAlert(fullLog, assetId, catalogLink)
        notify("Prompt no apareció", "Link copiado. Toca la miniatura para guardar imagen HD", 5)
        return false
    else
        notify("Prompt detectado", "Si no ves la compra, usa el link copiado", 4)
        return true
    end
end

-- ===================== BÚSQUEDA =====================
local function searchCatalog(keyword)
    local url = "https://catalog.roblox.com/v1/search/items/details?category=" 
        .. tostring(DEFAULT_CATEGORY) 
        .. "&limit=" .. tostring(DEFAULT_LIMIT) 
        .. "&keyword=" .. HttpService:UrlEncode(keyword or "")

    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success or not response or #response < 10 then
        url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
        success, response = pcall(function() return game:HttpGet(url) end)
    end
    if not success or not response then return nil, "Error de red" end

    local decoded
    local ok = pcall(function() decoded = HttpService:JSONDecode(response) end)
    if not ok or not decoded or not decoded.data then return nil, "Error JSON" end
    return decoded.data, "OK"
end

-- ===================== MENÚ =====================
local function createMenu()
    pcall(function()
        local old = CoreGui:FindFirstChild("CatalogNativeBuyerV14")
        if old then old:Destroy() end
        if gethui then
            local h = gethui():FindFirstChild("CatalogNativeBuyerV14")
            if h then h:Destroy() end
        end
    end)

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CatalogNativeBuyerV14"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999
    ScreenGui.IgnoreGuiInset = true
    protectGui(ScreenGui)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleFloat"
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

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Color3.fromRGB(100, 100, 160)
    tStroke.Thickness = 2.5
    tStroke.Parent = ToggleBtn

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

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = isMobile and UDim2.new(0.95, 0, 0.82, 0) or UDim2.new(0, 460, 0, 560)
    Main.Position = isMobile and UDim2.new(0.025, 0, 0.09, 0) or UDim2.new(0.5, -230, 0.5, -280)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Main.BorderSizePixel = 0
    Main.Visible = true
    Main.ZIndex = 20
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    local mStroke = Instance.new("UIStroke")
    mStroke.Color = Color3.fromRGB(55, 55, 90)
    mStroke.Thickness = 1.8
    mStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 54)
    Header.BackgroundColor3 = Color3.fromRGB(17, 17, 25)
    Header.BorderSizePixel = 0
    Header.ZIndex = 21
    Header.Parent = Main
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "CATALOG • NATIVE BUY v14"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Color3.fromRGB(240, 240, 250)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 22
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 42, 0, 42)
    CloseBtn.Position = UDim2.new(1, -50, 0.5, -21)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(55, 28, 32)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
    CloseBtn.ZIndex = 22
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
    end)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -120, 0, 44)
    SearchBox.Position = UDim2.new(0, 14, 0, 66)
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SearchBox.PlaceholderText = "Buscar item..."
    SearchBox.Text = ""
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.TextColor3 = Color3.fromRGB(235, 235, 245)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 21
    SearchBox.Parent = Main
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local SearchBtn = Instance.new("TextButton")
    SearchBtn.Size = UDim2.new(0, 90, 0, 44)
    SearchBtn.Position = UDim2.new(1, -104, 0, 66)
    SearchBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 185)
    SearchBtn.Text = "BUSCAR"
    SearchBtn.Font = Enum.Font.GothamBold
    SearchBtn.TextSize = 13
    SearchBtn.TextColor3 = Color3.new(1,1,1)
    SearchBtn.ZIndex = 21
    SearchBtn.Parent = Main
    Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 10)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -28, 0, 20)
    Status.Position = UDim2.new(0, 14, 0, 116)
    Status.BackgroundTransparency = 1
    Status.Text = "Toca la miniatura para guardar imagen HD en Delta"
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextColor3 = Color3.fromRGB(140, 210, 150)
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.ZIndex = 21
    Status.Parent = Main

    local Results = Instance.new("ScrollingFrame")
    Results.Size = UDim2.new(1, -28, 1, -148)
    Results.Position = UDim2.new(0, 14, 0, 142)
    Results.BackgroundTransparency = 1
    Results.BorderSizePixel = 0
    Results.ScrollBarThickness = 5
    Results.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    Results.CanvasSize = UDim2.new(0, 0, 0, 0)
    Results.ZIndex = 21
    Results.Parent = Main

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Results

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Results.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
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
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            ToggleBtn.Visible = true
            task.wait(2)
        end
    end)

    local function clearResults()
        for _, c in ipairs(Results:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
    end

    local function createItemCard(item)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 72)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        card.BorderSizePixel = 0
        card.ZIndex = 22
        card.Parent = Results
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 11)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(38, 38, 52)
        stroke.Thickness = 1
        stroke.Parent = card

        -- Miniatura CLICABLE
        local thumb = Instance.new("ImageButton")  -- ImageButton para que sea clicable
        thumb.Size = UDim2.new(0, 58, 0, 58)
        thumb.Position = UDim2.new(0, 7, 0.5, -29)
        thumb.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
        thumb.ZIndex = 23
        thumb.Parent = card
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

        -- Al tocar la miniatura → guardar imagen HD
        thumb.MouseButton1Click:Connect(function()
            notify("Descargando...", "Guardando imagen HD en Delta...", 3)
            task.spawn(function()
                local ok, result = saveImageHD(item.id, item.name)
                if ok then
                    notify("Imagen guardada", "Archivo: " .. tostring(result), 5)
                    print("[Imagen HD guardada] " .. tostring(result))
                else
                    notify("Error al guardar", tostring(result), 4)
                    warn("[Error guardar imagen] " .. tostring(result))
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
        name.ZIndex = 23
        name.Parent = card

        local price = Instance.new("TextLabel")
        price.Size = UDim2.new(1, -160, 0, 18)
        price.Position = UDim2.new(0, 74, 0, 38)
        price.BackgroundTransparency = 1
        local p = item.price or item.lowestPrice or item.highestPrice or 0
        price.Text = (tonumber(p) == 0 and "Gratis / Offsale") or (tostring(p) .. " R$")
        price.Font = Enum.Font.Gotham
        price.TextSize = 12
        price.TextColor3 = Color3.fromRGB(140, 210, 150)
        price.TextXAlignment = Enum.TextXAlignment.Left
        price.ZIndex = 23
        price.Parent = card

        local buy = Instance.new("TextButton")
        buy.Size = UDim2.new(0, 76, 0, 38)
        buy.Position = UDim2.new(1, -86, 0.5, -19)
        buy.BackgroundColor3 = Color3.fromRGB(45, 105, 195)
        buy.Text = "COMPRAR"
        buy.Font = Enum.Font.GothamBold
        buy.TextSize = 12
        buy.TextColor3 = Color3.new(1,1,1)
        buy.ZIndex = 23
        buy.Parent = card
        Instance.new("UICorner", buy).CornerRadius = UDim.new(0, 8)

        buy.MouseButton1Click:Connect(function()
            if buy.Text == "..." then return end
            buy.Text = "..."
            buy.BackgroundColor3 = Color3.fromRGB(30, 70, 140)

            task.spawn(function()
                local itemType = item.itemType or (item.bundleId and "Bundle") or "Asset"
                pcall(function()
                    promptNativePurchase(item.id, itemType, item.name)
                end)
                buy.Text = "COMPRAR"
                buy.BackgroundColor3 = Color3.fromRGB(45, 105, 195)
            end)
        end)
    end

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
                for _, item in ipairs(items) do createItemCard(item) end
                Status.Text = #items .. " resultados • Toca miniatura = guardar HD"
                Status.TextColor3 = Color3.fromRGB(130, 210, 140)
                notify("Éxito", #items .. " items", 3)
            else
                Status.Text = "Nada • " .. (msg or "Error")
                Status.TextColor3 = Color3.fromRGB(220, 120, 120)
                notify("Sin resultados", msg or "Error", 4)
            end
            searching = false
            SearchBtn.Text = "BUSCAR"
        end)
    end

    SearchBtn.MouseButton1Click:Connect(doSearch)
    SearchBox.FocusLost:Connect(function(enter) if enter then doSearch() end end)

    print("[Catalog Native Buyer v14] Listo – Miniatura guarda imagen HD en Delta")
    notify("v14 Listo", "Toca la miniatura de cualquier item para guardar imagen HD", 5)
end

createMenu()
