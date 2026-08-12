-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (v25.3 ANTI-FREEZE & ULTRA-ASYNC) - FIX SEARCH
-- Gestión Eficiente de Memoria + Frame-Slicing + Carga Asíncrona de I/O
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }
local KeepEquippedOnDeath = false 
local SavedEquippedIDs = {}
local PlayingAnimationTracks = {}
local ItemAdjustments = {}
local EqPanel, RefreshEquippedItems 

local CHARS_FILE = "CHARACTERS.json"
local DEFAULT_FLOATING_POS = UDim2.new(1, -80, 0.5, -30)

-- ==========================================================
-- SISTEMA DE BANNERS / CACHÉ & FRAME SLICING (ANTI-FREEZE)
-- ==========================================================
local BannerSystem = {
    Cache = {},
    LoadingQueue = {},
    IsProcessing = false,
    BatchSizePerFrame = 2,
}

function BannerSystem.PreloadBanners(bannerList)
    task.spawn(function()
        for i, bannerData in ipairs(bannerList) do
            if not BannerSystem.Cache[bannerData.Id] then
                table.insert(BannerSystem.LoadingQueue, bannerData)
            end
            if i % BannerSystem.BatchSizePerFrame == 0 then
                task.wait() 
            end
        end
        BannerSystem.ProcessQueue()
    end)
end

function BannerSystem.ProcessQueue()
    if BannerSystem.IsProcessing then return end
    BannerSystem.IsProcessing = true

    task.spawn(function()
        while #BannerSystem.LoadingQueue > 0 do
            local batchCount = 0
            while #BannerSystem.LoadingQueue > 0 and batchCount < BannerSystem.BatchSizePerFrame do
                local bannerData = table.remove(BannerSystem.LoadingQueue, 1)
                local bannerObj = BannerSystem.RenderBanner(bannerData)
                if bannerData.Id then
                    BannerSystem.Cache[bannerData.Id] = bannerObj
                end
                batchCount = batchCount + 1
            end
            task.wait()
        end
        BannerSystem.IsProcessing = false
    end)
end

function BannerSystem.RenderBanner(bannerData)
    if bannerData.Id and BannerSystem.Cache[bannerData.Id] then
        local cached = BannerSystem.Cache[bannerData.Id]
        cached.Parent = bannerData.ParentContainer
        return cached
    end

    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Card.Parent = bannerData.ParentContainer
    
    local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 10); CardCorner.Parent = Card
    
    local CardImg = Instance.new("ImageLabel")
    CardImg.Size = UDim2.new(1, 0, 0, 100)
    CardImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    CardImg.Parent = Card
    local ImgCorner = Instance.new("UICorner"); ImgCorner.CornerRadius = UDim.new(0, 10); ImgCorner.Parent = CardImg
    
    task.spawn(function()
        if bannerData.Id then
            CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(bannerData.Id) .. "&w=150&h=150"
        end
    end)
    
    local CardName = Instance.new("TextLabel")
    CardName.Size = UDim2.new(1, -10, 0, 25)
    CardName.Position = UDim2.new(0, 5, 0, 105)
    CardName.BackgroundTransparency = 1
    CardName.Text = bannerData.Name or "Item"
    CardName.Font = Enum.Font.GothamSemibold
    CardName.TextSize = 11
    CardName.TextColor3 = Color3.fromRGB(30, 30, 30)
    CardName.TextWrapped = true
    CardName.TextXAlignment = Enum.TextXAlignment.Left
    CardName.Parent = Card
    
    local CardCreator = Instance.new("TextLabel")
    CardCreator.Size = UDim2.new(1, -10, 0, 15)
    CardCreator.Position = UDim2.new(0, 5, 0, 135)
    CardCreator.BackgroundTransparency = 1
    CardCreator.Text = "De " .. (bannerData.Creator or "Desconocido")
    CardCreator.Font = Enum.Font.Gotham
    CardCreator.TextSize = 10
    CardCreator.TextColor3 = Color3.fromRGB(100, 100, 100)
    CardCreator.TextXAlignment = Enum.TextXAlignment.Left
    CardCreator.Parent = Card
    
    local CardPrice = Instance.new("TextLabel")
    CardPrice.Size = UDim2.new(1, -25, 0, 20)
    CardPrice.Position = UDim2.new(0, 25, 0, 155)
    CardPrice.BackgroundTransparency = 1
    CardPrice.Text = bannerData.Price and tostring(bannerData.Price) or "Gratis"
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
    CardRobux.Visible = (bannerData.Price ~= nil and type(bannerData.Price) == "number" and bannerData.Price > 0)
    CardRobux.Parent = Card

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = Card
    
    ClickBtn.MouseButton1Click:Connect(function()
        CurrentData.Id = tostring(bannerData.Id)
        CurrentData.Name = bannerData.Name
        CurrentData.Price = bannerData.Price and (tostring(bannerData.Price) .. " R$") or "Gratis"
        CurrentData.ItemType = bannerData.ItemType or "Asset"
        
        if bannerData.OnSelectCallback then
            bannerData.OnSelectCallback(bannerData.Id, bannerData.Price or "Gratis")
        end
    end)

    return Card
end

function BannerSystem.ClearCache()
    table.clear(BannerSystem.Cache)
    table.clear(BannerSystem.LoadingQueue)
    BannerSystem.IsProcessing = false
end

-- ==========================================================
-- PRECARGA DE ASSETS EN SEGUNDO PLANO
-- ==========================================================
local CachedDefaultDescription = nil

task.spawn(function()
    pcall(function()
        CachedDefaultDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
    end)

    local assetsToPreload = {
        "rbxassetid://13307406982",
        "rbxassetid://15538455161",
        "rbxassetid://11560341824"
    }
    pcall(function()
        ContentProvider:PreloadAsync(assetsToPreload)
    end)
end)

local function NotifyUser(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = 4; })
    end)
end

-- ==========================================================
-- FUNCIONES AUXILIARES DE TRANSFORMACIÓN
-- ==========================================================
local function ApplyAdjustmentToInstance(itemInstance, adj)
    if not itemInstance or not adj or not itemInstance:IsA("Accessory") then return end
    local handle = itemInstance:FindFirstChild("Handle")
    if not handle then return end
    local weld = handle:FindFirstChild("AccessoryWeld")
    if not weld then return end

    if not ItemAdjustments[itemInstance] then
        local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
        ItemAdjustments[itemInstance] = {
            OriginalWeldC1 = weld.C1,
            OrigMeshScale = mesh and mesh.Scale or nil,
            OffsetX = adj.OffsetX or 0,
            OffsetY = adj.OffsetY or 0,
            OffsetZ = adj.OffsetZ or 0,
            RotX = adj.RotX or 0,
            RotY = adj.RotY or 0,
            RotZ = adj.RotZ or 0,
            Scale = adj.Scale or 1
        }
    end

    local data = ItemAdjustments[itemInstance]
    data.OffsetX = adj.OffsetX or 0
    data.OffsetY = adj.OffsetY or 0
    data.OffsetZ = adj.OffsetZ or 0
    data.RotX = adj.RotX or 0
    data.RotY = adj.RotY or 0
    data.RotZ = adj.RotZ or 0
    data.Scale = adj.Scale or 1

    weld.C1 = data.OriginalWeldC1 
        * CFrame.new(-data.OffsetX, -data.OffsetY, -data.OffsetZ) 
        * CFrame.Angles(math.rad(data.RotX), math.rad(data.RotY), math.rad(data.RotZ))

    local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
    if mesh and data.OrigMeshScale then
        mesh.Scale = data.OrigMeshScale * data.Scale
    end
end

local function ApplyAdjustmentToDummy(dummyItem, adj)
    if not dummyItem or not adj or not dummyItem:IsA("Accessory") then return end
    local handle = dummyItem:FindFirstChild("Handle")
    if not handle then return end
    local weld = handle:FindFirstChild("AccessoryWeld")
    if not weld then return end

    local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")

    weld.C1 = weld.C1 
        * CFrame.new(-(adj.OffsetX or 0), -(adj.OffsetY or 0), -(adj.OffsetZ or 0)) 
        * CFrame.Angles(math.rad(adj.RotX or 0), math.rad(adj.RotY or 0), math.rad(adj.RotZ or 0))

    if mesh then
        mesh.Scale = mesh.Scale * (adj.Scale or 1)
    end
end

-- ==========================================================
-- SISTEMA DE ARCHIVOS Y METADATOS JSON EN SEGUNDO PLANO
-- ==========================================================
local CachedCharactersData = nil

