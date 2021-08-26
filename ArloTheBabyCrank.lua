if game.local_player.champ_name ~= "Blitzcrank" then
	return
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
  console:log("You Are VIP! Thanks For Supporting <3 #Family")
	console:log(".............................................................................")
end

--Ensuring that the librarys are downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
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


--Initialization lines:
local ml = require "VectorMath"
arkpred = _G.Prediction
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player

-- Ranges

local Q = { range = 1100, delay = .25, width = 70, speed = 1800 }
local W = { delay = .25 }
local E = { delay = .25 }
local R = { range = 600, delay = .25 }

-- Return game data and maths

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

local function Is_Me(unit)
	if unit.champ_name == myHero.champ_name then
		return true
	end
	return false
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

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and ml.IsValid(target) and GetDistanceSqr(main_target, target) < diameter_sqr then
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

		for i, target in ipairs(ml.GetEnemyHeroes()) do
			if target.object_id ~= 0 and ml.IsValid(target) then
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
	for i, unit in ipairs(ml.GetEnemyHeroes()) do
		local Dist = myHero:distance_to(unit.origin)
		if unit.object_id ~= 0 and ml.IsValid(unit) and Dist < 1500 then
			local CastPos, targets = GetBestAoEPosition(math.huge, 1.15, 1800, 240, unit, false, false)
			if CastPos then
				renderer:draw_circle(CastPos.x, CastPos.y, CastPos.z, 50, 0, 137, 255, 255)
				screen_pos = game:world_to_screen(CastPos.x, CastPos.y, CastPos.z)
				x, y = screen_pos.x, screen_pos.y
				renderer:draw_text_big(x, y, "Count = "..tostring(targets), 220, 20, 60, 255)
			end
		end
	end
end

-- No lib Functions Start

local function IsKillable(unit)
	if unit:has_buff_type(16) or unit:has_buff_type(18) or unit:has_buff("sionpassivezombie") then
		return false
	end
	return true
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

local function EasyDistCompare(p1, p2)
  p2x, p2y, p2z = p2.x, p2.y, p2.z
  p1x, p1y, p1z = p1.x, p1.y, p1.z
  local dx = p1x - p2x
  local dz = (p1z or p1y) - (p2z or p2y)
  return math.sqrt(dx*dx + dz*dz)
end

local function GetEnemyCount(range, unit)
	count = 0
	for i, hero in ipairs(ml.GetEnemyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit, hero) < Range and ml.IsValid(hero) then
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
		if minion.is_enemy and ml.IsValid(minion) and unit.object_id ~= minion.object_id and GetDistanceSqr(unit, minion) < Range then
			count = count + 1
		end
	end
	return count
end

local function MinionsAround(pos, range)
    local Count = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

local function GetBestCircularFarmPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = MinionsAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

function JungleMonstersAround(pos, range)
    local Count = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

function GetBestCircularJungPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = JungleMonstersAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

-- No lib Functions End

local function SupressedSpellReady(spell)
  return spellbook:can_cast_ignore_supressed(spell)
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

local function IsFlashSlotD()
flash = spellbook:get_spell_slot(SLOT_D)
FData = flash.spell_data
FName = FData.spell_name
if FName == "SummonerFlash" then
  return true
end
return false
end

local function ControlWardCheck()
  local control_ward = false
  local control_ward_slot = nil
  local inventory = ml.GetItems()
  for _, v in ipairs(inventory) do
    if tonumber(v) == 2055 then
    	local item = local_player:get_item(tonumber(v))
    	if item ~= 0 then
		    control_ward_slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
				control_ward = true
			end
  	end
  end
  return control_ward, control_ward_slot
end

local function SweeperCheck()
  local int = ml.GetItems()
  for _, v in ipairs(int) do
    if tonumber(v) == 3364 then
    	local item = local_player:get_item(tonumber(v))
    	if item ~= 0 then
				return true
			end
  	end
  end
  return false
end

local function SweeperCheck()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	if spell_slot.spell_data.name == "TrinketSweeperLvl3" then
		return true
	end
	return false
end

local function GetEnemyCountCicular(range, p1)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(p1, unit.origin) < Range and ml.IsValid(unit) then
        count = count + 1
        end
    end
    return count
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

local function FullComboManReady()
	local spell_slot_q = spellbook:get_spell_slot(SLOT_Q)
	local spell_slot_w = spellbook:get_spell_slot(SLOT_W)
	local spell_slot_e = spellbook:get_spell_slot(SLOT_E)
	local total_spell_cost = spell_slot_q.spell_data.mana_cost + spell_slot_w.spell_data.mana_cost + spell_slot_e.spell_data.mana_cost
	if myHero.mana > total_spell_cost then
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

