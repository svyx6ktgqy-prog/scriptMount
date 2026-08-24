-- ==========================================================
-- LOOKS PRO VISUAL v5 • APLICACIÓN REAL + PAGINACIÓN + EXPERT
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
local KeepCurrentItems  = false
local KeepOnDeath       = false
local SavedLookIds      = {}
local CurrentResults    = {}
local CurrentPage       = 1
local PAGE_SIZE         = 12

-- ==========================================================
-- NOTIFY
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
    if ok and res and #res > 40 then return res end
    return nil
end

-- ==========================================================
-- EQUIPADO REAL (doble método + forzado)
-- ==========================================================
local function ClearAvatar(char)
    char = char or LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function ForceEquipAsset(assetId, char)
    if not assetId or not char then return false end
    local id = tonumber(assetId)
    if not id then return false end

    local ok, objs = pcall(function()
        return game:GetObjects("rbxassetid://" .. id)
    end)
    if not (ok and objs and #objs > 0) then return false end

    local equipped = false
    for _, item in ipairs(objs) do
        if item:IsA("Accessory") then
            local clone = item:Clone()
            local handle = clone:FindFirstChild("Handle")
            if handle then
                handle.Anchored = false
                handle.CanCollide = false
                handle.Massless = true
                handle.Transparency = 0

                -- Limpiar joints viejos
                for _, j in ipairs(handle:GetJoints()) do j:Destroy() end

                local attach = handle:FindFirstChildWhichIsA("Attachment")
                local targetAttach
                if attach then
                    for _, a in ipairs(char:GetDescendants()) do
                        if a:IsA("Attachment") and a.Name == attach.Name and a.Parent:IsA("BasePart") then
                            targetAttach = a
                            break
                        end
                    end
                end

                local weld = Instance.new("Weld")
                weld.Name = "AccessoryWeld"
                if targetAttach then
                    weld.Part0 = targetAttach.Parent
                    weld.Part1 = handle
                    weld.C0 = targetAttach.CFrame
                    weld.C1 = attach.CFrame
                else
                    local body = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char.PrimaryPart
                    weld.Part0 = body
                    weld.Part1 = handle
                end
                weld.Parent = handle
            end
            clone.Parent = char
            equipped = true

        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            if not KeepCurrentItems then
                for _, v in pairs(char:GetChildren()) do
                    if v.ClassName == item.ClassName then v:Destroy() end
                end
            end
            local c = item:Clone()
            c.Parent = char
            equipped = true

        elseif item:IsA("Decal") then
            local head = char:FindFirstChild("Head")
            if head then
                local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
                if face then face.Texture = item.Texture
                else
                    local n = item:Clone()
                    n.Name = "face"
                    n.Parent = head
                end
                equipped = true
            end

        elseif item:IsA("Model") or item:IsA("Folder") then
            for _, sub in ipairs(item:GetChildren()) do
                ForceEquipAsset(sub, char) -- recursivo
            end
            equipped = true
        else
            local c = item:Clone()
            c.Parent = char
            equipped = true
        end
        task.wait(0.015)
    end
    return equipped
end

local function ApplyLookReal(look)
    local char = LocalPlayer.Character
    if not char then
        Notify("Error", "No hay personaje", 3)
        return false
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if not KeepCurrentItems then
        ClearAvatar(char)
    end

    -- Guardar para Keep on Death
    if KeepOnDeath then
        SavedLookIds = {}
        local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
        for _, it in ipairs(items) do
            local id = it.id or it.assetId
            if id then SavedLookIds[tostring(id)] = true end
        end
        if look.outfitId then
            SavedLookIds["outfit_" .. tostring(look.outfitId)] = true
        end
    end

    local success = false

    -- MÉTODO 1: HumanoidDescription (más limpio)
    local outfitId = look.outfitId or (look.avatarProperties and look.avatarProperties.outfitId)
    if outfitId then
        local ok, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromOutfitId(tonumber(outfitId))
        end)
        if ok and desc then
            local applyOk = pcall(function() hum:ApplyDescription(desc) end)
            if applyOk then
                success = true
                Notify("✅ Aplicado", (look.name or "Look") .. " (Description)", 4)
            end
        end
    end

    -- MÉTODO 2: Forzar cada asset (siempre se ejecuta para garantizar visual)
    local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
    local count = 0
    for _, it in ipairs(items) do
        local id = it.id or it.assetId
        if id and ForceEquipAsset(id, char) then
            count += 1
        end
        task.wait(0.025)
    end

    if count > 0 then
        success = true
        if not outfitId then
            Notify("✅ Aplicado", (look.name or "Look") .. " (" .. count .. " items)", 4)
        end
    end

    if not success then
        Notify("⚠️ Falló", "No se pudieron cargar los assets del Look", 4)
    end
    return success
end

