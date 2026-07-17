-- Inicialización de Rayfield (Asegúrate de tener la librería cargada en tu script base)
local Window = Rayfield:CreateWindow({
   Name = "Secret Menu Access 🎒",
   LoadingTitle = "Bypassing Configure GUI...",
   LoadingSubtitle = "by ALB8RAAQ",
   ConfigurationSaving = { Enabled = false }
})

local SecretTab = Window:CreateTab("Mutations & Config", "eye")
local Player = game:GetService("Players").LocalPlayer

-- Función segura para encontrar el menú
local function GetSecretGUI()
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if not PlayerGui then return nil end
    return PlayerGui:FindFirstChild("Configure")
end

SecretTab:CreateSection("Bypass de Visibilidad")

SecretTab:CreateButton({
   Name = "Forzar Apertura: Menú Principal (Configure)",
   Callback = function()
       local configGui = GetSecretGUI()
       if configGui then
           configGui.Enabled = true -- Activa el ScreenGui
           local frame = configGui:FindFirstChild("Frame")
           if frame then
               frame.Visible = true
               Rayfield:Notify({Title = "Éxito", Content = "Menú 'Configure' revelado en pantalla.", Duration = 3})
           else
               Rayfield:Notify({Title = "Error", Content = "No se encontró el Frame principal.", Duration = 3})
           end
       else
           Rayfield:Notify({Title = "No encontrado", Content = "El menú Configure no está cargado en tu PlayerGui.", Duration = 3})
       end
   end,
})

SecretTab:CreateButton({
   Name = "Forzar Apertura: Panel de Mutaciones",
   Callback = function()
       local configGui = GetSecretGUI()
       if configGui and configGui:FindFirstChild("Frame") then
           configGui.Enabled = true
           configGui.Frame.Visible = true
           
           -- Ocultar el panel de selección y mostrar directamente el de mutaciones
           local selectFrame = configGui.Frame:FindFirstChild("SelectFrame")
           local mutFrame = configGui.Frame:FindFirstChild("MutationsFrame")
           
           if selectFrame then selectFrame.Visible = false end
           if mutFrame then 
               mutFrame.Visible = true 
               Rayfield:Notify({Title = "Mutaciones Abiertas", Content = "Panel de mutaciones visible.", Duration = 3})
           end
       end
   end,
})

SecretTab:CreateSection("Acciones Directas (Log Replicators)")

-- Si forzar la visibilidad no basta, estos botones intentan "simular" un clic o acceder a los botones del log.
local mutations = {"Wet", "Fire", "Aurora"}

for _, mutName in ipairs(mutations) do
    SecretTab:CreateButton({
       Name = "Activar Mutación: " .. mutName,
       Callback = function()
           local configGui = GetSecretGUI()
           if configGui then
               pcall(function()
                   -- Intentar encontrar el botón basado en el log
                   local btn = configGui.Frame.MutationsFrame[mutName]
                   if btn then
                       -- Hacemos el botón visible por si acaso
                       btn.Visible = true
                       configGui.Enabled = true
                       configGui.Frame.Visible = true
                       configGui.Frame.MutationsFrame.Visible = true
                       
                       Rayfield:Notify({Title = "Botón Revelado", Content = "Haz clic en " .. mutName .. " en la pantalla.", Duration = 3})
                       
                       -- Si tu ejecutor soporta simulación de clics (firesignal), descomenta la siguiente línea:
                       -- si firesignal(btn.MouseButton1Click) end
                   else
                       Rayfield:Notify({Title = "Error", Content = "El botón " .. mutName .. " no existe o aún no ha cargado.", Duration = 3})
                   end
               end)
           end
       end,
    })
end

SecretTab:CreateSection("Utilidades")

SecretTab:CreateButton({
   Name = "Revelar Botón de Venta Oculto (Sell)",
   Callback = function()
       pcall(function()
           local sellGui = Player.PlayerGui:FindFirstChild("Sell")
           if sellGui and sellGui:FindFirstChild("Frame") then
               sellGui.Enabled = true
               sellGui.Frame.Visible = true
               
               if sellGui.Frame:FindFirstChild("Sell") then
                   sellGui.Frame.Sell.Visible = true
               end
               Rayfield:Notify({Title = "Sell UI Revelado", Content = "El menú de venta ha sido forzado a ser visible.", Duration = 3})
           end
       end)
   end,
})
