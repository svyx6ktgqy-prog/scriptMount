--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
	
	Universal Basketball 0.2 Script by Irdk (scriptblox)
	----------------------------------------------------
	PORTED TO RAYFIELD UI FOR DELTA iOS (MOBILE FRIENDLY)
	+ MOBILE GUI FIXES INTEGRATED
	+ SMART LOOPS & GREEN INDICATOR INSPECTOR
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "🏀 Universal Basketball | iOS Delta",
	LoadingTitle = "Cargando Script...",
	LoadingSubtitle = "by Irdk | Ported to Rayfield",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false,
})

-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Replicated = game:GetService("ReplicatedStorage")

-- Jugador
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- ==========================================
-- VARIABLES UNIVERSAL & HOOPS LIFE
-- ==========================================
local Uni_hoopPosition, Uni_target = nil, nil
local Uni_guardEnabled = false
local Uni_guardDistance, Uni_minDistance = 4, 15
local Uni_bypassSpeed = 50
local Uni_speedMultiplier = 1
local Uni_holdDuration = 455
local Uni_speedEnabled = false

local HL_hoopPos, HL_targetPart = nil, nil
local HL_guardEnabled, HL_autoShoot, HL_autoBlock, HL_queueJump = false, false, false, false
local HL_guardDistance = 5
local HL_guardMode = "Pro"
local HL_speedEnabled = false
local HL_baseSpeed = humanoid.WalkSpeed
local HL_targetSpeed = HL_baseSpeed + 2
local HL_speedMultiplier = 1
local HL_hipHeightEnabled = false
local HL_baseHipHeight = humanoid.HipHeight
local HL_targetHipHeight = HL_baseHipHeight

-- BodyVelocities
local Uni_bodyVelocity = Instance.new("BodyVelocity")
Uni_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
Uni_bodyVelocity.Parent = hrp

local HL_bodyVelocity = Instance.new("BodyVelocity")
HL_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
HL_bodyVelocity.Parent = hrp

-- ==========================================
-- VARIABLES MOBILE GUI & SMART SWITCHES
-- ==========================================
local Mobile_AutoShoot = false
local Mobile_AutoSprint = false
local Mobile_AutoGrab = false
local Inspect_GreenIndicator = false
local joystickMoving = false

-- Manejo de Respawns
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	
	if Uni_bodyVelocity then Uni_bodyVelocity:Destroy() end
	Uni_bodyVelocity = Instance.new("BodyVelocity")
	Uni_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	Uni_bodyVelocity.Parent = hrp

	if HL_bodyVelocity then HL_bodyVelocity:Destroy() end
	HL_bodyVelocity = Instance.new("BodyVelocity")
	HL_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	HL_bodyVelocity.Parent = hrp
end)

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	joystickMoving = humanoid.MoveDirection.Magnitude > 0
end)

-- ==========================================
-- FUNCIONES MOBILE GUI SEGURAS
-- ==========================================
local function getButton(pathArray)
    local current = PlayerGui:FindFirstChild("MobileActionsGui")
    if not current then return nil end
    for _, name in ipairs(pathArray) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local function fireMobileButton(button)
    if not button then return end
    if firesignal then
        pcall(function() firesignal(button.Activated) end)
        pcall(function() firesignal(button.TouchTap) end)
    elseif getconnections then
        pcall(function()
            for _, conn in pairs(getconnections(button.Activated)) do conn:Fire() end
        end)
    end
end

