-- 1. VITAL PARA DELTA iOS: Esperar a que el juego esté 100% cargado
repeat task.wait() until game:IsLoaded()

-- Cargar la librería Rayfield de forma segura
local successRayfield, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
end)

if not successRayfield then
    warn("Error al cargar Rayfield UI. Delta iOS podría estar bloqueando la conexión o el script se inyectó mal.")
    return
end

-- Crear la ventana principal con el título solicitado
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Cargando en Delta iOS...",
   LoadingSubtitle = "Sincronizando...",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Crear una pestaña
local MainTab = Window:CreateTab("Herramientas", 4483362458)

-- Función robusta de portapapeles (Delta iOS usa setclipboard)
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

-- Construcción dinámica del PowerShell para que funcione en CUALQUIER juego
local placeId = game.PlaceId
local gameName = "Juego-Desconocido"

pcall(function()
    local productInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId)
    if productInfo and productInfo.Name then
        gameName = string.gsub(productInfo.Name, "[%s%p]", "-")
    end
end)

local dynamicUri = string.format("https://apis.roblox.com/rotating-client-service/v1/defer/raven?pathname=%%2Fes%%2Fgames%%2F%d%%2F%s", placeId, gameName)
local psCommand = string.format('Invoke-WebRequest -Uri "%s" -Method GET -Headers @{"Content-Type"="text/javascript"}', dynamicUri)

-- Crear el botón "Copy PowerShell"
local Button = MainTab:CreateButton({
   Name = "Copiar PowerShell del Juego",
   Callback = function()
      local copiadoExitoso = copyToClipboardRobust(psCommand)
      
      if copiadoExitoso then
         Rayfield:Notify({
            Title = "Extracción Exitosa",
            Content = "PowerShell copiado al portapapeles de tu iPhone.",
            Duration = 5,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error de Delta",
            Content = "Delta no pudo acceder al portapapeles de iOS.",
            Duration = 5,
            Image = 4483362458
         })
      end
   end,
})
