-- ==========================================================
-- LOOKS PRO VISUAL v4 • Sub-menú estilo Kitty
-- Switch → Menú visual con miniaturas + búsqueda en vivo
-- + Mantener items + Keep on Death
-- ==========================================================

local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

local FAVORITES_FILE    = "LOOKS_FAVORITES.json"
local KeepCurrentItems  = false      -- no limpiar al aplicar
local KeepOnDeath       = false
local SavedLookIds      = {}         -- para re-equipar al respawnear

-- ==========================================================
-- NOTIFICACIONES
-- ==========================================================
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 4
        })
    end)
end

local function SafeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 30 then return res end
    return nil
end

-- ==========================================================
-- EQUIPADO INDIVIDUAL (estilo UniversalEquip original)
-- ==========================================================
local function ProcessAndEquipItem(item, targetChar)
    if not item or not targetChar then return false end

    if item:IsA("Accessory") then
        local cloneItem = item:Clone()
        local handle = cloneItem:FindFirstChild("Handle")
        if handle then
            handle.Transparency = 0
            handle.Anchored = false
            handle.CanCollide = false
            handle.Massless = true

            local accAttach = handle:FindFirstChildWhichIsA("Attachment")
            if accAttach then
                local targetAttach
                for _, v in ipairs(targetChar:GetDescendants()) do
                    if v:IsA("Attachment") and v.Name == accAttach.Name and v.Parent:IsA("BasePart") then
                        targetAttach = v
                        break
                    end
                end
                if targetAttach then
                    for _, j in ipairs(handle:GetJoints()) do j:Destroy() end
                    local weld = Instance.new("Weld")
                    weld.Name = "AccessoryWeld"
                    weld.Part0 = targetAttach.Parent
                    weld.Part1 = handle
                    weld.C0 = targetAttach.CFrame
                    weld.C1 = accAttach.CFrame
                    weld.Parent = handle
                end
            else
                local bodyTarget = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("LowerTorso") or targetChar:FindFirstChild("Torso") or targetChar.PrimaryPart
                if bodyTarget then
                    for _, j in ipairs(handle:GetJoints()) do j:Destroy() end
                    local weld = Instance.new("Weld")
                    weld.Name = "AccessoryWeld"
                    weld.Part0 = bodyTarget
                    weld.Part1 = handle
                    weld.Parent = handle
                end
            end

            local wrap = handle:FindFirstChildWhichIsA("WrapLayer")
            if wrap then
                task.defer(function()
                    wrap.Enabled = false
                    task.wait(0.05)
                    wrap.Enabled = true
                end)
            end
        end
        cloneItem.Parent = targetChar
        return true

    elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
        if not KeepCurrentItems then
            for _, v in pairs(targetChar:GetChildren()) do
                if v.ClassName == item.ClassName then v:Destroy() end
            end
        end
        local clone = item:Clone()
        clone.Parent = targetChar
        return true

    elseif item:IsA("Decal") then
        local head = targetChar:FindFirstChild("Head")
        if head then
            local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
            if face then face.Texture = item.Texture
            else
                local n = item:Clone()
                n.Name = "face"
                n.Parent = head
            end
            return true
        end

    elseif item:IsA("Model") or item:IsA("Folder") then
        for _, sub in ipairs(item:GetChildren()) do
            ProcessAndEquipItem(sub, targetChar)
        end
        return true
    else
        local clone = item:Clone()
        clone.Parent = targetChar
        return true
    end
    return false
end

local function UniversalEquipAssetId(assetId, targetChar)
    local numericId = tonumber(assetId)
    if not numericId or not targetChar then return false end

    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(numericId))
    end)
    if ok and objects then
        local success = false
        for _, obj in ipairs(objects) do
            if ProcessAndEquipItem(obj, targetChar) then success = true end
            task.wait(0.02)
        end
        return success
    end
    return false
end

