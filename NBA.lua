--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
	
	Universal Basketball 0.2 Script by Irdk (scriptblox)
	----------------------------------------------------
	PORTED TO RAYFIELD UI FOR DELTA iOS (MOBILE FRIENDLY)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "🏀 Universal Basketball | iOS Delta",
	LoadingTitle = "Cargando Script...",
	LoadingSubtitle = "by Irdk | Ported to Rayfield",
	ConfigurationSaving = {
		Enabled = false,
	},
	Discord = {
		Enabled = false,
	},
	KeySystem = false,
})

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Replicated = game:GetService("ReplicatedStorage")

-- Jugador
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- ==========================================
-- VARIABLES UNIVERSAL
-- ==========================================
local Uni_hoopPosition = nil
local Uni_target = nil
local Uni_guardEnabled = false
local Uni_guardDistance = 4
local Uni_minDistance = 15
local Uni_bypassSpeed = 50
local Uni_speedMultiplier = 1
local Uni_autoPaused = false
local Uni_holdDuration = 455
local Uni_speedEnabled = false
local Uni_DistanceIndicator = false
local Uni_GreenDot = false

local Uni_bodyVelocity = Instance.new("BodyVelocity")
Uni_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
Uni_bodyVelocity.Parent = hrp

-- ==========================================
-- VARIABLES HOOPS LIFE
-- ==========================================
local HL_hoopPos = nil
local HL_targetPart = nil
local HL_guardEnabled = false
local HL_guardDistance = 5
local HL_guardMode = "Pro"
local HL_speedEnabled = false
local HL_baseSpeed = humanoid.WalkSpeed
local HL_targetSpeed = HL_baseSpeed + 2
local HL_speedMultiplier = 1
local HL_hipHeightEnabled = false
local HL_baseHipHeight = humanoid.HipHeight
local HL_targetHipHeight = HL_baseHipHeight
local HL_autoShoot = false
local HL_autoBlock = false
local HL_queueJump = false

local HL_bodyVelocity = Instance.new("BodyVelocity")
HL_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
HL_bodyVelocity.Parent = hrp

-- Control de movimiento móvil (Pausar auto guard al moverse)
local keysDown = {}
local moveKeys = {W=true, A=true, S=true, D=true}
local joystickMoving = false

-- Manejo de Respawns
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	
	-- Recrear BodyVelocity Universal
	if Uni_bodyVelocity then Uni_bodyVelocity:Destroy() end
	Uni_bodyVelocity = Instance.new("BodyVelocity")
	Uni_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	Uni_bodyVelocity.Parent = hrp

	-- Recrear BodyVelocity Hoops Life
	if HL_bodyVelocity then HL_bodyVelocity:Destroy() end
	HL_bodyVelocity = Instance.new("BodyVelocity")
	HL_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	HL_bodyVelocity.Parent = hrp
	
	HL_baseSpeed = humanoid.WalkSpeed
	if not HL_speedEnabled then HL_targetSpeed = HL_baseSpeed end
	
	HL_baseHipHeight = humanoid.HipHeight
	if not HL_hipHeightEnabled then HL_targetHipHeight = HL_baseHipHeight end
end)

-- Detectar movimiento en móvil/PC para pausar auto guard
humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if humanoid.MoveDirection.Magnitude > 0 then
		joystickMoving = true
	else
		joystickMoving = false
	end
end)

-- ==========================================
-- INTERFAZ RAYFIELD
-- ==========================================

local TabUniversal = Window:CreateTab("Universal", 4483362458)
local TabHoops = Window:CreateTab("Hoops Life", 4483362458)

-- ======== PESTAÑA UNIVERSAL ========
TabUniversal:CreateSection("Configuración de Tiro y Defensa")

TabUniversal:CreateButton({
	Name = "📍 Marcar Aro (Reemplaza tecla L)",
	Callback = function()
		Uni_hoopPosition = hrp.Position
		Rayfield:Notify({Title = "Universal", Content = "Posición del aro guardada.", Duration = 3})
	end,
})

