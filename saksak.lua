--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local EskiUI = PlayerGui:FindFirstChild("MobilSistem_UI")
if EskiUI then
	EskiUI:Destroy()
end

local Sistem = {
	Acik = true,
	SimgeMod = false,
	PatatesMod = false,
	GorunumModu = "TamPanel" :: "TamPanel" | "UstTavan" | "TekButon",
	AktifSekme = "Nisan",
	Baglantilar = {} :: { RBXScriptConnection },
	OzelTusKayitlari = {} :: { [string]: () -> () },
	OzelTusDurumlari = {} :: { [string]: boolean },
	OzelTusButonlari = {} :: { [string]: TextButton },
	KayitliKonumlar = {} :: { { Ad: string, Konum: CFrame } },
	GecmisKonumlar = {} :: { CFrame },
	SeciliOyuncu = nil :: Player?,
	OtoTakipAktif = false,
	OtoTakipHedefModu = "EnYakinOyuncu" :: "EnYakinOyuncu" | "EnYakinBot" | "SeciliOyuncu",
	OtoTakipMesafe = 7,
	TahminAktif = false,
	TahminGucu = 0.14,
	TetikAktif = false,
	TetikBekleme = 0.08,
	SonTetikZamani = 0,
	MermiBicakHizCarpan = 50, -- 1 - 100
	FirlatmaHizi = 50, -- 1 - 100
	Aimbot = {
		Aktif = false,
		Tur = "Normal" :: "Normal" | "Daire" | "Acikta",
		HedefTuru = "Hepsi" :: "Hepsi" | "Bot" | "Oyuncu Gercek",
		Parca = "Kafa" :: "Kafa" | "Govde",
		SadeceAcikta = false,
		DaireGoster = true,
		DaireYaricap = 140,
		MesafeSiniri = 450,
		Keskinlik = 55, -- 0 - 100 (0 en yumusak, 100 en keskin)
	},
	SilentAim = {
		Aktif = false,
		HedefTuru = "Hepsi" :: "Hepsi" | "Bot" | "Oyuncu Gercek",
		Parca = "Kafa" :: "Kafa" | "Govde",
		DaireKullan = true,
		DaireYaricap = 150,
		SadeceAcikta = true,
		MesafeSiniri = 500,
	},
	Hitbox = {
		Aktif = false,
		HedefTuru = "Bot" :: "Hepsi" | "Bot" | "Oyuncu Gercek",
		ParcaModu = "Govde" :: "Govde" | "Kafa" | "Ikisi",
		Boyut = 7,
		Gorunur = true,
		Seffaflik = 0.65,
	},
	ESP = {
		Aktif = false,
		HedefTuru = "Hepsi" :: "Hepsi" | "Bot" | "Oyuncu Gercek",
		Isim = true,
		Mesafe = true,
		CanBar = true,
		Kutu = true,
		Cizgi = false,
		Vurgu = true,
		TakimRengi = true,
		MesafeSiniri = 800,
	},
	Hareket = {
		NormalFly = false,
		NormalFlyHiz = 70,
		NormalFlyShiftLock = true,
		DikeyYon = 0, -- -1 asagi, 0 sabit, 1 yukari
		CarFly = false,
		CarFlyHiz = 100,
		CarFlyShiftLock = true,
		ArabaHizDegeri = 90,
		SpeedAktif = false,
		SpeedDeger = 36,
		JumpAktif = false,
		JumpDeger = 75,
		GravityAktif = false,
		GravityDeger = 196.2,
		BoyutAktif = false,
		BoyutOran = 1.0,
		KafaOran = 1.0,
	},
	Varsayilan = {
		WalkSpeed = 16,
		JumpPower = 50,
		Gravity = Workspace.Gravity,
		HitboxVeri = {} :: { [BasePart]: { Size: Vector3, Transparency: number, CanCollide: boolean, Massless: boolean, Material: Enum.Material } },
	},
	Renkler = {
		ArkaPlan = Color3.fromRGB(16, 18, 25),
		Panel = Color3.fromRGB(23, 26, 36),
		Kart = Color3.fromRGB(30, 34, 47),
		Buton = Color3.fromRGB(39, 44, 60),
		Vurgu = Color3.fromRGB(255, 102, 51),
		VurguIkinci = Color3.fromRGB(56, 189, 248),
		Acik = Color3.fromRGB(46, 204, 113),
		Kapali = Color3.fromRGB(231, 76, 60),
		Yazi = Color3.fromRGB(242, 245, 252),
		AltYazi = Color3.fromRGB(158, 168, 190),
		Cizgi = Color3.fromRGB(58, 66, 90),
	},
	UI = {} :: { [string]: any },
	Sayfalar = {} :: { [string]: ScrollingFrame },
	SekmeButonlari = {} :: { [string]: TextButton },
	GizliOzellikler = {} :: { [string]: boolean },
}

local function BaglantiEkle(conn: RBXScriptConnection): RBXScriptConnection
	table.insert(Sistem.Baglantilar, conn)
	return conn
end

local function KarakterVerisi(): (Model?, Humanoid?, BasePart?)
	local char = LocalPlayer.Character
	if not char then return nil, nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	return char, hum, hrp
end

local function AyniTakimdaMi(model: Model): boolean
	local hedefOyuncu = Players:GetPlayerFromCharacter(model)
	if not hedefOyuncu then return false end
	if LocalPlayer.Team ~= nil and hedefOyuncu.Team ~= nil then
		return LocalPlayer.Team == hedefOyuncu.Team
	end
	return false
end

local function HedefOlmusMu(model: Model): boolean
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return true end
	if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
		return true
	end
	return false
end

local function HedefTuruGecerliMi(model: Model, hedefTuru: string): boolean
	if not model or not model.Parent then return false end
	if model == LocalPlayer.Character then return false end
	if AyniTakimdaMi(model) then return false end
	if HedefOlmusMu(model) then return false end

	local oyuncuMu = Players:GetPlayerFromCharacter(model) ~= nil
	if hedefTuru == "Hepsi" then
		return true
	elseif hedefTuru == "Oyuncu Gercek" then
		return oyuncuMu
	elseif hedefTuru == "Bot" then
		return not oyuncuMu
	end
	return false
end

local function HedefParcasiAl(model: Model, parcaSecimi: string): BasePart?
	if parcaSecimi == "Kafa" then
		local kafa = model:FindFirstChild("Head")
		if kafa and kafa:IsA("BasePart") then
			return kafa
		end
	end
	local govde = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model.PrimaryPart
	if govde and govde:IsA("BasePart") then
		return govde
	end
	return nil
end

local function AciktaGorunuyorMu(hedefKonum: Vector3, hedefModel: Model): boolean
	local baslangic = Camera.CFrame.Position
	local yon = hedefKonum - baslangic
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local haric = {} :: { Instance }
	if LocalPlayer.Character then
		table.insert(haric, LocalPlayer.Character)
	end
	table.insert(haric, hedefModel)
	params.FilterDescendantsInstances = haric

	local sonuc = Workspace:Raycast(baslangic, yon, params)
	return sonuc == nil
end

local function TahminliKonum(parca: BasePart): Vector3
	local poz = parca.Position
	if not Sistem.TahminAktif then
		return poz
	end
	local hiz = parca.AssemblyLinearVelocity
	return poz + (hiz * Sistem.TahminGucu)
end

local function HedefBul(
	hedefTuru: string,
	parcaSecimi: string,
	sadeceAcikta: boolean,
	daireKullan: boolean,
	daireYaricap: number,
	mesafeSiniri: number
): (BasePart?, Model?)
	local _, _, benHRP = KarakterVerisi()
	local benKonum = benHRP and benHRP.Position or Camera.CFrame.Position
	local vp = Camera.ViewportSize
	local merkez = Vector2.new(vp.X * 0.5, vp.Y * 0.5)

	local enIyiParca: BasePart? = nil
	local enIyiModel: Model? = nil
	local enYakinEkranFarki = math.huge

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefTuruGecerliMi(nesne, hedefTuru) then
			local parca = HedefParcasiAl(nesne, parcaSecimi)
			if parca then
				local mesafe = (parca.Position - benKonum).Magnitude
				if mesafe <= mesafeSiniri then
					local hedefNokta = TahminliKonum(parca)
					local ekranPos, gorunur = Camera:WorldToViewportPoint(hedefNokta)
					if gorunur and ekranPos.Z > 0 then
						local ekranFarki = (Vector2.new(ekranPos.X, ekranPos.Y) - merkez).Magnitude
						local daireUygun = (not daireKullan) or (ekranFarki <= daireYaricap)
						if daireUygun then
							if (not sadeceAcikta) or AciktaGorunuyorMu(hedefNokta, nesne) then
								if ekranFarki < enYakinEkranFarki then
									enYakinEkranFarki = ekranFarki
									enIyiParca = parca
									enIyiModel = nesne
								end
							end
						end
					end
				end
			end
		end
	end

	return enIyiParca, enIyiModel
end

local function EnYakinHedefBul(hedefTuru: string): (BasePart?, Model?, number)
	local _, _, benHRP = KarakterVerisi()
	if not benHRP then return nil, nil, math.huge end
	local enIyiParca: BasePart? = nil
	local enIyiModel: Model? = nil
	local enKisa = math.huge

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefTuruGecerliMi(nesne, hedefTuru) then
			local parca = HedefParcasiAl(nesne, "Govde")
			if parca then
				local d = (parca.Position - benHRP.Position).Magnitude
				if d < enKisa then
					enKisa = d
					enIyiParca = parca
					enIyiModel = nesne
				end
			end
		end
	end
	return enIyiParca, enIyiModel, enKisa
end
-- ============================================================================
-- BOLUM 02: AIMBOT (3 TUR + 0-100 KESKINLIK), SILENT AIM, TETIK & HITBOX
-- ============================================================================

