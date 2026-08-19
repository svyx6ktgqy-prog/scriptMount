-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (v25.6 ANTI-FREEZE & ULTRA-ASYNC)
-- Gestión Eficiente de Memoria + Frame-Slicing + Carga Asíncrona de I/O
-- + Filtro de Precios + Copiado de ID a Portapapeles (iOS Delta)
-- + EDIT PARTS (Eliminar partes del cuerpo guardables) [FIX ZINDEX UI]
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido", ItemType = "Asset" }
local KeepEquippedOnDeath = false 
local SavedEquippedIDs = {}
local SavedBodyModifiers = {} 
local PlayingAnimationTracks = {}
local ItemAdjustments = {}
local EqPanel, RefreshEquippedItems 

local CHARS_FILE = "CHARACTERS.json"
local DEFAULT_FLOATING_POS = UDim2.new(1, -80, 0.5, -30)

-- ==========================================================
-- ESTRUCTURAS DE CUERPO Y FUNCIONES DE OCULTACIÓN (EDIT PARTS)
-- ==========================================================
local BodyPartGroups = {
    Head = {"Head"},
    Torso = {"Torso", "UpperTorso", "LowerTorso"},
    LeftArm = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
    RightArm = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
    LeftLeg = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
    RightLeg = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

local function SetBodyPartHidden(targetChar, groupName, isHidden)
    if not targetChar then return end
    targetChar:SetAttribute("Hide_" .. groupName, isHidden)
    
    if targetChar == LocalPlayer.Character then
        SavedBodyModifiers[groupName] = isHidden
    end
    
    for _, p in ipairs(targetChar:GetDescendants()) do
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

-- Escuchar finalización de compra
MarketplaceService.PromptPurchaseFinished:Connect(function(player, assetId, isPurchased)
    if isPurchased then
        print("Compró el asset:", assetId)
    end
end)

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
                if bannerData.Id then BannerSystem.Cache[bannerData.Id] = bannerObj end
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
    pcall(function() CachedDefaultDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId) end)
    local assetsToPreload = {"rbxassetid://13307406982", "rbxassetid://15538455161", "rbxassetid://11560341824"}
    pcall(function() ContentProvider:PreloadAsync(assetsToPreload) end)
end)

local function NotifyUser(title, text)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = 4; }) end)
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
            OffsetX = adj.OffsetX or 0, OffsetY = adj.OffsetY or 0, OffsetZ = adj.OffsetZ or 0,
            RotX = adj.RotX or 0, RotY = adj.RotY or 0, RotZ = adj.RotZ or 0,
            Scale = adj.Scale or 1
        }
    end

    local data = ItemAdjustments[itemInstance]
    data.OffsetX = adj.OffsetX or 0; data.OffsetY = adj.OffsetY or 0; data.OffsetZ = adj.OffsetZ or 0
    data.RotX = adj.RotX or 0; data.RotY = adj.RotY or 0; data.RotZ = adj.RotZ or 0
    data.Scale = adj.Scale or 1

    weld.C1 = data.OriginalWeldC1 
        * CFrame.new(-data.OffsetX, -data.OffsetY, -data.OffsetZ) 
        * CFrame.Angles(math.rad(data.RotX), math.rad(data.RotY), math.rad(data.RotZ))

    local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
    if mesh and data.OrigMeshScale then mesh.Scale = data.OrigMeshScale * data.Scale end
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

    if mesh then mesh.Scale = mesh.Scale * (adj.Scale or 1) end
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
            local success, result = pcall(function() return HttpService:JSONDecode(readfile(CHARS_FILE)) end)
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
        if writefile then pcall(function() writefile(CHARS_FILE, HttpService:JSONEncode(data)) end) end
    end)
end

local function IsAlreadyEquipped(assetId)
    local char = LocalPlayer.Character
    if not char or not assetId then return false end
    local numericId = tonumber(assetId)
    if not numericId then return false end

    for _, v in ipairs(char:GetDescendants()) do
        if v:GetAttribute("AssetId") == numericId then return true end
    end
    return false
end

-- ==========================================================
-- RESTAURACIÓN DE AVATAR Y MANEJO DE HILOS
-- ==========================================================
local function ResetToDefaultAvatar()
    SavedEquippedIDs = {}
    ItemAdjustments = {}
    
    local Char = LocalPlayer.Character
    if not Char then return end

    -- Resetear Body Modifiers (Partes ocultas)
    SavedBodyModifiers = {}
    for groupName, _ in pairs(BodyPartGroups) do
        if Char:GetAttribute("Hide_" .. groupName) then
            SetBodyPartHidden(Char, groupName, false)
        end
    end
    
    for id, track in pairs(PlayingAnimationTracks) do
        pcall(function() track:Stop(); track:Destroy() end)
    end
    PlayingAnimationTracks = {}

    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return end

    for _, part in ipairs(Char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
            part.Transparency = 0 
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:GetAttribute("AssetId") then v:Destroy() end
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

    if EqPanel and RefreshEquippedItems then RefreshEquippedItems() end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent:IsA("Accessory") then v.LocalTransparencyModifier = 0 end
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
        local getSuccess, _ = pcall(function() objects = game:GetObjects("rbxassetid://" .. tostring(numericId)) end)

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
                for _, subItem in ipairs(item:GetChildren()) do ProcessItem(subItem) end
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
            if EqPanel and EqPanel.Visible and RefreshEquippedItems then RefreshEquippedItems() end
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not KeepEquippedOnDeath then 
        SavedEquippedIDs = {}
        SavedBodyModifiers = {}
        return 
    end
    newChar:WaitForChild("Humanoid", 10)
    task.wait(1.0)
    
    task.spawn(function()
        -- Restaurar Edit Parts (Body Modifiers)
        for group, isHidden in pairs(SavedBodyModifiers) do
            if isHidden then
                SetBodyPartHidden(newChar, group, true)
            end
        end

        -- Restaurar Equipamiento
        for id, active in pairs(SavedEquippedIDs) do
            if active and KeepEquippedOnDeath then
                UniversalEquip(id, true)
                task.wait(0.06)
            end
        end
    end)
end)

-- ==========================================================
-- UI DE VISUALIZACIÓN Y MENÚS (FORZANDO SIBLING Y ZINDEX ALTO)
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then CoreGui.QuirurgicoVisualizer:Destroy() end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.DisplayOrder = 10
VisualizerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- FUNDAMENTAL PARA EXECUTORS
VisualizerGui.Parent = CoreGui

-- ==========================================================
-- PANEL "EDIT PARTS" (RECONSTRUIDO CON ZINDEX FIJOS Y AUTOSCROLL)
-- ==========================================================
local PartsPanel = Instance.new("Frame")
PartsPanel.Size = UDim2.new(0, 320, 0, 340)
PartsPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
PartsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
PartsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PartsPanel.ClipsDescendants = true
PartsPanel.Visible = false
PartsPanel.ZIndex = 20
PartsPanel.Parent = VisualizerGui

