local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 1. Crear el GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodArgMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Sistema de seguridad para inyección en Delta iOS / Android
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 2. Botón Flotante para Móviles (Para abrir/cerrar)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0, 15)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "👽"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 22
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

-- 3. Ventana Principal (Estilo Carbón Oscuro - Ampliada para 4 botones y logs)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480) -- Altura aumentada para el panel de logs
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "HOOD ARGENTINO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Lógica para ocultar/mostrar menú tocando el botón flotante
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Lógica para arrastrar el menú (Touch/Mouse)
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Ventana Flotante de Info NPC (Mantenida igual)
local NpcFrame = Instance.new("Frame")
NpcFrame.Size = UDim2.new(0, 300, 0, 350)
NpcFrame.Position = UDim2.new(0.5, 170, 0.5, -175)
NpcFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NpcFrame.Visible = false
NpcFrame.Parent = ScreenGui

local NpcCorner = Instance.new("UICorner")
NpcCorner.CornerRadius = UDim.new(0, 8)
NpcCorner.Parent = NpcFrame

local NpcTitle = Instance.new("TextLabel")
NpcTitle.Size = UDim2.new(1, 0, 0, 40)
NpcTitle.BackgroundTransparency = 1
NpcTitle.Text = "DATOS DEL NPC"
NpcTitle.TextColor3 = Color3.fromRGB(110, 211, 55)
NpcTitle.Font = Enum.Font.GothamBold
NpcTitle.TextSize = 16
NpcTitle.Parent = NpcFrame

local CloseNpcBtn = Instance.new("TextButton")
CloseNpcBtn.Size = UDim2.new(0, 30, 0, 30)
CloseNpcBtn.Position = UDim2.new(1, -35, 0, 5)
CloseNpcBtn.BackgroundTransparency = 1
CloseNpcBtn.Text = "X"
CloseNpcBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseNpcBtn.Font = Enum.Font.GothamBold
CloseNpcBtn.TextSize = 16
CloseNpcBtn.Parent = NpcFrame

CloseNpcBtn.MouseButton1Click:Connect(function() NpcFrame.Visible = false end)

local NpcScroll = Instance.new("ScrollingFrame")
NpcScroll.Size = UDim2.new(1, -20, 1, -90)
NpcScroll.Position = UDim2.new(0, 10, 0, 40)
NpcScroll.BackgroundTransparency = 1
NpcScroll.BorderSizePixel = 0
NpcScroll.ScrollBarThickness = 4
NpcScroll.Parent = NpcFrame

local NpcInfoText = Instance.new("TextLabel")
NpcInfoText.Size = UDim2.new(1, -10, 0, 0)
NpcInfoText.BackgroundTransparency = 1
NpcInfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
NpcInfoText.Font = Enum.Font.Code
NpcInfoText.TextSize = 12
NpcInfoText.TextXAlignment = Enum.TextXAlignment.Left
NpcInfoText.TextYAlignment = Enum.TextYAlignment.Top
NpcInfoText.TextWrapped = true
NpcInfoText.AutomaticSize = Enum.AutomaticSize.Y
NpcInfoText.Parent = NpcScroll

local CopyNpcBtn = Instance.new("TextButton")
CopyNpcBtn.Size = UDim2.new(1, -20, 0, 35)
CopyNpcBtn.Position = UDim2.new(0, 10, 1, -45)
CopyNpcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CopyNpcBtn.Text = "Copiar NPC al Portapapeles"
CopyNpcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyNpcBtn.Font = Enum.Font.GothamBold
CopyNpcBtn.TextSize = 14
CopyNpcBtn.Parent = NpcFrame
Instance.new("UICorner", CopyNpcBtn).CornerRadius = UDim.new(0, 6)

CopyNpcBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(NpcInfoText.Text)
        CopyNpcBtn.Text = "¡Copiado con éxito!"
        CopyNpcBtn.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
        task.wait(1.5)
        CopyNpcBtn.Text = "Copiar NPC al Portapapeles"
        CopyNpcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        CopyNpcBtn.Text = "Tu ejecutor no soporta copiar"
        CopyNpcBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        CopyNpcBtn.Text = "Copiar NPC al Portapapeles"
        CopyNpcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- 4. Función constructora de Toggles
local function CreateToggle(name, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -30, 0, 45)
    ToggleFrame.Position = UDim2.new(0, 15, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.Parent = MainFrame
    
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 46, 0, 24)
    Btn.Position = UDim2.new(1, -60, 0.5, -12)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = ""
    Btn.Parent = ToggleFrame
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = UDim2.new(0, 2, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = Btn
    
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local toggled = false
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Btn.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
        else
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
        callback(toggled)
    end)
end

-- 5. Lógica de los Hacks