local AimbotDaireCizgi = Instance.new("Frame")
AimbotDaireCizgi.Name = "AimbotDaireGostergesi"
AimbotDaireCizgi.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotDaireCizgi.Position = UDim2.new(0.5, 0, 0.5, 0)
AimbotDaireCizgi.Size = UDim2.new(0, Sistem.Aimbot.DaireYaricap * 2, 0, Sistem.Aimbot.DaireYaricap * 2)
AimbotDaireCizgi.BackgroundTransparency = 1
AimbotDaireCizgi.Visible = false
AimbotDaireCizgi.ZIndex = 50

local AimbotDaireKose = Instance.new("UICorner")
AimbotDaireKose.CornerRadius = UDim.new(1, 0)
AimbotDaireKose.Parent = AimbotDaireCizgi

local AimbotDaireKenar = Instance.new("UIStroke")
AimbotDaireKenar.Thickness = 2
AimbotDaireKenar.Color = Sistem.Renkler.VurguIkinci
AimbotDaireKenar.Transparency = 0.15
AimbotDaireKenar.Parent = AimbotDaireCizgi

local AktifAimbotHedefModel: Model? = nil

local function AktifAimbotHedefiSec(): BasePart?
	local cfg = Sistem.Aimbot
	local daireAktif = (cfg.Tur == "Daire")
	local sadeceAcikta = cfg.SadeceAcikta or (cfg.Tur == "Acikta")

	-- Mevcut kilitli hedef hala canli ve gecerliyse once onu kontrol et
	if AktifAimbotHedefModel and HedefTuruGecerliMi(AktifAimbotHedefModel, cfg.HedefTuru) then
		local parca = HedefParcasiAl(AktifAimbotHedefModel, cfg.Parca)
		local _, _, benHRP = KarakterVerisi()
		if parca and benHRP then
			local mesafe = (parca.Position - benHRP.Position).Magnitude
			local nokta = TahminliKonum(parca)
			local ekPos, gor = Camera:WorldToViewportPoint(nokta)
			local merkez = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
			local fark = (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude
			local daireOk = (not daireAktif) or (gor and ekPos.Z > 0 and fark <= cfg.DaireYaricap)
			local acikOk = (not sadeceAcikta) or AciktaGorunuyorMu(nokta, AktifAimbotHedefModel)
			if mesafe <= cfg.MesafeSiniri and daireOk and acikOk then
				return parca
			end
		end
	end

	-- Mevcut hedef oldu veya ciktiysa otomatik en yakin uygun hedefe gec
	local yeniParca, yeniModel = HedefBul(
		cfg.HedefTuru,
		cfg.Parca,
		sadeceAcikta,
		daireAktif,
		cfg.DaireYaricap,
		cfg.MesafeSiniri
	)
	AktifAimbotHedefModel = yeniModel
	return yeniParca
end

local function KeskinlikOraniHesapla(keskinlik0_100: number, dt: number): number
	local k = math.clamp(keskinlik0_100, 0, 100)
	if k >= 99 then
		return 1
	end
	local hiz = 1.5 + ((k / 100) ^ 1.35) * 38
	return math.clamp(1 - math.exp(-hiz * dt), 0.02, 1)
end

local function TetikCalistir(hedefParca: BasePart?)
	if not Sistem.TetikAktif or not hedefParca then return end
	local simdi = os.clock()
	if simdi - Sistem.SonTetikZamani < Sistem.TetikBekleme then return end

	local vp = Camera.ViewportSize
	local merkez = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local ekPos, gor = Camera:WorldToViewportPoint(hedefParca.Position)
	if not gor or ekPos.Z <= 0 then return end

	local esik = Sistem.Aimbot.Tur == "Daire" and Sistem.Aimbot.DaireYaricap or 48
	if (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude <= esik then
		Sistem.SonTetikZamani = simdi
		local char = LocalPlayer.Character
		if char then
			local arac = char:FindFirstChildOfClass("Tool")
			if arac then
				pcall(function()
					arac:Activate()
				end)
			end
		end
	end
end

-- Silent Aim: Kamera/Raycast hedef yönünü en uygun hedefe hizalar
local SilentHedefParca: BasePart? = nil

local function SilentAimGuncelle()
	local s = Sistem.SilentAim
	if not s.Aktif then
		SilentHedefParca = nil
		return
	end
	local parca, _ = HedefBul(
		s.HedefTuru,
		s.Parca,
		s.SadeceAcikta,
		s.DaireKullan,
		s.DaireYaricap,
		s.MesafeSiniri
	)
	SilentHedefParca = parca
end

-- Hitbox Buyutme & Temiz Geri Alma
local function HitboxGeriAl()
	for parca, veri in pairs(Sistem.Varsayilan.HitboxVeri) do
		if parca and parca.Parent then
			parca.Size = veri.Size
			parca.Transparency = veri.Transparency
			parca.CanCollide = veri.CanCollide
			parca.Massless = veri.Massless
			parca.Material = veri.Material
		end
	end
	table.clear(Sistem.Varsayilan.HitboxVeri)
end

local function HitboxUygula()
	local h = Sistem.Hitbox
	if not h.Aktif then
		HitboxGeriAl()
		return
	end

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefTuruGecerliMi(nesne, h.HedefTuru) then
			local parcalar = {} :: { BasePart }
			if h.ParcaModu == "Kafa" or h.ParcaModu == "Ikisi" then
				local kafa = nesne:FindFirstChild("Head")
				if kafa and kafa:IsA("BasePart") then
					table.insert(parcalar, kafa)
				end
			end
			if h.ParcaModu == "Govde" or h.ParcaModu == "Ikisi" then
				local govde = nesne:FindFirstChild("HumanoidRootPart") or nesne:FindFirstChild("Torso") or nesne:FindFirstChild("UpperTorso")
				if govde and govde:IsA("BasePart") then
					table.insert(parcalar, govde)
				end
			end

			for _, p in ipairs(parcalar) do
				if not Sistem.Varsayilan.HitboxVeri[p] then
					Sistem.Varsayilan.HitboxVeri[p] = {
						Size = p.Size,
						Transparency = p.Transparency,
						CanCollide = p.CanCollide,
						Massless = p.Massless,
						Material = p.Material,
					}
				end
				p.Size = Vector3.new(h.Boyut, h.Boyut, h.Boyut)
				p.CanCollide = false
				p.Massless = true
				if h.Gorunur then
					p.Transparency = h.Seffaflik
					p.Material = Enum.Material.ForceField
				else
					p.Transparency = 1
				end
			end
		end
	end
end

-- Mermi / Bicak Firlatici Hiz Carpan (1 - 100)
local function FirlatmaNesnesiHizlandir(nesne: Instance)
	if Sistem.MermiBicakHizCarpan == 50 then return end
	local oran = math.clamp(Sistem.MermiBicakHizCarpan / 50, 0.1, 4.0)
	if nesne:IsA("BasePart") then
		local v = nesne.AssemblyLinearVelocity
		if v.Magnitude > 5 then
			nesne.AssemblyLinearVelocity = v * oran
		end
	elseif nesne:IsA("LinearVelocity") then
		nesne.VectorVelocity = nesne.VectorVelocity * oran
	elseif nesne:IsA("BodyVelocity") then
		nesne.Velocity = nesne.Velocity * oran
	end
end

BaglantiEkle(Workspace.DescendantAdded:Connect(function(nesne)
	if Sistem.MermiBicakHizCarpan ~= 50 and (nesne:IsA("BasePart") or nesne:IsA("LinearVelocity") or nesne:IsA("BodyVelocity")) then
		task.defer(function()
			FirlatmaNesnesiHizlandir(nesne)
		end)
	end
end))
-- ============================================================================
-- BOLUM 03: HAREKET (NORMAL FLY + SHIFTLOCK, CAR FLY, ARABA HIZI), BOYUT & ESP
-- ============================================================================

local normalBV: BodyVelocity? = nil
local normalBG: BodyGyro? = nil
local carBV: BodyVelocity? = nil
local carBG: BodyGyro? = nil

local function AktifAracKoltugu(): VehicleSeat?
	local _, hum, _ = KarakterVerisi()
	if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
		return hum.SeatPart
	end
	return nil
end

local function NormalFlyDurum(aktif: boolean)
	Sistem.Hareket.NormalFly = aktif
	local _, hum, hrp = KarakterVerisi()
	if not hum or not hrp then return end

	if aktif then
		hum.PlatformStand = true
		if not normalBV then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "NormalFlyHiz"
			bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
			bv.Velocity = Vector3.zero
			bv.Parent = hrp
			normalBV = bv
		end
		if not normalBG then
			local bg = Instance.new("BodyGyro")
			bg.Name = "NormalFlyYon"
			bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
			bg.P = 9e4
			bg.CFrame = Camera.CFrame
			bg.Parent = hrp
			normalBG = bg
		end
	else
		hum.PlatformStand = false
		if normalBV then normalBV:Destroy() normalBV = nil end
		if normalBG then normalBG:Destroy() normalBG = nil end
		Sistem.Hareket.DikeyYon = 0
	end
end

local function CarFlyDurum(aktif: boolean)
	Sistem.Hareket.CarFly = aktif
	local koltuk = AktifAracKoltugu()
	if not aktif or not koltuk then
		if carBV then carBV:Destroy() carBV = nil end
		if carBG then carBG:Destroy() carBG = nil end
		return
	end

	if not carBV then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "CarFlyHiz"
		bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
		bv.Velocity = Vector3.zero
		bv.Parent = koltuk
		carBV = bv
	end
	if not carBG then
		local bg = Instance.new("BodyGyro")
		bg.Name = "CarFlyYon"
		bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
		bg.P = 9e4
		bg.CFrame = Camera.CFrame
		bg.Parent = koltuk
		carBG = bg
	end
end

local function SeciliArabaHiziniUygula()
	local koltuk = AktifAracKoltugu()
	if not koltuk then return false end
	local bakis = koltuk.CFrame.LookVector
	local yatay = Vector3.new(bakis.X, 0, bakis.Z)
	if yatay.Magnitude < 0.05 then
		yatay = Camera.CFrame.LookVector
		yatay = Vector3.new(yatay.X, 0, yatay.Z)
	end
	if yatay.Magnitude > 0.01 then
		koltuk.AssemblyLinearVelocity = yatay.Unit * Sistem.Hareket.ArabaHizDegeri + Vector3.new(0, koltuk.AssemblyLinearVelocity.Y, 0)
	end
	return true
end

local function FizikVeBoyutUygula()
	local char, hum, _ = KarakterVerisi()
	if hum then
		hum.WalkSpeed = Sistem.Hareket.SpeedAktif and Sistem.Hareket.SpeedDeger or Sistem.Varsayilan.WalkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = Sistem.Hareket.JumpAktif and Sistem.Hareket.JumpDeger or Sistem.Varsayilan.JumpPower
	end
	Workspace.Gravity = Sistem.Hareket.GravityAktif and Sistem.Hareket.GravityDeger or Sistem.Varsayilan.Gravity

	if char and hum then
		local gOran = Sistem.Hareket.BoyutAktif and Sistem.Hareket.BoyutOran or 1.0
		local kOran = Sistem.Hareket.BoyutAktif and Sistem.Hareket.KafaOran or 1.0
		local r15Var = false
		for _, ad in ipairs({ "BodyWidthScale", "BodyHeightScale", "BodyDepthScale" }) do
			local nv = hum:FindFirstChild(ad)
			if nv and nv:IsA("NumberValue") then
				nv.Value = gOran
				r15Var = true
			end
		end
		local headScale = hum:FindFirstChild("HeadScale")
		if headScale and headScale:IsA("NumberValue") then
			headScale.Value = gOran * kOran
			r15Var = true
		end
		if not r15Var then
			pcall(function()
				char:ScaleTo(gOran)
			end)
		end
	end
end

-- ESP Sistemi (3 Tur + Tum Katmanlar + Patates Mod Uyumlu)
local ESPKayit = {} :: { [Model]: { Billboard: BillboardGui, Etiket: TextLabel, CanBarArka: Frame, CanBarDolgu: Frame, Kutu: Frame, Cizgi: Frame, Vurgu: Highlight } }

local function ESPSil(model: Model)
	local d = ESPKayit[model]
	if not d then return end
	if d.Billboard then d.Billboard:Destroy() end
	if d.Kutu then d.Kutu:Destroy() end
	if d.Cizgi then d.Cizgi:Destroy() end
	if d.Vurgu then d.Vurgu:Destroy() end
	ESPKayit[model] = nil
end

local function ESPTemizle()
	for m, _ in pairs(ESPKayit) do
		ESPSil(m)
	end
end

local function ESPOlustur(model: Model, parca: BasePart)
	if ESPKayit[model] then return end

	local vurgu = Instance.new("Highlight")
	vurgu.Adornee = model
	vurgu.FillTransparency = 0.7
	vurgu.OutlineTransparency = 0.1
	vurgu.Parent = PlayerGui

	local bb = Instance.new("BillboardGui")
	bb.Adornee = parca
	bb.Size = UDim2.new(0, 150, 0, 44)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = PlayerGui

	local etiket = Instance.new("TextLabel")
	etiket.Size = UDim2.new(1, 0, 0, 22)
	etiket.BackgroundTransparency = 1
	etiket.Font = Enum.Font.GothamBold
	etiket.TextSize = 12
	etiket.TextColor3 = Color3.new(1, 1, 1)
	etiket.TextStrokeTransparency = 0.25
	etiket.Parent = bb

	local canArka = Instance.new("Frame")
	canArka.Size = UDim2.new(0.76, 0, 0, 5)
	canArka.Position = UDim2.new(0.12, 0, 0, 26)
	canArka.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	canArka.BorderSizePixel = 0
	canArka.Parent = bb

	local canDolgu = Instance.new("Frame")
	canDolgu.Size = UDim2.new(1, 0, 1, 0)
	canDolgu.BackgroundColor3 = Sistem.Renkler.Acik
	canDolgu.BorderSizePixel = 0
	canDolgu.Parent = canArka

	local kutu = Instance.new("Frame")
	kutu.BackgroundTransparency = 1
	kutu.Visible = false
	kutu.Parent = PlayerGui

	local kutuKenar = Instance.new("UIStroke")
	kutuKenar.Thickness = 1.6
	kutuKenar.Parent = kutu

	local cizgi = Instance.new("Frame")
	cizgi.AnchorPoint = Vector2.new(0.5, 0.5)
	cizgi.BorderSizePixel = 0
	cizgi.Visible = false
	cizgi.Parent = PlayerGui

	ESPKayit[model] = {
		Billboard = bb,
		Etiket = etiket,
		CanBarArka = canArka,
		CanBarDolgu = canDolgu,
		Kutu = kutu,
		Cizgi = cizgi,
		Vurgu = vurgu,
	}
end
-- ============================================================================
-- BOLUM 04: CANLI DONGU (FLY, CAR FLY, AIMBOT, TETIK, SILENT AIM, ESP, OTO TAKIP)
-- ============================================================================

local function HareketVektoruAl(hum: Humanoid?): Vector3
	local yon = Vector3.zero
	if hum and hum.MoveDirection.Magnitude > 0.02 then
		local camLook = Camera.CFrame.LookVector
		local camRight = Camera.CFrame.RightVector
		local ileri = Vector3.new(camLook.X, 0, camLook.Z)
		if ileri.Magnitude > 0.01 then ileri = ileri.Unit else ileri = camLook end
		local sag = Vector3.new(camRight.X, 0, camRight.Z)
		if sag.Magnitude > 0.01 then sag = sag.Unit else sag = camRight end

		-- Joystick ileri/geri ve sag/sol hareketini kamera bakis acisina gore kur
		local moveLocal = hum.MoveDirection
		local sagKatki = moveLocal:Dot(sag)
		local ileriKatki = moveLocal:Dot(ileri)

		if Sistem.Hareket.NormalFly or Sistem.Hareket.CarFly then
			-- Kamera yukari/asagi bakiyorsa ileri gidince yukari/asagi da suzulsun
			yon += (Camera.CFrame.LookVector * ileriKatki) + (sag * sagKatki)
		else
			yon += (ileri * ileriKatki) + (sag * sagKatki)
		end
	end

	if Sistem.Hareket.DikeyYon ~= 0 then
		yon += Vector3.new(0, Sistem.Hareket.DikeyYon, 0)
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		yon += Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		yon -= Vector3.new(0, 1, 0)
	end

	if yon.Magnitude > 1 then
		yon = yon.Unit
	end
	return yon
end

BaglantiEkle(RunService.RenderStepped:Connect(function(dt)
	local char, hum, hrp = KarakterVerisi()
	local espCfg = Sistem.ESP

	-- 1. Normal Fly + ShiftLock/Kamera Hizalama
	if Sistem.Hareket.NormalFly and hum and hrp then
		if not normalBV or not normalBV.Parent then
			NormalFlyDurum(true)
		end
		local yon = HareketVektoruAl(hum)
		if normalBV then
			normalBV.Velocity = yon * Sistem.Hareket.NormalFlyHiz
		end
		if normalBG then
			local bakisYon = Camera.CFrame.LookVector
			if Sistem.Hareket.NormalFlyShiftLock then
				local yatayBak = Vector3.new(bakisYon.X, 0, bakisYon.Z)
				if yatayBak.Magnitude > 0.01 then
					normalBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + yatayBak.Unit)
				end
			else
				normalBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + bakisYon)
			end
		end
	elseif normalBV or normalBG then
		NormalFlyDurum(false)
	end

	-- 2. Car Fly + ShiftLock/Kamera Hizalama
	local koltuk = AktifAracKoltugu()
	if Sistem.Hareket.CarFly and koltuk then
		if not carBV or not carBV.Parent then
			CarFlyDurum(true)
		end
		local yon = HareketVektoruAl(hum)
		if carBV then
			carBV.Velocity = yon * Sistem.Hareket.CarFlyHiz
		end
		if carBG then
			local bakisYon = Camera.CFrame.LookVector
			if Sistem.Hareket.CarFlyShiftLock then
				local yatayBak = Vector3.new(bakisYon.X, 0, bakisYon.Z)
				if yatayBak.Magnitude > 0.01 then
					carBG.CFrame = CFrame.lookAt(koltuk.Position, koltuk.Position + yatayBak.Unit)
				end
			else
				carBG.CFrame = CFrame.lookAt(koltuk.Position, koltuk.Position + bakisYon)
			end
		end
	elseif carBV or carBG then
		CarFlyDurum(false)
	end

	-- 3. Aimbot Daire Gostergesi
	local daireGoster = Sistem.Aimbot.Aktif and Sistem.Aimbot.DaireGoster and (Sistem.Aimbot.Tur == "Daire" or Sistem.SilentAim.DaireKullan)
	AimbotDaireCizgi.Visible = daireGoster
	if daireGoster then
		local r = Sistem.Aimbot.Tur == "Daire" and Sistem.Aimbot.DaireYaricap or Sistem.SilentAim.DaireYaricap
		AimbotDaireCizgi.Size = UDim2.new(0, r * 2, 0, r * 2)
		AimbotDaireKenar.Thickness = Sistem.PatatesMod and 1.2 or 2
	end

	-- 4. Aimbot Kilitlenme (3 Tur + 0-100 Keskinlik + Tetik)
	if Sistem.Aimbot.Aktif then
		local hedefParca = AktifAimbotHedefiSec()
		if hedefParca then
			local hedefNokta = TahminliKonum(hedefParca)
			local istenenBak = CFrame.lookAt(Camera.CFrame.Position, hedefNokta)
			if Sistem.Aimbot.Tur == "Normal" and Sistem.Aimbot.Keskinlik >= 98 then
				Camera.CFrame = istenenBak
			else
				local oran = KeskinlikOraniHesapla(Sistem.Aimbot.Keskinlik, dt)
				Camera.CFrame = Camera.CFrame:Lerp(istenenBak, oran)
			end
			TetikCalistir(hedefParca)
		end
	else
		AktifAimbotHedefModel = nil
	end

	-- 5. Silent Aim Guncelleme
	SilentAimGuncelle()

	-- 6. Oto Takip
	if Sistem.OtoTakipAktif and char and hrp then
		local takipParca: BasePart? = nil
		if Sistem.OtoTakipHedefModu == "EnYakinOyuncu" then
			takipParca = EnYakinHedefBul("Oyuncu Gercek")
		elseif Sistem.OtoTakipHedefModu == "EnYakinBot" then
			takipParca = EnYakinHedefBul("Bot")
		elseif Sistem.OtoTakipHedefModu == "SeciliOyuncu" and Sistem.SeciliOyuncu and Sistem.SeciliOyuncu.Character then
			if not HedefOlmusMu(Sistem.SeciliOyuncu.Character) and not AyniTakimdaMi(Sistem.SeciliOyuncu.Character) then
				takipParca = HedefParcasiAl(Sistem.SeciliOyuncu.Character, "Govde")
			end
		end
		if takipParca then
			local yon = (hrp.Position - takipParca.Position)
			local yatay = Vector3.new(yon.X, 0, yon.Z)
			if yatay.Magnitude < 0.1 then
				yatay = Vector3.new(0, 0, 1)
			end
			local hedefKonum = takipParca.Position + (yatay.Unit * math.max(2, Sistem.OtoTakipMesafe)) + Vector3.new(0, 1.5, 0)
			char:PivotTo(CFrame.lookAt(hedefKonum, takipParca.Position))
		end
	end

	-- 7. ESP Guncelleme
	if not espCfg.Aktif then
		if next(ESPKayit) ~= nil then
			ESPTemizle()
		end
		return
	end

	local benKonum = hrp and hrp.Position or Camera.CFrame.Position
	local gorulen = {} :: { [Model]: boolean }

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefTuruGecerliMi(nesne, espCfg.HedefTuru) then
			local parca = HedefParcasiAl(nesne, "Govde")
			local hum = nesne:FindFirstChildOfClass("Humanoid")
			if parca and hum then
				local mesafe = (parca.Position - benKonum).Magnitude
				if mesafe <= espCfg.MesafeSiniri then
					gorulen[nesne] = true
					if not ESPKayit[nesne] then
						ESPOlustur(nesne, parca)
					end
					local d = ESPKayit[nesne]
					local plr = Players:GetPlayerFromCharacter(nesne)
					local renk = Sistem.Renkler.Vurgu
					if plr then
						renk = (espCfg.TakimRengi and plr.TeamColor and plr.TeamColor.Color) or Sistem.Renkler.VurguIkinci
					else
						renk = Sistem.Renkler.Acik
					end

					local metinParcalari = {} :: { string }
					if espCfg.Isim then
						local etiketTur = plr and "[OYUNCU]" or "[BOT]"
						table.insert(metinParcalari, etiketTur .. " " .. nesne.Name)
					end
					if espCfg.Mesafe then
						table.insert(metinParcalari, string.format("%.0fm", mesafe))
					end
					d.Etiket.Text = table.concat(metinParcalari, " • ")
					d.Etiket.TextColor3 = renk
					d.Billboard.Enabled = espCfg.Isim or espCfg.Mesafe or espCfg.CanBar

					if espCfg.CanBar then
						d.CanBarArka.Visible = true
						local oran = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
						d.CanBarDolgu.Size = UDim2.new(oran, 0, 1, 0)
						d.CanBarDolgu.BackgroundColor3 = Color3.fromRGB(231, 76, 60):Lerp(Color3.fromRGB(46, 204, 113), oran)
					else
						d.CanBarArka.Visible = false
					end

					d.Vurgu.Enabled = espCfg.Vurgu and (not Sistem.PatatesMod)
					d.Vurgu.FillColor = renk

					local ekPos, gor = Camera:WorldToViewportPoint(parca.Position)
					if gor and ekPos.Z > 0 then
						local olcek = 900 / math.max(1, ekPos.Z)
						local w = math.clamp(olcek * 2.1, 22, 260)
						local h = math.clamp(olcek * 3.2, 32, 380)

						d.Kutu.Visible = espCfg.Kutu
						d.Kutu.Position = UDim2.new(0, ekPos.X - w * 0.5, 0, ekPos.Y - h * 0.5)
						d.Kutu.Size = UDim2.new(0, w, 0, h)
						local stroke = d.Kutu:FindFirstChildOfClass("UIStroke")
						if stroke then stroke.Color = renk end

						d.Cizgi.Visible = espCfg.Cizgi and (not Sistem.PatatesMod)
						if d.Cizgi.Visible then
							local altMerkez = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
							local hedef2D = Vector2.new(ekPos.X, ekPos.Y)
							local fark = hedef2D - altMerkez
							d.Cizgi.BackgroundColor3 = renk
							d.Cizgi.Position = UDim2.new(0, (altMerkez.X + hedef2D.X) * 0.5, 0, (altMerkez.Y + hedef2D.Y) * 0.5)
							d.Cizgi.Size = UDim2.new(0, fark.Magnitude, 0, 1.5)
							d.Cizgi.Rotation = math.deg(math.atan2(fark.Y, fark.X))
						end
					else
						d.Kutu.Visible = false
						d.Cizgi.Visible = false
					end
				end
			end
		end
	end

	for m, _ in pairs(ESPKayit) do
		if not gorulen[m] or not m.Parent then
			ESPSil(m)
		end
	end
end))
-- ============================================================================
-- BOLUM 05: TELEPORT (OYUNCU, BOT/NEXTBOT, EN YAKIN) & SILENT AIM RAYCAST KANCASI
-- ============================================================================