local PartsCorner = Instance.new("UICorner"); PartsCorner.CornerRadius = UDim.new(0, 12); PartsCorner.Parent = PartsPanel
local PartsStroke = Instance.new("UIStroke"); PartsStroke.Color = Color3.fromRGB(180, 50, 255); PartsStroke.Thickness = 2; PartsStroke.Parent = PartsPanel

local PartsTitle = Instance.new("TextLabel")
PartsTitle.Size = UDim2.new(1, 0, 0, 40)
PartsTitle.BackgroundTransparency = 1
PartsTitle.Text = "🔧 Modificar Cuerpo Base"
PartsTitle.Font = Enum.Font.GothamBold
PartsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PartsTitle.TextSize = 14
PartsTitle.ZIndex = 21
PartsTitle.Parent = PartsPanel

local PartsCloseBtn = Instance.new("TextButton")
PartsCloseBtn.Size = UDim2.new(0, 30, 0, 30)
PartsCloseBtn.Position = UDim2.new(1, -35, 0, 5)
PartsCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
PartsCloseBtn.Text = "X"
PartsCloseBtn.Font = Enum.Font.GothamBold
PartsCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PartsCloseBtn.ZIndex = 21
PartsCloseBtn.Parent = PartsPanel
local PartsCloseCorner = Instance.new("UICorner"); PartsCloseCorner.CornerRadius = UDim.new(0, 6); PartsCloseCorner.Parent = PartsCloseBtn
PartsCloseBtn.MouseButton1Click:Connect(function() 
    PartsPanel.Visible = false
    EqPanel.Visible = true 
end)

local PartsScroll = Instance.new("ScrollingFrame")
PartsScroll.Size = UDim2.new(1, -20, 1, -50)
PartsScroll.Position = UDim2.new(0, 10, 0, 40)
PartsScroll.BackgroundTransparency = 1
PartsScroll.ScrollBarThickness = 5
PartsScroll.ClipsDescendants = true
PartsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PartsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PartsScroll.ZIndex = 21
PartsScroll.Parent = PartsPanel

local PartsLayout = Instance.new("UIListLayout")
PartsLayout.SortOrder = Enum.SortOrder.LayoutOrder
PartsLayout.Padding = UDim.new(0, 8)
PartsLayout.Parent = PartsScroll

local function CreatePartToggle(devName, groupName)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Row.ZIndex = 25
    Row.Parent = PartsScroll
    local RowCorner = Instance.new("UICorner"); RowCorner.CornerRadius = UDim.new(0, 6); RowCorner.Parent = Row
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = devName
    Label.Font = Enum.Font.GothamSemibold
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 26
    Label.Parent = Row

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 24, 0, 24)
    Checkbox.Position = UDim2.new(1, -34, 0.5, -12)
    Checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Checkbox.Text = ""
    Checkbox.Font = Enum.Font.GothamBold
    Checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkbox.TextSize = 14
    Checkbox.ZIndex = 26
    Checkbox.Parent = Row
    local CheckCorner = Instance.new("UICorner"); CheckCorner.CornerRadius = UDim.new(0, 4); CheckCorner.Parent = Checkbox
    local CheckStroke = Instance.new("UIStroke"); CheckStroke.Color = Color3.fromRGB(150, 150, 150); CheckStroke.Thickness = 1.5; CheckStroke.Parent = Checkbox
    
    local function UpdateVisuals(isChecked)
        Checkbox.Text = isChecked and "✔" or ""
        Checkbox.BackgroundColor3 = isChecked and Color3.fromRGB(180, 50, 255) or Color3.fromRGB(30, 30, 30)
    end

    -- Inicializar visuales inmediatamente para evitar que aparezcan en blanco
    local initChar = LocalPlayer.Character
    local initialCheck = initChar and initChar:GetAttribute("Hide_" .. groupName) or false
    UpdateVisuals(initialCheck)

    Checkbox.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local currentState = char:GetAttribute("Hide_" .. groupName) or false
        local newState = not currentState
        SetBodyPartHidden(char, groupName, newState)
        UpdateVisuals(newState)
    end)
    
    PartsPanel:GetPropertyChangedSignal("Visible"):Connect(function()
        if PartsPanel.Visible then
            local char = LocalPlayer.Character
            local isChecked = char and char:GetAttribute("Hide_" .. groupName) or false
            UpdateVisuals(isChecked)
        end
    end)
end

CreatePartToggle("Remove Head", "Head")
CreatePartToggle("Remove Torso", "Torso")
CreatePartToggle("Remove Left Arm", "LeftArm")
CreatePartToggle("Remove Right Arm", "RightArm")
CreatePartToggle("Remove Left Leg", "LeftLeg")
CreatePartToggle("Remove Right Leg", "RightLeg")

-- ==========================================================
-- MENÚ DE ALERTA DE OBTENCIÓN (CUSTOM + NATIVO DEFAULT)
-- ==========================================================
local PurchaseAlertMenu = Instance.new("Frame")
PurchaseAlertMenu.Size = UDim2.new(0, 260, 0, 140)
PurchaseAlertMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
PurchaseAlertMenu.AnchorPoint = Vector2.new(0.5, 0.5)
PurchaseAlertMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PurchaseAlertMenu.Visible = false
PurchaseAlertMenu.ZIndex = 100
PurchaseAlertMenu.Parent = VisualizerGui

local AlertCorner = Instance.new("UICorner"); AlertCorner.CornerRadius = UDim.new(0, 12); AlertCorner.Parent = PurchaseAlertMenu
local AlertStroke = Instance.new("UIStroke"); AlertStroke.Color = Color3.fromRGB(255, 105, 180); AlertStroke.Thickness = 2; AlertStroke.Parent = PurchaseAlertMenu

local AlertTitle = Instance.new("TextLabel")
AlertTitle.Size = UDim2.new(1, 0, 0, 35)
AlertTitle.BackgroundTransparency = 1
AlertTitle.Text = "⚠️ ¿Confirmar Obtención?"
AlertTitle.Font = Enum.Font.GothamBold
AlertTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AlertTitle.TextSize = 14
AlertTitle.ZIndex = 101
AlertTitle.Parent = PurchaseAlertMenu

local AlertDesc = Instance.new("TextLabel")
AlertDesc.Size = UDim2.new(1, -20, 0, 45)
AlertDesc.Position = UDim2.new(0, 10, 0, 40)
AlertDesc.BackgroundTransparency = 1
AlertDesc.Text = ""
AlertDesc.Font = Enum.Font.Gotham
AlertDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
AlertDesc.TextWrapped = true
AlertDesc.TextSize = 12
AlertDesc.ZIndex = 101
AlertDesc.Parent = PurchaseAlertMenu

