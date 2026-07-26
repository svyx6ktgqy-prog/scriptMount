-- =====================================================================
-- 🔪 BATTLE SNIFE - BYPASS REMOTE ENGINE (DELTA iOS)
-- =====================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "Battle Snife 🔪 Bypass",
   LoadingTitle = "Remote Engine...",
   LoadingSubtitle = "Modo Directo",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local AutoBypass = false
local CatchRadius = 35 -- Radio masivo para asegurar la detección

-- Buscador automático de eventos en el juego
local RemoteThrow, RemoteCatch = nil, nil
pcall(function()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = v.Name:lower()
            if name:match("throw") or name:match("attack") or name:match("shoot") then
                RemoteThrow = v
            elseif name:match("catch") or name:match("grab") or name:match("get") then
                RemoteCatch = v
            end
        end
    end
end)

local CombatTab = Window:CreateTab("Bypass Combat", 4483362458)

CombatTab:CreateToggle({
   Name = "⚡ Auto Ping-Pong (Modo Remote & GUI)",
   CurrentValue = false,
   Flag = "AutoBypass",
   Callback = function(Value)
       AutoBypass = Value
       
       if AutoBypass then
           RunService.RenderStepped:Connect(function()
               if not AutoBypass then return end
               
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("HumanoidRootPart") then return end
               
               local myRoot = character.HumanoidRootPart
               local hasKnife = character:FindFirstChildOfClass("Tool") ~= nil

               if hasKnife then
                   -- ATAQUE DIRECTO
                   if RemoteThrow then
                       pcall(function() RemoteThrow:FireServer() end)
                   else
                       -- Respaldo con GUI
                       pcall(function()
                           local btn = LocalPlayer.PlayerGui.HUD.MobileButtons.Throw.click
                           for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
                       end)
                   end
                   task.wait(0.2)
               else
                   -- DEFENSA: Escanear todo el workspace en busca de objetos volando
                   for _, obj in pairs(workspace:GetDescendants()) do
                       if obj:IsA("BasePart") then
                           local name = obj.Name:lower()
                           if name:match("knife") or name:match("blade") or name:match("projectile") then
                               local dist = (myRoot.Position - obj.Position).Magnitude
                               if dist <= CatchRadius then
                                   -- INTENTO DE CAPTURA DIRECTA
                                   if RemoteCatch then
                                       pcall(function() RemoteCatch:FireServer() end)
                                   end
                                   -- Respaldo con GUI táctil nativa
                                   pcall(function()
                                       local btn = LocalPlayer.PlayerGui.HUD.MobileButtons.Catch.click
                                       for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
                                       for _, c in pairs(getconnections(btn.TouchTap)) do c:Fire() end
                                   end)
                                   task.wait(0.15)
                                   break
                               end
                           end
                       end
                   end
               end
           end)
       end
   end,
})

CombatTab:CreateSlider({
   Name = "Radio de Detección Extremo",
   Range = {15, 70},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 35,
   Flag = "CatchRadius",
   Callback = function(Value)
       CatchRadius = Value
   end,
})

Rayfield:Notify({
    Title = "Bypass Activado",
    Content = "Conectado a los canales del juego.",
    Duration = 3,
    Image = 4483362458
})
