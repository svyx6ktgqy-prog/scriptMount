-- =======================================================
-- Rayfield Auto-Load + Botón Circular Arrastrable "TEST"
-- =======================================================

local CoreGui = game:GetService("CoreGui")

local function GetGuiParent()
    if gethui then return gethui()
    elseif syn and syn.protect_gui then return CoreGui
    else return CoreGui end
end
local GuiParent = GetGuiParent()

-- 1. CARGAR E INICIAR RAYFIELD
task.spawn(function()
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)

    if not success or not Rayfield then
        warn("❌ Error al descargar o ejecutar Rayfield.")
        return
    end

    local Window = Rayfield:CreateWindow({
        Name = "Rayfield Modificado",
        LoadingTitle = "Iniciando menú...",
        LoadingSubtitle = "Generando botón flotante...",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    local Tab = Window:CreateTab("Inicio", 4483362458)
    Tab:CreateLabel("El botón flotante de Rayfield ha sido reemplazado por el círculo TEST.")

    -- 2. ESPERAR Y TRANSFORMAR EL BOTÓN "PROMPT"
    task.spawn(function()
        local prompt = nil
        local attempts = 0
        
        -- Escanear la memoria hasta que Rayfield instancie el botón
        while not prompt and attempts < 30 do
            task.wait(0.1)
            attempts = attempts + 1
            for _, gui in ipairs(GuiParent:GetChildren()) do
                local rayfieldFolder = gui:FindFirstChild("Rayfield")
                if rayfieldFolder and rayfieldFolder:FindFirstChild("Prompt") then
                    prompt = rayfieldFolder.Prompt
                    break
                end
            end
        end

        if not prompt then
            warn("❌ No se encontró el botón Prompt tras la carga.")
            return
        end

        -- 3. LIMPIEZA DEL CONTENIDO ORIGINAL
        for _, child in ipairs(prompt:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        -- 4. CONVERSIÓN A CÍRCULO "TEST"
        prompt.Size = UDim2.new(0, 60, 0, 60)
        prompt.Position = UDim2.new(0.5, -30, 0.2, 0) -- Aparece centrado en pantalla visible
        prompt.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        prompt.BorderSizePixel = 0
        prompt.ZIndex = 9999

        -- Forma Circular
        local uiCorner = prompt:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = prompt

        -- Borde verde
        local uiStroke = prompt:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(0, 255, 150)
        uiStroke.Thickness = 2
        uiStroke.Parent = prompt

        -- Etiqueta de Texto
        local testLabel = Instance.new("TextLabel")
        testLabel.Name = "TestLabel"
        testLabel.Size = UDim2.new(1, 0, 1, 0)
        testLabel.BackgroundTransparency = 1
        testLabel.Text = "TEST"
        testLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        testLabel.TextSize = 13
        testLabel.Font = Enum.Font.GothamBold
        testLabel.ZIndex = 10000
        testLabel.Parent = prompt

        -- Activar Arrastre Móvil
        prompt.Active = true
        prompt.Draggable = true

        print("✅ Rayfield cargado. Botón reemplazado con éxito por un círculo 'TEST' arrastrable.")
    end)
end)
