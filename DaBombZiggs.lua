if game.local_player.champ_name ~= "Ziggs" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.4
		local file_name = "DaBombZiggs.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/DaBombZiggs.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/DaBombZiggs.lua.version.txt")
        console:log("DaBombZiggs.lua Vers: "..Version)
		console:log("DaBombZiggs.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".............................................................................")
            console:log("Shaun's Ziggs Successfully Loaded")
						console:log(".............................................................................")
        else
			http:download_file(url, file_name)
			      console:log("Shaun's Ziggs Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
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
pred:use_prediction()
arkpred = _G.Prediction
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player
local BlockW = false
local CastW2 = false
local w_cast = nil

-- Ranges

local Q = { delay = .25, width = 240, speed = 1700 }
local QNoBounce = { range = 850, delay = .25, width = 240, speed = 1700 }
local QBounce = { range = 1400, delay = .25, width = 240, speed = 1700 }
local W = { range = 1000, delay = .25, width = 325, speed = 1750 }
local E = { range = 900, delay = .25, width = 325, speed = 1550 }
local R = { range = 5000, delay = .375, width = 525, speed = 2250 }
local WTurretDMG = { 25, 27.5, 30, 32.5, 35 }

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

local function IsImmobileTarget(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(11) or unit:has_buff_type(22) or unit:has_buff_type(23) or unit:has_buff_type(25) or unit:has_buff_type(30) then
        return true
    end
    return false
end

local function KnockedUP(unit)
    if unit:has_buff_type(30) then
        return true
    end
    return false
end

local function TargetHasESlow(unit)
  if unit:has_buff("ZiggsESlow") then
    return true
  end
  return false
end

local function ZiggsHasW()
  if myHero:has_buff("ZiggsW") then
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
	ziggs_category = menu:add_category_sprite("Shaun's Sexy Ziggs", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	ziggs_category = menu:add_category("Shaun's Sexy Ziggs")
end

ziggs_enabled = menu:add_checkbox("Enabled", ziggs_category, 1)
ziggs_combokey = menu:add_keybinder("Combo Mode Key", ziggs_category, 32)
menu:add_label("Shaun's Sexy Ziggs", ziggs_category)
menu:add_label("#DaBombBaby!", ziggs_category)

ziggs_prediction = menu:add_subcategory("[Pred Selection]", ziggs_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
ziggs_pred_useage = menu:add_combobox("[Pred Selection]", ziggs_prediction, e_table, 1)

ziggs_ark_pred = menu:add_subcategory("[Ark Pred Settings]", ziggs_prediction)

ziggs_ark_pred_q1 = menu:add_subcategory("[Q1] No Bounce Settings", ziggs_ark_pred, 1)
ziggs_q1_hitchance = menu:add_slider("[Q1] Ziggs Hit Chance [%]", ziggs_ark_pred_q1, 1, 99, 40)
ziggs_q1_speed = menu:add_slider("[Q1] Ziggs Speed Input", ziggs_ark_pred_q1, 1, 2500, 1700)
ziggs_q1_range = menu:add_slider("[Q1] Ziggs Range Input", ziggs_ark_pred_q1, 1, 2500, 850)
ziggs_q1_radius = menu:add_slider("[Q1] Ziggs Radius Input", ziggs_ark_pred_q1, 1, 500, 150)

ziggs_ark_pred_q2 = menu:add_subcategory("[Q2] Bounce Settings", ziggs_ark_pred, 1)
ziggs_q2_hitchance = menu:add_slider("[Q2] Ziggs Hit Chance [%]", ziggs_ark_pred_q2, 1, 99, 40)
ziggs_q2_speed = menu:add_slider("[Q2] Ziggs Speed Input", ziggs_ark_pred_q2, 1, 2500, 1700)
ziggs_q2_range = menu:add_slider("[Q2] Ziggs Range Input", ziggs_ark_pred_q2, 1, 2500, 1400)
ziggs_q2_radius = menu:add_slider("[Q2] Ziggs Radius Input", ziggs_ark_pred_q2, 1, 500, 150)

ziggs_ark_pred_w = menu:add_subcategory("[W] Settings", ziggs_ark_pred, 1)
ziggs_w_hitchance = menu:add_slider("[W] Ziggs Hit Chance [%]", ziggs_ark_pred_w, 1, 99, 40)
ziggs_w_speed = menu:add_slider("[W] Ziggs Speed Input", ziggs_ark_pred_w, 1, 2500, 1750)
ziggs_w_range = menu:add_slider("[W] Ziggs Range Input", ziggs_ark_pred_w, 1, 2500, 1000)
ziggs_w_radius = menu:add_slider("[W] Ziggs Radius Input", ziggs_ark_pred_w, 1, 500, 325)

ziggs_ark_pred_e = menu:add_subcategory("[E] Settings", ziggs_ark_pred, 1)
ziggs_e_hitchance = menu:add_slider("[E] Ziggs Hit Chance [%]", ziggs_ark_pred_e, 1, 99, 40)
ziggs_e_speed = menu:add_slider("[E] Ziggs Speed Input", ziggs_ark_pred_e, 1, 2500, 1550)
ziggs_e_range = menu:add_slider("[E] Ziggs Range Input", ziggs_ark_pred_e, 1, 2500, 900)
ziggs_e_radius = menu:add_slider("[E] Ziggs Radius Input", ziggs_ark_pred_e, 1, 500, 400)

ziggs_ark_pred_r = menu:add_subcategory("[R] Settings", ziggs_ark_pred, 1)
ziggs_r_hitchance = menu:add_slider("[R] Ziggs Hit Chance [%]", ziggs_ark_pred_r, 1, 99, 40)
ziggs_r_speed = menu:add_slider("[R] Ziggs Speed Input", ziggs_ark_pred_r, 1, 5000, 2250)
ziggs_r_range = menu:add_slider("[R] Ziggs Range Input", ziggs_ark_pred_r, 1, 6000, 5000)
ziggs_r_radius = menu:add_slider("[R] Ziggs Radius Input", ziggs_ark_pred_r, 1, 700, 525)

ziggs_ks_function = menu:add_subcategory("[Kill Steal]", ziggs_category)
ziggs_ks_q = menu:add_subcategory("[Q] Settings", ziggs_ks_function, 1)
ziggs_ks_use_q = menu:add_checkbox("Use [Q]", ziggs_ks_q, 1)
ziggs_ks_e = menu:add_subcategory("[E] Settings", ziggs_ks_function, 1)
ziggs_ks_use_e = menu:add_checkbox("Use [E]", ziggs_ks_e, 1)
ziggs_ks_r = menu:add_subcategory("[R] Settings", ziggs_ks_function, 1)
ziggs_ks_use_r = menu:add_checkbox("Use [R]", ziggs_ks_r, 1)
ziggs_ks_use_r_range = menu:add_slider("Max KS [R] Range", ziggs_ks_r, 1, 5000, 3000)
ziggs_ks_use_r_ping = menu:add_checkbox("[PING] Target IF [R] Can Kill", ziggs_ks_function, 1)

ziggs_combo = menu:add_subcategory("[Combo]", ziggs_category)
ziggs_combo_q = menu:add_subcategory("[Q] Settings", ziggs_combo)
ziggs_combo_use_q = menu:add_checkbox("Use [Q]", ziggs_combo_q, 1)
ziggs_combo_use_q_minion = menu:add_checkbox("Use [Q] Minion Splash ", ziggs_combo_q, 1)
ziggs_extra_auto_q = menu:add_checkbox("Auto [Q] Immobilised Targets", ziggs_combo_q, 1)
ziggs_combo_w = menu:add_subcategory("[W] Settings", ziggs_combo)
ziggs_combo_use_w = menu:add_checkbox("Use [W]", ziggs_combo_w, 1)
ziggs_combo_e = menu:add_subcategory("[E] Settings", ziggs_combo)
ziggs_combo_use_e = menu:add_checkbox("Use [E]", ziggs_combo_e, 1)
ziggs_combo_r = menu:add_subcategory("[R] Settings", ziggs_combo)
ziggs_combo_use_r = menu:add_checkbox("Use [R]", ziggs_combo_r, 1)
ziggs_combo_r_burst_hp = menu:add_slider("[R] Burst Target HP [%]", ziggs_combo_r, 1, 100, 50)

e_table = {}
e_table[1] = "Combo Killable"
e_table[2] = "Burst"
ziggs_combo_r_useage = menu:add_combobox("Combo [R] Usage", ziggs_combo_r, e_table, 0)

ziggs_harass = menu:add_subcategory("[Harass]", ziggs_category)
ziggs_harass_q = menu:add_subcategory("[Q] Settings", ziggs_harass)
ziggs_harass_use_q = menu:add_checkbox("Use [Q]", ziggs_harass_q, 1)
ziggs_harass_use_q_minion = menu:add_checkbox("Use [Q] Minion Splash ", ziggs_harass_q, 1)
ziggs_harass_q_range = menu:add_slider("[Q] Harass Max Range", ziggs_harass_q, 1, 1400, 1200)
ziggs_harass_e = menu:add_subcategory("[E] Settings", ziggs_harass)
ziggs_harass_use_e = menu:add_checkbox("Use [E]", ziggs_harass_e, 1)
ziggs_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", ziggs_harass, 1, 100, 20)

ziggs_laneclear = menu:add_subcategory("[Lane Clear]", ziggs_category)
ziggs_laneclear_use_q = menu:add_checkbox("Use [Q]", ziggs_laneclear, 1)
ziggs_laneclear_use_e = menu:add_checkbox("Use [E]", ziggs_laneclear, 1)
ziggs_laneclear_min_q = menu:add_slider("Minimum Minions To Use [Q]", ziggs_laneclear, 1, 5, 2)
ziggs_laneclear_min_e = menu:add_slider("Minimum Minions To Use [E]", ziggs_laneclear, 1, 5, 3)
ziggs_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", ziggs_laneclear, 1, 100, 20)

ziggs_jungleclear = menu:add_subcategory("[Jungle Clear]", ziggs_category)
ziggs_jungleclear_use_q = menu:add_checkbox("Use [Q]", ziggs_jungleclear, 1)
ziggs_jungleclear_use_e = menu:add_checkbox("Use [E]", ziggs_jungleclear, 1)
ziggs_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", ziggs_jungleclear, 1, 100, 20)

ziggs_q_lasthit = menu:add_subcategory("[Last Hit]", ziggs_category)
ziggs_q_lasthit_use = menu:add_checkbox("Use [Q] Last Hit > [AA] Range", ziggs_q_lasthit, 1)

--[[ziggs_extra_q_number = menu:add_subcategory("Auto [Q] Hit AoE Count", ziggs_extra_q)
ziggs_extra_q_number_use = menu:add_checkbox("Use Auto [Q] AoE Count", ziggs_extra_q_number, 1)
ziggs_extra_q_number_count = menu:add_slider("[Q] AoE Count", ziggs_extra_q_number, 1, 5, 3)]]

ziggs_extra_w = menu:add_subcategory("[W] Automated] Features", ziggs_category)
ziggs_turret_w = menu:add_checkbox("[W] Smart Kill Turret Usage", ziggs_extra_w, 1)
ziggs_extra_semi_w_key = menu:add_keybinder("[W] Behind Target Key - Closest To Cursor", ziggs_extra_w, 84)
ziggs_extra_save = menu:add_subcategory("[W] Save Me! Settings", ziggs_extra_w)
ziggs_extra_saveme = menu:add_checkbox("[W] Save Me! Usage", ziggs_extra_save, 1)
ziggs_extra_saveme_myhp = menu:add_slider("[W] Save Me! When My HP < [%]", ziggs_extra_save, 1, 100, 25)
ziggs_extra_saveme_target = menu:add_slider("[W] Save Me! When Target > [%]", ziggs_extra_save, 1, 100, 45)

ziggs_extra_gap = menu:add_subcategory("[W] Anti Gap Closer", ziggs_extra_w)
ziggs_extra_gapclose = menu:add_toggle("[W] Toggle Gap Closer key", 1, ziggs_extra_gap, 73, true)
ziggs_extra_gapclose_blacklist = menu:add_subcategory("[W] Anti Gap Closer Champ Whitelist", ziggs_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), ziggs_extra_gapclose_blacklist, 1)
    end
end

ziggs_extra_int = menu:add_subcategory("[W] Interrupt Channels", ziggs_extra_w, 1)
ziggs_extra_interrupt = menu:add_checkbox("Use [W] Interrupt Major Channel Spells", ziggs_extra_int, 1)
ziggs_extra_interrupt_blacklist = menu:add_subcategory("[W] Interrupt Champ Whitelist", ziggs_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), ziggs_extra_interrupt_blacklist, 1)
    end
end

ziggs_extra_r = menu:add_subcategory("[R Automated] Features", ziggs_category)
ziggs_extra_semi_r_key = menu:add_keybinder("[R] Manual Key - Closest To Cursor", ziggs_extra_r, 65)
ziggs_extra_r_number = menu:add_subcategory("Auto [R] Hit AoE Count", ziggs_extra_r)
ziggs_extra_r_number_use = menu:add_checkbox("Use Auto [R] AoE Count", ziggs_extra_r_number, 1)
ziggs_extra_r_number_count = menu:add_slider("[R] AoE Count", ziggs_extra_r_number, 1, 5, 3)
ziggs_extra_r_range = menu:add_slider("Auto AoE [R] Max Range", ziggs_extra_r_number, 1, 5000, 3000)

ziggs_draw = menu:add_subcategory("[Drawing] Features", ziggs_category)
ziggs_draw_q = menu:add_checkbox("Draw [Q] Range", ziggs_draw, 1)
ziggs_draw_w = menu:add_checkbox("Draw [W] Range", ziggs_draw, 1)
ziggs_draw_e = menu:add_checkbox("Draw [E] Range", ziggs_draw, 1)
ziggs_draw_r = menu:add_checkbox("Draw [R] Max Range", ziggs_draw, 1)
ziggs_draw_r_minimap = menu:add_checkbox("Draw [R] Max Range Minimap", ziggs_draw, 1)
ziggs_draw_turrethp = menu:add_checkbox("Draw [W] Can Kill Turret Text", ziggs_draw, 1)
ziggs_gap_draw = menu:add_checkbox("Draw Toggle Auto [W] Gap Closer", ziggs_draw, 1)
ziggs_draw_kill = menu:add_checkbox("Draw Full Combo [Can Kill] Text", ziggs_draw, 1)
ziggs_draw_kill_healthbar = menu:add_checkbox("Draw [Full Combo Damage] On Target Health Bar", ziggs_draw, 1)

local Q1_input = {
    source = myHero,
    speed = menu:get_value(ziggs_q1_speed), range = menu:get_value(ziggs_q1_range),
    delay = 0.25, radius = menu:get_value(ziggs_q1_radius),
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

local Q2_input = {
    source = myHero,
		speed = menu:get_value(ziggs_q2_speed), range = menu:get_value(ziggs_q2_range),
    delay = 0.25, radius = menu:get_value(ziggs_q2_radius),
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

local W_input = {
    source = myHero,
		speed = menu:get_value(ziggs_w_speed), range = menu:get_value(ziggs_w_range),
		delay = 0.25, radius = menu:get_value(ziggs_w_radius),
    collision = {},
    type = "circular", hitbox = false
}

local E_input = {
    source = myHero,
		speed = menu:get_value(ziggs_e_speed), range = menu:get_value(ziggs_e_range),
		delay = 0.4, radius = menu:get_value(ziggs_e_radius),
    collision = {"terrain_wall"},
    type = "circular", hitbox = false
}

local R_input = {
    source = myHero,
		speed = menu:get_value(ziggs_r_speed), range = menu:get_value(ziggs_r_range),
		delay = 0.375, radius = menu:get_value(ziggs_r_radius),
    collision = {},
    type = "circular", hitbox = false

}

-- Casting

local function CastQNoBounce(unit)

	if menu:get_value(ziggs_pred_useage) == 0 then
		pred_output = pred:predict(Q.speed, Q.delay, QNoBounce.range, Q.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(ziggs_pred_useage) == 1 then
		local output = arkpred:get_prediction(Q1_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ziggs_q1_hitchance) / 100 and inv < (Q1_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
		end
	end
end

local function CastQMinion(unit)

	pred_output = pred:predict(Q.speed, Q.delay, QNoBounce.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastQBounce(unit)

	if menu:get_value(ziggs_pred_useage) == 0 then
		pred_output = pred:predict(Q.speed, Q.delay, QBounce.range, Q.width, unit, false, true)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(ziggs_pred_useage) == 1 then
		local output = arkpred:get_prediction(Q2_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ziggs_q2_hitchance) / 100 and inv < (Q2_input.delay / 2) then
			local p = output.cast_pos
			local draw = output.pred_pos
	    spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
			renderer:draw_circle(draw.x, draw.y, draw.z, 100, 255, 0, 0, 255)
		end
	end
end

local function CastW(unit)

	if menu:get_value(ziggs_pred_useage) == 0 then
		pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(ziggs_pred_useage) == 1 then
		local output = arkpred:get_prediction(W_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ziggs_w_hitchance) / 100 and inv < (W_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		end
	end
end

local function CastWBlow()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
	CastW2 = false
end

local function CastE(unit)

	if menu:get_value(ziggs_pred_useage) == 0 then
		if not pred_output.can_cast then
			w_cast = nil
		end
		pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
			w_cast = (client:get_tick_count() + 500)
			BlockW = true
		end
	end

	if menu:get_value(ziggs_pred_useage) == 1 then
		local output = arkpred:get_prediction(E_input, unit)
		 local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance < menu:get_value(ziggs_e_hitchance) / 100 then
			w_cast = nil
		end
		if output.hit_chance >= menu:get_value(ziggs_e_hitchance) / 100 and inv < (E_input.delay / 2) then
			local p = output.cast_pos
		  spellbook:cast_spell(SLOT_E, E.delay, p.x, p.y, p.z)
			w_cast = (client:get_tick_count() + 500)
			BlockW = true
		end
	end
end

local function CastR(unit)

	if menu:get_value(ziggs_pred_useage) == 0 then
		pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(ziggs_pred_useage) == 1 then
		local output = arkpred:get_prediction(R_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(ziggs_r_hitchance) / 100 and inv < (R_input.delay / 2) then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, p.x, p.y, p.z)
		end
	end
end

-- Combo

local function Combo()

	target = selector:find_target(R.range, mode_distance)

	local ComboKillR = GetQDmg(target) + GetEDmg(target) + GetRDmg(target)
	if menu:get_value(ziggs_combo_use_r) == 1 and menu:get_value(ziggs_combo_r_useage) == 0 then
		if myHero:distance_to(target.origin) <= QBounce.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) and ml.Ready(SLOT_E) and not KnockedUP(target) then
				if ComboKillR > target.health then
					CastR(target)
				end
			end
		end
	end
	if menu:get_value(ziggs_combo_use_r) == 1 and menu:get_value(ziggs_combo_r_useage) == 1 then
		if myHero:distance_to(target.origin) <= QBounce.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) and not KnockedUP(target) then
				if target:health_percentage() <= menu:get_value(ziggs_combo_r_burst_hp) then
					CastR(target)
				end
			end
		end
	end

	if menu:get_value(ziggs_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) and not KnockedUP(target) then
			CastE(target)
		end
	end

	if menu:get_value(ziggs_combo_use_q) == 1 then
	  if myHero:distance_to(target.origin) <= QNoBounce.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQNoBounce(target)
	 	end
 	end

	minions = game.minions
	for i, minion in ipairs(minions) do
		if menu:get_value(ziggs_combo_use_q) == 1 and menu:get_value(ziggs_combo_use_q_minion) == 1 then
		  if myHero:distance_to(minion.origin) <= QNoBounce.range and myHero:distance_to(target.origin) > QNoBounce.range and ml.IsValid(target) and ml.Ready(SLOT_Q) then
				if GetEnemyCountCicular(240, minion.origin) >= 1 then
		    	CastQMinion(minion)
		 		end
			end
	 	end
	end

	if menu:get_value(ziggs_combo_use_q) == 1 then
	  if myHero:distance_to(target.origin) <= QBounce.range and myHero:distance_to(target.origin) > QNoBounce.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    	CastQBounce(target)
			end
	 	end
 	end

	if menu:get_value(ziggs_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) and not TargetHasESlow(target) then
			if BlockW and w_cast ~= nil and client:get_tick_count() > w_cast then
				CastW(target)
			end
		end
		if ZiggsHasW() then
			CastW(target)
		end
	end
end

local function WBehindTarget()

	target = selector:find_target(W.range, mode_cursor)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if orbwalker:can_attack() and orbwalker:can_move() then
		if myHero:distance_to(target.origin) < TrueAARange then
			orbwalker:attack_target(target)
		end
	end

	local BehindRange = (W.range - 130)
	if myHero:distance_to(target.origin) <= BehindRange and ml.Ready(SLOT_W) then
		if ml.IsValid(target) and IsKillable(target) and myHero:distance_to(target.origin) <= W.range then
			behindpos = ml.Extend(myHero.origin, target.origin, 130)
			spellbook:cast_spell(SLOT_W, W.delay, behindpos.x, behindpos.y, behindpos.z)
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(R.range, mode_distance)

	if menu:get_value(ziggs_harass_use_e) == 1 then
	  if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
	    CastE(target)
	 	end
 	end

	if menu:get_value(ziggs_harass_use_q) == 1 then
	  if myHero:distance_to(target.origin) <= QNoBounce.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQNoBounce(target)
	 	end
 	end

	minions = game.minions
	for i, minion in ipairs(minions) do
		if menu:get_value(ziggs_harass_use_q) == 1 and menu:get_value(ziggs_harass_use_q_minion) == 1 then
			if myHero:distance_to(minion.origin) <= QNoBounce.range and myHero:distance_to(target.origin) > QNoBounce.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
				if GetEnemyCountCicular(240, minion.origin) >= 1 then
					CastQMinion(minion)
				end
			end
		end
	end

	if menu:get_value(ziggs_harass_use_q) == 1 then
	  if myHero:distance_to(target.origin) <= menu:get_value(ziggs_harass_q_range) and myHero:distance_to(target.origin) > QNoBounce.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    	CastQBounce(target)
			end
	 	end
 	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do

		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(ziggs_ks_use_r_ping) == 1 then
			if myHero:distance_to(target.origin) <= R.range then
				if GetRDmg(target) > target.health and ml.Ready(SLOT_R) and target.is_alive and target.is_visible then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					game:send_ping(x, y, z, PING_DEFAULT)
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QNoBounce.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(ziggs_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if ml.Ready(SLOT_Q) then
						CastQNoBounce(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= QBounce.range and myHero:distance_to(target.origin) > QNoBounce.range then
			if ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(ziggs_ks_use_q) == 1 then
					if GetQDmg(target) > target.health then
						if ml.Ready(SLOT_Q) then
							CastQBounce(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(ziggs_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if ml.Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and myHero:distance_to(target.origin) <= menu:get_value(ziggs_ks_use_r_range) then
			if ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(ziggs_ks_use_r) == 1 then
					if GetRDmg(target) > target.health then
						if ml.Ready(SLOT_R) and not KnockedUP(target)then
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

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ziggs_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 800
		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(ziggs_laneclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and ml.Ready(SLOT_E) then
				if GrabLaneClearMana and ml.Ready(SLOT_E) and TargetNearMouse then
					if GetMinionCount(E.width, target) >= menu:get_value(ziggs_laneclear_min_e) then
						pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, false)
						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end

		if menu:get_value(ziggs_laneclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QNoBounce.range then
				if GrabLaneClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					if GetMinionCount(Q.width, target) >= menu:get_value(ziggs_laneclear_min_q) then
						pred_output = pred:predict(Q.speed, Q.delay, QNoBounce.range, Q.width, target, false, false)
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

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(ziggs_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 800
		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(ziggs_jungleclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < E.range then
				if GrabJungleClearMana and ml.Ready(SLOT_E) and TargetNearMouse then
					pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, false)
					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end

		if menu:get_value(ziggs_jungleclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < QNoBounce.range then
				if GrabJungleClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					pred_output = pred:predict(Q.speed, Q.delay, QNoBounce.range, Q.width, target, false, false)
					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Auto R

local function AutoR()

	for i, target in ipairs(ml.GetEnemyHeroes()) do
	  if menu:get_value(ziggs_extra_r_number_use) == 1 then
			if myHero:distance_to(target.origin) <= menu:get_value(ziggs_extra_r_range) then
				if ml.IsValid(target) and ml.Ready(SLOT_R) then
					local CastPos, targets = GetBestAoEPosition(R.speed, R.delay, R.range, R.width, target, false, false)
					if CastPos and targets >= menu:get_value(ziggs_extra_r_number_count) then
						spellbook:cast_spell(SLOT_R, R.delay, CastPos.x, CastPos.y, CastPos.z)
					end
				end
	    end
	  end
	end
end

-- Auto Q

--[[local function AutoQ()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(ziggs_harass_min_mana) / 100

	for i, target in ipairs(ml.GetEnemyHeroes()) do
	  if menu:get_value(ziggs_extra_q_number_use) == 1 and GrabMana then
			if myHero:distance_to(target.origin) <= QBounce.range then
				if ml.IsValid(target) and ml.Ready(SLOT_Q) then
					local CastPos, targets = GetBestAoEPosition(Q.speed, Q.delay, QBounce.range, Q.width, target, false, false)
					if CastPos and targets >= menu:get_value(ziggs_extra_q_number_count) then
						spellbook:cast_spell(SLOT_Q, Q.delay, CastPos.x, CastPos.y, CastPos.z)
					end
				end
	    end
		end
  end
end]]

-- Auto Q Last Hit

local function AutoQLastHit()

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	minions = game.minions
	for i, target in ipairs(minions) do
	  if menu:get_value(ziggs_q_lasthit_use) == 1 and target.object_id ~= 0 and target.is_enemy then
			if GetQDmg(target) > target.health and myHero:distance_to(target.origin) > TrueAARange then
				if myHero:distance_to(target.origin) <= QNoBounce.range then
					if ml.IsValid(target) and ml.Ready(SLOT_Q) then
						CastQNoBounce(target)
					end
				end
	    end
		end
  end
end

-- AutoQImobli

local function AutoQImobli()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(ziggs_harass_min_mana) / 100

  target = selector:find_target(QBounce.range, mode_health)

  if menu:get_value(ziggs_extra_auto_q) == 1 and GrabMana then
    if myHero:distance_to(target.origin) <= QBounce.range then
			if IsImmobileTarget(target) then
				if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
					CastQBounce(target)
				end
			end
    end
  end
end

-- W Turret Cast

local function TurretWCast()

	if menu:get_value(ziggs_turret_w) == 1 then
		turrets = game.turrets
		for i, target in ipairs(turrets) do
			if ml.IsValid(target) and target.is_enemy and ml.Ready(SLOT_W) and myHero:distance_to(target.origin) <= W.range then
				if target:health_percentage() <= WTurretDMG[spellbook:get_spell_slot(SLOT_W).level] then
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

local function ManualR()

  target = selector:find_target(R.range, mode_cursor)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if orbwalker:can_attack() and orbwalker:can_move() then
		if myHero:distance_to(target.origin) < TrueAARange then
			orbwalker:attack_target(target)
		end
	end

  if game:is_key_down(menu:get_value(ziggs_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < R.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(ziggs_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
				if myHero:distance_to(obj.origin) < W.range and myHero:distance_to(dash_info.end_pos) < 500 and ml.Ready(SLOT_W) then
					CastW(obj)
					CastW2 = true
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) then
		if menu:get_value(ziggs_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
		   	if myHero:distance_to(obj.origin) < W.range and ml.Ready(SLOT_W) then
					CastW(obj)
					CastW2 = true
				end
			end
		end
	end
end

-- R Save me

local function RSaveMe()

  target = selector:find_target(W.range, mode_distance)

	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(ziggs_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(ziggs_extra_saveme_target) / 100

	if menu:get_value(ziggs_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < W.range then
			if myHero:distance_to(target.origin) < target.attack_range then
				if SaveMeHP and TargetHP then
					if target:is_facing(myHero) then
						if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
							CastW(target)
							CastW2 = true
						end
					end
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
	justme = myHero.origin
	turrets = game.turrets

	local medraw = game:world_to_screen(justme.x, justme.y, justme.z)
	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end


	if menu:get_value(ziggs_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, QBounce.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(ziggs_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(ziggs_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(ziggs_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 0, 255, 255, 255)
		end
	end

	if menu:get_value(ziggs_draw_r_minimap) == 1 then
		if ml.Ready(SLOT_R) then
			minimap:draw_circle(x, y, z, R.range, 0, 255, 255, 255)
		end
	end


	for i, turret in ipairs(turrets) do
		if menu:get_value(ziggs_draw_turrethp) == 1 then
			if myHero:distance_to(turret.origin) <= R.range and turret.is_enemy then
				if ml.IsValid(turret) and turret:health_percentage() <= WTurretDMG[spellbook:get_spell_slot(SLOT_W).level] and turret.is_on_screen then
					local torigin = turret.origin
					local tx, ty, tz = torigin.x, torigin.y, torigin.z
					local turretdraw = game:world_to_screen(tx, ty, tz)
					renderer:draw_text_big_centered(turretdraw.x, turretdraw.y, "[W] Can Kill Turret")
				end
			end
		end
	end

	if menu:get_toggle_state(ziggs_extra_gapclose) then
		if menu:get_value(ziggs_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [W] Anti Gap Closer Enabled")
		end
	end

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetRDmg(target)
		if ml.Ready(SLOT_Q) and ml.Ready(SLOT_R) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(ziggs_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(ziggs_draw_kill_healthbar) == 1 then
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

	if game:is_key_down(menu:get_value(ziggs_combokey)) and menu:get_value(ziggs_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if combo:get_mode() == MODE_LASTHIT then
		AutoQLastHit()
	end

	--AutoQ()
	AutoQImobli()
	AutoR()
	AutoKill()
	RSaveMe()
	TurretWCast()

	if game:is_key_down(menu:get_value(ziggs_extra_semi_r_key)) then
		ManualR()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(ziggs_extra_semi_w_key)) then
		WBehindTarget()
		orbwalker:move_to()
	end

	if BlockW and not ml.Ready(SLOT_W) and w_cast ~= nil and client:get_tick_count() > w_cast then
		BlockW = false
		w_cast = nil
	end

	if CastW2 then
		if ZiggsHasW() then
			CastWBlow()
		end
	end
	if not ml.Ready(SLOT_W) and not ZiggsHasW() then
		CastW2 = false
	end

end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
