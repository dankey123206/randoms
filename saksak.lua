--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local EskiUI = PlayerGui:FindFirstChild("MobilKontrol_UI")
if EskiUI then EskiUI:Destroy() end

local DOSYA_ADI = "mobil_ayar_hafizasi.json"

local VarsayilanAyar = {
	HedefTuru = "Hepsi",
	AimbotAcik = false,
	AimbotTur = "Normal",
	AimbotParca = "Kafa",
	AimbotMesafe = 500,
	AimbotKeskinlik = 60,
	DaireYaricap = 135,
	TahminAktif = false,
	TetikAktif = false,
	CrosshairAcik = false,
	CrosshairTip = "Nokta",
	SilentAcik = false,
	SilentParca = "Kafa",
	HitboxAcik = false,
	HitboxBoyut = 7,
	HitboxParca = "Govde",
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
	OyunPatatesAcik = false,
	GolgeSiliciAcik = false,
	AydinlikDeger = 50,
	KopyaliKonum = nil :: { number }?,
}

local function Kopyala(t: any): any
	if type(t) ~= "table" then return t end
	local k = {}
	for i, v in pairs(t) do k[i] = Kopyala(v) end
	return k
end

local Ayar = Kopyala(VarsayilanAyar)
local OturumHafiza: any = nil

local function AyarKaydet()
	OturumHafiza = Kopyala(Ayar)
	pcall(function()
		if type(writefile) == "function" then
			writefile(DOSYA_ADI, HttpService:JSONEncode(Ayar))
		end
	end)
end

local function AyarYukle()
	local ok = false
	pcall(function()
		if type(isfile) == "function" and type(readfile) == "function" and isfile(DOSYA_ADI) then
			local d = HttpService:JSONDecode(readfile(DOSYA_ADI))
			if type(d) == "table" then
				for k, v in pairs(d) do
					if Ayar[k] ~= nil then Ayar[k] = v end
				end
				ok = true
			end
		end
	end)
	if not ok and type(OturumHafiza) == "table" then
		for k, v in pairs(OturumHafiza) do
			if Ayar[k] ~= nil then Ayar[k] = v end
		end
	end
end

AyarYukle()

local Sistem = {
	Acik = true,
	SimgeMod = false,
	GorunumModu = "TamPanel" :: "TamPanel" | "UstTavan" | "TekButon",
	PatatesMod = false,
	MermiBicakHizCarpan = 50,
	TetikBekleme = 0.14,
	SonTetikZamani = 0,
	GecmisKonumlar = {} :: { CFrame },
	Renkler = {
		Acik = Color3.fromRGB(34, 197, 94),
		VurguIkinci = Color3.fromRGB(56, 189, 248),
	},
}

local Baglantilar = {} :: { RBXScriptConnection }
local function BaglantiEkle(c: RBXScriptConnection): RBXScriptConnection
	table.insert(Baglantilar, c)
	return c
end
local function Karakter(): (Model?, Humanoid?, BasePart?)
	local ch = LocalPlayer.Character
	if not ch then return nil, nil, nil end
	return ch, ch:FindFirstChildOfClass("Humanoid"), ch:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function TakimArkadasimi(model: Model): boolean
	local plr = Players:GetPlayerFromCharacter(model)
	if not plr or plr == LocalPlayer then return false end
	if LocalPlayer.Team ~= nil and plr.Team ~= nil then
		return LocalPlayer.Team == plr.Team
	end
	return false
end

local function OluMu(model: Model): boolean
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return true end
	return hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead
end

local function HedefGecerliMi(model: Model, turOverride: string?): boolean
	if not model or not model.Parent or model == LocalPlayer.Character then return false end
	if TakimArkadasimi(model) then return false end
	if OluMu(model) then return false end
	local tur = turOverride or Ayar.HedefTuru
	local oyuncuMu = Players:GetPlayerFromCharacter(model) ~= nil
	if tur == "Hepsi" then return true
	elseif tur == "Oyuncu Gercek" then return oyuncuMu
	elseif tur == "Bot" then return not oyuncuMu end
	return false
end

local function ParcaAl(model: Model, parcaTip: string): BasePart?
	if parcaTip == "Kafa" then
		local k = model:FindFirstChild("Head")
		if k and k:IsA("BasePart") then return k end
	end
	local g = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model.PrimaryPart
	if g and g:IsA("BasePart") then return g end
	return nil
end

local function EngelVarMi(hedefPos: Vector3, model: Model): boolean
	local origin = Camera.CFrame.Position
	local dir = hedefPos - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local list = {} :: { Instance }
	if LocalPlayer.Character then table.insert(list, LocalPlayer.Character) end
	table.insert(list, model)
	params.FilterDescendantsInstances = list
	return Workspace:Raycast(origin, dir, params) ~= nil
end

local flyBV: BodyVelocity? = nil
local flyBG: BodyGyro? = nil
local carBV: BodyVelocity? = nil
local carBG: BodyGyro? = nil
local dikeyYon = 0

local function AracKoltugu(): VehicleSeat?
	local _, hum, _ = Karakter()
	if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
		return hum.SeatPart
	end
	return nil
end

local function NormalFlyAyarla(aktif: boolean)
	Ayar.NormalFlyAcik = aktif
	local _, hum, hrp = Karakter()
	if not hum or not hrp then return end
	if aktif then
		hum.PlatformStand = true
		if not flyBV then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "KorunanFlyBV"
			bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
			bv.Velocity = Vector3.zero
			bv.Parent = hrp
			flyBV = bv
		end
		if not flyBG then
			local bg = Instance.new("BodyGyro")
			bg.Name = "KorunanFlyBG"
			bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
			bg.P = 9e4
			bg.CFrame = Camera.CFrame
			bg.Parent = hrp
			flyBG = bg
		end
	else
		hum.PlatformStand = false
		if flyBV then flyBV:Destroy() flyBV = nil end
		if flyBG then flyBG:Destroy() flyBG = nil end
		dikeyYon = 0
	end
	AyarKaydet()
end
local function CarFlyAyarla(aktif: boolean)
	Ayar.CarFlyAcik = aktif
	local koltuk = AracKoltugu()
	if not aktif or not koltuk then
		if carBV then carBV:Destroy() carBV = nil end
		if carBG then carBG:Destroy() carBG = nil end
		AyarKaydet()
		return
	end
	if not carBV then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "KorunanCarFlyBV"
		bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
		bv.Velocity = Vector3.zero
		bv.Parent = koltuk
		carBV = bv
	end
	if not carBG then
		local bg = Instance.new("BodyGyro")
		bg.Name = "KorunanCarFlyBG"
		bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
		bg.P = 9e4
		bg.CFrame = Camera.CFrame
		bg.Parent = koltuk
		carBG = bg
	end
	AyarKaydet()
end

local function ArabaHiziniUygula(): boolean
	local koltuk = AracKoltugu()
	if not koltuk then return false end
	local look = koltuk.CFrame.LookVector
	local yatay = Vector3.new(look.X, 0, look.Z)
	if yatay.Magnitude < 0.05 then
		local cLook = Camera.CFrame.LookVector
		yatay = Vector3.new(cLook.X, 0, cLook.Z)
	end
	if yatay.Magnitude > 0.01 then
		koltuk.AssemblyLinearVelocity = yatay.Unit * Ayar.ArabaHizi + Vector3.new(0, koltuk.AssemblyLinearVelocity.Y, 0)
	end
	return true
end

local function FizikVeBoyutUygula()
	local ch, hum, _ = Karakter()
	if hum then
		hum.WalkSpeed = Ayar.SpeedAcik and Ayar.SpeedDeger or 16
		hum.UseJumpPower = true
		hum.JumpPower = Ayar.JumpAcik and Ayar.JumpDeger or 50
	end
	Workspace.Gravity = Ayar.GravityAcik and Ayar.GravityDeger or 196.2
	if ch and hum then
		local oran = Ayar.BoyutAcik and Ayar.BoyutOran or 1.0
		local r15 = false
		for _, ad in ipairs({ "BodyWidthScale", "BodyHeightScale", "BodyDepthScale", "HeadScale" }) do
			local nv = hum:FindFirstChild(ad)
			if nv and nv:IsA("NumberValue") then
				nv.Value = oran
				r15 = true
			end
		end
		if not r15 then
			pcall(function() ch:ScaleTo(oran) end)
		end
	end
end

local CrosshairMerkez: Vector2? = nil
local KilitliAimbotHedef: Model? = nil
local AktifSilentHedef: BasePart? = nil
local HitboxYedek = {} :: { [BasePart]: { Size: Vector3, Transparency: number, CanCollide: boolean, Massless: boolean, Material: Enum.Material } }

local function KeskinlikCarpani(keskinlik: number, dt: number): number
	local k = math.clamp(keskinlik, 0, 100)
	if k >= 99 then return 1 end
	local hiz = 1.6 + ((k / 100) ^ 1.35) * 42
	return math.clamp(1 - math.exp(-hiz * dt), 0.02, 1)
end

local function TahminNoktasi(parca: BasePart): Vector3
	if not Ayar.TahminAktif then return parca.Position end
	return parca.Position + (parca.AssemblyLinearVelocity * 0.14)
