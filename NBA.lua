--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
	
	Universal Basketball 0.2 Script by Irdk
	----------------------------------------------------
	PORTED TO RAYFIELD UI FOR DELTA iOS (MOBILE FRIENDLY)
	+ MOBILE HOLD-BUTTON FIXES
	+ FLOATING AUTOSHOOTV BUTTON (525ms)
	+ PERFECT GREEN 100% INDICATOR OVERRIDE
	+ (FIX) UI LOADING & CORE GUI ERRORS BY GEMINI
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "🏀 Universal Basketball | iOS Delta",
	LoadingTitle = "Cargando Script...",
	LoadingSubtitle = "by Irdk | Perfect Green Edition",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false,
})

-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Replicated = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

-- Jugador
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- VARIABLES UNIVERSAL & HOOPS LIFE
-- ==========================================
local character, humanoid, hrp
local Uni_bodyVelocity, HL_bodyVelocity

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
local HL_baseSpeed = 16
local HL_targetSpeed = HL_baseSpeed + 2
local HL_speedMultiplier = 1
local HL_hipHeightEnabled = false
local HL_baseHipHeight = 2
local HL_targetHipHeight = HL_baseHipHeight

-- ==========================================
-- VARIABLES MOBILE GUI & SMART SWITCHES
-- ==========================================
local Mobile_AutoShoot = false
local Mobile_ShootHoldTime = 455 
local Mobile_AutoSprint = false
local Mobile_AutoGrab = false
local ForcePerfectGreen = false
local joystickMoving = false

-- ==========================================
-- MANEJO SEGURO DE PERSONAJE (EVITA QUE SE CONGELE LA UI)
-- ==========================================
local function setupCharacter(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	
	HL_baseSpeed = humanoid.WalkSpeed
	HL_baseHipHeight = humanoid.HipHeight
	
	if Uni_bodyVelocity and Uni_bodyVelocity.Parent then Uni_bodyVelocity:Destroy() end
	Uni_bodyVelocity = Instance.new("BodyVelocity")
	Uni_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	Uni_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	Uni_bodyVelocity.Parent = hrp

	if HL_bodyVelocity and HL_bodyVelocity.Parent then HL_bodyVelocity:Destroy() end
	HL_bodyVelocity = Instance.new("BodyVelocity")
	HL_bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
	HL_bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	HL_bodyVelocity.Parent = hrp

	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		joystickMoving = humanoid.MoveDirection.Magnitude > 0
	end)
end

if player.Character then
	task.spawn(setupCharacter, player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

-- ==========================================
-- FUNCIONES MOBILE GUI (HOLD REAL)
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

local function simulateButtonDown(button)
	if not button then return end
	if getconnections then
		pcall(function()
			for _, conn in pairs(getconnections(button.InputBegan)) do 
				conn:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.Begin}) 
			end
			for _, conn in pairs(getconnections(button.MouseButton1Down)) do conn:Fire() end
		end)
	end
end

local function simulateButtonUp(button)
	if not button then return end
	if getconnections then
		pcall(function()
			for _, conn in pairs(getconnections(button.InputEnded)) do 
				conn:Fire({UserInputType = Enum.UserInputType.Touch, UserInputState = Enum.UserInputState.End}) 
			end
			for _, conn in pairs(getconnections(button.MouseButton1Up)) do conn:Fire() end
		end)
	end
end

local function simulateButtonTap(button)
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
-- INTERFAZ FLOTANTE: AUTOSHOOTV (525ms) (MANEJO SEGURO DELTA iOS)
-- ==========================================
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "AutoShootV_Floating"
FloatGui.ResetOnSpawn = false

-- Prevención de crasheo silencioso de UI
local successParent = pcall(function()
	local getHui = gethui and gethui() or game:GetService("CoreGui")
	FloatGui.Parent = getHui
end)
if not successParent then
	pcall(function() FloatGui.Parent = PlayerGui end)
