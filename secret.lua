-- 1. Cargar la librería oficial de Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. Inicialización de la ventana principal
local Window = Rayfield:CreateWindow({
   Name = "Secret Menu Access 🎒",
   LoadingTitle = "Bypassing Configure GUI...",
   LoadingSubtitle = "by ALB8RAAQ",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "SecretMenu"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = false -- Cambia a true si quieres ponerle una contraseña
})

-- 3. Creación de la pestaña
local SecretTab = Window:CreateTab("Mutations & Config", "eye")
local Player = game:GetService("Players").LocalPlayer

-- Función segura para encontrar el menú oculto
local function GetSecretGUI()
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if not PlayerGui then return nil end
    return PlayerGui:FindFirstChild("Configure")
end

-- ==========================================
-- SECCIÓN: Bypass de Visibilidad
-- ==========================================
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

-- ==========================================
-- SECCIÓN: Acciones Directas
-- ==========================================
SecretTab:CreateSection("Acciones Directas (Log Replicators)")

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
                       
                       -- Si tu ejecutor soporta simulación de clics, descomenta la siguiente línea quitando los guiones:
                       -- firesignal(btn.MouseButton1Click)
                   else
                       Rayfield:Notify({Title = "Error", Content = "El botón " .. mutName .. " no existe o aún no ha cargado.", Duration = 3})
                   end
               end)
           end
       end,
    })
end

-- ==========================================
-- SECCIÓN: Utilidades
-- ==========================================
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

-- Opcional: Carga inicial finalizada
Rayfield:LoadConfiguration()
