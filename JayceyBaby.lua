if game.local_player.champ_name ~= "Jayce" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.5
		local file_name = "JayceyBaby.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/JayceyBaby.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/JayceyBaby.lua.version.txt")
        console:log("JayceyBaby.lua Vers: "..Version)
		console:log("JayceyBaby.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Shaun's Sexy Jayce Successfully Loaded.....")


        else
			http:download_file(url, file_name)
			      console:log("Sexy Jayce Update available.....")
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
	--console:log(tostring(user))
	table.insert(LIST, user)
end

local USER = client.username
local function VIP_USER_LIST()
	for _, value in pairs(LIST) do
		--console:log(tostring(value))
		if string.find(tostring(value), USER) then
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

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark223 Prediction Library Downloaded")
   console:log("Please Reload with F5")
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
end

pred:use_prediction()
arkpred = _G.Prediction
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local QCanFire = false
local AutoQCanFire = false
local Qcast = false


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local RangedQ1 = { range = 1150, speed = 1300, delay = 0.1515, width = 160	}
local RangedQ2 = { range = 1750, speed = 2350, delay = 0.1515, width = 250	}
local HammerQ = { range = 600, speed = 0, delay = 0.250, width = 0	}
local RangedW = { range = 500, speed = 0, delay = 0.250, Width = 0	}
local HammerW = { range = 350, speed = 0, delay = 0.264, width = 0	}
local RangedE = { range = 100, speed = 0, delay = 0.100, width = 120	}
local HammerE = { range = 240, speed = 0, delay = 0.250, width = 80	}

