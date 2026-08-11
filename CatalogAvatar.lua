-- ==============================================================================
-- 🏥 AVATAR CATALOG QUIRÚRGICO OMNI-SUPREME v12.0 (ULTRA-REFINADO)
-- Solución definitiva a: Invisibilidad, Desalineación 3D, Cabezas Dinámicas y Capas
-- ==============================================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }

-- ==============================================================================
-- 🛡️ MOTOR DE CORRECCIÓN DE VISIBILIDAD & ANTI-INVISIBILIDAD 3D
-- ==============================================================================
local function ApplyAntiInvisibilityFix(char)
    task.spawn(function()
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Corrección rigurosa para R15 y R6 contra mallas invisibles o rotas
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("BasePart") then
                -- Asegurar opacidad total inicial para evitar parches transparentes
                if part.Transparency > 0.9 and part.Name ~= "HumanoidRootPart" and part.Name ~= "Handle" then
                    -- Solo restauramos si no es una prenda que intencionalmente deba ser transparente (raro, pero prevenimos bugs)
                    if not part:FindFirstChildOfClass("WrapLayer") then
                        part.Transparency = 0
                    end
                end
                part.LocalTransparencyModifier = 0
            elseif part:IsA("WrapLayer") then
                -- Forzar activación del motor de capas 3D (Layered Clothing)
                part.Enabled = true
            end
        end

        -- Forzar actualización geométrica del HumanoidDescription si aplica
        if hum then
            pcall(function()
                hum:BuildAndUpdate()
            end)
        end
    end)
end

-- ==============================================================================
-- 🦾 UNIVERSAL EQUIP 3D/2D AVANZADO (ROPA GÓTICA, CABEZAS, ACCESORIOS Y 3D)
-- ==============================================================================
local function UniversalEquip(assetId)
    task.spawn(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end

        local success, err = pcall(function()
            local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
            
            local function ProcessItem(item)
                if not item then return end

                if item:IsA("Accessory") then
                    -- Blindaje anti-invisibilidad para accesorios 3D y capas góticas
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("BasePart") or desc:IsA("MeshPart") then
                            desc.Transparency = 0
                            desc.LocalTransparencyModifier = 0
                        end
                        if desc:IsA("WrapLayer") then
                            desc.Enabled = true
                            -- Ajustar parámetros de solapamiento para evitar que atraviese el cuerpo
                            desc.AutoSkin = Enum.AutoSkin.Enabled
                        end
                    end
                    Hum:AddAccessory(item:Clone())

                elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    -- Limpieza preventiva de ropa 2D conflictiva
                    for _, v in pairs(Char:GetChildren()) do
                        if v.ClassName == item.ClassName then
                            v:Destroy()
                        end
                    end
                    item:Clone().Parent = Char

                elseif item:IsA("Decal") or item:IsA("Texture") then
                    -- Gestión optimizada para caras y maquillaje 2D
                    local head = Char:FindFirstChild("Head")
                    if head then
                        local currentFace = head:FindFirstChildOfClass("Decal")
                        if currentFace then
                            currentFace.Texture = item.Texture
                        else
                            item:Clone().Parent = head
                        end
                    end

                elseif item:IsA("SpecialMesh") or item:IsA("CharacterMesh") then
                    -- Corrección para cabezas clásicas y meshes corporales antiguos
                    local head = Char:FindFirstChild("Head")
                    if head then
                        for _, m in ipairs(head:GetChildren()) do
                            if m:IsA("SpecialMesh") then m:Destroy() end
                        end
                        item:Clone().Parent = head
                    end
                    
                elseif item:IsA("Tool") or item:IsA("HopperBin") then
                    -- Inyección directa de Gears a la mochila del jugador
                    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if Backpack then
                        item:Clone().Parent = Backpack
                    end

                elseif item:IsA("Model") or item:IsA("Folder") then
                    -- Contenedores complejos (Bundles, cabezas dinámicas compuestas, ropa gótica en capas)
                    for _, subItem in ipairs(item:GetChildren()) do
                        ProcessItem(subItem)
                    end
                end
            end

            for _, mainItem in ipairs(objects) do
                ProcessItem(mainItem)
            end
            
            -- Ejecutar rutina anti-invisibilidad post-aplicación
            task.wait(0.1)
            ApplyAntiInvisibilityFix(Char)
        end)

        if not success then
            warn("Error crítico en UniversalEquip: " .. tostring(err))
        end
    end)
end

-- Mantener la salud visual del personaje ante respawns
LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    task.wait(0.5)
    ApplyAntiInvisibilityFix(newChar)
end)

-- ==============================================================================
-- 👁️ HUD VISUALIZADOR FLOTANTE ULTRA-INTELIGENTE
-- ==============================================================================
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

