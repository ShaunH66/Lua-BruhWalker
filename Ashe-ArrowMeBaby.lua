if game.local_player.champ_name ~= "Ashe" then
	return
end

do
    local function AutoUpdate()
		local Version = 0.2
		local file_name = "Ashe-ArrowMeBaby.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Ashe-ArrowMeBaby.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Ashe-ArrowMeBaby.lua.version.txt")
        console:log("Ashe-ArrowMeBaby.lua Vers: "..Version)
		console:log("Ashe-ArrowMeBaby.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

						console:log("Sexy Ashe Successfully Loaded.....")

        else
						http:download_file(url, file_name)
			      console:log("Sexy Ashe Update available.....")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
        end

    end

    AutoUpdate()
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

pred:use_prediction()
arkpred = _G.Prediction

--Ensuring that the librarys are downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark223 Prediction Library Downloaded")
   console:log("Please Reload with F5")
end

local ml = require "VectorMath"
require "PKDamageLib"
local myHero = game.local_player
local local_player = game.local_player
local AutoTime = nil
local AACast = false
local AACastW = false
local AutoTimeW = nil


local function Ready(spell)
  return spellbook:can_cast(spell)
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
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


local function GetGameTime()
	return tonumber(game.game_time)
end

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
		return true
	end
	return false
end

local function IsWattached(unit)
	if HasBuff(unit, "ashewattach") then
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
		or unit.champ_name == "SRU_Dragon_Elder"
		or unit.champ_name ==	"SRU_ChaosMinionSiege" then
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

local function IsKillable(unit)
	if unit:has_buff_type(16) or unit:has_buff_type(18) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	ashe_category = menu:add_category_sprite("Shaun's Sexy Ashe", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	ashe_category = menu:add_category("Shaun's Sexy Ashe")
end

ashe_enabled = menu:add_checkbox("Enabled", ashe_category, 1)
ashe_combokey = menu:add_keybinder("Combo Mode Key", ashe_category, 32)
menu:add_label("Shaun's Sexy Ashe", ashe_category)
menu:add_label("#LetMeArrowYouBaby", ashe_category)

ashe_ark_pred = menu:add_subcategory("[Ark Pred Settings]", ashe_category)
ashe_ark_pred_w = menu:add_subcategory("[W] Settings", ashe_ark_pred, 1)
ashe_w_hitchance = menu:add_slider("[W] Ashe Hit Chance [%]", ashe_ark_pred_w, 1, 99, 50)
ashe_ark_pred_r = menu:add_subcategory("[R] Settings", ashe_ark_pred, 1)
ashe_r_hitchance = menu:add_slider("[R] Ashe Hit Chance [%]", ashe_ark_pred_r, 1, 99, 50)

manual_r = menu:add_subcategory("Semi Manual [R] Settings", ashe_category)
ashe_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", manual_r, 65)
e_table = {}
e_table[1] = "Lowest Target Health"
e_table[2] = "Closest To Cursor"
target_selection = menu:add_combobox("[Target Selection]", manual_r, e_table, 0)

ashe_ks_function = menu:add_subcategory("[Kill Steal]", ashe_category)
ashe_ks_use_w = menu:add_checkbox("Use [W]", ashe_ks_function, 1)
ashe_ks_use_r = menu:add_checkbox("Use [R]", ashe_ks_function, 1)
ashe_ks_use_r_aa = menu:add_checkbox("Only Use [R] Ouside [AA] Range", ashe_ks_function, 1)
ashe_ks_use_range = menu:add_slider("Max Range To Use [R] Kill Steal", ashe_ks_function, 1, 6000, 3000)
ashe_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", ashe_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), ashe_ks_r_blacklist, 1)
    end
end


ashe_combo = menu:add_subcategory("[Combo]", ashe_category)
ashe_combo_use_q = menu:add_checkbox("Use [Q]", ashe_combo, 1)
ashe_combo_use_w = menu:add_checkbox("Use [W]", ashe_combo, 1)

ashe_harass = menu:add_subcategory("[Harass]", ashe_category)
ashe_harass_use_q = menu:add_checkbox("Use [Q]", ashe_harass, 1)
ashe_harass_use_w = menu:add_checkbox("Use [W]", ashe_harass, 1)
ashe_harass_min_mana = menu:add_slider("Minimum [%] Mana To Harass", ashe_harass, 1, 100, 20)

ashe_laneclear = menu:add_subcategory("[Lane Clear]", ashe_category)
ashe_laneclear_use_q = menu:add_checkbox("Use [Q]", ashe_laneclear, 1)
ashe_laneclear_use_w = menu:add_checkbox("Use [W]", ashe_laneclear, 1)
ashe_laneclear_min_mana = menu:add_slider("Minimum [%] Mana To Lane Clear", ashe_laneclear, 1, 100, 20)
ashe_laneclear_min_minions = menu:add_slider("Minimum Minions To [W] + [Q]", ashe_laneclear, 1, 10, 3)

ashe_jungleclear = menu:add_subcategory("[Jungle Clear]", ashe_category)
ashe_jungleclear_use_q = menu:add_checkbox("Use [Q]", ashe_jungleclear, 1)
ashe_jungleclear_use_w = menu:add_checkbox("Use [W]", ashe_jungleclear, 1)
ashe_jungleclear_min_mana = menu:add_slider("Minimum [%] Mana To jungle Clear", ashe_jungleclear, 1, 100, 20)

ashe_misc_options = menu:add_subcategory("Auto [E] Features", ashe_category)
ashe_misc_e_vision = menu:add_checkbox("Auto [E] On Lose Vision", ashe_misc_options, 1)

ashe_misc_options_r = menu:add_subcategory("Auto [R] Features", ashe_category)
ashe_extra_save = menu:add_subcategory("[R] Save Me! Settings",ashe_misc_options_r)
ashe_extra_saveme = menu:add_checkbox("[R] Save Me! Usage", ashe_extra_save, 1)
ashe_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", ashe_extra_save, 1, 100, 25)
ashe_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", ashe_extra_save, 1, 100, 45)

ashe_extra_gap = menu:add_subcategory("[R] Anti Gap Closer", ashe_misc_options_r)
ashe_extra_gapclose = menu:add_toggle("[R] Toggle Gap Closer key", 1, ashe_extra_gap, 73, true)
ashe_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", ashe_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), ashe_extra_gapclose_blacklist, 1)
    end
end

ashe_extra_int = menu:add_subcategory("[R] Interrupt Channels", ashe_misc_options_r, 1)
ashe_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", ashe_extra_int, 1)
ashe_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", ashe_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), ashe_extra_interrupt_blacklist, 1)
    end
end

ashe_draw = menu:add_subcategory("[Drawing] Features", ashe_category)
ashe_draw_w = menu:add_checkbox("Draw [W]", ashe_draw, 1)
ashe_draw_r = menu:add_checkbox("Draw [R]", ashe_draw, 1)
ashe_draw_gapclose = menu:add_checkbox("Draw [R] Anti Gap Closer Toggle Text", ashe_draw, 1)

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Ranges

local Q = { delay = .25 }
local W = { range = 1150, delay = .25, speed = 2000 }
local E = { delay = .25, speed = 1400 }
local R = { range = 6000, delay = 0.25, radius = 130, speed = 1600 }
local wAngle = { 27, 37, 37, 46, 46 }

local W_input = {
    source = myHero,
		speed = W.speed, range = W.range,
    delay = W.delay, radius = 100,
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

local R_input = {
    source = myHero,
    speed = R.speed, range = R.range,
    delay = R.delay, radius = R.radius,
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

-- Casting

local function CastQ()
	spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
	AACast = false
	AutoTime = nil
end


local function CastW(unit)

	local output = arkpred:get_prediction(W_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(ashe_w_hitchance) / 100 and inv < (W_input.delay / 2) then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		AACastW = false
		AutoTimeW = nil
	end
end

local function CastR(unit)

	local output = arkpred:get_prediction(R_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(ashe_r_hitchance) / 100 and inv < (R_input.delay / 2) then
		local p = output.cast_pos
	  spellbook:cast_spell(SLOT_R, R.delay, p.x, p.y, p.z)
	end
end

-- Combo

local function Combo()

	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local qtarget = selector:find_target(TrueAARange, mode_health)
	local target = selector:find_target(W.range, mode_health)

	local AutoAA = myHero:get_basic_attack_data()
	local CastAADelay = AutoAA.attack_cast_delay

	if menu:get_value(ashe_combo_use_q) == 1 then
		if IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(target.origin) <= TrueAARange then
				if AutoTime ~= nil and AutoTime + CastAADelay < tonumber(game.game_time) and AACast then
					if Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end
	end

	if menu:get_value(ashe_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and myHero:distance_to(target.origin) <= TrueAARange and IsValid(target) and IsKillable(target) then
			if AutoTimeW ~= nil and AutoTimeW + CastAADelay < tonumber(game.game_time) and AACastW then
				if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end

	if menu:get_value(ashe_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and myHero:distance_to(target.origin) > TrueAARange and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end
end

--Harass

local function Harass()

	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local target = selector:find_target(W.range, mode_health)
	local qtarget = selector:find_target(TrueAARange, mode_health)

	local AutoAA = myHero:get_basic_attack_data()
	local CastAADelay = AutoAA.attack_cast_delay

	if menu:get_value(ashe_harass_use_q) == 1 then
		if IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(qtarget.origin) <= TrueAARange then
				if Ready(SLOT_Q) then
					CastQ()
				end
			end
		end
	end

	if menu:get_value(ashe_harass_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ashe_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ashe_ks_use_r) == 1 and menu:get_value(ashe_ks_use_r_aa) == 1 and myHero:distance_to(target.origin) > TrueAARange then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) <= menu:get_value(ashe_ks_use_range) then
						if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
							CastR(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ashe_ks_use_r) == 1 and menu:get_value(ashe_ks_use_r_aa) == 0 then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) <= menu:get_value(ashe_ks_use_range) then
						if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
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

	minions = game.minions
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ashe_laneclear_min_mana) / 100

	for i, target in ipairs(minions) do

		if menu:get_value(ashe_laneclear_use_q) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < TrueAARange and IsValid(target) then
				if GetMinionCount(400, target) >= menu:get_value(ashe_laneclear_min_minions) then
					if Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(ashe_laneclear_use_w) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) <= TrueAARange and IsValid(target) then
				if GetMinionCount(400, target) >= menu:get_value(ashe_laneclear_min_minions) then
					if Ready(SLOT_W) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, 0.25, x, y, z)
					end
				end
			end
		end
	end
end

-- Jungle Clear

local function JungleClear()

	minions = game.jungle_minions
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ashe_jungleclear_min_mana) / 100

	for i, target in ipairs(minions) do

		if menu:get_value(ashe_jungleclear_use_q) == 1 and GrabJungleClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) <= TrueAARange and IsValid(target) then
				if Ready(SLOT_Q) then
					CastQ()
				end
			end
		end

		if menu:get_value(ashe_jungleclear_use_w) == 1 and GrabJungleClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) <= 600 and IsValid(target) then
				if Ready(SLOT_W) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_W, 0.25, x, y, z)
				end
			end
		end
	end