local BtnAlertYes = Instance.new("TextButton")
BtnAlertYes.Size = UDim2.new(0.4, 0, 0, 32)
BtnAlertYes.Position = UDim2.new(0.07, 0, 1, -42)
BtnAlertYes.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
BtnAlertYes.Text = "✅ Comprar"
BtnAlertYes.Font = Enum.Font.GothamBold
BtnAlertYes.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAlertYes.ZIndex = 101
BtnAlertYes.Parent = PurchaseAlertMenu
local AlertYesCorner = Instance.new("UICorner"); AlertYesCorner.CornerRadius = UDim.new(0, 6); AlertYesCorner.Parent = BtnAlertYes

local BtnAlertNo = Instance.new("TextButton")
BtnAlertNo.Size = UDim2.new(0.4, 0, 0, 32)
BtnAlertNo.Position = UDim2.new(0.53, 0, 1, -42)
BtnAlertNo.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
BtnAlertNo.Text = "❌ Cancelar"
BtnAlertNo.Font = Enum.Font.GothamBold
BtnAlertNo.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAlertNo.ZIndex = 101
BtnAlertNo.Parent = PurchaseAlertMenu
local AlertNoCorner = Instance.new("UICorner"); AlertNoCorner.CornerRadius = UDim.new(0, 6); AlertNoCorner.Parent = BtnAlertNo

BtnAlertNo.MouseButton1Click:Connect(function()
    PurchaseAlertMenu.Visible = false
end)

BtnAlertYes.MouseButton1Click:Connect(function()
    PurchaseAlertMenu.Visible = false
    local assetId = tonumber(CurrentData.Id)
    if assetId and assetId > 0 then
        pcall(function()
            MarketplaceService:PromptPurchase(LocalPlayer, assetId)
        end)
        if NotifyUser then
            NotifyUser("Obtención", "Abriendo menú de compra nativo...")
        end
    end
end)

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
EqTitle.TextSize = 12
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

local EditPartsBtn = Instance.new("TextButton")
EditPartsBtn.Size = UDim2.new(0, 85, 0, 30)
EditPartsBtn.Position = UDim2.new(1, -125, 0, 5)
EditPartsBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 255)
EditPartsBtn.Text = "🔧 Edit Parts"
EditPartsBtn.Font = Enum.Font.GothamBold
EditPartsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EditPartsBtn.TextSize = 11
EditPartsBtn.ZIndex = 11
EditPartsBtn.Parent = EqPanel
local EditPartsCorner = Instance.new("UICorner"); EditPartsCorner.CornerRadius = UDim.new(0, 6); EditPartsCorner.Parent = EditPartsBtn
EditPartsBtn.MouseButton1Click:Connect(function() 
    EqPanel.Visible = false
    PartsPanel.Visible = true
end)

-- ==========================================================
-- BOTÓN Y MENÚ DE HERRAMIENTAS AVANZADAS (EXTRAS) INYECTADOS AQUI
-- ==========================================================
local ExtraToolsBtn = Instance.new("TextButton")
ExtraToolsBtn.Size = UDim2.new(0, 85, 0, 30)
ExtraToolsBtn.Position = UDim2.new(1, -215, 0, 5) -- Al lado de Edit Parts
ExtraToolsBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ExtraToolsBtn.Text = "⚡ Extras"
ExtraToolsBtn.Font = Enum.Font.GothamBold
ExtraToolsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtraToolsBtn.TextSize = 11
ExtraToolsBtn.ZIndex = 11
ExtraToolsBtn.Parent = EqPanel
local ExtraToolsCorner = Instance.new("UICorner"); ExtraToolsCorner.CornerRadius = UDim.new(0, 6); ExtraToolsCorner.Parent = ExtraToolsBtn

local ExtraPanel = Instance.new("Frame")
ExtraPanel.Size = UDim2.new(0, 320, 0, 360)
ExtraPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
ExtraPanel.AnchorPoint = Vector2.new(0.5, 0.5)
ExtraPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ExtraPanel.ClipsDescendants = true
ExtraPanel.Visible = false
ExtraPanel.ZIndex = 40
ExtraPanel.Parent = VisualizerGui

local ExtraPanelCorner = Instance.new("UICorner"); ExtraPanelCorner.CornerRadius = UDim.new(0, 12); ExtraPanelCorner.Parent = ExtraPanel
local ExtraPanelStroke = Instance.new("UIStroke"); ExtraPanelStroke.Color = Color3.fromRGB(0, 150, 255); ExtraPanelStroke.Thickness = 2; ExtraPanelStroke.Parent = ExtraPanel

local ExtraTitle = Instance.new("TextLabel")
ExtraTitle.Size = UDim2.new(1, 0, 0, 40)
ExtraTitle.BackgroundTransparency = 1
ExtraTitle.Text = "⚡ Herramientas Avanzadas"
ExtraTitle.Font = Enum.Font.GothamBold
ExtraTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtraTitle.TextSize = 14
ExtraTitle.ZIndex = 41
ExtraTitle.Parent = ExtraPanel

local ExtraCloseBtn = Instance.new("TextButton")
ExtraCloseBtn.Size = UDim2.new(0, 30, 0, 30)
ExtraCloseBtn.Position = UDim2.new(1, -35, 0, 5)
ExtraCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ExtraCloseBtn.Text = "X"
ExtraCloseBtn.Font = Enum.Font.GothamBold
ExtraCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExtraCloseBtn.ZIndex = 41
ExtraCloseBtn.Parent = ExtraPanel
local ExtraCloseCorner = Instance.new("UICorner"); ExtraCloseCorner.CornerRadius = UDim.new(0, 6); ExtraCloseCorner.Parent = ExtraCloseBtn

ExtraCloseBtn.MouseButton1Click:Connect(function() 
    ExtraPanel.Visible = false
    EqPanel.Visible = true 
end)

ExtraToolsBtn.MouseButton1Click:Connect(function()
    EqPanel.Visible = false
    ExtraPanel.Visible = true
end)

-- 1. Limpiador Avanzado de RAM / Cache
local RamCleanBtn = Instance.new("TextButton")
RamCleanBtn.Size = UDim2.new(0.9, 0, 0, 40)
RamCleanBtn.Position = UDim2.new(0.05, 0, 0, 50)
RamCleanBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
RamCleanBtn.Text = "🧹 Limpiar RAM y Optimizar Delta (iOS)"
RamCleanBtn.Font = Enum.Font.GothamBold
RamCleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RamCleanBtn.TextSize = 12
RamCleanBtn.ZIndex = 41
RamCleanBtn.Parent = ExtraPanel
local RamCleanCorner = Instance.new("UICorner"); RamCleanCorner.CornerRadius = UDim.new(0, 8); RamCleanCorner.Parent = RamCleanBtn

RamCleanBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if collectgarbage then collectgarbage("collect") end
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        if NotifyUser then NotifyUser("Optimización Lista", "Se liberó RAM, texturas y partículas sin callbacks de error.") end
    end)
end)

