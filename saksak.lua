local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local State = {
    KeyCounter = 0,
    Aimbot = {
        Aimbot = false, SilentAim = false, LegitAim = false, RageAim = false,
        TargetLock = false, AutoShoot = false, Triggerbot = false, SmoothAim = false,
        FOV = false, AimPrediction = false, AimBone = "Head", NearestTarget = false,
        TargetSwitch = false, VisibleCheck = true, TeamCheck = true, FriendCheck = true,
        DeathCheck = true, KnockedCheck = true
    },
    ESP = {
        PlayerESP = false, BoxESP = false, SkeletonESP = false, NameESP = false,
        HealthESP = false, DistanceESP = false, TracerESP = false, Box2D = false,
        Box3D = false, HeadESP = false, Snaplines = false, Chams = false,
        GlowESP = false, ItemESP = false, WeaponESP = false, EnemyOnly = true,
        VisibleOnly = false
    },
    Movement = {
        SpeedHack = false, FlyHack = false, InfiniteJump = false, NoClip = false,
        Teleport = false, SuperJump = false, NoSlow = false, AirWalk = false,
        GravityHack = false, Spinbot = false, BunnyHop = false, AntiFall = false
    },
    Weapon = {
        NoRecoil = false, NoSpread = false, RapidFire = false, FastReload = false,
        InfiniteAmmo = false, NoReload = false, DamageModifier = false,
        HitboxExpander = false, MeleeAura = false, AutoKill = false
    },
    Checks = {
        TeamCheck = true, FriendCheck = true, EnemyCheck = true, AliveCheck = true,
        DeadCheck = true, VisibilityCheck = true, WallCheck = true, DistanceCheck = false,
        HealthCheck = false, NPCCheck = false, BotCheck = false, AFKCheck = false,
        SafeZoneCheck = false, FOVCheck = true, VehicleCheck = false
    },
    Misc = {
        AntiAim = false, FakeLag = false, Desync = false, HitSound = false,
        KillSound = false, HitMarker = false, CrosshairChanger = false,
        FOVChanger = false, FPSUnlocker = false, AutoRespawn = false,
        SpectatorMode = false, ConfigSystem = false, PanicButton = false
    },
    Character = {
        CharacterESP = false, HeadESP = false, BodyESP = false, HandESP = false,
        LegESP = false, OutfitESP = false, AvatarESP = false, PlayerHighlight = false,
        PlayerChams = false
    },
    World = {
        WorldESP = false, ObjectESP = false, DoorESP = false, LootESP = false,
        WeaponFinder = false, ItemFinder = false, Radar = false, Minimap = false,
        Fullbright = false, NoFog = false, NightVision = false
    },
    TargetSet = {
        TargetPart = "Head", TargetPriority = "Closest", TargetDistance = 250,
        TargetTeam = "Enemies", TargetVisibility = true, TargetHealth = "Lowest",
        TargetMode = "Standard", TargetFilter = "Standard", TargetIgnoreList = "",
        TargetWhitelist = "", TargetBlacklist = ""
    }
}

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "RayfieldCustomKeysGui"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local SpawnedKeys = {}

local function createKey(id, label, onToggle)
    if SpawnedKeys[id] then return SpawnedKeys[id].Btn end
    State.KeyCounter += 1
    local idx = State.KeyCounter

    local btn = Instance.new("TextButton")
    btn.Name = "Key_" .. id
    btn.Size = UDim2.new(0, 88, 0, 38)
    btn.Position = UDim2.new(0.14 + ((idx % 5) * 0.14), 0, 0.22 + (math.floor(idx / 5) * 0.08), 0)
    btn.BackgroundColor3 = Color3.fromRGB(115, 118, 125)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = label
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Active = true
    btn.Draggable = true
    btn.Parent = KeyGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local lockBox = Instance.new("Frame")
    lockBox.Size = UDim2.new(0, 12, 0, 12)
    lockBox.Position = UDim2.new(1, -12, 1, -12)
    lockBox.BackgroundColor3 = Color3.fromRGB(145, 145, 150)
    lockBox.BorderSizePixel = 0
    lockBox.Parent = btn
    Instance.new("UICorner", lockBox).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(165, 168, 175)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    local rec = { Btn = btn, Locked = false, Active = false }
    SpawnedKeys[id] = rec

    btn.MouseButton1Click:Connect(function()
        rec.Active = not rec.Active
        if not rec.Locked then
            btn.BackgroundColor3 = rec.Active and Color3.fromRGB(80, 95, 110) or Color3.fromRGB(115, 118, 125)
        else
            lockBox.BackgroundColor3 = rec.Active and Color3.fromRGB(255, 225, 45) or Color3.fromRGB(205, 165, 15)
        end
        if onToggle then onToggle(rec.Active) end
    end)

    local holdToken = 0
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdToken += 1
            local tok = holdToken
            task.delay(3, function()
                if tok == holdToken then
                    rec.Locked = not rec.Locked
                    btn.Active = not rec.Locked
                    btn.Draggable = not rec.Locked
                    if rec.Locked then
                        lockBox.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                        stroke.Color = Color3.fromRGB(255, 215, 0)
                        stroke.Thickness = 2.5
                    else
                        lockBox.BackgroundColor3 = Color3.fromRGB(145, 145, 150)
                        stroke.Color = Color3.fromRGB(165, 168, 175)
                        stroke.Thickness = 1.5
                    end
                end
            end)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdToken += 1
        end
    end)

    return btn
