-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v6.0)
-- Búsquedas Instantáneas (0 Rate Limits) y Motor Categorizado
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- SISTEMA DE VISUALIZADOR HUD (ESTRUCTURA PERFECTA)
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

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true
ImagePreview.Parent = Container

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

-- SOLUCIÓN LOGO DE ROBUX: Texto estandarizado y posicionado correctamente
local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(1, 0, 0, 30)
PriceTag.Position = UDim2.new(0, 0, 0, 165)
PriceTag.BackgroundTransparency = 1 
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 18
PriceTag.Parent = Container

-- ==========================================================
-- DICCIONARIO DE CATEGORÍAS
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
    ["All"] = 1,
    ["Accessories"] = 11,
    ["Clothing"] = 3,
    ["Characters"] = 4,
    ["Gear"] = 5,
    ["Animations"] = 12
}

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v6.0",
   LoadingTitle = "Motor Nativo Categorizado...",
   LoadingSubtitle = "0 Rate Limits | Fix de Caras y Accesorios",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CurrentData = { Name = "Ninguno", Id = "0", Price = 0, Category = "Desconocido" }
local SearchResultsCache = {}

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

local function UpdateVisualizer(id, price)
    ImagePreview.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    Container.Visible = true

    if price == 0 or price == "Gratis" then
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        -- Aplicando R$ en lugar de imagen para garantizar visibilidad
        PriceTag.Text = "R$ " .. tostring(price)
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0)
    end
end

-- ==========================================================
-- 1. BUSCADOR INSTANTÁNEO (FIX ERROR DE RED)
-- ==========================================================
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
   PlaceholderText = "Ej: Dominus, Cheeks, Espada...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       Rayfield:Notify({Title = "Buscando...", Content = "Petición directa a Roblox...", Duration = 2})
       
       -- SOLUCIÓN ERROR DE RED: Usamos el endpoint '/details' que trae todo en 1 solo request
       local apiCategory = CategoryToNumber[SearchCategory] or 1
       local url = "https://catalog.roproxy.com/v1/search/items/details?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
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
                   Rayfield:Notify({Title = "Éxito", Content = "Búsqueda instantánea completada.", Duration = 3})
               else
                   Rayfield:Notify({Title = "Sin resultados", Content = "Intenta con otro nombre.", Duration = 3})
               end
           end
       else
           Rayfield:Notify({Title = "Error", Content = "Falló la conexión al proxy.", Duration = 3})
       end
   end,
})

-- ==========================================================
-- 2. BUSCADOR CLÁSICO POR ID + RANDOMIZER
-- ==========================================================
Panel:CreateSection("Búsqueda Directa por ID")

local DirectIdInput = Panel:CreateInput({
   Name = "Ingresar ID Directa",
   PlaceholderText = "Ej: 144275038",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if not numericId then return end
       local s, info = pcall(function() return MarketplaceService:GetProductInfo(numericId) end)
       if s and info then
           CurrentData.Id = tostring(numericId)
           CurrentData.Price = info.PriceInRobux or 0
           UpdateVisualizer(numericId, CurrentData.Price)
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

-- ==========================================================
-- 3. MOTOR CATEGORIZADO (SOLUCIÓN CARAS, ROPA Y ACCESORIOS)
-- ==========================================================
Panel:CreateSection("🧪 Aplicar / Probar (Motor Natural)")

Panel:CreateButton({
   Name = "⚡ EQUIPAR NATURALEZA DEL ITEM",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       local Hum = Char:FindFirstChildOfClass("Humanoid")
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end

       local s_info, info = pcall(function() return MarketplaceService:GetProductInfo(assetId) end)
       if not s_info or not info then return end
       local typeId = info.AssetTypeId

       -- Bloqueo de Crashes
       if typeId == 9 then
           Rayfield:Notify({Title = "Bloqueado", Content = "Es un juego (Place). No se puede equipar.", Duration = 3})
           return
       end

       -- CASO 1: Caras (Faces) y Texturas (Decals)
       if typeId == 18 or typeId == 13 then
           local head = Char:FindFirstChild("Head")
           if head then
               local face = head:FindFirstChildOfClass("Decal") or Instance.new("Decal", head)
               face.Name = "face"
               face.Texture = "rbxassetid://" .. tostring(assetId)
               Rayfield:Notify({Title = "Éxito", Content = "Cara/Textura equipada nativamente.", Duration = 2})
           end
           return
       end

       -- CASO 2: Ropa Clásica 2D (Camisas, Pantalones, T-Shirts)
       local clothesMapping = { [2] = {"ShirtGraphic", "Graphic"}, [11] = {"Shirt", "ShirtTemplate"}, [12] = {"Pants", "PantsTemplate"} }
       if clothesMapping[typeId] then
           local className = clothesMapping[typeId][1]
           local propertyName = clothesMapping[typeId][2]
           
           local clothingItem = Char:FindFirstChildOfClass(className) or Instance.new(className, Char)
           clothingItem.Name = className
           clothingItem[propertyName] = "rbxassetid://" .. tostring(assetId)
           Rayfield:Notify({Title = "Éxito", Content = "Ropa aplicada nativamente.", Duration = 2})
           return
       end

       -- CASO 3: Accesorios 3D (Pelos, Gorros, Espaldas, etc.)
       local isAccessory = { [8]=true, [41]=true, [42]=true, [43]=true, [44]=true, [45]=true, [46]=true, [47]=true }
       if isAccessory[typeId] then
           local objSuccess, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId)) end)
           if objSuccess and objects and objects[1] and objects[1]:IsA("Accessory") then
               if Hum then Hum:AddAccessory(objects[1]) end
               Rayfield:Notify({Title = "Éxito", Content = "Accesorio (Pelo/Gorro) equipado.", Duration = 2})
               return
           end
       end

       -- CASO 4: Partes del Cuerpo (Brazos, Piernas, Torsos, Cabezas Dinámicas)
       local bodyParts = { [17] = "Head", [27] = "Torso", [28] = "RightArm", [29] = "LeftArm", [30] = "LeftLeg", [31] = "RightLeg" }
       if bodyParts[typeId] and Hum then
           local desc = Hum:GetAppliedDescription()
           desc[bodyParts[typeId]] = assetId
           pcall(function() Hum:ApplyDescription(desc) end)
           Rayfield:Notify({Title = "Éxito", Content = "Cuerpo aplicado por HumanoidDescription.", Duration = 2})
           return
       end

       -- CASO 5: Scripts, Tools y Animaciones (Fallback)
       if typeId == 19 then -- Gear/Tool
           local s, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId)) end)
           if s and objects and objects[1] and objects[1]:IsA("Tool") then
               objects[1].Parent = LocalPlayer.Backpack
               if Hum then Hum:EquipTool(objects[1]) end
               Rayfield:Notify({Title = "Éxito", Content = "Tool añadida al inventario.", Duration = 2})
           end
       elseif typeId == 24 then -- Animación
           local s, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId)) end)
           if s and objects and objects[1] and objects[1]:IsA("Animation") then
               local animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
               animator:LoadAnimation(objects[1]):Play()
               Rayfield:Notify({Title = "Éxito", Content = "Animación reproduciendo.", Duration = 2})
           end
       else
           Rayfield:Notify({Title = "Aviso", Content = "Tipo de item complejo o privado.", Duration = 3})
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador",
   Callback = function()
       Container.Visible = not Container.Visible
   end,
})