local function GecmisKonumKaydet()
	local _, _, hrp = KarakterVerisi()
	if hrp then
		table.insert(Sistem.GecmisKonumlar, hrp.CFrame)
		if #Sistem.GecmisKonumlar > 20 then
			table.remove(Sistem.GecmisKonumlar, 1)
		end
	end
end

local function KonumaIsinlan(hedefCF: CFrame): boolean
	local char, _, hrp = KarakterVerisi()
	if not char or not hrp then return false end
	GecmisKonumKaydet()
	char:PivotTo(hedefCF)
	return true
end

local function OyuncuyaIsinlan(oyuncu: Player?): boolean
	if not oyuncu or oyuncu == LocalPlayer or not oyuncu.Character then return false end
	if HedefOlmusMu(oyuncu.Character) then return false end
	local hrp = oyuncu.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return false end
	return KonumaIsinlan(hrp.CFrame * CFrame.new(0, 0, 4))
end

local function EnYakinOyuncuyaIsinlan(): boolean
	local _, _, benHRP = KarakterVerisi()
	if not benHRP then return false end
	local enYakinHRP: BasePart? = nil
	local enKisa = math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			if not AyniTakimdaMi(plr.Character) and not HedefOlmusMu(plr.Character) then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hrp then
					local d = (hrp.Position - benHRP.Position).Magnitude
					if d < enKisa then
						enKisa = d
						enYakinHRP = hrp
					end
				end
			end
		end
	end

	if enYakinHRP then
		return KonumaIsinlan(enYakinHRP.CFrame * CFrame.new(0, 0, 4))
	end
	return false
