--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local EskiArayuz = PlayerGui:FindFirstChild("MoonMobilArayuz_V15")
if EskiArayuz then
	EskiArayuz:Destroy()
end

local HAFIZA_DOSYASI = "moon_mobil_hafiza_v15.json"

local Varsayilan = {
	HedefTuru = "Hepsi",
	AimbotTur = "Normal",
	AimbotAcik = false,
	AimbotParca = "Kafa",
	AimbotMesafe = 500,
	AimbotKeskinlik = 60,
	DaireCap = 135,
	TahminAcik = false,
	TetikAcik = false,
	CrosshairAcik = false,
	CrosshairSekil = "Nokta",
	SilentAcik = false,
	SilentParca = "Kafa",
	HitboxAcik = false,
	HitboxBoyut = 7,
	HitboxParca = "Govde",
	MermiBicakHiz = 50,
	NormalFlyAcik = false,
	NormalFlyHiz = 70,
	CarFlyAcik = false,
	CarFlyHiz = 100,
	ArabaHizi = 90,
	SpeedAcik = false,
	SpeedDeger = 36,
	JumpAcik = false,
	JumpDeger = 75,
	GravityAcik = false,
	GravityDeger = 196.2,
	BoyutAcik = false,
	BoyutOran = 1.0,
	EspAcik = false,
	EspKutu = true,
	EspIsim = true,
	EspMesafe = true,
	EspCan = true,
	EspCizgi = false,
	EspVurgu = true,
	EspMesafeSiniri = 850,
	ArayuzPatates = false,
	OyunPatates = false,
	GolgeSilici = false,
	Aydinlik = 50,
	KayitKonum = nil :: { number }?,
}
local function KopyaTablo(t: any): any
	if type(t) ~= "table" then
		return t
	end
	local y = {}
	for k, v in pairs(t) do
		y[k] = KopyaTablo(v)
	end
	return y
end

local Ayar = KopyaTablo(Varsayilan)
local HafizaYedek: any = nil

local function HafizaKaydet()
	HafizaYedek = KopyaTablo(Ayar)
	pcall(function()
		if type(writefile) == "function" then
			writefile(HAFIZA_DOSYASI, HttpService:JSONEncode(Ayar))
		end
	end)
end

local function HafizaYukle()
	local yuklendi = false
	pcall(function()
		if type(isfile) == "function" and type(readfile) == "function" and isfile(HAFIZA_DOSYASI) then
			local veri = HttpService:JSONDecode(readfile(HAFIZA_DOSYASI))
			if type(veri) == "table" then
				for k, v in pairs(veri) do
					if Ayar[k] ~= nil then
						Ayar[k] = v
					end
				end
				yuklendi = true
			end
		end
	end)
	if not yuklendi and type(HafizaYedek) == "table" then
		for k, v in pairs(HafizaYedek) do
			if Ayar[k] ~= nil then
				Ayar[k] = v
			end
		end
	end
end

HafizaYukle()

local Durum = {
	PanelAcik = true,
	SimgeDurum = false,
	Gorunum = "TamPanel" :: "TamPanel" | "UstTavan" | "TekButon",
	DikeyYon = 0,
	SonTetik = 0,
	TetikAralik = 0.14,
	GecmisKonumlar = {} :: { CFrame },
	TiklaIsinlanMod = false,
}

local Baglantilar = {} :: { RBXScriptConnection }
local function Bagla(c: RBXScriptConnection): RBXScriptConnection
	table.insert(Baglantilar, c)
	return c
end
local function KarakterAl(): (Model?, Humanoid?, BasePart?)
	local ch = LocalPlayer.Character
	if not ch then
		return nil, nil, nil
	end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	return ch, hum, hrp
end

local function TakimKontrol(model: Model): boolean
	local plr = Players:GetPlayerFromCharacter(model)
	if not plr or plr == LocalPlayer then
		return false
	end
	if LocalPlayer.Team ~= nil and plr.Team ~= nil then
		return LocalPlayer.Team == plr.Team
	end
	return false
end

local function OluKontrol(model: Model): boolean
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then
		return true
	end
	return hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead
end

local function HedefUygunMu(model: Model, turSecimi: string?): boolean
	if not model or not model.Parent or model == LocalPlayer.Character then
		return false
	end
	if TakimKontrol(model) then
		return false
	end
	if OluKontrol(model) then
		return false
	end
	local tur = turSecimi or Ayar.HedefTuru
	local gercekOyuncu = Players:GetPlayerFromCharacter(model) ~= nil
	if tur == "Hepsi" then
		return true
	elseif tur == "Oyuncu Gercek" then
		return gercekOyuncu
	elseif tur == "Bot" then
		return not gercekOyuncu
	end
	return false
end

local function ParcaSec(model: Model, parcaAd: string): BasePart?
	if parcaAd == "Kafa" then
		local head = model:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head
		end
	end
	local root = model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("UpperTorso")
		or model.PrimaryPart
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function DuvarVarMi(hedefNokta: Vector3, hedefModel: Model): boolean
	local bas = Camera.CFrame.Position
	local yon = hedefNokta - bas
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local haric = {} :: { Instance }
	if LocalPlayer.Character then
		table.insert(haric, LocalPlayer.Character)
	end
	table.insert(haric, hedefModel)
	params.FilterDescendantsInstances = haric
	return Workspace:Raycast(bas, yon, params) ~= nil
end
local normalBV: BodyVelocity? = nil
local normalBG: BodyGyro? = nil
local carBV: BodyVelocity? = nil
local carBG: BodyGyro? = nil

local function KoltukAl(): VehicleSeat?
	local _, hum, _ = KarakterAl()
	if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
		return hum.SeatPart
	end
	return nil
end

local function NormalFlyAyarla(aktif: boolean)
	Ayar.NormalFlyAcik = aktif
	local _, hum, hrp = KarakterAl()
	if not hum or not hrp then
		return
	end
	if aktif then
		hum.PlatformStand = true
		if not normalBV then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "MobilNormalFlyBV"
			bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
			bv.Velocity = Vector3.zero
			bv.Parent = hrp
			normalBV = bv
		end
		if not normalBG then
			local bg = Instance.new("BodyGyro")
			bg.Name = "MobilNormalFlyBG"
			bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
			bg.P = 9e4
			bg.CFrame = Camera.CFrame
			bg.Parent = hrp
			normalBG = bg
		end
	else
		hum.PlatformStand = false
		if normalBV then
			normalBV:Destroy()
			normalBV = nil
		end
		if normalBG then
			normalBG:Destroy()
			normalBG = nil
		end
		Durum.DikeyYon = 0
	end
	HafizaKaydet()
end

local function CarFlyAyarla(aktif: boolean)
	Ayar.CarFlyAcik = aktif
	local koltuk = KoltukAl()
	if not aktif or not koltuk then
		if carBV then
			carBV:Destroy()
			carBV = nil
		end
		if carBG then
			carBG:Destroy()
			carBG = nil
		end
		HafizaKaydet()
		return
	end
	if not carBV then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "MobilCarFlyBV"
		bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
		bv.Velocity = Vector3.zero
		bv.Parent = koltuk
		carBV = bv
	end
	if not carBG then
		local bg = Instance.new("BodyGyro")
		bg.Name = "MobilCarFlyBG"
		bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
		bg.P = 9e4
		bg.CFrame = Camera.CFrame
		bg.Parent = koltuk
		carBG = bg
	end
	HafizaKaydet()
end
local function ArabaHiziUygula(): boolean
	local koltuk = KoltukAl()
	if not koltuk then
		return false
	end
	local ileri = koltuk.CFrame.LookVector
	local yatay = Vector3.new(ileri.X, 0, ileri.Z)
	if yatay.Magnitude < 0.05 then
		local cLook = Camera.CFrame.LookVector
		yatay = Vector3.new(cLook.X, 0, cLook.Z)
	end
	if yatay.Magnitude > 0.01 then
		koltuk.AssemblyLinearVelocity = (yatay.Unit * Ayar.ArabaHizi) + Vector3.new(0, koltuk.AssemblyLinearVelocity.Y, 0)
	end
	return true
end

local function FizikVeBoyutGuncelle()
	local ch, hum, _ = KarakterAl()
	if hum then
		hum.WalkSpeed = Ayar.SpeedAcik and Ayar.SpeedDeger or 16
		hum.UseJumpPower = true
		hum.JumpPower = Ayar.JumpAcik and Ayar.JumpDeger or 50
	end
	Workspace.Gravity = Ayar.GravityAcik and Ayar.GravityDeger or 196.2
	if ch and hum then
		local oran = Ayar.BoyutAcik and Ayar.BoyutOran or 1.0
		local olcekBulundu = false
		for _, ad in ipairs({ "BodyWidthScale", "BodyHeightScale", "BodyDepthScale", "HeadScale" }) do
			local nv = hum:FindFirstChild(ad)
			if nv and nv:IsA("NumberValue") then
				nv.Value = oran
				olcekBulundu = true
			end
		end
		if not olcekBulundu then
			pcall(function()
				ch:ScaleTo(oran)
			end)
		end
	end
