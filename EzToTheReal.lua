if game.local_player.champ_name ~= "Ezreal" then
	return
end

do
    local function AutoUpdate()
		local Version = 2.0
		local file_name = "EzToTheReal.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/EzToTheReal.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/EzToTheReal.lua.version.txt")
        console:log("EzToTheReal.Lua Vers: "..Version)
		console:log("EzToTheReal.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("----------------------------------------------------------------")
						console:log("----------------------------------------------------------------")
						console:log("Sexy Ezreal v2.0 successfully loaded.....")
						console:log("----------------------------------------------------------------")
						console:log("----------------------------------------------------------------")
        else
			http:download_file(url, file_name)
			      console:log("Sexy Ezreal Update available.....")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
						console:log("----------------------------")
						console:log("Please Reload via F5!.....")
        end

    end

    AutoUpdate()
end

pred:use_prediction()

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 1200, delay = .25, width = 120, speed = 2000 }
local W = { range = 1200, delay = .25, width = 160, speed = 1700 }
local E = { range = 475, delay = .25, width = 0, speed = 2000 }
local R = { range = 6000, delay = 1, width = 320, speed = 2000 }


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
				predicted_target = pred:predict(math.huge, 1.5, R.range, R.width, target, false, false)
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
			local CastPos, targets = GetBestAoEPosition(math.huge, 1.5, R.range, R.width, unit, false, false)
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