local function LoadSavedCharactersDataAsync(callback)
    task.spawn(function()
        if CachedCharactersData then
            if callback then callback(CachedCharactersData) end
            return
        end
        if isfile and isfile(CHARS_FILE) then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(CHARS_FILE))
            end)
            if success and type(result) == "table" then
                CachedCharactersData = result
                if callback then callback(result) end
                return
            end
        end
        CachedCharactersData = {}
        if callback then callback({}) end
    end)
end

local function SaveCharactersData(data)
    CachedCharactersData = data
    task.spawn(function()
        if writefile then
            pcall(function()
                writefile(CHARS_FILE, HttpService:JSONEncode(data))
            end)
        end
    end)
end

local function IsAlreadyEquipped(assetId)
    local char = LocalPlayer.Character
    if not char or not assetId then return false end
    local numericId = tonumber(assetId)
    if not numericId then return false end

    for _, v in ipairs(char:GetDescendants()) do
        if v:GetAttribute("AssetId") == numericId then
            return true
        end
    end
    return false
end

-- ==========================================================
-- RESTAURACIÓN DE AVATAR Y MANEJO DE HILOS
-- ==========================================================
local function ResetToDefaultAvatar()
    SavedEquippedIDs = {}
    ItemAdjustments = {}
    
    for id, track in pairs(PlayingAnimationTracks) do
        pcall(function()
            track:Stop()
            track:Destroy()
        end)
    end
    PlayingAnimationTracks = {}

    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return end

    for _, part in ipairs(Char:GetChildren()) do
        if part:IsA("BasePart") then
            local pName = string.lower(part.Name)
            if string.find(pName, "leg") or string.find(pName, "foot") then
                part.Transparency = 0
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:GetAttribute("AssetId") then
                v:Destroy()
            end
        end
    end

    for _, v in ipairs(Char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Tool") or v:GetAttribute("IsAnimation") then
            v:Destroy()
        end
    end

    pcall(function()
        local defaultDesc = CachedDefaultDescription or Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
        Hum:ApplyDescription(defaultDesc)
    end)

    if EqPanel and RefreshEquippedItems then
        RefreshEquippedItems()
    end
end

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
-- CARGA UNIVERSAL ASÍNCRONA
-- ==========================================================
local function UniversalEquip(assetId, isReequipping)
    task.spawn(function()
        local numericId = tonumber(assetId)
        if not numericId or numericId == 0 then return end

        if not isReequipping and IsAlreadyEquipped(numericId) then
            NotifyUser("⚠️ En Uso", "Este elemento ya está equipado.")
            return
        end

        local Char = LocalPlayer.Character
        if not Char then return end
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end

        local objects = nil
        local getSuccess, _ = pcall(function()
            objects = game:GetObjects("rbxassetid://" .. tostring(numericId))
        end)

        if not getSuccess or not objects or #objects == 0 then
            task.spawn(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. tostring(numericId)
                anim:SetAttribute("AssetId", numericId)
                
                local animator = Hum:FindFirstChildOfClass("Animator") or Hum:FindFirstChild("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = Hum
                end
                
                if PlayingAnimationTracks[numericId] then
                    PlayingAnimationTracks[numericId]:Stop()
                    PlayingAnimationTracks[numericId]:Destroy()
                end

                local track = animator:LoadAnimation(anim)
                track:Play()
                PlayingAnimationTracks[numericId] = track

                local animHolder = Char:FindFirstChild("AnimFolder_" .. numericId) or Instance.new("Folder")
                animHolder.Name = "AnimFolder_" .. numericId
                animHolder:SetAttribute("AssetId", numericId)
                animHolder:SetAttribute("IsAnimation", true)
                animHolder.Parent = Char

                SavedEquippedIDs[numericId] = true
            end)
            return
        end

        local function ProcessItem(item)
            if not item then return end

            if item:IsA("Accessory") then
                local cloneItem = item:Clone()
                cloneItem:SetAttribute("AssetId", numericId)
                local handle = cloneItem:FindFirstChild("Handle")
                
                if handle then
                    handle.Transparency = 0
                    handle.Anchored = false
                    handle.CanCollide = false
                    handle.Massless = true

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
                            weld.Name = "AccessoryWeld" 
                            weld.Part0 = targetAttach.Parent
                            weld.Part1 = handle
                            weld.C0 = targetAttach.CFrame
                            weld.C1 = accAttach.CFrame
                            weld.Parent = handle
                        end
                    else
                        local bodyTarget = Char:FindFirstChild("UpperTorso") or Char:FindFirstChild("LowerTorso") or Char:FindFirstChild("Torso") or Char.PrimaryPart
                        if bodyTarget then
                            for _, v in ipairs(handle:GetJoints()) do v:Destroy() end
                            local weld = Instance.new("Weld")
                            weld.Name = "AccessoryWeld" 
                            weld.Part0 = bodyTarget
                            weld.Part1 = handle
                            weld.C0 = CFrame.new()
                            weld.C1 = CFrame.new()
                            weld.Parent = handle
                        end
                    end
                    
                    local wrapLayer = handle:FindFirstChildWhichIsA("WrapLayer")
                    if wrapLayer then
                        task.defer(function()
                            wrapLayer.Enabled = false
                            task.wait(0.05)
                            wrapLayer.Enabled = true
                        end)
                        
                        local isPant = false
                        pcall(function()
                            if item.AccessoryType == Enum.AccessoryType.Pants or item.AccessoryType == Enum.AccessoryType.Shorts then
                                isPant = true
                            end
                        end)
                        if not isPant and accAttach and (accAttach.Name == "WaistCenterAttachment" or string.find(string.lower(item.Name), "pant")) then
                            isPant = true
                        end
                        
                        if isPant then
                            cloneItem:SetAttribute("HidesLegs", true)
                            for _, part in ipairs(Char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    local pName = string.lower(part.Name)
                                    if string.find(pName, "leg") or string.find(pName, "foot") then
                                        part.Transparency = 1
                                    end
                                end
                            end
                        end
                    end
                end
                
                cloneItem.Parent = Char
                SavedEquippedIDs[numericId] = true

            elseif item:IsA("Animation") then
                local animator = Hum:FindFirstChildOfClass("Animator") or Hum:FindFirstChild("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = Hum
                end
                
                if PlayingAnimationTracks[numericId] then
                    PlayingAnimationTracks[numericId]:Stop()
                    PlayingAnimationTracks[numericId]:Destroy()
                end

                local track = animator:LoadAnimation(item)
                track:Play()
                PlayingAnimationTracks[numericId] = track

                local animHolder = Char:FindFirstChild("AnimFolder_" .. numericId) or Instance.new("Folder")
                animHolder.Name = "AnimFolder_" .. numericId
                animHolder:SetAttribute("AssetId", numericId)
                animHolder:SetAttribute("IsAnimation", true)
                animHolder.Parent = Char

                SavedEquippedIDs[numericId] = true

            elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                for _, v in pairs(Char:GetChildren()) do
                    if v.ClassName == item.ClassName then v:Destroy() end
                end
                local cloneItem = item:Clone()
                cloneItem:SetAttribute("AssetId", numericId)
                cloneItem.Parent = Char
                SavedEquippedIDs[numericId] = true

            elseif item:IsA("MeshPart") then
                local currentPart = Char:FindFirstChild(item.Name)
                if currentPart and currentPart:IsA("MeshPart") then
                    currentPart.MeshId = item.MeshId
                    local surface = item:FindFirstChildWhichIsA("SurfaceAppearance")
                    if surface then
                        local oldSurface = currentPart:FindFirstChildWhichIsA("SurfaceAppearance")
                        if oldSurface then oldSurface:Destroy() end
                        surface:Clone().Parent = currentPart
                    end
                end
                SavedEquippedIDs[numericId] = true

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
                SavedEquippedIDs[numericId] = true
                
            elseif item:IsA("Tool") or item:IsA("HopperBin") or item:IsA("Gear") then
                local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if Backpack then 
                    local toolClone = item:Clone()
                    toolClone:SetAttribute("AssetId", numericId)
                    toolClone.Parent = Backpack 
                    pcall(function() Hum:EquipTool(toolClone) end)
                end
                SavedEquippedIDs[numericId] = true

            elseif item:IsA("Model") or item:IsA("Folder") then
                for _, subItem in ipairs(item:GetChildren()) do
                    ProcessItem(subItem)
                end
            else
                local cloneItem = item:Clone()
                cloneItem:SetAttribute("AssetId", numericId)
                cloneItem.Parent = Char
                SavedEquippedIDs[numericId] = true
            end
        end

        for _, mainItem in ipairs(objects) do 
            ProcessItem(mainItem) 
            task.wait(0.01)
        end

        task.defer(function()
            if EqPanel and EqPanel.Visible and RefreshEquippedItems then
                RefreshEquippedItems()
            end
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not KeepEquippedOnDeath then 
        SavedEquippedIDs = {}
        return 
    end
    newChar:WaitForChild("Humanoid", 10)
    task.wait(1.0)
    
    task.spawn(function()
        for id, active in pairs(SavedEquippedIDs) do
            if active and KeepEquippedOnDeath then
                UniversalEquip(id, true)
                task.wait(0.06)
            end
        end
    end)
end)

-- ==========================================================
-- UI DE VISUALIZACIÓN Y MENÚS
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then CoreGui.QuirurgicoVisualizer:Destroy() end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.DisplayOrder = 10
VisualizerGui.Parent = CoreGui

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 160, 0, 195)
Container.Position = UDim2.new(1, -180, 0.5, -95)
Container.BackgroundTransparency = 1
Container.Visible = false
Container.ZIndex = 1
Container.Parent = VisualizerGui

EqPanel = Instance.new("Frame")
EqPanel.Size = UDim2.new(0, 350, 0, 300)
EqPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
EqPanel.AnchorPoint = Vector2.new(0.5, 0.5)
EqPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
EqPanel.Visible = false
EqPanel.ClipsDescendants = true
EqPanel.ZIndex = 10
EqPanel.Parent = VisualizerGui
local EqCorner = Instance.new("UICorner"); EqCorner.CornerRadius = UDim.new(0, 12); EqCorner.Parent = EqPanel
local EqStroke = Instance.new("UIStroke"); EqStroke.Color = Color3.fromRGB(150, 150, 150); EqStroke.Thickness = 2; EqStroke.Parent = EqPanel

local EqTitle = Instance.new("TextLabel")
EqTitle.Size = UDim2.new(1, 0, 0, 40)
EqTitle.BackgroundTransparency = 1
EqTitle.Text = "Tus Elementos (Toca p/ Quitar | Manten p/ Editar)"
EqTitle.Font = Enum.Font.GothamBold
EqTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
EqTitle.TextSize = 13
EqTitle.ZIndex = 11
EqTitle.Parent = EqPanel

local EqCloseBtn = Instance.new("TextButton")
EqCloseBtn.Size = UDim2.new(0, 30, 0, 30)
EqCloseBtn.Position = UDim2.new(1, -35, 0, 5)
EqCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
EqCloseBtn.Text = "X"
EqCloseBtn.Font = Enum.Font.GothamBold
EqCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EqCloseBtn.ZIndex = 11
EqCloseBtn.Parent = EqPanel
local EqCloseCorner = Instance.new("UICorner"); EqCloseCorner.CornerRadius = UDim.new(0, 6); EqCloseCorner.Parent = EqCloseBtn
EqCloseBtn.MouseButton1Click:Connect(function() EqPanel.Visible = false end)

local EqScroll = Instance.new("ScrollingFrame")
EqScroll.Size = UDim2.new(1, -20, 1, -50)
EqScroll.Position = UDim2.new(0, 10, 0, 40)
EqScroll.BackgroundTransparency = 1
EqScroll.ScrollBarThickness = 5
EqScroll.ClipsDescendants = true
EqScroll.ZIndex = 11
EqScroll.Parent = EqPanel
local EqGrid = Instance.new("UIGridLayout")
EqGrid.CellSize = UDim2.new(0, 70, 0, 70)
EqGrid.CellPadding = UDim2.new(0, 10, 0, 10)
EqGrid.Parent = EqScroll
EqGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EqScroll.CanvasSize = UDim2.new(0, 0, 0, EqGrid.AbsoluteContentSize.Y + 20)
end)

-- ==========================================================
-- MENÚ DE PERSONAJES (CON CABLEADO FRAME-SLICING ASÍNCRONO)
-- ==========================================================
local CharMenu = Instance.new("Frame")
CharMenu.Size = UDim2.new(0, 450, 0.82, 0)
CharMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
CharMenu.AnchorPoint = Vector2.new(0.5, 0.5)
CharMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CharMenu.ClipsDescendants = true
CharMenu.Visible = false
CharMenu.ZIndex = 30
CharMenu.Parent = VisualizerGui

local CharMenuConstraint = Instance.new("UISizeConstraint")
CharMenuConstraint.MaxSize = Vector2.new(480, 320)
CharMenuConstraint.MinSize = Vector2.new(300, 240)
CharMenuConstraint.Parent = CharMenu

local CharCorner = Instance.new("UICorner"); CharCorner.CornerRadius = UDim.new(0, 12); CharCorner.Parent = CharMenu
local CharStroke = Instance.new("UIStroke"); CharStroke.Color = Color3.fromRGB(255, 105, 180); CharStroke.Thickness = 2; CharStroke.Parent = CharMenu

local CharTitle = Instance.new("TextLabel")
CharTitle.Size = UDim2.new(1, -50, 0, 38)
CharTitle.Position = UDim2.new(0, 12, 0, 2)
CharTitle.BackgroundTransparency = 1
CharTitle.Text = "📁 OUTFITS GUARDADOS"
CharTitle.Font = Enum.Font.GothamBold
CharTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CharTitle.TextSize = 13
CharTitle.TextXAlignment = Enum.TextXAlignment.Left
CharTitle.ZIndex = 31
CharTitle.Parent = CharMenu

local CharCloseBtn = Instance.new("TextButton")
CharCloseBtn.Size = UDim2.new(0, 26, 0, 26)
CharCloseBtn.Position = UDim2.new(1, -34, 0, 8)
CharCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CharCloseBtn.Text = "X"
CharCloseBtn.Font = Enum.Font.GothamBold
CharCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CharCloseBtn.TextSize = 13
CharCloseBtn.ZIndex = 32
CharCloseBtn.Parent = CharMenu
local CharCloseCorner = Instance.new("UICorner"); CharCloseCorner.CornerRadius = UDim.new(0, 6); CharCloseCorner.Parent = CharCloseBtn
CharCloseBtn.MouseButton1Click:Connect(function() CharMenu.Visible = false end)

local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(1, -140, 0, 32)
NameInput.Position = UDim2.new(0, 12, 0, 42)
NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NameInput.PlaceholderText = "Nombre del Personaje..."
NameInput.Text = ""
NameInput.Font = Enum.Font.GothamMedium
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NameInput.TextSize = 11
NameInput.TextXAlignment = Enum.TextXAlignment.Center
NameInput.ClipsDescendants = true
NameInput.ZIndex = 31
NameInput.Parent = CharMenu
local NameCorner = Instance.new("UICorner"); NameCorner.CornerRadius = UDim.new(0, 6); NameCorner.Parent = NameInput

local SaveCharBtn = Instance.new("TextButton")
SaveCharBtn.Size = UDim2.new(0, 105, 0, 32)
SaveCharBtn.Position = UDim2.new(1, -117, 0, 42)
SaveCharBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
SaveCharBtn.Text = "💾 GUARDAR"
SaveCharBtn.Font = Enum.Font.GothamBold
SaveCharBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveCharBtn.TextSize = 10
SaveCharBtn.ZIndex = 31
SaveCharBtn.Parent = CharMenu
local SaveCorner = Instance.new("UICorner"); SaveCorner.CornerRadius = UDim.new(0, 6); SaveCorner.Parent = SaveCharBtn

local CharScroll = Instance.new("ScrollingFrame")
CharScroll.Size = UDim2.new(1, -20, 1, -85)
CharScroll.Position = UDim2.new(0, 10, 0, 80)
CharScroll.BackgroundTransparency = 1
CharScroll.ScrollBarThickness = 4
CharScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
CharScroll.ClipsDescendants = true
CharScroll.ZIndex = 31
CharScroll.Parent = CharMenu

local CharScrollPadding = Instance.new("UIPadding")
CharScrollPadding.PaddingTop = UDim.new(0, 8)
CharScrollPadding.PaddingBottom = UDim.new(0, 15)
CharScrollPadding.PaddingLeft = UDim.new(0, 5)
CharScrollPadding.PaddingRight = UDim.new(0, 5)
CharScrollPadding.Parent = CharScroll

local CharGrid = Instance.new("UIGridLayout")
CharGrid.CellSize = UDim2.new(0, 105, 0, 140)
CharGrid.CellPadding = UDim2.new(0, 10, 0, 10)
CharGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
CharGrid.Parent = CharScroll

CharGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CharScroll.CanvasSize = UDim2.new(0, 0, 0, CharGrid.AbsoluteContentSize.Y + 25)
end)

local isGridRefreshing = false
local function RefreshSavedCharactersGrid()
    if isGridRefreshing then return end
    isGridRefreshing = true

    for _, child in ipairs(CharScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    LoadSavedCharactersDataAsync(function(data)
        task.spawn(function()
            for charName, itemEntries in pairs(data) do
                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(0, 105, 0, 140)
                Card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Card.ClipsDescendants = true
                Card.ZIndex = 32
                Card.Parent = CharScroll
                local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 8); CardCorner.Parent = Card
                local CardStroke = Instance.new("UIStroke"); CardStroke.Color = Color3.fromRGB(60, 60, 60); CardStroke.Thickness = 1; CardStroke.Parent = Card

                local Viewport = Instance.new("ViewportFrame")
                Viewport.Size = UDim2.new(1, -10, 0, 75)
                Viewport.Position = UDim2.new(0, 5, 0, 5)
                Viewport.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Viewport.BackgroundTransparency = 0
                Viewport.ClipsDescendants = true
                Viewport.ZIndex = 33
                Viewport.Parent = Card
                local VCorner = Instance.new("UICorner"); VCorner.CornerRadius = UDim.new(0, 6); VCorner.Parent = Viewport

                task.spawn(function()
                    local currentChar = LocalPlayer.Character
                    if not currentChar then return end
                    
                    currentChar.Archivable = true
                    local dummy = currentChar:Clone()
                    currentChar.Archivable = false

                    for _, v in ipairs(dummy:GetChildren()) do
                        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Tool") or v:IsA("Script") or v:IsA("LocalScript") then
                            v:Destroy()
                        end
                    end

                    for _, part in ipairs(dummy:GetChildren()) do
                        if part:IsA("BasePart") then
                            local pName = string.lower(part.Name)
                            if string.find(pName, "leg") or string.find(pName, "foot") then
                                part.Transparency = 0
                            end
                        end
                    end

                    local hum = dummy:FindFirstChildOfClass("Humanoid")
                    local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
                    
                    for _, part in ipairs(dummy:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Anchored = false
                        end
                    end

                    local hrp = dummy:FindFirstChild("HumanoidRootPart") or dummy.PrimaryPart
                    if hrp then hrp.Anchored = true end

                    local function ProcessDummyItem(item)
                        if not item then return end

                        if item:IsA("Accessory") then
                            local cloneItem = item:Clone()
                            local handle = cloneItem:FindFirstChild("Handle")
                            if handle then
                                handle.Transparency = 0
                                handle.Anchored = false
                                handle.CanCollide = false
                                
                                local accAttach = handle:FindFirstChildWhichIsA("Attachment")
                                if accAttach then
                                    local targetAttach = nil
                                    for _, att in ipairs(dummy:GetDescendants()) do
                                        if att:IsA("Attachment") and att.Name == accAttach.Name and att.Parent:IsA("BasePart") then
                                            targetAttach = att
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
                                    local bodyTarget = dummy:FindFirstChild("UpperTorso") or dummy:FindFirstChild("LowerTorso") or dummy:FindFirstChild("Torso") or dummy.PrimaryPart
                                    if bodyTarget then
                                        for _, j in ipairs(handle:GetJoints()) do j:Destroy() end
                                        local weld = Instance.new("Weld")
                                        weld.Name = "AccessoryWeld"
                                        weld.Part0 = bodyTarget
                                        weld.Part1 = handle
                                        weld.C0 = CFrame.new()
                                        weld.C1 = CFrame.new()
                                        weld.Parent = handle
                                    end
                                end

                                local isPant = false
                                pcall(function()
                                    if item.AccessoryType == Enum.AccessoryType.Pants or item.AccessoryType == Enum.AccessoryType.Shorts then
                                        isPant = true
                                    end
                                end)
                                if not isPant and accAttach and (accAttach.Name == "WaistCenterAttachment" or string.find(string.lower(item.Name), "pant")) then
                                    isPant = true
                                end
                                if isPant then
                                    for _, part in ipairs(dummy:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            local pName = string.lower(part.Name)
                                            if string.find(pName, "leg") or string.find(pName, "foot") then
                                                part.Transparency = 1
                                            end
                                        end
                                    end
                                end
                            end
                            cloneItem.Parent = dummy
                            return cloneItem

                        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                            for _, v in pairs(dummy:GetChildren()) do
                                if v.ClassName == item.ClassName then v:Destroy() end
                            end
                            local cloneItem = item:Clone()
                            cloneItem.Parent = dummy
                            return cloneItem

                        elseif item:IsA("Decal") then
                            local head = dummy:FindFirstChild("Head")
                            if head then
                                local currentFace = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
                                if currentFace then 
                                    currentFace.Texture = item.Texture
                                else
                                    local newFace = item:Clone()
                                    newFace.Name = "face"
                                    newFace.Parent = head
                                end
                            end

                        elseif item:IsA("Animation") then
                            if animator then
                                local track = animator:LoadAnimation(item)
                                track:Play()
                            end

                        elseif item:IsA("Tool") or item:IsA("Gear") then
                            local cloneItem = item:Clone()
                            cloneItem.Parent = dummy
                            return cloneItem

                        elseif item:IsA("Model") or item:IsA("Folder") then
                            for _, sub in ipairs(item:GetChildren()) do
                                ProcessDummyItem(sub)
                            end
                        else
                            local cloneItem = item:Clone()
                            cloneItem.Parent = dummy
                            return cloneItem
                        end
                    end

                    for _, entry in ipairs(itemEntries) do
                        local id = type(entry) == "table" and entry.id or entry
                        local adj = type(entry) == "table" and entry.adj or nil

                        local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
                        local processedAsObject = false

                        if success and objects and #objects > 0 then
                            for _, obj in ipairs(objects) do
                                processedAsObject = true
                                local dummyItem = ProcessDummyItem(obj)
                                if dummyItem and adj then
                                    ApplyAdjustmentToDummy(dummyItem, adj)
                                end
                            end
                        end

                        if not processedAsObject and animator then
                            pcall(function()
                                local anim = Instance.new("Animation")
                                anim.AnimationId = "rbxassetid://" .. tostring(id)
                                local track = animator:LoadAnimation(anim)
                                track:Play()
                            end)
                        end
                        task.wait()
                    end

                    local worldModel = Instance.new("WorldModel")
                    worldModel.Parent = Viewport
                    dummy.Parent = worldModel

                    local cam = Instance.new("Camera")
                    cam.Parent = Viewport
                    Viewport.CurrentCamera = cam

                    local primary = dummy:FindFirstChild("HumanoidRootPart") or dummy:FindFirstChild("UpperTorso") or dummy:FindFirstChild("Torso") or dummy.PrimaryPart
                    if primary then
                        cam.CFrame = CFrame.new(primary.Position + (primary.CFrame.LookVector * 5.2) + Vector3.new(0, 0.2, 0), primary.Position + Vector3.new(0, -0.1, 0))
                    end
                end)

                local LabelName = Instance.new("TextLabel")
                LabelName.Size = UDim2.new(1, -10, 0, 18)
                LabelName.Position = UDim2.new(0, 5, 0, 84)
                LabelName.BackgroundTransparency = 1
                LabelName.Text = charName
                LabelName.Font = Enum.Font.GothamBold
                LabelName.TextColor3 = Color3.fromRGB(255, 255, 255)
                LabelName.TextSize = 10
                LabelName.TextTruncate = Enum.TextTruncate.AtEnd
                LabelName.ZIndex = 33
                LabelName.Parent = Card

                local LoadBtn = Instance.new("TextButton")
                LoadBtn.Size = UDim2.new(0, 62, 0, 24)
                LoadBtn.Position = UDim2.new(0, 5, 1, -29)
                LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
                LoadBtn.Text = "Cargar"
                LoadBtn.Font = Enum.Font.GothamBold
                LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                LoadBtn.TextSize = 10
                LoadBtn.ZIndex = 33
                LoadBtn.Parent = Card
                local LoadCorner = Instance.new("UICorner"); LoadCorner.CornerRadius = UDim.new(0, 4); LoadCorner.Parent = LoadBtn

                local DelBtn = Instance.new("TextButton")
                DelBtn.Size = UDim2.new(0, 24, 0, 24)
                DelBtn.Position = UDim2.new(1, -29, 1, -29)
                DelBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                DelBtn.Text = "🗑️"
                DelBtn.Font = Enum.Font.GothamBold
                DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                DelBtn.TextSize = 10
                DelBtn.ZIndex = 33
                DelBtn.Parent = Card
                local DelCorner = Instance.new("UICorner"); DelCorner.CornerRadius = UDim.new(0, 4); DelCorner.Parent = DelBtn

                LoadBtn.MouseButton1Click:Connect(function()
                    ResetToDefaultAvatar()
                    task.wait(0.15)
                    
                    task.spawn(function()
                        for _, entry in ipairs(itemEntries) do
                            local id = type(entry) == "table" and entry.id or entry
                            local adj = type(entry) == "table" and entry.adj or nil

                            UniversalEquip(id, false)
                            
                            if adj then
                                task.spawn(function()
                                    task.wait(0.12)
                                    local char = LocalPlayer.Character
                                    if char then
                                        for _, child in ipairs(char:GetChildren()) do
                                            local childId = child:GetAttribute("AssetId")
                                            if (childId == id or child.SourceAssetId == id) and child:IsA("Accessory") then
                                                ApplyAdjustmentToInstance(child, adj)
                                            end
                                        end
                                    end
                                end)
                            end
                            task.wait(0.06)
                        end
                        NotifyUser("Personaje Cargado", "Se equipó: " .. charName)
                    end)
                end)

                DelBtn.MouseButton1Click:Connect(function()
                    LoadSavedCharactersDataAsync(function(currentData)
                        currentData[charName] = nil
                        SaveCharactersData(currentData)
                        RefreshSavedCharactersGrid()
                        NotifyUser("Eliminado", "Se eliminó a " .. charName)
                    end)
                end)

                task.wait()
            end
            isGridRefreshing = false
        end)
    end)
end

SaveCharBtn.MouseButton1Click:Connect(function()
    local name = NameInput.Text
    if name == "" or name:match("^%s*$") then
        NotifyUser("Atención", "Ingresa un nombre válido.")
        return
    end

    local itemsToSave = {}
    local char = LocalPlayer.Character

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Tool") or item:GetAttribute("IsAnimation") then
                local eqId = item:GetAttribute("AssetId")
                if (not eqId or eqId == 0) and item:IsA("Accessory") then eqId = item.SourceAssetId end

                if eqId and eqId > 0 then
                    local entry = { id = eqId }
                    if ItemAdjustments[item] then
                        local adj = ItemAdjustments[item]
                        entry.adj = {
                            OffsetX = adj.OffsetX,
                            OffsetY = adj.OffsetY,
                            OffsetZ = adj.OffsetZ,
                            RotX = adj.RotX,
                            RotY = adj.RotY,
                            RotZ = adj.RotZ,
                            Scale = adj.Scale
                        }
                    end
                    table.insert(itemsToSave, entry)
                end
            end
        end
    end

    for id, active in pairs(SavedEquippedIDs) do
        if active then
            local alreadyAdded = false
            for _, entry in ipairs(itemsToSave) do
                local entryId = type(entry) == "table" and entry.id or entry
                if entryId == id then
                    alreadyAdded = true
                    break
                end
            end
            if not alreadyAdded then
                table.insert(itemsToSave, { id = id })
            end
        end
    end

    if #itemsToSave == 0 then
        NotifyUser("Atención", "No tienes ítems equipados para guardar.")
        return
    end

    LoadSavedCharactersDataAsync(function(data)
        data[name] = itemsToSave
        SaveCharactersData(data)
        NameInput.Text = ""
        RefreshSavedCharactersGrid()
        NotifyUser("Guardado Exitoso", "Personaje '" .. name .. "' guardado con sus ajustes.")
    end)
end)

-- ==========================================================
-- EDIT PANEL
-- ==========================================================
local EditPanel = Instance.new("Frame")
EditPanel.Size = UDim2.new(0, 340, 0, 280)
EditPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
EditPanel.AnchorPoint = Vector2.new(0.5, 0.5)
EditPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
EditPanel.BackgroundTransparency = 0.4
EditPanel.ClipsDescendants = true
EditPanel.Visible = false
EditPanel.ZIndex = 15
EditPanel.Parent = VisualizerGui
local EditCorner = Instance.new("UICorner"); EditCorner.CornerRadius = UDim.new(0, 12); EditCorner.Parent = EditPanel
local EditStroke = Instance.new("UIStroke"); EditStroke.Color = Color3.fromRGB(255, 105, 180); EditStroke.Thickness = 2; EditStroke.Parent = EditPanel

local EditTitle = Instance.new("TextLabel")
EditTitle.Size = UDim2.new(1, 0, 0, 35)
EditTitle.BackgroundTransparency = 1
EditTitle.Text = "Ajustar Ítem Especial"
EditTitle.Font = Enum.Font.GothamBold
EditTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
EditTitle.TextSize = 14
EditTitle.ZIndex = 16
EditTitle.Parent = EditPanel

local EditCloseBtn = Instance.new("TextButton")
EditCloseBtn.Size = UDim2.new(0, 30, 0, 30)
EditCloseBtn.Position = UDim2.new(1, -35, 0, 5)
EditCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
EditCloseBtn.Text = "X"
EditCloseBtn.Font = Enum.Font.GothamBold
EditCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EditCloseBtn.ZIndex = 16
EditCloseBtn.Parent = EditPanel
local EditCloseCorner = Instance.new("UICorner"); EditCloseCorner.CornerRadius = UDim.new(0, 6); EditCloseCorner.Parent = EditCloseBtn

EditCloseBtn.MouseButton1Click:Connect(function()
    EditPanel.Visible = false
    EqPanel.Visible = true
end)

local ActiveEditItem = nil
local EditOffsetX = 0
local EditOffsetY = 0
local EditOffsetZ = 0
local EditRotX = 0
local EditRotY = 0
local EditRotZ = 0
local EditScale = 1

local function ApplyTransformations()
    if not ActiveEditItem or not ItemAdjustments[ActiveEditItem] then return end
    local data = ItemAdjustments[ActiveEditItem]
    
    data.OffsetX = EditOffsetX
    data.OffsetY = EditOffsetY
    data.OffsetZ = EditOffsetZ
    data.RotX = EditRotX
    data.RotY = EditRotY
    data.RotZ = EditRotZ
    data.Scale = EditScale

    local handle = ActiveEditItem:FindFirstChild("Handle")
    if handle then
        local weld = handle:FindFirstChild("AccessoryWeld")
        if weld and data.OriginalWeldC1 then
            weld.C1 = data.OriginalWeldC1 
                * CFrame.new(-EditOffsetX, -EditOffsetY, -EditOffsetZ) 
                * CFrame.Angles(math.rad(EditRotX), math.rad(EditRotY), math.rad(EditRotZ))
        end
        local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
        if mesh and data.OrigMeshScale then
            mesh.Scale = data.OrigMeshScale * EditScale
        end
    end
end

local PosFrame = Instance.new("Frame")
PosFrame.Size = UDim2.new(1, -20, 0, 40)
PosFrame.Position = UDim2.new(0, 10, 0, 35)
PosFrame.BackgroundTransparency = 1
PosFrame.ZIndex = 16
PosFrame.Parent = EditPanel

local PosLayout = Instance.new("UIListLayout")
PosLayout.FillDirection = Enum.FillDirection.Horizontal
PosLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PosLayout.Padding = UDim.new(0, 10)
PosLayout.Parent = PosFrame

local function CreatePosBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextSize = 18
    btn.ZIndex = 17
    btn.Parent = PosFrame
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreatePosBtn("⬅️", function() EditOffsetX -= 0.15; ApplyTransformations() end)
CreatePosBtn("⬆️", function() EditOffsetZ -= 0.15; ApplyTransformations() end)
CreatePosBtn("⬇️", function() EditOffsetZ += 0.15; ApplyTransformations() end)
CreatePosBtn("➡️", function() EditOffsetX += 0.15; ApplyTransformations() end)

local function CreateSlider(name, yPos, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, yPos - 20)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.ZIndex = 16
    Label.Parent = EditPanel

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0.8, 0, 0, 10)
    Bg.Position = UDim2.new(0.1, 0, 0, yPos)
    Bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Bg.BackgroundTransparency = 0.3
    Bg.ZIndex = 16
    Bg.Parent = EditPanel
    local BgCorner = Instance.new("UICorner"); BgCorner.Parent = Bg

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    Fill.ZIndex = 17
    Fill.Parent = Bg
    local FillCorner = Instance.new("UICorner"); FillCorner.Parent = Fill

    local Knob = Instance.new("TextButton")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new(1, -10, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Text = ""
    Knob.ZIndex = 18
    Knob.Parent = Fill
    local KnobCorner = Instance.new("UICorner"); KnobCorner.CornerRadius = UDim.new(1,0); KnobCorner.Parent = Knob

    local dragging = false
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp(input.Position.X - Bg.AbsolutePosition.X, 0, Bg.AbsoluteSize.X)
            local percentage = relativeX / Bg.AbsoluteSize.X
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            local val = minVal + (maxVal - minVal) * percentage
            callback(val)
        end
    end)
    
    return function(resetVal)
        local pct = math.clamp((resetVal - minVal)/(maxVal - minVal), 0, 1)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
    end
end

local ResetScaleSlider = CreateSlider("Escala (Tamaño)", 95, 0.1, 3, 1, function(val)
    EditScale = val
    ApplyTransformations()
end)

local ResetYSlider = CreateSlider("Posición (Arriba / Abajo)", 135, -3, 3, 0, function(val)
    EditOffsetY = val
    ApplyTransformations()
end)

local JoyLabel = Instance.new("TextLabel")
JoyLabel.Size = UDim2.new(1, 0, 0, 20)
JoyLabel.Position = UDim2.new(0, 0, 0, 155)
JoyLabel.BackgroundTransparency = 1
JoyLabel.Text = "🎮 Joystick Rotación Libre"
JoyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JoyLabel.Font = Enum.Font.Gotham
JoyLabel.ZIndex = 16
JoyLabel.Parent = EditPanel

local JoyBase = Instance.new("Frame")
JoyBase.Size = UDim2.new(0, 80, 0, 80)
JoyBase.Position = UDim2.new(0, 35, 0, 180)
JoyBase.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JoyBase.BackgroundTransparency = 0.3
JoyBase.ZIndex = 16
JoyBase.Parent = EditPanel
local JoyCorner = Instance.new("UICorner"); JoyCorner.CornerRadius = UDim.new(1, 0); JoyCorner.Parent = JoyBase
local JoyStroke = Instance.new("UIStroke"); JoyStroke.Color = Color3.fromRGB(255, 105, 180); JoyStroke.Thickness = 1.5; JoyStroke.Parent = JoyBase

local JoyKnob = Instance.new("TextButton")
JoyKnob.Size = UDim2.new(0, 26, 0, 26)
JoyKnob.Position = UDim2.new(0.5, -13, 0.5, -13)
JoyKnob.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
JoyKnob.Text = ""
JoyKnob.ZIndex = 17
JoyKnob.Parent = JoyBase
local KnobCorner = Instance.new("UICorner"); KnobCorner.CornerRadius = UDim.new(1, 0); KnobCorner.Parent = JoyKnob

local joyDragging = false
JoyKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        joyDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        joyDragging = false
        JoyKnob.Position = UDim2.new(0.5, -13, 0.5, -13)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if joyDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local center = JoyBase.AbsolutePosition + JoyBase.AbsoluteSize / 2
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = mousePos - center
        local maxDist = JoyBase.AbsoluteSize.X / 2
        local clampedDelta = delta
        if delta.Magnitude > maxDist then
            clampedDelta = delta.Unit * maxDist
        end
        
        JoyKnob.Position = UDim2.new(0.5, clampedDelta.X - 13, 0.5, clampedDelta.Y - 13)
        
        EditRotY = EditRotY + (clampedDelta.X / maxDist) * 3
        EditRotX = EditRotX + (clampedDelta.Y / maxDist) * 3
        ApplyTransformations()
    end
end)

local ResetRotBtn = Instance.new("TextButton")
ResetRotBtn.Size = UDim2.new(0, 140, 0, 36)
ResetRotBtn.Position = UDim2.new(0, 145, 0, 202)
ResetRotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResetRotBtn.BackgroundTransparency = 0.2
ResetRotBtn.Text = "🔄 Reset Rotation"
ResetRotBtn.Font = Enum.Font.GothamBold
ResetRotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetRotBtn.TextSize = 12
ResetRotBtn.ZIndex = 16
ResetRotBtn.Parent = EditPanel
local ResetRotCorner = Instance.new("UICorner"); ResetRotCorner.CornerRadius = UDim.new(0, 6); ResetRotCorner.Parent = ResetRotBtn

ResetRotBtn.MouseButton1Click:Connect(function()
    EditRotX = 0
    EditRotY = 0
    EditRotZ = 0
    ApplyTransformations()
end)

local function OpenEditMenuFor(item)
    if not item:IsA("Accessory") then
        NotifyUser("Aviso", "Solo puedes ajustar accesorios (sombreros, mochilas, etc.)")
        return
    end
    local handle = item:FindFirstChild("Handle")
    if not handle then return end
    local weld = handle:FindFirstChild("AccessoryWeld")
    if not weld then return end

    ActiveEditItem = item

    if not ItemAdjustments[item] then
        local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
        ItemAdjustments[item] = {
            OriginalWeldC1 = weld.C1,
            OrigMeshScale = mesh and mesh.Scale or nil,
            OffsetX = 0,
            OffsetY = 0,
            OffsetZ = 0,
            RotX = 0,
            RotY = 0,
            RotZ = 0,
            Scale = 1
        }
    end

    local data = ItemAdjustments[item]
    EditOffsetX = data.OffsetX or 0
    EditOffsetY = data.OffsetY or 0
    EditOffsetZ = data.OffsetZ or 0
    EditRotX = data.RotX or 0
    EditRotY = data.RotY or 0
    EditRotZ = data.RotZ or 0
    EditScale = data.Scale or 1
    
    ResetScaleSlider(EditScale)
    ResetYSlider(EditOffsetY)

    EqPanel.Visible = false
    EditPanel.Visible = true
end

-- ==========================================================
-- REFRESCO DE ELEMENTOS EQUIPADOS
-- ==========================================================
RefreshEquippedItems = function()
    for _, v in ipairs(EqScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local char = LocalPlayer.Character
    if not char then return end
    
    local items = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Tool") or v:GetAttribute("IsAnimation") then
            table.insert(items, v)
        end
    end
    
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") then table.insert(items, v) end
        end
    end
    
    for _, item in ipairs(items) do
        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        frame.ZIndex = 12
        frame.Parent = EqScroll
        local fCorner = Instance.new("UICorner"); fCorner.CornerRadius = UDim.new(0, 8); fCorner.Parent = frame
        
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.ZIndex = 13
        btn.Parent = frame
        
        local eqId = item:GetAttribute("AssetId")
        if (not eqId or eqId == 0) and item:IsA("Accessory") then eqId = item.SourceAssetId end
        
        if eqId and eqId > 0 then
            btn.Image = "rbxthumb://type=Asset&id="..tostring(eqId).."&w=150&h=150"
        else
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 1, -4)
            txt.Position = UDim2.new(0, 2, 0, 2)
            txt.BackgroundTransparency = 1
            txt.Text = item.Name
            txt.TextWrapped = true
            txt.TextScaled = true
            txt.Font = Enum.Font.Gotham
            txt.TextColor3 = Color3.fromRGB(200, 200, 200)
            txt.ZIndex = 14
            txt.Parent = btn
        end
        
        local isPressing = false
        local holdStart = 0

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressing = true
                holdStart = tick()
                
                task.spawn(function()
                    while isPressing do
                        if tick() - holdStart >= 0.5 then
                            isPressing = false
                            OpenEditMenuFor(item)
                            break
                        end
                        task.wait(0.05)
                    end
                end)
            end
        end)

        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isPressing then
                    isPressing = false
                    local timeHeld = tick() - holdStart
                    if timeHeld < 0.5 then
                        if eqId then
                            SavedEquippedIDs[eqId] = nil
                            if PlayingAnimationTracks[eqId] then
                                pcall(function()
                                    PlayingAnimationTracks[eqId]:Stop()
                                    PlayingAnimationTracks[eqId]:Destroy()
                                end)
                                PlayingAnimationTracks[eqId] = nil
                            end
                        end
                        
                        if item:GetAttribute("HidesLegs") then
                            local currentCharacter = LocalPlayer.Character
                            if currentCharacter then
                                for _, part in ipairs(currentCharacter:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        local pName = string.lower(part.Name)
                                        if string.find(pName, "leg") or string.find(pName, "foot") then
                                            part.Transparency = 0
                                        end
                                    end
                                end
                            end
                        end
                        
                        ItemAdjustments[item] = nil
                        item:Destroy()
                        frame:Destroy()
                    end
                end
            end
        end)
    end
end

-- LOGO EYES BUTTON
local EyeButton = Instance.new("ImageButton")
EyeButton.Size = UDim2.new(0, 40, 0, 40)
EyeButton.Position = UDim2.new(0.5, 0, 0, -45)
EyeButton.AnchorPoint = Vector2.new(0.5, 0)
EyeButton.BackgroundTransparency = 1
EyeButton.Image = "rbxassetid://13307406982"
EyeButton.ZIndex = 2
EyeButton.Parent = Container

EyeButton.MouseButton1Click:Connect(function()
    EqPanel.Visible = not EqPanel.Visible
    if EqPanel.Visible then RefreshEquippedItems() end
end)

-- VISUALIZADOR PREVIEW
local ImagePreview = Instance.new("ImageButton")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.AutoButtonColor = true 
ImagePreview.ZIndex = 1
ImagePreview.Parent = Container

ImagePreview.MouseButton1Click:Connect(function()
    local idNum = tonumber(CurrentData.Id)
    if idNum and idNum > 0 then UniversalEquip(idNum, false) end
end)

local UICorner = Instance.new("UICorner"); UICorner.CornerRadius = UDim.new(0, 12); UICorner.Parent = ImagePreview
local UIStroke = Instance.new("UIStroke"); UIStroke.Color = Color3.fromRGB(150, 150, 150); UIStroke.Thickness = 2; UIStroke.Parent = ImagePreview
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
PriceFrame.ZIndex = 1
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
RobuxIcon.ZIndex = 2
RobuxIcon.Parent = PriceFrame

local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(0, 0, 1, 0)
PriceTag.AutomaticSize = Enum.AutomaticSize.X
PriceTag.BackgroundTransparency = 1 
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 18
PriceTag.TextXAlignment = Enum.TextXAlignment.Left
PriceTag.ZIndex = 2
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
-- SISTEMA KITTY CATALOG UI
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then CoreGui.KittyCatalogGui:Destroy() end

local KittyGui = Instance.new("ScreenGui")
KittyGui.Name = "KittyCatalogGui"
KittyGui.Enabled = false 
KittyGui.DisplayOrder = 15
KittyGui.Parent = CoreGui

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "KittyFloatingBtn"
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = DEFAULT_FLOATING_POS
FloatingBtn.Image = "rbxassetid://15538455161"
FloatingBtn.BackgroundTransparency = 1
FloatingBtn.Visible = false 
FloatingBtn.Parent = KittyGui

local KittyMain = Instance.new("Frame")
KittyMain.Size = UDim2.new(0.95, 0, 0.9, 0) 
KittyMain.Position = UDim2.new(0.5, 0, 0.5, 0) 
KittyMain.AnchorPoint = Vector2.new(0.5, 0.5) 
KittyMain.BackgroundColor3 = Color3.fromRGB(255, 182, 193) 
KittyMain.BackgroundTransparency = 0.15 
KittyMain.BorderSizePixel = 0
KittyMain.ClipsDescendants = true
KittyMain.Parent = KittyGui

local isDraggingBtn = false
local dragStartPos = Vector2.new()
local startBtnPos = UDim2.new()
local holdStartTick = 0
local isHoldingBtn = false
local longPressTriggered = false
local DRAG_THRESHOLD = 8

FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingBtn = false
        longPressTriggered = false
        isHoldingBtn = true
        holdStartTick = tick()
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        startBtnPos = FloatingBtn.Position

        task.spawn(function()
            while isHoldingBtn do
                if (tick() - holdStartTick >= 0.5) and not isDraggingBtn then
                    longPressTriggered = true
                    isHoldingBtn = false
                    CharMenu.Visible = not CharMenu.Visible
                    if CharMenu.Visible then RefreshSavedCharactersGrid() end
                    break
                end
                task.wait(0.05)
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isHoldingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentPos - dragStartPos
        if delta.Magnitude > DRAG_THRESHOLD then
            isDraggingBtn = true
        end
        if isDraggingBtn then
            FloatingBtn.Position = UDim2.new(
                startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X,
                startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local wasHolding = isHoldingBtn
        isHoldingBtn = false
        
        if not isDraggingBtn and not longPressTriggered and wasHolding then
            FloatingBtn.Visible = false
            KittyMain.Visible = true
        end
    end
end)

local KittyConstraint = Instance.new("UISizeConstraint")
KittyConstraint.MaxSize = Vector2.new(850, 550) 
KittyConstraint.MinSize = Vector2.new(300, 250)
KittyConstraint.Parent = KittyMain

local KittyCorner = Instance.new("UICorner"); KittyCorner.CornerRadius = UDim.new(0, 16); KittyCorner.Parent = KittyMain
local KittyStroke = Instance.new("UIStroke"); KittyStroke.Color = Color3.fromRGB(255, 105, 180); KittyStroke.Thickness = 3; KittyStroke.Parent = KittyMain

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
local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(1, 0); CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    KittyMain.Visible = false; FloatingBtn.Visible = true
end)

local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.60, 0, 0, 40)
SearchContainer.Position = UDim2.new(0, 10, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SearchContainer.Parent = KittyTop
local SearchContainerCorner = Instance.new("UICorner"); SearchContainerCorner.CornerRadius = UDim.new(0, 8); SearchContainerCorner.Parent = SearchContainer

local KittySearch = Instance.new("TextBox")
KittySearch.Size = UDim2.new(1, -20, 1, 0)
KittySearch.Position = UDim2.new(0, 10, 0, 0)
KittySearch.BackgroundTransparency = 1
KittySearch.PlaceholderText = "🔍 Buscar..."
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
KittySearchBtn.Text = "Buscar"
KittySearchBtn.Font = Enum.Font.GothamBold
KittySearchBtn.TextSize = 14
KittySearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KittySearchBtn.Parent = KittyTop
local SearchBtnCorner = Instance.new("UICorner"); SearchBtnCorner.CornerRadius = UDim.new(0, 8); SearchBtnCorner.Parent = KittySearchBtn

local SidebarContainer = Instance.new("Frame")
SidebarContainer.Size = UDim2.new(0.25, 0, 1, 0)
SidebarContainer.Position = UDim2.new(0, 0, 0, 0)
SidebarContainer.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
SidebarContainer.BackgroundTransparency = 0.5
SidebarContainer.BorderSizePixel = 0
SidebarContainer.ClipsDescendants = true
SidebarContainer.Parent = KittyMain

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 16)
SidebarCorner.Parent = SidebarContainer

