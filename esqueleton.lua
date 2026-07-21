-- =========================================================
-- MENU INDEPENDIENTE: TRANSFORMACIÓN ESQUELETO 💀
-- =========================================================
-- Cargando la misma librería Rayfield del arsenal[span_2](start_span)[span_2](end_span)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/svyx6ktgqy-prog/rayfield/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Character Esqueleto 💀",
   LoadingTitle = "Inyectando modificador visual...",
   LoadingSubtitle = "Menú Independiente",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Keybind = "RightControl" -- Usa Control Derecho para ocultar el menú
})

-- Servicios de Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Crear el apartado / pestaña
local SkeletonTab = Window:CreateTab("Esqueleto", 4483362458)

SkeletonTab:CreateParagraph({
    Title = "Transformación Visual Local",
    Content = "Al activar esto, tu cuerpo intentará transformarse en el esqueleto (ID: 295) y tu cabeza será reemplazada por la Agony Bomb.\n\nNota: Estos cambios son 'Client-Sided' (solo tú los ves) a menos que el juego permita replicación de HumanoidDescription."
})

-- Función central para transformar al jugador
local function TransformToAgonySkeleton()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local head = char:FindFirstChild("Head")
    if not hum or not head then return end

    -- 1. Aplicar el paquete de esqueleto (Usando ID 295)
    -- Se usa un pcall para evitar errores si el ID falla o el juego bloquea descripciones locales
    pcall(function()
        -- 295 es el ID solicitado. Si es un Outfit ID de Roblox, esto lo cargará.
        local skeletonDescription = Players:GetHumanoidDescriptionFromOutfitId(295)
        hum:ApplyDescription(skeletonDescription)
    end)

    -- 2. Buscar la Agony Bomb en la ruta de Assets[span_3](start_span)[span_3](end_span)
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local bombsFolder = assets and assets:FindFirstChild("Bombs")
    local agonyBomb = bombsFolder and bombsFolder:FindFirstChild("Agony Bomb")

    if agonyBomb then
        -- Encontrar la parte física de la bomba (Handle o un BasePart)
        local bombPart = agonyBomb:FindFirstChild("Handle") or agonyBomb:FindFirstChildWhichIsA("BasePart")
        
        if bombPart then
            -- Hacer la cabeza original invisible (incluyendo la cara)
            head.Transparency = 1
            if head:FindFirstChild("face") then
                head.face.Transparency = 1
            end
            if head:FindFirstChild("Decal") then
                head.Decal.Transparency = 1
            end

            -- Eliminar cualquier cabeza de bomba anterior si el usuario presiona el botón varias veces
            local oldCustomHead = char:FindFirstChild("AgonyHead_Custom")
            if oldCustomHead then 
                oldCustomHead:Destroy() 
            end

            -- Clonar la bomba y configurarla como la nueva cabeza
            local customHead = bombPart:Clone()
            customHead.Name = "AgonyHead_Custom"
            customHead.Parent = char
            customHead.CFrame = head.CFrame
            customHead.CanCollide = false
            customHead.Massless = true

            -- Soldar (Weld) la bomba a la cabeza original invisible para que se mueva con tu cuerpo
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = head
            weld.Part1 = customHead
            weld.Parent = customHead
        else
            warn("No se encontró una parte física dentro de la Agony Bomb para usar como cabeza.")
        end
    else
        warn("No se pudo encontrar la 'Agony Bomb' en ReplicatedStorage.Assets.Bombs.")
    end
end

-- Botón en la interfaz para activar la transformación
SkeletonTab:CreateButton({
   Name = "💀 Obtener Esqueleto (Cabeza Agony)",
   Callback = function()
        TransformToAgonySkeleton()
        Rayfield:Notify({
            Title = "Mutación Completada", 
            Content = "Tu cuerpo es un esqueleto y tu cabeza es una Agony Bomb.", 
            Duration = 3
        })
   end,
})
