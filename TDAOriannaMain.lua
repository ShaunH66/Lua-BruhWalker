if game.local_player.champ_name ~= "Orianna" then
	return
end

pred:use_prediction()

local Q = { range = 825, delay = .1, width = 175, speed = 1400 }
local W = { range = 0, delay = .1, width = 225, speed = 0 }
local E = { range = 1120, delay = .1, width = 160, speed = 1850 }
local R = { range = 0, delay = 0.5, width = 400, speed = 0 }

local myHero = game.local_player
local Ball = myHero
local Qtime = 0

local function Ready(spell)
    return spellbook:can_cast(spell)
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
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
				predicted_target = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
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

local function GetInitialTargetsJungle(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius
	
	for i, target in ipairs(game.jungle_minions) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and IsValid(target) and GetDistanceSqr(main_target, target) < diameter_sqr and target.is_enemy then 
			table.insert(targets, target)
		end
	end	
	return targets
end

local function GetPredictedInitialTargetsJungle(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local predicted_main_target = pred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius
		
		for i, target in ipairs(game.jungle_minions) do
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

local function GetBestAoEPositionJungle(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	local targets = GetPredictedInitialTargetsJungle(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargetsJungle(radius, main_target)
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

local function GetEnemyCountCicular(range, ball)
	count = 0
	players = game.players
	for _, unit in ipairs(players) do
	Range = range * range
		if unit.is_enemy and GetDistanceSqr2(ball.origin, unit.origin) < Range and IsValid(unit) then
		count = count + 1
		end
	end
	return count
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

local function GetLineTargetCount(source, aimPos, range, width)
    local Count = 0
	local QCount = 0
	players = game.players
	for _, target in ipairs(players) do
        local Range = range * range
        if target.object_id ~= 0 and IsValid(target) and target.is_enemy and GetDistanceSqr(myHero, target) < Range then

            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end

function VectorMag(vec, mag)
	x, y, z = vec.x, vec.y, vec.z
	new_x = mag * x
	new_y = mag * y
	new_z = mag * z
	output = vec3.new(new_x, new_y, new_z)
	return output
end

function Add(vec1, vec2)
    new_x = vec1.x + vec2.x
    new_y = vec1.y + vec2.y
    new_z = vec1.z + vec2.z
    add = vec3.new(new_x, new_y, new_z)
    return add
end

function Sub(vec1, vec2)
	new_x = vec1.x - vec2.x
	new_y = vec1.y - vec2.y
	new_z = vec1.z - vec2.z
	sub = vec3.new(new_x, new_y, new_z)
	return sub
end
---------------------------------------Damage Calculations---------------------------

local function GetAutoDmg(unit)
	stacks = 0
	base = 0
	if myHero:has_buff("oriannapself") then
		buff = myHero:get_buff("oriannapself")
		stacks = buff.count
	end
	level = myHero.level
	if level == 1 then
		base = 10
	elseif level > 1 and level <= 4 then
		base = 18
	elseif level > 4 and level <= 7 then
		base = 26
	elseif level > 7 and level <= 10 then
		base = 34
	elseif level > 10 and level <= 13 then
		base = 42
	elseif level > 13 then
		base = 50
	end
	bonusdmg = 0.15 * myHero.ability_power
	damage = base + bonusdmg
	return unit:calculate_phys_damage(damage)
end

local function GetQDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_Q).level
	local BonusDmg = 0.50 * myHero.ability_power
	local QDamage = (({60, 90, 120, 150, 180})[level] + BonusDmg)
	Damage = QDamage
	return unit:calculate_magic_damage(Damage)
end

local function GetWDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_W).level
	local BonusDmg = 0.70 * myHero.ability_power
	local WDamage = (({60, 105, 150, 195, 240})[level] + BonusDmg)
	Damage = WDamage
	return unit:calculate_magic_damage(Damage)
end


local function GetEDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_E).level
	local BonusDmg = 0.30 * myHero.ability_power
	local EDamage = (({60, 90, 120, 150, 180})[level] + BonusDmg)
	Damage = EDamage
	return unit:calculate_magic_damage(Damage)
end

local function GetRDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_R).level
	local BonusDmg = 0.80 * myHero.ability_power
	local RDamage = (({200, 275, 350})[level] + BonusDmg)
	Damage = RDamage
	return unit:calculate_magic_damage(Damage)
end