end

local function ReferansEkranNoktasi(): Vector2
	if Ayar.CrosshairAcik and CrosshairMerkez then return CrosshairMerkez end
	local vp = Camera.ViewportSize
	return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end
local function AimbotHedefSec(): BasePart?
	if not Ayar.AimbotAcik then
		KilitliAimbotHedef = nil
		return nil
	end
	local _, _, benHRP = Karakter()
	if not benHRP then return nil end
	local tur = Ayar.AimbotTur
	local merkez = ReferansEkranNoktasi()

	local function UygunMu(model: Model): BasePart?
		if not HedefGecerliMi(model, Ayar.HedefTuru) then return nil end
		local parca = ParcaAl(model, Ayar.AimbotParca)
		if not parca then return nil end
		if (parca.Position - benHRP.Position).Magnitude > Ayar.AimbotMesafe then return nil end
		local nokta = TahminNoktasi(parca)
		local ekPos, gorunur = Camera:WorldToViewportPoint(nokta)
		if not gorunur or ekPos.Z <= 0 then return nil end
		if tur == "Daire" then
			if (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude > Ayar.DaireYaricap then return nil end
		elseif tur == "Acikta" then
			if EngelVarMi(nokta, model) then return nil end
		end
		return parca
	end

	if KilitliAimbotHedef then
		local mevcut = UygunMu(KilitliAimbotHedef)
		if mevcut then return mevcut end
		KilitliAimbotHedef = nil
	end

	local enIyiParca: BasePart? = nil
	local enIyiModel: Model? = nil
	local enKucukSkor = math.huge
	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") then
			local p = UygunMu(nesne)
			if p then
				local ekPos = Camera:WorldToViewportPoint(TahminNoktasi(p))
				local ekranFark = (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude
				local skor = (tur == "Normal") and (p.Position - benHRP.Position).Magnitude or ekranFark
				if skor < enKucukSkor then
					enKucukSkor = skor
					enIyiParca = p
					enIyiModel = nesne
				end
			end
		end
	end
	KilitliAimbotHedef = enIyiModel
	return enIyiParca
end

local function TetikKontrol(hedefParca: BasePart?)
	if not Ayar.TetikAktif or not hedefParca then return end
	local simdi = os.clock()
	if simdi - Sistem.SonTetikZamani < Sistem.TetikBekleme then return end
	local merkez = ReferansEkranNoktasi()
	local ekPos, gor = Camera:WorldToViewportPoint(hedefParca.Position)
	if not gor or ekPos.Z <= 0 then return end
	local yaricap = (Ayar.AimbotTur == "Daire") and Ayar.DaireYaricap or 45
	if (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude <= yaricap then
		Sistem.SonTetikZamani = simdi
		local arac = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if arac then pcall(function() arac:Activate() end) end
	end
end

local function SilentHedefBul(): BasePart?
	if not Ayar.SilentAcik then
		AktifSilentHedef = nil
		return nil
	end
	local _, _, benHRP = Karakter()
	if not benHRP then return nil end
	local merkez = ReferansEkranNoktasi()
	local enIyi: BasePart? = nil
	local enKucuk = math.huge
	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefGecerliMi(nesne, Ayar.HedefTuru) then
			local p = ParcaAl(nesne, Ayar.SilentParca)
			if p and (p.Position - benHRP.Position).Magnitude <= Ayar.AimbotMesafe then
				local nokta = TahminNoktasi(p)
				local ekPos, gor = Camera:WorldToViewportPoint(nokta)
				if gor and ekPos.Z > 0 then
					local fark = (Vector2.new(ekPos.X, ekPos.Y) - merkez).Magnitude
					if (Ayar.AimbotTur ~= "Daire" or fark <= Ayar.DaireYaricap) and (Ayar.AimbotTur ~= "Acikta" or not EngelVarMi(nokta, nesne)) then
						if fark < enKucuk then
							enKucuk = fark
							enIyi = p
						end
					end
				end
			end
		end
	end
	AktifSilentHedef = enIyi
	return enIyi
end
local function CrosshairMerkezindenNisanla(dokunmaEkranPos: Vector2?)
	local hedefNokta: Vector3? = nil
	if Ayar.SilentAcik then
		local sParca = SilentHedefBul()
		if sParca then hedefNokta = TahminNoktasi(sParca) end
	end
	if not hedefNokta and Ayar.CrosshairAcik then
		local merkez = CrosshairMerkez or Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
		local ray = Camera:ViewportPointToRay(merkez.X, merkez.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		if LocalPlayer.Character then params.FilterDescendantsInstances = { LocalPlayer.Character } end
		local sonuc = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
		hedefNokta = sonuc and sonuc.Position or (ray.Origin + ray.Direction * 350)
	end
	if hedefNokta then
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, hedefNokta)
	elseif dokunmaEkranPos then
		local ray = Camera:ViewportPointToRay(dokunmaEkranPos.X, dokunmaEkranPos.Y)
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, ray.Origin + ray.Direction * 250)
	end
end

local function HitboxTemizle()
	for parca, veri in pairs(HitboxYedek) do
		if parca and parca.Parent then
			parca.Size = veri.Size
			parca.Transparency = veri.Transparency
			parca.CanCollide = veri.CanCollide
			parca.Massless = veri.Massless
			parca.Material = veri.Material
		end
	end
	table.clear(HitboxYedek)
end

local function HitboxGuncelle()
	if not Ayar.HitboxAcik then HitboxTemizle() return end
	for _, nesne in ipairs(Workspace:GetDescendants()) do
		if nesne:IsA("Model") and HedefGecerliMi(nesne, Ayar.HedefTuru) then
			local adaylar = {} :: { BasePart }
			if Ayar.HitboxParca == "Kafa" or Ayar.HitboxParca == "Ikisi" then
				local k = nesne:FindFirstChild("Head")
				if k and k:IsA("BasePart") then table.insert(adaylar, k) end
			end
			if Ayar.HitboxParca == "Govde" or Ayar.HitboxParca == "Ikisi" then
				local g = nesne:FindFirstChild("HumanoidRootPart") or nesne:FindFirstChild("Torso") or nesne:FindFirstChild("UpperTorso")
				if g and g:IsA("BasePart") then table.insert(adaylar, g) end
			end
			for _, p in ipairs(adaylar) do
				if not HitboxYedek[p] then
					HitboxYedek[p] = { Size = p.Size, Transparency = p.Transparency, CanCollide = p.CanCollide, Massless = p.Massless, Material = p.Material }
				end
				p.Size = Vector3.new(Ayar.HitboxBoyut, Ayar.HitboxBoyut, Ayar.HitboxBoyut)
				p.CanCollide = false
				p.Massless = true
				p.Transparency = Sistem.PatatesMod and 0.8 or 0.65
				p.Material = Enum.Material.ForceField
			end
		end
	end
end

BaglantiEkle(Workspace.DescendantAdded:Connect(function(nesne)
	if Sistem.MermiBicakHizCarpan == 50 then return end
	local carpan = math.clamp(Sistem.MermiBicakHizCarpan / 50, 0.1, 4.0)
	if nesne:IsA("BasePart") then
		task.defer(function()
			if nesne and nesne.Parent and nesne.AssemblyLinearVelocity.Magnitude > 4 then
				nesne.AssemblyLinearVelocity = nesne.AssemblyLinearVelocity * carpan
			end
		end)
	elseif nesne:IsA("LinearVelocity") then
		nesne.VectorVelocity = nesne.VectorVelocity * carpan
	elseif nesne:IsA("BodyVelocity") then
		nesne.Velocity = nesne.Velocity * carpan
	end
end))

type ESPNesne = { BB: BillboardGui, Yazi: TextLabel, CanArka: Frame, CanDolgu: Frame, Kutu: Frame, KutuKenar: UIStroke, Cizgi: Frame, Vurgu: Highlight? }
local ESPKartlari = {} :: { [Model]: ESPNesne }
local KopyalananCFrame: CFrame? = nil
if type(Ayar.KopyaliKonum) == "table" and #Ayar.KopyaliKonum == 3 then
	KopyalananCFrame = CFrame.new(Ayar.KopyaliKonum[1], Ayar.KopyaliKonum[2], Ayar.KopyaliKonum[3])
end

local function ESPKartSil(model: Model)
	local k = ESPKartlari[model]
	if not k then return end
	if k.BB then k.BB:Destroy() end
	if k.Kutu then k.Kutu:Destroy() end
	if k.Cizgi then k.Cizgi:Destroy() end
	if k.Vurgu then k.Vurgu:Destroy() end
	ESPKartlari[model] = nil
end
local function TumESPKartlariSil()
	for m, _ in pairs(ESPKartlari) do ESPKartSil(m) end
end

local function ESPKartOlustur(model: Model, kok: BasePart): ESPNesne
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_Bilgi"
	bb.Adornee = kok
	bb.Size = UDim2.new(0, 165, 0, 44)
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
	canArka.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	canArka.BorderSizePixel = 0
	canArka.Parent = bb

	local canDolgu = Instance.new("Frame")
	canDolgu.Size = UDim2.new(1, 0, 1, 0)
	canDolgu.BackgroundColor3 = Sistem.Renkler.Acik
	canDolgu.BorderSizePixel = 0
	canDolgu.Parent = canArka

	local kutu = Instance.new("Frame")
	kutu.Name = "ESP_Kutu"
	kutu.BackgroundTransparency = 1
	kutu.Visible = false
	kutu.ZIndex = 40
	kutu.Parent = PlayerGui

	local kutuKenar = Instance.new("UIStroke")
	kutuKenar.Thickness = 1.6
	kutuKenar.Parent = kutu

	local cizgi = Instance.new("Frame")
	cizgi.Name = "ESP_Cizgi"
	cizgi.AnchorPoint = Vector2.new(0.5, 0.5)
	cizgi.BorderSizePixel = 0
	cizgi.Visible = false
	cizgi.ZIndex = 39
	cizgi.Parent = PlayerGui

	local vurgu: Highlight? = nil
	if not Sistem.PatatesMod then
		local h = Instance.new("Highlight")
		h.Adornee = model
		h.FillTransparency = 0.72
		h.OutlineTransparency = 0.1
		h.Parent = PlayerGui
		vurgu = h
	end

	local nesne: ESPNesne = { BB = bb, Yazi = yazi, CanArka = canArka, CanDolgu = canDolgu, Kutu = kutu, KutuKenar = kutuKenar, Cizgi = cizgi, Vurgu = vurgu }
	ESPKartlari[model] = nesne
	return nesne
end

local function ESPYenile()
	if not Ayar.EspAcik then
		if next(ESPKartlari) ~= nil then TumESPKartlariSil() end
		return
	end
	local _, _, benHRP = Karakter()
	local benKonum = benHRP and benHRP.Position or Camera.CFrame.Position
	local gorulen = {} :: { [Model]: boolean }

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and HedefGecerliMi(obj, Ayar.HedefTuru) then
			local kok = ParcaAl(obj, "Govde")
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if kok and hum then
				local mesafe = (kok.Position - benKonum).Magnitude
				if mesafe <= Ayar.EspMesafeSiniri then
					gorulen[obj] = true
					local kart = ESPKartlari[obj] or ESPKartOlustur(obj, kok)
					if Sistem.PatatesMod and kart.Vurgu then
						kart.Vurgu:Destroy() kart.Vurgu = nil
					elseif (not Sistem.PatatesMod) and (not kart.Vurgu) then
						local h = Instance.new("Highlight")
						h.Adornee = obj h.FillTransparency = 0.72 h.OutlineTransparency = 0.1 h.Parent = PlayerGui
						kart.Vurgu = h
					end
					local plr = Players:GetPlayerFromCharacter(obj)
					local renk = plr and Sistem.Renkler.VurguIkinci or Sistem.Renkler.Acik
					local satirlar = {} :: { string }
					if Ayar.EspIsim then table.insert(satirlar, (plr and "[OYUNCU] " or "[BOT] ") .. obj.Name) end
					if Ayar.EspMesafe then table.insert(satirlar, string.format("%.0fm", mesafe)) end
					kart.Yazi.Text = table.concat(satirlar, " • ")
					kart.Yazi.TextColor3 = renk
					kart.Yazi.Visible = #satirlar > 0
					if Ayar.EspCan then
						kart.CanArka.Visible = true
						local hpOran = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
						kart.CanDolgu.Size = UDim2.new(hpOran, 0, 1, 0)
						kart.CanDolgu.BackgroundColor3 = Color3.fromRGB(231, 76, 60):Lerp(Color3.fromRGB(46, 204, 113), hpOran)
					else
						kart.CanArka.Visible = false
					end
					kart.BB.Enabled = kart.Yazi.Visible or kart.CanArka.Visible
					if kart.Vurgu then kart.Vurgu.Enabled = Ayar.EspVurgu kart.Vurgu.FillColor = renk end
					local ekPos, gor = Camera:WorldToViewportPoint(kok.Position)
					if gor and ekPos.Z > 0 then
						local olcek = 920 / math.max(1, ekPos.Z)
						local w = math.clamp(olcek * 2.0, 22, 240)
						local h = math.clamp(olcek * 3.1, 32, 360)
						kart.Kutu.Visible = Ayar.EspKutu
						kart.Kutu.Position = UDim2.new(0, ekPos.X - w * 0.5, 0, ekPos.Y - h * 0.5)
						kart.Kutu.Size = UDim2.new(0, w, 0, h)
						kart.KutuKenar.Color = renk
						kart.Cizgi.Visible = Ayar.EspCizgi and (not Sistem.PatatesMod)
						if kart.Cizgi.Visible then
							local altOrta = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
							local hedef2D = Vector2.new(ekPos.X, ekPos.Y)
							local fark = hedef2D - altOrta
							kart.Cizgi.BackgroundColor3 = renk
							kart.Cizgi.Position = UDim2.new(0, (altOrta.X + hedef2D.X) * 0.5, 0, (altOrta.Y + hedef2D.Y) * 0.5)
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
	for m, _ in pairs(ESPKartlari) do
		if not gorulen[m] or not m.Parent then ESPKartSil(m) end
	end
end
local function KonumaGit(cf: CFrame): boolean
	local ch, _, hrp = Karakter()
	if not ch or not hrp then return false end
	table.insert(Sistem.GecmisKonumlar, hrp.CFrame)
	if #Sistem.GecmisKonumlar > 20 then table.remove(Sistem.GecmisKonumlar, 1) end
	ch:PivotTo(cf)
	return true
end

local function EnYakinOyuncuGit(): boolean
	local _, _, benHRP = Karakter()
	if not benHRP then return false end
	local enYakin: BasePart? = nil
	local enAz = math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not TakimArkadasimi(plr.Character) and not OluMu(plr.Character) then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				local d = (hrp.Position - benHRP.Position).Magnitude
				if d < enAz then enAz = d enYakin = hrp end
			end
		end
	end
	return enYakin and KonumaGit(enYakin.CFrame * CFrame.new(0, 0, 4)) or false
end

local function EnYakinBotNextbotGit(): boolean
	local _, _, benHRP = Karakter()
	if not benHRP then return false end
	local enYakin: BasePart? = nil
	local enAz = math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character and Players:GetPlayerFromCharacter(obj) == nil then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso") or obj.PrimaryPart) :: BasePart?
			local isimUygun = obj.Name:lower():find("bot") ~= nil or obj.Name:lower():find("npc") ~= nil or obj.Name:lower():find("nextbot") ~= nil
			if hrp and ((hum and hum.Health > 0) or isimUygun) and not OluMu(obj) then
				local d = (hrp.Position - benHRP.Position).Magnitude
				if d < enAz then enAz = d enYakin = hrp end
			end
		end
	end
	return enYakin and KonumaGit(enYakin.CFrame * CFrame.new(0, 0, 4)) or false
end

local function MevcutKonumuKopyala(): boolean
	local _, _, hrp = Karakter()
	if not hrp then return false end
	KopyalananCFrame = hrp.CFrame
	Ayar.KopyaliKonum = { hrp.Position.X, hrp.Position.Y, hrp.Position.Z }
	AyarKaydet()
	return true
end

local function KopyaliKonumaGit(): boolean
	if not KopyalananCFrame then return false end
	return KonumaGit(KopyalananCFrame)
end

local TiklaIsinlanBekle = false
local function TiklananYereGit(ekranPos: Vector2): boolean
	local ray = Camera:ViewportPointToRay(ekranPos.X, ekranPos.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	if LocalPlayer.Character then params.FilterDescendantsInstances = { LocalPlayer.Character } end
	local res = Workspace:Raycast(ray.Origin, ray.Direction * 1500, params)
	if res then return KonumaGit(CFrame.new(res.Position + Vector3.new(0, 3.5, 0))) end
	return KonumaGit(CFrame.new(ray.Origin + ray.Direction * 60))
end

local OrijinalIsik = { GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient }
local KapaliEfektler = {} :: { Instance }
local KucultulenParcalar = {} :: { [BasePart]: { Material: Enum.Material, CastShadow: boolean } }

local function GolgeSiliciUygula(aktif: boolean)
	Ayar.GolgeSiliciAcik = aktif
	if aktif then
		Lighting.GlobalShadows = false
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then obj.CastShadow = false end
		end
	else
		Lighting.GlobalShadows = OrijinalIsik.GlobalShadows
		for parca, veri in pairs(KucultulenParcalar) do
			if parca and parca.Parent then parca.CastShadow = veri.CastShadow end
		end
	end
	AyarKaydet()
end

local function AydinlikUygula(deger0_100: number)
	Ayar.AydinlikDeger = math.clamp(deger0_100, 0, 100)
	local oran = Ayar.AydinlikDeger / 100
	Lighting.ClockTime = 0.5 + (oran * 13.5)
	Lighting.Brightness = oran * 6.5
	local oTon = math.floor(10 + (oran * 215))
	local dTon = math.floor(15 + (oran * 225))
	Lighting.Ambient = Color3.fromRGB(oTon, oTon, oTon)
	Lighting.OutdoorAmbient = Color3.fromRGB(dTon, dTon, dTon)
	AyarKaydet()
end

local function OyunIciPatatesUygula(aktif: boolean)
	Ayar.OyunPatatesAcik = aktif
	if aktif then
		table.clear(KapaliEfektler)
		table.clear(KucultulenParcalar)
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA("PostEffect") and obj.Enabled then obj.Enabled = false table.insert(KapaliEfektler, obj) end
		end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
				if obj.Enabled then obj.Enabled = false table.insert(KapaliEfektler, obj) end
			elseif obj:IsA("BasePart") then
				KucultulenParcalar[obj] = { Material = obj.Material, CastShadow = obj.CastShadow }
				obj.CastShadow = false
				if obj.Material ~= Enum.Material.SmoothPlastic and obj.Material ~= Enum.Material.Neon then obj.Material = Enum.Material.SmoothPlastic end
			end
		end
		Lighting.GlobalShadows = false
	else
		for _, efekt in ipairs(KapaliEfektler) do
			if efekt and efekt.Parent and (efekt:IsA("PostEffect") or efekt:IsA("ParticleEmitter") or efekt:IsA("Trail") or efekt:IsA("Beam") or efekt:IsA("Fire") or efekt:IsA("Smoke") or efekt:IsA("Sparkles")) then
				efekt.Enabled = true
			end
		end
		table.clear(KapaliEfektler)
		for parca, veri in pairs(KucultulenParcalar) do
			if parca and parca.Parent then
				parca.Material = veri.Material
				if not Ayar.GolgeSiliciAcik then parca.CastShadow = veri.CastShadow end
			end
		end
		table.clear(KucultulenParcalar)
		if not Ayar.GolgeSiliciAcik then Lighting.GlobalShadows = OrijinalIsik.GlobalShadows end
	end
	AyarKaydet()
end
local function FlyHareketYon(hum: Humanoid?): Vector3
	local yon = Vector3.zero
	if hum and hum.MoveDirection.Magnitude > 0.02 then
		local camLook = Camera.CFrame.LookVector
		local camRight = Camera.CFrame.RightVector
		local ileriYatay = Vector3.new(camLook.X, 0, camLook.Z)
		if ileriYatay.Magnitude > 0.01 then ileriYatay = ileriYatay.Unit else ileriYatay = camLook end
		local sagYatay = Vector3.new(camRight.X, 0, camRight.Z)
		if sagYatay.Magnitude > 0.01 then sagYatay = sagYatay.Unit else sagYatay = camRight end
		yon += (Camera.CFrame.LookVector * hum.MoveDirection:Dot(ileriYatay)) + (sagYatay * hum.MoveDirection:Dot(sagYatay))
	end
	if dikeyYon ~= 0 then yon += Vector3.new(0, dikeyYon, 0) end
	if yon.Magnitude > 1 then yon = yon.Unit end
	return yon
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobilKontrol_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local CrosshairKapsayici = Instance.new("Frame")
CrosshairKapsayici.Name = "CrosshairKatmani"
CrosshairKapsayici.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairKapsayici.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairKapsayici.Size = UDim2.new(0, 44, 0, 44)
CrosshairKapsayici.BackgroundTransparency = 1
CrosshairKapsayici.Visible = false
CrosshairKapsayici.ZIndex = 55
CrosshairKapsayici.Parent = ScreenGui

local NoktaGorsel = Instance.new("Frame")
NoktaGorsel.AnchorPoint = Vector2.new(0.5, 0.5)
NoktaGorsel.Position = UDim2.new(0.5, 0, 0.5, 0)
NoktaGorsel.Size = UDim2.new(0, 6, 0, 6)
NoktaGorsel.BackgroundColor3 = Color3.fromRGB(0, 245, 212)
NoktaGorsel.BorderSizePixel = 0
NoktaGorsel.Parent = CrosshairKapsayici
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = NoktaGorsel end

local ArtiYatay = Instance.new("Frame")
ArtiYatay.AnchorPoint = Vector2.new(0.5, 0.5)
ArtiYatay.Position = UDim2.new(0.5, 0, 0.5, 0)
ArtiYatay.Size = UDim2.new(0, 22, 0, 2)
ArtiYatay.BackgroundColor3 = Color3.fromRGB(0, 245, 212)
ArtiYatay.BorderSizePixel = 0
ArtiYatay.Parent = CrosshairKapsayici

local ArtiDikey = Instance.new("Frame")
ArtiDikey.AnchorPoint = Vector2.new(0.5, 0.5)
ArtiDikey.Position = UDim2.new(0.5, 0, 0.5, 0)
ArtiDikey.Size = UDim2.new(0, 2, 0, 22)
ArtiDikey.BackgroundColor3 = Color3.fromRGB(0, 245, 212)
ArtiDikey.BorderSizePixel = 0
ArtiDikey.Parent = CrosshairKapsayici

local HalkaGorsel = Instance.new("Frame")
HalkaGorsel.AnchorPoint = Vector2.new(0.5, 0.5)
HalkaGorsel.Position = UDim2.new(0.5, 0, 0.5, 0)
HalkaGorsel.Size = UDim2.new(0, 24, 0, 24)
HalkaGorsel.BackgroundTransparency = 1
HalkaGorsel.Parent = CrosshairKapsayici
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = HalkaGorsel
	local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Color3.fromRGB(0, 245, 212) s.Parent = HalkaGorsel
end

local function CrosshairGuncelle()
	CrosshairKapsayici.Visible = Ayar.CrosshairAcik
	if not Ayar.CrosshairAcik then CrosshairMerkez = nil return end
	CrosshairMerkez = CrosshairKapsayici.AbsolutePosition + (CrosshairKapsayici.AbsoluteSize * 0.5)
	NoktaGorsel.Visible = (Ayar.CrosshairTip == "Nokta" or Ayar.CrosshairTip == "Arti")
	ArtiYatay.Visible = (Ayar.CrosshairTip == "Arti")
	ArtiDikey.Visible = (Ayar.CrosshairTip == "Arti")
	HalkaGorsel.Visible = (Ayar.CrosshairTip == "Halka")
end

local DaireFrame = Instance.new("Frame")
DaireFrame.Name = "AimbotDaire"
DaireFrame.AnchorPoint = Vector2.new(0.5, 0.5)
DaireFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
DaireFrame.Size = UDim2.new(0, Ayar.DaireYaricap * 2, 0, Ayar.DaireYaricap * 2)
DaireFrame.BackgroundTransparency = 1
DaireFrame.Visible = false
DaireFrame.ZIndex = 45
DaireFrame.Parent = ScreenGui
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = DaireFrame
	local s = Instance.new("UIStroke") s.Thickness = 2 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = DaireFrame
end

BaglantiEkle(RunService.RenderStepped:Connect(function(dt)
	local _, hum, hrp = Karakter()
	if Ayar.NormalFlyAcik and hum and hrp then
		if not flyBV or not flyBV.Parent then NormalFlyAyarla(true) end
		if flyBV then flyBV.Velocity = FlyHareketYon(hum) * Ayar.NormalFlyHiz end
		if flyBG then
			local bak = Camera.CFrame.LookVector
			local yatay = Vector3.new(bak.X, 0, bak.Z)
			if yatay.Magnitude > 0.01 then flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + yatay.Unit) end
		end
	elseif flyBV or flyBG then
		NormalFlyAyarla(false)
	end
	local koltuk = AracKoltugu()
	if Ayar.CarFlyAcik and koltuk then
		if not carBV or not carBV.Parent then CarFlyAyarla(true) end
		if carBV then carBV.Velocity = FlyHareketYon(hum) * Ayar.CarFlyHiz end
		if carBG then
			local bak = Camera.CFrame.LookVector
			local yatay = Vector3.new(bak.X, 0, bak.Z)
			if yatay.Magnitude > 0.01 then carBG.CFrame = CFrame.lookAt(koltuk.Position, koltuk.Position + yatay.Unit) end
		end
	elseif carBV or carBG then
		CarFlyAyarla(false)
	end
	if Ayar.AimbotAcik then
		local hedef = AimbotHedefSec()
		if hedef then
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, TahminNoktasi(hedef)), KeskinlikCarpani(Ayar.AimbotKeskinlik, dt))
			TetikKontrol(hedef)
		end
	else
		KilitliAimbotHedef = nil
	end
	SilentHedefBul()
	ESPYenile()
	if Ayar.CrosshairAcik then CrosshairGuncelle() else CrosshairKapsayici.Visible = false CrosshairMerkez = nil end
	local gosterDaire = Ayar.AimbotAcik and (Ayar.AimbotTur == "Daire")
	DaireFrame.Visible = gosterDaire
	if gosterDaire then
		DaireFrame.Size = UDim2.new(0, Ayar.DaireYaricap * 2, 0, Ayar.DaireYaricap * 2)
		DaireFrame.Position = UDim2.new(0, (CrosshairMerkez and CrosshairMerkez.X) or (Camera.ViewportSize.X * 0.5), 0, (CrosshairMerkez and CrosshairMerkez.Y) or (Camera.ViewportSize.Y * 0.5))
	end
end))
BaglantiEkle(UserInputService.InputBegan:Connect(function(input, isProcessed)
	if isProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local pos = Vector2.new(input.Position.X, input.Position.Y)
		if TiklaIsinlanBekle then TiklaIsinlanBekle = false TiklananYereGit(pos) return end
		if Ayar.CrosshairAcik or Ayar.SilentAcik then CrosshairMerkezindenNisanla(pos) end
	end
end))

