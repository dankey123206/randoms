-- =============================================================================
-- RAYFIELD UNIVERSAL COMBAT / ESP / MOVEMENT / TARGET HUB (MANUAL FULL BUILD)
-- Menu UI: Turkce | Feature Names: English
-- =============================================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Workspace.CurrentCamera then
        Camera = Workspace.CurrentCamera
    end
end)

-- Bireysel Ozellik Durum Degiskenleri
-- [AIMBOT / TARGETING]
local Aimbot_Enabled = false
local SilentAim_Enabled = false
local LegitAim_Enabled = false
local RageAim_Enabled = false
local TargetLock_Enabled = false
local AutoShoot_Enabled = false
local Triggerbot_Enabled = false
local SmoothAim_Enabled = false
local FOV_Enabled = false
local AimPrediction_Enabled = false
local NearestTarget_Enabled = false
local TargetSwitch_Enabled = false
local VisibleCheck_Aim = true
local TeamCheck_Aim = true
local FriendCheck_Aim = true
local DeathCheck_Aim = true
local KnockedCheck_Aim = true

-- [ESP / VISUALS]
local PlayerESP_Enabled = false
local BoxESP_Enabled = false
local SkeletonESP_Enabled = false
local NameESP_Enabled = false
local HealthESP_Enabled = false
local DistanceESP_Enabled = false
local TracerESP_Enabled = false
local Box2D_Enabled = false
local Box3D_Enabled = false
local HeadESP_Enabled = false
local Snaplines_Enabled = false
local Chams_Enabled = false
local GlowESP_Enabled = false
local ItemESP_Enabled = false
local WeaponESP_Enabled = false
local EnemyOnly_ESP = true
local VisibleOnly_ESP = false

-- [MOVEMENT]
local SpeedHack_Enabled = false
local FlyHack_Enabled = false
local InfiniteJump_Enabled = false
local NoClip_Enabled = false
local Teleport_Enabled = false
local SuperJump_Enabled = false
local NoSlow_Enabled = false
local AirWalk_Enabled = false
local GravityHack_Enabled = false
local Spinbot_Enabled = false
local BunnyHop_Enabled = false
local AntiFall_Enabled = false

-- [WEAPON / COMBAT]
local NoRecoil_Enabled = false
local NoSpread_Enabled = false
local RapidFire_Enabled = false
local FastReload_Enabled = false
local InfiniteAmmo_Enabled = false
local NoReload_Enabled = false
local DamageModifier_Enabled = false
local HitboxExpander_Enabled = false
local MeleeAura_Enabled = false
local AutoKill_Enabled = false

-- [CHECKS / FILTERS]
local TeamCheck_Filter = true
local FriendCheck_Filter = true
local EnemyCheck_Filter = true
local AliveCheck_Filter = true
local DeadCheck_Filter = true
local VisibilityCheck_Filter = true
local WallCheck_Filter = true
local DistanceCheck_Filter = false
local HealthCheck_Filter = false
local NPCCheck_Filter = false
local BotCheck_Filter = false
local AFKCheck_Filter = false
local SafeZoneCheck_Filter = false
local FOVCheck_Filter = true
local VehicleCheck_Filter = false

-- [MISC / OTHER]
local AntiAim_Enabled = false
local FakeLag_Enabled = false
local Desync_Enabled = false
local HitSound_Enabled = false
local KillSound_Enabled = false
local HitMarker_Enabled = false
local CrosshairChanger_Enabled = false
local FOVChanger_Enabled = false
local FPSUnlocker_Enabled = false
local AutoRespawn_Enabled = false
local SpectatorMode_Enabled = false
local ConfigSystem_Enabled = false
local PanicButton_Enabled = false

-- [PLAYER / CHARACTER]
local CharacterESP_Enabled = false
local HeadESP_Char_Enabled = false
local BodyESP_Char_Enabled = false
local HandESP_Char_Enabled = false
local LegESP_Char_Enabled = false
local OutfitESP_Char_Enabled = false
local AvatarESP_Char_Enabled = false
local PlayerHighlight_Char_Enabled = false
local PlayerChams_Char_Enabled = false

-- [WORLD / ENVIRONMENT]
local WorldESP_Enabled = false
local ObjectESP_Enabled = false
local DoorESP_Enabled = false
local LootESP_Enabled = false
local WeaponFinder_Enabled = false
local ItemFinder_Enabled = false
local Radar_Enabled = false
local Minimap_Enabled = false
local Fullbright_Enabled = false
local NoFog_Enabled = false
local NightVision_Enabled = false

-- [TARGET SETTINGS]
local TargetVisibility_Enabled = false

-- Secim ve Deger Degiskenleri
local AimType_Mode = "Smooth Aim"
local AimBone_Part = "Head"
local AimSmoothness_Value = 0.20
local AimFOV_Radius = 160
local AimPrediction_Lead = 0.14
local WalkSpeed_Value = 36
local JumpPower_Value = 90
local FlySpeed_Value = 55
local Gravity_Value = 75
local HitboxSize_Value = 6
local CameraFOV_Value = 90
local TargetPart_Name = "Head"
local TargetPriority_Mode = "Closest"
local TargetMaxDistance = 350
local TargetTeam_Mode = "Enemies"
local TargetHealth_Mode = "Lowest"
local TargetMode_Type = "Standard"
local TargetFilter_Mode = "Standard"
local TargetIgnore_Raw = ""
local TargetWhitelist_Raw = ""
local TargetBlacklist_Raw = ""
local LockedTargetPlayer = nil
local TargetSwitchTimer = 0

-- Hedef (Target) Bolumune Ozel Suruklenebilir Ekran Tuslari
local TargetKeyGui = Instance.new("ScreenGui")
TargetKeyGui.Name = "TargetSectionScreenKeys"
TargetKeyGui.ResetOnSpawn = false
TargetKeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TargetKeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function EnsureTargetKeyButton(keyId, buttonText, visibleFlag, onClickCallback)
    local existing = TargetKeyGui:FindFirstChild("TargetKey_" .. keyId)
    if visibleFlag then
        if existing then
            existing.Visible = true
            return existing
        end
        local btn = Instance.new("TextButton")
        btn.Name = "TargetKey_" .. keyId
        btn.Size = UDim2.new(0, 112, 0, 42)
        btn.Position = UDim2.new(0.15, 0, 0.28, 0)
        btn.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = buttonText
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Active = true
        btn.Draggable = true
        btn.Parent = TargetKeyGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 200, 50)
        stroke.Thickness = 1.5
        stroke.Parent = btn
        local toggled = false
        btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            btn.BackgroundColor3 = toggled and Color3.fromRGB(40, 150, 95) or Color3.fromRGB(55, 60, 70)
            if onClickCallback then
                onClickCallback(toggled)
            end
        end)
        return btn
    else
        if existing then
            existing:Destroy()
        end
    end
end

-- Karakter, Takim, Arkadas ve Gorunurluk Yardimci Fonksiyonlari
local function GetLocalCharacter()
    return LocalPlayer.Character
end

local function GetLocalRoot()
    local char = GetLocalCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
end

local function GetLocalHumanoid()
    local char = GetLocalCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function IsTeammate(plr)
    if not plr or plr == LocalPlayer then return true end
    if TargetTeam_Mode == "All" then return false end
    if (TeamCheck_Aim or TeamCheck_Filter) and LocalPlayer.Team and plr.Team then
        return plr.Team == LocalPlayer.Team
    end
    if LocalPlayer.TeamColor and plr.TeamColor and (TeamCheck_Aim or TeamCheck_Filter) then
        return plr.TeamColor == LocalPlayer.TeamColor
    end
    return false
end

local function IsFriend(plr)
    if not plr then return false end
    if not (FriendCheck_Aim or FriendCheck_Filter) then return false end
    local ok, res = pcall(function()
        return LocalPlayer:IsFriendsWith(plr.UserId)
    end)
    return ok and res == true
end

local function IsAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if (DeathCheck_Aim or AliveCheck_Filter or DeadCheck_Filter) and hum.Health <= 0 then
        return false
    end
    if KnockedCheck_Aim and hum:GetState() == Enum.HumanoidStateType.PlatformStand then
        return false
    end
    return true
end

local function NameInCsv(plrName, csvText)
    if not plrName or not csvText or csvText == "" then return false end
    local lowerName = string.lower(plrName)
    for token in string.gmatch(csvText, "[^,]+") do
        local cleaned = string.lower(token:gsub("^%s+", ""):gsub("%s+$", ""))
        if cleaned ~= "" and cleaned == lowerName then
            return true
        end
    end
    return false
end

local function IsPartVisible(part)
    if not Camera or not part then return false end
    if not (VisibleCheck_Aim or VisibilityCheck_Filter or WallCheck_Filter or TargetVisibility_Enabled or VisibleOnly_ESP) then
        return true
    end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {}
    if LocalPlayer.Character then
        table.insert(filterList, LocalPlayer.Character)
    end
    if part.Parent then
        table.insert(filterList, part.Parent)
    end
    params.FilterDescendantsInstances = filterList
    local rayResult = Workspace:Raycast(origin, direction, params)
    if not rayResult then
        return true
    end
    if part.Parent and rayResult.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return false
end

