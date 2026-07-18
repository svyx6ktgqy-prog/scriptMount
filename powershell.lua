-- Cargar la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirblood.github.io/Rayfield/source'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "MineAMountain",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

-- Crear una pestaña
local MainTab = Window:CreateTab("Herramientas", 4483362458)

-- Esta es la cadena de PowerShell construida a partir de los datos en image.png
-- Recrea la petición GET a la API de Roblox que ves en la pestaña Network/Red
local psCommand = [[Invoke-WebRequest -Uri "https://apis.roblox.com/rotating-client-service/v1/defer/raven?pathname=%2Fes%2Fgames%2F125927821145949%2FMine-a-Mountain" -Method GET -Headers @{"Content-Type"="text/javascript"}]]

-- Crear el botón "Copy PowerShell"
local Button = MainTab:CreateButton({
   Name = "Copy PowerShell",
   Callback = function()
      -- Verificar si el ejecutor soporta la función de copiar al portapapeles
      if setclipboard then
         setclipboard(psCommand)
         
         -- Notificación de éxito
         Rayfield:Notify({
            Title = "Comando Copiado",
            Content = "El script de PowerShell se ha copiado al portapapeles con éxito.",
            Duration = 5,
            Image = 4483362458
         })
      else
         -- Notificación de error si el ejecutor no lo soporta
         Rayfield:Notify({
            Title = "Error",
            Content = "Tu ejecutor no soporta la función setclipboard().",
            Duration = 5,
            Image = 4483362458
         })
      end
   end,
})
