-- ==========================================================
-- LOOKS PRO VISUAL v9
-- • Miniaturas ligeras (sin lag)
-- • Menú de guardado restaurado
-- • Búsqueda profunda
-- • Botón modo horizontal
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
local PAGE_SIZE         = 12
local IS_MOBILE         = UserInputService.TouchEnabled
local MAX_RESULTS       = 48          -- búsqueda profunda

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
-- BÚSQUEDA PROFUNDA
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

-- Botón HORIZONTAL (pequeño)
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
            Notify("Modo Horizontal", "Pantalla en horizontal", 2)
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

-- Main
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = IS_MOBILE and UDim2.new(0.92, 0, 0.82, 0) or UDim2.new(0, 410, 0, 560)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
Instance.new("UISizeConstraint", Main).MaxSize = Vector2.new(480, 650)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(255, 105, 180)
stroke.Thickness = 2

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👀 Looks Pro v9"
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
SearchBox.PlaceholderText = "🔍 Búsqueda profunda (y2k, goth, emo...)"
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
StatusLbl.Text = "Keep on Death ON • Mantén 👀 = Guardar skin"
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -24, 0, 320)
Scroll.Position = UDim2.new(0, 12, 0, 154)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 112, 0, 136)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.Parent = Scroll
Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 12)
end)

local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0.3, 0, 0, 34)
PrevBtn.Position = UDim2.new(0.03, 0, 1, -52)
PrevBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PrevBtn.Text = "⬅️ Atrás"
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 13
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.Parent = Main
Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 8)

local PageLbl = Instance.new("TextLabel")
PageLbl.Size = UDim2.new(0.3, 0, 0, 34)
PageLbl.Position = UDim2.new(0.35, 0, 1, -52)
PageLbl.BackgroundTransparency = 1
PageLbl.Text = "1 / 1"
PageLbl.Font = Enum.Font.GothamBold
PageLbl.TextSize = 13
PageLbl.TextColor3 = Color3.fromRGB(255, 105, 180)
PageLbl.Parent = Main

local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0.3, 0, 0, 34)
NextBtn.Position = UDim2.new(0.67, 0, 1, -52)
NextBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NextBtn.Text = "Siguiente ➡️"
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 13
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Parent = Main
Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================================
-- MENÚ DE GUARDADO (restaurado)
-- ==========================================================
local SaveMenu = Instance.new("Frame")
SaveMenu.Size = UDim2.new(0, 290, 0, 170)
SaveMenu.Position = UDim2.new(0.5, -145, 0.5, -85)
SaveMenu.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SaveMenu.Visible = false
SaveMenu.Parent = Gui
Instance.new("UICorner", SaveMenu).CornerRadius = UDim.new(0, 14)
local ss = Instance.new("UIStroke", SaveMenu)
ss.Color = Color3.fromRGB(100, 255, 150)
ss.Thickness = 2

local SaveTitle = Instance.new("TextLabel")
SaveTitle.Size = UDim2.new(1, 0, 0, 38)
SaveTitle.BackgroundTransparency = 1
SaveTitle.Text = "💾 Guardar Skin Actual"
SaveTitle.Font = Enum.Font.GothamBold
SaveTitle.TextSize = 15
SaveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTitle.Parent = SaveMenu

local SaveName = Instance.new("TextBox")
SaveName.Size = UDim2.new(1, -24, 0, 36)
SaveName.Position = UDim2.new(0, 12, 0, 46)
SaveName.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SaveName.PlaceholderText = "Nombre de la skin..."
SaveName.Text = ""
SaveName.Font = Enum.Font.Gotham
SaveName.TextSize = 13
SaveName.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveName.Parent = SaveMenu
Instance.new("UICorner", SaveName).CornerRadius = UDim.new(0, 8)

