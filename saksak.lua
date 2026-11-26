local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local State = {
    MenuMode = "BUTTON",
    TopNotchX = 0.5,
    KeybindCounter = 0,
    Sections = {
        AimbotTargeting = {
            Aimbot = false, SilentAim = false, LegitAim = false, RageAim = false,
            TargetLock = false, AutoShoot = false, Triggerbot = false, SmoothAim = false,
            FOV = false, AimPrediction = false, AimBone = "Head", NearestTarget = false,
            TargetSwitch = false, VisibleCheck = true, TeamCheck = true, FriendCheck = true,
            DeathCheck = true, KnockedCheck = true
        },
        EspVisuals = {
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
        WeaponCombat = {
            NoRecoil = false, NoSpread = false, RapidFire = false, FastReload = false,
            InfiniteAmmo = false, NoReload = false, DamageModifier = false,
            HitboxExpander = false, MeleeAura = false, AutoKill = false
        },
        ChecksFilters = {
            TeamCheck = true, FriendCheck = true, EnemyCheck = true, AliveCheck = true,
            DeadCheck = true, VisibilityCheck = true, WallCheck = true, DistanceCheck = false,
            HealthCheck = false, NPCCheck = false, BotCheck = false, AFKCheck = false,
            SafeZoneCheck = false, FOVCheck = true, VehicleCheck = false
        },
        MiscOther = {
            AntiAim = false, FakeLag = false, Desync = false, HitSound = false,
            KillSound = false, HitMarker = false, CrosshairChanger = false,
            FOVChanger = false, FPSUnlocker = false, AutoRespawn = false,
            SpectatorMode = false, ConfigSystem = false, PanicButton = false
        },
        PlayerCharacter = {
            CharacterESP = false, HeadESP = false, BodyESP = false, HandESP = false,
            LegESP = false, OutfitESP = false, AvatarESP = false, PlayerHighlight = false,
            PlayerChams = false
        },
        WorldEnvironment = {
            WorldESP = false, ObjectESP = false, DoorESP = false, LootESP = false,
            WeaponFinder = false, ItemFinder = false, Radar = false, Minimap = false,
            Fullbright = false, NoFog = false, NightVision = false
        },
        TargetSettings = {
            TargetPart = "Head", TargetPriority = "Closest", TargetDistance = 250,
            TargetTeam = "Enemies", TargetVisibility = true, TargetHealth = "Lowest",
            TargetMode = "Standard", TargetFilter = "Standard", TargetIgnoreList = "",
            TargetWhitelist = "", TargetBlacklist = ""
        },
        GuiMenu = {
            MobileMenu = true, RayfieldTemplate = true, TopNotch = false,
            ButtonMode = true, NotchPosition = 50
        }
    }
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalMobileKeybindOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TopNotchFrame = Instance.new("Frame")
TopNotchFrame.Size = UDim2.new(0, 190, 0, 34)
TopNotchFrame.Position = UDim2.new(State.TopNotchX, -95, 0, 6)
TopNotchFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TopNotchFrame.BorderSizePixel = 0
TopNotchFrame.Visible = false
TopNotchFrame.Parent = ScreenGui
Instance.new("UICorner", TopNotchFrame).CornerRadius = UDim.new(0, 14)

local notchStroke = Instance.new("UIStroke")
notchStroke.Color = Color3.fromRGB(95, 165, 255)
notchStroke.Thickness = 1.5
notchStroke.Parent = TopNotchFrame

local NotchLeftBtn = Instance.new("TextButton")
NotchLeftBtn.Size = UDim2.new(0.16, 0, 1, 0)
NotchLeftBtn.BackgroundTransparency = 1
NotchLeftBtn.Text = "<"
NotchLeftBtn.TextColor3 = Color3.fromRGB(160, 200, 255)
NotchLeftBtn.TextSize = 13
NotchLeftBtn.Font = Enum.Font.GothamBold
NotchLeftBtn.Parent = TopNotchFrame

local NotchToggleBtn = Instance.new("TextButton")
NotchToggleBtn.Size = UDim2.new(0.68, 0, 1, 0)
NotchToggleBtn.Position = UDim2.new(0.16, 0, 0, 0)
NotchToggleBtn.BackgroundTransparency = 1
NotchToggleBtn.Text = "NOTCH MENU"
NotchToggleBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
NotchToggleBtn.TextSize = 11
NotchToggleBtn.Font = Enum.Font.GothamBold
NotchToggleBtn.Parent = TopNotchFrame

local NotchRightBtn = Instance.new("TextButton")
NotchRightBtn.Size = UDim2.new(0.16, 0, 1, 0)
NotchRightBtn.Position = UDim2.new(0.84, 0, 0, 0)
NotchRightBtn.BackgroundTransparency = 1
NotchRightBtn.Text = ">"
NotchRightBtn.TextColor3 = Color3.fromRGB(160, 200, 255)
NotchRightBtn.TextSize = 13
NotchRightBtn.Font = Enum.Font.GothamBold
NotchRightBtn.Parent = TopNotchFrame

local MainFloatingBtn = Instance.new("TextButton")
MainFloatingBtn.Size = UDim2.new(0, 62, 0, 62)
MainFloatingBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
MainFloatingBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
MainFloatingBtn.Text = "HUB"
MainFloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainFloatingBtn.TextSize = 13
MainFloatingBtn.Font = Enum.Font.GothamBold
MainFloatingBtn.Active = true
MainFloatingBtn.Draggable = true
MainFloatingBtn.Parent = ScreenGui
Instance.new("UICorner", MainFloatingBtn).CornerRadius = UDim.new(1, 0)

local mainBtnStroke = Instance.new("UIStroke")
mainBtnStroke.Color = Color3.fromRGB(255, 215, 0)
mainBtnStroke.Thickness = 2
mainBtnStroke.Parent = MainFloatingBtn

local CreatedKeyButtons = {}

local function applyMenuMode()
    if State.MenuMode == "TOP_NOTCH" then
        TopNotchFrame.Visible = true
        MainFloatingBtn.Visible = false
        TopNotchFrame.Position = UDim2.new(State.TopNotchX, -95, 0, 6)
    else
        TopNotchFrame.Visible = false
        MainFloatingBtn.Visible = true
    end
end

NotchLeftBtn.MouseButton1Click:Connect(function()
    State.TopNotchX = math.clamp(State.TopNotchX - 0.08, 0.12, 0.88)
    State.Sections.GuiMenu.NotchPosition = math.floor(State.TopNotchX * 100)
    applyMenuMode()
end)

NotchRightBtn.MouseButton1Click:Connect(function()
    State.TopNotchX = math.clamp(State.TopNotchX + 0.08, 0.12, 0.88)
    State.Sections.GuiMenu.NotchPosition = math.floor(State.TopNotchX * 100)
    applyMenuMode()
end)

NotchToggleBtn.MouseButton1Click:Connect(function() Rayfield:Toggle() end)
MainFloatingBtn.MouseButton1Click:Connect(function() Rayfield:Toggle() end)

local function addKeybindButton(featureKey, displayLabel, onToggleCallback)
    if CreatedKeyButtons[featureKey] then
        return CreatedKeyButtons[featureKey].Button
    end

    State.KeybindCounter += 1
    local idx = State.KeybindCounter

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 86, 0, 38)
    keyBtn.Position = UDim2.new(0.15 + ((idx % 5) * 0.14), 0, 0.22 + (math.floor(idx / 5) * 0.08), 0)
    keyBtn.BackgroundColor3 = Color3.fromRGB(115, 118, 125)
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.Text = displayLabel
    keyBtn.TextSize = 10
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Active = true
    keyBtn.Draggable = true
    keyBtn.Parent = ScreenGui
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)

    local cornerBadge = Instance.new("Frame")
    cornerBadge.Size = UDim2.new(0, 12, 0, 12)
    cornerBadge.Position = UDim2.new(1, -12, 1, -12)
    cornerBadge.BackgroundColor3 = Color3.fromRGB(140, 140, 145)
    cornerBadge.BorderSizePixel = 0
    cornerBadge.Parent = keyBtn
    Instance.new("UICorner", cornerBadge).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(165, 168, 175)
    stroke.Thickness = 1.5
    stroke.Parent = keyBtn

    local entry = { Button = keyBtn, Locked = false, Active = false }
    CreatedKeyButtons[featureKey] = entry

    keyBtn.MouseButton1Click:Connect(function()
        entry.Active = not entry.Active
        if not entry.Locked then
            keyBtn.BackgroundColor3 = entry.Active and Color3.fromRGB(85, 95, 105) or Color3.fromRGB(115, 118, 125)
        else
            cornerBadge.BackgroundColor3 = entry.Active and Color3.fromRGB(255, 225, 40) or Color3.fromRGB(190, 155, 15)
        end
        if onToggleCallback then onToggleCallback(entry.Active) end
    end)

    local holdToken = 0
    keyBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdToken += 1
            local t = holdToken
            task.delay(3, function()
                if t == holdToken then
                    entry.Locked = not entry.Locked
                    keyBtn.Active = not entry.Locked
                    keyBtn.Draggable = not entry.Locked
                    if entry.Locked then
                        cornerBadge.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                        stroke.Color = Color3.fromRGB(255, 215, 0)
                        stroke.Thickness = 2.5
                    else
                        cornerBadge.BackgroundColor3 = Color3.fromRGB(140, 140, 145)
                        stroke.Color = Color3.fromRGB(165, 168, 175)
                        stroke.Thickness = 1.5
                    end
                end
            end)
        end
    end)

    keyBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdToken += 1
        end
    end)

    return keyBtn
