if game.local_player.champ_name ~= "Cassiopeia" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 7.2
		local file_name = "CassioToThePeia.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/CassioToThePeia.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/CassioToThePeia.lua.version.txt")
        console:log("Cassiopeia.Lua Vers: "..Version)
		console:log("Cassiopeia.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("Sexy Cassiopeia v7.2 Successfully Loaded.....")
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("------------------------------------------------------------------------------------------------------------")
        else
			http:download_file(url, file_name)
            console:log("Sexy Cassiopeia Update available.....")
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("Please reload via F5!.....")
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("Please reload via F5!.....")
						console:log("------------------------------------------------------------------------------------------------------------")
						console:log("Please reload via F5!.....")
						console:log("------------------------------------------------------------------------------------------------------------")
        end

    end

    AutoUpdate()


end

pred:use_prediction()
--require "LucifersPussyPrediction"

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

local Q = { range = 825, delay = .25, width = 80, radius = 37.5, speed = 2000 }
local W = { range = 700, delay = .25, width = 160, radius = 80, speed = 2000 }
local E = { range = 700, delay = .125, width = 0, speed = 0 }
local R = { range = 800, delay = .5, width = 200, radius = 412.5, speed = 2000 }

-- Return game data

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

local function GetInitialTargetsMinion(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius

	for i, target in ipairs(game.minions) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and IsValid(target) and GetDistanceSqr(main_target, target) < diameter_sqr and target.is_enemy then
			table.insert(targets, target)
		end
	end
	return targets
end

local function GetPredictedInitialTargetsMinion(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local predicted_main_target = pred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius

		for i, target in ipairs(game.minions) do
			if target.object_id ~= 0 and IsValid(target) then
				predicted_target = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
				if predicted_target.can_cast and target.object_id ~= main_target.object_id and GetDistanceSqr2(predicted_main_target.cast_pos, predicted_target.cast_pos) < diameter_sqr and target.is_enemy then
					table.insert(predicted_targets, target)
				end
			end
		end
	return predicted_targets
	end
end

local function GetBestAoEPositionMinion(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local targets = GetPredictedInitialTargetsMinion(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargetsMinion(radius, main_target)
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
    if unit:has_buff_type(poison) then
        return true
    end
    return false
end

function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
end

local function EpicMonsterPlusSiegMinion(unit)
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

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	Cass_category = menu:add_category_sprite("Shaun's Sexy Cassiopeia", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	Cass_category = menu:add_category("Shaun's Sexy Cassiopeia")
end

Cass_enabled = menu:add_checkbox("Enabled", Cass_category, 1)
Cass_combokey = menu:add_keybinder("Combo Mode Key", Cass_category, 32)
--[[s_table = {}
s_table[1] = "PKPrediction"
s_table[2] = "Bruh Internal"
Cass_prediction = menu:add_combobox("Prediction Selector", Cass_category, s_table, 0)]]

Cass_aa_mode = menu:add_subcategory("Auto Attacks Selector", Cass_category)
Cass_aa = menu:add_slider("Stop [AA] In Combo Mode >= Slider Level", Cass_aa_mode, 1, 18, 11)

Cass_ks_function = menu:add_subcategory("Kill Steal", Cass_category)
Cass_ks_use_q = menu:add_checkbox("Use [Q]", Cass_ks_function, 1)
Cass_ks_use_w = menu:add_checkbox("Use [W]", Cass_ks_function, 1)
Cass_ks_use_e = menu:add_checkbox("Use [E]", Cass_ks_function, 1)
Cass_ks_use_r = menu:add_checkbox("Use [R]", Cass_ks_function, 1)
Cass_ks_use_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", Cass_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), Cass_ks_use_r_blacklist, 1)
    end
end

Cass_lasthit = menu:add_subcategory("Last Hit", Cass_category)
Cass_lasthit_use = menu:add_checkbox("Use [E] Last Hit", Cass_lasthit, 1)
Cass_lasthit_auto = menu:add_checkbox("Auto [E] Last Hit", Cass_lasthit, 1)
Cass_lasthit_mana = menu:add_slider("Minimum Mana To [E] Last Hit", Cass_lasthit, 0, 200, 50)

Cass_combo = menu:add_subcategory("Combo", Cass_category)
Cass_combo_use_q = menu:add_checkbox("Use [Q]", Cass_combo, 1)
Cass_combo_use_w = menu:add_checkbox("Use [W]", Cass_combo, 1)
Cass_combo_use_e = menu:add_checkbox("Use [E]", Cass_combo, 1)
Cass_combo_r = menu:add_subcategory("[R] Combo Settings", Cass_combo, 1)
Cass_combo_use_r = menu:add_checkbox("Use [R]", Cass_combo_r, 1)
Cass_combo_r_enemy_hp = menu:add_slider("Combo [R] if Enemy HP is lower than [%]", Cass_combo_r, 1, 100, 50)
Cass_combo_r_my_hp = menu:add_slider("Only Combo [R] if My HP is Greater than [%]", Cass_combo_r, 1, 100, 20)
Cass_combo_use_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist", Cass_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use [R] Combo On: "..tostring(v.champ_name), Cass_combo_use_r_blacklist, 1)
    end
end
Cass_killkey = menu:add_keybinder("Engage [R] Combo Key", Cass_combo, 88, "Holding key Will Perform Enage [R] First Then Full Combo")
Cass_combo_w_posbuff = menu:add_checkbox("Only [W] When [Q] Has Missed and Target Is Not Poisoned", Cass_combo, 1)
Cass_combo_e_posbuff = menu:add_checkbox("Only [E] Combo When Posion Is Active", Cass_combo, 1)

Cass_harass = menu:add_subcategory("Harass", Cass_category)
Cass_harass_use_q = menu:add_checkbox("Use [Q]", Cass_harass, 1)
Cass_harass_use_w = menu:add_checkbox("Use [W]", Cass_harass, 1)
Cass_harass_use_e = menu:add_checkbox("use [E]", Cass_harass, 1)
Cass_harass_mana = menu:add_slider("Minimum Mana To Harass", Cass_harass, 0, 200, 50)
Cass_harass_posbuff = menu:add_checkbox("Only [E] Harass When Poison Is Active", Cass_harass, 1)

Cass_laneclear = menu:add_subcategory("Lane Clear", Cass_category)
Cass_laneclear_use_q = menu:add_checkbox("Use [Q]", Cass_laneclear, 1)
Cass_laneclear_use_w = menu:add_checkbox("Use [W]", Cass_laneclear, 1)
Cass_laneclear_use_e = menu:add_checkbox("use [E]", Cass_laneclear, 1)
Cass_laneclear_mana = menu:add_slider("Minimum Mana To Lane Clear", Cass_laneclear, 0, 200, 50)

Cass_jungleclear = menu:add_subcategory("Jungle Clear", Cass_category)
Cass_jungleclear_use_q = menu:add_checkbox("Use [Q]", Cass_jungleclear, 1)
Cass_jungleclear_use_w = menu:add_checkbox("Use [W]", Cass_jungleclear, 1)
Cass_jungleclear_use_e = menu:add_checkbox("use [E]", Cass_jungleclear, 1)
Cass_jungleclear_mana = menu:add_slider("Minimum Mana To jungle Clear", Cass_jungleclear, 0, 200, 50)

Cass_combo_r_options = menu:add_subcategory("Extra [R] Features", Cass_category)
Cass_combo_use_Inter = menu:add_checkbox("Auto [R] Interrupt Major Spells", Cass_combo_r_options, 1)
Cass_combo_use_gapclose = menu:add_checkbox("Auto [R] Gap Close", Cass_combo_r_options, 1)
Cass_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", Cass_combo_r_options, 65)
Cass_combo_r_auto = menu:add_checkbox("Use Auto [R]", Cass_combo_r_options, 1)
Cass_combo_r_auto_x = menu:add_slider("Number Of Targets To Perform Auto R", Cass_combo_r_options, 1, 5, 3)

Cass_draw = menu:add_subcategory("Drawing Features", Cass_category)
Cass_draw_q = menu:add_checkbox("Draw [Q]", Cass_draw, 1)
Cass_draw_e = menu:add_checkbox("Draw [E]", Cass_draw, 1)
Cass_draw_r = menu:add_checkbox("Draw [R]", Cass_draw, 1)
Cass_lasthit_draw = menu:add_checkbox("Draw Auto [E] Last Hit", Cass_draw, 1)
Cass_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", Cass_draw, 1)
Cass_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", Cass_draw, 1, "Health Bar Damage Is Computed From R, Q, W, E * 2")

-- Dmg Calculations

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = myHero.total_attack_damage + (.9 * myHero.ability_power)
  local QDamage = (({75, 110, 145, 180, 215})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetWDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_W).level
  local BonusDmg = myHero.total_attack_damage + (0.15 * myHero.ability_power)
  local WDamage = (({75, 25, 30, 35, 40})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_E).level
  local BonusDmg = myHero.total_attack_damage + (0.6 * myHero.ability_power)
  local EDamage = (({10, 30, 50, 70, 90})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmgLastHit(unit)
	local Damage = 0
  local level = myHero.level
  local EDamage = (48 + 4 * level) + (0.1 * myHero.ability_power)
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
  local BonusDmg = myHero.total_attack_damage + (0.5 * myHero.ability_power)
  local RDamage = (({150, 250, 350})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = RDamage - 10
  else
			Damage = RDamage
  end
	return unit:calculate_magic_damage(Damage)
end

-- Casting
--[[local function CastQ_PK(unit)

	local hitchance, PredPos = _G.PKPred.GetHitchance(myHero.origin, unit, Q.range, Q.delay, Q.speed, Q.width, false, false)
	console:log(tostring("Hitchance Q: "..hitchance))
	if PredPos and hitchance >= 1 then
		spellbook:cast_spell(SLOT_Q, Q.delay, PredPos.x, PredPos.y, PredPos.z)
	end
end]]

local function CastQ(unit)

	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

--[[local function CastW_PK(unit)

	local hitchance, PredPos = _G.PKPred.GetHitchance(myHero.origin, unit, W.range, W.delay, W.range, W.radius, false, false)
	console:log(tostring("Hitchance W: "..hitchance))
	if PredPos and hitchance >= 3 then
		spellbook:cast_spell(SLOT_W, W.delay, PredPos.x, PredPos.y, PredPos.z)
	end
end]]

local function CastW(unit)

	pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastE(unit)
	spellbook:cast_spell_targetted(SLOT_E, unit, E.delay)
end

--[[local function CastR_PK(unit)

	local hitchance, PredPos = _G.PKPred.GetHitchance(myHero.origin, unit, R.range, R.delay, R.range, R.radius, false, false)
	console:log(tostring("Hitchance R: "..hitchance))
	if PredPos and hitchance >= 3 then
		spellbook:cast_spell(SLOT_R, R.delay, PredPos.x, PredPos.y, PredPos.z)
	end
end]]

local function CastR(unit)

	pred_output = pred:predict(R.speed, R.delay, R.range, R.radius, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()
	local target = selector:find_target(Q.range, mode_health)
	local ChampLevel = myHero.level

	if menu:get_value(Cass_aa) <= ChampLevel then
		orbwalker:disable_auto_attacks()
	end
	if menu:get_value(Cass_aa) > ChampLevel then
		orbwalker:enable_auto_attacks()
	end

	if menu:get_value(Cass_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ(target)
				--[[if menu:get_value(Cass_prediction) == 0 then
					CastQ_PK(target)
				else
					CastQ(target)
				end]]
			end
		end
	end

	if menu:get_value(Cass_combo_use_w) == 1 and not Ready(SLOT_Q) then
		if menu:get_value(Cass_combo_w_posbuff) == 0 and Ready(SLOT_W) then
			if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				CastW(target)
				--[[if menu:get_value(Cass_prediction) == 0 then
					CastW_PK(target)
					CastQ(target)
				else
				end]]
			end
		end
	end

	if menu:get_value(Cass_combo_use_w) == 1 and not Ready(SLOT_Q) then
		if menu:get_value(Cass_combo_w_posbuff) == 1 and not HasPoison(target) and Ready(SLOT_W) then
			if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				CastW(target)
				--[[if menu:get_value(Cass_prediction) == 0 then
					CastW_PK(target)
				else
					CastW(target)
				end]]
			end
		end
	end

	if menu:get_value(Cass_combo_use_e) == 1 then
		if menu:get_value(Cass_combo_e_posbuff) == 0 and Ready(SLOT_E) then
			if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(Cass_combo_use_e) == 1 then
		if menu:get_value(Cass_combo_e_posbuff) == 1 and HasPoison(target) and Ready(SLOT_E) then
			if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(Cass_combo_use_r) == 1 then
		if target:health_percentage() <= menu:get_value(Cass_combo_r_enemy_hp) and local_player:health_percentage() >= menu:get_value(Cass_combo_r_my_hp) then
			if myHero:is_facing(target) and target:is_facing(myHero) and Ready(SLOT_R) then
				if menu:get_value_string("Use [R] Combo On: "..tostring(target.champ_name)) == 1 then
					if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
						CastR(target)
						--[[if menu:get_value(Cass_prediction) == 0 then
							CastR_PK(target)
						else
							CastR(target)
						end]]
					end
				end
			end
		end
	end
end

--Harass

local function Harass()
	local target = selector:find_target(Q.range, mode_health)

	if menu:get_value(Cass_harass_use_q) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) and Ready(SLOT_Q) then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(Cass_harass_use_w) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) and Ready(SLOT_W) then
			if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				CastW(target)
			end
		end
	end

	if menu:get_value(Cass_harass_use_e) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) then
			if menu:get_value(Cass_harass_posbuff) == 0 and Ready(SLOT_E) then
				if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
					CastE(target)
				end
			end
		end
	end

	if menu:get_value(Cass_harass_use_e) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) then
			if menu:get_value(Cass_harass_posbuff) == 1 and HasPoison(target) and Ready(SLOT_E) then
				if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
					CastE(target)
				end
			end
		end
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 then
			if menu:get_value(Cass_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 then
			if menu:get_value(Cass_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_W) then
							CastW(target)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 then
			if menu:get_value(Cass_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_E) then
							CastE(target)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 then
			if menu:get_value(Cass_ks_use_r) == 1 then
				if GetRDmg(target) > target.health and target.health > GetEDmg(target) then
					if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_R) and menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
							CastR(target)
						end
					end
				end
			end
		end
	end
end

-- Can Engage Function

local function Engage()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) then
			if Ready(SLOT_R) and Ready(SLOT_Q) and Ready(SLOT_W) then
				if myHero:is_facing(target) and target:is_facing(myHero) then
					CastR(target)
				end
			end
		end
		if not Ready(SLOT_R) and Ready(SLOT_Q) then
			CastQ(target)
		end
		if not Ready(SLOT_R) and Ready(SLOT_W) then
			CastW(target)
		end
		if not Ready(SLOT_R) and Ready(SLOT_E) then
			CastE(target)
		end
	end
end

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(Cass_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if target.object_id ~= 0 then
				if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
					if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
						local CastPos, targets = GetBestAoEPositionMinion(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
						if CastPos and targets >= 2 and Ready(SLOT_Q) then
							spellbook:cast_spell(SLOT_Q, Q.delay, CastPos.x, CastPos.y, CastPos.z)
						end
					end
				end
			end
		end

		if menu:get_value(Cass_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 then
				if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
					if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
						local CastPos, targets = GetBestAoEPositionMinion(W.speed, W.delay, W.range, W.width, target, false, false)
						if CastPos and targets >= 3 and Ready(SLOT_W) then
							spellbook:cast_spell(SLOT_W, W.delay, CastPos.x, CastPos.y, CastPos.z)
						end
					end
				end
			end
		end

	 	if menu:get_value(Cass_laneclear_use_e) == 1 then
			if menu:get_value(Cass_lasthit_auto) == 0 then
				if target.object_id ~= 0 then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
							if Ready(SLOT_E) then
								CastE(target)
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

		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_q) == 1 then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if Ready(SLOT_Q) then
					if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_w) == 1 then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_e) == 1 then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.object_id ~= 0 then
			if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
				if myHero:is_facing(target) and target:is_facing(myHero) and Ready(SLOT_R) then
					CastR(target)
				end
			end
		end
	end
end

-- Auto R >= Targets

local function AutoRxTargets()
for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 then
			if menu:get_value(Cass_combo_r_auto) == 1 and GetEnemyCount(800, myHero) >= menu:get_value(Cass_combo_r_auto_x) then
				if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
					if myHero:is_facing(target) and target:is_facing(myHero) then
						if Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
		end
	end
end

-- Auto E last Hit

local function AutoELastHit(target)

	if menu:get_value(Cass_lasthit_auto) == 0 then
		orbwalker:disable_auto_attacks()
	end

	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy then
			if GetEDmgLastHit(target) > target.health then
				if not game:is_key_down(menu:get_value(Cass_combokey)) and not game:is_key_down(menu:get_value(Cass_killkey)) then
					if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_E) then
							CastE(target)
						end
					end
				end
			end

			if EpicMonsterPlusSiegMinion(target) then
				if GetEDmgLastHit(target) > target.health then
					if not game:is_key_down(menu:get_value(Cass_combokey)) and not game:is_key_down(menu:get_value(Cass_killkey)) then
						if myHero:distance_to(target.origin) <= E.range and IsValid(target) then
							if Ready(SLOT_E) then
								CastE(target)
							end
						end
					end
				end
			end
		end
	end
end

-- Auto R Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(Cass_combo_use_Inter) == 1 then
      if myHero:distance_to(obj.origin) < R.range and Ready(SLOT_R) then
				if myHero:is_facing(target) and target:is_facing(myHero) then
        	CastR(obj)
				end
			end
		end
	end
end

-- Anti R Gap

local function on_gap_close(obj, data)

	if IsValid(obj) and menu:get_value(Cass_combo_use_gapclose) == 1 then
		if myHero:distance_to(obj.origin) <= R.range then
			if myHero:is_facing(target) and target:is_facing(myHero) then
				if Ready(SLOT_R) then
					CastW(obj)
				end
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()
	local_player = game.local_player
	screen_size = game.screen_size

	target = selector:find_target(2000, mode_health)
	targetvec = target.origin

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z

		if menu:get_value(Cass_draw_q) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
			end
		end

		if menu:get_value(Cass_draw_e) == 1 then
			if Ready(SLOT_E) then
				renderer:draw_circle(x, y, z, E.range, 0, 0, 255, 255)
			end
		end

		if menu:get_value(Cass_draw_r) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(x, y, z, R.range, 225, 0, 0, 255)
			end
		end
	end

	if menu:get_value(Cass_lasthit_draw) == 1 then
		if menu:get_value(Cass_lasthit_auto) == 1 then
			if menu:get_value(Cass_lasthit_use) == 1 then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Auto [E] Only Last Hit Enabled")
			end
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetEDmg(target) * 2 + GetRDmg(target)
		if Ready(SLOT_R) and Ready(SLOT_Q) and Ready(SLOT_W) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
				if menu:get_value(Cass_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Full Combo Can Kill")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(Cass_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(Cass_combokey)) and menu:get_value(Cass_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		orbwalker:enable_auto_attacks()
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		orbwalker:enable_auto_attacks()
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(Cass_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_value(Cass_combo_r_auto) == 1 then
		AutoRxTargets()
	end

	if combo:get_mode() == MODE_LASTHIT and menu:get_value(Cass_lasthit_use) == 1 and local_player.mana >= menu:get_value(Cass_lasthit_mana) and menu:get_value(Cass_lasthit_auto) == 0 then
		AutoELastHit()
	end
	if menu:get_value(Cass_lasthit_auto) == 1 and local_player.mana >= menu:get_value(Cass_lasthit_mana) then
		AutoELastHit()
	end

	if game:is_key_down(menu:get_value(Cass_killkey)) then
		orbwalker:move_to()
		Engage()
	end


	if not game:is_key_down(menu:get_value(Cass_killkey)) then
	 	if not game:is_key_down(menu:get_value(Cass_combokey)) then
	 		if not combo:get_mode() == MODE_LASTHIT then
				orbwalker:enable_auto_attacks()
			end
		end
	end

	KillSteal()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_gap_close", on_gap_close)