ImagePreview.MouseButton1Click:Connect(function()
    local idNum = tonumber(CurrentData.Id)
    if idNum and idNum > 0 then
        if CurrentData.ItemType == "Bundle" then
            MarketplaceService:PromptBundlePurchase(LocalPlayer, idNum)
        else
            MarketplaceService:PromptPurchase(LocalPlayer, idNum)
        end
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

-- ==============================================================================
-- 🎀 MENÚ KITTY SUPREME OMNI-COMPATIBLE (GÓTICO, 3D, CABEZAS Y MAQUILLAJE)
-- ==============================================================================
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
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
KittyMain.BackgroundColor3 = Color3.fromRGB(30, 25, 35) -- Tono gótico nocturno elegante
KittyMain.BackgroundTransparency = 0.1 
KittyMain.BorderSizePixel = 0
KittyMain.ClipsDescendants = true
KittyMain.Parent = KittyGui

FloatingBtn.MouseButton1Click:Connect(function()
    FloatingBtn.Visible = false
    KittyMain.Visible = true
end)

local KittyConstraint = Instance.new("UISizeConstraint")
KittyConstraint.MaxSize = Vector2.new(900, 580) 
KittyConstraint.MinSize = Vector2.new(350, 300)
KittyConstraint.Parent = KittyMain

local KittyCorner = Instance.new("UICorner")
KittyCorner.CornerRadius = UDim.new(0, 16)
KittyCorner.Parent = KittyMain

local KittyStroke = Instance.new("UIStroke")
KittyStroke.Color = Color3.fromRGB(186, 85, 211) -- Contraste gótico morado/magenta
KittyStroke.Thickness = 3
KittyStroke.Parent = KittyMain

-- Barra Superior
local KittyTop = Instance.new("Frame")
KittyTop.Size = UDim2.new(0.75, 0, 0, 60)
KittyTop.Position = UDim2.new(0.25, 0, 0, 0)
KittyTop.BackgroundTransparency = 1
KittyTop.Parent = KittyMain

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = KittyTop

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0) 
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    KittyMain.Visible = false
    FloatingBtn.Visible = true
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.60, 0, 0, 40)
SearchContainer.Position = UDim2.new(0, 10, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(45, 40, 50)
SearchContainer.Parent = KittyTop

local SearchContainerCorner = Instance.new("UICorner")
SearchContainerCorner.CornerRadius = UDim.new(0, 8)
SearchContainerCorner.Parent = SearchContainer

local KittySearch = Instance.new("TextBox")
KittySearch.Size = UDim2.new(1, -20, 1, 0)
KittySearch.Position = UDim2.new(0, 10, 0, 0)
KittySearch.BackgroundTransparency = 1
KittySearch.PlaceholderText = "🔍 Buscar gótico, 3D, cabello, ropa..."
KittySearch.Text = ""
KittySearch.Font = Enum.Font.GothamMedium
KittySearch.TextSize = 14
KittySearch.TextColor3 = Color3.fromRGB(230, 230, 230)
KittySearch.TextXAlignment = Enum.TextXAlignment.Left
KittySearch.Parent = SearchContainer

local KittySearchBtn = Instance.new("TextButton")
KittySearchBtn.Size = UDim2.new(0.20, 0, 0, 40)
KittySearchBtn.Position = UDim2.new(0.64, 0, 0.5, -20)
KittySearchBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
KittySearchBtn.Text = "Buscar"
KittySearchBtn.Font = Enum.Font.GothamBold
KittySearchBtn.TextSize = 14
KittySearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KittySearchBtn.Parent = KittyTop

local SearchBtnCorner = Instance.new("UICorner")
SearchBtnCorner.CornerRadius = UDim.new(0, 8)
SearchBtnCorner.Parent = KittySearchBtn

-- Sidebar de Categorías Exhaustivas
local KittySidebar = Instance.new("ScrollingFrame")
KittySidebar.Size = UDim2.new(0.25, 0, 1, 0)
KittySidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
KittySidebar.BackgroundTransparency = 0.4
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

local TitleCat = Instance.new("TextLabel")
TitleCat.Size = UDim2.new(1, 0, 0, 40)
TitleCat.BackgroundTransparency = 1
TitleCat.Text = "🦇 Categorías Omni"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 15
TitleCat.TextColor3 = Color3.fromRGB(186, 85, 211)
TitleCat.TextXAlignment = Enum.TextXAlignment.Center
TitleCat.Parent = KittySidebar

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(0.75, 0, 1, -60)
KittyResults.Position = UDim2.new(0.25, 0, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.ScrollBarThickness = 6
KittyResults.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
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

-- ==============================================================================
-- 🗂️ MAPEO RIGUROSO DE CATEGORÍAS Y PARÁMETROS GLOBALES/EXISTENCIALES
-- ==============================================================================
local KittyCurrentCategory = 1 
local KittyCurrentSubcategory = ""

local CategoriesDetailed = {
    {"Todos (All)", 1, ""}, 
    {"Accesorios (Gen)", 11, ""}, 
    {"Head (Accesorios)", 11, 21}, 
    {"Face (Accesorios)", 11, 22},
    {"Neck (Cuello)", 11, 23}, 
    {"Shoulder (Hombro)", 11, 24}, 
    {"Front (Frontal)", 11, 25}, 
    {"Back (Espalda)", 11, 26}, 
    {"Waist (Cintura)", 11, 27},
    {"Body (Cuerpos)", 4, ""}, 
    {"Hair (Cabello 3D/2D)", 11, 20}, 
    {"Heads (Cabezas 3D/Din)", 4, 15},
    {"Clothing (Ropa Gen)", 3, ""}, 
    {"Sweaters 3D", 3, 61}, 
    {"Jackets 3D", 3, 62},
    {"Pants 3D (Capas)", 3, 63},
    {"Shoes 3D (Zapatos)", 3, 55}, 
    {"Classic Shirts", 3, 12}, 
    {"Classic T-Shirts", 3, 13}, 
    {"Classic Pants", 3, 14},
    {"Makeup: Eyes", 11, 22},
    {"Makeup: Lips", 11, 22},
    {"Animations", 12, ""}, 
    {"Emotes", 12, ""}, 
    {"Gear (Herramientas)", 5, ""}
}

for _, catData in ipairs(CategoriesDetailed) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 35, 55)
    btn.Text = " " .. catData[1]
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Parent = KittySidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        KittyCurrentCategory = catData[2]
        KittyCurrentSubcategory = catData[3]
        KittySearch.PlaceholderText = "🔍 Buscando en " .. catData[1] .. "..."
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
        task.wait(0.2)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 35, 55)}):Play()
    end)