-- ==========================================
-- BUCLE INTELIGENTE (SMART LOOPS PARA MÓVIL)
-- Elimina el ruido repetido y gestiona cooldowns
-- ==========================================
task.spawn(function()
	local sprintState = false
	while task.wait(0.2) do -- Ciclo relajado de 5 veces por segundo
		
		-- 1. Auto Shoot Inteligente
		if Mobile_AutoShoot then
			local shootBtn = getButton({"Offense", "OnBall", "Shoot"})
			if shootBtn and shootBtn.Visible then
				fireMobileButton(shootBtn)
				task.wait(1) -- Cooldown de 1 segundo tras disparar para evitar sonido trabado
			end
		end

		-- 2. Auto Sprint Inteligente por Estado
		if Mobile_AutoSprint then
			if joystickMoving and not sprintState then
				local sprintBtn = getButton({"Shared", "Sprint"})
				if sprintBtn and sprintBtn.Visible then
					fireMobileButton(sprintBtn)
					sprintState = true
				end
			elseif not joystickMoving and sprintState then
				sprintState = false
			end
		end

		-- 3. Auto Recoger Balón Inteligente
		if Mobile_AutoGrab and hrp then
			local practiceCourt = Workspace:FindFirstChild("Courts") and Workspace.Courts:FindFirstChild("Practice_Court")
			if practiceCourt then
				for _, rack in pairs(practiceCourt:GetChildren()) do
					if rack.Name == "BallRack" and rack:FindFirstChild("PromptAttachment") then
						local prompt = rack.PromptAttachment:FindFirstChild("ProximityPrompt")
						if prompt and prompt.Enabled then
							local dist = (hrp.Position - rack.PromptAttachment.Position).Magnitude
							if dist <= (prompt.MaxActivationDistance + 2) and fireproximityprompt then
								fireproximityprompt(prompt, 1)
								task.wait(0.5) -- Pausa tras recoger para no espamear
							end
						end
					end
				end
			end
		end

	end
end)

-- ==========================================
-- INSPECTOR DE GREEN INDICATOR (LOGGER)
-- ==========================================
PlayerGui.DescendantAdded:Connect(function(descendant)
	if not Inspect_GreenIndicator then return end

	-- Filtramos por nombres comunes que usan los UIs de barras de tiro
	local name = string.lower(descendant.Name)
	if name:match("meter") or name:match("green") or name:match("indicator") or name:match("bar") or name:match("timing") then
		task.delay(0.1, function() -- Esperamos 0.1s para que el UI cargue sus propiedades
			print(" ")
			print("🟩 === GREEN INDICATOR DETECTADO === 🟩")
			print("Ruta del objeto: ", descendant:GetFullName())
			print("Tipo de Clase: ", descendant.ClassName)
			
			pcall(function() print("Tamaño (Size):", tostring(descendant.Size)) end)
			pcall(function() print("Posición (Position):", tostring(descendant.Position)) end)
			pcall(function() print("Visible:", tostring(descendant.Visible)) end)
			pcall(function() print("Transparencia:", tostring(descendant.BackgroundTransparency)) end)
			
			print("--- Sub-Elementos dentro del Indicador ---")
			for _, child in pairs(descendant:GetChildren()) do
				print(" ↳ Nombre:", child.Name, "| Clase:", child.ClassName)
			end
			print("===========================================")
			print(" ")
		end)
	end
end)


-- ==========================================
-- INTERFAZ RAYFIELD
-- ==========================================
local TabUniversal = Window:CreateTab("Universal", 4483362458)
local TabHoops = Window:CreateTab("Hoops Life", 4483362458)
local TabMobile = Window:CreateTab("📱 Mobile Fix", 4483362458)

-- ======== PESTAÑA MOBILE (NUEVO) ========
TabMobile:CreateSection("Acciones Inteligentes (Sin Ruido)")

TabMobile:CreateToggle({
	Name = "🏀 Auto-Shoot Táctil Inteligente",
	CurrentValue = false,
	Flag = "MobileShootToggle",
	Callback = function(Value) Mobile_AutoShoot = Value end,
})

TabMobile:CreateToggle({
	Name = "🏃 Auto-Sprint (Solo al moverse)",
	CurrentValue = false,
	Flag = "MobileSprintToggle",
	Callback = function(Value) Mobile_AutoSprint = Value end,
})

