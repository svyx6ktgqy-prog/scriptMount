-- Cargar la librería de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Ejecutor Delta",
   LoadingTitle = "Inyectando script...",
   LoadingSubtitle = "Método quirúrgico",
   Theme = "Default", 
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = false
   }
})

-- Rayfield requiere al menos una pestaña para colocar el Switch.
-- Se crea una única pestaña principal para mantenerlo limpio.
local MainTab = Window:CreateTab("Loader", 4483362458) 

-- Crear el Switch (Toggle)
local Toggle = MainTab:CreateToggle({
   Name = "Cargar Gamepass Gifter",
   CurrentValue = false,
   Flag = "LoadScriptToggle", 
   Callback = function(Value)
      if Value then
         -- Ejecución del loadstring al encender el switch
         loadstring(game:HttpGet('https://raw.githubusercontent.com/Makuscripts/MakuHub/refs/heads/main/GamepassGifter'))()
         
         -- Notificación de confirmación (Opcional, para saber que se presionó)
         Rayfield:Notify({
            Title = "Ejecutado",
            Content = "El script de optimización/loader se ha inyectado.",
            Duration = 3,
            Image = 4483362458
         })
      end
   end,
})