end

local function PerformKittySearch()
    if KittySearch.Text == "" then return end
    
    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local subParam = KittyCurrentSubcategory ~= "" and ("&subcategory="..tostring(KittyCurrentSubcategory)) or ""
    local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(KittyCurrentCategory)..subParam.."&limit=35&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
    
    local success, response = pcall(function() return game:HttpGet(url) end)
    
    if not success or not response then
        url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(KittyCurrentCategory)..subParam.."&limit=35&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
        success, response = pcall(function() return game:HttpGet(url) end)
    end

    if success and response then
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.data then
            for _, item in ipairs(decoded.data) do
                local Card = Instance.new("Frame")
                Card.BackgroundColor3 = Color3.fromRGB(40, 35, 48)
                Card.Parent = KittyResults
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 10)
                CardCorner.Parent = Card
                
                local CardImg = Instance.new("ImageLabel")
                CardImg.Size = UDim2.new(1, 0, 0, 100)
                CardImg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                CardImg.Parent = Card
                
                local ImgCorner = Instance.new("UICorner")
                ImgCorner.CornerRadius = UDim.new(0, 10)
                ImgCorner.Parent = CardImg
                
                local CardName = Instance.new("TextLabel")
                CardName.Size = UDim2.new(1, -10, 0, 25)
                CardName.Position = UDim2.new(0, 5, 0, 105)
                CardName.BackgroundTransparency = 1
                CardName.Text = item.name
                CardName.Font = Enum.Font.GothamSemibold
                CardName.TextSize = 11
                CardName.TextColor3 = Color3.fromRGB(240, 240, 240)
                CardName.TextWrapped = true
                CardName.TextXAlignment = Enum.TextXAlignment.Left
                CardName.Parent = Card
                
                local CardCreator = Instance.new("TextLabel")
                CardCreator.Size = UDim2.new(1, -10, 0, 15)
                CardCreator.Position = UDim2.new(0, 5, 0, 135)
                CardCreator.BackgroundTransparency = 1
                CardCreator.Text = "Por " .. (item.creatorName or "Oficial")
                CardCreator.Font = Enum.Font.Gotham
                CardCreator.TextSize = 10
                CardCreator.TextColor3 = Color3.fromRGB(160, 160, 160)
                CardCreator.TextXAlignment = Enum.TextXAlignment.Left
                CardCreator.Parent = Card
                
                local CardPrice = Instance.new("TextLabel")
                CardPrice.Size = UDim2.new(1, -25, 0, 20)
                CardPrice.Position = UDim2.new(0, 25, 0, 155)
                CardPrice.BackgroundTransparency = 1
                CardPrice.Text = item.price and tostring(item.price) or "Gratis"
                CardPrice.Font = Enum.Font.GothamBold
                CardPrice.TextSize = 12
                CardPrice.TextColor3 = Color3.fromRGB(220, 220, 220)
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
                    CurrentData.ItemType = item.itemType or "Asset"
                    
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