end

local function removeKeybindButton(featureKey)
    local entry = CreatedKeyButtons[featureKey]
    if entry and entry.Button then
        entry.Button:Destroy()
        CreatedKeyButtons[featureKey] = nil
    end
end

local function addToggleWithKeyControls(tab, label, featureKey, tableRef, fieldName, onChanged)
    tab:CreateToggle({
        Name = label,
        CurrentValue = tableRef[fieldName] == true,
        Callback = function(val)
            tableRef[fieldName] = val
            if CreatedKeyButtons[featureKey] then CreatedKeyButtons[featureKey].Active = val end
            if onChanged then onChanged(val) end
        end
    })
    tab:CreateButton({
        Name = "TUS +  (" .. label .. ")",
        Callback = function()
            addKeybindButton(featureKey, label, function(newState)
                tableRef[fieldName] = newState
                if onChanged then onChanged(newState) end
            end)
        end
    })
    tab:CreateButton({
        Name = "TUS -  (" .. label .. ")",
        Callback = function() removeKeybindButton(featureKey) end
    })
end

local Window = Rayfield:CreateWindow({
    Name = "10-Section Mobile Hub",
    LoadingTitle = "10 Bolumlu Mobil Hub",
    LoadingSubtitle = "Top Notch • Button • TUS + / TUS -",
    ConfigurationSaving = { Enabled = false }
})
local Sec1 = Window:CreateTab("1.Aimbot", 4483362458)
local Sec2 = Window:CreateTab("2.ESP", 4483362458)
local Sec3 = Window:CreateTab("3.Movement", 4483362458)
local Sec4 = Window:CreateTab("4.Weapon", 4483362458)
local Sec5 = Window:CreateTab("5.Checks", 4483362458)