TabMobile:CreateToggle({
	Name = "🤖 Auto Recoger Balón Infinito",
	CurrentValue = false,
	Flag = "MobileGrabToggle",
	Callback = function(Value)
		Mobile_AutoGrab = Value
		if Value then
			Rayfield:Notify({Title = "Auto Grab", Content = "Acércate a un BallRack, se cogerá solo.", Duration = 3})
		end
	end,
})

TabMobile:CreateSection("Herramientas de Desarrollo")

TabMobile:CreateToggle({
	Name = "🔍 Inspeccionar Green Indicator",
	CurrentValue = false,
	Flag = "InspectGreenToggle",
	Callback = function(Value)
		Inspect_GreenIndicator = Value
		if Value then
			Rayfield:Notify({Title = "Inspector Activo", Content = "Tira a canasta. Abre la consola (F9) para ver el log del indicador.", Duration = 5})
		end
	end,
})

TabMobile:CreateButton({
	Name = "💨 Forzar Dribble Rápido (S)",
	Callback = function()
		local dribbleBtn = getButton({"Offense", "OnBall", "DribbleMoveS"})
		if dribbleBtn and dribbleBtn.Visible then
			fireMobileButton(dribbleBtn)
		else
			Rayfield:Notify({Title = "Error", Content = "Necesitas el balón para hacer un dribble.", Duration = 2})
		end
	end,
})

-- ======== PESTAÑA UNIVERSAL ========
TabUniversal:CreateSection("Configuración de Tiro y Defensa")
TabUniversal:CreateButton({ Name = "📍 Marcar Aro (Reemplaza tecla L)", Callback = function() Uni_hoopPosition = hrp.Position; Rayfield:Notify({Title = "Universal", Content = "Posición del aro guardada.", Duration = 3}) end})
TabUniversal:CreateToggle({ Name = "🛡️ Auto Guard", CurrentValue = false, Flag = "UniGuardToggle", Callback = function(Value) if Value and not Uni_hoopPosition then Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3}); Uni_guardEnabled = false; return end; Uni_guardEnabled = Value end})
TabUniversal:CreateSlider({ Name = "Distancia de Defensa (Studs)", Range = {1, 15}, Increment = 1, CurrentValue = 4, Flag = "UniGuardDist", Callback = function(Value) Uni_guardDistance = Value end})
TabUniversal:CreateButton({ Name = "🎯 Mantener 'E' Automático", Callback = function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.delay(Uni_holdDuration / 1000, function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end) end})
TabUniversal:CreateSlider({ Name = "Tiempo de 'E' (ms)", Range = {100, 1000}, Increment = 5, CurrentValue = 455, Flag = "UniHoldE", Callback = function(Value) Uni_holdDuration = Value end})
TabUniversal:CreateSection("Movimiento y Velocidad")
TabUniversal:CreateToggle({ Name = "⚡ Modificador de Velocidad", CurrentValue = false, Flag = "UniSpeedToggle", Callback = function(Value) Uni_speedEnabled = Value end})
TabUniversal:CreateSlider({ Name = "Velocidad Bypass", Range = {10, 200}, Increment = 5, CurrentValue = 50, Flag = "UniBypassSpeed", Callback = function(Value) Uni_bypassSpeed = Value; Uni_speedMultiplier = Uni_bypassSpeed / 50 end})