end

local function EnYakinBotNextbotaIsinlan(): boolean
	local _, _, benHRP = KarakterVerisi()
	if not benHRP then return false end
	local enYakinParca: BasePart? = nil
	local enKisa = math.huge

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and nesne ~= LocalPlayer.Character then
			if Players:GetPlayerFromCharacter(nesne) == nil then
				local hum = nesne:FindFirstChildOfClass("Humanoid")
				local hrp = (nesne:FindFirstChild("HumanoidRootPart") or nesne:FindFirstChild("Torso") or nesne:FindFirstChild("UpperTorso") or nesne.PrimaryPart) :: BasePart?
				local nextbotMu = (hum ~= nil and hum.Health > 0) or nesne.Name:lower():find("bot") ~= nil or nesne.Name:lower():find("npc") ~= nil or nesne.Name:lower():find("nextbot") ~= nil
				if hrp and nextbotMu then
					local d = (hrp.Position - benHRP.Position).Magnitude
					if d < enKisa then
						enKisa = d
						enYakinParca = hrp
					end
				end
			end
		end
	end

	if enYakinParca then
		return KonumaIsinlan(enYakinParca.CFrame * CFrame.new(0, 0, 4))
	end
	return false
end

local function OncekiKonumaDon(): boolean
	if #Sistem.GecmisKonumlar == 0 then return false end
	local onceki = table.remove(Sistem.GecmisKonumlar)
	local char = LocalPlayer.Character
	if onceki and char then
		char:PivotTo(onceki)
		return true
	end
	return false
end

-- Silent Aim icin kamera yonunu hedefe cevirme yardimcisi (atış sirasinda tetiklenebilir)
local function SilentAimNoktaAl(): Vector3?
	if not Sistem.SilentAim.Aktif then return nil end
	if not SilentHedefParca or not SilentHedefParca.Parent then
		SilentAimGuncelle()
	end
	if SilentHedefParca and SilentHedefParca.Parent then
		local model = SilentHedefParca:FindFirstAncestorOfClass("Model")
		if model and HedefTuruGecerliMi(model, Sistem.SilentAim.HedefTuru) then
			return TahminliKonum(SilentHedefParca)
		end
	end
	return nil
end

-- Dokunmatik / Fare ile atis aninda Silent Aim aktifse kamerayi anlik hedef noktasina hizala
BaglantiEkle(UserInputService.InputBegan:Connect(function(input, isProcessed)
	if isProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if Sistem.SilentAim.Aktif then
			local nokta = SilentAimNoktaAl()
			if nokta then
				Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nokta)
			end
		end
	end
end))
-- ============================================================================
-- BOLUM 06: MOBIL ARAYUZ (DESENLI/PATATES MOD, UST TAVAN, TEK BUTON, OZEL TUSLAR)
-- ============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobilSistem_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
Sistem.UI.ScreenGui = ScreenGui

