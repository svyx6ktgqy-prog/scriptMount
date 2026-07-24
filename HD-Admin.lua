if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()
end)

if not success or type(Rayfield) ~= "table" then
    warn("Error al cargar Rayfield.")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "HD Admin | OVERRIDE EXTREMO",
   LoadingTitle = "Bypass de Chat...",
   LoadingSubtitle = "Secuestrando Interfaz Local",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------------
-- PESTAÑA 1: SPAM EXTREMO (GUI HIJACKING)
----------------------------------------------------------------------
local CommandTab = Window:CreateTab("Spam Bypass", nil)

local targetCommand = ""
local isSpamming = false
local spamDelay = 0.5 

-- FUNCIÓN DE FUERZA BRUTA: Secuestro de Chat UI
local function ExtremeGUIHijack(text)
    local player = game.Players.LocalPlayer
    local fired = false

    -- MÉTODO EXTREMO 1: Secuestro del Chat Clásico (Legacy)
    pcall(function()
        local chatBar = player.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
        if chatBar then
            chatBar.Text = text
            -- getconnections captura las conexiones internas del juego.
            -- Obligamos al juego a creer que se pulsó ENTER (true = presionado).
            for _, connection in pairs(getconnections(chatBar.FocusLost)) do
                connection:Fire(true)
            end
            fired = true
        end
    end)

    -- MÉTODO EXTREMO 2: Secuestro del TextChatService (Juegos Modernos)
    if not fired then
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            -- Delta puede acceder a CoreGui si tiene el Identity correcto
            local newChatBox = coreGui:FindFirstChild("ExperienceChat"):FindFirstChild("appLayout"):FindFirstChild("chatInputBar"):FindFirstChild("background"):FindFirstChild("TextBox", true)
            
            if newChatBox then
                newChatBox.Text = text
                for _, connection in pairs(getconnections(newChatBox.FocusLost)) do
                    connection:Fire(true)
                end
                fired = true
            end
        end)
    end

    -- MÉTODO EXTREMO 3: Ataque directo al Remote de ReplicatedStorage como Fallback
    if not fired then
        pcall(function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end)
    end
end

CommandTab:CreateInput({
   Name = "Comando a forzar",
   PlaceholderText = "Ej: ;hr Hola mundo",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommand = Text
   end,
})

CommandTab:CreateToggle({
   Name = "Ejecutar Secuestro de Chat",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         if targetCommand == "" then
             Rayfield:Notify({Title = "Error", Content = "Escribe un comando primero.", Duration = 3})
             return
         end

         task.spawn(function()
            while isSpamming do
               ExtremeGUIHijack(targetCommand)
               task.wait(spamDelay) 
            end
         end)
      end
   end,
})

CommandTab:CreateSlider({
   Name = "Delay (Segundos)",
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