-- 2. Mostrar / Ocultar Visualizador
local visHidden = false
local ToggleVisBtn = Instance.new("TextButton")
ToggleVisBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleVisBtn.Position = UDim2.new(0.05, 0, 0, 100)
ToggleVisBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
ToggleVisBtn.Text = "👁️ Ocultar Visualizador de Ítems"
ToggleVisBtn.Font = Enum.Font.GothamBold
ToggleVisBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleVisBtn.TextSize = 12
ToggleVisBtn.ZIndex = 41
ToggleVisBtn.Parent = ExtraPanel
local ToggleVisCorner = Instance.new("UICorner"); ToggleVisCorner.CornerRadius = UDim.new(0, 8); ToggleVisCorner.Parent = ToggleVisBtn

ToggleVisBtn.MouseButton1Click:Connect(function()
    visHidden = not visHidden
    if Container then Container.Visible = not visHidden end
    ToggleVisBtn.Text = visHidden and "👁️ Mostrar Visualizador de Ítems" or "👁️ Ocultar Visualizador de Ítems"
    if NotifyUser then NotifyUser("Visualizador", visHidden and "El panel visualizador está oculto" or "El panel visualizador está visible") end
end)

-- 3. Orientación de Pantalla
local OrientLabel = Instance.new("TextLabel")
OrientLabel.Size = UDim2.new(0.9, 0, 0, 20)
OrientLabel.Position = UDim2.new(0.05, 0, 0, 155)
OrientLabel.BackgroundTransparency = 1
OrientLabel.Text = "Orientación de Pantalla:"
OrientLabel.Font = Enum.Font.GothamSemibold
OrientLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
OrientLabel.TextSize = 12
OrientLabel.TextXAlignment = Enum.TextXAlignment.Left
OrientLabel.ZIndex = 41
OrientLabel.Parent = ExtraPanel

local OrientVertBtn = Instance.new("TextButton")
OrientVertBtn.Size = UDim2.new(0.42, 0, 0, 35)
OrientVertBtn.Position = UDim2.new(0.05, 0, 0, 180)
OrientVertBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
OrientVertBtn.Text = "📱 Vertical"
OrientVertBtn.Font = Enum.Font.GothamBold
OrientVertBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OrientVertBtn.TextSize = 12
OrientVertBtn.ZIndex = 41
OrientVertBtn.Parent = ExtraPanel
local OrientVertCorner = Instance.new("UICorner"); OrientVertCorner.CornerRadius = UDim.new(0, 6); OrientVertCorner.Parent = OrientVertBtn

local OrientHorizBtn = Instance.new("TextButton")
OrientHorizBtn.Size = UDim2.new(0.42, 0, 0, 35)
OrientHorizBtn.Position = UDim2.new(0.53, 0, 0, 180)
OrientHorizBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
OrientHorizBtn.Text = "📟 Horizontal"
OrientHorizBtn.Font = Enum.Font.GothamBold
OrientHorizBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OrientHorizBtn.TextSize = 12
OrientHorizBtn.ZIndex = 41
OrientHorizBtn.Parent = ExtraPanel
local OrientHorizCorner = Instance.new("UICorner"); OrientHorizCorner.CornerRadius = UDim.new(0, 6); OrientHorizCorner.Parent = OrientHorizBtn

local function SetScreenOrient(orientEnum, name)
    pcall(function()
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pGui then
            pGui.ScreenOrientation = orientEnum
        end
        if NotifyUser then NotifyUser("Orientación", "Pantalla ajustada a modo " .. name) end
    end)
end
OrientVertBtn.MouseButton1Click:Connect(function() SetScreenOrient(Enum.ScreenOrientation.Portrait, "Vertical") end)
OrientHorizBtn.MouseButton1Click:Connect(function() SetScreenOrient(Enum.ScreenOrientation.LandscapeRight, "Horizontal") end)

-- 4. Búsqueda por ID Personalizada
local SearchIdLabel = Instance.new("TextLabel")
SearchIdLabel.Size = UDim2.new(0.9, 0, 0, 20)
SearchIdLabel.Position = UDim2.new(0.05, 0, 0, 230)
SearchIdLabel.BackgroundTransparency = 1
SearchIdLabel.Text = "Buscar Accesorio / Item por ID:"
SearchIdLabel.Font = Enum.Font.GothamSemibold
SearchIdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchIdLabel.TextSize = 12
SearchIdLabel.TextXAlignment = Enum.TextXAlignment.Left
SearchIdLabel.ZIndex = 41
SearchIdLabel.Parent = ExtraPanel

local SearchIdInput = Instance.new("TextBox")
SearchIdInput.Size = UDim2.new(0.65, 0, 0, 35)
SearchIdInput.Position = UDim2.new(0.05, 0, 0, 255)
SearchIdInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchIdInput.PlaceholderText = "Escribe ID aquí..."
SearchIdInput.Text = ""
SearchIdInput.Font = Enum.Font.GothamMedium
SearchIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchIdInput.TextSize = 12
SearchIdInput.ZIndex = 41
SearchIdInput.Parent = ExtraPanel
local SearchIdCorner = Instance.new("UICorner"); SearchIdCorner.CornerRadius = UDim.new(0, 6); SearchIdCorner.Parent = SearchIdInput

local SearchIdActionBtn = Instance.new("TextButton")
SearchIdActionBtn.Size = UDim2.new(0.22, 0, 0, 35)
SearchIdActionBtn.Position = UDim2.new(0.73, 0, 0, 255)
SearchIdActionBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
SearchIdActionBtn.Text = "🔍"
SearchIdActionBtn.Font = Enum.Font.GothamBold
SearchIdActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchIdActionBtn.TextSize = 16
SearchIdActionBtn.ZIndex = 41
SearchIdActionBtn.Parent = ExtraPanel
local SearchIdActionCorner = Instance.new("UICorner"); SearchIdActionCorner.CornerRadius = UDim.new(0, 6); SearchIdActionCorner.Parent = SearchIdActionBtn