TabUniversal:CreateToggle({
	Name = "🛡️ Auto Guard",
	CurrentValue = false,
	Flag = "UniGuardToggle",
	Callback = function(Value)
		if Value and not Uni_hoopPosition then
			Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3})
			Uni_guardEnabled = false
			return
		end
		Uni_guardEnabled = Value
	end,
})

TabUniversal:CreateSlider({
	Name = "Distancia de Defensa (Studs)",
	Range = {1, 15},
	Increment = 1,
	CurrentValue = 4,
	Flag = "UniGuardDist",
	Callback = function(Value)
		Uni_guardDistance = Value
	end,
})

TabUniversal:CreateButton({
	Name = "🎯 Mantener 'E' Automático",
	Callback = function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.delay(Uni_holdDuration / 1000, function()
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end)
	end,
})

TabUniversal:CreateSlider({
	Name = "Tiempo de 'E' (ms)",
	Range = {100, 1000},
	Increment = 5,
	CurrentValue = 455,
	Flag = "UniHoldE",
	Callback = function(Value)
		Uni_holdDuration = Value
	end,
})

TabUniversal:CreateSection("Movimiento y Velocidad")

TabUniversal:CreateToggle({
	Name = "⚡ Modificador de Velocidad",
	CurrentValue = false,
	Flag = "UniSpeedToggle",
	Callback = function(Value)
		Uni_speedEnabled = Value
	end,
})

TabUniversal:CreateSlider({
	Name = "Velocidad Bypass",
	Range = {10, 200},
	Increment = 5,
	CurrentValue = 50,
	Flag = "UniBypassSpeed",
	Callback = function(Value)
		Uni_bypassSpeed = Value
		Uni_speedMultiplier = Uni_bypassSpeed / 50
	end,
})


-- ======== PESTAÑA HOOPS LIFE ========
TabHoops:CreateSection("Defensa y Aro")

TabHoops:CreateButton({
	Name = "📍 Marcar Aro (Reemplaza tecla L)",
	Callback = function()
		HL_hoopPos = hrp.Position
		_G.HL_HoopPosition = HL_hoopPos
		Rayfield:Notify({Title = "Hoops Life", Content = "Posición del aro guardada.", Duration = 3})
	end,
})

TabHoops:CreateToggle({
	Name = "🛡️ Auto Guard",
	CurrentValue = false,
	Flag = "HLGuardToggle",
	Callback = function(Value)
		if Value and not HL_hoopPos then
			Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3})
			HL_guardEnabled = false
			return
		end
		HL_guardEnabled = Value
	end,
})

TabHoops:CreateDropdown({
	Name = "Modo de Defensa",
	Options = {"Normal", "Pro", "Hacker"},
	CurrentOption = {"Pro"},
	MultipleOptions = false,
	Flag = "HLGuardMode",
	Callback = function(Options)
		HL_guardMode = Options[1]
	end,
})

TabHoops:CreateToggle({
	Name = "🧱 Auto Block (Salto Automático)",
	CurrentValue = false,
	Flag = "HLAutoBlock",
	Callback = function(Value)
		HL_autoBlock = Value
	end,
})

TabHoops:CreateSection("Ataque y Tiro")

TabHoops:CreateToggle({
	Name = "🏀 Activar Auto Shoot",
	CurrentValue = false,
	Flag = "HLAutoShootToggle",
	Callback = function(Value)
		HL_autoShoot = Value
		if Value then
			Rayfield:Notify({Title = "Auto Shoot", Content = "Activo. Usa el botón de abajo para disparar (Reemplaza tecla Q).", Duration = 4})
		end
	end,
})

TabHoops:CreateButton({
	Name = "🔥 Disparar (Auto Green / Reemplaza Q)",
	Callback = function()
		if HL_autoShoot then
			local shoot = Replicated:WaitForChild("Remotes"):WaitForChild("Shoot")
			shoot:FireServer(0, "Starting", "up", false, 0, 0)
			task.wait(0.5)
			shoot:FireServer(100000, "Ending", "up", false, 0, 0)
		else
			Rayfield:Notify({Title = "Aviso", Content = "Activa Auto Shoot primero.", Duration = 3})
		end
	end,
})