local function CastQ(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, E.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		--renderer:draw_circle(castPos.x, castPos.y, castPos.z, 125, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
		--direction = Sub(castPos, unit.origin):normalized()
		--vec = VectorMag(direction, 175)
		--final = Add(castPos, vec)
		spellbook:cast_spell(SLOT_Q, 0, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W)
end

local function CastE(unit)
	spellbook:cast_spell_targetted(SLOT_E, unit, E.delay)
end

local function CastR()
	spellbook:cast_spell(SLOT_R)
end

-- Menu --

if file_manager:file_exists("Banthors Common//Orianna.png") then
	BOrianna_category = menu:add_category_sprite("TDA Orianna", "Banthors Common//Orianna.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/Orianna.png", "Banthors Common//Orianna.png")
	BOrianna_category = menu:add_category("TDA Orianna")
end
BOrianna_enabled = menu:add_checkbox("Enabled", BOrianna_category, 1)
BOrianna_combokey = menu:add_keybinder("Combo Key", BOrianna_category, 32)

if file_manager:file_exists("Banthors Common//Combo.png") then
	Bcombo = menu:add_subcategory_sprite("Combo Features", BOrianna_category, "Banthors Common//Combo.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/Combo.png", "Banthors Common//Combo.png")
	Bcombo = menu:add_subcategory("Combo Features", BOrianna_category)
end

if file_manager:file_exists("Banthors Common//OriannaQ.png") then
	BcomboQ = menu:add_subcategory_sprite("[Q] Options", Bcombo, "Banthors Common//OriannaQ.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/OriannaQ.png", "Banthors Common//OriannaQ.png")
	BcomboQ = menu:add_subcategory("[Q] Options", Bcombo)
end
Bcombo_useq = menu:add_checkbox("Use Q", BcomboQ, 1)
Bcombo_useqx = menu:add_slider("Auto Q If It Will Catch [X] Enemies", BcomboQ, 1, 5, 3)

if file_manager:file_exists("Banthors Common//OriannaW.png") then
	BcomboW = menu:add_subcategory_sprite("[W] Options", Bcombo, "Banthors Common//OriannaW.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/OriannaW.png", "Banthors Common//OriannaW.png")
	BcomboW = menu:add_subcategory("[W] Options", Bcombo)
end
Bcombo_usew = menu:add_checkbox("Use W", BcomboW, 1)
Bcombo_usewx = menu:add_slider("Auto W If It Will Catch [X] Enemies", BcomboW, 1, 5, 3)

if file_manager:file_exists("Banthors Common//OriannaE.png") then
	BcomboE = menu:add_subcategory_sprite("[E] Options", Bcombo, "Banthors Common//OriannaE.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/OriannaE.png", "Banthors Common//OriannaE.png")
	BcomboE = menu:add_subcategory("[E] Options", Bcombo)
end
Bcombo_usee = menu:add_checkbox("Use E", BcomboE, 1)
Bcombo_useemissileself = menu:add_checkbox("Use E To Shield Missiles Self", BcomboE, 1)
Bcombo_useemissileally = menu:add_checkbox("Use E To Shield Missiles Ally", BcomboE, 1)
Bcombo_useex = menu:add_slider("Auto E If It Will Catch [X] Enemies", BcomboE, 1, 5, 3)

if file_manager:file_exists("Banthors Common//OriannaR.png") then
	BcomboR = menu:add_subcategory_sprite("[R] Options", Bcombo, "Banthors Common//OriannaR.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/OriannaR.png", "Banthors Common//OriannaR.png")
	BcomboR = menu:add_subcategory("[R] Options", Bcombo)
end
Bcombo_user = menu:add_checkbox("Use R", BcomboR, 1)
Bcombo_userx = menu:add_slider("Auto R If It Will Catch [X] Enemies", BcomboR, 1, 5, 3)
Bcombo_autoflash = menu:add_checkbox("Flash Into Position Where You Will Catch [X] Enemies", BcomboR, 1)
Bcombo_flashrcheck = menu:add_slider("Flash Into Position Where You Will Catch [X] Enemies", BcomboR, 1, 5, 3)

if file_manager:file_exists("Banthors Common//Harass.png") then
	Bharass = menu:add_subcategory_sprite("Harass Features", BOrianna_category, "Banthors Common//Harass.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/Harass.png", "Banthors Common//Harass.png")
	Bharass = menu:add_subcategory("Harass Features", BOrianna_category)
end
Bharass_useq = menu:add_checkbox("Use Q", Bharass, 1)
Bharass_usew = menu:add_checkbox("Use W", Bharass, 1)
Bharass_usee = menu:add_checkbox("Use E", Bharass, 1)
Bharass_usemana = menu:add_slider("Minimum Mana To Harass", Bharass, 0, 100, 20)

if file_manager:file_exists("Banthors Common//LaneClear.png") then
	Blane = menu:add_subcategory_sprite("LaneClear Features", BOrianna_category, "Banthors Common//LaneClear.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/LaneClear.png", "Banthors Common//LaneClear.png")
	Blane = menu:add_subcategory("LaneClear Features", BOrianna_category)
end
Blane_useq = menu:add_checkbox("Use Q", Blane, 1)
Blane_useqx = menu:add_slider("Minimum Minions To Use [Q]", Blane, 0, 10, 3)
Blane_usew = menu:add_checkbox("Use W", Blane, 1)
Blane_usewx = menu:add_slider("Minimum Minion To Use [W]", Blane, 0, 10, 3)
Blane_usee = menu:add_checkbox("Use E", Blane, 1)
Blane_usemana = menu:add_slider("Minimum Mana To LaneClear", Blane, 0, 100, 20)

if file_manager:file_exists("Banthors Common//JungleClear.png") then
	Bjungle = menu:add_subcategory_sprite("JungleClear Features", BOrianna_category, "Banthors Common//JungleClear.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/JungleClear.png", "Banthors Common//JungleClear.png")
	Bjungle = menu:add_subcategory("JungleClear Features", BOrianna_category)
end
Bjungle_useq = menu:add_checkbox("Use Q", Bjungle, 1)
Bjungle_usew = menu:add_checkbox("Use W", Bjungle, 1)
Bjungle_usee = menu:add_checkbox("Use E", Bjungle, 1)
Bjungle_mana = menu:add_slider("Minimum Mana To Jungle Clear", Bjungle, 0, 100, 10)

if file_manager:file_exists("Banthors Common//LastHit.png") then
	Blast = menu:add_subcategory_sprite("LastHit Features", BOrianna_category, "Banthors Common//LastHit.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/LastHit.png", "Banthors Common//LastHit.png")
	Blast = menu:add_subcategory("LastHit Features", BOrianna_category)
end
Blast_useq = menu:add_checkbox("Use Q", Blast, 1)
Blast_usee = menu:add_checkbox("Use E", Blast, 1)
Blast_mana = menu:add_slider("Minimum Mana To Last Hit", Blast, 0, 100, 20)

if file_manager:file_exists("Banthors Common//KillSteal.png") then
	Bkill = menu:add_subcategory_sprite("KillSteal Features", BOrianna_category, "Banthors Common//KillSteal.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/KillSteal.png", "Banthors Common//KillSteal.png")
	Bkill = menu:add_subcategory("KillSteal Features", BOrianna_category)
end
Bkill_useqw = menu:add_checkbox("[Q] + [W]", Bkill, 1)
Bkill_useqe = menu:add_checkbox("[Q] + [E]", Bkill, 1)
Bkill_user = menu:add_checkbox("[R]", Bkill, 1)
Bkill_blacklist = menu:add_subcategory("[R] Kill Steal Blacklist", Bkill)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), Bkill_blacklist, 1)
    end