AimbotDaireCizgi.Parent = ScreenGui

-- Ekranda ozellik yanindan acilan ozel hizli tuslarin kapsayicisi
local OzelTusKapsayici = Instance.new("Frame")
OzelTusKapsayici.Name = "OzelHizliTusKapsayici"
OzelTusKapsayici.Size = UDim2.new(0, 140, 0, 260)
OzelTusKapsayici.Position = UDim2.new(1, -152, 0.25, 0)
OzelTusKapsayici.BackgroundTransparency = 1
OzelTusKapsayici.ZIndex = 65
OzelTusKapsayici.Parent = ScreenGui

local OzelTusListe = Instance.new("UIListLayout")
OzelTusListe.Padding = UDim.new(0, 6)
OzelTusListe.HorizontalAlignment = Enum.HorizontalAlignment.Right
OzelTusListe.Parent = OzelTusKapsayici

local function OzelTusDurumGuncelle(anahtar: string, durum: boolean)
	Sistem.OzelTusDurumlari[anahtar] = durum
	local btn = Sistem.OzelTusButonlari[anahtar]
	if btn then
		btn.BackgroundColor3 = durum and Sistem.Renkler.Acik or Sistem.Renkler.Kart
		btn.TextColor3 = durum and Color3.fromRGB(12, 14, 20) or Sistem.Renkler.Yazi
	end
end

local function OzelEkranTusuEkle(anahtar: string, kisaAd: string, ilkDurum: boolean, degistirFn: (boolean) -> ())
	Sistem.OzelTusKayitlari[anahtar] = function()
		local yeni = not (Sistem.OzelTusDurumlari[anahtar] or false)
		OzelTusDurumGuncelle(anahtar, yeni)
		degistirFn(yeni)
	end

	if Sistem.OzelTusButonlari[anahtar] then
		OzelTusDurumGuncelle(anahtar, ilkDurum)
		return
	end

	local btn = Instance.new("TextButton")
	btn.Name = "OzelTus_" .. anahtar
	btn.Size = UDim2.new(0, 128, 0, 32)
	btn.BackgroundColor3 = ilkDurum and Sistem.Renkler.Acik or Sistem.Renkler.Kart
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = ilkDurum and Color3.fromRGB(12, 14, 20) or Sistem.Renkler.Yazi
	btn.Text = kisaAd
	btn.AutoButtonColor = false
	btn.ZIndex = 66
	btn.Parent = OzelTusKapsayici

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Thickness = 1.2
	s.Color = Sistem.Renkler.Vurgu
	s.Parent = btn

	Sistem.OzelTusButonlari[anahtar] = btn
	Sistem.OzelTusDurumlari[anahtar] = ilkDurum

	btn.MouseButton1Click:Connect(function()
		local fn = Sistem.OzelTusKayitlari[anahtar]
		if fn then fn() end
	end)
end

-- Ana Panel (Mobil odakli, desenli/saglam gorunum, animasyonsuz anlik tepki)
local AnaPanel = Instance.new("Frame")
AnaPanel.Name = "AnaPanel"
AnaPanel.Size = UDim2.new(0, 560, 0, 330)
AnaPanel.Position = UDim2.new(0.5, -280, 0.5, -165)
AnaPanel.BackgroundColor3 = Sistem.Renkler.ArkaPlan
AnaPanel.BorderSizePixel = 0
AnaPanel.ClipsDescendants = true
AnaPanel.ZIndex = 20
AnaPanel.Parent = ScreenGui
Sistem.UI.AnaPanel = AnaPanel

local AnaKose = Instance.new("UICorner")
AnaKose.CornerRadius = UDim.new(0, 12)
AnaKose.Parent = AnaPanel

local AnaKenar = Instance.new("UIStroke")
AnaKenar.Thickness = 1.6
AnaKenar.Color = Sistem.Renkler.Vurgu
AnaKenar.Parent = AnaPanel

-- Desenli arka plan katmani (Patates Mod acilinca kapanir, kapatilinca geri gelir)
local DesenKatmani = Instance.new("Frame")
DesenKatmani.Name = "DesenKatmani"
DesenKatmani.Size = UDim2.new(1, 0, 1, 0)
DesenKatmani.BackgroundColor3 = Sistem.Renkler.ArkaPlan
DesenKatmani.BorderSizePixel = 0
DesenKatmani.ZIndex = 21
DesenKatmani.Parent = AnaPanel

local DesenGradyan = Instance.new("UIGradient")
DesenGradyan.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(215, 224, 245)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 195, 165)),
})
DesenGradyan.Rotation = 35
DesenGradyan.Parent = DesenKatmani

-- Izgara/desen cizgileri
for i = 1, 8 do
	local dikey = Instance.new("Frame")
	dikey.Size = UDim2.new(0, 1, 1, 0)
	dikey.Position = UDim2.new(i / 9, 0, 0, 0)
	dikey.BackgroundColor3 = Sistem.Renkler.VurguIkinci
	dikey.BackgroundTransparency = 0.88
	dikey.BorderSizePixel = 0
	dikey.ZIndex = 21
	dikey.Parent = DesenKatmani
end

local UstBar = Instance.new("Frame")
UstBar.Name = "UstBar"
UstBar.Size = UDim2.new(1, 0, 0, 38)
UstBar.BackgroundColor3 = Sistem.Renkler.Panel
UstBar.BorderSizePixel = 0
UstBar.ZIndex = 25
UstBar.Parent = AnaPanel

local BaslikYazi = Instance.new("TextLabel")
BaslikYazi.Size = UDim2.new(1, -110, 1, 0)
BaslikYazi.Position = UDim2.new(0, 12, 0, 0)
BaslikYazi.BackgroundTransparency = 1
BaslikYazi.Font = Enum.Font.GothamBold
BaslikYazi.TextSize = 13
BaslikYazi.TextColor3 = Sistem.Renkler.Yazi
BaslikYazi.TextXAlignment = Enum.TextXAlignment.Left
BaslikYazi.Text = "MOBIL KONTROL • HEDEFLER & HAREKET"
BaslikYazi.ZIndex = 26
BaslikYazi.Parent = UstBar

local KucultBtn = Instance.new("TextButton")
KucultBtn.Size = UDim2.new(0, 30, 0, 26)
KucultBtn.Position = UDim2.new(1, -72, 0.5, -13)
KucultBtn.BackgroundColor3 = Sistem.Renkler.Buton
KucultBtn.Font = Enum.Font.GothamBold
KucultBtn.TextSize = 14
KucultBtn.TextColor3 = Sistem.Renkler.Yazi
KucultBtn.Text = "-"
KucultBtn.ZIndex = 26
KucultBtn.Parent = UstBar

local KapatBtn = Instance.new("TextButton")
KapatBtn.Size = UDim2.new(0, 30, 0, 26)
KapatBtn.Position = UDim2.new(1, -36, 0.5, -13)
KapatBtn.BackgroundColor3 = Sistem.Renkler.Kapali
KapatBtn.Font = Enum.Font.GothamBold
KucultBtn.TextSize = 12
KapatBtn.TextColor3 = Color3.new(1, 1, 1)
KapatBtn.Text = "X"
KapatBtn.ZIndex = 26
KapatBtn.Parent = UstBar

-- Ust Tavan Modu (Ekranin en ustunde tavan gibi, sadece saga-sola suruklenir)
local UstTavanBar = Instance.new("Frame")
UstTavanBar.Name = "UstTavanBar"
UstTavanBar.Size = UDim2.new(0, 240, 0, 30)
UstTavanBar.Position = UDim2.new(0.5, -120, 0, 0)
UstTavanBar.BackgroundColor3 = Sistem.Renkler.Panel
UstTavanBar.BorderSizePixel = 0
UstTavanBar.Visible = false
UstTavanBar.ZIndex = 75
UstTavanBar.Parent = ScreenGui

local UstTavanKenar = Instance.new("UIStroke")
UstTavanKenar.Thickness = 1.5
UstTavanKenar.Color = Sistem.Renkler.Vurgu
UstTavanKenar.Parent = UstTavanBar

local UstTavanAcBtn = Instance.new("TextButton")
UstTavanAcBtn.Size = UDim2.new(1, -12, 1, 0)
UstTavanAcBtn.Position = UDim2.new(0, 6, 0, 0)
UstTavanAcBtn.BackgroundTransparency = 1
UstTavanAcBtn.Font = Enum.Font.GothamBold
UstTavanAcBtn.TextSize = 11
UstTavanAcBtn.TextColor3 = Sistem.Renkler.Yazi
UstTavanAcBtn.Text = "TAVAN PANEL • AC / KAPAT"
UstTavanAcBtn.ZIndex = 76
UstTavanAcBtn.Parent = UstTavanBar

-- Tek Buton Modu (Sag, sol, yukari, asagi her yere suruklenir, boyut ayarlanir)
local TekButon = Instance.new("TextButton")
TekButon.Name = "TekButonAcici"
TekButon.Size = UDim2.new(0, 56, 0, 56)
TekButon.Position = UDim2.new(0.05, 0, 0.25, 0)
TekButon.BackgroundColor3 = Sistem.Renkler.Vurgu
TekButon.Font = Enum.Font.GothamBold
TekButon.TextSize = 12
TekButon.TextColor3 = Color3.new(1, 1, 1)
TekButon.Text = "AC"
TekButon.Visible = false
TekButon.ZIndex = 80
TekButon.Parent = ScreenGui

local TekButonKose = Instance.new("UICorner")
TekButonKose.CornerRadius = UDim.new(1, 0)
TekButonKose.Parent = TekButon

local TekButonKenar = Instance.new("UIStroke")
TekButonKenar.Thickness = 2
TekButonKenar.Color = Color3.new(1, 1, 1)
TekButonKenar.Parent = TekButon

