-- Cargar Rayfield usando la rama optimizada y compatible con Delta
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "HD Admin Auto-Spammer",
   LoadingTitle = "Iniciando Interfaz...",
   LoadingSubtitle = "Optimizando para Delta",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Comandos", nil)

-- Variables de control
local targetCommand = ""
local isSpamming = false
local spamDelay = 0.1 -- Tiempo entre clicks en segundos

MainTab:CreateInput({
   Name = "Nombre del Comando (ej. aaa, aab)",
   PlaceholderText = "Ingresa el nombre del comando a ejecutar",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommand = Text
   end,
})

MainTab:CreateToggle({
   Name = "Automatizar Ejecución",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         task.spawn(function()
            while isSpamming do
               -- Usamos pcall para evitar que el script crashee si la GUI no ha cargado
               pcall(function()
                  local player = game.Players.LocalPlayer
                  -- Navegación basada en los logs: HDAdminInterface -> MainFrame -> ... -> Commands -> [Comando] -> RunCommand
                  local hdGui = player.PlayerGui:FindFirstChild("HDAdminInterface")
                  
                  if hdGui and targetCommand ~= "" then
                     local commandsPage = hdGui.MainFrame.Pages.Commands.Commands
                     local cmdFrame = commandsPage:FindFirstChild(targetCommand)
                     
                     if cmdFrame then
                        local runBtn = cmdFrame:FindFirstChild("RunCommand")
                        
                        if runBtn then
                           -- Intentar ejecutar el evento de click (métodos soportados por Delta)
                           if firesignal then
                              firesignal(runBtn.MouseButton1Click)
                           else
                              -- Fallback de seguridad si firesignal falla
                              for _, connection in pairs(getconnections(runBtn.MouseButton1Click)) do
                                 connection:Fire()
                              end
                           end
                        end
                     end
                  end
               end)
               
               -- Yield necesario para no congelar el juego (Delta Main Thread)
               task.wait(spamDelay) 
            end
         end)
      end
   end,
})

-- Opcional: Un slider para ajustar la velocidad del loop sin tocar el código
MainTab:CreateSlider({
   Name = "Velocidad de Spam (Segundos)",
   Range = {0.05, 2},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.1,
   Flag = "SpamDelay",
   Callback = function(Value)
      spamDelay = Value
   end,
})
