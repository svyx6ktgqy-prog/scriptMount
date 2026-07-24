-- 1. Esperar a que el juego y el jugador estén completamente cargados
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.Players.LocalPlayer

-- 2. Cargar Rayfield modificado de forma segura
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
end)

if not success or type(Rayfield) ~= "table" then
    warn("Error crítico: No se pudo cargar Rayfield. Revisa tu internet o Delta.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "HD Admin | ROBUST SPAMMER",
   LoadingTitle = "Iniciando Sistema...",
   LoadingSubtitle = "Modo: Fuerza Bruta Multi-API",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------------
-- PESTAÑA 1: SPAM ROBUSTO DE COMANDOS
----------------------------------------------------------------------
local CommandTab = Window:CreateTab("Spam Robusto", nil)

local targetCommand = ""
local isSpamming = false
local spamDelay = 0.5 

-- Función ULTRA ROBUSTA para forzar el mensaje
local function ForceSendMessage(text)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local sent = false

    -- Intento 1: Nuevo Sistema de Chat de Roblox (TextChatService)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        pcall(function()
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(text)
                sent = true
            end
        end)
    end

    -- Intento 2: Sistema Clásico (Legacy API) - El más común en juegos HD Admin
    if not sent then
        pcall(function()
            local defaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChat and defaultChat:FindFirstChild("SayMessageRequest") then
                defaultChat.SayMessageRequest:FireServer(text, "All")
                sent = true
            end
        end)
    end
end

-- Declarar la variable del Toggle antes para poder referenciarla
local SpamToggleRef 

CommandTab:CreateInput({
   Name = "Comando (¡PRESIONA ENTER AL FINAL!)",
   PlaceholderText = "Ej: ;hr Hola mundo -> LUEGO PRESIONA ENTER",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommand = Text
   end,
})

SpamToggleRef = CommandTab:CreateToggle({
   Name = "Forzar Spam",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         -- VALIDACIÓN DE SEGURIDAD: Evitar fallos silenciosos
         if targetCommand == nil or targetCommand == "" or targetCommand:match("^%s*$") then
             Rayfield:Notify({
                 Title = "⚠️ Comando Vacío",
                 Content = "No has presionado ENTER en el cuadro de texto. Escribe y presiona ENTER primero.",
                 Duration = 5,
             })
             isSpamming = false
             SpamToggleRef:Set(false) -- Apaga el switch de vuelta
             return
         end

         task.spawn(function()
            while isSpamming do
               ForceSendMessage(targetCommand)
               
               -- Micro-variación (Jitter) para que Roblox no detecte un patrón robótico y silencie el chat
               local jitter = math.random(1, 10) / 100 
               task.wait(spamDelay + jitter) 
            end
         end)
      end
   end,
})

CommandTab:CreateSlider({
   Name = "Velocidad de Envío (Segundos)",
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
   Name = "Buscar Servidor Vacío",
   Callback = function()
      Rayfield:Notify({
         Title = "Iniciando Server Hop",
         Content = "Obteniendo datos de la API. Espera...",
         Duration = 5,
      })

      task.spawn(function()
          local HttpService = game:GetService("HttpService")
          local TeleportService = game:GetService("TeleportService")
          local PlaceId = game.PlaceId
          local JobId = game.JobId
          
          local req = request or http_request or (fluxus and fluxus.request)
          
          if req then
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
                          TeleportService:TeleportToPlaceInstance(PlaceId, validServers[1], game.Players.LocalPlayer)
                      else
                          Rayfield:Notify({Title = "Aviso", Content = "No hay servidores más vacíos que este.", Duration = 4})
                      end
                  end
              else
                  Rayfield:Notify({Title = "Error API", Content = "Petición bloqueada por tu versión de Delta.", Duration = 4})
              end
          else
              Rayfield:Notify({Title = "Incompatible", Content = "Faltan permisos HTTP en el ejecutor.", Duration = 4})
          end
      end)
   end,
})
