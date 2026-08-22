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
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Cambiado a un tono oscuro (o el color que gustes)
    Card.BackgroundTransparency = 0.35 -- Haces la tarjeta traslúcida (0 = sólido, 1 = invisible)
    Card.Parent = bannerData.ParentContainer
    
    local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 10); CardCorner.Parent = Card
    
    local CardImg = Instance.new("ImageLabel")
    CardImg.Size = UDim2.new(1, 0, 0, 100)
    CardImg.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Fondo de la imagen más oscuro
    CardImg.BackgroundTransparency = 0.5 -- Fondo de la imagen traslúcido
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
                Card.BackgroundTransparency = 0.3 -- Traslúcido
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
        frame.BackgroundTransparency = 0.3 -- Traslúcido
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

    -- Detectar FREE de forma robusta (número 0, "0", "0 R$", "Gratis", etc.)
    local isFree = false
    if price == 0 or price == "0" or price == "Gratis" or price == "Gratis / Off-Sale" or price == "FREE" then
        isFree = true
    elseif type(price) == "string" then
        local cleaned = tostring(price):gsub(" R%$", ""):gsub("%s+", "")
        if cleaned == "0" or cleaned == "" then
            isFree = true
        end
    end

    if isFree then
        RobuxIcon.Visible = false
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50)   -- Verde
    else
        RobuxIcon.Visible = true
        PriceTag.Text = tostring(price):gsub(" R%$", "")
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0)   -- Dorado
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

-- ==========================================================
-- SISTEMA DE ROBUX FALSO (CATÁLOGO)
-- ==========================================================
local FakeRobuxBalance = 300000 -- 300.00K inicial
local FAKE_ROBUX_MAX = 300000

local function FormatRobux(amount)
    if amount >= 1000000 then
        return string.format("%.2fM", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.2fK", amount / 1000)
    else
        return tostring(math.floor(amount))
    end
end

local function PlayCatalogSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = 1.2
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 6)
    end)
end

local FakeRobuxLabel -- se asigna más abajo

local function UpdateFakeRobuxDisplay()
    if FakeRobuxLabel then
        FakeRobuxLabel.Text = FormatRobux(FakeRobuxBalance)
    end
end

local function SpendFakeRobux(price)
    price = tonumber(price) or 0
    if price <= 0 then return end -- ítems FREE no gastan

    local spent = price
    if FakeRobuxBalance >= price then
        FakeRobuxBalance = FakeRobuxBalance - price
    else
        -- Si no alcanza, igual se compra y te deja en 0
        spent = FakeRobuxBalance
        FakeRobuxBalance = 0
    end

    UpdateFakeRobuxDisplay()
    PlayCatalogSound(130452529897520) -- sonido de compra

    -- Notificación con el gasto en rojo
    if NotifyUser then
        NotifyUser("Ítem seleccionado", "Gastaste  <font color='rgb(255,60,60)'>-" .. tostring(spent) .. " R$</font>")
    end

    -- Si llegamos a 0 → regenerar + sonido
    if FakeRobuxBalance <= 0 then
        task.delay(0.6, function()
            FakeRobuxBalance = FAKE_ROBUX_MAX
            UpdateFakeRobuxDisplay()
            PlayCatalogSound(607665037) -- sonido de regeneración
            if NotifyUser then
                NotifyUser("Robux regenerados", "Tu saldo se ha restaurado a " .. FormatRobux(FAKE_ROBUX_MAX))
            end
        end)
    end
end

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "KittyFloatingBtn"
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = DEFAULT_FLOATING_POS
FloatingBtn.Image = "rbxassetid://82434199149711"
FloatingBtn.BackgroundTransparency = 1
FloatingBtn.Visible = false 
FloatingBtn.Parent = KittyGui

local KittyMain = Instance.new("ImageLabel")
KittyMain.Size = UDim2.new(0.95, 0, 0.9, 0) 
KittyMain.Position = UDim2.new(0.5, 0, 0.5, 0) 
KittyMain.AnchorPoint = Vector2.new(0.5, 0.5) 
KittyMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
KittyMain.BackgroundTransparency = 1 
KittyMain.ImageTransparency = 0.5 -- Contola únicamente la transparencia de la imagen (0 a 1)
KittyMain.ScaleType = Enum.ScaleType.Crop
KittyMain.BorderSizePixel = 0
KittyMain.ClipsDescendants = true
KittyMain.Parent = KittyGui

-- ========== BARRA DE ROBUX FALSO (arriba del catálogo) ==========
local FakeRobuxBar = Instance.new("Frame")
FakeRobuxBar.Name = "FakeRobuxBar"
FakeRobuxBar.Size = UDim2.new(0, 170, 0, 34)
FakeRobuxBar.Position = UDim2.new(0.5, 0, 0, -42) -- arriba del menú
FakeRobuxBar.AnchorPoint = Vector2.new(0.5, 1)
FakeRobuxBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FakeRobuxBar.BackgroundTransparency = 0.15
FakeRobuxBar.BorderSizePixel = 0
FakeRobuxBar.Parent = KittyMain

local FakeRobuxCorner = Instance.new("UICorner")
FakeRobuxCorner.CornerRadius = UDim.new(0, 10)
FakeRobuxCorner.Parent = FakeRobuxBar

local FakeRobuxStroke = Instance.new("UIStroke")
FakeRobuxStroke.Color = Color3.fromRGB(255, 215, 0)
FakeRobuxStroke.Thickness = 1.5
FakeRobuxStroke.Parent = FakeRobuxBar

local FakeRobuxIcon = Instance.new("ImageLabel")
FakeRobuxIcon.Size = UDim2.new(0, 22, 0, 22)
FakeRobuxIcon.Position = UDim2.new(0, 10, 0.5, -11)
FakeRobuxIcon.BackgroundTransparency = 1
FakeRobuxIcon.Image = "rbxassetid://11560341824" -- logo Robux oficial
FakeRobuxIcon.Parent = FakeRobuxBar

FakeRobuxLabel = Instance.new("TextLabel")
FakeRobuxLabel.Size = UDim2.new(1, -40, 1, 0)
FakeRobuxLabel.Position = UDim2.new(0, 36, 0, 0)
FakeRobuxLabel.BackgroundTransparency = 1
FakeRobuxLabel.Font = Enum.Font.GothamBold
FakeRobuxLabel.TextSize = 16
FakeRobuxLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
FakeRobuxLabel.TextXAlignment = Enum.TextXAlignment.Left
FakeRobuxLabel.Text = FormatRobux(FakeRobuxBalance)
FakeRobuxLabel.Parent = FakeRobuxBar

