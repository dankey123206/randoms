local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then
		return hui
	end
	return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local Config = {
	-- Görüş & Aimbot
	Esp = false,
	MaxEspStuds = 500,
	AimActive = false,
	AimMaxDist = 350,
	AimPrediction = 0.12,
	TeamCheck = true,
	Part = "Head",
	AimTargetMode = "Hepsi",
	Smooth = 1,

	-- Savaş
	NoRecoil = false,
	TriggerBot = false,
	KillAura = false,
	AuraRange = 18,
	AutoSwing = false,
	SwingDelay = 0.12,
	InfAmmo = false,

	-- Karakter & Hareket
	Fly = false,
	FlySpeed = 60,
	CarFly = false,
	CarFlySpeed = 90,
	WalkSpeed = 16,
	JumpPower = 50,
	SpeedJumpEnabled = false,
	InfJump = false,
	GodMode = false,
	AntiBullet = false,
	Noclip = false,

	-- Işınlanma
	NearestTpMode = "Hepsi",
	SelectedTpPlayer = nil,

	-- Ekran Butonları
	ShowAimBtn = false,
	ShowTpBtn = false,
	ShowNearestTpBtn = false,
	ShowAuraBtn = false,
	ShowTrigBtn = false,
	ShowFlyBtn = false,

	-- Optimizasyon
	NoLag = false,
	UltraPotato = false
}

local espList = {}
local uiSetters = {}
local cachedTargets = {}
local cleanedInstances = setmetatable({}, { __mode = "k" })
local tpDropdownRef = nil
local lastScanTime = 0
local lastSwingTime = 0
local lastTriggerTime = 0
local lastOptTime = 0
local lastAmmoTime = 0
local prevCamLook = nil
local isSyncingUI = false

local flyBodyGyro = nil
local flyBodyVel = nil

local function syncModeUI()
	if isSyncingUI then
		return
	end
	isSyncingUI = true
	for _, fn in ipairs(uiSetters) do
		pcall(fn)
	end
	task.defer(function()
		isSyncingUI = false
	end)
end

local function isOwnCharacter(model)
	if not model then
		return true
	end
	if LocalPlayer.Character and (model == LocalPlayer.Character or model:IsDescendantOf(LocalPlayer.Character)) then
		return true
	end
	local plrFromChar = Players:GetPlayerFromCharacter(model)
	if plrFromChar and plrFromChar == LocalPlayer then
		return true
	end
	return false
end

local function isAliveCharacter(model)
	if not model or not model.Parent or isOwnCharacter(model) then
		return false
	end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end
	local stateOk, state = pcall(function()
		return hum:GetState()
	end)
	if stateOk and state == Enum.HumanoidStateType.Dead then
		return false
	end
	if model:GetAttribute("Dead") == true or model:GetAttribute("IsDead") == true or model:GetAttribute("Downed") == true then
		return false
	end
	return true
end

local function isTeammate(plr)
	if not Config.TeamCheck or not plr or plr == LocalPlayer then
		return false
	end

	local ok, sameTeam = pcall(function()
		if LocalPlayer.Team and plr.Team then
			return LocalPlayer.Team == plr.Team
		end
		if LocalPlayer.TeamColor and plr.TeamColor then
			if LocalPlayer.TeamColor ~= BrickColor.White() and plr.TeamColor ~= BrickColor.White() then
				return LocalPlayer.TeamColor == plr.TeamColor
			end
		end
		local myTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("TeamName") or LocalPlayer:GetAttribute("Faction")
		local theirTeamAttr = plr:GetAttribute("Team") or plr:GetAttribute("TeamName") or plr:GetAttribute("Faction")
		if myTeamAttr ~= nil and theirTeamAttr ~= nil then
			return tostring(myTeamAttr) == tostring(theirTeamAttr)
		end
		local myChar = LocalPlayer.Character
		local theirChar = plr.Character
		if myChar and theirChar then
			local c1 = myChar:GetAttribute("Team") or myChar:GetAttribute("TeamName")
			local c2 = theirChar:GetAttribute("Team") or theirChar:GetAttribute("TeamName")
			if c1 ~= nil and c2 ~= nil then
				return tostring(c1) == tostring(c2)
			end
		end
		return false
	end)

	return ok and sameTeam or false
end

local function readTeamValue(inst)
	if not inst then
		return nil
	end
	local v = inst:GetAttribute("Team") or inst:GetAttribute("TeamName") or inst:GetAttribute("Faction")
	if v ~= nil then
		return tostring(v)
	end
	for _, n in ipairs({"Team", "TeamName", "Faction"}) do
		local c = inst:FindFirstChild(n)
		if c and c:IsA("ValueBase") then
			local val = c.Value
			if val ~= nil then
				if typeof(val) == "Instance" then
					return val.Name
				end
				return tostring(val)
			end
		end
	end
	return nil
end

-- Hem oyuncular hem botlar için takım kontrolü
local function isTeammateTarget(t)
	if not Config.TeamCheck or not t then
		return false
	end
	if t.isPlayer then
		if isTeammate(t.player) then
			return true
		end
		local mine = LocalPlayer.Team and LocalPlayer.Team.Name or readTeamValue(LocalPlayer) or readTeamValue(LocalPlayer.Character)
		local theirs = readTeamValue(t.model)
		return mine ~= nil and theirs ~= nil and mine == theirs
	end
	local ok, res = pcall(function()
		local mine = LocalPlayer.Team and LocalPlayer.Team.Name or readTeamValue(LocalPlayer) or readTeamValue(LocalPlayer.Character)
		local theirs = readTeamValue(t.model)
		return mine ~= nil and theirs ~= nil and mine == theirs
	end)
	return ok and res or false