-- ======== PESTAÑA HOOPS LIFE ========
TabHoops:CreateSection("Defensa y Aro")
TabHoops:CreateButton({ Name = "📍 Marcar Aro (Reemplaza tecla L)", Callback = function() HL_hoopPos = hrp.Position; _G.HL_HoopPosition = HL_hoopPos; Rayfield:Notify({Title = "Hoops Life", Content = "Posición del aro guardada.", Duration = 3}) end})
TabHoops:CreateToggle({ Name = "🛡️ Auto Guard", CurrentValue = false, Flag = "HLGuardToggle", Callback = function(Value) if Value and not HL_hoopPos then Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3}); HL_guardEnabled = false; return end; HL_guardEnabled = Value end})
TabHoops:CreateDropdown({ Name = "Modo de Defensa", Options = {"Normal", "Pro", "Hacker"}, CurrentOption = {"Pro"}, MultipleOptions = false, Flag = "HLGuardMode", Callback = function(Options) HL_guardMode = Options[1] end})
TabHoops:CreateToggle({ Name = "🧱 Auto Block (Salto Automático)", CurrentValue = false, Flag = "HLAutoBlock", Callback = function(Value) HL_autoBlock = Value end})
TabHoops:CreateSection("Ataque y Tiro")
TabHoops:CreateToggle({ Name = "🏀 Activar Auto Shoot (Remotes)", CurrentValue = false, Flag = "HLAutoShootToggle", Callback = function(Value) HL_autoShoot = Value; if Value then Rayfield:Notify({Title = "Auto Shoot", Content = "Activo. Usa el botón de abajo para disparar.", Duration = 4}) end end})
TabHoops:CreateButton({ Name = "🔥 Disparar (Auto Green / Remotes)", Callback = function() if HL_autoShoot then local shoot = Replicated:WaitForChild("Remotes"):WaitForChild("Shoot"); shoot:FireServer(0, "Starting", "up", false, 0, 0); task.wait(0.5); shoot:FireServer(100000, "Ending", "up", false, 0, 0) else Rayfield:Notify({Title = "Aviso", Content = "Activa Auto Shoot primero.", Duration = 3}) end end})
TabHoops:CreateSection("Modificadores de Personaje")
TabHoops:CreateToggle({ Name = "🏃 Speed Changer", CurrentValue = false, Flag = "HLSpeedToggle", Callback = function(Value) HL_speedEnabled = Value; if not Value then HL_targetSpeed = HL_baseSpeed; HL_speedMultiplier = 1 end end})
TabHoops:CreateSlider({ Name = "Velocidad HL", Range = {10, 150}, Increment = 5, CurrentValue = 20, Flag = "HLSpeedSlider", Callback = function(Value) HL_targetSpeed = Value; HL_speedMultiplier = HL_targetSpeed / HL_baseSpeed end})
TabHoops:CreateToggle({ Name = "🧍 Altura de Cadera (Hip Height)", CurrentValue = false, Flag = "HLHipToggle", Callback = function(Value) HL_hipHeightEnabled = Value; if Value then humanoid.HipHeight = HL_targetHipHeight else humanoid.HipHeight = HL_baseHipHeight end end})
TabHoops:CreateSlider({ Name = "Ajuste de Altura", Range = {0, 20}, Increment = 1, CurrentValue = 5, Flag = "HLHipSlider", Callback = function(Value) HL_targetHipHeight = HL_baseHipHeight + Value; if HL_hipHeightEnabled then humanoid.HipHeight = HL_targetHipHeight end end})

-- ==========================================
-- LÓGICA RENDER STEPPED (SOLO FÍSICAS Y VECTORES)
-- (El código de Auto-Shoot y Sprint móvil ha sido eliminado de aquí)
-- ==========================================
RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not hrp then return end
	local autoPaused = joystickMoving

	-- Universal Wall Effect
	if Uni_hoopPosition then
		local toHRP = hrp.Position - Uni_hoopPosition
		if toHRP.Magnitude < Uni_minDistance then
			local dir = toHRP.Unit
			local vel = hrp.AssemblyLinearVelocity
			local inward = (vel:Dot(-dir))
			if inward > 0 then
				hrp.AssemblyLinearVelocity = Vector3.new((vel + dir * inward).X, vel.Y, (vel + dir * inward).Z)
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
			local guardPos = Uni_target.Position - (Uni_target.Position - Uni_hoopPosition).Unit * Uni_guardDistance
			guardPos = Vector3.new(guardPos.X, hrp.Position.Y, guardPos.Z)
			humanoid:MoveTo(guardPos)
		end
	end

	-- Universal Speed Boost
	if Uni_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local newVel = moveDir.Unit * (Uni_bypassSpeed * Uni_speedMultiplier)
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, hrp.AssemblyLinearVelocity.Y, newVel.Z)
			Uni_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z)
		else
			Uni_bodyVelocity.Velocity = Vector3.zero
		end
	else
		Uni_bodyVelocity.Velocity = Vector3.zero
	end
