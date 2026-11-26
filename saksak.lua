local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Cfg = {
    AimType = "Smooth", -- "Legit", "Smooth", "Lock", "Rage"
    AimSmoothness = 0.20, -- 0.03 (cok yumusak) .. 1.00 (anlik)
    AimFOV = 160,
    AimPart = "Head",
    TargetPriority = "Closest", -- "Closest", "LowestHealth", "FOV"
    TargetTeamMode = "Enemies", -- "Enemies", "All", "NonTeam"
    TargetFilterMode = "Standard", -- "Standard", "WhitelistOnly", "BlacklistSkip"
    IgnoreList = "",
    Whitelist = "",
    Blacklist = "",
    WalkSpeedVal = 32,
    JumpPowerVal = 85,
    GravityVal = 75,
    FlySpeedVal = 50,
    FOVVal = 85,

    Aimbot = {
        Aimbot = false, SilentAim = false, LegitAim = false, RageAim = false,
        TargetLock = false, AutoShoot = false, Triggerbot = false, SmoothAim = false,
        FOV = false, AimPrediction = false, NearestTarget = false, TargetSwitch = false,
        VisibleCheck = true, TeamCheck = true, FriendCheck = true, DeathCheck = true,
        KnockedCheck = true
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
        TargetVisibility = true
    }
}

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "RayfieldWorkingKeys"
OverlayGui.ResetOnSpawn = false
OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
OverlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local KeyButtons = {}
local keyOrder = 0

local function setScreenKey(id, label, enabled, onPress)
    if enabled then
        if KeyButtons[id] then
            KeyButtons[id].Btn.Visible = true
            return
        end
        keyOrder += 1
        local idx = keyOrder

        local btn = Instance.new("TextButton")
        btn.Name = "Btn_" .. id
        btn.Size = UDim2.new(0, 90, 0, 38)
        btn.Position = UDim2.new(0.12 + ((idx % 5) * 0.15), 0, 0.20 + (math.floor(idx / 5) * 0.08), 0)
        btn.BackgroundColor3 = Color3.fromRGB(115, 118, 125) -- GRI (suruklenebilir)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = label
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.Active = true
        btn.Draggable = true
        btn.Parent = OverlayGui
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local lockDot = Instance.new("Frame")
        lockDot.Size = UDim2.new(0, 12, 0, 12)
        lockDot.Position = UDim2.new(1, -12, 1, -12)
        lockDot.BackgroundColor3 = Color3.fromRGB(145, 145, 150)
        lockDot.BorderSizePixel = 0
        lockDot.Parent = btn
        Instance.new("UICorner", lockDot).CornerRadius = UDim.new(0, 4)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(170, 172, 178)
        stroke.Thickness = 1.5
        stroke.Parent = btn

        local item = { Btn = btn, Locked = false, State = false }
        KeyButtons[id] = item

        btn.MouseButton1Click:Connect(function()
            item.State = not item.State
            if not item.Locked then
                btn.BackgroundColor3 = item.State and Color3.fromRGB(70, 120, 185) or Color3.fromRGB(115, 118, 125)
            else
                lockDot.BackgroundColor3 = item.State and Color3.fromRGB(255, 225, 40) or Color3.fromRGB(205, 165, 15)
            end
            if onPress then onPress(item.State) end
        end)

        local holdGen = 0
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                holdGen += 1
                local g = holdGen
                task.delay(3, function()
                    if g == holdGen then
                        item.Locked = not item.Locked
                        btn.Active = not item.Locked
                        btn.Draggable = not item.Locked
                        if item.Locked then
                            lockDot.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- SARI (sabitlendi)
                            stroke.Color = Color3.fromRGB(255, 215, 0)
                            stroke.Thickness = 2.5
                        else
                            lockDot.BackgroundColor3 = Color3.fromRGB(145, 145, 150) -- GRI (serbest)
                            stroke.Color = Color3.fromRGB(170, 172, 178)
                            stroke.Thickness = 1.5
                        end
                    end
                end)
            end
        end)

        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                holdGen += 1
            end
        end)
    else
        if KeyButtons[id] and KeyButtons[id].Btn then
            KeyButtons[id].Btn:Destroy()
            KeyButtons[id] = nil
        end
    end
end

