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
-- SISTEMA DE VISUALIZADOR HUD (ABAJO AL CENTRO)
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then
    CoreGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(0, 160, 0, 160)
ImagePreview.Position = UDim2.new(0.5, -80, 1, -220) -- Abajo al centro
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

-- Etiqueta de Precio (FREE o ROBUX)
local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(1, 0, 0, 30)
PriceTag.Position = UDim2.new(0, 0, 1, -15) -- Sobresale abajo del frame
PriceTag.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PriceTag.TextColor3 = Color3.fromRGB(255, 255, 255)
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 16
PriceTag.Parent = ImagePreview

local PriceCorner = Instance.new("UICorner")
PriceCorner.CornerRadius = UDim.new(0, 8)
PriceCorner.Parent = PriceTag

local PriceStroke = Instance.new("UIStroke")
PriceStroke.Color = Color3.fromRGB(100, 100, 100)
PriceStroke.Thickness = 1
PriceStroke.Parent = PriceTag

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
local SearchResultsCache = {} -- Guarda los resultados de la búsqueda para sincronizar el spinner

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

-- ==========================================================
-- FUNCION: ACTUALIZAR VISUALIZADOR
-- ==========================================================
local function UpdateVisualizer(id, price)
    ImagePreview.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    ImagePreview.Visible = true

    if price == 0 or price == "Gratis" then
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50) -- Verde Brillante
        PriceStroke.Color = Color3.fromRGB(50, 255, 50)
    else
        PriceTag.Text = "💰 " .. tostring(price)
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0) -- Dorado (Robux)
        PriceStroke.Color = Color3.fromRGB(255, 215, 0)
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
       
       -- Uso de API Proxy para buscar el nombre real en Roblox
       local url = "https://catalog.roproxy.com/v1/search/items?category="..SearchCategory.."&limit=10&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
       if success and response then
           local decoded = HttpService:JSONDecode(response)
           if decoded and decoded.data then
               local newOptions = {}
               SearchResultsCache = {} -- Limpiar caché
               
               for _, item in ipairs(decoded.data) do
                   -- Obtener datos extra (Nombre real y Precio real) con MarketplaceService
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
-- 2. BUSCADOR CLÁSICO POR ID (Opcional)
-- ==========================================================
Panel:CreateSection("Búsqueda Directa por ID")
Panel:CreateInput({
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

       -- MATIZ 1: ¿Es un Script / MainModule?
       if CurrentData.Category == "Script LUA" or CurrentData.Category == "Plugin / Script" then
           local s, err = pcall(function()
               require(assetId)
           end)
           if s then
               Rayfield:Notify({Title = "Script Ejecutado", Content = "Módulo cargado con éxito.", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "No es un MainModule público.", Duration = 3})
           end
           return
       end

       -- MATIZ 2: Para el resto de objetos (Carga física)
       local success, err = pcall(function()
           local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
           local item = objects[1]
           if not item then return end

           -- A. Si es un TOOL (Gear / Espada / Item usable)
           if item:IsA("Tool") or item:IsA("HopperBin") then
               item.Parent = LocalPlayer.Backpack
               if Hum then Hum:EquipTool(item) end
               Rayfield:Notify({Title = "Item Equipado", Content = "Se añadió a tu inventario y mano.", Duration = 3})

           -- B. Si es Ropa Clásica
           elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
               for _, v in pairs(Char:GetChildren()) do
                   if v.ClassName == item.ClassName then v:Destroy() end
               end
               item.Parent = Char

           -- C. Si es Accesorio o Pelo
           elseif item:IsA("Accessory") then
               if Hum then Hum:AddAccessory(item) end

           -- D. Si es Cara (Face)
           elseif item:IsA("Decal") then
               local head = Char:FindFirstChild("Head")
               if head then
                   local currentFace = head:FindFirstChildOfClass("Decal")
                   if currentFace then currentFace.Texture = item.Texture else item.Parent = head end
               end

           -- E. Si es Animación
           elseif item:IsA("Animation") then
               if Hum then
                   local animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
                   local track = animator:LoadAnimation(item)
                   track:Play()
               end

           -- F. Modelos Varios
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