local KittySidebar = Instance.new("ScrollingFrame")
KittySidebar.Size = UDim2.new(1, 0, 1, 0)
KittySidebar.BackgroundTransparency = 1
KittySidebar.BorderSizePixel = 0
KittySidebar.ScrollBarThickness = 4
KittySidebar.ClipsDescendants = false
KittySidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
KittySidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
KittySidebar.Parent = SidebarContainer

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
TitleCat.Text = "🎀 Categoría"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 16
TitleCat.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleCat.TextXAlignment = Enum.TextXAlignment.Center
TitleCat.Parent = KittySidebar

local KittyCurrentCategory = 1 

local CategoriesEnglish = {
    {"All", 1},
    {"Accessories", 11}, 
    {"Clothing (All)", 3}, {"Shirts", 3}, {"T-Shirts", 3}, {"Sweaters", 3}, {"Jackets", 3}, {"Pants", 3}, {"Shoes", 3},
    {"Body", 4}, {"Hair", 4}, {"Heads", 4}, {"Faces / Makeup", 4},
    {"Animations", 12}, {"Emotes", 12},
    {"Gear", 5}
}

for i, catData in ipairs(CategoriesEnglish) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(255, 228, 225)
    btn.Text = " " .. catData[1]
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Parent = KittySidebar
    
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        KittyCurrentCategory = catData[2]
        KittySearch.PlaceholderText = "🔍 En " .. catData[1] .. "..."
        
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
        task.wait(0.2)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 228, 225)}):Play()
    end)
