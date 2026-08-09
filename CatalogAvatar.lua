-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v5.0 - DEFINITIVO)
-- Fix de UI, Búsquedas Cancelables y Motor Híbrido de Equipamiento
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- SISTEMA DE VISUALIZADOR HUD (ESTRUCTURA CORREGIDA)
-- ==========================================================
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then
    CoreGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

-- Contenedor principal invisible para mantener todo junto
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 160, 0, 195)
Container.Position = UDim2.new(1, -180, 0.5, -95)
Container.BackgroundTransparency = 1
Container.Visible = false
Container.Parent = VisualizerGui

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(1, 0, 0, 160)
ImagePreview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ImagePreview.ClipsDescendants = true -- Solo recorta lo que hay dentro de la imagen
ImagePreview.Parent = Container

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ImagePreview

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(150, 150, 150)
UIStroke.Thickness = 2
UIStroke.Parent = ImagePreview

-- Subrayado Rojo (Más corto para no tocar los bordes redondeados)
local RedUnderline = Instance.new("Frame")
RedUnderline.Size = UDim2.new(1, -20, 0, 4) -- 20 pixeles menos de ancho
RedUnderline.Position = UDim2.new(0.5, 0, 1, -4)
RedUnderline.AnchorPoint = Vector2.new(0.5, 0) -- Centrado perfecto
RedUnderline.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedUnderline.BorderSizePixel = 0
RedUnderline.ZIndex = 2
RedUnderline.Parent = ImagePreview

-- Etiqueta de Precio (Afuera de la imagen para no ser borrada por ClipsDescendants)
local PriceTag = Instance.new("TextLabel")
PriceTag.Size = UDim2.new(1, 0, 0, 30)
PriceTag.Position = UDim2.new(0, 0, 0, 165) -- Posicionado justo debajo de la imagen
PriceTag.BackgroundTransparency = 1 
PriceTag.RichText = true
PriceTag.Font = Enum.Font.GothamBold
PriceTag.TextSize = 18
PriceTag.Parent = Container

-- ==========================================================
-- DICCIONARIO DE CATEGORÍAS
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [5] = "Script LUA", [8] = "Sombrero", [9] = "Place", [10] = "Modelo", 
    [11] = "Camisa", [12] = "Pantalón", [17] = "Cabeza", [18] = "Cara", [19] = "Gear / Tool", 
    [24] = "Animación", [27] = "Torso", [28] = "Brazo Der", [29] = "Brazo Izq", 
    [30] = "Pierna Izq", [31] = "Pierna Der", [38] = "Plugin / Script", [41] = "Pelo", 
    [42] = "Acc. Cara", [43] = "Acc. Cuello", [44] = "Acc. Hombro", [45] = "Acc. Frontal", 
    [46] = "Acc. Trasero", [47] = "Acc. Cintura"
}

local CategoryToNumber = {
    ["All"] = 1,
    ["Accessories"] = 11,
    ["Clothing"] = 3,
    ["Gear"] = 5,
    ["Animations"] = 12,
    ["Characters"] = 4
}

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v5.0",
   LoadingTitle = "Iniciando Motor Definitivo...",
   LoadingSubtitle = "Fix UI & Búsquedas Híbridas",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CurrentData = { Name = "Ninguno", Id = "0", Price = 0, Category = "Desconocido" }
local SearchResultsCache = {}
local CurrentSearchTicket = 0 -- Variable para cancelar búsquedas solapadas

local Panel = Window:CreateTab("🏥 Catálogo Real", 4483362458)

-- ==========================================================
-- FUNCION: ACTUALIZAR VISUALIZADOR
-- ==========================================================
local function UpdateVisualizer(id, price)
    ImagePreview.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
    Container.Visible = true

    if price == 0 or price == "Gratis" then
        PriceTag.Text = "FREE"
        PriceTag.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        PriceTag.Text = '<img src="rbxassetid://11560341824" width="16" height="16"/> ' .. tostring(price)
        PriceTag.TextColor3 = Color3.fromRGB(255, 215, 0)
    end
end

