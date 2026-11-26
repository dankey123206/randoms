--[[
    saksak.lua  -  Camera & Character Test Panel (Luau)

    KURULUM
      * Kendi oyununda StarterPlayer > StarterPlayerScripts altina bir LocalScript olarak koy.
      * Panel sadece yetkili kullanicilarda acilir (asagidaki CONFIG.IsAuthorized):
        Studio, oyun sahibi (kullanici/grup), veya CONFIG.AllowedUserIds listesi.
      * Menu tusu: RightShift (Misc sekmesinden degistirilebilir). Mobilde sol ortadaki "S" butonu.

    SILAH AYARLARI (Combat & Weapon)
      Silah sisteminin kendisi oyuna ozel oldugu icin bu panel, Tool uzerindeki Attribute / NumberValue
      degerlerini gecici olarak degistirir. Desteklenen isimler asagida RULES tablosunda.
      Ayrica LocalPlayer uzerine "dbg_<Ayar>" attribute'lari yazilir; kendi silah scriptin bunlari
      okuyabilir (ornek: LocalPlayer:GetAttribute("dbg_NoRecoil")).

    NOT: Ayni anda en fazla ~31 Highlight render edilir (Roblox limiti).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local CONFIG = {
	AllowedUserIds = {}, -- ornek: {123456789}
	ItemTag = "Item",
	LootTag = "Loot",
	DoorTag = "Door",
	ObjectTag = "Object",
	SafeZoneTag = "SafeZone",
	RespawnRemoteName = "RequestRespawn", -- ReplicatedStorage icindeki RemoteEvent (opsiyonel)
	RespawnDelay = 2,
	AFKSeconds = 15,
	BaseWalkSpeed = 16,
	HitSoundId = "rbxasset://sounds/electronicpingshort.wav",
	KillSoundId = "rbxasset://sounds/snap.mp3",
}

local function isAuthorized()
	if RunService:IsStudio() then
		return true
	end
	if table.find(CONFIG.AllowedUserIds, LocalPlayer.UserId) then
		return true
	end
	if game.CreatorType == Enum.CreatorType.User and game.CreatorId == LocalPlayer.UserId then
		return true
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function()
			return LocalPlayer:GetRankInGroup(game.CreatorId)
		end)
		if ok and rank >= 255 then
			return true
		end
	end
	return false
end

if not isAuthorized() then
	return
end

----------------------------------------------------------------------
-- DEFAULTS / STATE
----------------------------------------------------------------------
local DEFAULTS = {
	-- Aim & Targeting
	CameraAim = false, AimSmooth = 0.5, AimHold = true, FOVCircle = true, FOVRadius = 150,
	AimPart = "Head", NearestTarget = true, TargetSwitch = true, LOSCheck = false,
	TeamCheck = true, FriendCheck = false, AliveCheck = true, KnockedCheck = false,
	-- Visuals & ESP
	ESPColor = "Red", ESPDistance = 1500,
	PlayerHighlight = false, BoundingBox = false, Skeleton = false, NameTag = false, HealthTag = false,
	DistanceTag = false, Tracer = false, Box2D = false, Box3D = false, HeadMarker = false,
	Snaplines = false, Chams = false, Glow = false, ItemMarker = false, WeaponMarker = false,
	EnemyOnly = false, VisibleOnly = false,
	-- Movement
	WalkSpeedOn = false, WalkSpeed = 32, FlyOn = false, FlySpeed = 60, InfJump = false, NoClip = false,
	ClickTP = false, JumpPowerOn = false, JumpPower = 70, NoSlow = false, AirWalk = false,
	GravityOn = false, Gravity = 196, SpinOn = false, SpinSpeed = 360, BunnyHop = false, AntiFall = false,
	-- Combat & Weapon
	NoRecoil = false, NoSpread = false, RapidFire = false, FastReload = false, InfiniteAmmo = false,
	NoReload = false, DamageScale = 1, HitboxScale = 1, MeleeRange = 1, AutoAction = false, AutoInterval = 0.1,
	-- Filters & Checks
	EnemyCheck = false, DeadCheck = false, ObstacleCheck = false, DistanceCheck = false,
	HealthCheck = false, HealthMin = 20, NPCCheck = true, BotCheck = false, AFKCheck = false,
	SafeZoneCheck = false, FOVCheck = false, VehicleCheck = false,
	-- Misc & System
	YawOffset = 0, NetworkDelay = 0, StateOffset = 0, HitAudio = false, KillAudio = false,
	HitIndicator = false, Crosshair = false, CrosshairSize = 8, CameraFOVOn = false, CameraFOV = 70,
	FrameRate = false, AutoRespawn = false, Spectate = false,
	-- Character & World
	CharacterVisual = false, HeadVisual = false, BodyVisual = false, HandVisual = false, LegVisual = false,
	OutfitInfo = false, AvatarInfo = false, WorldVisual = false, ObjectVisual = false, DoorVisual = false,
	LootVisual = false, WeaponSearch = "", ItemSearch = "", Radar = false, Minimap = false, RadarRange = 150,
	Fullbright = false, NoFog = false, NightVision = false,
	-- Target Selection
	PriorityMode = "Crosshair", MaxDistance = 1000, TeamMode = "All", VisibilityMode = "Any",
	HealthMode = "Any", BehaviorMode = "Any", FilterMode = "Off",
	IgnoreList = "", Whitelist = "", Blacklist = "", SelectedPlayer = "Auto",
}

local DEFAULT_BINDS = {
	MenuKey = "RightShift", AimKey = "MouseButton2", TeleKey = "T",
	CameraAim = "V", FlyOn = "F", NoClip = "N", InfJump = "J", ClickTP = "", WalkSpeedOn = "",
	SpinOn = "", AirWalk = "", AutoAction = "", Spectate = "H", Fullbright = "B", Radar = "",
	Crosshair = "", Box2D = "", PlayerHighlight = "", Chams = "", NightVision = "",
}

local S, B = {}, {}
for k, v in pairs(DEFAULTS) do S[k] = v end
for k, v in pairs(DEFAULT_BINDS) do B[k] = v end

----------------------------------------------------------------------
-- GUI ROOTS
----------------------------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
for _, n in ipairs({ "saksak_ui", "saksak_overlay", "saksak_world" }) do
	local old = PlayerGui:FindFirstChild(n)
	if old then old:Destroy() end
end

local function mk(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
	inst.Parent = parent
	return inst
end

local function corner(inst, r)
	return mk("UICorner", { CornerRadius = UDim.new(0, r or 6) }, inst)
end

local Overlay = mk("ScreenGui", {
	Name = "saksak_overlay", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
local World3D = mk("Folder", { Name = "saksak_world" }, PlayerGui)
local UIGui = mk("ScreenGui", {
	Name = "saksak_ui", ResetOnSpawn = false, DisplayOrder = 100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local C = {
	bg = Color3.fromRGB(20, 20, 26), panel = Color3.fromRGB(30, 30, 38), row = Color3.fromRGB(38, 38, 48),
	accent = Color3.fromRGB(124, 92, 255), off = Color3.fromRGB(70, 70, 84),
	text = Color3.fromRGB(235, 235, 245), muted = Color3.fromRGB(150, 150, 168),
}
local WHITE = Color3.new(1, 1, 1)

----------------------------------------------------------------------
-- SETTINGS PLUMBING
----------------------------------------------------------------------
local Refs, BindRefs, ToggleKeys = {}, {}, {}
local markDirty = false
local WORLD_KEYS = {
	ItemMarker = true, WeaponMarker = true, LootVisual = true, DoorVisual = true,
	ObjectVisual = true, WeaponSearch = true, ItemSearch = true,
}

local function addRef(key, fn)
	Refs[key] = Refs[key] or {}
	table.insert(Refs[key], fn)
end

local function setting(key, value)
	S[key] = value
	if WORLD_KEYS[key] then markDirty = true end
	local list = Refs[key]
	if list then
		for _, fn in ipairs(list) do fn(value) end
	end
end

local function setBind(key, name)
	B[key] = name
	local list = BindRefs[key]
	if list then
		for _, fn in ipairs(list) do fn() end
	end
end

local UI = { notify = function(_) end }
local currentTarget = nil
local lastShot = 0

----------------------------------------------------------------------
-- CORE HELPERS
----------------------------------------------------------------------
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function getHum()
	local c = LocalPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
	local c = LocalPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid(model)
	return model and model:FindFirstChildOfClass("Humanoid")
end

local function bindHeld(name)
	if not name or name == "" then return false end
	if name == "MouseButton1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
	if name == "MouseButton2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
	if name == "MouseButton3" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
	local ok, kc = pcall(function() return Enum.KeyCode[name] end)
	return ok and kc ~= nil and UserInputService:IsKeyDown(kc)
end

local listCache = {}
local function parseList(str)
	if not str or str == "" then return nil end
	local c = listCache[str]
	if c then return c end
	c = {}
	for name in string.gmatch(str, "[^,;%s]+") do c[string.lower(name)] = true end
	listCache[str] = c
	return c
end
local function inList(list, e)
	if not list then return false end
	if list[string.lower(e.Name)] then return true end
	return e.Player ~= nil and list[string.lower(e.Player.DisplayName)] == true
end

local function sameTeam(plr)
	return plr ~= nil and LocalPlayer.Team ~= nil and LocalPlayer.Team == plr.Team
end

local FriendCache = {}
local function isFriend(p)
	local c = FriendCache[p.UserId]
	if c == nil then
		FriendCache[p.UserId] = false
		task.spawn(function()
			local ok, r = pcall(function() return LocalPlayer:IsFriendsWith(p.UserId) end)
			FriendCache[p.UserId] = (ok and r) or false
		end)
		return false
	end
	return c
end

local KNOCK_NAMES = { "Knocked", "Downed", "KO", "IsKnocked", "Ragdoll" }
local function isKnocked(model, hum)
	for _, n in ipairs(KNOCK_NAMES) do
		if model:GetAttribute(n) == true or hum:GetAttribute(n) == true then return true end
		local v = model:FindFirstChild(n)
		if v and v:IsA("BoolValue") and v.Value then return true end
	end
	return false
end

local function isBot(e)
	return e.Model:GetAttribute("Bot") == true or e.Model:GetAttribute("IsBot") == true
		or string.find(string.lower(e.Name), "^bot") ~= nil
end

local AFKTrack = setmetatable({}, { __mode = "k" })
local function isAFK(model)
	local rec = AFKTrack[model]
	return rec ~= nil and os.clock() - rec.t > CONFIG.AFKSeconds
end

local function inSafeZone(model, root)
	if model:FindFirstChildOfClass("ForceField") then return true end
	if model:GetAttribute("SafeZone") == true or model:GetAttribute("InSafeZone") == true then return true end
	for _, z in ipairs(CollectionService:GetTagged(CONFIG.SafeZoneTag)) do
		if z:IsA("BasePart") then
			local rel = z.CFrame:PointToObjectSpace(root.Position)
			local h = z.Size * 0.5
			if math.abs(rel.X) <= h.X and math.abs(rel.Y) <= h.Y and math.abs(rel.Z) <= h.Z then
				return true
			end
		end
	end
	return false
end

-- Hedef listesi: oyuncular (+ NPCCheck kapaliysa NPC'ler)
local npcCache, npcTick = {}, 0
local function getTargets()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			table.insert(list, { Name = p.Name, Model = p.Character, Player = p })
		end
	end
	if not S.NPCCheck then
		if os.clock() - npcTick > 3 then
			npcTick = os.clock()
			npcCache = {}
			for _, d in ipairs(Workspace:GetDescendants()) do
				if d:IsA("Humanoid") then
					local m = d.Parent
					if m and m:IsA("Model") and not Players:GetPlayerFromCharacter(m) and m ~= LocalPlayer.Character then
						table.insert(npcCache, { Name = m.Name, Model = m, Player = nil })
					end
				end
			end
		end
		for _, e in ipairs(npcCache) do
			if e.Model.Parent then table.insert(list, e) end
		end
	end
	return list
end

local function isObstructed(part, model, obstacleOnly)
	local cam = Workspace.CurrentCamera
	local origin = cam.CFrame.Position
	local ignore = { model }
	if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
	local dir = part.Position - origin
	for _ = 1, 6 do
		rayParams.FilterDescendantsInstances = ignore
		local r = Workspace:Raycast(origin, dir, rayParams)
		if not r then return false end
		local inst = r.Instance
		if obstacleOnly and (inst.Transparency >= 0.9 or not inst.CanCollide) then
			table.insert(ignore, inst)
		else
			return true
		end
	end
	return true
end

local TORSO = { "UpperTorso", "Torso", "HumanoidRootPart" }
local ALL_PARTS = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm",
	"LeftUpperLeg", "RightUpperLeg", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local function getAimPart(model)
	local mode = S.AimPart
	if mode == "Head" then
		return model:FindFirstChild("Head")
	elseif mode == "Torso" then
		for _, n in ipairs(TORSO) do
			local p = model:FindFirstChild(n)
			if p then return p end
		end
		return nil
	elseif mode == "HumanoidRootPart" then
		return model:FindFirstChild("HumanoidRootPart")
	end
	local cam = Workspace.CurrentCamera
	local mp = UserInputService:GetMouseLocation()
	local best, bd
	for _, n in ipairs(ALL_PARTS) do
		local p = model:FindFirstChild(n)
		if p then
			local v, on = cam:WorldToViewportPoint(p.Position)
			if on then
				local d = (Vector2.new(v.X, v.Y) - mp).Magnitude
				if not bd or d < bd then bd, best = d, p end
			end
		end
	end
	return best
end

-- Genel filtreler (hem aim hem ESP)
local function passesCommon(e, dist)
	local model = e.Model
	local hum = getHumanoid(model)
	local root = model:FindFirstChild("HumanoidRootPart")
	if not (hum and root) then return false end
	local cam = Workspace.CurrentCamera
	dist = dist or (root.Position - cam.CFrame.Position).Magnitude

	local alive = hum.Health > 0
	if S.AliveCheck and not alive then return false end
	if S.DeadCheck and alive then return false end -- DeadCheck: SADECE olu hedefler (test icin)

	local mate = e.Player ~= nil and sameTeam(e.Player)
	local friend = e.Player ~= nil and isFriend(e.Player)
	if (S.TeamCheck or S.EnemyCheck) and mate then return false end
	if (S.FriendCheck or S.EnemyCheck) and friend then return false end
	if S.TeamMode == "Enemies" and mate then return false end
	if S.TeamMode == "Teammates" and not mate then return false end
	if S.KnockedCheck and isKnocked(model, hum) then return false end
	if S.BotCheck and isBot(e) then return false end
	if S.AFKCheck and isAFK(model) then return false end
	if S.SafeZoneCheck and inSafeZone(model, root) then return false end
	if S.VehicleCheck and hum.SeatPart ~= nil then return false end
	if S.DistanceCheck and dist > S.MaxDistance then return false end

	local pct = (hum.Health / math.max(hum.MaxHealth, 1)) * 100
	if S.HealthCheck and pct < S.HealthMin then return false end
	if S.HealthMode == "Low (<50%)" and pct >= 50 then return false end
	if S.HealthMode == "High (>=50%)" and pct < 50 then return false end

	local moving = root.AssemblyLinearVelocity.Magnitude > 2
	if S.BehaviorMode == "Moving" and not moving then return false end
	if S.BehaviorMode == "Stationary" and moving then return false end

	if inList(parseList(S.IgnoreList), e) then return false end
	if S.FilterMode == "Whitelist" then
		local wl = parseList(S.Whitelist)
		if wl and not inList(wl, e) then return false end
	elseif S.FilterMode == "Blacklist" then
		if inList(parseList(S.Blacklist), e) then return false end
	end
	return true
end

local function passesPart(e, part)
	local obs
	local function getObs()
		if obs == nil then obs = isObstructed(part, e.Model, false) end
		return obs
	end
	if S.LOSCheck and getObs() then return false end
	if S.ObstacleCheck and isObstructed(part, e.Model, true) then return false end
	if S.VisibilityMode == "Visible Only" and getObs() then return false end
	if S.VisibilityMode == "Hidden Only" and not getObs() then return false end
	return true
end

local function pickTarget()
	local cam = Workspace.CurrentCamera
	local center = cam.ViewportSize / 2
	local best, bestScore
	for _, e in ipairs(getTargets()) do
		if S.SelectedPlayer ~= "Auto" and e.Name ~= S.SelectedPlayer then continue end
		local part = getAimPart(e.Model)
		if part and passesCommon(e) then
			local dist = (part.Position - cam.CFrame.Position).Magnitude
			if dist <= S.MaxDistance and passesPart(e, part) then
				local v, on = cam:WorldToViewportPoint(part.Position)
				local sd = (Vector2.new(v.X, v.Y) - center).Magnitude
				if S.SelectedPlayer ~= "Auto" or (on and sd <= S.FOVRadius) then
					local hum = getHumanoid(e.Model)
					local pm = S.PriorityMode
					local score
					if not S.NearestTarget then score = 0
					elseif pm == "Distance" then score = dist
					elseif pm == "Lowest Health" then score = hum.Health
					elseif pm == "Highest Health" then score = -hum.Health
					else score = sd end
					if bestScore == nil or score < bestScore then best, bestScore = e, score end
				end
			end
		end
	end
	return best
end

local function nearestEntry()
	local root = getRoot()
	local cam = Workspace.CurrentCamera
	local origin = root and root.Position or cam.CFrame.Position
	local best, bd
	for _, e in ipairs(getTargets()) do
		local r = e.Model:FindFirstChild("HumanoidRootPart")
		if r then
			local d = (r.Position - origin).Magnitude
			if not bd or d < bd then bd, best = d, e end
		end
	end
	return best
end

local function focusEntry()
	if S.SelectedPlayer ~= "Auto" then
		local p = Players:FindFirstChild(S.SelectedPlayer)
		if p and p:IsA("Player") and p.Character then
			return { Name = p.Name, Model = p.Character, Player = p }
		end
	end
	return currentTarget or nearestEntry()
end

----------------------------------------------------------------------
-- OVERLAY ELEMENTS (FOV circle, crosshair, hit marker, fps, info, radar)
----------------------------------------------------------------------
local FovFrame = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
}, Overlay)
corner(FovFrame, 9999)
mk("UIStroke", { Color = WHITE, Thickness = 1.5, Transparency = 0.2 }, FovFrame)

local Cross = {}
for i = 1, 4 do
	Cross[i] = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0, Visible = false }, Overlay)
end

local Hit = {}
for i = 1, 2 do
	Hit[i] = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false,
		Size = UDim2.fromOffset(22, 3), Rotation = i == 1 and 45 or -45, BackgroundColor3 = WHITE,
	}, Overlay)
end
local hitToken = 0
local function flashIndicator(color)
	hitToken += 1
	local t = hitToken
	for _, f in ipairs(Hit) do f.BackgroundColor3 = color; f.Visible = true end
	task.delay(0.18, function()
		if t == hitToken then
			for _, f in ipairs(Hit) do f.Visible = false end
		end
	end)
end

local FpsLabel = mk("TextLabel", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 44), Size = UDim2.fromOffset(150, 20),
	BackgroundTransparency = 0.4, BackgroundColor3 = Color3.new(0, 0, 0), TextColor3 = WHITE,
	Font = Enum.Font.Code, TextSize = 13, Visible = false, Text = "",
}, Overlay)
corner(FpsLabel, 4)

