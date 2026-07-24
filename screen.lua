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
   Name = "SCREEN FIX ULTIMATE",
   LoadingTitle = "Cargando Fixes...",
   LoadingSubtitle = "Destruyendo bloqueos verticales",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------------
-- VARIABLES GLOBALES
----------------------------------------------------------------------
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local forceLoopConnection = nil

-- Función maestra para forzar la orientación en todos los frentes
local function SetScreenOrientation(mode)
    pcall(function()
        -- 1. Forzar en la interfaz activa actual
        if PlayerGui then
            PlayerGui.ScreenOrientation = mode
        end
        -- 2. Forzar en la base para futuras interfaces que carguen
        if StarterGui then
            StarterGui.ScreenOrientation = mode
        end
    end)
end

----------------------------------------------------------------------
-- PESTAÑA 1: FIX PRINCIPAL Y MÉTODOS DIRECTOS
----------------------------------------------------------------------
local MainTab = Window:CreateTab("Rotación Base", nil)

MainTab:CreateSection("Método Definitivo (Anti-Reversión)")

MainTab:CreateToggle({
   Name = "Fuerza Bruta (Evita que el juego lo quite)",
   CurrentValue = false,
   Flag = "ForceLoop",
   Callback = function(Value)
      if Value then
          -- Inicia un bucle infinito pegado al motor de renderizado del juego
          forceLoopConnection = RunService.RenderStepped:Connect(function()
              pcall(function()
                  if PlayerGui.ScreenOrientation ~= Enum.ScreenOrientation.LandscapeSensor then
                      PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
                      StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
                  end
              end)
          end)
          Rayfield:Notify({Title = "Fuerza Bruta ON", Content = "El juego ya no podrá forzar la pantalla vertical.", Duration = 4})
      else
          -- Apaga el bucle
          if forceLoopConnection then
              forceLoopConnection:Disconnect()
              forceLoopConnection = nil
          end
          Rayfield:Notify({Title = "Fuerza Bruta OFF", Content = "Bucle detenido.", Duration = 2})
      end
   end,
})

MainTab:CreateSection("Métodos de 1 Solo Uso")

MainTab:CreateButton({
   Name = "Forzar Horizontal (Izquierda)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeLeft)
      Rayfield:Notify({Title = "Aplicado", Content = "Landscape Left forzado.", Duration = 2})
   end,
})

MainTab:CreateButton({
   Name = "Forzar Horizontal (Derecha)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeRight)
      Rayfield:Notify({Title = "Aplicado", Content = "Landscape Right forzado.", Duration = 2})
   end,
})

MainTab:CreateButton({
   Name = "Forzar Horizontal (Sensor Automático)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.LandscapeSensor)
      Rayfield:Notify({Title = "Aplicado", Content = "Landscape Sensor forzado.", Duration = 2})
   end,
})

MainTab:CreateButton({
   Name = "Restaurar a la Normalidad (Desbloquear)",
   Callback = function()
      SetScreenOrientation(Enum.ScreenOrientation.Sensor)
      Rayfield:Notify({Title = "Restaurado", Content = "Orientación libre habilitada.", Duration = 2})
   end,
})

----------------------------------------------------------------------
-- PESTAÑA 2: REPARACIÓN DE PANTALLA Y CÁMARA
----------------------------------------------------------------------
local FixTab = Window:CreateTab("Parches UI", nil)

FixTab:CreateSection("Solución de Interfaces Rotas")

FixTab:CreateButton({
   Name = "Destruir Bloqueos de Tamaño (UI Constraints)",
   Callback = function()
      -- Muchos juegos verticales bloquean los menús para que no se estiren en horizontal. Esto los destruye.
      local destroyedCount = 0
      for _, element in pairs(PlayerGui:GetDescendants()) do
          if element:IsA("UIAspectRatioConstraint") or element:IsA("UISizeConstraint") then
              element:Destroy()
              destroyedCount = destroyedCount + 1
          end
      end
      Rayfield:Notify({Title = "Limpieza Completada", Content = "Se destruyeron " .. destroyedCount .. " bloqueos de interfaz.", Duration = 4})
   end,
})

FixTab:CreateSlider({
   Name = "Ajustar Zoom / FOV (Campo de visión)",
   Range = {10, 120},
   Increment = 1,
   Suffix = " FOV",
   CurrentValue = 70,
   Flag = "CameraFOV",
   Callback = function(Value)
      pcall(function()
          workspace.CurrentCamera.FieldOfView = Value
      end)
   end,
})
