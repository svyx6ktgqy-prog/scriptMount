-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (v16.0 INVENTARIO & FIX 3D)
-- Fix Chaquetas 3D + Inventario de Ojos + Flujo Corregido
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }
local MyEquippedItems = {} -- Registro de todo lo que nos equipamos

local function NotifyUser(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = 4; })
    end)
end

-- ==========================================================
-- 1. SOLUCIÓN EXTREMA: GENERADOR QUIRÚRGICO (BINOCULARES)
-- ==========================================================
local function CreateExtremeBinoculars()
    local tool = Instance.new("Tool")
    tool.Name = "Binoculars Custom"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1.2, 0.5, 0.8)
    handle.Transparency = 1
    handle.Parent = tool

    local lenteIzq = Instance.new("Part")
    lenteIzq.Shape = Enum.PartType.Cylinder
    lenteIzq.Size = Vector3.new(0.8, 0.45, 0.45)
    lenteIzq.Color = Color3.fromRGB(15, 15, 15)
    lenteIzq.Parent = tool
    local w1 = Instance.new("WeldConstraint")
    w1.Part0 = handle; w1.Part1 = lenteIzq; w1.Parent = handle
    lenteIzq.CFrame = handle.CFrame * CFrame.new(-0.3, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

    local lenteDer = lenteIzq:Clone()
    lenteDer.Parent = tool
    local w2 = Instance.new("WeldConstraint")
    w2.Part0 = handle; w2.Part1 = lenteDer; w2.Parent = handle
    lenteDer.CFrame = handle.CFrame * CFrame.new(0.3, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

    local tira = Instance.new("Part")
    tira.Shape = Enum.PartType.Block
    tira.Size = Vector3.new(0.7, 0.1, 0.1)
    tira.Color = Color3.fromRGB(5, 5, 5)
    tira.Parent = tool
    local w3 = Instance.new("WeldConstraint")
    w3.Part0 = handle; w3.Part1 = tira; w3.Parent = handle
    tira.CFrame = handle.CFrame * CFrame.new(0, 0, 0)

    local equipped = false
    local camera = workspace.CurrentCamera

    tool.Equipped:Connect(function() equipped = true end)
    tool.Unequipped:Connect(function()
        equipped = false
        TweenService:Create(camera, TweenInfo.new(0.2), {FieldOfView = 70}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not equipped then return end
        if input.KeyCode == Enum.KeyCode.E then TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 20}):Play()
        elseif input.KeyCode == Enum.KeyCode.Q then TweenService:Create(camera, TweenInfo.new(0.5), {FieldOfView = 10}):Play()
        elseif input.KeyCode == Enum.KeyCode.R then TweenService:Create(camera, TweenInfo.new(0.15), {FieldOfView = 35}):Play()
        end
    end)

    return tool
end

-- ==========================================================
-- 2. BUCLE ANTI-INVISIBILIDAD
-- ==========================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent:IsA("Accessory") then
                v.LocalTransparencyModifier = 0
            end
        end
    end
end)

