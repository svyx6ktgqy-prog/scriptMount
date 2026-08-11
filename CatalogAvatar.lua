-- ==========================================================
-- ALB8RAAQ CATALOG PRO (v10.0)
-- Fix Categorías Reales + Fix Compra Nativa + Equipamiento Agresivo
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }

-- ==========================================================
-- SISTEMA DE EQUIPAMIENTO AGRESIVO (ANTI-REVERSIÓN)
-- ==========================================================
local function UniversalEquip(assetId)
    task.spawn(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end

        local assetNum = tonumber(assetId)
        if not assetNum then return end

        -- Método 1: Intentar saltar restricción con GetObjects (Si el ejecutor lo permite)
        local successObjects = pcall(function()
            local objects = game:GetObjects("rbxassetid://" .. tostring(assetNum))
            for _, obj in ipairs(objects) do
                if obj:IsA("Accessory") then
                    Hum:AddAccessory(obj:Clone())
                elseif obj:IsA("Clothing") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") then
                    for _, v in pairs(Char:GetChildren()) do
                        if v.ClassName == obj.ClassName then v:Destroy() end
                    end
                    obj:Clone().Parent = Char
                end
            end
        end)

        if successObjects then return end -- Si funcionó, detenemos aquí.

        -- Método 2: Intentar con InsertService (Algunos ejecutores nivel 8 desbloquean esto)
        local successInsert = pcall(function()
            local model = InsertService:LoadAsset(assetNum)
            for _, obj in ipairs(model:GetChildren()) do
                if obj:IsA("Accessory") then
                    Hum:AddAccessory(obj:Clone())
                elseif obj:IsA("Clothing") or obj:IsA("ShirtGraphic") then
                    for _, v in pairs(Char:GetChildren()) do
                        if v.ClassName == obj.ClassName then v:Destroy() end
                    end
                    obj:Clone().Parent = Char
                end
            end
            model:Destroy()
        end)

        if successInsert then return end

        -- Método 3: HumanoidDescription Agresivo (Reconstrucción local)
        pcall(function()
            local desc = Hum:GetAppliedDescription()
            local s_info, info = pcall(function() return MarketplaceService:GetProductInfo(assetNum) end)
            
            if s_info and info then
                local typeId = info.AssetTypeId
                
                if typeId == 2 then desc.GraphicTShirt = assetNum
                elseif typeId == 11 then desc.Shirt = assetNum
                elseif typeId == 12 then desc.Pants = assetNum
                elseif typeId == 18 then desc.Face = assetNum
                elseif typeId == 17 then desc.Head = assetNum
                elseif typeId == 8 or typeId == 41 then 
                    desc.HairAccessory = desc.HairAccessory == "" and tostring(assetNum) or desc.HairAccessory .. "," .. tostring(assetNum)
                elseif typeId == 42 then 
                    desc.FaceAccessory = desc.FaceAccessory == "" and tostring(assetNum) or desc.FaceAccessory .. "," .. tostring(assetNum)
                elseif typeId == 43 then 
                    desc.NeckAccessory = desc.NeckAccessory == "" and tostring(assetNum) or desc.NeckAccessory .. "," .. tostring(assetNum)
                elseif typeId == 44 then 
                    desc.ShoulderAccessory = desc.ShoulderAccessory == "" and tostring(assetNum) or desc.ShoulderAccessory .. "," .. tostring(assetNum)
                elseif typeId == 45 then 
                    desc.FrontAccessory = desc.FrontAccessory == "" and tostring(assetNum) or desc.FrontAccessory .. "," .. tostring(assetNum)
                elseif typeId == 46 then 
                    desc.BackAccessory = desc.BackAccessory == "" and tostring(assetNum) or desc.BackAccessory .. "," .. tostring(assetNum)
                elseif typeId == 47 then 
                    desc.WaistAccessory = desc.WaistAccessory == "" and tostring(assetNum) or desc.WaistAccessory .. "," .. tostring(assetNum)
                end
                
                -- Se aplica forzadamente
                Hum:ApplyDescription(desc)
            end
        end)
    end)
end

-- ==========================================================
-- VISUALIZADOR Y COMPRA NATIVA (FIXED)
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then
    CoreGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 160, 0, 195)
Container.Position = UDim2.new(1, -180, 0.5, -95)
Container.BackgroundTransparency = 1
Container.Visible = false
Container.Parent = VisualizerGui

local ImagePreview = Instance.new("ImageButton")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.AutoButtonColor = true 
ImagePreview.Parent = Container