task.spawn(function()
    local imgUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/assets/likeLuaScript.jpg"
    if getcustomasset and writefile then
        local fileName = "likeLuaScript_bg.jpg"
        if not isfile or not isfile(fileName) then
            pcall(function() writefile(fileName, game:HttpGet(imgUrl)) end)
        end
        if isfile and isfile(fileName) then
            KittyMain.Image = getcustomasset(fileName)
        else
            KittyMain.Image = imgUrl
        end
    else
        KittyMain.Image = imgUrl
    end
end)

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
KittyResults.BackgroundColor3 = Color3.fromRGB(255, 182, 193) -- O usa Color3.fromRGB(25, 25, 25) para tono oscuro
KittyResults.BackgroundTransparency = 0.4 -- Traslúcido
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
                Card.BackgroundColor3 = Color3.fromRGB(255, 153, 204)
                Card.BackgroundTransparency = 0.5
                Card.Parent = KittyResults
                local CardCorner = Instance.new("UICorner"); CardCorner.CornerRadius = UDim.new(0, 10); CardCorner.Parent = Card
                
                local CardImg = Instance.new("ImageLabel")
                CardImg.AnchorPoint = Vector2.new(0.5, 0)
                CardImg.Size = UDim2.new(0.9, 0, 0, 90)
                CardImg.Position = UDim2.new(0.5, 0, 0, 5)
                CardImg.ScaleType = Enum.ScaleType.Fit
                CardImg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                CardImg.BackgroundTransparency = 0.5
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
                CardPrice.Font = Enum.Font.GothamBold
                CardPrice.TextSize = 13
                CardPrice.TextColor3 = Color3.fromRGB(50, 50, 50) -- Color original (no se toca en ítems de pago)
                CardPrice.TextXAlignment = Enum.TextXAlignment.Left
                CardPrice.Parent = Card

                -- FREE en verde o precio normal
                local isFree = not (type(item.price) == "number" and item.price > 0)
                if isFree then
                    CardPrice.Text = "FREE"
                    CardPrice.TextColor3 = Color3.fromRGB(50, 255, 50)
                    CardPrice.AnchorPoint = Vector2.new(0.5, 0)
                    CardPrice.Position = UDim2.new(0.5, 0, 0, 155)
                    CardPrice.Size = UDim2.new(1, -10, 0, 20)
                    CardPrice.TextXAlignment = Enum.TextXAlignment.Center
                else
                    CardPrice.Text = tostring(item.price)
                    -- Color no se toca
                end
                
                local CardRobux = Instance.new("ImageLabel")
                CardRobux.Size = UDim2.new(0, 14, 0, 14)
                CardRobux.Position = UDim2.new(0, 6, 0, 158)
                CardRobux.BackgroundTransparency = 1
                CardRobux.Image = "rbxassetid://11560341824"
                CardRobux.Visible = (item.price ~= nil and type(item.price) == "number" and item.price > 0)
                CardRobux.Parent = Card

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Size = UDim2.new(1, 0, 1, 0)
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Text = ""
                ClickBtn.Parent = Card
                
                -- ==========================================================
-- ==========================================================
-- MÉTODO NUEVO DE CLICK EN ITEM DEL CATÁLOGO KITTY (FIXED V30 - INVERTIDO)
-- Toque corto = Visualizador directo | Mantener = Escena 3D completa
-- + Cierre automático del menú de catálogo en ambas acciones
-- ==========================================================
local holding = false
local holdStart = 0
local longPress = false
local HOLD_TIME = 0.45