-- ==============================================================================
-- 🎛️ PANEL RAYFIELD CLÁSICO DE SOPORTE E INYECCIÓN RÁPIDA
-- ==============================================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script", [8] = "Sombrero", [11] = "Camisa", [12] = "Pantalón", 
    [17] = "Cabeza", [18] = "Cara", [19] = "Gear", [24] = "Animación", [41] = "Pelo", 
    [42] = "Acc. Cara", [43] = "Acc. Cuello", [44] = "Acc. Hombro", [45] = "Acc. Frontal", 
    [46] = "Acc. Trasero", [47] = "Acc. Cintura", [61] = "Suéter 3D", [62] = "Chaqueta 3D", [55] = "Zapatos 3D"
}

local CategoryToNumber = {
    ["All"] = 1, ["Accessories"] = 11, ["Clothing"] = 3, 
    ["Characters"] = 4, ["Gear"] = 5, ["Animations"] = 12
}

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🦇 Avatar Catalog OMNI-SUPREME v12.0",
   LoadingTitle = "Motor Gótico & 3D Antidistorsión...",
   LoadingSubtitle = "Compatibilidad Extrema 1000% Refinada",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local SearchResultsCache = {}
local Panel = Window:CreateTab("🦇 Catálogo OMNI", 4483362458)

Panel:CreateToggle({
   Name = "🎀 Activar Menú Kitty Interactivo",
   CurrentValue = false,
   Flag = "KittyMenuToggle", 
   Callback = function(Value)
       KittyGui.Enabled = Value
       if Value then
           KittyMain.Visible = true
           FloatingBtn.Visible = false
           Rayfield:Notify({Title = "Menú Kitty", Content = "Interfaz gótica/3D abierta con éxito.", Duration = 3})
       end
   end,
})

Panel:CreateSection("🔍 Búsqueda Directa y Filtros Existenciales")

local SearchCategory = "All"
Panel:CreateDropdown({
   Name = "Categoría Principal API",
   Options = {"All", "Accessories", "Clothing", "Characters", "Gear", "Animations"},
   CurrentOption = {"All"},
   MultipleOptions = false,
   Callback = function(Option)
       SearchCategory = type(Option) == "table" and Option[1] or Option
   end,
})

local SpinnerDropdown = Panel:CreateDropdown({
   Name = "🔽 Cascada de Resultados Optimizados",
   Options = {"Realiza una búsqueda..."},
   CurrentOption = {"Realiza una búsqueda..."},
   MultipleOptions = false,
   Callback = function(Option)
       local selectedText = type(Option) == "table" and Option[1] or Option
       if SearchResultsCache[selectedText] then
           local item = SearchResultsCache[selectedText]
           CurrentData.Id = tostring(item.Id)
           CurrentData.Name = item.Name
           CurrentData.Price = item.Price
           CurrentData.Category = item.Category
           CurrentData.ItemType = item.ItemType
           
           UpdateVisualizer(item.Id, item.Price)
           Rayfield:Notify({Title = "Seleccionado", Content = item.Name, Duration = 2})
       end
   end,
})

Panel:CreateInput({
   Name = "Buscador Inteligente (Gótico, Goth, 3D...)",
   PlaceholderText = "Ej: Goth Dress, Spiked Hair, 3D Boots...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       local apiCategory = CategoryToNumber[SearchCategory] or 1
       local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=15&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
       if not success then
           url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=15&keyword=" .. HttpService:UrlEncode(Text)
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
                   SearchResultsCache[listName] = {Id = item.id, Name = item.name, Price = priceStr, Category = catName, ItemType = item.itemType or "Asset"}
               end
               if #newOptions > 0 then
                   SpinnerDropdown:Refresh(newOptions, true)
               end
           end
       end
   end,
})

Panel:CreateSection("Herramientas de Mantenimiento y Forzado")

Panel:CreateButton({
   Name = "🛡️ Forzar Corrección Anti-Invisibilidad",
   Callback = function()
       ApplyAntiInvisibilityFix(LocalPlayer.Character)
       Rayfield:Notify({Title = "Corrección Aplicada", Content = "Se restauraron mallas y opacidad.", Duration = 3})
   end,
})

Panel:CreateButton({
   Name = "⚡ Equipar Último Objeto Seleccionado",
   Callback = function()
       local assetId = tonumber(CurrentData.Id)
       UniversalEquip(assetId)
       Rayfield:Notify({Title = "Equipado", Content = "Inyectando: " .. CurrentData.Name, Duration = 3})
   end,
})

Panel:CreateButton({
   Name = "🧹 Limpiar Memoria Caché y RAM",
   Callback = function() 
       collectgarbage("collect") 
       Rayfield:Notify({Title = "Limpieza", Content = "Memoria optimizada.", Duration = 2})
   end,
})