end

local function RSaveMe()

  target = selector:find_target(W.range, mode_distance)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(ashe_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(ashe_extra_saveme_target) / 100

	if menu:get_value(ashe_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) <= TrueAARange then
			if myHero:distance_to(target.origin) <= TrueAARange then
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

local function on_dash(obj, dash_info)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_toggle_state(ashe_extra_gapclose) then
    if IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
	      if myHero:distance_to(dash_info.end_pos) <= TrueAARange and myHero:distance_to(obj.origin) <= TrueAARange and Ready(SLOT_R) then
	        CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if IsValid(obj) then
    if menu:get_value(ashe_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) <= TrueAARange and Ready(SLOT_R) then
        	CastR(obj)
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()


	if menu:get_value(target_selection) == 0 then
		target = selector:find_target(R.range, mode_health)
		if myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and IsValid(target) and IsKillable(target) then
				CastR(target)
			end
		end
	end

	if menu:get_value(target_selection) == 1 then
		target = selector:find_target(R.range, mode_cursor)
		if myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and IsValid(target) and IsKillable(target) then
				CastR(target)
			end
		end
	end
end

local function on_lose_vision(obj)

	target = selector:find_target(1500, mode_health)

	if menu:get_value(ashe_misc_e_vision) == 1 and IsValid(obj) and IsValid(target) and myHero:distance_to(obj.origin) <= 1500 then
		if target.object_id == obj.object_id then
			origin = obj.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell(SLOT_E, 0.25, x, y, z)
		end
	end
end

--[[local function on_active_spell(obj, active_spell)

	if Is_Me(obj) then
		if active_spell.spell_name == "asheBasicAttack" or active_spell.spell_name == "asheBasicAttack2" then
			AutoTime = game.game_time
			AACast = true
		end
	end
end]]

local function on_active_spell(obj, active_spell)

	if obj ~= myHero then return end
	--windup_end_time = active_spell.cast_end_time

	if active_spell.is_autoattack then
		AutoTime = game.game_time
		AACast = true
		AutoTimeW = game.game_time
		AACastW = true
	end
end

--[[function on_process_spell(unit, args)
	if unit ~= myHero then return end
  --windup_end_time = args.cast_time + args.cast_delay

	if args.is_autoattack then
		AutoTime = game.game_time
		AACast = true
		AutoTimeW = game.game_time
		AACastW = true
	end
end]]

-- object returns, draw and tick usage

local function on_draw()

	screen_size = game.screen_size
	target = selector:find_target(2000, mode_health)

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(ashe_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(ashe_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 20, 147, 255)
		end
	end

	if menu:get_value(ashe_draw_gapclose) == 1 then
		if menu:get_toggle_state(ashe_extra_gapclose) then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle [R] Gap Closer Enabled")
		end
	end

end

local function on_tick()

	if game:is_key_down(menu:get_value(ashe_combokey)) and menu:get_value(ashe_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(ashe_combo_r_set_key)) then
		ManualRCast()
	end

	if not game:is_key_down(menu:get_value(ashe_combokey)) then
		AACast = false
		AutoTime = nil
		AACastW = false
		AutoTimeW = nil
	end

	AutoKill()
end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_lose_vision", on_lose_vision)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_active_spell", on_active_spell)