TabHoops:CreateSection("Modificadores de Personaje")

TabHoops:CreateToggle({
	Name = "🏃 Speed Changer",
	CurrentValue = false,
	Flag = "HLSpeedToggle",
	Callback = function(Value)
		HL_speedEnabled = Value
		if not Value then
			HL_targetSpeed = HL_baseSpeed
			HL_speedMultiplier = 1
		end
	end,
})

TabHoops:CreateSlider({
	Name = "Velocidad HL",
	Range = {10, 150},
	Increment = 5,
	CurrentValue = 20,
	Flag = "HLSpeedSlider",
	Callback = function(Value)
		HL_targetSpeed = Value
		HL_speedMultiplier = HL_targetSpeed / HL_baseSpeed
	end,
})

TabHoops:CreateToggle({
	Name = "🧍 Altura de Cadera (Hip Height)",
	CurrentValue = false,
	Flag = "HLHipToggle",
	Callback = function(Value)
		HL_hipHeightEnabled = Value
		if Value then
			humanoid.HipHeight = HL_targetHipHeight
		else
			humanoid.HipHeight = HL_baseHipHeight
		end
	end,
})

TabHoops:CreateSlider({
	Name = "Ajuste de Altura",
	Range = {0, 20},
	Increment = 1,
	CurrentValue = 5,
	Flag = "HLHipSlider",
	Callback = function(Value)
		HL_targetHipHeight = HL_baseHipHeight + Value
		if HL_hipHeightEnabled then
			humanoid.HipHeight = HL_targetHipHeight
		end
	end,
})

-- ==========================================
-- LÓGICA PRINCIPAL (RENDER STEPPED)
-- ==========================================

-- Lógica Universal
RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not hrp then return end
	local autoPaused = joystickMoving

	-- Universal Wall Effect
	if Uni_hoopPosition then
		local toHRP = hrp.Position - Uni_hoopPosition
		local dist = toHRP.Magnitude
		if dist < Uni_minDistance then
			local dir = toHRP.Unit
			local vel = hrp.AssemblyLinearVelocity
			local inward = (vel:Dot(-dir))
			if inward > 0 then
				local corrected = vel + dir * inward
				hrp.AssemblyLinearVelocity = Vector3.new(corrected.X, vel.Y, corrected.Z)
			end
		end
	end

	-- Universal Guard
	if Uni_guardEnabled and Uni_hoopPosition and not autoPaused then
		local closest, minDist = nil, math.huge
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < minDist then minDist = d; closest = p.Character.HumanoidRootPart end
			end
		end
		Uni_target = closest

		if Uni_target then
			local dirToPlayer = (Uni_target.Position - Uni_hoopPosition).Unit
			local guardPos = Uni_target.Position - dirToPlayer * Uni_guardDistance
			guardPos = Vector3.new(guardPos.X, hrp.Position.Y, guardPos.Z)
			if math.random(1, 180) == 1 then
				guardPos += Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit * 1.2
			end
			humanoid:MoveTo(guardPos)
		end
	end

	-- Universal Speed Boost
	if Uni_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local finalSpeed = Uni_bypassSpeed * Uni_speedMultiplier
			local vel = hrp.AssemblyLinearVelocity
			local newVel = moveDir.Unit * finalSpeed
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, vel.Y, newVel.Z)
			Uni_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z)
		else
			Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	else
		Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end
end)


-- Lógica Hoops Life
local IGNORE_IDS = {
	["913402848"] = true, ["10779904378"] = true, ["507766388"] = true, ["507766666"] = true,
	["507765644"] = true, ["6954982157"] = true, ["6958914473"] = true, ["6958910778"] = true,
	["7104836507"] = true, ["7015176518"] = true, ["6954967857"] = true, ["7015179264"] = true,
	["17385814388"] = true, ["7018040999"] = true, ["17248159181"] = true, ["6983005836"] = true,
}