-- Sol Sekme Sutunu ve Sag Icerik Alani
local SolSutun = Instance.new("ScrollingFrame")
SolSutun.Name = "SolSekmeler"
SolSutun.Size = UDim2.new(0, 126, 1, -38)
SolSutun.Position = UDim2.new(0, 0, 0, 38)
SolSutun.BackgroundColor3 = Sistem.Renkler.Panel
SolSutun.BorderSizePixel = 0
SolSutun.ScrollBarThickness = 3
SolSutun.AutomaticCanvasSize = Enum.AutomaticSize.Y
SolSutun.CanvasSize = UDim2.new(0, 0, 0, 0)
SolSutun.ZIndex = 23
SolSutun.Parent = AnaPanel

local SolListe = Instance.new("UIListLayout")
SolListe.Padding = UDim.new(0, 5)
SolListe.Parent = SolSutun

local SolBosluk = Instance.new("UIPadding")
SolBosluk.PaddingTop = UDim.new(0, 6)
SolBosluk.PaddingLeft = UDim.new(0, 6)
SolBosluk.PaddingRight = UDim.new(0, 6)
SolBosluk.PaddingBottom = UDim.new(0, 8)
SolBosluk.Parent = SolSutun

local IcerikAlani = Instance.new("Frame")
IcerikAlani.Name = "IcerikAlani"
IcerikAlani.Size = UDim2.new(1, -126, 1, -38)
IcerikAlani.Position = UDim2.new(0, 126, 0, 38)
IcerikAlani.BackgroundTransparency = 1
IcerikAlani.ClipsDescendants = true
IcerikAlani.ZIndex = 23
IcerikAlani.Parent = AnaPanel
-- ============================================================================
-- BOLUM 07: PATATES MOD, GORUNUM MODLARI, SURUKLEME & KONTROL URETICILERI
-- ============================================================================

local KayitliTema = {
	ArkaPlan = Sistem.Renkler.ArkaPlan,
	Panel = Sistem.Renkler.Panel,
	Kart = Sistem.Renkler.Kart,
	Buton = Sistem.Renkler.Buton,
	Vurgu = Sistem.Renkler.Vurgu,
}

local function GorunumModuUygula(mod: "TamPanel" | "UstTavan" | "TekButon")
	Sistem.GorunumModu = mod
	local vp = Camera.ViewportSize

	if mod == "TamPanel" then
		UstTavanBar.Visible = false
		TekButon.Visible = false
		AnaPanel.Visible = Sistem.Acik
		local w = math.clamp(vp.X - 24, 340, 620)
		local h = math.clamp(vp.Y - 48, 220, 360)
		AnaPanel.Size = UDim2.new(0, w, 0, Sistem.SimgeMod and 38 or h)
		AnaPanel.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
	elseif mod == "UstTavan" then
		TekButon.Visible = false
		UstTavanBar.Visible = true
		AnaPanel.Visible = Sistem.Acik
		local w = math.clamp(vp.X - 16, 340, 640)
		local tavanAlt = UstTavanBar.Position.Y.Offset + UstTavanBar.Size.Y.Offset + 6
		local h = math.clamp(vp.Y - tavanAlt - 12, 200, 340)
		AnaPanel.Size = UDim2.new(0, w, 0, Sistem.SimgeMod and 38 or h)
		AnaPanel.Position = UDim2.new(0.5, -w * 0.5, 0, tavanAlt)
	elseif mod == "TekButon" then
		UstTavanBar.Visible = false
		TekButon.Visible = true
		AnaPanel.Visible = false
		Sistem.Acik = false
	end
end

local function PatatesModUygula(aktif: boolean)
	Sistem.PatatesMod = aktif
	DesenKatmani.Visible = not aktif
	DesenGradyan.Enabled = not aktif

	if aktif then
		Sistem.Renkler.ArkaPlan = Color3.fromRGB(28, 28, 28)
		Sistem.Renkler.Panel = Color3.fromRGB(36, 36, 36)
		Sistem.Renkler.Kart = Color3.fromRGB(45, 45, 45)
		Sistem.Renkler.Buton = Color3.fromRGB(56, 56, 56)
		Sistem.Renkler.Vurgu = Color3.fromRGB(160, 160, 160)
		AnaKenar.Thickness = 1
	else
		Sistem.Renkler.ArkaPlan = KayitliTema.ArkaPlan
		Sistem.Renkler.Panel = KayitliTema.Panel
		Sistem.Renkler.Kart = KayitliTema.Kart
		Sistem.Renkler.Buton = KayitliTema.Buton
		Sistem.Renkler.Vurgu = KayitliTema.Vurgu
		AnaKenar.Thickness = 1.6
	end

	AnaPanel.BackgroundColor3 = Sistem.Renkler.ArkaPlan
	DesenKatmani.BackgroundColor3 = Sistem.Renkler.ArkaPlan
	UstBar.BackgroundColor3 = Sistem.Renkler.Panel
	SolSutun.BackgroundColor3 = Sistem.Renkler.Panel
	UstTavanBar.BackgroundColor3 = Sistem.Renkler.Panel
	AnaKenar.Color = Sistem.Renkler.Vurgu
	UstTavanKenar.Color = Sistem.Renkler.Vurgu
	TekButon.BackgroundColor3 = Sistem.Renkler.Vurgu
end

KucultBtn.MouseButton1Click:Connect(function()
	Sistem.SimgeMod = not Sistem.SimgeMod
	KucultBtn.Text = Sistem.SimgeMod and "+" or "-"
	GorunumModuUygula(Sistem.GorunumModu)
end)

KapatBtn.MouseButton1Click:Connect(function()
	Sistem.Acik = false
	AnaPanel.Visible = false
	if Sistem.GorunumModu == "TamPanel" then
		TekButon.Visible = true
	end
end)

UstTavanAcBtn.MouseButton1Click:Connect(function()
	Sistem.Acik = not Sistem.Acik
	AnaPanel.Visible = Sistem.Acik
end)

TekButon.MouseButton1Click:Connect(function()
	if Sistem.GorunumModu == "TekButon" then
		Sistem.Acik = not Sistem.Acik
		AnaPanel.Visible = Sistem.Acik
		if Sistem.Acik then
			local vp = Camera.ViewportSize
			local w = math.clamp(vp.X - 24, 340, 620)
			local h = math.clamp(vp.Y - 48, 220, 350)
			AnaPanel.Size = UDim2.new(0, w, 0, h)
			AnaPanel.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
		end
	else
		Sistem.Acik = true
		GorunumModuUygula("TamPanel")
	end
end)

-- Ust Tavan: Sadece saga-sola (X ekseni) surukleme
do
	local surukleniyor = false
	local baslangicX = 0
	local baslangicKonumX = 0

	UstTavanAcBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			surukleniyor = true
			baslangicX = input.Position.X
			baslangicKonumX = UstTavanBar.Position.X.Offset
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					surukleniyor = false
				end
			end)
		end
	end)

	BaglantiEkle(UserInputService.InputChanged:Connect(function(input)
		if surukleniyor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local deltaX = input.Position.X - baslangicX
			local maxX = math.max(0, Camera.ViewportSize.X - UstTavanBar.Size.X.Offset)
			local yeniX = math.clamp(baslangicKonumX + deltaX, 0, maxX)
			UstTavanBar.Position = UDim2.new(0, yeniX, 0, UstTavanBar.Position.Y.Offset)
		end
	end))
end

-- Tek Buton: Sag, sol, yukari, asagi her yere surukleme
do
	local surukleniyor = false
	local tasindi = false
	local baslangic = Vector2.zero
	local baslangicPos = UDim2.new()

	TekButon.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			surukleniyor = true
			tasindi = false
			baslangic = Vector2.new(input.Position.X, input.Position.Y)
			baslangicPos = TekButon.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					surukleniyor = false
				end
			end)
		end
	end)

	BaglantiEkle(UserInputService.InputChanged:Connect(function(input)
		if surukleniyor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local fark = Vector2.new(input.Position.X, input.Position.Y) - baslangic
			if fark.Magnitude > 6 then
				tasindi = true
			end
			local vp = Camera.ViewportSize
			local sz = TekButon.Size.X.Offset
			local x = math.clamp(baslangicPos.X.Offset + fark.X, 0, math.max(0, vp.X - sz))
			local y = math.clamp(baslangicPos.Y.Offset + fark.Y, 0, math.max(0, vp.Y - sz))
			TekButon.Position = UDim2.new(0, x, 0, y)
		end
	end))
end

-- Kontrol Ureticileri (Ac/Kapat + Opsiyonel Ozel Ekran Tusu, Kaydirici, Secici, Buton)
local UIYap = {}

function UIYap.SekmeEkle(ad: string, baslik: string): ScrollingFrame
	local btn = Instance.new("TextButton")
	btn.Name = "Sekme_" .. ad
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Sistem.Renkler.Kart
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Sistem.Renkler.AltYazi
	btn.Text = baslik
	btn.Parent = SolSutun

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn

	local sayfa = Instance.new("ScrollingFrame")
	sayfa.Name = "Sayfa_" .. ad
	sayfa.Size = UDim2.new(1, 0, 1, 0)
	sayfa.BackgroundTransparency = 1
	sayfa.ScrollBarThickness = 3
	sayfa.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sayfa.CanvasSize = UDim2.new(0, 0, 0, 0)
	sayfa.Visible = false
	sayfa.Parent = IcerikAlani

	local liste = Instance.new("UIListLayout")
	liste.Padding = UDim.new(0, 6)
	liste.Parent = sayfa

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = sayfa

	btn.MouseButton1Click:Connect(function()
		Sistem.AktifSekme = ad
		BaslikYazi.Text = "MOBIL KONTROL • " .. baslik:upper()
		for k, s in pairs(Sistem.Sayfalar) do
			s.Visible = (k == ad)
		end
		for k, b in pairs(Sistem.SekmeButonlari) do
			local aktif = (k == ad)
			b.BackgroundColor3 = aktif and Sistem.Renkler.Vurgu or Sistem.Renkler.Kart
			b.TextColor3 = aktif and Color3.new(1, 1, 1) or Sistem.Renkler.AltYazi
		end
	end)

	Sistem.Sayfalar[ad] = sayfa
	Sistem.SekmeButonlari[ad] = btn
	return sayfa