-- ==========================================================
-- 3. CEREBRO V16: SOLDADURA Y REPARACIÓN 3D (CHAQUETAS)
-- ==========================================================
local function UniversalEquip(assetId, assetName)
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum or not assetId or assetId == 0 then return end

    local insertedInstances = {}

    local success, err = pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        
        local function ProcessItem(item)
            if not item then return end

            if item:IsA("Accessory") then
                local cloneItem = item:Clone()
                local handle = cloneItem:FindFirstChild("Handle")
                local isLayered3D = false
                
                if handle then
                    handle.Transparency = 0
                    handle.Anchored = false
                    handle.CanCollide = false
                    
                    -- Detectar Ropa 3D (Chaquetas, Zapatos)
                    local wrap = handle:FindFirstChildWhichIsA("WrapLayer")
                    if wrap then
                        wrap.Enabled = true
                        wrap.AutoJoints = true
                        wrap.ShrinkFactor = 0
                        isLayered3D = true -- Marcamos como ropa 3D
                    end
                    
                    -- Solo soldar rígidamente si NO es ropa 3D
                    if not isLayered3D then
                        local accAttach = handle:FindFirstChildWhichIsA("Attachment")
                        if accAttach then
                            local targetAttach = nil
                            for _, v in ipairs(Char:GetDescendants()) do
                                if v:IsA("Attachment") and v.Name == accAttach.Name and v.Parent:IsA("BasePart") then
                                    targetAttach = v
                                    break
                                end
                            end
                            
                            if targetAttach then
                                for _, v in ipairs(handle:GetJoints()) do v:Destroy() end
                                local weld = Instance.new("Weld")
                                weld.Name = "OmniWeld3D"
                                weld.Part0 = targetAttach.Parent
                                weld.Part1 = handle
                                weld.C0 = targetAttach.CFrame
                                weld.C1 = accAttach.CFrame
                                weld.Parent = handle
                                
                                cloneItem.Parent = Char
                                table.insert(insertedInstances, cloneItem)
                                return 
                            end
                        end
                    end
                end
                
                Hum:AddAccessory(cloneItem)
                table.insert(insertedInstances, cloneItem)

            -- Ropa Clásica 2D
            elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                for _, v in pairs(Char:GetChildren()) do
                    if v.ClassName == item.ClassName then v:Destroy() end
                end
                local clone = item:Clone()
                clone.Parent = Char
                table.insert(insertedInstances, clone)

            -- Cabezas MeshPart
            elseif item:IsA("MeshPart") and item.Name == "Head" then
                local currentHead = Char:FindFirstChild("Head")
                if currentHead and currentHead:IsA("MeshPart") then
                    currentHead.MeshId = item.MeshId
                    local surface = item:FindFirstChildWhichIsA("SurfaceAppearance")
                    if surface then
                        local oldSurface = currentHead:FindFirstChildWhichIsA("SurfaceAppearance")
                        if oldSurface then oldSurface:Destroy() end
                        surface:Clone().Parent = currentHead
                    end
                    local controls = item:FindFirstChildWhichIsA("FaceControls")
                    if controls then
                        local oldControls = currentHead:FindFirstChildWhichIsA("FaceControls")
                        if oldControls then oldControls:Destroy() end
                        controls:Clone().Parent = currentHead
                    end
                end

            -- Caras
            elseif item:IsA("Decal") then
                local head = Char:FindFirstChild("Head")
                if head then
                    local currentFace = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
                    if currentFace then currentFace.Texture = item.Texture
                    else
                        local newFace = item:Clone()
                        newFace.Name = "face"
                        newFace.Parent = head
                    end
                end
                
            -- Bundles y Folders
            elseif item:IsA("Model") or item:IsA("Folder") then
                for _, subItem in ipairs(item:GetChildren()) do
                    ProcessItem(subItem)
                end
            else
                local clone = item:Clone()
                clone.Parent = Char
                table.insert(insertedInstances, clone)
            end
        end

        for _, mainItem in ipairs(objects) do ProcessItem(mainItem) end
    end)

    if success then
        -- Guardar en el inventario de equipados
        table.insert(MyEquippedItems, { Id = tostring(assetId), Name = assetName or "Objeto", Instances = insertedInstances })
    else
        warn("Error equipando: ", err)
        local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if Backpack then
            local fallbackTool = CreateExtremeBinoculars()
            fallbackTool.Parent = Backpack
            NotifyUser("⚠️ Contingencia Activada", "Hubo un error con este asset, se inyectó herramienta alternativa.")
        end
    end
end

-- ==========================================================
-- 4. SISTEMA DE VISUALIZADOR Y MENÚ DE INVENTARIO
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then CoreGui.QuirurgicoVisualizer:Destroy() end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 160, 0, 195)
Container.Position = UDim2.new(1, -180, 0.5, -95)
Container.BackgroundTransparency = 1
Container.Visible = false
Container.Parent = VisualizerGui

-- === BOTÓN DE OJO (INVENTARIO) ===
local EyesBtn = Instance.new("ImageButton")
EyesBtn.Size = UDim2.new(0, 45, 0, 45)
EyesBtn.Position = UDim2.new(0.5, -22, 0, -55)
EyesBtn.BackgroundTransparency = 1
EyesBtn.Image = "rbxassetid://13307406982"
EyesBtn.Parent = Container

local ImagePreview = Instance.new("ImageButton")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.AutoButtonColor = true 
ImagePreview.Parent = Container

