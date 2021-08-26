if game.local_player.champ_name ~= "Ezreal" then
	return
end

do
    local function AutoUpdate()
		local Version = 0.3
		local file_name = "NakedEzreal.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/NakedEzreal.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/NakedEzreal.lua.version.txt")
        console:log("NakedEzreal.Lua Vers: "..Version)
		console:log("NakedEzreal.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

						console:log("Naked Ezreal Successfully Loaded.....")
						console:log("---------R0B3RTxL33 Requested--------")

        else
						http:download_file(url, file_name)
			      console:log("Naked Ezreal Update available.....")
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
local WAutoTime = nil
local WAACast = false
local windup_end_time = 0
local CastWQ = false

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 1200, delay = .25, width = 120, speed = 2000 }
local W = { range = 1200, delay = .25, width = 160, speed = 1700 }
local E = { range = 475, delay = .25, width = 0, speed = 2000 }
local R = { range = 6000, delay = 1, width = 320, speed = 2000 }


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
	if HasBuff(unit, "ezrealwattach") then
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
	ezreal_category = menu:add_category_sprite("Shaun's Naked Ezreal", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	ezreal_category = menu:add_category("Shaun's Naked Ezreal")
end

ezreal_enabled = menu:add_checkbox("Enabled", ezreal_category, 1)
ezreal_combokey = menu:add_keybinder("Combo Mode Key", ezreal_category, 32)
menu:add_label("Shaun's Naked Ezreal", ezreal_category)
menu:add_label("#WhyYouNaked", ezreal_category)

manual_r = menu:add_subcategory("Semi Manual [R] Settings", ezreal_category)
ezreal_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", manual_r, 65)
e_table = {}
e_table[1] = "Lowest Target Health"
e_table[2] = "Closest Target To Cursor"
target_selection = menu:add_combobox("[Target Selection]", manual_r, e_table, 0)

manual_wq = menu:add_subcategory("Semi Manual [W+Q] Settings", ezreal_category)
ezreal_combo_wq_set_key = menu:add_keybinder("Semi Manual [W+Q] Key", manual_wq, 84)
menu:add_label("Utilizes Full [Q]+[W] Range", manual_wq)
wq_table = {}
wq_table[1] = "Lowest Target Health"
wq_table[2] = "Closest Target To Cursor"
target_selection_wq = menu:add_combobox("[Target Selection]", manual_wq, wq_table, 0)

ezreal_ark_pred = menu:add_subcategory("[Ark Pred Settings]", ezreal_category)

ezreal_ark_pred_q = menu:add_subcategory("[Q] Settings", ezreal_ark_pred, 1)
ezreal_q_hitchance = menu:add_slider("[Q] Ezreal Hit Chance [%]", ezreal_ark_pred_q, 1, 99, 50)
ezreal_q_speed = menu:add_slider("[Q] Ezreal Speed Input", ezreal_ark_pred_q, 1, 2500, 2000)
ezreal_q_range = menu:add_slider("[Q] Ezreal Range Input", ezreal_ark_pred_q, 1, 1200, 1145)
ezreal_q_radius = menu:add_slider("[Q] Ezreal Radius Input", ezreal_ark_pred_q, 1, 500, 70)

ezreal_ark_pred_w = menu:add_subcategory("[W] Settings", ezreal_ark_pred, 1)
ezreal_w_hitchance = menu:add_slider("[W] Ezreal Hit Chance [%]", ezreal_ark_pred_w, 1, 99, 50)
ezreal_w_speedy = menu:add_slider("[W] Ezreal Speed Input", ezreal_ark_pred_w, 1, 2500, 1700)
ezreal_w_range = menu:add_slider("[W] Ezreal Range Input", ezreal_ark_pred_w, 1, 1200, 1145)
ezreal_w_radius = menu:add_slider("[W] Ezreal Radius Input", ezreal_ark_pred_w, 1, 500, 80)

ezreal_ark_pred_r = menu:add_subcategory("[R] Settings", ezreal_ark_pred, 1)
ezreal_r_hitchance = menu:add_slider("[R] Ezreal Hit Chance [%]", ezreal_ark_pred_r, 1, 99, 40)
ezreal_r_speed = menu:add_slider("[R] Ezreal Speed Input", ezreal_ark_pred_r, 1, 2500, 2000)
ezreal_r_range = menu:add_slider("[R] Ezreal Range Input", ezreal_ark_pred_r, 1, 6000, 6000)
ezreal_r_radius = menu:add_slider("[R] Ezreal Radius Input", ezreal_ark_pred_r, 1, 500, 160)

ezreal_ks_function = menu:add_subcategory("[Kill Steal]", ezreal_category)
ezreal_ks_use_q = menu:add_checkbox("Use [Q]", ezreal_ks_function, 1)
ezreal_ks_use_r = menu:add_checkbox("Use [R]", ezreal_ks_function, 1)
ezreal_ks_use_range = menu:add_slider("Greater Than Range To Use [R] Kill Steal", ezreal_ks_function, 1, 5000, 1000)
ezreal_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", ezreal_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), ezreal_ks_r_blacklist, 1)
    end
end

ezreal_combo = menu:add_subcategory("[Combo]", ezreal_category)
ezreal_combo_use_q = menu:add_checkbox("Use [Q]", ezreal_combo, 1)
ezreal_combo_use_w = menu:add_checkbox("Use [W] Inside [AA] Range Only", ezreal_combo, 1)

ezreal_harass = menu:add_subcategory("[Harass]", ezreal_category)
ezreal_harass_use_q = menu:add_checkbox("Use [Q]", ezreal_harass, 1)
ezreal_harass_min_mana = menu:add_slider("Minimum [%] Mana To Harass", ezreal_harass, 1, 100, 20)

ezreal_laneclear = menu:add_subcategory("[Lane Clear]", ezreal_category)
ezreal_laneclear_use_q = menu:add_checkbox("Use [Q]", ezreal_laneclear, 1)
ezreal_laneclear_min_mana = menu:add_slider("Minimum [%] Mana To Lane Clear", ezreal_laneclear, 1, 100, 20)

ezreal_jungleclear = menu:add_subcategory("[Jungle Clear]", ezreal_category)
ezreal_jungleclear_use_q = menu:add_checkbox("Use [Q]", ezreal_jungleclear, 1)
ezreal_jungleclear_use_w = menu:add_checkbox("Use [W]", ezreal_jungleclear, 1)
ezreal_junglesteal = menu:add_checkbox("Jungle Steal [R] Epic Monsters", ezreal_jungleclear, 1)
ezreal_jungleclear_min_mana = menu:add_slider("Minimum [%] Mana To jungle Clear", ezreal_jungleclear, 1, 100, 20)

ezreal_draw = menu:add_subcategory("[Drawing] Features", ezreal_category)
ezreal_draw_q = menu:add_checkbox("Draw [Q]", ezreal_draw, 1)

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

local Q_input = {
    source = myHero,
    speed = menu:get_value(ezreal_q_speed), range = menu:get_value(ezreal_q_range),
    delay = 0.25, radius = menu:get_value(ezreal_q_radius),
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

local W_input = {
    source = myHero,
		speed = menu:get_value(ezreal_w_speedy), range = menu:get_value(ezreal_w_range),
    delay = 0.25, radius = menu:get_value(ezreal_w_radius),
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

local R_input = {
    source = myHero,
    speed = menu:get_value(ezreal_r_speed), range = menu:get_value(ezreal_r_range),
    delay = 1, radius = menu:get_value(ezreal_r_radius),
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

-- Casting

local function CastQ(unit)
	if windup_end_time <= game.game_time then

		local output = arkpred:get_prediction(Q_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ezreal_q_hitchance) / 100 and inv < 0.125 then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
			AACast = false
			AutoTime = nil
		end
	end
end

local function CastW(unit)

	if windup_end_time <= game.game_time then

		local output = arkpred:get_prediction(W_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ezreal_w_hitchance) / 100 and inv < 0.125 then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
			WAACast = false
			WAutoTime = nil
		end
	end
end

local function CastR(unit)

	local output = arkpred:get_prediction(R_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(ezreal_r_hitchance) / 100 and inv < 0.5 then
		local p = output.cast_pos
	  spellbook:cast_spell(SLOT_R, R.delay, p.x, p.y, p.z)
	end
end

-- Combo

local function Combo()

	local rtarget = selector:find_target(R.range, mode_health)
	local target = selector:find_target(Q.range, mode_health)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	local AutoAA = myHero:get_basic_attack_data()
	local CastAADelay = AutoAA.attack_cast_delay

	if menu:get_value(ezreal_combo_use_q) == 1 then
		if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end
	end

	if menu:get_value(ezreal_combo_use_q) == 1 then
		if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= TrueAARange then
				if AutoTime ~= nil and AutoTime + CastAADelay < tonumber(game.game_time) and AACast then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end

	if menu:get_value(ezreal_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= TrueAARange then
				if WAutoTime ~= nil and WAutoTime + CastAADelay < tonumber(game.game_time) and WAACast then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end
	end
end

--Harass

local function Harass()

	local target = selector:find_target(Q.range, mode_health)
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(ezreal_harass_min_mana) / 100
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	local AutoAA = myHero:get_basic_attack_data()
	local CastAADelay = AutoAA.attack_cast_delay

	if menu:get_value(ezreal_harass_use_q) == 1 and GrabHarassMana then
		if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= TrueAARange then
				if AutoTime ~= nil and AutoTime + CastAADelay < tonumber(game.game_time) and AACast then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end


	if menu:get_value(ezreal_harass_use_q) == 1 and GrabHarassMana then
		if IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end
	end
end


-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do


		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ezreal_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ezreal_ks_use_r) == 1 and GetRDmg(target) > target.health then
				if target.object_id ~= 0 then
					if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) > menu:get_value(ezreal_ks_use_range) then
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
	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ezreal_laneclear_min_mana) / 100
	for i, target in ipairs(minions) do

		if menu:get_value(ezreal_laneclear_use_q) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= 1 then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, true, false)

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

-- Jungle Clear

local function JungleClear()
	minions = game.jungle_minions
	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ezreal_jungleclear_min_mana) / 100
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(ezreal_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if GrabJungleClearMana then
				if Ready(SLOT_Q) then
					pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, true, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(ezreal_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range and IsValid(target) then
			if GrabJungleClearMana then
				if EpicMonster(target) and Ready(SLOT_W) and not Ready(SLOT_Q) then
					pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	if menu:get_value(target_selection) == 0 then
		target = selector:find_target(R.range, mode_health)
		if IsValid(target) and myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and IsKillable(target) then
				CastR(target)
			end
		end
	end

	if menu:get_value(target_selection) == 1 then
		target = selector:find_target(R.range, mode_cursor)
		if IsValid(target) and myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and IsKillable(target) then
				CastR(target)
			end
		end
	end
end

local function ManualWQCast()


	if menu:get_value(target_selection_wq) == 0 then
		target = selector:find_target(Q.range, mode_health)
		local targetvec = target.origin
		if IsValid(target) and myHero:distance_to(target.origin) <= Q.range then
			if Ready(SLOT_W) and Ready(SLOT_Q) and IsKillable(target) then

				local endPos = vec3.new(targetvec.x, targetvec.y, targetvec.z)
				local q_collisions = arkpred:get_collision(Q_input, endPos, target)
				if next(q_collisions) == nil then
					CastW(target)
					CastWQ = true
				end
			end
		end
		if CastWQ and IsValid(target) and myHero:distance_to(target.origin) <= Q.range then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(target_selection_wq) == 1 then
		target = selector:find_target(Q.range, mode_cursor)
		local targetvec = target.origin
		if IsValid(target) and myHero:distance_to(target.origin) <= Q.range then
			if Ready(SLOT_W) and Ready(SLOT_Q) and IsKillable(target) then

				local endPos = vec3.new(targetvec.x, targetvec.y, targetvec.z)
				local q_collisions = arkpred:get_collision(Q_input, endPos, target)
				if next(q_collisions) == nil then
					CastW(target)
					CastWQ = true
				end
			end
		end
		if CastWQ and IsValid(target) and myHero:distance_to(target.origin) <= Q.range then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end
end


local function RJungleSteal()

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and EpicMonster(target) and myHero:distance_to(target.origin) > 1500 then
			if IsValid(target) and myHero:distance_to(target.origin) < R.range then
				if Ready(SLOT_R) and GetRDmg(target) > target.health then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
				end
			end
		end
	end
end

--[[local function on_active_spell(obj, active_spell)

	if Is_Me(obj) then
		if active_spell.spell_name == "EzrealBasicAttack" or active_spell.spell_name == "EzrealBasicAttack2" then
			AutoTime = game.game_time
			AACast = true
		end
	end
end]]

local function on_active_spell(obj, active_spell)

	if obj ~= myHero then return end
	windup_end_time = active_spell.cast_end_time

	if active_spell.is_autoattack then
		AutoTime = game.game_time
		AACast = true
		WAutoTime = game.game_time
		WAACast = true
	end
end

--[[function on_process_spell(unit, args)
	if unit ~= myHero then return end
  windup_end_time = args.cast_time + args.cast_delay

	if args.is_autoattack then
		AutoTime = game.game_time
		AACast = true
		WAutoTime = game.game_time
		WAACast = true
	end
end]]

-- object returns, draw and tick usage

local function on_draw()
	screen_size = game.screen_size

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(ezreal_draw_q) == 1 then
		if  Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

end

local function on_tick()

	if game:is_key_down(menu:get_value(ezreal_combokey)) and menu:get_value(ezreal_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(ezreal_combo_r_set_key)) then
		ManualRCast()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(ezreal_combo_wq_set_key)) then
		ManualWQCast()
		orbwalker:move_to()
	else
		CastWQ = false
	end

	if not game:is_key_down(menu:get_value(ezreal_combokey)) then
		AACast = false
		AutoTime = nil
		WAACast = false
		WAutoTime = nil
	end

	if menu:get_value(ezreal_junglesteal) == 1 then
		RJungleSteal()
	end

	AutoKill()
end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_active_spell", on_active_spell)
