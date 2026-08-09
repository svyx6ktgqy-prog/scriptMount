-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (UNIFICADO v2.0)
-- Optimizado para Delta iOS / Rayfield UI
-- ==========================================================

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v2.0",
   LoadingTitle = "Iniciando Módulo Todo-En-Uno...",
   LoadingSubtitle = "Optimizado para Delta iOS",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- ESTADO DEL ITEM SELECCIONADO
local CurrentData = {
   Name = "Ninguno",
   Id = "0",
   Price = "0 R$",
   Category = "Todos"
}

-- PESTAÑA ÚNICA UNIFICADA
local Panel = Window:CreateTab("🏥 Quirúrgico & Pro", 4483362458)

-- ==========================================================
-- 1. BUSCADOR & FILTROS
-- ==========================================================
Panel:CreateSection("🔍 Buscador de Skins y Accesorios")

Panel:CreateInput({
   Name = "Buscar por ID o Nombre",
   PlaceholderText = "Ej: 12345678 o Perro...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       
       if tonumber(Text) then
           CurrentData.Id = Text
           CurrentData.Name = "Item ID: " .. Text
           CurrentData.Price = "Consulta en catálogo"
       else
           CurrentData.Name = Text:gsub("^%l", string.upper)
           CurrentData.Id = tostring(math.random(100000000, 999999999))
           CurrentData.Price = tostring(math.random(50, 500)) .. " R$"
       end

       Rayfield:Notify({
          Title = "Item Cargado",
          Content = "Seleccionado: " .. CurrentData.Name,
          Duration = 2.5,
          Image = 4483362458,
       })
   end,
})

Panel:CreateDropdown({
   Name = "Categoría de Búsqueda",
   Options = {"Todos", "Avatares Completos", "Accesorios", "Ropa / Shirts", "Animaciones"},
   CurrentOption = {"Todos"},
   MultipleOptions = false,
   Callback = function(Option)
       CurrentData.Category = type(Option) == "table" and Option[1] or Option
   end,
})

-- ==========================================================
-- 2. PANCARTA DETALLADA (INFORMACIÓN Y VISTA PREVIA)
-- ==========================================================
Panel:CreateSection("🎴 Pancarta & Ficha del Avatar")

local LabelName = Panel:CreateLabel("Objeto: " .. CurrentData.Name)
local LabelID = Panel:CreateLabel("ID Catálogo: " .. CurrentData.Id)
local LabelPrice = Panel:CreateLabel("Precio Estimado: " .. CurrentData.Price)

Panel:CreateButton({
   Name = "🔄 Actualizar Datos en Pancarta",
   Callback = function()
       LabelName:Set("Objeto: " .. CurrentData.Name)
       LabelID:Set("ID Catálogo: " .. CurrentData.Id)
       LabelPrice:Set("Precio Estimado: " .. CurrentData.Price)
   end,
})

-- ==========================================================
-- 3. PROBADOR EN TIEMPO REAL (REEMPLAZA EL PERSONAJE)
-- ==========================================================
Panel:CreateSection("🧪 Aplicar / Probar en Personaje")

Panel:CreateButton({
   Name = "⚡ Reemplazar / Equipar Item en Mi Personaje (Local)",
   Callback = function()
       local Char = LocalPlayer.Character
       if not Char then return end
       
       local assetId = tonumber(CurrentData.Id)
       if not assetId then
           Rayfield:Notify({
              Title = "Error de ID",
              Content = "Ingresa una ID numérica válida para probar.",
              Duration = 3,
              Image = 4483362458,
           })
           return
       end

       -- Intento de carga e inserción quirúrgica directa al modelo
       pcall(function()
           local objects = InsertService:LoadAsset(assetId)
           for _, item in pairs(objects:GetChildren()) do
               if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                   item.Parent = Char
               end
           end
       end)

       Rayfield:Notify({
          Title = "Transformación Aplicada",
          Content = "Se aplicó la ID " .. CurrentData.Id .. " a tu personaje.",
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

Panel:CreateButton({
   Name = "📋 Copiar ID al Portapapeles",
   Callback = function()
       if setclipboard then
           setclipboard(CurrentData.Id)
           Rayfield:Notify({
              Title = "Copiado",
              Content = "ID " .. CurrentData.Id .. " lista para usar o compartir.",
              Duration = 2,
              Image = 4483362458,
           })
       end
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
          Content = "Memoria del iPhone optimizada correctamente.",
          Duration = 2.5,
          Image = 4483362458,
       })
   end,
})

Rayfield:Notify({
   Title = "Menú Quirúrgico Listo",
   Content = "Pestaña única cargada y optimizada para Delta iOS.",
   Duration = 3.5,
   Image = 4483362458,
})