end

function UIYap.AcKapat(
	ebeveyn: Instance,
	etiket: string,
	varsayilan: boolean,
	ozelAnahtar: string?,
	ozelKisaAd: string?,
	callback: (boolean) -> ()
): { Ayarla: (boolean, boolean?) -> () }
	local durum = varsayilan
	local satir = Instance.new("Frame")
	satir.Size = UDim2.new(1, 0, 0, 36)
	satir.BackgroundColor3 = Sistem.Renkler.Kart
	satir.Parent = ebeveyn

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = satir

	local yazi = Instance.new("TextLabel")
	yazi.Size = UDim2.new(1, ozelAnahtar and -125 or -70, 1, 0)
	yazi.Position = UDim2.new(0, 10, 0, 0)
	yazi.BackgroundTransparency = 1
	yazi.Font = Enum.Font.GothamMedium
	yazi.TextSize = 12
	yazi.TextColor3 = Sistem.Renkler.Yazi
	yazi.TextXAlignment = Enum.TextXAlignment.Left
	yazi.Text = etiket
	yazi.Parent = satir

	local durumBtn = Instance.new("TextButton")
	durumBtn.Size = UDim2.new(0, 54, 0, 26)
	durumBtn.Position = UDim2.new(1, -60, 0.5, -13)
	durumBtn.Font = Enum.Font.GothamBold
	durumBtn.TextSize = 11
	durumBtn.TextColor3 = Color3.new(1, 1, 1)
	durumBtn.Parent = satir

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(0, 6)
	dc.Parent = durumBtn

	local function Ayarla(yeni: boolean, sessiz: boolean?)
		durum = yeni
		durumBtn.BackgroundColor3 = durum and Sistem.Renkler.Acik or Sistem.Renkler.Kapali
		durumBtn.Text = durum and "ACIK" or "KAPALI"
		if ozelAnahtar then
			OzelTusDurumGuncelle(ozelAnahtar, durum)
		end
		if not sessiz then
			callback(durum)
		end
	end

	if ozelAnahtar and ozelKisaAd then
		local ekBtn = Instance.new("TextButton")
		ekBtn.Size = UDim2.new(0, 56, 0, 26)
		ekBtn.Position = UDim2.new(1, -120, 0.5, -13)
		ekBtn.BackgroundColor3 = Sistem.Renkler.Buton
		ekBtn.Font = Enum.Font.GothamBold
		ekBtn.TextSize = 10
		ekBtn.TextColor3 = Sistem.Renkler.VurguIkinci
		ekBtn.Text = "+ TUS"
		ekBtn.Parent = satir

		local ec = Instance.new("UICorner")
		ec.CornerRadius = UDim.new(0, 6)
		ec.Parent = ekBtn

		ekBtn.MouseButton1Click:Connect(function()
			local mevcut = Sistem.OzelTusButonlari[ozelAnahtar]
			if mevcut then
				mevcut.Visible = not mevcut.Visible
				ekBtn.Text = mevcut.Visible and "- TUS" or "+ TUS"
			else
				OzelEkranTusuEkle(ozelAnahtar, ozelKisaAd, durum, function(y)
					Ayarla(y, false)
				end)
				ekBtn.Text = "- TUS"
			end
		end)
	end

	durumBtn.MouseButton1Click:Connect(function()
		Ayarla(not durum, false)
	end)

	Ayarla(varsayilan, true)
	return { Ayarla = Ayarla }
end

function UIYap.Kaydirici(ebeveyn: Instance, etiket: string, minV: number, maxV: number, varsayilan: number, callback: (number) -> ())
	local deger = varsayilan
	local kutu = Instance.new("Frame")
	kutu.Size = UDim2.new(1, 0, 0, 44)
	kutu.BackgroundColor3 = Sistem.Renkler.Kart
	kutu.Parent = ebeveyn

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = kutu

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, 3)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Sistem.Renkler.Yazi
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = etiket .. ": " .. tostring(deger)
	lbl.Parent = kutu

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -16, 0, 10)
	bar.Position = UDim2.new(0, 8, 0, 26)
	bar.BackgroundColor3 = Sistem.Renkler.ArkaPlan
	bar.Text = ""
	bar.Parent = kutu

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = bar

	local dolgu = Instance.new("Frame")
	dolgu.Size = UDim2.new(math.clamp((deger - minV) / math.max(0.001, maxV - minV), 0, 1), 0, 1, 0)
	dolgu.BackgroundColor3 = Sistem.Renkler.Vurgu
	dolgu.BorderSizePixel = 0
	dolgu.Parent = bar

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = dolgu

	local suruk = false
	local function Guncelle(xPos: number)
		local oran = math.clamp((xPos - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
		deger = math.floor((minV + (maxV - minV) * oran) + 0.5)
		dolgu.Size = UDim2.new(oran, 0, 1, 0)
		lbl.Text = etiket .. ": " .. tostring(deger)
		callback(deger)
	end

	bar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = true
			Guncelle(inp.Position.X)
		end
	end)

	BaglantiEkle(UserInputService.InputChanged:Connect(function(inp)
		if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			Guncelle(inp.Position.X)
		end
	end))

	BaglantiEkle(UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = false
		end
	end))
end

function UIYap.Secici(ebeveyn: Instance, etiket: string, secenekler: { string }, varsayilan: string, callback: (string) -> ())
	local index = 1
	for i, s in ipairs(secenekler) do
		if s == varsayilan then index = i break end
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = Sistem.Renkler.Buton
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Sistem.Renkler.Yazi
	btn.Text = etiket .. ": " .. secenekler[index]
	btn.Parent = ebeveyn

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		index = (index % #secenekler) + 1
		local secilen = secenekler[index]
		btn.Text = etiket .. ": " .. secilen
		callback(secilen)
	end)
end

function UIYap.Buton(ebeveyn: Instance, etiket: string, vurgulu: boolean, callback: () -> ())
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = vurgulu and Sistem.Renkler.Vurgu or Sistem.Renkler.Buton
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = etiket
	btn.Parent = ebeveyn

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn

	btn.MouseButton1Click:Connect(callback)
end
-- ============================================================================
-- BOLUM 08: SAYFALAR (NISAN/SILENT/HITBOX, HAREKET/ARABA, ESP, TELEPORT, DUZEN)
-- ============================================================================

-- 1. NISAN & VURUS SAYFASI
do
	local s = UIYap.SekmeEkle("Nisan", "Nisan & Vurus")

	UIYap.AcKapat(s, "Aimbot", false, "AimbotTus", "AIMBOT", function(v)
		Sistem.Aimbot.Aktif = v
	end)

	UIYap.Secici(s, "Aimbot Turu", { "Normal", "Daire", "Acikta" }, "Normal", function(t)
		Sistem.Aimbot.Tur = t :: "Normal" | "Daire" | "Acikta"
		if t == "Acikta" then
			Sistem.Aimbot.SadeceAcikta = true
		end
	end)

	UIYap.Secici(s, "Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, "Hepsi", function(h)
		Sistem.Aimbot.HedefTuru = h :: "Hepsi" | "Bot" | "Oyuncu Gercek"
	end)

	UIYap.Secici(s, "Kilit Parca", { "Kafa", "Govde" }, "Kafa", function(p)
		Sistem.Aimbot.Parca = p :: "Kafa" | "Govde"
	end)

	UIYap.AcKapat(s, "Sadece Acikta (Duvar Yok)", false, nil, nil, function(v)
		Sistem.Aimbot.SadeceAcikta = v
	end)

	UIYap.AcKapat(s, "Aimbot Dairesi Goster", true, nil, nil, function(v)
		Sistem.Aimbot.DaireGoster = v
	end)

	UIYap.Kaydirici(s, "Aimbot Daire Boyutu", 40, 320, 140, function(v)
		Sistem.Aimbot.DaireYaricap = v
	end)

	UIYap.Kaydirici(s, "Kilitlenme Uzakligi", 50, 1200, 450, function(v)
		Sistem.Aimbot.MesafeSiniri = v
	end)

	UIYap.Kaydirici(s, "Keskinlik / Yumusaklik (0-100)", 0, 100, 55, function(v)
		Sistem.Aimbot.Keskinlik = v
	end)

	UIYap.AcKapat(s, "Hareketli Hedef Tahmini", false, "TahminTus", "TAHMIN", function(v)
		Sistem.TahminAktif = v
	end)

	UIYap.AcKapat(s, "Tetik (Otomatik Vurus)", false, "TetikTus", "TETIK", function(v)
		Sistem.TetikAktif = v
	end)

	UIYap.AcKapat(s, "Silent Aim", false, "SilentTus", "SILENT", function(v)
		Sistem.SilentAim.Aktif = v
		SilentAimGuncelle()
	end)

	UIYap.Secici(s, "Silent Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, "Hepsi", function(h)
		Sistem.SilentAim.HedefTuru = h :: "Hepsi" | "Bot" | "Oyuncu Gercek"
	end)

	UIYap.Secici(s, "Silent Parca", { "Kafa", "Govde" }, "Kafa", function(p)
		Sistem.SilentAim.Parca = p :: "Kafa" | "Govde"
	end)

	UIYap.AcKapat(s, "Hitbox Buyutme", false, "HitboxTus", "HITBOX", function(v)
		Sistem.Hitbox.Aktif = v
		HitboxUygula()
	end)

	UIYap.Secici(s, "Hitbox Hedef Turu", { "Bot", "Hepsi", "Oyuncu Gercek" }, "Bot", function(h)
		Sistem.Hitbox.HedefTuru = h :: "Hepsi" | "Bot" | "Oyuncu Gercek"
		if Sistem.Hitbox.Aktif then HitboxUygula() end
	end)

	UIYap.Secici(s, "Hitbox Parca", { "Govde", "Kafa", "Ikisi" }, "Govde", function(p)
		Sistem.Hitbox.ParcaModu = p :: "Govde" | "Kafa" | "Ikisi"
		if Sistem.Hitbox.Aktif then HitboxUygula() end
	end)

	UIYap.Kaydirici(s, "Hitbox Boyutu", 2, 25, 7, function(v)
		Sistem.Hitbox.Boyut = v
		if Sistem.Hitbox.Aktif then HitboxUygula() end
	end)

	UIYap.Kaydirici(s, "Mermi / Bicak Hizi (1-100)", 1, 100, 50, function(v)
		Sistem.MermiBicakHizCarpan = v
	end)

	UIYap.Kaydirici(s, "Firlatma Hizi (1-100)", 1, 100, 50, function(v)
		Sistem.FirlatmaHizi = v
	end)
