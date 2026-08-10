-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v9.1 + KITTY MENU)
-- Buscador Directo + Compra en Visualizador + Motor v3.0
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido" }

-- ==========================================================
-- SISTEMA DE VISUALIZADOR HUD (AHORA CON BOTÓN DE COMPRA)
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

-- CAMBIO: De ImageLabel a ImageButton para permitir clics
local ImagePreview = Instance.new("ImageButton")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.AutoButtonColor = true -- Efecto visual al presionar
ImagePreview.Parent = Container

-- Evento de compra al hacer clic en el visualizador
ImagePreview.MouseButton1Click:Connect(function()
    local assetId = tonumber(CurrentData.Id)
    if assetId and assetId > 0 then
        -- Abre el menú oficial de Roblox para comprar/obtener el ítem
        MarketplaceService:PromptPurchase(LocalPlayer, assetId)
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
-- SISTEMA KITTY CATALOG UI (MENÚ TRASLÚCIDO)
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then
    CoreGui.KittyCatalogGui:Destroy()
end

local KittyGui = Instance.new("ScreenGui")
KittyGui.Name = "KittyCatalogGui"
KittyGui.Enabled = false 
KittyGui.Parent = CoreGui

local KittyMain = Instance.new("Frame")
KittyMain.Size = UDim2.new(0, 850, 0, 550)
KittyMain.Position = UDim2.new(0.5, -425, 0.5, -275)
KittyMain.BackgroundColor3 = Color3.fromRGB(255, 182, 193) 
KittyMain.BackgroundTransparency = 0.15 
KittyMain.BorderSizePixel = 0
KittyMain.ClipsDescendants = true
KittyMain.Parent = KittyGui

local KittyCorner = Instance.new("UICorner")
KittyCorner.CornerRadius = UDim.new(0, 16)
KittyCorner.Parent = KittyMain

local KittyStroke = Instance.new("UIStroke")
KittyStroke.Color = Color3.fromRGB(255, 105, 180) 
KittyStroke.Thickness = 3
KittyStroke.Parent = KittyMain

local KittyTop = Instance.new("Frame")
KittyTop.Size = UDim2.new(1, -200, 0, 60)
KittyTop.Position = UDim2.new(0, 200, 0, 0)
KittyTop.BackgroundTransparency = 1
KittyTop.Parent = KittyMain

local KittySearch = Instance.new("TextBox")
KittySearch.Size = UDim2.new(1, -40, 0, 40)
KittySearch.Position = UDim2.new(0, 20, 0.5, -20)
KittySearch.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
KittySearch.PlaceholderText = "🔍 Search (Escribe y presiona Enter)..."
KittySearch.Text = ""
KittySearch.Font = Enum.Font.GothamSemibold
KittySearch.TextSize = 16
KittySearch.TextColor3 = Color3.fromRGB(50, 50, 50)
KittySearch.Parent = KittyTop

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = KittySearch

local KittySidebar = Instance.new("ScrollingFrame")
KittySidebar.Size = UDim2.new(0, 200, 1, 0)
KittySidebar.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
KittySidebar.BackgroundTransparency = 0.5
KittySidebar.BorderSizePixel = 0
KittySidebar.ScrollBarThickness = 4
KittySidebar.Parent = KittyMain

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.Parent = KittySidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.Parent = KittySidebar

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(1, -200, 1, -60)
KittyResults.Position = UDim2.new(0, 200, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.ScrollBarThickness = 6
KittyResults.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
KittyResults.Parent = KittyMain

local ResultsLayout = Instance.new("UIGridLayout")
ResultsLayout.CellSize = UDim2.new(0, 140, 0, 190)
ResultsLayout.CellPadding = UDim2.new(0, 15, 0, 15)
ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ResultsLayout.Parent = KittyResults

local ResultsPadding = Instance.new("UIPadding")
ResultsPadding.PaddingTop = UDim.new(0, 10)
ResultsPadding.PaddingLeft = UDim.new(0, 15)
ResultsPadding.Parent = KittyResults

local TitleCat = Instance.new("TextLabel")
TitleCat.Size = UDim2.new(1, -10, 0, 40)
TitleCat.BackgroundTransparency = 1
TitleCat.Text = "🎀 Category"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 20
TitleCat.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleCat.TextXAlignment = Enum.TextXAlignment.Left
TitleCat.Parent = KittySidebar

local KittyCurrentCategory = 1 

local CategoriesEnglish = {
    {"All", 1}, {"Clothing", 3}, {"Body", 4}, 
    {"Accessories", 11}, {"Animations", 12}, 
    {"Head", 11}, {"Face", 11}, {"Gear", 5}
}

for i, catData in ipairs(CategoriesEnglish) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(255, 228, 225)
    btn.Text = "  " .. catData[1]
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = KittySidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        KittyCurrentCategory = catData[2]
        KittySearch.PlaceholderText = "🔍 Search in " .. catData[1] .. "..."
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
        task.wait(0.2)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 228, 225)}):Play()
    end)