end

local CrosshairKonum: Vector2? = nil
local KilitliHedefModel: Model? = nil
local HitboxKayit = {} :: { [BasePart]: { Size: Vector3, Transparency: number, CanCollide: boolean, Massless: boolean, Material: Enum.Material } }

local function KeskinlikAdimi(deger0_100: number, dt: number): number
	local k = math.clamp(deger0_100, 0, 100)
	if k >= 99 then
		return 1
	end
	local hiz = 1.6 + ((k / 100) ^ 1.35) * 42
	return math.clamp(1 - math.exp(-hiz * dt), 0.02, 1)
end

local function TahminKonumAl(parca: BasePart): Vector3
	if not Ayar.TahminAcik then
		return parca.Position
	end
	return parca.Position + (parca.AssemblyLinearVelocity * 0.14)
end

local function MerkezEkranAl(): Vector2
	if Ayar.CrosshairAcik and CrosshairKonum then
		return CrosshairKonum
	end
	local vp = Camera.ViewportSize
	return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end
local function AimbotHedefiAl(): BasePart?
	if not Ayar.AimbotAcik then
		KilitliHedefModel = nil
		return nil
	end
	local _, _, benHRP = KarakterAl()
	if not benHRP then
		return nil
	end
	local tur = Ayar.AimbotTur
	local merkez = MerkezEkranAl()

	local function KontrolEt(model: Model): BasePart?
		if not HedefUygunMu(model, Ayar.HedefTuru) then
			return nil
		end
		local parca = ParcaSec(model, Ayar.AimbotParca)
		if not parca then
			return nil
		end
		if (parca.Position - benHRP.Position).Magnitude > Ayar.AimbotMesafe then
			return nil
		end
		local nokta = TahminKonumAl(parca)
		local ekPos, gorunur = Camera:WorldToViewportPoint(nokta)
		if not gorunur or ekPos.Z <= 0 then
			return nil
		end
		if tur == "Daire" then
			if (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude > Ayar.DaireCap then
				return nil
			end
		elseif tur == "Acikta" then
			if DuvarVarMi(nokta, model) then
				return nil
			end
		end
		return parca
	end

	if KilitliHedefModel then
		local halaUygun = KontrolEt(KilitliHedefModel)
		if halaUygun then
			return halaUygun
		end
		KilitliHedefModel = nil
	end

	local enIyiParca: BasePart? = nil
	local enIyiModel: Model? = nil
	local enKucuk = math.huge

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") then
			local p = KontrolEt(nesne)
			if p then
				local ekPos = Camera:WorldToViewportPoint(TahminKonumAl(p))
				local ekranFark = (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude
				local skor = (tur == "Normal") and (p.Position - benHRP.Position).Magnitude or ekranFark
				if skor < enKucuk then
					enKucuk = skor
					enIyiParca = p
					enIyiModel = nesne
				end
			end
		end
	end

	KilitliHedefModel = enIyiModel
	return enIyiParca
end

local function TetikIslemi(hedef: BasePart?)
	if not Ayar.TetikAcik or not hedef then
		return
	end
	local simdi = os.clock()
	if simdi - Durum.SonTetik < Durum.TetikAralik then
		return
	end
	local ekPos, gor = Camera:WorldToViewportPoint(hedef.Position)
	if not gor or ekPos.Z <= 0 then
		return
	end
	local merkez = MerkezEkranAl()
	local sinir = (Ayar.AimbotTur == "Daire") and Ayar.DaireCap or 46
	if (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude <= sinir then
		Durum.SonTetik = simdi
		local char = LocalPlayer.Character
		local arac = char and char:FindFirstChildOfClass("Tool")
		if arac then
			pcall(function()
				arac:Activate()
			end)
		end
	end
end
local function SilentHedefAl(): BasePart?
	if not Ayar.SilentAcik then
		return nil
	end
	local _, _, benHRP = KarakterAl()
	if not benHRP then
		return nil
	end
	local merkez = MerkezEkranAl()
	local enIyi: BasePart? = nil
	local enKucuk = math.huge

	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefUygunMu(nesne, Ayar.HedefTuru) then
			local p = ParcaSec(nesne, Ayar.SilentParca)
			if p and (p.Position - benHRP.Position).Magnitude <= Ayar.AimbotMesafe then
				local nokta = TahminKonumAl(p)
				local ekPos, gor = Camera:WorldToViewportPoint(nokta)
				if gor and ekPos.Z > 0 then
					local fark = (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude
					local daireOk = (Ayar.AimbotTur ~= "Daire") or (fark <= Ayar.DaireCap)
					local acikOk = (Ayar.AimbotTur ~= "Acikta") or (not DuvarVarMi(nokta, nesne))
					if daireOk and acikOk and fark < enKucuk then
						enKucuk = fark
						enIyi = p
					end
				end
			end
		end
	end
	return enIyi
end

local function CrosshairHizala(dokunus: Vector2?)
	local hedefPos: Vector3? = nil
	if Ayar.SilentAcik then
		local sParca = SilentHedefAl()
		if sParca then
			hedefPos = TahminKonumAl(sParca)
		end
	end
	if not hedefPos and Ayar.CrosshairAcik then
		local merkez = CrosshairKonum or MerkezEkranAl()
		local ray = Camera:ViewportPointToRay(merkez.X, merkez.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		if LocalPlayer.Character then
			params.FilterDescendantsInstances = { LocalPlayer.Character }
		end
		local sonuc = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
		hedefPos = sonuc and sonuc.Position or (ray.Origin + ray.Direction * 350)
	end
	if hedefPos then
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, hedefPos)
	elseif dokunus then
		local ray = Camera:ViewportPointToRay(dokunus.X, dokunus.Y)
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, ray.Origin + ray.Direction * 250)
	end
end

local function HitboxSifirla()
	for p, veri in pairs(HitboxKayit) do
		if p and p.Parent then
			p.Size = veri.Size
			p.Transparency = veri.Transparency
			p.CanCollide = veri.CanCollide
			p.Massless = veri.Massless
			p.Material = veri.Material
		end
	end
	table.clear(HitboxKayit)
end
local function HitboxUygula()
	if not Ayar.HitboxAcik then
		HitboxSifirla()
		return
	end
	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefUygunMu(nesne, Ayar.HedefTuru) then
			local parcalar = {} :: { BasePart }
			if Ayar.HitboxParca == "Kafa" or Ayar.HitboxParca == "Ikisi" then
				local k = nesne:FindFirstChild("Head")
				if k and k:IsA("BasePart") then
					table.insert(parcalar, k)
				end
			end
			if Ayar.HitboxParca == "Govde" or Ayar.HitboxParca == "Ikisi" then
				local g = nesne:FindFirstChild("HumanoidRootPart") or nesne:FindFirstChild("Torso") or nesne:FindFirstChild("UpperTorso")
				if g and g:IsA("BasePart") then
					table.insert(parcalar, g)
				end
			end
			for _, p in ipairs(parcalar) do
				if not HitboxKayit[p] then
					HitboxKayit[p] = {
						Size = p.Size,
						Transparency = p.Transparency,
						CanCollide = p.CanCollide,
						Massless = p.Massless,
						Material = p.Material,
					}
				end
				p.Size = Vector3.new(Ayar.HitboxBoyut, Ayar.HitboxBoyut, Ayar.HitboxBoyut)
				p.CanCollide = false
				p.Massless = true
				p.Transparency = Ayar.ArayuzPatates and 0.8 or 0.65
				p.Material = Enum.Material.ForceField
			end
		end
	end
end

Bagla(Workspace.DescendantAdded:Connect(function(nesne)
	if Ayar.MermiBicakHiz == 50 then
		return
	end
	local oran = math.clamp(Ayar.MermiBicakHiz / 50, 0.1, 4.0)
	if nesne:IsA("BasePart") then
		task.defer(function()
			if nesne and nesne.Parent and nesne.AssemblyLinearVelocity.Magnitude > 4 then
				nesne.AssemblyLinearVelocity = nesne.AssemblyLinearVelocity * oran
			end
		end)
	elseif nesne:IsA("LinearVelocity") then
		nesne.VectorVelocity = nesne.VectorVelocity * oran
	elseif nesne:IsA("BodyVelocity") then
		nesne.Velocity = nesne.Velocity * oran
	end
end))
type ESPKutuNesne = {
	BB: BillboardGui,
	Yazi: TextLabel,
	CanArka: Frame,
	CanDolgu: Frame,
	Kutu: Frame,
	KutuKenar: UIStroke,
	Cizgi: Frame,
	Vurgu: Highlight?,
}

local ESPKartlar = {} :: { [Model]: ESPKutuNesne }
local KopyaliCF: CFrame? = nil
if type(Ayar.KayitKonum) == "table" and #Ayar.KayitKonum == 3 then
	KopyaliCF = CFrame.new(Ayar.KayitKonum[1], Ayar.KayitKonum[2], Ayar.KayitKonum[3])
end

local function ESPKartSil(m: Model)
	local k = ESPKartlar[m]
	if not k then
		return
	end
	if k.BB then k.BB:Destroy() end
	if k.Kutu then k.Kutu:Destroy() end
	if k.Cizgi then k.Cizgi:Destroy() end
	if k.Vurgu then k.Vurgu:Destroy() end
	ESPKartlar[m] = nil
end

local function TumESPSil()
	for m, _ in pairs(ESPKartlar) do
		ESPKartSil(m)
	end
end

local function ESPKartOlustur(m: Model, kok: BasePart): ESPKutuNesne
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_Bilgi"
	bb.Adornee = kok
	bb.Size = UDim2.new(0, 170, 0, 44)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = PlayerGui

	local yazi = Instance.new("TextLabel")
	yazi.Size = UDim2.new(1, 0, 0, 20)
	yazi.BackgroundTransparency = 1
	yazi.Font = Enum.Font.GothamBold
	yazi.TextSize = 11
	yazi.TextColor3 = Color3.new(1, 1, 1)
	yazi.TextStrokeTransparency = 0.2
	yazi.Parent = bb

	local canArka = Instance.new("Frame")
	canArka.Size = UDim2.new(0.75, 0, 0, 5)
	canArka.Position = UDim2.new(0.125, 0, 0, 24)
	canArka.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	canArka.BorderSizePixel = 0
	canArka.Parent = bb

	local canDolgu = Instance.new("Frame")
	canDolgu.Size = UDim2.new(1, 0, 1, 0)
	canDolgu.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	canDolgu.BorderSizePixel = 0
	canDolgu.Parent = canArka

	local kutu = Instance.new("Frame")
	kutu.Name = "ESP_Kutu"
	kutu.BackgroundTransparency = 1
	kutu.Visible = false
	kutu.ZIndex = 30
	kutu.Parent = PlayerGui

	local kutuKenar = Instance.new("UIStroke")
	kutuKenar.Thickness = 1.6
	kutuKenar.Parent = kutu

	local cizgi = Instance.new("Frame")
	cizgi.Name = "ESP_Cizgi"
	cizgi.AnchorPoint = Vector2.new(0.5, 0.5)
	cizgi.BorderSizePixel = 0
	cizgi.Visible = false
	cizgi.ZIndex = 29
	cizgi.Parent = PlayerGui

	local vurgu: Highlight? = nil
	if not Ayar.OyunPatates then
		local h = Instance.new("Highlight")
		h.Adornee = m
		h.FillTransparency = 0.72
		h.OutlineTransparency = 0.1
		h.Parent = PlayerGui
		vurgu = h
	end

	local item: ESPKutuNesne = {
		BB = bb,
		Yazi = yazi,
		CanArka = canArka,
		CanDolgu = canDolgu,
		Kutu = kutu,
		KutuKenar = kutuKenar,
		Cizgi = cizgi,
		Vurgu = vurgu,
	}
	ESPKartlar[m] = item
	return item
end
local function ESPGuncelle()
	if not Ayar.EspAcik then
		if next(ESPKartlar) ~= nil then
			TumESPSil()
		end
		return
	end
	local _, _, benHRP = KarakterAl()
	local benKonum = benHRP and benHRP.Position or Camera.CFrame.Position
	local aktifModeller = {} :: { [Model]: boolean }

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and HedefUygunMu(obj, Ayar.HedefTuru) then
			local kok = ParcaSec(obj, "Govde")
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if kok and hum then
				local mesafe = (kok.Position - benKonum).Magnitude
				if mesafe <= Ayar.EspMesafeSiniri then
					aktifModeller[obj] = true
					local kart = ESPKartlar[obj] or ESPKartOlustur(obj, kok)

					if Ayar.OyunPatates and kart.Vurgu then
						kart.Vurgu:Destroy()
						kart.Vurgu = nil
					elseif (not Ayar.OyunPatates) and (not kart.Vurgu) then
						local h = Instance.new("Highlight")
						h.Adornee = obj
						h.FillTransparency = 0.72
						h.OutlineTransparency = 0.1
						h.Parent = PlayerGui
						kart.Vurgu = h
					end

					local plr = Players:GetPlayerFromCharacter(obj)
					local renk = plr and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(34, 197, 94)

					local satir = {} :: { string }
					if Ayar.EspIsim then
						table.insert(satir, (plr and "[OYUNCU] " or "[BOT] ") .. obj.Name)
					end
					if Ayar.EspMesafe then
						table.insert(satir, string.format("%.0fm", mesafe))
					end
					kart.Yazi.Text = table.concat(satir, " • ")
					kart.Yazi.TextColor3 = renk
					kart.Yazi.Visible = #satir > 0

					if Ayar.EspCan then
						kart.CanArka.Visible = true
						local hp = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
						kart.CanDolgu.Size = UDim2.new(hp, 0, 1, 0)
						kart.CanDolgu.BackgroundColor3 = Color3.fromRGB(239, 68, 68):Lerp(Color3.fromRGB(34, 197, 94), hp)
					else
						kart.CanArka.Visible = false
					end

					kart.BB.Enabled = kart.Yazi.Visible or kart.CanArka.Visible

					if kart.Vurgu then
						kart.Vurgu.Enabled = Ayar.EspVurgu
						kart.Vurgu.FillColor = renk
					end

					local ekPos, gor = Camera:WorldToViewportPoint(kok.Position)
					if gor and ekPos.Z > 0 then
						local olcek = 920 / math.max(1, ekPos.Z)
						local w = math.clamp(olcek * 2.0, 22, 240)
						local h = math.clamp(olcek * 3.1, 32, 360)
						kart.Kutu.Visible = Ayar.EspKutu
						kart.Kutu.Position = UDim2.new(0, ekPos.X - w * 0.5, 0, ekPos.Y - h * 0.5)
						kart.Kutu.Size = UDim2.new(0, w, 0, h)
						kart.KutuKenar.Color = renk

						kart.Cizgi.Visible = Ayar.EspCizgi and (not Ayar.OyunPatates)
						if kart.Cizgi.Visible then
							local altMerkez = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
							local hedef2D = Vector2.new(ekPos.X, ekPos.Y)
							local fark = hedef2D - altMerkez
							kart.Cizgi.BackgroundColor3 = renk
							kart.Cizgi.Position = UDim2.new(0, (altMerkez.X + hedef2D.X) * 0.5, 0, (altMerkez.Y + hedef2D.Y) * 0.5)
							kart.Cizgi.Size = UDim2.new(0, fark.Magnitude, 0, 1.5)
							kart.Cizgi.Rotation = math.deg(math.atan2(fark.Y, fark.X))
						end
					else
						kart.Kutu.Visible = false
						kart.Cizgi.Visible = false
					end
				end
			end
		end
	end

	for m, _ in pairs(ESPKartlar) do
		if not aktifModeller[m] or not m.Parent then
			ESPKartSil(m)
		end
	end
end
local function KonumaIsinlan(cf: CFrame): boolean
	local ch, _, hrp = KarakterAl()
	if not ch or not hrp then
		return false
	end
	table.insert(Durum.GecmisKonumlar, hrp.CFrame)
	if #Durum.GecmisKonumlar > 20 then
		table.remove(Durum.GecmisKonumlar, 1)
	end
	ch:PivotTo(cf)
	return true
end

local function EnYakinOyuncuIsinlan(): boolean
	local _, _, benHRP = KarakterAl()
	if not benHRP then
		return false
	end
	local enYakin: BasePart? = nil
	local enKisa = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not TakimKontrol(plr.Character) and not OluKontrol(plr.Character) then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				local mesafe = (hrp.Position - benHRP.Position).Magnitude
				if mesafe < enKisa then
					enKisa = mesafe
					enYakin = hrp
				end
			end
		end
	end
	return enYakin and KonumaIsinlan(enYakin.CFrame * CFrame.new(0, 0, 4)) or false
end

local function EnYakinBotNextbotIsinlan(): boolean
	local _, _, benHRP = KarakterAl()
	if not benHRP then
		return false
	end
	local enYakin: BasePart? = nil
	local enKisa = math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character and Players:GetPlayerFromCharacter(obj) == nil then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = ParcaSec(obj, "Govde")
			local adUygun = obj.Name:lower():find("bot") ~= nil or obj.Name:lower():find("npc") ~= nil or obj.Name:lower():find("nextbot") ~= nil
			if hrp and ((hum and hum.Health > 0) or adUygun) and not OluKontrol(obj) then
				local mesafe = (hrp.Position - benHRP.Position).Magnitude
				if mesafe < enKisa then
					enKisa = mesafe
					enYakin = hrp
				end
			end
		end
	end
	return enYakin and KonumaIsinlan(enYakin.CFrame * CFrame.new(0, 0, 4)) or false
end

local function KonumKopyala(): boolean
	local _, _, hrp = KarakterAl()
	if not hrp then
		return false
	end
	KopyaliCF = hrp.CFrame
	Ayar.KayitKonum = { hrp.Position.X, hrp.Position.Y, hrp.Position.Z }
	HafizaKaydet()
	return true
end

local function KopyaliKonumaIsinlan(): boolean
	if not KopyaliCF then
		return false
	end
	return KonumaIsinlan(KopyaliCF)
end

local function TiklananNoktayaIsinlan(pos: Vector2): boolean
	local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	if LocalPlayer.Character then
		params.FilterDescendantsInstances = { LocalPlayer.Character }
	end
	local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
	if hit then
		return KonumaIsinlan(CFrame.new(hit.Position + Vector3.new(0, 3.5, 0)))
	end
	return KonumaIsinlan(CFrame.new(ray.Origin + ray.Direction * 60))
end
local IlkIsik = {
	GlobalShadows = Lighting.GlobalShadows,
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
}
local GizlenenEfektler = {} :: { Instance }
local YedekParcalar = {} :: { [BasePart]: { Material: Enum.Material, CastShadow: boolean } }

local function GolgeSiliciAyarla(aktif: boolean)
	Ayar.GolgeSiliciAcik = aktif
	if aktif then
		Lighting.GlobalShadows = false
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.CastShadow = false
			end
		end
	else
		Lighting.GlobalShadows = IlkIsik.GlobalShadows
		for p, v in pairs(YedekParcalar) do
			if p and p.Parent then
				p.CastShadow = v.CastShadow
			end
		end
	end
	HafizaKaydet()
end

local function AydinlikAyarla(deger: number)
	Ayar.Aydinlik = math.clamp(deger, 0, 100)
	local oran = Ayar.Aydinlik / 100
	Lighting.ClockTime = 0.5 + (oran * 13.5)
	Lighting.Brightness = oran * 6.5
	local icTon = math.floor(10 + (oran * 215))
	local disTon = math.floor(15 + (oran * 225))
	Lighting.Ambient = Color3.fromRGB(icTon, icTon, icTon)
	Lighting.OutdoorAmbient = Color3.fromRGB(disTon, disTon, disTon)
	HafizaKaydet()
end

local function OyunPatatesAyarla(aktif: boolean)
	Ayar.OyunPatates = aktif
	if aktif then
		table.clear(GizlenenEfektler)
		table.clear(YedekParcalar)
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA("PostEffect") and obj.Enabled then
				obj.Enabled = false
				table.insert(GizlenenEfektler, obj)
			end
		end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
				if obj.Enabled then
					obj.Enabled = false
					table.insert(GizlenenEfektler, obj)
				end
			elseif obj:IsA("BasePart") then
				YedekParcalar[obj] = { Material = obj.Material, CastShadow = obj.CastShadow }
				obj.CastShadow = false
				if obj.Material ~= Enum.Material.SmoothPlastic and obj.Material ~= Enum.Material.Neon then
					obj.Material = Enum.Material.SmoothPlastic
				end
			end
		end
		Lighting.GlobalShadows = false
	else
		for _, e in ipairs(GizlenenEfektler) do
			if e and e.Parent and (e:IsA("PostEffect") or e:IsA("ParticleEmitter") or e:IsA("Trail") or e:IsA("Beam") or e:IsA("Fire") or e:IsA("Smoke") or e:IsA("Sparkles")) then
				e.Enabled = true
			end
		end
		table.clear(GizlenenEfektler)
		for p, v in pairs(YedekParcalar) do
			if p and p.Parent then
				p.Material = v.Material
				if not Ayar.GolgeSiliciAcik then
					p.CastShadow = v.CastShadow
				end
			end
		end
		table.clear(YedekParcalar)
		if not Ayar.GolgeSiliciAcik then
			Lighting.GlobalShadows = IlkIsik.GlobalShadows
		end
	end
	HafizaKaydet()
end

local function FlyYonHesapla(hum: Humanoid?): Vector3
	local yon = Vector3.zero
	if hum and hum.MoveDirection.Magnitude > 0.02 then
		local look = Camera.CFrame.LookVector
		local right = Camera.CFrame.RightVector
		local ileriYatay = Vector3.new(look.X, 0, look.Z)
		if ileriYatay.Magnitude > 0.01 then
			ileriYatay = ileriYatay.Unit
		else
			ileriYatay = look
		end
		local sagYatay = Vector3.new(right.X, 0, right.Z)
		if sagYatay.Magnitude > 0.01 then
			sagYatay = sagYatay.Unit
		else
			sagYatay = right
		end
		yon += (Camera.CFrame.LookVector * hum.MoveDirection:Dot(ileriYatay)) + (sagYatay * hum.MoveDirection:Dot(sagYatay))
	end
	if Durum.DikeyYon ~= 0 then
		yon += Vector3.new(0, Durum.DikeyYon, 0)
	end
	if yon.Magnitude > 1 then
		yon = yon.Unit
	end
	return yon
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonMobilArayuz_V15"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairFrame.Size = UDim2.new(0, 44, 0, 44)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.ZIndex = 120
CrosshairFrame.Parent = ScreenGui

local ChNokta = Instance.new("Frame")
ChNokta.AnchorPoint = Vector2.new(0.5, 0.5)
ChNokta.Position = UDim2.new(0.5, 0, 0.5, 0)
ChNokta.Size = UDim2.new(0, 6, 0, 6)
ChNokta.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
ChNokta.BorderSizePixel = 0
ChNokta.Parent = CrosshairFrame
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = ChNokta end

local ChYatay = Instance.new("Frame")
ChYatay.AnchorPoint = Vector2.new(0.5, 0.5)
ChYatay.Position = UDim2.new(0.5, 0, 0.5, 0)
ChYatay.Size = UDim2.new(0, 22, 0, 2)
ChYatay.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
ChYatay.BorderSizePixel = 0
ChYatay.Parent = CrosshairFrame

local ChDikey = Instance.new("Frame")
ChDikey.AnchorPoint = Vector2.new(0.5, 0.5)
ChDikey.Position = UDim2.new(0.5, 0, 0.5, 0)
ChDikey.Size = UDim2.new(0, 2, 0, 22)
ChDikey.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
ChDikey.BorderSizePixel = 0
ChDikey.Parent = CrosshairFrame

local ChHalka = Instance.new("Frame")
ChHalka.AnchorPoint = Vector2.new(0.5, 0.5)
ChHalka.Position = UDim2.new(0.5, 0, 0.5, 0)
ChHalka.Size = UDim2.new(0, 24, 0, 24)
ChHalka.BackgroundTransparency = 1
ChHalka.Parent = CrosshairFrame
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = ChHalka
	local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Color3.fromRGB(34, 211, 238) s.Parent = ChHalka
end

local function CrosshairYenile()
	CrosshairFrame.Visible = Ayar.CrosshairAcik
	if not Ayar.CrosshairAcik then
		CrosshairKonum = nil
		return
	end
	CrosshairKonum = CrosshairFrame.AbsolutePosition + (CrosshairFrame.AbsoluteSize * 0.5)
	ChNokta.Visible = (Ayar.CrosshairSekil == "Nokta" or Ayar.CrosshairSekil == "Arti")
	ChYatay.Visible = (Ayar.CrosshairSekil == "Arti")
	ChDikey.Visible = (Ayar.CrosshairSekil == "Arti")
	ChHalka.Visible = (Ayar.CrosshairSekil == "Halka")
end

local AimDaire = Instance.new("Frame")
AimDaire.AnchorPoint = Vector2.new(0.5, 0.5)
AimDaire.Position = UDim2.new(0.5, 0, 0.5, 0)
AimDaire.Size = UDim2.new(0, Ayar.DaireCap * 2, 0, Ayar.DaireCap * 2)
AimDaire.BackgroundTransparency = 1
AimDaire.Visible = false
AimDaire.ZIndex = 115
AimDaire.Parent = ScreenGui
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = AimDaire
	local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = AimDaire
end

Bagla(RunService.RenderStepped:Connect(function(dt)
	local _, hum, hrp = KarakterAl()
	if Ayar.NormalFlyAcik and hum and hrp then
		if not normalBV or not normalBV.Parent then NormalFlyAyarla(true) end
		if normalBV then normalBV.Velocity = FlyYonHesapla(hum) * Ayar.NormalFlyHiz end
		if normalBG then
			local bak = Camera.CFrame.LookVector
			local yatay = Vector3.new(bak.X, 0, bak.Z)
			if yatay.Magnitude > 0.01 then normalBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + yatay.Unit) end
		end
	elseif normalBV or normalBG then
		NormalFlyAyarla(false)
	end

	local koltuk = KoltukAl()
	if Ayar.CarFlyAcik and koltuk then
		if not carBV or not carBV.Parent then CarFlyAyarla(true) end
		if carBV then carBV.Velocity = FlyYonHesapla(hum) * Ayar.CarFlyHiz end
		if carBG then
			local bak = Camera.CFrame.LookVector
			local yatay = Vector3.new(bak.X, 0, bak.Z)
			if yatay.Magnitude > 0.01 then carBG.CFrame = CFrame.lookAt(koltuk.Position, koltuk.Position + yatay.Unit) end
		end
	elseif carBV or carBG then
		CarFlyAyarla(false)
	end

	if Ayar.AimbotAcik then
		local hedef = AimbotHedefiAl()
		if hedef then
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, TahminKonumAl(hedef)), KeskinlikAdimi(Ayar.AimbotKeskinlik, dt))
			TetikIslemi(hedef)
		end
	else
		KilitliHedefModel = nil
	end

	ESPGuncelle()
	if Ayar.CrosshairAcik then CrosshairYenile() else CrosshairFrame.Visible = false CrosshairKonum = nil end
	local daireAc = Ayar.AimbotAcik and (Ayar.AimbotTur == "Daire")
	AimDaire.Visible = daireAc
	if daireAc then
		AimDaire.Size = UDim2.new(0, Ayar.DaireCap * 2, 0, Ayar.DaireCap * 2)
		AimDaire.Position = UDim2.new(0, (CrosshairKonum and CrosshairKonum.X) or (Camera.ViewportSize.X * 0.5), 0, (CrosshairKonum and CrosshairKonum.Y) or (Camera.ViewportSize.Y * 0.5))
	end
end))