local Q1_input = {
    source = myHero,
    speed = 1300, range = 1150,
    delay = 0.25, radius = 80,
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

local Q2_input = {
    source = myHero,
    speed = 2350, range = 1750,
    delay = 0.25, radius = 125,
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}


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

--Add two vectors
function Add(vec1, vec2)
    new_x = vec1.x + vec2.x
    new_y = vec1.y + vec2.y
    new_z = vec1.z + vec2.z
    add = vec3.new(new_x, new_y, new_z)
    return add
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

function Direction(vec)
    output = vec:normalized()
    return output
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
		if unit.object_id ~= 0 and IsValid(unit) and Dist < RangedQ2.range then
			local CastPos, targets = GetBestAoEPosition(RangedQ2.speed, RangedQ2.delay, RangedQ2.range, RangedQ2.width, unit, true, true)
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

local function HyperChargeCheck(unit)
	if unit:has_buff("JayceHyperCharge") then
		return true
	end
	return false
end

local function StaticFieldCheck(unit)
	if unit:has_buff("JayceStaticField") then
		return true
	end
	return false
end

local function IsRangedForm()
Range = spellbook:get_spell_slot(SLOT_Q)
QData = Range.spell_data
QName = QData.spell_name
if QName == "JayceShockBlast" then
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

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	jayce_category = menu:add_category_sprite("Shaun's Sexy Jayce", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	jayce_category = menu:add_category("Shaun's Sexy Jayce")
end

jayce_enabled = menu:add_checkbox("Enabled", jayce_category, 1)
jayce_combokey = menu:add_keybinder("Combo Mode Key", jayce_category, 32)
menu:add_label("Shaun's Sexy Jayce", jayce_category)
menu:add_label("#HeyWheresMyGateGone", jayce_category)

jayce_prediction = menu:add_subcategory("[Pred Selection]", jayce_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
jayce_pred_useage = menu:add_combobox("[Pred Selection]", jayce_prediction, e_table, 1)

jayce_ark_pred = menu:add_subcategory("[Ark Pred Settings]", jayce_prediction)
jayce_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", jayce_ark_pred, 1, 99, 50)

jayce_ks_function = menu:add_subcategory("[Kill Steal]", jayce_category)
jayce_ks_use_q = menu:add_checkbox("Use Ranged [EQ]", jayce_ks_function, 1)
jayce_ks_use_hammer_q = menu:add_checkbox("Use Hammer [Q]", jayce_ks_function, 1)
jayce_ks_use_hammer_e = menu:add_checkbox("Use Hammer [E]", jayce_ks_function, 1)

jayce_combo = menu:add_subcategory("[Combo]", jayce_category)
jayce_combo_ranged = menu:add_subcategory("[Ranged Combo]", jayce_combo)
jayce_combo_use_ranged_q = menu:add_checkbox("Use Range [Q]", jayce_combo_ranged, 1)
jayce_combo_use_ranged_w = menu:add_checkbox("Use Ranged [W]", jayce_combo_ranged, 1)
jayce_combo_use_ranged_e = menu:add_checkbox("Use Ranged [E]", jayce_combo_ranged, 1)
jayce_combo_hammer = menu:add_subcategory("[Hammer Combo]", jayce_combo)
jayce_combo_use_hammer_q = menu:add_checkbox("Use Hammer [Q]", jayce_combo_hammer, 1)
jayce_combo_use_hammer_w = menu:add_checkbox("Use Hammer [W]", jayce_combo_hammer, 1)
jayce_combo_use_hammer_e = menu:add_checkbox("Use Hammer [E]", jayce_combo_hammer, 1)
jayce_combo_use_e_ehp = menu:add_slider("Target HP Greater Then [%] To Use Hammer [E]", jayce_combo_hammer, 1, 100, 60)
jayce_combo_use_e_hp = menu:add_slider("Jayce HP Lower Then [%] To Use Hammer [E]", jayce_combo_hammer, 1, 100, 25)
jayce_combo_r_set = menu:add_subcategory("[R] Combo Settings", jayce_combo)
jayce_combo_use_r_auto = menu:add_checkbox("Combo [R] Smart Auto Switch On Cool Downs + Distance", jayce_combo_r_set, 1)


jayce_harass = menu:add_subcategory("[Harass]", jayce_category)
jayce_harass_ranged = menu:add_subcategory("Ranged Harass", jayce_harass)
jayce_harass_use_ranged_q = menu:add_checkbox("Use Ranged [Q]", jayce_harass_ranged, 1)
jayce_harass_use_ranged_e = menu:add_checkbox("Use Ranged [E]", jayce_harass_ranged, 1)
jayce_harass_hammer = menu:add_subcategory("Hammer Harras", jayce_harass)
jayce_harass_use_hammer_q = menu:add_checkbox("Use Hammer [Q]", jayce_harass_hammer, 1)
jayce_harass_use_hammer_e = menu:add_checkbox("Use Hammer [E]", jayce_harass_hammer, 1)
jayce_harass_min_mana = menu:add_slider("Minimum Mana To Harass", jayce_harass, 1, 500, 100)

jayce_extra = menu:add_subcategory("Auto [EQ] Settings", jayce_category)
jayce_auto_e = menu:add_checkbox("Auto [E] When You Manually [Q] In Any Direction", jayce_extra, 1)
jayce_eq_set_key = menu:add_keybinder("Semi Manual Ranged [EQ] Key - Closest To Cursor Target", jayce_extra, 65)
jayce_eq_auto = menu:add_checkbox("Auto Ranged [EQ] - Using Best Prediction For Max Damage", jayce_extra, 1)
jayce_eq_auto_min = menu:add_slider("Minimum Targets To Auto Ranged [EQ]", jayce_extra, 1, 5, 3)

jayce_extra_junglesteal = menu:add_subcategory("[EQ] Steal Epic Monsters", jayce_category)
jayce_junglesteal = menu:add_checkbox("Steal Epic Monsters - Hold Lane Clear Key", jayce_extra_junglesteal, 1)

jayce_extra_e = menu:add_subcategory("Auto [E] Settings", jayce_category)
jayce_e_interrupt = menu:add_checkbox("[E] Hammer To Interrupt Channel Spells", jayce_extra_e, 1)
jayce_e_gapclose = menu:add_checkbox("[E] Hammer To Anti Gapclose Targets", jayce_extra_e, 1)


--[[jayce_laneclear = menu:add_subcategory("Lane Clear", jayce_category)
jayce_laneclear_ranged = menu:add_subcategory("Ranged Lane Clear", jayce_laneclear)
jayce_laneclear_use_range_q = menu:add_checkbox("Use Ranged Q", jayce_laneclear_ranged, 1)
jayce_laneclear_use_ranged_w = menu:add_checkbox("Use Ranged W", jayce_laneclear_ranged, 1)
jayce_laneclear_ranged_q_min = menu:add_slider("Number Of Minions To Use Range Q", jayce_laneclear_ranged, 1, 10, 3)
jayce_laneclear_hammer = menu:add_subcategory("Hammer Lane Clear", jayce_laneclear)
jayce_laneclear_use_hammer_q = menu:add_checkbox("Use Hammer Q", jayce_laneclear_hammer, 1)
jayce_laneclear_hammer_q_min = menu:add_slider("Number Of Minions To Use Hammer Q", jayce_laneclear_hammer, 1, 10, 3)
jayce_laneclear_min_mana = menu:add_slider("Minimum Mana To Lane Clear", jayce_laneclear, 1, 500, 100)

jayce_jungleclear = menu:add_subcategory("Jungle Clear", jayce_category)
jayce_jungleclear_ranged = menu:add_subcategory("Ranged Jungle Clear", jayce_jungleclear)
jayce_jungleclear_use_range_q = menu:add_checkbox("Use Ranged Q", jayce_jungleclear_ranged, 1)
jayce_jungleclear_use_ranged_w = menu:add_checkbox("Use Ranged W", jayce_jungleclear_ranged, 1)
jayce_jungleclear_ranged_q_min = menu:add_slider("Number Of Minions To Use Range Q", jayce_jungleclear, 1, 10, 3)
jayce_jungleclear_hammer = menu:add_subcategory("Hammer Jungle Clear", jayce_jungleclear)
jayce_jungleclear_use_hammer_q = menu:add_checkbox("Use Hammer Q", jayce_jungleclear_hammer, 1)
jayce_jungleclear_hammer_q_min = menu:add_slider("Number Of Minions To Use Hammer Q", jayce_jungleclear_hammer, 1, 10, 3)
jayce_jungleclear_min_mana = menu:add_slider("Minimum Mana To Jungle Clear", jayce_laneclear, 1, 500, 100)]]

jayce_draw = menu:add_subcategory("[Drawing] Features", jayce_category)
jayce_draw_q = menu:add_checkbox("Draw Normal [Q] Range", jayce_draw, 1)
jayce_draw_eq = menu:add_checkbox("Draw [EQ] Range", jayce_draw, 1)
jayce_draw_hammer_q = menu:add_checkbox("Draw [Q] Hammer Range", jayce_draw, 1)
jayce_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", jayce_draw, 1)
jayce_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", jayce_draw, 1, "Health Bar Damage Is Computed From R > Q > W")


local function GetQHammerDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({55, 95, 135, 175, 215, 255})[level] + 1.2 * myHero.bonus_attack_damage
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetQRangeDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({77, 154, 231, 308, 385, 462})[level] + 1.68 * myHero.bonus_attack_damage
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_phys_damage(Damage)
end


local function GetEQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({55, 110, 165, 220, 275, 330})[level] + 1.2 * myHero.bonus_attack_damage
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
  local BonusDmg = 0
  local WDamage = ({25, 40, 55, 70, 85, 100})[level] + 0.25 * myHero.ability_power
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
  local BonusDmg = 0
  local EDamage = (({8, 10.4, 12.8, 15.2, 17.6, 20})[level] / 100) * unit.max_health + myHero.bonus_attack_damage

  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_phys_damage(Damage)
end

-- Casting

local function CastQ(unit)

	if menu:get_value(jayce_pred_useage) == 0 then
		pred_output = pred:predict(RangedQ1.speed, RangedQ1.delay, RangedQ1.range, RangedQ1.width, unit, true, true)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, RangedQ1.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(jayce_pred_useage) == 1 then
		local output = arkpred:get_prediction(Q1_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(jayce_q_hitchance) / 100 and inv < (Q1_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, RangedQ1.delay, p.x, p.y, p.z)
		end
	end
end

local function CastEQ(unit)

	if menu:get_value(jayce_pred_useage) == 0 then
		pred_output = pred:predict(RangedQ2.speed, RangedQ2.delay, RangedQ2.range, RangedQ2.width, unit, true, true)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, RangedQ2.delay, castPos.x, castPos.y, castPos.z)
			QCanFire = true
		end
	end

	if menu:get_value(jayce_pred_useage) == 1 then
		local output = arkpred:get_prediction(Q2_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(jayce_q_hitchance) / 100 and inv < (Q2_input.delay / 2) then
			local p = output.cast_pos
		  spellbook:cast_spell(SLOT_Q, RangedQ2.delay, p.x, p.y, p.z)
			QCanFire = true
		end
	end
end

local function HammerCastQ(unit)
	spellbook:cast_spell_targetted(SLOT_Q, unit, HammerQ.delay)
end

local function CastRangedW(unit)
	spellbook:cast_spell_targetted(SLOT_W, unit, RangedW.delay)
end

local function CastHammerdW()
	spellbook:cast_spell_targetted(SLOT_W, myHero, HammerW.delay)
end

local function CastERanged(unit)
	if QCanFire then
		Direction = Sub(unit.origin, myHero.origin):normalized()
		Position = VectorMag(Direction, 200)
		GatePos = Add(Position, myHero.origin)
		spellbook:cast_spell(SLOT_E, RangedE.delay, GatePos.x, GatePos.y, GatePos.z)
	end
end

local function CastEMouse()
	local mouse = game.mouse_pos
	spellbook:cast_spell(SLOT_E, RangedE.delay, mouse.x, mouse.y, mouse.z)
	Qcast = false
end

local function CastHammerE(unit)

	spellbook:cast_spell_targetted(SLOT_E, unit, HammerE.delay)
end

local function CastR()
	spellbook:cast_spell_targetted(SLOT_R, myHero, 0.1)
end

-- Combo

local function Combo()


	if IsRangedForm() then

		if Ready(SLOT_E) then
			target = selector:find_target(RangedQ2.range, mode_health)
		end

		if not Ready(SLOT_E) then
			target = selector:find_target(RangedQ1.range, mode_health)
		end

		if menu:get_value(jayce_combo_use_ranged_q) == 1 and menu:get_value(jayce_combo_use_ranged_e) == 0 then
		elseif menu:get_value(jayce_combo_use_ranged_q) == 1 and not Ready(SLOT_E) then
			if myHero:distance_to(target.origin) <= RangedQ1.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(jayce_combo_use_ranged_q) == 1 and menu:get_value(jayce_combo_use_ranged_e) == 1 then
			if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and Ready(SLOT_E) and QCanFire then
					CastERanged(target)
				end
			end
		end

		if menu:get_value(jayce_combo_use_ranged_q) == 1 and menu:get_value(jayce_combo_use_ranged_e) == 1 then
			if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and Ready(SLOT_E) then
					CastEQ(target)
				end
			end
		end

		if menu:get_value(jayce_combo_use_ranged_w) == 1 then
			if myHero:distance_to(target.origin) <= RangedW.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) then
					CastRangedW(target)
				end
			end
		end
	end

	if not IsRangedForm() then

		if Ready(SLOT_Q) then
			target = selector:find_target(HammerQ.range, mode_health)
		end

		if not Ready(SLOT_Q) then
			target = selector:find_target(HammerW.range, mode_health)
		end

		if menu:get_value(jayce_combo_use_hammer_q) == 1 then
			if myHero:distance_to(target.origin) <= HammerQ.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					HammerCastQ(target)
				end
			end
		end

		if menu:get_value(jayce_combo_use_hammer_w) == 1 then
			if myHero:distance_to(target.origin) <= HammerW.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) then
					CastHammerdW()
				end
			end
		end

		local EnemyHP = target.health/target.max_health >= menu:get_value(jayce_combo_use_e_ehp) / 100
		local MyHP = myHero.health/myHero.max_health <= menu:get_value(jayce_combo_use_e_hp) / 100
		if menu:get_value(jayce_combo_use_hammer_e) == 1 then
			if myHero:distance_to(target.origin) <= HammerE.range and IsValid(target) and IsKillable(target) then
				if EnemyHP and MyHP then
					if Ready(SLOT_E) then
						CastHammerE(target)
					end
				end
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(RangedQ2.range, mode_health)

	if IsRangedForm() and myHero.mana >= menu:get_value(jayce_harass_min_mana) then

		if Ready(SLOT_E) then
			target = selector:find_target(RangedQ2.range, mode_health)
		end

		if not Ready(SLOT_E) then
			target = selector:find_target(RangedQ1.range, mode_health)
		end

		if menu:get_value(jayce_harass_use_ranged_q) == 1 and menu:get_value(jayce_harass_use_ranged_e) == 0 then
		elseif menu:get_value(jayce_harass_use_ranged_q) == 1 and not Ready(SLOT_E) then
			if myHero:distance_to(target.origin) <= RangedQ1.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(jayce_harass_use_ranged_q) == 1 and menu:get_value(jayce_harass_use_ranged_e) == 1 then
			if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and Ready(SLOT_E) and QCanFire then
					CastERanged(target)
				end
			end
		end

		if menu:get_value(jayce_harass_use_ranged_q) == 1 and menu:get_value(jayce_harass_use_ranged_e) == 1 then
			if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and Ready(SLOT_E) then
					CastEQ(target)
				end
			end
		end
	end

	if not IsRangedForm() and myHero.mana >= menu:get_value(jayce_harass_min_mana) then

		if Ready(SLOT_Q) then
			target = selector:find_target(HammerQ.range, mode_health)
		end

		if not Ready(SLOT_Q) then
			target = selector:find_target(HammerW.range, mode_health)
		end

		if menu:get_value(jayce_harass_use_hammer_q) == 1 then
			if myHero:distance_to(target.origin) <= HammerQ.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					HammerCastQ(target)
				end
			end
		end

		if menu:get_value(jayce_harass_use_hammer_e) == 1 then
			if myHero:distance_to(target.origin) <= HammerE.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_E) then
					CastHammerE(target)
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if IsRangedForm() then

			if menu:get_value(jayce_ks_use_q) == 1 then
				if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_Q) and Ready(SLOT_E) and QCanFire then
						if GetQRangeDmg(target) > target.health then
							if QCanFire then
								Direction = Sub(target.origin, myHero.origin):normalized()
								Position = VectorMag(Direction, 200)
								GatePos = Add(Position, myHero.origin)
								spellbook:cast_spell(SLOT_E, RangedE.delay, GatePos.x, GatePos.y, GatePos.z)
							end
						end
					end
				end
			end

			if menu:get_value(jayce_ks_use_q) == 1 then
				if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
					if GetQRangeDmg(target) > target.health then
						if Ready(SLOT_Q) and Ready(SLOT_E) then
							pred_output = pred:predict(RangedQ2.speed, RangedQ2.delay, RangedQ2.range, RangedQ2.width, target, true, true)
							if pred_output.can_cast then
								castPos = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, RangedQ2.delay, castPos.x, castPos.y, castPos.z)
								QCanFire = true
							end
						end
					end
				end
			end
		end

		if not IsRangedForm() then

			if menu:get_value(jayce_ks_use_hammer_q) == 1 then
				if myHero:distance_to(target.origin) <= HammerQ.range and IsValid(target) and IsKillable(target) then
					if GetQHammerDmg(target) > target.health then
						if Ready(SLOT_Q) then
							spellbook:cast_spell_targetted(SLOT_Q, target, HammerQ.delay)
						end
					end
				end
			end

			if menu:get_value(jayce_ks_use_hammer_e) == 1 then
				if myHero:distance_to(target.origin) <= HammerE.range and IsValid(target) and IsKillable(target) then
					if GetEDmg(target) > target.health then
						if Ready(SLOT_E) then
							spellbook:cast_spell_targetted(SLOT_E, target, HammerE.delay)
						end
					end
				end
			end
		end
	end