local function animId(track)
	return tostring(track.Animation.AnimationId):match("%d+") or "0"
end

local function burstJump()
	for _=1,4 do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		RunService.Heartbeat:Wait()
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
	end
end

RunService:BindToRenderStep("HL_Block", Enum.RenderPriority.First.Value, function()
	if HL_queueJump and HL_autoBlock then
		HL_queueJump = false
		burstJump()
	end
end)

local function watch(plr)
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")
	animator.AnimationPlayed:Connect(function(track)
		if plr == player then return end
		if IGNORE_IDS[animId(track)] then return end
		local root = hum.RootPart or hum.Parent:FindFirstChild("HumanoidRootPart")
		if root and (root.Position - hrp.Position).Magnitude <= 15 then
			HL_queueJump = true
		end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do watch(p) end
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() watch(p) end)
end)

RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not hrp then return end
	local autoPaused = joystickMoving

	-- HL Wall Bounce
	if HL_hoopPos then
		local diff = hrp.Position - HL_hoopPos
		if diff.Magnitude < 12 then
			local dir = diff.Unit
			local vel = hrp.AssemblyLinearVelocity
			local inward = vel:Dot(-dir)
			if inward > 0 then
				local corrected = vel + dir * inward
				hrp.AssemblyLinearVelocity = Vector3.new(corrected.X, vel.Y, corrected.Z)
			end
		end
	end

	-- HL Guard
	if HL_guardEnabled and not autoPaused then
		local bestDist = math.huge
		HL_targetPart = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < bestDist then
					bestDist = d
					HL_targetPart = p.Character.HumanoidRootPart
				end
			end
		end

		if HL_targetPart and HL_hoopPos then
			local dir = (HL_targetPart.Position - HL_hoopPos).Unit
			local guardPos = HL_targetPart.Position - dir * HL_guardDistance
			guardPos = Vector3.new(guardPos.X, hrp.Position.Y, guardPos.Z)

			local moveDirection = (guardPos - hrp.Position)
			local distance = moveDirection.Magnitude
			if distance > 0.1 then moveDirection = moveDirection.Unit else moveDirection = Vector3.zero end

			local bSpeed = (HL_targetPart.AssemblyLinearVelocity.Magnitude > 1 and HL_targetPart.AssemblyLinearVelocity.Magnitude or 10)
			local guardSpeed = bSpeed * HL_speedMultiplier
			if guardSpeed < 999 then guardSpeed = 200 end

			HL_bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
			HL_bodyVelocity.Velocity = moveDirection * guardSpeed

			if HL_guardMode == "Normal" then
				local smallPush = moveDirection * (guardSpeed * 0.1)
				hrp.AssemblyLinearVelocity = Vector3.new(smallPush.X, hrp.AssemblyLinearVelocity.Y, smallPush.Z)
			elseif HL_guardMode == "Pro" then
				local push = moveDirection * (guardSpeed * 0.35)
				hrp.AssemblyLinearVelocity = Vector3.new(push.X, hrp.AssemblyLinearVelocity.Y, push.Z)
			elseif HL_guardMode == "Hacker" then
				local hackerVelocity = moveDirection * (guardSpeed * 1.75)
				HL_bodyVelocity.Velocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.new(hackerVelocity.X, hrp.AssemblyLinearVelocity.Y, hackerVelocity.Z)
			end
		else
			HL_bodyVelocity.Velocity = Vector3.zero
		end
	else
		HL_bodyVelocity.Velocity = Vector3.zero
	end

	-- HL Speed System
	if HL_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local finalSpeed = HL_targetSpeed * HL_speedMultiplier
			local vel = hrp.AssemblyLinearVelocity
			local newVel = moveDir.Unit * finalSpeed
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, vel.Y, newVel.Z)
			if not HL_guardEnabled then
				HL_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z)
			end
		elseif not HL_guardEnabled then
			HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)