Bagla(UserInputService.InputBegan:Connect(function(inp, isProcessed)
	if isProcessed then return end
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		local p = Vector2.new(inp.Position.X, inp.Position.Y)
		if Durum.TiklaIsinlanMod then
			Durum.TiklaIsinlanMod = false
			TiklananNoktayaIsinlan(p)
			return
		end
		if Ayar.CrosshairAcik or Ayar.SilentAcik then
			CrosshairHizala(p)
		end
	end
end))
local MAVI = Color3.fromRGB(59, 130, 246)
local SARI = Color3.fromRGB(250, 204, 21)
local YESIL = Color3.fromRGB(34, 197, 94)
local KIRMIZI = Color3.fromRGB(239, 68, 68)

local OzelTusKapsayici = Instance.new("Frame")
OzelTusKapsayici.Size = UDim2.new(1, 0, 1, 0)
OzelTusKapsayici.BackgroundTransparency = 1
OzelTusKapsayici.ZIndex = 135
OzelTusKapsayici.Parent = ScreenGui

local OzelTuslar = {} :: { [string]: { Buton: TextButton, Kenar: UIStroke, Acik: boolean, Kilitli: boolean, Fn: (boolean) -> () } }

local function OzelTusDurumYaz(id: string, acik: boolean)
	local k = OzelTuslar[id]
	if not k then return end
	k.Acik = acik
	k.Buton.BackgroundColor3 = acik and YESIL or KIRMIZI
