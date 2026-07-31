-- ==========================================
-- TOWER OF CANS: GUEST SPECTATOR BOT (V7)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espFolder = Instance.new("Folder")
espFolder.Name = "SurgicalCanESP_Bot"
espFolder.Parent = CoreGui

local Window = Rayfield:CreateWindow({
   Name = "🥤 Tower ESP | Modo Jugador Invitado",
   LoadingTitle = "Inyectando Bot Espectador...",
   LoadingSubtitle = "by Delta",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Multijugador", 4483362458)

local espEnabled = false
local botActive = false
local botCharacter = nil
local activeESPs = {}
local scanLoop = nil

local baseColors = {
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Blue = Color3.fromRGB(50, 150, 255),
    Yellow = Color3.fromRGB(255, 255, 50)
}

local function clearESP()
    for part, data in pairs(activeESPs) do
        if data.espObj then data.espObj:Destroy() end
    end
    table.clear(activeESPs)
    espFolder:ClearAllChildren()
end

-- Simular un Jugador Invitado / Full Player secundario al lado
local function toggleBot(state)
    botActive = state
    if botActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.Archivable = true
            botCharacter = char:Clone()
            char.Archivable = false
            
            botCharacter.Name = "Guest_Player_Bot"
            -- Posicionar al bot invitado a 8 studs a la derecha para forzar carga de red independiente
            botCharacter:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + Vector3.new(8, 0, 0))
            botCharacter.Parent = workspace
            
            -- Limpiar scripts locales para que no interfieran, mantener físicas de render
            for _, v in pairs(botCharacter:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("Script") then
                    v:Destroy()
                elseif v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            
            -- Cambiar la cámara temporalmente al bot invitado para "jugar" desde su perspectiva
            local camera = workspace.CurrentCamera
            if camera and botCharacter:FindFirstChild("Humanoid") then
                camera.CameraSubject = botCharacter.Humanoid
            end
        end
    else
        if botCharacter then
            botCharacter:Destroy()
            botCharacter = nil
        end
        local camera = workspace.CurrentCamera
        if camera and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end

-- Motor ESP Quirúrgico ajustado al nuevo punto de vista del Bot Invitado
local function updateESP()
    for _, trainingFolder in pairs(workspace:GetChildren()) do
        if string.match(trainingFolder.Name, "^Training") then
            for _, descendant in pairs(trainingFolder:GetDescendants()) do
                if descendant:IsA("BasePart") or descendant:IsA("UnionOperation") then
                    local parentName = descendant.Parent and descendant.Parent.Name or ""
                    
                    -- Detección estricta Rival (SodaM o áreas de torres)
                    local rivalBase = string.match(parentName, "^(%a+)SodaM$")
                    if not rivalBase and (string.find(trainingFolder.Name, "MasterSort") or string.find(parentName, "MasterSort")) then
                        rivalBase = "Red" -- Rescate por defecto para la torre del rival
                    end
                    
                    if rivalBase and baseColors[rivalBase] and not activeESPs[descendant] then
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = descendant
                        highlight.FillTransparency = 1
                        highlight.OutlineTransparency = 0
                        highlight.OutlineColor = baseColors[rivalBase]
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = espFolder
                        
                        activeESPs[descendant] = { espObj = highlight }
                    end
                    
                    -- Detección estricta Player (SodaP) con skin y texto limpio
                    local playerBase = string.match(parentName, "^(%a+)SodaP$")
                    if playerBase and baseColors[playerBase] and not activeESPs[descendant] then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Adornee = descendant
                        billboard.Size = UDim2.new(0, 150, 0, 30)
                        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                        billboard.AlwaysOnTop = true

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Parent = billboard
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = string.format("[%s] %s", playerBase, descendant.Name)
                        textLabel.TextColor3 = baseColors[playerBase]
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        textLabel.TextSize = 12
                        textLabel.Font = Enum.Font.Code 
                        billboard.Parent = espFolder
                        
                        activeESPs[descendant] = { espObj = billboard }
                    end
                end
            end
        end
    end
end

Tab:CreateToggle({
   Name = "Activar Jugador Invitado (Bot al Lado)",
   CurrentValue = false,
   Flag = "BotToggle",
   Callback = function(Value)
       toggleBot(Value)
   end,
})

Tab:CreateToggle({
   Name = "Activar ESP Inteligente (Modo Invitado)",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
       espEnabled = Value
       if espEnabled then
           scanLoop = task.spawn(function()
               while espEnabled do
                   updateESP()
                   for part, data in pairs(activeESPs) do
                       if not part or not part.Parent then
                           if data.espObj then data.espObj:Destroy() end
                           activeESPs[part] = nil
                       end
                   end
                   task.wait(0.3)
               end
           end)
       else
           clearESP()
       end
   end,
})

Rayfield:Notify({
   Title = "Modo Invitado Listo",
   Content = "Simula un jugador extra para forzar el renderizado del rival.",
   Duration = 4,
   Image = 4483362458,
})
