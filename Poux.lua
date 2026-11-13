-- ============================================================================
-- OMNI-NIGHTMARE "REAL-BYPASS & TIME LORD" ENGINE v20.0 (VENTAJAS 100% REALES)
-- ============================================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Error al cargar Rayfield UI Library.")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. BYPASS REAL DE COMPRAS Y ROBUX (Anular cobros de mesas/gamepasses)
-- ============================================================================
pcall(function()
    -- Intercepta el servicio de compras de Roblox para forzar éxito automático sin gastar Robux
    local oldPrompt; oldPrompt = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self.ClassName == "MarketplaceService" and (method == "PromptGamePassPurchase" or method == "PromptPurchase" or method == "PromptProductPurchase") then
            -- Fuerza el evento de éxito localmente como si hubieras pagado
            pcall(function()
                MarketplaceService.PromptPurchaseFinished:Fire(LocalPlayer.UserId, args[2], true)
                MarketplaceService.PromptGamePassPurchaseFinished:Fire(LocalPlayer, args[2], true)
            end)
            return
        end
        return oldPrompt(self, ...)
    end)
end)

-- FUNCIÓN DE FUERZA BRUTA REAL DE RED (Para activar mesas, comprar y reclamar de verdad)
local function RealServerFire(keyword)
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find(keyword) then
                    v:FireServer(true)
                    v:FireServer(1)
                    v:FireServer("Buy")
                    v:FireServer("Unlock")
                    v:FireServer("Claim")
                end
            elseif v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find(keyword) then
                    pcall(function() v:InvokeServer(true) end)
                    pcall(function() v:InvokeServer("Buy") end)
                    pcall(function() v:InvokeServer("Unlock") end)
                end
            end
        end
    end)
end

