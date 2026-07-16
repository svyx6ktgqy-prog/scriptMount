-- ==================================================
-- [ ALB8RAAQ ] - K2 WARP FORCER
-- ==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Crear una Interfaz Minimalista y Única
local function CreateWarpUI()
    -- Limpiar versión anterior si existe
    if CoreGui:FindFirstChild("ALB8RAAQ_Warp") then
        CoreGui.ALB8RAAQ_Warp:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ALB8RAAQ_Warp"
    ScreenGui.Parent = CoreGui

    local WarpFrame = Instance.new("Frame")
    WarpFrame.Size = UDim2.new(0, 180, 0, 60)
    WarpFrame.Position = UDim2.new(0.5, -90, 0.1, 0) -- Parte superior central
    WarpFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    WarpFrame.BorderSizePixel = 0
    WarpFrame.Active = true
    WarpFrame.Draggable = true
    WarpFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = WarpFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 200, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = WarpFrame

    local WarpBtn = Instance.new("TextButton")
    WarpBtn.Size = UDim2.new(1, -10, 1, -10)
    WarpBtn.Position = UDim2.new(0, 5, 0, 5)
    WarpBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    WarpBtn.Text = "⚡ FORZAR VIAJE: K2"
    WarpBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    WarpBtn.Font = Enum.Font.Code
    WarpBtn.TextSize = 14
    WarpBtn.Parent = WarpFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = WarpBtn

    return WarpBtn
end

-- Función Lógica para Forzar el Clic
local function ForceK2Travel()
    -- Navegación segura por la ruta extraída de tus logs
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return warn("[ALB8RAAQ] PlayerGui no encontrado.") end

    local K2_Button = PlayerGui:FindFirstChild("Mountains")
        and PlayerGui.Mountains:FindFirstChild("Main")
        and PlayerGui.Mountains.Main:FindFirstChild("MountainFrame")
        and PlayerGui.Mountains.Main.MountainFrame:FindFirstChild("Holder")
        and PlayerGui.Mountains.Main.MountainFrame.Holder:FindFirstChild("K2")

    if not K2_Button then
        return warn("[ALB8RAAQ] ERROR: No se pudo encontrar el botón K2. ¿El menú Mountains está cargado en el juego?")
    end

    print("[ALB8RAAQ] Iniciando protocolo de salto a K2...")

    -- Intentar ejecutar las conexiones nativas del botón usando exploits
    local success = false

    if getconnections then
        for _, connection in pairs(getconnections(K2_Button.MouseButton1Click)) do
            connection:Fire()
            success = true
        end
        for _, connection in pairs(getconnections(K2_Button.MouseButton1Down)) do
            connection:Fire()
            success = true
        end
    elseif firesignal then
        firesignal(K2_Button.MouseButton1Click)
        firesignal(K2_Button.MouseButton1Down)
        success = true
    end

    if success then
        print("[ALB8RAAQ] ✅ Señal de viaje enviada exitosamente al servidor.")
        
        -- Efecto visual en el botón de nuestro módulo
        local btn = CoreGui.ALB8RAAQ_Warp.Frame.TextButton
        btn.Text = "CARGANDO..."
        btn.TextColor3 = Color3.fromRGB(50, 255, 50)
        task.wait(1)
        btn.Text = "⚡ FORZAR VIAJE: K2"
        btn.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        warn("[ALB8RAAQ] ❌ Tu ejecutor no soporta firesignal o getconnections.")
    end
end

-- Inicializar el Módulo
local ActionButton = CreateWarpUI()
ActionButton.MouseButton1Click:Connect(ForceK2Travel)

print("[ALB8RAAQ] Módulo de Viaje Forzado cargado. Arrastra el panel donde te sea cómodo.")