end

local function getPlayerNamesList()
	local names = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(names, plr.Name)
		end
	end
	if #names == 0 then
		table.insert(names, "Oyuncu Yok")
	end
	return names
end

local function refreshTpDropdown()
	if tpDropdownRef then
		pcall(function()
			tpDropdownRef:Refresh(getPlayerNamesList(), true)
		end)
	end
end

local function getMyRoot()
	local char = LocalPlayer.Character
	if not char or not char.Parent then
		return nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("Head")
end

local function teleportToPart(targetPart)
	local myRoot = getMyRoot()
	if targetPart and targetPart:IsA("BasePart") and targetPart.Parent and myRoot then
		pcall(function()
			myRoot.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3.5)
		end)
	end
end

local function teleportToPlayerName(playerName)
	if not playerName or playerName == "Oyuncu Yok" then
		return
	end
	local targetPlr = Players:FindFirstChild(playerName)
	if not targetPlr or targetPlr == LocalPlayer then
		return
	end
	local tChar = targetPlr.Character
	if not isAliveCharacter(tChar) then
		return
	end
	local tPart = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Head")
	teleportToPart(tPart)
end

local function teleportToNearestTarget()
	local myRoot = getMyRoot()
	if not myRoot then
		return
	end

	local nearestPart = nil
	local nearestDist = math.huge

	for _, t in ipairs(cachedTargets) do
		if t and isAliveCharacter(t.model) and t.part and t.part:IsA("BasePart") and t.part.Parent then
			local allowByMode = true
			if Config.NearestTpMode == "Oyuncular" then
				allowByMode = (t.isPlayer == true)
			elseif Config.NearestTpMode == "Bot" then
				allowByMode = (t.isPlayer == false)
			end

			if allowByMode and not isTeammateTarget(t) then
				local dist = (t.part.Position - myRoot.Position).Magnitude
				if dist > 1.5 and dist < nearestDist then
					nearestDist = dist
					nearestPart = t.part
				end
			end
		end
	end

	if nearestPart then
		teleportToPart(nearestPart)
	end
end

Players.PlayerAdded:Connect(function()
	task.wait(0.2)
	refreshTpDropdown()
end)

Players.PlayerRemoving:Connect(function()
	task.wait(0.2)
	refreshTpDropdown()
end)

-- Uçma & Araç Uçma Temizleyici
local function stopFlyObjects()
	if flyBodyGyro then
		pcall(function() flyBodyGyro:Destroy() end)
		flyBodyGyro = nil
	end
	if flyBodyVel then
		pcall(function() flyBodyVel:Destroy() end)
		flyBodyVel = nil
	end
end

local function getSeatVehiclePart()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local seat = hum and hum.SeatPart
	if seat and seat:IsA("BasePart") then
		local model = seat:FindFirstAncestorOfClass("Model")
		if model and model.PrimaryPart then
			return model.PrimaryPart
		end
		return seat
	end
	return nil
end

local function updateFlyAndMovement()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local myRoot = getMyRoot()
	local cam = Workspace.CurrentCamera
	if not char or not hum or not myRoot or not cam then
		stopFlyObjects()
		return
	end

	-- Hız ve Zıplama
	if Config.SpeedJumpEnabled then
		pcall(function()
			hum.WalkSpeed = Config.WalkSpeed
			if hum.UseJumpPower then
				hum.JumpPower = Config.JumpPower
			else
				hum.JumpHeight = math.max(7.2, Config.JumpPower * 0.15)
			end
		end)
	end

	-- God Mode (İstemci tarafı can koruma & düşme hasarı önleme)
	if Config.GodMode then
		pcall(function()
			if hum.Health < hum.MaxHealth and hum.Health > 0 then
				hum.Health = hum.MaxHealth
			end
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end)
	end

	-- Düşman Mermileri İçimden Geçsin (Anti-Bullet / Karakter Hitbox CanQuery kapatma)
	if Config.AntiBullet then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function()
					part.CanQuery = false
					part.CanTouch = false
				end)
			end
		end
	end

	-- Noclip
	if Config.Noclip or Config.Fly then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function()
					part.CanCollide = false
				end)
			end
		end
	end

	-- Fly / Car Fly
	local activeFlyPart = nil
	local activeSpeed = Config.FlySpeed

	if Config.CarFly then
		local seatPart = getSeatVehiclePart()
		if seatPart then
			activeFlyPart = seatPart
			activeSpeed = Config.CarFlySpeed
		end
	end

	if not activeFlyPart and Config.Fly then
		activeFlyPart = myRoot
		activeSpeed = Config.FlySpeed
	end

	if activeFlyPart then
		if not flyBodyGyro or flyBodyGyro.Parent ~= activeFlyPart then
			stopFlyObjects()
			flyBodyGyro = Instance.new("BodyGyro")
			flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			flyBodyGyro.P = 9e4
			flyBodyGyro.D = 500
			flyBodyGyro.Parent = activeFlyPart

			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			flyBodyVel.Velocity = Vector3.zero
			flyBodyVel.Parent = activeFlyPart
		end

		if activeFlyPart == myRoot then
			pcall(function()
				hum.PlatformStand = true
			end)
		end

		local moveDir = hum.MoveDirection
		local camCF = cam.CFrame
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			vertical = vertical + 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			vertical = vertical - 1
		end

		-- Mobil joystick ileri itildiğinde kameranın baktığı yöne doğru yükselip alçalma
		local flyVec = Vector3.zero
		if moveDir.Magnitude > 0.05 then
			local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
			local forwardAmt = 0
			if flatLook.Magnitude > 0.01 then
				forwardAmt = moveDir:Dot(flatLook.Unit)
			end
			flyVec = (moveDir * activeSpeed) + Vector3.new(0, camCF.LookVector.Y * forwardAmt * activeSpeed, 0)
		end
		if vertical ~= 0 then
			flyVec = flyVec + Vector3.new(0, vertical * activeSpeed, 0)
		end

		flyBodyGyro.CFrame = camCF
		flyBodyVel.Velocity = flyVec
	else
		if flyBodyGyro or flyBodyVel then
			stopFlyObjects()
			pcall(function()
				hum.PlatformStand = false
			end)
		end
	end