local InfoBox = mk("TextLabel", {
	Name = "Info", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -12),
	Size = UDim2.fromOffset(250, 10), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.35, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.Code, TextSize = 12, TextWrapped = true,
	Visible = false, Text = "",
}, Overlay)
corner(InfoBox, 6)
mk("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, InfoBox)

local function makeMap(name, pos, round)
	local f = mk("Frame", {
		Name = name, Size = UDim2.fromOffset(150, 150), Position = pos, BackgroundColor3 = Color3.fromRGB(10, 10, 14),
		BackgroundTransparency = 0.35, BorderSizePixel = 0, Visible = false, ClipsDescendants = true,
	}, Overlay)
	corner(f, round and 9999 or 8)
	mk("UIStroke", { Color = C.accent, Thickness = 1.5 }, f)
	local me = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = WHITE, BorderSizePixel = 0,
	}, f)
	corner(me, 3)
	return f
end
local RadarFrame = makeMap("Radar", UDim2.fromOffset(12, 70), true)
local MiniFrame = makeMap("Minimap", UDim2.new(1, -162, 0, 70), false)
local DotPool = { Radar = {}, Mini = {} }

local function placeDots(frame, pool, entries)
	for i, en in ipairs(entries) do
		local d = pool[i]
		if not d then
			d = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0,
			}, frame)
			corner(d, 3)
			pool[i] = d
		end
		d.Visible = true
		d.BackgroundColor3 = en.color
		d.Position = UDim2.new(0.5, en.v.X * 68, 0.5, en.v.Y * 68)
	end
	for i = #entries + 1, #pool do pool[i].Visible = false end