end

local function KittyEquip(assetId)
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not assetId or assetId == 0 then return end

    local success, err = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        local item = objects[1]
        if not item then return end
        
        if item:IsA("Accessory") then
            if Hum then Hum:AddAccessory(item) end
        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            for _, v in pairs(Char:GetChildren()) do
                if v.ClassName == item.ClassName then v:Destroy() end
            end
            item.Parent = Char
        elseif item:IsA("Decal") then
            local head = Char:FindFirstChild("Head")
            if head then
                local currentFace = head:FindFirstChildOfClass("Decal")
                if currentFace then
                    currentFace.Texture = item.Texture
                else
                    item.Parent = head
                end
            end
        else
            local clone = item:Clone()
            clone.Parent = Char
        end
    end)
end

KittySearch.FocusLost:Connect(function(enterPressed)
    if enterPressed and KittySearch.Text ~= "" then
        for _, child in ipairs(KittyResults:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=30&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
        local success, response = pcall(function() return game:HttpGet(url) end)
        
        if not success or not response then
            url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=30&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
            success, response = pcall(function() return game:HttpGet(url) end)
        end

        if success and response then
            local decoded = HttpService:JSONDecode(response)
            if decoded and decoded.data then
                for _, item in ipairs(decoded.data) do
                    local Card = Instance.new("Frame")
                    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Card.Parent = KittyResults
                    
                    local CardCorner = Instance.new("UICorner")
                    CardCorner.CornerRadius = UDim.new(0, 10)
                    CardCorner.Parent = Card
                    
                    local CardImg = Instance.new("ImageLabel")
                    CardImg.Size = UDim2.new(1, 0, 0, 110)
                    CardImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                    CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                    CardImg.Parent = Card
                    
                    local ImgCorner = Instance.new("UICorner")
                    ImgCorner.CornerRadius = UDim.new(0, 10)
                    ImgCorner.Parent = CardImg
                    
                    local CardName = Instance.new("TextLabel")
                    CardName.Size = UDim2.new(1, -10, 0, 30)
                    CardName.Position = UDim2.new(0, 5, 0, 112)
                    CardName.BackgroundTransparency = 1
                    CardName.Text = item.name
                    CardName.Font = Enum.Font.GothamSemibold
                    CardName.TextSize = 12
                    CardName.TextColor3 = Color3.fromRGB(30, 30, 30)
                    CardName.TextWrapped = true
                    CardName.TextXAlignment = Enum.TextXAlignment.Left
                    CardName.Parent = Card
                    
                    local CardCreator = Instance.new("TextLabel")
                    CardCreator.Size = UDim2.new(1, -10, 0, 15)
                    CardCreator.Position = UDim2.new(0, 5, 0, 145)
                    CardCreator.BackgroundTransparency = 1
                    CardCreator.Text = "De " .. (item.creatorName or "Desconocido")
                    CardCreator.Font = Enum.Font.Gotham
                    CardCreator.TextSize = 10
                    CardCreator.TextColor3 = Color3.fromRGB(100, 100, 100)
                    CardCreator.TextXAlignment = Enum.TextXAlignment.Left
                    CardCreator.Parent = Card
                    
                    local CardPrice = Instance.new("TextLabel")
                    CardPrice.Size = UDim2.new(1, -25, 0, 20)
                    CardPrice.Position = UDim2.new(0, 25, 0, 165)
                    CardPrice.BackgroundTransparency = 1
                    CardPrice.Text = item.price and tostring(item.price) or "Gratis"
                    CardPrice.Font = Enum.Font.GothamBold
                    CardPrice.TextSize = 13
                    CardPrice.TextColor3 = Color3.fromRGB(50, 50, 50)
                    CardPrice.TextXAlignment = Enum.TextXAlignment.Left
                    CardPrice.Parent = Card
                    
                    local CardRobux = Instance.new("ImageLabel")
                    CardRobux.Size = UDim2.new(0, 14, 0, 14)
                    CardRobux.Position = UDim2.new(0, 6, 0, 168)
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
                        -- Actualizamos la data global para el botón de compra
                        CurrentData.Id = tostring(item.id)
                        CurrentData.Name = item.name
                        CurrentData.Price = item.price and (tostring(item.price) .. " R$") or "Gratis"
                        
                        -- Actualizamos visualizador y equipamos
                        UpdateVisualizer(item.id, item.price or "Gratis")
                        KittyEquip(item.id)
                    end)
                end
            end
        end
    end
end)

