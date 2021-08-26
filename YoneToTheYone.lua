if game.local_player.champ_name ~= "Yone" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 2.1
		local file_name = "YoneToTheYone.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/YoneToTheYone.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/YoneToTheYone.lua.version.txt")
        console:log("YoneToTheYone.Lua Vers: "..Version)
		console:log("YoneToTheYone.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log(".....Sexy Yone Successfully Loaded.....")

        else
			http:download_file(url, file_name)
            console:log("Sexy Yone Update available.....")
			console:log("Please Reload via F5!.....")
			console:log("-----------------------------")
			console:log("Please Reload via F5!.....")
			console:log("-----------------------------")
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

local myHero = game.local_player
local local_player = game.local_player

local Wcast = false
local AutoTime = nil
local AutoAATime = nil
local AAcast = false
local QDelayAS = 0
local WDelayAS = 0
local windup_end_time = nil

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 450, delay = .25 }
local Q3 = { range = 1000, delay = .25 }
local W = { range = 600, delay = .35, width = 700, speed = 0 }
local E = { range = 300, delay = .25, width = 225, speed = 0 }
local R = { range = 990, delay = .75, width = 226, speed = 0 }
local RF = { range = 1750, delay = .75, width = 225, speed = 0 }

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

local function IsYoneQ3()
	QSpell = spellbook:get_spell_slot(SLOT_Q)
	QData = QSpell.spell_data
	QName = QData.spell_name
	if QName == "yoneq3ready" then
		return true
	end
	return false
end

local function IsYoneQ()
	QSpell = spellbook:get_spell_slot(SLOT_Q)
	QData = QSpell.spell_data
	QName = QData.spell_name
	if QName == "YoneQ" then
		return true
	end
	return false
end

local function HasCastedYoneE(unit)
	if HasBuff(unit, "YoneE") then
		return true
	end
	return false
end

local function IsFlashSlotF()
flash = spellbook:get_spell_slot(SLOT_F)
FData = flash.spell_data
FName = FData.spell_name
--console:log(tostring(FName))
if FName == "SummonerFlash" then
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