end

local function updateMaps(cam, targets, myPos)
	RadarFrame.Visible = S.Radar
	MiniFrame.Visible = S.Minimap
	if not (S.Radar or S.Minimap) then return end
	local radarList, miniList = {}, {}
	for _, e in ipairs(targets) do
		local r = e.Model:FindFirstChild("HumanoidRootPart")
		local h = getHumanoid(e.Model)
		if r and h and h.Health > 0 then
			local color = (e.Player and sameTeam(e.Player)) and Color3.fromRGB(80, 160, 255) or Color3.fromRGB(255, 70, 70)
			if S.Radar then
				local rel = cam.CFrame:PointToObjectSpace(r.Position)
				local v = Vector2.new(rel.X, rel.Z) / S.RadarRange
				if v.Magnitude > 1 then v = v.Unit end
				table.insert(radarList, { v = v, color = color })
			end
			if S.Minimap then
				local d = r.Position - myPos
				local v = Vector2.new(d.X, d.Z) / S.RadarRange
				if v.Magnitude > 1 then v = v.Unit end
				table.insert(miniList, { v = v, color = color })
			end
		end
	end
	placeDots(RadarFrame, DotPool.Radar, radarList)
	placeDots(MiniFrame, DotPool.Mini, miniList)
end

local function mkSound(id)
	return mk("Sound", { SoundId = id, Volume = 0.8 }, Overlay)
end
local HitSound, KillSound = mkSound(CONFIG.HitSoundId), mkSound(CONFIG.KillSoundId)

----------------------------------------------------------------------
-- ESP
----------------------------------------------------------------------
local ESPObj = {}
local COLORS = {
	Red = Color3.fromRGB(255, 60, 60), Green = Color3.fromRGB(60, 255, 100), Blue = Color3.fromRGB(70, 140, 255),
	White = WHITE, Yellow = Color3.fromRGB(255, 220, 60),
}
local function espColor(e)
	if S.ESPColor == "Team" and e.Player and e.Player.Team then return e.Player.TeamColor.Color end
	return COLORS[S.ESPColor] or COLORS.Red
end

local function destroyAny(v)
	if typeof(v) == "Instance" then v:Destroy()
	elseif type(v) == "table" then for _, x in pairs(v) do destroyAny(x) end end
end
local function clearObj(o)
	for k, v in pairs(o) do destroyAny(v); o[k] = nil end
end
local function feat(o, key, on, make)
	local cur = o[key]
	if on then
		if cur and (type(cur) == "table" or cur.Parent) then return cur end
		o[key] = make()
		return o[key]
	elseif cur then
		destroyAny(cur)
		o[key] = nil
	end
	return nil
end

local function newLine(parent)
	return mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false }, parent)
end
local function setLine(f, a, b, color, thick)
	local d = b - a
	f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
	f.Size = UDim2.fromOffset(d.Magnitude, thick or 1)
	f.Rotation = math.deg(math.atan2(d.Y, d.X))
	f.BackgroundColor3 = color
	f.Visible = true
end
local function project(cam, pos)
	local v = cam:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), v.Z
end
local function screenBox(cam, model)
	local cf, size = model:GetBoundingBox()
	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				local v = cam:WorldToViewportPoint(cf:PointToWorldSpace(size * 0.5 * Vector3.new(x, y, z)))
				if v.Z <= 0 then return nil end
				minX, minY = math.min(minX, v.X), math.min(minY, v.Y)
				maxX, maxY = math.max(maxX, v.X), math.max(maxY, v.Y)
			end
		end
	end
	return minX, minY, maxX, maxY
end