local OzelTusAlan = Instance.new("Frame")
OzelTusAlan.Name = "OzelTusAlani"
OzelTusAlan.Size = UDim2.new(1, 0, 1, 0)
OzelTusAlan.BackgroundTransparency = 1
OzelTusAlan.ZIndex = 70
OzelTusAlan.Parent = ScreenGui

local MAVI_RENK = Color3.fromRGB(59, 130, 246)
local SARI_RENK = Color3.fromRGB(250, 204, 21)
local YESIL_RENK = Color3.fromRGB(34, 197, 94)
local KIRMIZI_RENK = Color3.fromRGB(239, 68, 68)

local OzelTusKayit = {} :: { [string]: { Buton: TextButton, Kenar: UIStroke, Durum: boolean, Kilitli: boolean, Degistir: (boolean) -> () } }

local function OzelTusDurumSenkron(kimlik: string, acik: boolean)
	local kayit = OzelTusKayit[kimlik]
	if not kayit then return end
	kayit.Durum = acik
	kayit.Buton.BackgroundColor3 = acik and YESIL_RENK or KIRMIZI_RENK
end

local function OzelTusOlustur(kimlik: string, baslik: string, ilkAcik: boolean, degistirFn: (boolean) -> ())
	local mevcut = OzelTusKayit[kimlik]
	if mevcut then mevcut.Buton.Visible = not mevcut.Buton.Visible return end
	local sira = 0
	for _ in pairs(OzelTusKayit) do sira += 1 end

	local btn = Instance.new("TextButton")
	btn.Name = "OzelTus_" .. kimlik
	btn.Size = UDim2.new(0, 108, 0, 34)
	btn.Position = UDim2.new(0.76, 0, 0.16 + ((sira % 6) * 0.08), 0)
	btn.BackgroundColor3 = ilkAcik and YESIL_RENK or KIRMIZI_RENK
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = baslik
	btn.AutoButtonColor = false
	btn.ZIndex = 72
	btn.Parent = OzelTusAlan
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = btn end
	local kenar = Instance.new("UIStroke")
	kenar.Thickness = 2.2
	kenar.Color = MAVI_RENK
	kenar.Parent = btn

	local kayit = { Buton = btn, Kenar = kenar, Durum = ilkAcik, Kilitli = false, Degistir = degistirFn }
	OzelTusKayit[kimlik] = kayit

	local basili = false
	local suruklendi = false
	local baslangicDokunus = Vector2.zero
	local baslangicKonum = UDim2.new()
	local tutmaGen = 0

	btn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			basili = true
			suruklendi = false
			baslangicDokunus = Vector2.new(inp.Position.X, inp.Position.Y)
			baslangicKonum = btn.Position
			tutmaGen += 1
			local g = tutmaGen
			task.delay(3, function()
				if basili and not suruklendi and g == tutmaGen then
					kayit.Kilitli = not kayit.Kilitli
					kenar.Color = kayit.Kilitli and SARI_RENK or MAVI_RENK
				end
			end)
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					if basili and not suruklendi then
						tutmaGen += 1
						local yeni = not kayit.Durum
						kayit.Durum = yeni
						btn.BackgroundColor3 = yeni and YESIL_RENK or KIRMIZI_RENK
						degistirFn(yeni)
					end
					basili = false
				end
			end)
		end
	end)

	BaglantiEkle(UserInputService.InputChanged:Connect(function(inp)
		if basili and (not kayit.Kilitli) and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local fark = Vector2.new(inp.Position.X, inp.Position.Y) - baslangicDokunus
			if fark.Magnitude > 6 then suruklendi = true tutmaGen += 1 end
			if suruklendi then
				local vp = Camera.ViewportSize
				btn.Position = UDim2.new(
					0, math.clamp(baslangicKonum.X.Offset + fark.X, 0, math.max(0, vp.X - btn.AbsoluteSize.X)),
					0, math.clamp(baslangicKonum.Y.Offset + fark.Y, 0, math.max(0, vp.Y - btn.AbsoluteSize.Y))
				)
			end
		end
	end))