SearchIdActionBtn.MouseButton1Click:Connect(function()
    local inputId = tonumber(SearchIdInput.Text)
    if inputId and inputId > 0 then
        pcall(function()
            local info = MarketplaceService:GetProductInfo(inputId)
            CurrentData.Id = tostring(inputId)
            CurrentData.Name = info.Name
            CurrentData.Price = info.PriceInRobux and (tostring(info.PriceInRobux) .. " R$") or "Gratis"
            CurrentData.ItemType = "Asset"
            if UpdateVisualizer then 
                UpdateVisualizer(inputId, CurrentData.Price)
            end
            if not visHidden then
                Container.Visible = true 
            end
            if NotifyUser then NotifyUser("Buscador ID", "Item cargado en el visualizador con éxito.") end
        end)
    else
        if NotifyUser then NotifyUser("Error ID", "Por favor ingresa una ID numérica válida.") end
    end
end)
-- ==========================================================
-- FIN INTEGRACIONES EXTRA (Continúa código original EqScroll)
-- ==========================================================

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
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Transparency = 0 
                        end
                    end

                    local hum = dummy:FindFirstChildOfClass("Humanoid")
                    local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
                    
                    for _, part in ipairs(dummy:GetDescendants()) do
                        if part:IsA("BasePart") then part.Anchored = false end
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
                                            targetAttach = att; break
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
                                    if item.AccessoryType == Enum.AccessoryType.Pants or item.AccessoryType == Enum.AccessoryType.Shorts then isPant = true end
                                end)
                                if not isPant and accAttach and (accAttach.Name == "WaistCenterAttachment" or string.find(string.lower(item.Name), "pant")) then isPant = true end
                                if isPant then
                                    for _, part in ipairs(dummy:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            local pName = string.lower(part.Name)
                                            if string.find(pName, "leg") or string.find(pName, "foot") then part.Transparency = 1 end
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
                                if currentFace then currentFace.Texture = item.Texture
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
                            for _, sub in ipairs(item:GetChildren()) do ProcessDummyItem(sub) end
                        else
                            local cloneItem = item:Clone()
                            cloneItem.Parent = dummy
                            return cloneItem
                        end
                    end

                    for _, entry in ipairs(itemEntries) do
                        if type(entry) == "table" and entry.isBodyModifier then
                            for groupName, isHidden in pairs(entry.hidden) do
                                SetBodyPartHidden(dummy, groupName, isHidden)
                            end
                        else
                            local id = type(entry) == "table" and entry.id or entry
                            local adj = type(entry) == "table" and entry.adj or nil

                            local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
                            local processedAsObject = false

                            if success and objects and #objects > 0 then
                                for _, obj in ipairs(objects) do
                                    processedAsObject = true
                                    local dummyItem = ProcessDummyItem(obj)
                                    if dummyItem and adj then ApplyAdjustmentToDummy(dummyItem, adj) end
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
                            if type(entry) == "table" and entry.isBodyModifier then
                                for groupName, isHidden in pairs(entry.hidden) do
                                    SetBodyPartHidden(LocalPlayer.Character, groupName, isHidden)
                                end
                            else
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
    if name == "" or name:match("^%s*$") then NotifyUser("Atención", "Ingresa un nombre válido."); return end

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
                        entry.adj = { OffsetX = adj.OffsetX, OffsetY = adj.OffsetY, OffsetZ = adj.OffsetZ, RotX = adj.RotX, RotY = adj.RotY, RotZ = adj.RotZ, Scale = adj.Scale }
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
                if entryId == id then alreadyAdded = true; break end
            end
            if not alreadyAdded then table.insert(itemsToSave, { id = id }) end
        end
    end
    
    -- Agregar configuraciones de Edit Parts (Body Modifiers)
    local hiddenGroups = {}
    local hasHiddenParts = false
    for group, _ in pairs(BodyPartGroups) do
        if SavedBodyModifiers[group] then
            hiddenGroups[group] = true
            hasHiddenParts = true
        end
    end
    if hasHiddenParts then
        table.insert(itemsToSave, { isBodyModifier = true, hidden = hiddenGroups })
    end

    if #itemsToSave == 0 then NotifyUser("Atención", "No tienes ítems equipados ni cuerpo modificado."); return end

    LoadSavedCharactersDataAsync(function(data)
        data[name] = itemsToSave
        SaveCharactersData(data)
        NameInput.Text = ""
        RefreshSavedCharactersGrid()
        NotifyUser("Guardado Exitoso", "Personaje '" .. name .. "' guardado con sus ajustes.")
    end)
end)

-- ==========================================================
-- EDIT PANEL (AJUSTE ESPECIAL DE ACCESORIOS)
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

EditCloseBtn.MouseButton1Click:Connect(function() EditPanel.Visible = false; EqPanel.Visible = true end)

local ActiveEditItem = nil
local EditOffsetX = 0; local EditOffsetY = 0; local EditOffsetZ = 0
local EditRotX = 0; local EditRotY = 0; local EditRotZ = 0
local EditScale = 1

local function ApplyTransformations()
    if not ActiveEditItem or not ItemAdjustments[ActiveEditItem] then return end
    local data = ItemAdjustments[ActiveEditItem]
    
    data.OffsetX = EditOffsetX; data.OffsetY = EditOffsetY; data.OffsetZ = EditOffsetZ
    data.RotX = EditRotX; data.RotY = EditRotY; data.RotZ = EditRotZ
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
        if mesh and data.OrigMeshScale then mesh.Scale = data.OrigMeshScale * EditScale end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

local ResetScaleSlider = CreateSlider("Escala (Tamaño)", 95, 0.1, 3, 1, function(val) EditScale = val; ApplyTransformations() end)
local ResetYSlider = CreateSlider("Posición (Arriba / Abajo)", 135, -3, 3, 0, function(val) EditOffsetY = val; ApplyTransformations() end)

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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then joyDragging = true end
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
        if delta.Magnitude > maxDist then clampedDelta = delta.Unit * maxDist end
        
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
    EditRotX = 0; EditRotY = 0; EditRotZ = 0; ApplyTransformations()
end)

local function OpenEditMenuFor(item)
    if not item:IsA("Accessory") then NotifyUser("Aviso", "Solo puedes ajustar accesorios (sombreros, mochilas, etc.)"); return end
    local handle = item:FindFirstChild("Handle")
    if not handle then return end
    local weld = handle:FindFirstChild("AccessoryWeld")
    if not weld then return end

    ActiveEditItem = item

    if not ItemAdjustments[item] then
        local mesh = handle:FindFirstChildWhichIsA("DataModelMesh")
        ItemAdjustments[item] = {
            OriginalWeldC1 = weld.C1, OrigMeshScale = mesh and mesh.Scale or nil,
            OffsetX = 0, OffsetY = 0, OffsetZ = 0, RotX = 0, RotY = 0, RotZ = 0, Scale = 1
        }
    end

    local data = ItemAdjustments[item]
    EditOffsetX = data.OffsetX or 0; EditOffsetY = data.OffsetY or 0; EditOffsetZ = data.OffsetZ or 0
    EditRotX = data.RotX or 0; EditRotY = data.RotY or 0; EditRotZ = data.RotZ or 0
    EditScale = data.Scale or 1
    
    ResetScaleSlider(EditScale); ResetYSlider(EditOffsetY)
    EqPanel.Visible = false; EditPanel.Visible = true
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
                                pcall(function() PlayingAnimationTracks[eqId]:Stop(); PlayingAnimationTracks[eqId]:Destroy() end)
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
                                            -- SOLO lo devolvemos si NO está oculto por Edit Parts
                                            local group = string.find(pName, "left") and "LeftLeg" or "RightLeg"
                                            if not SavedBodyModifiers[group] then
                                                part.Transparency = 0 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        ItemAdjustments[item] = nil
                        item:Destroy(); frame:Destroy()
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
    PartsPanel.Visible = false
    if EqPanel.Visible then RefreshEquippedItems() end