ClickBtn.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    holding = true
    longPress = false
    holdStart = tick()

    task.spawn(function()
        while holding do
            if tick() - holdStart >= HOLD_TIME then
                longPress = true
                holding = false

                -- ==================================================
                -- MANTENER PRESIONADO → ESCENA 3D COMPLETA
                -- ==================================================
                CurrentData.Id = tostring(item.id)
                CurrentData.Name = item.name or "Objeto"
                CurrentData.Price = item.price and (tostring(item.price) .. " R$") or "Gratis"
                CurrentData.ItemType = item.itemType or "Asset"

                -- Gastar Robux falso
                SpendFakeRobux(item.price)                        

                -- Cerrar menú de catálogo
                KittyMain.Visible = false
                FloatingBtn.Visible = true

                task.spawn(function()
                    -- ... AQUÍ SIGUE TODA TU ESCENA 3D SIN CAMBIOS ...
                    local Workspace = game:GetService("Workspace")
                    local Players = game:GetService("Players")
                    local TweenService = game:GetService("TweenService")
                    local RunService = game:GetService("RunService")
                    local Debris = game:GetService("Debris")
                    local StarterGui = game:GetService("StarterGui")
                    local Lighting = game:GetService("Lighting")
                    local CoreGui = game:GetService("CoreGui")
                    local LocalPlayer = Players.LocalPlayer

                    -- ==================================================
                    -- CONTROL DEL SCREENGUI
                    -- ==================================================
                    local function ToggleUIVisibility(state)
                        pcall(function()
                            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                            
                            if Container then Container.Visible = state end
                            
                            local hubNames = {"VisualizadorItemGUI", "Kitty", "KittyHub"} 
                            for _, name in ipairs(hubNames) do
                                local ui = (CoreGui and CoreGui:FindFirstChild(name)) or (PlayerGui and PlayerGui:FindFirstChild(name))
                                if ui then
                                    if ui:IsA("ScreenGui") then ui.Enabled = state else ui.Visible = state end
                                end
                            end

                            if PlayerGui then
                                for _, gui in ipairs(PlayerGui:GetChildren()) do
                                    if gui:IsA("ScreenGui") then
                                        gui.Enabled = state
                                    elseif gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                                        gui.Visible = state
                                    end
                                end
                            end
                        end)
                    end

                    -- ==================================================
                    -- 1. LIMPIEZA SEGURA DE PREVIEWS ANTERIORES
                    -- ==================================================
                    for _, child in ipairs(Workspace:GetChildren()) do
                        if child.Name == "Kitty3DPreview" then child:Destroy() end
                    end
                    for _, child in ipairs(Lighting:GetChildren()) do
                        if child.Name == "KittyPreviewBlur" then child:Destroy() end
                    end
                    task.wait() 

                    local PreviewFolder = Instance.new("Folder")
                    PreviewFolder.Name = "Kitty3DPreview"
                    PreviewFolder.Parent = Workspace

                    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    
                    local rawPos = hrp.Position + (hrp.CFrame.LookVector * 14)
                    local spawnPos = Vector3.new(rawPos.X, hrp.Position.Y - 3, rawPos.Z)

                    -- ==================================================
                    -- ESCANEO DE SUELO UNIFICADO (Centro para la mesa)
                    -- ==================================================
                    local rayOrigin = spawnPos + Vector3.new(0, 50, 0)
                    local ignoreList = {char, PreviewFolder}
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local trueGroundY = spawnPos.Y 
                    
                    for i = 1, 10 do
                        raycastParams.FilterDescendantsInstances = ignoreList
                        local result = Workspace:Raycast(rayOrigin, Vector3.new(0, -100, 0), raycastParams)
                        
                        if result then
                            local inst = result.Instance
                            if inst ~= Workspace.Terrain and (inst.Transparency >= 0.8 and not inst.CanCollide) then
                                table.insert(ignoreList, inst)
                            else
                                trueGroundY = result.Position.Y
                                break
                            end
                        else
                            break
                        end
                    end

                    spawnPos = Vector3.new(spawnPos.X, trueGroundY, spawnPos.Z)

                    -- ==================================================
                    -- FUNCIONES DE FÍSICAS Y CAÍDA
                    -- ==================================================
                    local function AnimateDrop(model, targetCFrame, dropHeight)
                        dropHeight = dropHeight or 25
                        local cfValue = Instance.new("CFrameValue")
                        cfValue.Value = targetCFrame + Vector3.new(0, dropHeight, 0)
                        
                        if model:IsA("Model") then model:PivotTo(cfValue.Value) else model.CFrame = cfValue.Value end
                        
                        local dropTween = TweenService:Create(cfValue, TweenInfo.new(0.65, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Value = targetCFrame})
                        dropTween:Play()
                        
                        local conn
                        conn = cfValue.Changed:Connect(function(newCf)
                            if model and model.Parent then
                                if model:IsA("Model") then model:PivotTo(newCf) else model.CFrame = newCf end
                            end
                        end)
                        
                        dropTween.Completed:Connect(function()
                            if conn then conn:Disconnect() end
                            if cfValue then cfValue:Destroy() end
                        end)
                    end

                    local function LockPhysics(obj)
                        if obj:IsA("BasePart") then obj.Anchored = true; obj.CanCollide = false end
                        for _, p in ipairs(obj:GetDescendants()) do
                            if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false end
                        end
                    end

                    -- ==================================================
                    -- CARGA MODULAR ESCALONADA CON CAÍDA INDEPENDIENTE (ANTI-FLOTE)
                    -- ==================================================
                    local SceneObjects = {}
                    local currentLoadDelay = 0 
                    
                    local function LoadAsset(id, name, offsetCFrame, manualLift, skipDrop, collideWithFolder, onLoaded)
                        currentLoadDelay = currentLoadDelay + 0.12 
                        local thisDelay = currentLoadDelay
                        
                        task.spawn(function()
                            if thisDelay > 0 then task.wait(thisDelay) end
                            
                            local success, objs = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
                            if success and objs and #objs > 0 then
                                local model = objs[1]:Clone()
                                model.Name = name
                                LockPhysics(model) 
                                model.Parent = PreviewFolder 
                                
                                -- [NUEVO]: Raycast individual para cada elemento decorativo basado en su offset (X, Z)
                                local rawTargetPos = (CFrame.new(spawnPos) * offsetCFrame).Position
                                local itemRayOrigin = rawTargetPos + Vector3.new(0, 50, 0)
                                local itemGroundY = rawTargetPos.Y -- Fallback si no encuentra nada
                                
                                local raycastParamsIndividual = RaycastParams.new()
                                raycastParamsIndividual.FilterType = Enum.RaycastFilterType.Exclude
                                                    -- Por defecto ignoramos la carpeta para que la mesa y demás no se pisen entre sí
                                local individualIgnoreList = {char, PreviewFolder}
                                
                                -- Pero si activamos el permiso, el objeto (el maletín) podrá chocar con la mesa
                                if collideWithFolder then
                                    individualIgnoreList = {char, model}
                                end
                                
                                for i = 1, 10 do
                                    raycastParamsIndividual.FilterDescendantsInstances = individualIgnoreList
                                    local result = Workspace:Raycast(itemRayOrigin, Vector3.new(0, -100, 0), raycastParamsIndividual)
                                    
                                    if result then
                                        local inst = result.Instance
                                        if inst ~= Workspace.Terrain and (inst.Transparency >= 0.8 and not inst.CanCollide) then
                                            table.insert(individualIgnoreList, inst)
                                        else
                                            itemGroundY = result.Position.Y
                                            break
                                        end
                                    else
                                        break
                                    end
                                end
                                
                                -- Posicionar basándose en SU suelo real, no en el suelo de la mesa
                                local baseCFrame = CFrame.new(rawTargetPos.X, itemGroundY, rawTargetPos.Z) * offsetCFrame.Rotation
                                local finalCFrame
                                
                                if manualLift then
                                    finalCFrame = CFrame.new(baseCFrame.X, baseCFrame.Y + manualLift, baseCFrame.Z) * baseCFrame.Rotation
                                else
                                    local boundsCFrame, size = model:GetBoundingBox()
                                    local pivotY = model:GetPivot().Y
                                    local bottomY = boundsCFrame.Y - (size.Y / 2)
                                    local liftOffset = pivotY - bottomY 
                                    
                                    if size.Y < 0.1 or liftOffset ~= liftOffset then liftOffset = 0.05 end
                                    finalCFrame = CFrame.new(baseCFrame.X, baseCFrame.Y + liftOffset, baseCFrame.Z) * baseCFrame.Rotation
                                end
                                
                                if skipDrop then
                                    if model:IsA("Model") then model:PivotTo(finalCFrame) else model.CFrame = finalCFrame end
                                else
                                    AnimateDrop(model, finalCFrame)
                                end
                                
                                table.insert(SceneObjects, model)
                                if onLoaded then task.spawn(function() onLoaded(model) end) end
                            end
                        end)
                    end

                    -- ==================================================
                    -- 2. CARGA DE ESCENOGRAFÍA SECUENCIAL
                    -- ==================================================
                    LoadAsset("114068096511672", "MoneyBase", CFrame.new(0, 0, 0))
                    LoadAsset("9124849026", "Table", CFrame.new(0, 0, 0))
                    LoadAsset("121348416036836", "KittySignTable", CFrame.new(5.0, 0.35, -2.0) * CFrame.Angles(0, math.rad(-25), 0), 0, true)
                    LoadAsset("8504132994", "Briefcase", CFrame.new(8.4, 0, 0) * CFrame.Angles(0, math.rad(-250), 0), nil, false, true)
                    LoadAsset("18303013374", "MoneyBag", CFrame.new(-3.5, 0, 0) * CFrame.Angles(0, math.rad(-15), 0))
                    LoadAsset("6554303222", "FloorMoney", CFrame.new(0, 0, 3.5) * CFrame.Angles(0, math.rad(10), 0))
                    LoadAsset("8808108873", "Cofre", CFrame.new(6.5, 0, -8.5) * CFrame.Angles(0, math.rad(124), 0))
                    LoadAsset("103693408325569", "WeaponBox", CFrame.new(12.5, 0, -10.5) * CFrame.Angles(0, math.rad(-75), 0))
                    LoadAsset("140487868173670", "Iphone", CFrame.new(-5.0, 0, 4.0) * CFrame.Angles(0, math.rad(-20), 0))
                    
                    -- Reloj
                    LoadAsset("86136491298166", "ClockTime", CFrame.new(9.5, 0, 8.5) * CFrame.Angles(0, math.rad(25), 0), nil, nil, false, function(clockModel)
                        if clockModel:IsA("Model") then clockModel:ScaleTo(20)
                        elseif clockModel:IsA("BasePart") then clockModel.Size = clockModel.Size * 20 end

                        local bbGui = Instance.new("BillboardGui")
                        bbGui.Name = "KittyClockGui"
                        bbGui.Size = UDim2.new(8, 0, 2.5, 0)
                        bbGui.StudsOffset = Vector3.new(0, 8, 0) 
                        bbGui.AlwaysOnTop = true
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextScaled = true
                        txt.Font = Enum.Font.GothamBlack 
                        txt.TextColor3 = Color3.fromRGB(136, 8, 8)
                        txt.TextStrokeTransparency = 2 
                        txt.Parent = bbGui
                        
                        local parentPart = clockModel:IsA("Model") and (clockModel.PrimaryPart or clockModel:FindFirstChildWhichIsA("BasePart")) or clockModel
                        bbGui.Adornee = parentPart or clockModel
                        
                        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if PlayerGui then bbGui.Parent = PlayerGui else bbGui.Parent = PreviewFolder end
                        
                        task.spawn(function()
                            while clockModel and clockModel.Parent do
                                local date = os.date("*t")
                                txt.Text = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
                                task.wait(1)
                            end
                            if bbGui then bbGui:Destroy() end
                        end)
                    end)

                    -- ==================================================
                    -- 3. ESFERA VIVA REFLECTANTE Y CONGELADA
                    -- ==================================================
                    local SphereModel = Instance.new("Part")
                    SphereModel.Name = "KittyGlassSphere"
                    SphereModel.Shape = Enum.PartType.Ball
                    SphereModel.Size = Vector3.new(3.6, 3.6, 3.6)
                    SphereModel.Material = Enum.Material.ForceField 
                    SphereModel.Color = Color3.fromRGB(40, 255, 160) 
                    SphereModel.Transparency = 0.60
                    SphereModel.Reflectance = 0.9
                    SphereModel.Anchored = true
                    SphereModel.CanCollide = false
                    SphereModel.Parent = PreviewFolder

                    local SphereHighlight = Instance.new("Highlight")
                    SphereHighlight.Name = "TechMeshHighlight"
                    SphereHighlight.Adornee = SphereModel
                    SphereHighlight.FillTransparency = 1 
                    SphereHighlight.OutlineColor = Color3.fromRGB(85, 255, 127)
                    SphereHighlight.OutlineTransparency = 0.15
                    SphereHighlight.Parent = SphereModel

                    local WhiteReflect = Instance.new("Part")
                    WhiteReflect.Name = "WhiteGlassReflection"
                    WhiteReflect.Shape = Enum.PartType.Ball
                    WhiteReflect.Size = Vector3.new(3.62, 3.62, 3.62)
                    WhiteReflect.Material = Enum.Material.SmoothPlastic 
                    WhiteReflect.Color = Color3.fromRGB(255, 255, 255)
                    WhiteReflect.Transparency = 0.88 
                    WhiteReflect.Reflectance = 0.95 
                    WhiteReflect.Anchored = true
                    WhiteReflect.CanCollide = false
                    WhiteReflect.CFrame = SphereModel.CFrame
                    WhiteReflect.Parent = SphereModel

                    local GlassSpecGlint = Instance.new("PointLight")
                    GlassSpecGlint.Name = "GlassSpecGlint"
                    GlassSpecGlint.Color = Color3.fromRGB(255, 255, 255)
                    GlassSpecGlint.Brightness = 4.5
                    GlassSpecGlint.Range = 3.5
                    GlassSpecGlint.Shadows = false
                    GlassSpecGlint.Parent = WhiteReflect

                    local WeldWhite = Instance.new("WeldConstraint")
                    WeldWhite.Part0 = SphereModel
                    WeldWhite.Part1 = WhiteReflect
                    WeldWhite.Parent = WhiteReflect

                    local InnerGlass = Instance.new("Part")
                    InnerGlass.Name = "InnerGlassReflector"
                    InnerGlass.Shape = Enum.PartType.Ball
                    InnerGlass.Size = Vector3.new(4.0, 4.0, 4.0)
                    InnerGlass.Material = Enum.Material.SmoothPlastic 
                    InnerGlass.Color = Color3.fromRGB(20, 255, 140)
                    InnerGlass.Transparency = 0.65 
                    InnerGlass.Reflectance = 0.75 
                    InnerGlass.Anchored = true
                    InnerGlass.CanCollide = false
                    InnerGlass.CFrame = SphereModel.CFrame
                    InnerGlass.Parent = SphereModel

                    local WeldGlass = Instance.new("WeldConstraint")
                    WeldGlass.Part0 = SphereModel
                    WeldGlass.Part1 = InnerGlass
                    WeldGlass.Parent = InnerGlass

                    local FrostLight = Instance.new("PointLight")
                    FrostLight.Name = "FrostGlow"
                    FrostLight.Color = Color3.fromRGB(85, 255, 127)
                    FrostLight.Brightness = 1.8
                    FrostLight.Range = 6.5
                    FrostLight.Shadows = false
                    FrostLight.Parent = InnerGlass

                    local FrostParticles = Instance.new("ParticleEmitter")
                    FrostParticles.Name = "IceFrostAura"
                    FrostParticles.Texture = "rbxassetid://243660364" 
                    FrostParticles.Color = ColorSequence.new(Color3.fromRGB(120, 255, 180))
                    FrostParticles.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.5, 0.75),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    FrostParticles.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1.2),
                        NumberSequenceKeypoint.new(1, 2.5)
                    })
                    FrostParticles.Lifetime = NumberRange.new(1.5, 2.5)
                    FrostParticles.Rate = 8
                    FrostParticles.Speed = NumberRange.new(0.1, 0.4)
                    FrostParticles.LightEmission = 0.35
                    FrostParticles.Parent = InnerGlass

                    for i = 1, 3 do
                        local PolyPart = Instance.new("Part")
                        PolyPart.Name = "InternalPoly" .. i
                        PolyPart.Shape = Enum.PartType.Block
                        PolyPart.Size = Vector3.new(2.5, 2.5, 2.5)
                        PolyPart.Material = Enum.Material.Ice 
                        PolyPart.Color = Color3.fromRGB(85, 255, 127)
                        PolyPart.Transparency = 0.82 
                        PolyPart.Anchored = true
                        PolyPart.CanCollide = false
                        
                        local rotX = math.rad(math.random(0, 360))
                        local rotY = math.rad(math.random(0, 360))
                        local rotZ = math.rad(math.random(0, 360))
                        PolyPart.CFrame = SphereModel.CFrame * CFrame.Angles(rotX, rotY, rotZ)
                        PolyPart.Parent = SphereModel

                        local WeldPoly = Instance.new("WeldConstraint")
                        WeldPoly.Part0 = SphereModel
                        WeldPoly.Part1 = PolyPart
                        WeldPoly.Parent = PolyPart
                    end

                    local baseRadius = 2.15 
                    local lineColor = Color3.fromRGB(85, 255, 127) 
                    local grosorVisual = 0.015 
                    local grosorProfundidad = 0.015 

                    for i = 1, 4 do
                        local meridian = Instance.new("CylinderHandleAdornment")
                        meridian.Name = "MeridianLine" .. i
                        meridian.Adornee = SphereModel
                        meridian.Radius = baseRadius
                        meridian.InnerRadius = baseRadius - grosorProfundidad 
                        meridian.Height = grosorVisual 
                        meridian.Color3 = lineColor
                        meridian.Transparency = 0.45 
                        meridian.AlwaysOnTop = false 
                        meridian.ZIndex = 0
                        
                        local angle = math.rad((180 / 4) * i)
                        meridian.CFrame = CFrame.Angles(0, angle, math.rad(90))
                        meridian.Parent = SphereModel
                    end

                    local latitudes = {-1.0, 0, 1.0} 
                    for i, yOffset in ipairs(latitudes) do
                        local parallel = Instance.new("CylinderHandleAdornment")
                        parallel.Name = "ParallelLine" .. i
                        parallel.Adornee = SphereModel
                        
                        local ringRadius = math.sqrt(baseRadius^2 - yOffset^2)
                        
                        parallel.Radius = ringRadius
                        parallel.InnerRadius = ringRadius - grosorProfundidad
                        parallel.Height = grosorVisual
                        
                        parallel.Color3 = lineColor
                        parallel.Transparency = 0.45
                        parallel.AlwaysOnTop = false 
                        parallel.ZIndex = 0
                        
                        parallel.CFrame = CFrame.new(0, yOffset, 0) * CFrame.Angles(math.rad(90), 0, 0)
                        parallel.Parent = SphereModel
                    end

                    task.delay(0.65, function() 
                        for i = 1, 10 do
                            local spark = Instance.new("Part")
                            spark.Size = Vector3.new(0.3, 0.3, 0.3)
                            spark.Position = spawnPos + Vector3.new(0, 2, 0)
                            spark.Material = Enum.Material.Neon
                            spark.Color = Color3.fromRGB(85, 255, 127)
                            spark.Anchored = false; spark.CanCollide = false
                            spark.Parent = PreviewFolder
                            spark.Velocity = Vector3.new(math.random(-25, 25), math.random(20, 45), math.random(-25, 25))
                            Debris:AddItem(spark, 1.5)
                        end
                    end)

                    -- ==================================================
                    -- 4. EFECTO: LLUVIA DE BILLETES (Método intacto)
                    -- ==================================================
                    local RainActive = true
                    local GroundedBills = {}
                    local AllRainBills = {}

                    task.spawn(function()
                        local success, rainObjs = pcall(function() return game:GetObjects("rbxassetid://439712421") end)
                        local BillTemplate = (success and rainObjs and #rainObjs > 0) and rainObjs[1] or nil

                        if not BillTemplate then
                            BillTemplate = Instance.new("Part")
                            BillTemplate.Size = Vector3.new(1.2, 0.1, 0.6)
                            BillTemplate.Color = Color3.fromRGB(85, 170, 127)
                            BillTemplate.Material = Enum.Material.SmoothPlastic
                        end

                        local function GetSeparatedSpawnOffset()
                            local offset, attempts = nil, 0
                            repeat
                                attempts = attempts + 1
                                offset = Vector3.new(math.random(-6, 6), 25, math.random(-6, 6))
                                local tooClose = false
                                local testPos = spawnPos + Vector3.new(offset.X, 0, offset.Z)
                                for _, b in ipairs(GroundedBills) do
                                    if b.Parent and (Vector3.new(b.Position.X, 0, b.Position.Z) - Vector3.new(testPos.X, 0, testPos.Z)).Magnitude < 2.5 then
                                        tooClose = true; break
                                    end
                                end
                            until not tooClose or attempts > 10
                            return offset
                        end

                        while RainActive and PreviewFolder and PreviewFolder.Parent do
                            local bill = BillTemplate:Clone()
                            bill.Parent = PreviewFolder
                            table.insert(AllRainBills, bill)
                            
                            for _, p in ipairs(bill:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = false; p.CanCollide = false end end
                            local isModel = bill:IsA("Model")
                            local mainPart = isModel and bill.PrimaryPart or bill

                            if mainPart then
                                mainPart.Anchored = false; mainPart.CanCollide = false
                                mainPart.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
                            end

                            local startCFrame = CFrame.new(spawnPos + GetSeparatedSpawnOffset()) * CFrame.Angles(math.random(), math.random(), math.random())
                            if isModel then bill:PivotTo(startCFrame) else bill.CFrame = startCFrame end

                            local fallConn
                            fallConn = RunService.Heartbeat:Connect(function()
                                if not bill or not bill.Parent or not RainActive then if fallConn then fallConn:Disconnect() end return end

                                local currentPos = isModel and bill:GetPivot().Position or bill.Position
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = AllRainBills 
                                
                                local result = Workspace:Raycast(currentPos, Vector3.new(0, -1.5, 0), rayParams)

                                if result then
                                    fallConn:Disconnect()
                                    if isModel then
                                        for _, p in ipairs(bill:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = true end end
                                        bill:PivotTo(CFrame.new(result.Position + Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, math.random(0, 360), 0))
                                    else
                                        bill.Anchored = true
                                        bill.CFrame = CFrame.new(result.Position + Vector3.new(0, bill.Size.Y/2, 0)) * CFrame.Angles(0, math.random(0, 360), 0)
                                    end
                                    table.insert(GroundedBills, bill)

                                    if #GroundedBills > 10 then
                                        local oldBill = table.remove(GroundedBills, 1)
                                        if oldBill and oldBill.Parent then
                                            local tInfo = TweenInfo.new(0.5)
                                            if oldBill:IsA("Model") then
                                                for _, p in ipairs(oldBill:GetDescendants()) do if p:IsA("BasePart") then TweenService:Create(p, tInfo, {Transparency = 1}):Play() end end
                                            else
                                                TweenService:Create(oldBill, tInfo, {Transparency = 1}):Play()
                                            end
                                            Debris:AddItem(oldBill, 0.5)
                                        end
                                    end
                                end
                            end)
                            task.wait(0.5)
                        end
                    end)

                    -- ==================================================
                    -- 5. CONSTRUCCIÓN DEL LIBRO Y LA IMAGEN FLOTANTE
                    -- ==================================================
                    local function CreateFloatingBook()
                        local book = Instance.new("Model")
                        book.Name = "CustomBook"

                        local pages = Instance.new("Part")
                        pages.Size = Vector3.new(1.8, 0.4, 2.5)
                        pages.Color = Color3.fromRGB(255, 204, 0) 
                        pages.Material = Enum.Material.SmoothPlastic
                        pages.Parent = book
                        book.PrimaryPart = pages

                        local topCover = Instance.new("Part")
                        topCover.Size = Vector3.new(1.9, 0.05, 2.6)
                        topCover.Color = Color3.fromRGB(15, 15, 15)
                        topCover.CFrame = pages.CFrame * CFrame.new(0, 0.225, 0)
                        topCover.Parent = book

                        local bottomCover = topCover:Clone()
                        bottomCover.CFrame = pages.CFrame * CFrame.new(0, -0.225, 0)
                        bottomCover.Parent = book

                        local spine = Instance.new("Part")
                        spine.Size = Vector3.new(0.05, 0.5, 2.6)
                        spine.Color = Color3.fromRGB(15, 15, 15)
                        spine.CFrame = pages.CFrame * CFrame.new(-0.925, 0, 0)
                        spine.Parent = book

                        local topSurfaceGui = Instance.new("SurfaceGui", topCover)
                        topSurfaceGui.Face = Enum.NormalId.Top
                        topSurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; topSurfaceGui.PixelsPerStud = 100
                        
                        local topTextLabel = Instance.new("TextLabel", topSurfaceGui)
                        topTextLabel.Size = UDim2.new(1, 0, 1, 0)
                        topTextLabel.BackgroundTransparency = 1; topTextLabel.Text = "REAL SCRIPT ON BACK ☠️"
                        topTextLabel.TextColor3 = Color3.new(1, 1, 1)
                        topTextLabel.Font = Enum.Font.GothamBlack; topTextLabel.TextScaled = true; topTextLabel.Rotation = -90 

                        local bottomSurfaceGui = Instance.new("SurfaceGui", bottomCover)
                        bottomSurfaceGui.Face = Enum.NormalId.Bottom
                        bottomSurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; bottomSurfaceGui.PixelsPerStud = 100
                        
                        local bottomTextLabel = Instance.new("TextLabel", bottomSurfaceGui)
                        bottomTextLabel.Size = UDim2.new(1, 0, 1, 0)
                        bottomTextLabel.BackgroundTransparency = 1; bottomTextLabel.Text = "REAL SCRIPT.. 🖤"
                        bottomTextLabel.TextColor3 = Color3.new(1, 1, 1)
                        bottomTextLabel.Font = Enum.Font.GothamBlack; bottomTextLabel.TextScaled = true; bottomTextLabel.Rotation = -90 

                        for _, p in ipairs(book:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false end end
                        book.Parent = PreviewFolder
                        table.insert(SceneObjects, book) 
                        return book
                    end

                    local CustomBook = CreateFloatingBook()

                    local ImagePart = Instance.new("Part")
                    ImagePart.Name = "KittyItemImage"
                    ImagePart.Size = Vector3.new(3, 3, 0.05) 
                    ImagePart.Anchored = true; ImagePart.CanCollide = false
                    ImagePart.Transparency = 1; ImagePart.Parent = PreviewFolder

                    local DecalFront = Instance.new("Decal", ImagePart)
                    DecalFront.Face = Enum.NormalId.Front
                    DecalFront.Texture = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=420&h=420"
                    DecalFront.Transparency = 0

                    local DecalBack = Instance.new("Decal", ImagePart)
                    DecalBack.Face = Enum.NormalId.Back
                    DecalBack.Texture = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=420&h=420"
                    DecalBack.Transparency = 0

                    local rotConnection
                    local floatTime = 0
                    rotConnection = RunService.RenderStepped:Connect(function(dt)
                        if not ImagePart or not ImagePart.Parent then rotConnection:Disconnect() return end
                        floatTime = floatTime + dt
                        local basePos = spawnPos + Vector3.new(0, 5.2 + math.sin(floatTime * 1.8) * 0.4, 0)
                        
                        local itemCF = CFrame.new(basePos) * CFrame.Angles(0, floatTime * 1.6, 0)
                        ImagePart.CFrame = itemCF

                        if SphereModel and SphereModel.Parent then
                            local sphereCF = CFrame.new(basePos) * CFrame.Angles(floatTime * 0.5, -floatTime * 1.2, floatTime * 0.8)
                            SphereModel.CFrame = sphereCF
                        end

                        if CustomBook and CustomBook.Parent then
                            local bookBasePos = basePos + Vector3.new(0, 4.0, 0) 
                            local pivotOffset = CFrame.new(0.9, 0, 1.25) 
                            local spinCFrame = CFrame.Angles(floatTime * 1.4, floatTime * 2.1, floatTime * 1.6) 
                            CustomBook:PivotTo(CFrame.new(bookBasePos) * spinCFrame * pivotOffset:Inverse())
                        end
                    end)

                    -- ==================================================
                    -- 6. DETECCIÓN POR CONTACTO ESTRICTO Y ANIMACIÓN
                    -- ==================================================
                    local promptState = "Waiting" 
                    local proximityConn

                    proximityConn = RunService.Heartbeat:Connect(function()
                        if not ImagePart or not ImagePart.Parent then
                            if proximityConn then proximityConn:Disconnect() end
                            return
                        end

                        -- [NUEVO]: Verificación Cilíndrica para asegurar que está "chocando" con la mesa y no flotando/lejos.
                        local horizontalDist = Vector2.new(hrp.Position.X - spawnPos.X, hrp.Position.Z - spawnPos.Z).Magnitude
                        local verticalDist = math.abs(hrp.Position.Y - spawnPos.Y)
                        
                        -- Horizontal <= 4.5 studs asegura que está tocando los bordes físicos de una mesa promedio.
                        -- Vertical <= 6.5 asegura que el jugador no esté volando o en un piso superior.
                        if horizontalDist <= 2.5 and verticalDist <= 6.5 and promptState == "Waiting" then
                            promptState = "Prompting"
                            
                            ToggleUIVisibility(false)

                            local clockGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("KittyClockGui")
                            if clockGui then clockGui.Enabled = false end

                            local blurEffect = Instance.new("BlurEffect")
                            blurEffect.Name = "KittyPreviewBlur"
                            blurEffect.Size = 15
                            blurEffect.Parent = Lighting

                            local bindable = Instance.new("BindableFunction")
                            bindable.OnInvoke = function(response)
                                ToggleUIVisibility(true)

                                if response == "Conseguir" then
                                    if proximityConn then proximityConn:Disconnect() end
                                    RainActive = false 
                                    
                                    if blurEffect then blurEffect:Destroy() end
                                    if PreviewFolder and PreviewFolder.Parent then PreviewFolder.Name = "Kitty3DPreview_Sinking" end
                                    
                                    task.spawn(function()
                                        if rotConnection then rotConnection:Disconnect() end
                                        ImagePart.Anchored = true 
                                        
                                        local head = char:FindFirstChild("Head") or hrp
                                        local startTime = tick()
                                        local duration = 2.2 
                                        local startPos = ImagePart.Position

                                        local attractConn
                                        attractConn = RunService.RenderStepped:Connect(function()
                                            if not ImagePart or not ImagePart.Parent then attractConn:Disconnect(); return end

                                            local t = math.clamp((tick() - startTime) / duration, 0, 1)
                                            local ease = t * t * (3 - 2 * t) 
                                            
                                            local startDist = (startPos - head.Position).Magnitude
                                            local currentRadius = startDist * (1 - ease)
                                            local angle = ease * math.pi * 12 
                                            local heightOffset = math.sin(ease * math.pi) * 3.5 
                                            
                                            local orbitPos = head.Position + Vector3.new(
                                                math.cos(angle) * currentRadius, 
                                                heightOffset + (1 - ease) * (startPos.Y - head.Position.Y), 
                                                math.sin(angle) * currentRadius
                                            )
                                            
                                            local spinSpeed = 15 + (ease * 30)
                                            local finalCFrame = CFrame.new(orbitPos) * CFrame.Angles(tick() * spinSpeed, tick() * spinSpeed, math.sin(tick() * 10))
                                            
                                            ImagePart.CFrame = finalCFrame

                                            if DecalFront then DecalFront.Transparency = ease end
                                            if DecalBack then DecalBack.Transparency = ease end

                                            if SphereModel and SphereModel.Parent then
                                                SphereModel.CFrame = finalCFrame * CFrame.Angles(math.rad(45), tick() * spinSpeed * -0.5, 0)
                                                SphereModel.Transparency = 0.55 + (0.45 * ease)
                                            end

                                            if t >= 1 then
                                                attractConn:Disconnect()
                                                ImagePart:Destroy()
                                                if SphereModel then SphereModel:Destroy() end
                                                if clockGui then clockGui:Destroy() end

                                                local function SinkAndDestroy(obj)
                                                    if not obj then return end
                                                    task.spawn(function()
                                                        for i = 1, 20 do 
                                                            if not obj.Parent then break end
                                                            if obj:IsA("Model") then obj:PivotTo(obj:GetPivot() * CFrame.new(0, -0.35, 0))
                                                            elseif obj:IsA("BasePart") then obj.CFrame = obj.CFrame * CFrame.new(0, -0.35, 0) end
                                                            for _, p in ipairs(obj:GetDescendants()) do
                                                                if p:IsA("BasePart") then p.Transparency = math.clamp(p.Transparency + 0.06, 0, 1) end
                                                            end
                                                            if obj:IsA("BasePart") then obj.Transparency = math.clamp(obj.Transparency + 0.06, 0, 1) end
                                                            task.wait(0.03)
                                                        end
                                                        if obj and obj.Parent then obj:Destroy() end
                                                    end)
                                                end

                                                for _, sceneObj in ipairs(SceneObjects) do SinkAndDestroy(sceneObj) end
                                                for _, b in ipairs(AllRainBills) do SinkAndDestroy(b) end

                                                task.delay(1.5, function() if PreviewFolder and PreviewFolder.Parent then PreviewFolder:Destroy() end end)
                                                
                                                UpdateVisualizer(item.id, item.price or "Gratis")
                                                NotifyUser("Ítem Obtenido", item.name .. " ahora está en el Visualizador")
                                            end
                                        end)
                                    end)
                                else
                                    if blurEffect then blurEffect:Destroy() end
                                    if clockGui then clockGui.Enabled = true end 
                                    promptState = "Cooldown"
                                end
                            end

                            pcall(function()
                                StarterGui:SetCore("SendNotification", {
                                    Title = item.name,
                                    Text = "¿Quieres conseguir este ítem?",
                                    Icon = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150",
                                    Duration = 9999999, 
                                    Button1 = "Conseguir",
                                    Button2 = "Rechazar",
                                    Callback = bindable
                                })
                            end)
                            
                        -- Reseteo de Cooldown: Si el jugador se aleja (distancia horizontal > 7.5), podrá volver a tocar la mesa después
                        elseif horizontalDist > 7.5 and promptState == "Cooldown" then
                            promptState = "Waiting"
                        end
                    end)
                end)
                break
            end
            task.wait(0.03)
        end
    end)
end)

ClickBtn.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    holding = false
end)