-- Toggle 1: Generador de Plata (Y: 60)
CreateToggle("Generador de Plata", 60, function(Value)
    getgenv().a = Value
    if Value then
        local p = workspace:FindFirstChild("map") and workspace.map:FindFirstChild("map_jobs") and workspace.map.map_jobs:FindFirstChild("pedidosYaJOB") and workspace.map.map_jobs.pedidosYaJOB:FindFirstChild("pedidosYaNPC") and workspace.map.map_jobs.pedidosYaJOB.pedidosYaNPC:FindFirstChild("Trigger")
        if not p then return end
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local oldCFrame = hrp.CFrame
        
        character:PivotTo(p.CFrame)
        task.wait(0.8)
        if p:FindFirstChild("ProximityPrompt") then fireproximityprompt(p.ProximityPrompt) end
        task.wait(0.5)
        character:PivotTo(oldCFrame)
        
        task.spawn(function()
            local eventsFolder = ReplicatedStorage:WaitForChild("Events", 5)
            local pedidosYaEvent = eventsFolder and eventsFolder:WaitForChild("pedidosya", 5)
            
            while getgenv().a do
                task.wait(0.3)
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local gui = playerGui and playerGui:FindFirstChild("pedidosYaGUI")
                    
                    if gui then
                        local rLoc, dLoc = gui:FindFirstChild("restaurantLocation"), gui:FindFirstChild("deliveryLocation")
                        local acceptBtn = gui:FindFirstChild("screenFrame") and gui.screenFrame:FindFirstChild("acceptButton")
                        if acceptBtn and type(firesignal) == "function" then pcall(function() firesignal(acceptBtn.MouseButton1Click) end) end
                        if pedidosYaEvent and rLoc and dLoc and rLoc.Value and dLoc.Value then
                            pedidosYaEvent:WaitForChild("attemptPickup"):FireServer(rLoc.Value)
                            pedidosYaEvent:WaitForChild("attemptDelivery"):FireServer(dLoc.Value)
                        end
                    end
                end)
            end
        end)
    end
end)

-- Toggle 2: Auto-Agarrar Plata (Y: 115)
getgenv().autoGrab = false
CreateToggle("Auto-Agarrar Plata", 115, function(Value) getgenv().autoGrab = Value end)
local function WatchCashFolder(folder)
    if not folder then return end
    folder.ChildAdded:Connect(function(v)
        if getgenv().autoGrab then
            local claimPrompt = v:WaitForChild("claim", 3) 
            if claimPrompt and claimPrompt:IsA("ProximityPrompt") then
                claimPrompt.HoldDuration = 0
                fireproximityprompt(claimPrompt)
            end
        end
    end)
end
task.spawn(function()
    local filter = workspace:WaitForChild("Filter", 10)
    if filter then WatchCashFolder(filter:FindFirstChild("CashDrops")) end
    local cuerposMuertos = workspace:WaitForChild("CuerposMuertos", 10)
    if cuerposMuertos then
        local cmFilter = cuerposMuertos:WaitForChild("Filter", 5)
        if cmFilter then WatchCashFolder(cmFilter:FindFirstChild("CashDrops")) end
    end
end)

-- Toggle 3: Inspector de NPC (Y: 170)
getgenv().npcDetector = false
CreateToggle("Inspector de NPC (Touch)", 170, function(Value)
    getgenv().npcDetector = Value
    if not Value then NpcFrame.Visible = false end
end)
local Mouse = LocalPlayer:GetMouse()
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not getgenv().npcDetector then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                local info = "NPC: " .. model.Name .. "\n\n[ ATRIBUTOS ]\n"
                local hasAttrs = false
                for k, v in pairs(model:GetAttributes()) do info = info .. k .. ": " .. tostring(v) .. "\n"; hasAttrs = true end
                if not hasAttrs then info = info .. "Ninguno\n" end
                
                info = info .. "\n[ PROPIEDADES ]\n"
                local hasValues = false
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("BoolValue") then
                        info = info .. child.Name .. ": " .. tostring(child.Value) .. "\n"; hasValues = true
                    elseif child:IsA("ProximityPrompt") then
                        info = info .. "Acción: " .. tostring(child.ActionText) .. "\n"
                    end
                end
                if not hasValues then info = info .. "Sin valores\n" end
                NpcInfoText.Text = info
                NpcFrame.Visible = true
            end
        end
    end
end)

-- ==========================================
-- NUEVO: Toggle 4: Rastreador de GUI e Inventario (Y: 225)
-- ==========================================

-- Interfaz del Log debajo del Switch 4
local GuiLogScroll = Instance.new("ScrollingFrame")
GuiLogScroll.Size = UDim2.new(1, -30, 0, 120)
GuiLogScroll.Position = UDim2.new(0, 15, 0, 280)
GuiLogScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GuiLogScroll.BorderSizePixel = 0
GuiLogScroll.ScrollBarThickness = 4
GuiLogScroll.Parent = MainFrame
Instance.new("UICorner", GuiLogScroll).CornerRadius = UDim.new(0, 6)

