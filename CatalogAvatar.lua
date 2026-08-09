-- ==========================================================
-- MENU QUIRÚRGICO PRO v3.0 (PREVIEW + REEMPLAZO REAL)
-- Compatible con Delta iOS & Rayfield
-- ==========================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🏥 Avatar Catalog Quirúrgico v3.0",
   LoadingTitle = "Cargando Motor de Inyección...",
   LoadingSubtitle = "Optimizado para Delta iOS",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Panel = Window:CreateTab("🏥 Quirúrgico & Pro", 4483362458)

local CurrentId = "0"
local CurrentName = "Ninguno"

-- ----------------------------------------------------------
-- CREACIÓN DEL FRAME DE PREVISUALIZACIÓN DE IMAGEN
-- ----------------------------------------------------------
local PreviewGui = Instance.new("ScreenGui")
PreviewGui.Name = "QuirurgicoPreviewGui"
PreviewGui.ResetOnSpawn = false

-- Si ya existe una previa, la eliminamos antes de crear
if CoreGui:FindFirstChild("QuirurgicoPreviewGui") then
    CoreGui.QuirurgicoPreviewGui:Destroy()
end
PreviewGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 140)
Frame.Position = UDim2.new(0.82, 0, 0.2, 0) -- Esquina derecha de la pantalla
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 170, 255)
Frame.Active = true
Frame.Draggable = true -- Puedes mover la imagen por la pantalla
Frame.Parent = PreviewGui

local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Size = UDim2.new(1, -10, 1, -10)
ImageLabel.Position = UDim2.new(0, 5, 0, 5)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Image = "rbxassetid://0"
ImageLabel.Parent = Frame

local FrameTitle = Instance.new("TextLabel")
FrameTitle.Size = UDim2.new(1, 0, 0, 18)
FrameTitle.Position = UDim2.new(0, 0, 1, 2)
FrameTitle.BackgroundTransparency = 1
FrameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FrameTitle.TextSize = 11
FrameTitle.Text = "Previa de Ítem"
FrameTitle.Parent = Frame

-- ----------------------------------------------------------
-- FUNCIONES QUIRÚRGICAS (CARGA E INYECCIÓN)
-- ----------------------------------------------------------

-- Función para actualizar la imagen
local function UpdatePreviewImage(assetId)
    if tonumber(assetId) and tonumber(assetId) > 0 then
        -- Carga la miniatura directamente desde el servidor de Roblox
        ImageLabel.Image = "rbxthumb://type=Asset&id=" .. assetId .. "&w=420&h=420"
        FrameTitle.Text = "ID: " .. assetId
    else
        ImageLabel.Image = "rbxassetid://0"
        FrameTitle.Text = "Sin Selección"
    end
end

-- Función para reemplazar/equipar ítem en el personaje
local function EquipAssetQuirurgico(assetId)
    local Char = LocalPlayer.Character
    if not Char then return end
    
    local id = tonumber(assetId)
    if not id or id <= 0 then
        Rayfield:Notify({
            Title = "Error",
            Content = "Ingresa una ID válida.",
            Duration = 2
        })
        return
    end

    -- Usamos game:GetObjects soportado por ejecutores
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. id)
    end)

    if success and objects and #objects > 0 then
        for _, obj in ipairs(objects) do
            -- Si es un accesorio
            if obj:IsA("Accessory") or obj:IsA("Accoutrement") then
                -- Quitar accesorios del mismo tipo/zona si se desea
                for _, oldObj in ipairs(Char:GetChildren()) do
                    if oldObj:IsA("Accessory") and oldObj.AccessoryType == obj.AccessoryType then
                        oldObj:Destroy()
                    end
                end
                obj.Parent = Char
                
            -- Si es camisa o pantalón
            elseif obj:IsA("Clothing") or obj:IsA("Shirt") or obj:IsA("Pants") then
                for _, oldObj in ipairs(Char:GetChildren()) do
                    if oldObj.ClassName == obj.ClassName then
                        oldObj:Destroy()
                    end
                end
                obj.Parent = Char
                
            -- Si es cara / cara adhesiva
            elseif obj:IsA("Decal") then
                local head = Char:FindFirstChild("Head")
                if head then
                    for _, oldDecal in ipairs(head:GetChildren()) do
                        if oldDecal:IsA("Decal") then oldDecal:Destroy() end
                    end
                    obj.Parent = head
                end
            else
                obj.Parent = Char
            end
        end

        Rayfield:Notify({
            Title = "¡Equipado!",
            Content = "Se reemplazó e inyectó la ID " .. id .. " en tu personaje.",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Error de Carga",
            Content = "No se pudo obtener el ítem " .. id .. ". Revisa si la ID es correcta.",
            Duration = 3
        })
    end
end

-- ----------------------------------------------------------
-- INTERFAZ RAYFIELD
-- ----------------------------------------------------------
Panel:CreateSection("🔍 Buscador e Previsualización")

Panel:CreateInput({
   Name = "Ingresar ID del Ítem / Avatar",
   PlaceholderText = "Ej: 1028856 o 13961108...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       CurrentId = Text
       UpdatePreviewImage(Text)
   end,
})

Panel:CreateSection("🎴 Acciones del Personaje")

Panel:CreateButton({
   Name = "⚡ Reemplazar y Equipar Ítem en Mi Personaje",
   Callback = function()
       EquipAssetQuirurgico(CurrentId)
   end,
})

Panel:CreateButton({
   Name = "🗑️ Quitar Todos los Accesorios de Mi Personaje",
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
               Content = "Se removieron todos los accesorios.",
               Duration = 2
           })
       end
   end,
})

Panel:CreateSection("⚙️ Rendimiento")

Panel:CreateButton({
   Name = "🧹 Limpiar RAM / Memoria",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({
           Title = "RAM Liberada",
           Content = "Optimización completada.",
           Duration = 2
       })
   end,
})

Rayfield:Notify({
   Title = "Sistema Listo",
   Content = "Cargado con previsualización flotante e inyector activo.",
   Duration = 3
})
