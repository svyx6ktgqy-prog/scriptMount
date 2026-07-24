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
   Name = "HD Admin | VIM CLICKER",
   LoadingTitle = "Iniciando Motor VIM...",
   LoadingSubtitle = "Clics a nivel de Hardware",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------------
-- PESTAÑA 1: SPAM VIM (CLIC FÍSICO)
----------------------------------------------------------------------
local CommandTab = Window:CreateTab("Spam Físico", nil)

local targetCommandName = ""
local isSpamming = false
local spamDelay = 0.5 

-- SERVICIO VIRTUAL DE ENTRADA (El Santo Grial para GUIs rebeldes)
local vim = game:GetService("VirtualInputManager")
local guiService = game:GetService("GuiService")

local function VIMClick(button)
    -- Obtener la posición y tamaño absolutos del botón en la pantalla
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    
    -- Calcular el centro exacto del botón
    local centerX = absPos.X + (absSize.X / 2)
    local centerY = absPos.Y + (absSize.Y / 2)
    
    -- Compensar el margen superior (Topbar) de Roblox para no fallar el clic
    local inset, _ = guiService:GetGuiInset()
    centerY = centerY + inset.Y

    -- Emular Clic Izquierdo del ratón (Presionar y Soltar)
    vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1) -- Botón Presionado
    task.wait(0.05) -- Pequeño retraso humano
    vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1) -- Botón Soltado
end

CommandTab:CreateInput({
   Name = "Comando en pantalla (Ej: aab)",
   PlaceholderText = "Escribe el comando y ABRE EL MENÚ",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      targetCommandName = Text
   end,
})

CommandTab:CreateToggle({
   Name = "Iniciar Clics Físicos",
   CurrentValue = false,
   Flag = "SpamToggle",
   Callback = function(Value)
      isSpamming = Value
      
      if isSpamming then
         if targetCommandName == "" then
             Rayfield:Notify({Title = "Error", Content = "Pon el nombre del comando.", Duration = 3})
             isSpamming = false
             return
         end

         task.spawn(function()
            local player = game.Players.LocalPlayer
            
            while isSpamming do
               pcall(function()
                   -- Ruta exacta de tu Log
                   local hdInterface = player.PlayerGui:FindFirstChild("HDAdminInterface")
                   if hdInterface then
                       local commandsPage = hdInterface:FindFirstChild("MainFrame")
                                            and hdInterface.MainFrame:FindFirstChild("Pages")
                                            and hdInterface.MainFrame.Pages:FindFirstChild("Commands")
                                            and hdInterface.MainFrame.Pages.Commands:FindFirstChild("Commands")
                       
                       if commandsPage then
                           local cmdFrame = commandsPage:FindFirstChild(targetCommandName)
                           if cmdFrame then
                               local runBtn = cmdFrame:FindFirstChild("RunCommand")
                               -- Verificar que el botón existe y es visible en pantalla
                               if runBtn and runBtn.AbsolutePosition.X > 0 then
                                   VIMClick(runBtn)
                               else
                                   warn("El botón no está visible en la pantalla. ¡Abre el menú!")
                               end
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
   Name = "Velocidad (Segundos)",
   Range = {0.1, 3},
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
      Rayfield:Notify({Title = "Server Hop", Content = "Buscando...", Duration = 3})

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
