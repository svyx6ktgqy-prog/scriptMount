-- ==========================================================
-- LOOKS PRO VISUAL v10 + FIX LAYOUT (v11)
-- • Scroll maximizado pro (todos los menús)
-- • Menú Guardado = gestor de skins (cargar / borrar cartas)
-- • FIX: horizontal, límites, no se salen / no desaparecen
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
local SKINS_FILE        = "skins.json"
local KeepOnDeath       = true
local SavedLookIds      = {}
local CurrentResults    = {}
local CurrentPage       = 1
local PAGE_SIZE         = 10          -- estable (evita overflow)
local IS_MOBILE         = UserInputService.TouchEnabled
local MAX_RESULTS       = 48

local BodyPartGroups = {
    Head     = {"Head"},
    Torso    = {"Torso", "UpperTorso", "LowerTorso"},
    LeftArm  = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
    RightArm = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
    LeftLeg  = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    RightLeg = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

-- ==========================================================
-- UTILS
-- ==========================================================
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3.5
        })
    end)
end

local function SafeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 40 then return res end
    return nil
end

local function LoadJSON(file)
    if isfile and isfile(file) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
        if ok and type(d) == "table" then return d end
    end
    return {}
end

local function SaveJSON(file, data)
    if writefile then pcall(function() writefile(file, HttpService:JSONEncode(data)) end) end
end

local Favorites = LoadJSON(FAVORITES_FILE)
local Skins     = LoadJSON(SKINS_FILE)

-- ==========================================================
-- EQUIPADO
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
    local id = tonumber(assetId)
    if not id or not char then return false end

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
            clone:SetAttribute("AssetId", id)
            clone.Parent = char
            equipped = true

        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            for _, v in pairs(char:GetChildren()) do
                if v.ClassName == item.ClassName then v:Destroy() end
            end
            local c = item:Clone()
            c:SetAttribute("AssetId", id)
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
                ForceEquipAsset(sub, char)
            end
            equipped = true
        else
            local c = item:Clone()
            c:SetAttribute("AssetId", id)
            c.Parent = char
            equipped = true
        end
    end
    return equipped
end

local function ApplyLookReal(look)
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    ClearAvatar(char)

    if KeepOnDeath then
        SavedLookIds = {}
        local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
        for _, it in ipairs(items) do
            local id = it.id or it.assetId
            if id then SavedLookIds[tostring(id)] = true end
        end
        if look.outfitId then SavedLookIds["outfit_" .. tostring(look.outfitId)] = true end
    end

    local success = false
    local outfitId = look.outfitId or (look.avatarProperties and look.avatarProperties.outfitId)
    if outfitId then
        local ok, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromOutfitId(tonumber(outfitId))
        end)
        if ok and desc then
            pcall(function() hum:ApplyDescription(desc) end)
            success = true
        end
    end

    local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
    local count = 0
    for _, it in ipairs(items) do
        local id = it.id or it.assetId
        if id and ForceEquipAsset(id, char) then count += 1 end
    end

    if count > 0 or success then
        Notify("✅ Aplicado", look.name or "Look", 3)
        return true
    end
    Notify("⚠️", "No se pudieron cargar los assets", 3)
    return false
end

local function ApplySavedSkin(entry)
    local char = LocalPlayer.Character
    if not char then return end
    ClearAvatar(char)

    if entry.lookIds and next(entry.lookIds) then
        for key, _ in pairs(entry.lookIds) do
            if key:find("outfit_") then
                local oid = key:gsub("outfit_", "")
                pcall(function()
                    local desc = Players:GetHumanoidDescriptionFromOutfitId(tonumber(oid))
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h and desc then h:ApplyDescription(desc) end
                end)
            else
                ForceEquipAsset(key, char)
            end
            task.wait(0.03)
        end
    end

    if entry.ids then
        for _, id in ipairs(entry.ids) do
            ForceEquipAsset(id, char)
            task.wait(0.03)
        end
    end

    if KeepOnDeath then
        SavedLookIds = entry.lookIds or {}
        for _, id in ipairs(entry.ids or {}) do
            SavedLookIds[tostring(id)] = true
        end
    end

    Notify("✅ Skin cargada", entry.name or "Skin", 3)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not KeepOnDeath or not next(SavedLookIds) then return end
    newChar:WaitForChild("Humanoid", 10)
    task.wait(1.3)
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
        task.wait(0.04)
    end