end

local AnaFrame = Instance.new("Frame")
AnaFrame.Name = "MoonPanel"
AnaFrame.Size = UDim2.new(0, 560, 0, 320)
AnaFrame.Position = UDim2.new(0.5, -280, 0.5, -160)
AnaFrame.BackgroundColor3 = Color3.fromRGB(15, 13, 28)
AnaFrame.BorderSizePixel = 0
AnaFrame.ClipsDescendants = true
AnaFrame.ZIndex = 20
AnaFrame.Parent = ScreenGui
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 14) c.Parent = AnaFrame local s = Instance.new("UIStroke") s.Thickness = 1.8 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = AnaFrame end

local DesenArka = Instance.new("Frame")
DesenArka.Size = UDim2.new(1, 0, 1, 0)
DesenArka.BackgroundColor3 = Color3.fromRGB(22, 18, 42)
DesenArka.BorderSizePixel = 0
DesenArka.ZIndex = 21
DesenArka.Parent = AnaFrame

local MoonGradyan = Instance.new("UIGradient")
MoonGradyan.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 60, 220)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(38, 28, 74)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 195, 185)) })
MoonGradyan.Rotation = 30
MoonGradyan.Parent = DesenArka

for idx = 1, 7 do
	local cizgi = Instance.new("Frame")
	cizgi.Size = UDim2.new(0, 1, 1, 0)
	cizgi.Position = UDim2.new(idx / 8, 0, 0, 0)
	cizgi.BackgroundColor3 = Color3.fromRGB(216, 180, 254)
	cizgi.BackgroundTransparency = 0.86
	cizgi.BorderSizePixel = 0
	cizgi.ZIndex = 21
	cizgi.Parent = DesenArka