-- ==========================================================
-- 1. BUSCADOR INTELIGENTE
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
   PlaceholderText = "Ej: Dominus, Espada, Script...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       
       -- SISTEMA ANTI-SOLAPAMIENTO: Aumentamos el ticket para cancelar loops viejos
       CurrentSearchTicket = CurrentSearchTicket + 1
       local myTicket = CurrentSearchTicket
       
       Rayfield:Notify({Title = "Buscando...", Content = "Conectando a Roblox...", Duration = 2})
       
       local apiCategory = CategoryToNumber[SearchCategory] or 1
       local url = "https://catalog.roproxy.com/v1/search/items?category="..tostring(apiCategory).."&limit=8&keyword=" .. HttpService:UrlEncode(Text)
       
       local success, response = pcall(function() return game:HttpGet(url) end)
       if success and response then
           local decoded = HttpService:JSONDecode(response)
           if decoded and decoded.data then
               local newOptions = {}
               SearchResultsCache = {} 
               
               for _, item in ipairs(decoded.data) do
                   -- SI EL TICKET CAMBIÓ (hiciste otra búsqueda), ABORTAR ESTE LOOP
                   if CurrentSearchTicket ~= myTicket then return end
                   
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
                   -- Tiempo ligeramente aumentado para asegurar estabilidad del proxy
                   task.wait(0.2) 
               end
               
               -- Solo actualizar UI si no cancelaste la búsqueda
               if CurrentSearchTicket == myTicket then
                   if #newOptions > 0 then
                       SpinnerDropdown:Refresh(newOptions, true)
                       Rayfield:Notify({Title = "Éxito", Content = "Resultados cargados.", Duration = 3})
                   else
                       Rayfield:Notify({Title = "Sin resultados", Content = "Intenta con otro nombre.", Duration = 3})
                   end
               end
           end
       else
           Rayfield:Notify({Title = "Error de Red", Content = "El proxy falló. Intenta de nuevo.", Duration = 3})
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

Panel:CreateButton({
   Name = "🎲 Randomizar ID Aleatorio",
   Callback = function()
       local randomId = tostring(math.random(1000000, 999999999))
       if DirectIdInput then DirectIdInput:Set(randomId) end
   end,
})

-- ==========================================================
-- 3. MOTOR HÍBRIDO DE EQUIPAMIENTO (EL MÁS ESTABLE)
-- ==========================================================
Panel:CreateSection("🧪 Aplicar / Probar (Motor Híbrido)")

Panel:CreateButton({
   Name = "⚡ EQUIPAR / EJECUTAR ITEM",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       local Hum = Char:FindFirstChildOfClass("Humanoid")
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end

       local s_info, info = pcall(function() return MarketplaceService:GetProductInfo(assetId) end)
       if s_info and info and info.AssetTypeId == 9 then
           Rayfield:Notify({Title = "Bloqueado", Content = "Detectado Place ID. Bloqueado para evitar crash.", Duration = 3})
           return
       end

       if CurrentData.Category == "Script LUA" or CurrentData.Category == "Plugin / Script" then
           local s, err = pcall(function() require(assetId) end)
           if s then
               Rayfield:Notify({Title = "Script Ejecutado", Content = "Módulo cargado.", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "No es un MainModule público.", Duration = 3})
           end
           return
       end

       -- PASO 1: Intentar Método Tradicional (Perfecto para Gorros y Accesorios públicos)
       local classicSuccess = false
       local objSuccess, err = pcall(function()
           local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
           local item = objects[1]
           if not item then return end

           if item:IsA("Accessory") then
               if Hum then Hum:AddAccessory(item) end
               classicSuccess = true
           elseif item:IsA("Tool") or item:IsA("HopperBin") then
               item.Parent = LocalPlayer.Backpack
               if Hum then Hum:EquipTool(item) end
               classicSuccess = true
           elseif item:IsA("Animation") then
               if Hum then
                   local animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
                   animator:LoadAnimation(item):Play()
               end
               classicSuccess = true
           end
       end)

       -- PASO 2: Si el método clásico falló (Privado) o si es ropa, usamos el Método Nativo
       if not classicSuccess and s_info and info and Hum then
           local nativeMapping = {
               [2] = "GraphicTShirt", [11] = "Shirt", [12] = "Pants", 
               [17] = "Head", [18] = "Face", [27] = "Torso", [28] = "RightArm", 
               [29] = "LeftArm", [30] = "LeftLeg", [31] = "RightLeg",
               [8] = "HatAccessory", [41] = "HairAccessory", [42] = "FaceAccessory",
               [43] = "NeckAccessory", [44] = "ShoulderAccessory", [45] = "FrontAccessory", 
               [46] = "BackAccessory", [47] = "WaistAccessory"
           }

           if nativeMapping[info.AssetTypeId] then
               local desc = Hum:GetAppliedDescription()
               local propName = nativeMapping[info.AssetTypeId]
               
               if string.find(propName, "Accessory") then
                   local currentVal = desc[propName]
                   -- ARREGLO: Evita comas al principio de la cadena
                   if currentVal == nil or currentVal == "" then
                       desc[propName] = tostring(assetId)
                   else
                       desc[propName] = currentVal .. "," .. tostring(assetId)
                   end
               else
                   desc[propName] = assetId
               end

               pcall(function() Hum:ApplyDescription(desc) end)
               Rayfield:Notify({Title = "Equipado", Content = "Cargado vía Motor Nativo.", Duration = 2})
               return
           end
       end

       if not objSuccess and not classicSuccess then
           Rayfield:Notify({Title = "Fallo", Content = "Objeto privado o incompatible.", Duration = 3})
       elseif classicSuccess then
           Rayfield:Notify({Title = "Éxito", Content = "Equipado con éxito.", Duration = 2})
       end
   end,
})

Panel:CreateButton({
   Name = "👁️ Ocultar / Mostrar Visualizador",
   Callback = function()
       Container.Visible = not Container.Visible
   end,
})
