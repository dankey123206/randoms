--!strict
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 01: SERVICES, STATE, THEMES, PRESETS & CORE UTILITIES (A)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- Prevent duplicate instances if re-executed in Studio Play Solo
local EXISTING_GUI = PlayerGui:FindFirstChild("MaxUltimateHub_UI")
if EXISTING_GUI then
    EXISTING_GUI:Destroy()
end

-- ============================================================================
-- 1. CENTRALIZED CONNECTION & MEMORY MANAGER
-- ============================================================================
local Hub = {
    BrandName = "tiktok: max1sroxedits01",
    Version = "v4.2.0-STUDIO",
    IsOpen = true,
    IsMinimized = false,
    IsDestroyed = false,
    ActivePage = "Home",
    Connections = {} :: { [string]: RBXScriptConnection },
    DynamicConnections = {} :: { RBXScriptConnection },
    Instances = {} :: { Instance },
    Pages = {} :: { [string]: ScrollingFrame },
    NavButtons = {} :: { [string]: TextButton },
    UIElements = {} :: { [string]: any },
    ActiveFeatures = {} :: { [string]: boolean },
    RecentFeatures = {} :: { string },
    SavedPositions = {} :: { { Name: string, CFrame: CFrame } },
    PositionHistory = {} :: { CFrame },
    Configs = {} :: { [string]: any },
    CurrentConfigName = "Default",
    Keybinds = {} :: { [string]: { Key: Enum.KeyCode?, Enabled: boolean, Category: string, Callback: () -> () } },
    ESPCache = {} :: { [Model]: any },
    TrainingStats = {
        Shots = 0,
        Hits = 0,
        TotalReactionTime = 0,
        ReactionSamples = 0,
        LastTargetSpawnTime = 0,
    },
    OriginalLighting = {},
    OriginalCharacter = {
        WalkSpeed = 16,
        JumpPower = 50,
        JumpHeight = 7.2,
        UseJumpPower = true,
        FOV = 70,
        Gravity = Workspace.Gravity,
    },
    SelectedPlayer = nil :: Player?,
    SpectatingPlayer = nil :: Player?,
    CurrentVehicle = nil :: VehicleSeat?,
    VehicleOrigin = nil :: CFrame?,
}

function Hub:TrackConnection(name: string?, conn: RBXScriptConnection): RBXScriptConnection
    if name then
        if self.Connections[name] then
            self.Connections[name]:Disconnect()
        end
        self.Connections[name] = conn
    else
        table.insert(self.DynamicConnections, conn)
    end
    return conn
end

function Hub:DisconnectNamed(name: string)
    if self.Connections[name] then
        self.Connections[name]:Disconnect()
        self.Connections[name] = nil
    end
end

function Hub:CleanupAll()
    self.IsDestroyed = true
    for _, conn in pairs(self.Connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    for _, conn in ipairs(self.DynamicConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.Connections)
    table.clear(self.DynamicConnections)

    -- Clean up ESP Drawings/Billboards
    for model, data in pairs(self.ESPCache) do
        if data.Billboard then data.Billboard:Destroy() end
        if data.Highlight then data.Highlight:Destroy() end
        if data.BoxFrame then data.BoxFrame:Destroy() end
        if data.TracerLine then data.TracerLine:Destroy() end
    end
    table.clear(self.ESPCache)

    -- Restore camera if spectating
    if Camera and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
            Camera.CameraType = Enum.CameraType.Custom
        end
    end

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ============================================================================
-- 2. AUTHORIZED SERVER REMOTE BRIDGE (STUDIO INTEGRATION)
-- ============================================================================
-- Safely locates optional Studio server remotes for server-authoritative actions
-- (e.g., teleporting, spawning training targets, setting server properties).
local RemoteFolder = ReplicatedStorage:FindFirstChild("MaxHubRemotes")
local function InvokeAuthorizedServer(actionName: string, payload: any): (boolean, any)
    if not RemoteFolder then
        return false, "Server bridge 'ReplicatedStorage.MaxHubRemotes' not installed; using local fallback."
    end
    local remote = RemoteFolder:FindFirstChild(actionName)
    if remote and remote:IsA("RemoteFunction") then
        local ok, res = pcall(function()
            return remote:InvokeServer(payload)
        end)
        return ok, res
    elseif remote and remote:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            remote:FireServer(payload)
        end)
        return ok, err
    end
    return false, "Action remote '" .. actionName .. "' not configured on server."
end

-- ============================================================================
-- 3. THEMES & COLOR SYSTEM
-- ============================================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(16, 17, 22),
        Sidebar = Color3.fromRGB(21, 23, 30),
        Card = Color3.fromRGB(26, 29, 38),
        Button = Color3.fromRGB(34, 38, 50),
        ButtonHover = Color3.fromRGB(44, 49, 64),
        Accent = Color3.fromRGB(88, 130, 255),
        ToggleOn = Color3.fromRGB(88, 130, 255),
        ToggleOff = Color3.fromRGB(52, 56, 70),
        Text = Color3.fromRGB(240, 242, 248),
        SubText = Color3.fromRGB(155, 162, 180),
        Border = Color3.fromRGB(44, 48, 62),
        Success = Color3.fromRGB(64, 200, 130),
        Warning = Color3.fromRGB(245, 185, 65),
        Danger = Color3.fromRGB(235, 85, 95),
    },
    Light = {
        Background = Color3.fromRGB(240, 242, 247),
        Sidebar = Color3.fromRGB(230, 233, 240),
        Card = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(224, 228, 238),
        ButtonHover = Color3.fromRGB(210, 215, 228),
        Accent = Color3.fromRGB(52, 102, 240),
        ToggleOn = Color3.fromRGB(52, 102, 240),
        ToggleOff = Color3.fromRGB(185, 192, 208),
        Text = Color3.fromRGB(22, 25, 34),
        SubText = Color3.fromRGB(95, 102, 120),
        Border = Color3.fromRGB(205, 210, 222),
        Success = Color3.fromRGB(35, 165, 95),
        Warning = Color3.fromRGB(215, 145, 25),
        Danger = Color3.fromRGB(215, 55, 65),
    },
    Midnight = {
        Background = Color3.fromRGB(10, 12, 18),
        Sidebar = Color3.fromRGB(13, 16, 24),
        Card = Color3.fromRGB(17, 21, 32),
        Button = Color3.fromRGB(24, 30, 46),
        ButtonHover = Color3.fromRGB(32, 40, 60),
        Accent = Color3.fromRGB(56, 189, 248),
        ToggleOn = Color3.fromRGB(56, 189, 248),
        ToggleOff = Color3.fromRGB(38, 46, 66),
        Text = Color3.fromRGB(235, 245, 255),
        SubText = Color3.fromRGB(130, 150, 175),
        Border = Color3.fromRGB(30, 38, 56),
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Danger = Color3.fromRGB(248, 113, 113),
    },
    Crimson = {
        Background = Color3.fromRGB(20, 14, 16),
        Sidebar = Color3.fromRGB(26, 18, 21),
        Card = Color3.fromRGB(34, 22, 26),
        Button = Color3.fromRGB(46, 28, 34),
        ButtonHover = Color3.fromRGB(62, 36, 44),
        Accent = Color3.fromRGB(235, 68, 90),
        ToggleOn = Color3.fromRGB(235, 68, 90),
        ToggleOff = Color3.fromRGB(64, 42, 48),
        Text = Color3.fromRGB(248, 238, 240),
        SubText = Color3.fromRGB(178, 148, 154),
        Border = Color3.fromRGB(60, 38, 44),
        Success = Color3.fromRGB(64, 200, 130),
        Warning = Color3.fromRGB(245, 185, 65),
        Danger = Color3.fromRGB(255, 85, 100),
    },
    Purple = {
        Background = Color3.fromRGB(18, 15, 26),
        Sidebar = Color3.fromRGB(23, 19, 34),
        Card = Color3.fromRGB(30, 25, 44),
        Button = Color3.fromRGB(40, 33, 58),
        ButtonHover = Color3.fromRGB(52, 43, 76),
        Accent = Color3.fromRGB(168, 85, 247),
        ToggleOn = Color3.fromRGB(168, 85, 247),
        ToggleOff = Color3.fromRGB(56, 48, 78),
        Text = Color3.fromRGB(244, 240, 252),
        SubText = Color3.fromRGB(162, 150, 188),
        Border = Color3.fromRGB(52, 44, 74),
        Success = Color3.fromRGB(64, 200, 130),
        Warning = Color3.fromRGB(245, 185, 65),
        Danger = Color3.fromRGB(235, 85, 95),
    },
    Blue = {
        Background = Color3.fromRGB(14, 19, 28),
        Sidebar = Color3.fromRGB(18, 25, 36),
        Card = Color3.fromRGB(23, 32, 46),
        Button = Color3.fromRGB(30, 42, 60),
        ButtonHover = Color3.fromRGB(40, 56, 80),
        Accent = Color3.fromRGB(59, 130, 246),
        ToggleOn = Color3.fromRGB(59, 130, 246),
        ToggleOff = Color3.fromRGB(46, 60, 82),
        Text = Color3.fromRGB(238, 244, 252),
        SubText = Color3.fromRGB(148, 166, 192),
        Border = Color3.fromRGB(42, 56, 78),
        Success = Color3.fromRGB(64, 200, 130),
        Warning = Color3.fromRGB(245, 185, 65),
        Danger = Color3.fromRGB(235, 85, 95),
    },
    Emerald = {
        Background = Color3.fromRGB(13, 21, 19),
        Sidebar = Color3.fromRGB(17, 28, 25),
        Card = Color3.fromRGB(22, 36, 32),
        Button = Color3.fromRGB(29, 48, 42),
        ButtonHover = Color3.fromRGB(38, 64, 56),
        Accent = Color3.fromRGB(16, 185, 129),
        ToggleOn = Color3.fromRGB(16, 185, 129),
        ToggleOff = Color3.fromRGB(44, 68, 60),
        Text = Color3.fromRGB(236, 250, 245),
        SubText = Color3.fromRGB(145, 178, 168),
        Border = Color3.fromRGB(38, 62, 54),
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(245, 185, 65),
        Danger = Color3.fromRGB(235, 85, 95),
    },
}
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 02: SERVICES, STATE, THEMES, PRESETS & CORE UTILITIES (B)
-- ============================================================================

-- ============================================================================
-- 4. DEFAULT SETTINGS & LIVE STATE CONFIGURATION
-- ============================================================================
local DefaultState = {
    ThemeName = "Dark",
    CustomTheme = table.clone(Themes.Dark),
    UI = {
        WindowWidth = 780,
        WindowHeight = 520,
        SidebarWidth = 195,
        CornerRadius = 8,
        BorderThickness = 1,
        Transparency = 0,
        UIScale = 1.0,
        Font = Enum.Font.GothamMedium,
        FontSize = 14,
        Spacing = 8,
        ButtonHeight = 36,
        ToggleSize = 20,
        AnimationsEnabled = true,
        AnimationSpeed = 0.22,
        KeybindsEnabled = true,
        ToggleMenuKey = Enum.KeyCode.RightShift,
    },
    Audio = {
        Enabled = true,
        MasterVolume = 0.5,
        UIVolume = 0.5,
        NotifVolume = 0.6,
        ClickSoundId = "rbxassetid://6895079853",
        ToggleSoundId = "rbxassetid://6895079853",
        NotifSoundId = "rbxassetid://4590662766",
    },
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        JumpHeight = 7.2,
        Gravity = 196.2,
        FOV = 70,
        LocalTransparency = 0,
    },
    Movement = {
        FlyEnabled = false,
        FlySpeed = 60,
        FlyMode = "Camera", -- "Camera" or "Directional"
        NoclipEnabled = false,
        InfiniteJump = false,
        SprintEnabled = false,
        SprintSpeed = 32,
        CrouchEnabled = false,
        CrouchSpeed = 8,
        DashPower = 85,
        DashCooldown = 1.0,
        DoubleJump = false,
        AirControl = 1.0,
        Acceleration = 1.0,
        Deceleration = 1.0,
        CanCollide = true,
        Preset = "Default",
    },
    CharacterScale = {
        Uniform = 1.0,
        Width = 1.0,
        Height = 1.0,
        Depth = 1.0,
        Head = 1.0,
    },
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Distance = true,
        HealthText = true,
        HealthBar = true,
        Tracer = false,
        Skeleton = false,
        HeadMarker = false,
        Highlight = true,
        TeamColors = false,
        TargetNPCs = true,
        TargetDebugObjects = true,
        FilterAliveOnly = true,
        MaxDistance = 1000,
        Transparency = 0.2,
        Thickness = 2,
        TextSize = 13,
        CustomColor = Color3.fromRGB(88, 130, 255),
        TracerOrigin = "Bottom", -- "Bottom", "Center", "Mouse"
    },
    Combat = {
        AimTrainingActive = false,
        TargetTracking = false,
        Smoothness = 0.25,
        TargetSize = 3.0,
        TargetMovement = "Static", -- "Static", "Strafe", "Orbit", "Random"
        HitDetectionVis = true,
        HitboxVis = false,
        ProjectileVis = true,
        SimDamage = 25,
        SelectedTarget = nil :: Model?,
    },
    Vehicle = {
        FlyEnabled = false,
        FlySpeed = 80,
        MaxSpeed = 120,
        Acceleration = 1.0,
        Deceleration = 1.0,
        SteeringSensitivity = 1.0,
        BoostPower = 180,
        Stabilization = true,
        ControlMode = "Default", -- "Default", "Smooth", "Precision", "Custom"
    },
    Graphics = {
        ShowFPS = true,
        ShowMonitor = false,
        Shadows = true,
        ParticlesEnabled = true,
        EffectsEnabled = true,
        LowEffectsMode = false,
        ReducedVisuals = false,
        ColorCorrectionEnabled = false,
        Brightness = 0,
        Contrast = 0,
        Saturation = 0,
        BloomEnabled = false,
        BloomIntensity = 0.4,
        BlurEnabled = false,
        BlurSize = 4,
        SunRaysEnabled = false,
        Preset = "Balanced",
    },
    World = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        AtmosphereDensity = 0.3,
    },
}

local function DeepCopy(orig: any): any
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        copy[DeepCopy(k)] = DeepCopy(v)
    end
    return copy
end

Hub.State = DeepCopy(DefaultState)
Hub.Theme = DeepCopy(Themes.Dark)

-- Snapshot initial Lighting state for clean reversibility
Hub.OriginalLighting = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
}

