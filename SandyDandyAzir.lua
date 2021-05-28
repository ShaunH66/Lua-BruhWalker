if game.local_player.champ_name ~= "Azir" then
	return
end

--[[do
    local function AutoUpdate()
		local Version = 1
		local file_name = "SandyDanyAzir.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SandyDanyAzir.lua"
    local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SandyDanyAzir.lua.version.txt")
    console:log("SandyDanyAzir..lua Vers: "..Version)
		console:log("SandyDanyAzir..Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log(".................Shaun's Sexy Azir Successfully Loaded........................")
    else
						http:download_file(url, file_name)
			      console:log("Sexy Azir Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end

    end

    AutoUpdate()
end]]

--Ensuring that the librarys are downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
end

local VIP = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/VIP_USER_LIST.lua.txt")
VIP = VIP .. ','
local LIST = {}
for user in VIP:gmatch("(.-),") do
	table.insert(LIST, user)
end
local USER = client.username
local function VIP_USER_LIST()
	for _, value in pairs(LIST) do
		if string.find(tostring(value), client.username) then
			return true
		end
	end
return false
end

if not VIP_USER_LIST() then
  console:log("You Are Not VIP! To Become a Supportor Please Contact Shaunyboi")
  return
end

if VIP_USER_LIST() then
  console:log("..................You Are VIP! Thanks For Supporting <3 #Family........................")
end

--Initialization lines:
local ml = require "VectorMath"
pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local QFire = false
local RFire = false
local INSECGO = false

-- Ranges
local Q = { range = 1000, delay = .25, width = 140, speed = 1600 }
local W = { range = 650, delay = .25, width = 315, speed = math.huge }
local E = { range = 1100, delay = .25, speed = math.huge }
local R = { range = 1500, delay = .5, width = 500, speed = 1000 }
local Tether = { range = 660 }

local function IsFlashSlotF()
flash = spellbook:get_spell_slot(SLOT_F)
FData = flash.spell_data
FName = FData.spell_name
if FName == "SummonerFlash" then
    return true
end
return false
end

-- No lib Functions Start

function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
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

local function AzirE(unit)
	if unit:has_buff("AzirE") then
		return true
	end
	return false
end

-- No lib Functions End

local soldiers = {}
local function on_object_created(object, obj_name)
    if object and obj_name == "AzirSoldier" then
        if object.is_alive then
            table.insert(soldiers, object)
        end
    end
end

function CountSoldiers()
    local count = 0
    for _ in pairs(soldiers) do
        count = count + 1
    end
    return count
end


--[[local function SoldierDmg(unit)
	local level = myHero.level

	if level < 8 then

		return unit:calculate_phys_damage(58 + (2 * LvL)) + 0.6 * myHero.ability_power)
	elseif level < 12 then

		return unit:calculate_phys_damage(35 + (5 * LvL)) + 0.6 * myHero.ability_power)
	elseif level > 12 then

		return unit:calculate_phys_damage((10 * LvL) - 20) + 0.6 * myHero.ability_power)
	end
end]]

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetEDmg(unit)
	local EDmg = getdmg("E", unit, myHero, 1)
	return EDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	azir_category = menu:add_category_sprite("Shaun's Sexy Azir", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	azir_category = menu:add_category("Shaun's Sexy Azir")
end

azir_enabled = menu:add_checkbox("Enabled", azir_category, 1)
azir_combokey = menu:add_keybinder("Combo Mode Key", azir_category, 88)
azir_extra_flee_key = menu:add_keybinder("[Q] + [E] Manual Key", azir_category, 90)
menu:add_label("Welcome To Shaun's Sexy Azir", azir_category)
menu:add_label("#SandInMyBallsHurts", azir_category)

azir_ks_function = menu:add_subcategory("Kill Steal", azir_category)
azir_ks_q = menu:add_subcategory("[Q] Settings", azir_ks_function, 1)
azir_ks_use_q = menu:add_checkbox("Use [Q]", azir_ks_q, 1)
azir_ks_use_qw = menu:add_checkbox("Use [W] Target >= [Q] Range", azir_ks_q, 1)
azir_ks_qe = menu:add_subcategory("[Q] + [E] Smart Settings", azir_ks_function, 1)
azir_ks_use_e = menu:add_checkbox("Use [Q] + [E]", azir_ks_qe, 1)
azir_ks_use_e_count = menu:add_slider("<= Enemy Count Around To [E]", azir_ks_qe, 1, 5, 2)
azir_ks_r = menu:add_subcategory("[R] Smart Settings", azir_ks_function, 1)
azir_ks_use_r = menu:add_checkbox("Use [R]", azir_ks_r, 1)
azir_ks_r_overkill = menu:add_checkbox("[R] Overkill Check", azir_ks_r, 1)
azir_ks_insec = menu:add_subcategory("[INSEC] Settings", azir_ks_function, 1)
azir_ks_insec_use = menu:add_checkbox("Use [INSEC]", azir_ks_insec, 1)
azir_ks_use_insec_count = menu:add_slider("<= Enemy Count Around To [INSEC]", azir_ks_insec, 1, 5, 2)
azir_ks_blacklist = menu:add_subcategory("Kill Steal Champ Whitelist", azir_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Kill Steal Whitelist: "..tostring(t.champ_name), azir_ks_blacklist, 1)
    end
end

azir_combo = menu:add_subcategory("Combo", azir_category)
azir_combo_q = menu:add_subcategory("[Q] Settings", azir_combo)
azir_combo_use_q = menu:add_checkbox("Use [Q]", azir_combo_q, 1)
azir_combo_use_qw = menu:add_checkbox("Use [W] Target >= [Q] Range", azir_combo_q, 1)
azir_combo_w = menu:add_subcategory("[W] Settings", azir_combo)
azir_combo_use_w = menu:add_checkbox("Use [W]", azir_combo_w, 1)
azir_combo_e = menu:add_subcategory("[E] Settings", azir_combo)
azir_combo_use_e = menu:add_checkbox("Use [E]", azir_combo_e, 1)
azir_combo_use_e_hp = menu:add_slider("[E] IF Target HP <= than [%]", azir_combo_e, 1, 100, 30)
azir_combo_use_e_count = menu:add_slider("<= Enemy Count To [E]", azir_combo_e, 1, 5, 2)

azir_harass = menu:add_subcategory("Harass", azir_category)
azir_harass_q = menu:add_subcategory("[Q] Settings", azir_harass)
azir_harass_use_q = menu:add_checkbox("Use [Q]", azir_harass_q, 1)
azir_harass_use_qw = menu:add_checkbox("Use [W] Target >= [Q] Range", azir_harass_q, 1)
azir_harass_w = menu:add_subcategory("[W] Settings", azir_harass)
azir_harass_use_w = menu:add_checkbox("Use [W]", azir_harass_w, 1)
azir_combo_w_savecount = menu:add_slider("Save [W] Soldier Count", azir_harass_w, 1, 3 , 1)

azir_laneclear = menu:add_subcategory("Lane Clear", azir_category)
azir_laneclear_use_q = menu:add_checkbox("Use [Q]", azir_laneclear, 1)
azir_laneclear_use_w = menu:add_checkbox("Use [W]", azir_laneclear, 1)
azir_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", azir_laneclear, 1, 100, 20)
azir_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", azir_laneclear, 1, 10, 3)

azir_jungleclear = menu:add_subcategory("Jungle Clear", azir_category)
azir_jungleclear_use_q = menu:add_checkbox("Use [Q]", azir_jungleclear, 1)
azir_jungleclear_use_w = menu:add_checkbox("Use [W]", azir_jungleclear, 1)
azir_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", azir_jungleclear, 1, 100, 20)

azir_extra_insec = menu:add_subcategory("[INSEC] Settings", azir_category)
azir_insec_key = menu:add_keybinder("INSEC Key", azir_extra_insec, 32)
e_table = {}
e_table[1] = "To Allys"
e_table[2] = "To Ally Tower"
e_table[3] = "To Mouse Position"
azir_insec_direction = menu:add_combobox("[R] INSEC Direction Preference", azir_extra_insec, e_table, 0)

azir_extra = menu:add_subcategory("[R] Extra Features", azir_category)
azir_extra_semi_r_key = menu:add_keybinder("[R] Semi Manual Key - Closest To Cursor", azir_extra, 65)
azir_extra_save = menu:add_subcategory("Smart [R] Save Me! Settings", azir_extra)
azir_extra_saveme = menu:add_checkbox("Use Smart [R] Save Me! Usage", azir_extra_save, 1)
azir_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", azir_extra_save, 1, 100, 25)
azir_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", azir_extra_save, 1, 100, 45)

azir_extra_gap = menu:add_subcategory("[R] Anti Gap Closer Settings", azir_extra)
azir_extra_gapclose = menu:add_toggle("[R] Toggle Anti Gap Closer key", 1, azir_extra_gap, 90, true)
azir_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", azir_extra_gap)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(t.champ_name), azir_extra_gapclose_blacklist, 1)
    end
end

azir_extra_int = menu:add_subcategory("[R] Interrupt Major Channel Spells Settings", azir_extra, 1)
azir_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", azir_extra_int, 1)
azir_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", azir_extra_int)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(t.champ_name), azir_extra_interrupt_blacklist, 1)
    end
end

azir_draw = menu:add_subcategory("The Drawing Features", azir_category)
azir_draw_q = menu:add_checkbox("Draw [Q] Range", azir_draw, 1)
azir_draw_q2 = menu:add_checkbox("Draw [Q] + [W] Range", azir_draw, 1)
azir_draw_w = menu:add_checkbox("Draw [W] Range", azir_draw, 1)
azir_draw_w2 = menu:add_checkbox("Draw [W] Solider Range", azir_draw, 1)
azir_draw_gapclose = menu:add_checkbox("Draw [R] Anti Gap Closer Toggle Text", azir_draw, 1)
azir_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", azir_draw, 1)
azir_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo Colours On Target Health Bar", azir_draw, 1)

-- Casting

local function CastQ(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastQ2(unit)
	pred_output = pred:predict(Q2.speed, Q2.delay, Q2.range, Q2.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q2.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastWBehind(unit)
	SolPos = ml.Extend(unit.origin, myHero.origin, 150)
	spellbook:cast_spell(SLOT_W, W.delay, SolPos.x, SolPos.y, SolPos.z)
end

local function CastW(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
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

	target = selector:find_target(1500, mode_health)
	local TargetHP = target.health/target.max_health <= menu:get_value(azir_combo_use_e_hp) / 100

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_combo_use_q) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if CountSoldiers() > 0 then
					if myHero:distance_to(soldier.origin) <= Tether.range then
						if myHero:distance_to(target.origin) <= Q.range then
							if ml.Ready(SLOT_Q) then
								CastQ(target)
							end
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_combo_use_qw) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) > W.range then
					if ml.Ready(SLOT_W) and ml.Ready(SLOT_Q) then
						CastW(target)
					end
				end
			end
		end
	end

	if menu:get_value(azir_combo_use_w) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) <= W.range then
					if ml.Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end
	end

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_combo_use_e) == 1 then
			if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
				local _, count = ml.GetEnemyCount(target.origin, 1500)
				if TargetHP and count <= menu:get_value(azir_combo_use_e_count) then
					if soldier:distance_to(target.origin) <= Q.range then
						if ml.Ready(SLOT_E) and not IsUnderTurret(target) then
							CastE(target)
						end
					end
				end
			end
		end
	end