-- BOLUM 1: AIMBOT / TARGETING
addToggleWithKeyControls(Sec1, "Aimbot", "s1_aimbot", State.Sections.AimbotTargeting, "Aimbot")
addToggleWithKeyControls(Sec1, "Silent Aim", "s1_silent", State.Sections.AimbotTargeting, "SilentAim")
addToggleWithKeyControls(Sec1, "Legit Aim", "s1_legit", State.Sections.AimbotTargeting, "LegitAim")
addToggleWithKeyControls(Sec1, "Rage Aim", "s1_rage", State.Sections.AimbotTargeting, "RageAim")
addToggleWithKeyControls(Sec1, "Target Lock", "s1_lock", State.Sections.AimbotTargeting, "TargetLock")
addToggleWithKeyControls(Sec1, "Auto Shoot", "s1_autoshoot", State.Sections.AimbotTargeting, "AutoShoot")
addToggleWithKeyControls(Sec1, "Triggerbot", "s1_trigger", State.Sections.AimbotTargeting, "Triggerbot")
addToggleWithKeyControls(Sec1, "Smooth Aim", "s1_smooth", State.Sections.AimbotTargeting, "SmoothAim")
addToggleWithKeyControls(Sec1, "FOV", "s1_fov", State.Sections.AimbotTargeting, "FOV")
addToggleWithKeyControls(Sec1, "Aim Prediction", "s1_pred", State.Sections.AimbotTargeting, "AimPrediction")
addToggleWithKeyControls(Sec1, "Nearest Target", "s1_nearest", State.Sections.AimbotTargeting, "NearestTarget")
addToggleWithKeyControls(Sec1, "Target Switch", "s1_switch", State.Sections.AimbotTargeting, "TargetSwitch")
addToggleWithKeyControls(Sec1, "Visible Check", "s1_vis", State.Sections.AimbotTargeting, "VisibleCheck")
addToggleWithKeyControls(Sec1, "Team Check", "s1_team", State.Sections.AimbotTargeting, "TeamCheck")
addToggleWithKeyControls(Sec1, "Friend Check", "s1_friend", State.Sections.AimbotTargeting, "FriendCheck")
addToggleWithKeyControls(Sec1, "Death Check", "s1_death", State.Sections.AimbotTargeting, "DeathCheck")
addToggleWithKeyControls(Sec1, "Knocked Check", "s1_knock", State.Sections.AimbotTargeting, "KnockedCheck")
Sec1:CreateDropdown({
    Name = "Aim Bone",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) State.Sections.AimbotTargeting.AimBone = o[1] end
})