-- Keep on Death
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not KeepOnDeath or not next(SavedLookIds) then return end
    newChar:WaitForChild("Humanoid", 10)
    task.wait(1.4)
    for key, _ in pairs(SavedLookIds) do
        if key:find("outfit_") then
            local oid = key:gsub("outfit_", "")
            pcall(function()
                local desc = Players:GetHumanoidDescriptionFromOutfitId(tonumber(oid))
                local h = newChar:FindFirstChildOfClass("Humanoid")
                if h and desc then h:ApplyDescription(desc) end
            end)
        else
            ForceEquipAsset(key, newChar)
        end
        task.wait(0.06)
    end
end)

-- ==========================================================
-- FAVORITOS + BÚSQUEDA
-- ==========================================================
local function LoadFavorites()
    if isfile and isfile(FAVORITES_FILE) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(FAVORITES_FILE)) end)
        if ok and type(d) == "table" then return d end
    end
    return {}
end
local function SaveFavorites(d)
    if writefile then pcall(function() writefile(FAVORITES_FILE, HttpService:JSONEncode(d)) end) end
end
local Favorites = LoadFavorites()

local function SearchLooks(keyword)
    if not keyword or #keyword < 2 then return {} end
    local encoded = HttpService:UrlEncode(keyword)
    local urls = {
        "https://apis.roblox.com/marketplace-widgets/v1/widgets?query="..encoded.."&context=avatarTab",
        "https://apis.roblox.com/marketplace-widgets/v1/widgets/search?query="..encoded,
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets?query="..encoded.."&context=avatarTab",
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets/search?query="..encoded
    }
    local ids = {}
    for _, url in ipairs(urls) do
        local res = SafeHttpGet(url)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then
                local function walk(t)
                    if type(t) ~= "table" then return end
                    if t.type == "Look" and t.id then table.insert(ids, tostring(t.id)) end
                    for _, v in pairs(t) do walk(v) end
                end
                walk(data)
                if #ids > 0 then break end
            end
        end
    end
    local unique, seen = {}, {}
    for _, id in ipairs(ids) do
        if not seen[id] then seen[id] = true table.insert(unique, id) end
    end
    return unique
end

local function FetchLook(lookId)
    for _, base in ipairs({
        "https://apis.roblox.com/look-api/v2/looks/",
        "https://apis.roproxy.com/look-api/v2/looks/"
    }) do
        local res = SafeHttpGet(base .. lookId)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then return data.look or data end
        end
    end
    return nil
end

-- ==========================================================
-- UI VISUAL COMPLETA
-- ==========================================================
if CoreGui:FindFirstChild("LooksProVisualGui") then CoreGui.LooksProVisualGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LooksProVisualGui"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 45
Gui.Parent = CoreGui

-- Float button
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 58, 0, 58)
FloatBtn.Position = UDim2.new(1, -72, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
FloatBtn.Text = "👀"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 26
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Parent = Gui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 560)
Main.Position = UDim2.new(0.5, -200, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Thickness = 2

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👀 Looks Pro Visual v5"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

-- Search
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -24, 0, 34)
SearchBox.Position = UDim2.new(0, 12, 0, 54)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "🔍 Buscar looks (y2k, goth, emo...)"
SearchBox.Text = ""
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 13
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

-- ID Input
local IdBox = Instance.new("TextBox")
IdBox.Size = UDim2.new(0.62, 0, 0, 30)
IdBox.Position = UDim2.new(0, 12, 0, 94)
IdBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
IdBox.PlaceholderText = "Look ID directo..."
IdBox.Text = ""
IdBox.Font = Enum.Font.Gotham
IdBox.TextSize = 12
IdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
IdBox.Parent = Main
Instance.new("UICorner", IdBox).CornerRadius = UDim.new(0, 7)

local IdBtn = Instance.new("TextButton")
IdBtn.Size = UDim2.new(0.32, 0, 0, 30)
IdBtn.Position = UDim2.new(0.66, 0, 0, 94)
IdBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
IdBtn.Text = "Cargar ID"
IdBtn.Font = Enum.Font.GothamBold
IdBtn.TextSize = 12
IdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
IdBtn.Parent = Main
Instance.new("UICorner", IdBtn).CornerRadius = UDim.new(0, 7)

-- Toggles
local function MakeToggle(name, x, default, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.48, 0, 0, 28)
    b.Position = UDim2.new(x, 0, 0, 132)
    b.BackgroundColor3 = default and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(45, 45, 45)
    b.Text = (default and "✓ " or "") .. name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(45, 45, 45)
        b.Text = (state and "✓ " or "") .. name
        cb(state)
    end)
end
MakeToggle("Mantener items", 0.03, false, function(v) KeepCurrentItems = v end)
MakeToggle("Keep on Death", 0.52, false, function(v) KeepOnDeath = v end)

-- Status
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -24, 0, 22)
StatusLbl.Position = UDim2.new(0, 12, 0, 166)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Listo"
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = Main

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -24, 0, 280)
Scroll.Position = UDim2.new(0, 12, 0, 192)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 112, 0, 138)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = Scroll
Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 16)
end)

-- Pagination buttons
local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0.3, 0, 0, 32)
PrevBtn.Position = UDim2.new(0.03, 0, 1, -48)
PrevBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PrevBtn.Text = "⬅️ Atrás"
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 13
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.Parent = Main
Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 8)

