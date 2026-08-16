-- ==========================================================
-- SCRIPT DEL SERVIDOR (Ubicación: ServerScriptService)
-- ==========================================================
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Creamos y alojamos el RemoteEvent para que el cliente lo encuentre
local PromptPurchaseRemote = Instance.new("RemoteEvent")
PromptPurchaseRemote.Name = "PromptPurchaseRemote"
PromptPurchaseRemote.Parent = ReplicatedStorage

PromptPurchaseRemote.OnServerEvent:Connect(function(player, assetId)
	-- Validación de seguridad básica
	if typeof(assetId) ~= "number" or assetId <= 0 then return end
	
	-- Se lanza el prompt oficial de Roblox
	MarketplaceService:PromptPurchase(player, assetId)
end)