end

local UstPanel = Instance.new("Frame")
UstPanel.Size = UDim2.new(1, 0, 0, 36)
UstPanel.BackgroundColor3 = Color3.fromRGB(24, 20, 44)
UstPanel.BorderSizePixel = 0
UstPanel.ZIndex = 25
UstPanel.Parent = AnaFrame

local BaslikLbl = Instance.new("TextLabel")
BaslikLbl.Size = UDim2.new(1, -110, 1, 0)
BaslikLbl.Position = UDim2.new(0, 12, 0, 0)
BaslikLbl.BackgroundTransparency = 1
BaslikLbl.Font = Enum.Font.GothamBold
BaslikLbl.TextSize = 12
BaslikLbl.TextColor3 = Color3.fromRGB(245, 240, 255)
BaslikLbl.TextXAlignment = Enum.TextXAlignment.Left
BaslikLbl.Text = "MOON KONTROL • AIMBOT & VURUS"
BaslikLbl.ZIndex = 26
BaslikLbl.Parent = UstPanel

local SimgeBtn = Instance.new("TextButton")
SimgeBtn.Size = UDim2.new(0, 28, 0, 24)
SimgeBtn.Position = UDim2.new(1, -68, 0.5, -12)
SimgeBtn.BackgroundColor3 = Color3.fromRGB(52, 42, 92)
SimgeBtn.Font = Enum.Font.GothamBold
SimgeBtn.TextSize = 13
SimgeBtn.TextColor3 = Color3.new(1, 1, 1)
SimgeBtn.Text = "-"
SimgeBtn.ZIndex = 26
SimgeBtn.Parent = UstPanel

local KapatXBtn = Instance.new("TextButton")
KapatXBtn.Size = UDim2.new(0, 28, 0, 24)
KapatXBtn.Position = UDim2.new(1, -34, 0.5, -12)
KapatXBtn.BackgroundColor3 = KIRMIZI_RENK
KapatXBtn.Font = Enum.Font.GothamBold
KapatXBtn.TextSize = 12
KapatXBtn.TextColor3 = Color3.new(1, 1, 1)
KapatXBtn.Text = "X"
KapatXBtn.ZIndex = 26
KapatXBtn.Parent = UstPanel

local TavanCubugu = Instance.new("Frame")
TavanCubugu.Size = UDim2.new(0, 230, 0, 28)
TavanCubugu.Position = UDim2.new(0.5, -115, 0, 0)
TavanCubugu.BackgroundColor3 = Color3.fromRGB(24, 20, 44)
TavanCubugu.BorderSizePixel = 0
TavanCubugu.Visible = false
TavanCubugu.ZIndex = 75
TavanCubugu.Parent = ScreenGui
do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = TavanCubugu local s = Instance.new("UIStroke") s.Thickness = 1.6 s.Color = Color3.fromRGB(168, 85, 247) s.Parent = TavanCubugu end

