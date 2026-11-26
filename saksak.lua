-- [1] Kutuphane ve Servisler
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
-- [2] Hedef ve Hareket Durum Degiskenleri
local Aim_Enabled = false
local AimType = "Normal" -- "Normal", "Acikta", "Daire"
local AimPart = "Head"
local AimSmoothness = 0.25
local FOV_ShowCircle = true
local FOV_Radius = 150

local TeamCheck = true
local AliveCheck = true
local WallCheck = true

local Speed_Enabled = false
local WalkSpeed_Val = 32
local Jump_Enabled = false
local JumpPower_Val = 85
local InfiniteJump_Enabled = false
local NoClip_Enabled = false
local Fly_Enabled = false
local FlySpeed_Val = 50
-- [3] ESP ve Dunya Degiskenleri
local ESP_Enabled = false
local ESP_Box = true
local ESP_Name = true
local ESP_Distance = true
local ESP_EnemyOnly = true

local Fullbright_Enabled = false
local NoFog_Enabled = false

local ESP_Cache = {}
local SavedFogStart = Lighting.FogStart
local SavedFogEnd = Lighting.FogEnd
local SavedBrightness = Lighting.Brightness
local SavedAmbient = Lighting.Ambient
-- [4] Karakter ve Kontrol Yardimcilari
local function GetChar()
    return LocalPlayer.Character
end

local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function IsEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if not ESP_EnemyOnly and not TeamCheck then return true end
    if LocalPlayer.Team and plr.Team then
        return plr.Team ~= LocalPlayer.Team
    end
    return true
end

local function IsPlayerAlive(plr)
    if not AliveCheck then return true end
    local c = plr and plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0
end
-- [5] Acikta (Gorunurluk) Kontrolu
local function IsOpenTarget(targetPart)
    if not targetPart or not Camera then return false end
    if AimType == "Normal" then return true end
    if AimType == "Acikta" or WallCheck then
        local origin = Camera.CFrame.Position
        local dir = targetPart.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if GetChar() then table.insert(ignore, GetChar()) end
        if targetPart.Parent then table.insert(ignore, targetPart.Parent) end
        params.FilterDescendantsInstances = ignore

        local hit = Workspace:Raycast(origin, dir, params)
        if not hit then return true end
        if targetPart.Parent and hit.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end
-- [6] Hedef Secme (Normal / Acikta / Daire)
local function GetBestTarget()
    if not Camera then return nil end
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local bestPart = nil
    local bestMetric = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and IsPlayerAlive(plr) and IsEnemy(plr) then
            local part = plr.Character:FindFirstChild(AimPart) or plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            if part and part:IsA("BasePart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local worldDist = (part.Position - Camera.CFrame.Position).Magnitude
                local screenDist = onScreen and screenPos.Z > 0 and (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude or math.huge

                if AimType == "Daire" then
                    if not onScreen or screenPos.Z <= 0 or screenDist > FOV_Radius then
                        continue
                    end
                    if not IsOpenTarget(part) then
                        continue
                    end
                    if screenDist < bestMetric then
                        bestMetric = screenDist
                        bestPart = part
                    end
                elseif AimType == "Acikta" then
                    if not IsOpenTarget(part) then
                        continue
                    end
                    if worldDist < bestMetric then
                        bestMetric = worldDist
                        bestPart = part
                    end
                else -- "Normal"
                    if worldDist < bestMetric then
                        bestMetric = worldDist
                        bestPart = part
                    end
                end
            end
        end
    end

    return bestPart
end
-- [7] FOV Dairesi Cizimi
local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.6
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 200, 40)
    FOVCircle.Visible = false
end
-- [8] ESP Olusturma ve Guncelleme
local function ClearESP(plr)
    local data = ESP_Cache[plr]
    if not data then return end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    ESP_Cache[plr] = nil
end

Players.PlayerRemoving:Connect(ClearESP)

local function UpdateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character or not ESP_Enabled then
            ClearESP(plr)
            continue
        end

        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head or not IsPlayerAlive(plr) or not IsEnemy(plr) then
            ClearESP(plr)
            continue
        end

        local data = ESP_Cache[plr]
        if not data then
            data = {}
            ESP_Cache[plr] = data
        end

        if ESP_Box then
            if not data.Highlight or not data.Highlight.Parent then
                local hl = Instance.new("Highlight")
                hl.Name = "CleanESP_HL"
                hl.FillColor = Color3.fromRGB(255, 70, 70)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.65
                hl.OutlineTransparency = 0.1
                hl.Adornee = char
                hl.Parent = char
                data.Highlight = hl
            end
            data.Highlight.Enabled = true
        elseif data.Highlight then
            data.Highlight.Enabled = false
        end

        if ESP_Name or ESP_Distance then
            if not data.Billboard or not data.Billboard.Parent then
                local bb = Instance.new("BillboardGui")
                bb.Name = "CleanESP_BB"
                bb.Size = UDim2.new(0, 170, 0, 36)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head

                local lbl = Instance.new("TextLabel")
                lbl.Name = "Txt"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.TextStrokeTransparency = 0.2
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 12
                lbl.Parent = bb

                data.Billboard = bb
                data.Label = lbl
            end
            data.Billboard.Enabled = true
            local info = {}
            if ESP_Name then table.insert(info, plr.DisplayName) end
            if ESP_Distance and Camera then
                table.insert(info, math.floor((hrp.Position - Camera.CFrame.Position).Magnitude) .. "m")
            end
            if data.Label then
                data.Label.Text = table.concat(info, " | ")
            end
        elseif data.Billboard then
            data.Billboard.Enabled = false
        end
    end
end
-- [9] Rayfield Penceresi
local Window = Rayfield:CreateWindow({
    Name = "Temiz Oyun Menusu",
    LoadingTitle = "Yukleniyor...",
    LoadingSubtitle = "Aim • Movement • Visuals",
    ConfigurationSaving = { Enabled = false }
})
-- [10] Sekme 1: Aim Ayarlari
local TabAim = Window:CreateTab("Hedef / Aim", 4483362458)

TabAim:CreateToggle({
    Name = "AimBot",
    CurrentValue = false,
    Callback = function(v) Aim_Enabled = v end
})

TabAim:CreateDropdown({
    Name = "AimType (Normal / Acikta / Daire)",
    Options = {"Normal", "Acikta", "Daire"},
    CurrentOption = {"Normal"},
    Callback = function(opt) AimType = opt[1] end
})

TabAim:CreateDropdown({
    Name = "AimPart",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(opt) AimPart = opt[1] end
})

TabAim:CreateSlider({
    Name = "Smoothness",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(v) AimSmoothness = v / 100 end
})

TabAim:CreateToggle({
    Name = "FOVCircle",
    CurrentValue = true,
    Callback = function(v) FOV_ShowCircle = v end
})

TabAim:CreateSlider({
    Name = "FOVRadius",
    Range = {40, 400},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(v) FOV_Radius = v end
})

TabAim:CreateToggle({
    Name = "TeamCheck",
    CurrentValue = true,
    Callback = function(v) TeamCheck = v end
})
-- [11] Sekme 2: Hareket Ayarlari
local TabMove = Window:CreateTab("Hareket", 4483362458)

TabMove:CreateToggle({
    Name = "SpeedHack",
    CurrentValue = false,
    Callback = function(v) Speed_Enabled = v end
})

TabMove:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 32,
    Callback = function(v) WalkSpeed_Val = v end
})