local BONES_R15 = {
	{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local BONES_R6 = {
	{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
	{ "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}
local GROUPS = {
	HeadVisual = { "Head" },
	BodyVisual = { "UpperTorso", "LowerTorso", "Torso" },
	HandVisual = { "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "Left Arm", "Right Arm" },
	LegVisual = { "LeftFoot", "RightFoot", "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg", "Left Leg", "Right Leg" },
	CharacterVisual = true,
}
local VISUAL_KEYS = { "PlayerHighlight", "BoundingBox", "Skeleton", "NameTag", "HealthTag", "DistanceTag", "Tracer",
	"Box2D", "Box3D", "HeadMarker", "Snaplines", "Chams", "Glow", "WeaponMarker",
	"HeadVisual", "BodyVisual", "HandVisual", "LegVisual", "CharacterVisual" }

local function updateESP(e, o, cam, center, myPos)
	local model = e.Model
	local root = model:FindFirstChild("HumanoidRootPart")
	local hum = getHumanoid(model)
	if not (root and hum) then clearObj(o) return end

	local dist = (root.Position - myPos).Magnitude
	local show = dist <= S.ESPDistance and passesCommon(e, dist)
	if show and S.EnemyOnly and e.Player and sameTeam(e.Player) then show = false end
	if show and S.FOVCheck then
		local v, z = project(cam, root.Position)
		if z <= 0 or (v - center).Magnitude > S.FOVRadius then show = false end
	end
	if show and S.VisibleOnly and isObstructed(root, model, false) then show = false end
	if not show then clearObj(o) return end

	local color = espColor(e)
	local head = model:FindFirstChild("Head")

	local hl = feat(o, "hl", S.PlayerHighlight, function()
		return mk("Highlight", { FillTransparency = 1, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop }, model)
	end)
	if hl then hl.OutlineColor = color end

	local ch = feat(o, "chams", S.Chams, function()
		return mk("Highlight", { OutlineTransparency = 1, FillTransparency = 0.45, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop }, model)
	end)
	if ch then ch.FillColor = color end

	local gl = feat(o, "glow", S.Glow, function()
		return mk("PointLight", { Brightness = 3, Range = 14 }, root)
	end)
	if gl then gl.Color = color end

	local tag = feat(o, "tag", S.NameTag or S.HealthTag or S.DistanceTag or S.WeaponMarker, function()
		local bb = mk("BillboardGui", {
			Size = UDim2.fromOffset(200, 60), StudsOffset = Vector3.new(0, 3.2, 0), AlwaysOnTop = true,
			LightInfluence = 0, Adornee = head or root,
		}, World3D)
		mk("TextLabel", {
			Name = "T", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold,
			TextSize = 13, TextStrokeTransparency = 0.4, TextColor3 = WHITE,
		}, bb)
		return bb
	end)
	if tag then
		local lines = {}
		if S.NameTag then table.insert(lines, e.Player and e.Player.DisplayName or e.Name) end
		if S.HealthTag then table.insert(lines, string.format("HP %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))) end
		if S.DistanceTag then table.insert(lines, string.format("%d studs", math.floor(dist))) end
		if S.WeaponMarker then
			local tool = model:FindFirstChildOfClass("Tool")
			if tool then table.insert(lines, "[" .. tool.Name .. "]") end
		end
		local t = tag:FindFirstChild("T")
		if t then t.Text = table.concat(lines, "\n"); t.TextColor3 = color end
	end

	local sb = feat(o, "bound", S.BoundingBox, function()
		return mk("SelectionBox", { Adornee = model, LineThickness = 0.03, SurfaceTransparency = 1 }, World3D)
	end)
	if sb then sb.Color3 = color end

	local b3 = feat(o, "box3d", S.Box3D, function()
		return mk("BoxHandleAdornment", { Adornee = root, AlwaysOnTop = true, ZIndex = 1, Transparency = 0.7 }, World3D)
	end)
	if b3 then
		local cf, size = model:GetBoundingBox()
		b3.Size = size
		b3.CFrame = root.CFrame:ToObjectSpace(cf)
		b3.Color3 = color
	end

	local bx = feat(o, "box2d", S.Box2D, function()
		local f = mk("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0 }, Overlay)
		mk("UIStroke", { Thickness = 1.5 }, f)
		return f
	end)
	if bx then
		local x1, y1, x2, y2 = screenBox(cam, model)
		if x1 then
			bx.Visible = true
			bx.Position = UDim2.fromOffset(x1, y1)
			bx.Size = UDim2.fromOffset(x2 - x1, y2 - y1)
			bx.UIStroke.Color = color
		else
			bx.Visible = false
		end
	end

	local rootPos, rz = project(cam, root.Position)
	local tr = feat(o, "tracer", S.Tracer, function() return newLine(Overlay) end)
	if tr then
		if rz > 0 then setLine(tr, Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y), rootPos, color, 1.5)
		else tr.Visible = false end
	end

	local headPos, hz = rootPos, rz
	if head then headPos, hz = project(cam, head.Position) end
	local sn = feat(o, "snap", S.Snaplines, function() return newLine(Overlay) end)
	if sn then
		if hz > 0 then setLine(sn, center, headPos, color, 1) else sn.Visible = false end
	end

	local hm = feat(o, "hmark", S.HeadMarker, function()
		local f = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, BorderSizePixel = 0,
		}, Overlay)
		corner(f, 9999)
		mk("UIStroke", { Thickness = 2 }, f)
		return f
	end)
	if hm then
		if head and hz > 0 then
			hm.Visible = true
			hm.Position = UDim2.fromOffset(headPos.X, headPos.Y)
			hm.UIStroke.Color = color
		else
			hm.Visible = false
		end
	end

	local sk = feat(o, "skel", S.Skeleton, function() return {} end)
	if sk then
		local bones = model:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6
		for i, bn in ipairs(bones) do
			local ln = sk[i]
			if not ln then ln = newLine(Overlay); sk[i] = ln end
			local p1, p2 = model:FindFirstChild(bn[1]), model:FindFirstChild(bn[2])
			if p1 and p2 then
				local a, az = project(cam, p1.Position)
				local b2, bz = project(cam, p2.Position)
				if az > 0 and bz > 0 then setLine(ln, a, b2, color, 1.5) else ln.Visible = false end
			else
				ln.Visible = false
			end
		end
	end

	for key, names in pairs(GROUPS) do
		local list = feat(o, "g_" .. key, S[key], function()
			local ad = {}
			for _, p in ipairs(model:GetChildren()) do
				if p:IsA("BasePart") then
					local ok
					if names == true then ok = p.Name ~= "HumanoidRootPart" else ok = table.find(names, p.Name) ~= nil end
					if ok then
						table.insert(ad, mk("BoxHandleAdornment", {
							Adornee = p, Size = p.Size + Vector3.new(0.05, 0.05, 0.05), AlwaysOnTop = true,
							ZIndex = 2, Transparency = 0.55,
						}, World3D))
					end
				end
			end
			return ad
		end)
		if list then
			if #list == 0 then o["g_" .. key] = nil
			else for _, a in ipairs(list) do a.Color3 = color end end
		end
	end
end

-- Hit / kill sesi + gostergesi
local watched = setmetatable({}, { __mode = "k" })
local function watchTarget(e)
	local hum = getHumanoid(e.Model)
	if not hum or watched[hum] then return end
	watched[hum] = true
	local last = hum.Health
	hum.HealthChanged:Connect(function(h)
		if h < last and os.clock() - lastShot < 1.2 then
			local killed = h <= 0
			if killed then
				if S.KillAudio then KillSound:Play() end
			elseif S.HitAudio then
				HitSound:Play()
			end
			if S.HitIndicator then
				flashIndicator(killed and Color3.fromRGB(255, 70, 70) or WHITE)
			end
		end
		last = h
	end)
end

RunService:BindToRenderStep("saksak_esp", Enum.RenderPriority.Last.Value, function()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local vs = cam.ViewportSize
	local center = vs / 2
	local myPos = cam.CFrame.Position

	-- overlay: FOV circle / crosshair
	FovFrame.Visible = S.FOVCircle
	FovFrame.Size = UDim2.fromOffset(S.FOVRadius * 2, S.FOVRadius * 2)
	FovFrame.Position = UDim2.fromOffset(center.X, center.Y)
	local len, gap = S.CrosshairSize, 4
	for _, f in ipairs(Cross) do f.Visible = S.Crosshair end
	if S.Crosshair then
		Cross[1].Size = UDim2.fromOffset(2, len); Cross[1].Position = UDim2.fromOffset(center.X, center.Y - gap - len / 2)
		Cross[2].Size = UDim2.fromOffset(2, len); Cross[2].Position = UDim2.fromOffset(center.X, center.Y + gap + len / 2)
		Cross[3].Size = UDim2.fromOffset(len, 2); Cross[3].Position = UDim2.fromOffset(center.X - gap - len / 2, center.Y)
		Cross[4].Size = UDim2.fromOffset(len, 2); Cross[4].Position = UDim2.fromOffset(center.X + gap + len / 2, center.Y)
	end
	for _, f in ipairs(Hit) do f.Position = UDim2.fromOffset(center.X, center.Y) end

	local anyOn = false
	for _, k in ipairs(VISUAL_KEYS) do
		if S[k] then anyOn = true break end
	end

	local targets = getTargets()
	local seen = {}
	for _, e in ipairs(targets) do
		seen[e.Model] = true
		watchTarget(e)
		if anyOn then
			local o = ESPObj[e.Model]
			if not o then o = {}; ESPObj[e.Model] = o end
			updateESP(e, o, cam, center, myPos)
		end
	end
	for m, o in pairs(ESPObj) do
		if not seen[m] or not anyOn then
			clearObj(o)
			ESPObj[m] = nil
		end
	end

	updateMaps(cam, targets, myPos)
end)

----------------------------------------------------------------------
-- AIM ASSIST + CAMERA
----------------------------------------------------------------------
local specOn = false
RunService:BindToRenderStep("saksak_aim", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local cam = Workspace.CurrentCamera
	if not cam then return end
	if S.CameraFOVOn then cam.FieldOfView = S.CameraFOV end

	if S.Spectate then
		local e = focusEntry()
		local th = e and getHumanoid(e.Model)
		if th and cam.CameraSubject ~= th then cam.CameraSubject = th end
		specOn = true
	elseif specOn then
		specOn = false
		local h = getHum()
		if h then cam.CameraSubject = h end
	end

	if not S.CameraAim or S.Spectate then currentTarget = nil return end
	if S.AimHold and B.AimKey ~= "" and not bindHeld(B.AimKey) then currentTarget = nil return end

	local keep = false
	if not S.TargetSwitch and currentTarget then
		local part = getAimPart(currentTarget.Model)
		keep = currentTarget.Model.Parent ~= nil and part ~= nil and passesCommon(currentTarget)
	end
	if not keep then currentTarget = pickTarget() end
	if not currentTarget then return end

	local part = getAimPart(currentTarget.Model)
	if not part then return end
	local pos = part.Position + part.AssemblyLinearVelocity * (S.NetworkDelay / 1000) + Vector3.new(0, S.StateOffset, 0)
	local goal = CFrame.lookAt(cam.CFrame.Position, pos)
	if S.YawOffset ~= 0 then goal = goal * CFrame.Angles(0, math.rad(S.YawOffset), 0) end
	local alpha = math.clamp(1 - S.AimSmooth, 0.03, 1)
	alpha = 1 - (1 - alpha) ^ (dt * 60)
	cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end)

----------------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------------
local origGravity = Workspace.Gravity
local gravityApplied = false
local flyOn = false
local airPart, airY
local lastSafe
local autoT = 0
local fps = 60

local function teleportTo(cf)
	local root = getRoot()
	if root then root.CFrame = cf end
end
local function teleportToTarget()
	local e = focusEntry()
	local r = e and e.Model:FindFirstChild("HumanoidRootPart")
	if r then
		teleportTo(r.CFrame * CFrame.new(0, 0, 3))
		UI.notify("Hedefe ışınlandın: " .. e.Name)
	else
		UI.notify("Hedef bulunamadı")
	end
end
local function clickTeleport()
	local cam = Workspace.CurrentCamera
	local mp = UserInputService:GetMouseLocation()
	local ray = cam:ViewportPointToRay(mp.X, mp.Y)
	local ignore = {}
	if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
	rayParams.FilterDescendantsInstances = ignore
	local res = Workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
	if res then teleportTo(CFrame.new(res.Position + Vector3.new(0, 3, 0))) end
end

RunService.Heartbeat:Connect(function(dt)
	fps = fps * 0.9 + (1 / math.max(dt, 1e-4)) * 0.1
	FpsLabel.Visible = S.FrameRate
	if S.FrameRate then
		FpsLabel.Text = string.format("FPS %d  (%.1f ms)", math.floor(fps + 0.5), dt * 1000)
	end

	if S.Gravity and S.GravityOn then
		Workspace.Gravity = S.Gravity
		gravityApplied = true
	elseif gravityApplied then
		Workspace.Gravity = origGravity
		gravityApplied = false
	end

	local c = LocalPlayer.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	local root = c and c:FindFirstChild("HumanoidRootPart")
	if not (hum and root) then return end

	if S.WalkSpeedOn then hum.WalkSpeed = S.WalkSpeed
	elseif S.NoSlow and hum.WalkSpeed < CONFIG.BaseWalkSpeed then hum.WalkSpeed = CONFIG.BaseWalkSpeed end
	if S.JumpPowerOn then hum.UseJumpPower = true; hum.JumpPower = S.JumpPower end

	-- Fly
	if S.FlyOn then
		if not flyOn then flyOn = true; hum.PlatformStand = true end
		local cf = Workspace.CurrentCamera.CFrame
		local dir = Vector3.zero
		if not UserInputService:GetFocusedTextBox() then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
		end
		if dir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then dir = hum.MoveDirection end
		if dir.Magnitude > 0 then dir = dir.Unit end
		root.AssemblyLinearVelocity = dir * S.FlySpeed
		root.AssemblyAngularVelocity = Vector3.zero
	elseif flyOn then
		flyOn = false
		hum.PlatformStand = false
	end

	-- AirWalk
	if S.AirWalk then
		if not airPart then
			airPart = mk("Part", {
				Name = "saksak_air", Anchored = true, Size = Vector3.new(8, 1, 8), Transparency = 0.85,
				Color = C.accent, Material = Enum.Material.Neon, CanQuery = false,
			}, Workspace)
			local off = hum.RigType == Enum.HumanoidRigType.R6 and 3 or (hum.HipHeight + root.Size.Y / 2)
			airY = root.Position.Y - off - 0.5
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then airY += 25 * dt
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then airY -= 25 * dt end
		airPart.CFrame = CFrame.new(root.Position.X, airY, root.Position.Z)
	elseif airPart then
		airPart:Destroy()
		airPart = nil
	end

	if S.SpinOn then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(S.SpinSpeed) * dt, 0) end

	if S.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air and not UserInputService:GetFocusedTextBox()
		and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	if S.AntiFall then
		if hum.FloorMaterial ~= Enum.Material.Air then lastSafe = root.CFrame end
		if lastSafe and root.Position.Y < Workspace.FallenPartsDestroyHeight + 40 then
			root.CFrame = lastSafe + Vector3.new(0, 5, 0)
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end

	-- AutoAction
	autoT += dt
	if S.AutoAction and autoT >= S.AutoInterval then
		autoT = 0
		local tool = c:FindFirstChildOfClass("Tool")
		if tool then
			local tgt = currentTarget or pickTarget()
			if tgt then
				lastShot = os.clock()
				tool:Activate()
			end
		end
	end

	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then lastShot = os.clock() end
end)

RunService.Stepped:Connect(function()
	if S.NoClip then
		local c = LocalPlayer.Character
		if c then
			for _, p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if S.InfJump then
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

----------------------------------------------------------------------
-- COMBAT & WEAPON (Tool attribute / NumberValue overrides)
----------------------------------------------------------------------
local ToolBackup = setmetatable({}, { __mode = "k" })
local RULES = {
	{ names = { "Recoil", "RecoilAmount", "RecoilStrength", "RecoilPower" },
		active = function() return S.NoRecoil end, calc = function() return 0 end },
	{ names = { "Spread", "SpreadAmount", "BaseSpread", "MaxSpread" },
		active = function() return S.NoSpread end, calc = function() return 0 end },
	{ names = { "FireDelay", "FireCooldown", "Cooldown", "ShotDelay" },
		active = function() return S.RapidFire end, calc = function(o) return math.min(o, 0.05) end },
	{ names = { "ReloadTime", "ReloadDuration", "ReloadDelay" },
		active = function() return S.FastReload or S.NoReload end,
		calc = function(o) return S.NoReload and 0 or o * 0.25 end },
	{ names = { "Ammo", "CurrentAmmo", "Clip", "Magazine", "Mag" }, keep = true,
		active = function() return S.InfiniteAmmo end,
		calc = function(o, tool)
			return tool:GetAttribute("MaxAmmo") or tool:GetAttribute("MagSize") or tool:GetAttribute("ClipSize") or math.max(o, 30)
		end },
	{ names = { "Damage", "BaseDamage" },
		active = function() return S.DamageScale ~= 1 end, calc = function(o) return o * S.DamageScale end },
	{ names = { "Range", "MeleeRange", "Reach", "AttackRange" },
		active = function() return S.MeleeRange ~= 1 end, calc = function(o) return o * S.MeleeRange end },
}

local function getNum(tool, name)
	local a = tool:GetAttribute(name)
	if type(a) == "number" then return a, "attr", nil end
	local v = tool:FindFirstChild(name)
	if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then return v.Value, "val", v end
	return nil
end

local function applyRules(tool)
	local bk = ToolBackup[tool]
	if not bk then bk = {}; ToolBackup[tool] = bk end
	for _, rule in ipairs(RULES) do
		local on = rule.active()
		for _, name in ipairs(rule.names) do
			local cur, kind, obj = getNum(tool, name)
			if cur ~= nil then
				if on then
					if bk[name] == nil then bk[name] = cur end
					local nv = rule.calc(bk[name], tool)
					if cur ~= nv then
						if kind == "attr" then tool:SetAttribute(name, nv) else obj.Value = nv end
					end
				elseif bk[name] ~= nil then
					if not rule.keep then
						if kind == "attr" then tool:SetAttribute(name, bk[name]) else obj.Value = bk[name] end
					end
					bk[name] = nil
				end
			end
		end
	end
end

local HitboxOrig = setmetatable({}, { __mode = "k" })
local function applyHitbox()
	local scale = S.HitboxScale
	local want = {}
	if scale ~= 1 then
		for _, e in ipairs(getTargets()) do
			local skip = S.TeamCheck and e.Player ~= nil and sameTeam(e.Player)
			if not skip then
				for _, n in ipairs({ "HumanoidRootPart", "Head" }) do
					local p = e.Model:FindFirstChild(n)
					if p then
						want[p] = true
						if not HitboxOrig[p] then
							HitboxOrig[p] = { Size = p.Size, T = p.Transparency, C = p.CanCollide }
						end
						p.Size = HitboxOrig[p].Size * scale
						p.Transparency = math.max(HitboxOrig[p].T, 0.6)
						p.CanCollide = false
					end
				end
			end
		end
	end
	for p, o in pairs(HitboxOrig) do
		if not want[p] then
			if p.Parent then p.Size = o.Size; p.Transparency = o.T; p.CanCollide = o.C end
			HitboxOrig[p] = nil
		end
	end
end

task.spawn(function()
	local n = 0
	while true do
		task.wait(0.2)
		n += 1
		local c = LocalPlayer.Character
		if c then
			for _, ch in ipairs(c:GetChildren()) do
				if ch:IsA("Tool") then applyRules(ch) end
			end
		end
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") then applyRules(t) end
			end
		end
		for _, k in ipairs({ "NoRecoil", "NoSpread", "RapidFire", "FastReload", "InfiniteAmmo", "NoReload" }) do
			LocalPlayer:SetAttribute("dbg_" .. k, S[k])
		end
		LocalPlayer:SetAttribute("dbg_DamageScale", S.DamageScale)
		LocalPlayer:SetAttribute("dbg_MeleeRange", S.MeleeRange)
		if n % 2 == 0 then applyHitbox() end
	end
end)

----------------------------------------------------------------------
-- WORLD: lighting, markers, info panel, AFK tracking
----------------------------------------------------------------------
local LightOrig = {
	Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
}
local AtmoOrig = {}
local CC = mk("ColorCorrectionEffect", { Name = "saksak_cc", Enabled = false }, Lighting)
local fbOn, nfOn = false, false

RunService.Heartbeat:Connect(function()
	if S.Fullbright then
		fbOn = true
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = WHITE
		Lighting.OutdoorAmbient = WHITE
		Lighting.GlobalShadows = false
	elseif fbOn then
		fbOn = false
		for _, k in ipairs({ "Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "GlobalShadows" }) do
			Lighting[k] = LightOrig[k]
		end
	end

	if S.NoFog then
		nfOn = true
		Lighting.FogEnd = 1e9
		Lighting.FogStart = 1e9
		for _, a in ipairs(Lighting:GetChildren()) do
			if a:IsA("Atmosphere") then
				if AtmoOrig[a] == nil then AtmoOrig[a] = a.Density end
				a.Density = 0
			end
		end
	elseif nfOn then
		nfOn = false
		Lighting.FogEnd = LightOrig.FogEnd
		Lighting.FogStart = LightOrig.FogStart
		for a, d in pairs(AtmoOrig) do
			if a.Parent then a.Density = d end
			AtmoOrig[a] = nil
		end
	end

	if S.NightVision then
		CC.Enabled = true
		CC.TintColor = Color3.fromRGB(120, 255, 130)
		CC.Brightness = 0.15
		CC.Contrast = 0.25
		CC.Saturation = -0.2
	elseif S.WorldVisual then
		CC.Enabled = true
		CC.TintColor = Color3.fromRGB(255, 240, 225)
		CC.Brightness = 0
		CC.Contrast = 0.1
		CC.Saturation = 0.45
	else
		CC.Enabled = false
	end
end)

-- World markers
local WorldMarkers = {}
local function anyPart(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Tool") then return inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart", true) end
	if inst:IsA("Model") then return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true) end
	return nil
end
local function inCharacter(inst)
	local m = inst:FindFirstAncestorOfClass("Model")
	while m do
		if m:FindFirstChildOfClass("Humanoid") then return true end
		m = m:FindFirstAncestorOfClass("Model")
	end
	return false
end

local function rebuildMarkers()
	local want, count = {}, 0
	local function add(inst, color)
		if want[inst] or count >= 200 then return end
		want[inst] = { color = color }
		count += 1
	end
	if S.ItemMarker then for _, i in ipairs(CollectionService:GetTagged(CONFIG.ItemTag)) do add(i, Color3.fromRGB(80, 200, 255)) end end
	if S.LootVisual then for _, i in ipairs(CollectionService:GetTagged(CONFIG.LootTag)) do add(i, Color3.fromRGB(255, 200, 60)) end end
	if S.ObjectVisual then for _, i in ipairs(CollectionService:GetTagged(CONFIG.ObjectTag)) do add(i, Color3.fromRGB(180, 180, 255)) end end
	if S.DoorVisual then for _, i in ipairs(CollectionService:GetTagged(CONFIG.DoorTag)) do add(i, Color3.fromRGB(255, 150, 80)) end end

	local wq, iq = string.lower(S.WeaponSearch), string.lower(S.ItemSearch)
	if S.WeaponMarker or S.DoorVisual or wq ~= "" or iq ~= "" then
		for _, d in ipairs(Workspace:GetDescendants()) do
			if d:IsA("Tool") then
				if not inCharacter(d) then
					if S.WeaponMarker then add(d, Color3.fromRGB(255, 230, 80)) end
					if wq ~= "" and string.find(string.lower(d.Name), wq, 1, true) then add(d, Color3.fromRGB(255, 90, 220)) end
				end
			elseif d:IsA("Model") or d:IsA("BasePart") then
				local ln = string.lower(d.Name)
				if S.DoorVisual and string.find(ln, "door", 1, true) then add(d, Color3.fromRGB(255, 150, 80)) end
				if iq ~= "" and string.find(ln, iq, 1, true) then add(d, Color3.fromRGB(90, 255, 200)) end
			end
		end
	end

	for inst, m in pairs(WorldMarkers) do
		if not want[inst] or not inst.Parent then
			m.gui:Destroy()
			WorldMarkers[inst] = nil
		end
	end
	for inst, info in pairs(want) do
		if not WorldMarkers[inst] then
			local part = anyPart(inst)
			if part then
				local gui = mk("BillboardGui", {
					Size = UDim2.fromOffset(160, 22), AlwaysOnTop = true, LightInfluence = 0,
					StudsOffset = Vector3.new(0, 2, 0), Adornee = part,
				}, World3D)
				local lbl = mk("TextLabel", {
					BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
					TextColor3 = info.color, TextStrokeTransparency = 0.4,
				}, gui)
				WorldMarkers[inst] = { gui = gui, label = lbl, part = part, name = inst.Name }
			end
		end
	end
end

local function updateMarkerLabels()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	for _, m in pairs(WorldMarkers) do
		if m.part.Parent then
			local d = (m.part.Position - cam.CFrame.Position).Magnitude
			m.label.Text = string.format("%s [%d]", m.name, math.floor(d))
		end
	end
end

-- Info panel
local function buildInfo(e)
	local m = e.Model
	local hum = getHumanoid(m)
	local L = {}
	if S.AvatarInfo then
		table.insert(L, "== Avatar ==")
		table.insert(L, "Name: " .. e.Name .. (e.Player and (" (" .. e.Player.DisplayName .. ")") or " [NPC]"))
		if e.Player then
			table.insert(L, "UserId: " .. e.Player.UserId)
			table.insert(L, "AccountAge: " .. e.Player.AccountAge .. " days")
			table.insert(L, "Team: " .. (e.Player.Team and e.Player.Team.Name or "none"))
		end
		if hum then
			table.insert(L, "Rig: " .. hum.RigType.Name)
			table.insert(L, string.format("HP: %d/%d  Speed: %d", math.floor(hum.Health), math.floor(hum.MaxHealth), math.floor(hum.WalkSpeed)))
		end
		local tool = m:FindFirstChildOfClass("Tool")
		table.insert(L, "Tool: " .. (tool and tool.Name or "none"))
	end
	if S.OutfitInfo then
		table.insert(L, "== Outfit ==")
		local acc = {}
		for _, a in ipairs(m:GetChildren()) do
			if a:IsA("Accessory") then table.insert(acc, a.Name) end
		end
		table.insert(L, "Accessories (" .. #acc .. "): " .. table.concat(acc, ", ", 1, math.min(#acc, 6)))
		local shirt, pants, gfx = m:FindFirstChildOfClass("Shirt"), m:FindFirstChildOfClass("Pants"), m:FindFirstChildOfClass("ShirtGraphic")
		table.insert(L, "Shirt: " .. (shirt and shirt.ShirtTemplate or "-"))
		table.insert(L, "Pants: " .. (pants and pants.PantsTemplate or "-"))
		table.insert(L, "Graphic: " .. (gfx and gfx.Graphic or "-"))
	end
	return table.concat(L, "\n")
end

task.spawn(function()
	local n = 0
	while true do
		task.wait(0.25)
		n += 1
		if markDirty or n >= 8 then
			n = 0
			markDirty = false
			rebuildMarkers()
		end
		updateMarkerLabels()

		if n % 2 == 0 then
			for _, e in ipairs(getTargets()) do
				local r = e.Model:FindFirstChild("HumanoidRootPart")
				if r then
					local rec = AFKTrack[e.Model]
					if not rec or (r.Position - rec.pos).Magnitude > 0.5 then
						AFKTrack[e.Model] = { pos = r.Position, t = os.clock() }
					end
				end
			end
			if S.OutfitInfo or S.AvatarInfo then
				local e = focusEntry()
				InfoBox.Visible = e ~= nil
				if e then InfoBox.Text = buildInfo(e) end
			else
				InfoBox.Visible = false
			end
		end
	end
end)

----------------------------------------------------------------------
-- CHARACTER EVENTS (auto respawn, shot tracking)
----------------------------------------------------------------------
local function onCharacter(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.Died:Connect(function()
		if S.AutoRespawn then
			task.wait(CONFIG.RespawnDelay)
			local r = ReplicatedStorage:FindFirstChild(CONFIG.RespawnRemoteName)
			if r and r:IsA("RemoteEvent") then r:FireServer() end
		end
	end)
	char.ChildAdded:Connect(function(ch)
		if ch:IsA("Tool") then
			ch.Activated:Connect(function() lastShot = os.clock() end)
		end
	end)
end
if LocalPlayer.Character then task.spawn(onCharacter, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacter)

----------------------------------------------------------------------
-- PROFILE SAVE / LOAD / RESET
----------------------------------------------------------------------
local function saveProfile()
	local json = HttpService:JSONEncode({ S = S, B = B })
	LocalPlayer:SetAttribute("saksak_profile", json)
	pcall(function()
		local env = getfenv()
		if env.writefile then env.writefile("saksak_profile.json", json) end
	end)
	UI.notify("Profil kaydedildi (oturum + varsa dosya)")
end

local function loadProfile()
	local json = LocalPlayer:GetAttribute("saksak_profile")
	if not json then
		pcall(function()
			local env = getfenv()
			if env.readfile and env.isfile and env.isfile("saksak_profile.json") then
				json = env.readfile("saksak_profile.json")
			end
		end)
	end
	if not json then UI.notify("Kayıtlı profil yok") return end
	local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
	if not ok or type(data) ~= "table" then UI.notify("Profil okunamadı") return end
	for k, v in pairs(data.S or {}) do
		if DEFAULTS[k] ~= nil and type(v) == type(DEFAULTS[k]) then setting(k, v) end
	end
	for k, v in pairs(data.B or {}) do
		if DEFAULT_BINDS[k] ~= nil and type(v) == "string" then setBind(k, v) end
	end
	UI.notify("Profil yüklendi")
end

local function resetAll()
	for k, v in pairs(DEFAULTS) do setting(k, v) end
	for k, v in pairs(DEFAULT_BINDS) do setBind(k, v) end
	UI.notify("Tüm ayarlar sıfırlandı")
end

----------------------------------------------------------------------
-- UI FRAMEWORK
----------------------------------------------------------------------
local activeDrag = nil
local capturing = nil
local orderN = 0
local function nextOrder() orderN += 1; return orderN end

UserInputService.InputChanged:Connect(function(input)
	if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		activeDrag(input.Position)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		activeDrag = nil
	end
end)

local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
local WIN_W, WIN_H = math.min(620, vp.X - 20), math.min(420, vp.Y - 20)
local Window = mk("Frame", {
	Name = "Window", Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
	BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true,
}, UIGui)
corner(Window, 10)
mk("UIStroke", { Color = C.accent, Thickness = 1.2, Transparency = 0.4 }, Window)

local TitleBar = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.panel, BorderSizePixel = 0 }, Window)
corner(TitleBar, 10)
mk("TextLabel", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -90, 1, 0),
	Text = "SAKSAK  •  Test Paneli", TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold,
	TextSize = 14, TextColor3 = C.text,
}, TitleBar)

local Body = mk("Frame", { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 1, -34), BackgroundTransparency = 1 }, Window)

local function titleButton(text, offset, fn)
	local b = mk("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offset, 0.5, 0), Size = UDim2.fromOffset(26, 22),
		BackgroundColor3 = C.row, Text = text, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0,
	}, TitleBar)
	corner(b, 5)
	b.MouseButton1Click:Connect(fn)
end
local minimized = false
titleButton("—", -40, function()
	minimized = not minimized
	Body.Visible = not minimized
	Window.Size = minimized and UDim2.fromOffset(WIN_W, 34) or UDim2.fromOffset(WIN_W, WIN_H)
end)
titleButton("✕", -8, function() Window.Visible = false end)

local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragStart, startPos = input.Position, Window.Position
		activeDrag = function(pos)
			local d = pos - dragStart
			Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end
end)

local Status = mk("TextLabel", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -2), Size = UDim2.new(1, -20, 0, 16),
	BackgroundTransparency = 1, Text = "Hazır", TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.muted,
}, Body)
UI.notify = function(t) Status.Text = t end