-- Her ozellik icin ac/kapa toggle + yaninda/altinda o tusu ekrana ac/kapa yapan toggle
local function makeFeature(tab, name, id, tbl, field, onChange)
    tab:CreateToggle({
        Name = name,
        CurrentValue = tbl[field] == true,
        Callback = function(v)
            tbl[field] = v
            if KeyButtons[id] then KeyButtons[id].State = v end
            if onChange then onChange(v) end
        end
    })

    tab:CreateToggle({
        Name = name .. " [Ekran Tusu Ac/Kapa]",
        CurrentValue = false,
        Callback = function(showKey)
            setScreenKey(id, name, showKey, function(newState)
                tbl[field] = newState
                if onChange then onChange(newState) end
            end)
        end
    })
end

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Pro Hub",
    LoadingTitle = "Rayfield Yukleniyor...",
    LoadingSubtitle = "Calisan Sistem • Tur & Yumusaklik",
    ConfigurationSaving = { Enabled = false }
})
-- 1. AIMBOT / TARGETING
local T1 = Window:CreateTab("Aimbot", 4483362458)
T1:CreateDropdown({
    Name = "Aimbot Turu",
    Options = {"Legit", "Smooth", "Lock", "Rage"},
    CurrentOption = {"Smooth"},
    Callback = function(o) Cfg.AimType = o[1] end
})
T1:CreateSlider({
    Name = "Yumusaklik (Smoothness)",
    Range = {3, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v) Cfg.AimSmoothness = v / 100 end
})
T1:CreateSlider({
    Name = "FOV Yaricapi",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 160,
    Callback = function(v) Cfg.AimFOV = v end
})
T1:CreateDropdown({
    Name = "Aim Bone",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) Cfg.AimPart = o[1] end
})
makeFeature(T1, "Aimbot", "a1", Cfg.Aimbot, "Aimbot")
makeFeature(T1, "Silent Aim", "a2", Cfg.Aimbot, "SilentAim")
makeFeature(T1, "Legit Aim", "a3", Cfg.Aimbot, "LegitAim")
makeFeature(T1, "Rage Aim", "a4", Cfg.Aimbot, "RageAim")
makeFeature(T1, "Target Lock", "a5", Cfg.Aimbot, "TargetLock")
makeFeature(T1, "Auto Shoot", "a6", Cfg.Aimbot, "AutoShoot")
makeFeature(T1, "Triggerbot", "a7", Cfg.Aimbot, "Triggerbot")
makeFeature(T1, "Smooth Aim", "a8", Cfg.Aimbot, "SmoothAim")
makeFeature(T1, "FOV", "a9", Cfg.Aimbot, "FOV")
makeFeature(T1, "Aim Prediction", "a10", Cfg.Aimbot, "AimPrediction")
makeFeature(T1, "Nearest Target", "a11", Cfg.Aimbot, "NearestTarget")
makeFeature(T1, "Target Switch", "a12", Cfg.Aimbot, "TargetSwitch")
makeFeature(T1, "Visible Check", "a13", Cfg.Aimbot, "VisibleCheck")
makeFeature(T1, "Team Check", "a14", Cfg.Aimbot, "TeamCheck")
makeFeature(T1, "Friend Check", "a15", Cfg.Aimbot, "FriendCheck")
makeFeature(T1, "Death Check", "a16", Cfg.Aimbot, "DeathCheck")
makeFeature(T1, "Knocked Check", "a17", Cfg.Aimbot, "KnockedCheck")

-- 2. ESP / VISUALS
local T2 = Window:CreateTab("ESP", 4483362458)
makeFeature(T2, "Player ESP", "e1", Cfg.ESP, "PlayerESP")
makeFeature(T2, "Box ESP", "e2", Cfg.ESP, "BoxESP")
makeFeature(T2, "Skeleton ESP", "e3", Cfg.ESP, "SkeletonESP")
makeFeature(T2, "Name ESP", "e4", Cfg.ESP, "NameESP")
makeFeature(T2, "Health ESP", "e5", Cfg.ESP, "HealthESP")
makeFeature(T2, "Distance ESP", "e6", Cfg.ESP, "DistanceESP")
makeFeature(T2, "Tracer ESP", "e7", Cfg.ESP, "TracerESP")
makeFeature(T2, "2D Box", "e8", Cfg.ESP, "Box2D")
makeFeature(T2, "3D Box", "e9", Cfg.ESP, "Box3D")
makeFeature(T2, "Head ESP", "e10", Cfg.ESP, "HeadESP")
makeFeature(T2, "Snaplines", "e11", Cfg.ESP, "Snaplines")
makeFeature(T2, "Chams", "e12", Cfg.ESP, "Chams")
makeFeature(T2, "Glow ESP", "e13", Cfg.ESP, "GlowESP")
makeFeature(T2, "Item ESP", "e14", Cfg.ESP, "ItemESP")
makeFeature(T2, "Weapon ESP", "e15", Cfg.ESP, "WeaponESP")
makeFeature(T2, "Enemy Only", "e16", Cfg.ESP, "EnemyOnly")
makeFeature(T2, "Visible Only", "e17", Cfg.ESP, "VisibleOnly")