-- FLujo modificado: Ahora el visualizador EQUIPA el objeto
ImagePreview.MouseButton1Click:Connect(function()
    local idNum = tonumber(CurrentData.Id)
    if idNum and idNum > 0 then
        UniversalEquip(idNum, CurrentData.Name)
        NotifyUser("Equipado", CurrentData.Name)
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

-- === INTERFAZ DE INVENTARIO (REJILLAS) ===
local InventoryGui = Instance.new("Frame")
InventoryGui.Name = "InventoryPanel"
InventoryGui.Size = UDim2.new(0, 450, 0, 350)
InventoryGui.Position = UDim2.new(0.5, 0, 0.5, 0)
InventoryGui.AnchorPoint = Vector2.new(0.5, 0.5)
InventoryGui.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InventoryGui.BackgroundTransparency = 0.1
InventoryGui.Visible = false
InventoryGui.Parent = VisualizerGui

local InvCorner = Instance.new("UICorner")
InvCorner.CornerRadius = UDim.new(0, 12)
InvCorner.Parent = InventoryGui
local InvStroke = Instance.new("UIStroke")
InvStroke.Color = Color3.fromRGB(150, 150, 150)
InvStroke.Thickness = 2
InvStroke.Parent = InventoryGui

local InvTop = Instance.new("Frame")
InvTop.Size = UDim2.new(1, 0, 0, 40)
InvTop.BackgroundTransparency = 1
InvTop.Parent = InventoryGui

local InvTitle = Instance.new("TextLabel")
InvTitle.Size = UDim2.new(1, -50, 1, 0)
InvTitle.Position = UDim2.new(0, 15, 0, 0)
InvTitle.BackgroundTransparency = 1
InvTitle.Text = "Mis Elementos Equipados"
InvTitle.Font = Enum.Font.GothamBold
InvTitle.TextSize = 18
InvTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InvTitle.TextXAlignment = Enum.TextXAlignment.Left
InvTitle.Parent = InvTop

local InvCloseBtn = Instance.new("TextButton")
InvCloseBtn.Size = UDim2.new(0, 30, 0, 30)
InvCloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
InvCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
InvCloseBtn.Text = "X"
InvCloseBtn.Font = Enum.Font.GothamBold
InvCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InvCloseBtn.Parent = InvTop
local InvCloseCorner = Instance.new("UICorner")
InvCloseCorner.CornerRadius = UDim.new(1, 0)
InvCloseCorner.Parent = InvCloseBtn

local InvScroll = Instance.new("ScrollingFrame")
InvScroll.Size = UDim2.new(1, -20, 1, -55)
InvScroll.Position = UDim2.new(0, 10, 0, 45)
InvScroll.BackgroundTransparency = 1
InvScroll.ScrollBarThickness = 6
InvScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
InvScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InvScroll.Parent = InventoryGui

local InvGrid = Instance.new("UIGridLayout")
InvGrid.CellSize = UDim2.new(0, 100, 0, 100)
InvGrid.CellPadding = UDim2.new(0, 10, 0, 10)
InvGrid.SortOrder = Enum.SortOrder.LayoutOrder
InvGrid.Parent = InvScroll
local InvPadding = Instance.new("UIPadding")
InvPadding.PaddingTop = UDim.new(0, 5)
InvPadding.PaddingLeft = UDim.new(0, 5)
InvPadding.Parent = InvScroll

local function RefreshInventory()
    for _, child in ipairs(InvScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for index, item in ipairs(MyEquippedItems) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ItemFrame.Parent = InvScroll
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 8)
        ItemCorner.Parent = ItemFrame
        
        local ItemImg = Instance.new("ImageLabel")
        ItemImg.Size = UDim2.new(1, 0, 1, 0)
        ItemImg.BackgroundTransparency = 1
        ItemImg.Image = "rbxthumb://type=Asset&id=" .. item.Id .. "&w=150&h=150"
        ItemImg.Parent = ItemFrame
        
        local RemoveBtn = Instance.new("TextButton")
        RemoveBtn.Size = UDim2.new(1, 0, 1, 0)
        RemoveBtn.BackgroundTransparency = 1
        RemoveBtn.Text = ""
        RemoveBtn.Parent = ItemFrame
        
        RemoveBtn.MouseButton1Click:Connect(function()
            -- Destruir instancias físicas en el personaje
            for _, inst in ipairs(item.Instances) do
                if inst and inst.Parent then inst:Destroy() end
            end
            -- Quitar de la tabla y recargar rejilla
            table.remove(MyEquippedItems, index)
            RefreshInventory()
        end)
    end
end

EyesBtn.MouseButton1Click:Connect(function()
    InventoryGui.Visible = true
    RefreshInventory()
end)

InvCloseBtn.MouseButton1Click:Connect(function()
    InventoryGui.Visible = false
end)

-- ==========================================================
-- 5. SISTEMA KITTY CATALOG UI
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then CoreGui.KittyCatalogGui:Destroy() end

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
        dragToggle = true; dragStart = input.Position; startPos = FloatingBtn.Position
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
    FloatingBtn.Visible = false; KittyMain.Visible = true
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
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0) 
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    KittyMain.Visible = false; FloatingBtn.Visible = true
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.60, 0, 0, 40)
SearchContainer.Position = UDim2.new(0, 10, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SearchContainer.Parent = KittyTop
local SearchContainerCorner = Instance.new("UICorner")
SearchContainerCorner.CornerRadius = UDim.new(0, 8)
SearchContainerCorner.Parent = SearchContainer

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
local SearchBtnCorner = Instance.new("UICorner")
SearchBtnCorner.CornerRadius = UDim.new(0, 8)
SearchBtnCorner.Parent = KittySearchBtn

local KittySidebar = Instance.new("ScrollingFrame")
KittySidebar.Size = UDim2.new(0.25, 0, 1, 0)
KittySidebar.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
KittySidebar.BackgroundTransparency = 0.5
KittySidebar.BorderSizePixel = 0
KittySidebar.ScrollBarThickness = 4
KittySidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
KittySidebar.Parent = KittyMain

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.Parent = KittySidebar
local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 5)
SidebarPadding.PaddingRight = UDim.new(0, 5)
SidebarPadding.Parent = KittySidebar

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(0.75, 0, 1, -60)
KittyResults.Position = UDim2.new(0.25, 0, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.ScrollBarThickness = 6
KittyResults.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
KittyResults.AutomaticCanvasSize = Enum.AutomaticSize.Y 
KittyResults.Parent = KittyMain

local ResultsLayout = Instance.new("UIGridLayout")
ResultsLayout.CellSize = UDim2.new(0, 130, 0, 180) 
ResultsLayout.CellPadding = UDim2.new(0, 10, 0, 15)
ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ResultsLayout.Parent = KittyResults
local ResultsPadding = Instance.new("UIPadding")
ResultsPadding.PaddingTop = UDim.new(0, 10)
ResultsPadding.PaddingLeft = UDim.new(0, 10)
ResultsPadding.Parent = KittyResults

local TitleCat = Instance.new("TextLabel")
TitleCat.Size = UDim2.new(1, 0, 0, 40)
TitleCat.BackgroundTransparency = 1
TitleCat.Text = "🎀 Category"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 16
TitleCat.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleCat.Parent = KittySidebar

local KittyCurrentCategory = 1 
local CategoriesEnglish = {
    {"All", 1}, {"Accessories", 11}, {"Clothing (All)", 3}, {"Shirts", 3}, {"T-Shirts", 3}, {"Sweaters", 3}, {"Jackets", 3}, {"Pants", 3}, {"Shoes", 3},
    {"Body", 4}, {"Hair", 4}, {"Heads", 4}, {"Faces / Makeup", 4}, {"Animations", 12}, {"Emotes", 12}, {"Gear", 5}
}

for _, catData in ipairs(CategoriesEnglish) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(255, 228, 225)
    btn.Text = " " .. catData[1]
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = KittySidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        KittyCurrentCategory = catData[2]
        KittySearch.PlaceholderText = "🔍 In " .. catData[1] .. "..."
    end)
end

local function PerformKittySearch()
    if KittySearch.Text == "" then return end
    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=30&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
    local success, response = pcall(function() return game:HttpGet(url) end)

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
                CardName.TextWrapped = true
                CardName.TextXAlignment = Enum.TextXAlignment.Left
                CardName.Parent = Card
                
                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Text = ""
                ClickBtn.Parent = Card
                
                -- Flujo modificado: Ahora solo selecciona para el visualizador
                ClickBtn.MouseButton1Click:Connect(function()
                    CurrentData.Id = tostring(item.id)
                    CurrentData.Name = item.name
                    UpdateVisualizer(item.id, item.price or "Gratis")
                end)
            end
        end
    end
end
KittySearchBtn.MouseButton1Click:Connect(PerformKittySearch)