-- ==========================================================
-- DICCIONARIO Y LÓGICA DEL SCRIPT ORIGINAL V9.0
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script LUA", [8] = "Sombrero", [9] = "Place", [10] = "Modelo", 
    [11] = "Camisa", [12] = "Pantalón", [13] = "Decal", [17] = "Cabeza", [18] = "Cara", [19] = "Gear", 
    [24] = "Animación", [27] = "Torso", [28] = "Brazo Der", [29] = "Brazo Izq", 
    [30] = "Pierna Izq", [31] = "Pierna Der", [38] = "Plugin / Script", [41] = "Pelo", 
    [42] = "Acc. Cara", [43] = "Acc. Cuello", [44] = "Acc. Hombro", [45] = "Acc. Frontal", 
    [46] = "Acc. Trasero", [47] = "Acc. Cintura"
}

local CategoryToNumber = {
    ["All"] = 1, ["Accessories"] = 11, ["Clothing"] = 3, 
    ["Characters"] = 4, ["Gear"] = 5, ["Animations"] = 12
}

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v9.1",
   LoadingTitle = "Motor Unificado v9.1...",
   LoadingSubtitle = "Endpoint v7.0 + Motor v3.0 + Precio Centrado",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local SearchResultsCache = {}

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

Panel:CreateToggle({
   Name = "🎀 Activar Menú Kitty Visual (Recomendado)",
   CurrentValue = false,
   Flag = "KittyMenuToggle", 
   Callback = function(Value)
       KittyGui.Enabled = Value
       if Value then
           Rayfield:Notify({Title = "🎀 Menú Kitty", Content = "Escribe arriba y presiona Enter para buscar.", Duration = 3})
       end
   end,
})

Panel:CreateSection("🔍 Búsqueda en Vivo (Nombre Real)")

local SearchCategory = "All"
Panel:CreateDropdown({
   Name = "Filtro de Categoría",
   Options = {"All", "Accessories", "Clothing", "Characters", "Gear", "Animations"},
   CurrentOption = {"All"},
   MultipleOptions = false,
   Callback = function(Option)
       SearchCategory = type(Option) == "table" and Option[1] or Option
   end,
})

local SpinnerDropdown = Panel:CreateDropdown({
   Name = "🔽 Resultados (Cascada)",
   Options = {"Esperando búsqueda..."},
   CurrentOption = {"Esperando búsqueda..."},
   MultipleOptions = false,
   Callback = function(Option)
       local selectedText = type(Option) == "table" and Option[1] or Option
       if SearchResultsCache[selectedText] then
           local item = SearchResultsCache[selectedText]
           CurrentData.Id = tostring(item.Id)
           CurrentData.Name = item.Name
           CurrentData.Price = item.Price
           CurrentData.Category = item.Category
           
           UpdateVisualizer(item.Id, item.Price)
           Rayfield:Notify({Title = "Seleccionado", Content = item.Name, Duration = 2})
       end
   end,
})