end

local function OzelTusEkle(id: string, ad: string, ilkAcik: boolean, fn: (boolean) -> ())
	local mevcut = OzelTuslar[id]
	if mevcut then
		mevcut.Buton.Visible = not mevcut.Buton.Visible
		return
	end
	local sira = 0
	for _ in pairs(OzelTuslar) do sira += 1 end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 106, 0, 34)
	btn.Position = UDim2.new(0.74, 0, 0.16 + ((sira % 6) * 0.08), 0)
	btn.BackgroundColor3 = ilkAcik and YESIL or KIRMIZI
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = ad
	btn.AutoButtonColor = false
	btn.ZIndex = 136
	btn.Parent = OzelTusKapsayici
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = btn end

	local kenar = Instance.new("UIStroke")
	kenar.Thickness = 2.4
	kenar.Color = MAVI
	kenar.Parent = btn

	local kayit = { Buton = btn, Kenar = kenar, Acik = ilkAcik, Kilitli = false, Fn = fn }
	OzelTuslar[id] = kayit

	local basili = false
	local suruklendi = false
	local dokBas = Vector2.zero
	local uiBas = UDim2.new()
	local sayac = 0

	btn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			basili = true
			suruklendi = false
			dokBas = Vector2.new(inp.Position.X, inp.Position.Y)
			uiBas = btn.Position
			sayac += 1
			local mevcutSayac = sayac
			task.delay(3, function()
				if basili and not suruklendi and mevcutSayac == sayac then
					kayit.Kilitli = not kayit.Kilitli
					kenar.Color = kayit.Kilitli and SARI or MAVI
				end
			end)
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					if basili and not suruklendi then
						sayac += 1
						local yeni = not kayit.Acik
						kayit.Acik = yeni
						btn.BackgroundColor3 = yeni and YESIL or KIRMIZI
						fn(yeni)
					end
					basili = false
				end
			end)
		end
	end)

	Bagla(UserInputService.InputChanged:Connect(function(inp)
		if basili and (not kayit.Kilitli) and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local fark = Vector2.new(inp.Position.X, inp.Position.Y) - dokBas
			if fark.Magnitude > 6 then
				suruklendi = true
				sayac += 1
			end
			if suruklendi then
				local vp = Camera.ViewportSize
				btn.Position = UDim2.new(
					0, math.clamp(uiBas.X.Offset + fark.X, 0, math.max(0, vp.X - btn.AbsoluteSize.X)),
					0, math.clamp(uiBas.Y.Offset + fark.Y, 0, math.max(0, vp.Y - btn.AbsoluteSize.Y))
				)
			end
		end
	end))