end

if file_manager:file_exists("Banthors Common//Drawing.png") then
	BSpell_range = menu:add_subcategory_sprite("Drawing Features", BOrianna_category, "Banthors Common//Drawing.png")
else
	http:download_file("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Common/Drawing.png", "Banthors Common//Drawing.png")
	BSpell_range = menu:add_subcategory("Drawing Features", BOrianna_category)
end
Bdrawq = menu:add_checkbox("Draw Q", BSpell_range, 1)
Bdraww = menu:add_checkbox("Draw W", BSpell_range, 1)
Bdrawe = menu:add_checkbox("Draw E", BSpell_range, 1)
Bdrawr = menu:add_checkbox("Draw R", BSpell_range, 1)
Bdraw_kill_text = menu:add_checkbox("Draw Kill Combo Text", BSpell_range, 1)
Bdraw_kill_healthbar = menu:add_checkbox("Draw Health Bar Full Combo Damage", BSpell_range, 1)
Bdrawball = menu:add_checkbox("Draw Ball", BSpell_range, 1)
BColorR = menu:add_slider("Red", BSpell_range, 1, 255, 220)
BColorG = menu:add_slider("Green", BSpell_range, 1, 255, 55)
BColorB = menu:add_slider("Blue", BSpell_range, 1, 255, 14)
BColorA = menu:add_slider("Alpha", BSpell_range, 1, 255, 255)