local PageLbl = Instance.new("TextLabel")
PageLbl.Size = UDim2.new(0.3, 0, 0, 32)
PageLbl.Position = UDim2.new(0.35, 0, 1, -48)
PageLbl.BackgroundTransparency = 1
PageLbl.Text = "1 / 1"
PageLbl.Font = Enum.Font.GothamBold
PageLbl.TextSize = 13
PageLbl.TextColor3 = Color3.fromRGB(255, 105, 180)
PageLbl.Parent = Main

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0.3, 0, 0, 32)
NextBtn.Position = UDim2.new(0.67, 0, 1, -48)
NextBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NextBtn.Text = "Siguiente ➡️"
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 13
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Parent = Main
Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================================
-- RENDER + PAGINACIÓN
-- ==========================================================
local function ClearCards()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function CreateCard(look)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Card.Parent = Scroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(1, -8, 0, 88)
    Img.Position = UDim2.new(0, 4, 0, 4)
    Img.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Img.ScaleType = Enum.ScaleType.Fit
    Img.Parent = Card
    Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 8)

    local thumb = look.id or look.lookId
    if look.items and look.items[1] and look.items[1].id then
        thumb = look.items[1].id
    end
    Img.Image = "rbxthumb://type=Asset&id=" .. tostring(thumb) .. "&w=150&h=150"

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -6, 0, 32)
    Name.Position = UDim2.new(0, 3, 0, 94)
    Name.BackgroundTransparency = 1
    Name.Text = look.name or ("Look "..tostring(look.id))
    Name.Font = Enum.Font.GothamSemibold
    Name.TextSize = 11
    Name.TextColor3 = Color3.fromRGB(240, 240, 240)
    Name.TextWrapped = true
    Name.TextTruncate = Enum.TextTruncate.AtEnd
    Name.Parent = Card

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Card

    Btn.MouseButton1Click:Connect(function()
        StatusLbl.Text = "Aplicando..."
        task.spawn(function()
            ApplyLookReal(look)
            StatusLbl.Text = "Listo"
        end)
    end)

    Btn.MouseButton2Click:Connect(function()
        local id = tostring(look.id or look.lookId or "")
        if id ~= "" then
            Favorites[id] = {id = id, name = look.name or id, savedAt = os.time()}
            SaveFavorites(Favorites)
            Notify("❤️", "Guardado en favoritos", 2)
        end
    end)
end

local function RefreshPage()
    ClearCards()
    local totalPages = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
    CurrentPage = math.clamp(CurrentPage, 1, totalPages)
    PageLbl.Text = CurrentPage .. " / " .. totalPages

    local start = (CurrentPage - 1) * PAGE_SIZE + 1
    local finish = math.min(start + PAGE_SIZE - 1, #CurrentResults)
    for i = start, finish do
        CreateCard(CurrentResults[i])
    end
end

PrevBtn.MouseButton1Click:Connect(function()
    if CurrentPage > 1 then
        CurrentPage -= 1
        RefreshPage()
    end
end)
NextBtn.MouseButton1Click:Connect(function()
    local total = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
    if CurrentPage < total then
        CurrentPage += 1
        RefreshPage()
    end
end)

-- ==========================================================
-- BÚSQUEDA EN VIVO
-- ==========================================================
local searchTask
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchTask then task.cancel(searchTask) end
    local q = SearchBox.Text
    if #q < 2 then
        ClearCards()
        StatusLbl.Text = "Escribe para buscar..."
        return
    end
    searchTask = task.spawn(function()
        task.wait(0.5)
        StatusLbl.Text = "Buscando..."
        ClearCards()
        local ids = SearchLooks(q)
        if #ids == 0 then
            StatusLbl.Text = "Sin resultados (prueba ID directo)"
            return
        end
        StatusLbl.Text = "Cargando " .. #ids .. " looks..."
        CurrentResults = {}
        CurrentPage = 1
        for i, id in ipairs(ids) do
            if i > 36 then break end
            local data = FetchLook(id)
            if data then
                data.id = data.id or data.lookId or id
                table.insert(CurrentResults, data)
            end
            task.wait(0.04)
        end
        StatusLbl.Text = #CurrentResults .. " looks listos"
        RefreshPage()
    end)
end)

IdBtn.MouseButton1Click:Connect(function()
    local id = IdBox.Text:match("%d+")
    if not id then
        Notify("Error", "ID inválido", 3)
        return
    end
    StatusLbl.Text = "Cargando Look ID..."
    task.spawn(function()
        local data = FetchLook(id)
        if data then
            data.id = data.id or id
            ApplyLookReal(data)
            StatusLbl.Text = "Aplicado por ID"
        else
            StatusLbl.Text = "No se encontró el Look"
            Notify("Error", "Look no encontrado", 3)
        end
    end)
end)

-- ==========================================================
-- EVENTOS UI
-- ==========================================================
FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    FloatBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(180, 60, 130) or Color3.fromRGB(255, 105, 180)
end)
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
end)

-- Drag Main
local drag, dStart, sPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true dStart = i.Position sPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

Notify("Looks Pro v5 listo", "Toca 👀 • Ahora SÍ se aplica al personaje", 5)