end

-- ==========================================================
-- FIX CRÍTICO: BÚSQUEDA CORREGIDA Y PROCESAMIENTO ASÍNCRONO
-- ==========================================================
local function PerformKittySearch()
    local searchString = string.gsub(KittySearch.Text, "^%s*(.-)%s*$", "%1")

    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    task.spawn(function()
        local nextPageCursor = ""
        local maxPages = 2
        local pageCount = 0

        repeat
            pageCount = pageCount + 1
            local cursorParam = nextPageCursor ~= "" and ("&cursor=" .. nextPageCursor) or ""
            local queryParam = searchString ~= "" and ("&keyword=" .. HttpService:UrlEncode(searchString)) or ""
            local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=120" .. queryParam .. cursorParam
            
            local success, response = pcall(function() return game:HttpGet(url) end)
            if not success or not response then
                url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit=120" .. queryParam .. cursorParam
                success, response = pcall(function() return game:HttpGet(url) end)
            end

            if success and response then
                local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(response) end)
                if decodeSuccess and decoded and decoded.data then
                    for _, item in ipairs(decoded.data) do
                        local Card = Instance.new("Frame")
                        Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Card.Parent = KittyResults
                        
                        local CardCorner = Instance.new("UICorner")
                        CardCorner.CornerRadius = UDim.new(0, 10)
                        CardCorner.Parent = Card
                        
                        local CardImg = Instance.new("ImageLabel")
                        CardImg.Size = UDim2.new(1, 0, 0, 100)
                        CardImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                        CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                        CardImg.Parent = Card
                        
                        local ImgCorner = Instance.new("UICorner")
                        ImgCorner.CornerRadius = UDim.new(0, 10)
                        ImgCorner.Parent = CardImg
                        
                        local CardName = Instance.new("TextLabel")
                        CardName.Size = UDim2.new(1, -10, 0, 25)
                        CardName.Position = UDim2.new(0, 5, 0, 105)
                        CardName.BackgroundTransparency = 1
                        CardName.Text = item.name or "Item"
                        CardName.Font = Enum.Font.GothamSemibold
                        CardName.TextSize = 11
                        CardName.TextColor3 = Color3.fromRGB(30, 30, 30)
                        CardName.TextWrapped = true
                        CardName.TextXAlignment = Enum.TextXAlignment.Left
                        CardName.Parent = Card
                        
                        local CardCreator = Instance.new("TextLabel")
                        CardCreator.Size = UDim2.new(1, -10, 0, 15)
                        CardCreator.Position = UDim2.new(0, 5, 0, 135)
                        CardCreator.BackgroundTransparency = 1
                        CardCreator.Text = "De " .. (item.creatorName or "Desconocido")
                        CardCreator.Font = Enum.Font.Gotham
                        CardCreator.TextSize = 10
                        CardCreator.TextColor3 = Color3.fromRGB(100, 100, 100)
                        CardCreator.TextXAlignment = Enum.TextXAlignment.Left
                        CardCreator.Parent = Card
                        
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
                            CurrentData.Name = item.name or "Item"
                            CurrentData.Price = item.price and (tostring(item.price) .. " R$") or "Gratis"
                            CurrentData.ItemType = item.itemType or "Asset"
                            
                            UpdateVisualizer(item.id, item.price or "Gratis")
                        end)
                    end
                    
                    nextPageCursor = decoded.nextPageCursor or nil
                else
                    nextPageCursor = nil
                end
            else
                nextPageCursor = nil
            end
            
            task.wait(0.03)
        until not nextPageCursor or nextPageCursor == "" or pageCount >= maxPages
    end)