end

local function removeKey(id)
    local rec = SpawnedKeys[id]
    if rec and rec.Btn then
        rec.Btn:Destroy()
        SpawnedKeys[id] = nil
    end
end

local function addOpt(tab, title, id, tbl, field, cb)
    tab:CreateToggle({
        Name = title,
        CurrentValue = tbl[field] == true,
        Callback = function(v)
            tbl[field] = v
            if SpawnedKeys[id] then SpawnedKeys[id].Active = v end
            if cb then cb(v) end
        end
    })
    tab:CreateButton({
        Name = "TUS +  (" .. title .. ")",
        Callback = function()
            createKey(id, title, function(st)
                tbl[field] = st
                if cb then cb(st) end
            end)
        end
    })
    tab:CreateButton({
        Name = "TUS -  (" .. title .. ")",
        Callback = function() removeKey(id) end
    })
end

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Hub",
    LoadingTitle = "Yukleniyor...",
    LoadingSubtitle = "Tum Ozellikler + TUS + / TUS -",
    ConfigurationSaving = { Enabled = false }
})

-- 1. AIMBOT / TARGETING
local T1 = Window:CreateTab("Aimbot", 4483362458)
addOpt(T1, "Aimbot", "a1", State.Aimbot, "Aimbot")
addOpt(T1, "Silent Aim", "a2", State.Aimbot, "SilentAim")
addOpt(T1, "Legit Aim", "a3", State.Aimbot, "LegitAim")
addOpt(T1, "Rage Aim", "a4", State.Aimbot, "RageAim")
addOpt(T1, "Target Lock", "a5", State.Aimbot, "TargetLock")
addOpt(T1, "Auto Shoot", "a6", State.Aimbot, "AutoShoot")
addOpt(T1, "Triggerbot", "a7", State.Aimbot, "Triggerbot")
addOpt(T1, "Smooth Aim", "a8", State.Aimbot, "SmoothAim")
addOpt(T1, "FOV", "a9", State.Aimbot, "FOV")
addOpt(T1, "Aim Prediction", "a10", State.Aimbot, "AimPrediction")
addOpt(T1, "Nearest Target", "a11", State.Aimbot, "NearestTarget")
addOpt(T1, "Target Switch", "a12", State.Aimbot, "TargetSwitch")
addOpt(T1, "Visible Check", "a13", State.Aimbot, "VisibleCheck")
addOpt(T1, "Team Check", "a14", State.Aimbot, "TeamCheck")
addOpt(T1, "Friend Check", "a15", State.Aimbot, "FriendCheck")
addOpt(T1, "Death Check", "a16", State.Aimbot, "DeathCheck")
addOpt(T1, "Knocked Check", "a17", State.Aimbot, "KnockedCheck")
T1:CreateDropdown({
    Name = "Aim Bone",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) State.Aimbot.AimBone = o[1] end
})