end

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 80)
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Text = "Shoot\n(525)"
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 14
FloatBtn.UICorner = Instance.new("UICorner", FloatBtn)
FloatBtn.UICorner.CornerRadius = UDim.new(1, 0)
FloatBtn.Parent = FloatGui
FloatBtn.Visible = false 

-- Lógica para arrastrar el botón en móvil/PC
local dragging, dragInput, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = FloatBtn.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
FloatBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

FloatBtn.Activated:Connect(function()
	local shootBtn = getButton({"Offense", "OnBall", "Shoot"})
	if shootBtn and shootBtn.Visible then
		FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) 
		simulateButtonDown(shootBtn)
		task.wait(0.525) 
		simulateButtonUp(shootBtn)
		FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 80) 
	end
end)

-- ==========================================
-- BUCLES INTELIGENTES (SMART LOOPS)
-- ==========================================
task.spawn(function()
	local sprintState = false
	while task.wait(0.1) do
		if Mobile_AutoShoot then
			local shootBtn = getButton({"Offense", "OnBall", "Shoot"})
			if shootBtn and shootBtn.Visible then
				simulateButtonDown(shootBtn) 
				task.wait(Mobile_ShootHoldTime / 1000) 
				simulateButtonUp(shootBtn) 
				task.wait(1.5) 
			end
		end

		if Mobile_AutoSprint then
			local sprintBtn = getButton({"Shared", "Sprint"})
			if joystickMoving and not sprintState then
				if sprintBtn and sprintBtn.Visible then
					simulateButtonDown(sprintBtn)
					sprintState = true
				end
			elseif not joystickMoving and sprintState then
				if sprintBtn then
					simulateButtonUp(sprintBtn)
				end
				sprintState = false
			end
		end

		if Mobile_AutoGrab then
			local practiceCourt = Workspace:FindFirstChild("Courts") and Workspace.Courts:FindFirstChild("Practice_Court")
			if practiceCourt then
				local rack = practiceCourt:FindFirstChild("BallRack")
				if rack and rack:FindFirstChild("PromptAttachment") then
					local prompt = rack.PromptAttachment:FindFirstChild("ProximityPrompt")
					if prompt and fireproximityprompt then
						fireproximityprompt(prompt, 1)
					end
				end
			end
		end
	end
end)

-- ==========================================
-- INTERFAZ RAYFIELD
-- ==========================================
-- Los IDs numéricos como String evitan errores sintácticos en Rayfield
local TabUniversal = Window:CreateTab("Universal", "4483362458")
local TabHoops = Window:CreateTab("Hoops Life", "4483362458")
local TabMobile = Window:CreateTab("📱 Mobile Fix", "4483362458")

-- ======== PESTAÑA MOBILE ========
TabMobile:CreateSection("Asistencias de Tiro (NUEVO)")

TabMobile:CreateToggle({
	Name = "🟢 Forzar 100% Indicador Verde",
	CurrentValue = false,
	Flag = "ForcePerfectGreen",
	Callback = function(Value)
		ForcePerfectGreen = Value
	end,
})

TabMobile:CreateToggle({
	Name = "🔘 Habilitar Botón Flotante AutoShootV (525ms)",
	CurrentValue = false,
	Flag = "FloatAutoShootToggle",
	Callback = function(Value)
		FloatBtn.Visible = Value
	end,
})