end)

-- ==========================================================
-- VISUALIZADOR PREVIEW CORREGIDO (Menú Alert Implementado + COPY ID iOS)
-- ==========================================================
local ImagePreview = Instance.new("ImageButton")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.AutoButtonColor = true 
ImagePreview.ZIndex = 1
ImagePreview.Parent = Container

local isPreviewPressing = false
local previewHoldStart = 0
local longPressFired = false

ImagePreview.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPreviewPressing = true
        longPressFired = false
        previewHoldStart = tick()
        
        task.spawn(function()
            while isPreviewPressing do
                -- Si se mantiene por 0.55 segundos, copia ID y abre menú
                if tick() - previewHoldStart >= 0.55 then
                    isPreviewPressing = false
                    longPressFired = true
                    
                    local assetId = tonumber(CurrentData.Id)
                    if assetId and assetId > 0 then
                        -- ==============================================
                        -- SISTEMA DE COPIADO AL PORTAPAPELES (SOPORTE DELTA iOS)
                        -- ==============================================
                        pcall(function()
                            if setclipboard then
                                setclipboard(tostring(assetId))
                            elseif toclipboard then
                                toclipboard(tostring(assetId))
                            end
                        end)
                        
                        if NotifyUser then
                            NotifyUser("Éxito", "ID Copiado: " .. tostring(assetId) .. "\nAbriendo Menú Nativo...")
                        end
                        
                        -- Llama directamente al menú de compra de Roblox, ignorando el menú UI personalizado
                        pcall(function()
                            MarketplaceService:PromptPurchase(LocalPlayer, assetId)
                        end)
                    else
                        if NotifyUser then
                            NotifyUser("Error", "No hay un ítem seleccionado")
                        end
                    end
                    break
                end
                task.wait(0.03)
            end
        end)
    end
end)

ImagePreview.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isPreviewPressing = false
    end
end)

ImagePreview.MouseButton1Click:Connect(function()
    if longPressFired then return end -- Si fue long-press evita doble equipamiento
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
-- SISTEMA KITTY CATALOG UI (INTEGRACIONES SOLICITADAS)
-- ==========================================================
if CoreGui:FindFirstChild("KittyCatalogGui") then CoreGui.KittyCatalogGui:Destroy() end

local KittyGui = Instance.new("ScreenGui")
KittyGui.Name = "KittyCatalogGui"
KittyGui.Enabled = false 
KittyGui.DisplayOrder = 15
KittyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
        if delta.Magnitude > DRAG_THRESHOLD then isDraggingBtn = true end
        if isDraggingBtn then
            FloatingBtn.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
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

-- ==========================================================
-- KITTY TOP BAR Y SUS ELEMENTOS (CON FILTRO DE PRECIOS INTEGRADO)
-- ==========================================================
local KittyTop = Instance.new("Frame")
KittyTop.Size = UDim2.new(0.75, 0, 0, 60)
KittyTop.Position = UDim2.new(0.25, 0, 0, 0)
KittyTop.BackgroundTransparency = 1
KittyTop.Parent = KittyMain

local KittySearchLimit = 30 
local KITTY_MIN_LIMIT = 10
local KITTY_MAX_LIMIT = 30

local KittyCurrentCategory = 1 
local KittyPageHistory = {""} 
local KittyCurrentPage = 1
local KittyNextCursor = nil
local KittyMaxPages = 120
local PerformKittySearch 

local KittyResults = Instance.new("ScrollingFrame")
KittyResults.Size = UDim2.new(0.75, 0, 1, -100)
KittyResults.Position = UDim2.new(0.25, 0, 0, 60)
KittyResults.BackgroundTransparency = 1
KittyResults.ScrollBarThickness = 6
KittyResults.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
KittyResults.AutomaticCanvasSize = Enum.AutomaticSize.Y 
KittyResults.CanvasSize = UDim2.new(0, 0, 0, 0)
KittyResults.Parent = KittyMain

local PagiLabel = Instance.new("TextLabel")

-- Botón Home (Aislado)
local HomeBtn = Instance.new("ImageButton")
HomeBtn.Size = UDim2.new(0, 40, 0, 40)
HomeBtn.Position = UDim2.new(0.02, 0, 0.5, -20)
HomeBtn.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
HomeBtn.Image = "rbxassetid://132859920937628"
HomeBtn.Parent = KittyTop
local HomeCorner = Instance.new("UICorner"); HomeCorner.CornerRadius = UDim.new(0, 8); HomeCorner.Parent = HomeBtn

local KittySearch = Instance.new("TextBox") 

local function PerformHomeSearch()
    if KittySearch.Text == "" then return end
    KittyCurrentPage = 1
    KittyPageHistory = {""}
    KittyNextCursor = nil
    PerformKittySearch(false)
end
HomeBtn.MouseButton1Click:Connect(PerformHomeSearch)

-- Contenedor de Límite
local MaxItemsFrame = Instance.new("Frame")
MaxItemsFrame.Size = UDim2.new(0.24, 0, 0, 40)
MaxItemsFrame.Position = UDim2.new(0.10, 0, 0.5, -20)
MaxItemsFrame.BackgroundTransparency = 1
MaxItemsFrame.Parent = KittyTop

local MaxItemsLabel = Instance.new("TextLabel")
MaxItemsLabel.Size = UDim2.new(1, 0, 0, 15)
MaxItemsLabel.BackgroundTransparency = 1
MaxItemsLabel.Text = "Límite: " .. tostring(KITTY_MAX_LIMIT)
MaxItemsLabel.Font = Enum.Font.GothamBold
MaxItemsLabel.TextColor3 = Color3.fromRGB(255, 20, 147)
MaxItemsLabel.TextSize = 11
MaxItemsLabel.TextXAlignment = Enum.TextXAlignment.Center
MaxItemsLabel.Parent = MaxItemsFrame

local SpinnerBg = Instance.new("Frame")
SpinnerBg.Size = UDim2.new(1, 0, 0, 22)
SpinnerBg.Position = UDim2.new(0, 0, 0, 15)
SpinnerBg.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SpinnerBg.Parent = MaxItemsFrame
local SpinnerCorner = Instance.new("UICorner"); SpinnerCorner.CornerRadius = UDim.new(0, 4); SpinnerCorner.Parent = SpinnerBg

local BtnMinus = Instance.new("TextButton")
BtnMinus.Size = UDim2.new(0.3, 0, 1, 0)
BtnMinus.Position = UDim2.new(0, 0, 0, 0)
BtnMinus.BackgroundTransparency = 1
BtnMinus.Text = "-"
BtnMinus.Font = Enum.Font.GothamBold
BtnMinus.TextColor3 = Color3.fromRGB(255, 50, 50)
BtnMinus.TextSize = 16
BtnMinus.Parent = SpinnerBg

local MaxItemsInputBox = Instance.new("TextBox")
MaxItemsInputBox.Size = UDim2.new(0.4, 0, 1, 0)
MaxItemsInputBox.Position = UDim2.new(0.3, 0, 0, 0)
MaxItemsInputBox.BackgroundTransparency = 1
MaxItemsInputBox.Text = tostring(KITTY_MAX_LIMIT)
MaxItemsInputBox.Font = Enum.Font.GothamBold
MaxItemsInputBox.TextColor3 = Color3.fromRGB(255, 20, 147)
MaxItemsInputBox.TextSize = 12
MaxItemsInputBox.Parent = SpinnerBg

local BtnPlus = Instance.new("TextButton")
BtnPlus.Size = UDim2.new(0.3, 0, 1, 0)
BtnPlus.Position = UDim2.new(0.7, 0, 0, 0)
BtnPlus.BackgroundTransparency = 1
BtnPlus.Text = "+"
BtnPlus.Font = Enum.Font.GothamBold
BtnPlus.TextColor3 = Color3.fromRGB(50, 205, 50)
BtnPlus.TextSize = 16
BtnPlus.Parent = SpinnerBg

local function UpdateLimit(newVal)
    newVal = math.clamp(newVal, KITTY_MIN_LIMIT, KITTY_MAX_LIMIT)
    if KittySearchLimit == newVal then return end 
    KittySearchLimit = newVal
    MaxItemsInputBox.Text = tostring(newVal)
    MaxItemsLabel.Text = "Límite: " .. tostring(newVal)
    
    if KittySearch and KittySearch.Text ~= "" and KittyMain.Visible then
        PerformKittySearch(false) 
    end
end

BtnMinus.MouseButton1Click:Connect(function()
    local current = tonumber(MaxItemsInputBox.Text) or KittySearchLimit
    UpdateLimit(current - 20)
end)

BtnPlus.MouseButton1Click:Connect(function()
    local current = tonumber(MaxItemsInputBox.Text) or KittySearchLimit
    UpdateLimit(current + 20)
end)

MaxItemsInputBox.FocusLost:Connect(function()
    local val = tonumber(MaxItemsInputBox.Text) or KITTY_MIN_LIMIT
    if val > 10 and val < 30 then val = 30 end
    UpdateLimit(val)
end)

-- Barra de Busqueda Estándar
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0.24, 0, 0, 40)
SearchContainer.Position = UDim2.new(0.36, 0, 0.5, -20)
SearchContainer.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
SearchContainer.Parent = KittyTop
local SearchContainerCorner = Instance.new("UICorner"); SearchContainerCorner.CornerRadius = UDim.new(0, 8); SearchContainerCorner.Parent = SearchContainer

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