end

UserInputService.JumpRequest:Connect(function()
	if Config.InfJump then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			pcall(function()
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end
	end
end)

-- Sınırsız Mermi (Tool & Silah değişkenleri tarayıcı)
local function applyInfiniteAmmo()
	if not Config.InfAmmo then
		return
	end
	local containers = { LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack") }
	for _, container in ipairs(containers) do
		if container then
			for _, obj in ipairs(container:GetDescendants()) do
				if obj:IsA("IntValue") or obj:IsA("NumberValue") then
					local n = string.lower(obj.Name)
					if string.find(n, "ammo", 1, true)
						or string.find(n, "mag", 1, true)
						or string.find(n, "clip", 1, true)
						or string.find(n, "bullet", 1, true)
						or string.find(n, "mermi", 1, true) then
						pcall(function()
							if obj.Value < 999 then
								obj.Value = 999
							end
						end)
					end
				elseif obj:IsA("Tool") or obj:IsA("Configuration") then
					pcall(function()
						for attrName, attrVal in pairs(obj:GetAttributes()) do
							if type(attrVal) == "number" then
								local an = string.lower(attrName)
								if string.find(an, "ammo", 1, true)
									or string.find(an, "mag", 1, true)
									or string.find(an, "clip", 1, true)
									or string.find(an, "bullet", 1, true) then
									if attrVal < 999 then
										obj:SetAttribute(attrName, 999)
									end
								end
							end
						end
					end)
				end
			end
		end
	end
end

-- No Lag & Ultra Patates Modu
local function isCharacterPart(obj)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and obj:IsDescendantOf(plr.Character) then
			return true
		end
	end
	local ancestorModel = obj:FindFirstAncestorOfClass("Model")
	if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then
		return true
	end
	return false
end

local function isFloorOrSpawn(obj)
	if not obj:IsA("BasePart") then
		return false
	end
	local lower = string.lower(obj.Name)
	if string.find(lower, "baseplate", 1, true)
		or string.find(lower, "spawn", 1, true)
		or string.find(lower, "floor", 1, true)
		or string.find(lower, "ground", 1, true)
		or string.find(lower, "road", 1, true) then
		return true
	end
	if obj.Size.X >= 35 and obj.Size.Z >= 35 and obj.Size.Y <= 6 then
		return true
	end
	return false
end

local function applyNoLag()
	local count = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if count >= 600 then
			break
		end
		if not cleanedInstances[obj] then
			if obj:IsA("ParticleEmitter")
				or obj:IsA("Trail")
				or obj:IsA("Beam")
				or obj:IsA("Fire")
				or obj:IsA("Smoke")
				or obj:IsA("Sparkles") then
				cleanedInstances[obj] = true
				pcall(function()
					obj.Enabled = false
				end)
				count = count + 1
			elseif obj:IsA("Explosion") then
				cleanedInstances[obj] = true
				pcall(function()
					obj.Visible = false
				end)
				count = count + 1
			end
		end
	end
end

local function applyUltraPotato()
	applyNoLag()

	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
		Lighting.FogStart = 1e5
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(165, 165, 165)
		Lighting.OutdoorAmbient = Color3.fromRGB(175, 175, 175)
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0

		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("Atmosphere") then
				eff.Density = 0
				eff.Haze = 0
			elseif eff:IsA("BloomEffect") or eff:IsA("SunRaysEffect") or eff:IsA("BlurEffect") or eff:IsA("DepthOfFieldEffect") then
				eff.Enabled = false
			elseif eff:IsA("ColorCorrectionEffect") then
				eff.Brightness = 0
				eff.Contrast = 0
				eff.Saturation = 0
			end
		end
	end)

	pcall(function()
		local terrain = Workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterReflectance = 0
			terrain.WaterTransparency = 1
		end
	end)

	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)

	local processed = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if processed >= 550 then
			break
		end
		if not cleanedInstances[obj] then
			cleanedInstances[obj] = true
			processed = processed + 1

			if obj:IsA("BasePart") then
				pcall(function()
					obj.Material = Enum.Material.SmoothPlastic
					obj.CastShadow = false
					if obj:IsA("MeshPart") then
						obj.TextureID = ""
					end
					if not isCharacterPart(obj) and not isFloorOrSpawn(obj) then
						local lowerName = string.lower(obj.Name)
						if string.find(lowerName, "wall", 1, true)
							or string.find(lowerName, "duvar", 1, true)
							or string.find(lowerName, "decor", 1, true)
							or string.find(lowerName, "prop", 1, true)
							or string.find(lowerName, "tree", 1, true)
							or string.find(lowerName, "bush", 1, true)
							or string.find(lowerName, "foliage", 1, true) then
							obj.LocalTransparencyModifier = 1
						end
					end
				end)
			elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
	end