TabMobile:CreateSection("Acciones de GUI (Simulan Toque Real)")
TabMobile:CreateToggle({ Name = "🏀 Auto-Shoot Táctil Loop (Mantiene Presionado)", CurrentValue = false, Flag = "MobileShootToggle", Callback = function(Value) Mobile_AutoShoot = Value end})
TabMobile:CreateSlider({ Name = "Tiempo de Barra Loop (ms)", Range = {100, 1000}, Increment = 5, CurrentValue = 455, Flag = "MobileShootHoldTime", Callback = function(Value) Mobile_ShootHoldTime = Value end})
TabMobile:CreateToggle({ Name = "🏃 Auto-Sprint (Mantiene al moverse)", CurrentValue = false, Flag = "MobileSprintToggle", Callback = function(Value) Mobile_AutoSprint = Value; if not Value then local sprintBtn = getButton({"Shared", "Sprint"}); if sprintBtn then simulateButtonUp(sprintBtn) end end end})
TabMobile:CreateToggle({ Name = "🤖 Auto Recoger Balón Infinito", CurrentValue = false, Flag = "MobileGrabToggle", Callback = function(Value) Mobile_AutoGrab = Value end})
TabMobile:CreateButton({ Name = "💨 Forzar Dribble Rápido (S)", Callback = function() local dribbleBtn = getButton({"Offense", "OnBall", "DribbleMoveS"}); if dribbleBtn and dribbleBtn.Visible then simulateButtonTap(dribbleBtn) else Rayfield:Notify({Title = "Error", Content = "Necesitas el balón para hacer un dribble.", Duration = 2}) end end})

-- ======== PESTAÑA UNIVERSAL ========
TabUniversal:CreateSection("Configuración de Tiro y Defensa")
TabUniversal:CreateButton({ Name = "📍 Marcar Aro (Reemplaza tecla L)", Callback = function() if hrp then Uni_hoopPosition = hrp.Position; Rayfield:Notify({Title = "Universal", Content = "Posición del aro guardada.", Duration = 3}) end end})
TabUniversal:CreateToggle({ Name = "🛡️ Auto Guard", CurrentValue = false, Flag = "UniGuardToggle", Callback = function(Value) if Value and not Uni_hoopPosition then Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3}); Uni_guardEnabled = false; return end; Uni_guardEnabled = Value end})
TabUniversal:CreateSlider({ Name = "Distancia de Defensa (Studs)", Range = {1, 15}, Increment = 1, CurrentValue = 4, Flag = "UniGuardDist", Callback = function(Value) Uni_guardDistance = Value end})
TabUniversal:CreateButton({ Name = "🎯 Mantener 'E' Automático", Callback = function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.delay(Uni_holdDuration / 1000, function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end) end})
TabUniversal:CreateSlider({ Name = "Tiempo de 'E' PC (ms)", Range = {100, 1000}, Increment = 5, CurrentValue = 455, Flag = "UniHoldE", Callback = function(Value) Uni_holdDuration = Value end})

TabUniversal:CreateSection("Movimiento y Velocidad")
TabUniversal:CreateToggle({ Name = "⚡ Modificador de Velocidad", CurrentValue = false, Flag = "UniSpeedToggle", Callback = function(Value) Uni_speedEnabled = Value end})
TabUniversal:CreateSlider({ Name = "Velocidad Bypass", Range = {10, 200}, Increment = 5, CurrentValue = 50, Flag = "UniBypassSpeed", Callback = function(Value) Uni_bypassSpeed = Value; Uni_speedMultiplier = Uni_bypassSpeed / 50 end})

-- ======== PESTAÑA HOOPS LIFE ========
TabHoops:CreateSection("Defensa y Aro")
TabHoops:CreateButton({ Name = "📍 Marcar Aro (Reemplaza tecla L)", Callback = function() if hrp then HL_hoopPos = hrp.Position; _G.HL_HoopPosition = HL_hoopPos; Rayfield:Notify({Title = "Hoops Life", Content = "Posición del aro guardada.", Duration = 3}) end end})
TabHoops:CreateToggle({ Name = "🛡️ Auto Guard", CurrentValue = false, Flag = "HLGuardToggle", Callback = function(Value) if Value and not HL_hoopPos then Rayfield:Notify({Title = "Error", Content = "Marca el aro primero.", Duration = 3}); HL_guardEnabled = false; return end; HL_guardEnabled = Value end})
TabHoops:CreateDropdown({ Name = "Modo de Defensa", Options = {"Normal", "Pro", "Hacker"}, CurrentOption = {"Pro"}, MultipleOptions = false, Flag = "HLGuardMode", Callback = function(Options) HL_guardMode = Options[1] end})
TabHoops:CreateToggle({ Name = "🧱 Auto Block (Salto Automático)", CurrentValue = false, Flag = "HLAutoBlock", Callback = function(Value) HL_autoBlock = Value end})