end)

-- (El resto de la lógica de Auto Block y Hoops Life permanece intacta, 
--  ya que solo afectaba a la versión de físicas del jugador)
local IGNORE_IDS = { ["913402848"] = true, ["10779904378"] = true, ["507766388"] = true, ["507766666"] = true, ["507765644"] = true, ["6954982157"] = true, ["6958914473"] = true, ["6958910778"] = true, ["7104836507"] = true, ["7015176518"] = true, ["6954967857"] = true, ["7015179264"] = true, ["17385814388"] = true, ["7018040999"] = true, ["17248159181"] = true, ["6983005836"] = true }
local function animId(t) return tostring(t.Animation.AnimationId):match("%d+") or "0" end
local function burstJump() for _=1,4 do VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game); RunService.Heartbeat:Wait(); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end end

RunService:BindToRenderStep("HL_Block", Enum.RenderPriority.First.Value, function()
	if HL_queueJump and HL_autoBlock then HL_queueJump = false; burstJump() end
end)

local function watch(plr)
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")
	animator.AnimationPlayed:Connect(function(track)
		if plr == player or IGNORE_IDS[animId(track)] then return end
		local root = hum.RootPart or hum.Parent:FindFirstChild("HumanoidRootPart")
		if root and (root.Position - hrp.Position).Magnitude <= 15 then HL_queueJump = true end
	end)
end
for _, p in ipairs(Players:GetPlayers()) do watch(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() watch(p) end) end)

RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not hrp then return end
	if HL_hoopPos then
		local diff = hrp.Position - HL_hoopPos
		if diff.Magnitude < 12 then
			local vel, dir = hrp.AssemblyLinearVelocity, diff.Unit
			if vel:Dot(-dir) > 0 then hrp.AssemblyLinearVelocity = Vector3.new((vel + dir * vel:Dot(-dir)).X, vel.Y, (vel + dir * vel:Dot(-dir)).Z) end
		end
	end

	if HL_guardEnabled and not joystickMoving then
		local bestDist, HL_targetPart = math.huge, nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < bestDist then bestDist = d; HL_targetPart = p.Character.HumanoidRootPart end
			end
		end

		if HL_targetPart and HL_hoopPos then
			local dir = (HL_targetPart.Position - HL_hoopPos).Unit
			local guardPos = Vector3.new((HL_targetPart.Position - dir * HL_guardDistance).X, hrp.Position.Y, (HL_targetPart.Position - dir * HL_guardDistance).Z)
			local moveDirection = (guardPos - hrp.Position)
			moveDirection = moveDirection.Magnitude > 0.1 and moveDirection.Unit or Vector3.zero
			
			local guardSpeed = (HL_targetPart.AssemblyLinearVelocity.Magnitude > 1 and HL_targetPart.AssemblyLinearVelocity.Magnitude or 10) * HL_speedMultiplier
			if guardSpeed < 999 then guardSpeed = 200 end
			
			HL_bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
			HL_bodyVelocity.Velocity = moveDirection * guardSpeed

			if HL_guardMode == "Normal" then hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 0.1)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 0.1)).Z)
			elseif HL_guardMode == "Pro" then hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 0.35)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 0.35)).Z)
			elseif HL_guardMode == "Hacker" then HL_bodyVelocity.Velocity = Vector3.zero; hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 1.75)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 1.75)).Z) end
		else HL_bodyVelocity.Velocity = Vector3.zero end
	else HL_bodyVelocity.Velocity = Vector3.zero end

	if HL_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local newVel = moveDir.Unit * (HL_targetSpeed * HL_speedMultiplier)
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, hrp.AssemblyLinearVelocity.Y, newVel.Z)
			if not HL_guardEnabled then HL_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z) end
		elseif not HL_guardEnabled then HL_bodyVelocity.Velocity = Vector3.zero end
	end
end)