end

-- ESP
local function clearEsp()
	for id, bb in pairs(espList) do
		if bb then
			pcall(function()
				bb:Destroy()
			end)
		end
		espList[id] = nil
	end
end

local function getEsp(id, part, title)
	local bb = espList[id]
	if bb and bb.Adornee == part and bb.Parent then
		return bb
	end
	if bb then
		pcall(function()
			bb:Destroy()
		end)
	end

	bb = Instance.new("BillboardGui")
	bb.Adornee = part
	bb.Size = UDim2.new(0, 135, 0, 44)
	bb.StudsOffset = Vector3.new(0, 2.3, 0)
	bb.AlwaysOnTop = true
	pcall(function()
		bb.Parent = getGuiParent()
	end)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 16, 0, 16)
	box.Position = UDim2.new(0.5, -8, 0.5, 4)
	box.BackgroundTransparency = 1
	box.Parent = bb

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 55, 55)
	stroke.Thickness = 1.5
	stroke.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Lbl"
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0.2
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.Text = title
	lbl.Parent = bb

	espList[id] = bb
	return bb
end

-- Mobil Ekran Butonları
local Screen = Instance.new("ScreenGui")
Screen.Name = "SaksakMobileKeys"
Screen.ResetOnSpawn = false
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 999999
pcall(function()
	Screen.Parent = getGuiParent()
end)

local function makeFlagKey(labelText, pos, activeColor, getter, setter, onChange)
	local btn = Instance.new("TextButton")
	btn.Name = labelText
	btn.Size = UDim2.new(0, 76, 0, 40)
	btn.Position = pos
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.Active = true
	btn.Draggable = true
	btn.Visible = false
	btn.Parent = Screen
	pcall(function()
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = activeColor
		stroke.Thickness = 1.5
	end)

	local function refresh()
		local on = getter()
		btn.Text = labelText .. ": " .. (on and "ON" or "OFF")
		btn.BackgroundColor3 = on and activeColor or Color3.fromRGB(25, 25, 30)
	end

	btn.MouseButton1Click:Connect(function()
		local nextVal = not getter()
		setter(nextVal)
		if onChange then
			onChange(nextVal)
		end
		refresh()
		syncModeUI()
	end)

	table.insert(uiSetters, refresh)
	refresh()
	return btn, refresh
end

local AimBtn = makeFlagKey("AIM", UDim2.new(0.86, 0, 0.55, 0), Color3.fromRGB(45, 200, 110), function()
	return Config.AimActive
end, function(v)
	Config.AimActive = v
end)

local FlyBtn = makeFlagKey("FLY", UDim2.new(0.77, 0, 0.55, 0), Color3.fromRGB(60, 175, 255), function()
	return Config.Fly
end, function(v)
	Config.Fly = v
end)

local AuraBtn = makeFlagKey("AURA", UDim2.new(0.68, 0, 0.65, 0), Color3.fromRGB(240, 140, 35), function()
	return Config.KillAura
end, function(v)
	Config.KillAura = v
end)

local TrigBtn = makeFlagKey("TRIG", UDim2.new(0.77, 0, 0.65, 0), Color3.fromRGB(185, 80, 255), function()
	return Config.TriggerBot
end, function(v)
	Config.TriggerBot = v
end)

local TpBtn = Instance.new("TextButton")
TpBtn.Name = "TP"
TpBtn.Size = UDim2.new(0, 76, 0, 40)
TpBtn.Position = UDim2.new(0.86, 0, 0.65, 0)
TpBtn.TextColor3 = Color3.new(1, 1, 1)
TpBtn.Font = Enum.Font.GothamBold
TpBtn.TextSize = 10
TpBtn.Text = "TP"
TpBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 240)
TpBtn.Active = true
TpBtn.Draggable = true
TpBtn.Visible = false
TpBtn.Parent = Screen
pcall(function()
	Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 8)
	local tpStroke = Instance.new("UIStroke", TpBtn)
	tpStroke.Color = Color3.fromRGB(110, 190, 255)
	tpStroke.Thickness = 1.5
end)
TpBtn.MouseButton1Click:Connect(function()
	teleportToPlayerName(Config.SelectedTpPlayer)
end)

local NearestTpBtn = Instance.new("TextButton")
NearestTpBtn.Name = "E-TP"
NearestTpBtn.Size = UDim2.new(0, 76, 0, 40)
NearestTpBtn.Position = UDim2.new(0.86, 0, 0.75, 0)
NearestTpBtn.TextColor3 = Color3.new(1, 1, 1)
NearestTpBtn.Font = Enum.Font.GothamBold
NearestTpBtn.TextSize = 10
NearestTpBtn.Text = "E-TP"
NearestTpBtn.BackgroundColor3 = Color3.fromRGB(20, 175, 165)
NearestTpBtn.Active = true
NearestTpBtn.Draggable = true
NearestTpBtn.Visible = false
NearestTpBtn.Parent = Screen
pcall(function()
	Instance.new("UICorner", NearestTpBtn).CornerRadius = UDim.new(0, 8)
	local eTpStroke = Instance.new("UIStroke", NearestTpBtn)
	eTpStroke.Color = Color3.fromRGB(110, 240, 225)
	eTpStroke.Thickness = 1.5
end)
NearestTpBtn.MouseButton1Click:Connect(function()
	teleportToNearestTarget()
end)

-- Hedef Parça & Görünürlük Kontrolleri
local function isValidPart(part, model)
	if not part or not part:IsA("BasePart") or not part.Parent then
		return false
	end
	if not isAliveCharacter(model) then
		return false
	end
	return true