local GuiLogTextLabel = Instance.new("TextLabel")
GuiLogTextLabel.Size = UDim2.new(1, -10, 0, 0)
GuiLogTextLabel.Position = UDim2.new(0, 5, 0, 5)
GuiLogTextLabel.BackgroundTransparency = 1
GuiLogTextLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
GuiLogTextLabel.Font = Enum.Font.Code
GuiLogTextLabel.TextSize = 12
GuiLogTextLabel.TextXAlignment = Enum.TextXAlignment.Left
GuiLogTextLabel.TextYAlignment = Enum.TextYAlignment.Top
GuiLogTextLabel.TextWrapped = true
GuiLogTextLabel.AutomaticSize = Enum.AutomaticSize.Y
GuiLogTextLabel.Text = "Esperando interacciones de GUI y Celular..."
GuiLogTextLabel.Parent = GuiLogScroll

-- Botón Copiar Logs (Y: 410)
local CopyLogsBtn = Instance.new("TextButton")
CopyLogsBtn.Size = UDim2.new(1, -30, 0, 30)
CopyLogsBtn.Position = UDim2.new(0, 15, 0, 410)
CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CopyLogsBtn.Text = "Copiar Datos Capturados"
CopyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyLogsBtn.Font = Enum.Font.GothamBold
CopyLogsBtn.TextSize = 13
CopyLogsBtn.Parent = MainFrame
Instance.new("UICorner", CopyLogsBtn).CornerRadius = UDim.new(0, 6)

CopyLogsBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GuiLogTextLabel.Text)
        CopyLogsBtn.Text = "¡Registros copiados!"
        CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
        task.wait(1.5)
        CopyLogsBtn.Text = "Copiar Datos Capturados"
        CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        CopyLogsBtn.Text = "Error: Sin soporte de portapapeles"
        CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        CopyLogsBtn.Text = "Copiar Datos Capturados"
        CopyLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

local guiConnections = {}
local guiLogHistory = ""

local function addLog(prefix, text)
    local timestamp = os.date("%H:%M:%S")
    guiLogHistory = "["..timestamp.."] " .. prefix .. " " .. text .. "\n" .. guiLogHistory
    if #guiLogHistory > 5000 then guiLogHistory = string.sub(guiLogHistory, 1, 5000) end
    GuiLogTextLabel.Text = guiLogHistory
end

CreateToggle("Inspector Celular/Inventario", 225, function(Value)
    if Value then
        addLog("[SISTEMA]", "Iniciando captura de interfaces y celular...")
        
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local backpack = LocalPlayer:WaitForChild("Backpack")
        
        -- Captura 1: Nuevos elementos UI (Cuando se abre una app del celular o menú)
        table.insert(guiConnections, playerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ScreenGui") or descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
                -- Filtramos un poco para no spamear con UIs invisibles
                task.wait(0.1) 
                if descendant:IsA("ScreenGui") and descendant.Enabled then
                    addLog("[📱 NUEVA INTERFAZ]", descendant.Name)
                elseif descendant:IsA("Frame") and descendant.Visible then
                    addLog("[🪟 NUEVO FRAME]", descendant.Name)
                end
            end
        end))
        
        -- Captura 2: Cambios de visibilidad (Ej: cuando el celular ya existe pero estaba oculto)
        for _, ui in ipairs(playerGui:GetDescendants()) do
            if ui:IsA("ScreenGui") then
                table.insert(guiConnections, ui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if ui.Enabled then addLog("[📱 UI VISIBLE]", ui.Name) end
                end))
            elseif ui:IsA("Frame") then
                table.insert(guiConnections, ui:GetPropertyChangedSignal("Visible"):Connect(function()
                    if ui.Visible then addLog("[🪟 FRAME VISIBLE]", ui.Name) end
                end))
            end
        end
        
        -- Captura 3: Inventario (Cuando se recibe o guarda un item)
        table.insert(guiConnections, backpack.ChildAdded:Connect(function(tool)
            addLog("[🎒 INVENTARIO]", "Recibido: " .. tool.Name)
        end))
        
        -- Captura 4: Personaje (Cuando el jugador saca el celular o equipa algo)
        local function setupCharacterTracking(char)
            table.insert(guiConnections, char.ChildAdded:Connect(function(tool)
                if tool:IsA("Tool") then
                    addLog("[🖐️ EQUIPADO]", tool.Name)
                    -- Analiza si el objeto equipado tiene valores ocultos (ej: número de la persona que llama)
                    for _, v in ipairs(tool:GetDescendants()) do
                        if v:IsA("StringValue") or v:IsA("IntValue") then
                            addLog("  ↳ [VALOR]", v.Name .. " = " .. tostring(v.Value))
                        end
                    end
                end
            end))
        end
        
        if LocalPlayer.Character then setupCharacterTracking(LocalPlayer.Character) end
        table.insert(guiConnections, LocalPlayer.CharacterAdded:Connect(setupCharacterTracking))

    else
        addLog("[SISTEMA]", "Captura detenida.")
        -- Limpieza de conexiones para evitar lag cuando está apagado
        for _, conn in ipairs(guiConnections) do
            if conn.Connected then conn:Disconnect() end
        end
        guiConnections = {}
    end
end)

-- Créditos (Y: 450)
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.Position = UDim2.new(0, 0, 1, -30)
Credits.BackgroundTransparency = 1
Credits.Text = "ID: Gattoi | Lógica Optimizada & GUI Tracker"
Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 11
Credits.Parent = MainFrame