end)

local function SetBodyPartHidden(groupName, isHidden)
    local char = LocalPlayer.Character
    if not char then return end
    char:SetAttribute("Hide_" .. groupName, isHidden)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            if BodyPartGroups[groupName] then
                for _, name in ipairs(BodyPartGroups[groupName]) do
                    if p.Name == name then
                        p.Transparency = isHidden and 1 or 0
                        if groupName == "Head" then
                            local face = p:FindFirstChildWhichIsA("Decal")
                            if face then face.Transparency = isHidden and 1 or 0 end
                        end
                    end
                end
            end
        end
    end
end

-- ==========================================================
-- BÚSQUEDA
-- ==========================================================
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
-- UI
-- ==========================================================
if CoreGui:FindFirstChild("LooksProVisualGui") then CoreGui.LooksProVisualGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "LooksProVisualGui"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 50
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

-- 👁
local EyeBtn = Instance.new("TextButton")
EyeBtn.Size = IS_MOBILE and UDim2.new(0, 52, 0, 52) or UDim2.new(0, 48, 0, 48)
EyeBtn.Position = UDim2.new(1, IS_MOBILE and -72 or -66, 0.30, 0)
EyeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
EyeBtn.Text = "👁"
EyeBtn.Font = Enum.Font.GothamBold
EyeBtn.TextSize = IS_MOBILE and 24 or 22
EyeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EyeBtn.Parent = Gui
Instance.new("UICorner", EyeBtn).CornerRadius = UDim.new(1, 0)

-- ↔️
local HorizBtn = Instance.new("TextButton")
HorizBtn.Size = IS_MOBILE and UDim2.new(0, 42, 0, 42) or UDim2.new(0, 38, 0, 38)
HorizBtn.Position = UDim2.new(1, IS_MOBILE and -68 or -62, 0.22, 0)
HorizBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
HorizBtn.Text = "↔️"
HorizBtn.Font = Enum.Font.GothamBold
HorizBtn.TextSize = 16
HorizBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HorizBtn.Parent = Gui
Instance.new("UICorner", HorizBtn).CornerRadius = UDim.new(1, 0)
HorizBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            pg.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
            Notify("Horizontal", "Modo horizontal activado", 2)
        end
    end)
end)

-- 👀
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = IS_MOBILE and UDim2.new(0, 64, 0, 64) or UDim2.new(0, 56, 0, 56)
FloatBtn.Position = UDim2.new(1, IS_MOBILE and -78 or -70, 0.40, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
FloatBtn.Text = "👀"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = IS_MOBILE and 28 or 24
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Parent = Gui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- ==========================================================
-- MAIN LOOKS  (FIX LAYOUT)
-- ==========================================================
local Main = Instance.new("Frame")
Main.Name = "MainLooks"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
Main.Visible = false
Main.ClipsDescendants = true          -- impide que se salgan
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local sizeConst = Instance.new("UISizeConstraint")
sizeConst.MinSize = Vector2.new(280, 280)
sizeConst.MaxSize = Vector2.new(560, 650)
sizeConst.Parent = Main

local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Thickness = 2

-- Tamaño dinámico según orientación
local function UpdateMainSize()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local isLandscape = vp.X > vp.Y

    if isLandscape then
        Main.Size = UDim2.new(0, math.min(520, math.floor(vp.X * 0.72)), 0, math.min(360, math.floor(vp.Y * 0.78)))
    else
        Main.Size = UDim2.new(0, math.min(410, math.floor(vp.X * 0.92)), 0, math.min(560, math.floor(vp.Y * 0.82)))
    end
end
UpdateMainSize()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMainSize)
end

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👀 Looks Pro v10"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
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
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -24, 0, 34)
SearchBox.Position = UDim2.new(0, 12, 0, 54)
SearchBox.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
SearchBox.PlaceholderText = "🔍 Búsqueda profunda..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 13
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
SearchBox.Parent = Main
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