end

-- Lane Clear

--[[local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(jayce_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, target) and GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						spellbook:cast_spell_targetted(SLOT_Q, target, Q.delay)
					end
				end
			end
		end

		if menu:get_value(jayce_laneclear_use_w) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if GetMinionCount(W.range, target) >= menu:get_value(jayce_laneclear_w_min) and not IsUnderTurret(myHero) then
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
end]]


-- Jungle Clear

local function JungleSteal()

	if IsRangedForm() then
		minions = game.jungle_minions
		for i, target in ipairs(minions) do

			if menu:get_value(jayce_junglesteal) == 1 then
				if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_Q) and Ready(SLOT_E) and QCanFire and EpicMonster(target) then
						if GetQRangeDmg(target) > target.health then
							if QCanFire then
								Direction = Sub(target.origin, myHero.origin):normalized()
								Position = VectorMag(Direction, 200)
								GatePos = Add(Position, myHero.origin)
								spellbook:cast_spell(SLOT_E, RangedE.delay, GatePos.x, GatePos.y, GatePos.z)
							end
						end
					end
				end
			end

			if menu:get_value(jayce_junglesteal) == 1 then
				if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
					if GetQRangeDmg(target) > target.health then
						if Ready(SLOT_Q) and Ready(SLOT_E) and EpicMonster(target) then
							pred_output = pred:predict(RangedQ2.speed, RangedQ2.delay, RangedQ2.range, RangedQ2.width, target, false, false)
							if pred_output.can_cast then
								castPos = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, RangedQ2.delay, castPos.x, castPos.y, castPos.z)
								QCanFire = true
							end
						end
					end
				end
			end
		end
	end