-- BOLUM 2: ESP / VISUALS
addToggleWithKeyControls(Sec2, "Player ESP", "s2_pesp", State.Sections.EspVisuals, "PlayerESP")
addToggleWithKeyControls(Sec2, "Box ESP", "s2_box", State.Sections.EspVisuals, "BoxESP")
addToggleWithKeyControls(Sec2, "Skeleton ESP", "s2_skel", State.Sections.EspVisuals, "SkeletonESP")
addToggleWithKeyControls(Sec2, "Name ESP", "s2_name", State.Sections.EspVisuals, "NameESP")
addToggleWithKeyControls(Sec2, "Health ESP", "s2_hp", State.Sections.EspVisuals, "HealthESP")
addToggleWithKeyControls(Sec2, "Distance ESP", "s2_dist", State.Sections.EspVisuals, "DistanceESP")
addToggleWithKeyControls(Sec2, "Tracer ESP", "s2_trace", State.Sections.EspVisuals, "TracerESP")
addToggleWithKeyControls(Sec2, "2D Box", "s2_2d", State.Sections.EspVisuals, "Box2D")
addToggleWithKeyControls(Sec2, "3D Box", "s2_3d", State.Sections.EspVisuals, "Box3D")
addToggleWithKeyControls(Sec2, "Head ESP", "s2_head", State.Sections.EspVisuals, "HeadESP")
addToggleWithKeyControls(Sec2, "Snaplines", "s2_snap", State.Sections.EspVisuals, "Snaplines")
addToggleWithKeyControls(Sec2, "Chams", "s2_chams", State.Sections.EspVisuals, "Chams")
addToggleWithKeyControls(Sec2, "Glow ESP", "s2_glow", State.Sections.EspVisuals, "GlowESP")
addToggleWithKeyControls(Sec2, "Item ESP", "s2_item", State.Sections.EspVisuals, "ItemESP")
addToggleWithKeyControls(Sec2, "Weapon ESP", "s2_weap", State.Sections.EspVisuals, "WeaponESP")
addToggleWithKeyControls(Sec2, "Enemy Only", "s2_enemy", State.Sections.EspVisuals, "EnemyOnly")
addToggleWithKeyControls(Sec2, "Visible Only", "s2_visonly", State.Sections.EspVisuals, "VisibleOnly")

