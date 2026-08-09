-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v8.5)
-- Fix Buscador de Nombres + Centrado de Precio + Motor v3.0
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- SISTEMA DE VISUALIZADOR HUD (PRECIO Y ROBUX CENTRADOS)
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

-- Contenedor del Precio
local PriceFrame = Instance.new("Frame")
PriceFrame.Size = UDim2.new(1, 0, 0, 30)
PriceFrame.Position = UDim2.new(0, 0, 0, 165)
PriceFrame.BackgroundTransparency = 1
PriceFrame.Parent = Container

-- Layout para centrar automáticamente el Icono + Texto en el medio exacto
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

-- ==========================================================
-- FUNCION: ACTUALIZAR VISUALIZADOR CON CENTRADO
-- ==========================================================
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
-- DICCIONARIO DE TIPOS DE ASSETS
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script LUA", [8] = "Hat/Accesorio", [9] = "Place", [10] = "Modelo", 
    [11] = "Camisa", [12] = "Pantalón", [13] = "Decal", [17] = "Cabeza", [18] = "Cara", [19] = "Gear", 
    [24] = "Animación", [27] = "Torso", [28] = "Brazo Der", [29] = "Brazo Izq", 
    [30] = "Pierna Izq", [31] = "Pierna Der", [38] = "Plugin / Script", [41] = "Pelo", 
    [42] = "Accesorio de Cara", [43] = "Accesorio de Cuello", [44] = "Accesorio de Hombro", [45] = "Accesorio Frontal", 
    [46] = "Accesorio Trasero", [47] = "Accesorio de Cintura"
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
   Name = "🏥 Avatar Catalog Quirúrgico Pro v8.5",
   LoadingTitle = "Motor v3.0 Integrado...",
   LoadingSubtitle = "Fix Búsqueda + Centrado Perfecto",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CurrentData = { Name = "Ninguno", Id = "0", Price = "0 R$", Category = "Desconocido" }
local SearchResultsCache = {}

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

-- ==========================================================
-- 1. BUSCADOR EN VIVO (FIX CONEXIÓN Y PROXY)
-- ==========================================================
Panel:CreateSection("🔍 Búsqueda en Vivo (Nombre o Categoría)")

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
   PlaceholderText = "Ej: Dominus, Beanie, Cheeks...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       Rayfield:Notify({Title = "Buscando...", Content = "Petición a la base de datos...", Duration = 2})
       
       local apiCategory = CategoryToNumber[SearchCategory] or 1
       local url = "https://catalog.roproxy.com/v1/search/items?category="..tostring(apiCategory).."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
       if success and response then
           local decoded = HttpService:JSONDecode(response)
           if decoded and decoded.data then
               local newOptions = {}
               SearchResultsCache = {} 
               
               for _, item in ipairs(decoded.data) do
                   local s, info = pcall(function() return MarketplaceService:GetProductInfo(item.id) end)
                   if s and info then
                       local priceStr = info.PriceInRobux or 0
                       local catName = AssetTypeNames[info.AssetTypeId] or "Item"
                       local listName = string.format("%s - [%s]", info.Name, catName)
                       
                       table.insert(newOptions, listName)
                       SearchResultsCache[listName] = {
                           Id = item.id,
                           Name = info.Name,
                           Price = priceStr,
                           Category = catName
                       }
                   end
                   task.wait(0.05)
               end
               
               if #newOptions > 0 then
                   SpinnerDropdown:Refresh(newOptions, true)
                   Rayfield:Notify({Title = "Éxito", Content = "Resultados listados.", Duration = 3})
               else
                   Rayfield:Notify({Title = "Sin resultados", Content = "Intenta con otro término.", Duration = 3})
               end
           end
       else
           Rayfield:Notify({Title = "Error de Red", Content = "No se pudo conectar al catálogo.", Duration = 3})
       end
   end,
})

-- ==========================================================
-- 2. BUSCADOR DIRECTO POR ID
-- ==========================================================
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

-- ==========================================================
-- 3. PROBADOR EN TIEMPO REAL (LÓGICA EXACTA DE LA V3.0)
-- ==========================================================
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
           Rayfield:Notify({
              Title = "Transformación Aplicada",
              Content = "Se equipó: " .. CurrentData.Name,
              Duration = 3,
           })
       else
           Rayfield:Notify({
              Title = "Fallo al aplicar",
              Content = "Tu ejecutor puede no soportar GetObjects o el ID no es compatible.",
              Duration = 4,
           })
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador",
   Callback = function()
       Container.Visible = not Container.Visible
   end,
})

-- ==========================================================
-- 4. OPTIMIZACIÓN Y LIMPIEZA ANTI-CRASH (iOS DELTA)
-- ==========================================================
Panel:CreateSection("⚙️ Rendimiento Quirúrgico (Anti-Crash iOS)")

Panel:CreateButton({
   Name = "🧹 Limpiar Caché y Liberar RAM",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({
          Title = "RAM Purgada",
          Content = "Memoria optimizada para evitar crashes.",
          Duration = 2.5,
       })
   end,
})