-- FIX COMPRA: Forzamos la alerta nativa envolviéndola en un pcall robusto
ImagePreview.MouseButton1Click:Connect(function()
    local idNum = tonumber(CurrentData.Id)
    if idNum and idNum > 0 then
        pcall(function()
            if CurrentData.ItemType == "Bundle" then
                MarketplaceService:PromptBundlePurchase(LocalPlayer, idNum)
            else
                MarketplaceService:PromptPurchase(LocalPlayer, idNum)
            end
        end)
    end
end)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ImagePreview

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(150, 150, 150)
UIStroke.Thickness = 2
UIStroke.Parent = ImagePreview

local RedUnderline = Instance.new("Frame")
RedUnderline.Size = UDim2.new(1, -20, 0, 4)
RedUnderline.Position = UDim2.new(0.5, 0, 1, -4)
RedUnderline.AnchorPoint = Vector2.new(0.5, 0)
RedUnderline.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedUnderline.BorderSizePixel = 0
RedUnderline.ZIndex = 2
RedUnderline.Parent = ImagePreview

local PriceFrame = Instance.new("Frame")
PriceFrame.Size = UDim2.new(1, 0, 0, 30)
PriceFrame.Position = UDim2.new(0, 0, 0, 165)
PriceFrame.BackgroundTransparency = 1
PriceFrame.Parent = Container

local PriceLayout = Instance.new("UIListLayout")
PriceLayout.FillDirection = Enum.FillDirection.Horizontal
PriceLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PriceLayout.VerticalAlignment = Enum.VerticalAlignment.Center
PriceLayout.Padding = UDim.new(0, 6)
PriceLayout.Parent = PriceFrame

local RobuxIcon = Instance.new("ImageLabel")
RobuxIcon.Size = UDim2.new(0, 18, 0, 18)
RobuxIcon.BackgroundTransparency = 1
RobuxIcon.Image = "rbxassetid://11560341824"
RobuxIcon.Parent = PriceFrame

local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(0, 0, 1, 0)
PriceTag.AutomaticSize = Enum.AutomaticSize.X
PriceTag.BackgroundTransparency = 1 
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 18
PriceTag.TextXAlignment = Enum.TextXAlignment.Left
PriceTag.Parent = PriceFrame

local function UpdateVisualizer(id, price)
    ImagePreview.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    Container.Visible = true
    if price == 0 or price == "Gratis" or price == "Gratis / Off-Sale" then
        RobuxIcon.Visible = false
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        RobuxIcon.Visible = true
        PriceTag.Text = tostring(price):gsub(" R%$", "")
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0)
    end
end

-- ==========================================================
-- KITTY CATALOG UI & CATEGORÍAS EXACTAS
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then
    CoreGui.KittyCatalogGui:Destroy()
end

local KittyGui = Instance.new("ScreenGui")
KittyGui.Name = "KittyCatalogGui"
KittyGui.Enabled = false 
KittyGui.Parent = CoreGui

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "KittyFloatingBtn"
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = UDim2.new(1, -80, 0.5, -30)
FloatingBtn.Image = "rbxassetid://15538455161"
FloatingBtn.BackgroundTransparency = 1
FloatingBtn.Visible = false 
FloatingBtn.Parent = KittyGui

local dragToggle, dragInput, dragStart, startPos
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = FloatingBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
FloatingBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        FloatingBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local KittyMain = Instance.new("Frame")
KittyMain.Size = UDim2.new(0.95, 0, 0.9, 0) 
KittyMain.Position = UDim2.new(0.5, 0, 0.5, 0) 
KittyMain.AnchorPoint = Vector2.new(0.5, 0.5) 
KittyMain.BackgroundColor3 = Color3.fromRGB(255, 182, 193) 
KittyMain.BackgroundTransparency = 0.15 
KittyMain.BorderSizePixel = 0
KittyMain.ClipsDescendants = true
KittyMain.Parent = KittyGui

FloatingBtn.MouseButton1Click:Connect(function()
    FloatingBtn.Visible = false
    KittyMain.Visible = true
end)

local KittyConstraint = Instance.new("UISizeConstraint")
KittyConstraint.MaxSize = Vector2.new(850, 550) 
KittyConstraint.MinSize = Vector2.new(300, 250)
KittyConstraint.Parent = KittyMain

local KittyCorner = Instance.new("UICorner")
KittyCorner.CornerRadius = UDim.new(0, 16)
KittyCorner.Parent = KittyMain

local KittyStroke = Instance.new("UIStroke")
KittyStroke.Color = Color3.fromRGB(255, 105, 180) 
KittyStroke.Thickness = 3
KittyStroke.Parent = KittyMain

local KittyTop = Instance.new("Frame")
KittyTop.Size = UDim2.new(0.75, 0, 0, 60)
KittyTop.Position = UDim2.new(0.25, 0, 0, 0)
KittyTop.BackgroundTransparency = 1
KittyTop.Parent = KittyMain

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = KittyTop
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0) 

