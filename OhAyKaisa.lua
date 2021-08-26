if game.local_player.champ_name ~= "Kaisa" then
	return
end

do
    local function AutoUpdate()
		local Version = 3.2
		local file_name = "OhAyKaisa.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/OhAyKaisa.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/OhAyKaisa.lua.version.txt")
        console:log("OhAyKaisa.lua Vers: "..Version)
				console:log("OhAyKaisa.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log(".....Shaun's Sexy Kaisa Successfully Loaded.....")

    else
						http:download_file(url, file_name)
			      console:log("Sexy Kaisa Update available.....")
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

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
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
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local Gapclose_text = false

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local AA = { range = 600 }
local Q = { range = 600, delay = .1, width = 0, speed = 0 }
local W = { range = 3000, delay = .4, width = 200, speed = 1750 }
local E = { range = 0, delay = .1, width = 0, speed = 0 }
local R = { delay = .1, width = 0, speed = 0 }
local rRange = { 1500, 2250, 3000 }

local W_input = {
    source = myHero,
    speed = 1750, range = 3000,
    delay = 0.45, radius = 100,
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

local function GetMinionCountCicular(range, p1)
		count = 0
		minions = game.minions
		for i, minion in ipairs(minions) do
				Range = range * range
        if minion.is_enemy and IsValid(minion) and minion.object_id ~= minion.object_id and GetDistanceSqr(p1, minion.origin) < Range then
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

function HasPassiveCount(unit)
    if unit:has_buff("kaisapassivemarker") then
        buff = unit:get_buff("kaisapassivemarker")
        if buff.count > 0 then
            return buff.count
        end
    end
    return 0
end

local function HasPassiveBuff(unit)
	if unit:has_buff("kaisapassivemarker") then
		return true
	end
	return false
end

local function HasBuff(unit)
	if unit:has_buff("KaisaQEvolved") then
		return true
	end
	return false
end

local function HasEBuff(unit)
	if unit:has_buff("KaisaE") then
		return true
	end
	return false
end


local function CheckQ()
	if HasBuff(myHero) then
		return 9
	else
		return 5
	end
end


local function TargetIsIsolated(range, unit)
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

local function GetGameTime()
	return tonumber(game.game_time)
end

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
		return true
	end
	return false
end

local function IsImmobileTarget(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(11) or unit:has_buff_type(21) or unit:has_buff_type(22) or unit:has_buff_type(24) or unit:has_buff_type(29) then
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

local function GetWDmg(unit)
	local Wdmg = getdmg("W", unit, myHero, 1)
	local W2dmg = getdmg("W", unit, myHero, 2)
	local buff = HasPassiveCount(unit)
	if buff and buff == 4 then
		return (Wdmg+W2dmg)
	else
		return Wdmg
	end
end

local function GetQDmg(unit)
	local count = GetEnemyCount(600, unit)
	local QDmg = getdmg("Q", unit, myHero)
	local QDmg2 = (CheckQ() * (getdmg("Q", unit, myHero)/100*25))
	if count >= 2 then
		return QDmg+(QDmg2/count)
	else
		return QDmg+QDmg2
	end
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	Kai_category = menu:add_category_sprite("Shaun's Sexy Kaisa", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	Kai_category = menu:add_category("Shaun's Sexy Kaisa")
end

Kai_enabled = menu:add_checkbox("Enabled", Kai_category, 1)
Kai_combokey = menu:add_keybinder("Combo Mode Key", Kai_category, 32)
menu:add_label("Shaun's Sexy Kaisa", Kai_category)
menu:add_label("#TheVoidMakesMeTingle", Kai_category)

Kai_prediction = menu:add_subcategory("[Pred Selection]", Kai_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
Kai_pred_useage = menu:add_combobox("[Pred Selection]", Kai_prediction, e_table, 1)

Kai_ark_pred = menu:add_subcategory("[Ark Pred Settings]", Kai_prediction)
Kai_w_hitchance = menu:add_slider("[W] Hit Chance [%]", Kai_ark_pred, 1, 99, 40)

Kai_ks_function = menu:add_subcategory("[Kill Steal]", Kai_category)
Kai_ks_q = menu:add_subcategory("[Q] Settings", Kai_ks_function, 1)
Kai_ks_use_q = menu:add_checkbox("Use [Q]", Kai_ks_q, 1)
Kai_ks_w = menu:add_subcategory("[W] Settings", Kai_ks_function, 1)
Kai_ks_use_w = menu:add_checkbox("Use [W]", Kai_ks_w, 1)
Kai_ks_w_range = menu:add_slider("Max Range [W]", Kai_ks_w, 1, 3000, 2000)
Kai_ks_r = menu:add_subcategory("[R] Smart Settings", Kai_ks_function)
Kai_ks_use_r = menu:add_checkbox("[R] Smart Kill Steal", Kai_ks_r, 1)
Kai_ks_r_blacklist = menu:add_subcategory("[R] Smart Kill Steal Blacklist", Kai_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), Kai_ks_r_blacklist, 1)
    end
end

Kai_combo = menu:add_subcategory("[Combo]", Kai_category)
Kai_combo_q = menu:add_subcategory("[Q] Settings", Kai_combo)
Kai_combo_use_q = menu:add_checkbox("Use [Q]", Kai_combo_q, 1)
Kai_combo_q_iso = menu:add_checkbox("[Q] Isolated Target Only", Kai_combo_q, 0)
Kai_combo_w = menu:add_subcategory("[W] Settings", Kai_combo)
Kai_combo_use_w = menu:add_checkbox("Use [W]", Kai_combo_w, 1)
Kai_combo_use_w_aa = menu:add_checkbox("Only Use [W] Outside AA Range", Kai_combo_w, 1)
Kai_combo_use_w_range = menu:add_slider("Max Range [W]", Kai_combo_w, 1, 3000, 2000)
Kai_combo_use_w_stack = menu:add_slider("Minimum Passive Stacks To Use [W]", Kai_combo_w, 0, 4, 2)
Kai_combo_e = menu:add_subcategory("[E] Settings", Kai_combo)
Kai_combo_use_e = menu:add_checkbox("Use [E]", Kai_combo_e, 1)
Kai_combo_e_aa = menu:add_checkbox("Only Use [E] Outside AA Range", Kai_combo_e, 1)

Kai_harass = menu:add_subcategory("[Harass]", Kai_category)
Kai_harass_q = menu:add_subcategory("[Q] Settings", Kai_harass)
Kai_harass_use_q = menu:add_checkbox("Use [Q]", Kai_harass_q, 1)
Kai_harass_q_iso = menu:add_checkbox("[Q] Isolated Target Only", Kai_harass_q, 1)
Kai_harass_use_auto_q = menu:add_toggle("Toggle Auto Isolated [Q] Harass", 1, Kai_harass_q, 90, true)
Kai_harass_w = menu:add_subcategory("[W] Settings", Kai_harass)
Kai_harass_use_w = menu:add_checkbox("Use [W]", Kai_harass_w, 1)
Kai_harass_use_w_aa = menu:add_checkbox("Only Use [W] Outside AA Range", Kai_harass_w, 1)
Kai_harass_use_w_range = menu:add_slider("Max Range [W]", Kai_harass_w, 1, 3000, 2000)
Kai_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", Kai_harass, 1, 100, 20)

Kai_extra = menu:add_subcategory("[Automated] Features", Kai_category)
Kai_auto_e_gap = menu:add_checkbox("Auto [E] Gap Close", Kai_extra, 1)
Kai_auto_e_toclose = menu:add_checkbox("Auto [E] Escape Short Ranged Targets", Kai_extra, 1)
Kai_auto_w = menu:add_checkbox("Auto [W] Immobilised Target", Kai_extra, 1)

Kai_laneclear = menu:add_subcategory("[Lane Clear]", Kai_category)
Kai_laneclear_use_q = menu:add_checkbox("Use [Q]", Kai_laneclear, 1)
Kai_laneclear_use_e = menu:add_checkbox("Use [E]", Kai_laneclear, 1)
Kai_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", Kai_laneclear, 1, 100, 20)
Kai_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", Kai_laneclear, 1, 10, 3)
Kai_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", Kai_laneclear, 1, 10, 3)

Kai_jungleclear = menu:add_subcategory("[Jungle Clear]", Kai_category)
Kai_jungleclear_use_q = menu:add_checkbox("Use [Q]", Kai_jungleclear, 1)
Kai_jungleclear_use_e = menu:add_checkbox("Use [E]", Kai_jungleclear, 1)
Kai_jungleclear_use_w = menu:add_checkbox("Use [W]", Kai_jungleclear, 1)
Kai_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", Kai_jungleclear, 1, 100, 20)

Kai_draw = menu:add_subcategory("[Drawing] Features", Kai_category)
Kai_draw_q = menu:add_checkbox("Draw [Q] Range", Kai_draw, 1)
Kai_draw_w = menu:add_checkbox("Draw [W] Range", Kai_draw, 1)
Kai_draw_r = menu:add_checkbox("Draw [R] Range", Kai_draw, 1)
Kai_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Harass", Kai_draw, 1)
Kai_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", Kai_draw, 1)
Kai_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", Kai_draw, 1, "Health Bar Damage Is Computed From R > Q > W")


-- Casting

local function CastQ()
	spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
end

local function CastW(unit)

	if menu:get_value(Kai_pred_useage) == 0 then
		pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, true, true)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(Kai_pred_useage) == 1 then
		local output = arkpred:get_prediction(W_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(Kai_w_hitchance) / 100 and inv < 0.2 then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		end
	end
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
end

local function CastR(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

-- Combo

local function Combo()

	target = selector:find_target(Q.range, mode_health)
	wtarget = selector:find_target(W.range, mode_health)


	if menu:get_value(Kai_combo_use_q) == 1 and menu:get_value(Kai_combo_q_iso) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and TargetIsIsolated(Q.range, myHero) == 0 then
				CastQ()
			end
		end
	end

	if menu:get_value(Kai_combo_use_q) == 1 and menu:get_value(Kai_combo_q_iso) == 0 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ()
			end
		end
	end

	if menu:get_value(Kai_combo_use_w) == 1 and menu:get_value(Kai_combo_use_w_aa) == 1 then
		if myHero:distance_to(wtarget.origin) <= menu:get_value(Kai_combo_use_w_range) and IsValid(wtarget) and IsKillable(wtarget) then
			if myHero:distance_to(wtarget.origin) >= myHero.attack_range then
	     	if HasPassiveCount(wtarget) >= menu:get_value(Kai_combo_use_w_stack) and Ready(SLOT_W) then
					CastW(wtarget)
				end
			end
		end
	end

	if menu:get_value(Kai_combo_use_w) == 1 and menu:get_value(Kai_combo_use_w_aa) == 0 then
		if myHero:distance_to(wtarget.origin) <= menu:get_value(Kai_combo_use_w_range) and IsValid(wtarget) and IsKillable(wtarget) then
	     if HasPassiveCount(wtarget) >= menu:get_value(Kai_combo_use_w_stack) and Ready(SLOT_W) then
				CastW(wtarget)
			end
		end
	end

	 if menu:get_value(Kai_combo_use_e) == 1 and menu:get_value(Kai_combo_e_aa) == 1 then
		if myHero:distance_to(target.origin) > Q.range and myHero:distance_to(target.origin) < 1500 and IsKillable(target) and IsValid(target) then
			if Ready(SLOT_E) then
				CastE()
			end
		end
	end

	if menu:get_value(Kai_combo_use_e) == 1 and menu:get_value(Kai_combo_e_aa) == 0 then
		if myHero:distance_to(target.origin) < 1500 and IsKillable(target) and IsValid(target) then
			if Ready(SLOT_E) then
				CastE()
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(W.range, mode_health)
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(Kai_harass_min_mana) / 100


	if menu:get_value(Kai_harass_use_q) == 1 and menu:get_value(Kai_harass_q_iso) == 1 and not menu:get_toggle_state(Kai_harass_use_auto_q) and GrabHarassMana then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and TargetIsIsolated(Q.range, myHero) == 0 then
				CastQ()
			end
		end
	end

	if menu:get_value(Kai_harass_use_q) == 1 and menu:get_value(Kai_harass_q_iso) == 0 and not menu:get_toggle_state(Kai_harass_use_auto_q) and GrabHarassMana then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ()
			end
		end
	end

	if menu:get_value(Kai_harass_use_w) == 1 and menu:get_value(Kai_harass_use_w_aa) == 1 and GrabHarassMana then
		if myHero:distance_to(target.origin) <= menu:get_value(Kai_harass_use_w_range) and IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) >= myHero.attack_range then
	     	if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end

	if menu:get_value(Kai_harass_use_w) == 1 and menu:get_value(Kai_harass_use_w_aa) == 0 and GrabHarassMana then
		if myHero:distance_to(target.origin) <= menu:get_value(Kai_harass_use_w_range) and IsValid(target) and IsKillable(target) then
	     if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end
end

-- Auto Q Harass

local function AutoQHarass()

	target = selector:find_target(Q.range, mode_health)

	if menu:get_toggle_state(Kai_harass_use_auto_q) and menu:get_value(Kai_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and not IsUnderTurret(myHero) and TargetIsIsolated(Q.range, myHero) == 0 then
				CastQ(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if menu:get_value(Kai_ks_use_q) == 1 and Ready(SLOT_Q) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(Kai_ks_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= menu:get_value(Kai_ks_w_range) and IsValid(target) and IsKillable(target) then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		local QWDmg = GetQDmg(target) + GetWDmg(target)

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= rRange[spellbook:get_spell_slot(SLOT_R).level] and IsValid(target) and IsKillable(target) then
			if menu:get_value(Kai_ks_use_r) == 1 then
				if myHero:distance_to(target.origin) > 700 then
					if not IsUnderTurret(target) and HasPassiveBuff(target) then
        		if QWDmg > target.health and GetEnemyCountCicular(1500, target.origin) <= 2 then
				  		if menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
								if Ready(SLOT_R) and spellbook:get_spell_slot(SLOT_Q).can_cast then
									if not HasEBuff(myHero) and Ready(SLOT_E) then
										CastE()
									elseif HasEBuff(myHero) then
					  				CastR(target)
									elseif not Ready(SLOT_E) then
										CastR(target)
									end
								end
							end
						end
          end
			  end
		  end
    end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(Kai_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(Kai_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, myHero) >= menu:get_value(Kai_laneclear_q_min) then
					if GrabLaneClearMana and Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(Kai_laneclear_use_e) == 1 and Ready(SLOT_E) then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < AA.range then
				if GetMinionCount(AA.range, myHero) >= menu:get_value(Kai_laneclear_e_min) then
					if GrabLaneClearMana and Ready(SLOT_E) then
            CastE()
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(Kai_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(Kai_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_Q) then
					CastQ()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(Kai_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < AA.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_E) then
          CastE()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(Kai_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range then
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
	end
end

-- Auto W

local function AutoW()
  target = selector:find_target(W.range, mode_health)

  if Ready(SLOT_W) and menu:get_value(Kai_auto_w) == 1 then
    if IsImmobileTarget(target) and myHero:distance_to(target.origin) < 2000 then
      CastW(target)
    end
  end
end

-- Auto E

local function AutoE()
  target = selector:find_target(W.range, mode_health)

  if Ready(SLOT_E) and menu:get_value(Kai_auto_e_toclose) == 1 then
    if myHero:distance_to(target.origin) < target.attack_range and target.attack_range < 300 then
      CastE()
    end
  end
end

-- Gap Close

local function on_dash(obj, dash_info)

	local justme = myHero.origin
	local medraw = game:world_to_screen(justme.x, justme.y, justme.z)

	if menu:get_value(Kai_auto_e_gap) == 1 and Ready(SLOT_E) then
		if IsValid(obj) and obj.is_enemy then
			if myHero:distance_to(dash_info.end_pos) < myHero.attack_range and myHero:distance_to(obj.origin) < myHero.attack_range then
				CastE()
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()

	screen_size = game.screen_size
	local_player = game.local_player
	target = selector:find_target(2000, mode_health)
	targetvec = target.origin

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(Kai_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(Kai_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(Kai_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, 1000, 255, 0, 255, 255)
		end
	end

	if menu:get_value(Kai_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, rRange[spellbook:get_spell_slot(SLOT_R).level], 255, 0, 0, 255)
			minimap:draw_circle(x, y, z, rRange[spellbook:get_spell_slot(SLOT_R).level], 255, 0, 0, 255)
		end
	end

	if menu:get_value(Kai_auto_q_draw) == 1 then
		if menu:get_value(Kai_harass_use_q) == 1 then
			if menu:get_toggle_state(Kai_harass_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto Isolated [Q] Harass Enabled")
			end
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + (myHero.total_attack_damage * 3)
		if Ready(SLOT_W) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
				if menu:get_value(Kai_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(Kai_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

--local timer, health = 0, 0

--[[local function on_process_spell(unit, args)
    if unit ~= game.local_player or timer >
        args.cast_time - 1 then return end
    timer = args.cast_time
end]]

local function on_tick()

	--[[for _, unit in ipairs(game.players) do
		if unit.champ_name:find("Practice") then
			if unit.is_valid and unit.is_enemy and
				unit.is_alive and unit.is_visible and health ~=
				unit.health and game.game_time - timer < 1 then
				local delay = game.game_time - timer - 0.0167
				console:log(tostring(delay))
				health = unit.health
			end
		end
	end]]

	if game:is_key_down(menu:get_value(Kai_combokey)) and menu:get_value(Kai_enabled) == 1 then
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
  AutoE()
	AutoKill()

	if not game:is_key_down(menu:get_value(Kai_combokey)) then
		AutoQHarass()
	end


end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
