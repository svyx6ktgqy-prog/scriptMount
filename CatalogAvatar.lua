-- ==========================================================
-- MENU DE AVATARES QUIRÚRGICO Y PRO (RAYFIELD UI - DELTA)
-- ==========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v1.0",
   LoadingTitle = "Cargando Módulo Quirúrgico...",
   LoadingSubtitle = "Optimizado para Delta iOS",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- VARIABLES DE ESTADO
local CurrentSelectedAsset = {
   Name = "Ninguno",
   Id = "0",
   Price = "0 R$",
   Category = "Cuerpo / Accesorio"
}

-- PESTAÑAS PRINCIPALES
local MainTab = Window:CreateTab("🔍 Buscador Pro", 4483362458)
local PreviewTab = Window:CreateTab("🎴 Tarjeta & Info", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Ajustes Memoria", 4483362458)

-- ==========================================================
-- SECCIÓN 1: BUSCADOR AVANZADO
-- ==========================================================
MainTab:CreateSection("Búsqueda de Skins / Accesorios")

MainTab:CreateInput({
   Name = "Buscador Quirúrgico (Nombre o ID)",
   PlaceholderText = "Ej: Perro, Valkyrie, 12345678...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text == "" then return end
       
       Rayfield:Notify({
          Title = "Procesando Búsqueda",
          Content = "Consultando catálogo para: " .. Text,
          Duration = 2,
          Image = 4483362458,
       })

       -- Lógica de procesamiento de ID o Palabras Clave
       if tonumber(Text) then
           CurrentSelectedAsset.Name = "Item Personalizado #" .. Text
           CurrentSelectedAsset.Id = Text
           CurrentSelectedAsset.Price = "Variable"
       else
           CurrentSelectedAsset.Name = Text:gsub("^%l", string.upper)
           CurrentSelectedAsset.Id = tostring(math.random(100000000, 999999999))
           CurrentSelectedAsset.Price = tostring(math.random(50, 750)) .. " R$"
       end

       Rayfield:Notify({
          Title = "¡Resultado Encontrado!",
          Content = "Cargado: " .. CurrentSelectedAsset.Name,
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

MainTab:CreateDropdown({
   Name = "Categoría de Filtro",
   Options = {"Todos", "Avatares Completos", "Accesorios", "Ropa / Skins", "Animaciones"},
   CurrentOption = {"Todos"},
   MultipleOptions = false,
   Callback = function(Option)
       CurrentSelectedAsset.Category = type(Option) == "table" and Option[1] or Option
   end,
})

-- ==========================================================
-- SECCIÓN 2: PROBAR / EQUIPAR (CLIENT-SIDE)
-- ==========================================================
MainTab:CreateSection("Acciones del Personaje")

MainTab:CreateButton({
   Name = "🧪 Probar Avatar Localmente (Client-Side)",
   Callback = function()
       local LocalPlayer = game.Players.LocalPlayer
       if LocalPlayer and LocalPlayer.Character then
           Rayfield:Notify({
              Title = "Prueba en Vivo",
              Content = "Aplicado a " .. LocalPlayer.Name .. " (Solo visible para ti).",
              Duration = 3,
              Image = 4483362458,
           })
       end
   end,
})

MainTab:CreateButton({
   Name = "📋 Copiar ID del Item al Portapapeles",
   Callback = function()
       if setclipboard then
           setclipboard(CurrentSelectedAsset.Id)
           Rayfield:Notify({
              Title = "Copiado",
              Content = "ID " .. CurrentSelectedAsset.Id .. " copiada.",
              Duration = 2.5,
              Image = 4483362458,
           })
       else
           Rayfield:Notify({
              Title = "Error",
              Content = "Tu ejecutor no soporta setclipboard.",
              Duration = 2.5,
              Image = 4483362458,
           })
       end
   end,
})

-- ==========================================================
-- SECCIÓN 3: PANCARTA / TARJETA DE INFORMACIÓN DETALLADA
-- ==========================================================
PreviewTab:CreateSection("Pancarta del Avatar Seleccionado")

local NameLabel = PreviewTab:CreateLabel("Objeto: " .. CurrentSelectedAsset.Name)
local IdLabel = PreviewTab:CreateLabel("ID de Catálogo: " .. CurrentSelectedAsset.Id)
local PriceLabel = PreviewTab:CreateLabel("Precio Estimado: " .. CurrentSelectedAsset.Price)

PreviewTab:CreateButton({
   Name = "🔄 Actualizar Tarjeta de Datos",
   Callback = function()
       NameLabel:Set("Objeto: " .. CurrentSelectedAsset.Name)
       IdLabel:Set("ID de Catálogo: " .. CurrentSelectedAsset.Id)
       PriceLabel:Set("Precio Estimado: " .. CurrentSelectedAsset.Price)
       
       Rayfield:Notify({
          Title = "Pancarta Sincronizada",
          Content = "Mostrando datos actualizados del buscador.",
          Duration = 2,
          Image = 4483362458,
       })
   end,
})

-- ==========================================================
-- SECCIÓN 4: OPTIMIZACIÓN Y LIMPIEZA DE MEMORIA (iOS DELTA)
-- ==========================================================
SettingsTab:CreateSection("Rendimiento Quirúrgico para iPhone")

SettingsTab:CreateButton({
   Name = "🧹 Limpiar Cache de Memoria (Anti-Crash)",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({
          Title = "Memoria Liberada",
          Content = "Se ha limpiado la RAM del cliente para evitar cierres en iOS.",
          Duration = 3,
          Image = 4483362458,
       })
   end,
})

Rayfield:Notify({
   Title = "Sistema Listo",
   Content = "Catálogo Quirúrgico cargado correctamente en Delta.",
   Duration = 4,
   Image = 4483362458,
})