local IdBox = Instance.new("TextBox")
IdBox.Size = UDim2.new(0.62, 0, 0, 30)
IdBox.Position = UDim2.new(0, 12, 0, 94)
IdBox.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
IdBox.PlaceholderText = "Look ID..."
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
IdBtn.Text = "Cargar"
IdBtn.Font = Enum.Font.GothamBold
IdBtn.TextSize = 12
IdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
IdBtn.Parent = Main
Instance.new("UICorner", IdBtn).CornerRadius = UDim.new(0, 7)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -24, 0, 20)
StatusLbl.Position = UDim2.new(0, 12, 0, 130)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Keep on Death ON • Usa Atrás / Siguiente"
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = Main

-- SCROLL con límites estrictos (FIX)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "LooksScroll"
Scroll.Size = UDim2.new(1, -24, 1, -200)       -- espacio fijo arriba y abajo
Scroll.Position = UDim2.new(0, 12, 0, 154)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Scroll.BackgroundTransparency = 0.35
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ElasticBehavior = Enum.ElasticBehavior.Never  -- evita que se salga
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.None -- control manual
Scroll.ClipsDescendants = true                       -- clave
Scroll.Parent = Main
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 108, 0, 130)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = Scroll

local GridPad = Instance.new("UIPadding")
GridPad.PaddingTop = UDim.new(0, 6)
GridPad.PaddingBottom = UDim.new(0, 12)
GridPad.Parent = Scroll

local function UpdateCanvas()
    local contentY = Grid.AbsoluteContentSize.Y + 18
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(contentY, 10))
end
Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

-- Barra de páginas fija abajo
local PageBar = Instance.new("Frame")
PageBar.Size = UDim2.new(1, -24, 0, 36)
PageBar.Position = UDim2.new(0, 12, 1, -48)
PageBar.BackgroundTransparency = 1
PageBar.Parent = Main

local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0.3, 0, 1, 0)
PrevBtn.Position = UDim2.new(0, 0, 0, 0)
PrevBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PrevBtn.Text = "⬅️ Atrás"
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 13
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.Parent = PageBar
Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 8)

local PageLbl = Instance.new("TextLabel")
PageLbl.Size = UDim2.new(0.36, 0, 1, 0)
PageLbl.Position = UDim2.new(0.32, 0, 0, 0)
PageLbl.BackgroundTransparency = 1
PageLbl.Text = "1 / 1"
PageLbl.Font = Enum.Font.GothamBold
PageLbl.TextSize = 13
PageLbl.TextColor3 = Color3.fromRGB(255, 105, 180)
PageLbl.Parent = PageBar

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0.3, 0, 1, 0)
NextBtn.Position = UDim2.new(0.7, 0, 0, 0)
NextBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NextBtn.Text = "Siguiente ➡️"
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 13
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Parent = PageBar
Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================================
-- MENÚ DE GUARDADO (gestor de cartas)
-- ==========================================================
local SaveMenu = Instance.new("Frame")
SaveMenu.AnchorPoint = Vector2.new(0.5, 0.5)
SaveMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
SaveMenu.Size = IS_MOBILE and UDim2.new(0.9, 0, 0.78, 0) or UDim2.new(0, 360, 0, 480)
SaveMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SaveMenu.Visible = false
SaveMenu.ClipsDescendants = true
SaveMenu.Parent = Gui
Instance.new("UICorner", SaveMenu).CornerRadius = UDim.new(0, 14)
local saveStroke = Instance.new("UIStroke", SaveMenu)
saveStroke.Color = Color3.fromRGB(100, 255, 150)
saveStroke.Thickness = 2