end

local AnaKutu = Instance.new("Frame")
AnaKutu.Name = "AnaKutu"
AnaKutu.Size = UDim2.new(0, 560, 0, 320)
AnaKutu.Position = UDim2.new(0.5, -280, 0.5, -160)
AnaKutu.BackgroundColor3 = Color3.fromRGB(16, 13, 30)
AnaKutu.BorderSizePixel = 0
AnaKutu.ClipsDescendants = true
AnaKutu.Visible = true
AnaKutu.ZIndex = 50
AnaKutu.Parent = ScreenGui
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 14) c.Parent = AnaKutu
	local s = Instance.new("UIStroke") s.Thickness = 1.8 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = AnaKutu
end

local DesenKatman = Instance.new("Frame")
DesenKatman.Size = UDim2.new(1, 0, 1, 0)
DesenKatman.BackgroundColor3 = Color3.fromRGB(24, 19, 46)
DesenKatman.BorderSizePixel = 0
DesenKatman.ZIndex = 51
DesenKatman.Parent = AnaKutu

local Gradyan = Instance.new("UIGradient")
Gradyan.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 65, 235)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 28, 78)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 182, 212)),
})
Gradyan.Rotation = 32
Gradyan.Parent = DesenKatman

for i = 1, 7 do
	local ciz = Instance.new("Frame")
	ciz.Size = UDim2.new(0, 1, 1, 0)
	ciz.Position = UDim2.new(i / 8, 0, 0, 0)
	ciz.BackgroundColor3 = Color3.fromRGB(216, 180, 254)
	ciz.BackgroundTransparency = 0.86
	ciz.BorderSizePixel = 0
	ciz.ZIndex = 51
	ciz.Parent = DesenKatman
end

local UstSerit = Instance.new("Frame")
UstSerit.Size = UDim2.new(1, 0, 0, 36)
UstSerit.BackgroundColor3 = Color3.fromRGB(26, 21, 48)
UstSerit.BorderSizePixel = 0
UstSerit.ZIndex = 55
UstSerit.Parent = AnaKutu

local BaslikYazisi = Instance.new("TextLabel")
BaslikYazisi.Size = UDim2.new(1, -108, 1, 0)
BaslikYazisi.Position = UDim2.new(0, 12, 0, 0)
BaslikYazisi.BackgroundTransparency = 1
BaslikYazisi.Font = Enum.Font.GothamBold
BaslikYazisi.TextSize = 12
BaslikYazisi.TextColor3 = Color3.new(1, 1, 1)
BaslikYazisi.TextXAlignment = Enum.TextXAlignment.Left
BaslikYazisi.Text = "MOON MOBIL • AIMBOT & VURUS"
BaslikYazisi.ZIndex = 56
BaslikYazisi.Parent = UstSerit

local SimgeYapBtn = Instance.new("TextButton")
SimgeYapBtn.Size = UDim2.new(0, 28, 0, 24)
SimgeYapBtn.Position = UDim2.new(1, -68, 0.5, -12)
SimgeYapBtn.BackgroundColor3 = Color3.fromRGB(54, 44, 96)
SimgeYapBtn.Font = Enum.Font.GothamBold
SimgeYapBtn.TextSize = 13
SimgeYapBtn.TextColor3 = Color3.new(1, 1, 1)
SimgeYapBtn.Text = "-"
SimgeYapBtn.ZIndex = 56
SimgeYapBtn.Parent = UstSerit

local KapatBtn = Instance.new("TextButton")
KapatBtn.Size = UDim2.new(0, 28, 0, 24)
KapatBtn.Position = UDim2.new(1, -34, 0.5, -12)
KapatBtn.BackgroundColor3 = KIRMIZI
KapatBtn.Font = Enum.Font.GothamBold
KapatBtn.TextSize = 12
KapatBtn.TextColor3 = Color3.new(1, 1, 1)
KapatBtn.Text = "X"
KapatBtn.ZIndex = 56
KapatBtn.Parent = UstSerit

local TavanPanel = Instance.new("Frame")
TavanPanel.Size = UDim2.new(0, 230, 0, 28)
TavanPanel.Position = UDim2.new(0.5, -115, 0, 0)
TavanPanel.BackgroundColor3 = Color3.fromRGB(26, 21, 48)
TavanPanel.BorderSizePixel = 0
TavanPanel.Visible = false
TavanPanel.ZIndex = 140
TavanPanel.Parent = ScreenGui
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = TavanPanel local s = Instance.new("UIStroke") s.Thickness = 1.6 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = TavanPanel end