end

local function getAimPart(char)
	if not isAliveCharacter(char) then
		return nil
	end
	local chosen = char:FindFirstChild(Config.Part)
	if chosen and chosen:IsA("BasePart") then
		return chosen
	end
	return char:FindFirstChild("Head")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChildWhichIsA("BasePart")
end

local function getCandidateParts(model)
	local parts = {}
	if not isAliveCharacter(model) then
		return parts
	end

	local preferred = getAimPart(model)
	if isValidPart(preferred, model) then
		table.insert(parts, preferred)
	end

	local partOrder = {
		"Head",
		"HumanoidRootPart",
		"UpperTorso",
		"LowerTorso",
		"Torso",
		"LeftUpperArm",
		"RightUpperArm",
		"LeftLowerArm",
		"RightLowerArm",
		"LeftUpperLeg",
		"RightUpperLeg",
		"LeftLowerLeg",
		"RightLowerLeg",
		"Left Arm",
		"Right Arm",
		"Left Leg",
		"Right Leg"
	}

	for _, name in ipairs(partOrder) do
		local p = model:FindFirstChild(name)
		if isValidPart(p, model) and p ~= preferred then
			table.insert(parts, p)
		end
	end

	if #parts == 0 then
		for _, d in ipairs(model:GetDescendants()) do
			if isValidPart(d, model) then
				table.insert(parts, d)
				break
			end
		end
	end

	return parts
end

local function isGlassOrPassable(instance)
	if not instance or not instance:IsA("BasePart") then
		return true
	end
	if instance.Material == Enum.Material.Glass then
		return true
	end
	if instance.CanCollide == false and instance.Transparency >= 0.35 then
		return true
	end
	local lowerName = string.lower(instance.Name)
	if string.find(lowerName, "glass", 1, true)
		or string.find(lowerName, "cam", 1, true)
		or string.find(lowerName, "window", 1, true) then
		if instance.Transparency >= 0.25 then
			return true
		end
	end
	return false
end

local function findVisiblePart(cam, target)
	if not cam or not target or not isAliveCharacter(target.model) then
		return nil
	end
	if not isValidPart(target.part, target.model) then
		return nil
	end

	local origin = cam.CFrame.Position
	local candidates = getCandidateParts(target.model)

	for _, part in ipairs(candidates) do
		local toPart = part.Position - origin
		local dist = toPart.Magnitude
		if dist > 2.5 and dist <= Config.AimMaxDist then
			local excludeList = {}
			if LocalPlayer.Character then
				table.insert(excludeList, LocalPlayer.Character)
			end

			local blocked = false
			local dirUnit = toPart.Unit

			for _ = 1, 6 do
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = excludeList
				params.IgnoreWater = true

				local hit = Workspace:Raycast(origin, dirUnit * (dist + 0.5), params)
				if not hit or not hit.Instance then
					return part
				end
				if isOwnCharacter(hit.Instance) then
					table.insert(excludeList, hit.Instance)
				elseif hit.Instance:IsDescendantOf(target.model) then
					return part
				elseif isGlassOrPassable(hit.Instance) then
					table.insert(excludeList, hit.Instance)
				else
					blocked = true
					break
				end
			end

			if not blocked then
				return part
			end
		end
	end

	return nil
end

local function scanTargets()
	local list = {}
	local added = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			if isAliveCharacter(char) then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local part = getAimPart(char)
				if hum and isValidPart(part, char) then
					added[char] = true
					local hpPct = hum.MaxHealth > 0 and math.clamp(math.floor((hum.Health / hum.MaxHealth) * 100), 0, 100) or 100
					table.insert(list, {
						id = "plr_" .. tostring(plr.UserId),
						name = plr.DisplayName,
						hpPct = hpPct,
						model = char,
						part = part,
						isPlayer = true,
						player = plr
					})
				end
			end
		end
	end

	local npcCount = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if npcCount >= 120 then
			break
		end
		if obj:IsA("Model") and not added[obj] and not Players:GetPlayerFromCharacter(obj) and isAliveCharacter(obj) then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local part = getAimPart(obj)
			if hum and isValidPart(part, obj) then
				added[obj] = true
				npcCount = npcCount + 1
				local hpPct = hum.MaxHealth > 0 and math.clamp(math.floor((hum.Health / hum.MaxHealth) * 100), 0, 100) or 100
				table.insert(list, {
					id = "npc_" .. tostring(obj:GetDebugId()),
					name = "[BOT] " .. obj.Name,
					hpPct = hpPct,
					model = obj,
					part = part,
					isPlayer = false,
					player = nil
				})
			end
		end
	end

	return list
end

local function lockCam(part, model)
	local cam = Workspace.CurrentCamera
	local myRoot = getMyRoot()
	if not cam or not myRoot then
		return
	end
	if not isValidPart(part, model) then
		return
	end

	local vel = part.AssemblyLinearVelocity or Vector3.zero
	local targetPos = part.Position + (vel * Config.AimPrediction)
	local camPos = cam.CFrame.Position
	local dist = (targetPos - camPos).Magnitude
	if dist <= 2.5 or dist > Config.AimMaxDist then
		return
	end

	if targetPos.Y < (myRoot.Position.Y - 4.5) then
		return
	end

	pcall(function()
		if cam.CameraType == Enum.CameraType.Scriptable then
			cam.CameraType = Enum.CameraType.Custom
		end
		local goal = CFrame.lookAt(camPos, targetPos)
		cam.CFrame = Config.Smooth >= 0.99 and goal or cam.CFrame:Lerp(goal, Config.Smooth)
	end)
