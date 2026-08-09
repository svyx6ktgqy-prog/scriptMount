-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v3.0)
-- Optimizado para Delta iOS / Rayfield UI
-- ==========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- SISTEMA DE VISUALIZADOR (FRAME DE VISTA PREVIA)
-- ==========================================================
-- Limpiamos visualizadores anteriores para evitar sobreposición en ejecuciones múltiples
if CoreGui:FindFirstChild("QuirurgicoVisualizer") then
    CoreGui.QuirurgicoVisualizer:Destroy()
end

local VisualizerGui = Instance.new("ScreenGui")
VisualizerGui.Name = "QuirurgicoVisualizer"
VisualizerGui.Parent = CoreGui

local ImagePreview = Instance.new("ImageLabel")
ImagePreview.Size = UDim2.new(0, 160, 0, 160)
ImagePreview.Position = UDim2.new(1, -180, 0.5, -80) -- Centro-Derecha de la pantalla
ImagePreview.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ImagePreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
ImagePreview.BorderSizePixel = 2
ImagePreview.Visible = false -- Se oculta hasta que se busque algo
ImagePreview.Parent = VisualizerGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ImagePreview

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(200, 200, 200)
UIStroke.Thickness = 2
UIStroke.Parent = ImagePreview

-- ==========================================================
-- DICCIONARIO DE TIPOS DE ASSETS (Para catalogación precisa)
-- ==========================================================
local AssetTypeNames = {
    [2] = "T-Shirt", [8] = "Hat/Accesorio", [11] = "Camisa", [12] = "Pantalón",
    [18] = "Cara", [41] = "Pelo", [42] = "Accesorio de Cara",
    [43] = "Accesorio de Cuello", [44] = "Accesorio de Hombro",
    [45] = "Accesorio Frontal", [46] = "Accesorio Trasero", [47] = "Accesorio de Cintura"
}

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v3.0",
   LoadingTitle = "Iniciando Motor Todo-En-Uno...",
   LoadingSubtitle = "Visualizador + Bypass de IDs",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local CurrentData = {
   Name = "Ninguno",
   Id = "0",
   Price = "0 R$",
   Category = "Desconocido"
}

local Panel = Window:CreateTab("🏥 Quirúrgico & Pro", 4483362458)

-- ==========================================================
-- 1. BUSCADOR & FILTROS CON CONEXIÓN AL MARKETPLACE
-- ==========================================================
Panel:CreateSection("🔍 Buscador (Ingresa el ID Real)")

local LabelName = Panel:CreateLabel("Objeto: " .. CurrentData.Name)
local LabelID = Panel:CreateLabel("ID Catálogo: " .. CurrentData.Id)
local LabelPrice = Panel:CreateLabel("Precio: " .. CurrentData.Price)
local LabelCategory = Panel:CreateLabel("Tipo: " .. CurrentData.Category)

Panel:CreateInput({
   Name = "Buscar por ID (Numérico)",
   PlaceholderText = "Ej: 144275038...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local numericId = tonumber(Text)
       if not numericId then
           Rayfield:Notify({Title = "Error", Content = "Debes ingresar solo números.", Duration = 2})
           return
       end

       -- Obteniendo datos REALES del catálogo
       local success, info = pcall(function()
           return MarketplaceService:GetProductInfo(numericId)
       end)

       if success and info then
           CurrentData.Id = tostring(numericId)
           CurrentData.Name = info.Name
           CurrentData.Price = info.PriceInRobux and (tostring(info.PriceInRobux) .. " R$") or "Gratis / Off-Sale"
           CurrentData.Category = AssetTypeNames[info.AssetTypeId] or ("ID de Tipo: " .. tostring(info.AssetTypeId))

           -- Actualizar la Pancarta
           LabelName:Set("Objeto: " .. CurrentData.Name)
           LabelID:Set("ID Catálogo: " .. CurrentData.Id)
           LabelPrice:Set("Precio: " .. CurrentData.Price)
           LabelCategory:Set("Tipo: " .. CurrentData.Category)

           -- Actualizar el Visualizador (Miniatura real de Roblox)
           ImagePreview.Image = "rbxthumb://type=Asset&id=" .. CurrentData.Id .. "&w=150&h=150"
           ImagePreview.Visible = true

           Rayfield:Notify({Title = "Item Encontrado", Content = "Mostrando vista previa...", Duration = 2})
       else
           Rayfield:Notify({Title = "Error de ID", Content = "No se pudo encontrar en el catálogo.", Duration = 3})
       end
   end,
})

-- ==========================================================
-- 2. PROBADOR EN TIEMPO REAL (MÉTODO PRECISO GETOBJECTS)
-- ==========================================================
Panel:CreateSection("🧪 Aplicar / Probar en Personaje")

Panel:CreateButton({
   Name = "⚡ Equipar/Reemplazar en Mi Personaje",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       local Hum = Char:FindFirstChildOfClass("Humanoid")
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId or assetId == 0 then return end

       -- MÉTODO PRECISO: Usar GetObjects (Bypasea restricciones de InsertService)
       local success, err = pcall(function()
           local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
           local item = objects[1]

           if not item then return end

           -- ENFOQUE 1: Es un accesorio (Pelo, sombrero, espadas)
           if item:IsA("Accessory") then
               if Hum then Hum:AddAccessory(item) end

           -- ENFOQUE 2: Es ropa (Camisa, pantalón, T-Shirt)
           elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
               -- Eliminar la ropa vieja del mismo tipo
               for _, v in pairs(Char:GetChildren()) do
                   if v.ClassName == item.ClassName then
                       v:Destroy()
                   end
               end
               item.Parent = Char

           -- ENFOQUE 3: Es una cara (Decal)
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
               
           -- ENFOQUE 4: Otras cosas / Modelos (Clonación forzada)
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
       ImagePreview.Visible = not ImagePreview.Visible
   end,
})

-- ==========================================================
-- 3. OPTIMIZACIÓN Y LIMPIEZA ANTI-CRASH (iOS DELTA)
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