local SaveHeader = Instance.new("Frame")
SaveHeader.Size = UDim2.new(1, 0, 0, 44)
SaveHeader.BackgroundColor3 = Color3.fromRGB(25, 40, 30)
SaveHeader.Parent = SaveMenu
Instance.new("UICorner", SaveHeader).CornerRadius = UDim.new(0, 14)

local SaveTitle = Instance.new("TextLabel")
SaveTitle.Size = UDim2.new(1, -50, 1, 0)
SaveTitle.Position = UDim2.new(0, 14, 0, 0)
SaveTitle.BackgroundTransparency = 1
SaveTitle.Text = "💾 Skins Guardadas"
SaveTitle.Font = Enum.Font.GothamBold
SaveTitle.TextSize = 15
SaveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTitle.TextXAlignment = Enum.TextXAlignment.Left
SaveTitle.Parent = SaveHeader

local SaveClose = Instance.new("TextButton")
SaveClose.Size = UDim2.new(0, 30, 0, 30)
SaveClose.Position = UDim2.new(1, -38, 0.5, -15)
SaveClose.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
SaveClose.Text = "X"
SaveClose.Font = Enum.Font.GothamBold
SaveClose.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveClose.Parent = SaveHeader
Instance.new("UICorner", SaveClose).CornerRadius = UDim.new(0, 7)
SaveClose.MouseButton1Click:Connect(function() SaveMenu.Visible = false end)

local NewSaveFrame = Instance.new("Frame")
NewSaveFrame.Size = UDim2.new(1, -20, 0, 70)
NewSaveFrame.Position = UDim2.new(0, 10, 0, 52)
NewSaveFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
NewSaveFrame.Parent = SaveMenu
Instance.new("UICorner", NewSaveFrame).CornerRadius = UDim.new(0, 10)

local SaveNameBox = Instance.new("TextBox")
SaveNameBox.Size = UDim2.new(1, -20, 0, 30)
SaveNameBox.Position = UDim2.new(0, 10, 0, 8)
SaveNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SaveNameBox.PlaceholderText = "Nombre de la nueva skin..."
SaveNameBox.Text = ""
SaveNameBox.Font = Enum.Font.Gotham
SaveNameBox.TextSize = 13
SaveNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNameBox.Parent = NewSaveFrame
Instance.new("UICorner", SaveNameBox).CornerRadius = UDim.new(0, 7)

local SaveNowBtn = Instance.new("TextButton")
SaveNowBtn.Size = UDim2.new(1, -20, 0, 26)
SaveNowBtn.Position = UDim2.new(0, 10, 0, 40)
SaveNowBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 90)
SaveNowBtn.Text = "💾 Guardar skin actual"
SaveNowBtn.Font = Enum.Font.GothamBold
SaveNowBtn.TextSize = 12
SaveNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNowBtn.Parent = NewSaveFrame
Instance.new("UICorner", SaveNowBtn).CornerRadius = UDim.new(0, 7)

local SkinsScroll = Instance.new("ScrollingFrame")
SkinsScroll.Size = UDim2.new(1, -20, 1, -140)
SkinsScroll.Position = UDim2.new(0, 10, 0, 130)
SkinsScroll.BackgroundTransparency = 1
SkinsScroll.ScrollBarThickness = 5
SkinsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 255, 150)
SkinsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
SkinsScroll.ElasticBehavior = Enum.ElasticBehavior.Never
SkinsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SkinsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SkinsScroll.ClipsDescendants = true
SkinsScroll.Parent = SaveMenu

local SkinsList = Instance.new("UIListLayout")
SkinsList.SortOrder = Enum.SortOrder.LayoutOrder
SkinsList.Padding = UDim.new(0, 8)
SkinsList.Parent = SkinsScroll

local SkinsPad = Instance.new("UIPadding")
SkinsPad.PaddingBottom = UDim.new(0, 16)
SkinsPad.Parent = SkinsScroll

