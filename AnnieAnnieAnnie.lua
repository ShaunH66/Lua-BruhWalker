if game.local_player.champ_name ~= "Annie" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.6
		local file_name = "AnnieAnnieAnnie.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/AnnieAnnieAnnie.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/AnnieAnnieAnnie.lua.version.txt")
        console:log("AnnieAnnieAnnie.lua Vers: "..Version)
		console:log("AnnieAnnieAnnie.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Shaun's Sexy Annie Successfully Loaded.....")



        else
			http:download_file(url, file_name)
			      console:log("Sexy Annie Update available.....")
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

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 625, delay = .25, width = 0, speed = 0 }
local W = { range = 625, delay = .25, width = 50, speed = 0 }
local E = { range = 800, delay = .1, width = 0, speed = 0 }
local R = { range = 600, delay = .25, width = 350, speed = 0 }


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
			local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, unit, false, false)
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

local function HasStunPassive(unit)
	if unit:has_buff("anniepassiveprimed") then
		return true
	end
	return false
end

local function TiddersUP(unit)
	if unit:has_buff("AnnieRController") then
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

function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
end

local function IsFlashSlotF()
flash = spellbook:get_spell_slot(SLOT_F)
FData = flash.spell_data
FName = FData.spell_name
if FName == "SummonerFlash" then
    return true