CloseBtn.MouseButton1Click:Connect(function()
    KittyMain.Visible = false
    FloatingBtn.Visible = true
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.60, 0, 0, 40)
SearchContainer.Position = UDim2.new(0, 10, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SearchContainer.Parent = KittyTop
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)

local KittySearch = Instance.new("TextBox")
KittySearch.Size = UDim2.new(1, -20, 1, 0)
KittySearch.Position = UDim2.new(0, 10, 0, 0)
KittySearch.BackgroundTransparency = 1
KittySearch.PlaceholderText = "🔍 Search..."
KittySearch.Text = ""
KittySearch.Font = Enum.Font.GothamMedium
KittySearch.TextSize = 14
KittySearch.TextColor3 = Color3.fromRGB(50, 50, 50)
KittySearch.TextXAlignment = Enum.TextXAlignment.Left
KittySearch.Parent = SearchContainer

local KittySearchBtn = Instance.new("TextButton")
KittySearchBtn.Size = UDim2.new(0.20, 0, 0, 40)
KittySearchBtn.Position = UDim2.new(0.64, 0, 0.5, -20)
KittySearchBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
KittySearchBtn.Text = "Search"
KittySearchBtn.Font = Enum.Font.GothamBold
KittySearchBtn.TextSize = 14
KittySearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KittySearchBtn.Parent = KittyTop
Instance.new("UICorner", KittySearchBtn).CornerRadius = UDim.new(0, 8)

local KittySidebar = Instance.new("ScrollingFrame")
KittySidebar.Size = UDim2.new(0.25, 0, 1, 0)
KittySidebar.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
KittySidebar.BackgroundTransparency = 0.5
KittySidebar.BorderSizePixel = 0
KittySidebar.ScrollBarThickness = 4
KittySidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
KittySidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
KittySidebar.Parent = KittyMain

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.Parent = KittySidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 5)
SidebarPadding.PaddingRight = UDim.new(0, 5)
SidebarPadding.PaddingBottom = UDim.new(0, 10)
SidebarPadding.Parent = KittySidebar

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(0.75, 0, 1, -60)
KittyResults.Position = UDim2.new(0.25, 0, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.ScrollBarThickness = 6
KittyResults.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
KittyResults.AutomaticCanvasSize = Enum.AutomaticSize.Y 
KittyResults.CanvasSize = UDim2.new(0, 0, 0, 0)
KittyResults.Parent = KittyMain

local ResultsLayout = Instance.new("UIGridLayout")
ResultsLayout.CellSize = UDim2.new(0, 130, 0, 180) 
ResultsLayout.CellPadding = UDim2.new(0, 10, 0, 15)
ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ResultsLayout.Parent = KittyResults

local ResultsPadding = Instance.new("UIPadding")
ResultsPadding.PaddingTop = UDim.new(0, 10)
ResultsPadding.PaddingLeft = UDim.new(0, 10)
ResultsPadding.PaddingBottom = UDim.new(0, 20)
ResultsPadding.Parent = KittyResults

local TitleCat = Instance.new("TextLabel")
TitleCat.Size = UDim2.new(1, 0, 0, 40)
TitleCat.BackgroundTransparency = 1
TitleCat.Text = "🎀 Category"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 16
TitleCat.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleCat.TextXAlignment = Enum.TextXAlignment.Center
TitleCat.Parent = KittySidebar

-- ==========================================================
-- CATEGORÍAS REALES DEL CATÁLOGO DE ROBLOX
-- Formato: {Nombre, ID Categoria, ID Subcategoria (nil si no tiene)}
-- ==========================================================
local KittyCurrentCategory = 1 
local KittyCurrentSubcategory = nil

local ExactCategories = {
    {"All", 1, nil},
    {"-- BODY --", 0, nil},
    {"Hair", 4, 20},
    {"Heads", 4, 15},
    {"Face", 4, 10},
    {"-- CLOTHING --", 0, nil},
    {"Classic Shirts", 3, 12},
    {"Classic T-Shirts", 3, 13},
    {"Classic Pants", 3, 14},
    {"Shirts (3D)", 3, 56},
    {"Sweaters", 3, 58},
    {"Jackets", 3, 57},
    {"Pants (3D)", 3, 59},
    {"Shoes", 3, 54},
    {"-- ACCESSORIES --", 0, nil},
    {"Head Acc", 11, 9},
    {"Face Acc", 11, 10},
    {"Neck Acc", 11, 11},
    {"Shoulder Acc", 11, 12},
    {"Front Acc", 11, 13},
    {"Back Acc", 11, 14},
    {"Waist Acc", 11, 15},
    {"Gear", 5, nil},
    {"-- ANIMATIONS --", 0, nil},
    {"Bundles", 4, 37},
    {"Emotes", 12, nil}
}

for i, catData in ipairs(ExactCategories) do
    if catData[2] == 0 then
        -- Es un título separador
        local sep = Instance.new("TextLabel")
        sep.Size = UDim2.new(1, 0, 0, 25)
        sep.BackgroundTransparency = 1
        sep.Text = catData[1]
        sep.Font = Enum.Font.GothamBold
        sep.TextSize = 11
        sep.TextColor3 = Color3.fromRGB(255, 105, 180)
        sep.Parent = KittySidebar
    else
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(255, 228, 225)
        btn.Text = " " .. catData[1]
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(80, 80, 80)
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.Parent = KittySidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            KittyCurrentCategory = catData[2]
            KittyCurrentSubcategory = catData[3]
            KittySearch.PlaceholderText = "🔍 In " .. catData[1] .. "..."
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
            task.wait(0.2)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 228, 225)}):Play()
        end)
    end