function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
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
	ezreal_category = menu:add_category_sprite("Shaun's Sexy Ezreal", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	ezreal_category = menu:add_category("Shaun's Sexy Ezreal")
end

ezreal_enabled = menu:add_checkbox("Enabled", ezreal_category, 1)
ezreal_combokey = menu:add_keybinder("Combo Mode Key", ezreal_category, 32)
menu:add_label("Welcome To Shaun's Sexy Ezreal", ezreal_category)
menu:add_label("#PrettyBoyEz", ezreal_category)

ezreal_ks_function = menu:add_subcategory("Kill Steal", ezreal_category)
ezreal_ks_use_q = menu:add_checkbox("Use [Q]", ezreal_ks_function, 1)
ezreal_ks_use_w = menu:add_checkbox("Use [W]", ezreal_ks_function, 1)
ezreal_ks_use_r = menu:add_checkbox("Use [R]", ezreal_ks_function, 1)
ezreal_ks_use_range = menu:add_slider("Greater Than Range To Use [R] Kill Steal", ezreal_ks_function, 1, 5000, 1000)
ezreal_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", ezreal_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), ezreal_ks_r_blacklist, 1)
    end
end


ezreal_combo = menu:add_subcategory("Combo", ezreal_category)
ezreal_combo_use_q = menu:add_checkbox("Use [Q]", ezreal_combo, 1)
ezreal_combo_use_w = menu:add_checkbox("Use [W]", ezreal_combo, 1)
ezreal_combo_r = menu:add_subcategory("[R] Combo Settings", ezreal_combo)
ezreal_combo_use_r = menu:add_checkbox("Use [R]", ezreal_combo_r, 1)
ezreal_combo_use_range = menu:add_slider("Greater Than Range To Use [R] Combo", ezreal_combo_r, 1, 5000, 1000)
ezreal_combo_r_enemy_hp = menu:add_slider("Combo [R] if Enemy HP is lower than [%]", ezreal_combo_r, 1, 100, 40)
ezreal_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist", ezreal_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), ezreal_combo_r_blacklist, 1)
    end
end

ezreal_harass = menu:add_subcategory("Harass", ezreal_category)
ezreal_harass_use_q = menu:add_checkbox("Use [Q]", ezreal_harass, 1)
ezreal_harass_use_w = menu:add_checkbox("Use [W]", ezreal_harass, 1)
ezreal_harass_use_auto_q = menu:add_toggle("Toggle Auto [Q] Harass", 1, ezreal_harass, 90, true)
ezreal_harass_min_mana = menu:add_slider("Minimum Mana To Harass", ezreal_harass, 1, 500, 100)

ezreal_laneclear = menu:add_subcategory("Lane Clear", ezreal_category)
ezreal_laneclear_use_q = menu:add_checkbox("Use [Q]", ezreal_laneclear, 1)
ezreal_laneclear_min_mana = menu:add_slider("Minimum Mana To Lane Clear", ezreal_laneclear, 1, 500, 200)

ezreal_jungleclear = menu:add_subcategory("Jungle Clear", ezreal_category)
ezreal_jungleclear_use_q = menu:add_checkbox("Use [Q]", ezreal_jungleclear, 1)
ezreal_jungleclear_use_w = menu:add_checkbox("Use [W]", ezreal_jungleclear, 1)
ezreal_jungleclear_min_mana = menu:add_slider("Minimum Mana To jungle Clear", ezreal_jungleclear, 1, 500, 200)


ezreal_misc_options = menu:add_subcategory("Extra Features", ezreal_category)
ezreal_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", ezreal_misc_options, 65)
ezreal_misc_w_turret = menu:add_toggle("Toggle Auto [W] Turret", 1, ezreal_misc_options, 85, true)

ezreal_auto_r = menu:add_subcategory("Auto [R] - Using Best AoE Position", ezreal_category)
ezreal_use_auto_r = menu:add_checkbox("Use Auto [R]", ezreal_auto_r, 1)
ezreal_auto_r_range = menu:add_slider("Greater Than Range To Use Auto [R]", ezreal_auto_r, 1, 5000, 2500)
ezreal_auto_r_x = menu:add_slider("Minimum Targets To Use Auto R", ezreal_auto_r, 1, 5, 3)

ezreal_draw = menu:add_subcategory("Drawing Features", ezreal_category)
ezreal_draw_q = menu:add_checkbox("Draw [Q]", ezreal_draw, 1)
ezreal_draw_e = menu:add_checkbox("Draw [E]", ezreal_draw, 1)
ezreal_auto_q_draw = menu:add_checkbox("Toggle Auto [Q] Harass Draw", ezreal_draw, 1)
ezreal_auto_turret_draw = menu:add_checkbox("Toggle Auto [W] Turret Draw", ezreal_draw, 1)
ezreal_r_best_draw = menu:add_checkbox("Draw Auto [R] Best Position Circle + Count", ezreal_draw, 1)
ezreal_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", ezreal_draw, 1)
ezreal_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", ezreal_draw, 1, "Health Bar Damage Is Computed From R, Q, W")


local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = myHero.total_attack_damage + (.9 * myHero.ability_power)
  local QDamage = ({20, 45, 70, 95, 120})[level] + 0.15 * myHero.ability_power + 1.3 * myHero.total_attack_damage
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetWDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_W).level
  local BonusDmg = myHero.total_attack_damage + (0.15 * myHero.ability_power)
  local WDamage = ({80, 135, 190, 245, 300})[level] + (({0.7, 0.75, 0.8, 0.85, 0.9})[level] * myHero.ability_power) + 0.6 * myHero.bonus_attack_damage
  if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetRDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_R).level
  local BonusDmg = myHero.total_attack_damage + (0.5 * myHero.ability_power)
  local RDamage = ({350, 500, 650})[level] + 0.9 * myHero.ability_power + myHero.bonus_attack_damage
  if HasHealingBuff(unit) then
      Damage = RDamage - 10
  else
			Damage = RDamage
  end
	return unit:calculate_magic_damage(Damage)
end


-- Casting