end

-- Harass

local function Harass()

	target = selector:find_target(1500, mode_health)

	for _, soldier in pairs(soldiers) do
		if menu:get_value(azir_harass_use_q) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if CountSoldiers() > 0 then
					if myHero:distance_to(soldier.origin) <= Tether.range then
						if myHero:distance_to(target.origin) <= Q.range then
							if ml.Ready(SLOT_Q) then
								CastQ(target)
							end
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_harass_use_qw) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) > W.range then
					if CountSoldiers() <  menu:get_value(azir_combo_w_savecount) then
						if ml.Ready(SLOT_W) and ml.Ready(SLOT_Q) then
							CastW(target)
						end
					end
				end
			end
		end
	end

	if menu:get_value(azir_harass_use_w) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if myHero:distance_to(target.origin) <= W.range then
					if CountSoldiers() <  menu:get_value(azir_combo_w_savecount) then
						if ml.Ready(SLOT_W) then
							CastW(target)
						end
					end
				end
			end
		end
	end
end

-- KillSteal

--[[local function AutoKill()

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)
	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QERrange and IsValid(target) and IsKillable(target) then
			if menu:get_value(azir_ks_use_er) == 1 and HasECharge(target) then
				if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
					local Buff = ECount(target)
					if Buff and Buff.count >= 3 then
						local FullDMG = (GetEDmg(target) + GetRDmg(target))
						if FullDMG > target.health and Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
		end

		local AATotalDMG = (myHero.total_attack_damage * menu:get_value(azir_ks_use_r_aa))
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QERrange and IsValid(target) and IsKillable(target) then
			if menu:get_value(azir_ks_use_r) == 1 then
				if menu:get_value_string("Kill Steal Whitelist: "..tostring(target.champ_name)) == 1 then
					if AATotalDMG < target.health and Ready(SLOT_R) then
						if GetRDmg(target) > target.health then
							CastR(target)
						end
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)
	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(azir_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QERrange then
				if GetMinionCount(QERrange, myHero) >= menu:get_value(azir_laneclear_q_min) then
					if GrabLaneClearMana and Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(azir_laneclear_use_e) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QERrange then
				if EpicMonsterPlusSiege(target) then
					if GrabLaneClearMana and Ready(SLOT_E) then
            CastE(target)
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)
	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(azir_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(azir_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < QERrange then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_Q) then
					CastQ()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(azir_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < QERrange then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_E) then
          CastE(target)
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)
  target = selector:find_target(W.range, mode_cursor)

  if game:is_key_down(menu:get_value(azir_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < QERrange then
			if IsValid(target) and IsKillable(target) and Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

-- Manual R

local function RSaveMe()

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)

  target = selector:find_target(W.range, mode_distance)
	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(azir_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(azir_extra_saveme_target) / 100

	if menu:get_value(azir_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < QERrange then
			if myHero:distance_to(target.origin) < target.attack_range then
				if target:is_facing(myHero) then
					if SaveMeHP and TargetHP then
						if IsValid(target) and IsKillable(target) and Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
    end
  end
end

-- Gap Close

local function on_gap_close(obj, data)

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)

	if menu:get_toggle_state(azir_extra_gapclose) then
    if IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
	      if myHero:distance_to(obj.origin) < 400 and Ready(SLOT_R) then
	        CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	local QERrange = (myHero.attack_range + myHero.bounding_radius + 40)
	if IsValid(obj) then
    if menu:get_value(azir_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) < QERrange and Ready(SLOT_R) then
        	CastR(obj)
				end
			end
		end
	end
end]]