local function ClearAvatar(targetChar)
    targetChar = targetChar or LocalPlayer.Character
    if not targetChar then return end
    for _, v in ipairs(targetChar:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function ApplyLookData(look)
    if not look then return false end
    local Char = LocalPlayer.Character
    if not Char then return false end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return false end

    if not KeepCurrentItems then
        ClearAvatar(Char)
    end

    -- Guardar para Keep on Death
    if KeepOnDeath then
        SavedLookIds = {}
        local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
        for _, itemData in ipairs(items) do
            local id = itemData.id or itemData.assetId
            if id then SavedLookIds[tostring(id)] = true end
        end
    end

    -- 1. OutfitId completo
    local outfitId = look.outfitId or (look.avatarProperties and look.avatarProperties.outfitId)
    if outfitId then
        local ok, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromOutfitId(tonumber(outfitId))
        end)
        if ok and desc then
            pcall(function() Hum:ApplyDescription(desc) end)
            Notify("✅ Look aplicado", look.name or "Look", 4)
            return true
        end
    end

    -- 2. Assets individuales
    local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
    local count = 0
    for _, itemData in ipairs(items) do
        local id = itemData.id or itemData.assetId
        if id and UniversalEquipAssetId(id, Char) then
            count += 1
        end
        task.wait(0.03)
    end

    if count > 0 then
        Notify("✅ Look aplicado", (look.name or "Look") .. " (" .. count .. " items)", 4)
        return true
    end
    Notify("⚠️", "No se pudieron equipar los items", 3)
    return false
end

-- Keep on Death
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not KeepOnDeath then return end
    newChar:WaitForChild("Humanoid", 8)
    task.wait(1.2)
    for id, _ in pairs(SavedLookIds) do
        UniversalEquipAssetId(id, newChar)
        task.wait(0.05)
    end
end)

-- ==========================================================
-- FAVORITOS
-- ==========================================================
local function LoadFavorites()
    if isfile and isfile(FAVORITES_FILE) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(FAVORITES_FILE)) end)
        if ok and type(data) == "table" then return data end
    end
    return {}
end
local function SaveFavorites(data)
    if writefile then pcall(function() writefile(FAVORITES_FILE, HttpService:JSONEncode(data)) end) end
end
local Favorites = LoadFavorites()

-- ==========================================================
-- BÚSQUEDA
-- ==========================================================
local function SearchLooksByKeyword(keyword)
    if not keyword or #keyword < 2 then return {} end
    local encoded = HttpService:UrlEncode(keyword)
    local urls = {
        "https://apis.roblox.com/marketplace-widgets/v1/widgets?query=" .. encoded .. "&context=avatarTab",
        "https://apis.roblox.com/marketplace-widgets/v1/widgets/search?query=" .. encoded,
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets?query=" .. encoded .. "&context=avatarTab",
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets/search?query=" .. encoded
    }
    local lookIds = {}
    for _, url in ipairs(urls) do
        local res = SafeHttpGet(url)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then
                local function extract(t)
                    if type(t) ~= "table" then return end
                    if t.type == "Look" and t.id then table.insert(lookIds, tostring(t.id)) end
                    for _, v in pairs(t) do extract(v) end
                end
                extract(data)
                if #lookIds > 0 then break end
            end
        end
    end
    local unique, seen = {}, {}
    for _, id in ipairs(lookIds) do
        if not seen[id] then seen[id] = true table.insert(unique, id) end
    end
    return unique
end

local function FetchLookDetails(lookId)
    local urls = {
        "https://apis.roblox.com/look-api/v2/looks/" .. lookId,
        "https://apis.roproxy.com/look-api/v2/looks/" .. lookId
    }
    for _, url in ipairs(urls) do
        local res = SafeHttpGet(url)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then return data.look or data end
        end
    end
    return nil
end

-- ==========================================================
-- UI VISUAL ESTILO KITTY
-- ==========================================================
if CoreGui:FindFirstChild("LooksProVisualGui") then
    CoreGui.LooksProVisualGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LooksProVisualGui"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 40
Gui.Parent = CoreGui

-- Botón flotante (switch)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 56, 0, 56)
FloatBtn.Position = UDim2.new(1, -70, 0.5, -28)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
FloatBtn.Text = "👀"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 24
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Parent = Gui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 1.5
FloatStroke.Parent = FloatBtn

-- Menú principal
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 520)
Main.Position = UDim2.new(0.5, -190, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 105, 180)
MainStroke.Thickness = 2
MainStroke.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👀 Looks Pro Visual"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

-- Search box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -24, 0, 36)
SearchBox.Position = UDim2.new(0, 12, 0, 58)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.PlaceholderText = "🔍 Buscar (y2k, goth, emo...)"
SearchBox.Text = ""
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 14
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