end

KittySearch.FocusLost:Connect(function(enterPressed) if enterPressed then PerformKittySearch() end end)
KittySearchBtn.MouseButton1Click:Connect(PerformKittySearch)

-- ==========================================================
-- INTEGRACIÓN RAYFIELD & INTERFAZ
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script LUA", [8] = "Sombrero", [9] = "Place", [10] = "Modelo", 
    [11] = "Camisa", [12] = "Pantalón", [13] = "Decal", [17] = "Cabeza", [18] = "Cara", [19] = "Gear", 
    [24] = "Animación", [27] = "Torso", [28] = "Brazo Der", [29] = "Brazo Izq", 
    [30] = "Pierna Izq", [31] = "Pierna Der", [38] = "Plugin", [41] = "Pelo", 
    [42] = "Acc. Cara", [43] = "Acc. Cuello", [44] = "Acc. Hombro", [45] = "Acc. Frontal", 
    [46] = "Acc. Trasero", [47] = "Acc. Cintura", [64] = "T-Shirt 3D", [65] = "Camisa 3D", 
    [66] = "Pantalón 3D", [67] = "Chaqueta 3D", [68] = "Suéter 3D", [69] = "Zapatos 3D", [70] = "Vestido 3D"
}

local CategoryToNumber = { ["All"] = 1, ["Accessories"] = 11, ["Clothing"] = 3, ["Characters"] = 4, ["Gear"] = 5, ["Animations"] = 12 }

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v25.3 Ultra-Async",
   LoadingTitle = "Cargando optimizaciones Anti-Lag...",
   LoadingSubtitle = "Frame Slicing + Preload Activo",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local SearchResultsCache = {}