-- ==========================================================
-- BOTÓN DE FILTRO DE PRECIO 
-- ==========================================================
local PriceFilterMode = 0 -- 0: Todos, 1: Gratis(0), 2: +1M
local PriceFilterBtn = Instance.new("TextButton")
PriceFilterBtn.Size = UDim2.new(0.10, 0, 0, 40)
PriceFilterBtn.Position = UDim2.new(0.62, 0, 0.5, -20)
PriceFilterBtn.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
PriceFilterBtn.Text = "💸 Todos"
PriceFilterBtn.Font = Enum.Font.GothamBold
PriceFilterBtn.TextSize = 12
PriceFilterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PriceFilterBtn.Parent = KittyTop
local PriceFilterCorner = Instance.new("UICorner"); PriceFilterCorner.CornerRadius = UDim.new(0, 8); PriceFilterCorner.Parent = PriceFilterBtn

PriceFilterBtn.MouseButton1Click:Connect(function()
    PriceFilterMode = (PriceFilterMode + 1) % 3
    if PriceFilterMode == 0 then
        PriceFilterBtn.Text = "💸 Todos"
        PriceFilterBtn.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
    elseif PriceFilterMode == 1 then
        PriceFilterBtn.Text = "💸 Gratis"
        PriceFilterBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    else
        PriceFilterBtn.Text = "💸 +1M"
        PriceFilterBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
    end
    if KittySearch.Text ~= "" then PerformKittySearch(false) end
end)
-- ==========================================================

local KittySearchBtn = Instance.new("TextButton")
KittySearchBtn.Size = UDim2.new(0.14, 0, 0, 40)
KittySearchBtn.Position = UDim2.new(0.74, 0, 0.5, -20)
KittySearchBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
KittySearchBtn.Text = "Buscar"
KittySearchBtn.Font = Enum.Font.GothamBold
KittySearchBtn.TextSize = 14
KittySearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KittySearchBtn.Parent = KittyTop
local SearchBtnCorner = Instance.new("UICorner"); SearchBtnCorner.CornerRadius = UDim.new(0, 8); SearchBtnCorner.Parent = KittySearchBtn

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

CloseBtn.MouseButton1Click:Connect(function() KittyMain.Visible = false; FloatingBtn.Visible = true end)

local SidebarContainer = Instance.new("Frame")
SidebarContainer.Size = UDim2.new(0.25, 0, 1, 0)
SidebarContainer.Position = UDim2.new(0, 0, 0, 0)
SidebarContainer.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
SidebarContainer.BackgroundTransparency = 0.5
SidebarContainer.BorderSizePixel = 0
SidebarContainer.ClipsDescendants = true
SidebarContainer.Parent = KittyMain
local SidebarCorner = Instance.new("UICorner"); SidebarCorner.CornerRadius = UDim.new(0, 16); SidebarCorner.Parent = SidebarContainer

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

-- Paginación y Categorías
local PagiContainer = Instance.new("Frame")
PagiContainer.Size = UDim2.new(0.75, 0, 0, 40)
PagiContainer.Position = UDim2.new(0.25, 0, 1, -40)
PagiContainer.BackgroundTransparency = 1
PagiContainer.BorderSizePixel = 0
PagiContainer.Parent = KittyMain

local PagiPrevBtn = Instance.new("TextButton")
PagiPrevBtn.Size = UDim2.new(0, 80, 0, 30)
PagiPrevBtn.Position = UDim2.new(0, 15, 0.5, -15)
PagiPrevBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
PagiPrevBtn.Text = "⬅️ Atrás"
PagiPrevBtn.Font = Enum.Font.GothamBold
PagiPrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PagiPrevBtn.Visible = false
PagiPrevBtn.Parent = PagiContainer
local PagiPrevCorner = Instance.new("UICorner"); PagiPrevCorner.CornerRadius = UDim.new(0, 6); PagiPrevCorner.Parent = PagiPrevBtn

local PagiNextBtn = Instance.new("TextButton")
PagiNextBtn.Size = UDim2.new(0, 100, 0, 30)
PagiNextBtn.Position = UDim2.new(1, -115, 0.5, -15)
PagiNextBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
PagiNextBtn.Text = "Siguiente ➡️"
PagiNextBtn.Font = Enum.Font.GothamBold
PagiNextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PagiNextBtn.Visible = false
PagiNextBtn.Parent = PagiContainer
local PagiNextCorner = Instance.new("UICorner"); PagiNextCorner.CornerRadius = UDim.new(0, 6); PagiNextCorner.Parent = PagiNextBtn