local TavanAcBtn = Instance.new("TextButton")
TavanAcBtn.Size = UDim2.new(1, -10, 1, 0)
TavanAcBtn.Position = UDim2.new(0, 5, 0, 0)
TavanAcBtn.BackgroundTransparency = 1
TavanAcBtn.Font = Enum.Font.GothamBold
TavanAcBtn.TextSize = 11
TavanAcBtn.TextColor3 = Color3.new(1, 1, 1)
TavanAcBtn.Text = "TAVAN • AC / KAPAT"
TavanAcBtn.ZIndex = 76
TavanAcBtn.Parent = TavanCubugu

local SerbestButon = Instance.new("TextButton")
SerbestButon.Size = UDim2.new(0, 54, 0, 54)
SerbestButon.Position = UDim2.new(0.04, 0, 0.22, 0)
SerbestButon.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
SerbestButon.Font = Enum.Font.GothamBold
SerbestButon.TextSize = 11
SerbestButon.TextColor3 = Color3.new(1, 1, 1)
SerbestButon.Text = "MOON"
SerbestButon.Visible = false
SerbestButon.ZIndex = 80
SerbestButon.Parent = ScreenGui
do local c =local SolMenuSutun = Instance.new("ScrollingFrame")
  local SolMenuSutun = Instance.new("ScrollingFrame")
SolMenuSutun.Size = UDim2.new(0, 122, 1, -36)
SolMenuSutun.Position = UDim2.new(0, 0, 0, 36)
SolMenuSutun.BackgroundColor3 = Color3.fromRGB(20, 17, 38)
SolMenuSutun.BorderSizePixel = 0
SolMenuSutun.ScrollBarThickness = 3
SolMenuSutun.AutomaticCanvasSize = Enum.AutomaticSize.Y
SolMenuSutun.CanvasSize = UDim2.new(0, 0, 0, 0)
SolMenuSutun.ZIndex = 23
SolMenuSutun.Parent = AnaFrame
do
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 5)
	l.Parent = SolMenuSutun
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 6)
	p.PaddingLeft = UDim.new(0, 6)
	p.PaddingRight = UDim.new(0, 6)
	p.Parent = SolMenuSutun
end

local SagSayfaAlani = Instance.new("Frame")
SagSayfaAlani.Size = UDim2.new(1, -122, 1, -36)
SagSayfaAlani.Position = UDim2.new(0, 122, 0, 36)
SagSayfaAlani.BackgroundTransparency = 1
SagSayfaAlani.ClipsDescendants = true
SagSayfaAlani.ZIndex = 23
SagSayfaAlani.Parent = AnaFrame

local function ModUygula(mod: "TamPanel" | "UstTavan" | "TekButon")
	Sistem.GorunumModu = mod
	local vp = Camera.ViewportSize
	if mod == "TamPanel" then
		TavanCubugu.Visible = false
		SerbestButon.Visible = false
		AnaFrame.Visible = Sistem.Acik
		local w = math.clamp(vp.X - 24, 340, 600)
		local h = math.clamp(vp.Y - 46, 220, 340)
		AnaFrame.Size = UDim2.new(0, w, 0, Sistem.SimgeMod and 36 or h)
		AnaFrame.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
	elseif mod == "UstTavan" then
		SerbestButon.Visible = false
		TavanCubugu.Visible = true
		AnaFrame.Visible = Sistem.Acik
		local w = math.clamp(vp.X - 16, 340, 620)
		local altY = TavanCubugu.Size.Y.Offset + 6
		local h = math.clamp(vp.Y - altY - 12, 200, 325)
		AnaFrame.Size = UDim2.new(0, w, 0, Sistem.SimgeMod and 36 or h)
		AnaFrame.Position = UDim2.new(0.5, -w * 0.5, 0, altY)
	elseif mod == "TekButon" then
		TavanCubugu.Visible = false
		SerbestButon.Visible = true
		AnaFrame.Visible = false
		Sistem.Acik = false
	end
end

local function PatatesAyarla(aktif: boolean)
	Sistem.PatatesMod = aktif
	DesenArka.Visible = not aktif
	MoonGradyan.Enabled = not aktif
	AnaFrame.BackgroundColor3 = aktif and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(15, 13, 28)
	UstPanel.BackgroundColor3 = aktif and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(24, 20, 44)
	SolMenuSutun.BackgroundColor3 = aktif and Color3.fromRGB(34, 34, 34) or Color3.fromRGB(20, 17, 38)
	TavanCubugu.BackgroundColor3 = aktif and Color3.fromRGB(36, 36, 36) or Color3.fromRGB(24, 20, 44)
	ESPYenile()
	HitboxGuncelle()
end

SimgeBtn.MouseButton1Click:Connect(function()
	Sistem.SimgeMod = not Sistem.SimgeMod
	SimgeBtn.Text = Sistem.SimgeMod and "+" or "-"
	ModUygula(Sistem.GorunumModu)
end)

KapatXBtn.MouseButton1Click:Connect(function()
	Sistem.Acik = false
	AnaFrame.Visible = false
	if Sistem.GorunumModu == "TamPanel" then
		SerbestButon.Visible = true
	end
end)

TavanAcBtn.MouseButton1Click:Connect(function()
	Sistem.Acik = not Sistem.Acik
	AnaFrame.Visible = Sistem.Acik
end)

SerbestButon.MouseButton1Click:Connect(function()
	if Sistem.GorunumModu == "TekButon" then
		Sistem.Acik = not Sistem.Acik
		AnaFrame.Visible = Sistem.Acik
		if Sistem.Acik then
			local vp = Camera.ViewportSize
			local w = math.clamp(vp.X - 24, 340, 600)
			local h = math.clamp(vp.Y - 46, 220, 340)
			AnaFrame.Size = UDim2.new(0, w, 0, h)
			AnaFrame.Position = UDim2.new(0.5, -w * 0.5, 0.5, -h * 0.5)
		end
	else
		Sistem.Acik = true
		ModUygula("TamPanel")
	end
end)

do
	local suruk = false
	local startX = 0
	local startOffX = 0
	TavanAcBtn.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = true
			startX = inp.Position.X
			startOffX = TavanCubugu.Position.X.Offset
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					suruk = false
				end
			end)
		end
	end)
	BaglantiEkle(UserInputService.InputChanged:Connect(function(inp)
		if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local maxX = math.max(0, Camera.ViewportSize.X - TavanCubugu.Size.X.Offset)
			TavanCubugu.Position = UDim2.new(0, math.clamp(startOffX + (inp.Position.X - startX), 0, maxX), 0, 0)
		end
	end))
end

do
	local suruk = false
	local startPos = Vector2.zero
	local startUiPos = UDim2.new()
	SerbestButon.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = true
			startPos = Vector2.new(inp.Position.X, inp.Position.Y)
			startUiPos = SerbestButon.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					suruk = false
				end
			end)
		end
	end)
	BaglantiEkle(UserInputService.InputChanged:Connect(function(inp)
		if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(inp.Position.X, inp.Position.Y) - startPos
			local vp = Camera.ViewportSize
			local sz = SerbestButon.Size.X.Offset
			SerbestButon.Position = UDim2.new(
				0, math.clamp(startUiPos.X.Offset + delta.X, 0, math.max(0, vp.X - sz)),
				0, math.clamp(startUiPos.Y.Offset + delta.Y, 0, math.max(0, vp.Y - sz))
			)
		end
	end))
  end
  local SayfaListe = {} :: { [string]: ScrollingFrame }
local SekmeButonListe = {} :: { [string]: TextButton }

local function SayfaEkle(kimlik: string, ad: string): ScrollingFrame
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 30, 64)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(190, 180, 220)
	b.Text = ad
	b.Parent = SolMenuSutun
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 7)
		c.Parent = b
	end

	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, 0, 1, 0)
	sf.BackgroundTransparency = 1
	sf.ScrollBarThickness = 3
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	sf.Visible = false
	sf.Parent = SagSayfaAlani
	do
		local l = Instance.new("UIListLayout")
		l.Padding = UDim.new(0, 6)
		l.Parent = sf
		local p = Instance.new("UIPadding")
		p.PaddingTop = UDim.new(0, 8)
		p.PaddingLeft = UDim.new(0, 8)
		p.PaddingRight = UDim.new(0, 8)
		p.PaddingBottom = UDim.new(0, 10)
		p.Parent = sf
	end

	b.MouseButton1Click:Connect(function()
		BaslikLbl.Text = "MOON KONTROL • " .. ad:upper()
		for k, s in pairs(SayfaListe) do
			s.Visible = (k == kimlik)
		end
		for k, btn in pairs(SekmeButonListe) do
			local aktif = (k == kimlik)
			btn.BackgroundColor3 = aktif and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(36, 30, 64)
			btn.TextColor3 = aktif and Color3.new(1, 1, 1) or Color3.fromRGB(190, 180, 220)
		end
	end)

	SayfaListe[kimlik] = sf
	SekmeButonListe[kimlik] = b
	return sf
end