ClickBtn.MouseButton1Click:Connect(function()
    -- Si fue long-press, no ejecutar el click corto
    if longPress then
        longPress = false
        return
    end

    -- ==================================================
    -- CLICK RÁPIDO → VISUALIZADOR DIRECTO
    -- ==================================================
    CurrentData.Id = tostring(item.id)
    CurrentData.Name = item.name
    CurrentData.Price = item.price and (tostring(item.price) .. " R$") or "Gratis"
    CurrentData.ItemType = item.itemType or "Asset"

    -- Gastar Robux falso
    SpendFakeRobux(item.price)
                        
    -- Cerrar menú de catálogo
    KittyMain.Visible = false
    FloatingBtn.Visible = true

    if UpdateVisualizer then
        UpdateVisualizer(CurrentData.Id, CurrentData.Price)
    end
    if NotifyUser then
        NotifyUser("Visualizador", (item.name or "Ítem") .. " listo. Toca la preview para equipar.")
    end
end)

                ---

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

--#EXTRA: RAYFIELD TAB (ECLIPSE VERSION: GRAPHICS BLACKOUT + HASH DICTIONARY O(1) + 0 LAG)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui") 
local TweenService = game:GetService("TweenService")

-- ==========================================================
-- 🔔 NATIVE ALERT SYSTEM (100% SAFE FOR DELTA / MOBILE OPTIMIZED)
-- ==========================================================
local function UniversalAlert(config)
    task.spawn(function()
        pcall(function()
            local rawText = config.Text or config.Content or ""
            
            -- EL COMPROMISO NATIVO:
            -- Ponemos el nombre del jugador y un emoji de verificado a la derecha.
            local alertData = {
                Title = Players.LocalPlayer.DisplayName .. " 💬",
                Text = rawText,
                Icon = "rbxassetid://9322622699", -- Vuelve tu icono de perfil a la izquierda
                Duration = config.Duration or 5
            }

            if config.Button1 then
                alertData.Button1 = config.Button1
                if config.Button2 then alertData.Button2 = config.Button2 end
                if config.Callback then alertData.Callback = config.Callback end
            end

            StarterGui:SetCore("SendNotification", alertData)
        end)
    end)