end

-- 2. HAREKET & ARABA SAYFASI
do
	local s = UIYap.SekmeEkle("Hareket", "Hareket & Araba")

	UIYap.AcKapat(s, "Normal Fly (ShiftLock + Kamera)", false, "FlyTus", "FLY", function(v)
		NormalFlyDurum(v)
	end)

	UIYap.Kaydirici(s, "Normal Fly Hizi", 15, 250, 70, function(v)
		Sistem.Hareket.NormalFlyHiz = v
	end)

	UIYap.Buton(s, "Fly Yukari (+Y)", false, function()
		Sistem.Hareket.DikeyYon = (Sistem.Hareket.DikeyYon == 1) and 0 or 1
	end)

	UIYap.Buton(s, "Fly Asagi (-Y)", false, function()
		Sistem.Hareket.DikeyYon = (Sistem.Hareket.DikeyYon == -1) and 0 or -1
	end)

	UIYap.AcKapat(s, "Car Fly (ShiftLock + Kamera)", false, "CarFlyTus", "CAR FLY", function(v)
		CarFlyDurum(v)
	end)

	UIYap.Kaydirici(s, "Car Fly Hizi", 20, 300, 100, function(v)
		Sistem.Hareket.CarFlyHiz = v
	end)

	UIYap.Kaydirici(s, "Araba Hizi Degeri", 20, 350, 90, function(v)
		Sistem.Hareket.ArabaHizDegeri = v
	end)

	UIYap.Buton(s, "Araba Hizini Uygula", true, function()
		SeciliArabaHiziniUygula()
	end)

	UIYap.AcKapat(s, "Speed", false, nil, nil, function(v)
		Sistem.Hareket.SpeedAktif = v
		FizikVeBoyutUygula()
	end)

	UIYap.Kaydirici(s, "Speed Degeri", 16, 200, 36, function(v)
		Sistem.Hareket.SpeedDeger = v
		if Sistem.Hareket.SpeedAktif then FizikVeBoyutUygula() end
	end)

	UIYap.AcKapat(s, "Jump", false, nil, nil, function(v)
		Sistem.Hareket.JumpAktif = v
		FizikVeBoyutUygula()
	end)

	UIYap.Kaydirici(s, "Jump Degeri", 50, 250, 75, function(v)
		Sistem.Hareket.JumpDeger = v
		if Sistem.Hareket.JumpAktif then FizikVeBoyutUygula() end
	end)

	UIYap.AcKapat(s, "Gravity", false, nil, nil, function(v)
		Sistem.Hareket.GravityAktif = v
		FizikVeBoyutUygula()
	end)

	UIYap.Kaydirici(s, "Gravity Degeri", 10, 300, 196, function(v)
		Sistem.Hareket.GravityDeger = v
		if Sistem.Hareket.GravityAktif then FizikVeBoyutUygula() end
	end)

	UIYap.AcKapat(s, "Boyut Degistir", false, nil, nil, function(v)
		Sistem.Hareket.BoyutAktif = v
		FizikVeBoyutUygula()
	end)

	UIYap.Kaydirici(s, "Karakter Boyutu (%10-%500)", 10, 500, 100, function(v)
		Sistem.Hareket.BoyutOran = math.clamp(v / 100, 0.1, 5.0)
		if Sistem.Hareket.BoyutAktif then FizikVeBoyutUygula() end
	end)

	UIYap.Kaydirici(s, "Kafa Boyutu (%50-%400)", 50, 400, 100, function(v)
		Sistem.Hareket.KafaOran = math.clamp(v / 100, 0.5, 4.0)
		if Sistem.Hareket.BoyutAktif then FizikVeBoyutUygula() end
	end)
end

-- 3. ESP & TAKIP SAYFASI
do
	local s = UIYap.SekmeEkle("ESP", "ESP & Takip")

	UIYap.AcKapat(s, "ESP Ac / Kapat", false, "ESPTus", "ESP", function(v)
		Sistem.ESP.Aktif = v
		if not v then ESPTemizle() end
	end)

	UIYap.Secici(s, "ESP Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, "Hepsi", function(h)
		Sistem.ESP.HedefTuru = h :: "Hepsi" | "Bot" | "Oyuncu Gercek"
	end)

	UIYap.AcKapat(s, "Kutu ESP", true, nil, nil, function(v) Sistem.ESP.Kutu = v end)
	UIYap.AcKapat(s, "Isim ESP", true, nil, nil, function(v) Sistem.ESP.Isim = v end)
	UIYap.AcKapat(s, "Mesafe ESP", true, nil, nil, function(v) Sistem.ESP.Mesafe = v end)
	UIYap.AcKapat(s, "Can Bari ESP", true, nil, nil, function(v) Sistem.ESP.CanBar = v end)
	UIYap.AcKapat(s, "Vurgu (Highlight)", true, nil, nil, function(v) Sistem.ESP.Vurgu = v end)
	UIYap.AcKapat(s, "Cizgi ESP", false, nil, nil, function(v) Sistem.ESP.Cizgi = v end)

	UIYap.Kaydirici(s, "ESP Mesafe Siniri", 100, 2000, 800, function(v)
		Sistem.ESP.MesafeSiniri = v
	end)

	UIYap.AcKapat(s, "Oto Takip", false, "OtoTakipTus", "TAKIP", function(v)
		Sistem.OtoTakipAktif = v
	end)

	UIYap.Secici(s, "Oto Takip Hedefi", { "EnYakinOyuncu", "EnYakinBot", "SeciliOyuncu" }, "EnYakinOyuncu", function(m)
		Sistem.OtoTakipHedefModu = m :: "EnYakinOyuncu" | "EnYakinBot" | "SeciliOyuncu"
	end)

	UIYap.Kaydirici(s, "Oto Takip Mesafesi", 2, 25, 7, function(v)
		Sistem.OtoTakipMesafe = v
	end)
end

-- 4. TELEPORT SAYFASI
do
	local s = UIYap.SekmeEkle("Teleport", "Teleport")

	UIYap.Buton(s, "En Yakin Oyuncuya Isinlan", true, function()
		EnYakinOyuncuyaIsinlan()
	end)

	UIYap.Buton(s, "En Yakin Bot / Nextbota Isinlan", true, function()
		EnYakinBotNextbotaIsinlan()
	end)

	UIYap.Secici(s, "Oyuncu Sec", { "Secili Yok" }, "Secili Yok", function()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				Sistem.SeciliOyuncu = plr
				OyuncuyaIsinlan(plr)
				break
			end
		end
	end)

	UIYap.Buton(s, "Secili Oyuncuya Isinlan", false, function()
		OyuncuyaIsinlan(Sistem.SeciliOyuncu)
	end)

	UIYap.Buton(s, "Onceki Konuma Don", false, function()
		OncekiKonumaDon()
	end)
end

-- 5. GORUNUM & PATATES MOD SAYFASI
do
	local s = UIYap.SekmeEkle("Duzen", "Gorunum & Patates")

	UIYap.Secici(s, "Gorunum Modu", { "TamPanel", "UstTavan", "TekButon" }, "TamPanel", function(m)
		GorunumModuUygula(m :: "TamPanel" | "UstTavan" | "TekButon")
	end)

	UIYap.Kaydirici(s, "Ust Tavan Genisligi", 150, 460, 240, function(v)
		UstTavanBar.Size = UDim2.new(0, v, 0, UstTavanBar.Size.Y.Offset)
	end)

	UIYap.Kaydirici(s, "Ust Tavan Yuksekligi", 24, 52, 30, function(v)
		UstTavanBar.Size = UDim2.new(0, UstTavanBar.Size.X.Offset, 0, v)
		GorunumModuUygula(Sistem.GorunumModu)
	end)

	UIYap.Kaydirici(s, "Tek Buton Boyutu", 38, 96, 56, function(v)
		TekButon.Size = UDim2.new(0, v, 0, v)
		TekButonKose.CornerRadius = UDim.new(0, v * 0.5)
	end)

	UIYap.AcKapat(s, "Patates Mod (Sade / Az Kasar)", false, "PatatesTus", "PATATES", function(v)
		PatatesModUygula(v)
	end)
end

-- Ilk Sekmeyi Ac ve Respawn Uyumunu Bagla
do
	local ilkSekme = Sistem.Sayfalar["Nisan"]
	local ilkButon = Sistem.SekmeButonlari["Nisan"]
	if ilkSekme then ilkSekme.Visible = true end
	if ilkButon then
		ilkButon.BackgroundColor3 = Sistem.Renkler.Vurgu
		ilkButon.TextColor3 = Color3.new(1, 1, 1)
	end
end

BaglantiEkle(LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.25)
	FizikVeBoyutUygula()
	if Sistem.Hareket.NormalFly then
		NormalFlyDurum(true)
	end
	if Sistem.Hitbox.Aktif then
		HitboxUygula()
	end
end))