local TavanTetikBtn = Instance.new("TextButton")
TavanTetikBtn.Size = UDim2.new(1, 0, 1, 0)
TavanTetikBtn.BackgroundTransparency = 1
TavanTetikBtn.Font = Enum.Font.GothamBold
TavanTetikBtn.TextSize = 11
TavanTetikBtn.TextColor3 = Color3.new(1, 1, 1)
TavanTetikBtn.Text = "TAVAN • AC / KAPAT"
TavanTetikBtn.ZIndex = 141
TavanTetikBtn.Parent = TavanPanel

local TekButonAc = Instance.new("TextButton")
TekButonAc.Size = UDim2.new(0, 54, 0, 54)
TekButonAc.Position = UDim2.new(0.04, 0, 0.22, 0)
TekButonAc.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
TekButonAc.Font = Enum.Font.GothamBold
TekButonAc.TextSize = 11
TekButonAc.TextColor3 = Color3.new(1, 1, 1)
TekButonAc.Text = "AC"
TekButonAc.Visible = false
TekButonAc.ZIndex = 145
TekButonAc.Parent = ScreenGui
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = TekButonAc local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Color3.new(1, 1, 1) s.Parent = TekButonAc end

local SolSutun = Instance.new("ScrollingFrame")
SolSutun.Size = UDim2.new(0, 122, 1, -36)
SolSutun.Position = UDim2.new(0, 0, 0, 36)
SolSutun.BackgroundColor3 = Color3.fromRGB(21, 17, 40)
SolSutun.BorderSizePixel = 0
SolSutun.ScrollBarThickness = 3
SolSutun.AutomaticCanvasSize = Enum.AutomaticSize.Y
SolSutun.CanvasSize = UDim2.new(0, 0, 0, 0)
SolSutun.ZIndex = 53
SolSutun.Parent = AnaKutu
do
	local l = Instance.new("UIListLayout") l.Padding = UDim.new(0, 5) l.Parent = SolSutun
	local p = Instance.new("UIPadding") p.PaddingTop = UDim.new(0, 6) p.PaddingLeft = UDim.new(0, 6) p.PaddingRight = UDim.new(0, 6) p.Parent = SolSutun
end

local SagBolge = Instance.new("Frame")
SagBolge.Size = UDim2.new(1, -122, 1, -36)
SagBolge.Position = UDim2.new(0, 122, 0, 36)
SagBolge.BackgroundTransparency = 1
SagBolge.ClipsDescendants = true
SagBolge.ZIndex = 53
SagBolge.Parent = AnaKutu
local function GorunumSec(mod: "TamPanel" | "UstTavan" | "TekButon")
	Durum.Gorunum = mod
	local vp = Camera.ViewportSize
	if mod == "TamPanel" then
		TavanPanel.Visible = false
		TekButonAc.Visible = false
		AnaKutu.Visible = Durum.PanelAcik
		local w = math.clamp(vp.X - 24, 340, 600)
		local h = math.clamp(vp.Y - 46, 220, 340)
		AnaKutu.Size = UDim2.new(0, w, 0, Durum.SimgeDurum and 36 or h)
		AnaKutu.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
	elseif mod == "UstTavan" then
		TekButonAc.Visible = false
		TavanPanel.Visible = true
		AnaKutu.Visible = Durum.PanelAcik
		local w = math.clamp(vp.X - 16, 340, 620)
		local altY = TavanPanel.Size.Y.Offset + 6
		local h = math.clamp(vp.Y - altY - 12, 200, 325)
		AnaKutu.Size = UDim2.new(0, w, 0, Durum.SimgeDurum and 36 or h)
		AnaKutu.Position = UDim2.new(0.5, -w * 0.5, 0, altY)
	elseif mod == "TekButon" then
		TavanPanel.Visible = false
		TekButonAc.Visible = true
		AnaKutu.Visible = false
		Durum.PanelAcik = false
	end
end

local function ArayuzPatatesAyarla(aktif: boolean)
	Ayar.ArayuzPatates = aktif
	DesenKatman.Visible = not aktif
	Gradyan.Enabled = not aktif
	AnaKutu.BackgroundColor3 = aktif and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(16, 13, 30)
	UstSerit.BackgroundColor3 = aktif and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(26, 21, 48)
	SolSutun.BackgroundColor3 = aktif and Color3.fromRGB(34, 34, 34) or Color3.fromRGB(21, 17, 40)
	TavanPanel.BackgroundColor3 = aktif and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(26, 21, 48)
	ESPGuncelle()
	HitboxUygula()
	HafizaKaydet()
end

SimgeYapBtn.MouseButton1Click:Connect(function()
	Durum.SimgeDurum = not Durum.SimgeDurum
	SimgeYapBtn.Text = Durum.SimgeDurum and "+" or "-"
	GorunumSec(Durum.Gorunum)
end)

KapatBtn.MouseButton1Click:Connect(function()
	Durum.PanelAcik = false
	AnaKutu.Visible = false
	if Durum.Gorunum == "TamPanel" then
		TekButonAc.Visible = true
	end
end)

TavanTetikBtn.MouseButton1Click:Connect(function()
	Durum.PanelAcik = not Durum.PanelAcik
	AnaKutu.Visible = Durum.PanelAcik
end)

TekButonAc.MouseButton1Click:Connect(function()
	if Durum.Gorunum == "TekButon" then
		Durum.PanelAcik = not Durum.PanelAcik
		AnaKutu.Visible = Durum.PanelAcik
		if Durum.PanelAcik then
			local vp = Camera.ViewportSize
			local w = math.clamp(vp.X - 24, 340, 600)
			local h = math.clamp(vp.Y - 46, 220, 340)
			AnaKutu.Size = UDim2.new(0, w, 0, h)
			AnaKutu.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
		end
	else
		Durum.PanelAcik = true
		GorunumSec("TamPanel")
	end
end)

do local suruk = false local bx = 0 local boff = 0
	TavanTetikBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then suruk = true bx = inp.Position.X boff = TavanPanel.Position.X.Offset inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then suruk = false end end) end end)
	Bagla(UserInputService.InputChanged:Connect(function(inp) if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local maxX = math.max(0, Camera.ViewportSize.X - TavanPanel.Size.X.Offset) TavanPanel.Position = UDim2.new(0, math.clamp(boff + (inp.Position.X - bx), 0, maxX), 0, 0) end end))
end

do local suruk = false local bPos = Vector2.zero local bUi = UDim2.new()
	TekButonAc.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then suruk = true bPos = Vector2.new(inp.Position.X, inp.Position.Y) bUi = TekButonAc.Position inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then suruk = false end end) end end)
	Bagla(UserInputService.InputChanged:Connect(function(inp) if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local d = Vector2.new(inp.Position.X, inp.Position.Y) - bPos local vp = Camera.ViewportSize local sz = TekButonAc.Size.X.Offset TekButonAc.Position = UDim2.new(0, math.clamp(bUi.X.Offset + d.X, 0, math.max(0, vp.X - sz)), 0, math.clamp(bUi.Y.Offset + d.Y, 0, math.max(0, vp.Y - sz))) end end))
end

local SayfaMap = {} :: { [string]: ScrollingFrame }
local SekmeBtnMap = {} :: { [string]: TextButton }

local function SayfaKur(id: string, ad: string): ScrollingFrame
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 30, 64)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(190, 180, 220)
	b.Text = ad
	b.ZIndex = 54
	b.Parent = SolSutun
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = b end

	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, 0, 1, 0)
	sf.BackgroundTransparency = 1
	sf.ScrollBarThickness = 3
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	sf.Visible = false
	sf.ZIndex = 54
	sf.Parent = SagBolge
	do
		local l = Instance.new("UIListLayout") l.Padding = UDim.new(0, 6) l.Parent = sf
		local p = Instance.new("UIPadding") p.PaddingTop = UDim.new(0, 8) p.PaddingLeft = UDim.new(0, 8) p.PaddingRight = UDim.new(0, 8) p.PaddingBottom = UDim.new(0, 10) p.Parent = sf
	end

	b.MouseButton1Click:Connect(function()
		BaslikYazisi.Text = "MOON MOBIL • " .. ad:upper()
		for k, s in pairs(SayfaMap) do s.Visible = (k == id) end
		for k, btn in pairs(SekmeBtnMap) do
			local aktif = (k == id)
			btn.BackgroundColor3 = aktif and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(36, 30, 64)
			btn.TextColor3 = aktif and Color3.new(1, 1, 1) or Color3.fromRGB(190, 180, 220)
		end
	end)

	SayfaMap[id] = sf
	SekmeBtnMap[id] = b
	return sf
end