end

-- ==========================================================
-- 🧠 ULTRA-FAST CACHE & MEMORY SYSTEMS
-- ==========================================================
local ItemCache = {}
local ZeroPhysics = PhysicalProperties.new(0, 0, 0, 0, 0)

local TrashClasses = {
    FaceControls = true, Animator = true, Animation = true, Script = true, 
    LocalScript = true, Sound = true, ParticleEmitter = true, Trail = true, 
    Fire = true, Smoke = true, Sparkles = true, Decal = true, Texture = true
}

-- ==========================================================
-- 🌑 "ECLIPSE" SYSTEM
-- ==========================================================
local function ToggleEclipse(state)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local eclipseUI = playerGui:FindFirstChild("OptiEclipseBlackout")
    
    if state then
        if not eclipseUI then
            eclipseUI = Instance.new("ScreenGui")
            eclipseUI.Name = "OptiEclipseBlackout"
            eclipseUI.IgnoreGuiInset = true
            eclipseUI.DisplayOrder = 9999 
            
            local blackoutFrame = Instance.new("Frame")
            blackoutFrame.Name = "BlackBackground"
            blackoutFrame.Size = UDim2.new(1, 0, 1, 0)
            blackoutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blackoutFrame.BackgroundTransparency = 1
            blackoutFrame.Parent = eclipseUI
            eclipseUI.Parent = playerGui
        end
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        eclipseUI.BlackBackground.BackgroundTransparency = 0
    else
        if eclipseUI and eclipseUI:FindFirstChild("BlackBackground") then
            pcall(function() settings().Rendering.QualityLevel = "Automatic" end)
            local tween = TweenService:Create(eclipseUI.BlackBackground, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            tween:Play()
            tween.Completed:Connect(function() eclipseUI:Destroy() end)
        end
    end
end

-- ==========================================================
-- 🛡️ ECLIPSE ENGINE (INTERCEPTOR WITH HASH DICTIONARY)
-- ==========================================================
if not getgenv().EclipseRenderHook then
    getgenv().EclipseRenderHook = true
    
    local oldNewindex
    oldNewindex = hookmetamethod(game, "__newindex", function(self, index, value)
        if index == "Parent" and not checkcaller() then
            if typeof(value) == "Instance" and value.ClassName == "ViewportFrame" then
                
                task.spawn(function()
                    pcall(function()
                        if self.ClassName == "Model" then
                            for _, v in ipairs(self:GetDescendants()) do
                                local cName = v.ClassName
                                
                                if cName == "Part" or cName == "MeshPart" or cName == "WedgePart" or cName == "CornerWedgePart" then
                                    v.CastShadow = false
                                    v.CanCollide = false
                                    v.CanTouch = false
                                    v.CanQuery = false
                                    v.Anchored = true
                                    v.Massless = true
                                    v.CustomPhysicalProperties = ZeroPhysics
                                    pcall(function() v.CollisionFidelity = Enum.CollisionFidelity.Box end)
                                    if cName == "MeshPart" then
                                        pcall(function() v.RenderFidelity = Enum.RenderFidelity.Performance end)
                                    end
                                elseif cName == "Humanoid" then
                                    v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                                    v.RequiresNeck = false
                                    pcall(function() v:ChangeState(Enum.HumanoidStateType.Dead) end)
                                    for _, humanoidState in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                                        pcall(function() v:SetStateEnabled(humanoidState, false) end)
                                    end
                                elseif TrashClasses[cName] then
                                    if (cName == "Decal" or cName == "Texture") then
                                        if v.Transparency == 1 then v:Destroy() end
                                    else
                                        v:Destroy()
                                    end
                                end
                            end
                        end
                    end)
                end)
            end
        end
        return oldNewindex(self, index, value)
    end)
end
-- ==========================================================

local ExtraTab = Window:CreateTab("EXTRA", 4483362458)

ExtraTab:CreateSection("⚡ Extreme Optimization & Performance")

ExtraTab:CreateButton({
    Name = "🧹 Extreme Cleanup & Ping Optimizer",
    Callback = function()
        local bindable = Instance.new("BindableFunction")
        bindable.OnInvoke = function(response)
            if response == "Accept" then
                UniversalAlert({Text = "Applying smooth/minimalist mode.", Duration = 3})
                task.spawn(function()
                    task.wait(0.5) 
                    pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 0; Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0; Lighting.ShadowSoftness = 0; Lighting.FogEnd = 9e9 end)
                    for _, effect in ipairs(Lighting:GetChildren()) do pcall(function() if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") then effect:Destroy() end end) end
                    pcall(function() if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.WaterWaveSize = 0; Workspace.Terrain.WaterWaveSpeed = 0; Workspace.Terrain.WaterReflectance = 0; Workspace.Terrain.WaterTransparency = 1; Workspace.Terrain.Decoration = false end end)
                    for _, v in ipairs(Workspace:GetDescendants()) do pcall(function() if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0; v.CastShadow = false elseif v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 elseif v:IsA("SurfaceAppearance") then v:Destroy() end end) end
                    UniversalAlert({Text = "Environment is 100% smooth.", Duration = 3})
                end)
            end
        end
        -- Botones actualizados a Dev English
        UniversalAlert({Text = "The map will lose textures. Continue?", Duration = 10, Button1 = "Accept", Button2 = "Cancel", Callback = bindable})
    end
})

ExtraTab:CreateButton({
    Name = "🌍 Restore Environment (Default)",
    Callback = function()
        local bindable = Instance.new("BindableFunction")
        bindable.OnInvoke = function(response)
            if response == "Accept" then
                task.spawn(function()
                    pcall(function() Lighting.GlobalShadows = true; Lighting.Brightness = 2; Lighting.EnvironmentDiffuseScale = 1; Lighting.EnvironmentSpecularScale = 1; Lighting.ShadowSoftness = 0.2; Lighting.FogEnd = 100000 end)
                    pcall(function() if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.WaterWaveSize = 0.15; Workspace.Terrain.WaterWaveSpeed = 10; Workspace.Terrain.WaterReflectance = 1; Workspace.Terrain.WaterTransparency = 0.3; Workspace.Terrain.Decoration = true end end)
                    for _, v in ipairs(Workspace:GetDescendants()) do pcall(function() if v:IsA("BasePart") and v.Material == Enum.Material.SmoothPlastic then v.Material = Enum.Material.Plastic; v.CastShadow = true elseif v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 end end) end
                    UniversalAlert({Text = "Graphics returned to normal.", Duration = 3})
                end)
            end
        end
        -- Botones actualizados a Dev English
        UniversalAlert({Text = "Do you want to restore original graphics?", Duration = 10, Button1 = "Accept", Button2 = "Cancel", Callback = bindable})
    end
})

ExtraTab:CreateSection("🖼️ Item Visualizer Control")

ExtraTab:CreateToggle({
    Name = "👁️ Toggle Item Visualizer",
    CurrentValue = false,
    Flag = "ToggleItemVisualizer",
    Callback = function(Value)
        pcall(function()
            if Container then Container.Visible = Value
            else
                local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                local visualizerUI = CoreGui:FindFirstChild("VisualizadorItemGUI") or playerGui:FindFirstChild("VisualizadorItemGUI")
                if visualizerUI then if visualizerUI:IsA("ScreenGui") then visualizerUI.Enabled = Value else visualizerUI.Visible = Value end end
            end
        end)
    end
})

ExtraTab:CreateSection("👔 Outfit Manager")

ExtraTab:CreateButton({
    Name = "📁 Toggle Outfit Menu",
    Callback = function()
        task.spawn(function()
            local success, err = pcall(function()
                local targetMenu = nil
                
                if CharMenu then targetMenu = CharMenu
                else
                    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                    local visualizerUI = CoreGui:FindFirstChild("QuirurgicoVisualizer") or playerGui:FindFirstChild("QuirurgicoVisualizer")
                    if visualizerUI then
                        for _, frame in ipairs(visualizerUI:GetChildren()) do
                            if frame:IsA("Frame") then
                                local title = frame:FindFirstChildWhichIsA("TextLabel", true)
                                if title and string.find(string.lower(title.Text), "outfits") then targetMenu = frame break end
                            end
                        end
                    end
                end

                if targetMenu then
                    targetMenu.Visible = not targetMenu.Visible 
                    
                    if targetMenu.Visible then
                        UniversalAlert({Text = "Loading saved avatars...", Duration = 2})
                        
                        if RefreshSavedCharactersGrid then
                            task.spawn(function()
                                pcall(RefreshSavedCharactersGrid)
                            end)
                        end
                    end
                else
                    UniversalAlert({Text = "Outfit menu not detected.", Duration = 3})
                end
            end)
        end)
    end
})

ExtraTab:CreateSection("📱 Device Screen Control (Mobile)")

local function SetOrientation(orientation) pcall(function() Players.LocalPlayer.PlayerGui.ScreenOrientation = orientation end) end
ExtraTab:CreateButton({Name = "➡️ Force Landscape (Right)", Callback = function() SetOrientation(Enum.ScreenOrientation.LandscapeRight) end})
ExtraTab:CreateButton({Name = "⬅️ Force Landscape (Left)", Callback = function() SetOrientation(Enum.ScreenOrientation.LandscapeLeft) end})
ExtraTab:CreateButton({Name = "⬆️ Force Portrait", Callback = function() SetOrientation(Enum.ScreenOrientation.Portrait) end})
ExtraTab:CreateButton({Name = "🔄 Auto Sensor Landscape", Callback = function() SetOrientation(Enum.ScreenOrientation.SensorLandscape) end})
ExtraTab:CreateButton({Name = "🌐 Free Sensor (Full Rotation)", Callback = function() SetOrientation(Enum.ScreenOrientation.Sensor) end})

ExtraTab:CreateSection("🔍 Smart Item Visualizer (Cached)")

ExtraTab:CreateInput({
    Name = "👁️ Preview Item via ID",
    PlaceholderText = "Paste Item ID here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local itemID = tonumber(Text)
        if itemID and itemID > 0 then
            
            local itemInfo
            if ItemCache[itemID] then
                itemInfo = ItemCache[itemID]
            else
                local success, data = pcall(function() return MarketplaceService:GetProductInfo(itemID) end)
                if success and data then
                    itemInfo = data
                    ItemCache[itemID] = data 
                end
            end

            if itemInfo then
                pcall(function()
                    if CurrentData then CurrentData.Id = tostring(itemID); CurrentData.Price = tostring(itemInfo.PriceInRobux or 0); if itemInfo.Name then CurrentData.Name = itemInfo.Name end end
                    if UpdateVisualizer then UpdateVisualizer(itemID, itemInfo.PriceInRobux and (itemInfo.PriceInRobux .. " R$") or "Free") end
                end)
                UniversalAlert({Text = "Showing: " .. (itemInfo.Name or "Unknown Item"), Duration = 3})
            else
                UniversalAlert({Text = "The entered ID does not exist or network failed.", Duration = 4})
            end
        else
            UniversalAlert({Text = "Please enter valid numbers only.", Duration = 3})
        end
    end
})

Rayfield:LoadConfiguration()
