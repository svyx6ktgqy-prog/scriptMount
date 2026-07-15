-- Cargar librería Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear Ventana Principal (Espacio de trabajo asignado)
local Window = Rayfield:CreateWindow({
   Name = "ALB8RAAQ | Advanced Shop Exploiter",
   LoadingTitle = "Iniciando Protocolos de Interfaz...",
   LoadingSubtitle = "Delta iOS V2",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Manipulación UI", "box")

-- Variables de Control
local uiLoopActivo = false
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Palabras clave globales para interceptar
local keywordsAgotado = {"agotado", "sold out", "out of stock", "max", "lleno", "comprado", "unavailable"}
local keywordsPrecio = {"precio", "price", "cost", "costo", "valor"}
local keywordsStock = {"stock", "amount", "cantidad", "left", "restante"}

-- Función de Fuerza Bruta para UI
local function ReinforceUI()
    local modificados = 0
    
    -- Usamos GetDescendants para penetrar todas las capas (Frames, ScrollingFrames, etc.)
    for _, v in pairs(PlayerGui:GetDescendants()) do
        
        -- 1. Forzar Textos (Precios a 0 y Agotados a GRATIS)
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            local txt = string.lower(v.Text)
            local esAgotado = false
            
            for _, word in ipairs(keywordsAgotado) do
                if string.find(txt, word) then esAgotado = true break end
            end
            
            if esAgotado or string.find(txt, "%$") or tonumber(txt) then
                if v.Text ~= "0" and v.Text ~= "GRATIS" then
                    v.Text = "0" -- Forzar a número 0
                    v.TextColor3 = Color3.fromRGB(0, 255, 0) -- Verde brillante para confirmación visual
                    modificados = modificados + 1
                end
            end
        end
        
        -- 2. Rehabilitar Interacción de Botones
        if v:IsA("GuiButton") then
            if not v.Active or not v.Interactable or not v.Visible then
                v.Active = true
                v.Interactable = true
                v.Visible = true
                v.AutoButtonColor = true
                modificados = modificados + 1
            end
        end

        -- 3. Eliminar "Filtros de Agotado" (Imágenes oscurecidas/transparentes)
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            -- Muchos juegos ponen los iconos grises o semi-transparentes cuando no hay stock
            if v.ImageColor3.R < 0.6 and v.ImageColor3.G < 0.6 and v.ImageColor3.B < 0.6 then
                v.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Restaurar a color original
                v.ImageTransparency = 0
            end
        end

        -- 4. Manipulación Interna de Valores (Técnica Avanzada)
        -- Muchos scripts locales leen estos valores en vez del texto
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            local nombreVal = string.lower(v.Name)
            
            for _, word in ipairs(keywordsPrecio) do
                if string.find(nombreVal, word) and v.Value > 0 then
                    v.Value = 0 -- Poner precio interno a 0
                end
            end
            
            for _, word in ipairs(keywordsStock) do
                if string.find(nombreVal, word) and v.Value <= 0 then
                    v.Value = 9999 -- Simular stock infinito internamente
                end
            end
        end
        
        -- 5. Intercepción de Atributos (Nueva función de Roblox)
        local attributes = v:GetAttributes()
        for attrName, attrValue in pairs(attributes) do
            local lName = string.lower(attrName)
            if string.find(lName, "price") or string.find(lName, "cost") then
                v:SetAttribute(attrName, 0)
            elseif string.find(lName, "stock") then
                v:SetAttribute(attrName, 999)
            end
        end
    end
    
    return modificados
end

-- Interfaz de Rayfield
Tab:CreateSection("1. Forzado Manual e Inteligente")

Tab:CreateButton({
   Name = "Ejecutar Bypass de Tienda (1 Vez)",
   Callback = function()
       local count = ReinforceUI()
       Rayfield:Notify({
           Title = "Bypass Completado", 
           Content = "Se alteraron " .. count .. " propiedades (Valores en 0, botones activos).", 
           Duration = 3
       })
   end,
})

Tab:CreateSection("2. Persistencia (Anti-Update)")

Tab:CreateToggle({
   Name = "Bucle: Mantener Todo Gratis y Habilitado",
   CurrentValue = false,
   Flag = "UI_Loop", 
   Callback = function(Value)
       uiLoopActivo = Value
       
       if uiLoopActivo then
           Rayfield:Notify({Title = "Bucle Activado", Content = "Congelando valores a 0 y forzando habilitación constante...", Duration = 3})
           -- Usamos task.spawn y un while loop para no saturar el RenderStepped
           task.spawn(function()
               while uiLoopActivo do
                   ReinforceUI()
                   task.wait(0.5) -- Revisar cada medio segundo
               end
           end)
       else
           Rayfield:Notify({Title = "Bucle Desactivado", Content = "La UI ya no está congelada.", Duration = 3})
       end
   end,
})

-- Pestaña del NPC
local NpcTab = Window:CreateTab("NPC & Red", "cpu")

NpcTab:CreateButton({
   Name = "Abrir Bomber Barry",
   Callback = function()
       local player = game.Players.LocalPlayer
       local promptPath = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("BomberBarry") and workspace.Things.BomberBarry:FindFirstChild("Torso") and workspace.Things.BomberBarry.Torso:FindFirstChild("BombPrompt")

       if promptPath then
           if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.CFrame = workspace.Things.BomberBarry.Torso.CFrame * CFrame.new(0, 0, 3)
               task.wait(0.2)
           end
           fireproximityprompt(promptPath)
       else
           Rayfield:Notify({Title = "Error", Content = "No se encontró a Bomber Barry.", Duration = 3})
       end
   end,
})

NpcTab:CreateButton({
   Name = "Forzar Transacción (BombShopQuery)",
   Callback = function()
       local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("BombShopQuery")

       if remote and remote:IsA("RemoteFunction") then
           task.spawn(function()
               local success, result = pcall(function() return remote:InvokeServer() end)
               if success then
                   print("[ALB8RAAQ] Servidor responde:", result)
               end
           end)
       end
   end,
})