-- BOLUM 3: MOVEMENT
addToggleWithKeyControls(Sec3, "Speed Hack", "s3_speed", State.Sections.Movement, "SpeedHack")
addToggleWithKeyControls(Sec3, "Fly Hack", "s3_fly", State.Sections.Movement, "FlyHack")
addToggleWithKeyControls(Sec3, "Infinite Jump", "s3_infjump", State.Sections.Movement, "InfiniteJump")
addToggleWithKeyControls(Sec3, "No Clip", "s3_noclip", State.Sections.Movement, "NoClip")
addToggleWithKeyControls(Sec3, "Teleport", "s3_tp", State.Sections.Movement, "Teleport")
addToggleWithKeyControls(Sec3, "Super Jump", "s3_superjump", State.Sections.Movement, "SuperJump")
addToggleWithKeyControls(Sec3, "No Slow", "s3_noslow", State.Sections.Movement, "NoSlow")
addToggleWithKeyControls(Sec3, "Air Walk", "s3_airwalk", State.Sections.Movement, "AirWalk")
addToggleWithKeyControls(Sec3, "Gravity Hack", "s3_grav", State.Sections.Movement, "GravityHack")
addToggleWithKeyControls(Sec3, "Spinbot", "s3_spin", State.Sections.Movement, "Spinbot")
addToggleWithKeyControls(Sec3, "Bunny Hop", "s3_bhop", State.Sections.Movement, "BunnyHop")
addToggleWithKeyControls(Sec3, "Anti Fall", "s3_antifall", State.Sections.Movement, "AntiFall")

-- BOLUM 4: WEAPON / COMBAT
addToggleWithKeyControls(Sec4, "No Recoil", "s4_recoil", State.Sections.WeaponCombat, "NoRecoil")
addToggleWithKeyControls(Sec4, "No Spread", "s4_spread", State.Sections.WeaponCombat, "NoSpread")
addToggleWithKeyControls(Sec4, "Rapid Fire", "s4_rapid", State.Sections.WeaponCombat, "RapidFire")
addToggleWithKeyControls(Sec4, "Fast Reload", "s4_fastrel", State.Sections.WeaponCombat, "FastReload")
addToggleWithKeyControls(Sec4, "Infinite Ammo", "s4_infammo", State.Sections.WeaponCombat, "InfiniteAmmo")
addToggleWithKeyControls(Sec4, "No Reload", "s4_norel", State.Sections.WeaponCombat, "NoReload")
addToggleWithKeyControls(Sec4, "Damage Modifier", "s4_dmg", State.Sections.WeaponCombat, "DamageModifier")
addToggleWithKeyControls(Sec4, "Hitbox Expander", "s4_hitbox", State.Sections.WeaponCombat, "HitboxExpander")
addToggleWithKeyControls(Sec4, "Melee Aura", "s4_melee", State.Sections.WeaponCombat, "MeleeAura")
addToggleWithKeyControls(Sec4, "Auto Kill", "s4_autokill", State.Sections.WeaponCombat, "AutoKill")

-- BOLUM 5: CHECKS / FILTERS
addToggleWithKeyControls(Sec5, "Team Check", "s5_team", State.Sections.ChecksFilters, "TeamCheck")
addToggleWithKeyControls(Sec5, "Friend Check", "s5_friend", State.Sections.ChecksFilters, "FriendCheck")
addToggleWithKeyControls(Sec5, "Enemy Check", "s5_enemy", State.Sections.ChecksFilters, "EnemyCheck")
addToggleWithKeyControls(Sec5, "Alive Check", "s5_alive", State.Sections.ChecksFilters, "AliveCheck")
addToggleWithKeyControls(Sec5, "Dead Check", "s5_dead", State.Sections.ChecksFilters, "DeadCheck")
addToggleWithKeyControls(Sec5, "Visibility Check", "s5_vis", State.Sections.ChecksFilters, "VisibilityCheck")
addToggleWithKeyControls(Sec5, "Wall Check", "s5_wall", State.Sections.ChecksFilters, "WallCheck")
addToggleWithKeyControls(Sec5, "Distance Check", "s5_dist", State.Sections.ChecksFilters, "DistanceCheck")
addToggleWithKeyControls(Sec5, "Health Check", "s5_hp", State.Sections.ChecksFilters, "HealthCheck")
addToggleWithKeyControls(Sec5, "NPC Check", "s5_npc", State.Sections.ChecksFilters, "NPCCheck")
addToggleWithKeyControls(Sec5, "Bot Check", "s5_bot", State.Sections.ChecksFilters, "BotCheck")
addToggleWithKeyControls(Sec5, "AFK Check", "s5_afk", State.Sections.ChecksFilters, "AFKCheck")
addToggleWithKeyControls(Sec5, "Safe Zone Check", "s5_safe", State.Sections.ChecksFilters, "SafeZoneCheck")
addToggleWithKeyControls(Sec5, "FOV Check", "s5_fov", State.Sections.ChecksFilters, "FOVCheck")
addToggleWithKeyControls(Sec5, "Vehicle Check", "s5_veh", State.Sections.ChecksFilters, "VehicleCheck")
local Sec6 = Window:CreateTab("6.Misc", 4483362458)
local Sec7 = Window:CreateTab("7.Character", 4483362458)
local Sec8 = Window:CreateTab("8.World", 4483362458)
local Sec9 = Window:CreateTab("9.TargetSet", 4483362458)
local Sec10 = Window:CreateTab("10.GUI/Menu", 4483362458)