local Sidebar = mk("ScrollingFrame", {
	Position = UDim2.fromOffset(6, 4), Size = UDim2.new(0, 142, 1, -24), BackgroundColor3 = C.panel, BorderSizePixel = 0,
	ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Body)
corner(Sidebar, 8)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, Sidebar)
mk("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, Sidebar)

local Content = mk("Frame", {
	Position = UDim2.fromOffset(154, 4), Size = UDim2.new(1, -160, 1, -24), BackgroundTransparency = 1,
}, Body)

local function row(page, h)
	local f = mk("Frame", { Size = UDim2.new(1, -8, 0, h), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = nextOrder() }, page)
	corner(f, 6)
	return f
end

local function rowLabel(parent, text, width)
	return mk("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = width or UDim2.new(1, -120, 1, 0),
		Text = text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 13,
		TextColor3 = C.text, TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function BindButton(parent, key, pos, width)
	local b = mk("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = pos, Size = UDim2.fromOffset(width, 18), BackgroundColor3 = C.panel,
		Text = "", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.muted, AutoButtonColor = false,
		BorderSizePixel = 0, TextScaled = true,
	}, parent)
	corner(b, 4)
	mk("UITextSizeConstraint", { MaxTextSize = 11, MinTextSize = 7 }, b)
	local function show()
		b.Text = (B[key] and B[key] ~= "") and B[key] or "none"
	end
	BindRefs[key] = BindRefs[key] or {}
	table.insert(BindRefs[key], show)
	show()
	b.MouseButton1Click:Connect(function()
		capturing = { key = key, allowMouse = key == "AimKey" }
		b.Text = "..."
	end)
end

local function Section(page, text)
	mk("TextLabel", {
		Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1, Text = text, TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.accent, LayoutOrder = nextOrder(),
	}, page)
end

local function Toggle(page, key, label, bindable)
	local f = row(page, 28)
	rowLabel(f, label, UDim2.new(1, bindable and -112 or -62, 1, 0))
	local sw = mk("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(42, 18),
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.off, BorderSizePixel = 0,
	}, f)
	corner(sw, 9)
	local knob = mk("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, sw)
	corner(knob, 7)
	local function refresh(v)
		sw.BackgroundColor3 = v and C.accent or C.off
		knob.Position = v and UDim2.fromOffset(26, 2) or UDim2.fromOffset(2, 2)
	end
	addRef(key, refresh)
	refresh(S[key])
	sw.MouseButton1Click:Connect(function() setting(key, not S[key]) end)
	if bindable then
		ToggleKeys[key] = true
		BindButton(f, key, UDim2.new(1, -56, 0.5, 0), 46)
	end
end

local function Keybind(page, key, label)
	local f = row(page, 28)
	rowLabel(f, label, UDim2.new(1, -110, 1, 0))
	BindButton(f, key, UDim2.new(1, -8, 0.5, 0), 96)
end

local function Slider(page, key, label, min, max, step)
	local f = row(page, 44)
	local dec = step >= 1 and 0 or (step >= 0.1 and 1 or 2)
	rowLabel(f, label, UDim2.new(1, -80, 0, 24)).Position = UDim2.fromOffset(10, 3)
	local val = mk("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 5), Size = UDim2.fromOffset(60, 18),
		Text = "", TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.accent,
	}, f)
	local track = mk("Frame", { Position = UDim2.new(0, 10, 0, 31), Size = UDim2.new(1, -20, 0, 6), BackgroundColor3 = C.off, BorderSizePixel = 0 }, f)
	corner(track, 3)
	local fill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0 }, track)
	corner(fill, 3)
	local knob = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = WHITE, BorderSizePixel = 0,
	}, track)
	corner(knob, 6)
	local hit = mk("TextButton", { BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 22) }, f)

	local function refresh(v)
		local t = math.clamp((v - min) / (max - min), 0, 1)
		fill.Size = UDim2.fromScale(t, 1)
		knob.Position = UDim2.fromScale(t, 0.5)
		val.Text = string.format("%." .. dec .. "f", v)
	end
	addRef(key, refresh)
	refresh(S[key])

	local function fromX(x)
		local t = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = min + (max - min) * t
		v = math.floor(v / step + 0.5) * step
		setting(key, math.clamp(v, min, max))
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			activeDrag = function(p) fromX(p.X) end
			fromX(input.Position.X)
		end
	end)