TabHoops:CreateSection("Ataque y Tiro")
TabHoops:CreateToggle({ Name = "🏀 Activar Auto Shoot (Remotes)", CurrentValue = false, Flag = "HLAutoShootToggle", Callback = function(Value) HL_autoShoot = Value; if Value then Rayfield:Notify({Title = "Auto Shoot", Content = "Activo. Usa el botón de abajo para disparar.", Duration = 4}) end end})
TabHoops:CreateButton({ Name = "🔥 Disparar (Auto Green / Remotes)", Callback = function() if HL_autoShoot then local shoot = Replicated:WaitForChild("Remotes"):WaitForChild("Shoot"); shoot:FireServer(0, "Starting", "up", false, 0, 0); task.wait(0.5); shoot:FireServer(100000, "Ending", "up", false, 0, 0) else Rayfield:Notify({Title = "Aviso", Content = "Activa Auto Shoot primero.", Duration = 3}) end end})

TabHoops:CreateSection("Modificadores de Personaje")
TabHoops:CreateToggle({ Name = "🏃 Speed Changer", CurrentValue = false, Flag = "HLSpeedToggle", Callback = function(Value) HL_speedEnabled = Value; if not Value then HL_targetSpeed = HL_baseSpeed; HL_speedMultiplier = 1 end end})
TabHoops:CreateSlider({ Name = "Velocidad HL", Range = {10, 150}, Increment = 5, CurrentValue = 20, Flag = "HLSpeedSlider", Callback = function(Value) HL_targetSpeed = Value; HL_speedMultiplier = HL_targetSpeed / HL_baseSpeed end})
TabHoops:CreateToggle({ Name = "🧍 Altura de Cadera (Hip Height)", CurrentValue = false, Flag = "HLHipToggle", Callback = function(Value) HL_hipHeightEnabled = Value; if Value and humanoid then humanoid.HipHeight = HL_targetHipHeight elseif humanoid then humanoid.HipHeight = HL_baseHipHeight end end})
TabHoops:CreateSlider({ Name = "Ajuste de Altura", Range = {0, 20}, Increment = 1, CurrentValue = 5, Flag = "HLHipSlider", Callback = function(Value) HL_targetHipHeight = HL_baseHipHeight + Value; if HL_hipHeightEnabled and humanoid then humanoid.HipHeight = HL_targetHipHeight end end})

