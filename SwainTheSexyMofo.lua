if game.local_player.champ_name ~= "Swain" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.3
		local file_name = "SwainTheSexyMofo.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SwainTheSexyMofo.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SwainTheSexyMofo.lua.version.txt")
        console:log("SwainTheSexyMofo.lua Vers: "..Version)
		console:log("SwainTheSexyMofo.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

            console:log("...Shaun's Sexy Swain Successfully Loaded.....")


        else
			http:download_file(url, file_name)
			      console:log("Sexy swain Update available.....")
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

pred:use_prediction()
arkpred = _G.Prediction

local myHero = game.local_player
local local_player = game.local_player
local KSRActive = false

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 725, delay = .25, width = 725, speed = 0 }
local W = { range = 5500, delay = .25, width = 325, speed = 0 }
local E = { range = 850, delay = .25, width = 170, speed = 0 }
local R = { range = 650, delay = .5, width = 0, speed = 0 }


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

local function HasBuff(unit)
	if unit:has_buff(buffhere) then
		return true
	end
	return false
end

local function SwainRActive(unit)
	if unit:has_buff("SwainR") then
		return true
	end
	return false
end

local function SwainPassiveBuff(unit)
	if unit:has_buff("SwainPassive") then
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

function IsImmobile(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(12) or unit:has_buff_type(30) or unit:has_buff_type(25) or unit:has_buff_type(11) then
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
	if unit:has_buff_type(16) or unit:has_buff_type(18) or unit:has_buff("sionpassivezombie") then
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

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	swain_category = menu:add_category_sprite("Shaun's Sexy Swain", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	swain_category = menu:add_category("Shaun's Sexy Swain")
end

swain_enabled = menu:add_checkbox("Enabled", swain_category, 1)
swain_combokey = menu:add_keybinder("Combo Mode Key", swain_category, 32)
menu:add_label("Shaun's Sexy Swain", swain_category)
menu:add_label("#WheresMyBirdsYouDick..", swain_category)

swain_prediction = menu:add_subcategory("[Pred Selection]", swain_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
swain_pred_useage = menu:add_combobox("[Pred Selection]", swain_prediction, e_table, 1)

swain_ark_pred = menu:add_subcategory("[Ark Pred Settings]", swain_prediction)

swain_ark_pred_q = menu:add_subcategory("[Q] Settings", swain_ark_pred, 1)
swain_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", swain_ark_pred_q, 1, 99, 50)

swain_ark_pred_w = menu:add_subcategory("[W] Settings", swain_ark_pred, 1)
swain_w_hitchance = menu:add_slider("[W] Hit Chance [%]", swain_ark_pred_w, 1, 99, 50)

swain_ark_pred_e = menu:add_subcategory("[E] Settings", swain_ark_pred, 1)
swain_e_hitchance = menu:add_slider("[E] Hit Chance [%]", swain_ark_pred_e, 1, 99, 50)

swain_ks_function = menu:add_subcategory("[Kill Steal]", swain_category)
swain_ks_use_q = menu:add_checkbox("Use [Q]", swain_ks_function, 1)
swain_ks_use_w = menu:add_checkbox("Use [W]", swain_ks_function, 1)
swain_ks_use_e = menu:add_checkbox("Use [E]", swain_ks_function, 1)
swain_ks_use_r = menu:add_checkbox("Use [R]", swain_ks_function, 1)
swain_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Whitelist", swain_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), swain_ks_r_blacklist, 1)
    end
end

swain_combo = menu:add_subcategory("[Combo]", swain_category)
swain_combo_q = menu:add_subcategory("[Q] Settings", swain_combo)
swain_combo_use_q = menu:add_checkbox("Use [Q]", swain_combo_q, 1)
swain_combo_w = menu:add_subcategory("[W] Settings", swain_combo)
swain_combo_use_w = menu:add_checkbox("Use [W]", swain_combo_w, 1)
swain_combo_use_w_imb = menu:add_checkbox("Use [W] Only When Target Is Immobilised", swain_combo_w, 1)
swain_combo_w_range = menu:add_slider("Max [W] Range In Combo", swain_combo_w, 1, 5000, 2000)
swain_combo_e = menu:add_subcategory("[E] Settings", swain_combo)
swain_combo_use_e = menu:add_checkbox("Use [E]", swain_combo_e, 1)
swain_combo_e_range = menu:add_slider("Max [E] Range In Combo", swain_combo_e, 1, 850, 850)
swain_combo_r = menu:add_subcategory("[R] Combo Settings", swain_combo)
swain_combo_use_r = menu:add_checkbox("Use [R]", swain_combo_r, 1)
swain_combo_r_enemy_hp = menu:add_slider("Combo [R] if Enemy HP is lower than [%]", swain_combo_r, 1, 100, 30)
swain_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Whitelist", swain_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), swain_combo_r_blacklist, 1)
    end
end

swain_harass = menu:add_subcategory("[Harass]", swain_category)
swain_harass_use_q = menu:add_checkbox("Use [Q]", swain_harass, 1)
swain_harass_use_e = menu:add_checkbox("Use [E]", swain_harass, 1)
swain_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", swain_harass, 1, 100, 20)

swain_autmated_features = menu:add_subcategory("[Automated Features]", swain_category)
swain_auto_passive = menu:add_checkbox("Auto [Passive] Usage", swain_autmated_features, 1)
swain_extra_w = menu:add_subcategory("Auto [W] Settings", swain_autmated_features)
swain_auto_w = menu:add_checkbox("Auto [W] Immobilised Targets", swain_extra_w, 1)
swain_extra_e = menu:add_subcategory("Auto [E] Settings", swain_autmated_features)
swain_auto_gapclose = menu:add_checkbox("[E] Anti Gap Close", swain_extra_e, 1)
swain_auto_interrupt = menu:add_checkbox("[E] Interrupt Major Channel Spells", swain_extra_e, 1)
swain_auto_r = menu:add_subcategory("Auto [R] Settings", swain_autmated_features, 1)
swain_auto_r_use = menu:add_checkbox("Use Auto [R]", swain_auto_r, 1)
swain_auto_r_min = menu:add_slider("Minimum Targets To Perform Auto [R]", swain_auto_r, 1, 5, 3)

swain_laneclear = menu:add_subcategory("[Lane Clear]", swain_category)
swain_laneclear_use_q = menu:add_checkbox("Use [Q]", swain_laneclear, 1)
swain_laneclear_use_w = menu:add_checkbox("Use [W]", swain_laneclear, 1)
swain_laneclear_use_e = menu:add_checkbox("Use [E]", swain_laneclear, 1)
swain_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", swain_laneclear, 1, 100, 20)
swain_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", swain_laneclear, 1, 10, 3)
swain_laneclear_w_min = menu:add_slider("Number Of Minions To Use [W]", swain_laneclear, 1, 10, 3)
swain_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", swain_laneclear, 1, 10, 3)

swain_jungleclear = menu:add_subcategory("[Jungle Clear]", swain_category)
swain_jungleclear_use_q = menu:add_checkbox("Use [Q]", swain_jungleclear, 1)
swain_jungleclear_use_w = menu:add_checkbox("Use [W]", swain_jungleclear, 1)
swain_jungleclear_use_e = menu:add_checkbox("Use [E]", swain_jungleclear, 1)
swain_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", swain_jungleclear, 1, 100, 20)

swain_draw = menu:add_subcategory("[Drawing Features]", swain_category)
swain_draw_q = menu:add_checkbox("Draw [Q] Range", swain_draw, 1)
swain_draw_w = menu:add_checkbox("Draw Max [W] Range", swain_draw, 1)
swain_draw_e = menu:add_checkbox("Draw [E] Range", swain_draw, 1)
swain_draw_r = menu:add_checkbox("Draw [R] Range", swain_draw, 1)
swain_draw_w_mm = menu:add_checkbox("Draw MiniMap Max [W] Range", swain_draw, 1)
swain_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", swain_draw, 1)
swain_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", swain_draw, 1, "Health Bar Damage Is Computed From R > E > Q > W")


local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({55, 75, 95, 115, 135})[level] + 0.4 * myHero.ability_power
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
  local WDamage = ({80, 120, 160, 200, 240})[level] + 0.7 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_W).level
  local BonusDmg = 0
  local WDamage = ({35, 70, 105, 140, 175})[level] + 0.25 * myHero.ability_power
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
  local RDamage = ({200, 300, 400})[level] + 1 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = RDamage - 10
  else
			Damage = RDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local Q_input = {
    source = myHero,
		speed = math.huge, range = 715,
    delay = 0.25, angle = 40,
    collision = {},
    type = "conic", hitbox = false
}

local W_input = {
    source = myHero,
		speed = math.huge, range = 5000,
		delay = 0.25, radius = 325,
    collision = {},
    type = "circular", hitbox = false
}

local E_input = {
    source = myHero,
		speed = 935, range = 835,
		delay = 0.25, radius = 85,
    collision = {},
  type = "linear", hitbox = true
}

-- Casting

local function PassiveCast(unit)
	orbwalker:attack_target(unit)
end

local function CastQ(unit)

	if menu:get_value(swain_pred_useage) == 0 then
		pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	  if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	  end
	end

	if menu:get_value(swain_pred_useage) == 1 then
		local output = arkpred:get_prediction(Q_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(swain_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
		end
	end
end

local function CastW(unit)

	if menu:get_value(swain_pred_useage) == 0 then
		pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(swain_pred_useage) == 1 then
		local output = arkpred:get_prediction(W_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(swain_w_hitchance) / 100 and inv < (W_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		end
	end
end

local function CastE(unit)

	if menu:get_value(swain_pred_useage) == 0 then
	  pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
	  if pred_output.can_cast then
	    castPos = pred_output.cast_pos
	    spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
	  end
	end

	if menu:get_value(swain_pred_useage) == 1 then
		local output = arkpred:get_prediction(E_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(swain_e_hitchance) / 100 and inv < (E_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_E, E.delay, p.x, p.y, p.z)
		end
	end
end

local function CastR()
	spellbook:cast_spell_targetted(SLOT_R, myHero, R.delay)
end

-- Combo

local function Combo()

	target = selector:find_target(E.range, mode_health)
	qtarget = selector:find_target(Q.range, mode_health)

	if menu:get_value(swain_combo_use_r) == 1 then
		if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if target:health_percentage() <= menu:get_value(swain_combo_r_enemy_hp) then
				if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
					if Ready(SLOT_R) and not SwainRActive(myHero) then
						CastR()
					end
				end
			end
		end
	end

	if menu:get_value(swain_combo_use_q) == 1 then
		if myHero:distance_to(qtarget.origin) <= Q.range and IsValid(qtarget) and IsKillable(qtarget) then
			if Ready(SLOT_Q) then
				CastQ(qtarget)
			end
		end
	end

	if menu:get_value(swain_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= menu:get_value(swain_combo_w_range) and IsValid(target) and IsKillable(target) then
      if menu:get_value(swain_combo_use_w_imb) == 1 and IsImmobile(target) and Ready(SLOT_W) then
				CastW(target)
			end
		end
	end

	if menu:get_value(swain_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= menu:get_value(swain_combo_w_range) and IsValid(target) and IsKillable(target) then
      if menu:get_value(swain_combo_use_w_imb) == 0 and Ready(SLOT_W) then
				CastW(target)
			end
		end
	end

  if menu:get_value(swain_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= menu:get_value(swain_combo_e_range) and IsKillable(target) and IsValid(target) then
			if Ready(SLOT_E) then
				CastE(target)
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(E.range, mode_health)
	qtarget = selector:find_target(Q.range, mode_health)
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(swain_harass_min_mana) / 100

	if menu:get_value(swain_harass_use_q) == 1 then
		if myHero:distance_to(qtarget.origin) <= Q.range and IsValid(qtarget) and IsKillable(qtarget) then
			if GrabHarassMana and Ready(SLOT_Q) then
				CastQ(qtarget)
			end
		end
	end


	if menu:get_value(swain_harass_use_e) == 1 then
		if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
			if GrabHarassMana and Ready(SLOT_E) then
				CastE(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(swain_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(swain_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

    if target.object_id ~= 0 and myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(swain_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(swain_ks_use_r) == 1 then
        if GetRDmg(target) > target.health then
				  if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 and Ready(SLOT_R) and not SwainRActive(myHero) then
					  CastR()
          end
			  end
		  end
    end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(swain_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(swain_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, target) >= menu:get_value(swain_laneclear_q_min) then
					if GrabLaneClearMana and Ready(SLOT_Q) then
						pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
					  if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end

		if menu:get_value(swain_laneclear_use_w) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < E.range then
				if GetMinionCount(W.range, target) >= menu:get_value(swain_laneclear_w_min) then
					if GrabLaneClearMana and Ready(SLOT_W) then
						pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)
						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end

		if menu:get_value(swain_laneclear_use_e) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < E.range then
				if GetMinionCount(E.range, target) >= menu:get_value(swain_laneclear_e_min) then
					if GrabLaneClearMana and Ready(SLOT_E) then
						pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, false)
					  if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(swain_laneclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(swain_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_Q) then
					pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
				  if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(swain_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < E.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_W) then
					pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)
					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(swain_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < E.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_E) then
					pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, false)
				  if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Auto R >= Targets

local function AutoR()
  if Ready(SLOT_R) and menu:get_value(swain_auto_r_use) == 1 then
    if GetEnemyCountCicular(R.range, myHero.origin) >= menu:get_value(swain_auto_r_min) and not SwainRActive(myHero) then
      CastR()
    end
  end
end

-- Auto W

local function AutoW()
  target = selector:find_target(W.range, mode_health)

  if Ready(SLOT_W) and menu:get_value(swain_auto_w) == 1 then
    if IsImmobile(target) and myHero:distance_to(target.origin) < W.range then
      CastW(target)
    end
  end
end

-- Auto R Interrupt

local function on_possible_interrupt(obj, spell_name)
	if menu:get_value(swain_auto_interrupt) == 1 then
    if IsValid(obj) then
      if myHero:distance_to(obj.origin) < E.range and Ready(SLOT_E) then
        CastE(obj)
			end
		end
	end
end

-- Auto Passive AA

local function AutoPassive()

	target = selector:find_target(1300, mode_health)

	if menu:get_value(swain_auto_passive) == 1 then
		if SwainPassiveBuff(myHero) then
			if myHero:distance_to(target.origin) <= 1100 then
				if IsImmobile(target) and IsValid(target) and IsKillable(target) then
					PassiveCast(target)
				end
			end
		end
	end
end

-- Gap Close

local function on_gap_close(obj, data)

	if menu:get_value(swain_auto_gapclose) == 1 then
    if IsValid(obj) then
      if myHero:distance_to(obj.origin) < E.range and Ready(SLOT_E) then
        CastE(obj)
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
	end

	if menu:get_value(swain_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(swain_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(swain_draw_w_mm) == 1 then
		if Ready(SLOT_W) then
			minimap:draw_circle(x, y, z, W.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(swain_draw_e) == 1 then
		if Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(swain_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetEDmg(target)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
			if menu:get_value(swain_draw_kill) == 1 then
				if fulldmg > target.health and IsValid(target) then
					if enemydraw.is_valid and target.is_on_screen then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(swain_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(swain_combokey)) and menu:get_value(swain_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	AutoW()
  AutoR()
	AutoKill()

	if not game:is_key_down(menu:get_value(swain_combokey)) then
		AutoPassive()
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