-- 2. ESP / VISUALS
local T2 = Window:CreateTab("ESP", 4483362458)
addOpt(T2, "Player ESP", "e1", State.ESP, "PlayerESP")
addOpt(T2, "Box ESP", "e2", State.ESP, "BoxESP")
addOpt(T2, "Skeleton ESP", "e3", State.ESP, "SkeletonESP")
addOpt(T2, "Name ESP", "e4", State.ESP, "NameESP")
addOpt(T2, "Health ESP", "e5", State.ESP, "HealthESP")
addOpt(T2, "Distance ESP", "e6", State.ESP, "DistanceESP")
addOpt(T2, "Tracer ESP", "e7", State.ESP, "TracerESP")
addOpt(T2, "2D Box", "e8", State.ESP, "Box2D")
addOpt(T2, "3D Box", "e9", State.ESP, "Box3D")
addOpt(T2, "Head ESP", "e10", State.ESP, "HeadESP")
addOpt(T2, "Snaplines", "e11", State.ESP, "Snaplines")
addOpt(T2, "Chams", "e12", State.ESP, "Chams")
addOpt(T2, "Glow ESP", "e13", State.ESP, "GlowESP")
addOpt(T2, "Item ESP", "e14", State.ESP, "ItemESP")
addOpt(T2, "Weapon ESP", "e15", State.ESP, "WeaponESP")
addOpt(T2, "Enemy Only", "e16", State.ESP, "EnemyOnly")
addOpt(T2, "Visible Only", "e17", State.ESP, "VisibleOnly")

-- 3. MOVEMENT
local T3 = Window:CreateTab("Movement", 4483362458)
addOpt(T3, "Speed Hack", "m1", State.Movement, "SpeedHack")
addOpt(T3, "Fly Hack", "m2", State.Movement, "FlyHack")
addOpt(T3, "Infinite Jump", "m3", State.Movement, "InfiniteJump")
addOpt(T3, "No Clip", "m4", State.Movement, "NoClip")
addOpt(T3, "Teleport", "m5", State.Movement, "Teleport")
addOpt(T3, "Super Jump", "m6", State.Movement, "SuperJump")
addOpt(T3, "No Slow", "m7", State.Movement, "NoSlow")
addOpt(T3, "Air Walk", "m8", State.Movement, "AirWalk")
addOpt(T3, "Gravity Hack", "m9", State.Movement, "GravityHack")
addOpt(T3, "Spinbot", "m10", State.Movement, "Spinbot")
addOpt(T3, "Bunny Hop", "m11", State.Movement, "BunnyHop")
addOpt(T3, "Anti Fall", "m12", State.Movement, "AntiFall")
-- 4. WEAPON / COMBAT
local T4 = Window:CreateTab("Weapon", 4483362458)
addOpt(T4, "No Recoil", "w1", State.Weapon, "NoRecoil")
addOpt(T4, "No Spread", "w2", State.Weapon, "NoSpread")
addOpt(T4, "Rapid Fire", "w3", State.Weapon, "RapidFire")
addOpt(T4, "Fast Reload", "w4", State.Weapon, "FastReload")
addOpt(T4, "Infinite Ammo", "w5", State.Weapon, "InfiniteAmmo")
addOpt(T4, "No Reload", "w6", State.Weapon, "NoReload")
addOpt(T4, "Damage Modifier", "w7", State.Weapon, "DamageModifier")
addOpt(T4, "Hitbox Expander", "w8", State.Weapon, "HitboxExpander")
addOpt(T4, "Melee Aura", "w9", State.Weapon, "MeleeAura")
addOpt(T4, "Auto Kill", "w10", State.Weapon, "AutoKill")

-- 5. CHECKS / FILTERS
local T5 = Window:CreateTab("Checks", 4483362458)
addOpt(T5, "Team Check", "c1", State.Checks, "TeamCheck")
addOpt(T5, "Friend Check", "c2", State.Checks, "FriendCheck")
addOpt(T5, "Enemy Check", "c3", State.Checks, "EnemyCheck")
addOpt(T5, "Alive Check", "c4", State.Checks, "AliveCheck")
addOpt(T5, "Dead Check", "c5", State.Checks, "DeadCheck")
addOpt(T5, "Visibility Check", "c6", State.Checks, "VisibilityCheck")
addOpt(T5, "Wall Check", "c7", State.Checks, "WallCheck")
addOpt(T5, "Distance Check", "c8", State.Checks, "DistanceCheck")
addOpt(T5, "Health Check", "c9", State.Checks, "HealthCheck")
addOpt(T5, "NPC Check", "c10", State.Checks, "NPCCheck")
addOpt(T5, "Bot Check", "c11", State.Checks, "BotCheck")
addOpt(T5, "AFK Check", "c12", State.Checks, "AFKCheck")
addOpt(T5, "Safe Zone Check", "c13", State.Checks, "SafeZoneCheck")
addOpt(T5, "FOV Check", "c14", State.Checks, "FOVCheck")
addOpt(T5, "Vehicle Check", "c15", State.Checks, "VehicleCheck")