local SaveConfirm = Instance.new("TextButton")
SaveConfirm.Size = UDim2.new(0.45, 0, 0, 36)
SaveConfirm.Position = UDim2.new(0.05, 0, 1, -50)
SaveConfirm.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
SaveConfirm.Text = "Guardar"
SaveConfirm.Font = Enum.Font.GothamBold
SaveConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfirm.Parent = SaveMenu
Instance.new("UICorner", SaveConfirm).CornerRadius = UDim.new(0, 8)

local SaveCancel = Instance.new("TextButton")
SaveCancel.Size = UDim2.new(0.45, 0, 0, 36)
SaveCancel.Position = UDim2.new(0.5, 0, 1, -50)
SaveCancel.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
SaveCancel.Text = "Cancelar"
SaveCancel.Font = Enum.Font.GothamBold
SaveCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveCancel.Parent = SaveMenu
Instance.new("UICorner", SaveCancel).CornerRadius = UDim.new(0, 8)

SaveCancel.MouseButton1Click:Connect(function()
    SaveMenu.Visible = false
end)

SaveConfirm.MouseButton1Click:Connect(function()
    local name = SaveName.Text
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
    Notify("💾 Guardado", name .. " → skins.json", 4)
    SaveMenu.Visible = false
    SaveName.Text = ""
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
EqScroll.ScrollBarThickness = 4
EqScroll.Parent = EyeMenu

local EqGrid = Instance.new("UIGridLayout")
EqGrid.CellSize = UDim2.new(0, 70, 0, 70)
EqGrid.CellPadding = UDim2.new(0, 8, 0, 8)
EqGrid.Parent = EqScroll
EqGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EqScroll.CanvasSize = UDim2.new(0, 0, 0, EqGrid.AbsoluteContentSize.Y + 10)
end)

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
-- CARDS LIGERAS (sin lag)
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
    Img.Size = UDim2.new(1, -8, 0, 86)
    Img.Position = UDim2.new(0, 4, 0, 4)
    Img.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Img.ScaleType = Enum.ScaleType.Fit
    Img.Parent = Card
    Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 8)

    local thumbId = GetBestThumb(look)
    Img.Image = "rbxthumb://type=Asset&id=" .. tostring(thumbId) .. "&w=150&h=150"

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -6, 0, 34)
    Name.Position = UDim2.new(0, 3, 0, 92)
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
end

PrevBtn.MouseButton1Click:Connect(function()
    if CurrentPage > 1 then CurrentPage -= 1 RefreshPage() end
end)
NextBtn.MouseButton1Click:Connect(function()
    local total = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
    if CurrentPage < total then CurrentPage += 1 RefreshPage() end
end)

-- ==========================================================
-- BÚSQUEDA PROFUNDA
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
            StatusLbl.Text = "Sin resultados (usa ID directo)"
            return
        end

        StatusLbl.Text = "Cargando " .. math.min(#ids, MAX_RESULTS) .. " looks..."
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
        StatusLbl.Text = #CurrentResults .. " looks cargados"
        RefreshPage()
    end)
end)

IdBtn.MouseButton1Click:Connect(function()
    local id = IdBox.Text:match("%d+")
    if not id then Notify("Error", "ID inválido", 2) return end
    StatusLbl.Text = "Cargando ID..."
    task.spawn(function()
        local data = FetchLook(id)
        if data then
            data.id = data.id or id
            ApplyLookReal(data)
            StatusLbl.Text = "Aplicado"
        else
            StatusLbl.Text = "Look no encontrado"
        end
    end)
end)

-- ==========================================================
-- LONG PRESS → MENÚ DE GUARDADO
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
            SaveName.Text = ""
        else
            Main.Visible = not Main.Visible
            FloatBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(180, 60, 130) or Color3.fromRGB(255, 105, 180)
        end
        holding = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
end)

-- Drag
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

Notify("Looks Pro v9 listo", "Sin lag • Menú guardado • Búsqueda profunda • ↔️ Horizontal", 5)