end

local function Dropdown(page, key, label, options)
	local box = mk("Frame", {
		Size = UDim2.new(1, -8, 0, 28), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.row,
		BorderSizePixel = 0, LayoutOrder = nextOrder(),
	}, page)
	corner(box, 6)
	mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, box)
	local header = mk("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "", LayoutOrder = 1,
	}, box)
	local txt = mk("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -30, 1, 0), Text = "",
		TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, header)
	mk("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(16, 28),
		Text = "▾", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.muted,
	}, header)
	local opts = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, LayoutOrder = 2,
	}, box)
	mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, opts)
	mk("UIPadding", { PaddingBottom = UDim.new(0, 4) }, opts)

	local function setOptions(list)
		for _, c in ipairs(opts:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for i, name in ipairs(list) do
			local b = mk("TextButton", {
				Size = UDim2.new(1, -12, 0, 24), BackgroundColor3 = C.panel, Text = name, TextColor3 = C.text,
				Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0, LayoutOrder = i,
			}, opts)
			corner(b, 4)
			b.MouseButton1Click:Connect(function()
				setting(key, name)
				opts.Visible = false
			end)
		end
	end
	setOptions(options)
	addRef(key, function(v) txt.Text = label .. ":  " .. tostring(v) end)
	txt.Text = label .. ":  " .. tostring(S[key])
	header.MouseButton1Click:Connect(function() opts.Visible = not opts.Visible end)
	return { setOptions = setOptions }
end

local function TextInput(page, key, label, placeholder)
	local f = row(page, 28)
	rowLabel(f, label, UDim2.new(0.4, 0, 1, 0))
	local tb = mk("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.6, -14, 0, 20),
		BackgroundColor3 = C.panel, Text = S[key], PlaceholderText = placeholder or "name1, name2", PlaceholderColor3 = C.muted,
		TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, f)
	corner(tb, 4)
	mk("UIPadding", { PaddingLeft = UDim.new(0, 6) }, tb)
	tb.FocusLost:Connect(function() setting(key, tb.Text) end)
	addRef(key, function(v) tb.Text = v end)
end

local function Button(page, label, fn)
	local b = mk("TextButton", {
		Size = UDim2.new(1, -8, 0, 28), BackgroundColor3 = C.accent, Text = label, TextColor3 = WHITE,
		Font = Enum.Font.GothamBold, TextSize = 13, BorderSizePixel = 0, LayoutOrder = nextOrder(),
	}, page)
	corner(b, 6)
	b.MouseButton1Click:Connect(fn)
end

local Pages, TabButtons = {}, {}
local function showTab(i)
	for idx, p in ipairs(Pages) do p.Visible = idx == i end
	for idx, b in ipairs(TabButtons) do b.BackgroundColor3 = idx == i and C.accent or C.row end
end
local function newTab(title)
	local i = #Pages + 1
	local btn = mk("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.row, Text = title, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
		TextSize = 12, BorderSizePixel = 0, LayoutOrder = i, TextWrapped = true,
	}, Sidebar)
	corner(btn, 6)
	local page = mk("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
	}, Content)
	mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	mk("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) }, page)
	Section(page, title:upper())
	Pages[i], TabButtons[i] = page, btn
	btn.MouseButton1Click:Connect(function() showTab(i) end)
	return page
end

----------------------------------------------------------------------
-- TABS
----------------------------------------------------------------------
local PlayerDD

-- 1) Nişan & Hedefleme
do
	local p = newTab("Nişan & Hedefleme")
	Toggle(p, "CameraAim", "Camera Aim Assist", true)
	Slider(p, "AimSmooth", "Smoothness Slider", 0, 0.95, 0.01)
	Toggle(p, "AimHold", "Hold To Aim")
	Keybind(p, "AimKey", "Aim Key")
	Toggle(p, "FOVCircle", "FOV Circle")
	Slider(p, "FOVRadius", "FOV Radius", 20, 600, 5)
	Dropdown(p, "AimPart", "Aim Part", { "Head", "Torso", "HumanoidRootPart", "Closest To Cursor" })
	Toggle(p, "NearestTarget", "Nearest Target")
	Toggle(p, "TargetSwitch", "Target Switch")
	Toggle(p, "LOSCheck", "Line Of Sight Check")
	Toggle(p, "TeamCheck", "Team Check")
	Toggle(p, "FriendCheck", "Friend Check")
	Toggle(p, "AliveCheck", "Alive Check")
	Toggle(p, "KnockedCheck", "Knocked Check")
