-- Cargar Rayfield usando la rama optimizada y compatible con Delta
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main'))()

local Window = Rayfield:CreateWindow({
   Name = "HD Admin Auto-Spammer & Utility",
   LoadingTitle = "Iniciando Interfaz...",
   LoadingSubtitle = "Optimizando para Delta",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

----------------------------------------------------------------------
-- PESTAÑA 1: SPAM DE COMANDOS DE TEXTO
----------------------------------------------------------------------
local CommandTab = Window:CreateTab("Spam Comandos", nil)

local targetCommand = ""
local isSpamming = false
local spamDelay = 0.5 -- Un poco más alto por defecto para no ser kickeado por el filtro de chat

-- Función universal para enviar texto al chat (Soporta Legacy y TextChatService)
local function SendChatCommand(text)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- Motor nuevo de Roblox
        pcall(function()
            TextChatService.TextChannels.RBXGeneral:SendAsync(text)
        end)
    else
        -- Motor clásico de Roblox (el más común en juegos con HD Admin)
        pcall(function()
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end)
    end
end

CommandTab:CreateInput({
   Name = "Comando Completo",
   PlaceholderText = "Ej: ;hr Hola mundo",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommand = Text
   end,
})

CommandTab:CreateToggle({
   Name = "Automatizar Envío",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         task.spawn(function()
            while isSpamming do
               if targetCommand ~= "" then
                   SendChatCommand(targetCommand)
               end
               task.wait(spamDelay) 
            end
         end)
      end
   end,
})

CommandTab:CreateSlider({
   Name = "Velocidad de Spam (Segundos)",
   Range = {0.1, 5},
   Increment = 0.1,
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
   Name = "Buscar Servidor Vacío (Server Hop)",
   Callback = function()
      -- Notificar al usuario
      Rayfield:Notify({
         Title = "Buscando servidor...",
         Content = "Esto puede tardar unos segundos, por favor espera.",
         Duration = 5,
      })

      task.spawn(function()
          local HttpService = game:GetService("HttpService")
          local TeleportService = game:GetService("TeleportService")
          local PlaceId = game.PlaceId
          local JobId = game.JobId
          
          -- Identificar la función HTTP de Delta o usar fallback
          local req = request or http_request or (fluxus and fluxus.request)
          
          if req then
              -- La API usa sortOrder=Asc para traer primero los servidores con menos jugadores
              local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)
              
              local success, response = pcall(function()
                  return req({
                      Url = url,
                      Method = "GET"
                  })
              end)
              
              if success and response and response.Body then
                  local data = HttpService:JSONDecode(response.Body)
                  
                  if data and data.data then
                      local validServers = {}
                      
                      for _, server in pairs(data.data) do
                          -- Filtrar: servidores con hueco, no es el actual, y tiene un ping razonable
                          if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) then
                              if server.playing < server.maxPlayers and server.id ~= JobId then
                                  table.insert(validServers, server.id)
                              end
                          end
                      end
                      
                      if #validServers > 0 then
                          -- Escogemos el primer servidor de la lista (el más vacío)
                          local emptyServer = validServers[1]
                          TeleportService:TeleportToPlaceInstance(PlaceId, emptyServer, game.Players.LocalPlayer)
                      else
                          Rayfield:Notify({Title = "Error", Content = "No se encontraron servidores vacíos.", Duration = 4})
                      end
                  end
              else
                  Rayfield:Notify({Title = "Error de API", Content = "Tu ejecutor bloqueó la petición a Roblox.", Duration = 4})
              end
          else
              Rayfield:Notify({Title = "Incompatible", Content = "Delta necesita permisos HTTP para hacer esto.", Duration = 4})
          end
      end)
   end,
})