local function GetTargetPartForCharacter(char)
    if not char then return nil end
    local preferred = TargetPart_Name or AimBone_Part or "Head"
    local p = char:FindFirstChild(preferred)
    if p and p:IsA("BasePart") then return p end
    local alt1 = char:FindFirstChild("Head")
    if alt1 and alt1:IsA("BasePart") then return alt1 end
    local alt2 = char:FindFirstChild("HumanoidRootPart")
    if alt2 and alt2:IsA("BasePart") then return alt2 end
    return char:FindFirstChildWhichIsA("BasePart")
end

-- Gelismis Hedef Secme ve Filtreleme Sistemi
local function SelectBestTarget()
    if not Camera then return nil end
    if LockedTargetPlayer and LockedTargetPlayer.Parent == Players and IsAlive(LockedTargetPlayer) then
        local lockedChar = LockedTargetPlayer.Character
        local lockedPart = GetTargetPartForCharacter(lockedChar)
        if lockedPart then
            local dist = (lockedPart.Position - Camera.CFrame.Position).Magnitude
            if dist <= TargetMaxDistance then
                return lockedPart, LockedTargetPlayer
            end
        end
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local bestPart = nil
    local bestPlayer = nil
    local bestScore = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if NameInCsv(plr.Name, TargetIgnore_Raw) then
                continue
            end
            if TargetFilter_Mode == "WhitelistOnly" and not NameInCsv(plr.Name, TargetWhitelist_Raw) then
                continue
            end
            if TargetFilter_Mode == "BlacklistSkip" and NameInCsv(plr.Name, TargetBlacklist_Raw) then
                continue
            end
            if not IsAlive(plr) then
                continue
            end
            if IsTeammate(plr) then
                continue
            end
            if IsFriend(plr) then
                continue
            end

            local part = GetTargetPartForCharacter(plr.Character)
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if part and hum then
                local worldDist = (part.Position - Camera.CFrame.Position).Magnitude
                if DistanceCheck_Filter and worldDist > TargetMaxDistance then
                    continue
                end
                if worldDist > TargetMaxDistance then
                    continue
                end
                if not IsPartVisible(part) then
                    continue
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local fovDist = math.huge
                if onScreen and screenPos.Z > 0 then
                    fovDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                end

                if (FOV_Enabled or FOVCheck_Filter) and fovDist > AimFOV_Radius then
                    continue
                end

                local score = worldDist
                if TargetPriority_Mode == "LowestHealth" or TargetHealth_Mode == "Lowest" then
                    score = hum.Health
                elseif TargetPriority_Mode == "FOV" or NearestTarget_Enabled then
                    score = (fovDist < math.huge) and fovDist or worldDist
                elseif TargetPriority_Mode == "Closest" then
                    score = worldDist
                end

                if score < bestScore then
                    bestScore = score
                    bestPart = part
                    bestPlayer = plr
                end
            end
        end
    end

    return bestPart, bestPlayer
end

-- Calisan ESP Sistemi (Highlight + BillboardGui + Drawing Box/Tracer/Head)
local PlayerHighlights = {}
local PlayerBillboards = {}
local PlayerDrawings = {}
local WorldESPFolder = Instance.new("Folder")
WorldESPFolder.Name = "HubWorldESPFolder"
WorldESPFolder.Parent = Workspace

local function EnsureDrawing(plr, key, dtype)
    if not Drawing then return nil end
    PlayerDrawings[plr] = PlayerDrawings[plr] or {}
    if PlayerDrawings[plr][key] then
        return PlayerDrawings[plr][key]
    end
    local obj = Drawing.new(dtype)
    obj.Visible = false
    PlayerDrawings[plr][key] = obj
    return obj
end

local function HidePlayerDrawings(plr)
    local d = PlayerDrawings[plr]
    if not d then return end
    for _, obj in pairs(d) do
        if obj then obj.Visible = false end
    end
end

local function CleanupPlayerESP(plr)
    if PlayerHighlights[plr] then
        PlayerHighlights[plr]:Destroy()
        PlayerHighlights[plr] = nil
    end
    if PlayerBillboards[plr] then
        PlayerBillboards[plr]:Destroy()
        PlayerBillboards[plr] = nil
    end
    if PlayerDrawings[plr] then
        for _, obj in pairs(PlayerDrawings[plr]) do
            pcall(function() obj:Remove() end)
        end
        PlayerDrawings[plr] = nil
    end
end

Players.PlayerRemoving:Connect(CleanupPlayerESP)

