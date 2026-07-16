-- Inicializar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear Ventana Principal
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ", -- Título del menú
   LoadingTitle = "Cargando scripts de fuego...",
   LoadingSubtitle = "por Gemini",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Crear Pestaña
local Tab = Window:CreateTab("Efectos de Fuego", 4483362458) 

-- Variable para el jugador local
local player = game.Players.LocalPlayer

-- Funciones Auxiliares
local function limpiarFuego(parent)
    -- Busca y destruye cualquier fuego creado previamente por este script
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "FuegoCustom" then
            child:Destroy()
        end
    end
end

-- ==========================================
-- SECCIÓN 1: FUEGO EN LA HERRAMIENTA (PICO)
-- ==========================================
local SectionTool = Tab:CreateSection("Herramienta / Pico")

Tab:CreateButton({
   Name = "Quemar Herramienta Equipada",
   Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        -- Busca la herramienta activa (ej. "Weathered Wood")
        local tool = character:FindFirstChildOfClass("Tool")
        
        if tool and tool:FindFirstChild("Handle") then
            local handle = tool.Handle
            limpiarFuego(handle) -- Evita duplicados
            
            -- Crea e incrusta el fuego en el pico
            local fire = Instance.new("Fire")
            fire.Name = "FuegoCustom"
            fire.Size = 5
            fire.Heat = 9
            fire.Parent = handle
            
            Rayfield:Notify({
                Title = "¡Éxito!",
                Content = "Fuego incrustado en: " .. tool.Name,
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "¡Debes equipar una herramienta en tu mano primero!",
                Duration = 3,
                Image = 4483362458,
            })
        end
   end,
})

Tab:CreateButton({
   Name = "Apagar Fuego de Herramienta",
   Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            limpiarFuego(tool.Handle)
        end
   end,
})

-- ==========================================
-- SECCIÓN 2: FUEGO EN LA CABEZA
-- ==========================================
local SectionHead = Tab:CreateSection("Jugador")

Tab:CreateButton({
   Name = "Quemar Cabeza del Jugador",
   Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local head = character:FindFirstChild("Head")
        
        if head then
            limpiarFuego(head) -- Evita duplicados
            
            -- Crea e incrusta el fuego en la cabeza
            local fire = Instance.new("Fire")
            fire.Name = "FuegoCustom"
            fire.Size = 6
            fire.Heat = 15
            fire.Parent = head
            
            Rayfield:Notify({
                Title = "¡Éxito!",
                Content = "Fuego incrustado en tu cabeza.",
                Duration = 3,
                Image = 4483362458,
            })
        end
   end,
})

Tab:CreateButton({
   Name = "Apagar Fuego de Cabeza",
   Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local head = character:FindFirstChild("Head")
        if head then
            limpiarFuego(head)
        end
   end,
})