end

-- 2) Görseller & ESP
do
	local p = newTab("Görseller & ESP")
	Dropdown(p, "ESPColor", "ESP Color", { "Red", "Green", "Blue", "White", "Yellow", "Team" })
	Slider(p, "ESPDistance", "ESP Max Distance", 50, 5000, 50)
	Toggle(p, "PlayerHighlight", "Player Highlight", true)
	Toggle(p, "BoundingBox", "Bounding Box")
	Toggle(p, "Skeleton", "Skeleton")
	Toggle(p, "NameTag", "Name Tag")
	Toggle(p, "HealthTag", "Health Tag")
	Toggle(p, "DistanceTag", "Distance Tag")
	Toggle(p, "Tracer", "Tracer")
	Toggle(p, "Box2D", "2D Box", true)
	Toggle(p, "Box3D", "3D Box")
	Toggle(p, "HeadMarker", "Head Marker")
	Toggle(p, "Snaplines", "Snaplines")
	Toggle(p, "Chams", "Chams", true)
	Toggle(p, "Glow", "Glow")
	Toggle(p, "ItemMarker", "Item Marker")
	Toggle(p, "WeaponMarker", "Weapon Marker")
	Toggle(p, "EnemyOnly", "Enemy Only")
	Toggle(p, "VisibleOnly", "Visible Only")