local function GrabBuff(unit)
  if unit:has_buff("rocketgrab2") then
    return true
  end
  return false
end

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetEDmg(unit)
	local EDmg = getdmg("E", unit, myHero, 1)
	return EDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	blitz_category = menu:add_category_sprite("Shaun's Sexy Blitz", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	blitz_category = menu:add_category("Shaun's Sexy Blitz")
end

blitz_enabled = menu:add_checkbox("Enabled", blitz_category, 1)
blitz_combokey = menu:add_keybinder("Combo Mode Key", blitz_category, 32)
menu:add_label("Shaun's Sexy Blitz", blitz_category)
menu:add_label("#ArloBestBabyEUW!", blitz_category)

blitz_ark_pred = menu:add_subcategory("[Ark Pred Settings]", blitz_category)
blitz_ark_pred_q = menu:add_subcategory("[Q] Settings", blitz_ark_pred, 1)
blitz_q_speed = menu:add_slider("[Q] Blitz Speed Input", blitz_ark_pred_q, 1, 2500, 1800)
blitz_q_range = menu:add_slider("[Q] Blitz Range Input", blitz_ark_pred_q, 1, 2500, 1050)
blitz_q_radius = menu:add_slider("[Q] Blitz Radius Input", blitz_ark_pred_q, 1, 500, 70)

blitz_ks_function = menu:add_subcategory("[Kill Steal]", blitz_category)
blitz_ks_q = menu:add_subcategory("[Q] Settings", blitz_ks_function, 1)
blitz_ks_use_q = menu:add_checkbox("Use [Q]", blitz_ks_q, 1)
blitz_ks_e = menu:add_subcategory("[E] Settings", blitz_ks_function, 1)
blitz_ks_use_e = menu:add_checkbox("Use [E]", blitz_ks_e, 1)
blitz_ks_r = menu:add_subcategory("[R] Settings", blitz_ks_function, 1)
blitz_ks_use_r = menu:add_checkbox("Use [R]", blitz_ks_r, 1)

blitz_combo = menu:add_subcategory("[Combo]", blitz_category)
blitz_combo_q_blacklist = menu:add_subcategory("[Q] Combo Target Whitelist", blitz_combo)
local xplayers = game.players
for _, x in pairs(xplayers) do
    if x and x.is_enemy then
        menu:add_checkbox("Combo [Q] Target Whitelist: "..tostring(x.champ_name), blitz_combo_q_blacklist, 1)
    end
end
blitz_q_hitchance_combo = menu:add_slider("[Q] Combo Hit Chance [%]", blitz_combo, 1, 99, 55)
blitz_combo_q = menu:add_subcategory("[Q] Settings", blitz_combo)
blitz_combo_use_q = menu:add_checkbox("Use [Q]", blitz_combo_q, 1)
blitz_combo_use_aa = menu:add_checkbox("Use [Q] Outside [AA] Range", blitz_combo_q, 1)
blitz_only_qe = menu:add_checkbox("Only [Q] IF [E] Ready", blitz_combo_q, 0)
blitz_combo_w = menu:add_subcategory("[W] Settings", blitz_combo)
blitz_combo_use_w = menu:add_checkbox("Use [W] With [Q] Collision Check", blitz_combo_w, 1)
blitz_combo_e = menu:add_subcategory("[E] Settings", blitz_combo)
blitz_combo_use_e = menu:add_checkbox("Use [E]", blitz_combo_e, 1)

blitz_auto_q = menu:add_subcategory("[Q] Auto Features", blitz_category)
blitz_auto_q_toggle = menu:add_toggle("Auto [Q] Toggle", 1, blitz_auto_q, 65, true)
blitz_auto_q_hitchance = menu:add_slider("[Q] Toggle Hit Chance [%]", blitz_auto_q, 1, 99, 65)
blitz_q_min_mana = menu:add_slider("Min Mana [%] To Auto [Q]", blitz_auto_q, 1, 100, 40)
blitz_auto_q_immobile = menu:add_checkbox("Auto [Q] Immobilised Targets", blitz_auto_q, 1)
blitz_auto_q_blacklist = menu:add_subcategory("Toggle [Q] Target Whitelist", blitz_auto_q)
local jplayers = game.players
for _, j in pairs(jplayers) do
    if j and j.is_enemy then
        menu:add_checkbox("Toggle [Q] Whitelist: "..tostring(j.champ_name), blitz_auto_q_blacklist, 1)
    end
end

blitz_extra_int = menu:add_subcategory("[R] Interrupt Channels", blitz_category, 1)
blitz_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", blitz_extra_int, 1)
blitz_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", blitz_extra_int)
local vplayers = game.players
for _, v in pairs(vplayers) do
    if v and v.is_enemy then
        menu:add_checkbox("[R] Interrupt Whitelist: "..tostring(v.champ_name), blitz_extra_interrupt_blacklist, 1)
    end
end

blitz_emote = menu:add_subcategory("[Emote] Features", blitz_category)
blitz_emote_laugh = menu:add_checkbox("Use [Emote] Laugh On Successfully [Q]", blitz_emote, 1)
blitz_emote_mastery = menu:add_checkbox("Use [Emote] Mastery On Successfully [Q]", blitz_emote, 1)

blitz_draw = menu:add_subcategory("[Drawing] Features", blitz_category)
blitz_draw_q = menu:add_checkbox("Draw [Q] Max Range", blitz_draw, 1)
blitz_draw_r = menu:add_checkbox("Draw [R] Max Range", blitz_draw, 1)
blitz_draw_circle_helper = menu:add_checkbox("Draw [Q] Target Predicted Position Circle", blitz_draw, 1)
blitz_draw_helper = menu:add_checkbox("Draw [Q] Prediction Collision Line Helper", blitz_draw, 1)
blitz_autoq_draw = menu:add_checkbox("Draw Toggle Auto [Q] Enabled Text", blitz_draw, 1)
blitz_draw_helper_width = menu:add_slider("Prediction Collision Line Helper Width", blitz_draw, 1, 100, 5)
blitz_draw_helper_radius = menu:add_slider("Target Predicted Position Radius", blitz_draw, 1, 500, 100)

local Q_input = {
    source = myHero,
    speed = menu:get_value(blitz_q_speed), range = menu:get_value(blitz_q_range),
    delay = 0.25, radius = menu:get_value(blitz_q_radius),
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

-- Casting

local function CastQCombo(unit)

	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(blitz_q_hitchance_combo) / 100 and inv < (Q_input.delay / 2) then
		local p = output.cast_pos
	  spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastQAuto(unit)

	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(blitz_auto_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
		local p = output.cast_pos
	  spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
end

local function CastR()
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

local function DrawPredictionHelpers(unit)

	targetvec = unit.origin
	justme = myHero.origin
	local medraw = game:world_to_screen(justme.x, justme.y, justme.z)
	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)

	if menu:get_value(blitz_draw_helper) == 1 then
		if myHero:distance_to(unit.origin) <= Q.range and unit.is_valid and unit.is_on_screen then
			local endPos = vec3.new(targetvec.x, targetvec.y, targetvec.z)
			local q_collisions = arkpred:get_collision(Q_input, endPos, unit)
			if next(q_collisions) == nil then
				renderer:draw_line(medraw.x, medraw.y, enemydraw.x, enemydraw.y, menu:get_value(blitz_draw_helper_width), 0, 255, 0, 255)
			elseif next(q_collisions) ~= nil then
				renderer:draw_line(medraw.x, medraw.y, enemydraw.x, enemydraw.y, menu:get_value(blitz_draw_helper_width), 255, 0, 0, 255)
			end
		end
	end

	if menu:get_value(blitz_draw_circle_helper) == 1 then
		if myHero:distance_to(unit.origin) <= Q.range and unit.is_valid and unit.is_on_screen then
			local output = arkpred:get_prediction(Q_input, unit)
			local draw = output.pred_pos
			renderer:draw_circle(draw.x, draw.y, draw.z, menu:get_value(blitz_draw_helper_radius), 255, 0, 0, 255)
		end
	end
end

-- Combo

local function Combo()

	TrueAARange = myHero.attack_range + myHero.bounding_radius
	target = selector:find_target(Q.range + 200, mode_health)


	if menu:get_value(blitz_combo_use_q) == 1 and menu:get_value(blitz_only_qe) == 1 and menu:get_value(blitz_combo_use_aa) == 0 then
		if myHero:distance_to(target.origin) <= Q.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
				if menu:get_value_string("Combo [Q] Target Whitelist: "..tostring(target.champ_name)) == 1 then
					CastQCombo(target)
				end
			end
		end
	end

	if menu:get_value(blitz_combo_use_q) == 1 and menu:get_value(blitz_only_qe) == 0 and menu:get_value(blitz_combo_use_aa) == 0 then
		if myHero:distance_to(target.origin) <= Q.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
				if menu:get_value_string("Combo [Q] Target Whitelist: "..tostring(target.champ_name)) == 1 then
					CastQCombo(target)
				end
			end
		end
	end

	if menu:get_value(blitz_combo_use_q) == 1 and menu:get_value(blitz_only_qe) == 1 and menu:get_value(blitz_combo_use_aa) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
				if menu:get_value_string("Combo [Q] Target Whitelist: "..tostring(target.champ_name)) == 1 then
					CastQCombo(target)
				end
			end
		end
	end

	if menu:get_value(blitz_combo_use_q) == 1 and menu:get_value(blitz_only_qe) == 0 and menu:get_value(blitz_combo_use_aa) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
				if menu:get_value_string("Combo [Q] Target Whitelist: "..tostring(target.champ_name)) == 1 then
					CastQCombo(target)
				end
			end
		end
	end

	targetvec = target.origin
	if menu:get_value(blitz_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
			local endPos = vec3.new(targetvec.x, targetvec.y, targetvec.z)
			local q_collisions = arkpred:get_collision(Q_input, endPos, target)
			if next(q_collisions) == nil then
				CastW()
			end
		end
	end

	if menu:get_value(blitz_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
			CastW()
		end
	end

	if menu:get_value(blitz_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
			CastE()
		end
	end

	if menu:get_value_string("Combo [Q] Target Whitelist: "..tostring(target.champ_name)) == 1 then
		DrawPredictionHelpers(target)
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do

		TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(blitz_ks_use_q) == 1 then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
				if GetQDmg(target) > target.health then
					if ml.Ready(SLOT_Q) then
						CastQCombo(target)
					end
				end
			end
		end

		if menu:get_value(blitz_ks_use_e) == 1 then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) then
				if GetEDmg(target) > target.health then
					if ml.Ready(SLOT_E) then
						CastE()
					end
				end
			end
		end

		if menu:get_value(blitz_ks_use_r) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range then
					if GetRDmg(target) > target.health then
						if ml.Ready(SLOT_R) then
							CastR()
						end
					end
				end
			end
		end
	end
end

-- Auto Q

local function AutoQ()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(blitz_q_min_mana) / 100

	for i, target in ipairs(ml.GetEnemyHeroes()) do
	  if menu:get_toggle_state(blitz_auto_q_toggle) and GrabMana then
			if myHero:distance_to(target.origin) <= Q.range and not myHero.is_recalling then
				if ml.IsValid(target) and ml.Ready(SLOT_Q) then
					if menu:get_value_string("Toggle [Q] Whitelist: "..tostring(target.champ_name)) == 1 then
						CastQAuto(target)
					end
				end
	    end
		end
		if menu:get_value_string("Toggle [Q] Whitelist: "..tostring(target.champ_name)) == 1 then
			DrawPredictionHelpers(target)
		end
  end
end

local function AutoE()
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if menu:get_value(blitz_combo_use_e) == 1 then
			if GrabBuff(target) and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
				CastE()
			end
		end
	end
end

-- AutoQImobli

local function AutoQImobile()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(blitz_q_min_mana) / 100

	for i, target in ipairs(ml.GetEnemyHeroes()) do
	  if menu:get_value(blitz_auto_q_immobile) == 1 and GrabMana then
	    if myHero:distance_to(target.origin) <= Q.range then
				if IsImmobile(target) then
					if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
						CastQCombo(target)
					end
				end
	    end
	  end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) then
		if menu:get_value(blitz_extra_interrupt) == 1 then
			if menu:get_value_string("[R] Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
		   	if myHero:distance_to(obj.origin) <= R.range and ml.Ready(SLOT_R) then
					CastR()
				end
			end
		end
	end
end

local function EmoteSpam()

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if menu:get_value(blitz_emote_laugh) == 1 then
			if GrabBuff(target) then
				game:send_emote(EMOTE_LAUGH)
			end
		end

		if menu:get_value(blitz_emote_mastery) == 1 then
			if GrabBuff(target) then
				game:mastery_display()
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_draw()

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(blitz_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(blitz_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 0, 255, 255, 255)
		end
	end

	screen_size = game.screen_size
	if menu:get_toggle_state(blitz_auto_q_toggle) then
		if menu:get_value(blitz_autoq_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [Q] Enabled")
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

	if game:is_key_down(menu:get_value(blitz_combokey)) and menu:get_value(blitz_enabled) == 1 then
		Combo()
	end

	if not game:is_key_down(menu:get_value(blitz_combokey)) then
		AutoQ()
		AutoQImobile()
	end

	AutoKill()
	EmoteSpam()
	AutoE()

end

do
    local function AutoUpdate()
		local Version = 1.1
		local file_name = "ArloTheBabyCrank.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ArloTheBabyCrank.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ArloTheBabyCrank.lua.version.txt")
        console:log("ArloTheBabyCrank.lua Vers: "..Version)
		console:log("ArloTheBabyCrank.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".............................................................................")
            console:log("Shaun's Blitz Successfully Loaded")
						console:log(".............................................................................")
        else
			http:download_file(url, file_name)
			      console:log("Shaun's Blitz Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end
    end
    AutoUpdate()
end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