end

-- Auto EQ --

local function AutoEQ()

	if menu:get_value(jayce_eq_auto) == 1 then
		for _, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= RangedQ2.range then
				if IsRangedForm() then
					local CastPos, targets = GetBestAoEPosition(RangedQ2.speed, RangedQ2.delay, RangedQ2.range, RangedQ2.width, unit, true, true)
					if CastPos and targets >= menu:get_value(jayce_eq_auto_min) then
						if Ready(SLOT_Q) and not Ready(SLOT_E) and AutoQCanFire then
							spellbook:cast_spell(SLOT_Q, RangedQ2.delay, CastPos.x, CastPos.y, CastPos.z)

						end
						if Ready(SLOT_Q) and Ready(SLOT_E) then
							Direction = Sub(unit.origin, myHero.origin):normalized()
							Position = VectorMag(Direction, 200)
							GatePos = Add(Position, myHero.origin)
							spellbook:cast_spell(SLOT_E, RangedE.delay, GatePos.x, GatePos.y, GatePos.z)
							AutoQCanFire = true
						end
					end
				end
			end
		end
	end
end

-- Manual EQ Cast

local function ManualEQCast()
	target = selector:find_target(RangedQ2.range, mode_cursor)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) and IsKillable(target) then
			if IsRangedForm() then

				if menu:get_value(jayce_combo_use_ranged_q) == 1 and menu:get_value(jayce_combo_use_ranged_e) == 1 then
					if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_Q) and Ready(SLOT_E) and QCanFire then
							CastERanged(target)
						end
					end
				end

				if menu:get_value(jayce_combo_use_ranged_q) == 1 and menu:get_value(jayce_combo_use_ranged_e) == 1 then
					if myHero:distance_to(target.origin) <= RangedQ2.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_Q) and Ready(SLOT_E) then
							CastEQ(target)
						end
					end
				end
			end
		end
	end