-- 6. MISC / OTHER
local T6 = Window:CreateTab("Misc", 4483362458)
addOpt(T6, "Anti-Aim", "x1", State.Misc, "AntiAim")
addOpt(T6, "Fake Lag", "x2", State.Misc, "FakeLag")
addOpt(T6, "Desync", "x3", State.Misc, "Desync")
addOpt(T6, "Hit Sound", "x4", State.Misc, "HitSound")
addOpt(T6, "Kill Sound", "x5", State.Misc, "KillSound")
addOpt(T6, "Hit Marker", "x6", State.Misc, "HitMarker")
addOpt(T6, "Crosshair Changer", "x7", State.Misc, "CrosshairChanger")
addOpt(T6, "FOV Changer", "x8", State.Misc, "FOVChanger")
addOpt(T6, "FPS Unlocker", "x9", State.Misc, "FPSUnlocker")
addOpt(T6, "Auto Respawn", "x10", State.Misc, "AutoRespawn")
addOpt(T6, "Spectator Mode", "x11", State.Misc, "SpectatorMode")
addOpt(T6, "Config System", "x12", State.Misc, "ConfigSystem")
addOpt(T6, "Panic Button", "x13", State.Misc, "PanicButton", function(on)
    if on then
        for _, grp in pairs(State) do
            if type(grp) == "table" then
                for k, v in pairs(grp) do
                    if type(v) == "boolean" then grp[k] = false end
                end
            end
        end
    end
end)

-- 7. PLAYER / CHARACTER
local T7 = Window:CreateTab("Character", 4483362458)
addOpt(T7, "Character ESP", "p1", State.Character, "CharacterESP")
addOpt(T7, "Head ESP", "p2", State.Character, "HeadESP")
addOpt(T7, "Body ESP", "p3", State.Character, "BodyESP")
addOpt(T7, "Hand ESP", "p4", State.Character, "HandESP")
addOpt(T7, "Leg ESP", "p5", State.Character, "LegESP")
addOpt(T7, "Outfit ESP", "p6", State.Character, "OutfitESP")
addOpt(T7, "Avatar ESP", "p7", State.Character, "AvatarESP")
addOpt(T7, "Player Highlight", "p8", State.Character, "PlayerHighlight")
addOpt(T7, "Player Chams", "p9", State.Character, "PlayerChams")

-- 8. WORLD / ENVIRONMENT
local T8 = Window:CreateTab("World", 4483362458)
addOpt(T8, "World ESP", "d1", State.World, "WorldESP")
addOpt(T8, "Object ESP", "d2", State.World, "ObjectESP")
addOpt(T8, "Door ESP", "d3", State.World, "DoorESP")
addOpt(T8, "Loot ESP", "d4", State.World, "LootESP")
addOpt(T8, "Weapon Finder", "d5", State.World, "WeaponFinder")
addOpt(T8, "Item Finder", "d6", State.World, "ItemFinder")
addOpt(T8, "Radar", "d7", State.World, "Radar")
addOpt(T8, "Minimap", "d8", State.World, "Minimap")
addOpt(T8, "Fullbright", "d9", State.World, "Fullbright", function(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)
addOpt(T8, "No Fog", "d10", State.World, "NoFog", function(on)
    if on then Lighting.FogEnd = 1e6 end
end)
addOpt(T8, "Night Vision", "d11", State.World, "NightVision", function(on)
    Lighting.Ambient = on and Color3.fromRGB(70, 220, 120) or Color3.fromRGB(0, 0, 0)
end)

-- 9. TARGET SETTINGS
local T9 = Window:CreateTab("TargetSet", 4483362458)
T9:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) State.TargetSet.TargetPart = o[1] end
})
T9:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest", "LowestHealth", "FOV"},
    CurrentOption = {"Closest"},
    Callback = function(o) State.TargetSet.TargetPriority = o[1] end
})
T9:CreateSlider({
    Name = "Target Distance",
    Range = {20, 1000},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) State.TargetSet.TargetDistance = v end
})
T9:CreateDropdown({
    Name = "Target Team",
    Options = {"Enemies", "All", "NonTeam"},
    CurrentOption = {"Enemies"},
    Callback = function(o) State.TargetSet.TargetTeam = o[1] end
})
addOpt(T9, "Target Visibility", "t1", State.TargetSet, "TargetVisibility")
T9:CreateDropdown({
    Name = "Target Health",
    Options = {"Lowest", "Highest", "Any"},
    CurrentOption = {"Lowest"},
    Callback = function(o) State.TargetSet.TargetHealth = o[1] end
})
T9:CreateDropdown({
    Name = "Target Mode",
    Options = {"Standard", "Aggressive", "Legit"},
    CurrentOption = {"Standard"},
    Callback = function(o) State.TargetSet.TargetMode = o[1] end
})
T9:CreateDropdown({
    Name = "Target Filter",
    Options = {"Standard", "WhitelistOnly", "BlacklistSkip"},
    CurrentOption = {"Standard"},
    Callback = function(o) State.TargetSet.TargetFilter = o[1] end
})
T9:CreateInput({
    Name = "Target Ignore List",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.TargetSet.TargetIgnoreList = t end
})
T9:CreateInput({
    Name = "Target Whitelist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.TargetSet.TargetWhitelist = t end
})
T9:CreateInput({
    Name = "Target Blacklist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.TargetSet.TargetBlacklist = t end
})
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if (State.Aimbot.TeamCheck or State.Checks.TeamCheck) and LocalPlayer.Team and plr.Team then
        return plr.Team ~= LocalPlayer.Team
    end
    return true