-- 3. MOVEMENT
local T3 = Window:CreateTab("Movement", 4483362458)
T3:CreateSlider({
    Name = "Speed Hizi",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 32,
    Callback = function(v) Cfg.WalkSpeedVal = v end
})
T3:CreateSlider({
    Name = "Super Jump Gucu",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 85,
    Callback = function(v) Cfg.JumpPowerVal = v end
})
T3:CreateSlider({
    Name = "Gravity Degeri",
    Range = {10, 196},
    Increment = 2,
    CurrentValue = 75,
    Callback = function(v)
        Cfg.GravityVal = v
        if Cfg.Movement.GravityHack then Workspace.Gravity = v end
    end
})
T3:CreateSlider({
    Name = "Fly Hizi",
    Range = {15, 150},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Cfg.FlySpeedVal = v end
})
makeFeature(T3, "Speed Hack", "m1", Cfg.Movement, "SpeedHack", function(v)
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = v and Cfg.WalkSpeedVal or 16 end
end)
makeFeature(T3, "Fly Hack", "m2", Cfg.Movement, "FlyHack")
makeFeature(T3, "Infinite Jump", "m3", Cfg.Movement, "InfiniteJump")
makeFeature(T3, "No Clip", "m4", Cfg.Movement, "NoClip")
makeFeature(T3, "Teleport", "m5", Cfg.Movement, "Teleport", function(v)
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local best, dMin = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dMin then dMin = d; best = p.Character.HumanoidRootPart end
            end
        end
        if best then hrp.CFrame = best.CFrame * CFrame.new(0, 0, -4) end
    end
end)
makeFeature(T3, "Super Jump", "m6", Cfg.Movement, "SuperJump", function(v)
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower = v and Cfg.JumpPowerVal or 50 end
end)
makeFeature(T3, "No Slow", "m7", Cfg.Movement, "NoSlow")
makeFeature(T3, "Air Walk", "m8", Cfg.Movement, "AirWalk")
makeFeature(T3, "Gravity Hack", "m9", Cfg.Movement, "GravityHack", function(v)
    Workspace.Gravity = v and Cfg.GravityVal or 196.2
end)
makeFeature(T3, "Spinbot", "m10", Cfg.Movement, "Spinbot")
makeFeature(T3, "Bunny Hop", "m11", Cfg.Movement, "BunnyHop")
makeFeature(T3, "Anti Fall", "m12", Cfg.Movement, "AntiFall")

-- 4. WEAPON / COMBAT
local T4 = Window:CreateTab("Weapon", 4483362458)
makeFeature(T4, "No Recoil", "w1", Cfg.Weapon, "NoRecoil")
makeFeature(T4, "No Spread", "w2", Cfg.Weapon, "NoSpread")
makeFeature(T4, "Rapid Fire", "w3", Cfg.Weapon, "RapidFire")
makeFeature(T4, "Fast Reload", "w4", Cfg.Weapon, "FastReload")
makeFeature(T4, "Infinite Ammo", "w5", Cfg.Weapon, "InfiniteAmmo")
makeFeature(T4, "No Reload", "w6", Cfg.Weapon, "NoReload")
makeFeature(T4, "Damage Modifier", "w7", Cfg.Weapon, "DamageModifier")
makeFeature(T4, "Hitbox Expander", "w8", Cfg.Weapon, "HitboxExpander")
makeFeature(T4, "Melee Aura", "w9", Cfg.Weapon, "MeleeAura")
makeFeature(T4, "Auto Kill", "w10", Cfg.Weapon, "AutoKill")