local function CastQ(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, true, true)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastR(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()

	local target = selector:find_target(R.range, mode_health)

	if menu:get_value(ezreal_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end

	if menu:get_value(ezreal_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(ezreal_combo_use_r) == 1 then
		if myHero:distance_to(target.origin) > menu:get_value(ezreal_combo_use_range) and IsValid(target) and IsKillable(target) then
			if target:health_percentage() <= menu:get_value(ezreal_combo_r_enemy_hp) then
				if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
					if Ready(SLOT_R) then
						CastR(target)
					end
				end
			end
		end
	end
end

--Harass

local function Harass()

	local target = selector:find_target(Q.range, mode_health)

	if menu:get_value(ezreal_harass_use_q) == 1 then
		if myHero.mana >= menu:get_value(ezreal_harass_min_mana) then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end
	end

	if menu:get_value(ezreal_harass_use_w) == 1 then
		if myHero.mana >= menu:get_value(ezreal_harass_min_mana) then
			if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end
end

-- Auto Q Harass

local function AutoQHarass()

	local target = selector:find_target(Q.range, mode_health)

	if menu:get_value(ezreal_harass_use_q) == 1 then
		if myHero.mana >= menu:get_value(ezreal_harass_min_mana) then
			if combo:get_mode() ~= MODE_COMBO and not game:is_key_down(menu:get_value(ezreal_combokey)) then
				if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_Q) and not IsUnderTurret(myHero) then
						CastQ(target)
					end
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

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(ezreal_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
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
	for i, target in ipairs(minions) do

		if menu:get_value(ezreal_laneclear_use_q) == 1 and myHero.mana >= menu:get_value(ezreal_laneclear_min_mana) then
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
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(ezreal_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if myHero.mana >= menu:get_value(ezreal_jungleclear_min_mana) then
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

		if target.object_id ~= 0 and menu:get_value(ezreal_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range and IsValid(target) then
			if myHero.mana >= menu:get_value(ezreal_jungleclear_min_mana) then
				if EpicMonster(target) and Ready(SLOT_W) and not Ready(SLOT_Q) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
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
	target = selector:find_target(R.range, mode_cursor)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) and IsKillable(target) then
			CastR(target)
		end
	end
end

-- W Turret Cast

local function ManualWCast()

	turrets = game.turrets
	for i, target in ipairs(turrets) do
		if target and target.is_enemy then
			if target.is_alive then
				if IsUnderTurret(myHero) and Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end
end

local function AutoRx()
	if Ready(SLOT_R) and menu:get_value(ezreal_use_auto_r) == 1 then
		for i, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= menu:get_value(ezreal_auto_r_range) then
				local CastPos, targets = GetBestAoEPosition(math.huge, 1.5, R.range, R.width, unit, false, false)
				if CastPos and targets >= menu:get_value(ezreal_auto_r_x) then
					spellbook:cast_spell(SLOT_R, R.delay, CastPos.x, CastPos.y, CastPos.z)
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

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(ezreal_draw_q) == 1 then
		if  Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(ezreal_draw_e) == 1 then
		if Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 20, 147, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = (GetQDmg(target) + GetWDmg(target) + GetRDmg(target))
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range then
				if menu:get_value(ezreal_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(ezreal_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

	if menu:get_value(ezreal_auto_q_draw) == 1 then
		if menu:get_value(ezreal_harass_use_q) == 1 then
			if menu:get_toggle_state(ezreal_harass_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [Q] Harass Enabled")
			end
		end
	end

	if menu:get_value(ezreal_auto_turret_draw) == 1 then
		if menu:get_toggle_state(ezreal_misc_w_turret) then
			renderer:draw_text_centered(screen_size.width / 2, screen_size.height / 50, "Toggle Auto [W] Turret Enabled")
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

	if menu:get_toggle_state(ezreal_harass_use_auto_q) and combo:get_mode() ~= MODE_COMBO and not game:is_key_down(menu:get_value(ezreal_combokey)) then
		AutoQHarass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(ezreal_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_toggle_state(ezreal_misc_w_turret) and not game:is_key_down(menu:get_value(ezreal_combokey)) then
		ManualWCast()
	end

	if menu:get_value(ezreal_r_best_draw) == 1 then
		AoEDraw()
	end

	AutoRx()

	AutoKill()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