PagiLabel.Size = UDim2.new(0, 100, 0, 30)
PagiLabel.Position = UDim2.new(0.5, -50, 0.5, -15)
PagiLabel.BackgroundTransparency = 1
PagiLabel.Text = "Página 1"
PagiLabel.Font = Enum.Font.GothamBold
PagiLabel.TextColor3 = Color3.fromRGB(255, 20, 147)
PagiLabel.TextSize = 14
PagiLabel.Parent = PagiContainer

local TitleCat = Instance.new("TextLabel")
TitleCat.Size = UDim2.new(1, 0, 0, 40)
TitleCat.BackgroundTransparency = 1
TitleCat.Text = "🎀 Categoría"
TitleCat.Font = Enum.Font.GothamBold
TitleCat.TextSize = 16
TitleCat.TextColor3 = Color3.fromRGB(255, 20, 147)
TitleCat.TextXAlignment = Enum.TextXAlignment.Center
TitleCat.Parent = KittySidebar

local CategoriesEnglish = {
    {"All", 1}, {"Accessories", 11}, 
    {"Clothing (All)", 3}, {"Shirts", 3}, {"T-Shirts", 3}, {"Sweaters", 3}, {"Jackets", 3}, {"Pants", 3}, {"Shoes", 3},
    {"Body", 4}, {"Hair", 4}, {"Heads", 4}, {"Faces / Makeup", 4},
    {"Animations", 12}, {"Emotes", 12}, {"Gear", 5}
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
        if catData[1] ~= "All" and catData[1] ~= "Accessories" and catData[1] ~= "Clothing (All)" and catData[1] ~= "Body" then
            KittySearch.Text = catData[1] .. " "
        else
            KittySearch.Text = ""
        end
        KittySearch.PlaceholderText = "🔍 En " .. catData[1] .. "..."
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
        task.wait(0.2)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 228, 225)}):Play()
    end)
end

PerformKittySearch = function(isPagination)
    if KittySearch.Text == "" then return end
    if not isPagination then
        KittyPageHistory = {""}
        KittyCurrentPage = 1
        KittyNextCursor = nil
    end

    for _, child in ipairs(KittyResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    PagiLabel.Text = "Cargando..."
    PagiPrevBtn.Visible = false
    PagiNextBtn.Visible = false

    local cursor = KittyPageHistory[KittyCurrentPage] or ""
    
    -- INYECCIÓN DEL FILTRO DE PRECIOS
    local url = "https://catalog.roblox.com/v1/search/items/details?category="..tostring(KittyCurrentCategory).."&limit="..tostring(KittySearchLimit).."&keyword=" .. HttpService:UrlEncode(KittySearch.Text)
    if PriceFilterMode == 1 then
        url = url .. "&maxPrice=0"
    elseif PriceFilterMode == 2 then
        url = url .. "&minPrice=1000000"
    end
    
    if cursor ~= "" then url = url .. "&cursor=" .. HttpService:UrlEncode(cursor) end

    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success or not response then
        url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
        success, response = pcall(function() return game:HttpGet(url) end)
    end

    if success and response then
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.data then
            KittyNextCursor = decoded.nextPageCursor
            PagiLabel.Text = "Página " .. tostring(KittyCurrentPage)
            PagiPrevBtn.Visible = (KittyCurrentPage > 1)
            PagiNextBtn.Visible = (KittyNextCursor ~= nil and KittyNextCursor ~= "" and KittyCurrentPage < KittyMaxPages)

            for _, item in ipairs(decoded.data) do
                local Card = Instance.new("Frame")
                Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Card.Parent = KittyResults
                local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 10); CardCorner.Parent = Card
                
                local CardImg = Instance.new("ImageLabel")
                CardImg.Size = UDim2.new(1, 0, 0, 100)
                CardImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                CardImg.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
                CardImg.Parent = Card
                local ImgCorner = Instance.new("UICorner"); ImgCorner.CornerRadius = UDim.new(0, 10); ImgCorner.Parent = CardImg
                
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
                CardRobux.Visible = (item.price ~= nil and type(item.price)=="number" and item.price > 0)
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
                end)
            end
        else
            PagiLabel.Text = "Sin resultados"
        end
    else
        PagiLabel.Text = "Error de Red"
    end
end

KittySearch.FocusLost:Connect(function(enterPressed) if enterPressed then PerformKittySearch(false) end end)
KittySearchBtn.MouseButton1Click:Connect(function() PerformKittySearch(false) end)

PagiNextBtn.MouseButton1Click:Connect(function()
    if KittyNextCursor and KittyNextCursor ~= "" and KittyCurrentPage < KittyMaxPages then
        KittyCurrentPage = KittyCurrentPage + 1
        if not KittyPageHistory[KittyCurrentPage] then KittyPageHistory[KittyCurrentPage] = KittyNextCursor end
        PerformKittySearch(true)
    end
end)

PagiPrevBtn.MouseButton1Click:Connect(function()
    if KittyCurrentPage > 1 then
        KittyCurrentPage = KittyCurrentPage - 1
        PerformKittySearch(true)
    end
end)

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
   Name = "🏥 Avatar Catalog Quirúrgico Pro v25.6 Ultra-Async",
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
           PartsPanel.Visible = false
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
           local url = "https://catalog.roblox.com/v1/search/items/details?category="..apiCategory.."&limit=30&keyword=" .. HttpService:UrlEncode(Text)
           local success, response = pcall(function() return game:HttpGet(url) end)
           
           if not success or not response then
               url = url:gsub("catalog.roblox.com", "catalog.roproxy.com")
               success, response = pcall(function() return game:HttpGet(url) end)
           end

           if success and response then
               local decoded = HttpService:JSONDecode(response)
               if decoded and decoded.data and #decoded.data > 0 then
                   local options = {}
                   table.clear(SearchResultsCache)
                   for _, item in ipairs(decoded.data) do
                       local entryName = item.name .. " (ID: " .. item.id .. ")"
                       table.insert(options, entryName)
                       SearchResultsCache[entryName] = {
                           Id = item.id,
                           Name = item.name,
                           Price = item.price or "Gratis",
                           Category = item.category,
                           ItemType = item.itemType or "Asset"
                       }
                   end
                   SpinnerDropdown:Refresh(options, true)
                   Rayfield:Notify({Title = "Éxito", Content = "Se encontraron " .. #options .. " resultados.", Duration = 3})
               else
                   Rayfield:Notify({Title = "Sin resultados", Content = "No se encontraron ítems con ese nombre.", Duration = 3})
               end
           else
               Rayfield:Notify({Title = "Error", Content = "Falló la conexión al catálogo.", Duration = 3})
           end
       end)
   end,
})

Rayfield:LoadConfiguration()
