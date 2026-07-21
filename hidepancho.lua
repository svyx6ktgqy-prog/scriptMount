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

-- 3. Ventana Principal (Estilo Carbón Oscuro - Ampliada para componentes de info)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 430)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "HOOD ARGENTINO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

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

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 4. Función constructora de Toggles con soporte para paneles de info internos
local function CreateToggleWithInfo(name, yPos, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -30, 0, 110)
    ToggleFrame.Position = UDim2.new(0, 15, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.Parent = MainFrame
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 40)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 42, 0, 22)
    Btn.Position = UDim2.new(1, -52, 0, 9)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = ""
    Btn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = Btn
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.Position = UDim2.new(0, 2, 0.5, -9)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = Btn
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator
    
    -- Panel de Info Abajo del Switch
    local InfoBox = Instance.new("TextBox")
    InfoBox.Size = UDim2.new(1, -16, 0, 45)
    InfoBox.Position = UDim2.new(0, 8, 0, 42)
    InfoBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    InfoBox.TextColor3 = Color3.fromRGB(180, 255, 140)
    InfoBox.Font = Enum.Font.Code
    InfoBox.TextSize = 10
    InfoBox.TextWrapped = true
    InfoBox.ClearTextOnFocus = false
    InfoBox.TextEditable = false
    InfoBox.Text = "Inactivo..."
    InfoBox.Parent = ToggleFrame
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = InfoBox
    
    -- Botón de Copiar Específico
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(1, -16, 0, 16)
    CopyBtn.Position = UDim2.new(0, 8, 0, 90)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CopyBtn.Text = "Copiar Info al Portapapeles"
    CopyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 9
    CopyBtn.Parent = ToggleFrame
    
    local CopyCorner = Instance.new("UICorner")
    CopyCorner.CornerRadius = UDim.new(0, 3)
    CopyCorner.Parent = CopyBtn
    
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(InfoBox.Text)
            CopyBtn.Text = "¡Copiado con Éxito!"
            task.delay(1.5, function()
                CopyBtn.Text = "Copiar Info al Portapapeles"
            end)
        end
    end)
    
    local toggled = false
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Btn.BackgroundColor3 = Color3.fromRGB(110, 211, 55)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        callback(toggled, InfoBox)
    end)
end

-- 5. Lógica de Funciones del Script adaptada con la ruta exacta de RepartosYa y Celular

-- Toggle 1: Generador de Plata (RepartosYa exacto)
CreateToggleWithInfo("Generador de Plata (RepartosYa)", 50, function(Value, infoBox)
    getgenv().a = Value
    if Value then
        local p = Workspace:FindFirstChild("Map") 
                  and Workspace.Map:FindFirstChild("Jobs") 
                  and Workspace.Map.Jobs:FindFirstChild("RepartosYA") 
                  and Workspace.Map.Jobs.RepartosYA:FindFirstChild("restaurantLocations")
                  and Workspace.Map.Jobs.RepartosYA.restaurantLocations:FindFirstChild("La esquina - Rotiseria")
                  and Workspace.Map.Jobs.RepartosYA.restaurantLocations["La esquina - Rotiseria"]:FindFirstChild("ProximityPrompt")

        if not p then 
            infoBox.Text = "Error: Prompt de RepartosYA no encontrado en ruta exacta."
            return 
        end
        
        infoBox.Text = "Ejecutando automatización de pedidos limpia..."
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local oldCFrame = hrp.CFrame
        
        character:PivotTo(p.Parent.CFrame)
        task.wait(0.8)
        
        fireproximityprompt(p)
        
        task.wait(0.5)
        character:PivotTo(oldCFrame)
        
        task.spawn(function()
            while getgenv().a do
                task.wait(0.3)
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    local phoneGui = playerGui and playerGui:FindFirstChild("Phone")
                    
                    if phoneGui then
                        local acceptBtn = phoneGui:FindFirstChild("PhoneBorder") 
                            and phoneGui.PhoneBorder:FindFirstChild("RepartosYaApp") 
                            and phoneGui.PhoneBorder.RepartosYaApp:FindFirstChild("OrdersFrame") 
                            and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame:FindFirstChild("orders") 
                            and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame.orders:FindFirstChild("ScrollingFrame") 
                            and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame.orders.ScrollingFrame:FindFirstChild("Order_785") 
                            and phoneGui.PhoneBorder.RepartosYaApp.OrdersFrame.orders.ScrollingFrame.Order_785:FindFirstChild("AcceptOrderBtn")
                        
                        if acceptBtn and type(firesignal) == "function" then
                            pcall(function() firesignal(acceptBtn.MouseButton1Click) end)
                            infoBox.Text = "¡Pedido aceptado vía GUI de Celular!"
                        end
                    end
                end)
            end
        end)
    else
        infoBox.Text = "Generador desactivado."
    end
end)

-- Toggle 2: Inspector de NPCs Avanzado
getgenv().npcDetector = false
CreateToggleWithInfo("Inspector NPC / Vendedor (Touch)", 165, function(Value, infoBox)
    getgenv().npcDetector = Value
    if not Value then 
        infoBox.Text = "Inspector apagado."
        return 
    end
    
    infoBox.Text = "Toca cualquier NPC o vendedor en el juego..."
    local Mouse = LocalPlayer:GetMouse()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not getgenv().npcDetector then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = Mouse.Target
            if target then
                local model = target:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                    
                    local dataStr = "NPC: " .. model.Name .. "\n"
                    
                    for k, v in pairs(model:GetAttributes()) do
                        dataStr = dataStr .. "Attr ["..tostring(k).."]: " .. tostring(v) .. "\n"
                    end
                    
                    for _, child in ipairs(model:GetDescendants()) do
                        if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("BoolValue") then
                            dataStr = dataStr .. child.Name .. ": " .. tostring(child.Value) .. "\n"
                        elseif child:IsA("Tool") then
                            dataStr = dataStr .. "Equipado (Celular/Item): " .. child.Name .. "\n"
                        elseif child:IsA("ProximityPrompt") then
                            dataStr = dataStr .. "Prompt: " .. tostring(child.ActionText) .. " (" .. tostring(child.ObjectText) .. ")\n"
                        end
                    end
                    
                    infoBox.Text = dataStr
                end
            end
        end
    end)
end)

-- Toggle 3: Capturador de GUI, Inventarios y Celular del Jugador
getgenv().guiCapturer = false
CreateToggleWithInfo("Capturador GUI & Inventario (Celular)", 280, function(Value, infoBox)
    getgenv().guiCapturer = Value
    if not Value then
        infoBox.Text = "Capturador GUI apagado."
        return
    end
    
    infoBox.Text = "Monitoreando elementos del Celular y GUI..."
    
    task.spawn(function()
        while getgenv().guiCapturer do
            task.wait(0.8)
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Enabled then
                            for _, descendant in ipairs(gui:GetDescendants()) do
                                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                                    local txt = descendant.Text
                                    if txt and txt ~= "" and string.len(txt) < 40 and (string.find(txt, "$") or string.find(txt, "Item") or string.find(txt, "Phone") or string.find(txt, "Menu") or string.find(txt, "Comprar") or string.find(txt, "Reclamar") or string.find(txt, "Accept")) then
                                        infoBox.Text = "GUI [" .. gui.Name .. "] -> " .. descendant.Name .. ": " .. txt
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- Créditos
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 25)
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.BackgroundTransparency = 1
Credits.Text = "ID: Gattoi | Anti-Ban Seguro (Sin Hooks)"
Credits.TextColor3 = Color3.fromRGB(110, 110, 110)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 10
Credits.Parent = MainFrame
