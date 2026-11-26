-- [SATIR 1] Rayfield Arayuz Kutuphanesi Yukleniyor
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- [SATIR 4] Temel Roblox Servisleri
local OyuncularServisi = game:GetService("Players")
local CalismaServisi = game:GetService("RunService")
local GirisServisi = game:GetService("UserInputService")
local AydinlatmaServisi = game:GetService("Lighting")
local DunyaServisi = game:GetService("Workspace")
local TweenServisi = game:GetService("TweenService")

-- [SATIR 12] Yerel Oyuncu ve Kamera Referanslari
local BenimOyuncu = OyuncularServisi.LocalPlayer
local AktifKamera = DunyaServisi.CurrentCamera

-- [SATIR 16] Aimbot ve Hedef Ayarlari (Tamamen Bagimsiz Degiskenler)
local AimbotTuruSecili = "Yumusak Aim" -- "Normal Aim", "Legit Aim", "Yumusak Aim", "Rage Aim", "Hedef Kilitle"
local AimbotAktif = false
local SessizAimAktif = false
local LegitAimAktif = false
local RageAimAktif = false
local HedefKilitleAktif = false
local OtomatikAtesAktif = false
local TetikBotuAktif = false
local YumusakAimAktif = false
local FovDairesiAktif = false
local NisantahminiAktif = false
local EnYakinHedefAktif = false
local HedefDegistirAktif = false
local GorunurlukKontrolAktif = true
local TakimKontrolAimAktif = true
local ArkadasKontrolAimAktif = true
local OlumKontrolAimAktif = true
local BayginKontrolAimAktif = true
local AimbotKemigiSecili = "Head"
local AimbotYumusakligi = 0.18
local AimbotFovYaricapi = 150
local FovDaireRengi = Color3.fromRGB(255, 220, 50)

-- [SATIR 41] Hedef Ayarlari (Ekran Tusu Ozelligi Sadece Burada)
local HedefBolgeSecili = "Head"
local HedefOnceligiSecili = "En Yakin" -- "En Yakin", "En Dusuk Can", "FOV Ici"
local HedefMesafesiSiniri = 300
local HedefTakimModu = "Dusmanlar" -- "Dusmanlar", "Herkes", "Takim Disi"
local HedefGorunurlukAktif = false
local HedefCanModu = "En Dusuk"
local HedefModuSecili = "Normal"
local HedefFiltreModu = "Standart" -- "Standart", "Beyaz Liste", "Kara Liste"
local YokSayilanIsimlerMetni = ""
local BeyazListeIsimlerMetni = ""
local KaraListeIsimlerMetni = ""

-- [SATIR 55] Sadece Hedef (Target) Tarafina Ozel Ekran Tusu Durumlari
local HedefGorunurlukTusAktif = false
local HedefKilitleTusAktif = false
local HedefDegistirTusAktif = false

-- [SATIR 60] ESP ve Gorunum Ayarlari (Tus Yok, Temiz Ayri Degiskenler)
local OyuncuEspAktif = false
local KutuEspAktif = false
local IskeletEspAktif = false
local IsimEspAktif = false
local CanEspAktif = false
local MesafeEspAktif = false
local CizgiEspAktif = false
local Kutu2DEspAktif = false
local Kutu3DEspAktif = false
local KafaEspAktif = false
local SnaplineEspAktif = false
local ChamsEspAktif = false
local ParlamaEspAktif = false
local EsyaEspAktif = false
local SilahEspAktif = false
local SadeceDusmanEspAktif = true
local SadeceGorunenEspAktif = false

-- [SATIR 80] Hareket Ayarlari (Ayri Degiskenler)
local HizHilesiAktif = false
local UcusHilesiAktif = false
local SinirsizZiplamaAktif = false
local DuvarGecisiAktif = false
local IsinlanmaAktif = false
local SuperZiplamaAktif = false
local YavaslamaKaldirAktif = false
local HavadaYurumeAktif = false
local YercekimiHilesiAktif = false
local SpinbotAktif = false
local TavsanZiplamaAktif = false
local DusmeKorumaAktif = false
local SeciliHizDegeri = 32
local SeciliZiplamaDegeri = 85
local SeciliUcusHizi = 55
local SeciliYercekimi = 75