-- BOLUM 6: MISC / OTHER
addToggleWithKeyControls(Sec6, "Anti-Aim", "s6_antiaim", State.Sections.MiscOther, "AntiAim")
addToggleWithKeyControls(Sec6, "Fake Lag", "s6_fakelag", State.Sections.MiscOther, "FakeLag")
addToggleWithKeyControls(Sec6, "Desync", "s6_desync", State.Sections.MiscOther, "Desync")
addToggleWithKeyControls(Sec6, "Hit Sound", "s6_hitsound", State.Sections.MiscOther, "HitSound")
addToggleWithKeyControls(Sec6, "Kill Sound", "s6_killsound", State.Sections.MiscOther, "KillSound")
addToggleWithKeyControls(Sec6, "Hit Marker", "s6_hitmark", State.Sections.MiscOther, "HitMarker")
addToggleWithKeyControls(Sec6, "Crosshair Changer", "s6_crosshair", State.Sections.MiscOther, "CrosshairChanger")
addToggleWithKeyControls(Sec6, "FOV Changer", "s6_fovchg", State.Sections.MiscOther, "FOVChanger")
addToggleWithKeyControls(Sec6, "FPS Unlocker", "s6_fps", State.Sections.MiscOther, "FPSUnlocker")
addToggleWithKeyControls(Sec6, "Auto Respawn", "s6_respawn", State.Sections.MiscOther, "AutoRespawn")
addToggleWithKeyControls(Sec6, "Spectator Mode", "s6_spec", State.Sections.MiscOther, "SpectatorMode")
addToggleWithKeyControls(Sec6, "Config System", "s6_cfg", State.Sections.MiscOther, "ConfigSystem")
addToggleWithKeyControls(Sec6, "Panic Button", "s6_panic", State.Sections.MiscOther, "PanicButton", function(active)
    if active then
        for _, sec in pairs(State.Sections) do
            for k, v in pairs(sec) do
                if type(v) == "boolean" then sec[k] = false end
            end
        end
    end
end)

-- BOLUM 7: PLAYER / CHARACTER
addToggleWithKeyControls(Sec7, "Character ESP", "s7_charesp", State.Sections.PlayerCharacter, "CharacterESP")
addToggleWithKeyControls(Sec7, "Head ESP", "s7_headesp", State.Sections.PlayerCharacter, "HeadESP")
addToggleWithKeyControls(Sec7, "Body ESP", "s7_bodyesp", State.Sections.PlayerCharacter, "BodyESP")
addToggleWithKeyControls(Sec7, "Hand ESP", "s7_handesp", State.Sections.PlayerCharacter, "HandESP")
addToggleWithKeyControls(Sec7, "Leg ESP", "s7_legesp", State.Sections.PlayerCharacter, "LegESP")
addToggleWithKeyControls(Sec7, "Outfit ESP", "s7_outfit", State.Sections.PlayerCharacter, "OutfitESP")
addToggleWithKeyControls(Sec7, "Avatar ESP", "s7_avatar", State.Sections.PlayerCharacter, "AvatarESP")
addToggleWithKeyControls(Sec7, "Player Highlight", "s7_hl", State.Sections.PlayerCharacter, "PlayerHighlight")
addToggleWithKeyControls(Sec7, "Player Chams", "s7_pchams", State.Sections.PlayerCharacter, "PlayerChams")

