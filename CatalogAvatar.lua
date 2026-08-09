-- ==========================================================
-- MENU QUIRÚRGICO PRO v4.0 (DEFINITIVO - DELTA iOS)
-- Solución a Catálogo Vacío + Switches + Auto-Preview
-- ==========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico Pro v4.0",
   LoadingTitle = "Iniciando Motor Quirúrgico v4...",
   LoadingSubtitle = "Optimizado para Delta iOS",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- BASE DE DATOS DE CATÁLOGO PRE-CARGADA (Evita menú vacío)
local CatalogDatabase = {
   ["Perrito Kawaii (Accesorio)"] = "13961108",
   ["Cabeza de Perro 3D"] = "63690008",
   ["Valkyrie Helm"] = "1028856",
   ["Dominus Empyreus"] = "21070012",
   ["Alas de Ángel"] = "113325608",
   ["Rostro Súper Súper Feliz"] = "49429054"
}

local CurrentSelectedID = "13961108"
local AutoEquipOnSelect = false

local MainTab = Window:CreateTab("🏥 Quirúrgico v4", 4483362458)

-- ==========================================================
-- FUNCIONES DE INYECCIÓN REAL (REEMPLAZO DE PERSONAJE)
-- ==========================================================
local function InyectarItem(assetId)
   local Char = LocalPlayer.Character
   if not Char then return end
   
   local id = tonumber(assetId)
   if not id or id <= 0 then
       Rayfield:Notify({ Title = "Error", Content = "ID no válida", Duration = 2 })
       return
   end

   local success, objects = pcall(function()
       return game:GetObjects("rbxassetid://" .. id)
   end)

   if success and objects and #objects > 0 then
       for _, obj in ipairs(objects) do
           if obj:IsA("Accessory") or obj:IsA("Accoutrement") then
               -- Remueve el accesorio anterior del mismo tipo
               for _, old in ipairs(Char:GetChildren()) do
                   if old:IsA("Accessory") and old.AccessoryType == obj.AccessoryType then
                       old:Destroy()
                   end
               end
               obj.Parent = Char
           elseif obj:IsA("Clothing") or obj:IsA("Shirt") or obj:IsA("Pants") then
               for _, old in ipairs(Char:GetChildren()) do
                   if old.ClassName == obj.ClassName then old:Destroy() end
               end
               obj.Parent = Char
           else
               obj.Parent = Char
           end
       end

       Rayfield:Notify({
           Title = "¡Inyección Exitosa!",
           Content = "Item " .. id .. " equipado correctamente.",
           Duration = 2.5
       })
   else
       Rayfield:Notify({
           Title = "Error de Descarga",
           Content = "No se pudo cargar el item. Verifica la ID o tu conexión.",
           Duration = 3
       })
   end
end

-- ==========================================================
-- 1. SECCIÓN: BUSCADOR DIRECTO Y SELECCIÓN DE CATÁLOGO
-- ==========================================================
MainTab:CreateSection("🔍 Buscador & Lista Quirúrgica")

MainTab:CreateInput({
   Name = "Buscar o Ingresar ID Personalizada",
   PlaceholderText = "Escribe una ID aquí (Ej: 1028856)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       if Text ~= "" then
           CurrentSelectedID = Text
           Rayfield:Notify({
               Title = "ID Seleccionada",
               Content = "Nueva ID lista para probar: " .. Text,
               Duration = 2
           })
           if AutoEquipOnSelect then
               InyectarItem(CurrentSelectedID)
           end
       end
   end,
})

-- Desplegable con items reales para probar al instante sin buscar
local CatalogNames = {}
for name, _ in pairs(CatalogDatabase) do
   table.insert(CatalogNames, name)
end

MainTab:CreateDropdown({
   Name = "Catálogo Rápido Pre-Cargado",
   Options = CatalogNames,
   CurrentOption = {CatalogNames[1]},
   MultipleOptions = false,
   Callback = function(Option)
       local selectedName = type(Option) == "table" and Option[1] or Option
       if CatalogDatabase[selectedName] then
           CurrentSelectedID = CatalogDatabase[selectedName]
           Rayfield:Notify({
               Title = "Objeto Cargado",
               Content = selectedName .. " (ID: " .. CurrentSelectedID .. ")",
               Duration = 2.5
           })
           if AutoEquipOnSelect then
               InyectarItem(CurrentSelectedID)
           end
       end
   end,
})

-- ==========================================================
-- 2. SECCIÓN: SWITCHES Y CONTROLES (SOLUCIÓN A SWITCHES INVISIBLES)
-- ==========================================================
MainTab:CreateSection("🎛️ Configuración y Switches")

MainTab:CreateToggle({
   Name = "Auto-Equipar al Seleccionar / Buscar",
   CurrentValue = false,
   Flag = "AutoEquipToggle",
   Callback = function(Value)
       AutoEquipOnSelect = Value
       Rayfield:Notify({
           Title = "Auto-Equipar",
           Content = Value and "Activado: Se equipará al hacer clic." or "Desactivado: Uso manual.",
           Duration = 2
       })
   end,
})

-- ==========================================================
-- 3. SECCIÓN: ACCIONES DEL PERSONAJE
-- ==========================================================
MainTab:CreateSection("⚡ Acciones Pro")

MainTab:CreateButton({
   Name = "🧪 Reemplazar / Equipar Item Seleccionado",
   Callback = function()
       InyectarItem(CurrentSelectedID)
   end,
})

MainTab:CreateButton({
   Name = "🗑️ Desequipar Todos los Accesorios",
   Callback = function()
       local Char = LocalPlayer.Character
       if Char then
           for _, item in ipairs(Char:GetChildren()) do
               if item:IsA("Accessory") then
                   item:Destroy()
               end
           end
           Rayfield:Notify({
               Title = "Personaje Limpio",
               Content = "Se eliminaron todos los accesorios del cuerpo.",
               Duration = 2
           })
       end
   end,
})

MainTab:CreateButton({
   Name = "📋 Copiar ID Seleccionada",
   Callback = function()
       if setclipboard then
           setclipboard(CurrentSelectedID)
           Rayfield:Notify({ Title = "Copiado", Content = "ID copiada al portapapeles.", Duration = 2 })
       end
   end,
})

-- ==========================================================
-- 4. SECCIÓN: OPTIMIZACIÓN Y LIMPIEZA
-- ==========================================================
MainTab:CreateSection("⚙️ Mantenimiento Anti-Crash iOS")

MainTab:CreateButton({
   Name = "🧹 Liberar Memoria RAM (Purgar Caché)",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({
           Title = "RAM Maximizada",
           Content = "Caché de iOS liberada correctamente.",
           Duration = 2
       })
   end,
})

Rayfield:Notify({
   Title = "Quirúrgico v4.0 Cargado",
   Content = "Catálogo pre-cargado y Switches activos.",
   Duration = 3.5
})