local function Combo()
	target = selector:find_target(Q.range, mode_health)
	if myHero:distance_to(target.origin) < Q.range and Ready(SLOT_Q) then
		CastQ(target)
	end

	if Ready(SLOT_W) and menu:get_value(Bcombo_usew) == 1 and IsValid(target) and Ball:distance_to(target.origin) <= W.width then
		CastW()
	end

	if Ball.object_id ~= myHero.object_id and Ready(SLOT_E) and IsValid(target) and menu:get_value(Bcombo_usee) == 1 then
		local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
		if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
			CastE(myHero)
		end
	end
end

local function Harass()

	target = selector:find_target(Q.range, mode_health)
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(Bharass_usemana) / 100

	if menu:get_value(Bharass_useq) == 1 then
		if myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if GrabHarassMana and not orbwalker:can_attack() then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end
	end

	if menu:get_value(Bharass_usew) == 1 then
		if Ball:distance_to(target.origin) <= W.width and IsValid(target) then
			if GrabHarassMana then
				if Ready(SLOT_W) then
					CastW()
				end
			end
		end
	end

	if menu:get_value(Bharass_usee) == 1 then
		if GrabHarassMana then
			if Ball.object_id ~= myHero.object_id and Ready(SLOT_E) and IsValid(target) then
				local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
				if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
					CastE(myHero)
				end
			end
		end
	end
end

