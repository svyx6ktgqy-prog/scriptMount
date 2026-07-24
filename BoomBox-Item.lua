-- Cargamos la librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Radio Script 📻",
   LoadingTitle = "Cargando Interfaz...",
   LoadingSubtitle = "Motor de Audio & Pose: ACTIVADO",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Inventario", 4483362458) 

-- Variables globales
local toolName = "BoomBoxV3"
local assetId = "rbxassetid://15876467320"
local clonedTool = nil
local customUI = nil

Tab:CreateToggle({
   Name = "Equipar Radio (BoomBoxV3)",
   CurrentValue = false,
   Flag = "RadioToggle", 
   Callback = function(Value)
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           local success, errorMessage = pcall(function()
               
               -- 1. Forzamos la barra de inventario
               local StarterGui = game:GetService("StarterGui")
               pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
               
               -- 2. Descargamos el asset y auto-forjamos la herramienta
               local objects = game:GetObjects(assetId)
               local obj = objects[1]
               local realTool = nil
               
               if obj:IsA("Tool") then
                   realTool = obj 
               else
                   local innerTool = obj:FindFirstChildWhichIsA("Tool", true)
                   if innerTool then
                       realTool = innerTool
                   else
                       realTool = Instance.new("Tool")
                       realTool.RequiresHandle = true
                       if obj:IsA("BasePart") then
                           obj.Name = "Handle"
                           obj.Parent = realTool
                       elseif obj:IsA("Model") or obj:IsA("Folder") then
                           for _, child in pairs(obj:GetChildren()) do child.Parent = realTool end
                           local handle = realTool:FindFirstChild("Handle") or realTool:FindFirstChildWhichIsA("BasePart")
                           if handle then handle.Name = "Handle"
                           else
                               handle = Instance.new("Part")
                               handle.Name = "Handle"
                               handle.Size = Vector3.new(1, 1, 1)
                               handle.Transparency = 1
                               handle.Parent = realTool
                           end
                       end
                   end
               end
               
               if not realTool then error("Error en Auto-Forjado.") end
               
               clonedTool = realTool
               clonedTool.Name = toolName
               
               -- ANTI-FREEZE
               for _, part in pairs(clonedTool:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.Anchored = false
                       part.CanCollide = false 
                   end
               end
               
               -- ==========================================
               -- [NUEVO]: POSTURA MUSICAL (Hombro Izquierdo y Oído)
               -- ==========================================
               -- Modificamos el agarre (Grip). En lugar de estar en la mano derecha abajo, 
               -- lo desplazamos -1.5 hacia la izquierda, lo subimos, y lo rotamos hacia la cabeza.
               clonedTool.Grip = CFrame.new(-1.5, 0.8, 0) * CFrame.Angles(math.rad(15), math.rad(90), math.rad(-25))
               
               -- ==========================================
               -- [NUEVO]: MOTOR DE AUDIO PROPIO Y UI PERSONALIZADA
               -- ==========================================
               local handle = clonedTool:FindFirstChild("Handle")
               
               -- Inyectamos un parlante (Sound) dentro de la radio
               local radioSound = Instance.new("Sound")
               radioSound.Name = "CustomMusicPlayer"
               radioSound.Volume = 1
               radioSound.Looped = true
               radioSound.Parent = handle
               
               -- Creamos nuestra PROPIA interfaz funcional que nunca fallará
               customUI = Instance.new("ScreenGui")
               customUI.Name = "ExploitRadioUI"
               customUI.ResetOnSpawn = false
               
               -- Diseño del panel
               local frame = Instance.new("Frame", customUI)
               frame.Size = UDim2.new(0, 250, 0, 130)
               frame.Position = UDim2.new(0.5, -125, 0.8, -130) -- Aparece abajo en el centro
               frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
               frame.BorderSizePixel = 2
               frame.BorderColor3 = Color3.fromRGB(0, 255, 128)
               frame.Visible = false -- Oculto hasta que hagas clic
               
               local title = Instance.new("TextLabel", frame)
               title.Size = UDim2.new(1, 0, 0, 25)
               title.Text = "📻 MENÚ DE RADIO 📻"
               title.TextColor3 = Color3.new(1, 1, 1)
               title.BackgroundTransparency = 1
               title.Font = Enum.Font.SourceSansBold
               title.TextSize = 18
               
               local inputBox = Instance.new("TextBox", frame)
               inputBox.Size = UDim2.new(0.9, 0, 0, 30)
               inputBox.Position = UDim2.new(0.05, 0, 0.3, 0)
               inputBox.PlaceholderText = "Pega aquí la ID (Ej: 142376088)"
               inputBox.Text = ""
               inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
               inputBox.TextColor3 = Color3.new(1, 1, 1)
               inputBox.TextScaled = true
               
               local playBtn = Instance.new("TextButton", frame)
               playBtn.Size = UDim2.new(0.4, 0, 0, 35)
               playBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
               playBtn.Text = "▶ REPRODUCIR"
               playBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
               playBtn.TextColor3 = Color3.new(1, 1, 1)
               playBtn.Font = Enum.Font.SourceSansBold
               
               local stopBtn = Instance.new("TextButton", frame)
               stopBtn.Size = UDim2.new(0.4, 0, 0, 35)
               stopBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
               stopBtn.Text = "⏹ DETENER"
               stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
               stopBtn.TextColor3 = Color3.new(1, 1, 1)
               stopBtn.Font = Enum.Font.SourceSansBold
               
               -- Lógica de los botones
               playBtn.MouseButton1Click:Connect(function()
                   local id = inputBox.Text:match("%d+") -- Extrae solo los números
                   if id then
                       radioSound.SoundId = "rbxassetid://" .. id
                       radioSound:Play()
                   end
               end)
               
               stopBtn.MouseButton1Click:Connect(function()
                   radioSound:Stop()
               end)
               
               customUI.Parent = player:WaitForChild("PlayerGui")
               
               -- Al hacer clic con la radio en la mano, mostramos/ocultamos nuestro menú
               clonedTool.Activated:Connect(function()
                   if customUI then
                       frame.Visible = not frame.Visible
                   end
               end)
               
               -- Persistencia y Equipamiento
               if player:FindFirstChild("StarterGear") then
                   local gearClone = clonedTool:Clone()
                   gearClone.Parent = player.StarterGear
               end

               clonedTool.Parent = player.Backpack 
               task.wait(0.2) 
               if humanoid then humanoid:EquipTool(clonedTool) end
               
               Rayfield:Notify({
                   Title = "Radio Operativa",
                   Content = "Pose musical aplicada. Toca la pantalla/clic para abrir tu reproductor.",
                   Duration = 4,
               })
           end)

           if not success then
               Rayfield:Notify({Title = "Error", Content = tostring(errorMessage), Duration = 6})
           end
           
       else
           -- Limpieza total
           pcall(function()
               if customUI then customUI:Destroy() customUI = nil end
               if player:FindFirstChild("StarterGear") and player.StarterGear:FindFirstChild(toolName) then player.StarterGear[toolName]:Destroy() end
               if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(toolName) then player.Backpack[toolName]:Destroy() end
               if character and character:FindFirstChild(toolName) then character[toolName]:Destroy() end
               if clonedTool then clonedTool:Destroy() clonedTool = nil end
               
               Rayfield:Notify({Title = "Radio Apagada", Content = "Inventario y UI limpios.", Duration = 2})
           end)
       end
   end,
})
