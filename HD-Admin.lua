-- Esperar a que el juego y el jugador estén cargados
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

-- Cargar Rayfield de forma segura
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
end)

if not success or type(Rayfield) ~= "table" then
    warn("Error al cargar la interfaz. Revisa tu conexión.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "HD Admin | GUI CLICKER EXTREMO",
   LoadingTitle = "Iniciando Sistema...",
   LoadingSubtitle = "Modo: Fuerza Bruta de Interfaz",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------------
-- PESTAÑA 1: SPAM DE INTERFAZ (GUI CLICKER)
----------------------------------------------------------------------
local CommandTab = Window:CreateTab("Spam GUI", nil)

local targetCommandName = ""
local isSpamming = false
local spamDelay = 0.5 

-- Función Robusta para disparar clics en botones de Roblox
local function ForceClickButton(button)
    -- Intento 1: Usar firesignal (Soportado por Delta)
    if firesignal then
        pcall(function() firesignal(button.MouseButton1Click) end)
        pcall(function() firesignal(button.Activated) end)
    end
    
    -- Intento 2: Usar getconnections (El más efectivo para interfaces personalizadas)
    if getconnections then
        pcall(function()
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(button.Activated)) do
                connection:Fire()
            end
        end)
    end
end

CommandTab:CreateInput({
   Name = "Nombre exacto del comando (Ej: aab)",
   PlaceholderText = "Escribe el comando que aparece en la lista",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommandName = Text
   end,
})

local SpamToggleRef = CommandTab:CreateToggle({
   Name = "Spamear Botón 'RunCommand'",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         if targetCommandName == "" then
             Rayfield:Notify({Title = "Aviso", Content = "Escribe el nombre del comando primero.", Duration = 3})
             isSpamming = false
             return
         end

         task.spawn(function()
            local player = game.Players.LocalPlayer
            
            while isSpamming do
               pcall(function()
                   -- Buscamos la ruta exacta basada en tus logs
                   local hdInterface = player.PlayerGui:FindFirstChild("HDAdminInterface")
                   if hdInterface then
                       local commandsPage = hdInterface:FindFirstChild("MainFrame")
                                            and hdInterface.MainFrame:FindFirstChild("Pages")
                                            and hdInterface.MainFrame.Pages:FindFirstChild("Commands")
                                            and hdInterface.MainFrame.Pages.Commands:FindFirstChild("Commands")
                       
                       if commandsPage then
                           -- Buscamos el frame del comando específico (ej: "aab")
                           local cmdFrame = commandsPage:FindFirstChild(targetCommandName)
                           if cmdFrame then
                               local runBtn = cmdFrame:FindFirstChild("RunCommand")
                               if runBtn then
                                   -- Disparamos el clic directamente al botón de la interfaz
                                   ForceClickButton(runBtn)
                               end
                           else
                               -- Si el comando no está cargado en la lista, avisamos en consola
                               warn("No se encontró el comando '" .. targetCommandName .. "' en la interfaz. Asegúrate de tener el menú de comandos abierto o cargado.")
                           end
                       end
                   end
               end)
               
               task.wait(spamDelay) 
            end
         end)
      end
   end,
})

CommandTab:CreateSlider({
   Name = "Velocidad de Clics (Segundos)",
   Range = {0.05, 3},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "SpamDelay",
   Callback = function(Value)
      spamDelay = Value
   end,
})

----------------------------------------------------------------------
-- PESTAÑA 2: SERVIDOR (SERVER HOPPING)
----------------------------------------------------------------------
local ServerTab = Window:CreateTab("Servidores", nil)

ServerTab:CreateButton({
   Name = "Buscar Servidor Vacío",
   Callback = function()
      Rayfield:Notify({Title = "Server Hop", Content = "Extrayendo IDs...", Duration = 3})

      task.spawn(function()
          local HttpService = game:GetService("HttpService")
          local TeleportService = game:GetService("TeleportService")
          
          local req = request or http_request or (fluxus and fluxus.request)
          if not req then return end
          
          local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
          
          local successReq, response = pcall(function() return req({Url = url, Method = "GET"}) end)
          
          if successReq and response and response.Body then
              local data = HttpService:JSONDecode(response.Body)
              if data and data.data then
                  for _, server in pairs(data.data) do
                      if type(server) == "table" and server.playing and server.maxPlayers then
                          if server.playing < server.maxPlayers and server.id ~= game.JobId then
                              TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                              return
                          end
                      end
                  end
              end
          end
      end)
   end,
})