end
return false
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	annie_category = menu:add_category_sprite("Shaun's Sexy Annie", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	annie_category = menu:add_category("Shaun's Sexy Annie")
end

annie_enabled = menu:add_checkbox("Enabled", annie_category, 1)
annie_combokey = menu:add_keybinder("Combo Mode Key", annie_category, 32)
menu:add_label("Welcome To Shaun's Sexy Annie", annie_category)
menu:add_label("#WheresMyTibbers?", annie_category)

annie_ks_function = menu:add_subcategory("Kill Steal", annie_category)
annie_ks_use_q = menu:add_checkbox("Use [Q]", annie_ks_function, 1)
annie_ks_use_w = menu:add_checkbox("Use [W]", annie_ks_function, 1)
annie_ks_use_r = menu:add_checkbox("Use [R]", annie_ks_function, 1)
annie_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", annie_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), annie_ks_r_blacklist, 1)
    end
end


annie_combo = menu:add_subcategory("Combo", annie_category)
annie_combo_use_q = menu:add_checkbox("Use [Q]", annie_combo, 1)
annie_combo_use_w = menu:add_checkbox("Use [W]", annie_combo, 1)
annie_combo_r = menu:add_subcategory("[R] Combo Settings", annie_combo)
annie_combo_use_r = menu:add_checkbox("Use [R]", annie_combo_r, 1)
annie_combo_r_enemy_hp = menu:add_slider("Combo [R] if Enemy HP is lower than [%]", annie_combo_r, 1, 100, 25)
annie_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist", annie_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), annie_combo_r_blacklist, 1)
    end
end

annie_harass = menu:add_subcategory("Harass", annie_category)
annie_harass_use_q = menu:add_checkbox("Use [Q]", annie_harass, 1)
annie_harass_use_w = menu:add_checkbox("Use [W]", annie_harass, 1)

annie_auto_e = menu:add_subcategory("[E] Features", annie_category)
annie_auto_e_use = menu:add_checkbox("Use [E] To Charge Stun", annie_auto_e, 1)
annie_auto_ally = menu:add_checkbox("Use [E] On Ally", annie_auto_e, 1)
annie_auto_self = menu:add_checkbox("Use [E] On Self", annie_auto_e, 1)
annie_allyblacklist = menu:add_subcategory("Ally [E] Blacklist", annie_auto_e)
players = game.players
for _, v in ipairs(players) do
	if not v.is_enemy and v.object_id ~= myHero.object_id then
		menu:add_checkbox("Use E On : "..tostring(v.champ_name), annie_allyblacklist, 1)
	end
end
annie_auto_ally_hp = menu:add_slider("Minimum Health % To Use [E] On Ally", annie_auto_e, 1, 100, 25)
annie_auto_self_hp = menu:add_slider("Minimum Health % To Use [E] On Self", annie_auto_e, 1, 100, 20)


annie_laneclear = menu:add_subcategory("Lane Clear", annie_category)
annie_laneclear_use_q = menu:add_checkbox("Use [Q]", annie_laneclear, 1)
annie_laneclear_use_w = menu:add_checkbox("Use [W]", annie_laneclear, 1)
annie_laneclear_w_min = menu:add_slider("Number Of Minions To Use [W]", annie_laneclear, 1, 10, 3)

annie_jungleclear = menu:add_subcategory("Jungle Clear", annie_category)
annie_jungleclear_use_q = menu:add_checkbox("Use [Q]", annie_jungleclear, 1)
annie_jungleclear_use_w = menu:add_checkbox("Use [W]", annie_jungleclear, 1)

annie_lasthit = menu:add_subcategory("Last Hit", annie_category)
annie_lasthit_use_q = menu:add_checkbox("Use [Q]", annie_lasthit, 1)
annie_lasthit_use_auto_q = menu:add_toggle("Toggle Auto [Q] Last Hit", 1, annie_lasthit, 90, true)
annie_lasthit_stun = menu:add_checkbox("Use [Q] Last Hit When Stun Is Ready", annie_lasthit, 1)

annie_r_misc_options = menu:add_subcategory("[R] Features", annie_category)
annie_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key - Closest To Cursor Target", annie_r_misc_options, 65)
annie_combo_r_auto = menu:add_checkbox("Auto [R] - Using Best AoE Prediction", annie_r_misc_options, 1)
annie_combo_r_auto_x = menu:add_slider("Minimum Of Targets To Perform Auto [R]", annie_r_misc_options, 1, 5, 2)
annie_combo_flash_r_auto = menu:add_keybinder("Flash [R] Key - Using Best AoE Prediction", annie_r_misc_options, 88)
annie_combo_flash_r_auto_x = menu:add_slider("Minimum Of Targets To Perform Flash [R]", annie_r_misc_options, 1, 5, 3)

annie_r_extra = menu:add_subcategory("[Extra] Features", annie_category)
annie_gapclose = menu:add_checkbox("Auto Stun Gap Close", annie_r_extra, 1)
annie_interrupt = menu:add_checkbox("Auto Stun Major Channel Spells", annie_r_extra, 1)


annie_draw = menu:add_subcategory("The Drawing Features", annie_category)
annie_draw_q = menu:add_checkbox("Draw [Q] Range", annie_draw, 1)
annie_draw_r = menu:add_checkbox("Draw [R] Range", annie_draw, 1)
annie_stun_draw = menu:add_checkbox("Draw Stun Ready Text", annie_draw, 1)
annie_r_best_draw = menu:add_checkbox("Draw Auto [R] Best Position Circle + Count", annie_draw, 1)
annie_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Last Hit Text", annie_draw, 1)
annie_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", annie_draw, 1)
annie_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", annie_draw, 1, "Health Bar Damage Is Computed From R > Q > W")


local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({80, 115, 150, 185, 220})[level] + 0.8 * myHero.ability_power
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
  local BonusDmg = 0
  local WDamage = ({70, 115, 160, 205, 250})[level] + 0.85 * myHero.ability_power
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
  local BonusDmg = 0
  local RDamage = ({150, 275, 400})[level] + 0.65 * myHero.ability_power
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
end

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

local function CastR(unit)
	pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()

	target = selector:find_target(Q.range, mode_health)

	if menu:get_value(annie_combo_use_r) == 1 and IsValid(target) then
		if target:health_percentage() <= menu:get_value(annie_combo_r_enemy_hp) then
			if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 and not TiddersUP(myHero) then
				if myHero:distance_to(target.origin) <= R.range and IsKillable(target) then
					if Ready(SLOT_R) and HasStunPassive(myHero) then
						CastR(target)
					end
				end
			end
		end
	end

	if menu:get_value(annie_combo_use_q) == 1 and IsValid(target) then
		if myHero:distance_to(target.origin) <= Q.range and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(annie_combo_use_w) == 1 and IsValid(target) then
		if myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end

end

--Harass

local function Harass()

	target = selector:find_target(Q.range, mode_health)

	if menu:get_value(annie_harass_use_q) == 1 and IsValid(target) then
		if myHero:distance_to(target.origin) <= Q.range and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end


	if menu:get_value(annie_harass_use_w) == 1 and IsValid(target) then
		if myHero:distance_to(target.origin) <= W.range and IsKillable(target) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(annie_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(annie_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(annie_ks_use_r) == 1 and GetRDmg(target) > target.health then
				if Ready(SLOT_R) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 and not TiddersUP(myHero) then
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

		if menu:get_value(annie_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, target) and GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						spellbook:cast_spell_targetted(SLOT_Q, target, Q.delay)
					end
				end
			end
		end

		if menu:get_value(annie_laneclear_use_w) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if GetMinionCount(W.range, target) >= menu:get_value(annie_laneclear_w_min) and not IsUnderTurret(myHero) then
					if Ready(SLOT_W) then

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
end


-- Jungle Clear

local function JungleClear()
	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(annie_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if Ready(SLOT_Q) then
					spellbook:cast_spell_targetted(SLOT_Q, target, Q.delay)
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(annie_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range then
			if IsValid(target) then
				if Ready(SLOT_W) then

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
		if Ready(SLOT_R) and IsValid(target) and IsKillable(target) and not TiddersUP(myHero) then
			CastR(target)
		end
	end
end

-- Auto R >= Targets

local function AutoR()
	if Ready(SLOT_R) and not TiddersUP(myHero) and HasStunPassive(myHero) then
		for i, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= R.range then
				local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, unit, false, false)
				if CastPos and targets >= menu:get_value(annie_combo_r_auto_x) then
					spellbook:cast_spell(SLOT_R, R.delay, CastPos.x, CastPos.y, CastPos.z)
				end
			end
		end
	end
end

-- Auto Flash R --

local function AutoFlash()

	target = selector:find_target(Q.range, mode_health)

	if Ready(SLOT_R) and not TiddersUP(myHero) and HasStunPassive(myHero) then
		for _, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= 1000 then
				local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, unit, false, false)
				if CastPos and targets >= menu:get_value(annie_combo_flash_r_auto_x) then
					if not IsFlashSlotF() and Ready(SLOT_D) then
	          spellbook:cast_spell(SLOT_D, 0, CastPos.x, CastPos.y, CastPos.z)
	        elseif IsFlashSlotF() and Ready(SLOT_F) then
	          spellbook:cast_spell(SLOT_F, 0, CastPos.x, CastPos.y, CastPos.z)
					end
				end
			end
		end
	end

	if not Ready(SLOT_F) and TiddersUP(myHero) then
		if menu:get_value(annie_combo_use_q) == 1 then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(annie_combo_use_w) == 1 then
			if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end
end

-- Auto E --

local function AutoE()

	target = selector:find_target(1500, mode_health)
	players = game.players
	for _, v in ipairs(players) do
		----------------------------- Ally E--------------------------
		if not v.is_enemy and v.object_id ~= myHero.object_id then
			if menu:get_value(annie_auto_ally) == 1 and Ready(SLOT_E) then
				if v and myHero:distance_to(v.origin) < E.range and IsValid(v) then
					if v:health_percentage() <= menu:get_value(annie_auto_ally_hp) then
						if IsValid(target) and GetEnemyCountCicular(1500, target.origin) >= 1 then
							if menu:get_value_string("Use E On : "..v.champ_name) == 1 and not HasStunPassive(myHero) then
								CastE(v)
							end
						end
					end
				end
			end
		end
		--------------------------- Self E -----------------------------
		if Is_Me(v) then
			if menu:get_value(annie_auto_self) == 1 and Ready(SLOT_E) and IsValid(v) then
				if IsValid(target) and GetEnemyCountCicular(1500, target.origin) >= 1 then
					if v:health_percentage() <= menu:get_value(annie_auto_self_hp) and not HasStunPassive(myHero) then
						CastE(v)
					end
				end
			end
		end
		--------------------------- Self Auto E Charge -----------------------------
		if Is_Me(v) then
			if menu:get_value(annie_auto_e_use) == 1 and Ready(SLOT_E) and IsValid(v) then
				if not HasStunPassive(myHero) and not myHero.is_recalling then
					CastE(v)
				end
			end
		end
	end
end

local function QLastHit()

	minions = game.minions
	for i, target in ipairs(minions) do
		if menu:get_value(annie_lasthit_use_q) == 1 then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= 1 then
					if GetQDmg(target) > target.health then
						if menu:get_value(annie_lasthit_stun) == 0 and not HasStunPassive(myHero) or menu:get_value(annie_lasthit_stun) == 1 then
							if Ready(SLOT_Q) then
								CastQ(target)
							end
						end
					end
				end
			end
		end
	end
end

local function AutoQLastHit()

	minions = game.minions
	for i, target in ipairs(minions) do
		if menu:get_value(annie_lasthit_use_q) == 1 and menu:get_value(annie_lasthit_use_auto_q) == 1 then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= 1 then
					if GetQDmg(target) > target.health then
						if menu:get_value(annie_lasthit_stun) == 0 and not HasStunPassive(myHero) or menu:get_value(annie_lasthit_stun) == 1 then
							if Ready(SLOT_Q) then
								CastQ(target)
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
    if menu:get_value(annie_interrupt) == 1 then
      if myHero:distance_to(obj.origin) < Q.range and HasStunPassive(myHero) and Ready(SLOT_Q) then
        CastQ(obj)
			end
		end
	end
end

-- Gap Close

local function on_gap_close(obj, data)

	if IsValid(obj) then
    if menu:get_value(annie_gapclose) == 1 then
      if myHero:distance_to(obj.origin) < Q.range and HasStunPassive(myHero) and Ready(SLOT_Q) then
        CastQ(obj)
			end
		end
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	target = selector:find_target(2000, mode_health)
	targetvec = target.origin

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(annie_draw_q) == 1 then
		if  Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(annie_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 20, 147, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target)
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range then
				if menu:get_value(annie_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(annie_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

	if menu:get_value(annie_auto_q_draw) == 1 then
		if menu:get_value(annie_lasthit_use_q) == 1 then
			if menu:get_toggle_state(annie_lasthit_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto Q Last Hit Enabled")
			end
		end
	end

	if menu:get_value(annie_stun_draw) == 1 then
		if HasStunPassive(myHero) then
			renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 5, "Stun Ready")
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(annie_combokey)) and menu:get_value(annie_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LASTHIT then
		QLastHit()
		QLastHitEnabled = true
	else
		QLastHitEnabled = false
	end

	if menu:get_toggle_state(annie_lasthit_use_auto_q) and not game:is_key_down(menu:get_value(annie_combokey)) and not QLastHitEnabled then
		AutoQLastHit()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if menu:get_value(annie_combo_r_auto) == 1 then
		AutoR()
	end

	if game:is_key_down(menu:get_value(annie_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_value(annie_r_best_draw) == 1 then
		AoEDraw()
	end

	if game:is_key_down(menu:get_value(annie_combo_flash_r_auto)) then
		orbwalker:move_to()
		AutoFlash()
	end

	if HasStunPassive(myHero) and Ready(SLOT_Q) then
		orbwalker:disable_auto_attacks()
	else
		orbwalker:enable_auto_attacks()
	end

	AutoE()

	AutoKill()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