-- ============================================================================
-- 5. UTILITY HELPERS (TWEENS, AUDIO, COLOR, VALIDATION)
-- ============================================================================
local function GetTweenInfo(durationOverride: number?): TweenInfo
    local speed = Hub.State.UI.AnimationsEnabled and (durationOverride or Hub.State.UI.AnimationSpeed) or 0.001
    return TweenInfo.new(math.max(0.001, speed), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

local function PlayHubSound(kind: "Click" | "Toggle" | "Notif")
    if not Hub.State.Audio.Enabled then return end
    local id = Hub.State.Audio.ClickSoundId
    local vol = Hub.State.Audio.UIVolume
    if kind == "Toggle" then
        id = Hub.State.Audio.ToggleSoundId
    elseif kind == "Notif" then
        id = Hub.State.Audio.NotifSoundId
        vol = Hub.State.Audio.NotifVolume
    end
    local finalVol = math.clamp(vol * Hub.State.Audio.MasterVolume, 0, 2)
    if finalVol <= 0 then return end

    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = finalVol
    sound.Parent = SoundService
    sound:Play()
    task.delay(2, function()
        if sound and sound.Parent then
            sound:Destroy()
        end
    end)
end

local function Color3ToHex(c: Color3): string
    return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function HexToColor3(hex: string): Color3?
    hex = hex:gsub("#", ""):gsub("%s+", "")
    if #hex ~= 6 then return nil end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if r and g and b then
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

local function RecordFeatureUsage(featureName: string, active: boolean?)
    if active ~= nil then
        Hub.ActiveFeatures[featureName] = active or nil
    end
    -- Maintain unique recent list of max 8 items
    for i = #Hub.RecentFeatures, 1, -1 do
        if Hub.RecentFeatures[i] == featureName then
            table.remove(Hub.RecentFeatures, i)
        end
    end
    table.insert(Hub.RecentFeatures, 1, featureName)
    if #Hub.RecentFeatures > 8 then
        table.remove(Hub.RecentFeatures)
    end
end

local function GetCharacterParts(): (Model?, Humanoid?, BasePart?)
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    return char, hum, hrp
end

local function AddCorner(parent: GuiObject, radiusOverride: number?): UICorner
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radiusOverride or Hub.State.UI.CornerRadius)
    c.Parent = parent
    return c
end

local function AddStroke(parent: GuiObject, colorOverride: Color3?, thicknessOverride: number?): UIStroke
    local s = Instance.new("UIStroke")
    s.Color = colorOverride or Hub.Theme.Border
    s.Thickness = thicknessOverride or Hub.State.UI.BorderThickness
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddPadding(parent: GuiObject, top: number, bottom: number, left: number, right: number): UIPadding
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top)
    p.PaddingBottom = UDim.new(0, bottom)
    p.PaddingLeft = UDim.new(0, left)
    p.PaddingRight = UDim.new(0, right)
    p.Parent = parent
    return p
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 03: GUI FRAMEWORK, LOADING SCREEN, NOTIFICATIONS & WINDOW (A)
-- ============================================================================

-- 1. SCREEN GUI & ROOT CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MaxUltimateHub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui
Hub.ScreenGui = ScreenGui

local UIScaleObj = Instance.new("UIScale")
UIScaleObj.Scale = Hub.State.UI.UIScale
UIScaleObj.Parent = ScreenGui
Hub.UIScaleObj = UIScaleObj

-- 2. NOTIFICATION SYSTEM
local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "NotificationHolder"
NotifHolder.Size = UDim2.new(0, 310, 1, -30)
NotifHolder.Position = UDim2.new(1, -325, 0, 15)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 100
NotifHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifHolder

function Hub:Notify(title: string, message: string, kind: ("Info" | "Success" | "Warning" | "Danger")?, duration: number?)
    if self.IsDestroyed then return end
    PlayHubSound("Notif")

    local accent = self.Theme.Accent
    if kind == "Success" then accent = self.Theme.Success
    elseif kind == "Warning" then accent = self.Theme.Warning
    elseif kind == "Danger" then accent = self.Theme.Danger end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 68)
    card.BackgroundColor3 = self.Theme.Card
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = 101
    card.Parent = NotifHolder
    AddCorner(card, 8)
    AddStroke(card, accent, 1.2)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 102
    bar.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 22)
    titleLbl.Position = UDim2.new(0, 12, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = self.Theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = title .. " • " .. self.BrandName
    titleLbl.ZIndex = 102
    titleLbl.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 34)
    msgLbl.Position = UDim2.new(0, 12, 0, 28)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 12
    msgLbl.TextColor3 = self.Theme.SubText
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextWrapped = true
    msgLbl.Text = message
    msgLbl.ZIndex = 102
    msgLbl.Parent = card

    -- Progress timer bar
    local timerBar = Instance.new("Frame")
    timerBar.Size = UDim2.new(1, 0, 0, 2)
    timerBar.Position = UDim2.new(0, 0, 1, -2)
    timerBar.BackgroundColor3 = accent
    timerBar.BorderSizePixel = 0
    timerBar.ZIndex = 103
    timerBar.Parent = card

    local life = duration or 3.5
    TweenService:Create(timerBar, TweenInfo.new(life, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    task.delay(life, function()
        if card and card.Parent then
            local tw = TweenService:Create(card, GetTweenInfo(0.25), { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
            tw:Play()
            tw.Completed:Wait()
            if card then card:Destroy() end
        end
    end)
end

-- 3. LOADING SPLASH OVERLAY
local SplashFrame = Instance.new("Frame")
SplashFrame.Name = "LoadingSplash"
SplashFrame.Size = UDim2.new(0, 360, 0, 150)
SplashFrame.Position = UDim2.new(0.5, -180, 0.5, -75)
SplashFrame.BackgroundColor3 = Hub.Theme.Background
SplashFrame.ZIndex = 90
SplashFrame.Parent = ScreenGui
AddCorner(SplashFrame, 12)
AddStroke(SplashFrame, Hub.Theme.Accent, 1.5)

local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(1, -24, 0, 32)
SplashTitle.Position = UDim2.new(0, 12, 0, 22)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.TextSize = 18
SplashTitle.TextColor3 = Hub.Theme.Text
SplashTitle.Text = Hub.BrandName
SplashTitle.ZIndex = 91
SplashTitle.Parent = SplashFrame

local SplashSub = Instance.new("TextLabel")
SplashSub.Size = UDim2.new(1, -24, 0, 20)
SplashSub.Position = UDim2.new(0, 12, 0, 56)
SplashSub.BackgroundTransparency = 1
SplashSub.Font = Enum.Font.Gotham
SplashSub.TextSize = 13
SplashSub.TextColor3 = Hub.Theme.SubText
SplashSub.Text = "Initializing Studio Systems & Modules..."
SplashSub.ZIndex = 91
SplashSub.Parent = SplashFrame

local LoadTrack = Instance.new("Frame")
LoadTrack.Size = UDim2.new(1, -48, 0, 8)
LoadTrack.Position = UDim2.new(0, 24, 0, 96)
LoadTrack.BackgroundColor3 = Hub.Theme.Card
LoadTrack.BorderSizePixel = 0
LoadTrack.ZIndex = 91
LoadTrack.Parent = SplashFrame
AddCorner(LoadTrack, 4)

local LoadFill = Instance.new("Frame")
LoadFill.Size = UDim2.new(0, 0, 1, 0)
LoadFill.BackgroundColor3 = Hub.Theme.Accent
LoadFill.BorderSizePixel = 0
LoadFill.ZIndex = 92
LoadFill.Parent = LoadTrack
AddCorner(LoadFill, 4)

TweenService:Create(LoadFill, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) }):Play()

-- 4. MAIN WINDOW FRAME
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, Hub.State.UI.WindowWidth, 0, Hub.State.UI.WindowHeight)
MainWindow.Position = UDim2.new(0.5, -Hub.State.UI.WindowWidth / 2, 0.5, -Hub.State.UI.WindowHeight / 2)
MainWindow.BackgroundColor3 = Hub.Theme.Background
MainWindow.BackgroundTransparency = Hub.State.UI.Transparency
MainWindow.ClipsDescendants = true
MainWindow.Visible = false
MainWindow.Parent = ScreenGui
AddCorner(MainWindow, Hub.State.UI.CornerRadius)
local MainStroke = AddStroke(MainWindow, Hub.Theme.Border, Hub.State.UI.BorderThickness)
Hub.MainWindow = MainWindow
Hub.MainStroke = MainStroke

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 44)
Topbar.BackgroundColor3 = Hub.Theme.Sidebar
Topbar.BorderSizePixel = 0
Topbar.Parent = MainWindow
Hub.Topbar = Topbar

local TopDivider = Instance.new("Frame")
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.Position = UDim2.new(0, 0, 1, -1)
TopDivider.BackgroundColor3 = Hub.Theme.Border
TopDivider.BorderSizePixel = 0
TopDivider.Parent = Topbar

local BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(0, 320, 1, 0)
BrandLabel.Position = UDim2.new(0, 16, 0, 0)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Font = Enum.Font.GothamBold
BrandLabel.TextSize = 15
BrandLabel.TextColor3 = Hub.Theme.Text
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.Text = Hub.BrandName .. "  |  " .. Hub.Version
BrandLabel.Parent = Topbar
Hub.BrandLabel = BrandLabel

-- Live FPS & Telemetry Pill in Topbar
local TelemetryLabel = Instance.new("TextLabel")
TelemetryLabel.Size = UDim2.new(0, 190, 0, 26)
TelemetryLabel.Position = UDim2.new(1, -295, 0.5, -13)
TelemetryLabel.BackgroundColor3 = Hub.Theme.Card
TelemetryLabel.Font = Enum.Font.Code
TelemetryLabel.TextSize = 12
TelemetryLabel.TextColor3 = Hub.Theme.Accent
TelemetryLabel.Text = "FPS: 60 | MEM: 0 MB"
TelemetryLabel.Parent = Topbar
AddCorner(TelemetryLabel, 6)
Hub.TelemetryLabel = TelemetryLabel

-- Topbar Control Buttons (Minimize, Close/Hide)
local function MakeTopButton(text: string, offsetX: number, hoverColor: Color3): TextButton
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 28)
    btn.Position = UDim2.new(1, offsetX, 0.5, -14)
    btn.BackgroundColor3 = Hub.Theme.Card
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Hub.Theme.Text
    btn.Text = text
    btn.AutoButtonColor = false
    btn.Parent = Topbar
    AddCorner(btn, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, GetTweenInfo(0.15), { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, GetTweenInfo(0.15), { BackgroundColor3 = Hub.Theme.Card }):Play()
    end)
    return btn
end

local MinBtn = MakeTopButton("—", -76, Hub.Theme.ButtonHover)
local CloseBtn = MakeTopButton("✕", -40, Hub.Theme.Danger)

-- Mobile / Floating Re-open Pill
local FloatingToggleBtn = Instance.new("TextButton")
FloatingToggleBtn.Name = "MobileTogglePill"
FloatingToggleBtn.Size = UDim2.new(0, 175, 0, 36)
FloatingToggleBtn.Position = UDim2.new(0, 16, 0.5, -18)
FloatingToggleBtn.BackgroundColor3 = Hub.Theme.Sidebar
FloatingToggleBtn.Font = Enum.Font.GothamBold
FloatingToggleBtn.TextSize = 12
FloatingToggleBtn.TextColor3 = Hub.Theme.Text
FloatingToggleBtn.Text = "☰ " .. Hub.BrandName
FloatingToggleBtn.Visible = false
FloatingToggleBtn.ZIndex = 80
FloatingToggleBtn.Parent = ScreenGui
AddCorner(FloatingToggleBtn, 18)
AddStroke(FloatingToggleBtn, Hub.Theme.Accent, 1.5)

function Hub:SetWindowVisible(visible: boolean)
    self.IsOpen = visible
    if visible then
        MainWindow.Visible = true
        FloatingToggleBtn.Visible = false
        MainWindow.Size = UDim2.new(0, self.State.UI.WindowWidth * 0.94, 0, self.State.UI.WindowHeight * 0.94)
        TweenService:Create(MainWindow, GetTweenInfo(), {
            Size = UDim2.new(0, self.State.UI.WindowWidth, 0, self.IsMinimized and 44 or self.State.UI.WindowHeight)
        }):Play()
    else
        local tw = TweenService:Create(MainWindow, GetTweenInfo(0.18), {
            Size = UDim2.new(0, self.State.UI.WindowWidth * 0.94, 0, 0)
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not self.IsOpen then
                MainWindow.Visible = false
                FloatingToggleBtn.Visible = true
            end
        end)
    end
end

MinBtn.MouseButton1Click:Connect(function()
    PlayHubSound("Click")
    Hub.IsMinimized = not Hub.IsMinimized
    MinBtn.Text = Hub.IsMinimized and "+" or "—"
    TweenService:Create(MainWindow, GetTweenInfo(), {
        Size = UDim2.new(0, Hub.State.UI.WindowWidth, 0, Hub.IsMinimized and 44 or Hub.State.UI.WindowHeight)
    }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    PlayHubSound("Click")
    Hub:SetWindowVisible(false)
    Hub:Notify("UI Hidden", "Press RightShift or tap the floating pill to reopen.", "Info", 3)
end)

FloatingToggleBtn.MouseButton1Click:Connect(function()
    PlayHubSound("Click")
    Hub:SetWindowVisible(true)
end)

-- Smooth Dragging (PC Mouse + Mobile Touch)
do
    local dragging = false
    local dragInput: InputObject? = nil
    local dragStart = Vector2.zero
    local startPos = UDim2.new()

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = MainWindow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Hub:TrackConnection("WindowDrag", UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local scale = UIScaleObj.Scale
            MainWindow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + (delta.X / scale),
                startPos.Y.Scale,
                startPos.Y.Offset + (delta.Y / scale)
            )
        end
    end))
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 04: SIDEBAR NAVIGATION, PAGES & COMPONENT BUILDERS (A)
-- ============================================================================

-- 5. SIDEBAR & CONTENT AREA
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, Hub.State.UI.SidebarWidth, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Hub.Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow
Hub.Sidebar = Sidebar

local SideDivider = Instance.new("Frame")
SideDivider.Size = UDim2.new(0, 1, 1, 0)
SideDivider.Position = UDim2.new(1, -1, 0, 0)
SideDivider.BackgroundColor3 = Hub.Theme.Border
SideDivider.BorderSizePixel = 0
SideDivider.Parent = Sidebar

-- Navigation Search Box
local NavSearchBox = Instance.new("TextBox")
NavSearchBox.Name = "NavSearch"
NavSearchBox.Size = UDim2.new(1, -16, 0, 30)
NavSearchBox.Position = UDim2.new(0, 8, 0, 8)
NavSearchBox.BackgroundColor3 = Hub.Theme.Card
NavSearchBox.Font = Enum.Font.Gotham
NavSearchBox.TextSize = 12
NavSearchBox.TextColor3 = Hub.Theme.Text
NavSearchBox.PlaceholderColor3 = Hub.Theme.SubText
NavSearchBox.PlaceholderText = "🔍 Search 25 tabs..."
NavSearchBox.Text = ""
NavSearchBox.ClearTextOnFocus = false
NavSearchBox.Parent = Sidebar
AddCorner(NavSearchBox, 6)
AddStroke(NavSearchBox, Hub.Theme.Border, 1)
AddPadding(NavSearchBox, 0, 0, 8, 8)

local NavScroll = Instance.new("ScrollingFrame")
NavScroll.Name = "NavList"
NavScroll.Size = UDim2.new(1, 0, 1, -46)
NavScroll.Position = UDim2.new(0, 0, 0, 44)
NavScroll.BackgroundTransparency = 1
NavScroll.BorderSizePixel = 0
NavScroll.ScrollBarThickness = 3
NavScroll.ScrollBarImageColor3 = Hub.Theme.Accent
NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NavScroll.Parent = Sidebar
AddPadding(NavScroll, 4, 8, 8, 8)

local NavListLayout = Instance.new("UIListLayout")
NavListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavListLayout.Padding = UDim.new(0, 4)
NavListLayout.Parent = NavScroll

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -Hub.State.UI.SidebarWidth, 1, -44)
ContentContainer.Position = UDim2.new(0, Hub.State.UI.SidebarWidth, 0, 44)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainWindow
Hub.ContentContainer = ContentContainer