local function AnahtarSatir(ebeveyn: Instance, ad: string, ilk: boolean, tusKimlik: string?, tusKisa: string?, fn: (boolean) -> ())
	local d = ilk
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundColor3 = Color3.fromRGB(32, 27, 58)
	row.Parent = ebeveyn
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 7)
		c.Parent = row
	end

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, tusKimlik and -118 or -68, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = ad
	lbl.Parent = row

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 52, 0, 24)
	sw.Position = UDim2.new(1, -58, 0.5, -12)
	sw.Font = Enum.Font.GothamBold
	sw.TextSize = 10
	sw.TextColor3 = Color3.new(1, 1, 1)
	sw.Parent = row
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = sw
	end

	local function Yenile(yeni: boolean, sessiz: boolean?)
		d = yeni
		sw.BackgroundColor3 = d and YESIL_RENK or KIRMIZI_RENK
		sw.Text = d and "ACIK" or "KAPALI"
		if tusKimlik then
			OzelTusDurumSenkron(tusKimlik, d)
		end
		if not sessiz then
			AyarKaydet()
			fn(d)
		end
	end

	if tusKimlik and tusKisa then
		local artiBtn = Instance.new("TextButton")
		artiBtn.Size = UDim2.new(0, 52, 0, 24)
		artiBtn.Position = UDim2.new(1, -114, 0.5, -12)
		artiBtn.BackgroundColor3 = Color3.fromRGB(55, 45, 95)
		artiBtn.Font = Enum.Font.GothamBold
		artiBtn.TextSize = 10
		artiBtn.TextColor3 = Color3.fromRGB(125, 211, 252)
		artiBtn.Text = "+ TUS"
		artiBtn.Parent = row
		do
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 6)
			c.Parent = artiBtn
		end

		artiBtn.MouseButton1Click:Connect(function()
			OzelTusOlustur(tusKimlik, tusKisa, d, function(y)
				Yenile(y, false)
			end)
		end)
	end

	sw.MouseButton1Click:Connect(function()
		Yenile(not d, false)
	end)

	Yenile(ilk, true)
end

local function SecimSatir(ebeveyn: Instance, ad: string, secenekler: { string }, ilk: string, fn: (string) -> ())
	local idx = 1
	for i, v in ipairs(secenekler) do
		if v == ilk then
			idx = i
			break
		end
	end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(42, 35, 76)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = ad .. ": " .. secenekler[idx]
	btn.Parent = ebeveyn
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 7)
		c.Parent = btn
	end

	btn.MouseButton1Click:Connect(function()
		idx = (idx % #secenekler) + 1
		local sec = secenekler[idx]
		btn.Text = ad .. ": " .. sec
		AyarKaydet()
		fn(sec)
	end)
end

local function KaydirSatir(ebeveyn: Instance, ad: string, minV: number, maxV: number, ilk: number, fn: (number) -> ())
	local val = ilk
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 42)
	box.BackgroundColor3 = Color3.fromRGB(32, 27, 58)
	box.Parent = ebeveyn
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 7)
		c.Parent = box
	end

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -14, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, 2)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = ad .. ": " .. tostring(val)
	lbl.Parent = box

	local ray = Instance.new("TextButton")
	ray.Size = UDim2.new(1, -16, 0, 9)
	ray.Position = UDim2.new(0, 8, 0, 25)
	ray.BackgroundColor3 = Color3.fromRGB(16, 14, 28)
	ray.Text = ""
	ray.Parent = box
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = ray
	end

	local dolgu = Instance.new("Frame")
	dolgu.Size = UDim2.new(math.clamp((val - minV) / math.max(0.001, maxV - minV), 0, 1), 0, 1, 0)
	dolgu.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	dolgu.BorderSizePixel = 0
	dolgu.Parent = ray
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = dolgu
	end

	local suruk = false
	local function AyarlaX(x: number)
		local oran = math.clamp((x - ray.AbsolutePosition.X) / math.max(1, ray.AbsoluteSize.X), 0, 1)
		val = math.floor((minV + (maxV - minV) * oran) + 0.5)
		dolgu.Size = UDim2.new(oran, 0, 1, 0)
		lbl.Text = ad .. ": " .. tostring(val)
		AyarKaydet()
		fn(val)
	end

	ray.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = true
			AyarlaX(inp.Position.X)
		end
	end)
	BaglantiEkle(UserInputService.InputChanged:Connect(function(inp)
		if suruk and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			AyarlaX(inp.Position.X)
		end
	end))
	BaglantiEkle(UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			suruk = false
		end
	end))
end

