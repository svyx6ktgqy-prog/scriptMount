-- ==========================================================
-- LOOKS PRO v2.1 • Paginación + Aplicar Directo + Aviso CSRF
-- ==========================================================

local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

local FAVORITES_FILE    = "LOOKS_FAVORITES.json"
local PAGE_SIZE         = 8          -- resultados por página
local CurrentResults    = {}         -- todos los looks cargados
local CurrentPage       = 1
local CurrentSelected   = nil

-- ==========================================================
-- RAYFIELD
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/AvatarCatalog/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "👀 Looks Pro v2.1 • Descubre Avatares",
    LoadingTitle = "Cargando Looks Pro...",
    LoadingSubtitle = "Paginación + Aplicar Directo",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("👀 Looks Pro", 4483362458)

-- ==========================================================
-- UTILIDADES
-- ==========================================================
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 4
        })
    end)
    Rayfield:Notify({ Title = title, Content = text, Duration = duration or 4 })
end

local function SafeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 30 then return res end
    return nil
end

local function ClearAvatar()
    local Char = LocalPlayer.Character
    if not Char then return end
    for _, v in ipairs(Char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function ApplyLookData(look)
    if not look then return false end
    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return false end

    ClearAvatar()

    local outfitId = look.outfitId
        or (look.avatarProperties and look.avatarProperties.outfitId)
        or (look.outfit and look.outfit.id)

    if outfitId then
        local ok, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromOutfitId(tonumber(outfitId))
        end)
        if ok and desc then
            pcall(function() Hum:ApplyDescription(desc) end)
            return true
        end
    end

    local items = look.items or look.assets or look.assetsIncludingBundleParts or {}
    local count = 0
    for _, item in ipairs(items) do
        local id = item.id or item.assetId
        if id then
            task.spawn(function()
                local s, objs = pcall(function()
                    return game:GetObjects("rbxassetid://" .. tostring(id))
                end)
                if s and objs then
                    for _, obj in ipairs(objs) do
                        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                            local c = obj:Clone()
                            c.Parent = Char
                            count += 1
                        end
                    end
                end
            end)
            task.wait(0.03)
        end
    end
    return count > 0
end

-- ==========================================================
-- FAVORITOS JSON
-- ==========================================================
local function LoadFavorites()
    if isfile and isfile(FAVORITES_FILE) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(FAVORITES_FILE))
        end)
        if ok and type(data) == "table" then return data end
    end
    return {}
end

local function SaveFavorites(data)
    if writefile then
        pcall(function()
            writefile(FAVORITES_FILE, HttpService:JSONEncode(data))
        end)
    end
end

local Favorites = LoadFavorites()

-- ==========================================================
-- BUSCADOR KEYWORD + DETALLES
-- ==========================================================
local function SearchLooksByKeyword(keyword)
    if not keyword or keyword == "" then return {} end

    local encoded = HttpService:UrlEncode(keyword)
    local urls = {
        "https://apis.roblox.com/marketplace-widgets/v1/widgets?query=" .. encoded .. "&context=avatarTab",
        "https://apis.roblox.com/marketplace-widgets/v1/widgets/search?query=" .. encoded,
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets?query=" .. encoded .. "&context=avatarTab",
        "https://apis.roproxy.com/marketplace-widgets/v1/widgets/search?query=" .. encoded
    }

    local lookIds = {}
    local usedAuthRequired = false

    for _, url in ipairs(urls) do
        local res = SafeHttpGet(url)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then
                local function extract(tbl)
                    if type(tbl) ~= "table" then return end
                    if tbl.type == "Look" and tbl.id then
                        table.insert(lookIds, tostring(tbl.id))
                    end
                    for _, v in pairs(tbl) do extract(v) end
                end
                extract(data)
                if #lookIds > 0 then break end
            end
        else
            usedAuthRequired = true
        end
    end

    -- Duplicados
    local unique, seen = {}, {}
    for _, id in ipairs(lookIds) do
        if not seen[id] then
            seen[id] = true
            table.insert(unique, id)
        end
    end

    return unique, usedAuthRequired
end

local function FetchLookDetails(lookId)
    local urls = {
        "https://apis.roblox.com/look-api/v2/looks/" .. lookId,
        "https://apis.roproxy.com/look-api/v2/looks/" .. lookId
    }
    for _, url in ipairs(urls) do
        local res = SafeHttpGet(url)
        if res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data then
                return data.look or data
            end
        end
    end
    return nil
end