-- Navigation Filtering
NavSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = NavSearchBox.Text:lower()
    for name, btn in pairs(Hub.NavButtons) do
        btn.Visible = (q == "" or name:lower():find(q, 1, true) ~= nil)
    end
end)

-- 6. PAGE & COMPONENT BUILDER API
local NavDefinitions = {
    { Name = "Home", Icon = "⌂" },
    { Name = "Player", Icon = "👤" },
    { Name = "Spectator", Icon = "🎥" },
    { Name = "Movement", Icon = "⚡" },
    { Name = "Teleport", Icon = "📍" },
    { Name = "Character", Icon = "🧍" },
    { Name = "Visuals", Icon = "👁" },
    { Name = "ESP", Icon = "🎯" },
    { Name = "Combat", Icon = "⚔" },
    { Name = "Aim Training", Icon = "⊕" },
    { Name = "NPC Tools", Icon = "🤖" },
    { Name = "Vehicles", Icon = "🚗" },
    { Name = "Vehicle Editor", Icon = "🔧" },
    { Name = "World", Icon = "🌍" },
    { Name = "Graphics", Icon = "🖥" },
    { Name = "Performance", Icon = "📊" },
    { Name = "Lighting", Icon = "☀" },
    { Name = "Environment", Icon = "🌲" },
    { Name = "Audio", Icon = "🔊" },
    { Name = "Animations", Icon = "✨" },
    { Name = "Keybinds", Icon = "⌨" },
    { Name = "Configuration", Icon = "💾" },
    { Name = "Interface Settings", Icon = "🎨" },
    { Name = "Developer Tools", Icon = "🛠" },
    { Name = "About", Icon = "ℹ" },
}

function Hub:SwitchPage(pageName: string)
    if not self.Pages[pageName] then return end
    self.ActivePage = pageName
    PlayHubSound("Click")

    for name, page in pairs(self.Pages) do
        local active = (name == pageName)
        page.Visible = active
        if active then
            page.CanvasPosition = Vector2.new(0, 0)
        end
    end

    for name, btn in pairs(self.NavButtons) do
        local active = (name == pageName)
        local indicator = btn:FindFirstChild("Indicator") :: Frame?
        TweenService:Create(btn, GetTweenInfo(0.18), {
            BackgroundColor3 = active and self.Theme.Card or self.Theme.Sidebar,
            TextColor3 = active and self.Theme.Accent or self.Theme.SubText,
        }):Play()
        if indicator then
            TweenService:Create(indicator, GetTweenInfo(0.18), {
                BackgroundTransparency = active and 0 or 1,
                Size = active and UDim2.new(0, 3, 0, 18) or UDim2.new(0, 3, 0, 0)
            }):Play()
        end
    end
end

for idx, info in ipairs(NavDefinitions) do
    local navBtn = Instance.new("TextButton")
    navBtn.Name = "Nav_" .. info.Name
    navBtn.LayoutOrder = idx
    navBtn.Size = UDim2.new(1, 0, 0, 32)
    navBtn.BackgroundColor3 = Hub.Theme.Sidebar
    navBtn.Font = Enum.Font.GothamMedium
    navBtn.TextSize = 13
    navBtn.TextColor3 = Hub.Theme.SubText
    navBtn.TextXAlignment = Enum.TextXAlignment.Left
    navBtn.Text = "   " .. info.Icon .. "  " .. info.Name
    navBtn.AutoButtonColor = false
    navBtn.Parent = NavScroll
    AddCorner(navBtn, 6)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 2, 0.5, -9)
    indicator.BackgroundColor3 = Hub.Theme.Accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = navBtn
    AddCorner(indicator, 2)

    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. info.Name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Hub.Theme.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = ContentContainer
    AddPadding(page, 12, 16, 14, 14)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, Hub.State.UI.Spacing)
    pageLayout.Parent = page

    navBtn.MouseButton1Click:Connect(function()
        Hub:SwitchPage(info.Name)
    end)

    Hub.NavButtons[info.Name] = navBtn
    Hub.Pages[info.Name] = page
end

-- Component Builder Factory attached to Page helpers
local UIFactory = {}

function UIFactory.CreateSection(page: ScrollingFrame, title: string, collapsible: boolean?): Frame
    local section = Instance.new("Frame")
    section.Name = "Section_" .. title
    section.Size = UDim2.new(1, 0, 0, 36)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Hub.Theme.Card
    section.BorderSizePixel = 0
    section.Parent = page
    AddCorner(section, Hub.State.UI.CornerRadius)
    AddStroke(section, Hub.Theme.Border, 1)
    AddPadding(section, 8, 10, 12, 12)

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 7)
    layout.Parent = section

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.LayoutOrder = 0
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextColor3 = Hub.Theme.Accent
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = (collapsible and "▾ " or "▪ ") .. title:upper()
    header.AutoButtonColor = false
    header.Parent = section

    local expanded = true
    if collapsible then
        header.MouseButton1Click:Connect(function()
            PlayHubSound("Click")
            expanded = not expanded
            header.Text = (expanded and "▾ " or "▸ ") .. title:upper()
            for _, child in ipairs(section:GetChildren()) do
                if child:IsA("GuiObject") and child ~= header then
                    child.Visible = expanded
                end
            end
        end)
    end

    return section
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 05: COMPONENT BUILDERS — LABELS, BUTTONS, TOGGLES & SLIDERS (B)
-- ============================================================================

function UIFactory.CreateLabel(parent: GuiObject, text: string, isSub: boolean?): TextLabel
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, isSub and 18 or 22)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Font = isSub and Enum.Font.Gotham or Hub.State.UI.Font
    lbl.TextSize = isSub and 12 or Hub.State.UI.FontSize
    lbl.TextColor3 = isSub and Hub.Theme.SubText or Hub.Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

function UIFactory.CreateButton(parent: GuiObject, text: string, callback: () -> (), accentStyle: boolean?): TextButton
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, Hub.State.UI.ButtonHeight)
    btn.BackgroundColor3 = accentStyle and Hub.Theme.Accent or Hub.Theme.Button
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = accentStyle and Color3.new(1, 1, 1) or Hub.Theme.Text
    btn.Text = text
    btn.AutoButtonColor = false
    btn.Parent = parent
    AddCorner(btn, 6)

    local baseColor = btn.BackgroundColor3
    local hoverColor = accentStyle and Hub.Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.15) or Hub.Theme.ButtonHover

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, GetTweenInfo(0.14), { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, GetTweenInfo(0.14), { BackgroundColor3 = baseColor }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        PlayHubSound("Click")
        RecordFeatureUsage(text, nil)
        callback()
    end)
    return btn
end

function UIFactory.CreateToggle(parent: GuiObject, text: string, defaultVal: boolean, callback: (boolean) -> ()): { Set: (boolean, boolean?) -> (), Get: () -> boolean }
    local state = defaultVal
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, Hub.State.UI.ButtonHeight)
    row.BackgroundColor3 = Hub.Theme.Button
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = parent
    AddCorner(row, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -62, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Hub.State.UI.Font
    lbl.TextSize = 13
    lbl.TextColor3 = Hub.Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 42, 0, Hub.State.UI.ToggleSize)
    pill.Position = UDim2.new(1, -52, 0.5, -Hub.State.UI.ToggleSize / 2)
    pill.BackgroundColor3 = state and Hub.Theme.ToggleOn or Hub.Theme.ToggleOff
    pill.BorderSizePixel = 0
    pill.Parent = row
    AddCorner(pill, Hub.State.UI.ToggleSize / 2)

    local knobSize = Hub.State.UI.ToggleSize - 4
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = state and UDim2.new(1, -knobSize - 2, 0.5, -knobSize / 2) or UDim2.new(0, 2, 0.5, -knobSize / 2)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    AddCorner(knob, knobSize / 2)

    local function Set(newVal: boolean, silent: boolean?)
        state = newVal
        TweenService:Create(pill, GetTweenInfo(0.18), {
            BackgroundColor3 = state and Hub.Theme.ToggleOn or Hub.Theme.ToggleOff
        }):Play()
        TweenService:Create(knob, GetTweenInfo(0.18), {
            Position = state and UDim2.new(1, -knobSize - 2, 0.5, -knobSize / 2) or UDim2.new(0, 2, 0.5, -knobSize / 2)
        }):Play()
        RecordFeatureUsage(text, state)
        if not silent then
            callback(state)
        end
    end

    row.MouseButton1Click:Connect(function()
        PlayHubSound("Toggle")
        Set(not state, false)
    end)

    return {
        Set = Set,
        Get = function() return state end
    }
end

function UIFactory.CreateSlider(parent: GuiObject, text: string, minVal: number, maxVal: number, defaultVal: number, decimals: number?, callback: (number) -> ()): { Set: (number, boolean?) -> (), Get: () -> number }
    local dec = decimals or 0
    local mult = 10 ^ dec
    local currentVal = math.clamp(defaultVal, minVal, maxVal)

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 50)
    box.BackgroundColor3 = Hub.Theme.Button
    box.BorderSizePixel = 0
    box.Parent = parent
    AddCorner(box, 6)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -90, 0, 22)
    titleLbl.Position = UDim2.new(0, 12, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Hub.State.UI.Font
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = Hub.Theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = text
    titleLbl.Parent = box

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 76, 0, 22)
    valLbl.Position = UDim2.new(1, -88, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.Code
    valLbl.TextSize = 13
    valLbl.TextColor3 = Hub.Theme.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(currentVal)
    valLbl.Parent = box

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = Hub.Theme.Background
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = box
    AddCorner(track, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((currentVal - minVal) / math.max(0.0001, maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Hub.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    AddCorner(fill, 4)

    local function Set(val: number, silent: boolean?)
        local clamped = math.clamp(val, minVal, maxVal)
        currentVal = math.floor(clamped * mult + 0.5) / mult
        local ratio = (currentVal - minVal) / math.max(0.0001, maxVal - minVal)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valLbl.Text = string.format("%." .. dec .. "f", currentVal)
        if not silent then
            callback(currentVal)
        end
    end

    local dragging = false
    local function UpdateFromInput(input: InputObject)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        Set(minVal + (maxVal - minVal) * relX, false)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateFromInput(input)
        end
    end)

    Hub:TrackConnection(nil, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromInput(input)
        end
    end))

    Hub:TrackConnection(nil, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    Set(defaultVal, true)
    return {
        Set = Set,
        Get = function() return currentVal end
    }
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 06: COMPONENT BUILDERS — DROPDOWNS & TEXTBOXES (C)
-- ============================================================================

function UIFactory.CreateDropdown(parent: GuiObject, text: string, options: { string }, defaultOption: string, callback: (string) -> ()): { Set: (string, boolean?) -> (), Refresh: ({ string }) -> () }
    local selected = defaultOption
    local isOpen = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, Hub.State.UI.ButtonHeight)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = Hub.Theme.Button
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = parent
    AddCorner(container, 6)

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local headerBtn = Instance.new("TextButton")
    headerBtn.LayoutOrder = 0
    headerBtn.Size = UDim2.new(1, 0, 0, Hub.State.UI.ButtonHeight)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Font = Hub.State.UI.Font
    headerBtn.TextSize = 13
    headerBtn.TextColor3 = Hub.Theme.Text
    headerBtn.TextXAlignment = Enum.TextXAlignment.Left
    headerBtn.Text = "   " .. text .. ":  " .. selected
    headerBtn.Parent = container

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -34, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 13
    arrow.TextColor3 = Hub.Theme.Accent
    arrow.Text = "▾"
    arrow.Parent = headerBtn

    local listFrame = Instance.new("Frame")
    listFrame.LayoutOrder = 1
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.BackgroundColor3 = Hub.Theme.Background
    listFrame.Visible = false
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local function Set(opt: string, silent: boolean?)
        selected = opt
        headerBtn.Text = "   " .. text .. ":  " .. selected
        isOpen = false
        listFrame.Visible = false
        arrow.Text = "▾"
        if not silent then
            callback(selected)
        end
    end

    local function Populate(opts: { string })
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundColor3 = Hub.Theme.Card
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.TextColor3 = Hub.Theme.Text
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.Text = "     • " .. opt
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                PlayHubSound("Click")
                Set(opt, false)
            end)
        end
    end

    Populate(options)

    headerBtn.MouseButton1Click:Connect(function()
        PlayHubSound("Click")
        isOpen = not isOpen
        listFrame.Visible = isOpen
        arrow.Text = isOpen and "▴" or "▾"
    end)

    return {
        Set = Set,
        Refresh = Populate
    }
end

function UIFactory.CreateTextBox(parent: GuiObject, labelText: string, placeholder: string, callback: (string) -> ()): TextBox
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, Hub.State.UI.ButtonHeight)
    row.BackgroundColor3 = Hub.Theme.Button
    row.BorderSizePixel = 0
    row.Parent = parent
    AddCorner(row, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Hub.State.UI.Font
    lbl.TextSize = 13
    lbl.TextColor3 = Hub.Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.55, -12, 0, 26)
    box.Position = UDim2.new(0.45, 4, 0.5, -13)
    box.BackgroundColor3 = Hub.Theme.Background
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextColor3 = Hub.Theme.Text
    box.PlaceholderColor3 = Hub.Theme.SubText
    box.PlaceholderText = placeholder
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = row
    AddCorner(box, 5)
    AddStroke(box, Hub.Theme.Border, 1)
    AddPadding(box, 0, 0, 8, 8)

    box.FocusLost:Connect(function(enterPressed)
        callback(box.Text)
    end)

    return box
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 07: MOVEMENT & CHARACTER SCALING SYSTEMS
-- ============================================================================

local MovementEngine = {
    FlyVelocity = nil :: BodyVelocity?,
    FlyGyro = nil :: BodyGyro?,
    JumpCount = 0,
    LastDashTime = 0,
    IsCrouching = false,
    IsSprinting = false,
}

-- 1. MOVEMENT & PHYSICS CONTROLLER
function MovementEngine:SetFly(enabled: boolean)
    Hub.State.Movement.FlyEnabled = enabled
    local _, hum, hrp = GetCharacterParts()
    if not hum or not hrp then return end

    if enabled then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MaxHubFlyVel"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.Name = "MaxHubFlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        self.FlyVelocity = bv
        self.FlyGyro = bg
    else
        hum.PlatformStand = false
        if self.FlyVelocity then self.FlyVelocity:Destroy() self.FlyVelocity = nil end
        if self.FlyGyro then self.FlyGyro:Destroy() self.FlyGyro = nil end
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj.Name == "MaxHubFlyVel" or obj.Name == "MaxHubFlyGyro" then
                obj:Destroy()
            end
        end
    end
end

function MovementEngine:TriggerDash()
    local now = os.clock()
    if now - self.LastDashTime < Hub.State.Movement.DashCooldown then return end
    local _, _, hrp = GetCharacterParts()
    if not hrp then return end

    self.LastDashTime = now
    local dir = Camera.CFrame.LookVector
    local flatDir = Vector3.new(dir.X, 0, dir.Z)
    if flatDir.Magnitude > 0.01 then
        flatDir = flatDir.Unit
    else
        flatDir = hrp.CFrame.LookVector
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = flatDir * Hub.State.Movement.DashPower
    bv.Parent = hrp
    task.delay(0.16, function()
        if bv and bv.Parent then bv:Destroy() end
    end)
end