local function INSEC()

	target = selector:find_target(2000, mode_cursor)

	players = game.players
	for _, ally in ipairs(players) do
		for _, soldier in pairs(soldiers) do

			if menu:get_value(azir_insec_direction) == 0 then
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if ml.IsValid(target) and IsKillable(target) then
					 	if ally:distance_to(target.origin) <= 1500 then
							if CountSoldiers() <= 0 and myHero:distance_to(target.origin) <= E.range then
								CastW(target)
							end

							if myHero:distance_to(soldier.origin) <= E.range and soldier:distance_to(target.origin) <= Q.range then
								CastE(target)
								QFire = true
							end

							if QFire and myHero:distance_to(target.origin) <= E.range then
								CastQ(target)
								RFire = true
							end

							if RFire and ml.Ready(SLOT_R) and myHero:distance_to(target.origin) <= 200 then
								CastR(ally)
							end
						end
					end
				end
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()

	screen_size = game.screen_size

	target = selector:find_target(2000, mode_health)
	targetvec = target.origin

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(azir_draw_q) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, Q.range, 255, 0, 255, 255)
		end
	end

  if menu:get_value(azir_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	--[[local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetEDmg(target) + (myHero.total_attack_damage * 3) + GetRDmg(target)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
			if menu:get_value(azir_draw_kill) == 1 then
				if fulldmg > target.health and IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end

		if IsValid(target) and menu:get_value(azir_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

	if menu:get_value(azir_draw_gapclose) == 1 then
		if menu:get_toggle_state(azir_extra_gapclose) then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle [R] Anti Gap Closer Enabled")
		end
	end]]
end

local function on_tick()

	if game:is_key_down(menu:get_value(azir_combokey)) and menu:get_value(azir_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	--[[if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(azir_extra_semi_r_key)) then
		orbwalker:move_to()
		ManualR()
	end

	AutoKill()
	AutoETurret()
	RSaveMe()]]

	if game:is_key_down(menu:get_value(azir_insec_key)) then
		INSEC()
		orbwalker:move_to()
	end

	for index, soldier in pairs(soldiers) do
    if not soldier.is_alive then
        table.remove(soldiers, index)
    end
	end

	if not ml.Ready(SLOT_R) then
		Qfire = false
		Rfire = false
		q_cast = nil
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
--client:set_event_callback("on_gap_close", on_gap_close)
--client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_object_created", on_object_created)