end

local function PerformKittySearch()
    if KittySearch.Text == "" then return end
    
    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- URL estructurada para soportar subcategorías
    local baseUrl = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=30&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
    if KittyCurrentSubcategory then
        baseUrl = baseUrl .. "&subcategory=" .. tostring(KittyCurrentSubcategory)
    end

    local success, response = pcall(function() return game:HttpGet(baseUrl) end)
    
    if not success or not response then
        local fallbackUrl = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=30&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
        if KittyCurrentSubcategory then fallbackUrl = fallbackUrl .. "&subcategory=" .. tostring(KittyCurrentSubcategory) end
        success, response = pcall(function() return game:HttpGet(fallbackUrl) end)
    end

    if success and response then
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.data then
            for _, item in ipairs(decoded.data) do
                local Card = Instance.new("Frame")
                Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Card.Parent = KittyResults
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
                
                local CardImg = Instance.new("ImageLabel")
                CardImg.Size = UDim2.new(1, 0, 0, 100)
                CardImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                CardImg.Parent = Card
                Instance.new("UICorner", CardImg).CornerRadius = UDim.new(0, 10)
                
                local CardName = Instance.new("TextLabel")
                CardName.Size = UDim2.new(1, -10, 0, 25)
                CardName.Position = UDim2.new(0, 5, 0, 105)
                CardName.BackgroundTransparency = 1
                CardName.Text = item.name
                CardName.Font = Enum.Font.GothamSemibold
                CardName.TextSize = 11
                CardName.TextColor3 = Color3.fromRGB(30, 30, 30)
                CardName.TextWrapped = true
                CardName.TextXAlignment = Enum.TextXAlignment.Left
                CardName.Parent = Card
                
                local CardPrice = Instance.new("TextLabel")
                CardPrice.Size = UDim2.new(1, -25, 0, 20)
                CardPrice.Position = UDim2.new(0, 25, 0, 155)
                CardPrice.BackgroundTransparency = 1
                CardPrice.Text = item.price and tostring(item.price) or "Gratis"
                CardPrice.Font = Enum.Font.GothamBold
                CardPrice.TextSize = 13
                CardPrice.TextColor3 = Color3.fromRGB(50, 50, 50)
                CardPrice.TextXAlignment = Enum.TextXAlignment.Left
                CardPrice.Parent = Card
                
                local CardRobux = Instance.new("ImageLabel")
                CardRobux.Size = UDim2.new(0, 14, 0, 14)
                CardRobux.Position = UDim2.new(0, 6, 0, 158)
                CardRobux.BackgroundTransparency = 1
                CardRobux.Image = "rbxassetid://11560341824"
                CardRobux.Visible = (item.price ~= nil and item.price > 0)
                CardRobux.Parent = Card

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Text = ""
                ClickBtn.Parent = Card
                
                ClickBtn.MouseButton1Click:Connect(function()
                    CurrentData.Id = tostring(item.id)
                    CurrentData.Name = item.name
                    CurrentData.Price = item.price and (tostring(item.price) .. " R$") or "Gratis"
                    CurrentData.ItemType = item.itemType or "Asset" -- Vital para la alerta de compra
                    
                    UpdateVisualizer(item.id, item.price or "Gratis")
                    UniversalEquip(item.id)
                end)
            end
        end
    end
end

KittySearch.FocusLost:Connect(function(enterPressed)
    if enterPressed then PerformKittySearch() end
end)
KittySearchBtn.MouseButton1Click:Connect(PerformKittySearch)

-- ==========================================================
-- INICIADOR (Para invocar la UI de prueba directo)
-- ==========================================================
KittyGui.Enabled = true
KittyMain.Visible = true