-- BOLUM 8: WORLD / ENVIRONMENT
addToggleWithKeyControls(Sec8, "World ESP", "s8_wesp", State.Sections.WorldEnvironment, "WorldESP")
addToggleWithKeyControls(Sec8, "Object ESP", "s8_oesp", State.Sections.WorldEnvironment, "ObjectESP")
addToggleWithKeyControls(Sec8, "Door ESP", "s8_door", State.Sections.WorldEnvironment, "DoorESP")
addToggleWithKeyControls(Sec8, "Loot ESP", "s8_loot", State.Sections.WorldEnvironment, "LootESP")
addToggleWithKeyControls(Sec8, "Weapon Finder", "s8_wfind", State.Sections.WorldEnvironment, "WeaponFinder")
addToggleWithKeyControls(Sec8, "Item Finder", "s8_ifind", State.Sections.WorldEnvironment, "ItemFinder")
addToggleWithKeyControls(Sec8, "Radar", "s8_radar", State.Sections.WorldEnvironment, "Radar")
addToggleWithKeyControls(Sec8, "Minimap", "s8_minimap", State.Sections.WorldEnvironment, "Minimap")
addToggleWithKeyControls(Sec8, "Fullbright", "s8_fullbright", State.Sections.WorldEnvironment, "Fullbright", function(v)
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)
addToggleWithKeyControls(Sec8, "No Fog", "s8_nofog", State.Sections.WorldEnvironment, "NoFog", function(v)
    if v then Lighting.FogEnd = 1e6 end
end)
addToggleWithKeyControls(Sec8, "Night Vision", "s8_nv", State.Sections.WorldEnvironment, "NightVision", function(v)
    Lighting.Ambient = v and Color3.fromRGB(70, 220, 120) or Color3.fromRGB(0, 0, 0)
end)

-- BOLUM 9: TARGET SETTINGS
Sec9:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(o) State.Sections.TargetSettings.TargetPart = o[1] end
})
Sec9:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest", "LowestHealth", "FOV"},
    CurrentOption = {"Closest"},
    Callback = function(o) State.Sections.TargetSettings.TargetPriority = o[1] end
})
Sec9:CreateSlider({
    Name = "Target Distance",
    Range = {20, 1000},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) State.Sections.TargetSettings.TargetDistance = v end
})
Sec9:CreateDropdown({
    Name = "Target Team",
    Options = {"Enemies", "All", "NonTeam"},
    CurrentOption = {"Enemies"},
    Callback = function(o) State.Sections.TargetSettings.TargetTeam = o[1] end
})
addToggleWithKeyControls(Sec9, "Target Visibility", "s9_vis", State.Sections.TargetSettings, "TargetVisibility")
Sec9:CreateDropdown({
    Name = "Target Health",
    Options = {"Lowest", "Highest", "Any"},
    CurrentOption = {"Lowest"},
    Callback = function(o) State.Sections.TargetSettings.TargetHealth = o[1] end
})
Sec9:CreateDropdown({
    Name = "Target Mode",
    Options = {"Standard", "Aggressive", "Legit"},
    CurrentOption = {"Standard"},
    Callback = function(o) State.Sections.TargetSettings.TargetMode = o[1] end
})
Sec9:CreateDropdown({
    Name = "Target Filter",
    Options = {"Standard", "WhitelistOnly", "BlacklistSkip"},
    CurrentOption = {"Standard"},
    Callback = function(o) State.Sections.TargetSettings.TargetFilter = o[1] end
})
Sec9:CreateInput({
    Name = "Target Ignore List",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.Sections.TargetSettings.TargetIgnoreList = t end
})
Sec9:CreateInput({
    Name = "Target Whitelist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.Sections.TargetSettings.TargetWhitelist = t end
})
Sec9:CreateInput({
    Name = "Target Blacklist",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) State.Sections.TargetSettings.TargetBlacklist = t end
})

