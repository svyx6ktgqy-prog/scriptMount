-- ==========================================================
-- MENU DE AVATARES DEFINITIVO (GetObjects Engine)
-- Solución real para Ejecutores (Bypasses ApplyDescription)
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }

-- ==========================================================
-- SISTEMA DE EQUIPAMIENTO (MÉTODO EXPLOIT: GetObjects)
-- ==========================================================
local function UniversalEquip(assetId)
    task.spawn(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end

        -- MÉTODO DEFINITIVO: game:GetObjects() descarga el asset real (Texturas y Meshes correctos)
        local success, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(assetId))
        end)

        if success and objects and #objects > 0 then
            for _, asset in ipairs(objects) do
                if asset:IsA("Accessory") then
                    -- Equipar Accesorio 3D (Pelo, Sombreros, etc.)
                    Hum:AddAccessory(asset)
                    
                elseif asset:IsA("Shirt") then
                    -- Reemplazar Camisa
                    local old = Char:FindFirstChildOfClass("Shirt")
                    if old then old:Destroy() end
                    asset.Parent = Char
                    
                elseif asset:IsA("Pants") then
                    -- Reemplazar Pantalón
                    local old = Char:FindFirstChildOfClass("Pants")
                    if old then old:Destroy() end
                    asset.Parent = Char
                    
                elseif asset:IsA("ShirtGraphic") then
                    -- Reemplazar T-Shirt
                    local old = Char:FindFirstChildOfClass("ShirtGraphic")
                    if old then old:Destroy() end
                    asset.Parent = Char
                    
                elseif asset:IsA("Decal") then
                    -- Reemplazar Cara
                    local head = Char:FindFirstChild("Head")
                    if head then
                        local old = head:FindFirstChildOfClass("Decal")
                        if old then old:Destroy() end
                        asset.Parent = head
                    end
                else
                    asset:Destroy() -- Eliminar si no es equipable
                end
            end
        else
            -- FALLBACK: Si GetObjects falla (raro en buenos ejecutores), intentar inyección de textura cruda
            warn("GetObjects falló, intentando inyección cruda...")
            local s_info, info = pcall(function() return MarketplaceService:GetProductInfo(assetId) end)
            if not s_info or not info then return end

            local typeId = info.AssetTypeId
            if typeId == 2 then 
                local t = Char:FindFirstChildOfClass("ShirtGraphic") or Instance.new("ShirtGraphic", Char)
                t.Graphic = "rbxassetid://" .. assetId
            elseif typeId == 11 then 
                local s = Char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", Char)
                s.ShirtTemplate = "rbxassetid://" .. assetId
            elseif typeId == 12 then
                local p = Char:FindFirstChildOfClass("Pants") or Instance.new("Pants", Char)
                p.PantsTemplate = "rbxassetid://" .. assetId
            elseif typeId == 18 then
                local head = Char:FindFirstChild("Head")
                if head then
                    local face = head:FindFirstChildOfClass("Decal") or Instance.new("Decal", head)
                    face.Texture = "rbxassetid://" .. assetId
                end
            end
        end
    end)
end

-- ==========================================================
-- SISTEMA VISUALIZADOR Y COMPRAS (EN PLAYERGUI)
-- ==========================================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("QuirurgicoVisualizer") then
    PlayerGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.ResetOnSpawn = false
VisualizerGui.Parent = PlayerGui

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

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ImagePreview

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(150, 150, 150)
UIStroke.Thickness = 2
UIStroke.Parent = ImagePreview

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
-- SISTEMA KITTY CATALOG UI (BÚSQUEDA CORREGIDA)
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then
    CoreGui.KittyCatalogGui:Destroy()
end

local KittyGui = Instance.new("ScreenGui")
KittyGui.Name = "KittyCatalogGui"
KittyGui.Enabled = false 
KittyGui.Parent = CoreGui

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = UDim2.new(1, -80, 0.5, -30)
FloatingBtn.Image = "rbxassetid://15538455161"
FloatingBtn.BackgroundTransparency = 1
FloatingBtn.Visible = false 
FloatingBtn.Parent = KittyGui

local dragToggle, dragStart, startPos
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = FloatingBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatingBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

local KittyMain = Instance.new("Frame")
KittyMain.Size = UDim2.new(0.95, 0, 0.9, 0) 
KittyMain.Position = UDim2.new(0.5, 0, 0.5, 0) 
KittyMain.AnchorPoint = Vector2.new(0.5, 0.5) 
KittyMain.BackgroundColor3 = Color3.fromRGB(255, 182, 193) 
KittyMain.Parent = KittyGui

local KittyConstraint = Instance.new("UISizeConstraint")
KittyConstraint.MaxSize = Vector2.new(850, 550) 
KittyConstraint.MinSize = Vector2.new(300, 250)
KittyConstraint.Parent = KittyMain

FloatingBtn.MouseButton1Click:Connect(function()
    FloatingBtn.Visible = false
    KittyMain.Visible = true
end)