-- ==========================================================
-- PAGINACIÓN
-- ==========================================================
local function GetPageSlice()
    local startIdx = (CurrentPage - 1) * PAGE_SIZE + 1
    local endIdx   = math.min(startIdx + PAGE_SIZE - 1, #CurrentResults)
    local slice = {}
    for i = startIdx, endIdx do
        table.insert(slice, CurrentResults[i])
    end
    return slice, startIdx, endIdx
end

local function RefreshResultsDropdown()
    local slice = GetPageSlice()
    local options = {}
    for _, look in ipairs(slice) do
        local name = look.name or ("Look " .. (look.id or "?"))
        table.insert(options, name .. " | " .. tostring(look.id))
    end
    if #options == 0 then
        options = {"Sin resultados en esta página"}
    end
    ResultsDropdown:Refresh(options, true)

    local totalPages = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
    PageLabel:Set("Página " .. CurrentPage .. " / " .. totalPages .. "  (" .. #CurrentResults .. " looks)")
end

-- ==========================================================
-- PREVIEW VIEWPORT (igual que antes)
-- ==========================================================
local PreviewGui = Instance.new("ScreenGui")
PreviewGui.Name = "LooksPreviewGui"
PreviewGui.DisplayOrder = 50
PreviewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
PreviewGui.Enabled = false
PreviewGui.Parent = CoreGui

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Size = UDim2.new(0, 320, 0, 420)
PreviewFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
PreviewFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
PreviewFrame.BorderSizePixel = 0
PreviewFrame.Parent = PreviewGui
Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 12)

local PreviewTitle = Instance.new("TextLabel")
PreviewTitle.Size = UDim2.new(1, -40, 0, 36)
PreviewTitle.Position = UDim2.new(0, 12, 0, 6)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "Preview"
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextSize = 14
PreviewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
PreviewTitle.Parent = PreviewFrame

local ClosePreview = Instance.new("TextButton")
ClosePreview.Size = UDim2.new(0, 28, 0, 28)
ClosePreview.Position = UDim2.new(1, -36, 0, 6)
ClosePreview.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ClosePreview.Text = "X"
ClosePreview.Font = Enum.Font.GothamBold
ClosePreview.TextColor3 = Color3.fromRGB(255, 255, 255)
ClosePreview.Parent = PreviewFrame
Instance.new("UICorner", ClosePreview).CornerRadius = UDim.new(0, 6)
ClosePreview.MouseButton1Click:Connect(function() PreviewGui.Enabled = false end)

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -24, 0, 280)
Viewport.Position = UDim2.new(0, 12, 0, 48)
Viewport.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Viewport.Parent = PreviewFrame
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 8)

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size = UDim2.new(0.48, 0, 0, 36)
ApplyBtn.Position = UDim2.new(0.02, 0, 1, -50)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
ApplyBtn.Text = "✅ Aplicar"
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyBtn.Parent = PreviewFrame
Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 8)

local FavBtn = Instance.new("TextButton")
FavBtn.Size = UDim2.new(0.48, 0, 0, 36)
FavBtn.Position = UDim2.new(0.5, 0, 1, -50)
FavBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
FavBtn.Text = "❤️ Favorito"
FavBtn.Font = Enum.Font.GothamBold
FavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FavBtn.Parent = PreviewFrame
Instance.new("UICorner", FavBtn).CornerRadius = UDim.new(0, 8)

local function ShowPreview(look)
    if not look then return end
    CurrentSelected = look
    PreviewTitle.Text = look.name or ("Look " .. (look.id or "?"))
    PreviewGui.Enabled = true

    for _, c in ipairs(Viewport:GetChildren()) do
        if c:IsA("WorldModel") or c:IsA("Camera") then c:Destroy() end
    end

    task.spawn(function()
        local Char = LocalPlayer.Character
        if not Char then return end
        Char.Archivable = true
        local dummy = Char:Clone()
        Char.Archivable = false

        for _, v in ipairs(dummy:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            end
        end

        local world = Instance.new("WorldModel")
        world.Parent = Viewport
        dummy.Parent = world

        local cam = Instance.new("Camera")
        cam.Parent = Viewport
        Viewport.CurrentCamera = cam

        local hrp = dummy:FindFirstChild("HumanoidRootPart") or dummy.PrimaryPart
        if hrp then
            hrp.Anchored = true
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 5.5), hrp.Position + Vector3.new(0, 0.8, 0))
        end

        local outfitId = look.outfitId or (look.avatarProperties and look.avatarProperties.outfitId)
        if outfitId then
            local ok, desc = pcall(function()
                return Players:GetHumanoidDescriptionFromOutfitId(tonumber(outfitId))
            end)
            if ok and desc then
                local hum = dummy:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ApplyDescription(desc) end) end
            end
        end
    end)