-- 5. CHECKS / FILTERS
local T5 = Window:CreateTab("Checks", 4483362458)
makeFeature(T5, "Team Check", "c1", Cfg.Checks, "TeamCheck")
makeFeature(T5, "Friend Check", "c2", Cfg.Checks, "FriendCheck")
makeFeature(T5, "Enemy Check", "c3", Cfg.Checks, "EnemyCheck")
makeFeature(T5, "Alive Check", "c4", Cfg.Checks, "AliveCheck")
makeFeature(T5, "Dead Check", "c5", Cfg.Checks, "DeadCheck")
makeFeature(T5, "Visibility Check", "c6", Cfg.Checks, "VisibilityCheck")
makeFeature(T5, "Wall Check", "c7", Cfg.Checks, "WallCheck")
makeFeature(T5, "Distance Check", "c8", Cfg.Checks, "DistanceCheck")
makeFeature(T5, "Health Check", "c9", Cfg.Checks, "HealthCheck")
makeFeature(T5, "NPC Check", "c10", Cfg.Checks, "NPCCheck")
makeFeature(T5, "Bot Check", "c11", Cfg.Checks, "BotCheck")
makeFeature(T5, "AFK Check", "c12", Cfg.Checks, "AFKCheck")
makeFeature(T5, "Safe Zone Check", "c13", Cfg.Checks, "SafeZoneCheck")
makeFeature(T5, "FOV Check", "c14", Cfg.Checks, "FOVCheck")
makeFeature(T5, "Vehicle Check", "c15", Cfg.Checks, "VehicleCheck")

-- 6. MISC / OTHER
local T6 = Window:CreateTab("Misc", 4483362458)
T6:CreateSlider({
    Name = "Kamera FOV Degeri",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = 85,
    Callback = function(v)
        Cfg.FOVVal = v
        if Cfg.Misc.FOVChanger and Camera then Camera.FieldOfView = v end
    end
})
makeFeature(T6, "Anti-Aim", "x1", Cfg.Misc, "AntiAim")
makeFeature(T6, "Fake Lag", "x2", Cfg.Misc, "FakeLag")
makeFeature(T6, "Desync", "x3", Cfg.Misc, "Desync")
makeFeature(T6, "Hit Sound", "x4", Cfg.Misc, "HitSound")
makeFeature(T6, "Kill Sound", "x5", Cfg.Misc, "KillSound")
makeFeature(T6, "Hit Marker", "x6", Cfg.Misc, "HitMarker")
makeFeature(T6, "Crosshair Changer", "x7", Cfg.Misc, "CrosshairChanger")
makeFeature(T6, "FOV Changer", "x8", Cfg.Misc, "FOVChanger", function(v)
    if Camera then Camera.FieldOfView = v and Cfg.FOVVal or 70 end
end)
makeFeature(T6, "FPS Unlocker", "x9", Cfg.Misc, "FPSUnlocker", function(v)
    if setfpscap then setfpscap(v and 240 or 60) end
end)
makeFeature(T6, "Auto Respawn", "x10", Cfg.Misc, "AutoRespawn")
makeFeature(T6, "Spectator Mode", "x11", Cfg.Misc, "SpectatorMode")
makeFeature(T6, "Config System", "x12", Cfg.Misc, "ConfigSystem")
makeFeature(T6, "Panic Button", "x13", Cfg.Misc, "PanicButton", function(on)
    if on then
        for k, grp in pairs(Cfg) do
            if type(grp) == "table" then
                for f, val in pairs(grp) do
                    if type(val) == "boolean" then grp[f] = false end
                end
            end
        end
        Workspace.Gravity = 196.2
        if Camera then Camera.FieldOfView = 70 end
    end
end)

-- 7. PLAYER / CHARACTER
local T7 = Window:CreateTab("Character", 4483362458)
makeFeature(T7, "Character ESP", "p1", Cfg.Character, "CharacterESP")
makeFeature(T7, "Head ESP", "p2", Cfg.Character, "HeadESP")
makeFeature(T7, "Body ESP", "p3", Cfg.Character, "BodyESP")
makeFeature(T7, "Hand ESP", "p4", Cfg.Character, "HandESP")
makeFeature(T7, "Leg ESP", "p5", Cfg.Character, "LegESP")
makeFeature(T7, "Outfit ESP", "p6", Cfg.Character, "OutfitESP")
makeFeature(T7, "Avatar ESP", "p7", Cfg.Character, "AvatarESP")
makeFeature(T7, "Player Highlight", "p8", Cfg.Character, "PlayerHighlight")
makeFeature(T7, "Player Chams", "p9", Cfg.Character, "PlayerChams")