Panel:CreateInput({
   Name = "Escribe el Nombre del Item y dale Enter",
   PlaceholderText = "Ej: Beanie, Dominus, Cheeks...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       Rayfield:Notify({Title = "Buscando...", Content = "Conectando al catálogo de Roblox...", Duration = 2})
       
       local apiCategory = CategoryToNumber[SearchCategory] or 1
       local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
       
       if not success or not response then
           url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
           success, response = pcall(function() return game:HttpGet(url) end)
       end

       if success and response then
           local decoded = HttpService:JSONDecode(response)
           if decoded and decoded.data then
               local newOptions = {}
               SearchResultsCache = {} 
               
               for _, item in ipairs(decoded.data) do
                   local priceStr = item.price or 0
                   local catName = AssetTypeNames[item.assetType] or item.itemType or "Item"
                   local listName = string.format("%s - [%s]", item.name, catName)
                   
                   table.insert(newOptions, listName)
                   SearchResultsCache[listName] = {
                       Id = item.id,
                       Name = item.name,
                       Price = priceStr,
                       Category = catName
                   }
               end
               
               if #newOptions > 0 then
                   SpinnerDropdown:Refresh(newOptions, true)
                   Rayfield:Notify({Title = "Éxito", Content = "Resultados cargados.", Duration = 3})
               else
                   Rayfield:Notify({Title = "Sin resultados", Content = "Intenta con otro nombre.", Duration = 3})
               end
           end
       else
           Rayfield:Notify({Title = "Error", Content = "No se pudo establecer conexión con el catálogo.", Duration = 3})
       end
   end,
})

Panel:CreateSection("Búsqueda Directa por ID")

local DirectIdInput = Panel:CreateInput({
   Name = "Ingresar ID Directa",
   PlaceholderText = "Ej: 144275038...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if not numericId then
           Rayfield:Notify({Title = "Error", Content = "Debes ingresar solo números.", Duration = 2})
           return
       end

       local success, info = pcall(function()
           return MarketplaceService:GetProductInfo(numericId)
       end)

       if success and info then
           CurrentData.Id = tostring(numericId)
           CurrentData.Name = info.Name
           CurrentData.Price = info.PriceInRobux and (tostring(info.PriceInRobux) .. " R$") or "Gratis / Off-Sale"
           CurrentData.Category = AssetTypeNames[info.AssetTypeId] or ("ID de Tipo: " .. tostring(info.AssetTypeId))

           UpdateVisualizer(CurrentData.Id, CurrentData.Price)
           Rayfield:Notify({Title = "Item Encontrado", Content = CurrentData.Name, Duration = 2})
       else
           Rayfield:Notify({Title = "Error de ID", Content = "No se pudo encontrar en el catálogo.", Duration = 3})
       end
   end,
})

Panel:CreateButton({
   Name = "🎲 Randomizar ID Aleatorio",
   Callback = function()
       local randomId = tostring(math.random(1000000, 999999999))
       if DirectIdInput then DirectIdInput:Set(randomId) end
   end,
})

Panel:CreateSection("🧪 Aplicar / Probar en Personaje")

Panel:CreateButton({
   Name = "⚡ Equipar/Probar en Mi Personaje",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       local Hum = Char:FindFirstChildOfClass("Humanoid")
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end

       local s_info, info = pcall(function() return MarketplaceService:GetProductInfo(assetId) end)
       if s_info and info and info.AssetTypeId == 9 then
           Rayfield:Notify({Title = "Bloqueado", Content = "Es un Place ID. No se puede equipar.", Duration = 3})
           return
       end

       local success, err = pcall(function()
           local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
           local item = objects[1]

           if not item then return end

           if item:IsA("Accessory") then
               if Hum then Hum:AddAccessory(item) end
           elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
               for _, v in pairs(Char:GetChildren()) do
                   if v.ClassName == item.ClassName then
                       v:Destroy()
                   end
               end
               item.Parent = Char
           elseif item:IsA("Decal") then
               local head = Char:FindFirstChild("Head")
               if head then
                   local currentFace = head:FindFirstChildOfClass("Decal")
                   if currentFace then
                       currentFace.Texture = item.Texture
                   else
                       item.Parent = head
                   end
               end
           else
               local clone = item:Clone()
               clone.Parent = Char
           end
       end)

       if success then
           Rayfield:Notify({Title = "Transformación Aplicada", Content = "Se equipó: " .. CurrentData.Name, Duration = 3})
       else
           Rayfield:Notify({Title = "Fallo al aplicar", Content = "Tu ejecutor puede no soportar GetObjects o el ID no es compatible.", Duration = 4})
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador Clásico",
   Callback = function()
       Container.Visible = not Container.Visible
   end,
})

Panel:CreateSection("⚙️ Rendimiento Quirúrgico (Anti-Crash iOS)")

Panel:CreateButton({
   Name = "🧹 Limpiar Caché y Liberar RAM",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({Title = "RAM Purgada", Content = "Memoria optimizada para evitar crashes.", Duration = 2.5})
   end,
})