local function RefreshSkinsList()
    for _, c in ipairs(SkinsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    local count = 0
    for name, entry in pairs(Skins) do
        count += 1
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 64)
        Card.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Card.Parent = SkinsScroll
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0.55, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 12, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = entry.name or name
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextSize = 13
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        NameLbl.Parent = Card

        local LoadBtn = Instance.new("TextButton")
        LoadBtn.Size = UDim2.new(0, 64, 0, 28)
        LoadBtn.Position = UDim2.new(1, -140, 0.5, -14)
        LoadBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 220)
        LoadBtn.Text = "Cargar"
        LoadBtn.Font = Enum.Font.GothamBold
        LoadBtn.TextSize = 12
        LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoadBtn.Parent = Card
        Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)

        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0, 56, 0, 28)
        DelBtn.Position = UDim2.new(1, -68, 0.5, -14)
        DelBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        DelBtn.Text = "Borrar"
        DelBtn.Font = Enum.Font.GothamBold
        DelBtn.TextSize = 12
        DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DelBtn.Parent = Card
        Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 6)

        LoadBtn.MouseButton1Click:Connect(function()
            ApplySavedSkin(entry)
            SaveMenu.Visible = false
        end)

        DelBtn.MouseButton1Click:Connect(function()
            Skins[name] = nil
            SaveJSON(SKINS_FILE, Skins)
            Notify("🗑️ Borrada", entry.name or name, 2)
            RefreshSkinsList()
        end)
    end

    if count == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "No hay skins guardadas aún"
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.Parent = SkinsScroll
    end
end

SaveNowBtn.MouseButton1Click:Connect(function()
    local name = SaveNameBox.Text
    if name == "" then name = "Skin_" .. os.time() end

    local char = LocalPlayer.Character
    local ids = {}
    if char then
        for _, v in ipairs(char:GetChildren()) do
            local aid = v:GetAttribute("AssetId")
            if aid then table.insert(ids, aid) end
        end
    end

    Skins[name] = {
        name = name,
        ids = ids,
        lookIds = SavedLookIds,
        savedAt = os.time()
    }
    SaveJSON(SKINS_FILE, Skins)
    Notify("💾 Guardada", name, 3)
    SaveNameBox.Text = ""
    RefreshSkinsList()
end)

-- ==========================================================
-- MENÚ 👁
-- ==========================================================
local EyeMenu = Instance.new("Frame")
EyeMenu.AnchorPoint = Vector2.new(0.5, 0.5)
EyeMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
EyeMenu.Size = IS_MOBILE and UDim2.new(0.9, 0, 0.75, 0) or UDim2.new(0, 360, 0, 480)
EyeMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
EyeMenu.Visible = false
EyeMenu.ClipsDescendants = true
EyeMenu.Parent = Gui
Instance.new("UICorner", EyeMenu).CornerRadius = UDim.new(0, 14)
local eyeStroke = Instance.new("UIStroke", EyeMenu)
eyeStroke.Color = Color3.fromRGB(100, 180, 255)
eyeStroke.Thickness = 2

local EyeHeader = Instance.new("Frame")
EyeHeader.Size = UDim2.new(1, 0, 0, 42)
EyeHeader.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
EyeHeader.Parent = EyeMenu
Instance.new("UICorner", EyeHeader).CornerRadius = UDim.new(0, 14)

local EyeTitle = Instance.new("TextLabel")
EyeTitle.Size = UDim2.new(1, -50, 1, 0)
EyeTitle.Position = UDim2.new(0, 12, 0, 0)
EyeTitle.BackgroundTransparency = 1
EyeTitle.Text = "👁 Items & Partes"
EyeTitle.Font = Enum.Font.GothamBold
EyeTitle.TextSize = 14
EyeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
EyeTitle.TextXAlignment = Enum.TextXAlignment.Left
EyeTitle.Parent = EyeHeader