end

local function activateEquippedTool()
	local char = LocalPlayer.Character
	if not char then
		return
	end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool.Parent == char then
		pcall(function()
			tool:Activate()
		end)
	end
end

local function applyNoRecoil(cam, activeAimPart)
	if not Config.NoRecoil or not cam or activeAimPart then
		prevCamLook = cam and cam.CFrame.LookVector or nil
		return
	end

	local currentLook = cam.CFrame.LookVector
	if prevCamLook then
		local dy = currentLook.Y - prevCamLook.Y
		local dx = currentLook.X - prevCamLook.X
		if dy > 0.008 or math.abs(dx) > 0.014 then
			local correctedLook = Vector3.new(
				currentLook.X - (dx * 0.55),
				prevCamLook.Y + (dy * 0.2),
				currentLook.Z
			).Unit
			local pos = cam.CFrame.Position
			cam.CFrame = CFrame.new(pos, pos + correctedLook)
			currentLook = cam.CFrame.LookVector
		end
	end
	prevCamLook = currentLook
end

local function isTargetUnderCenter(cam, targets)
	local origin = cam.CFrame.Position
	local dir = cam.CFrame.LookVector * Config.AimMaxDist
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	if LocalPlayer.Character then
		params.FilterDescendantsInstances = {LocalPlayer.Character}
	end
	params.IgnoreWater = true

	local result = Workspace:Raycast(origin, dir, params)
	if not result or not result.Instance or isOwnCharacter(result.Instance) then
		return false
	end

	for _, t in ipairs(targets) do
		if isAliveCharacter(t.model)
			and not isTeammateTarget(t)
			and result.Instance:IsDescendantOf(t.model) then
			return true
		end
	end
	return false
end

local function loadRayfieldSafe()
	local urls = {
		"https://sirius.menu/rayfield",
		"https://raw.githubusercontent.com/shlexware/Rayfield/main/source"
	}
	for _, url in ipairs(urls) do
		local okCode, code = pcall(function()
			return game:HttpGet(url)
		end)
		if okCode and type(code) == "string" and #code > 100 then
			local okFn, fn = pcall(loadstring, code)
			if okFn and type(fn) == "function" then
				local okLib, lib = pcall(fn)
				if okLib and type(lib) == "table" and lib.CreateWindow then
					return lib
				end
			end
		end
	end
	return nil
end

-- Ana Döngü
RunService.RenderStepped:Connect(function()
	pcall(function()
		AimBtn.Visible = Config.ShowAimBtn
		FlyBtn.Visible = Config.ShowFlyBtn
		TpBtn.Visible = Config.ShowTpBtn
		NearestTpBtn.Visible = Config.ShowNearestTpBtn
		AuraBtn.Visible = Config.ShowAuraBtn
		TrigBtn.Visible = Config.ShowTrigBtn
	end)

	updateFlyAndMovement()

	local cam = Workspace.CurrentCamera
	local myRoot = getMyRoot()
	if not cam or not myRoot then
		return
	end

	local now = os.clock()
	if now - lastScanTime >= 0.2 then
		lastScanTime = now
		pcall(function()
			cachedTargets = scanTargets()
		end)
	end

	if now - lastAmmoTime >= 0.35 then
		lastAmmoTime = now
		pcall(applyInfiniteAmmo)
	end

	if now - lastOptTime >= 1.5 then
		lastOptTime = now
		pcall(function()
			if Config.UltraPotato then
				applyUltraPotato()
			elseif Config.NoLag then
				applyNoLag()
			end
		end)
	end

	local chosenPart = nil
	local chosenModel = nil
	local bestStuds = Config.AimMaxDist
	local auraPart = nil
	local auraStuds = Config.AuraRange
	local seen = {}

	for _, t in ipairs(cachedTargets) do
		if isValidPart(t.part, t.model) then
			local studs = (t.part.Position - myRoot.Position).Magnitude
			local teammate = isTeammateTarget(t)

			if Config.Esp and studs <= Config.MaxEspStuds then
				seen[t.id] = true
				pcall(function()
					local bb = getEsp(t.id, t.part, t.name)
					local lbl = bb and bb:FindFirstChild("Lbl")
					if lbl then
						local tag = teammate and " [TAKIM]" or ""
						lbl.Text = t.name .. tag .. " [" .. tostring(t.hpPct or 100) .. "%] [" .. math.floor(studs) .. "s]"
					end
				end)
			end

			local aimModeOk = true
			if Config.AimTargetMode == "Gerçek Oyuncular" then
				aimModeOk = (t.isPlayer == true)
			elseif Config.AimTargetMode == "Botlar" then
				aimModeOk = (t.isPlayer == false)
			end

			if Config.AimActive and aimModeOk and not teammate and studs > 2.5 and studs <= bestStuds then
				local visPart = findVisiblePart(cam, t)
				if visPart then
					bestStuds = studs
					chosenPart = visPart
					chosenModel = t.model
				end
			end

			if Config.KillAura and not teammate and studs > 1.5 and studs <= auraStuds then
				auraStuds = studs
				auraPart = t.part
			end
		end
	end

	if not Config.Esp then
		if next(espList) then
			clearEsp()
		end
	else
		for id, bb in pairs(espList) do
			if not seen[id] then
				pcall(function()
					bb:Destroy()
				end)
				espList[id] = nil
			end
		end
	end

	if Config.AimActive and chosenPart and chosenModel then
		lockCam(chosenPart, chosenModel)
	end

	pcall(function()
		applyNoRecoil(cam, Config.AimActive and chosenPart or nil)
	end)

	pcall(function()
		if Config.KillAura and auraPart then
			local rootPos = myRoot.Position
			local lookGoal = CFrame.lookAt(rootPos, Vector3.new(auraPart.Position.X, rootPos.Y, auraPart.Position.Z))
			myRoot.CFrame = myRoot.CFrame:Lerp(lookGoal, 0.55)
			if now - lastSwingTime >= Config.SwingDelay then
				lastSwingTime = now
				activateEquippedTool()
			end
		elseif Config.AutoSwing and (now - lastSwingTime >= Config.SwingDelay) then
			lastSwingTime = now
			activateEquippedTool()
		end

		if Config.TriggerBot and (now - lastTriggerTime >= 0.06) then
			if isTargetUnderCenter(cam, cachedTargets) then
				lastTriggerTime = now
				activateEquippedTool()
			end
		end
	end)
end)