local function AnahtarYap(ebeveyn: Instance, ad: string, ilk: boolean, tusId: string?, tusKisa: string?, fn: (boolean) -> ())
	local d = ilk
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundColor3 = Color3.fromRGB(32, 27, 58)
	row.ZIndex = 55
	row.Parent = ebeveyn
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = row end

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, tusId and -118 or -68, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = ad
	lbl.ZIndex = 56
	lbl.Parent = row

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 52, 0, 24)
	sw.Position = UDim2.new(1, -58, 0.5, -12)
	sw.Font = Enum.Font.GothamBold
	sw.TextSize = 10
	sw.TextColor3 = Color3.new(1, 1, 1)
	sw.ZIndex = 56
	sw.Parent = row
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = sw end

	local function Guncelle(yeni: boolean, sessiz: boolean?)
		d = yeni
		sw.BackgroundColor3 = d and YESIL or KIRMIZI
		sw.Text = d and "ACIK" or "KAPALI"
		if tusId then OzelTusDurumYaz(tusId, d) end
		if not sessiz then HafizaKaydet() fn(d) end
	end

	if tusId and tusKisa then
		local ekBtn = Instance.new("TextButton")
		ekBtn.Size = UDim2.new(0, 52, 0, 24)
		ekBtn.Position = UDim2.new(1, -114, 0.5, -12)
		ekBtn.BackgroundColor3 = Color3.fromRGB(55, 45, 95)
		ekBtn.Font = Enum.Font.GothamBold
		ekBtn.TextSize = 10
		ekBtn.TextColor3 = Color3.fromRGB(125, 211, 252)
		ekBtn.Text = "+ TUS"
		ekBtn.ZIndex = 56
		ekBtn.Parent = row
		do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = ekBtn end
		ekBtn.MouseButton1Click:Connect(function() OzelTusEkle(tusId, tusKisa, d, function(y) Guncelle(y, false) end) end)
	end

	sw.MouseButton1Click:Connect(function() Guncelle(not d, false) end)
	Guncelle(ilk, true)
end
local function SecimYap(ebeveyn: Instance, ad: string, liste: { string }, ilk: string, fn: (string) -> ())
	local idx = 1
	for i, v in ipairs(liste) do if v == ilk then idx = i break end end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(42, 35, 76)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = ad .. ": " .. liste[idx]
	btn.ZIndex = 56
	btn.Parent = ebeveyn
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = btn end
	btn.MouseButton1Click:Connect(function() idx = (idx % #liste) + 1 local sec = liste[idx] btn.Text = ad .. ": " .. sec HafizaKaydet() fn(sec) end)
end

local function KaydirYap(ebeveyn: Instance, ad: string, minV: number, maxV: number, ilk: number, fn: (number) -> ())
	local val = ilk
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 42)
	box.BackgroundColor3 = Color3.fromRGB(32, 27, 58)
	box.ZIndex = 55
	box.Parent = ebeveyn
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = box end

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -14, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, 2)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = ad .. ": " .. tostring(val)
	lbl.ZIndex = 56
	lbl.Parent = box

	local ray = Instance.new("TextButton")
	ray.Size = UDim2.new(1, -16, 0, 9)
	ray.Position = UDim2.new(0, 8, 0, 25)
	ray.BackgroundColor3 = Color3.fromRGB(16, 14, 28)
	ray.Text = ""
	ray.ZIndex = 56
	ray.Parent = box
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = ray end

	local dolgu = Instance.new("Frame")
	dolgu.Size = UDim2.new(math.clamp((val - minV) / math.max(0.001, maxV - minV), 0, 1), 0, 1, 0)
	dolgu.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	dolgu.BorderSizePixel = 0
	dolgu.ZIndex = 57
	dolgu.Parent = ray
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = dolgu end

	local suruk = false
	local function AyarlaX(x: number)
		local oran = math.clamp((x - ray.AbsolutePosition.X) / math.max(1, ray.AbsoluteSize.X), 0, 1)
		val = math.floor((minV + (maxV - minV) * oran) + 0.5)
		dolgu.Size = UDim2.new(oran, 0, 1, 0)
		lbl.Text = ad .. ": " .. tostring(val)
		HafizaKaydet()
		fn(val)
	end

	ray.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then suruk = true AyarlaX(inp.Position.X) end end)
	Bagla(UserInputService.InputChanged:Connect(function(inp) if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then AyarlaX(inp.Position.X) end end))
	Bagla(UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then suruk = false end end))
end

local function ButonYap(ebeveyn: Instance, ad: string, vurgu: boolean, fn: () -> ())
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = vurgu and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(42, 35, 76)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = ad
	btn.ZIndex = 56
	btn.Parent = ebeveyn
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = btn end
	btn.MouseButton1Click:Connect(fn)
end

