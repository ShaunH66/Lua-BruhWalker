if game.local_player.champ_name ~= "Vladimir" then
	return
end

do
    local function AutoUpdate()
		local Version = 1
		local file_name = "VladToTheImir.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/VladToTheImir.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/VladToTheImir.lua.version.txt")
        console:log("VladToTheImir.Lua Vers: "..Version)
		console:log("VladToTheImir.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("-----------------------------------------")
            console:log("Shaun's Sexy Vladimir v1 successfully loaded.....")
						console:log("-----------------------------------------")

        else
			http:download_file(url, file_name)
			      console:log("Sexy Vladimir Update available.....")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
        end

    end

    AutoUpdate()
end

--[[local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = "W", type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = "E", type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AhriQ"] = {charName = "Ahri", displayName = "Ahri Orb of Deception", slot = "Q", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 100, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = "R", type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["AniviaQ"] = {charName = "Anivia", displayName = "Flash Frost", slot = "Q", type = "linear", speed = 850, range = 1075, delay = 0.5, radius = 125, collision = true},
	["AsheR"] = {charName = "Ashe", displayName = "Enchanted Crysta lArrow", slot = "R", type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = true},
	["AsheW"] = {charName = "Ashe", displayName = "Volley Attack", slot = "W", type = "linear", speed = 1500, range = 1350, delay = 0.25, radius = 20, collision = true},
	["AzirQ"] = {charName = "AzirQ", displayName = "Conquering Sands", slot = "Q", type = "linear", speed = 1600, range = 1150, delay = 0.25, radius = 80, collision = true},
	["AzirQ"] = {charName = "AzirQ", displayName = "Conquering Sands", slot = "Q", type = "linear", speed = 1600, range = 1150, delay = 0.25, radius = 80, collision = true},
	["AkaliE"] = {charName = "Akali", displayName = "Shuriken Flip", slot = "E", type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 70, collision = true},
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = "Q", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = "Q", type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = "R", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 550, collision = false},
	["AniviaQ"] = {charName = "Anivia", displayName = "Flash Frost", slot = "Q", type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = "R", type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = "Q", type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = "R", type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["ApheliosR"] = {charName = "Aphelios", displayName = "Moonlight Vigil", slot = "R", type = "linear", speed = 2050, range = 1600, delay = 0.5, radius = 125, collision = false},
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = "Q", type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = "R", type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["BrandQ"] = {charName = "Brand", displayName = "Sear", slot = "Q", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 60, collision = true},
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = "Q", type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = "Q", type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = "R", type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = "W", type = "circular", speed = math.huge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = "E", type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = "Q", type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = "E", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["DravenRCast"] = {charName = "Draven", displayName = "Whirling Death", slot = "R", type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},
	["DianaQ"] = {charName = "Diana", displayName = "Crescent Strike", slot = "Q", type = "circular", speed = 1900, range = 900, delay = 0.25, radius = 185, collision = true},
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = "Q", type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = "E", type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
	["EzrealR"] = {charName = "Ezreal", displayName = "Trueshot Barrage", slot = "R", type = "linear", speed = 2000, range = 12500, delay = 1, radius = 160, collision = true},
	["EzrealQ"] = {charName = "Ezreal", displayName = "Mystic Shot", slot = "Q", type = "linear", speed = 2000, range = 1200, delay = 0.25, radius = 60, collision = true},
	["FizzR"] = {charName = "Fizz", displayName = "Chum the Waters", slot = "R", type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["GalioE"] = {charName = "Galio", displayName = "Justice Punch", slot = "E", type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, collision = false},
	["GnarQMissile"] = {charName = "Gnar", displayName = "Boomerang Throw", slot = "Q", type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, collision = false},
	["GnarBigQMissile"] = {charName = "Gnar", displayName = "Boulder Toss", slot = "Q", type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, collision = true},
	["GnarBigW"] = {charName = "Gnar", displayName = "Wallop", slot = "W", type = "linear", speed = math.huge, range = 575, delay = 0.6, radius = 100, collision = false},
	["GnarR"] = {charName = "Gnar", displayName = "GNAR!", slot = "R", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 475, collision = false},
	["GragasQ"] = {charName = "Gragas", displayName = "Barrel Roll", slot = "Q", type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasR"] = {charName = "Gragas", displayName = "Explosive Cask", slot = "R", type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GravesSmokeGrenade"] = {charName = "Graves", displayName = "Smoke Grenade", slot = "W", type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["HeimerdingerE"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = "E", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerEUlt"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = "E", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["IreliaR"] = {charName = "Irelia", displayName = "Vanguard's Edge", slot = "R", type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, collision = false},
	["IvernQ"] = {charName = "Ivern", displayName = "Rootcaller", slot = "Q", type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["IllaoiE"] = {charName = "Illaoi", displayName = "Test of Spirit", slot = "E", type = "linear", speed = 1900, range = 900, delay = 0.25, radius = 50, collision = true},
	["IvernQ"] = {charName = "Ivern", displayName = "Rootcaller", slot = "Q", type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["HowlingGaleSpell"] = {charName = "Janna", displayName = "Howling Gale", slot = "Q", type = "linear", speed = 667, range = 1750, delay = 0, radius = 100, collision = false},
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = "Q", type = "linear", speed = math.huge, range = 770, delay = 0.4, radius = 70, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = "W", type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinRShot"] = {charName = "Jhin", displayName = "Curtain Call", slot = "R", type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = "E", type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JinxWMissile"] = {charName = "Jinx", displayName = "Zap!", slot = "W", type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = true},
	["JinxR"] = {charName = "Jinx", displayName = "Super Mega Death Rocket!", slot = "R", type = "linear", speed = 1700, range = 0.25, delay = 0.6, radius = 60, collision = true},
	["KarmaQ"] = {charName = "Karma", displayName = "Inner Flame", slot = "Q", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra]", slot = "Q", origin = "linear", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KayleQ"] = {charName = "Kayle", displayName = "Radiant Blast", slot = "Q", type = "linear", speed = 2000, range = 850, delay = 0.5, radius = 60, collision = false},
	["KaynW"] = {charName = "Kayn", displayName = "Blade's Reach", slot = "W", type = "linear", speed = math.huge, range = 700, delay = 0.55, radius = 90, collision = false},
	["KhazixWLong"] = {charName = "Khazix", displayName = "Void Spike [Threeway]", slot = "W", type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70,angle = 23, collision = true},
	["KledQ"] = {charName = "Kled", displayName = "Beartrap on a Rope", slot = "Q", type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["BlindMonkQOne"] = {charName = "Leesin", displayName = "Sonic Wave", slot = "Q", type = "linear", speed = 1800, range = 1100, delay = 0.25, radius = 60, collision = true},
	["LeblancE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard]", slot = "E", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancRE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate]", slot = "E", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeonaZenithBlade"] = {charName = "Leona", displayName = "Zenith Blade", slot = "E", type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, collision = false},
	["LissandraQMissile"] = {charName = "Lissandra", displayName = "Ice Shard", slot = "Q", type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, collision = false},
	["LuluQ"] = {charName = "Lulu", displayName = "Glitterlance", slot = "Q", type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LucianQ"] = {charName = "Lucian", displayName = "Piercing Light", slot = "Q", type = "linear", speed = math.huge, range = 1140, delay = 0.25, radius = 65, collision = false},
	["LuxLightBinding"] = {charName = "Lux", displayName = "Light Binding", slot = "Q", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = false},
	["LuxMaliceCannonMis"] = {charName = "Lux", displayName = "Ult", slot = "R", type = "linear", speed = math.huge, range = 3340, delay = 1, radius = 100, collision = false},
	["Landslide"] = {charName = "Malphite", displayName = "Ground Slam", slot = "E", type = "circular", speed = math.huge, range = 0, delay = 0.242, radius = 400, collision = false},
	["MalzaharQ"] = {charName = "Malzahar", displayName = "Call of the Void", slot = "Q", type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MaokaiQ"] = {charName = "Maokai", displayName = "Bramble Smash", slot = "Q", type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["MorganaQ"] = {charName = "Morgana", displayName = "Dark Binding", slot = "Q", type = "linear", speed = 1200, range = 1250, delay = 0.25, radius = 70, collision = true},
	["NamiQ"] = {charName = "Nami", displayName = "Aqua Prison", slot = "Q", type = "circular", speed = math.huge, range = 875, delay = 1, radius = 180, collision = false},
	["NamiRMissile"] = {charName = "Nami", displayName = "Tidal Wave", slot = "R", type = "linear", speed = 850, range = 2750, delay = 0.5, radius = 250, collision = false},
	["NautilusAnchorDragMissile"] = {charName = "Nautilus", displayName = "Dredge Line", slot = "Q", type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 90, collision = true},
	["NeekoQ"] = {charName = "Neeko", displayName = "Blooming Burst", slot = "Q", type = "circular", speed = 1500, range = 800, delay = 0.25, radius = 200, collision = false},
	["NeekoE"] = {charName = "Neeko", displayName = "Tangle-Barbs", slot = "E", type = "linear", speed = 1400, range = 1000, delay = 0.25, radius = 65, collision = false},
	["NidaleeQ"] = {charName = "Niddalee", displayName = "Javelin Toss", slot = "Q", type = "linear", speed = 1300, range = 1500, delay = 0.25, radius = 40, collision = true},
	["OlafAxeThrowCast"] = {charName = "Olaf", displayName = "Undertow", slot = "Q", type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OrnnQ"] = {charName = "Ornn", displayName = "Volcanic Rupture", slot = "Q", type = "linear", speed = 1800, range = 800, delay = 0.3, radius = 65, collision = false},
	["OrnnE"] = {charName = "Ornn", displayName = "Searing Charge", slot = "E", type = "linear", speed = 1600, range = 800, delay = 0.35, radius = 150, collision = false},
	["OrnnRCharge"] = {charName = "Ornn", displayName = "Call of the Forge God", slot = "R", type = "linear", speed = 1650, range = 2500, delay = 0.5, radius = 200, collision = false},
	["PoppyQSpell"] = {charName = "Poppy", displayName = "Hammer Shock", slot = "Q", type = "linear", speed = math.huge, range = 430, delay = 0.332, radius = 100, collision = false},
	["PoppyRSpell"] = {charName = "Poppy", displayName = "Keeper's Verdict", slot = "R", type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PykeQMelee"] = {charName = "Pyke", displayName = "Bone Skewer [Melee]", slot = "Q", type = "linear", speed = math.huge, range = 400, delay = 0.25, radius = 70, collision = false},
	["PykeQRange"] = {charName = "Pyke", displayName = "Bone Skewer [Range]", slot = "Q", type = "linear", speed = 2000, range = 1100, delay = 0.2, radius = 70, collision = true},
	["PykeE"] = {charName = "Pyke", displayName = "Phantom Undertow", slot = "E", type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["QiyanaR"] = {charName = "Qiyana", displayName = "Supreme Display of Talent", slot = "R", type = "linear", speed = 2000, range = 950, delay = 0.25, radius = 190, collision = false},
	["RakanW"] = {charName = "Rakan", displayName = "Grand Entrance", slot = "W", type = "circular", speed = math.huge, range = 650, delay = 0.7, radius = 265, collision = false},
	["RengarE"] = {charName = "Rengar", displayName = "Bola Strike", slot = "E", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RumbleGrenade"] = {charName = "Rumble", displayName = "Electro Harpoon", slot = "E", type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["SejuaniR"] = {charName = "Sejuani", displayName = "Glacial Prison", slot = "R", type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["ShyvanaTransformLeap"] = {charName = "Shyvana", displayName = "Transform Leap", slot = "R", type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, collision = false},
	["SionQ"] = {charName = "Sion", displayName = "Decimating Smash", slot = "Q", origin = "", type = "linear", speed = math.huge, range = 750, delay = 2, radius = 150, collision = false},
	["SionE"] = {charName = "Sion", displayName = "Roar of the Slayer", slot = "E", type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SkarnerFractureMissile"] = {charName = "Skarner", displayName = "Fracture", slot = "E", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = false},
	["SonaR"] = {charName = "Sona", displayName = "Crescendo", slot = "R", type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SorakaQ"] = {charName = "Soraka", displayName = "Starcall", slot = "Q", type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SwainW"] = {charName = "Swain", displayName = "Vision of Empire", slot = "W", type = "circular", speed = math.huge, range = 3500, delay = 1.5, radius = 300, collision = false},
	["SwainE"] = {charName = "Swain", displayName = "Nevermove", slot = "E", type = "linear", speed = 1800, range = 850, delay = 0.25, radius = 85, collision = false},
	["SylasE2"] = {charName = "Sylas", displayName = "Abduct", slot = "E", type = "linear", speed = 1600, range = 850, delay = 0.25, radius = 60, collision = true},
	["SyndraE"] = {charName = "Syndra", displayName = "Scatter the Weak", slot = "E", type = "linear", speed = 2000, range = 850, delay =  0.25, radius = 90, collision = true},
	["TahmKenchQ"] = {charName = "TahmKench", displayName = "Tongue Lash", slot = "Q", type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TaliyahWVC"] = {charName = "Taliyah", displayName = "Seismic Shove", slot = "W", type = "circular", speed = math.huge, range = 900, delay = 0.85, radius = 150, collision = false},
	["TaliyahR"] = {charName = "Taliyah", displayName = "Weaver's Wall", slot = "R", type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["ThreshE"] = {charName = "Thresh", displayName = "Flay", slot = "E", type = "linear", speed = math.huge, range = 500, delay = 0.389, radius = 110, collision = true},
	["ThreshQ"] = {charName = "Thresh", displayName = "Death Sentence", slot = "Q", type = "linear", speed = 1900, range = 1200, delay = 0.5, radius = 70, collision = true},
	["OriannaQ"] = {charName = "Orianna", displayName = "Command: Dissonance", slot = "Q", type = "circular", speed = 1150, range = 1825, delay = 0.25, radius = 250, collision = false},
	["TristanaW"] = {charName = "Tristana", displayName = "Rocket Jump", slot = "W", type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, collision = false},
	["UrgotQ"] = {charName = "Urgot", displayName = "Corrosive Charge", slot = "Q", type = "circular", speed = math.huge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotE"] = {charName = "Urgot", displayName = "Disdain", slot = "E", type = "linear", speed = 1540, range = 475, delay = 0.45, radius = 100, collision = false},
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = "R", type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},
	["VarusR"] = {charName = "Varus", displayName = "Chain of Corruption", slot = "R", type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VelkozQ"] = {charName = "Velkoz", displayName = "Plasma Fission", slot = "Q", type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozE"] = {charName = "Velkoz", displayName = "Tectonic Disruption", slot = "E", type = "circular", speed = math.huge, range = 800, delay = 0.8, radius = 185, collision = false},
	["ViktorGravitonField"] = {charName = "Viktor", displayName = "Graviton Field", slot = "W", type = "circular", speed = math.huge, range = 800, delay = 1.75, radius = 270, collision = false},
	["WarwickR"] = {charName = "Warwick", displayName = "Infinite Duress", slot = "R", type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, collision = false},
	["XerathArcaneBarrage2"] = {charName = "Xerath", displayName = "Arcane Barrage", slot = "W", type = "circular", speed = math.huge, range = 1000, delay = 0.75, radius = 235, collision = false},
	["XerathMageSpear"] = {charName = "Xerath", displayName = "Mage Spear", slot = "E", type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XinZhaoW"] = {charName = "XinZhao", displayName = "Wind Becomes Lightning", slot = "W", type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, collision = false},
	["ZacQ"] = {charName = "Zac", displayName = "Stretching Strikes", slot = "Q", type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZiggsW"] = {charName = "Ziggs", displayName = "Satchel Charge", slot = "W", type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, collision = false},
	["ZiggsE"] = {charName = "Ziggs", displayName = "Hexplosive Minefield", slot = "E", type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, collision = false},
	["ZileanQ"] = {charName = "Zilean", displayName = "Time Bomb", slot = "Q", type = "circular", speed = math.huge, range = 900, delay = 0.8, radius = 150, collision = false},
	["RengarE"] = {charName = "Rengar", displayName = "Bola Strike", slot = "E", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["ZoeE"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble", slot = "E", type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZyraE"] = {charName = "Zyra", displayName = "Grasping Roots", slot = "E", type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = false},
	["ZyraR"] = {charName = "Zyra", displayName = "Stranglethorns", slot = "R", type = "circular", speed = math.huge, range = 700, delay = 2, radius = 500, collision = false},
	["RivenR"] = {charName = "Riven", displayName = "Wind Slash", slot = "R", type = "linear", speed = 1600, range = 1100, delay = 0.25, radius = 100, collision = true},
	["BrandConflagration"] = {charName = "Brand", slot = "R", type = "targeted", displayName = "Conflagration", range = 625,cc = true},
	["JarvanIVCataclysm"] = {charName = "JarvanIV", slot = "R", type = "targeted", displayName = "Cataclysm", range = 650},
	["JayceThunderingBlow"] = {charName = "Jayce", slot = "E", type = "targeted", displayName = "Thundering Blow", range = 240},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = "R", type = "targeted", displayName = "Dragon's Rage", range = 375},
	["LissandraR"] = {charName = "Lissandra", slot = "R", type = "targeted", displayName = "Frozen Tomb", range = 550},
	["SeismicShard"] = {charName = "Malphite", slot = "Q", type = "targeted", displayName = "Seismic Shard", range = 625,cc = true},
	["AlZaharNetherGrasp"] = {charName = "Malzahar", slot = "R", type = "targeted", displayName = "Nether Grasp", range = 700},
	["MaokaiW"] = {charName = "Maokai", slot = "W", type = "targeted", displayName = "Twisted Advance", range = 525},
	["NautilusR"] = {charName = "Nautilus", slot = "R", type = "targeted", displayName = "Depth Charge", range = 825},
	["PoppyE"] = {charName = "Poppy", slot = "E", type = "targeted", displayName = "Heroic Charge", range = 475},
	["RyzeW"] = {charName = "Ryze", slot = "W", type = "targeted", displayName = "Rune Prison", range = 615},
	["SkarnerImpale"] = {charName = "Skarner", slot = "R", type = "targeted", displayName = "Impale", range = 350},
	["TahmKenchW"] = {charName = "TahmKench", slot = "W", type = "targeted", displayName = "Devour", range = 250},
	["TristanaR"] = {charName = "Tristana", slot = "R", type = "targeted", displayName = "Buster Shot", range = 669},
	["GarenR"] = {charName = "Garen", slot = "R", type = "targeted", displayName = "Demacian Justice", range = 400},
	["ChoGathR"] = {charName = "ChoGath", slot = "R", type = "targeted", displayName = "Feast", range = 175},
	["GarenQ"] = {charName = "Garen", slot = "Q", type = "targeted", displayName = "Decisive Strike", range = 300},
	["DariusR"] = {charName = "Darius", slot = "R", type = "targeted", displayName = "Noxian Guillotine", range = 460},
	["DariusE"] = {charName = "Darius", displayName = "Apprehend", slot = "E", type = "circular", speed = math.huge, range = 570, delay = 0.32, radius = 55, collision = false},

}]]

pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 600, delay = .25, width = 0, speed = 0 }
local W = { range = 350, delay = .1, width = 0, speed = 0 }
local E = { range = 600, delay = .1, width = 120, speed = 4000 }
local R = { range = 625, delay = .1, width = 375, speed = 0 }


-- Return game data and maths

--Converts from Degrees to Radians
local function D2R(degrees)
  radians = degrees * (math.pi / 180)
  return radians
end

--Subtract two vectors
local function Sub(vec1, vec2)
  new_x = vec1.x - vec2.x
  new_y = vec1.y - vec2.y
  new_z = vec1.z - vec2.z
  sub = vec3.new(new_x, new_y, new_z)
  return sub
end

--Multiplies vector by magnitude
local function VectorMag(vec, mag)
  x, y, z = vec.x, vec.y, vec.z
  new_x = mag * x
  new_y = mag * y
  new_z = mag * z
  output = vec3.new(new_x, new_y, new_z)
  return output
end

--Dot product of two vectors
local function DotProduct(vec1, vec2)
  dot = (vec1.x * vec2.x) + (vec1.y * vec2.y) + (vec1.z * vec2.z)
  return dot
end

--Vector Magnitude
local function Magnitude(vec)
  mag = math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
  return mag
end

--Returns the angle formed from a vector to both input vectors
local function AngleBetween(vec1, vec2)
  dot = DotProduct(vec1, vec2)
  mag1 = Magnitude(vec1)
  mag2 = Magnitude(vec2)
  output = (math.acos(dot / (mag1 * mag2)))
  return output
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	players = game.players
	for i, unit in ipairs(players) do
		if unit and not unit.is_enemy and unit.object_id ~= myHero.object_id then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

local function GetDistanceSqr(unit, p2)
    p2 = p2.origin or myHero.origin
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1 = unit.origin
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

-- Best Prediction Start

local function GetCenter(points)
	local sum_x = 0
	local sum_z = 0

	for i = 1, #points do
		sum_x = sum_x + points[i].origin.x
		sum_z = sum_z + points[i].origin.z
	end

	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	return center
end

local function ContainsThemAll(circle, points)
	local radius_sqr = circle.radi*circle.radi
	local contains_them_all = true
	local i = 1

	while contains_them_all and i <= #points do
		contains_them_all = GetDistanceSqr2(points[i].origin, circle.center) <= radius_sqr
		i = i + 1
	end
	return contains_them_all
end

local function FarthestFromPositionIndex(points, position)
	local index = 2
	local actual_dist_sqr
	local max_dist_sqr = GetDistanceSqr2(points[index].origin, position)

	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr2(points[i].origin, position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	return index
end

local function RemoveWorst(targets, position)
	local worst_target = FarthestFromPositionIndex(targets, position)
	table.remove(targets, worst_target)
	return targets
end

local function GetInitialTargets(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius

	for i, target in ipairs(GetEnemyHeroes()) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and IsValid(target) and GetDistanceSqr(main_target, target) < diameter_sqr then
			table.insert(targets, target)
		end
	end
	return targets
end

local function GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local predicted_main_target = pred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius

		for i, target in ipairs(GetEnemyHeroes()) do
			if target.object_id ~= 0 and IsValid(target) then
				predicted_target = pred:predict(math.huge, delay, 1800, radius, target, false, false)
				if predicted_target.can_cast and target.object_id ~= main_target.object_id and GetDistanceSqr2(predicted_main_target.cast_pos, predicted_target.cast_pos) < diameter_sqr then
					table.insert(predicted_targets, target)
				end
			end
		end
	return predicted_targets
	end
end

local function GetBestAoEPosition(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local targets = GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargets(radius, main_target)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = {pos = position, radi = radius}
	circle.center = position

	if #targets >= 2 then best_pos_found = ContainsThemAll(circle, targets) end

	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
	return vec3.new(position.x, position.y, position.z), #targets
end

local function AoEDraw()
	for i, unit in ipairs(GetEnemyHeroes()) do
		local Dist = myHero:distance_to(unit.origin)
		if unit.object_id ~= 0 and IsValid(unit) and Dist < 1500 then
			local CastPos, targets = GetBestAoEPosition(math.huge, 1.15, 1800, 240, unit, false, false)
			if CastPos then
				renderer:draw_circle(CastPos.x, CastPos.y, CastPos.z, 50, 0, 137, 255, 255)
				screen_pos = game:world_to_screen(CastPos.x, CastPos.y, CastPos.z)
				x, y = screen_pos.x, screen_pos.y
				renderer:draw_text_big(x, y, "Count = "..tostring(targets), 220, 20, 60, 255)
			end
		end
	end
end

-- Best Prediction End

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

local function GetEnemyCount(range, unit)
	count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit, hero) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetEnemyCountCicular(range, p1)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(p1, unit.origin) < Range and IsValid(unit) then
        count = count + 1
        end
    end
    return count
end

local function GetMinionCount(range, unit)
	count = 0
	minions = game.minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and IsValid(minion) and unit.object_id ~= minion.object_id and GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function HasPoison(unit)
    if unit:has_buff_type(23) then
        return true
    end
    return false
end

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function HasBuff(unit, buffname)
    if unit:has_buff(buffname) then
        buff = unit:get_buff(buffname)
        if buff.count > 0 then
            return true
        end
    end
    return false
end

local function HasEMark(unit)
	if unit:has_buff("VladimirE") then
		return true
	end
	return false
end

local function GetGameTime()
	return tonumber(game.game_time)
end

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
		return true
	end
	return false
end


local function EpicMonster(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder" then
		return true
	else
		return false
	end
end

local function IsUnderTurret(unit)
    turrets = game.turrets
    for i, v in ipairs(turrets) do
        if v and v.is_enemy then
            local range = (v.bounding_radius / 2 + 775 + unit.bounding_radius / 2)
            if v.is_alive then
                if v:distance_to(unit.origin) < range then
                    return true
                end
            end
        end
    end
    return false
end

-- Menu Config

vlad_category = menu:add_category("Shaun's Sexy Vladimir")
vlad_enabled = menu:add_checkbox("Enabled", vlad_category, 1)
vlad_combokey = menu:add_keybinder("Combo Mode Key", vlad_category, 32)

vlad_ks_function = menu:add_subcategory("Kill Steal", vlad_category)
vlad_ks_use_q = menu:add_checkbox("Use Q", vlad_ks_function, 1)
vlad_ks_use_e = menu:add_checkbox("Use E", vlad_ks_function, 1)
vlad_ks_use_r = menu:add_checkbox("Use R", vlad_ks_function, 1)
vlad_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", vlad_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), vlad_ks_r_blacklist, 1)
    end
end


vlad_combo = menu:add_subcategory("Combo", vlad_category)
vlad_combo_use_q = menu:add_checkbox("Use Q", vlad_combo, 1)
vlad_combo_use_w = menu:add_checkbox("Use W", vlad_combo, 1)
vlad_combo_use_e = menu:add_checkbox("Use E", vlad_combo, 1)
vlad_combo_r = menu:add_subcategory("R Combo Settings", vlad_combo)
vlad_combo_use_r = menu:add_checkbox("Use R", vlad_combo_r, 1)
vlad_combo_r_enemy_hp = menu:add_slider("Combo R if Enemy HP is lower than [%]", vlad_combo_r, 1, 100, 25)
vlad_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist", vlad_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), vlad_combo_r_blacklist, 1)
    end
end

vlad_harass = menu:add_subcategory("Harass", vlad_category)
vlad_harass_use_q = menu:add_checkbox("Use Q", vlad_harass, 1)
vlad_harass_use_e = menu:add_checkbox("Use E", vlad_harass, 1)
vlad_harass_use_auto_q = menu:add_toggle("Toggle Auto Q Harass", 1, vlad_harass, 90, true)

vlad_laneclear = menu:add_subcategory("Lane Clear", vlad_category)
vlad_laneclear_use_q = menu:add_checkbox("Use Q", vlad_laneclear, 1)
vlad_laneclear_use_e = menu:add_checkbox("Use E", vlad_laneclear, 1)
vlad_laneclear_e_min = menu:add_slider("Number Of Minions To Use E", vlad_laneclear, 1, 10, 3)

vlad_jungleclear = menu:add_subcategory("Jungle Clear", vlad_category)
vlad_jungleclear_use_q = menu:add_checkbox("Use Q", vlad_jungleclear, 1)
vlad_jungleclear_use_e = menu:add_checkbox("Use E", vlad_jungleclear, 1)

vlad_auto_w = menu:add_subcategory("EPIC Pool Features", vlad_category)
vlad_misc_anti_w = menu:add_checkbox("W Anti Gap Closer", vlad_auto_w, 1)
vlad_misc_life = menu:add_checkbox("Enable W Life Saver", vlad_auto_w, 1)
vlad_misc_life_hp = menu:add_slider("Vlad Health [%] To use W Life Saver", vlad_auto_w, 1, 100, 15)
--vlad_auto_w_use = menu:add_checkbox("Auto W Incomming Spells", vlad_auto_w, 1)
--vlad_blockList = menu:add_subcategory("Spell List", vlad_auto_w)

--[[for i, spell in pairs(CCSpells) do
	if not CCSpells[i] then return end
	for j, k in pairs(GetEnemyHeroes()) do
		if spell.charName == k.champ_name then
			i = menu:add_checkbox(""..spell.charName.." "..spell.slot.." | "..spell.displayName, vlad_blockList, 1)
		end
	end
end]]

vlad_r_misc_options = menu:add_subcategory("INSANE Ulitmate Features", vlad_category)
vlad_combo_r_set_key = menu:add_keybinder("Semi Manual R Key - Closest To Cursor Target", vlad_r_misc_options, 65)
vlad_combo_r_auto = menu:add_checkbox("Auto R - Using Best AoE Prediction", vlad_r_misc_options, 1)
vlad_combo_r_auto_x = menu:add_slider("Minimum Of Targets To Perform Auto R", vlad_r_misc_options, 1, 5, 3)

vlad_draw = menu:add_subcategory("The Drawing Features", vlad_category)
vlad_draw_q = menu:add_checkbox("Draw Q", vlad_draw, 1)
vlad_draw_r = menu:add_checkbox("Draw R", vlad_draw, 1)
vlad_r_best_draw = menu:add_checkbox("Draw Auto R Best Position Circle + Count", vlad_draw, 1)
vlad_auto_q_draw = menu:add_checkbox("Toggle Auto Q Harass Draw", vlad_draw, 1)
vlad_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", vlad_draw, 1)
vlad_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", vlad_draw, 1, "Health Bar Damage Is Computed From R > Q > E")


local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({80, 100, 120, 140, 160})[level] + 0.6 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetEDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_E).level
  local BonusDmg = 0
  local EDamage = ({60, 90, 120, 150, 180})[level] + 0.8 * myHero.ability_power + 0.06 * myHero.max_health
  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetRDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_R).level
  local BonusDmg = 0
  local RDamage = ({150, 250, 350})[level] + 0.7 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = RDamage - 10
  else
			Damage = RDamage
  end
	return unit:calculate_magic_damage(Damage)
end


-- Casting

local function CastQ(unit)
	spellbook:cast_spell_targetted(SLOT_Q, unit, Q.delay)
	orbwalker:reset_aa()
end

local function CastE(unit)

	local Charge_buff = local_player:get_buff("VladimirE")
	if Charge_buff.is_valid then
		local diff = game.game_time - Charge_buff.start_time

		if diff >= 1 then
			if IsValid(unit) then
 				spellbook:cast_spell(SLOT_E, 0.1)
			end
		end
	else
		if unit.object_id ~= 0 then
			if Ready(SLOT_E) then
				spellbook:start_charged_spell(SLOT_E)
			end
		end
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W)
end

local function CastR(unit)
	pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()

	target = selector:find_target(R.range, mode_health)

	if menu:get_value(vlad_combo_use_r) == 1 then
		if myHero:distance_to(target.origin) <= R.range and IsValid(target) then
			if Ready(SLOT_R) then
				if target:health_percentage() <= menu:get_value(vlad_combo_r_enemy_hp) then
					if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
						CastR(target)
					end
				end
			end
		end
	end

	if menu:get_value(vlad_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(vlad_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= E.range and IsValid(target) then
			CastE(target)
		end
	end

	if menu:get_value(vlad_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= E.range and IsValid(target) and HasEMark(myHero) then
			if Ready(SLOT_W) then
				CastW()
			end
		end
	end

end

--Harass

local function Harass()

	target = selector:find_target(R.range, mode_health)

	if menu:get_value(vlad_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if Ready(SLOT_Q) and not menu:get_toggle_state(vlad_harass_use_auto_q) then
				CastQ(target)
			end
		end
	end


	if menu:get_value(vlad_harass_use_e) == 1 then
		if myHero:distance_to(target.origin) <= E.range and IsValid(target) then
			CastE(target)
		end
	end
end

-- Auto Q Harass

local function AutoQHarass()

	target = selector:find_target(Q.range, mode_health)

	if menu:get_toggle_state(vlad_harass_use_auto_q) and menu:get_value(vlad_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if Ready(SLOT_Q) and not IsUnderTurret(myHero) then
				CastQ(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	players = game.players
	for _, target in ipairs(players) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if menu:get_value(vlad_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= E.range and IsValid(target) then
			if menu:get_value(vlad_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					CastE(target)
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) then
			if menu:get_value(vlad_ks_use_r) == 1 and GetRDmg(target) > target.health then
				if Ready(SLOT_R) and IsValid(target) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
						CastR(target)
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(vlad_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, target) and GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						spellbook:cast_spell_targetted(SLOT_Q, target, Q.delay)
						orbwalker:reset_aa()
					end
				end
			end
		end

		if menu:get_value(vlad_laneclear_use_e) == 1 then

			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < E.range then
				if GetMinionCount(E.range, target) >= menu:get_value(vlad_laneclear_e_min) then

					local Charge_buff = local_player:get_buff("VladimirE")
					if Charge_buff.is_valid then
						local diff = game.game_time - Charge_buff.start_time

						if diff >= 1 then
							if IsValid(target) then
			 					spellbook:cast_spell(SLOT_E, 0.1)
							end
						end
					else
						if target.object_id ~= 0 then
							if Ready(SLOT_E) then
								spellbook:start_charged_spell(SLOT_E)
							end
						end
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()
	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(vlad_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if Ready(SLOT_Q) then
					spellbook:cast_spell_targetted(SLOT_Q, target, Q.delay)
					orbwalker:reset_aa()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(vlad_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < E.range then
			if IsValid(target) then

				local Charge_buff = local_player:get_buff("VladimirE")
				if Charge_buff.is_valid then
					local diff = game.game_time - Charge_buff.start_time

					if diff >= 1 then
						if IsValid(target) then
			 				spellbook:cast_spell(SLOT_E, 0.1)
						end
					end
				else
					if target.object_id ~= 0 then
						if Ready(SLOT_E) then
							spellbook:start_charged_spell(SLOT_E)
						end
					end
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	target = selector:find_target(R.range, mode_cursor)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) then
			CastR(target)
		end
	end
end

-- Auto R >= Targets

local function AutoR()
	if Ready(SLOT_R) then
		for i, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= R.range then
				local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, unit, false, false)
				if CastPos and targets >= menu:get_value(vlad_combo_r_auto_x) then
					spellbook:cast_spell(SLOT_R, R.delay, CastPos.x, CastPos.y, CastPos.z)
				end
			end
		end
	end
end

-- Life Saver --

local function Wlifeaver()
	target = selector:find_target(R.range, mode_distance)
	if menu:get_value(vlad_misc_life) == 1 and Ready(SLOT_W) then
		if target.object_id ~= 0 then
			if myHero:health_percentage() <= menu:get_value(vlad_misc_life_hp) then
				if myHero:distance_to(target.origin) <= R.range and IsValid(target) then
					CastW()
				end
			end
		end
	end
end

-- Last Hit

--[[local function Lasthit()

	minions = game.minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) and GetMinionCount(Q.range, target) >= 1 then
				if GetQDmg(target) > target.health then
					if combo:get_mode() ~= MODE_COMBO and not game:is_key_down(menu:get_value(vlad_combokey)) then
						if Ready(SLOT_Q) then
							console:log("screen_size.width: " .. tostring(GetQDmg(target)))
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, true, true)

							if pred_output.can_cast then
								castPos = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
							end
						end
					end
				end
			end
		end
	end
end]]

-- Anti E Gap

local function on_gap_close(obj, data)

	if IsValid(obj) and menu:get_value(vlad_misc_anti_w) == 1 then
		if myHero:distance_to(obj.origin) <= W.range and Ready(SLOT_W) then
			CastW()
		end
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	local target = selector:find_target(2000, mode_health)

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(vlad_draw_q) == 1 then
		if  Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(vlad_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 20, 147, 255)
		end
	end

	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetRDmg(target)
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range then
				if menu:get_value(vlad_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 50, "Current Ready Spell Rotation Can Kill Target")
					end
				end
			end
		end
		if menu:get_value(vlad_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end


	if menu:get_value(vlad_auto_q_draw) == 1 then
		if menu:get_value(vlad_harass_use_q) == 1 then
			if menu:get_toggle_state(vlad_harass_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto Q Harass Enabled")
			end
		end
	end



	--[[if menu:get_value(vlad_auto_turret_draw) == 1 then
		if menu:get_toggle_state(vlad_misc_w_turret) then
			renderer:draw_text_centered(screen_size.width / 2, screen_size.height / 50, "Toggle Auto W Turret Enabled")
		end
	end]]

end

local function on_tick()

	if game:is_key_down(menu:get_value(vlad_combokey)) and menu:get_value(vlad_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if menu:get_toggle_state(vlad_harass_use_auto_q) and not game:is_key_down(menu:get_value(vlad_combokey)) then
		AutoQHarass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if menu:get_value(vlad_combo_r_auto) == 1 then
		AutoR()
	end

	if game:is_key_down(menu:get_value(vlad_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_value(vlad_r_best_draw) == 1 then
		AoEDraw()
	end

	Wlifeaver()

	AutoKill()

	--[[if game:is_key_down(menu:get_value(vlad_lasthit_use_q)) and menu:get_value(vlad_auto_lasthit) == 0 then
		if combo:get_mode() == MODE_LASTHIT then
			Lasthit()
		end
	end

	if menu:get_value(vlad_auto_lasthit) == 1 and combo:get_mode() ~= MODE_COMBO and not game:is_key_down(menu:get_value(vlad_combokey)) then
		Lasthit()
	end]]


	--[[if SpellName and Spell then
		if CCSpells[SpellName] and Ready(SLOT_W) then
			local Col = VectorPointProjectionOnLineSegment(Spell.start_pos, Spell.end_pos, myHero.origin)
			local Radius = (CCSpells[SpellName].radius + myHero.bounding_radius) * (CCSpells[SpellName].radius + myHero.bounding_radius)
			if GetDistanceSqr2(myHero, Spell.end_pos) < Radius or GetDistanceSqr2(myHero, Col) < Radius then
				local TimeToHit = (myHero:distance_to(Spell.start_pos) / CCSpells[SpellName].speed)
				if game.game_time - Spell.start_time >= (TimeToHit - 0.3) then
					SpellName = nil
					Spell = nil
					spellbook:cast_spell(SLOT_W, 0.3)
					SpellName = nil
					Spell = nil
					return
				end
			end
		else
			SpellName = nil
			Spell = nil
		end
	end]]

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