-- 8. WORLD / ENVIRONMENT
local T8 = Window:CreateTab("World", 4483362458)
makeFeature(T8, "World ESP", "d1", Cfg.World, "WorldESP")
makeFeature(T8, "Object ESP", "d2", Cfg.World, "ObjectESP")
makeFeature(T8, "Door ESP", "d3", Cfg.World, "DoorESP")
makeFeature(T8, "Loot ESP", "d4", Cfg.World, "LootESP")
makeFeature(T8, "Weapon Finder", "d5", Cfg.World, "WeaponFinder")
makeFeature(T8, "Item Finder", "d6", Cfg.World, "ItemFinder")
makeFeature(T8, "Radar", "d7", Cfg.World, "Radar")
makeFeature(T8, "Minimap", "d8", Cfg.World, "Minimap")
makeFeature(T8, "Fullbright", "d9", Cfg.World, "Fullbright", function(v)
    if v then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)
makeFeature(T8, "No Fog", "d10", Cfg.World, "NoFog", function(v)
    Lighting.FogEnd = v and 1e6 or 500
end)
makeFeature(T8, "Night Vision", "d11", Cfg.World, "NightVision", function(v)
    Lighting.Ambient = v and Color3.fromRGB(65, 220, 120) or Color3.fromRGB(0, 0, 0)
end)

-- 9. TARGET SETTINGS
local T9 = Window:CreateTab("TargetSet", 4483362458)
T9:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) Cfg.AimPart = o[1] end
})
T9:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest", "LowestHealth", "FOV"},
    CurrentOption = {"Closest"},
    Callback = function(o) Cfg.TargetPriority = o[1] end
})
T9:CreateDropdown({
    Name = "Target Team",
    Options = {"Enemies", "All", "NonTeam"},
    CurrentOption = {"Enemies"},
    Callback = function(o) Cfg.TargetTeamMode = o[1] end
})
T9:CreateDropdown({
    Name = "Target Filter",
    Options = {"Standard", "WhitelistOnly", "BlacklistSkip"},
    CurrentOption = {"Standard"},
    Callback = function(o) Cfg.TargetFilterMode = o[1] end
})
makeFeature(T9, "Target Visibility", "t1", Cfg.TargetSet, "TargetVisibility")
T9:CreateInput({
    Name = "Target Ignore List",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) Cfg.IgnoreList = t end
})
T9:CreateInput({
    Name = "Target Whitelist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) Cfg.Whitelist = t end
})
T9:CreateInput({
    Name = "Target Blacklist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) Cfg.Blacklist = t end
})
local function inCsv(name, csv)
    if not csv or csv == "" then return false end
    local low = name:lower()
    for part in string.gmatch(csv, "[^,]+") do
        if part:gsub("^%s+", ""):gsub("%s+$", ""):lower() == low then
            return true
        end
    end
    return false
end

local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if Cfg.TargetTeamMode == "All" then return true end
    if (Cfg.Aimbot.TeamCheck or Cfg.Checks.TeamCheck) and LocalPlayer.Team and plr.Team then
        return plr.Team ~= LocalPlayer.Team
    end
    return true
end

local function isFriend(plr)
    if not plr then return false end
    local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
    return ok and res or false
end

local function isVisible(targetPart)
    if not Camera or not targetPart then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {}
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    if targetPart.Parent then table.insert(ignore, targetPart.Parent) end
    params.FilterDescendantsInstances = ignore

    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local hit = Workspace:Raycast(origin, dir, params)
    return hit == nil
end

