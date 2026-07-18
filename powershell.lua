-- Esperar a que el juego esté completamente cargado (Vital en Delta iOS)
repeat task.wait() until game:IsLoaded()

-- Cargar la librería Rayfield de forma segura
local successRayfield, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirblood.github.io/Rayfield/source'))()
end)

if not successRayfield then
    warn("Error al cargar Rayfield UI. Verifica tu conexión.")
    return
end

-- Crear la ventana principal usando el título de la sesión
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Cargando en Delta iOS...",
   LoadingSubtitle = "Generando PowerShell Web...",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Herramientas", 4483362458)

-- Función robusta de portapapeles
local function copyToClipboardRobust(text)
    local success, result = pcall(function()
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        end
        return false
    end)
    return success and result
end

-- Función para limpiar el nombre y crear una URL idéntica a la de PC
local function createUrlSlug(rawName)
    -- Eliminar emojis y caracteres especiales, reemplazar espacios con guiones
    local cleanName = string.gsub(rawName, "[^%w%s]", "")
    cleanName = string.gsub(cleanName, "%s+", "-")
    cleanName = string.gsub(cleanName, "^%-*(.-)%-*$", "%1")
    if cleanName == "" then cleanName = "Juego" end
    return cleanName
end

local placeId = game.PlaceId
local gameName = "Roblox-Game"

-- Obtener el nombre real del juego
pcall(function()
    local productInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId)
    if productInfo and productInfo.Name then
        gameName = createUrlSlug(productInfo.Name)
    end
end)

-- =========================================================
-- NUEVO ENFOQUE: Simular el "Copiar como PowerShell" de DevTools en PC
-- Apuntando directamente al enlace web del juego con cabeceras de navegador real
-- =========================================================

local gameUrl = string.format("https://www.roblox.com/games/%d/%s", placeId, gameName)

-- Construcción del comando masivo idéntico al que extrae Google Chrome
local psTemplate = [[
Invoke-WebRequest -Uri "%s" `
-Method "GET" `
-Headers @{
"accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
"accept-language"="es-ES,es;q=0.9,en;q=0.8"
"cache-control"="max-age=0"
"sec-ch-ua"="`"Chromium`";v=`"122`", `"Not(A:Brand`";v=`"24`", `"Google Chrome`";v=`"122`""
"sec-ch-ua-mobile"="?0"
"sec-ch-ua-platform"="`"Windows`""
"sec-fetch-dest"="document"
"sec-fetch-mode"="navigate"
"sec-fetch-site"="none"
"sec-fetch-user"="?1"
"upgrade-insecure-requests"="1"
"User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
}
]]

-- Insertar la URL en la plantilla
local psCommand = string.format(psTemplate, gameUrl)

-- Crear el botón en la interfaz
local Button = MainTab:CreateButton({
   Name = "Copiar PowerShell (DevTools PC)",
   Callback = function()
      local copiadoExitoso = copyToClipboardRobust(psCommand)
      
      if copiadoExitoso then
         Rayfield:Notify({
            Title = "Extracción Web Exitosa",
            Content = "PowerShell de DevTools copiado al portapapeles.",
            Duration = 5,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error de Delta",
            Content = "Delta no pudo acceder al portapapeles.",
            Duration = 5,
            Image = 4483362458
         })
      end
   end,
})