TabMove:CreateToggle({
    Name = "JumpPowerHack",
    CurrentValue = false,
    Callback = function(v) Jump_Enabled = v end
})

TabMove:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 85,
    Callback = function(v) JumpPower_Val = v end
})

TabMove:CreateToggle({
    Name = "InfiniteJump",
    CurrentValue = false,
    Callback = function(v) InfiniteJump_Enabled = v end
})

TabMove:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v) NoClip_Enabled = v end
})

TabMove:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v) Fly_Enabled = v end
})

TabMove:CreateSlider({
    Name = "FlySpeed",
    Range = {15, 140},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) FlySpeed_Val = v end
})
-- [12] Sekme 3: ESP ve Gorunum
local TabVis = Window:CreateTab("Gorunum / ESP", 4483362458)

TabVis:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(v) ESP_Enabled = v end
})

TabVis:CreateToggle({
    Name = "HighlightESP",
    CurrentValue = true,
    Callback = function(v) ESP_Box = v end
})

TabVis:CreateToggle({
    Name = "NameESP",
    CurrentValue = true,
    Callback = function(v) ESP_Name = v end
})

TabVis:CreateToggle({
    Name = "DistanceESP",
    CurrentValue = true,
    Callback = function(v) ESP_Distance = v end
})

TabVis:CreateToggle({
    Name = "EnemyOnly",
    CurrentValue = true,
    Callback = function(v) ESP_EnemyOnly = v end
})

TabVis:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        Fullbright_Enabled = v
        if v then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = SavedBrightness
            Lighting.Ambient = SavedAmbient
        end
    end
})

TabVis:CreateToggle({
    Name = "NoFog",
    CurrentValue = false,
    Callback = function(v)
        NoFog_Enabled = v
        if v then
            Lighting.FogStart = 100000
            Lighting.FogEnd = 100000
        else
            Lighting.FogStart = SavedFogStart
            Lighting.FogEnd = SavedFogEnd
        end
    end
})
-- [13] Sonsuz Zipla Baglantisi
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump_Enabled then
        local hum = GetHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
-- [14] Hareket ve NoClip Dongusu
RunService.Stepped:Connect(function()
    local char = GetChar()
    local hum = GetHum()
    local hrp = GetHRP()

    if hum then
        if Speed_Enabled then
            hum.WalkSpeed = WalkSpeed_Val
        end
        if Jump_Enabled then
            hum.UseJumpPower = true
            hum.JumpPower = JumpPower_Val
        end
    end

    if char and NoClip_Enabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if hrp and Fly_Enabled then
        local move = hum and hum.MoveDirection or Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.new(move.X * FlySpeed_Val, 0, move.Z * FlySpeed_Val)
    end
end)
-- [15] Ana Render Dongusu
RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)

    if FOVCircle and Camera then
        FOVCircle.Visible = (AimType == "Daire" and FOV_ShowCircle)
        FOVCircle.Radius = FOV_Radius
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    end

    if Aim_Enabled and Camera then
        local targetPart = GetBestTarget()
        if targetPart then
            local goalCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, math.clamp(AimSmoothness, 0.02, 1))
        end
    end
end)