end

ApplyBtn.MouseButton1Click:Connect(function()
    if CurrentSelected then
        local ok = ApplyLookData(CurrentSelected)
        Notify(ok and "✅ Aplicado" or "⚠️", ok and (CurrentSelected.name or "Look") or "No se pudo aplicar", 4)
    end
end)

FavBtn.MouseButton1Click:Connect(function()
    if not CurrentSelected then return end
    local id = tostring(CurrentSelected.id or CurrentSelected.lookId or "")
    if id == "" then return end
    Favorites[id] = { id = id, name = CurrentSelected.name or ("Look " .. id), savedAt = os.time() }
    SaveFavorites(Favorites)
    Notify("❤️ Guardado", "Añadido a favoritos", 3)
end)

-- ==========================================================
-- INTERFAZ RAYFIELD
-- ==========================================================
Tab:CreateSection("⚠️ Aviso importante sobre el buscador")

Tab:CreateParagraph({
    Title = "Limitación de marketplace-widgets",
    Content = "Los endpoints de búsqueda por keyword (marketplace-widgets) a veces requieren cookie/CSRF y pueden devolver 0 resultados o fallar según el executor/proxy.\n\nSi no aparecen resultados:\n• Usa el input de Look ID directo (más fiable)\n• Prueba keywords muy populares (y2k, goth, emo, aesthetic)\n• Cambia de executor o usa un proxy diferente"
})

Tab:CreateSection("🔍 Buscador por Keyword")

