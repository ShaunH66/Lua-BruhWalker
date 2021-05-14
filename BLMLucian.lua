if game.local_player.champ_name ~= "Lucian" then
	return
end

do
    local function AutoUpdate()
		local Version = 1
		local file_name = "BLMLucian.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BLMLucian.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BLMLucian.lua.version.txt")
        console:log("BLMLucian.lua Vers: "..Version)
		console:log("BLMLucian.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".......................................................................................")
						console:log(".......................................................................................")
            console:log("Shaun's Sexy Lucian v1.0 Successfully Loaded")
						console:log("#BLM #BlackLivesMatter #LucianBLMSaviour")
						console:log(".......................................................................................")
						console:log(".......................................................................................")

        else
			http:download_file(url, file_name)
			      console:log("Sexy Lucian Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end

    end

    AutoUpdate()
end

pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local AA = { range = 500 }
local Q = { range = 650, delay = .25, width = 120, speed = math.huge }
local Q2 = { range = 900, delay = .25, width = 120, speed = math.huge }
local W = { range = 1000, delay = .25, width = 110, speed = math.huge }
local E = { range = 425, delay = .25, width = 100, speed = 1350 }
local ES = { range = 200, delay = .25, width = 100, speed = 1350 }
local R = { range = 1200, delay = .1, width = 225, speed = math.huge }

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
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

local function GetLineTargetCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.players
    for _, target in ipairs(players) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and IsValid(target) and target.is_enemy and GetDistanceSqr(myHero, target) < Range then

            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end

local function GetLineMinionCount(source, aimPos, delay, speed, width)
    local Count = 0
		minions = game.minions
		for i, target in ipairs(minions) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and IsValid(target) and target.is_enemy and GetDistanceSqr(myHero, target) < Range then

            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
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

local function HasCount(unit)
    if unit:has_buff(buff) then
        buff = unit:get_buff(buff)
        if buff.count > 0 then
            return buff
        end
    end
    return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end


local function HasPassiveShotsReady(unit)
	if unit:has_buff("LucianPassiveBuff") then
		return true
	end
	return false
end

local function HasRActive(unit)
	if unit:has_buff("LucianR") then
		return true
	end
	return false
end

local function HasBuff(unit)
	if unit:has_buff(buff) then
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

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetQDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Menu Config

lucian_category = menu:add_category("Shaun's Sexy BLM Lucian")
lucian_enabled = menu:add_checkbox("Enabled", lucian_category, 1)
lucian_combokey = menu:add_keybinder("Combo Mode Key", lucian_category, 32)

lucian_ks_function = menu:add_subcategory("Kill Steal", lucian_category)
lucian_ks_q = menu:add_subcategory("[Q] Settings", lucian_ks_function, 1)
lucian_ks_use_q = menu:add_checkbox("Use [Q]", lucian_ks_q, 1)
lucian_ks_w = menu:add_subcategory("[W] Settings", lucian_ks_function, 1)
lucian_ks_use_w = menu:add_checkbox("Use [W]", lucian_ks_w, 1)

lucian_combo = menu:add_subcategory("Combo", lucian_category)

lucian_combo_prioity = menu:add_combobox("Spell Rotation Priority", lucian_combo, s_table, 1)
s_table = {}
s_table[1] = "Q W E"
s_table[2] = "E Q W"

lucian_combo_q = menu:add_subcategory("[Q] Settings", lucian_combo)
lucian_combo_use_q = menu:add_checkbox("Use [Q]", lucian_combo_q, 1)
lucian_combo_w = menu:add_subcategory("[W] Settings", lucian_combo)
lucian_combo_use_w = menu:add_checkbox("Use [W]", lucian_combo_w, 1)
lucian_combo_e = menu:add_subcategory("[E] Settings", lucian_combo)
lucian_combo_use_e = menu:add_checkbox("Use [E]", lucian_combo_e, 1)

lucian_combo_e_useage = menu:add_combobox("Combo [E] Dash Direction", lucian_combo_e, e_table, 1)
e_table = {}
e_table[1] = "To Mouse"
e_table[2] = "To Target"
e_table[3] = "To Side"

lucian_harass = menu:add_subcategory("Harass", lucian_category)
lucian_harass_q = menu:add_subcategory("[Q] Settings", lucian_harass)
lucian_harass_use_q = menu:add_checkbox("Use [Q]", lucian_harass_q, 1)
lucian_harass_use_q_ext = menu:add_checkbox("Use [Q] Extend", lucian_harass_q, 1)
lucian_harass_use_auto_q = menu:add_toggle("Toggle Auto [Q] Harass", 1, lucian_harass_q, 88, true)
lucian_harass_w = menu:add_subcategory("[W] Settings", lucian_harass)
lucian_harass_use_w = menu:add_checkbox("Use [W]", lucian_harass_w, 1)
lucian_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", lucian_harass, 1, 100, 20)

lucian_laneclear = menu:add_subcategory("Lane Clear", lucian_category)
lucian_laneclear_use_q = menu:add_checkbox("Use [Q]", lucian_laneclear, 1)
lucian_laneclear_use_w = menu:add_checkbox("Use [W]", lucian_laneclear, 1)
lucian_laneclear_use_e = menu:add_checkbox("Use [E]", lucian_laneclear, 1)
lucian_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", lucian_laneclear, 1, 100, 20)
lucian_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", lucian_laneclear, 1, 10, 3)
lucian_laneclear_w_min = menu:add_slider("Number Of Minions To Use [W]", lucian_laneclear, 1, 10, 3)
lucian_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", lucian_laneclear, 1, 10, 3)

lucian_jungleclear = menu:add_subcategory("Jungle Clear", lucian_category)
lucian_jungleclear_use_q = menu:add_checkbox("Use [Q]", lucian_jungleclear, 1)
lucian_jungleclear_use_w = menu:add_checkbox("Use [W]", lucian_jungleclear, 1)
lucian_jungleclear_use_e = menu:add_checkbox("Use [E]", lucian_jungleclear, 1)
lucian_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", lucian_jungleclear, 1, 100, 20)

lucian_extra = menu:add_subcategory("BLM Extra Feature", lucian_category)
lucian_extra_gapclose = menu:add_checkbox("Use [E] Evade Enemy Gap Close", lucian_extra, 1)
lucian_extra_semi_r_key = menu:add_keybinder("[R] Semi Manual Key", lucian_extra, 65)

lucian_draw = menu:add_subcategory("The Drawing Features", lucian_category)
lucian_draw_q = menu:add_checkbox("Draw [Q] Range", lucian_draw, 1)
lucian_draw_e = menu:add_checkbox("Draw [E] Range", lucian_draw, 1)
lucian_draw_w = menu:add_checkbox("Draw [W] Range", lucian_draw, 1)
lucian_draw_r = menu:add_checkbox("Draw [R] Range", lucian_draw, 1)
lucian_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Harass", lucian_draw, 1)
lucian_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", lucian_draw, 1)
lucian_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", lucian_draw, 1, "Health Bar Damage Is Computed From R > Q > W")


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
	origin = target.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
	orbwalker:reset_aa()
end

local function CastEMouse()
	local mouse = game.mouse_pos
	spellbook:cast_spell(SLOT_E, E.delay, mouse.x, mouse.y, mouse.z)
	orbwalker:reset_aa()
end

local function CastESide()
	origin = myHero.origin
	x, y, z = origin.x + 425, origin.y, origin.z
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
	orbwalker:reset_aa()
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

	target = selector:find_target(W.range, mode_health)
	local AAQRange = Q.range + AA.range

	if menu:get_value(lucian_combo_prioity) == 0 then

		if menu:get_value(lucian_combo_use_q) == 1 then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(lucian_combo_use_w) == 1 then
			if myHero:distance_to(target.origin) and IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= W.range then
		     	if Ready(SLOT_W) and not Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
						CastW(target)
					end
				end
			end
		end

		-- E

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 1 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not Ready(SLOT_W) and not Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 0 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not Ready(SLOT_W) and not Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastEMouse()
					end
				end
			end
		end

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 2 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not Ready(SLOT_W) and not Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastESide()
					end
				end
			end
		end
	end

	if menu:get_value(lucian_combo_prioity) == 1 then

		if menu:get_value(lucian_combo_use_q) == 1 then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if not Ready(SLOT_E) and Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(lucian_combo_use_w) == 1 then
			if myHero:distance_to(target.origin) and IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= W.range then
		     	if Ready(SLOT_W) and not Ready(SLOT_Q) and not Ready(SLOT_E) and HasPassiveShotsReady(myHero) then
						CastW(target)
					end
				end
			end
		end

		-- E

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 1 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 0 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastEMouse()
					end
				end
			end
		end

		if menu:get_value(lucian_combo_use_e) == 1 and menu:get_value(lucian_combo_e_useage) == 2 then
			if myHero:distance_to(target.origin) < AAQRange and IsValid(target) and IsKillable(target) then
				if not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_E) then
						CastESide()
					end
				end
			end
		end
	end
end

-- Combo

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(lucian_harass_min_mana) / 100
	target = selector:find_target(W.range, mode_health)

	if menu:get_value(lucian_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) then
				if GrabHarassMana then
					CastQ(target)
				end
			end
		end
	end

	if menu:get_value(lucian_harass_use_w) == 1 then
		if myHero:distance_to(target.origin) and IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= W.range then
				if Ready(SLOT_W) and not Ready(SLOT_Q) and not HasPassiveShotsReady(myHero) and GrabHarassMana then
					CastW(target)
				end
			end
		end
	end
end



-- Auto Q Harass

local function AutoQHarass()

	local GrabAutoHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(lucian_harass_min_mana) / 100
	target = selector:find_target(Q.range, mode_health)

	if menu:get_toggle_state(lucian_harass_use_auto_q) and menu:get_value(lucian_harass_use_q) == 1 and not game:is_key_down(menu:get_value(lucian_combokey)) then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) and not HasRActive(myHero) and not HasPassiveShotsReady(myHero) then
			if Ready(SLOT_Q) and not IsUnderTurret(myHero) and GrabAutoHarassMana then
				CastQ(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(lucian_ks_use_q) == 1 then
				if GetQDmg(target) > target.health and not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(lucian_ks_use_w) == 1 then
				if GetWDmg(target) > target.health and not HasPassiveShotsReady(myHero) then
					if Ready(SLOT_W)then
						CastW(target)
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(lucian_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(lucian_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, myHero) >= menu:get_value(lucian_laneclear_q_min) then
					if GrabLaneClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if menu:get_value(lucian_laneclear_use_e) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < AA.range then
				if GetMinionCount(AA.range, myHero) >= menu:get_value(lucian_laneclear_e_min) then
					if GrabLaneClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_E) then
            CastEMouse()
					end
				end
			end
		end

		if menu:get_value(lucian_laneclear_use_w) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < AA.range then
				if GetMinionCount(AA.range, myHero) >= menu:get_value(lucian_laneclear_w_min) then
					if GrabLaneClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_W) then
            CastW(target)
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(lucian_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(lucian_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if GrabJungleClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(lucian_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < AA.range then
			if IsValid(target) then
				if GrabJungleClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_E) then
          CastEMouse()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(lucian_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < AA.range then
			if IsValid(target) then
				if GrabJungleClearMana and not HasPassiveShotsReady(myHero) and Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end
end

-- Extend Q

--[[local function QExtend()

	target = selector:find_target(Q2.range, mode_health)

	if menu:get_value(lucian_harass_use_q_ext) == 1 then

		pred_output = pred:predict(Q2.speed, Q2.delay, Q2.range, Q2.width, target, false, false)
		if pred_output.can_cast then
			local output = pred_output.cast_pos

			minions = game.minions
			for i, minion in ipairs(minions) do
				if IsValid(target) and target.object_id ~= 0 and target.is_enemy then
					if IsValid(minion) and minion.object_id ~= 0 and minion.is_enemy then

						local Count = GetLineTargetCount(myHero, output, Q2.delay, Q2.speed, Q.width / 2)
						if Count >= 1 then
							console:log("HERE")
							targetorigin = target.origin
							x, y, z = origin.x, origin.y, origin.z

							local Count2 = GetLineMinionCount(minion, output, Q.delay, Q.speed, Q.width / 2)
							console:log("HERE2")
							if Count2 >= 1 then
								if Count >= 1 and Count2 >= 1 then
									console:log("HERE3")

									--if myHero:distance_to(minion.origin) < Q.range then
										console:log("HERE4")
										if GetDistanceSqr2(minion, target) <= 300 and myHero:distance_to(target.origin) > Q.range then
											console:log("HERE5")
											if Ready(SLOT_Q) then
												origin = minion.origin
												x, y, z = origin.x, origin.y, origin.z
												spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
											end
										end
									--end
								end
							end
						end
	        end
	      end
	  	end
	  end
	end
end]]

-- Manual R

local function ManualR()
  target = selector:find_target(R.range, mode_health)

  if game:is_key_down(menu:get_value(lucian_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < R.range then
			if IsValid(target) and IsKillable(target) and Ready(SLOT_R) and not HasRActive(myHero) then
				CastR(target)
			end
    end
  end
end

-- Gap Close

local function on_gap_close(obj, data)

	if menu:get_value(lucian_extra_gapclose) == 1 then
    if IsValid(obj) then
      if myHero:distance_to(obj.origin) < myHero.attack_range and Ready(SLOT_E) then
        CastEMouse()
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

	if menu:get_value(lucian_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(lucian_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(lucian_draw_e) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, E.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(lucian_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	if menu:get_value(lucian_auto_q_draw) == 1 then
		if menu:get_value(lucian_harass_use_q) == 1 then
			if menu:get_toggle_state(lucian_harass_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [Q] Harass Enabled")
			end
		end
	end


	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + (myHero.total_attack_damage * 6)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
			if menu:get_value(lucian_draw_kill) == 1 then
				if fulldmg > target.health and IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
					end
				end
			end
		end

		if IsValid(target) and menu:get_value(lucian_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end

	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(lucian_combokey)) and menu:get_value(lucian_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
		--QExtend()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(lucian_extra_semi_r_key)) then
		ManualR()
		orbwalker:move_to()
	end

	AutoKill()
	AutoQHarass()


end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