-- [SATIR 99] Silah ve Savas Ayarlari (Ayri Degiskenler)
local SekmeKaldirAktif = false
local DagilmaKaldirAktif = false
local HizliAtesAktif = false
local HizliSarjorAktif = false
local SinirsizMermiAktif = false
local SarjorYokAktif = false
local HasarDegistirAktif = false
local HitboxBuyutAktif = false
local YakinDovusAuraAktif = false
local OtomatikOldurAktif = false

-- [SATIR 112] Kontroller ve Filtreler (Ayri Degiskenler)
local FiltreTakimKontrol = true
local FiltreArkadasKontrol = true
local FiltreDusmanKontrol = true
local FiltreCanliKontrol = true
local FiltreOluKontrol = true
local FiltreGorunurKontrol = true
local FiltreDuvarKontrol = true
local FiltreMesafeKontrol = false
local FiltreCanKontrol = false
local FiltreNpcKontrol = false
local FiltreBotKontrol = false
local FiltreAfkKontrol = false
local FiltreGuvenliBolgeKontrol = false
local FiltreFovKontrol = true
local FiltreAracKontrol = false

-- [SATIR 129] Diger / Karakter / Dunya Ayarlari
local AntiAimAktif = false
local SahteGecikmeAktif = false
local DesyncAktif = false
local VurusSesiAktif = false
local OldurmeSesiAktif = false
local VurusIsaretiAktif = false
local NisantahDegistirAktif = false
local FovDegistirAktif = false
local FpsSinirKaldirAktif = false
local OtomatikDogmaAktif = false
local IzleyiciModuAktif = false
local YapilandirmaAktif = false
local PanikButonuAktif = false
local SeciliKameraFov = 85

local KarakterEspAktif = false
local KarakterKafaEspAktif = false
local KarakterGovdeEspAktif = false
local KarakterElEspAktif = false
local KarakterBacakEspAktif = false
local KiyafetEspAktif = false
local AvatarEspAktif = false
local OyuncuVurguAktif = false
local OyuncuChamsAktif = false

local DunyaEspAktif = false
local NesneEspAktif = false
local KapiEspAktif = false
local GanimetEspAktif = false
local SilahBulucuAktif = false
local EsyaBulucuAktif = false
local RadarAktif = false
local MiniHaritaAktif = false
local TamAydinlikAktif = false
local SisKaldirAktif = false
local GeceGorusuAktif = false

-- [SATIR 166] Rayfield Ana Penceresi (Turkce Sekmeler)
local AnaPencere = Rayfield:CreateWindow({
    Name = "Turkce Rayfield Hub",
    LoadingTitle = "Turkce Rayfield Yukleniyor...",
    LoadingSubtitle = "Aimbot • Hedef • ESP • Hareket • Silah",
    ConfigurationSaving = { Enabled = false }
})
-- [SATIR 167] Sadece Hedef (Target) Sekmesi Icin Suruklenebilir Ekran Tusu Olusturucu
local HedefTusGui = Instance.new("ScreenGui")
HedefTusGui.Name = "HedefOzelEkranTuslari"
HedefTusGui.ResetOnSpawn = false
HedefTusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HedefTusGui.Parent = BenimOyuncu:WaitForChild("PlayerGui")

local function HedefEkranTusuYonet(kimlik, yazi, acikMi, degisimFonksiyonu)
    local mevcut = HedefTusGui:FindFirstChild("HedefTus_" .. kimlik)
    if acikMi then
        if mevcut then
            mevcut.Visible = true
            return
        end
        local tus = Instance.new("TextButton")
        tus.Name = "HedefTus_" .. kimlik
        tus.Size = UDim2.new(0, 104, 0, 40)
        tus.Position = UDim2.new(0.18, 0, 0.25, 0)
        tus.BackgroundColor3 = Color3.fromRGB(115, 118, 125)
        tus.TextColor3 = Color3.fromRGB(255, 255, 255)
        tus.Text = yazi
        tus.TextSize = 11
        tus.Font = Enum.Font.GothamBold
        tus.Active = true
        tus.Draggable = true
        tus.Parent = HedefTusGui
        Instance.new("UICorner", tus).CornerRadius = UDim.new(0, 8)

        local aktifDurum = false
        tus.MouseButton1Click:Connect(function()
            aktifDurum = not aktifDurum
            tus.BackgroundColor3 = aktifDurum and Color3.fromRGB(55, 145, 225) or Color3.fromRGB(115, 118, 125)
            if degisimFonksiyonu then
                degisimFonksiyonu(aktifDurum)
            end
        end)
    elseif mevcut then
        mevcut:Destroy()
    end