end

local function isFriend(plr)
    if not plr then return false end
    local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
    return ok and res or false
end

local function isInList(name, csv)
    if not csv or csv == "" then return false end
    local target = name:lower()
    for item in string.gmatch(csv, "[^,]+") do
        if item:gsub("^%s+", ""):gsub("%s+$", ""):lower() == target then
            return true
        end
    end
    return false
end

local function pickTarget()
    local chosen = nil
    local bestDist = math.huge
    local maxDist = State.TargetSet.TargetDistance or 250
    local partName = State.TargetSet.TargetPart or State.Aimbot.AimBone or "Head"
    local filterMode = State.TargetSet.TargetFilter

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if isInList(plr.Name, State.TargetSet.TargetIgnoreList) then continue end
            if filterMode == "WhitelistOnly" and not isInList(plr.Name, State.TargetSet.TargetWhitelist) then continue end
            if filterMode == "BlacklistSkip" and isInList(plr.Name, State.TargetSet.TargetBlacklist) then continue end

            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")

            local aliveOk = not State.Checks.AliveCheck or (hum and hum.Health > 0)
            local enemyOk = not (State.ESP.EnemyOnly or State.Checks.EnemyCheck) or isEnemy(plr)
            local friendOk = not ((State.Aimbot.FriendCheck or State.Checks.FriendCheck) and isFriend(plr))

            if aliveOk and enemyOk and friendOk and part and Camera then
                local d = (part.Position - Camera.CFrame.Position).Magnitude
                if d <= maxDist and d < bestDist then
                    bestDist = d
                    chosen = part
                end
            end
        end
    end
    return chosen
end

local activeHighlights = {}
local function refreshHighlights()
    local want = State.ESP.PlayerESP or State.ESP.Chams or State.ESP.GlowESP or State.Character.CharacterESP or State.Character.PlayerHighlight or State.Character.PlayerChams
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local show = want and (not State.ESP.EnemyOnly or isEnemy(plr))
            local hl = activeHighlights[plr]
            if show then
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.65
                    hl.OutlineTransparency = 0
                    hl.FillColor = isEnemy(plr) and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 220, 120)
                    hl.Parent = plr.Character
                    activeHighlights[plr] = hl
                end
            elseif hl then
                hl:Destroy()
                activeHighlights[plr] = nil
            end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    refreshHighlights()

    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if hum then
            if State.Movement.SpeedHack then hum.WalkSpeed = 32 end
            if State.Movement.SuperJump then hum.JumpPower = 85 end
        end

        if hrp and State.Movement.Spinbot then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
        end
    end

    if State.Aimbot.Aimbot or State.Aimbot.LegitAim or State.Aimbot.TargetLock then
        local target = pickTarget()
        if target and Camera then
            local alpha = State.Aimbot.LegitAim and 0.12 or (State.Aimbot.SmoothAim and 0.18 or 0.35)
            local goal = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
        end
    end
end)