end

-- 3) Hareket
do
	local p = newTab("Hareket")
	Toggle(p, "WalkSpeedOn", "WalkSpeed", true)
	Slider(p, "WalkSpeed", "WalkSpeed Value", 4, 200, 1)
	Toggle(p, "FlyOn", "Fly", true)
	Slider(p, "FlySpeed", "Fly Speed", 10, 250, 5)
	Toggle(p, "InfJump", "Infinite Jump", true)
	Toggle(p, "NoClip", "NoClip", true)
	Toggle(p, "ClickTP", "Teleport (Click)", true)
	Keybind(p, "TeleKey", "Teleport Key")
	Button(p, "Teleport To Target", teleportToTarget)
	Toggle(p, "JumpPowerOn", "JumpPower")
	Slider(p, "JumpPower", "JumpPower Value", 10, 300, 5)
	Toggle(p, "NoSlow", "NoSlow")
	Toggle(p, "AirWalk", "AirWalk", true)
	Toggle(p, "GravityOn", "Gravity")
	Slider(p, "Gravity", "Gravity Value", 0, 400, 2)
	Toggle(p, "SpinOn", "Spin", true)
	Slider(p, "SpinSpeed", "Spin Speed (deg/s)", 30, 1440, 10)
	Toggle(p, "BunnyHop", "BunnyHop")
	Toggle(p, "AntiFall", "AntiFall")
end

-- 4) Savaş & Silah
do
	local p = newTab("Savaş & Silah")
	Toggle(p, "NoRecoil", "NoRecoil")
	Toggle(p, "NoSpread", "NoSpread")
	Toggle(p, "RapidFire", "RapidFire")
	Toggle(p, "FastReload", "FastReload")
	Toggle(p, "InfiniteAmmo", "InfiniteAmmo")
	Toggle(p, "NoReload", "NoReload")
	Slider(p, "DamageScale", "DamageScale", 1, 10, 0.5)
	Slider(p, "HitboxScale", "HitboxScale", 1, 6, 0.25)
	Slider(p, "MeleeRange", "MeleeRange", 1, 5, 0.25)
	Toggle(p, "AutoAction", "AutoAction", true)
	Slider(p, "AutoInterval", "AutoAction Interval (s)", 0.03, 1, 0.01)
end

-- 5) Filtreler & Kontroller
do
	local p = newTab("Filtreler & Kontroller")
	Toggle(p, "TeamCheck", "TeamCheck")
	Toggle(p, "FriendCheck", "FriendCheck")
	Toggle(p, "EnemyCheck", "EnemyCheck")
	Toggle(p, "AliveCheck", "AliveCheck")
	Toggle(p, "DeadCheck", "DeadCheck")
	Toggle(p, "LOSCheck", "LineOfSightCheck")
	Toggle(p, "ObstacleCheck", "ObstacleCheck")
	Toggle(p, "DistanceCheck", "DistanceCheck")
	Slider(p, "MaxDistance", "Max Distance", 50, 5000, 50)
	Toggle(p, "HealthCheck", "HealthCheck")
	Slider(p, "HealthMin", "Min Health %", 1, 100, 1)
	Toggle(p, "NPCCheck", "NPCCheck")
	Toggle(p, "BotCheck", "BotCheck")
	Toggle(p, "AFKCheck", "AFKCheck")
	Toggle(p, "SafeZoneCheck", "SafeZoneCheck")
	Toggle(p, "FOVCheck", "FOVCheck")
	Toggle(p, "VehicleCheck", "VehicleCheck")
end

-- 6) Çeşitli & Sistem
do
	local p = newTab("Çeşitli & Sistem")
	Slider(p, "YawOffset", "YawOffset", -180, 180, 1)
	Slider(p, "NetworkDelay", "NetworkDelay (ms)", 0, 300, 5)
	Slider(p, "StateOffset", "StateOffset (studs)", -5, 5, 0.1)
	Toggle(p, "HitAudio", "HitAudio")
	Toggle(p, "KillAudio", "KillAudio")
	Toggle(p, "HitIndicator", "HitIndicator")
	Toggle(p, "Crosshair", "Crosshair", true)
	Slider(p, "CrosshairSize", "Crosshair Size", 4, 30, 1)
	Toggle(p, "CameraFOVOn", "CameraFOV")
	Slider(p, "CameraFOV", "CameraFOV Value", 30, 120, 1)
	Toggle(p, "FrameRate", "FrameRate")
	Toggle(p, "AutoRespawn", "AutoRespawn")
	Toggle(p, "Spectate", "Spectate", true)
	Keybind(p, "MenuKey", "Menu Key")
	Button(p, "ProfileSave", saveProfile)
	Button(p, "Load Profile", loadProfile)
	Button(p, "ResetAll", resetAll)
end

-- 7) Karakter & Dünya
do
	local p = newTab("Karakter & Dünya")
	Toggle(p, "CharacterVisual", "CharacterVisual")
	Toggle(p, "HeadVisual", "HeadVisual")
	Toggle(p, "BodyVisual", "BodyVisual")
	Toggle(p, "HandVisual", "HandVisual")
	Toggle(p, "LegVisual", "LegVisual")
	Toggle(p, "OutfitInfo", "OutfitInfo")
	Toggle(p, "AvatarInfo", "AvatarInfo")
	Toggle(p, "PlayerHighlight", "Highlight")
	Toggle(p, "Chams", "Chams")
	Toggle(p, "WorldVisual", "WorldVisual")
	Toggle(p, "ObjectVisual", "ObjectVisual")
	Toggle(p, "DoorVisual", "DoorVisual")
	Toggle(p, "LootVisual", "LootVisual")
	TextInput(p, "WeaponSearch", "WeaponSearch", "tool name")
	TextInput(p, "ItemSearch", "ItemSearch", "item name")
	Toggle(p, "Radar", "Radar", true)
	Toggle(p, "Minimap", "Minimap")
	Slider(p, "RadarRange", "Radar / Minimap Range", 30, 600, 10)
	Toggle(p, "Fullbright", "Fullbright", true)
	Toggle(p, "NoFog", "NoFog")
	Toggle(p, "NightVision", "NightVision", true)
end

-- 8) Hedef Seçimi
do
	local p = newTab("Hedef Seçimi")
	PlayerDD = Dropdown(p, "SelectedPlayer", "Target Player", { "Auto" })
	Dropdown(p, "AimPart", "TargetPart", { "Head", "Torso", "HumanoidRootPart", "Closest To Cursor" })
	Dropdown(p, "PriorityMode", "PriorityMode", { "Crosshair", "Distance", "Lowest Health", "Highest Health" })
	Slider(p, "MaxDistance", "MaxDistance", 50, 5000, 50)
	Dropdown(p, "TeamMode", "TeamMode", { "All", "Enemies", "Teammates" })
	Dropdown(p, "VisibilityMode", "VisibilityMode", { "Any", "Visible Only", "Hidden Only" })
	Dropdown(p, "HealthMode", "HealthMode", { "Any", "Low (<50%)", "High (>=50%)" })
	Dropdown(p, "BehaviorMode", "BehaviorMode", { "Any", "Moving", "Stationary" })
	Dropdown(p, "FilterMode", "FilterMode", { "Off", "Whitelist", "Blacklist" })
	TextInput(p, "IgnoreList", "IgnoreList")
	TextInput(p, "Whitelist", "Whitelist")
	TextInput(p, "Blacklist", "Blacklist")
	Button(p, "Teleport To Target", teleportToTarget)
end

showTab(1)

----------------------------------------------------------------------
-- LIVE PLAYER LIST
----------------------------------------------------------------------
local function refreshPlayerList(exclude)
	local names = { "Auto" }
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl ~= exclude then table.insert(names, pl.Name) end
	end
	PlayerDD.setOptions(names)
	if S.SelectedPlayer ~= "Auto" and not table.find(names, S.SelectedPlayer) then
		setting("SelectedPlayer", "Auto")
	end
end
Players.PlayerAdded:Connect(function() refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(pl) refreshPlayerList(pl) end)
refreshPlayerList()

----------------------------------------------------------------------
-- GLOBAL INPUT (binds, menu, capture)
----------------------------------------------------------------------
local function toggleWindow() Window.Visible = not Window.Visible end

UserInputService.InputBegan:Connect(function(input, gp)
	if capturing then
		local c = capturing
		if input.UserInputType == Enum.UserInputType.Keyboard then
			capturing = nil
			setBind(c.key, input.KeyCode == Enum.KeyCode.Escape and "" or input.KeyCode.Name)
		elseif c.allowMouse and (input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3) then
			capturing = nil
			setBind(c.key, input.UserInputType.Name)
		end
		return
	end
	if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local name = input.KeyCode.Name
	if name == B.MenuKey then toggleWindow() return end
	for key in pairs(ToggleKeys) do
		if B[key] == name then setting(key, not S[key]) end
	end
	if S.ClickTP and B.TeleKey == name then clickTeleport() end
end)

-- Mobil / dokunmatik icin yuzen buton
local Fab = mk("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(36, 36),
	BackgroundColor3 = C.accent, Text = "S", TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 18,
	BorderSizePixel = 0, ZIndex = 5,
}, UIGui)
corner(Fab, 18)
Fab.MouseButton1Click:Connect(toggleWindow)

UI.notify("saksak yüklendi  •  Menü: " .. B.MenuKey)
print("[saksak] panel hazır")