local function EylemButon(ebeveyn: Instance, ad: string, vurgu: boolean, fn: () -> ())
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = vurgu and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(42, 35, 76)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = ad
	btn.Parent = ebeveyn
	do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 7)
		c.Parent = btn
	end
	btn.MouseButton1Click:Connect(fn)
  end
  do
	local s = SayfaEkle("Aimbot", "Aimbot & Vurus")
	SecimSatir(s, "Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, Ayar.HedefTuru, function(v) Ayar.HedefTuru = v HitboxGuncelle() end)
	SecimSatir(s, "Aimbot Turu", { "Normal", "Daire", "Acikta" }, Ayar.AimbotTur, function(v) Ayar.AimbotTur = v KilitliAimbotHedef = nil end)
	AnahtarSatir(s, "Aimbot Ac / Kapat", Ayar.AimbotAcik, "aimbot", "AIMBOT", function(v) Ayar.AimbotAcik = v if not v then KilitliAimbotHedef = nil end end)
	SecimSatir(s, "Aimbot Parca", { "Kafa", "Govde" }, Ayar.AimbotParca, function(v) Ayar.AimbotParca = v end)
	KaydirSatir(s, "Uzaklik Siniri", 50, 1200, Ayar.AimbotMesafe, function(v) Ayar.AimbotMesafe = v end)
	KaydirSatir(s, "Yumusak / Keskin Hiz (0-100)", 0, 100, Ayar.AimbotKeskinlik, function(v) Ayar.AimbotKeskinlik = v end)
	KaydirSatir(s, "Daire Boyutu", 40, 300, Ayar.DaireYaricap, function(v) Ayar.DaireYaricap = v end)
	AnahtarSatir(s, "Hareketli Hedef Tahmini", Ayar.TahminAktif, "tahmin", "TAHMIN", function(v) Ayar.TahminAktif = v end)
	AnahtarSatir(s, "Tetik (Otomatik Vurus)", Ayar.TetikAktif, "tetik", "TETIK", function(v) Ayar.TetikAktif = v end)
	SecimSatir(s, "Crosshair Tipi", { "Nokta", "Arti", "Halka" }, Ayar.CrosshairTip, function(v) Ayar.CrosshairTip = v CrosshairGuncelle() end)
	AnahtarSatir(s, "Crosshair & Merkez Atis", Ayar.CrosshairAcik, "crosshair", "CROSS", function(v) Ayar.CrosshairAcik = v CrosshairGuncelle() end)
	AnahtarSatir(s, "Silent Aim", Ayar.SilentAcik, "silent", "SILENT", function(v) Ayar.SilentAcik = v end)
	SecimSatir(s, "Silent Parca", { "Kafa", "Govde" }, Ayar.SilentParca, function(v) Ayar.SilentParca = v end)
	AnahtarSatir(s, "Hitbox Buyut", Ayar.HitboxAcik, "hitbox", "HITBOX", function(v) Ayar.HitboxAcik = v HitboxGuncelle() end)
	KaydirSatir(s, "Hitbox Boyutu", 2, 25, Ayar.HitboxBoyut, function(v) Ayar.HitboxBoyut = v HitboxGuncelle() end)
	KaydirSatir(s, "Mermi / Bicak Hizi (1-100)", 1, 100, Sistem.MermiBicakHizCarpan, function(v) Sistem.MermiBicakHizCarpan = v end)
end

do
	local s = SayfaEkle("Hareket", "Hareket & Araba")
	AnahtarSatir(s, "Normal Fly", Ayar.NormalFlyAcik, "nfly", "FLY", function(v) NormalFlyAyarla(v) end)
	KaydirSatir(s, "Normal Fly Hizi", 15, 250, Ayar.NormalFlyHiz, function(v) Ayar.NormalFlyHiz = v end)
	EylemButon(s, "Fly Yukari (+)", false, function() dikeyYon = (dikeyYon == 1) and 0 or 1 end)
	EylemButon(s, "Fly Asagi (-)", false, function() dikeyYon = (dikeyYon == -1) and 0 or -1 end)
	AnahtarSatir(s, "Car Fly", Ayar.CarFlyAcik, "cfly", "CAR FLY", function(v) CarFlyAyarla(v) end)
	KaydirSatir(s, "Car Fly Hizi", 20, 300, Ayar.CarFlyHiz, function(v) Ayar.CarFlyHiz = v end)
	KaydirSatir(s, "Araba Hizi", 20, 350, Ayar.ArabaHizi, function(v) Ayar.ArabaHizi = v end)
	EylemButon(s, "Araba Hizini Uygula", true, function() ArabaHiziniUygula() end)
	AnahtarSatir(s, "Speed", Ayar.SpeedAcik, "speed", "SPEED", function(v) Ayar.SpeedAcik = v FizikVeBoyutUygula() end)
	KaydirSatir(s, "Speed Degeri", 16, 200, Ayar.SpeedDeger, function(v) Ayar.SpeedDeger = v FizikVeBoyutUygula() end)
	AnahtarSatir(s, "Jump", Ayar.JumpAcik, "jump", "JUMP", function(v) Ayar.JumpAcik = v FizikVeBoyutUygula() end)
	KaydirSatir(s, "Jump Degeri", 50, 250, Ayar.JumpDeger, function(v) Ayar.JumpDeger = v FizikVeBoyutUygula() end)
	AnahtarSatir(s, "Gravity", Ayar.GravityAcik, "grav", "GRAV", function(v) Ayar.GravityAcik = v FizikVeBoyutUygula() end)
	KaydirSatir(s, "Gravity Degeri", 10, 300, math.floor(Ayar.GravityDeger), function(v) Ayar.GravityDeger = v FizikVeBoyutUygula() end)
	AnahtarSatir(s, "Boyut Degistir", Ayar.BoyutAcik, "boyut", "BOYUT", function(v) Ayar.BoyutAcik = v FizikVeBoyutUygula() end)
	KaydirSatir(s, "Boyut Orani (%10-%500)", 10, 500, math.floor(Ayar.BoyutOran * 100), function(v) Ayar.BoyutOran = math.clamp(v / 100, 0.1, 5.0) FizikVeBoyutUygula() end)
end

do
	local s = SayfaEkle("ESP", "ESP Ayarlari")
	AnahtarSatir(s, "ESP Ac / Kapat", Ayar.EspAcik, "esp", "ESP", function(v) Ayar.EspAcik = v ESPYenile() end)
	SecimSatir(s, "ESP Hedef Turu", { "Hepsi", "Bot", "Oyuncu Gercek" }, Ayar.HedefTuru, function(v) Ayar.HedefTuru = v ESPYenile() end)
	AnahtarSatir(s, "Kutu ESP", Ayar.EspKutu, nil, nil, function(v) Ayar.EspKutu = v ESPYenile() end)
	AnahtarSatir(s, "Isim ESP", Ayar.EspIsim, nil, nil, function(v) Ayar.EspIsim = v ESPYenile() end)
	AnahtarSatir(s, "Mesafe ESP", Ayar.EspMesafe, nil, nil, function(v) Ayar.EspMesafe = v ESPYenile() end)
	AnahtarSatir(s, "Can Bari ESP", Ayar.EspCan, nil, nil, function(v) Ayar.EspCan = v ESPYenile() end)
	AnahtarSatir(s, "Cizgi ESP", Ayar.EspCizgi, nil, nil, function(v) Ayar.EspCizgi = v ESPYenile() end)
	AnahtarSatir(s, "Vurgu ESP", Ayar.EspVurgu, nil, nil, function(v) Ayar.EspVurgu = v ESPYenile() end)
	KaydirSatir(s, "ESP Mesafe Siniri", 100, 2500, Ayar.EspMesafeSiniri, function(v) Ayar.EspMesafeSiniri = v ESPYenile() end)
end

do
	local s = SayfaEkle("Teleport", "Teleport")
	local seciliOyuncu: Player? = nil
	local secBtn = Instance.new("TextButton")
	secBtn.Size = UDim2.new(1, 0, 0, 34)
	secBtn.BackgroundColor3 = Color3.fromRGB(42, 35, 76)
	secBtn.Font = Enum.Font.GothamBold
	secBtn.TextSize = 11
	secBtn.TextColor3 = Color3.new(1, 1, 1)
	secBtn.Text = "Oyuncu Sec"
	secBtn.Parent = s
	do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = secBtn end

	local listeKutu = Instance.new("Frame")
	listeKutu.Size = UDim2.new(1, 0, 0, 0)
	listeKutu.AutomaticSize = Enum.AutomaticSize.Y
	listeKutu.BackgroundColor3 = Color3.fromRGB(24, 20, 46)
	listeKutu.Visible = false
	listeKutu.Parent = s
	do
		local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = listeKutu
		local l = Instance.new("UIListLayout") l.Padding = UDim.new(0, 4) l.Parent = listeKutu
		local p = Instance.new("UIPadding") p.PaddingTop = UDim.new(0, 5) p.PaddingBottom = UDim.new(0, 5) p.PaddingLeft = UDim.new(0, 5) p.PaddingRight = UDim.new(0, 5) p.Parent = listeKutu
	end

	local function OyuncuListesiDoldur()
		for _, child in ipairs(listeKutu:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local pBtn = Instance.new("TextButton")
				pBtn.Size = UDim2.new(1, 0, 0, 30)
				pBtn.BackgroundColor3 = Color3.fromRGB(48, 40, 88)
				pBtn.Font = Enum.Font.GothamMedium
				pBtn.TextSize = 11
				pBtn.TextColor3 = Color3.new(1, 1, 1)
				pBtn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
				pBtn.Parent = listeKutu
				do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = pBtn end
				pBtn.MouseButton1Click:Connect(function()
					seciliOyuncu = plr
					secBtn.Text = "Secili: " .. plr.DisplayName .. " (" .. plr.Name .. ")"
					listeKutu.Visible = false
				end)
			end
		end
	end

	secBtn.MouseButton1Click:Connect(function()
		listeKutu.Visible = not listeKutu.Visible
		if listeKutu.Visible then OyuncuListesiDoldur() end
	end)

	EylemButon(s, "Secili Oyuncuya Isinlan", true, function()
		if seciliOyuncu and seciliOyuncu.Character and not OluMu(seciliOyuncu.Character) then
			local hrp = seciliOyuncu.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then KonumaGit(hrp.CFrame * CFrame.new(0, 0, 4)) end
		end
	end)
	EylemButon(s, "En Yakin Oyuncuya Isinlan", true, function() EnYakinOyuncuGit() end)
	EylemButon(s, "En Yakin Bot / Nextbota Isinlan", true, function() EnYakinBotNextbotGit() end)
	EylemButon(s, "Tikladigim Yere Isinlan", false, function() TiklaIsinlanBekle = true AnaFrame.Visible = false Sistem.Acik = false end)
	EylemButon(s, "Konumu Kopyala", false, function() MevcutKonumuKopyala() end)
	EylemButon(s, "Kopyalanan Konuma Isinlan", false, function() KopyaliKonumaGit() end)
end

do
	local s = SayfaEkle("Duzen", "Duzen & Dunya")
	SecimSatir(s, "Gorunum Modu", { "TamPanel", "UstTavan", "TekButon" }, Sistem.GorunumModu, function(m) ModUygula(m :: "TamPanel" | "UstTavan" | "TekButon") end)
	KaydirSatir(s, "Ust Tavan Genisligi", 150, 460, TavanCubugu.Size.X.Offset, function(v) TavanCubugu.Size = UDim2.new(0, v, 0, TavanCubugu.Size.Y.Offset) TavanCubugu.Position = UDim2.new(0.5, -v * 0.5, 0, 0) end)
	KaydirSatir(s, "Ust Tavan Yuksekligi", 24, 52, TavanCubugu.Size.Y.Offset, function(v) TavanCubugu.Size = UDim2.new(0, TavanCubugu.Size.X.Offset, 0, v) if Sistem.GorunumModu == "UstTavan" then ModUygula("UstTavan") end end)
	KaydirSatir(s, "Tek Buton Boyutu", 38, 96, SerbestButon.Size.X.Offset, function(v) SerbestButon.Size = UDim2.new(0, v, 0, v) end)
	AnahtarSatir(s, "Arayuz Patates Mod", Sistem.PatatesMod, "patates", "PATATES", function(v) PatatesAyarla(v) end)
	AnahtarSatir(s, "Oyun Ici Patates Mod (No Lag)", Ayar.OyunPatatesAcik, "nolag", "NO LAG", function(v) OyunIciPatatesUygula(v) end)
	AnahtarSatir(s, "Golge Silici", Ayar.GolgeSiliciAcik, "golge", "GOLGE", function(v) GolgeSiliciUygula(v) end)
	KaydirSatir(s, "Aydinlik Ayari (0-100)", 0, 100, Ayar.AydinlikDeger, function(v) AydinlikUygula(v) end)
	EylemButon(s, "Ayarlari Simdi Kaydet", false, function() AyarKaydet() end)
end

SayfaListe["Aimbot"].Visible = true
SekmeButonListe["Aimbot"].BackgroundColor3 = Color3.fromRGB(168, 85, 247)
SekmeButonListe["Aimbot"].TextColor3 = Color3.new(1, 1, 1)
ModUygula("TamPanel")
FizikVeBoyutUygula()
if Ayar.NormalFlyAcik then NormalFlyAyarla(true) end
if Ayar.HitboxAcik then HitboxGuncelle() end
if Ayar.OyunPatatesAcik then OyunIciPatatesUygula(true) end
if Ayar.GolgeSiliciAcik then GolgeSiliciUygula(true) end
AydinlikUygula(Ayar.AydinlikDeger)

BaglantiEkle(LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.25)
	FizikVeBoyutUygula()
	if Ayar.NormalFlyAcik then NormalFlyAyarla(true) end
	if Ayar.HitboxAcik then HitboxGuncelle() end
end))
  