end

-- Auto Hammer E Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(jayce_e_interrupt) == 1 and not IsRangedForm() then
      if myHero:distance_to(obj.origin) < HammerE.range and Ready(SLOT_E) then
        CastHammerE(obj)
			end
		end
	end
end

-- Auto Hammer E Gap

local function on_dash(obj, dash_info)

	if menu:get_value(jayce_e_gapclose) == 1 and not IsRangedForm() then
		if IsValid(obj) then
			if myHero:distance_to(dash_info.end_pos) < HammerE.range and myHero:distance_to(obj.origin) < HammerE.range and Ready(SLOT_E) then
				CastHammerE(obj)
			end
		end
	end
end

local function QManualThenE()

	if menu:get_value(jayce_auto_e) == 1 then
		if Ready(SLOT_Q) and Ready(SLOT_E) then
			if IsRangedForm() then
			 	if Qcast then
				 	CastEMouse()
			 	end
			end
		end
	end
end

-- Auto R --

local function AutoR()

	if menu:get_value(jayce_combo_use_r_auto) == 1 then

		if IsRangedForm() then

			target = selector:find_target(RangedQ2.range, mode_distance)


			if not HyperChargeCheck(myHero) then
				if not Ready(SLOT_Q) and not Ready(SLOT_W) and not Ready(SLOT_E) then
					if Ready(SLOT_R) then
						if myHero:distance_to(target.origin) <= HammerQ.range then
							CastR()
						end
					end
				end
			end
		end

		if not IsRangedForm() then

			target = selector:find_target(RangedQ2.range, mode_distance)

			if myHero:distance_to(target.origin) >= HammerW.range then
				if not Ready(SLOT_Q) then
					if Ready(SLOT_R) then
						if myHero:distance_to(target.origin) >= myHero.attack_range then
							CastR()
						end
					end
				end
			end
		end
	end