local function LaneClear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(Blane_usemana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(Blane_useq) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if Ready(SLOT_Q) then
					local CastPos, targets = GetBestAoEPositionMinion(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
					if CastPos and targets >= menu:get_value(Blane_useqx) then
						spellbook:cast_spell(SLOT_Q, Q.delay, CastPos.x, CastPos.y, CastPos.z)
					end
				end
			end
		end

		if menu:get_value(Blane_usew) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and IsValid(target) then
				if GetMinionCount(W.width, Ball) >= menu:get_value(Blane_usewx) then
					if Ready(SLOT_W) then
						CastW()
					end
				end
			end
		end

		if menu:get_value(Blane_usee) == 1 and GrabLaneClearMana then
			if Ball.object_id ~= myHero.object_id and target.is_enemy and Ready(SLOT_E) and IsValid(target) then
				local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
				if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
					CastE(myHero)
				end
			end
		end
	end
end

local function JungleClear()

	local GrabLaneJungleMana = myHero.mana/myHero.max_mana >= menu:get_value(Bjungle_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if menu:get_value(Bjungle_useq) == 1 and GrabLaneJungleMana then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) < Q.range and IsValid(target) and Ready(SLOT_Q) then
				local CastPos, targets = GetBestAoEPositionMinion(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
				if CastPos and targets >= 1 then
					spellbook:cast_spell(SLOT_Q, Q.delay, CastPos.x, CastPos.y, CastPos.z)
				end
			end
		end

		if menu:get_value(Bjungle_usew) == 1 and GrabLaneJungleMana then
			if target.object_id ~= 0 and IsValid(target) then
				if Ball:distance_to(target.origin) <= W.width then
					if Ready(SLOT_W) then
						CastW()
					end
				end
			end
		end

		if menu:get_value(Bjungle_usee) == 1 and GrabLaneJungleMana then
			if Ball.object_id ~= myHero.object_id and Ready(SLOT_E) and IsValid(target) then
				local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
				if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
					CastE(myHero)
				end
			end
		end
	end
end

local function LastHit()

	local GrabLaneLasthitMana = myHero.mana/myHero.max_mana >= menu:get_value(Blast_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do
		local AttackRange = myHero.bounding_radius + myHero.attack_range + target.bounding_radius
		if myHero:distance_to(target.origin) > AttackRange or not orbwalker:can_move() then
			if menu:get_value(Blast_useq) == 1 and GrabLaneLasthitMana then
				if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
					if GetQDmg(target) > target.health then
						if Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
			if menu:get_value(Blast_usee) == 1 and GrabLaneLasthitMana then
				if Ball.object_id ~= myHero.object_id and target.is_enemy and Ready(SLOT_E) and IsValid(target) then
					if GetEDmg(target) > target.health then
						local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
						if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
							CastE(myHero)
						end
					end
				end
			end
		end
	end
end

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		local QWDmg = GetQDmg(target) + GetWDmg(target)
		local QEDmg = GetQDmg(target) + GetEDmg(target)

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and QWDmg > target.health and menu:get_value(Bkill_useqw) == 1 then
			if menu:get_value(Bkill_useqw) == 1 and Ready(SLOT_Q) and Ready(SLOT_W) then
				CastQ(target)
			end
			if Ball:distance_to(target.origin) <= W.width and IsValid(target) and not Ready(SLOT_Q) and Ready(SLOT_W) then
				CastW()
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and QEDmg > target.health and menu:get_value(Bkill_useqe) == 1 then
			if Ready(SLOT_Q) and Ready(SLOT_E) then
				CastQ(target)
			end
			if Ball.object_id ~= myHero.object_id and IsValid(target) and not Ready(SLOT_Q) and Ready(SLOT_E) then
				local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(Ball.origin, myHero.origin, target.origin)
				if pointLine and GetDistanceSqr2(pointSegment, target.origin) < 80 then
					CastE(myHero)
				end
			end
		end

		if target.object_id ~= 0 and Ball:distance_to(target.origin) <= R.width and IsValid(target) then
			if menu:get_value(Bkill_user) == 1 then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) then
						if menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
							CastR(target)
						end
					end
				end
			end
		end
	end
end

local function AutoFlash()
	if Ready(SLOT_R) then
		for _, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= Q.range and Ball == myHero and menu:get_value(Bcombo_autoflash) == 1 then
				local CastPos, targets = GetBestAoEPosition(math.huge, 0, 425, R.width, unit, false, false)
				if CastPos and targets >= menu:get_value(Bcombo_flashrcheck) then
					if myHero:distance_to(CastPos) < 425 then
						if Ready(SLOT_D) then
							spellbook:cast_spell(SLOT_D, 0, CastPos.x, CastPos.y, CastPos.z)
						end
					end
				end
			end
		end
	end
end

local function AutoQ()
	if Ready(SLOT_Q) then
		for i, unit in ipairs(GetEnemyHeroes()) do
			local Dist = myHero:distance_to(unit.origin)
			if unit.object_id ~= 0 and IsValid(unit) and Dist <= Q.range then
				local CastPos, targets = GetBestAoEPosition(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
				if CastPos and targets >= menu:get_value(Bcombo_useqx) then
					spellbook:cast_spell(SLOT_Q, Q.delay, CastPos.x, CastPos.y, CastPos.z)
				end
			end
		end
	end
end

local function AutoW()
	if Ready(SLOT_W) then
		count = GetEnemyCountCicular(W.width, Ball)
		if count >= menu:get_value(Bcombo_usewx) then
			CastW()
		end
	end
end

local function AutoE()
	local Count = 0
    players = game.players
	for _, target in ipairs(players) do
        if target.is_enemy and IsValid(target) and Ball:distance_to(target.origin) <= E.range and Ready(SLOT_E) then
			local Count = GetLineTargetCount(myHero, Ball.origin, E.range, 70)
            if Count >= menu:get_value(Bcombo_useex) then
                CastE(myHero)
            end
        end
    end
end

local function AutoR()
	if Ready(SLOT_R) then
		count = GetEnemyCountCicular(R.width, Ball)
		if count >= menu:get_value(Bcombo_userx) then
			spellbook:cast_spell(SLOT_R, 0.5)
		end
	end
end

local function MissileCheck()
	missiles = game.missiles
	for _, v in ipairs(missiles) do
		if v.is_missile then
			missile = v.missile_data
			if missile.target_id == myHero.object_id and menu:get_value(Bcombo_useemissileself) == 1 and Ready(SLOT_E) then
				if not missile.name:lower():find("minion") and not missile.name:lower():find("plating") and not missile.name:lower():find("razorbeak") and not missile.name:lower():find("gromp") and not missile.name:lower():find("redact") and not missile.name:lower():find("lizard") and not missile.name:lower():find("ancient") then
					x,y,z = missile.end_pos.x, missile.end_pos.y, missile.end_pos.z
					spellbook:cast_spell_targetted(SLOT_E, myHero, 0)
					--console:log(missile.name)
				end
			end
			players = game.players
			for _, ally in ipairs(players) do
				if myHero:distance_to(ally.origin) < 1120 and not ally.is_enemy then
					if missile.target_id == ally.object_id and menu:get_value(Bcombo_useemissileally) == 1 and Ready(SLOT_E) then
						if not missile.name:lower():find("minion") and not missile.name:lower():find("plating") and not missile.name:lower():find("razorbeak") and not missile.name:lower():find("gromp") and not missile.name:lower():find("redact") and not missile.name:lower():find("lizard") and not missile.name:lower():find("ancient")then
							x,y,z = missile.end_pos.x, missile.end_pos.y, missile.end_pos.z
							spellbook:cast_spell_targetted(SLOT_E, ally, 0)
							--console:log(missile.name)
						end
					end
				end
			end
		end
	end
end


local function on_draw()
	local_player = game.local_player

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
		Ballpos = Ball.origin

		if menu:get_value(Bdrawq) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, 825, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end

		if menu:get_value(Bdraww) == 1 then
			if Ready(SLOT_W) then
				renderer:draw_circle(Ballpos.x, Ballpos.y, Ballpos.z, 225, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end

		if menu:get_value(Bdrawe) == 1 then
			if Ready(SLOT_E) then
				renderer:draw_circle(x, y, z, 1120, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end

		if menu:get_value(Bdrawr) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(Ballpos.x, Ballpos.y, Ballpos.z, 415, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
			end
		end
		if menu:get_value(Bdrawball) == 1 then
			renderer:draw_circle(Ballpos.x, Ballpos.y, Ballpos.z, 125, menu:get_value(BColorR), menu:get_value(BColorG), menu:get_value(BColorB), menu:get_value(BColorA))
		end
	end

	for i, target in ipairs(GetEnemyHeroes()) do
		local screen_size = game.screen_size
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetEDmg(target) + GetRDmg(target)
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range then
				if menu:get_value(Bdraw_kill_text) == 1 then
					if fulldmg > target.health and IsValid(target) then
						renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 50, "Full Combo Rotation Can Kill Target")
					end
				end
			end
		end
		if menu:get_value(Bdraw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_object_created(object, obj_name)
	if obj_name == "Orianna_Base_Q_yomu_ring_green" then
		Ball = object
	end
end

local function on_buff_active(obj, buff_name)
	if obj:has_buff("orianaghostself") then
		Ball = myHero
	elseif obj:has_buff("orianaghost") then
		Ball = obj
	end
end

-- Every Game Tick --

local function on_tick()
	if menu:get_value(BOrianna_enabled) == 1 then
		local Mode = combo:get_mode()
		if game:is_key_down(menu:get_value(BOrianna_combokey)) then
			Combo()
		elseif Mode == MODE_HARASS then
			Harass()
		elseif Mode == MODE_LANECLEAR then
			LaneClear()
			JungleClear()
		elseif Mode == MODE_LASTHIT then
			LastHit()
		end
		AutoQ()
		AutoW()
		AutoE()
		AutoR()
		AutoFlash()
		KillSteal()
		MissileCheck()
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_buff_active", on_buff_active)
client:set_event_callback("on_object_created", on_object_created)

console:clear()

console:log("-------------------------------------The Dodgy Alliance Presents : Orianna-------------------------------------")
console:log("Version History : 2                                             Banthors / Shaunyboii")
console:log("-----------------------------------------------------Notes:------------------------------------------------------")
console:log("Predction : Setting Is Affected By Core Prediction Setting. For Best Results Use Spredict High And Fast SPredict")
console:log("-------------------------------------------------Added / Changed:-----------------------------------------------")
console:log("- Bug Fix On Draw Combo Kill Text")
console:log("-")
console:log("-")
console:log("-")
console:log("-")
console:log("-")
console:log("-----------------------------------------------------To Do:------------------------------------------------------")
console:log("-")
console:log(" ")


do
	local function AutoUpdate()
		local Version = 2
		local file_name = "TDAOrianna.lua"
		local url = "https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/TDAOrianna.lua"
		local web_version = http:get("https://raw.githubusercontent.com/Banthors/Bruhwalker/main/Banthors%20Orianna/TDAOrianna.version.txt")
		--console:log("BanthorsBrand.Lua Vers: "..Version)
		--console:log("BanthorsBrand.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
			console:log("The Dodgy Alliance Orianna successfully loaded.....")
			else
			http:download_file(url, file_name)
			console:log("New Orianna Update available.....")
			console:log("Please reload via F5.....")
			end
		end

 AutoUpdate()

end
