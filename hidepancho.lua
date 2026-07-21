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

-- Sistema de seguridad para inyección en Delta iOS
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

-- 3. Ventana Principal (Estilo Carbón Oscuro - Ampliada para 3 botones)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 275) -- Aumentado el alto para el 3er toggle
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -137)
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

-- Ventana Flotante de Info NPC
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

CloseNpcBtn.MouseButton1Click:Connect(function()
    NpcFrame.Visible = false
end)

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
CopyNpcBtn.Text = "Copiar al Portapapeles"
CopyNpcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyNpcBtn.Font = Enum.Font.GothamBold
CopyNpcBtn.TextSize = 14
CopyNpcBtn.Parent = NpcFrame

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyNpcBtn

CopyNpcBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(NpcInfoText.Text)
        CopyNpcBtn.Text = "¡Copiado!"
        task.wait(1.5)
        CopyNpcBtn.Text = "Copiar al Portapapeles"
    end
end)

-- 4. Función constructora de Toggles
local function CreateToggle(name, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -30, 0, 45)
    ToggleFrame.Position = UDim2.new(0, 15, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.Parent = MainFrame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleFrame
    
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
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = Btn
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 20, 0, 20)
    Indicator.Position = UDim2.new(0, 2, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = Btn
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator
    
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

-- Toggle 1: Generador de Plata
CreateToggle("Generador de Plata", 60, function(Value)
    getgenv().a = Value
    if Value then
        local p = workspace:FindFirstChild("map") 
                  and workspace.map:FindFirstChild("map_jobs") 
                  and workspace.map.map_jobs:FindFirstChild("pedidosYaJOB") 
                  and workspace.map.map_jobs.pedidosYaJOB:FindFirstChild("pedidosYaNPC")
                  and workspace.map.map_jobs.pedidosYaJOB.pedidosYaNPC:FindFirstChild("Trigger")

        if not p then return end
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local oldCFrame = hrp.CFrame
        
        character:PivotTo(p.CFrame)
        task.wait(0.8)
        
        if p:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(p.ProximityPrompt)
        end
        
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
                        local rLoc = gui:FindFirstChild("restaurantLocation")
                        local dLoc = gui:FindFirstChild("deliveryLocation")
                        
                        local acceptBtn = gui:FindFirstChild("screenFrame") and gui.screenFrame:FindFirstChild("acceptButton")
                        if acceptBtn and type(firesignal) == "function" then
                            pcall(function() firesignal(acceptBtn.MouseButton1Click) end)
                        end

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

-- Toggle 2: Auto-Agarrar Plata
getgenv().autoGrab = false
CreateToggle("Auto-Agarrar Plata", 115, function(Value)
    getgenv().autoGrab = Value
end)

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

-- Toggle 3: Detector Info de NPC (Sin Hooks - Seguro)
getgenv().npcDetector = false
CreateToggle("Inspector de NPC (Touch)", 170, function(Value)
    getgenv().npcDetector = Value
    if not Value then NpcFrame.Visible = false end
end)

local Mouse = LocalPlayer:GetMouse()

-- Detector de toques/clics totalmente seguro. Solo lee información local sin interactuar con el servidor.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not getgenv().npcDetector then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local target = Mouse.Target
        if target then
            -- Busca si la pieza tocada pertenece a un modelo de personaje
            local model = target:FindFirstAncestorOfClass("Model")
            
            -- Verifica si es un NPC (Tiene Humanoid pero NO es un jugador real)
            if model and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                
                local info = "=================\n"
                info = info .. "  NPC: " .. model.Name .. "\n"
                info = info .. "=================\n\n"
                
                -- Extraer Atributos Ocultos (Suelen usarse para variables de vendedores)
                local attrs = model:GetAttributes()
                local hasAttrs = false
                info = info .. "[ ATRIBUTOS INTERNOS ]\n"
                for k, v in pairs(attrs) do
                    info = info .. " - " .. tostring(k) .. ": " .. tostring(v) .. "\n"
                    hasAttrs = true
                end
                if not hasAttrs then info = info .. " - Ninguno\n" end
                
                info = info .. "\n[ PROPIEDADES Y VALORES ]\n"
                local hasValues = false
                
                -- Escanear todo dentro del NPC en busca de valores interactivos o inventarios
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("BoolValue") then
                        info = info .. " - " .. child.Name .. " (" .. child.ClassName .. "): " .. tostring(child.Value) .. "\n"
                        hasValues = true
                    elseif child:IsA("ProximityPrompt") then
                        info = info .. "\n[ DETECCIÓN DE INTERACCIÓN ]\n"
                        info = info .. " - Acción: " .. tostring(child.ActionText) .. "\n"
                        info = info .. " - Objeto: " .. tostring(child.ObjectText) .. "\n"
                        info = info .. " - Tecla: " .. tostring(child.KeyboardKeyCode.Name) .. "\n"
                        info = info .. " - Requiere línea de visión: " .. tostring(child.RequiresLineOfSight) .. "\n"
                    end
                end
                
                if not hasValues then info = info .. " - Sin valores expuestos\n" end
                
                info = info .. "\nUbicación Exacta:\n" .. tostring(model:GetPivot().Position)

                -- Mostrar los resultados en la UI flotante
                NpcInfoText.Text = info
                NpcFrame.Visible = true
            end
        end
    end
end)

-- Créditos
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.Position = UDim2.new(0, 0, 1, -30)
Credits.BackgroundTransparency = 1
Credits.Text = "ID: Gattoi | Lógica Optimizada"
Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 11
Credits.Parent = MainFrame
