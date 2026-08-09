-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v4.0 - REAL ED)
-- Optimizado para Delta iOS / Rayfield UI
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- SISTEMA DE VISUALIZADOR HUD (A LA DERECHA)
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then
    CoreGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(0, 160, 0, 160)
ImagePreview.Position = UDim2.new(1, -180, 0.5, -80) -- Posicionado a la derecha
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
ImagePreview.BorderSizePixel = 0
ImagePreview.Visible = false
ImagePreview.Parent = VisualizerGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ImagePreview

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(150, 150, 150)
UIStroke.Thickness = 2
UIStroke.Parent = ImagePreview

-- Subrayado Rojo Inferior
local RedUnderline = Instance.new("Frame")
RedUnderline.Size = UDim2.new(1, 0, 0, 4)
RedUnderline.Position = UDim2.new(0, 0, 1, -4) -- Pegado al borde inferior adentro de la imagen
RedUnderline.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedUnderline.BorderSizePixel = 0
RedUnderline.ZIndex = 2
RedUnderline.Parent = ImagePreview

-- Etiqueta de Precio (FREE o ROBUX - Sin contenedor ni borde adicional)
local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(1, 0, 0, 30)
PriceTag.Position = UDim2.new(0, 0, 1, 5) -- Sobresale abajo del frame
PriceTag.BackgroundTransparency = 1 -- Contenedor negro eliminado
PriceTag.RichText = true
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 18
PriceTag.Parent = ImagePreview

-- ==========================================================
-- DICCIONARIO DE CATEGORÍAS (ROBLOX CATALOG)
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script LUA", [8] = "Sombrero", [10] = "Modelo", [11] = "Camisa", 
    [12] = "Pantalón", [17] = "Cabeza", [18] = "Cara", [19] = "Gear / Tool", 
    [24] = "Animación", [38] = "Plugin / Script", [41] = "Pelo", [42] = "Acc. Cara",
    [43] = "Acc. Cuello", [44] = "Acc. Hombro", [45] = "Acc. Frontal", [46] = "Acc. Trasero", 
    [47] = "Acc. Cintura"
}

-- Mapeo para la API de búsqueda de Roblox (Requiere números, no texto)
local CategoryToNumber = {
    ["All"] = 1,
    ["Accessories"] = 11,
    ["Clothing"] = 3,
    ["Gear"] = 5,
    ["Animations"] = 12
}

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v4.0",
   LoadingTitle = "Motor de Catálogo Real...",
   LoadingSubtitle = "Búsqueda + Tools + Scripts",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CurrentData = { Name = "Ninguno", Id = "0", Price = 0, Category = "Desconocido" }
local SearchResultsCache = {}

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

-- ==========================================================
-- FUNCION: ACTUALIZAR VISUALIZADOR
-- ==========================================================
local function UpdateVisualizer(id, price)
    ImagePreview.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    ImagePreview.Visible = true

    if price == 0 or price == "Gratis" then
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50) -- Solo verde puro
    else
        PriceTag.Text = '<img src="rbxassetid://11560341824" width="16" height="16"/> ' .. tostring(price)
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0) -- Dorado puro (sin contornos ni fondos)
    end
end

-- ==========================================================
-- 1. BUSCADOR INTELIGENTE POR NOMBRE Y CATEGORÍA
-- ==========================================================
Panel:CreateSection("🔍 Búsqueda en Vivo (Nombre Real)")

local SearchCategory = "All"
Panel:CreateDropdown({
   Name = "Filtro de Categoría",
   Options = {"All", "Accessories", "Clothing", "Gear", "Animations"},
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
   PlaceholderText = "Ej: Dominus, Espada, Script...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       Rayfield:Notify({Title = "Buscando...", Content = "Conectando a la base de datos de Roblox.", Duration = 2})
       
       -- Arreglo del proxy: Convirtiendo el texto de categoría al número que la API exige
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
                   task.wait(0.05) -- Delay preventivo para evitar el "Rate Limit" (Error de Proxy) de Roblox.
               end
               
               if #newOptions > 0 then
                   SpinnerDropdown:Refresh(newOptions, true)
                   Rayfield:Notify({Title = "Éxito", Content = "Se encontraron " .. tostring(#newOptions) .. " resultados.", Duration = 3})
               else
                   Rayfield:Notify({Title = "Sin resultados", Content = "Intenta con otro nombre.", Duration = 3})
               end
           end
       else
           Rayfield:Notify({Title = "Error de Red", Content = "El proxy falló o estás limitando peticiones.", Duration = 3})
       end
   end,
})

-- ==========================================================
-- 2. BUSCADOR CLÁSICO POR ID + RANDOMIZER
-- ==========================================================
Panel:CreateSection("Búsqueda Directa por ID")

local DirectIdInput
DirectIdInput = Panel:CreateInput({
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

-- Nuevo botón para generar un ID aleatorio e insertarlo en el input superior
Panel:CreateButton({
   Name = "🎲 Randomizar ID Aleatorio",
   Callback = function()
       local randomId = tostring(math.random(10000000, 999999999))
       if DirectIdInput then
           DirectIdInput:Set(randomId) -- Auto-inserta el número en el Input
       end
   end,
})

-- ==========================================================
-- 3. MOTOR DE EQUIPAMIENTO MULTI-PROPÓSITO (EL NÚCLEO)
-- ==========================================================
Panel:CreateSection("🧪 Aplicar / Probar (Motor Inteligente)")

Panel:CreateButton({
   Name = "⚡ EQUIPAR / EJECUTAR ITEM",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       local Hum = Char:FindFirstChildOfClass("Humanoid")
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end

       if CurrentData.Category == "Script LUA" or CurrentData.Category == "Plugin / Script" then
           local s, err = pcall(function() require(assetId) end)
           if s then
               Rayfield:Notify({Title = "Script Ejecutado", Content = "Módulo cargado con éxito.", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "No es un MainModule público.", Duration = 3})
           end
           return
       end

       local success, err = pcall(function()
           local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
           local item = objects[1]
           if not item then return end

           if item:IsA("Tool") or item:IsA("HopperBin") then
               item.Parent = LocalPlayer.Backpack
               if Hum then Hum:EquipTool(item) end
               Rayfield:Notify({Title = "Item Equipado", Content = "Se añadió a tu inventario y mano.", Duration = 3})

           elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
               for _, v in pairs(Char:GetChildren()) do
                   if v.ClassName == item.ClassName then v:Destroy() end
               end
               item.Parent = Char

           elseif item:IsA("Accessory") then
               if Hum then Hum:AddAccessory(item) end

           elseif item:IsA("Decal") then
               local head = Char:FindFirstChild("Head")
               if head then
                   local currentFace = head:FindFirstChildOfClass("Decal")
                   if currentFace then currentFace.Texture = item.Texture else item.Parent = head end
               end

           elseif item:IsA("Animation") then
               if Hum then
                   local animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
                   local track = animator:LoadAnimation(item)
                   track:Play()
               end

           else
               local clone = item:Clone()
               clone.Parent = Char
           end
       end)

       if not success then
           Rayfield:Notify({Title = "Fallo", Content = "El ID no es compatible o privado.", Duration = 3})
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador Flotante",
   Callback = function()
       ImagePreview.Visible = not ImagePreview.Visible
   end,
})