local function UpdateAllESP()
    local anyHighlight = PlayerESP_Enabled or Chams_Enabled or GlowESP_Enabled or CharacterESP_Enabled or PlayerHighlight_Char_Enabled or PlayerChams_Char_Enabled
    local anyBill = NameESP_Enabled or HealthESP_Enabled or DistanceESP_Enabled or HeadESP_Char_Enabled or BodyESP_Char_Enabled or HandESP_Char_Enabled or LegESP_Char_Enabled or OutfitESP_Char_Enabled or AvatarESP_Char_Enabled
    local anyDraw = BoxESP_Enabled or Box2D_Enabled or Box3D_Enabled or TracerESP_Enabled or Snaplines_Enabled or HeadESP_Enabled or SkeletonESP_Enabled

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then
            CleanupPlayerESP(plr)
            continue
        end

        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            HidePlayerDrawings(plr)
            if PlayerHighlights[plr] then PlayerHighlights[plr].Enabled = false end
            if PlayerBillboards[plr] then PlayerBillboards[plr].Enabled = false end
            continue
        end

        local mate = IsTeammate(plr)
        if EnemyOnly_ESP and mate then
            HidePlayerDrawings(plr)
            if PlayerHighlights[plr] then PlayerHighlights[plr].Enabled = false end
            if PlayerBillboards[plr] then PlayerBillboards[plr].Enabled = false end
            continue
        end

        local visOk = IsPartVisible(head or hrp)
        if VisibleOnly_ESP and not visOk then
            HidePlayerDrawings(plr)
            if PlayerHighlights[plr] then PlayerHighlights[plr].Enabled = false end
            if PlayerBillboards[plr] then PlayerBillboards[plr].Enabled = false end
            continue
        end

        local espColor = mate and Color3.fromRGB(60, 220, 120) or Color3.fromRGB(255, 65, 65)

        if anyHighlight then
            local hl = PlayerHighlights[plr]
            if not hl or not hl.Parent then
                hl = Instance.new("Highlight")
                hl.Name = "HubPlayerHighlight"
                hl.Parent = char
                PlayerHighlights[plr] = hl
            end
            hl.Enabled = true
            hl.Adornee = char
            hl.FillColor = espColor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = Chams_Enabled and 0.35 or 0.68
            hl.OutlineTransparency = GlowESP_Enabled and 0 or 0.25
        elseif PlayerHighlights[plr] then
            PlayerHighlights[plr].Enabled = false
        end

        if anyBill and head then
            local bb = PlayerBillboards[plr]
            local lbl = bb and bb:FindFirstChild("InfoLabel")
            if not bb or not bb.Parent then
                bb = Instance.new("BillboardGui")
                bb.Name = "HubPlayerBillboard"
                bb.Size = UDim2.new(0, 180, 0, 48)
                bb.StudsOffset = Vector3.new(0, 2.8, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head
                lbl = Instance.new("TextLabel")
                lbl.Name = "InfoLabel"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.TextStrokeTransparency = 0.2
                lbl.TextSize = 12
                lbl.Font = Enum.Font.GothamBold
                lbl.Parent = bb
                PlayerBillboards[plr] = bb
            end
            bb.Enabled = true
            local partsText = {}
            if NameESP_Enabled then table.insert(partsText, plr.Name) end
            if HealthESP_Enabled then table.insert(partsText, "HP: " .. math.floor(hum.Health)) end
            if DistanceESP_Enabled and Camera then
                local d = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                table.insert(partsText, d .. "m")
            end
            if OutfitESP_Char_Enabled or AvatarESP_Char_Enabled then
                table.insert(partsText, "UserId:" .. plr.UserId)
            end
            if #partsText == 0 then
                table.insert(partsText, plr.DisplayName)
            end
            if lbl then
                lbl.Text = table.concat(partsText, " | ")
                lbl.TextColor3 = espColor
            end
        elseif PlayerBillboards[plr] then
            PlayerBillboards[plr].Enabled = false
        end

        if anyDraw and Camera and Drawing then
            local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen and rootPos.Z > 0 then
                local dist = math.max(1, rootPos.Z)
                local boxW = math.clamp(2200 / dist, 14, 160)
                local boxH = math.clamp(3400 / dist, 24, 240)
                local topLeft = Vector2.new(rootPos.X - boxW * 0.5, rootPos.Y - boxH * 0.5)

                local boxObj = EnsureDrawing(plr, "Box", "Square")
                if boxObj then
                    local showBox = BoxESP_Enabled or Box2D_Enabled or Box3D_Enabled
                    boxObj.Visible = showBox
                    if showBox then
                        boxObj.Position = topLeft
                        boxObj.Size = Vector2.new(boxW, boxH)
                        boxObj.Color = espColor
                        boxObj.Thickness = 1.6
                        boxObj.Filled = false
                    end
                end

                local tracerObj = EnsureDrawing(plr, "Tracer", "Line")
                if tracerObj then
                    local showTracer = TracerESP_Enabled or Snaplines_Enabled
                    tracerObj.Visible = showTracer
                    if showTracer then
                        tracerObj.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                        tracerObj.To = Vector2.new(rootPos.X, rootPos.Y + boxH * 0.5)
                        tracerObj.Color = espColor
                        tracerObj.Thickness = 1.4
                    end
                end

                local headObj = EnsureDrawing(plr, "Head", "Circle")
                if headObj and head then
                    local hPos, hOn = Camera:WorldToViewportPoint(head.Position)
                    headObj.Visible = HeadESP_Enabled and hOn and hPos.Z > 0
                    if headObj.Visible then
                        headObj.Position = Vector2.new(hPos.X, hPos.Y)
                        headObj.Radius = math.clamp(450 / dist, 4, 24)
                        headObj.Color = Color3.fromRGB(255, 220, 70)
                        headObj.Thickness = 1.5
                        headObj.Filled = false
                    end
                end
            else
                HidePlayerDrawings(plr)
            end
        else
            HidePlayerDrawings(plr)
        end
    end
end

-- Dunya, Esya ve Silah Bulucu Sistemi
local WorldESPFolder = Instance.new("Folder")
WorldESPFolder.Name = "HubWorldMarkersFolder"
WorldESPFolder.Parent = Workspace

local function RefreshWorldESP()
    for _, child in ipairs(WorldESPFolder:GetChildren()) do
        child:Destroy()
    end
    local scanWorld = WorldESP_Enabled or ObjectESP_Enabled or DoorESP_Enabled or LootESP_Enabled or WeaponFinder_Enabled or ItemFinder_Enabled or ItemESP_Enabled or WeaponESP_Enabled
    if not scanWorld then return end

    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if count >= 45 then break end
        if obj:IsA("BasePart") then
            local lname = string.lower(obj.Name)
            local matched = false
            local col = Color3.fromRGB(120, 200, 255)
            if (DoorESP_Enabled or WorldESP_Enabled) and (lname:find("door") or lname:find("gate")) then
                matched = true; col = Color3.fromRGB(255, 180, 50)
            elseif (LootESP_Enabled or ItemFinder_Enabled or ItemESP_Enabled) and (lname:find("loot") or lname:find("item") or lname:find("chest") or lname:find("crate") or lname:find("med") or lname:find("ammo")) then
                matched = true; col = Color3.fromRGB(80, 255, 140)
            elseif (WeaponFinder_Enabled or WeaponESP_Enabled) and (lname:find("gun") or lname:find("weapon") or lname:find("rifle") or lname:find("sword") or lname:find("knife")) then
                matched = true; col = Color3.fromRGB(255, 90, 160)
            elseif ObjectESP_Enabled and obj.Anchored and obj.Size.Magnitude > 6 then
                matched = true; col = Color3.fromRGB(180, 150, 255)
            end
            if matched then
                count += 1
                local box = Instance.new("SelectionBox")
                box.Adornee = obj
                box.Color3 = col
                box.LineThickness = 0.04
                box.Parent = WorldESPFolder
            end
        end
    end
end

task.spawn(function()
    while task.wait(2.5) do
        pcall(RefreshWorldESP)
    end
end)

-- FOV Dairesi Cizimi
local FOVCircleDraw = nil
if Drawing then
    FOVCircleDraw = Drawing.new("Circle")
    FOVCircleDraw.Filled = false
    FOVCircleDraw.Thickness = 1.8
    FOVCircleDraw.NumSides = 64
    FOVCircleDraw.Color = Color3.fromRGB(255, 215, 60)
    FOVCircleDraw.Visible = false
end

-- Rayfield Pencere Olusturma (Turkce Menu, Ingilizce Ozellik Adlari)
local Window = Rayfield:CreateWindow({
    Name = "Gelismis Oyun Menusu",
    LoadingTitle = "Sistem Yukleniyor...",
    LoadingSubtitle = "Aimbot • ESP • Movement • Weapon • Target",
    ConfigurationSaving = { Enabled = false }
})

-- [SEKME 1] AIMBOT / TARGETING
local TabAimbot = Window:CreateTab("Aimbot / Hedefleme", 4483362458)

TabAimbot:CreateDropdown({
    Name = "Aimbot Modu Secimi",
    Options = {"Legit Aim", "Smooth Aim", "Normal Aim", "Target Lock", "Rage Aim"},
    CurrentOption = {"Smooth Aim"},
    Callback = function(opt)
        AimType_Mode = opt[1]
    end
})

TabAimbot:CreateSlider({
    Name = "Yumusaklik Ayari (Smoothness)",
    Range = {2, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(val)
        AimSmoothness_Value = val / 100
    end
})

TabAimbot:CreateSlider({
    Name = "FOV Daire Boyutu",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 160,
    Callback = function(val)
        AimFOV_Radius = val
    end
})

TabAimbot:CreateDropdown({
    Name = "Hedef Kemik (Aim Bone)",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(opt)
        AimBone_Part = opt[1]
        TargetPart_Name = opt[1]
    end
})

TabAimbot:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "SilentAim",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "LegitAim",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "RageAim",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "TargetLock",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "AutoShoot",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "Triggerbot",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "FOV",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "AimPrediction",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "NearestTarget",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "TargetSwitch",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabAimbot:CreateToggle({
    Name = "VisibleCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabAimbot:CreateToggle({
    Name = "TeamCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabAimbot:CreateToggle({
    Name = "FriendCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabAimbot:CreateToggle({
    Name = "DeathCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabAimbot:CreateToggle({
    Name = "KnockedCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})

-- [SEKME 2] ESP / GORSEL
local TabESP = Window:CreateTab("ESP / Gorunum", 4483362458)
TabESP:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "BoxESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "SkeletonESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "NameESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "HealthESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "DistanceESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "TracerESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "Box2D",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "Box3D",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "HeadESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "Snaplines",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "GlowESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "ItemESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "WeaponESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabESP:CreateToggle({
    Name = "EnemyOnly",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabESP:CreateToggle({
    Name = "VisibleOnly",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 3] HAREKET
local TabMovement = Window:CreateTab("Hareket Ayarlari", 4483362458)

TabMovement:CreateSlider({
    Name = "Hiz Degeri (WalkSpeed)",
    Range = {16, 150},
    Increment = 1,
    CurrentValue = 36,
    Callback = function(v) WalkSpeed_Value = v end
})

TabMovement:CreateSlider({
    Name = "Ziplama Gucu (JumpPower)",
    Range = {50, 250},
    Increment = 5,
    CurrentValue = 90,
    Callback = function(v) JumpPower_Value = v end
})

TabMovement:CreateSlider({
    Name = "Ucus Hizi (Fly Speed)",
    Range = {15, 180},
    Increment = 5,
    CurrentValue = 55,
    Callback = function(v) FlySpeed_Value = v end
})

TabMovement:CreateSlider({
    Name = "Yercekimi (Gravity)",
    Range = {10, 196},
    Increment = 2,
    CurrentValue = 75,
    Callback = function(v)
        Gravity_Value = v
        if GravityHack_Enabled then Workspace.Gravity = v end
    end
})

TabMovement:CreateToggle({
    Name = "SpeedHack",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "FlyHack",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "InfiniteJump",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "Teleport",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "SuperJump",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "NoSlow",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "AirWalk",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "GravityHack",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "Spinbot",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "BunnyHop",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMovement:CreateToggle({
    Name = "AntiFall",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 4] SILAH VE SAVAS
local TabWeapon = Window:CreateTab("Silah / Savas", 4483362458)

TabWeapon:CreateSlider({
    Name = "Hitbox Boyutu",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v) HitboxSize_Value = v end
})

TabWeapon:CreateToggle({
    Name = "NoRecoil",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "NoSpread",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "RapidFire",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "FastReload",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "InfiniteAmmo",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "NoReload",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "DamageModifier",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "HitboxExpander",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "MeleeAura",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWeapon:CreateToggle({
    Name = "AutoKill",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 5] KONTROLLER VE FILTRELER
local TabChecks = Window:CreateTab("Kontroller / Filtre", 4483362458)
TabChecks:CreateToggle({
    Name = "TeamCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "FriendCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "EnemyCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "AliveCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "DeadCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "VisibilityCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "WallCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "DistanceCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "HealthCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "NPCCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "BotCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "AFKCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "SafeZoneCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChecks:CreateToggle({
    Name = "FOVCheck",
    CurrentValue = true,
    Callback = function(v)
        true = v
    end
})
TabChecks:CreateToggle({
    Name = "VehicleCheck",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 6] DIGER AYARLAR
local TabMisc = Window:CreateTab("Diger Ayarlar", 4483362458)

TabMisc:CreateSlider({
    Name = "Kamera FOV Degeri",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = 90,
    Callback = function(v)
        CameraFOV_Value = v
        if FOVChanger_Enabled and Camera then Camera.FieldOfView = v end
    end
})

TabMisc:CreateToggle({
    Name = "AntiAim",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "FakeLag",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "Desync",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "HitSound",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "KillSound",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "HitMarker",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "CrosshairChanger",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "FOVChanger",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "FPSUnlocker",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "AutoRespawn",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "SpectatorMode",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "ConfigSystem",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabMisc:CreateToggle({
    Name = "PanicButton",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 7] OYUNCU VE KARAKTER
local TabChar = Window:CreateTab("Karakter / Oyuncu", 4483362458)
TabChar:CreateToggle({
    Name = "CharacterESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "HeadESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "BodyESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "HandESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "LegESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "OutfitESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "AvatarESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "PlayerHighlight",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabChar:CreateToggle({
    Name = "PlayerChams",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 8] DUNYA VE CEVRE
local TabWorld = Window:CreateTab("Dunya / Cevre", 4483362458)
TabWorld:CreateToggle({
    Name = "WorldESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "ObjectESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "DoorESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "LootESP",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "WeaponFinder",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "ItemFinder",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "Radar",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "Minimap",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "NoFog",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})
TabWorld:CreateToggle({
    Name = "NightVision",
    CurrentValue = false,
    Callback = function(v)
        false = v
    end
})

-- [SEKME 9] HEDEF AYARLARI (EKRAN TUSLARI SADECE BURADA)
local TabTarget = Window:CreateTab("Hedef Ayarlari", 4483362458)

TabTarget:CreateDropdown({
    Name = "Hedef Parca (Target Part)",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(opt)
        TargetPart_Name = opt[1]
        AimBone_Part = opt[1]
    end
})

TabTarget:CreateDropdown({
    Name = "Hedef Onceligi (Target Priority)",
    Options = {"Closest", "LowestHealth", "FOV"},
    CurrentOption = {"Closest"},
    Callback = function(opt)
        TargetPriority_Mode = opt[1]
    end
})

TabTarget:CreateSlider({
    Name = "Hedef Mesafesi (Target Distance)",
    Range = {25, 1000},
    Increment = 10,
    CurrentValue = 350,
    Callback = function(val)
        TargetMaxDistance = val
    end
})

TabTarget:CreateDropdown({
    Name = "Hedef Takimi (Target Team)",
    Options = {"Enemies", "All", "NonTeam"},
    CurrentOption = {"Enemies"},
    Callback = function(opt)
        TargetTeam_Mode = opt[1]
    end
})

TabTarget:CreateToggle({
    Name = "Target Visibility",
    CurrentValue = TargetVisibility_Enabled,
    Callback = function(v)
        TargetVisibility_Enabled = v
    end
})

TabTarget:CreateToggle({
    Name = "[Ekran Tusu] Target Visibility",
    CurrentValue = false,
    Callback = function(showBtn)
        EnsureTargetKeyButton("vis", "TARGET VIS", showBtn, function(state)
            TargetVisibility_Enabled = state
        end)
    end
})

TabTarget:CreateToggle({
    Name = "[Ekran Tusu] Target Lock",
    CurrentValue = false,
    Callback = function(showBtn)
        EnsureTargetKeyButton("lock", "TARGET LOCK", showBtn, function(state)
            TargetLock_Enabled = state
            if not state then LockedTargetPlayer = nil end
        end)
    end
})

TabTarget:CreateToggle({
    Name = "[Ekran Tusu] Target Switch",
    CurrentValue = false,
    Callback = function(showBtn)
        EnsureTargetKeyButton("switch", "NEXT TARGET", showBtn, function(state)
            TargetSwitch_Enabled = state
            if state then
                local _, nextPlr = SelectBestTarget()
                LockedTargetPlayer = nextPlr
            end
        end)
    end
})

TabTarget:CreateDropdown({
    Name = "Hedef Can Durumu (Target Health)",
    Options = {"Lowest", "Highest", "Any"},
    CurrentOption = {"Lowest"},
    Callback = function(opt)
        TargetHealth_Mode = opt[1]
    end
})

TabTarget:CreateDropdown({
    Name = "Hedef Modu (Target Mode)",
    Options = {"Standard", "Aggressive", "Legit"},
    CurrentOption = {"Standard"},
    Callback = function(opt)
        TargetMode_Type = opt[1]
    end
})

TabTarget:CreateDropdown({
    Name = "Hedef Filtresi (Target Filter)",
    Options = {"Standard", "WhitelistOnly", "BlacklistSkip"},
    CurrentOption = {"Standard"},
    Callback = function(opt)
        TargetFilter_Mode = opt[1]
    end
})

TabTarget:CreateInput({
    Name = "Target Ignore List",
    PlaceholderText = "Player1, Player2",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt) TargetIgnore_Raw = txt end
})

TabTarget:CreateInput({
    Name = "Target Whitelist",
    PlaceholderText = "Player1, Player2",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt) TargetWhitelist_Raw = txt end
})

TabTarget:CreateInput({
    Name = "Target Blacklist",
    PlaceholderText = "Player1, Player2",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt) TargetBlacklist_Raw = txt end
})

-- Ziplama ve Hareket Baglantilari
local AirWalkPart = Instance.new("Part")
AirWalkPart.Name = "HubAirWalkPart"
AirWalkPart.Size = Vector3.new(9, 1, 9)
AirWalkPart.Anchored = true
AirWalkPart.CanCollide = true
AirWalkPart.Transparency = 1
AirWalkPart.Parent = Workspace

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump_Enabled or BunnyHop_Enabled then
        local hum = GetLocalHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Ana Kare Dongusu (RenderStepped)
RunService.RenderStepped:Connect(function(dt)
    pcall(UpdateAllESP)

    if FOVCircleDraw and Camera then
        FOVCircleDraw.Visible = FOV_Enabled
        FOVCircleDraw.Radius = AimFOV_Radius
        FOVCircleDraw.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    end

    local char = GetLocalCharacter()
    local hum = GetLocalHumanoid()
    local hrp = GetLocalRoot()

    if hum then
        if SpeedHack_Enabled then
            hum.WalkSpeed = WalkSpeed_Value
        end
        if SuperJump_Enabled then
            hum.UseJumpPower = true
            hum.JumpPower = JumpPower_Value
        end
        if NoSlow_Enabled and hum.WalkSpeed < 16 then
            hum.WalkSpeed = 16
        end
        if AutoRespawn_Enabled and hum.Health <= 0 then
            pcall(function() LocalPlayer:LoadCharacter() end)
        end
    end

    if char and NoClip_Enabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if hrp then
        if AirWalk_Enabled then
            AirWalkPart.Position = hrp.Position - Vector3.new(0, 3.6, 0)
        else
            AirWalkPart.Position = Vector3.new(0, -5000, 0)
        end

        if FlyHack_Enabled then
            local moveVec = hum and hum.MoveDirection or Vector3.zero
            local verticalY = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                verticalY = FlySpeed_Value * 0.65
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                verticalY = -FlySpeed_Value * 0.65
            end
            hrp.AssemblyLinearVelocity = Vector3.new(moveVec.X * FlySpeed_Value, verticalY, moveVec.Z * FlySpeed_Value)
        end

        if Spinbot_Enabled or AntiAim_Enabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
        end

        if AntiFall_Enabled and hrp.AssemblyLinearVelocity.Y < -70 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
        end
    end

    if HitboxExpander_Enabled or MeleeAura_Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not IsTeammate(plr) then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and tRoot:IsA("BasePart") then
                    if HitboxExpander_Enabled then
                        tRoot.Size = Vector3.new(HitboxSize_Value, HitboxSize_Value, HitboxSize_Value)
                        tRoot.Transparency = 0.75
                        tRoot.CanCollide = false
                    end
                    if MeleeAura_Enabled and hrp and (tRoot.Position - hrp.Position).Magnitude <= 14 then
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end
        end
    end

    local aimActive = Aimbot_Enabled or LegitAim_Enabled or RageAim_Enabled or TargetLock_Enabled or SmoothAim_Enabled or NearestTarget_Enabled
    if aimActive and Camera then
        local targetPart, targetPlr = SelectBestTarget()
        if TargetLock_Enabled and targetPlr then
            LockedTargetPlayer = targetPlr
        end
        if targetPart then
            local aimPos = targetPart.Position
            if AimPrediction_Enabled and targetPart:IsA("BasePart") then
                aimPos = aimPos + (targetPart.AssemblyLinearVelocity * AimPrediction_Lead)
            end

            local alpha = AimSmoothness_Value
            if LegitAim_Enabled or AimType_Mode == "Legit Aim" then
                alpha = math.min(alpha, 0.10)
            elseif RageAim_Enabled or AimType_Mode == "Rage Aim" then
                alpha = 0.92
            elseif TargetLock_Enabled or AimType_Mode == "Target Lock" then
                alpha = 0.65
            elseif AimType_Mode == "Normal Aim" then
                alpha = 0.45
            end

            local desiredCF = CFrame.lookAt(Camera.CFrame.Position, aimPos)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCF, math.clamp(alpha, 0.02, 1))

            if AutoShoot_Enabled or Triggerbot_Enabled then
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end
end)
-- Bireysel Ozellik Isleyici Fonksiyonlari (Her Ozellik Icin Ayri Blok)

local function RunModule_Aimbot()
    if not Aimbot_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Aimbot" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Aimbot" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Aimbot" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Aimbot" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Aimbot" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SilentAim()
    if not SilentAim_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SilentAim" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SilentAim" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SilentAim" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SilentAim" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SilentAim" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_LegitAim()
    if not LegitAim_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "LegitAim" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "LegitAim" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "LegitAim" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "LegitAim" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "LegitAim" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_RageAim()
    if not RageAim_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "RageAim" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "RageAim" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "RageAim" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "RageAim" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "RageAim" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_TargetLock()
    if not TargetLock_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "TargetLock" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "TargetLock" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "TargetLock" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "TargetLock" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "TargetLock" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AutoShoot()
    if not AutoShoot_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AutoShoot" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AutoShoot" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AutoShoot" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AutoShoot" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AutoShoot" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Triggerbot()
    if not Triggerbot_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Triggerbot" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Triggerbot" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Triggerbot" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Triggerbot" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Triggerbot" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SmoothAim()
    if not SmoothAim_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SmoothAim" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SmoothAim" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SmoothAim" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SmoothAim" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SmoothAim" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FOV()
    if not FOV_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FOV" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FOV" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FOV" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FOV" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FOV" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AimPrediction()
    if not AimPrediction_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AimPrediction" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AimPrediction" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AimPrediction" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AimPrediction" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AimPrediction" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NearestTarget()
    if not NearestTarget_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NearestTarget" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NearestTarget" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NearestTarget" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NearestTarget" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NearestTarget" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_TargetSwitch()
    if not TargetSwitch_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "TargetSwitch" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "TargetSwitch" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "TargetSwitch" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "TargetSwitch" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "TargetSwitch" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_PlayerESP()
    if not PlayerESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "PlayerESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "PlayerESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "PlayerESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "PlayerESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "PlayerESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_BoxESP()
    if not BoxESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "BoxESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "BoxESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "BoxESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "BoxESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "BoxESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SkeletonESP()
    if not SkeletonESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SkeletonESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SkeletonESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SkeletonESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SkeletonESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SkeletonESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NameESP()
    if not NameESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NameESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NameESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NameESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NameESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NameESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_HealthESP()
    if not HealthESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "HealthESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "HealthESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "HealthESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "HealthESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "HealthESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_DistanceESP()
    if not DistanceESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "DistanceESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "DistanceESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "DistanceESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "DistanceESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "DistanceESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_TracerESP()
    if not TracerESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "TracerESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "TracerESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "TracerESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "TracerESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "TracerESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Box2D()
    if not Box2D_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Box2D" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Box2D" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Box2D" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Box2D" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Box2D" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Box3D()
    if not Box3D_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Box3D" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Box3D" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Box3D" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Box3D" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Box3D" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_HeadESP()
    if not HeadESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "HeadESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "HeadESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "HeadESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "HeadESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "HeadESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Snaplines()
    if not Snaplines_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Snaplines" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Snaplines" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Snaplines" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Snaplines" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Snaplines" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Chams()
    if not Chams_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Chams" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Chams" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Chams" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Chams" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Chams" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_GlowESP()
    if not GlowESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "GlowESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "GlowESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "GlowESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "GlowESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "GlowESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_ItemESP()
    if not ItemESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "ItemESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "ItemESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "ItemESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "ItemESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "ItemESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_WeaponESP()
    if not WeaponESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "WeaponESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "WeaponESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "WeaponESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "WeaponESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "WeaponESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_EnemyOnly()
    if not EnemyOnly_ESP then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "EnemyOnly" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "EnemyOnly" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "EnemyOnly" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "EnemyOnly" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "EnemyOnly" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_VisibleOnly()
    if not VisibleOnly_ESP then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "VisibleOnly" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "VisibleOnly" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "VisibleOnly" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "VisibleOnly" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "VisibleOnly" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SpeedHack()
    if not SpeedHack_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SpeedHack" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SpeedHack" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SpeedHack" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SpeedHack" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SpeedHack" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FlyHack()
    if not FlyHack_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FlyHack" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FlyHack" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FlyHack" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FlyHack" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FlyHack" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_InfiniteJump()
    if not InfiniteJump_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "InfiniteJump" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "InfiniteJump" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "InfiniteJump" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "InfiniteJump" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "InfiniteJump" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoClip()
    if not NoClip_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoClip" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoClip" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoClip" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoClip" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoClip" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Teleport()
    if not Teleport_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Teleport" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Teleport" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Teleport" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Teleport" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Teleport" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SuperJump()
    if not SuperJump_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SuperJump" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SuperJump" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SuperJump" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SuperJump" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SuperJump" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoSlow()
    if not NoSlow_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoSlow" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoSlow" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoSlow" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoSlow" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoSlow" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AirWalk()
    if not AirWalk_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AirWalk" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AirWalk" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AirWalk" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AirWalk" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AirWalk" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_GravityHack()
    if not GravityHack_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "GravityHack" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "GravityHack" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "GravityHack" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "GravityHack" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "GravityHack" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Spinbot()
    if not Spinbot_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Spinbot" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Spinbot" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Spinbot" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Spinbot" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Spinbot" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_BunnyHop()
    if not BunnyHop_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "BunnyHop" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "BunnyHop" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "BunnyHop" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "BunnyHop" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "BunnyHop" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AntiFall()
    if not AntiFall_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AntiFall" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AntiFall" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AntiFall" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AntiFall" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AntiFall" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoRecoil()
    if not NoRecoil_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoRecoil" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoRecoil" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoRecoil" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoRecoil" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoRecoil" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoSpread()
    if not NoSpread_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoSpread" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoSpread" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoSpread" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoSpread" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoSpread" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_RapidFire()
    if not RapidFire_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "RapidFire" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "RapidFire" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "RapidFire" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "RapidFire" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "RapidFire" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FastReload()
    if not FastReload_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FastReload" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FastReload" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FastReload" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FastReload" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FastReload" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_InfiniteAmmo()
    if not InfiniteAmmo_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "InfiniteAmmo" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "InfiniteAmmo" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "InfiniteAmmo" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "InfiniteAmmo" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "InfiniteAmmo" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoReload()
    if not NoReload_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoReload" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoReload" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoReload" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoReload" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoReload" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_DamageModifier()
    if not DamageModifier_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "DamageModifier" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "DamageModifier" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "DamageModifier" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "DamageModifier" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "DamageModifier" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_HitboxExpander()
    if not HitboxExpander_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "HitboxExpander" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "HitboxExpander" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "HitboxExpander" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "HitboxExpander" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "HitboxExpander" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_MeleeAura()
    if not MeleeAura_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "MeleeAura" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "MeleeAura" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "MeleeAura" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "MeleeAura" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "MeleeAura" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AutoKill()
    if not AutoKill_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AutoKill" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AutoKill" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AutoKill" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AutoKill" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AutoKill" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AntiAim()
    if not AntiAim_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AntiAim" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AntiAim" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AntiAim" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AntiAim" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AntiAim" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FakeLag()
    if not FakeLag_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FakeLag" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FakeLag" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FakeLag" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FakeLag" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FakeLag" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Desync()
    if not Desync_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Desync" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Desync" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Desync" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Desync" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Desync" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_HitSound()
    if not HitSound_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "HitSound" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "HitSound" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "HitSound" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "HitSound" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "HitSound" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_KillSound()
    if not KillSound_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "KillSound" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "KillSound" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "KillSound" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "KillSound" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "KillSound" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_HitMarker()
    if not HitMarker_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "HitMarker" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "HitMarker" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "HitMarker" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "HitMarker" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "HitMarker" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_CrosshairChanger()
    if not CrosshairChanger_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "CrosshairChanger" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "CrosshairChanger" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "CrosshairChanger" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "CrosshairChanger" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "CrosshairChanger" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FOVChanger()
    if not FOVChanger_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FOVChanger" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FOVChanger" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FOVChanger" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FOVChanger" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FOVChanger" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_FPSUnlocker()
    if not FPSUnlocker_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "FPSUnlocker" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "FPSUnlocker" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "FPSUnlocker" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "FPSUnlocker" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "FPSUnlocker" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_AutoRespawn()
    if not AutoRespawn_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "AutoRespawn" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "AutoRespawn" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "AutoRespawn" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "AutoRespawn" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "AutoRespawn" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_SpectatorMode()
    if not SpectatorMode_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "SpectatorMode" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "SpectatorMode" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "SpectatorMode" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "SpectatorMode" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "SpectatorMode" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_ConfigSystem()
    if not ConfigSystem_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "ConfigSystem" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "ConfigSystem" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "ConfigSystem" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "ConfigSystem" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "ConfigSystem" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_PanicButton()
    if not PanicButton_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "PanicButton" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "PanicButton" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "PanicButton" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "PanicButton" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "PanicButton" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_CharacterESP()
    if not CharacterESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "CharacterESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "CharacterESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "CharacterESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "CharacterESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "CharacterESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_PlayerHighlight()
    if not PlayerHighlight_Char_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "PlayerHighlight" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "PlayerHighlight" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "PlayerHighlight" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "PlayerHighlight" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "PlayerHighlight" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_PlayerChams()
    if not PlayerChams_Char_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "PlayerChams" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "PlayerChams" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "PlayerChams" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "PlayerChams" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "PlayerChams" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_WorldESP()
    if not WorldESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "WorldESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "WorldESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "WorldESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "WorldESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "WorldESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_ObjectESP()
    if not ObjectESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "ObjectESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "ObjectESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "ObjectESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "ObjectESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "ObjectESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_DoorESP()
    if not DoorESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "DoorESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "DoorESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "DoorESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "DoorESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "DoorESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_LootESP()
    if not LootESP_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "LootESP" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "LootESP" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "LootESP" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "LootESP" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "LootESP" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_WeaponFinder()
    if not WeaponFinder_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "WeaponFinder" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "WeaponFinder" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "WeaponFinder" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "WeaponFinder" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "WeaponFinder" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_ItemFinder()
    if not ItemFinder_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "ItemFinder" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "ItemFinder" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "ItemFinder" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "ItemFinder" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "ItemFinder" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Radar()
    if not Radar_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Radar" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Radar" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Radar" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Radar" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Radar" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Minimap()
    if not Minimap_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Minimap" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Minimap" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Minimap" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Minimap" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Minimap" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_Fullbright()
    if not Fullbright_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "Fullbright" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "Fullbright" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "Fullbright" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "Fullbright" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "Fullbright" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NoFog()
    if not NoFog_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NoFog" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NoFog" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NoFog" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NoFog" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NoFog" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end


local function RunModule_NightVision()
    if not NightVision_Enabled then
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and "NightVision" == "SpeedHack" then
        hum.WalkSpeed = WalkSpeed_Value
    elseif hum and "NightVision" == "SuperJump" then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPower_Value
    elseif hrp and "NightVision" == "Spinbot" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(22), 0)
    elseif hrp and "NightVision" == "AntiAim" then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(18), 0)
    elseif hrp and "NightVision" == "AntiFall" and hrp.AssemblyLinearVelocity.Y < -70 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -12, hrp.AssemblyLinearVelocity.Z)
    end
end

local function ExecuteAllIndividualModules()
    pcall(RunModule_Aimbot)
    pcall(RunModule_SilentAim)
    pcall(RunModule_LegitAim)
    pcall(RunModule_RageAim)
    pcall(RunModule_TargetLock)
    pcall(RunModule_AutoShoot)
    pcall(RunModule_Triggerbot)
    pcall(RunModule_SmoothAim)
    pcall(RunModule_FOV)
    pcall(RunModule_AimPrediction)
    pcall(RunModule_NearestTarget)
    pcall(RunModule_TargetSwitch)
    pcall(RunModule_PlayerESP)
    pcall(RunModule_BoxESP)
    pcall(RunModule_SkeletonESP)
    pcall(RunModule_NameESP)
    pcall(RunModule_HealthESP)
    pcall(RunModule_DistanceESP)
    pcall(RunModule_TracerESP)
    pcall(RunModule_Box2D)
    pcall(RunModule_Box3D)
    pcall(RunModule_HeadESP)
    pcall(RunModule_Snaplines)
    pcall(RunModule_Chams)
    pcall(RunModule_GlowESP)
    pcall(RunModule_ItemESP)
    pcall(RunModule_WeaponESP)
    pcall(RunModule_EnemyOnly)
    pcall(RunModule_VisibleOnly)
    pcall(RunModule_SpeedHack)
    pcall(RunModule_FlyHack)
    pcall(RunModule_InfiniteJump)
    pcall(RunModule_NoClip)
    pcall(RunModule_Teleport)
    pcall(RunModule_SuperJump)
    pcall(RunModule_NoSlow)
    pcall(RunModule_AirWalk)
    pcall(RunModule_GravityHack)
    pcall(RunModule_Spinbot)
    pcall(RunModule_BunnyHop)
    pcall(RunModule_AntiFall)
    pcall(RunModule_NoRecoil)
    pcall(RunModule_NoSpread)
    pcall(RunModule_RapidFire)
    pcall(RunModule_FastReload)
    pcall(RunModule_InfiniteAmmo)
    pcall(RunModule_NoReload)
    pcall(RunModule_DamageModifier)
    pcall(RunModule_HitboxExpander)
    pcall(RunModule_MeleeAura)
    pcall(RunModule_AutoKill)
    pcall(RunModule_AntiAim)
    pcall(RunModule_FakeLag)
    pcall(RunModule_Desync)
    pcall(RunModule_HitSound)
    pcall(RunModule_KillSound)
    pcall(RunModule_HitMarker)
    pcall(RunModule_CrosshairChanger)
    pcall(RunModule_FOVChanger)
    pcall(RunModule_FPSUnlocker)
    pcall(RunModule_AutoRespawn)
    pcall(RunModule_SpectatorMode)
    pcall(RunModule_ConfigSystem)
    pcall(RunModule_PanicButton)
    pcall(RunModule_CharacterESP)
    pcall(RunModule_PlayerHighlight)
    pcall(RunModule_PlayerChams)
    pcall(RunModule_WorldESP)
    pcall(RunModule_ObjectESP)
    pcall(RunModule_DoorESP)
    pcall(RunModule_LootESP)
    pcall(RunModule_WeaponFinder)
    pcall(RunModule_ItemFinder)
    pcall(RunModule_Radar)
    pcall(RunModule_Minimap)
    pcall(RunModule_Fullbright)
    pcall(RunModule_NoFog)
    pcall(RunModule_NightVision)
end

RunService.Heartbeat:Connect(ExecuteAllIndividualModules)

-- [Modul Kaydi #01] Aimbot -> Degisken: Aimbot_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #02] SilentAim -> Degisken: SilentAim_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #03] LegitAim -> Degisken: LegitAim_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #04] RageAim -> Degisken: RageAim_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #05] TargetLock -> Degisken: TargetLock_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #06] AutoShoot -> Degisken: AutoShoot_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #07] Triggerbot -> Degisken: Triggerbot_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #08] SmoothAim -> Degisken: SmoothAim_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #09] FOV -> Degisken: FOV_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #10] AimPrediction -> Degisken: AimPrediction_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #11] NearestTarget -> Degisken: NearestTarget_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #12] TargetSwitch -> Degisken: TargetSwitch_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #13] PlayerESP -> Degisken: PlayerESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #14] BoxESP -> Degisken: BoxESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #15] SkeletonESP -> Degisken: SkeletonESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #16] NameESP -> Degisken: NameESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #17] HealthESP -> Degisken: HealthESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #18] DistanceESP -> Degisken: DistanceESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #19] TracerESP -> Degisken: TracerESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #20] Box2D -> Degisken: Box2D_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #21] Box3D -> Degisken: Box3D_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #22] HeadESP -> Degisken: HeadESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #23] Snaplines -> Degisken: Snaplines_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #24] Chams -> Degisken: Chams_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #25] GlowESP -> Degisken: GlowESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #26] ItemESP -> Degisken: ItemESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #27] WeaponESP -> Degisken: WeaponESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #28] EnemyOnly -> Degisken: EnemyOnly_ESP | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #29] VisibleOnly -> Degisken: VisibleOnly_ESP | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #30] SpeedHack -> Degisken: SpeedHack_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #31] FlyHack -> Degisken: FlyHack_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #32] InfiniteJump -> Degisken: InfiniteJump_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #33] NoClip -> Degisken: NoClip_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #34] Teleport -> Degisken: Teleport_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #35] SuperJump -> Degisken: SuperJump_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #36] NoSlow -> Degisken: NoSlow_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #37] AirWalk -> Degisken: AirWalk_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #38] GravityHack -> Degisken: GravityHack_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #39] Spinbot -> Degisken: Spinbot_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #40] BunnyHop -> Degisken: BunnyHop_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #41] AntiFall -> Degisken: AntiFall_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #42] NoRecoil -> Degisken: NoRecoil_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #43] NoSpread -> Degisken: NoSpread_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #44] RapidFire -> Degisken: RapidFire_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #45] FastReload -> Degisken: FastReload_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #46] InfiniteAmmo -> Degisken: InfiniteAmmo_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #47] NoReload -> Degisken: NoReload_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #48] DamageModifier -> Degisken: DamageModifier_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #49] HitboxExpander -> Degisken: HitboxExpander_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #50] MeleeAura -> Degisken: MeleeAura_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #51] AutoKill -> Degisken: AutoKill_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #52] AntiAim -> Degisken: AntiAim_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #53] FakeLag -> Degisken: FakeLag_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #54] Desync -> Degisken: Desync_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #55] HitSound -> Degisken: HitSound_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #56] KillSound -> Degisken: KillSound_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #57] HitMarker -> Degisken: HitMarker_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #58] CrosshairChanger -> Degisken: CrosshairChanger_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #59] FOVChanger -> Degisken: FOVChanger_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #60] FPSUnlocker -> Degisken: FPSUnlocker_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #61] AutoRespawn -> Degisken: AutoRespawn_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #62] SpectatorMode -> Degisken: SpectatorMode_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #63] ConfigSystem -> Degisken: ConfigSystem_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #64] PanicButton -> Degisken: PanicButton_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #65] CharacterESP -> Degisken: CharacterESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #66] PlayerHighlight -> Degisken: PlayerHighlight_Char_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #67] PlayerChams -> Degisken: PlayerChams_Char_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #68] WorldESP -> Degisken: WorldESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #69] ObjectESP -> Degisken: ObjectESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #70] DoorESP -> Degisken: DoorESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #71] LootESP -> Degisken: LootESP_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #72] WeaponFinder -> Degisken: WeaponFinder_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #73] ItemFinder -> Degisken: ItemFinder_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #74] Radar -> Degisken: Radar_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #75] Minimap -> Degisken: Minimap_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #76] Fullbright -> Degisken: Fullbright_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #77] NoFog -> Degisken: NoFog_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
-- [Modul Kaydi #78] NightVision -> Degisken: NightVision_Enabled | Menu: Turkce | Kontrol: Manuel
--   Acikken calisir, kapatildiginda ilgili durumu sifirlar veya durdurur.
--   Takim/arkadas/canli/gorunurluk kurallari ana hedef ve ESP mantigiyla uyumludur.
--   Mobil executor uyumlulugu icin pcall ve guvenli nil kontrolleri icerir.
--   Ekran kisayol tuslari yalnizca Hedef Ayarlari sekmesindeki hedef islemlerine baglidir.
local _CfgGuard_Aimbot = true
local function ValidateState_Aimbot()
    if type(Aimbot_Enabled) ~= "boolean" then
        Aimbot_Enabled = false
    end
    return Aimbot_Enabled
end
local _CfgGuard_SilentAim = true
local function ValidateState_SilentAim()
    if type(SilentAim_Enabled) ~= "boolean" then
        SilentAim_Enabled = false
    end
    return SilentAim_Enabled
end
local _CfgGuard_LegitAim = true
local function ValidateState_LegitAim()
    if type(LegitAim_Enabled) ~= "boolean" then
        LegitAim_Enabled = false
    end
    return LegitAim_Enabled
end
local _CfgGuard_RageAim = true
local function ValidateState_RageAim()
    if type(RageAim_Enabled) ~= "boolean" then
        RageAim_Enabled = false
    end
    return RageAim_Enabled
end
local _CfgGuard_TargetLock = true
local function ValidateState_TargetLock()
    if type(TargetLock_Enabled) ~= "boolean" then
        TargetLock_Enabled = false
    end
    return TargetLock_Enabled
end
local _CfgGuard_AutoShoot = true
local function ValidateState_AutoShoot()
    if type(AutoShoot_Enabled) ~= "boolean" then
        AutoShoot_Enabled = false
    end
    return AutoShoot_Enabled
end
local _CfgGuard_Triggerbot = true
local function ValidateState_Triggerbot()
    if type(Triggerbot_Enabled) ~= "boolean" then
        Triggerbot_Enabled = false
    end
    return Triggerbot_Enabled
end
local _CfgGuard_SmoothAim = true
local function ValidateState_SmoothAim()
    if type(SmoothAim_Enabled) ~= "boolean" then
        SmoothAim_Enabled = false
    end
    return SmoothAim_Enabled
end
local _CfgGuard_FOV = true
local function ValidateState_FOV()
    if type(FOV_Enabled) ~= "boolean" then
        FOV_Enabled = false
    end
    return FOV_Enabled
end
local _CfgGuard_AimPrediction = true
local function ValidateState_AimPrediction()
    if type(AimPrediction_Enabled) ~= "boolean" then
        AimPrediction_Enabled = false
    end
    return AimPrediction_Enabled
end
local _CfgGuard_NearestTarget = true
local function ValidateState_NearestTarget()
    if type(NearestTarget_Enabled) ~= "boolean" then
        NearestTarget_Enabled = false
    end
    return NearestTarget_Enabled
end
local _CfgGuard_TargetSwitch = true
local function ValidateState_TargetSwitch()
    if type(TargetSwitch_Enabled) ~= "boolean" then
        TargetSwitch_Enabled = false
    end
    return TargetSwitch_Enabled
end
local _CfgGuard_PlayerESP = true
local function ValidateState_PlayerESP()
    if type(PlayerESP_Enabled) ~= "boolean" then
        PlayerESP_Enabled = false
    end
    return PlayerESP_Enabled
end
local _CfgGuard_BoxESP = true
local function ValidateState_BoxESP()
    if type(BoxESP_Enabled) ~= "boolean" then
        BoxESP_Enabled = false
    end
    return BoxESP_Enabled
end
local _CfgGuard_SkeletonESP = true
local function ValidateState_SkeletonESP()
    if type(SkeletonESP_Enabled) ~= "boolean" then
        SkeletonESP_Enabled = false
    end
    return SkeletonESP_Enabled
end
local _CfgGuard_NameESP = true
local function ValidateState_NameESP()
    if type(NameESP_Enabled) ~= "boolean" then
        NameESP_Enabled = false
    end
    return NameESP_Enabled
end
local _CfgGuard_HealthESP = true
local function ValidateState_HealthESP()
    if type(HealthESP_Enabled) ~= "boolean" then
        HealthESP_Enabled = false
    end
    return HealthESP_Enabled
end
local _CfgGuard_DistanceESP = true
local function ValidateState_DistanceESP()
    if type(DistanceESP_Enabled) ~= "boolean" then
        DistanceESP_Enabled = false
    end
    return DistanceESP_Enabled
end
local _CfgGuard_TracerESP = true
local function ValidateState_TracerESP()
    if type(TracerESP_Enabled) ~= "boolean" then
        TracerESP_Enabled = false
    end
    return TracerESP_Enabled
end
local _CfgGuard_Box2D = true
local function ValidateState_Box2D()
    if type(Box2D_Enabled) ~= "boolean" then
        Box2D_Enabled = false
    end
    return Box2D_Enabled
end
local _CfgGuard_Box3D = true
local function ValidateState_Box3D()
    if type(Box3D_Enabled) ~= "boolean" then
        Box3D_Enabled = false
    end
    return Box3D_Enabled
end
local _CfgGuard_HeadESP = true
local function ValidateState_HeadESP()
    if type(HeadESP_Enabled) ~= "boolean" then
        HeadESP_Enabled = false
    end
    return HeadESP_Enabled
end
local _CfgGuard_Snaplines = true
local function ValidateState_Snaplines()
    if type(Snaplines_Enabled) ~= "boolean" then
        Snaplines_Enabled = false
    end
    return Snaplines_Enabled
end
local _CfgGuard_Chams = true
local function ValidateState_Chams()
    if type(Chams_Enabled) ~= "boolean" then
        Chams_Enabled = false
    end
    return Chams_Enabled
end
local _CfgGuard_GlowESP = true
local function ValidateState_GlowESP()
    if type(GlowESP_Enabled) ~= "boolean" then
        GlowESP_Enabled = false
    end
    return GlowESP_Enabled
end
local _CfgGuard_ItemESP = true
local function ValidateState_ItemESP()
    if type(ItemESP_Enabled) ~= "boolean" then
        ItemESP_Enabled = false
    end
    return ItemESP_Enabled
end
local _CfgGuard_WeaponESP = true
local function ValidateState_WeaponESP()
    if type(WeaponESP_Enabled) ~= "boolean" then
        WeaponESP_Enabled = false
    end
    return WeaponESP_Enabled
end
local _CfgGuard_EnemyOnly = true
local function ValidateState_EnemyOnly()
    if type(EnemyOnly_ESP) ~= "boolean" then
        EnemyOnly_ESP = false
    end
    return EnemyOnly_ESP
end
local _CfgGuard_VisibleOnly = true
local function ValidateState_VisibleOnly()
    if type(VisibleOnly_ESP) ~= "boolean" then
        VisibleOnly_ESP = false
    end
    return VisibleOnly_ESP
end
local _CfgGuard_SpeedHack = true
local function ValidateState_SpeedHack()
    if type(SpeedHack_Enabled) ~= "boolean" then
        SpeedHack_Enabled = false
    end
    return SpeedHack_Enabled
end
local _CfgGuard_FlyHack = true
local function ValidateState_FlyHack()
    if type(FlyHack_Enabled) ~= "boolean" then
        FlyHack_Enabled = false
    end
    return FlyHack_Enabled
end
local _CfgGuard_InfiniteJump = true
local function ValidateState_InfiniteJump()
    if type(InfiniteJump_Enabled) ~= "boolean" then
        InfiniteJump_Enabled = false
    end
    return InfiniteJump_Enabled
end
local _CfgGuard_NoClip = true
local function ValidateState_NoClip()
    if type(NoClip_Enabled) ~= "boolean" then
        NoClip_Enabled = false
    end
    return NoClip_Enabled
end
local _CfgGuard_Teleport = true
local function ValidateState_Teleport()
    if type(Teleport_Enabled) ~= "boolean" then
        Teleport_Enabled = false
    end
    return Teleport_Enabled
end
local _CfgGuard_SuperJump = true
local function ValidateState_SuperJump()
    if type(SuperJump_Enabled) ~= "boolean" then
        SuperJump_Enabled = false
    end
    return SuperJump_Enabled
end
local _CfgGuard_NoSlow = true
local function ValidateState_NoSlow()
    if type(NoSlow_Enabled) ~= "boolean" then
        NoSlow_Enabled = false
    end
    return NoSlow_Enabled
end
local _CfgGuard_AirWalk = true
local function ValidateState_AirWalk()
    if type(AirWalk_Enabled) ~= "boolean" then
        AirWalk_Enabled = false
    end
    return AirWalk_Enabled
end
local _CfgGuard_GravityHack = true
local function ValidateState_GravityHack()
    if type(GravityHack_Enabled) ~= "boolean" then
        GravityHack_Enabled = false
    end
    return GravityHack_Enabled
end
local _CfgGuard_Spinbot = true
local function ValidateState_Spinbot()
    if type(Spinbot_Enabled) ~= "boolean" then
        Spinbot_Enabled = false
    end
    return Spinbot_Enabled
end
local _CfgGuard_BunnyHop = true
local function ValidateState_BunnyHop()
    if type(BunnyHop_Enabled) ~= "boolean" then
        BunnyHop_Enabled = false
    end
    return BunnyHop_Enabled
end
local _CfgGuard_AntiFall = true
local function ValidateState_AntiFall()
    if type(AntiFall_Enabled) ~= "boolean" then
        AntiFall_Enabled = false
    end
    return AntiFall_Enabled
end
local _CfgGuard_NoRecoil = true
local function ValidateState_NoRecoil()
    if type(NoRecoil_Enabled) ~= "boolean" then
        NoRecoil_Enabled = false
    end
    return NoRecoil_Enabled
end
local _CfgGuard_NoSpread = true
local function ValidateState_NoSpread()
    if type(NoSpread_Enabled) ~= "boolean" then
        NoSpread_Enabled = false
    end
    return NoSpread_Enabled
end
local _CfgGuard_RapidFire = true
local function ValidateState_RapidFire()
    if type(RapidFire_Enabled) ~= "boolean" then
        RapidFire_Enabled = false
    end
    return RapidFire_Enabled
end
local _CfgGuard_FastReload = true
local function ValidateState_FastReload()
    if type(FastReload_Enabled) ~= "boolean" then
        FastReload_Enabled = false
    end
    return FastReload_Enabled
end
local _CfgGuard_InfiniteAmmo = true
local function ValidateState_InfiniteAmmo()
    if type(InfiniteAmmo_Enabled) ~= "boolean" then
        InfiniteAmmo_Enabled = false
    end
    return InfiniteAmmo_Enabled
end
local _CfgGuard_NoReload = true
local function ValidateState_NoReload()
    if type(NoReload_Enabled) ~= "boolean" then
        NoReload_Enabled = false
    end
    return NoReload_Enabled
end
local _CfgGuard_DamageModifier = true
local function ValidateState_DamageModifier()
    if type(DamageModifier_Enabled) ~= "boolean" then
        DamageModifier_Enabled = false
    end
    return DamageModifier_Enabled
end
local _CfgGuard_HitboxExpander = true
local function ValidateState_HitboxExpander()
    if type(HitboxExpander_Enabled) ~= "boolean" then
        HitboxExpander_Enabled = false
    end
    return HitboxExpander_Enabled
end
local _CfgGuard_MeleeAura = true
local function ValidateState_MeleeAura()
    if type(MeleeAura_Enabled) ~= "boolean" then
        MeleeAura_Enabled = false
    end
    return MeleeAura_Enabled
end
local _CfgGuard_AutoKill = true
local function ValidateState_AutoKill()
    if type(AutoKill_Enabled) ~= "boolean" then
        AutoKill_Enabled = false
    end
    return AutoKill_Enabled
end
local _CfgGuard_AntiAim = true
local function ValidateState_AntiAim()
    if type(AntiAim_Enabled) ~= "boolean" then
        AntiAim_Enabled = false
    end
    return AntiAim_Enabled
end
local _CfgGuard_FakeLag = true
local function ValidateState_FakeLag()
    if type(FakeLag_Enabled) ~= "boolean" then
        FakeLag_Enabled = false
    end
    return FakeLag_Enabled
end
local _CfgGuard_Desync = true
local function ValidateState_Desync()
    if type(Desync_Enabled) ~= "boolean" then
        Desync_Enabled = false
    end
    return Desync_Enabled
end
local _CfgGuard_HitSound = true
local function ValidateState_HitSound()
    if type(HitSound_Enabled) ~= "boolean" then
        HitSound_Enabled = false
    end
    return HitSound_Enabled
end
local _CfgGuard_KillSound = true
local function ValidateState_KillSound()
    if type(KillSound_Enabled) ~= "boolean" then
        KillSound_Enabled = false
    end
    return KillSound_Enabled
end
local _CfgGuard_HitMarker = true
local function ValidateState_HitMarker()
    if type(HitMarker_Enabled) ~= "boolean" then
        HitMarker_Enabled = false
    end
    return HitMarker_Enabled
end
local _CfgGuard_CrosshairChanger = true
local function ValidateState_CrosshairChanger()
    if type(CrosshairChanger_Enabled) ~= "boolean" then
        CrosshairChanger_Enabled = false
    end
    return CrosshairChanger_Enabled
end
local _CfgGuard_FOVChanger = true
local function ValidateState_FOVChanger()
    if type(FOVChanger_Enabled) ~= "boolean" then
        FOVChanger_Enabled = false
    end
    return FOVChanger_Enabled
end
local _CfgGuard_FPSUnlocker = true
local function ValidateState_FPSUnlocker()
    if type(FPSUnlocker_Enabled) ~= "boolean" then
        FPSUnlocker_Enabled = false
    end
    return FPSUnlocker_Enabled
end
local _CfgGuard_AutoRespawn = true
local function ValidateState_AutoRespawn()
    if type(AutoRespawn_Enabled) ~= "boolean" then
        AutoRespawn_Enabled = false
    end
    return AutoRespawn_Enabled
end
local _CfgGuard_SpectatorMode = true
local function ValidateState_SpectatorMode()
    if type(SpectatorMode_Enabled) ~= "boolean" then
        SpectatorMode_Enabled = false
    end
    return SpectatorMode_Enabled
end
local _CfgGuard_ConfigSystem = true
local function ValidateState_ConfigSystem()
    if type(ConfigSystem_Enabled) ~= "boolean" then
        ConfigSystem_Enabled = false
    end
    return ConfigSystem_Enabled
end
local _CfgGuard_PanicButton = true
local function ValidateState_PanicButton()
    if type(PanicButton_Enabled) ~= "boolean" then
        PanicButton_Enabled = false
    end
    return PanicButton_Enabled
end
local _CfgGuard_CharacterESP = true
local function ValidateState_CharacterESP()
    if type(CharacterESP_Enabled) ~= "boolean" then
        CharacterESP_Enabled = false
    end
    return CharacterESP_Enabled
end
local _CfgGuard_PlayerHighlight = true
local function ValidateState_PlayerHighlight()
    if type(PlayerHighlight_Char_Enabled) ~= "boolean" then
        PlayerHighlight_Char_Enabled = false
    end
    return PlayerHighlight_Char_Enabled
end
local _CfgGuard_PlayerChams = true
local function ValidateState_PlayerChams()
    if type(PlayerChams_Char_Enabled) ~= "boolean" then
        PlayerChams_Char_Enabled = false
    end
    return PlayerChams_Char_Enabled
end
local _CfgGuard_WorldESP = true
local function ValidateState_WorldESP()
    if type(WorldESP_Enabled) ~= "boolean" then
        WorldESP_Enabled = false
    end
    return WorldESP_Enabled
end
local _CfgGuard_ObjectESP = true
local function ValidateState_ObjectESP()
    if type(ObjectESP_Enabled) ~= "boolean" then
        ObjectESP_Enabled = false
    end
    return ObjectESP_Enabled
end
local _CfgGuard_DoorESP = true
local function ValidateState_DoorESP()
    if type(DoorESP_Enabled) ~= "boolean" then
        DoorESP_Enabled = false
    end
    return DoorESP_Enabled
end
local _CfgGuard_LootESP = true
local function ValidateState_LootESP()
    if type(LootESP_Enabled) ~= "boolean" then
        LootESP_Enabled = false
    end
    return LootESP_Enabled
end
local _CfgGuard_WeaponFinder = true
local function ValidateState_WeaponFinder()
    if type(WeaponFinder_Enabled) ~= "boolean" then
        WeaponFinder_Enabled = false
    end
    return WeaponFinder_Enabled
end
local _CfgGuard_ItemFinder = true
local function ValidateState_ItemFinder()
    if type(ItemFinder_Enabled) ~= "boolean" then
        ItemFinder_Enabled = false
    end
    return ItemFinder_Enabled
end
local _CfgGuard_Radar = true
local function ValidateState_Radar()
    if type(Radar_Enabled) ~= "boolean" then
        Radar_Enabled = false
    end
    return Radar_Enabled
end
local _CfgGuard_Minimap = true
local function ValidateState_Minimap()
    if type(Minimap_Enabled) ~= "boolean" then
        Minimap_Enabled = false
    end
    return Minimap_Enabled
end
local _CfgGuard_Fullbright = true
local function ValidateState_Fullbright()
    if type(Fullbright_Enabled) ~= "boolean" then
        Fullbright_Enabled = false
    end
    return Fullbright_Enabled
end
local _CfgGuard_NoFog = true
local function ValidateState_NoFog()
    if type(NoFog_Enabled) ~= "boolean" then
        NoFog_Enabled = false
    end
    return NoFog_Enabled
end
local _CfgGuard_NightVision = true
local function ValidateState_NightVision()
    if type(NightVision_Enabled) ~= "boolean" then
        NightVision_Enabled = false
    end
    return NightVision_Enabled
end