do local s = SayfaKur("Aimbot", "Aimbot & Vurus")
	SecimYap(s, "Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, Ayar.HedefTuru, function(v) Ayar.HedefTuru = v HitboxUygula() end)
	SecimYap(s, "Aimbot Turu", { "Normal", "Daire", "Acikta" }, Ayar.AimbotTur, function(v) Ayar.AimbotTur = v KilitliHedefModel = nil end)
	AnahtarYap(s, "Aimbot Ac / Kapat", Ayar.AimbotAcik, "aimbot", "AIMBOT", function(v) Ayar.AimbotAcik = v if not v then KilitliHedefModel = nil end end)
	SecimYap(s, "Aimbot Parca", { "Kafa", "Govde" }, Ayar.AimbotParca, function(v) Ayar.AimbotParca = v end)
	KaydirYap(s, "Uzaklik Siniri", 50, 1200, Ayar.AimbotMesafe, function(v) Ayar.AimbotMesafe = v end)
	KaydirYap(s, "Yumusak / Keskin Hiz (0-100)", 0, 100, Ayar.AimbotKeskinlik, function(v) Ayar.AimbotKeskinlik = v end)
	KaydirYap(s, "Daire Boyutu", 40, 300, Ayar.DaireCap, function(v) Ayar.DaireCap = v end)
	AnahtarYap(s, "Hareketli Hedef Tahmini", Ayar.TahminAcik, "tahmin", "TAHMIN", function(v) Ayar.TahminAcik = v end)
	AnahtarYap(s, "Tetik (Otomatik Vurus)", Ayar.TetikAcik, "tetik", "TETIK", function(v) Ayar.TetikAcik = v end)
	SecimYap(s, "Crosshair Sekli", { "Nokta", "Arti", "Halka" }, Ayar.CrosshairSekil, function(v) Ayar.CrosshairSekil = v CrosshairYenile() end)
	AnahtarYap(s, "Crosshair & Merkez Atis", Ayar.CrosshairAcik, "crosshair", "CROSS", function(v) Ayar.CrosshairAcik = v CrosshairYenile() end)
	AnahtarYap(s, "Silent Aim", Ayar.SilentAcik, "silent", "SILENT", function(v) Ayar.SilentAcik = v end)
	SecimYap(s, "Silent Parca", { "Kafa", "Govde" }, Ayar.SilentParca, function(v) Ayar.SilentParca = v end)
	AnahtarYap(s, "Hitbox Buyut", Ayar.HitboxAcik, "hitbox", "HITBOX", function(v) Ayar.HitboxAcik = v HitboxUygula() end)
	KaydirYap(s, "Hitbox Boyutu", 2, 25, Ayar.HitboxBoyut, function(v) Ayar.HitboxBoyut = v HitboxUygula() end)
	KaydirYap(s, "Mermi / Bicak Hizi (1-100)", 1, 100, Ayar.MermiBicakHiz, function(v) Ayar.MermiBicakHiz = v end)
end

do local s = SayfaKur("Hareket", "Hareket & Araba")
	AnahtarYap(s, "Normal Fly", Ayar.NormalFlyAcik, "nfly", "FLY", function(v) NormalFlyAyarla(v) end)
	KaydirYap(s, "Normal Fly Hizi", 15, 250, Ayar.NormalFlyHiz, function(v) Ayar.NormalFlyHiz = v end)
	ButonYap(s, "Fly Yukari (+)", false, function() Durum.DikeyYon = (Durum.DikeyYon == 1) and 0 or 1 end)
	ButonYap(s, "Fly Asagi (-)", false, function() Durum.DikeyYon = (Durum.DikeyYon == -1) and 0 or -1 end)
	AnahtarYap(s, "Car Fly", Ayar.CarFlyAcik, "cfly", "CAR FLY", function(v) CarFlyAyarla(v) end)
	KaydirYap(s, "Car Fly Hizi", 20, 300, Ayar.CarFlyHiz, function(v) Ayar.CarFlyHiz = v end)
	KaydirYap(s, "Araba Hizi", 20, 350, Ayar.ArabaHizi, function(v) Ayar.ArabaHizi = v end)
	ButonYap(s, "Araba Hizini Uygula", true, function() ArabaHiziUygula() end)
	AnahtarYap(s, "Speed", Ayar.SpeedAcik, "speed", "SPEED", function(v) Ayar.SpeedAcik = v FizikVeBoyutGuncelle() end)
	KaydirYap(s, "Speed Degeri", 16, 200, Ayar.SpeedDeger, function(v) Ayar.SpeedDeger = v FizikVeBoyutGuncelle() end)
	AnahtarYap(s, "Jump", Ayar.JumpAcik, "jump", "JUMP", function(v) Ayar.JumpAcik = v FizikVeBoyutGuncelle() end)
	KaydirYap(s, "Jump Degeri", 50, 250, Ayar.JumpDeger, function(v) Ayar.JumpDeger = v FizikVeBoyutGuncelle() end)
	AnahtarYap(s, "Gravity", Ayar.GravityAcik, "grav", "GRAV", function(v) Ayar.GravityAcik = v FizikVeBoyutGuncelle() end)
	KaydirYap(s, "Gravity Degeri", 10, 300, math.floor(Ayar.GravityDeger), function(v) Ayar.GravityDeger = v FizikVeBoyutGuncelle() end)
	AnahtarYap(s, "Boyut Degistir", Ayar.BoyutAcik, "boyut", "BOYUT", function(v) Ayar.BoyutAcik = v FizikVeBoyutGuncelle() end)
	KaydirYap(s, "Boyut Orani (%10-%500)", 10, 500, math.floor(Ayar.BoyutOran * 100), function(v) Ayar.BoyutOran = math.clamp(v / 100, 0.1, 5.0) FizikVeBoyutGuncelle() end)
end

do local s = SayfaKur("ESP", "ESP Ayarlari")
	AnahtarYap(s, "ESP Ac / Kapat", Ayar.EspAcik, "esp", "ESP", function(v) Ayar.EspAcik = v ESPGuncelle() end)
	SecimYap(s, "ESP Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, Ayar.HedefTuru, function(v) Ayar.HedefTuru = v ESPGuncelle() end)
	AnahtarYap(s, "Kutu ESP", Ayar.EspKutu, nil, nil, function(v) Ayar.EspKutu = v ESPGuncelle() end)
	AnahtarYap(s, "Isim ESP", Ayar.EspIsim, nil, nil, function(v) Ayar.EspIsim = v ESPGuncelle() end)
	AnahtarYap(s, "Mesafe ESP", Ayar.EspMesafe, nil, nil, function(v) Ayar.EspMesafe = v ESPGuncelle() end)
	AnahtarYap(s, "Can Bari ESP", Ayar.EspCan, nil, nil, function(v) Ayar.EspCan = v ESPGuncelle() end)
	AnahtarYap(s, "Cizgi ESP", Ayar.EspCizgi, nil, nil, function(v) Ayar.EspCizgi = v ESPGuncelle() end)
	AnahtarYap(s, "Vurgu ESP", Ayar.EspVurgu, nil, nil, function(v) Ayar.EspVurgu = v ESPGuncelle() end)
	KaydirYap(s, "ESP Mesafe Siniri", 100, 2500, Ayar.EspMesafeSiniri, function(v) Ayar.EspMesafeSiniri = v ESPGuncelle() end)
end

do local s = SayfaKur("Teleport", "Teleport")
	local seciliPlr: Player? = nil
	local secBtn = Instance.new("TextButton")
	secBtn.Size = UDim2.new(1, 0, 0, 34)
	secBtn.BackgroundColor3 = Color3.fromRGB(42, 35, 76)
	secBtn.Font = Enum.Font.GothamBold
	secBtn.TextSize = 11
	secBtn.TextColor3 = Color3.new(1, 1, 1)
	secBtn.Text = "Oyuncu Sec"
	secBtn.ZIndex = 56
	secBtn.Parent = s
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = secBtn end

	local listeKutu = Instance.new("Frame")
	listeKutu.Size = UDim2.new(1, 0, 0, 0)
	listeKutu.AutomaticSize = Enum.AutomaticSize.Y
	listeKutu.BackgroundColor3 = Color3.fromRGB(24, 20, 46)
	listeKutu.Visible = false
	listeKutu.ZIndex = 56
	listeKutu.Parent = s
	do
		local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = listeKutu
		local l = Instance.new("UIListLayout") l.Padding = UDim.new(0, 4) l.Parent = listeKutu
		local p = Instance.new("UIPadding") p.PaddingTop = UDim.new(0, 5) p.PaddingBottom = UDim.new(0, 5) p.PaddingLeft = UDim.new(0, 5) p.PaddingRight = UDim.new(0, 5) p.Parent = listeKutu
	end

	local function OyuncuListele()
		for _, ch in ipairs(listeKutu:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 30)
				b.BackgroundColor3 = Color3.fromRGB(48, 40, 88)
				b.Font = Enum.Font.GothamMedium
				b.TextSize = 11
				b.TextColor3 = Color3.new(1, 1, 1)
				b.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
				b.ZIndex = 57
				b.Parent = listeKutu
				do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = b end
				b.MouseButton1Click:Connect(function()
					seciliPlr = plr
					secBtn.Text = "Secili: " .. plr.DisplayName .. " (" .. plr.Name .. ")"
					listeKutu.Visible = false
				end)
			end
		end
	end

	secBtn.MouseButton1Click:Connect(function() listeKutu.Visible = not listeKutu.Visible if listeKutu.Visible then OyuncuListele() end end)
	ButonYap(s, "Secili Oyuncuya Isinlan", true, function() if seciliPlr and seciliPlr.Character and not OluKontrol(seciliPlr.Character) then local hrp = seciliPlr.Character:FindFirstChild("HumanoidRootPart") :: BasePart? if hrp then KonumaIsinlan(hrp.CFrame * CFrame.new(0, 0, 4)) end end end)
	ButonYap(s, "En Yakin Oyuncuya Isinlan", true, function() EnYakinOyuncuIsinlan() end)
	ButonYap(s, "En Yakin Bot / Nextbota Isinlan", true, function() EnYakinBotNextbotIsinlan() end)
	ButonYap(s, "Tikladigim Yere Isinlan", false, function() Durum.TiklaIsinlanMod = true AnaKutu.Visible = false Durum.PanelAcik = false end)
	ButonYap(s, "Konumu Kopyala", false, function() KonumKopyala() end)
	ButonYap(s, "Kopyalanan Konuma Isinlan", false, function() KopyaliKonumaIsinlan() end)
end

do local s = SayfaKur("Duzen", "Duzen & Dunya")
	SecimYap(s, "Gorunum Modu", { "TamPanel", "UstTavan", "TekButon" }, Durum.Gorunum, function(m) GorunumSec(m :: "TamPanel" | "UstTavan" | "TekButon") end)
	KaydirYap(s, "Ust Tavan Genisligi", 150, 460, TavanPanel.Size.X.Offset, function(v) TavanPanel.Size = UDim2.new(0, v, 0, TavanPanel.Size.Y.Offset) TavanPanel.Position = UDim2.new(0.5, -v * 0.5, 0, 0) end)
	KaydirYap(s, "Ust Tavan Yuksekligi", 24, 52, TavanPanel.Size.Y.Offset, function(v) TavanPanel.Size = UDim2.new(0, TavanPanel.Size.X.Offset, 0, v) if Durum.Gorunum == "UstTavan" then GorunumSec("UstTavan") end end)
	KaydirYap(s, "Tek Buton Boyutu", 38, 96, TekButonAc.Size.X.Offset, function(v) TekButonAc.Size = UDim2.new(0, v, 0, v) end)
	AnahtarYap(s, "Arayuz Patates Mod", Ayar.ArayuzPatates, "apatates", "UI PATATES", function(v) ArayuzPatatesAyarla(v) end)
	AnahtarYap(s, "Oyun Ici Patates Mod (No Lag)", Ayar.OyunPatates, "opatates", "NO LAG", function(v) OyunPatatesAyarla(v) end)
	AnahtarYap(s, "Golge Silici", Ayar.GolgeSiliciAcik, "golge", "GOLGE", function(v) GolgeSiliciAyarla(v) end)
	KaydirYap(s, "Aydinlik Ayari (0-100)", 0, 100, Ayar.Aydinlik, function(v) AydinlikAyarla(v) end)
	ButonYap(s, "Ayarlari Kaydet", false, function() HafizaKaydet() end)
end

SayfaMap["Aimbot"].Visible = true
SekmeBtnMap["Aimbot"].BackgroundColor3 = Color3.fromRGB(168, 85, 247)
SekmeBtnMap["Aimbot"].TextColor3 = Color3.new(1, 1, 1)
GorunumSec("TamPanel")
FizikVeBoyutGuncelle()
if Ayar.NormalFlyAcik then NormalFlyAyarla(true) end
if Ayar.CarFlyAcik then CarFlyAyarla(true) end
if Ayar.HitboxAcik then HitboxUygula() end
if Ayar.OyunPatates then OyunPatatesAyarla(true) end
if Ayar.GolgeSiliciAcik then GolgeSiliciAyarla(true) end
AydinlikAyarla(Ayar.Aydinlik)
ArayuzPatatesAyarla(Ayar.ArayuzPatates)

Bagla(LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.25)
	FizikVeBoyutGuncelle()
	if Ayar.NormalFlyAcik then NormalFlyAyarla(true) end
	if Ayar.CarFlyAcik then CarFlyAyarla(true) end
	if Ayar.HitboxAcik then HitboxUygula() end
end))