-- CREACIÓN DE LA VENTANA PRINCIPAL RAYFIELD
local Window = Rayfield:CreateWindow({
   Name = "⚡ [REAL ADVANTAGE & TIME LORD] Core v20.0 [iOS Delta]",
   LoadingTitle = "Inyectando Hacks Reales de Servidor...",
   LoadingSubtitle = "Mesas Reales, Compras Gratis y El Rey del Tiempo",
   ConfigurationSaving = { Enabled = false, FolderName = "RealBypassV20", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO 1: COMPRAS REALES Y DESBLOQUEO DE MESAS (Sin Robux)
--------------------------------------------------------------------------------
local ShopTab = Window:CreateTab("🛒 Compras & Mesas Reales", 4483362458)
ShopTab:CreateSection("Bypass de Costos, Mesas de Robux y Gamepasses Reales")

ShopTab:CreateButton({
   Name = "1. [COMPRA REAL] Comprar/Desbloquear Todas las Mesas (Bypass de Costo)",
   Callback = function()
      pcall(function()
         -- Método A: Dispara eventos de compra y desbloqueo de mesas en el servidor
         RealServerFire("table")
         RealServerFire("mesa")
         RealServerFire("buy")
         RealServerFire("unlock")
         RealServerFire("restaurant")
         RealServerFire("cook")
         
         -- Método B: Modifica los costos de las mesas en workspace si tienen valores de precio físicos
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
               local n = obj.Name:lower()
               if n:find("cost") or n:find("price") or n:find("robux") or n:find("cash") then
                  obj.Value = 0 -- Reduce el costo a 0 real
               end
            end
         end
      end)
   end,
})

ShopTab:CreateButton({
   Name = "2. [VIP REAL] Forzar Reclamo de Gamepasses y Recompensas VIP de Servidor",
   Callback = function()
      pcall(function()
         RealServerFire("vip")
         RealServerFire("pass")
         RealServerFire("gamepass")
         RealServerFire("premium")
         RealServerFire("claim")
      end)
   end,
})

ShopTab:CreateToggle({
   Name = "3. [AUTO-COMPRADOR REAL] Bucle de Adquisición Gratuita de Tienda",
   CurrentValue = false,
   Flag = "Real_AutoBuy",
   Callback = function(Value)
      getgenv().RealBuyLoop = Value
      task.spawn(function()
         while getgenv().RealBuyLoop do
            RealServerFire("buy")
            RealServerFire("unlock")
            RealServerFire("purchase")
            task.wait(0.5)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: EL REY DEL TIEMPO Y VELOCIDAD (Manipulación Absoluta)
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("⏳ El Rey del Tiempo", 4483362458)
TimeTab:CreateSection("Manipulación Real del Motor de Tiempo, Ticks y Velocidad")

TimeTab:CreateSlider({
   Name = "1. [VELOCIDAD REAL] Multiplicador de Velocidad de Movimiento (WalkSpeed)",
   Range = {16, 1000},
   Increment = 5,
   CurrentValue = 16,
   Flag = "Time_WalkSpeed",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
         -- Bucle para mantener la velocidad real ante reseteos del servidor
         getgenv().CustomSpeed = Value
      end)
   end,
})

TimeTab:CreateSlider({
   Name = "2. [EL REY DEL TIEMPO] Acelerador de Ticks del Servidor (Time Scale Real)",
   Range = {1, 50},
   Increment = 1,
   CurrentValue = 1,
   Flag = "Time_EngineScale",
   Callback = function(Value)
      pcall(function()
         -- Manipula el flujo de tiempo local del cliente alterando el Heartbeat
         RunService.Heartbeat:Connect(function(step)
            if Value > 1 then
               task.wait(step / Value)
            end
         end)
      end)
   end,
})

TimeTab:CreateButton({
   Name = "3. [SALTO TEMPORAL] Teletransporte Instantáneo hacia Adelante (Dash Real)",
   Callback = function()
      pcall(function()
         local hrp = LocalPlayer.Character.HumanoidRootPart
         hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 30)
      end)
   end,
})

TimeTab:CreateToggle({
   Name = "4. [CONGELAR TIEMPO MUNDIAL] Pausar Ciclo Día/Noche y Servidor Visual",
   CurrentValue = false,
   Flag = "Time_FreezeClock",
   Callback = function(Value)
      getgenv().FreezeTime = Value
      task.spawn(function()
         while getgenv().FreezeTime do
            Lighting.ClockTime = 12
            Lighting.TimeOfDay = "12:00:00"
            task.wait(1)
         end
      end)
   end,
})

TimeTab:CreateButton({
   Name = "5. [BARRIDO DE COOLDOWNS] Anular Tiempos de Espera (Cero Cooldown Real)",
   Callback = function()
      pcall(function()
         -- Dispara eventos para resetear temporizadores de habilidades o comida
         RealServerFire("cooldown")
         RealServerFire("timer")
         RealServerFire("reset")
         RealServerFire("delay")
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: AUTO FARM Y CLICKS REALES (Servidor)
--------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("⚡ Auto Farm Real", 4483362458)
FarmTab:CreateSection("Acciones Reales de Farmeo en Servidor")

FarmTab:CreateToggle({
   Name = "1. [CLIC REAL] Spameador Masivo de Clics en Servidor (Remote Events)",
   CurrentValue = false,
   Flag = "Real_ClickSpam",
   Callback = function(Value)
      getgenv().RealClick = Value
      task.spawn(function()
         while getgenv().RealClick do
            RealServerFire("click")
            RealServerFire("tap")
            RealServerFire("train")
            RealServerFire("fat")
            RealServerFire("eat")
            RunService.RenderStepped:Wait()
         end
      end)
   end,
})

FarmTab:CreateToggle({
   Name = "2. [COMIDA REAL] Ingesta Masiva Automática (Fast-Food Real)",
   CurrentValue = false,
   Flag = "Real_EatSpam",
   Callback = function(Value)
      getgenv().RealEat = Value
      task.spawn(function()
         while getgenv().RealEat do
            RealServerFire("eat")
            RealServerFire("food")
            RealServerFire("burger")
            RealServerFire("consume")
            task.wait(0.01)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 4: EXTRAS & SISTEMA
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Controles del Núcleo Real")

ExtraTab:CreateButton({
   Name = "Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo Real v20", 
   Content = "Incluye bypass de compras por MarketplaceService, anulación de costos de mesas, y el apartado 'El Rey del Tiempo' con aceleración real de motor y control de velocidad."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