local EyeClose = Instance.new("TextButton")
EyeClose.Size = UDim2.new(0, 30, 0, 30)
EyeClose.Position = UDim2.new(1, -38, 0.5, -15)
EyeClose.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
EyeClose.Text = "X"
EyeClose.Font = Enum.Font.GothamBold
EyeClose.TextColor3 = Color3.fromRGB(255, 255, 255)
EyeClose.Parent = EyeHeader
Instance.new("UICorner", EyeClose).CornerRadius = UDim.new(0, 7)

local PartsFrame = Instance.new("Frame")
PartsFrame.Size = UDim2.new(1, -20, 0, 70)
PartsFrame.Position = UDim2.new(0, 10, 0, 50)
PartsFrame.BackgroundTransparency = 1
PartsFrame.Parent = EyeMenu

local PartsLabel = Instance.new("TextLabel")
PartsLabel.Size = UDim2.new(1, 0, 0, 20)
PartsLabel.BackgroundTransparency = 1
PartsLabel.Text = "Ocultar partes del cuerpo"
PartsLabel.Font = Enum.Font.GothamBold
PartsLabel.TextSize = 12
PartsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PartsLabel.TextXAlignment = Enum.TextXAlignment.Left
PartsLabel.Parent = PartsFrame

local partNames = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
local partLabels = {"Cabeza", "Torso", "Brazo Izq", "Brazo Der", "Pierna Izq", "Pierna Der"}

for i, g in ipairs(partNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 52, 0, 28)
    b.Position = UDim2.new(0, (i-1)*54, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.Text = partLabels[i]
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = PartsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    local hidden = false
    b.MouseButton1Click:Connect(function()
        hidden = not hidden
        SetBodyPartHidden(g, hidden)
        b.BackgroundColor3 = hidden and Color3.fromRGB(180, 50, 80) or Color3.fromRGB(50, 50, 60)
    end)
end

local EqScroll = Instance.new("ScrollingFrame")
EqScroll.Size = UDim2.new(1, -20, 1, -140)
EqScroll.Position = UDim2.new(0, 10, 0, 130)
EqScroll.BackgroundTransparency = 1
EqScroll.ScrollBarThickness = 5
EqScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 180, 255)
EqScroll.ScrollingDirection = Enum.ScrollingDirection.Y
EqScroll.ElasticBehavior = Enum.ElasticBehavior.Never
EqScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
EqScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
EqScroll.ClipsDescendants = true
EqScroll.Parent = EyeMenu

local EqGrid = Instance.new("UIGridLayout")
EqGrid.CellSize = UDim2.new(0, 70, 0, 70)
EqGrid.CellPadding = UDim2.new(0, 8, 0, 8)
EqGrid.Parent = EqScroll

local EqPad = Instance.new("UIPadding")
EqPad.PaddingBottom = UDim.new(0, 16)
EqPad.Parent = EqScroll

local function RefreshEquippedGrid()
    for _, c in ipairs(EqScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("ImageButton") then c:Destroy() end
    end
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            local id = v:GetAttribute("AssetId") or 0
            local Card = Instance.new("ImageButton")
            Card.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Card.Parent = EqScroll
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

            local Img = Instance.new("ImageLabel")
            Img.Size = UDim2.new(1, -6, 1, -6)
            Img.Position = UDim2.new(0, 3, 0, 3)
            Img.BackgroundTransparency = 1
            Img.ScaleType = Enum.ScaleType.Fit
            Img.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
            Img.Parent = Card
            Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 6)

            Card.MouseButton1Click:Connect(function()
                v:Destroy()
                Notify("Desequipado", v.Name, 2)
                task.wait(0.1)
                RefreshEquippedGrid()
            end)
        end
    end
end

EyeBtn.MouseButton1Click:Connect(function()
    EyeMenu.Visible = not EyeMenu.Visible
    if EyeMenu.Visible then RefreshEquippedGrid() end
end)
EyeClose.MouseButton1Click:Connect(function() EyeMenu.Visible = false end)