function MovementEngine:SetCrouch(enabled: boolean)
    self.IsCrouching = enabled
    Hub.State.Movement.CrouchEnabled = enabled
    local _, hum, _ = GetCharacterParts()
    if not hum then return end
    if enabled then
        hum.WalkSpeed = Hub.State.Movement.CrouchSpeed
        hum.HipHeight = math.max(0, hum.HipHeight - 1.1)
    else
        hum.WalkSpeed = self.IsSprinting and Hub.State.Movement.SprintSpeed or Hub.State.Player.WalkSpeed
        hum.HipHeight = 2.0
    end
end

function MovementEngine:SetSprint(enabled: boolean)
    self.IsSprinting = enabled
    Hub.State.Movement.SprintEnabled = enabled
    local _, hum, _ = GetCharacterParts()
    if not hum then return end
    if enabled and not self.IsCrouching then
        hum.WalkSpeed = Hub.State.Movement.SprintSpeed
    elseif not self.IsCrouching then
        hum.WalkSpeed = Hub.State.Player.WalkSpeed
    end
end

function MovementEngine:ApplyMovementPreset(presetName: string)
    Hub.State.Movement.Preset = presetName
    local _, hum, _ = GetCharacterParts()
    if presetName == "Default" then
        Hub.State.Player.WalkSpeed = 16
        Hub.State.Player.JumpPower = 50
        Hub.State.Player.Gravity = 196.2
        Hub.State.Movement.FlySpeed = 60
    elseif presetName == "Parkour" then
        Hub.State.Player.WalkSpeed = 28
        Hub.State.Player.JumpPower = 68
        Hub.State.Player.Gravity = 165
        Hub.State.Movement.DoubleJump = true
    elseif presetName == "Low Gravity" then
        Hub.State.Player.WalkSpeed = 20
        Hub.State.Player.JumpPower = 55
        Hub.State.Player.Gravity = 65
    elseif presetName == "Speedster" then
        Hub.State.Player.WalkSpeed = 75
        Hub.State.Player.JumpPower = 85
        Hub.State.Player.Gravity = 196.2
        Hub.State.Movement.FlySpeed = 160
    end
    Workspace.Gravity = Hub.State.Player.Gravity
    if hum then
        hum.WalkSpeed = Hub.State.Player.WalkSpeed
        hum.JumpPower = Hub.State.Player.JumpPower
    end
end

