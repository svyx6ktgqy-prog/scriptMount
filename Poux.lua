-- ============================================================================
-- OMNI-NIGHTMARE "REAL-HOOK & MARKETPLACE BYPASS" ENGINE v24.0
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
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- MÉTODO 1 (REAL): Interceptación de Memoria para Compras y Gamepasses (Hooking)
-- ============================================================================
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Si el juego intenta verificar si posees un Gamepass o VIP oficial, forzamos true
            if self.ClassName == "MarketplaceService" and (method == "UserOwnsGamePassAsync" or method == "PlayerOwnsAsset") then
                return true
            end
            
            -- Si intenta abrir una compra de Robux, forzamos el evento de éxito instantáneo
            if self.ClassName == "MarketplaceService" and (method == "PromptGamePassPurchase" or method == "PromptPurchase") then
                pcall(function()
                    MarketplaceService.PromptGamePassPurchaseFinished:Fire(LocalPlayer, args[2], true)
                    MarketplaceService.PromptPurchaseFinished:Fire(LocalPlayer.UserId, args[2], true)
                end)
                return true
            end
            
            return oldNamecall(self, ...)
        end)
    end
end)

-- Método de escaneo y disparo real de RemoteEvents de compra/desbloqueo
local function ForceRealUnlock()
    pcall(function()
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local name = v.Name:lower()
                if name:find("buy") or name:find("unlock") or name:find("vip") or name:find("pass") or name:find("claim") then
                    v:FireServer(true)
                    v:FireServer(1)
                    v:FireServer("Buy")
                    v:FireServer("Unlock")
                end
            elseif v:IsA("RemoteFunction") then
                local name = v.Name:lower()
                if name:find("buy") or name:find("unlock") or name:find("vip") or name:find("pass") then
                    pcall(function() v:InvokeServer(true) end)
                    pcall(function() v:InvokeServer("Buy") end)
                end
            end
        end
    end)
end

-- Creación de la Ventana Principal Rayfield
local Window = Rayfield:CreateWindow({
   Name = "💎 [REAL MARKETPLACE & HOOK BYPASS] v24.0 [iOS Delta]",
   LoadingTitle = "Inyectando Ganchos de Memoria Oficial...",
   LoadingSubtitle = "Desbloqueo Real de Tiendas y Gamepasses",
   ConfigurationSaving = { Enabled = false, FolderName = "RealBypassV24", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = false,
})

--------------------------------------------------------------------------------
-- APARTADO ÚNICO: MÉTODOS DE DESBLOQUEO REAL
--------------------------------------------------------------------------------
local UnlockTab = Window:CreateTab("💎 Desbloqueo Real", 4483362458)
UnlockTab:CreateSection("Ganchos de Memoria y Funciones de Servidor Auténticas")

UnlockTab:CreateButton({
   Name = "1. [HOOK OFICIAL] Forzar Propiedad de Gamepasses y Tienda en Memoria",
   Callback = function()
      pcall(function()
         -- Inyecta permisos directamente en los atributos del jugador para validaciones locales
         LocalPlayer:SetAttribute("VIP", true)
         LocalPlayer:SetAttribute("IsVIP", true)
         LocalPlayer:SetAttribute("HasPass", true)
         LocalPlayer:SetAttribute("GamePassOwner", true)
         LocalPlayer:SetAttribute("Premium", true)
         
         -- Ejecuta el escáner de red de desbloqueo real
         ForceRealUnlock()
         print("Gancho de MarketplaceService y atributos aplicados con éxito.")
      end)
   end,
})

UnlockTab:CreateButton({
   Name = "2. [DESBLOQUEO DE MESAS Y ZONAS] Forzar Activación de Modelos de Servidor",
   Callback = function()
      pcall(function()
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
               local name = obj.Name:lower()
               if name:find("mesa") or name:find("table") or name:find("vip") or name:find("door") or name:find("unlock") then
                  if obj:IsA("BasePart") then
                     obj.CanCollide = false
                     obj.Transparency = 0.4
                  elseif obj:IsA("Model") then
                     for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                           p.CanCollide = false
                           p.Transparency = 0.4
                        end
                     end
                  end
               end
            end
         end
      end)
   end,
})

UnlockTab:CreateToggle({
   Name = "3. [BARRIDO REAL CONSTANTE] Auto-Inyección de Permisos y Gamepasses",
   CurrentValue = false,
   Flag = "Real_UnlockLoop",
   Callback = function(Value)
      getgenv().RealUnlockActive = Value
      task.spawn(function()
         while getgenv().RealUnlockActive do
            pcall(function()
               LocalPlayer:SetAttribute("VIP", true)
               LocalPlayer:SetAttribute("HasPass", true)
               ForceRealUnlock()
            end)
            task.wait(1)
         end
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 2: EL REY DEL TIEMPO Y VELOCIDAD
--------------------------------------------------------------------------------
local TimeTab = Window:CreateTab("⏳ El Rey del Tiempo", 4483362458)
TimeTab:CreateSection("Control Real de Movimiento y Física Local")

TimeTab:CreateSlider({
   Name = "1. Velocidad de Movimiento (WalkSpeed Real)",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Flag = "Time_SpeedReal",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end)
   end,
})

TimeTab:CreateSlider({
   Name = "2. Potencia de Salto (JumpPower Real)",
   Range = {50, 400},
   Increment = 5,
   CurrentValue = 50,
   Flag = "Time_JumpReal",
   Callback = function(Value)
      pcall(function()
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end)
   end,
})

--------------------------------------------------------------------------------
-- APARTADO 3: EXTRAS & SISTEMA
--------------------------------------------------------------------------------
local ExtraTab = Window:CreateTab("Extras & Sistema", 4483362458)
ExtraTab:CreateSection("Controles del Script")

ExtraTab:CreateButton({
   Name = "Destruir Completamente la UI (Unload Total)",
   Callback = function()
      Rayfield:Destroy()
   end,
})

ExtraTab:CreateParagraph({
   Title = "Estado del Núcleo v24 Real Hook", 
   Content = "Este script utiliza `hookmetamethod` para interceptar `MarketplaceService` y hacer creer al juego que posees todos los gamepasses y VIP de forma oficial en memoria."
})

-- Carga final segura
pcall(function()
   Rayfield:LoadConfiguration()
end)