local KittyTop = Instance.new("Frame")
KittyTop.Size = UDim2.new(1, 0, 0, 60)
KittyTop.BackgroundTransparency = 1
KittyTop.Parent = KittyMain

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = KittyTop

CloseBtn.MouseButton1Click:Connect(function()
    KittyMain.Visible = false
    FloatingBtn.Visible = true
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.5, 0, 0, 40)
SearchContainer.Position = UDim2.new(0.3, 0, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SearchContainer.Parent = KittyTop

local KittySearch = Instance.new("TextBox")
KittySearch.Size = UDim2.new(1, -10, 1, 0)
KittySearch.Position = UDim2.new(0, 10, 0, 0)
KittySearch.BackgroundTransparency = 1
KittySearch.PlaceholderText = "🔍 Buscar ID o Nombre..."
KittySearch.Text = ""
KittySearch.TextColor3 = Color3.fromRGB(50, 50, 50)
KittySearch.TextXAlignment = Enum.TextXAlignment.Left
KittySearch.Parent = SearchContainer

local KittySearchBtn = Instance.new("TextButton")
KittySearchBtn.Size = UDim2.new(0.15, 0, 0, 40)
KittySearchBtn.Position = UDim2.new(0.82, 0, 0.5, -20)
KittySearchBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
KittySearchBtn.Text = "Buscar"
KittySearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KittySearchBtn.Parent = KittyTop

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(1, -20, 1, -70)
KittyResults.Position = UDim2.new(0, 10, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
KittyResults.Parent = KittyMain

local ResultsLayout = Instance.new("UIGridLayout")
ResultsLayout.CellSize = UDim2.new(0, 120, 0, 160) 
ResultsLayout.CellPadding = UDim2.new(0, 10, 0, 10)
ResultsLayout.Parent = KittyResults

local function PerformKittySearch()
    local query = KittySearch.Text
    if query == "" then return end
    
    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- Forzar uso de RoProxy porque los ejecutores bloquean roblox.com
    local url = "https://catalog.roproxy.com/v1/search/items/details?category=1&limit=30&keyword=" .. HttpService:UrlEncode(query)
    
    task.spawn(function()
        local success, response = pcall(function() return game:HttpGet(url) end)
        
        if success and response then
            local decoded = HttpService:JSONDecode(response)
            if decoded and decoded.data then
                for _, item in ipairs(decoded.data) do
                    local Card = Instance.new("Frame")
                    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Card.Parent = KittyResults
                    
                    local CardImg = Instance.new("ImageLabel")
                    CardImg.Size = UDim2.new(1, 0, 0, 90)
                    CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                    CardImg.Parent = Card
                    
                    local CardName = Instance.new("TextLabel")
                    CardName.Size = UDim2.new(1, -4, 0, 30)
                    CardName.Position = UDim2.new(0, 2, 0, 95)
                    CardName.BackgroundTransparency = 1
                    CardName.Text = item.name
                    CardName.TextScaled = true
                    CardName.Parent = Card
                    
                    local ClickBtn = Instance.new("TextButton")
                    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                    ClickBtn.BackgroundTransparency = 1
                    ClickBtn.Text = ""
                    ClickBtn.Parent = Card
                    
                    ClickBtn.MouseButton1Click:Connect(function()
                        CurrentData.Id = tostring(item.id)
                        CurrentData.Name = item.name
                        CurrentData.ItemType = item.itemType or "Asset"
                        
                        UpdateVisualizer(item.id, item.price or "Gratis")
                        UniversalEquip(item.id)
                    end)
                end
            end
        else
            warn("Error al buscar: Puede que RoProxy esté temporalmente caído.")
        end
    end)
end

KittySearchBtn.MouseButton1Click:Connect(PerformKittySearch)
KittySearch.FocusLost:Connect(function(enterPressed)
    if enterPressed then PerformKittySearch() end
end)

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Motor GetObjects v10",
   LoadingTitle = "Cargando Bypass de Equipamiento...",
   LoadingSubtitle = "100% Funcional en Ejecutores",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Panel = Window:CreateTab("🏥 Control Principal", 4483362458)

Panel:CreateToggle({
   Name = "🎀 Activar Menú Visual (Kitty)",
   CurrentValue = false,
   Callback = function(Value)
       KittyGui.Enabled = Value
       if Value then
           KittyMain.Visible = true
           FloatingBtn.Visible = false
       end
   end,
})

Panel:CreateInput({
   Name = "Equipar por ID Directa",
   PlaceholderText = "Pega un ID aquí...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if numericId then
           UniversalEquip(numericId)
           UpdateVisualizer(numericId, "Cargando...")
           Rayfield:Notify({Title = "Equipando", Content = "Inyectando Asset: " .. Text, Duration = 2})
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador",
   Callback = function()
       Container.Visible = not Container.Visible
   end,
})