-- ==========================================
-- LÓGICA RENDER STEPPED (FÍSICAS, VECTORES Y 100% GREEN)
-- ==========================================
RunService.RenderStepped:Connect(function()
	if not character or not humanoid or not hrp or not hrp.Parent then return end
	local autoPaused = joystickMoving

	-- FORZAR PERFECT GREEN (100%)
	if ForcePerfectGreen then
		local passIndicator = PlayerGui:FindFirstChild("PassIndicator", true)
		if passIndicator then
			local circle = passIndicator:FindFirstChild("CircleFrame")
			if circle then
				circle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) 
			end
			local label = passIndicator:FindFirstChild("NumberLabel", true)
			if label and label:IsA("TextLabel") then
				label.Text = "100"
				label.TextColor3 = Color3.fromRGB(0, 255, 0)
			end
		end
	end

	-- Universal Wall Effect
	if Uni_hoopPosition then
		local toHRP = hrp.Position - Uni_hoopPosition
		if toHRP.Magnitude < Uni_minDistance then
			local dir = toHRP.Unit
			local vel = hrp.AssemblyLinearVelocity
			local inward = (vel:Dot(-dir))
			if inward > 0 then hrp.AssemblyLinearVelocity = Vector3.new((vel + dir * inward).X, vel.Y, (vel + dir * inward).Z) end
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
		if Uni_target then humanoid:MoveTo(Vector3.new((Uni_target.Position - (Uni_target.Position - Uni_hoopPosition).Unit * Uni_guardDistance).X, hrp.Position.Y, (Uni_target.Position - (Uni_target.Position - Uni_hoopPosition).Unit * Uni_guardDistance).Z)) end
	end

	-- Universal Speed Boost
	if Uni_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local newVel = moveDir.Unit * (Uni_bypassSpeed * Uni_speedMultiplier)
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, hrp.AssemblyLinearVelocity.Y, newVel.Z)
			if Uni_bodyVelocity then Uni_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z) end
		elseif Uni_bodyVelocity then Uni_bodyVelocity.Velocity = Vector3.zero end
	elseif Uni_bodyVelocity then Uni_bodyVelocity.Velocity = Vector3.zero end

	-- HL Wall Bounce
	if HL_hoopPos then
		local diff = hrp.Position - HL_hoopPos
		if diff.Magnitude < 12 then
			local vel, dir = hrp.AssemblyLinearVelocity, diff.Unit
			if vel:Dot(-dir) > 0 then hrp.AssemblyLinearVelocity = Vector3.new((vel + dir * vel:Dot(-dir)).X, vel.Y, (vel + dir * vel:Dot(-dir)).Z) end
		end
	end

	-- HL Guard
	if HL_guardEnabled and not joystickMoving then
		local bestDist, targetPart = math.huge, nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < bestDist then bestDist = d; targetPart = p.Character.HumanoidRootPart end
			end
		end

		if targetPart and HL_hoopPos then
			local dir = (targetPart.Position - HL_hoopPos).Unit
			local guardPos = Vector3.new((targetPart.Position - dir * HL_guardDistance).X, hrp.Position.Y, (targetPart.Position - dir * HL_guardDistance).Z)
			local moveDirection = (guardPos - hrp.Position)
			moveDirection = moveDirection.Magnitude > 0.1 and moveDirection.Unit or Vector3.zero
			
			local guardSpeed = (targetPart.AssemblyLinearVelocity.Magnitude > 1 and targetPart.AssemblyLinearVelocity.Magnitude or 10) * HL_speedMultiplier
			if guardSpeed < 999 then guardSpeed = 200 end
			
			if HL_bodyVelocity then
				HL_bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
				HL_bodyVelocity.Velocity = moveDirection * guardSpeed
			end

			if HL_guardMode == "Normal" then hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 0.1)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 0.1)).Z)
			elseif HL_guardMode == "Pro" then hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 0.35)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 0.35)).Z)
			elseif HL_guardMode == "Hacker" then if HL_bodyVelocity then HL_bodyVelocity.Velocity = Vector3.zero end; hrp.AssemblyLinearVelocity = Vector3.new((moveDirection * (guardSpeed * 1.75)).X, hrp.AssemblyLinearVelocity.Y, (moveDirection * (guardSpeed * 1.75)).Z) end
		elseif HL_bodyVelocity then HL_bodyVelocity.Velocity = Vector3.zero end
	elseif HL_bodyVelocity then HL_bodyVelocity.Velocity = Vector3.zero end

	-- HL Speed
	if HL_speedEnabled then
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			local newVel = moveDir.Unit * (HL_targetSpeed * HL_speedMultiplier)
			hrp.AssemblyLinearVelocity = Vector3.new(newVel.X, hrp.AssemblyLinearVelocity.Y, newVel.Z)
			if not HL_guardEnabled and HL_bodyVelocity then HL_bodyVelocity.Velocity = Vector3.new(newVel.X, 0, newVel.Z) end
		elseif not HL_guardEnabled and HL_bodyVelocity then HL_bodyVelocity.Velocity = Vector3.zero end
	end
end)

-- Sistema de Bloqueo Automático (HL_AutoBlock)
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
		if root and hrp and (root.Position - hrp.Position).Magnitude <= 15 then HL_queueJump = true end
	end)
end
for _, p in ipairs(Players:GetPlayers()) do pcall(function() watch(p) end) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); pcall(function() watch(p) end) end) end)

Rayfield:LoadConfiguration()