local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

Panel:CreateToggle({
   Name = "🎀 Activar Menú Kitty & Persistencia",
   CurrentValue = false,
   Flag = "KittyMenuToggle", 
   Callback = function(Value)
       KittyGui.Enabled = Value
       KeepEquippedOnDeath = Value
       
       if Value then
           KittyMain.Visible = true
           FloatingBtn.Visible = false
           FloatingBtn.Position = DEFAULT_FLOATING_POS
           Rayfield:Notify({Title = "Sistema Unificado", Content = "Menú visual y persistencia de avatar ACTIVADOS.", Duration = 3})
       else
           ResetToDefaultAvatar()
           KittyMain.Visible = false
           FloatingBtn.Visible = false
           FloatingBtn.Position = DEFAULT_FLOATING_POS
           EqPanel.Visible = false
           EditPanel.Visible = false
           CharMenu.Visible = false
           Rayfield:Notify({Title = "Restaurado", Content = "Avatar desequipado y reseteado al estado original (Muerte Real).", Duration = 3.5})
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
   Callback = function(Option) SearchCategory = type(Option) == "table" and Option[1] or Option end,
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
           CurrentData.Id = tostring(item.Id); CurrentData.Name = item.Name; CurrentData.Price = item.Price
           CurrentData.Category = item.Category; CurrentData.ItemType = item.ItemType
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
       
       task.spawn(function()
           local apiCategory = CategoryToNumber[SearchCategory] or 1
           local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
           local success, response = pcall(function() return game:HttpGet(url) end)
           if not success or not response then
               url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
               success, response = pcall(function() return game:HttpGet(url) end)
           end

           if success and response then
               local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(response) end)
               if decodeSuccess and decoded and decoded.data then
                   local newOptions = {}; SearchResultsCache = {} 
                   for _, item in ipairs(decoded.data) do
                       local priceStr = item.price or 0
                       local catName = AssetTypeNames[item.assetType] or item.itemType or "Item"
                       local listName = string.format("%s - [%s]", item.name or "Item", catName)
                       table.insert(newOptions, listName)
                       SearchResultsCache[listName] = { Id = item.id, Name = item.name or "Item", Price = priceStr, Category = catName, ItemType = item.itemType or "Asset" }
                   end
                   if #newOptions > 0 then
                       SpinnerDropdown:Refresh(newOptions, true)
                       Rayfield:Notify({Title = "Éxito", Content = "Resultados cargados.", Duration = 3})
                   end
               end
           end
       end)
   end,
})

