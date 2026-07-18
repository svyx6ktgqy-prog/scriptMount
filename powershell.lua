-- Asegurar que el juego esté cargado antes de dibujar la interfaz
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- URL proporcionada para la librería Rayfield
local rayfieldUrl = "https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua"

-- Intentar cargar la librería con pcall para evitar crasheos si falla la descarga
local successRayfield, Rayfield = pcall(function()
    return loadstring(game:HttpGet(rayfieldUrl))()
end)

if not successRayfield or not Rayfield then
    warn("Error crítico: No se pudo cargar Rayfield desde el nuevo repositorio.")
    print("Detalle del error:", Rayfield)
    return
end

-- Crear la ventana principal con compatibilidad móvil
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Delta iOS Edition",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Crear pestaña de herramientas
local MainTab = Window:CreateTab("Herramientas", 4483362458)

-- Función robusta de portapapeles para iOS
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

-- Limpieza de nombre de juego para simular el formato de PC
local function createUrlSlug(rawName)
    local cleanName = string.gsub(rawName, "[^%w%s]", "")
    cleanName = string.gsub(cleanName, "%s+", "-")
    cleanName = string.gsub(cleanName, "^%-*(.-)%-*$", "%1")
    if cleanName == "" then cleanName = "Juego" end
    return cleanName
end

local placeId = game.PlaceId
local gameName = "Roblox-Game"

pcall(function()
    local productInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId)
    if productInfo and productInfo.Name then
        gameName = createUrlSlug(productInfo.Name)
    end
end)

-- Construcción del comando PowerShell estilo DevTools PC
local gameUrl = string.format("https://www.roblox.com/games/%d/%s", placeId, gameName)
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

local psCommand = string.format(psTemplate, gameUrl)

-- Crear botón de extracción
local Button = MainTab:CreateButton({
   Name = "Copiar PowerShell (DevTools PC)",
   Callback = function()
      local copiadoExitoso = copyToClipboardRobust(psCommand)
      
      if copiadoExitoso then
         Rayfield:Notify({
            Title = "Extracción Exitosa",
            Content = "PowerShell copiado al portapapeles del iPhone.",
            Duration = 5,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error de Portapapeles",
            Content = "Delta no pudo interactuar con el portapapeles de iOS.",
            Duration = 5,
            Image = 4483362458
         })
      end
   end,
})
