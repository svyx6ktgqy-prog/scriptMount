-- 1. Esperar a que el juego y el jugador estén completamente cargados
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.Players.LocalPlayer

-- 2. Cargar tu versión específica de Rayfield de forma segura
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
end)

-- Si falla la carga, detenemos el script para no causar lag
if not success or type(Rayfield) ~= "table" then
    warn("Error al cargar Rayfield. Revisa tu conexión o el enlace.")
    return
end

-- 3. Crear la Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "HD Admin Auto-Spammer",
   LoadingTitle = "Iniciando Interfaz...",
   LoadingSubtitle = "Carga segura para Delta",
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
local spamDelay = 0.5 

-- Función universal para enviar texto al chat (Soporta Legacy y TextChatService)
local function SendChatCommand(text)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        pcall(function()
            TextChatService.TextChannels.RBXGeneral:SendAsync(text)
        end)
    else
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
          
          local req = request or http_request or (fluxus and fluxus.request)
          
          if req then
              -- Buscar servidores ordenados de menor a mayor cantidad de jugadores
              local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)
              
              local requestSuccess, response = pcall(function()
                  return req({ Url = url, Method = "GET" })
              end)
              
              if requestSuccess and response and response.Body then
                  local data = HttpService:JSONDecode(response.Body)
                  
                  if data and data.data then
                      local validServers = {}
                      
                      for _, server in pairs(data.data) do
                          if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) then
                              if server.playing < server.maxPlayers and server.id ~= JobId then
                                  table.insert(validServers, server.id)
                              end
                          end
                      end
                      
                      if #validServers > 0 then
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