Panel:CreateSection("Búsqueda Directa por ID")

local DirectIdInput = Panel:CreateInput({
   Name = "Ingresar ID Directa",
   PlaceholderText = "Ej: 144275038...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if not numericId then return end
       task.spawn(function()
           local success, info = pcall(function() return MarketplaceService:GetProductInfo(numericId) end)
           if success and info then
               CurrentData.Id = tostring(numericId); CurrentData.Name = info.Name
               CurrentData.Price = info.PriceInRobux and (tostring(info.PriceInRobux) .. " R$") or "Gratis / Off-Sale"
               CurrentData.Category = AssetTypeNames[info.AssetTypeId] or "Desconocido"
               CurrentData.ItemType = "Asset"
               UpdateVisualizer(CurrentData.Id, CurrentData.Price)
               Rayfield:Notify({Title = "Item Encontrado", Content = CurrentData.Name, Duration = 2})
           end
       end)
   end,
})

Panel:CreateSection("🧪 Aplicar / Probar en Personaje")

Panel:CreateButton({
   Name = "⚡ Equipar/Probar Selección",
   Callback = function()
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end
       UniversalEquip(assetId, false)
   end,
})

Panel:CreateButton({
   Name = "🔄 Resetear Avatar a Default Manual",
   Callback = function()
       ResetToDefaultAvatar()
       FloatingBtn.Position = DEFAULT_FLOATING_POS
       Rayfield:Notify({Title = "Personaje Restaurado", Content = "Se cargó el avatar oficial de Roblox.", Duration = 2.5})
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador Clásico",
   Callback = function() Container.Visible = not Container.Visible end,
})

Panel:CreateSection("⚙️ Rendimiento")

Panel:CreateButton({
   Name = "🧹 Limpiar Caché y Liberar RAM",
   Callback = function()
       BannerSystem.ClearCache()
       collectgarbage("collect")
       Rayfield:Notify({Title = "RAM Purgada", Content = "Caché de pancartas e historial liberados.", Duration = 2.5})
   end,
})