-- Jump & Double Jump Listener
Hub:TrackConnection("JumpRequest", UserInputService.JumpRequest:Connect(function()
    local _, hum, _ = GetCharacterParts()
    if not hum then return end
    if Hub.State.Movement.InfiniteJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    elseif Hub.State.Movement.DoubleJump then
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Freefall and MovementEngine.JumpCount < 1 then
            MovementEngine.JumpCount += 1
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- Noclip & Collision Loop (Stepped)
Hub:TrackConnection("NoclipStepped", RunService.Stepped:Connect(function()
    local char, _, _ = GetCharacterParts()
    if not char then return end
    if Hub.State.Movement.NoclipEnabled or not Hub.State.Movement.CanCollide then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- Fly & Air Control Loop (RenderStepped)
Hub:TrackConnection("MovementRender", RunService.RenderStepped:Connect(function(dt)
    local _, hum, hrp = GetCharacterParts()
    if not hum or not hrp then return end

    if hum.FloorMaterial ~= Enum.Material.Air then
        MovementEngine.JumpCount = 0
    end

    if Hub.State.Movement.FlyEnabled and MovementEngine.FlyVelocity and MovementEngine.FlyGyro then
        local moveDir = Vector3.zero
        local camCF = Camera.CFrame
        local forward = (Hub.State.Movement.FlyMode == "Camera") and camCF.LookVector or Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local right = camCF.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir -= Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        local targetVel = moveDir * Hub.State.Movement.FlySpeed
        local accel = math.clamp(Hub.State.Movement.Acceleration * 12 * dt, 0.05, 1)
        MovementEngine.FlyVelocity.Velocity = MovementEngine.FlyVelocity.Velocity:Lerp(targetVel, accel)
        MovementEngine.FlyGyro.CFrame = camCF
    end
end))

-- 2. CHARACTER SCALER ENGINE (0.1x to 10.0x)
local CharacterScaler = {}

function CharacterScaler:ApplyScale()
    local char, hum, _ = GetCharacterParts()
    if not char or not hum then return end
    local s = Hub.State.CharacterScale

    -- R15 Humanoid NumberValues
    local scaleMap = {
        BodyWidthScale = math.clamp(s.Width * s.Uniform, 0.1, 10),
        BodyHeightScale = math.clamp(s.Height * s.Uniform, 0.1, 10),
        BodyDepthScale = math.clamp(s.Depth * s.Uniform, 0.1, 10),
        HeadScale = math.clamp(s.Head * s.Uniform, 0.1, 10),
    }

    local appliedR15 = false
    for propName, value in pairs(scaleMap) do
        local nv = hum:FindFirstChild(propName)
        if nv and nv:IsA("NumberValue") then
            nv.Value = value
            appliedR15 = true
        end
    end

    -- Fallback for R6 or custom Studio rigs using Model:ScaleTo
    if not appliedR15 then
        pcall(function()
            char:ScaleTo(math.clamp(s.Uniform, 0.1, 10))
        end)
    end
end

function CharacterScaler:Reset()
    Hub.State.CharacterScale = { Uniform = 1.0, Width = 1.0, Height = 1.0, Depth = 1.0, Head = 1.0 }
    self:ApplyScale()
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 08: TELEPORT & SPECTATOR CAMERA SYSTEMS
-- ============================================================================

-- 3. TELEPORT & POSITION HISTORY SYSTEM
local TeleportEngine = {}

function TeleportEngine:RecordPreviousPosition()
    local _, _, hrp = GetCharacterParts()
    if hrp then
        table.insert(Hub.PositionHistory, hrp.CFrame)
        if #Hub.PositionHistory > 25 then
            table.remove(Hub.PositionHistory, 1)
        end
    end
end

function TeleportEngine:TeleportToCFrame(targetCF: CFrame): boolean
    local char, _, hrp = GetCharacterParts()
    if not char or not hrp then
        Hub:Notify("Teleport Failed", "Character HumanoidRootPart not found.", "Danger", 3)
        return false
    end

    self:RecordPreviousPosition()

    -- First check if Studio server remote exists for server-authoritative teleport
    local okServer, _ = InvokeAuthorizedServer("TeleportTo", targetCF)
    if not okServer then
        char:PivotTo(targetCF)
    end
    return true
end

function TeleportEngine:ReturnToPrevious(): boolean
    if #Hub.PositionHistory == 0 then
        Hub:Notify("History Empty", "No previous position recorded.", "Warning", 2.5)
        return false
    end
    local prevCF = table.remove(Hub.PositionHistory)
    if prevCF then
        local char = LocalPlayer.Character
        if char then
            char:PivotTo(prevCF)
            Hub:Notify("Returned", "Teleported back to previous position.", "Success", 2.5)
            return true
        end
    end
    return false
end

function TeleportEngine:SaveCurrentPosition(customName: string?)
    local _, _, hrp = GetCharacterParts()
    if not hrp then return end
    local name = (customName and customName ~= "") and customName or ("Waypoint #" .. (#Hub.SavedPositions + 1))
    table.insert(Hub.SavedPositions, {
        Name = name,
        CFrame = hrp.CFrame,
    })
    Hub:Notify("Position Saved", "Saved '" .. name .. "'", "Success", 2.5)
end

-- 4. SPECTATOR CAMERA ENGINE (Non-destructive local camera follow)
local SpectatorEngine = {
    Mode = "Follow", -- "Follow" or "FreeOrbit"
}

function SpectatorEngine:StartSpectating(targetPlayer: Player)
    if not targetPlayer or targetPlayer == LocalPlayer then
        Hub:Notify("Spectator", "Select another valid player first.", "Warning", 2.5)
        return
    end
    local targetChar = targetPlayer.Character
    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHum then
        Hub:Notify("Spectator", targetPlayer.DisplayName .. " has no active character.", "Danger", 2.5)
        return
    end

    Hub.SpectatingPlayer = targetPlayer
    Camera.CameraSubject = targetHum
    Camera.CameraType = Enum.CameraType.Custom
    RecordFeatureUsage("Spectator Mode", true)
    Hub:Notify("Spectating", "Now spectating " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")", "Info", 3)
end

function SpectatorEngine:StopSpectating()
    Hub.SpectatingPlayer = nil
    local _, hum, _ = GetCharacterParts()
    if hum then
        Camera.CameraSubject = hum
        Camera.CameraType = Enum.CameraType.Custom
    end
    RecordFeatureUsage("Spectator Mode", false)
    Hub:Notify("Spectator Stopped", "Camera returned to your character.", "Info", 2.5)
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 09: AUTHORIZED ESP & VISUAL OVERLAY ENGINE
-- ============================================================================

-- 1. ESP & VISUALIZATION ENGINE
-- Strictly scoped to authorized NPCs, Training Targets, and Debug-tagged objects
-- (Models with Attribute "IsTrainingTarget", "IsNPC", or CollectionService tag "MaxHubESP").
local ESPEngine = {}

function ESPEngine:IsAuthorizedTarget(model: Instance): (boolean, BasePart?, Humanoid?)
    if not model:IsA("Model") then return false, nil, nil end
    if model == LocalPlayer.Character then return false, nil, nil end
    -- Exclude real players to ensure fair gameplay and studio-compliant debugging
    if Players:GetPlayerFromCharacter(model) ~= nil then
        return false, nil, nil
    end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart") :: BasePart? or model.PrimaryPart
    if not root then return false, nil, nil end

    local isNPC = (hum ~= nil) or model:GetAttribute("IsNPC") == true
    local isDebugObj = model:GetAttribute("IsTrainingTarget") == true or CollectionService:HasTag(model, "MaxHubESP")

    if isNPC and Hub.State.ESP.TargetNPCs then
        if Hub.State.ESP.FilterAliveOnly and hum and hum.Health <= 0 then
            return false, nil, nil
        end
        return true, root, hum
    end

    if isDebugObj and Hub.State.ESP.TargetDebugObjects then
        return true, root, hum
    end

    return false, nil, nil
end

function ESPEngine:CreateESPObject(model: Model, root: BasePart)
    if Hub.ESPCache[model] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MaxHub_Highlight"
    highlight.Adornee = model
    highlight.FillColor = Hub.State.ESP.CustomColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = Hub.State.ESP.Transparency
    highlight.Parent = ScreenGui

    local bb = Instance.new("BillboardGui")
    bb.Name = "MaxHub_ESPBillboard"
    bb.Adornee = root
    bb.Size = UDim2.new(0, 160, 0, 70)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = ScreenGui

    local infoLbl = Instance.new("TextLabel")
    infoLbl.Name = "InfoLabel"
    infoLbl.Size = UDim2.new(1, 0, 0, 36)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Font = Enum.Font.GothamBold
    infoLbl.TextSize = Hub.State.ESP.TextSize
    infoLbl.TextColor3 = Hub.State.ESP.CustomColor
    infoLbl.TextStrokeTransparency = 0.3
    infoLbl.Text = model.Name
    infoLbl.Parent = bb

    local hpBg = Instance.new("Frame")
    hpBg.Name = "HealthBg"
    hpBg.Size = UDim2.new(0.7, 0, 0, 5)
    hpBg.Position = UDim2.new(0.15, 0, 0, 38)
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = bb

    local hpFill = Instance.new("Frame")
    hpFill.Name = "HealthFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Hub.Theme.Success
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg

    -- 2D Screen Box & Tracer Frame
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "MaxHub_ESPBox"
    boxFrame.BackgroundTransparency = 1
    boxFrame.Visible = false
    boxFrame.Parent = ScreenGui
    local boxStroke = AddStroke(boxFrame, Hub.State.ESP.CustomColor, Hub.State.ESP.Thickness)

    local tracerLine = Instance.new("Frame")
    tracerLine.Name = "MaxHub_Tracer"
    tracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
    tracerLine.BackgroundColor3 = Hub.State.ESP.CustomColor
    tracerLine.BorderSizePixel = 0
    tracerLine.Visible = false
    tracerLine.Parent = ScreenGui

    local headDot = Instance.new("Frame")
    headDot.Name = "MaxHub_HeadDot"
    headDot.AnchorPoint = Vector2.new(0.5, 0.5)
    headDot.Size = UDim2.new(0, 8, 0, 8)
    headDot.BackgroundColor3 = Hub.Theme.Warning
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.Parent = ScreenGui
    AddCorner(headDot, 4)

    Hub.ESPCache[model] = {
        Highlight = highlight,
        Billboard = bb,
        InfoLabel = infoLbl,
        HealthBg = hpBg,
        HealthFill = hpFill,
        BoxFrame = boxFrame,
        BoxStroke = boxStroke,
        TracerLine = tracerLine,
        HeadDot = headDot,
    }
end

function ESPEngine:RemoveESPObject(model: Model)
    local data = Hub.ESPCache[model]
    if not data then return end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    if data.BoxFrame then data.BoxFrame:Destroy() end
    if data.TracerLine then data.TracerLine:Destroy() end
    if data.HeadDot then data.HeadDot:Destroy() end
    Hub.ESPCache[model] = nil
end

function ESPEngine:ClearAll()
    for model, _ in pairs(Hub.ESPCache) do
        self:RemoveESPObject(model)
    end
end

-- ESP Update Loop
Hub:TrackConnection("ESPRender", RunService.RenderStepped:Connect(function()
    if not Hub.State.ESP.Enabled then
        if next(Hub.ESPCache) ~= nil then
            ESPEngine:ClearAll()
        end
        return
    end

    local _, _, myHRP = GetCharacterParts()
    local myPos = myHRP and myHRP.Position or Camera.CFrame.Position
    local cfg = Hub.State.ESP
    local seen = {}

    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("Model") then
            local valid, root, hum = ESPEngine:IsAuthorizedTarget(inst)
            if valid and root then
                local dist = (root.Position - myPos).Magnitude
                if dist <= cfg.MaxDistance then
                    seen[inst] = true
                    if not Hub.ESPCache[inst] then
                        ESPEngine:CreateESPObject(inst, root)
                    end
                    local data = Hub.ESPCache[inst]
                    local color = cfg.CustomColor

                    data.Highlight.Enabled = cfg.Highlight
                    data.Highlight.FillColor = color
                    data.Highlight.OutlineTransparency = cfg.Transparency

                    local lines = {}
                    if cfg.Name then table.insert(lines, inst.Name) end
                    if cfg.Distance then table.insert(lines, string.format("[%.0fm]", dist)) end
                    if cfg.HealthText and hum then
                        table.insert(lines, string.format("HP: %.0f/%.0f", hum.Health, hum.MaxHealth))
                    end
                    data.InfoLabel.Text = table.concat(lines, " ")
                    data.InfoLabel.TextSize = cfg.TextSize
                    data.InfoLabel.TextColor3 = color
                    data.Billboard.Enabled = (#lines > 0) or (cfg.HealthBar and hum ~= nil)

                    if cfg.HealthBar and hum then
                        data.HealthBg.Visible = true
                        local ratio = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                        data.HealthFill.Size = UDim2.new(ratio, 0, 1, 0)
                        data.HealthFill.BackgroundColor3 = Color3.fromRGB(235, 70, 70):Lerp(Color3.fromRGB(64, 210, 120), ratio)
                    else
                        data.HealthBg.Visible = false
                    end

                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen and screenPos.Z > 0 then
                        local scaleFactor = 1000 / math.max(1, screenPos.Z)
                        local w = math.clamp(scaleFactor * 2.2, 20, 300)
                        local h = math.clamp(scaleFactor * 3.4, 30, 450)

                        data.BoxFrame.Visible = cfg.Box
                        data.BoxFrame.Position = UDim2.new(0, screenPos.X - w / 2, 0, screenPos.Y - h / 2)
                        data.BoxFrame.Size = UDim2.new(0, w, 0, h)
                        data.BoxStroke.Color = color
                        data.BoxStroke.Thickness = cfg.Thickness

                        if cfg.Tracer then
                            local vp = Camera.ViewportSize
                            local origin = Vector2.new(vp.X / 2, vp.Y)
                            if cfg.TracerOrigin == "Center" then
                                origin = Vector2.new(vp.X / 2, vp.Y / 2)
                            elseif cfg.TracerOrigin == "Mouse" then
                                origin = UserInputService:GetMouseLocation()
                            end
                            local target2D = Vector2.new(screenPos.X, screenPos.Y)
                            local diff = target2D - origin
                            data.TracerLine.Visible = true
                            data.TracerLine.BackgroundColor3 = color
                            data.TracerLine.Position = UDim2.new(0, (origin.X + target2D.X) / 2, 0, (origin.Y + target2D.Y) / 2)
                            data.TracerLine.Size = UDim2.new(0, diff.Magnitude, 0, cfg.Thickness)
                            data.TracerLine.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                        else
                            data.TracerLine.Visible = false
                        end

                        local head = inst:FindFirstChild("Head") :: BasePart?
                        if cfg.HeadMarker and head then
                            local hPos, hVis = Camera:WorldToViewportPoint(head.Position)
                            data.HeadDot.Visible = hVis
                            data.HeadDot.Position = UDim2.new(0, hPos.X, 0, hPos.Y)
                        else
                            data.HeadDot.Visible = false
                        end
                    else
                        data.BoxFrame.Visible = false
                        data.TracerLine.Visible = false
                        data.HeadDot.Visible = false
                    end
                end
            end
        end
    end

    for model, _ in pairs(Hub.ESPCache) do
        if not seen[model] or not model.Parent then
            ESPEngine:RemoveESPObject(model)
        end
    end
end))
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 10: AIM TRAINING, SHOOTING RANGE & VEHICLE SYSTEMS
-- ============================================================================

-- 2. AIM TRAINING & SHOOTING RANGE ENGINE (Training Targets & NPCs Only)
local CombatEngine = {
    RangeFolder = nil :: Folder?,
    SpawnedTargets = {} :: { Model },
}

function CombatEngine:EnsureRangeFolder(): Folder
    local existing = Workspace:FindFirstChild("MaxHub_ShootingRange")
    if existing and existing:IsA("Folder") then
        self.RangeFolder = existing
        return existing
    end
    local folder = Instance.new("Folder")
    folder.Name = "MaxHub_ShootingRange"
    folder.Parent = Workspace
    self.RangeFolder = folder
    return folder
end

function CombatEngine:SpawnTrainingTarget(offsetStuds: Vector3?)
    local _, _, hrp = GetCharacterParts()
    local baseCF = hrp and (hrp.CFrame * CFrame.new(offsetStuds or Vector3.new(math.random(-15, 15), 2, -28))) or CFrame.new(0, 5, -25)

    local folder = self:EnsureRangeFolder()
    local model = Instance.new("Model")
    model.Name = "TrainingTarget_" .. (#self.SpawnedTargets + 1)
    model:SetAttribute("IsTrainingTarget", true)
    model:SetAttribute("SpawnOrigin", baseCF.Position)
    CollectionService:AddTag(model, "MaxHubESP")

    local sz = Hub.State.Combat.TargetSize
    local part = Instance.new("Part")
    part.Name = "HumanoidRootPart"
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(sz, sz, sz)
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(235, 75, 95)
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = baseCF
    part.Parent = model

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 100
    hum.Health = 100
    hum.Parent = model

    model.PrimaryPart = part
    model.Parent = folder
    table.insert(self.SpawnedTargets, model)
    Hub.TrainingStats.LastTargetSpawnTime = os.clock()
    Hub.State.Combat.SelectedTarget = model
    return model
end

function CombatEngine:ClearTargets()
    for _, m in ipairs(self.SpawnedTargets) do
        if m and m.Parent then m:Destroy() end
    end
    table.clear(self.SpawnedTargets)
    if self.RangeFolder then
        self.RangeFolder:Destroy()
        self.RangeFolder = nil
    end
end

function CombatEngine:FireTestShot()
    Hub.TrainingStats.Shots += 1
    local origin = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = { LocalPlayer.Character }
    end

    local result = Workspace:Raycast(origin, direction, params)
    local hitPos = result and result.Position or (origin + direction)

    -- Projectile Tracer Visualization
    if Hub.State.Combat.ProjectileVis then
        local dist = (hitPos - origin).Magnitude
        local beam = Instance.new("Part")
        beam.Anchored = true
        beam.CanCollide = false
        beam.Material = Enum.Material.Neon
        beam.Color = result and Hub.Theme.Success or Hub.Theme.Accent
        beam.Size = Vector3.new(0.12, 0.12, dist)
        beam.CFrame = CFrame.lookAt(origin, hitPos) * CFrame.new(0, 0, -dist / 2)
        beam.Parent = Workspace
        task.delay(0.25, function()
            if beam then beam:Destroy() end
        end)
    end

    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and (model:GetAttribute("IsTrainingTarget") == true or model:GetAttribute("IsNPC") == true) then
            Hub.TrainingStats.Hits += 1
            if Hub.TrainingStats.LastTargetSpawnTime > 0 then
                local rt = (os.clock() - Hub.TrainingStats.LastTargetSpawnTime) * 1000
                Hub.TrainingStats.TotalReactionTime += rt
                Hub.TrainingStats.ReactionSamples += 1
                Hub.TrainingStats.LastTargetSpawnTime = 0
            end

            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(Hub.State.Combat.SimDamage)
                if hum.Health <= 0 then
                    model:Destroy()
                end
            end

            if Hub.State.Combat.HitDetectionVis then
                local marker = Instance.new("Part")
                marker.Shape = Enum.PartType.Ball
                marker.Size = Vector3.new(0.6, 0.6, 0.6)
                marker.Anchored = true
                marker.CanCollide = false
                marker.Material = Enum.Material.Neon
                marker.Color = Hub.Theme.Success
                marker.Position = hitPos
                marker.Parent = Workspace
                task.delay(0.4, function()
                    if marker then marker:Destroy() end
                end)
            end
        end
    end
end

-- Target Movement & Training Camera Assist Loop (Training Targets Only)
Hub:TrackConnection("CombatStep", RunService.RenderStepped:Connect(function(dt)
    local t = os.clock()
    local moveMode = Hub.State.Combat.TargetMovement

    for i = #CombatEngine.SpawnedTargets, 1, -1 do
        local m = CombatEngine.SpawnedTargets[i]
        if not m or not m.Parent or not m.PrimaryPart then
            table.remove(CombatEngine.SpawnedTargets, i)
        else
            local origin: Vector3 = m:GetAttribute("SpawnOrigin") or m.PrimaryPart.Position
            if moveMode == "Strafe" then
                m.PrimaryPart.CFrame = CFrame.new(origin + Vector3.new(math.sin(t * 2.5 + i) * 10, 0, 0))
            elseif moveMode == "Orbit" then
                m.PrimaryPart.CFrame = CFrame.new(origin + Vector3.new(math.cos(t * 2 + i) * 8, math.sin(t * 3) * 2.5, math.sin(t * 2 + i) * 8))
            elseif moveMode == "Random" then
                m.PrimaryPart.CFrame = CFrame.new(origin + Vector3.new(math.sin(t * 3.1 + i) * 7, math.cos(t * 2.7) * 3, math.cos(t * 1.9) * 5))
            end
        end
    end

    -- Smooth Camera Tracking strictly for Training Targets during Aim Training drills
    if Hub.State.Combat.AimTrainingActive and Hub.State.Combat.TargetTracking then
        local target = Hub.State.Combat.SelectedTarget
        if target and target.Parent and target.PrimaryPart then
            if target:GetAttribute("IsTrainingTarget") == true then
                local desired = CFrame.lookAt(Camera.CFrame.Position, target.PrimaryPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(Hub.State.Combat.Smoothness, 0.02, 1))
            end
        end
    end
end))

-- 3. VEHICLE CONTROLLER & EDITOR ENGINE
local VehicleEngine = {
    FlyVel = nil :: BodyVelocity?,
    FlyGyro = nil :: BodyGyro?,
}

function VehicleEngine:GetSeatedVehicle(): (VehicleSeat?, Model?)
    local _, hum, _ = GetCharacterParts()
    if not hum or not hum.SeatPart then return nil, nil end
    if hum.SeatPart:IsA("VehicleSeat") then
        local seat = hum.SeatPart
        if not Hub.VehicleOrigin then
            Hub.VehicleOrigin = seat.CFrame
        end
        Hub.CurrentVehicle = seat
        return seat, seat:FindFirstAncestorOfClass("Model")
    end
    return nil, nil
end

function VehicleEngine:SetVehicleFly(enabled: boolean)
    Hub.State.Vehicle.FlyEnabled = enabled
    local seat, _ = self:GetSeatedVehicle()
    if not seat then
        if enabled then
            Hub:Notify("Vehicle Fly", "Sit in a VehicleSeat first.", "Warning", 2.5)
        end
        return
    end

    if enabled then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MaxHubVehFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = seat

        local bg = Instance.new("BodyGyro")
        bg.Name = "MaxHubVehGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 5e4
        bg.CFrame = seat.CFrame
        bg.Parent = seat

        self.FlyVel = bv
        self.FlyGyro = bg
    else
        if self.FlyVel then self.FlyVel:Destroy() self.FlyVel = nil end
        if self.FlyGyro then self.FlyGyro:Destroy() self.FlyGyro = nil end
    end
end

function VehicleEngine:Boost()
    local seat, _ = self:GetSeatedVehicle()
    if not seat then return end
    seat.AssemblyLinearVelocity = seat.CFrame.LookVector * Hub.State.Vehicle.BoostPower
end

function VehicleEngine:Brake()
    local seat, _ = self:GetSeatedVehicle()
    if not seat then return end
    seat.AssemblyLinearVelocity = Vector3.zero
    seat.AssemblyAngularVelocity = Vector3.zero
end

function VehicleEngine:ReturnToSpawn()
    local seat, model = self:GetSeatedVehicle()
    if not seat or not Hub.VehicleOrigin then return end
    if model then
        model:PivotTo(Hub.VehicleOrigin)
    else
        seat.CFrame = Hub.VehicleOrigin
    end
    self:Brake()
end

Hub:TrackConnection("VehicleStep", RunService.RenderStepped:Connect(function()
    local seat, _ = VehicleEngine:GetSeatedVehicle()
    if not seat then return end

    seat.MaxSpeed = Hub.State.Vehicle.MaxSpeed
    seat.TurnSpeed = Hub.State.Vehicle.SteeringSensitivity

    if Hub.State.Vehicle.FlyEnabled and VehicleEngine.FlyVel and VehicleEngine.FlyGyro then
        local move = Vector3.zero
        local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then move = move.Unit end
        VehicleEngine.FlyVel.Velocity = move * Hub.State.Vehicle.FlySpeed
        VehicleEngine.FlyGyro.CFrame = cf
    end
end))
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 11: UI PAGES 01–03 (HOME DASHBOARD, PLAYER SYSTEM, SPECTATOR)
-- ============================================================================

-- 1. HOME DASHBOARD
do
    local p = Hub.Pages["Home"]
    local secWelcome = UIFactory.CreateSection(p, "Dashboard Overview", false)
    UIFactory.CreateLabel(secWelcome, Hub.BrandName .. "  •  Studio Admin, Physics, Visuals & Debug Suite (" .. Hub.Version .. ")", false)
    local statusLbl = UIFactory.CreateLabel(secWelcome, "Loading live telemetry...", true)

    local secTelemetry = UIFactory.CreateSection(p, "Live System & Session Telemetry", false)
    local playerInfoLbl = UIFactory.CreateLabel(secTelemetry, "Player: " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", true)
    local charStatusLbl = UIFactory.CreateLabel(secTelemetry, "Character: Active", true)
    local perfInfoLbl = UIFactory.CreateLabel(secTelemetry, "FPS: -- | FrameTime: -- ms | Ping: -- ms | Memory: -- MB", true)
    local configInfoLbl = UIFactory.CreateLabel(secTelemetry, "Theme: Dark | Profile: Default | Active Modules: 0", true)
    local recentLbl = UIFactory.CreateLabel(secTelemetry, "Recently Used: None", true)

    local secQuick = UIFactory.CreateSection(p, "Quick Actions", false)
    UIFactory.CreateButton(secQuick, "Spawn Shooting Range Target", function()
        local t = CombatEngine:SpawnTrainingTarget(nil)
        Hub:Notify("Range Target", "Spawned " .. t.Name, "Success", 2.5)
    end, true)
    UIFactory.CreateButton(secQuick, "Return to Previous Position", function()
        TeleportEngine:ReturnToPrevious()
    end, false)
    UIFactory.CreateButton(secQuick, "Reset Character", function()
        local _, hum, _ = GetCharacterParts()
        if hum then hum.Health = 0 end
    end, false)

    -- Live Dashboard Updater (throttled to 0.5s intervals)
    local accum = 0
    local frames = 0
    Hub:TrackConnection("DashboardTelemetry", RunService.RenderStepped:Connect(function(dt)
        accum += dt
        frames += 1
        if accum >= 0.5 then
            local fps = math.floor(frames / accum + 0.5)
            local ft = (accum / math.max(1, frames)) * 1000
            local mem = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)

            TelemetryLabel.Text = string.format("FPS: %d | MEM: %d MB", fps, mem)
            perfInfoLbl.Text = string.format("FPS: %d  |  FrameTime: %.2f ms  |  Ping: %d ms  |  Memory: %d MB", fps, ft, ping, mem)

            local char, hum, hrp = GetCharacterParts()
            if char and hum and hrp then
                charStatusLbl.Text = string.format("Character: Alive  |  HP: %.0f/%.0f  |  Pos: (%.1f, %.1f, %.1f)",
                    hum.Health, hum.MaxHealth, hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
            else
                charStatusLbl.Text = "Character: Respawning / Missing"
            end

            local activeCount = 0
            for _, v in pairs(Hub.ActiveFeatures) do
                if v then activeCount += 1 end
            end
            configInfoLbl.Text = string.format("Theme: %s  |  Profile: %s  |  Active Toggles: %d",
                Hub.State.ThemeName, Hub.CurrentConfigName, activeCount)
            recentLbl.Text = "Recently Used: " .. (#Hub.RecentFeatures > 0 and table.concat(Hub.RecentFeatures, ", ") or "None")
            statusLbl.Text = "System Status: Optimal  •  Studio LocalScript Active"

            accum = 0
            frames = 0
        end
    end))
end

-- 2. PLAYER SYSTEM
do
    local p = Hub.Pages["Player"]
    local secTarget = UIFactory.CreateSection(p, "Player Directory & Selection", false)
    local selectedLbl = UIFactory.CreateLabel(secTarget, "Selected Player: None", false)

    local function GetPlayerNames(): { string }
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(list, plr.Name)
        end
        return list
    end

    local plrDropdown = UIFactory.CreateDropdown(secTarget, "Select Player", GetPlayerNames(), LocalPlayer.Name, function(name)
        local plr = Players:FindFirstChild(name) :: Player?
        Hub.SelectedPlayer = plr
        if plr then
            local distStr = "N/A"
            local _, _, myHrp = GetCharacterParts()
            local tHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            local tHum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if myHrp and tHrp then
                distStr = string.format("%.1f studs", (myHrp.Position - tHrp.Position).Magnitude)
            end
            local hpStr = tHum and string.format("%.0f/%.0f", tHum.Health, tHum.MaxHealth) or "Dead/None"
            selectedLbl.Text = string.format("Selected: %s (@%s) | HP: %s | Dist: %s", plr.DisplayName, plr.Name, hpStr, distStr)
        end
    end)

    UIFactory.CreateTextBox(secTarget, "Search Username", "Type username...", function(query)
        local q = query:lower()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():find(q, 1, true) or plr.DisplayName:lower():find(q, 1, true) then
                plrDropdown.Set(plr.Name, false)
                break
            end
        end
    end)

    UIFactory.CreateButton(secTarget, "Refresh Player List", function()
        plrDropdown.Refresh(GetPlayerNames())
        Hub:Notify("Player List", "Updated active players (" .. #Players:GetPlayers() .. ").", "Info", 2)
    end, false)

    UIFactory.CreateButton(secTarget, "Teleport to Selected Player (Authorized)", function()
        local target = Hub.SelectedPlayer
        if not target or not target.Character then
            Hub:Notify("Teleport", "Select a valid player with an active character.", "Warning", 2.5)
            return
        end
        local tHrp = target.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if tHrp then
            TeleportEngine:TeleportToCFrame(tHrp.CFrame * CFrame.new(0, 0, 4))
            Hub:Notify("Teleported", "Moved to " .. target.DisplayName, "Success", 2.5)
        end
    end, true)

    local secLocal = UIFactory.CreateSection(p, "Local Character Attributes", false)
    local wsSlider = UIFactory.CreateSlider(secLocal, "WalkSpeed", 0, 250, 16, 0, function(v)
        Hub.State.Player.WalkSpeed = v
        local _, hum, _ = GetCharacterParts()
        if hum then hum.WalkSpeed = v end
    end)
    local jpSlider = UIFactory.CreateSlider(secLocal, "JumpPower", 0, 300, 50, 0, function(v)
        Hub.State.Player.JumpPower = v
        local _, hum, _ = GetCharacterParts()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end)
    local jhSlider = UIFactory.CreateSlider(secLocal, "JumpHeight", 0, 120, 7.2, 1, function(v)
        Hub.State.Player.JumpHeight = v
        local _, hum, _ = GetCharacterParts()
        if hum then
            hum.UseJumpPower = false
            hum.JumpHeight = v
        end
    end)
    local gravSlider = UIFactory.CreateSlider(secLocal, "Workspace Gravity", 0, 500, 196.2, 1, function(v)
        Hub.State.Player.Gravity = v
        Workspace.Gravity = v
    end)
    local fovSlider = UIFactory.CreateSlider(secLocal, "Camera Field of View", 30, 120, 70, 0, function(v)
        Hub.State.Player.FOV = v
        Camera.FieldOfView = v
    end)
    local visSlider = UIFactory.CreateSlider(secLocal, "Local Character Transparency", 0, 1, 0, 2, function(v)
        Hub.State.Player.LocalTransparency = v
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = v
                end
            end
        end
    end)

    UIFactory.CreateButton(secLocal, "Reset Player Settings", function()
        wsSlider.Set(16, false)
        jpSlider.Set(50, false)
        jhSlider.Set(7.2, false)
        gravSlider.Set(196.2, false)
        fovSlider.Set(70, false)
        visSlider.Set(0, false)
        Hub:Notify("Player Reset", "Restored default player attributes.", "Success", 2.5)
    end, false)
end

-- 3. SPECTATOR SYSTEM
do
    local p = Hub.Pages["Spectator"]
    local secSpec = UIFactory.CreateSection(p, "Camera Spectator Controls", false)
    UIFactory.CreateLabel(secSpec, "Spectator mode attaches your local camera to the selected player without modifying their character.", true)

    UIFactory.CreateButton(secSpec, "Spectate Selected Player", function()
        if Hub.SelectedPlayer then
            SpectatorEngine:StartSpectating(Hub.SelectedPlayer)
        else
            Hub:Notify("Spectator", "Select a player in the Player tab first.", "Warning", 2.5)
        end
    end, true)

    UIFactory.CreateButton(secSpec, "Spectate Next Player in Server", function()
        local list = Players:GetPlayers()
        for _, plr in ipairs(list) do
            if plr ~= LocalPlayer and plr ~= Hub.SpectatingPlayer then
                Hub.SelectedPlayer = plr
                SpectatorEngine:StartSpectating(plr)
                return
            end
        end
        Hub:Notify("Spectator", "No other players available to spectate.", "Info", 2.5)
    end, false)

    UIFactory.CreateButton(secSpec, "Stop Spectating (Return Camera)", function()
        SpectatorEngine:StopSpectating()
    end, false)
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 12: UI PAGES 04–06 (MOVEMENT, TELEPORT, CHARACTER SIZE EDITOR)
-- ============================================================================

-- 4. MOVEMENT SYSTEM
do
    local p = Hub.Pages["Movement"]
    local secCore = UIFactory.CreateSection(p, "Flight & Traversal", false)
    local flyTog = UIFactory.CreateToggle(secCore, "Enable Flight", false, function(v)
        MovementEngine:SetFly(v)
    end)
    local flySpeed = UIFactory.CreateSlider(secCore, "Fly Speed", 10, 400, 60, 0, function(v)
        Hub.State.Movement.FlySpeed = v
    end)
    UIFactory.CreateDropdown(secCore, "Fly Direction Mode", { "Camera", "Planar" }, "Camera", function(mode)
        Hub.State.Movement.FlyMode = mode
    end)
    local noclipTog = UIFactory.CreateToggle(secCore, "Noclip (Authorized Testing)", false, function(v)
        Hub.State.Movement.NoclipEnabled = v
    end)
    local infJumpTog = UIFactory.CreateToggle(secCore, "Infinite Jump", false, function(v)
        Hub.State.Movement.InfiniteJump = v
    end)
    local dblJumpTog = UIFactory.CreateToggle(secCore, "Double Jump", false, function(v)
        Hub.State.Movement.DoubleJump = v
    end)

    local secActions = UIFactory.CreateSection(p, "Sprint, Crouch, Dash & Physics", false)
    UIFactory.CreateToggle(secActions, "Sprint Mode", false, function(v)
        MovementEngine:SetSprint(v)
    end)
    UIFactory.CreateSlider(secActions, "Sprint WalkSpeed", 16, 200, 32, 0, function(v)
        Hub.State.Movement.SprintSpeed = v
        if MovementEngine.IsSprinting then MovementEngine:SetSprint(true) end
    end)
    UIFactory.CreateToggle(secActions, "Crouch Mode", false, function(v)
        MovementEngine:SetCrouch(v)
    end)
    UIFactory.CreateSlider(secActions, "Dash Impulse Power", 20, 250, 85, 0, function(v)
        Hub.State.Movement.DashPower = v
    end)
    UIFactory.CreateButton(secActions, "Execute Forward Dash", function()
        MovementEngine:TriggerDash()
    end, true)
    UIFactory.CreateSlider(secActions, "Flight Acceleration", 0.1, 5.0, 1.0, 1, function(v)
        Hub.State.Movement.Acceleration = v
    end)
    UIFactory.CreateDropdown(secActions, "Movement Presets", { "Default", "Parkour", "Low Gravity", "Speedster" }, "Default", function(preset)
        MovementEngine:ApplyMovementPreset(preset)
        Hub:Notify("Preset Applied", "Movement preset: " .. preset, "Info", 2)
    end)
    UIFactory.CreateButton(secActions, "Reset Movement Settings", function()
        flyTog.Set(false, false)
        flySpeed.Set(60, false)
        noclipTog.Set(false, false)
        infJumpTog.Set(false, false)
        dblJumpTog.Set(false, false)
        MovementEngine:ApplyMovementPreset("Default")
        Hub:Notify("Movement Reset", "All movement parameters restored.", "Success", 2.5)
    end, false)
end

-- 5. TELEPORT SYSTEM
do
    local p = Hub.Pages["Teleport"]
    local secCoord = UIFactory.CreateSection(p, "Coordinate Teleportation", false)
    local xVal, yVal, zVal = 0, 10, 0
    UIFactory.CreateTextBox(secCoord, "X Coordinate", "0", function(t) xVal = tonumber(t) or xVal end)
    UIFactory.CreateTextBox(secCoord, "Y Coordinate", "10", function(t) yVal = tonumber(t) or yVal end)
    UIFactory.CreateTextBox(secCoord, "Z Coordinate", "0", function(t) zVal = tonumber(t) or zVal end)
    UIFactory.CreateButton(secCoord, "Teleport to Coordinates", function()
        TeleportEngine:TeleportToCFrame(CFrame.new(xVal, yVal, zVal))
    end, true)
    UIFactory.CreateButton(secCoord, "Teleport to Map SpawnLocation", function()
        local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if spawnLoc then
            TeleportEngine:TeleportToCFrame(spawnLoc.CFrame * CFrame.new(0, 4, 0))
        else
            TeleportEngine:TeleportToCFrame(CFrame.new(0, 15, 0))
        end
    end, false)
    UIFactory.CreateButton(secCoord, "Return to Previous Position", function()
        TeleportEngine:ReturnToPrevious()
    end, false)

    local secSaved = UIFactory.CreateSection(p, "Saved Waypoints", false)
    local wpName = ""
    local selectedWpIndex = 1
    UIFactory.CreateTextBox(secSaved, "Waypoint Name", "e.g., Base Camp", function(t) wpName = t end)

    local wpDropdown = UIFactory.CreateDropdown(secSaved, "Saved Waypoints", { "None" }, "None", function(name)
        for i, wp in ipairs(Hub.SavedPositions) do
            if wp.Name == name then
                selectedWpIndex = i
                break
            end
        end
    end)

    local function RefreshWaypointDropdown()
        local names = {}
        for _, wp in ipairs(Hub.SavedPositions) do
            table.insert(names, wp.Name)
        end
        if #names == 0 then table.insert(names, "None") end
        wpDropdown.Refresh(names)
    end

    UIFactory.CreateButton(secSaved, "Save Current Position", function()
        TeleportEngine:SaveCurrentPosition(wpName)
        RefreshWaypointDropdown()
    end, true)
    UIFactory.CreateButton(secSaved, "Teleport to Selected Waypoint", function()
        local wp = Hub.SavedPositions[selectedWpIndex]
        if wp then
            TeleportEngine:TeleportToCFrame(wp.CFrame)
        else
            Hub:Notify("Waypoint", "No saved waypoint selected.", "Warning", 2)
        end
    end, false)
    UIFactory.CreateButton(secSaved, "Rename Selected Waypoint", function()
        local wp = Hub.SavedPositions[selectedWpIndex]
        if wp and wpName ~= "" then
            wp.Name = wpName
            RefreshWaypointDropdown()
            Hub:Notify("Renamed", "Waypoint renamed to " .. wpName, "Success", 2)
        end
    end, false)
    UIFactory.CreateButton(secSaved, "Delete Selected Waypoint", function()
        if Hub.SavedPositions[selectedWpIndex] then
            table.remove(Hub.SavedPositions, selectedWpIndex)
            RefreshWaypointDropdown()
            Hub:Notify("Deleted", "Waypoint removed.", "Info", 2)
        end
    end, false)
end

-- 6. CHARACTER SIZE EDITOR
do
    local p = Hub.Pages["Character"]
    local secScale = UIFactory.CreateSection(p, "Character Scaling (0.1x – 10.0x)", false)
    local uSl = UIFactory.CreateSlider(secScale, "Uniform Scale", 0.1, 10.0, 1.0, 2, function(v)
        Hub.State.CharacterScale.Uniform = v
        CharacterScaler:ApplyScale()
    end)
    local wSl = UIFactory.CreateSlider(secScale, "Body Width Scale", 0.1, 10.0, 1.0, 2, function(v)
        Hub.State.CharacterScale.Width = v
        CharacterScaler:ApplyScale()
    end)
    local hSl = UIFactory.CreateSlider(secScale, "Body Height Scale", 0.1, 10.0, 1.0, 2, function(v)
        Hub.State.CharacterScale.Height = v
        CharacterScaler:ApplyScale()
    end)
    local dSl = UIFactory.CreateSlider(secScale, "Body Depth Scale", 0.1, 10.0, 1.0, 2, function(v)
        Hub.State.CharacterScale.Depth = v
        CharacterScaler:ApplyScale()
    end)
    local hdSl = UIFactory.CreateSlider(secScale, "Head Scale", 0.1, 10.0, 1.0, 2, function(v)
        Hub.State.CharacterScale.Head = v
        CharacterScaler:ApplyScale()
    end)

    UIFactory.CreateDropdown(secScale, "Scale Presets", { "Normal (1x)", "Miniature (0.3x)", "Giant (3x)", "Titan (8x)", "Bobblehead" }, "Normal (1x)", function(preset)
        if preset == "Normal (1x)" then
            uSl.Set(1, false) wSl.Set(1, false) hSl.Set(1, false) dSl.Set(1, false) hdSl.Set(1, false)
        elseif preset == "Miniature (0.3x)" then
            uSl.Set(0.3, false)
        elseif preset == "Giant (3x)" then
            uSl.Set(3.0, false)
        elseif preset == "Titan (8x)" then
            uSl.Set(8.0, false)
        elseif preset == "Bobblehead" then
            uSl.Set(1.0, false) hdSl.Set(3.0, false)
        end
    end)

    UIFactory.CreateButton(secScale, "Reset Character Dimensions", function()
        CharacterScaler:Reset()
        uSl.Set(1, true) wSl.Set(1, true) hSl.Set(1, true) dSl.Set(1, true) hdSl.Set(1, true)
        Hub:Notify("Scale Reset", "Character proportions restored to 1.0x.", "Success", 2.5)
    end, false)
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 13: UI PAGES 07–13 (VISUALS, ESP, COMBAT, AIM, NPC, VEHICLES)
-- ============================================================================

-- 7. VISUALS & 8. ESP
do
    local pVis = Hub.Pages["Visuals"]
    local secVis = UIFactory.CreateSection(pVis, "ESP Appearance & Preview", false)
    UIFactory.CreateLabel(secVis, "Authorized Debug/NPC ESP renders overlays only on NPCs, training targets, and debug-tagged models.", true)
    UIFactory.CreateSlider(secVis, "Max Render Distance (Studs)", 50, 5000, 1000, 0, function(v) Hub.State.ESP.MaxDistance = v end)
    UIFactory.CreateSlider(secVis, "Highlight Transparency", 0, 1, 0.2, 2, function(v) Hub.State.ESP.Transparency = v end)
    UIFactory.CreateSlider(secVis, "Line / Box Thickness", 1, 6, 2, 0, function(v) Hub.State.ESP.Thickness = v end)
    UIFactory.CreateSlider(secVis, "Label Text Size", 10, 24, 13, 0, function(v) Hub.State.ESP.TextSize = v end)
    UIFactory.CreateTextBox(secVis, "Custom ESP HEX Color", "#5882FF", function(hex)
        local c = HexToColor3(hex)
        if c then Hub.State.ESP.CustomColor = c end
    end)

    local pEsp = Hub.Pages["ESP"]
    local secEsp = UIFactory.CreateSection(pEsp, "Authorized NPC & Debug ESP Layers", false)
    local masterEsp = UIFactory.CreateToggle(secEsp, "Enable Authorized ESP System", false, function(v)
        Hub.State.ESP.Enabled = v
        if not v then ESPEngine:ClearAll() end
    end)
    UIFactory.CreateToggle(secEsp, "Box ESP", true, function(v) Hub.State.ESP.Box = v end)
    UIFactory.CreateToggle(secEsp, "Name ESP", true, function(v) Hub.State.ESP.Name = v end)
    UIFactory.CreateToggle(secEsp, "Distance ESP", true, function(v) Hub.State.ESP.Distance = v end)
    UIFactory.CreateToggle(secEsp, "Health Text ESP", true, function(v) Hub.State.ESP.HealthText = v end)
    UIFactory.CreateToggle(secEsp, "Health Bar ESP", true, function(v) Hub.State.ESP.HealthBar = v end)
    UIFactory.CreateToggle(secEsp, "Tracer ESP", false, function(v) Hub.State.ESP.Tracer = v end)
    UIFactory.CreateDropdown(secEsp, "Tracer Origin", { "Bottom", "Center", "Mouse" }, "Bottom", function(o) Hub.State.ESP.TracerOrigin = o end)
    UIFactory.CreateToggle(secEsp, "Head Marker Dot", false, function(v) Hub.State.ESP.HeadMarker = v end)
    UIFactory.CreateToggle(secEsp, "Chams / Highlight", true, function(v) Hub.State.ESP.Highlight = v end)
    UIFactory.CreateToggle(secEsp, "Include NPCs", true, function(v) Hub.State.ESP.TargetNPCs = v end)
    UIFactory.CreateToggle(secEsp, "Include Debug / Range Targets", true, function(v) Hub.State.ESP.TargetDebugObjects = v end)
    UIFactory.CreateButton(secEsp, "Reset ESP Settings", function()
        masterEsp.Set(false, false)
        Hub.State.ESP = DeepCopy(DefaultState.ESP)
        Hub:Notify("ESP Reset", "ESP layers restored to defaults.", "Success", 2.5)
    end, false)
end

-- 9. COMBAT, 10. AIM TRAINING & 11. NPC TOOLS
do
    local pCombat = Hub.Pages["Combat"]
    local secC = UIFactory.CreateSection(pCombat, "Weapon & Hitbox Debugging", false)
    UIFactory.CreateToggle(secC, "Hit Detection Markers", true, function(v) Hub.State.Combat.HitDetectionVis = v end)
    UIFactory.CreateToggle(secC, "Projectile Tracer Visualization", true, function(v) Hub.State.Combat.ProjectileVis = v end)
    UIFactory.CreateSlider(secC, "Simulated Hit Damage", 1, 250, 25, 0, function(v) Hub.State.Combat.SimDamage = v end)
    UIFactory.CreateButton(secC, "Fire Simulated Raycast Shot", function()
        CombatEngine:FireTestShot()
    end, true)

    local pAim = Hub.Pages["Aim Training"]
    local secAim = UIFactory.CreateSection(pAim, "Shooting Range & Aim Drills (Training Targets Only)", false)
    local statsLbl = UIFactory.CreateLabel(secAim, "Shots: 0 | Hits: 0 | Accuracy: 0.0% | Avg Reaction: 0 ms", false)
    UIFactory.CreateToggle(secAim, "Enable Aim Training Drill", false, function(v) Hub.State.Combat.AimTrainingActive = v end)
    UIFactory.CreateToggle(secAim, "Smooth Target Camera Tracking (Targets Only)", false, function(v) Hub.State.Combat.TargetTracking = v end)
    UIFactory.CreateSlider(secAim, "Tracking Smoothness", 0.05, 1.0, 0.25, 2, function(v) Hub.State.Combat.Smoothness = v end)
    UIFactory.CreateSlider(secAim, "Training Target Size (Studs)", 1.0, 10.0, 3.0, 1, function(v) Hub.State.Combat.TargetSize = v end)
    UIFactory.CreateDropdown(secAim, "Target Movement Pattern", { "Static", "Strafe", "Orbit", "Random" }, "Static", function(m) Hub.State.Combat.TargetMovement = m end)
    UIFactory.CreateButton(secAim, "Spawn Training Target", function()
        CombatEngine:SpawnTrainingTarget(nil)
    end, true)
    UIFactory.CreateButton(secAim, "Clear All Training Targets", function()
        CombatEngine:ClearTargets()
    end, false)
    UIFactory.CreateButton(secAim, "Reset Training Statistics", function()
        Hub.TrainingStats = { Shots = 0, Hits = 0, TotalReactionTime = 0, ReactionSamples = 0, LastTargetSpawnTime = 0 }
        statsLbl.Text = "Shots: 0 | Hits: 0 | Accuracy: 0.0% | Avg Reaction: 0 ms"
    end, false)

    Hub:TrackConnection("AimStatsLoop", RunService.Heartbeat:Connect(function()
        if pAim.Visible then
            local s = Hub.TrainingStats
            local acc = s.Shots > 0 and (s.Hits / s.Shots * 100) or 0
            local avgRt = s.ReactionSamples > 0 and (s.TotalReactionTime / s.ReactionSamples) or 0
            statsLbl.Text = string.format("Shots: %d | Hits: %d | Accuracy: %.1f%% | Avg Reaction: %.0f ms", s.Shots, s.Hits, acc, avgRt)
        end
    end))

    local pNpc = Hub.Pages["NPC Tools"]
    local secNpc = UIFactory.CreateSection(pNpc, "Studio NPC & Dummy Utilities", false)
    UIFactory.CreateButton(secNpc, "Spawn Cluster of 5 Training Targets", function()
        for i = -2, 2 do
            CombatEngine:SpawnTrainingTarget(Vector3.new(i * 6, 3, -30))
        end
        Hub:Notify("NPC / Range", "Spawned 5 training targets.", "Success", 2.5)
    end, true)
    UIFactory.CreateButton(secNpc, "Tag Workspace NPCs for Debug ESP", function()
        local count = 0
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
                m:SetAttribute("IsNPC", true)
                count += 1
            end
        end
        Hub:Notify("NPC Tagging", "Tagged " .. count .. " workspace NPCs.", "Info", 2.5)
    end, false)
end

-- 12. VEHICLES & 13. VEHICLE EDITOR
do
    local pVeh = Hub.Pages["Vehicles"]
    local secV = UIFactory.CreateSection(pVeh, "Vehicle Movement & Flight", false)
    UIFactory.CreateToggle(secV, "Vehicle Flight", false, function(v) VehicleEngine:SetVehicleFly(v) end)
    UIFactory.CreateSlider(secV, "Vehicle Fly Speed", 20, 400, 80, 0, function(v) Hub.State.Vehicle.FlySpeed = v end)
    UIFactory.CreateSlider(secV, "Vehicle MaxSpeed", 10, 500, 120, 0, function(v) Hub.State.Vehicle.MaxSpeed = v end)
    UIFactory.CreateSlider(secV, "Steering Sensitivity", 0.2, 5.0, 1.0, 2, function(v) Hub.State.Vehicle.SteeringSensitivity = v end)
    UIFactory.CreateSlider(secV, "Boost Velocity", 50, 500, 180, 0, function(v) Hub.State.Vehicle.BoostPower = v end)
    UIFactory.CreateButton(secV, "Trigger Vehicle Boost", function() VehicleEngine:Boost() end, true)
    UIFactory.CreateButton(secV, "Emergency Vehicle Brake", function() VehicleEngine:Brake() end, false)
    UIFactory.CreateButton(secV, "Return Vehicle to Spawn", function() VehicleEngine:ReturnToSpawn() end, false)

    local pVehEd = Hub.Pages["Vehicle Editor"]
    local secVE = UIFactory.CreateSection(pVehEd, "Vehicle Position & Orientation Nudger", false)
    UIFactory.CreateDropdown(secVE, "Control Mode", { "Default", "Smooth", "Precision", "Custom" }, "Default", function(m)
        Hub.State.Vehicle.ControlMode = m
    end)
    UIFactory.CreateButton(secVE, "Lift Vehicle +10 Studs (Y-Axis)", function()
        local seat, model = VehicleEngine:GetSeatedVehicle()
        if model then model:PivotTo(model:GetPivot() * CFrame.new(0, 10, 0))
        elseif seat then seat.CFrame *= CFrame.new(0, 10, 0) end
    end, false)
    UIFactory.CreateButton(secVE, "Flip / Upright Vehicle Orientation", function()
        local seat, model = VehicleEngine:GetSeatedVehicle()
        if model then
            local pos = model:GetPivot().Position
            model:PivotTo(CFrame.new(pos))
        elseif seat then
            seat.CFrame = CFrame.new(seat.Position)
        end
    end, true)
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 14: UI PAGES 14–20 (WORLD, GRAPHICS, PERFORMANCE, LIGHTING, ENV, AUDIO, ANIM)
-- ============================================================================

-- 14. WORLD, 15. GRAPHICS, 16. PERFORMANCE, 17. LIGHTING, 18. ENVIRONMENT
do
    -- Post-Processing Instances managed cleanly in Lighting
    local ccEffect = Lighting:FindFirstChild("MaxHub_CC") :: ColorCorrectionEffect? or Instance.new("ColorCorrectionEffect")
    ccEffect.Name = "MaxHub_CC"
    ccEffect.Enabled = false
    ccEffect.Parent = Lighting

    local bloomEffect = Lighting:FindFirstChild("MaxHub_Bloom") :: BloomEffect? or Instance.new("BloomEffect")
    bloomEffect.Name = "MaxHub_Bloom"
    bloomEffect.Enabled = false
    bloomEffect.Parent = Lighting

    local blurEffect = Lighting:FindFirstChild("MaxHub_Blur") :: BlurEffect? or Instance.new("BlurEffect")
    blurEffect.Name = "MaxHub_Blur"
    blurEffect.Enabled = false
    blurEffect.Size = 4
    blurEffect.Parent = Lighting

    local sunRays = Lighting:FindFirstChild("MaxHub_SunRays") :: SunRaysEffect? or Instance.new("SunRaysEffect")
    sunRays.Name = "MaxHub_SunRays"
    sunRays.Enabled = false
    sunRays.Parent = Lighting

    -- Page 14: World
    local pWorld = Hub.Pages["World"]
    local secW = UIFactory.CreateSection(pWorld, "World Time & Atmosphere", false)
    local clockSl = UIFactory.CreateSlider(secW, "ClockTime (0–24h)", 0, 24, Lighting.ClockTime, 1, function(v)
        Hub.State.World.ClockTime = v
        Lighting.ClockTime = v
    end)
    local brightSl = UIFactory.CreateSlider(secW, "Lighting Brightness", 0, 10, Lighting.Brightness, 2, function(v)
        Hub.State.World.Brightness = v
        Lighting.Brightness = v
    end)
    local fogStartSl = UIFactory.CreateSlider(secW, "Fog Start", 0, 5000, Lighting.FogStart, 0, function(v)
        Hub.State.World.FogStart = v
        Lighting.FogStart = v
    end)
    local fogEndSl = UIFactory.CreateSlider(secW, "Fog End", 50, 10000, math.min(10000, Lighting.FogEnd), 0, function(v)
        Hub.State.World.FogEnd = v
        Lighting.FogEnd = v
    end)
    UIFactory.CreateButton(secW, "Reset World & Lighting to Original", function()
        local orig = Hub.OriginalLighting
        Lighting.ClockTime = orig.ClockTime
        Lighting.Brightness = orig.Brightness
        Lighting.Ambient = orig.Ambient
        Lighting.OutdoorAmbient = orig.OutdoorAmbient
        Lighting.FogColor = orig.FogColor
        Lighting.FogStart = orig.FogStart
        Lighting.FogEnd = orig.FogEnd
        Lighting.GlobalShadows = orig.GlobalShadows
        clockSl.Set(orig.ClockTime, true)
        brightSl.Set(orig.Brightness, true)
        Hub:Notify("World Reset", "Restored original experience lighting.", "Success", 2.5)
    end, false)

    -- Page 15: Graphics
    local pGfx = Hub.Pages["Graphics"]
    local secGfx = UIFactory.CreateSection(pGfx, "Post-Processing & Visual Effects", false)
    UIFactory.CreateLabel(secGfx, "Note: Engine render quality levels are managed by Roblox Client Settings; controls below adjust supported Lighting & Particle properties.", true)
    UIFactory.CreateToggle(secGfx, "Global Shadows", Lighting.GlobalShadows, function(v)
        Hub.State.Graphics.Shadows = v
        Lighting.GlobalShadows = v
    end)
    UIFactory.CreateToggle(secGfx, "Workspace Particles & Beams", true, function(v)
        Hub.State.Graphics.ParticlesEnabled = v
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = v
            end
        end
    end)
    UIFactory.CreateToggle(secGfx, "Color Correction", false, function(v) ccEffect.Enabled = v end)
    UIFactory.CreateSlider(secGfx, "CC Brightness", -1, 1, 0, 2, function(v) ccEffect.Brightness = v end)
    UIFactory.CreateSlider(secGfx, "CC Contrast", -1, 1, 0, 2, function(v) ccEffect.Contrast = v end)
    UIFactory.CreateSlider(secGfx, "CC Saturation", -1, 1, 0, 2, function(v) ccEffect.Saturation = v end)
    UIFactory.CreateToggle(secGfx, "Bloom Effect", false, function(v) bloomEffect.Enabled = v end)
    UIFactory.CreateToggle(secGfx, "Depth / Screen Blur", false, function(v) blurEffect.Enabled = v end)
    UIFactory.CreateToggle(secGfx, "SunRays Effect", false, function(v) sunRays.Enabled = v end)

    -- Page 16: Performance
    local pPerf = Hub.Pages["Performance"]
    local secPerf = UIFactory.CreateSection(pPerf, "Performance Presets & Telemetry", false)
    UIFactory.CreateToggle(secPerf, "Show Topbar FPS & Memory Pill", true, function(v)
        Hub.State.Graphics.ShowFPS = v
        TelemetryLabel.Visible = v
    end)
    UIFactory.CreateDropdown(secPerf, "Graphics Quality Preset", {
        "Ultra Quality", "High Quality", "Balanced", "Performance", "Low Graphics", "Minimal Effects"
    }, "Balanced", function(preset)
        Hub.State.Graphics.Preset = preset
        if preset == "Ultra Quality" then
            Lighting.GlobalShadows = true
            bloomEffect.Enabled = true
            sunRays.Enabled = true
        elseif preset == "Balanced" then
            Lighting.GlobalShadows = true
            bloomEffect.Enabled = false
            sunRays.Enabled = false
        elseif preset == "Performance" or preset == "Low Graphics" or preset == "Minimal Effects" then
            Lighting.GlobalShadows = false
            bloomEffect.Enabled = false
            sunRays.Enabled = false
            blurEffect.Enabled = false
        end
        Hub:Notify("Graphics Preset", "Applied " .. preset, "Info", 2)
    end)

    -- Page 17: Lighting & Page 18: Environment
    local pLight = Hub.Pages["Lighting"]
    local secL = UIFactory.CreateSection(pLight, "Ambient & Fog Color Editor", false)
    UIFactory.CreateTextBox(secL, "Ambient HEX", "#7F7F7F", function(hex)
        local c = HexToColor3(hex)
        if c then Lighting.Ambient = c end
    end)
    UIFactory.CreateTextBox(secL, "OutdoorAmbient HEX", "#8C8C8C", function(hex)
        local c = HexToColor3(hex)
        if c then Lighting.OutdoorAmbient = c end
    end)
    UIFactory.CreateTextBox(secL, "FogColor HEX", "#C0C0C0", function(hex)
        local c = HexToColor3(hex)
        if c then Lighting.FogColor = c end
    end)

    local pEnv = Hub.Pages["Environment"]
    local secEnv = UIFactory.CreateSection(pEnv, "Environment Time Presets", false)
    UIFactory.CreateButton(secEnv, "Preset: Crisp Morning (08:00)", function()
        Lighting.ClockTime = 8
        Lighting.Brightness = 2.2
    end, false)
    UIFactory.CreateButton(secEnv, "Preset: Golden Sunset (18:15)", function()
        Lighting.ClockTime = 18.25
        Lighting.Brightness = 1.8
    end, false)
    UIFactory.CreateButton(secEnv, "Preset: Starry Midnight (00:00)", function()
        Lighting.ClockTime = 0
        Lighting.Brightness = 1.0
    end, false)
end

-- 19. AUDIO & 20. ANIMATIONS
do
    local pAudio = Hub.Pages["Audio"]
    local secAud = UIFactory.CreateSection(pAudio, "Interface Sound Feedback", false)
    UIFactory.CreateToggle(secAud, "Enable UI Audio", true, function(v) Hub.State.Audio.Enabled = v end)
    UIFactory.CreateSlider(secAud, "Master UI Volume", 0, 1, 0.5, 2, function(v) Hub.State.Audio.MasterVolume = v end)
    UIFactory.CreateSlider(secAud, "Click & Toggle Volume", 0, 1, 0.5, 2, function(v) Hub.State.Audio.UIVolume = v end)
    UIFactory.CreateSlider(secAud, "Notification Volume", 0, 1, 0.6, 2, function(v) Hub.State.Audio.NotifVolume = v end)
    UIFactory.CreateButton(secAud, "Test Notification Sound", function()
        Hub:Notify("Audio Test", "Notification chime triggered.", "Info", 2)
    end, false)

    local pAnim = Hub.Pages["Animations"]
    local secAnim = UIFactory.CreateSection(pAnim, "Motion & Tween Settings", false)
    UIFactory.CreateToggle(secAnim, "Enable UI Animations", true, function(v) Hub.State.UI.AnimationsEnabled = v end)
    UIFactory.CreateSlider(secAnim, "Animation Duration (Seconds)", 0.05, 0.8, 0.22, 2, function(v) Hub.State.UI.AnimationSpeed = v end)
end
-- ============================================================================
-- PROJECT: tiktok: max1sroxedits01 (MAX ULTIMATE HUB)
-- PART 15: UI PAGES 21–25, KEYBINDS, CONFIG, THEME, RESPAWN & INIT
-- ============================================================================

-- 21. KEYBIND MANAGER
do
    local pKeys = Hub.Pages["Keybinds"]
    local secK = UIFactory.CreateSection(pKeys, "Interactive Keybind Assignments", false)
    UIFactory.CreateToggle(secK, "Enable Global Keybinds", true, function(v) Hub.State.UI.KeybindsEnabled = v end)

    local listeningAction: string? = nil
    local keyButtons: { [string]: TextButton } = {}

    local function RegisterKeybind(actionName: string, defaultKey: Enum.KeyCode?, category: string, callback: () -> ())
        Hub.Keybinds[actionName] = {
            Key = defaultKey,
            Enabled = true,
            Category = category,
            Callback = callback,
        }

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = Hub.Theme.Button
        row.BorderSizePixel = 0
        row.Parent = secK
        AddCorner(row, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -135, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Hub.State.UI.Font
        lbl.TextSize = 13
        lbl.TextColor3 = Hub.Theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = actionName .. " (" .. category .. ")"
        lbl.Parent = row

        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(0, 115, 0, 24)
        bindBtn.Position = UDim2.new(1, -123, 0.5, -12)
        bindBtn.BackgroundColor3 = Hub.Theme.Background
        bindBtn.Font = Enum.Font.Code
        bindBtn.TextSize = 12
        bindBtn.TextColor3 = Hub.Theme.Accent
        bindBtn.Text = defaultKey and defaultKey.Name or "NONE"
        bindBtn.Parent = row
        AddCorner(bindBtn, 5)
        keyButtons[actionName] = bindBtn

        bindBtn.MouseButton1Click:Connect(function()
            PlayHubSound("Click")
            listeningAction = actionName
            bindBtn.Text = "[Press Key...]"
            bindBtn.TextColor3 = Hub.Theme.Warning
        end)
    end

    RegisterKeybind("Toggle Hub UI", Enum.KeyCode.RightShift, "Interface", function()
        Hub:SetWindowVisible(not Hub.IsOpen)
    end)
    RegisterKeybind("Toggle Flight", Enum.KeyCode.F, "Movement", function()
        MovementEngine:SetFly(not Hub.State.Movement.FlyEnabled)
        Hub:Notify("Flight", Hub.State.Movement.FlyEnabled and "Enabled" or "Disabled", "Info", 1.8)
    end)
    RegisterKeybind("Toggle Noclip", Enum.KeyCode.N, "Movement", function()
        Hub.State.Movement.NoclipEnabled = not Hub.State.Movement.NoclipEnabled
        Hub:Notify("Noclip", Hub.State.Movement.NoclipEnabled and "Enabled" or "Disabled", "Info", 1.8)
    end)
    RegisterKeybind("Execute Dash", Enum.KeyCode.Q, "Movement", function()
        MovementEngine:TriggerDash()
    end)
    RegisterKeybind("Toggle Authorized ESP", Enum.KeyCode.Y, "Visuals", function()
        Hub.State.ESP.Enabled = not Hub.State.ESP.Enabled
        Hub:Notify("ESP", Hub.State.ESP.Enabled and "Enabled" or "Disabled", "Info", 1.8)
    end)
    RegisterKeybind("Fire Range Test Shot", Enum.KeyCode.T, "Combat", function()
        CombatEngine:FireTestShot()
    end)

    Hub:TrackConnection("GlobalKeyInput", UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        if listeningAction then
            local newKey = input.KeyCode
            if newKey == Enum.KeyCode.Escape or newKey == Enum.KeyCode.Backspace then
                Hub.Keybinds[listeningAction].Key = nil
                keyButtons[listeningAction].Text = "NONE"
            else
                -- Conflict detection
                for otherName, data in pairs(Hub.Keybinds) do
                    if otherName ~= listeningAction and data.Key == newKey then
                        Hub:Notify("Key Conflict", newKey.Name .. " is also bound to " .. otherName, "Warning", 3)
                    end
                end
                Hub.Keybinds[listeningAction].Key = newKey
                keyButtons[listeningAction].Text = newKey.Name
            end
            keyButtons[listeningAction].TextColor3 = Hub.Theme.Accent
            listeningAction = nil
            return
        end

        if gameProcessed or not Hub.State.UI.KeybindsEnabled then return end
        for _, data in pairs(Hub.Keybinds) do
            if data.Enabled and data.Key == input.KeyCode then
                data.Callback()
            end
        end
    end))
end

-- 22. CONFIGURATION & PROFILES
do
    local pCfg = Hub.Pages["Configuration"]
    local secCfg = UIFactory.CreateSection(pCfg, "Profile Management", false)
    local profileNameInput = "Default"
    Hub.Configs["Default"] = DeepCopy(Hub.State)

    local profileDrop = UIFactory.CreateDropdown(secCfg, "Active Profile", { "Default" }, "Default", function(name)
        Hub.CurrentConfigName = name
    end)

    local function RefreshProfiles()
        local list = {}
        for k, _ in pairs(Hub.Configs) do table.insert(list, k) end
        profileDrop.Refresh(list)
    end

    UIFactory.CreateTextBox(secCfg, "Profile Name", "Enter profile name...", function(txt)
        if txt ~= "" then profileNameInput = txt end
    end)
    UIFactory.CreateButton(secCfg, "Save Current Configuration", function()
        Hub.Configs[profileNameInput] = DeepCopy(Hub.State)
        Hub.CurrentConfigName = profileNameInput
        RefreshProfiles()
        Hub:Notify("Config Saved", "Saved profile '" .. profileNameInput .. "'", "Success", 2.5)
    end, true)
    UIFactory.CreateButton(secCfg, "Load Selected Configuration", function()
        local saved = Hub.Configs[Hub.CurrentConfigName]
        if saved then
            Hub.State = DeepCopy(saved)
            Hub:Notify("Config Loaded", "Loaded profile '" .. Hub.CurrentConfigName .. "'", "Success", 2.5)
        end
    end, false)
    UIFactory.CreateButton(secCfg, "Delete Selected Configuration", function()
        if Hub.CurrentConfigName ~= "Default" then
            Hub.Configs[Hub.CurrentConfigName] = nil
            Hub.CurrentConfigName = "Default"
            RefreshProfiles()
            Hub:Notify("Config Deleted", "Reverted to Default profile.", "Info", 2.5)
        else
            Hub:Notify("Protected", "Cannot delete Default profile.", "Warning", 2)
        end
    end, false)
    UIFactory.CreateButton(secCfg, "Reset ALL Hub Settings", function()
        Hub.State = DeepCopy(DefaultState)
        MovementEngine:SetFly(false)
        ESPEngine:ClearAll()
        CharacterScaler:Reset()
        Hub:Notify("Full Reset", "All systems restored to factory defaults.", "Success", 3)
    end, false)
end

-- 23. INTERFACE SETTINGS & THEME EDITOR
do
    local pUI = Hub.Pages["Interface Settings"]
    local secTheme = UIFactory.CreateSection(pUI, "Theme & Color Customization", false)

    function Hub:ApplyTheme(themeName: string)
        local t = Themes[themeName] or Hub.State.CustomTheme
        Hub.State.ThemeName = themeName
        Hub.Theme = DeepCopy(t)
        MainWindow.BackgroundColor3 = Hub.Theme.Background
        Topbar.BackgroundColor3 = Hub.Theme.Sidebar
        Sidebar.BackgroundColor3 = Hub.Theme.Sidebar
        MainStroke.Color = Hub.Theme.Border
        TelemetryLabel.TextColor3 = Hub.Theme.Accent
    end

    UIFactory.CreateDropdown(secTheme, "Select Theme Preset", {
        "Dark", "Light", "Midnight", "Crimson", "Purple", "Blue", "Emerald"
    }, "Dark", function(name)
        Hub:ApplyTheme(name)
        Hub:Notify("Theme Updated", "Applied " .. name .. " theme.", "Info", 2)
    end)

    UIFactory.CreateTextBox(secTheme, "Custom Accent HEX", "#5882FF", function(hex)
        local c = HexToColor3(hex)
        if c then
            Hub.Theme.Accent = c
            Hub.Theme.ToggleOn = c
            TelemetryLabel.TextColor3 = c
            Hub:Notify("Accent Updated", "Custom accent color applied.", "Success", 2)
        end
    end)

    local secDims = UIFactory.CreateSection(pUI, "Window Layout & Scale", false)
    UIFactory.CreateSlider(secDims, "Window Width", 620, 1100, 780, 0, function(v)
        Hub.State.UI.WindowWidth = v
        MainWindow.Size = UDim2.new(0, v, 0, Hub.IsMinimized and 44 or Hub.State.UI.WindowHeight)
    end)
    UIFactory.CreateSlider(secDims, "Window Height", 380, 780, 520, 0, function(v)
        Hub.State.UI.WindowHeight = v
        if not Hub.IsMinimized then
            MainWindow.Size = UDim2.new(0, Hub.State.UI.WindowWidth, 0, v)
        end
    end)
    UIFactory.CreateSlider(secDims, "Sidebar Width", 150, 260, 195, 0, function(v)
        Hub.State.UI.SidebarWidth = v
        Sidebar.Size = UDim2.new(0, v, 1, -44)
        ContentContainer.Size = UDim2.new(1, -v, 1, -44)
        ContentContainer.Position = UDim2.new(0, v, 0, 44)
    end)
    UIFactory.CreateSlider(secDims, "Global UI Scale", 0.75, 1.35, 1.0, 2, function(v)
        Hub.State.UI.UIScale = v
        UIScaleObj.Scale = v
    end)
    UIFactory.CreateSlider(secDims, "Window Transparency", 0, 0.5, 0, 2, function(v)
        Hub.State.UI.Transparency = v
        MainWindow.BackgroundTransparency = v
    end)
end

-- 24. DEVELOPER TOOLS & 25. ABOUT
do
    local pDev = Hub.Pages["Developer Tools"]
    local secDev = UIFactory.CreateSection(pDev, "Studio Diagnostics & Cleanup", false)
    UIFactory.CreateButton(secDev, "Print Current State Snapshot to Output", function()
        print("[" .. Hub.BrandName .. "] State Snapshot:", Hub.State)
        Hub:Notify("Developer Output", "Printed state table to F9 Developer Console.", "Info", 2.5)
    end, false)
    UIFactory.CreateButton(secDev, "Unload & Destroy Hub Cleanly", function()
        Hub:CleanupAll()
    end, true)

    local pAbout = Hub.Pages["About"]
    local secAb = UIFactory.CreateSection(pAbout, "System Information", false)
    UIFactory.CreateLabel(secAb, Hub.BrandName .. "  —  " .. Hub.Version, false)
    UIFactory.CreateLabel(secAb, "Modular Roblox Studio Admin, Gameplay Testing, Physics, Vehicle & Visual Debugging Suite.", true)
    UIFactory.CreateLabel(secAb, "Supports PC (Mouse/Keyboard) and Mobile (Touch) with zero external dependencies.", true)
end

-- ============================================================================
-- CHARACTER RESPAWN & INITIALIZATION SEQUENCE
-- ============================================================================
Hub:TrackConnection("CharacterAdded", LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 5) :: Humanoid?
    if hum then
        hum.WalkSpeed = Hub.State.Player.WalkSpeed
        if hum.UseJumpPower then
            hum.JumpPower = Hub.State.Player.JumpPower
        else
            hum.JumpHeight = Hub.State.Player.JumpHeight
        end
    end
    task.wait(0.2)
    CharacterScaler:ApplyScale()
    if Hub.State.Movement.FlyEnabled then
        MovementEngine:SetFly(true)
    end
end))

-- Transition from Splash Screen to Main Window
task.delay(0.75, function()
    if SplashFrame and SplashFrame.Parent then
        local fade = TweenService:Create(SplashFrame, GetTweenInfo(0.25), { BackgroundTransparency = 1 })
        fade:Play()
        fade.Completed:Wait()
        SplashFrame:Destroy()
    end
    MainWindow.Visible = true
    Hub:SwitchPage("Home")
    Hub:Notify("Ready", Hub.BrandName .. " initialized successfully.", "Success", 3.5)
end)

-- ============================================================================
-- END OF PART 15 (COMPLETE SYSTEM)
-- ============================================================================