-- Toggles
local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(1, -24, 0, 34)
ToggleFrame.Position = UDim2.new(0, 12, 0, 100)
ToggleFrame.BackgroundTransparency = 1
ToggleFrame.Parent = Main

local function CreateToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 1, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 50)
    btn.Text = (default and "✓ " or "  ") .. text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = ToggleFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 50)
        btn.Text = (state and "✓ " or "  ") .. text
        callback(state)
    end)
    return btn
end

local KeepItemsBtn = CreateToggle("Mantener items", false, function(v) KeepCurrentItems = v end)
KeepItemsBtn.Position = UDim2.new(0, 0, 0, 0)

local KeepDeathBtn = CreateToggle("Keep on Death", false, function(v) KeepOnDeath = v end)
KeepDeathBtn.Position = UDim2.new(0.52, 0, 0, 0)

-- Scroll de resultados
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -24, 1, -150)
Scroll.Position = UDim2.new(0, 12, 0, 140)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 108, 0, 140)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = Scroll

Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 20)
end)

-- ==========================================================
-- RENDER DE TARJETAS CON MINIATURAS
-- ==========================================================
local function ClearResults()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function CreateLookCard(look)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Card.Parent = Scroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(1, -10, 0, 90)
    Img.Position = UDim2.new(0, 5, 0, 5)
    Img.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Img.ScaleType = Enum.ScaleType.Fit
    Img.Parent = Card
    Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 8)

    -- Miniatura (usamos el primer asset o un thumb genérico de look)
    local thumbId = look.id or look.lookId
    if look.items and look.items[1] and look.items[1].id then
        thumbId = look.items[1].id
    end
    Img.Image = "rbxthumb://type=Asset&id=" .. tostring(thumbId) .. "&w=150&h=150"

    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(1, -8, 0, 28)
    NameLbl.Position = UDim2.new(0, 4, 0, 98)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = look.name or ("Look " .. (look.id or "?"))
    NameLbl.Font = Enum.Font.GothamSemibold
    NameLbl.TextSize = 11
    NameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    NameLbl.TextWrapped = true
    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    NameLbl.Parent = Card

    local Click = Instance.new("TextButton")
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.Parent = Card

    Click.MouseButton1Click:Connect(function()
        ApplyLookData(look)
    end)

    -- Long press / derecho para favorito (simple)
    Click.MouseButton2Click:Connect(function()
        local id = tostring(look.id or look.lookId or "")
        if id ~= "" then
            Favorites[id] = { id = id, name = look.name or ("Look " .. id), savedAt = os.time() }
            SaveFavorites(Favorites)
            Notify("❤️", "Guardado en favoritos", 2)
        end
    end)
end

-- ==========================================================
-- BÚSQUEDA EN TIEMPO REAL
-- ==========================================================
local searchThread
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchThread then task.cancel(searchThread) end
    local text = SearchBox.Text
    if #text < 2 then
        ClearResults()
        return
    end

    searchThread = task.spawn(function()
        task.wait(0.45) -- debounce
        ClearResults()

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 30)
        status.BackgroundTransparency = 1
        status.Text = "Buscando..."
        status.Font = Enum.Font.Gotham
        status.TextSize = 13
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
        status.Parent = Scroll

        local ids = SearchLooksByKeyword(text)
        status:Destroy()

        if #ids == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 40)
            empty.BackgroundTransparency = 1
            empty.Text = "Sin resultados\n(usa Look ID si falla)"
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 13
            empty.TextColor3 = Color3.fromRGB(180, 180, 180)
            empty.Parent = Scroll
            return
        end

        for i, id in ipairs(ids) do
            if i > 24 then break end
            local details = FetchLookDetails(id)
            if details then
                details.id = details.id or details.lookId or id
                CreateLookCard(details)
            end
            task.wait(0.05)
        end
    end)
end)

-- ==========================================================
-- EVENTOS UI
-- ==========================================================
FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        FloatBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 120)
    else
        FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
end)

-- Arrastrar el menú
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Arrastrar el botón flotante también
local fDrag, fStart, fPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = true
        fStart = input.Position
        fPos = FloatBtn.Position
    end
end)
FloatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDrag = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - fStart
        FloatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
    end
end)

Notify("Looks Pro Visual listo", "Toca el botón 👀 para abrir el menú", 5)