-- BOLUM 10: GUI / MENU
addToggleWithKeyControls(Sec10, "MOBILE MENU", "s10_mobile", State.Sections.GuiMenu, "MobileMenu", function(v)
    ScreenGui.Enabled = v
end)
addToggleWithKeyControls(Sec10, "RAYFIELD SABLON", "s10_rayfield", State.Sections.GuiMenu, "RayfieldTemplate", function(v)
    if v then Rayfield:Toggle() end
end)
addToggleWithKeyControls(Sec10, "TOP NOTCH (Tavanda Sag-Sol)", "s10_notch", State.Sections.GuiMenu, "TopNotch", function(v)
    State.Sections.GuiMenu.TopNotch = v
    State.Sections.GuiMenu.ButtonMode = not v
    State.MenuMode = v and "TOP_NOTCH" or "BUTTON"
    applyMenuMode()
end)
addToggleWithKeyControls(Sec10, "BUTTON (Her Yere Suruklenen)", "s10_button", State.Sections.GuiMenu, "ButtonMode", function(v)
    State.Sections.GuiMenu.ButtonMode = v
    State.Sections.GuiMenu.TopNotch = not v
    State.MenuMode = v and "BUTTON" or "TOP_NOTCH"
    applyMenuMode()
end)
Sec10:CreateSlider({
    Name = "Top Notch Sag / Sol Konumu (%)",
    Range = {12, 88},
    Increment = 2,
    CurrentValue = 50,
    Callback = function(v)
        State.Sections.GuiMenu.NotchPosition = v
        State.TopNotchX = v / 100
        applyMenuMode()
    end
})
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if (State.Sections.AimbotTargeting.TeamCheck or State.Sections.ChecksFilters.TeamCheck) and LocalPlayer.Team and plr.Team then
        return plr.Team ~= LocalPlayer.Team
    end
    return true
end

local function isFriend(plr)
    if not plr then return false end
    local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
    return ok and res or false
end

local function findTarget()
    local bestPart = nil
    local bestScore = math.huge
    local maxDist = State.Sections.TargetSettings.TargetDistance or 250
    local partName = State.Sections.TargetSettings.TargetPart or "Head"

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")

            local aliveOk = not State.Sections.ChecksFilters.AliveCheck or (hum and hum.Health > 0)
            local enemyOk = not (State.Sections.AimbotTargeting.EnemyOnly or State.Sections.ChecksFilters.EnemyCheck) or isEnemy(plr)
            local friendOk = not ((State.Sections.AimbotTargeting.FriendCheck or State.Sections.ChecksFilters.FriendCheck) and isFriend(plr))

            if aliveOk and enemyOk and friendOk and part then
                local dist = Camera and (part.Position - Camera.CFrame.Position).Magnitude or 9999
                if dist <= maxDist and dist < bestScore then
                    bestScore = dist
                    bestPart = part
                end
            end
        end
    end
    return bestPart
end

local espHighlights = {}
local function updateHighlights()
    local wantHighlight = State.Sections.EspVisuals.PlayerESP or State.Sections.EspVisuals.PlayerHighlight or State.Sections.EspVisuals.Chams or State.Sections.PlayerCharacter.PlayerHighlight or State.Sections.PlayerCharacter.PlayerChams
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local enemyOnly = State.Sections.EspVisuals.EnemyOnly
            local show = wantHighlight and (not enemyOnly or isEnemy(plr))
            local hl = espHighlights[plr]
            if show then
                if not hl or not hl.Parent then
                    hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.65
                    hl.OutlineTransparency = 0
                    hl.FillColor = isEnemy(plr) and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 220, 120)
                    hl.Parent = plr.Character
                    espHighlights[plr] = hl
                end
            elseif hl then
                hl:Destroy()
                espHighlights[plr] = nil
            end
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if State.Sections.Movement.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    updateHighlights()

    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if hum then
            if State.Sections.Movement.SpeedHack then hum.WalkSpeed = 32 end
            if State.Sections.Movement.SuperJump then hum.JumpPower = 85 end
        end

        if hrp and State.Sections.Movement.Spinbot then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
        end
    end

    if State.Sections.AimbotTargeting.Aimbot or State.Sections.AimbotTargeting.LegitAim or State.Sections.AimbotTargeting.TargetLock then
        local target = findTarget()
        if target and Camera then
            local smooth = State.Sections.AimbotTargeting.LegitAim and 0.12 or (State.Sections.AimbotTargeting.SmoothAim and 0.18 or 0.35)
            local desired = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desired, smooth)
        end
    end
end)

applyMenuMode()