local function getTarget()
    if not Camera then return nil end
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local bestPart = nil
    local bestMetric = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if inCsv(plr.Name, Cfg.IgnoreList) then continue end
            if Cfg.TargetFilterMode == "WhitelistOnly" and not inCsv(plr.Name, Cfg.Whitelist) then continue end
            if Cfg.TargetFilterMode == "BlacklistSkip" and inCsv(plr.Name, Cfg.Blacklist) then continue end

            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(Cfg.AimPart) or char:FindFirstChild("HumanoidRootPart")

            local aliveOk = not Cfg.Checks.AliveCheck or (hum and hum.Health > 0)
            local enemyOk = not (Cfg.ESP.EnemyOnly or Cfg.Checks.EnemyCheck) or isEnemy(plr)
            local friendOk = not ((Cfg.Aimbot.FriendCheck or Cfg.Checks.FriendCheck) and isFriend(plr))
            local visOk = not ((Cfg.Aimbot.VisibleCheck or Cfg.Checks.VisibilityCheck or Cfg.TargetSet.TargetVisibility) and not isVisible(part))

            if aliveOk and enemyOk and friendOk and visOk and part then
                local screenPt, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPt.Z > 0 then
                    local fovDist = (Vector2.new(screenPt.X, screenPt.Y) - center).Magnitude
                    if fovDist <= Cfg.AimFOV then
                        local metric = fovDist
                        if Cfg.TargetPriority == "Closest" then
                            metric = (part.Position - Camera.CFrame.Position).Magnitude
                        elseif Cfg.TargetPriority == "LowestHealth" and hum then
                            metric = hum.Health
                        end
                        if metric < bestMetric then
                            bestMetric = metric
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

local highlights = {}
local function updateESP()
    local espActive = Cfg.ESP.PlayerESP or Cfg.ESP.Chams or Cfg.ESP.GlowESP or Cfg.Character.CharacterESP or Cfg.Character.PlayerHighlight or Cfg.Character.PlayerChams
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local show = espActive and (not Cfg.ESP.EnemyOnly or isEnemy(plr))
            local hl = highlights[plr]
            if show then
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.65
                    hl.OutlineTransparency = 0
                    hl.Parent = plr.Character
                    highlights[plr] = hl
                end
                hl.FillColor = isEnemy(plr) and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(65, 220, 120)
            elseif hl then
                hl:Destroy()
                highlights[plr] = nil
            end
        end
    end
end

local airPart = Instance.new("Part")
airPart.Name = "AirWalkPlatform"
airPart.Size = Vector3.new(8, 1, 8)
airPart.Anchored = true
airPart.CanCollide = true
airPart.Transparency = 1
airPart.Parent = Workspace

UserInputService.JumpRequest:Connect(function()
    if Cfg.Movement.InfiniteJump or Cfg.Movement.BunnyHop then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    updateESP()

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if Cfg.Movement.SpeedHack then hum.WalkSpeed = Cfg.WalkSpeedVal end
        if Cfg.Movement.SuperJump then hum.JumpPower = Cfg.JumpPowerVal end
        if Cfg.Movement.NoSlow and hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
    end

    if char and Cfg.Movement.NoClip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if hrp then
        if Cfg.Movement.AirWalk then
            airPart.Position = hrp.Position - Vector3.new(0, 3.5, 0)
        else
            airPart.Position = Vector3.new(0, -5000, 0)
        end

        if Cfg.Movement.FlyHack then
            local moveDir = hum and hum.MoveDirection or Vector3.zero
            hrp.Velocity = moveDir * Cfg.FlySpeedVal + Vector3.new(0, 2, 0)
        end

        if Cfg.Movement.Spinbot or Cfg.Misc.AntiAim then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end

        if Cfg.Movement.AntiFall and hrp.AssemblyLinearVelocity.Y < -65 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -15, hrp.AssemblyLinearVelocity.Z)
        end
    end

    local aimOn = Cfg.Aimbot.Aimbot or Cfg.Aimbot.LegitAim or Cfg.Aimbot.RageAim or Cfg.Aimbot.TargetLock or Cfg.Aimbot.SmoothAim
    if aimOn and Camera then
        local target = getTarget()
        if target then
            local alpha = Cfg.Aimbot.LegitAim and 0.10
                or (Cfg.Aimbot.RageAim and 0.85)
                or (Cfg.Aimbot.TargetLock and 0.65)
                or Cfg.AimSmoothness
            if Cfg.AimType == "Legit" then alpha = math.min(alpha, 0.12)
            elseif Cfg.AimType == "Rage" then alpha = 0.90
            elseif Cfg.AimType == "Lock" then alpha = 0.65 end

            local goal = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(alpha, 0.02, 1))
        end
    end
end)