end

local function on_active_spell(obj, active_spell)

	if Is_Me(obj) then
		if active_spell.spell_name == "JayceShockBlast" then
			Qcast = true
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

	if IsRangedForm() then

		if menu:get_value(jayce_draw_q) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, RangedQ1.range, 255, 255, 255, 255)
			end
		end

		if menu:get_value(jayce_draw_eq) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, RangedQ2.range, 255, 0, 255, 255)
			end
		end

	else

		if menu:get_value(jayce_draw_hammer_q) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, HammerQ.range, 255, 255, 0, 255)
			end
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg =  GetQRangeDmg(target) + GetQHammerDmg(target) + GetEDmg(target)
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= RangedQ2.range then
				if menu:get_value(jayce_draw_kill) == 1 and target.is_on_screen then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(jayce_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local timer, health = 0, 0

local function on_process_spell(unit, args)
    if unit ~= game.local_player or timer >
        args.cast_time - 1 then return end
    timer = args.cast_time
end

local function on_tick()

	for _, unit in ipairs(game.players) do
		if unit.champ_name:find("Practice") then
			if unit.is_valid and unit.is_enemy and
				unit.is_alive and unit.is_visible and health ~=
				unit.health and game.game_time - timer < 1 then
				local delay = game.game_time - timer - 0.0167
				console:log(tostring(delay))
				health = unit.health
			end
		end
	end

	if game:is_key_down(menu:get_value(jayce_combokey)) and menu:get_value(jayce_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		JungleSteal()
	end

	if game:is_key_down(menu:get_value(jayce_eq_set_key)) then
		ManualEQCast()
		orbwalker:move_to()
	end

	AutoKill()
	AutoEQ()
	AutoR()

	if not game:is_key_down(menu:get_value(jayce_combokey)) then
		QManualThenE()
	end

	if not Ready(SLOT_Q) and not Ready(SLOT_E) then
		QCanFire = false
		AutoQCanFire = false
		Qcast = false
	end

end

client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_active_spell", on_active_spell)