Tab:CreateInput({
    Name = "Palabra clave (y2k, goth, emo, cute...)",
    PlaceholderText = "Escribe y presiona Enter...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        task.spawn(function()
            Notify("Buscando...", "Consultando endpoints...", 2)
            local ids, authWarning = SearchLooksByKeyword(Text)

            if #ids == 0 then
                if authWarning then
                    Notify("Sin resultados + posible auth", "marketplace-widgets puede requerir cookie/CSRF.\nUsa Look ID directo.", 6)
                else
                    Notify("Sin resultados", "Prueba otra keyword o usa Look ID", 4)
                end
                return
            end

            Notify("IDs encontrados", #ids .. " looks. Cargando detalles (puede tardar)...", 3)

            CurrentResults = {}
            CurrentPage = 1

            for i, id in ipairs(ids) do
                if i > 40 then break end -- límite de seguridad
                local details = FetchLookDetails(id)
                if details then
                    details.id = details.id or details.lookId or id
                    table.insert(CurrentResults, details)
                end
                task.wait(0.07)
            end

            if #CurrentResults == 0 then
                Notify("Error", "Se obtuvieron IDs pero falló la carga de detalles", 4)
                return
            end

            RefreshResultsDropdown()
            Notify("Listo", #CurrentResults .. " Looks cargados. Usa las flechas de página.", 4)
        end)
    end
})

-- Dropdown de resultados de la página actual
ResultsDropdown = Tab:CreateDropdown({
    Name = "Resultados (página actual)",
    Options = {"Esperando búsqueda..."},
    CurrentOption = {"Esperando búsqueda..."},
    MultipleOptions = false,
    Callback = function(Option)
        local selected = type(Option) == "table" and Option[1] or Option
        if not selected or selected:find("Sin resultados") or selected:find("Esperando") then return end

        local lookId = selected:match("| (%d+)$")
        if not lookId then return end

        for _, look in ipairs(CurrentResults) do
            if tostring(look.id) == lookId then
                CurrentSelected = look
                break
            end
        end
    end
})

-- Label de página
PageLabel = Tab:CreateLabel("Página 1 / 1  (0 looks)")

-- Botones de paginación
Tab:CreateButton({
    Name = "⬅️ Página anterior",
    Callback = function()
        if CurrentPage > 1 then
            CurrentPage -= 1
            RefreshResultsDropdown()
        else
            Notify("Info", "Ya estás en la primera página", 2)
        end
    end
})

Tab:CreateButton({
    Name = "➡️ Página siguiente",
    Callback = function()
        local totalPages = math.max(1, math.ceil(#CurrentResults / PAGE_SIZE))
        if CurrentPage < totalPages then
            CurrentPage += 1
            RefreshResultsDropdown()
        else
            Notify("Info", "Ya estás en la última página", 2)
        end
    end
})

-- ==========================================================
-- APLICAR DIRECTO (sin preview)
-- ==========================================================
Tab:CreateSection("⚡ Acciones rápidas")

Tab:CreateButton({
    Name = "✅ Aplicar Look seleccionado (sin preview)",
    Callback = function()
        if not CurrentSelected then
            Notify("Error", "Primero selecciona un Look del dropdown", 3)
            return
        end
        local ok = ApplyLookData(CurrentSelected)
        Notify(ok and "✅ Aplicado" or "⚠️", ok and (CurrentSelected.name or "Look") or "No se pudo aplicar completamente", 4)
    end
})

Tab:CreateButton({
    Name = "👁️ Abrir Preview del seleccionado",
    Callback = function()
        if not CurrentSelected then
            Notify("Error", "Primero selecciona un Look del dropdown", 3)
            return
        end
        ShowPreview(CurrentSelected)
    end
})

Tab:CreateButton({
    Name = "❤️ Guardar seleccionado en Favoritos",
    Callback = function()
        if not CurrentSelected then
            Notify("Error", "Primero selecciona un Look", 3)
            return
        end
        local id = tostring(CurrentSelected.id or "")
        Favorites[id] = {
            id = id,
            name = CurrentSelected.name or ("Look " .. id),
            savedAt = os.time()
        }
        SaveFavorites(Favorites)
        Notify("❤️ Guardado", "Añadido a favoritos", 3)
    end
})

-- ==========================================================
-- CARGA DIRECTA POR ID
-- ==========================================================
Tab:CreateSection("📌 Carga directa por Look ID (más fiable)")

Tab:CreateInput({
    Name = "Look ID",
    PlaceholderText = "6954265135743238304",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local id = Text:match("%d+")
        if not id then
            Notify("Error", "ID inválido", 3)
            return
        end
        task.spawn(function()
            local details = FetchLookDetails(id)
            if details then
                details.id = details.id or id
                CurrentSelected = details
                ShowPreview(details)
            else
                Notify("Error", "No se pudo obtener el Look", 4)
            end
        end)
    end
})

-- ==========================================================
-- FAVORITOS
-- ==========================================================
Tab:CreateSection("❤️ Favoritos")

Tab:CreateButton({
    Name = "📂 Cargar lista de Favoritos",
    Callback = function()
        Favorites = LoadFavorites()
        local opts = {}
        for id, data in pairs(Favorites) do
            table.insert(opts, (data.name or "Look") .. " | " .. id)
        end
        if #opts == 0 then
            Notify("Vacío", "No hay favoritos guardados", 3)
            return
        end
        FavDropdown:Refresh(opts, true)
        Notify("Favoritos", #opts .. " Looks cargados", 3)
    end
})

FavDropdown = Tab:CreateDropdown({
    Name = "Tus Favoritos",
    Options = {"Presiona 'Cargar lista' primero"},
    CurrentOption = {"Presiona 'Cargar lista' primero"},
    MultipleOptions = false,
    Callback = function(Option)
        local selected = type(Option) == "table" and Option[1] or Option
        local id = selected:match("| (%d+)$")
        if not id then return end
        task.spawn(function()
            local details = FetchLookDetails(id)
            if details then
                details.id = id
                CurrentSelected = details
                ShowPreview(details)
            else
                Notify("Error", "No se pudo cargar el favorito", 3)
            end
        end)
    end
})

Tab:CreateButton({
    Name = "🗑️ Borrar todos los favoritos",
    Callback = function()
        Favorites = {}
        SaveFavorites(Favorites)
        FavDropdown:Refresh({"Sin favoritos"}, true)
        Notify("Borrado", "Lista vaciada", 3)
    end
})

-- ==========================================================
-- UTILIDADES
-- ==========================================================
Tab:CreateSection("🧹 Utilidades")

Tab:CreateButton({
    Name = "🗑️ Limpiar avatar actual",
    Callback = function()
        ClearAvatar()
        Notify("Limpio", "Accesorios y ropa eliminados", 3)
    end
})

Tab:CreateButton({
    Name = "♻️ Restaurar avatar original",
    Callback = function()
        local Char = LocalPlayer.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        if Hum then
            pcall(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                Hum:ApplyDescription(desc)
            end)
            Notify("Restaurado", "Avatar original de la cuenta", 3)
        end
    end
})

Notify("Looks Pro v2.1 listo", "Paginación + Aplicar directo activos", 5)