-- ==========================================================
-- CARDS + PAGINACIÓN ESTRICTA
-- ==========================================================
local function ClearCards()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function GetBestThumb(look)
    if look.items and #look.items > 0 then
        for _, it in ipairs(look.items) do
            local id = it.id or it.assetId
            if id and tonumber(id) then return tonumber(id) end
        end
    end
    return tonumber(look.id) or tonumber(look.lookId) or 1
end

local function CreateCard(look)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Card.Parent = Scroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Img = Instance.new("ImageLabel")
    Img.Size = UDim2.new(1, -8, 0, 82)
    Img.Position = UDim2.new(0, 4, 0, 4)
    Img.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Img.ScaleType = Enum.ScaleType.Fit
    Img.Parent = Card
    Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 8)

    local thumbId = GetBestThumb(look)
    Img.Image = "rbxthumb://type=Asset&id=" .. tostring(thumbId) .. "&w=150&h=150"

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -6, 0, 34)
    Name.Position = UDim2.new(0, 3, 0, 88)
    Name.BackgroundTransparency = 1
    Name.Text = look.name or ("Look " .. tostring(look.id))
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
end

local function RefreshPage()
    ClearCards()
    local total = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
    CurrentPage = math.clamp(CurrentPage, 1, total)
    PageLbl.Text = CurrentPage .. " / " .. total

    local start = (CurrentPage - 1) * PAGE_SIZE + 1
    local finish = math.min(start + PAGE_SIZE - 1, #CurrentResults)
    for i = start, finish do
        CreateCard(CurrentResults[i])
    end

    -- Reset al top de la página (evita items “ocultos”)
    Scroll.CanvasPosition = Vector2.new(0, 0)
    task.defer(UpdateCanvas)
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
-- BÚSQUEDA
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
        task.wait(0.4)
        StatusLbl.Text = "Búsqueda profunda..."
        ClearCards()
        local ids = SearchLooks(q)
        if #ids == 0 then
            StatusLbl.Text = "Sin resultados"
            return
        end
        StatusLbl.Text = "Cargando..."
        CurrentResults = {}
        CurrentPage = 1

        local batch = {}
        for i, id in ipairs(ids) do
            if i > MAX_RESULTS then break end
            table.insert(batch, id)
            if #batch >= 5 or i == math.min(#ids, MAX_RESULTS) then
                local threads = {}
                for _, bid in ipairs(batch) do
                    table.insert(threads, task.spawn(function()
                        local data = FetchLook(bid)
                        if data then
                            data.id = data.id or data.lookId or bid
                            table.insert(CurrentResults, data)
                        end
                    end))
                end
                for _ = 1, #threads do task.wait() end
                batch = {}
                RefreshPage()
            end
        end
        StatusLbl.Text = #CurrentResults .. " looks"
        RefreshPage()
    end)
end)

IdBtn.MouseButton1Click:Connect(function()
    local id = IdBox.Text:match("%d+")
    if not id then Notify("Error", "ID inválido", 2) return end
    task.spawn(function()
        local data = FetchLook(id)
        if data then
            data.id = data.id or id
            ApplyLookReal(data)
        else
            Notify("Error", "Look no encontrado", 3)
        end
    end)
end)

-- ==========================================================
-- LONG PRESS + EVENTOS
-- ==========================================================
local holding, holdStart = false, 0
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        holding = true
        holdStart = tick()
    end
end)
FloatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if holding and (tick() - holdStart) >= 0.55 then
            SaveMenu.Visible = true
            RefreshSkinsList()
        else
            Main.Visible = not Main.Visible
            FloatBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(180, 60, 130) or Color3.fromRGB(255, 105, 180)
            if Main.Visible then
                UpdateMainSize()
            end
        end
        holding = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
end)

local drag, dStart, sPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = i.Position
        sPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

Notify("Looks Pro v10 + Fix", "Horizontal estable • Límites • Atrás/Siguiente", 5)