end

-- [SATIR 208] 1. SEKME: AIMBOT VE HEDEFLEME
local AimbotSekmesi = AnaPencere:CreateTab("Aimbot", 4483362458)

AimbotSekmesi:CreateDropdown({
    Name = "Aimbot Turu Secimi",
    Options = {"Normal Aim", "Legit Aim", "Yumusak Aim", "Rage Aim", "Hedef Kilitle"},
    CurrentOption = {"Yumusak Aim"},
    Callback = function(secim)
        AimbotTuruSecili = secim[1]
    end
})

AimbotSekmesi:CreateSlider({
    Name = "Aimbot Yumusakligi",
    Range = {2, 100},
    Increment = 1,
    CurrentValue = 18,
    Callback = function(deger)
        AimbotYumusakligi = deger / 100
    end
})

AimbotSekmesi:CreateSlider({
    Name = "FOV Dairesi Buyuklugu",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(deger)
        AimbotFovYaricapi = deger
    end
})

AimbotSekmesi:CreateDropdown({
    Name = "Aimbot Kemigi",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(secim)
        AimbotKemigiSecili = secim[1]
    end
})

AimbotSekmesi:CreateToggle({ Name = "FOV Dairesini Ekranda Goster", CurrentValue = false, Callback = function(v) FovDaireAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Sessiz Aim (Silent Aim)", CurrentValue = false, Callback = function(v) SessizAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Legit Aim", CurrentValue = false, Callback = function(v) LegitAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Rage Aim", CurrentValue = false, Callback = function(v) RageAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Hedef Kilitle (Target Lock)", CurrentValue = false, Callback = function(v) HedefKilitleAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Otomatik Ates (Auto Shoot)", CurrentValue = false, Callback = function(v) OtomatikAtesAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Tetik Botu (Triggerbot)", CurrentValue = false, Callback = function(v) TetikBotuAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Yumusak Aim (Smooth Aim)", CurrentValue = false, Callback = function(v) YumusakAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Nisan Tahmini (Aim Prediction)", CurrentValue = false, Callback = function(v) NisantahminiAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "En Yakin Hedef", CurrentValue = false, Callback = function(v) EnYakinHedefAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Hedef Degistir", CurrentValue = false, Callback = function(v) HedefDegistirAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Gorunurluk Kontrolu", CurrentValue = true, Callback = function(v) GorunurlukKontrolAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Takim Kontrolu", CurrentValue = true, Callback = function(v) TakimKontrolAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Arkadas Kontrolu", CurrentValue = true, Callback = function(v) ArkadasKontrolAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Olum Kontrolu", CurrentValue = true, Callback = function(v) OlumKontrolAimAktif = v end })
AimbotSekmesi:CreateToggle({ Name = "Baygin Kontrolu", CurrentValue = true, Callback = function(v) BayginKontrolAimAktif = v end })

-- [SATIR 262] 2. SEKME: HEDEF AYARLARI (TUS SADECE BURADA)
local HedefSekmesi = AnaPencere:CreateTab("Hedef Ayarlari", 4483362458)

HedefSekmesi:CreateDropdown({
    Name = "Hedef Bolgesi",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(secim)
        HedefBolgeSecili = secim[1]
        AimbotKemigiSecili = secim[1]
    end
})

HedefSekmesi:CreateDropdown({
    Name = "Hedef Onceligi",
    Options = {"En Yakin", "En Dusuk Can", "FOV Ici"},
    CurrentOption = {"En Yakin"},
    Callback = function(secim)
        HedefOnceligiSecili = secim[1]
    end
})

HedefSekmesi:CreateSlider({
    Name = "Hedef Mesafe Siniri",
    Range = {20, 1000},
    Increment = 10,
    CurrentValue = 300,
    Callback = function(deger)
        HedefMesafesiSiniri = deger
    end
})

HedefSekmesi:CreateDropdown({
    Name = "Hedef Takim Modu",
    Options = {"Dusmanlar", "Herkes", "Takim Disi"},
    CurrentOption = {"Dusmanlar"},
    Callback = function(secim)
        HedefTakimModu = secim[1]
    end
})

HedefSekmesi:CreateToggle({
    Name = "Hedef Gorunurluk Kontrolu",
    CurrentValue = false,
    Callback = function(v) HedefGorunurlukAktif = v end
})
HedefSekmesi:CreateToggle({
    Name = "Hedef Gorunurluk Ekran Tusu",
    CurrentValue = false,
    Callback = function(v)
        HedefGorunurlukTusAktif = v
        HedefEkranTusuYonet("gorunurluk", "HEDEF VIS", v, function(durum)
            HedefGorunurlukAktif = durum
        end)
    end
})

HedefSekmesi:CreateToggle({
    Name = "Hedef Kilitle Ekran Tusu",
    CurrentValue = false,
    Callback = function(v)
        HedefKilitleTusAktif = v
        HedefEkranTusuYonet("kilitle", "HEDEF KILIT", v, function(durum)
            HedefKilitleAktif = durum
        end)
    end
})

HedefSekmesi:CreateToggle({
    Name = "Hedef Degistir Ekran Tusu",
    CurrentValue = false,
    Callback = function(v)
        HedefDegistirTusAktif = v
        HedefEkranTusuYonet("degistir", "HEDEF DEGIS", v, function(durum)
            HedefDegistirAktif = durum
        end)
    end
})

HedefSekmesi:CreateInput({
    Name = "Yok Sayilan Oyuncular",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(metin) YokSayilanIsimlerMetni = metin end
})

HedefSekmesi:CreateInput({
    Name = "Beyaz Liste (Whitelist)",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(metin) BeyazListeIsimlerMetni = metin end
})

HedefSekmesi:CreateInput({
    Name = "Kara Liste (Blacklist)",
    PlaceholderText = "Isim1, Isim2",
    RemoveTextAfterFocusLost = false,
    Callback = function(metin) KaraListeIsimlerMetni = metin end
})
-- [SATIR 336] 3. SEKME: ESP VE GORSEL
local EspSekmesi = AnaPencere:CreateTab("ESP", 4483362458)
EspSekmesi:CreateToggle({ Name = "Oyuncu ESP", CurrentValue = false, Callback = function(v) OyuncuEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Kutu ESP", CurrentValue = false, Callback = function(v) KutuEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Iskelet ESP", CurrentValue = false, Callback = function(v) IskeletEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Isim ESP", CurrentValue = false, Callback = function(v) IsimEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Can ESP", CurrentValue = false, Callback = function(v) CanEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Mesafe ESP", CurrentValue = false, Callback = function(v) MesafeEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Cizgi ESP (Tracer)", CurrentValue = false, Callback = function(v) CizgiEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "2D Kutu", CurrentValue = false, Callback = function(v) Kutu2DEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "3D Kutu", CurrentValue = false, Callback = function(v) Kutu3DEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Kafa ESP", CurrentValue = false, Callback = function(v) KafaEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Snaplines", CurrentValue = false, Callback = function(v) SnaplineEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Chams", CurrentValue = false, Callback = function(v) ChamsEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Parlama ESP", CurrentValue = false, Callback = function(v) ParlamaEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Esya ESP", CurrentValue = false, Callback = function(v) EsyaEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Silah ESP", CurrentValue = false, Callback = function(v) SilahEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Sadece Dusmanlar", CurrentValue = true, Callback = function(v) SadeceDusmanEspAktif = v end })
EspSekmesi:CreateToggle({ Name = "Sadece Gorunenler", CurrentValue = false, Callback = function(v) SadeceGorunenEspAktif = v end })

-- [SATIR 355] 4. SEKME: HAREKET
local HareketSekmesi = AnaPencere:CreateTab("Hareket", 4483362458)
HareketSekmesi:CreateSlider({ Name = "Kosma Hizi", Range = {16, 120}, Increment = 1, CurrentValue = 32, Callback = function(v) SeciliHizDegeri = v end })
HareketSekmesi:CreateSlider({ Name = "Ziplama Gucu", Range = {50, 200}, Increment = 5, CurrentValue = 85, Callback = function(v) SeciliZiplamaDegeri = v end })
HareketSekmesi:CreateSlider({ Name = "Ucus Hizi", Range = {15, 150}, Increment = 5, CurrentValue = 55, Callback = function(v) SeciliUcusHizi = v end })
HareketSekmesi:CreateSlider({ Name = "Yercekimi", Range = {10, 196}, Increment = 2, CurrentValue = 75, Callback = function(v) SeciliYercekimi = v end })
HareketSekmesi:CreateToggle({ Name = "Hiz Hilesi", CurrentValue = false, Callback = function(v) HizHilesiAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Ucus Hilesi", CurrentValue = false, Callback = function(v) UcusHilesiAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Sinirsiz Ziplama", CurrentValue = false, Callback = function(v) SinirsizZiplamaAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Duvar Gecisi (No Clip)", CurrentValue = false, Callback = function(v) DuvarGecisiAktif = v end })
HareketSekmesi:CreateToggle({ Name = "En Yakina Isinlan", CurrentValue = false, Callback = function(v) IsinlanmaAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Super Ziplama", CurrentValue = false, Callback = function(v) SuperZiplamaAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Yavaslama Kaldir", CurrentValue = false, Callback = function(v) YavaslamaKaldirAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Havada Yurume", CurrentValue = false, Callback = function(v) HavadaYurumeAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Yercekimi Hilesi", CurrentValue = false, Callback = function(v) YercekimiHilesiAktif = v; DunyaServisi.Gravity = v and SeciliYercekimi or 196.2 end })
HareketSekmesi:CreateToggle({ Name = "Spinbot", CurrentValue = false, Callback = function(v) SpinbotAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Bunny Hop", CurrentValue = false, Callback = function(v) TavsanZiplamaAktif = v end })
HareketSekmesi:CreateToggle({ Name = "Dusme Koruma", CurrentValue = false, Callback = function(v) DusmeKorumaAktif = v end })

-- [SATIR 375] 5. SEKME: SILAH VE SAVAS
local SilahSekmesi = AnaPencere:CreateTab("Silah", 4483362458)
SilahSekmesi:CreateToggle({ Name = "Sekme Kaldir (No Recoil)", CurrentValue = false, Callback = function(v) SekmeKaldirAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Dagilma Kaldir (No Spread)", CurrentValue = false, Callback = function(v) DagilmaKaldirAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Hizli Ates", CurrentValue = false, Callback = function(v) HizliAtesAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Hizli Sarjor", CurrentValue = false, Callback = function(v) HizliSarjorAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Sinirsiz Mermi", CurrentValue = false, Callback = function(v) SinirsizMermiAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Sarjor Yok", CurrentValue = false, Callback = function(v) SarjorYokAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Hasar Degistirici", CurrentValue = false, Callback = function(v) HasarDegistirAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Hitbox Buyutucu", CurrentValue = false, Callback = function(v) HitboxBuyutAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Yakin Dovus Aura", CurrentValue = false, Callback = function(v) YakinDovusAuraAktif = v end })
SilahSekmesi:CreateToggle({ Name = "Otomatik Oldur", CurrentValue = false, Callback = function(v) OtomatikOldurAktif = v end })

-- [SATIR 387] 6. SEKME: KONTROLLER VE FILTRELER
local FiltreSekmesi = AnaPencere:CreateTab("Kontroller", 4483362458)
FiltreSekmesi:CreateToggle({ Name = "Takim Kontrolu", CurrentValue = true, Callback = function(v) FiltreTakimKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Arkadas Kontrolu", CurrentValue = true, Callback = function(v) FiltreArkadasKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Dusman Kontrolu", CurrentValue = true, Callback = function(v) FiltreDusmanKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Canli Kontrolu", CurrentValue = true, Callback = function(v) FiltreCanliKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Olu Kontrolu", CurrentValue = true, Callback = function(v) FiltreOluKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Gorunurluk Kontrolu", CurrentValue = true, Callback = function(v) FiltreGorunurKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Duvar Kontrolu", CurrentValue = true, Callback = function(v) FiltreDuvarKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Mesafe Kontrolu", CurrentValue = false, Callback = function(v) FiltreMesafeKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Can Kontrolu", CurrentValue = false, Callback = function(v) FiltreCanKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "NPC Kontrolu", CurrentValue = false, Callback = function(v) FiltreNpcKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Bot Kontrolu", CurrentValue = false, Callback = function(v) FiltreBotKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "AFK Kontrolu", CurrentValue = false, Callback = function(v) FiltreAfkKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Guvenli Bolge Kontrolu", CurrentValue = false, Callback = function(v) FiltreGuvenliBolgeKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "FOV Kontrolu", CurrentValue = true, Callback = function(v) FiltreFovKontrol = v end })
FiltreSekmesi:CreateToggle({ Name = "Arac Kontrolu", CurrentValue = false, Callback = function(v) FiltreAracKontrol = v end })

-- [SATIR 404] 7. SEKME: DIGER, KARAKTER VE DUNYA
local DigerSekmesi = AnaPencere:CreateTab("Diger & Dunya", 4483362458)
DigerSekmesi:CreateSlider({ Name = "Kamera FOV", Range = {50, 120}, Increment = 1, CurrentValue = 85, Callback = function(v) SeciliKameraFov = v; if FovDegistirAktif and AktifKamera then AktifKamera.FieldOfView = v end end })
DigerSekmesi:CreateToggle({ Name = "Kamera FOV Degistir", CurrentValue = false, Callback = function(v) FovDegistirAktif = v; if AktifKamera then AktifKamera.FieldOfView = v and SeciliKameraFov or 70 end end })
DigerSekmesi:CreateToggle({ Name = "Tam Aydinlik (Fullbright)", CurrentValue = false, Callback = function(v) TamAydinlikAktif = v; if v then AydinlatmaServisi.Brightness = 2.5; AydinlatmaServisi.ClockTime = 14; AydinlatmaServisi.GlobalShadows = false end end })
DigerSekmesi:CreateToggle({ Name = "Sis Kaldir (No Fog)", CurrentValue = false, Callback = function(v) SisKaldirAktif = v; AydinlatmaServisi.FogEnd = v and 1e6 or 500 end })
DigerSekmesi:CreateToggle({ Name = "Gece Gorusu", CurrentValue = false, Callback = function(v) GeceGorusuAktif = v; AydinlatmaServisi.Ambient = v and Color3.fromRGB(65, 220, 120) or Color3.fromRGB(0, 0, 0) end })
DigerSekmesi:CreateToggle({ Name = "Karakter & Vurgu ESP", CurrentValue = false, Callback = function(v) KarakterEspAktif = v; OyuncuVurguAktif = v; OyuncuChamsAktif = v end })
DigerSekmesi:CreateToggle({ Name = "Dunya & Ganimet ESP", CurrentValue = false, Callback = function(v) DunyaEspAktif = v; GanimetEspAktif = v; EsyaBulucuAktif = v; SilahBulucuAktif = v end })
DigerSekmesi:CreateToggle({ Name = "Anti-Aim", CurrentValue = false, Callback = function(v) AntiAimAktif = v end })
DigerSekmesi:CreateToggle({ Name = "Vurus / Oldurme Sesi", CurrentValue = false, Callback = function(v) VurusSesiAktif = v; OldurmeSesiAktif = v end })
DigerSekmesi:CreateToggle({ Name = "FPS Siniri Kaldir", CurrentValue = false, Callback = function(v) FpsSinirKaldirAktif = v; if setfpscap then setfpscap(v and 240 or 60) end end })
-- [SATIR 416] Ekranda FOV Dairesi (Drawing Destegi Varsa)
local FovDaireCizimi = nil
if Drawing then
    FovDaireCizimi = Drawing.new("Circle")
    FovDaireCizimi.Thickness = 1.8
    FovDaireCizimi.NumSides = 64
    FovDaireCizimi.Filled = false
    FovDaireCizimi.Visible = false
    FovDaireCizimi.Color = FovDaireRengi
end

-- [SATIR 428] Isim Liste Kontrolu ve Takim / Gorunurluk Yardimcilari
local function ListeIcindeMi(oyuncuAdi, listeMetni)
    if not listeMetni or listeMetni == "" then return false end
    local aranan = oyuncuAdi:lower()
    for parca in string.gmatch(listeMetni, "[^,]+") do
        local temiz = parca:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if temiz == aranan then return true end
    end
    return false
end

local function DusmanMi(oyuncu)
    if not oyuncu or oyuncu == BenimOyuncu then return false end
    if HedefTakimModu == "Herkes" then return true end
    if (TakimKontrolAimAktif or FiltreTakimKontrol) and BenimOyuncu.Team and oyuncu.Team then
        return oyuncu.Team ~= BenimOyuncu.Team
    end
    return true
end

local function ArkadasMi(oyuncu)
    if not oyuncu then return false end
    local basarili, sonuc = pcall(function() return BenimOyuncu:IsFriendsWith(oyuncu.UserId) end)
    return basarili and sonuc or false
end

local function GorunurMu(hedefParca)
    if not AktifKamera or not hedefParca then return true end
    local rayParam = RaycastParams.new()
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    local haricler = {}
    if BenimOyuncu.Character then table.insert(haricler, BenimOyuncu.Character) end
    if hedefParca.Parent then table.insert(haricler, hedefParca.Parent) end
    rayParam.FilterDescendantsInstances = haricler
    local baslangic = AktifKamera.CFrame.Position
    local yon = hedefParca.Position - baslangic
    local carpisma = DunyaServisi:Raycast(baslangic, yon, rayParam)
    return carpisma == nil
end

-- [SATIR 468] Aktif Hedefi Secme Fonksiyonu
local function HedefSec()
    if not AktifKamera then return nil end
    local ekranMerkezi = Vector2.new(AktifKamera.ViewportSize.X * 0.5, AktifKamera.ViewportSize.Y * 0.5)
    local secilenParca = nil
    local enIyiPuan = math.huge

    for _, oyuncu in ipairs(OyuncularServisi:GetPlayers()) do
        if oyuncu ~= BenimOyuncu and oyuncu.Character then
            if ListeIcindeMi(oyuncu.Name, YokSayilanIsimlerMetni) then continue end
            if HedefFiltreModu == "Beyaz Liste" and not ListeIcindeMi(oyuncu.Name, BeyazListeIsimlerMetni) then continue end
            if HedefFiltreModu == "Kara Liste" and ListeIcindeMi(oyuncu.Name, KaraListeIsimlerMetni) then continue end

            local karakter = oyuncu.Character
            local canInsani = karakter:FindFirstChildOfClass("Humanoid")
            local parca = karakter:FindFirstChild(HedefBolgeSecili) or karakter:FindFirstChild(AimbotKemigiSecili) or karakter:FindFirstChild("HumanoidRootPart")

            local canliOk = not (OlumKontrolAimAktif or FiltreCanliKontrol) or (canInsani and canInsani.Health > 0)
            local dusmanOk = not (TakimKontrolAimAktif or FiltreDusmanKontrol) or DusmanMi(oyuncu)
            local arkadasOk = not ((ArkadasKontrolAimAktif or FiltreArkadasKontrol) and ArkadasMi(oyuncu))
            local gorunurOk = not ((GorunurlukKontrolAimAktif or FiltreGorunurlukKontrol or HedefGorunurlukAktif) and not GorunurMu(parca))

            if canliOk and dusmanOk and arkadasOk and gorunurOk and parca then
                local dunyaMesafe = (parca.Position - AktifKamera.CFrame.Position).Magnitude
                if dunyaMesafe <= HedefMesafesiSiniri then
                    local ekranKonum, ekranda = AktifKamera:WorldToViewportPoint(parca.Position)
                    if ekranda and ekranKonum.Z > 0 then
                        local fovFarki = (Vector2.new(ekranKonum.X, ekranKonum.Y) - ekranMerkezi).Magnitude
                        if not FiltreFovKontrol or fovFarki <= AimbotFovYaricapi then
                            local puan = dunyaMesafe
                            if HedefOnceligiSecili == "En Dusuk Can" and canInsani then
                                puan = canInsani.Health
                            elseif HedefOnceligiSecili == "FOV Ici" then
                                puan = fovFarki
                            end
                            if puan < enIyiPuan then
                                enIyiPuan = puan
                                secilenParca = parca
                            end
                        end
                    end
                end
            end
        end
    end

    return secilenParca
end

-- [SATIR 505] ESP Vurgulama Sistemi
local EspVurgulari = {}
local function EspGuncelle()
    local herhangiEspAcik = OyuncuEspAktif or KutuEspAktif or Kutu2DEspAktif or Kutu3DEspAktif or ChamsEspAktif or ParlamaEspAktif or KarakterEspAktif or OyuncuVurguAktif or OyuncuChamsAktif
    for _, oyuncu in ipairs(OyuncularServisi:GetPlayers()) do
        if oyuncu ~= BenimOyuncu and oyuncu.Character then
            local goster = herhangiEspAcik and (not SadeceDusmanEspAktif or DusmanMi(oyuncu))
            local mevcutVurgu = EspVurgulari[oyuncu]
            if goster then
                if not mevcutVurgu or not mevcutVurgu.Parent then
                    mevcutVurgu = Instance.new("Highlight")
                    mevcutVurgu.FillTransparency = 0.65
                    mevcutVurgu.OutlineTransparency = 0
                    mevcutVurgu.Parent = oyuncu.Character
                    EspVurgulari[oyuncu] = mevcutVurgu
                end
                mevcutVurgu.FillColor = DusmanMi(oyuncu) and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(65, 220, 120)
            elseif mevcutVurgu then
                mevcutVurgu:Destroy()
                EspVurgulari[oyuncu] = nil
            end
        end
    end
end

-- [SATIR 526] Havada Yurume ve Ziplama Baglantilari
local YurumePlatformu = Instance.new("Part")
YurumePlatformu.Name = "TurkceHubAirWalk"
YurumePlatformu.Size = Vector3.new(8, 1, 8)
YurumePlatformu.Anchored = true
YurumePlatformu.CanCollide = true
YurumePlatformu.Transparency = 1
YurumePlatformu.Parent = DunyaServisi

GirisServisi.JumpRequest:Connect(function()
    if SinirsizZiplamaAktif or TavsanZiplamaAktif then
        local insani = BenimOyuncu.Character and BenimOyuncu.Character:FindFirstChildOfClass("Humanoid")
        if insani then insani:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- [SATIR 542] Ana Kare Dongusu
CalismaServisi.RenderStepped:Connect(function()
    EspGuncelle()

    if FovDaireCizimi and AktifKamera then
        FovDaireCizimi.Visible = FovDaireAktif
        FovDaireCizimi.Radius = AimbotFovYaricapi
        FovDaireCizimi.Position = Vector2.new(AktifKamera.ViewportSize.X * 0.5, AktifKamera.ViewportSize.Y * 0.5)
        FovDaireCizimi.Color = FovDaireRengi
    end

    local karakter = BenimOyuncu.Character
    local insani = karakter and karakter:FindFirstChildOfClass("Humanoid")
    local kokParca = karakter and karakter:FindFirstChild("HumanoidRootPart")

    if insani then
        if HizHilesiAktif then insani.WalkSpeed = SeciliHizDegeri end
        if SuperZiplamaAktif then insani.JumpPower = SeciliZiplamaDegeri end
        if YavaslamaKaldirAktif and insani.WalkSpeed < 16 then insani.WalkSpeed = 16 end
    end

    if karakter and DuvarGecisiAktif then
        for _, parca in ipairs(karakter:GetDescendants()) do
            if parca:IsA("BasePart") then parca.CanCollide = false end
        end
    end

    if kokParca then
        if HavadaYurumeAktif then
            YurumePlatformu.Position = kokParca.Position - Vector3.new(0, 3.5, 0)
        else
            YurumePlatformu.Position = Vector3.new(0, -5000, 0)
        end

        if UcusHilesiAktif then
            local yon = insani and insani.MoveDirection or Vector3.zero
            kokParca.AssemblyLinearVelocity = yon * SeciliUcusHizi + Vector3.new(0, 2, 0)
        end

        if SpinbotAktif or AntiAimAktif then
            kokParca.CFrame = kokParca.CFrame * CFrame.Angles(0, math.rad(20), 0)
        end

        if DusmeKorumaAktif and kokParca.AssemblyLinearVelocity.Y < -65 then
            kokParca.AssemblyLinearVelocity = Vector3.new(kokParca.AssemblyLinearVelocity.X, -15, kokParca.AssemblyLinearVelocity.Z)
        end
    end

    local aimCalissin = AimbotAktif or LegitAimAktif or RageAimAktif or HedefKilitleAktif or YumusakAimAktif
    if aimCalissin and AktifKamera then
        local hedef = HedefSec()
        if hedef then
            local hedefKonum = hedef.Position
            if NisantahminiAktif and hedef:IsA("BasePart") then
                hedefKonum = hedefKonum + (hedef.AssemblyLinearVelocity * 0.14)
            end

            local yumusaklik = AimbotYumusakligi
            if AimbotTuruSecili == "Legit Aim" or LegitAimAktif then
                yumusaklik = math.min(yumusaklik, 0.10)
            elseif AimbotTuruSecili == "Rage Aim" or RageAimAktif then
                yumusaklik = 0.90
            elseif AimbotTuruSecili == "Hedef Kilitle" or HedefKilitleAktif then
                yumusaklik = 0.70
            elseif AimbotTuruSecili == "Normal Aim" then
                yumusaklik = 0.45
            end

            local istenenAci = CFrame.lookAt(AktifKamera.CFrame.Position, hedefKonum)
            AktifKamera.CFrame = AktifKamera.CFrame:Lerp(istenenAci, math.clamp(yumusaklik, 0.02, 1))
        end
    end
end)