-- Rayfield Menü
task.spawn(function()
	if not game:IsLoaded() then
		pcall(function()
			game.Loaded:Wait()
		end)
	end
	LocalPlayer:WaitForChild("PlayerGui", 5)
	task.wait(0.25)

	local Rayfield = loadRayfieldSafe()
	if not Rayfield then
		return
	end

	local Win = Rayfield:CreateWindow({
		Name = "Saksak Hub",
		ConfigurationSaving = { Enabled = false },
		KeySystem = false
	})

	-- 1. ANA SEKME (ESP & AIMBOT)
	local Main = Win:CreateTab("Ana", 4483362458)
	Main:CreateToggle({
		Name = "ESP",
		CurrentValue = false,
		Callback = function(v)
			Config.Esp = v
			if not v then
				clearEsp()
			end
		end
	})

	local tAim = Main:CreateToggle({
		Name = "Aimbot (Sadece Yaşayan Düşman)",
		CurrentValue = false,
		Callback = function(v)
			if isSyncingUI then
				return
			end
			Config.AimActive = v
			syncModeUI()
		end
	})
	table.insert(uiSetters, function()
		pcall(function()
			tAim:Set(Config.AimActive)
		end)
	end)

	Main:CreateToggle({
		Name = "Takım Kontrolü (Aimbot Team Check)",
		CurrentValue = true,
		Callback = function(v)
			Config.TeamCheck = v
		end
	})

	Main:CreateSlider({
		Name = "Aimbot Kilitlenme Hızı",
		Range = {5, 100},
		Increment = 5,
		Suffix = "%",
		CurrentValue = 100,
		Callback = function(v)
			Config.Smooth = v / 100
		end
	})

	Main:CreateSlider({
		Name = "Aimbot Maksimum Uzaklık",
		Range = {30, 1500},
		Increment = 10,
		Suffix = "s",
		CurrentValue = 350,
		Callback = function(v)
			Config.AimMaxDist = v
		end
	})

	Main:CreateSlider({
		Name = "Aimbot Hareket Tahmini",
		Range = {0, 35},
		Increment = 1,
		Suffix = "x0.01",
		CurrentValue = 12,
		Callback = function(v)
			Config.AimPrediction = v / 100
		end
	})

	Main:CreateDropdown({
		Name = "Hedef Parça",
		Options = {"Head", "HumanoidRootPart"},
		CurrentOption = {"Head"},
		MultipleOptions = false,
		Callback = function(opt)
			Config.Part = opt and opt[1] or "Head"
		end
	})

	Main:CreateDropdown({
		Name = "Aimbot Hedef Türü",
		Options = {"Hepsi", "Gerçek Oyuncular", "Botlar"},
		CurrentOption = {"Hepsi"},
		MultipleOptions = false,
		Callback = function(opt)
			Config.AimTargetMode = opt and opt[1] or "Hepsi"
		end
	})

	-- 2. SAVAŞ SEKMESİ
	local Combat = Win:CreateTab("Savaş", 4483362458)
	Combat:CreateToggle({
		Name = "No Recoil (Sekmeme)",
		CurrentValue = false,
		Callback = function(v)
			Config.NoRecoil = v
		end
	})
	Combat:CreateToggle({
		Name = "Trigger Bot (Crosshair Oto Sıkma)",
		CurrentValue = false,
		Callback = function(v)
			Config.TriggerBot = v
		end
	})
	Combat:CreateToggle({
		Name = "Sınırsız Mermi (Inf Ammo)",
		CurrentValue = false,
		Callback = function(v)
			Config.InfAmmo = v
			if v then
				applyInfiniteAmmo()
			end
		end
	})
	Combat:CreateToggle({
		Name = "Kill Aura",
		CurrentValue = false,
		Callback = function(v)
			Config.KillAura = v
		end
	})
	Combat:CreateSlider({
		Name = "Kill Aura Menzili",
		Range = {5, 50},
		Increment = 1,
		Suffix = "s",
		CurrentValue = 18,
		Callback = function(v)
			Config.AuraRange = v
		end
	})
	Combat:CreateToggle({
		Name = "Auto Swing",
		CurrentValue = false,
		Callback = function(v)
			Config.AutoSwing = v
		end
	})
	Combat:CreateSlider({
		Name = "Saldırı Hızı (Gecikme)",
		Range = {5, 60},
		Increment = 5,
		Suffix = "ms x10",
		CurrentValue = 12,
		Callback = function(v)
			Config.SwingDelay = v / 100
		end
	})

	-- 3. KARAKTER SEKMESİ
	local PlayerTab = Win:CreateTab("Karakter", 4483362458)
	local tFly = PlayerTab:CreateToggle({
		Name = "Fly (Uçma)",
		CurrentValue = false,
		Callback = function(v)
			if isSyncingUI then
				return
			end
			Config.Fly = v
			syncModeUI()
		end
	})
	table.insert(uiSetters, function()
		pcall(function()
			tFly:Set(Config.Fly)
		end)
	end)

	PlayerTab:CreateSlider({
		Name = "Fly Hızı",
		Range = {15, 250},
		Increment = 5,
		CurrentValue = 60,
		Callback = function(v)
			Config.FlySpeed = v
		end
	})

	PlayerTab:CreateToggle({
		Name = "Car Fly (Araç Uçurma)",
		CurrentValue = false,
		Callback = function(v)
			Config.CarFly = v
		end
	})

	PlayerTab:CreateSlider({
		Name = "Car Fly Hızı",
		Range = {20, 350},
		Increment = 5,
		CurrentValue = 90,
		Callback = function(v)
			Config.CarFlySpeed = v
		end
	})

	PlayerTab:CreateToggle({
		Name = "Hız & Zıplama Aktif",
		CurrentValue = false,
		Callback = function(v)
			Config.SpeedJumpEnabled = v
			if not v then
				local char = LocalPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then
					pcall(function()
						hum.WalkSpeed = 16
						hum.JumpPower = 50
					end)
				end
			end
		end
	})

	PlayerTab:CreateSlider({
		Name = "Yürüme Hızı (Speed)",
		Range = {16, 200},
		Increment = 2,
		CurrentValue = 16,
		Callback = function(v)
			Config.WalkSpeed = v
		end
	})

	PlayerTab:CreateSlider({
		Name = "Zıplama Gücü (Jump)",
		Range = {50, 250},
		Increment = 5,
		CurrentValue = 50,
		Callback = function(v)
			Config.JumpPower = v
		end
	})

	PlayerTab:CreateToggle({
		Name = "Havada Sınırsız Zıplama (Inf Jump)",
		CurrentValue = false,
		Callback = function(v)
			Config.InfJump = v
		end
	})

	PlayerTab:CreateToggle({
		Name = "God Mode (Ölümsüzlük)",
		CurrentValue = false,
		Callback = function(v)
			Config.GodMode = v
		end
	})

	PlayerTab:CreateToggle({
		Name = "Mermiler İçimden Geçsin (Anti-Hitbox)",
		CurrentValue = false,
		Callback = function(v)
			Config.AntiBullet = v
			if not v then
				local char = LocalPlayer.Character
				if char then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function()
								part.CanQuery = true
								part.CanTouch = true
							end)
						end
					end
				end
			end
		end
	})

	PlayerTab:CreateToggle({
		Name = "Noclip (Duvarlardan Geçme)",
		CurrentValue = false,
		Callback = function(v)
			Config.Noclip = v
		end
	})

	-- 4. TUŞLAR SEKMESİ
	local Keys = Win:CreateTab("Tuşlar", 4483362458)
	Keys:CreateToggle({
		Name = "AIM Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowAimBtn = v
		end
	})
	Keys:CreateToggle({
		Name = "FLY Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowFlyBtn = v
		end
	})
	Keys:CreateToggle({
		Name = "TP Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowTpBtn = v
		end
	})
	Keys:CreateToggle({
		Name = "E-TP Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowNearestTpBtn = v
		end
	})
	Keys:CreateToggle({
		Name = "AURA Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowAuraBtn = v
		end
	})
	Keys:CreateToggle({
		Name = "TRIG Tuşunu Göster/Gizle",
		CurrentValue = false,
		Callback = function(v)
			Config.ShowTrigBtn = v
		end
	})

	-- 5. EKSTRA SEKMESİ
	local Extra = Win:CreateTab("Ekstra", 4483362458)
	Extra:CreateDropdown({
		Name = "E-TP Hedef Türü",
		Options = {"Hepsi", "Oyuncular", "Bot"},
		CurrentOption = {"Hepsi"},
		MultipleOptions = false,
		Callback = function(opt)
			Config.NearestTpMode = opt and opt[1] or "Hepsi"
		end
	})
	Extra:CreateSlider({
		Name = "ESP Maksimum Mesafe",
		Range = {50, 2000},
		Increment = 50,
		Suffix = "s",
		CurrentValue = 500,
		Callback = function(v)
			Config.MaxEspStuds = v
		end
	})

	local initPlayers = getPlayerNamesList()
	Config.SelectedTpPlayer = initPlayers[1]

	tpDropdownRef = Extra:CreateDropdown({
		Name = "Oyuncu Seç",
		Options = initPlayers,
		CurrentOption = { initPlayers[1] },
		MultipleOptions = false,
		Callback = function(opt)
			Config.SelectedTpPlayer = opt and opt[1] or nil
		end
	})

	Extra:CreateButton({
		Name = "Teleport",
		Callback = function()
			teleportToPlayerName(Config.SelectedTpPlayer)
		end
	})

	Extra:CreateToggle({
		Name = "No Lag",
		CurrentValue = false,
		Callback = function(v)
			Config.NoLag = v
			if v then
				applyNoLag()
			end
		end
	})
	Extra:CreateToggle({
		Name = "Ultra Patates Modu",
		CurrentValue = false,
		Callback = function(v)
			Config.UltraPotato = v
			if v then
				applyUltraPotato()
			end
		end
	})
end)