local function GetGameTime()
	return tonumber(game.game_time)
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	yone_category = menu:add_category_sprite("Shaun's Sexy Yone", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	yone_category = menu:add_category("Shaun's Sexy Yone")
end

yone_enabled = menu:add_checkbox("Enabled", yone_category, 1)
yone_combokey = menu:add_keybinder("Combo Mode Key", yone_category, 32)
menu:add_label("Shaun's Sexy Yone", yone_category)
menu:add_label("#MassiveSword..Small Nose?", yone_category)

yone_prediction = menu:add_subcategory("[Pred Selection]", yone_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
yone_pred_useage = menu:add_combobox("[Pred Selection]", yone_prediction, e_table, 1)

yone_ark_pred = menu:add_subcategory("[Ark Pred Settings]", yone_prediction)
yone_ark_pred_q = menu:add_subcategory("[Q] Settings", yone_ark_pred, 1)
yone_q_hitchance = menu:add_slider("[Q] Yone Hit Chance [%]", yone_ark_pred_q, 1, 99, 50)
yone_q_speed = menu:add_slider("[Q] Yone Speed Input", yone_ark_pred_q, 1, 2500, 1500)
yone_q_range = menu:add_slider("[Q] Yone Range Input", yone_ark_pred_q, 1, 1000, 450)
yone_q_radius = menu:add_slider("[Q] Yone Radius Input", yone_ark_pred_q, 1, 500, 60)

yone_ark_pred_q3 = menu:add_subcategory("[Q3] Settings", yone_ark_pred, 1)
yone_q3_hitchance = menu:add_slider("[Q3] Yone Hit Chance [%]", yone_ark_pred_q3, 1, 99, 50)
yone_q3_speed = menu:add_slider("[Q3] Yone Speed Input", yone_ark_pred_q3, 1, 2500, 1500)
yone_q3_range = menu:add_slider("[Q3] Yone Range Input", yone_ark_pred_q3, 1, 2000, 1000)
yone_q3_radius = menu:add_slider("[Q3] Yone Radius Input", yone_ark_pred_q3, 1, 500, 100)

yone_ark_pred_w = menu:add_subcategory("[W] Settings", yone_ark_pred, 1)
yone_w_hitchance = menu:add_slider("[W] Yone Hit Chance [%]", yone_ark_pred_w, 1, 99, 50)
yone_w_range = menu:add_slider("[W] Yone Range Input", yone_ark_pred_w, 1, 1500, 600)
yone_w_angle = menu:add_slider("[W] Yone Angle Input", yone_ark_pred_w, 1, 500, 80)

yone_ark_pred_r = menu:add_subcategory("[R] Settings", yone_ark_pred, 1)
yone_r_hitchance = menu:add_slider("[R] Yone Hit Chance [%]", yone_ark_pred_r, 1, 99, 50)
yone_r_range = menu:add_slider("[R] Yone Range Input", yone_ark_pred_r, 1, 2500, 1000)
yone_r_radius = menu:add_slider("[R] Yone Radius Input", yone_ark_pred_r, 1, 500, 113)

yone_ks_function = menu:add_subcategory("[Kill Steal]", yone_category)
yone_ks_use_q = menu:add_checkbox("Use [Q]", yone_ks_function, 1)
yone_ks_use_w = menu:add_checkbox("Use [W]", yone_ks_function, 1)
yone_ks_use_r = menu:add_checkbox("Use [R]", yone_ks_function, 1)
yone_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", yone_ks_function)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(v.champ_name), yone_ks_r_blacklist, 1)
    end
end

yone_lasthit = menu:add_subcategory("[Last Hit]", yone_category)
yone_lasthit_use = menu:add_checkbox("Use [Q1] Last Hit", yone_lasthit, 1)
yone_lasthit_use_q3 = menu:add_checkbox("Use [Q3] Last Hit", yone_lasthit, 1)
yone_lasthit_use_toggle = menu:add_toggle("Use [Q] Last Hit Toggle", 1, yone_lasthit, 85, false)

yone_combo = menu:add_subcategory("[Combo]", yone_category)
yone_combo_q = menu:add_subcategory("[Q] Settings", yone_combo, 1)
yone_combo_first_aa = menu:add_checkbox("Use [AA] Before First [Q] In Combo", yone_combo_q, 1)
yone_combo_use_q = menu:add_checkbox("Use [Q]", yone_combo_q, 1)
yone_combo_q3_turret = menu:add_checkbox("[Q3] Turret Check", yone_combo_q, 1)
yone_combo_w = menu:add_subcategory("[W] Settings", yone_combo, 1)
yone_combo_use_w = menu:add_checkbox("Use [W]", yone_combo_w, 1)
yone_combo_use_w_aa = menu:add_checkbox("Use [W] Outside [AA] Range", yone_combo_w, 1)
yone_combo_e = menu:add_subcategory("[E] Settings", yone_combo, 1)
yone_combo_use_e = menu:add_checkbox("Use Smart [E]", yone_combo_e, 1)
yone_combo_r = menu:add_subcategory("[R] Settings", yone_combo, 1)
yone_combo_use_r = menu:add_checkbox("Use [R]", yone_combo_r, 1)
yone_combo_r_enemy_hp = menu:add_slider("Use Combo [R] if Enemy HP is lower than [%]", yone_combo_r, 1, 100, 50)
yone_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist",yone_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), yone_combo_r_blacklist, 1)
    end
end

yone_harass = menu:add_subcategory("[Harass]", yone_category)
yone_harass_use_q = menu:add_checkbox("Use [Q]", yone_harass, 1)
yone_harass_use_w = menu:add_checkbox("Use [W]", yone_harass, 1)

yone_laneclear = menu:add_subcategory("[Lane Clear]", yone_category)
yone_laneclear_use_q = menu:add_checkbox("Use [Q1]", yone_laneclear, 1)
yone_laneclear_use_q3 = menu:add_checkbox("Use [Q3]", yone_laneclear, 1)
yone_laneclear_use_w = menu:add_checkbox("Use [W]", yone_laneclear, 1)
yone_laneclear_min_q = menu:add_slider("Minimum Minion To [Q3]", yone_laneclear, 1, 10, 1)
yone_laneclear_min_w = menu:add_slider("Minimum Minion To [W]", yone_laneclear, 1, 10, 3)

yone_jungleclear = menu:add_subcategory("[Jungle Clear]", yone_category)
yone_jungleclear_use_q = menu:add_checkbox("Use [Q]", yone_jungleclear, 1)
yone_jungleclear_use_w = menu:add_checkbox("Use [W]", yone_jungleclear, 1)

yone_engage = menu:add_subcategory("[Yone Engage!]", yone_category)
yone_engage_enable = menu:add_checkbox("Enable Engage Function", yone_engage, 1)
yone_combo_F_E_R = menu:add_keybinder("Semi Manual [Flash] > [E] > [R] Key - Nearest To Cursor", yone_engage, 90)

yone_combo_r_options = menu:add_subcategory("[R] Features", yone_category)
yone_combo_r_turret = menu:add_checkbox("[R] All Usage Turret Check", yone_combo_r_options, 1)
yone_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key - Nearest To Cursor", yone_combo_r_options, 65)
yone_combo_r_auto = menu:add_checkbox("Use Auto [R]", yone_combo_r_options, 1)
yone_combo_r_auto_x = menu:add_slider("Number Of Targets To Perform Auto [R]", yone_combo_r_options, 1, 5, 3)

yone_draw = menu:add_subcategory("[Drawing] Features", yone_category)
yone_draw_q = menu:add_checkbox("Draw [Q]", yone_draw, 1)
yone_draw_w = menu:add_checkbox("Draw [W]", yone_draw, 1)
yone_draw_r = menu:add_checkbox("Draw [R]", yone_draw, 1)
yone_draw_RF = menu:add_checkbox("Draw [Flash] > [E] > [R] Range", yone_draw, 1)
yone_lasthit_toggle_draw = menu:add_checkbox("Draw [Q] Toggle Last Hit Text", yone_draw, 1)
yone_lasthit_draw = menu:add_checkbox("Draw Auto [Q] Last Hit", yone_draw, 1)
yone_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", yone_draw, 1)
yone_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", yone_draw, 1, "Health Bar Damage Is Computed From R, Q, W, E Return * 2 AA")

local function IsUnderTurret(unit)
    turrets = game.turrets
    for i, v in ipairs(turrets) do
        if v and v.is_enemy then
            local range = (v.bounding_radius / 2 + 775 + unit.bounding_radius / 2)
            if v.is_alive and menu:get_value(yone_combo_r_turret) == 1 then
                if v:distance_to(unit.origin) < range then
                    return true
                end
            end
        end
    end
    return false
end

local function IsUnderTurretQ3(unit)
    turrets = game.turrets
    for i, v in ipairs(turrets) do
        if v and v.is_enemy then
            local range = (v.bounding_radius / 2 + 775 + unit.bounding_radius / 2)
            if v.is_alive and menu:get_value(yone_combo_q3_turret) == 1 then
                if v:distance_to(unit.origin) < range then
                    return true
                end
            end
        end
    end
    return false
end

-- Damage

local function GetQDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_Q).level
	local BonusDmg = myHero.total_attack_damage
	local QDamage = (({20, 40, 60, 80, 100})[level] + BonusDmg)
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
	local BonusDmg = ({0.055, 0.06, 0.065, 0.07, 0.075})[level] * unit.max_health
	local WDamage = (({5, 10, 15, 20, 25})[level] + BonusDmg)
	if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_phys_damage(Damage)
end

local function GetRDmg(unit)
	local Damage = 0
	local level = spellbook:get_spell_slot(SLOT_R).level
	local BonusDmg = (0.4 * myHero.total_attack_damage)
	local RDamage = (({100, 200, 300})[level] + BonusDmg)
	if HasHealingBuff(unit) then
			Damage = RDamage - 10
	else
			Damage = RDamage
	end
	return unit:calculate_phys_damage(Damage)
end

local Q_input = {
    source = myHero,
    speed = menu:get_value(yone_q_speed), range = menu:get_value(yone_q_range),
    delay = QDelayAS, radius = menu:get_value(yone_q_radius),
    collision = {},
    type = "linear", hitbox = true
}

local Q3_input = {
    source = myHero,
		speed = menu:get_value(yone_q3_speed), range = menu:get_value(yone_q3_range),
		delay = QDelayAS, radius = menu:get_value(yone_q3_radius),
    collision = {},
    type = "linear", hitbox = true
}

local W_input = {
    source = myHero,
    speed = math.huge, range = menu:get_value(yone_w_range),
    delay = WDelayAS, angle = menu:get_value(yone_w_angle),
    collision = {},
    type = "conic", hitbox = false
}

local R_input = {
    source = myHero,
    speed = math.huge, range = menu:get_value(yone_r_range),
    delay = 0.75, radius = menu:get_value(yone_r_radius),
    collision = {},
    type = "linear", hitbox = true
}


-- Casting

local function CastQ(unit)

	if IsYoneQ() and Ready(SLOT_Q) then
		origin = unit.origin
		x, y, z = origin.x, origin.y, origin.z
		spellbook:cast_spell(SLOT_Q, QDelayAS, x, y, z)
	end
	if menu:get_value(yone_pred_useage) == 1 and Ready(SLOT_Q) then
		local output = arkpred:get_prediction(Q_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(yone_q_hitchance) / 100 and inv < (QDelayAS / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, QDelayAS, p.x, p.y, p.z)
		end
	end

end

local function CastQ3(unit)

	if menu:get_value(yone_pred_useage) == 0 then
		if IsYoneQ3() and Ready(SLOT_Q) then
			if unit.object_id ~= 0 then
				if Ready(SLOT_Q) then
					origin = unit.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_Q, QDelayAS, x, y, z)
				end
			end
		end
	end

	if menu:get_value(yone_pred_useage) == 1 and IsYoneQ3() and Ready(SLOT_Q) then
		local output = arkpred:get_prediction(Q3_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(yone_q3_hitchance) / 100 and inv < (QDelayAS / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, QDelayAS, p.x, p.y, p.z)
		end
	end
end

local function CastW(unit)

	if unit.object_id ~= 0 then
		if Ready(SLOT_W) then
			origin = unit.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(W.speed, WDelayAS, W.range, W.width, unit, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_W, WDelayAS, castPos.x, castPos.y, castPos.z)
			end
		end
	end

	if menu:get_value(yone_pred_useage) == 1 and Ready(SLOT_W) then
		local output = arkpred:get_prediction(W_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(yone_w_hitchance) / 100 and inv < (WDelayAS / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_W, WDelayAS, p.x, p.y, p.z)
		end
	end
end

local function CastR(unit)

	if menu:get_value(yone_pred_useage) == 0 then
		pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(yone_pred_useage) == 1 then
		local output = arkpred:get_prediction(R_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(yone_r_hitchance) / 100 and inv < (R_input.delay / 2) then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, p.x, p.y, p.z)
		end
	end
end

-- Combo

local function Combo()

	local Auto = myHero:get_basic_attack_data()
	local CastDelay = Auto.attack_cast_delay
	local AutoAA = myHero:get_basic_attack_data()
	local CastAADelay = AutoAA.attack_cast_delay

	target = selector:find_target(R.range, mode_health)
	qtarget = selector:find_target(Q.range, mode_health)

	if menu:get_value(yone_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q3.range and IsValid(target) and IsKillable(target) and Ready(SLOT_Q) then
			if AutoAATime ~= nil and AutoAATime + CastAADelay < tonumber(game.game_time) then
				if menu:get_value(yone_combo_first_aa) == 1 and AAcast and not IsYoneQ3() and Ready(SLOT_Q) then
					CastQ(target)
					AAcast = false
				end
			end
		end
	end

	if menu:get_value(yone_combo_use_q) == 1 then
		if myHero:distance_to(qtarget.origin) <= Q.range and IsValid(qtarget) and IsKillable(qtarget) then
			if menu:get_value(yone_combo_first_aa) == 0 or not Ready(SLOT_W) and not IsYoneQ3() and Ready(SLOT_Q) then
				CastQ(qtarget)
			end
		end
	end

	if menu:get_value(yone_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q3.range and IsValid(target) and IsKillable(target) and not IsUnderTurretQ3(target) then
			if IsYoneQ3() and Ready(SLOT_Q) then
				CastQ3(target)
				console:log("1")
			end
		end
	end

	if menu:get_value(yone_combo_use_w) == 1 then
		if myHero:distance_to(qtarget.origin) <= W.range and IsValid(qtarget) and IsKillable(qtarget) and Ready(SLOT_W) then
			if AutoTime ~= nil and AutoTime + CastDelay < tonumber(game.game_time) and not Ready(SLOT_Q) then
				if Wcast then
					CastW(qtarget)
					Wcast = false
				end
			end
		end
	end

	if menu:get_value(yone_combo_use_w) == 1 and menu:get_value(yone_combo_use_w_aa) == 1 then
		if myHero:distance_to(qtarget.origin) <= W.range and IsValid(qtarget) and IsKillable(qtarget) and Ready(SLOT_W) then
			if myHero:distance_to(qtarget.origin) > myHero.attack_range then
				CastW(qtarget)
			end
		end
	end

	local EDmgCheck = GetQDmg(target) + GetWDmg(target) + GetRDmg(target) + myHero.total_attack_damage * 3
	if menu:get_value(yone_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if target.health < EDmgCheck then
				if not Ready(SLOT_Q) and Ready(SLOT_E) and not HasCastedYoneE(myHero) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
				end
			end
		end
	end

	if menu:get_value(yone_combo_use_r) == 1 then
		if myHero:distance_to(target.origin) <= R.range and IsValid(target) and IsKillable(target) then
			if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
				if target:health_percentage() <= menu:get_value(yone_combo_r_enemy_hp) and not IsUnderTurret(target) and  Ready(SLOT_R) then
					CastR(target)
				end
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(R.range, mode_health)
	qtarget = selector:find_target(Q.range, mode_health)

	if menu:get_value(yone_harass_use_q) == 1 and IsYoneQ() then
		if myHero:distance_to(qtarget.origin) <= Q.range and IsValid(qtarget) and IsKillable(qtarget) and Ready(SLOT_Q) then
			CastQ(qtarget)
		end
	end

	if menu:get_value(yone_harass_use_q) == 1 and IsYoneQ3() then
		if myHero:distance_to(target.origin) <= Q3.range and IsValid(target) and IsKillable(target) and not IsUnderTurretQ3(target) and Ready(SLOT_Q) then
			CastQ3(target)
		end
	end


	if menu:get_value(yone_harass_use_w) == 1 then
		if myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) and Ready(SLOT_W) then
			CastW(target)
		end
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and Ready(SLOT_Q) and IsValid(target) and IsKillable(target) then
			if menu:get_value(yone_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <=  W.range and Ready(SLOT_W) and IsValid(target) and IsKillable(target) then
			if menu:get_value(yone_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
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
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and Ready(SLOT_R) and IsValid(target) and IsKillable(target) then
			if menu:get_value(yone_ks_use_r) == 1 then
				if GetRDmg(target) > target.health then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
						if Ready(SLOT_R) and not IsUnderTurret(target) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

							if pred_output.can_cast then
	        			castPos = pred_output.cast_pos
	        			spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
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
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(yone_laneclear_use_q) == 1 and not IsYoneQ3() then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if not orbwalker:can_attack() or myHero:distance_to(target.origin) > myHero.attack_range then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					end
				end
			end
		end

		if menu:get_value(yone_laneclear_use_q3) == 1 and menu:get_value(yone_laneclear_use_q) == 1 and IsYoneQ3() then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q3.range and IsValid(target) then
				if GetMinionCount(300, target) >= menu:get_value(yone_laneclear_min_q) then
					if not orbwalker:can_attack() or myHero:distance_to(target.origin) > myHero.attack_range then
						if Ready(SLOT_Q) and not IsUnderTurretQ3(myHero) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						end
					end
				end
			end
		end

		if menu:get_value(yone_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range and IsValid(target) then
				if GetMinionCount(W.range, target) >= menu:get_value(yone_laneclear_min_w) then
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

		if target.object_id ~= 0 and menu:get_value(yone_jungleclear_use_q) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if Ready(SLOT_Q) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
			end
		end
		if target.object_id ~= 0 and menu:get_value(yone_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < W.range and IsValid(target) then
			if not Ready(SLOT_Q) then
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
		if Ready(SLOT_R) and IsValid(target) and IsKillable(target) and not IsUnderTurret(target) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Manual F > E > R Cast

local function EFlashRCast()

	local attackRange = myHero.attack_range
	if orbwalker:can_attack() and orbwalker:can_move() then
		if myHero:distance_to(target.origin) < attackRange then
			orbwalker:attack_target(target)
		end
	end

	if IsFlashSlotF() then

		target = selector:find_target(RF.range, mode_cursor)
		if target.object_id ~= 0 then
			if Ready(SLOT_R) and Ready(SLOT_F) and Ready(SLOT_E) and IsValid(target) and IsKillable(target) and not IsUnderTurret(target) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_F, 0.1, x, y, z)
			end
		end


		if target.object_id ~= 0 then
			if not Ready(SLOT_F) and Ready(SLOT_E) and not HasCastedYoneE(myHero) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
			end
		end

		if not Ready(SLOT_F) and Ready(SLOT_R) and HasCastedYoneE(myHero) then
			Rtarget = selector:find_target(R.range, mode_cursor)
			origin = Rtarget.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
			end
		end

	else

		target = selector:find_target(RF.range, mode_cursor)
		if target.object_id ~= 0 then
			if Ready(SLOT_R) and Ready(SLOT_D) and Ready(SLOT_E) and not IsUnderTurret(target) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_D, 0.1, x, y, z)
			end
		end


		if target.object_id ~= 0 then
			if not Ready(SLOT_D) and Ready(SLOT_E) and not HasCastedYoneE(myHero) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
			end
		end

		if not Ready(SLOT_D) and Ready(SLOT_R) and HasCastedYoneE(myHero) then
			Rtarget = selector:find_target(R.range, mode_cursor)
			origin = Rtarget.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Auto R >= Targets

function AutoR()
  local Count = 0
  players = game.players
  for _, target in ipairs(players) do
    if Ready(SLOT_R) and target.is_enemy and IsValid(target) and myHero:distance_to(target.origin) <= R.range and not IsUnderTurret(target) then
      pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)
      output = pred_output.cast_pos

			local Count = GetLineTargetCount(myHero, output, R.delay, R.range, R.width / 2)
      if Count >= menu:get_value(yone_combo_r_auto_x) then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Auto Q last Hit

local function AutoQLastHit(target)
	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) and not IsYoneQ3() then
			if GetMinionCount(Q.range, target) >= 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					end
				end
			end
		end
		if menu:get_value(yone_lasthit_use_q3) == 1 and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q3.range and IsValid(target) and IsYoneQ3() then
			if GetMinionCount(Q.range, target) >= 1 then
				if GetQDmg(target) > target.health then
					if myHero:distance_to(target.origin) > myHero.attack_range then
						if Ready(SLOT_Q) and not IsUnderTurretQ3(target) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						end
					end
				end
			end
		end
	end
end

--[[local function on_active_spell(obj, active_spell)

	if Is_Me(obj) then
		if active_spell.spell_name == "YoneBasicAttack"
		or active_spell.spell_name == "YoneBasicAttack2"
		or active_spell.spell_name == "YoneBasicAttack3"
		or active_spell.spell_name == "YoneBasicAttack4"
		or active_spell.spell_name == "YoneCritAttack"
		or active_spell.spell_name == "YoneCritAttack2"
		or active_spell.spell_name == "YoneCritAttack3"
		or active_spell.spell_name == "YoneCritAttack4" then
			AutoTime = game.game_time
			Wcast = true
		end

	if active_spell.spell_name == "YoneBasicAttack"
	or active_spell.spell_name == "YoneBasicAttack2"
	or active_spell.spell_name == "YoneBasicAttack3"
	or active_spell.spell_name == "YoneBasicAttack4"
	or active_spell.spell_name == "YoneCritAttack"
	or active_spell.spell_name == "YoneCritAttack2"
	or active_spell.spell_name == "YoneCritAttack3"
	or active_spell.spell_name == "YoneCritAttack4" then
			AutoAATime = game.game_time
			AAcast = true
		end
	end
end]]

--[[function on_process_spell(unit, args)
	if unit ~= myHero then return end
  windup_end_time = args.cast_time + args.cast_delay

	if args.is_autoattack then
		AutoAATime = game.game_time
		AAcast = true
		AutoTime = game.game_time
		Wcast = true
	end
end]]

local function on_active_spell(obj, active_spell)

	if obj ~= myHero then return end
	windup_end_time = active_spell.cast_end_time

	if active_spell.is_autoattack then
		AutoAATime = game.game_time
		AAcast = true
		AutoTime = game.game_time
		Wcast = true
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

	if menu:get_value(yone_draw_q) == 1 then
		if Ready(SLOT_Q) and not IsYoneQ3() then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(yone_draw_q) == 1 then
		if Ready(SLOT_Q) and IsYoneQ3(myHero) then
			renderer:draw_circle(x, y, z, Q3.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(yone_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 0, 0, 255, 255)
		end
	end

	if menu:get_value(yone_draw_RF) == 1 then
		if Ready(SLOT_R) and Ready(SLOT_F) and Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, RF.range, 225, 255, 0, 255)
		end
	end

	if menu:get_value(yone_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 225, 0, 0, 255)
		end
	end

	if menu:get_value(yone_lasthit_toggle_draw) == 1 then
		if menu:get_value(yone_lasthit_use) == 1 then
			if menu:get_toggle_state(yone_lasthit_use_toggle) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [Q] Last Hit Enabled")
			end
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target) + myHero.total_attack_damage * 2
		if Ready(SLOT_Q) and Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
				if menu:get_value(yone_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(yone_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(yone_combokey)) or game:is_key_down(menu:get_value(yone_combo_F_E_R)) and menu:get_value(yone_enabled) == 1 then
		Combo()
	end

	if not game:is_key_down(menu:get_value(yone_combokey)) then
		AutoTime = nil
		Wcast = false
		AutoAATime = nil
		AAcast = false
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(yone_combo_r_set_key)) then
		ManualRCast()
	end

	if game:is_key_down(menu:get_value(yone_combo_F_E_R)) and menu:get_value(yone_engage_enable) == 1 then
		orbwalker:move_to()
		EFlashRCast()
	end

	if menu:get_value(yone_combo_r_auto) == 1 then
		AutoR()
	end

	if combo:get_mode() == MODE_LASTHIT and not menu:get_toggle_state(yone_lasthit_use_toggle) and menu:get_value(yone_lasthit_use) == 1 then
		if not game:is_key_down(menu:get_value(yone_combokey)) then
			AutoQLastHit()
		end
	end

	if menu:get_toggle_state(yone_lasthit_use_toggle) and menu:get_value(yone_lasthit_use) == 1 then
		if not game:is_key_down(menu:get_value(yone_combokey)) then
			AutoQLastHit()
		end
	end

	KillSteal()

	myHero = game.local_player
	YoneAS = (myHero.bonus_attack_speed - 1) * 100
	if YoneAS < 15 then
		QDelayAS = 0.4
	elseif YoneAS < 30 and YoneAS >= 15 then
		QDelayAS = 0.364
	elseif YoneAS < 45 and YoneAS >= 30 then
		QDelayAS = 0.328
	elseif YoneAS < 60 and YoneAS >= 45 then
		QDelayAS = 0.292
	elseif YoneAS < 75 and YoneAS >= 60 then
		QDelayAS = 0.256
	elseif YoneAS < 90 and YoneAS >= 75 then
		QDelayAS = 0.22
	elseif YoneAS < 105 and YoneAS >= 90 then
		QDelayAS = 0.184
	elseif YoneAS < 111.11 and YoneAS >= 105 then
		QDelayAS = 0.148
	elseif YoneAS >= 111.11 then
		QDelayAS = 0.133
	end

	if YoneAS < 10.5 then
		WDelayAS = 0.5
	elseif YoneAS < 21 and YoneAS >= 10.5 then
		WDelayAS = 0.47
	elseif YoneAS < 31.5 and YoneAS >= 21 then
		WDelayAS = 0.44
	elseif YoneAS < 42 and YoneAS >= 31.5 then
		WDelayAS = 0.41
	elseif YoneAS < 52.5 and YoneAS >= 42 then
		WDelayAS = 0.38
	elseif YoneAS < 63 and YoneAS >= 52.5 then
		WDelayAS = 0.34
	elseif YoneAS < 73.5 and YoneAS >= 63 then
		WDelayAS = 0.31
	elseif YoneAS < 84 and YoneAS >= 73.5 then
		WDelayAS = 0.28
	elseif YoneAS < 94.5 and YoneAS >= 84 then
		WDelayAS = 0.25
	elseif YoneAS < 105 and YoneAS >= 94.5 then
		WDelayAS = 0.22
	elseif YoneAS >= 105 then
		WDelayAS = 0.19
	end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_active_spell", on_active_spell)
--client:set_event_callback("on_process_spell", on_process_spell)
