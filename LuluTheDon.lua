if game.local_player.champ_name ~= "Lulu" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.2
		local file_name = "LuluTheDon.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/LuluTheDon.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/LuluTheDon.lua.version.txt")
        console:log("LuluTheDon.lua Vers: "..Version)
		console:log("LuluTheDon.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then

            console:log("....Shaun's Sexy Lulu Successfully Loaded...")


        else
			http:download_file(url, file_name)
			      console:log("Sexy lulu Update available.....")
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
local PixyOnline = false


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 925, delay = .25, width = 60, speed = 1600 }
local Q2 = { range = 1600, delay = .5, width = 60, speed = 1600 }
local W = { range = 650, delay = .25, width = 0, speed = math.huge }
local E = { range = 650, delay = .1, width = 0, speed = math.huge }
local R = { range = 900, delay = .1, width = 400, speed = math.huge }


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

-- GetLineTargetCount Start --

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

-- GetLineTargetCount End --

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

local function GetEnemyCountCicular(range, target)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if unit.is_enemy and GetDistanceSqr2(target.origin, unit.origin) < Range and IsValid(unit) then
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
	if unit:has_buff(bufname) then
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
	lulu_category = menu:add_category_sprite("Shaun's Sexy Lulu", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	lulu_category = menu:add_category("Shaun's Sexy Lulu")
end

lulu_enabled = menu:add_checkbox("Enabled", lulu_category, 1)
lulu_combokey = menu:add_keybinder("Combo Mode Key", lulu_category, 32)
menu:add_label("Welcome To Shaun's Sexy Lulu", lulu_category)
menu:add_label("#LetsMakeYouBigBaby", lulu_category)

lulu_combo = menu:add_subcategory("Combo", lulu_category)
lulu_combo_q = menu:add_subcategory("[Q] Settings", lulu_combo, 1)
lulu_combo_use_q = menu:add_checkbox("Use [Q]", lulu_combo_q, 1)

lulu_combo_w = menu:add_subcategory("[W] Settings", lulu_combo, 1)
lulu_combo_use_w = menu:add_checkbox("Use [W]", lulu_combo_w, 1)
lulu_w_allyblacklist = menu:add_subcategory("Ally [W] Blacklist", lulu_combo_w)
players = game.players
for _, v in ipairs(players) do
	if not v.is_enemy and v.object_id ~= myHero.object_id then
		menu:add_checkbox("Use W On : "..tostring(v.champ_name), lulu_w_allyblacklist, 1)
	end
end
lulu_combo_e = menu:add_subcategory("[E] Settings", lulu_combo, 1)
lulu_combo_use_e = menu:add_checkbox("Use [E]", lulu_combo_e, 1)
lulu_combo_e_ally_hp = menu:add_slider("[E] Ally HP is lower than [%]", lulu_combo_e, 1, 100, 40)
lulu_combo_e_me_hp = menu:add_slider("[E] Myself HP is lower than [%]", lulu_combo_e, 1, 100, 10)
lulu_e_allyblacklist = menu:add_subcategory("Ally [E] Blacklist", lulu_combo_e)
players = game.players
for _, v in ipairs(players) do
	if not v.is_enemy and v.object_id ~= myHero.object_id then
		menu:add_checkbox("Use E On : "..tostring(v.champ_name), lulu_e_allyblacklist, 1)
	end
end
lulu_combo_r = menu:add_subcategory("[R] Settings", lulu_combo)
lulu_combo_use_r = menu:add_checkbox("Use [R]", lulu_combo_r, 1)
lulu_combo_r_ally_hp = menu:add_slider("[R] Ally HP is lower than [%]", lulu_combo_r, 1, 100, 30)
lulu_combo_r_me_hp = menu:add_slider("[R] Myself HP is lower than [%]", lulu_combo_r, 1, 100, 10)
lulu_r_allyblacklist = menu:add_subcategory("[R] Ally Blacklist", lulu_combo_r)
players = game.players
for _, v in ipairs(players) do
	if not v.is_enemy and v.object_id ~= myHero.object_id then
		menu:add_checkbox("Use R On : "..tostring(v.champ_name), lulu_r_allyblacklist, 1)
	end
end
lulu_harass = menu:add_subcategory("Harass", lulu_category)
lulu_harass_q = menu:add_subcategory("[Q] Settings", lulu_harass, 1)
lulu_harass_use_q = menu:add_checkbox("Use [Q]", lulu_harass_q, 1)
lulu_harass_use_q_ext = menu:add_checkbox("Use [Q] Extended", lulu_harass_q, 1)
lulu_harass_use_w = menu:add_checkbox("Use [W]", lulu_harass, 1)

lulu_ks = menu:add_subcategory("Kill Steal", lulu_category)
lulu_ks_use_q = menu:add_checkbox("Use [Q]", lulu_ks , 1)
lulu_ks_use_e = menu:add_checkbox("Use [E]", lulu_ks , 1)

lulu_extra = menu:add_subcategory("Automated Features", lulu_category)
lulu_manual_r_use = menu:add_subcategory("Semi Manual [R] Settings", lulu_extra)
lulu_manual_r_key = menu:add_keybinder("Semi Manual [R] Key - Myself When Ally > R Range", lulu_manual_r_use, 90)
lulu_manual_r_ally_hp = menu:add_slider("Semi Manual [R] - Ally HP is lower than [%]", lulu_manual_r_use, 1, 100, 30)
lulu_r_knockup_use = menu:add_subcategory("Auto [R] Knockup", lulu_extra, 1)
lulu_r_knockup = menu:add_checkbox("Use Auto [R] Knockup", lulu_r_knockup_use, 1)
lulu_r_knockup_min = menu:add_slider("Minimum Number Of Targets To Knock Up", lulu_r_knockup_use, 1, 5, 3)
--lulu_aoe_q = menu:add_checkbox("Auto AoE Q", lulu_extra, 1)
--lulu_aoe_q_min = menu:add_slider("Minimum Number Of Targets To AoE Q", lulu_extra, 1, 5, 3)
lulu_w_interrupt = menu:add_checkbox("Auto [W] Interrupt Major Channel Spells", lulu_extra, 1)
lulu_w_gap = menu:add_checkbox("Auto [W] Gap Closer", lulu_extra, 1)

lulu_laneclear = menu:add_subcategory("Lane Clear", lulu_category)
lulu_laneclear_use_q = menu:add_checkbox("Use [Q]", lulu_laneclear, 1)
lulu_laneclear_use_w = menu:add_checkbox("Use [W] Ally Or Self", lulu_laneclear, 1)
lulu_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q] & [W]", lulu_laneclear, 1, 10, 3)

lulu_draw = menu:add_subcategory("The Drawing Features", lulu_category)
lulu_draw_q = menu:add_checkbox("Draw [Q] Range", lulu_draw, 1)
lulu_draw_q_ext = menu:add_checkbox("Draw [Q] Extended Range", lulu_draw, 1)
lulu_draw_w = menu:add_checkbox("Draw [W] & [E] Range", lulu_draw, 1)
lulu_draw_r = menu:add_checkbox("Draw [R] Range", lulu_draw, 1)
lulu_draw_r_knockup = menu:add_checkbox("Draw [R] Knockup Range", lulu_draw, 1)


local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = 0
  local QDamage = ({70, 105, 140, 175, 210})[level] + 0.5 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_E).level
  local BonusDmg = 0
  local EDamage = ({80, 120, 160, 200, 240})[level] + 0.4 * myHero.ability_power
  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_magic_damage(Damage)
end

-- Casting

local function CastQ(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW(unit)
	spellbook:cast_spell_targetted(SLOT_W, unit, W.delay)
end

local function CastE(unit)
	spellbook:cast_spell_targetted(SLOT_E, unit, E.delay)
end

local function CastR(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

-- Combo

local function Combo()

	target = selector:find_target(2000, mode_health)

	players = game.players
	for _, ally in ipairs(players) do

		if menu:get_value(lulu_combo_use_r) == 1 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if ally:health_percentage() <= menu:get_value(lulu_combo_r_ally_hp) then
					if menu:get_value_string("Use R On : "..tostring(ally.champ_name)) == 1 then
						if ally:distance_to(target.origin) <= Q.range and IsValid(target) and IsValid(ally) then
							if Ready(SLOT_R) and ally:distance_to(myHero.origin) <= R.range then
								CastR(ally)
							end
						end
					end
				end
			end
		end

		if menu:get_value(lulu_combo_use_r) == 1 then
			if myHero:health_percentage() <= menu:get_value(lulu_combo_r_me_hp) then
				if Ready(SLOT_R) and target:distance_to(myHero.origin) <= Q.range then
					CastR(myHero)
				end
			end
		end

		if menu:get_value(lulu_combo_use_q) == 1 then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) then
					CastQ(target)
				end
			end
		end

		if menu:get_value(lulu_combo_use_w) == 1 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if ally:distance_to(target.origin) <= ally.attack_range and IsValid(target) and IsKillable(target) and IsValid(ally) then
					if menu:get_value_string("Use W On : "..tostring(ally.champ_name)) == 1 then
						if Ready(SLOT_W) and myHero:distance_to(ally.origin) <= W.range then
							CastW(ally)
						end
					end
				end
			end
		end

		if menu:get_value(lulu_combo_use_w) == 1 then
			if myHero:distance_to(ally.origin) > Q.range and myHero:distance_to(target.origin) <= myHero.attack_range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) then
					CastW(myHero)
				end
			end
		end

		local AllyHP = ally.health/ally.max_health <= menu:get_value(lulu_combo_e_ally_hp) / 100
		if menu:get_value(lulu_combo_use_e) == 1 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if AllyHP then
					if menu:get_value_string("Use E On : "..tostring(ally.champ_name)) == 1 then
						if ally:distance_to(target.origin) <= Q.range and IsValid(target) and IsValid(ally) then
							if Ready(SLOT_E) and ally:distance_to(myHero.origin) <= E.range then
								CastE(ally)
							end
						end
					end
				end
			end
		end

		local MyHP = myHero.health/myHero.max_health <= menu:get_value(lulu_combo_e_me_hp) / 100
		if menu:get_value(lulu_combo_use_e) == 1 then
			if MyHP then
				if ally:distance_to(myHero.origin) > E.range and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
					if Ready(SLOT_E) then
						CastE(myHero)
					end
				end
			end
		end
	end
end

local function QExtended()

	target = selector:find_target(Q2.range, mode_health)

	minions = game.minions
	for i, minion in ipairs(minions) do

		if menu:get_value(lulu_harass_use_q) == 1 and menu:get_value(lulu_harass_use_q_ext) == 1 then
			if IsValid(minion) and minion.object_id ~= 0 and minion.is_enemy and myHero:distance_to(minion.origin) < E.range then
				if myHero:distance_to(target.origin) < Q2.range and myHero:distance_to(target.origin) > Q.range and Ready(SLOT_E) and Ready(SLOT_Q) then
					CastE(minion)
					PixyOnline = true
				end
			end
		end

		if PixyOnline and minion:distance_to(target.origin) < Q2.range then
			if Ready(SLOT_Q) and not Ready(SLOT_E) then
				pred_output = pred:predict(Q.speed, Q.delay, Q2.range, Q.width, target, false, false)
				if pred_output.can_cast then
					castPos = pred_output.cast_pos
					spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
				end

				if not Ready(SLOT_E) and not Ready(SLOT_Q) then
					PixyOnline = false
				end
			end
		end

		if menu:get_value(lulu_harass_use_q) == 1 and menu:get_value(lulu_harass_use_q_ext) == 1 then
			if myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_E) then
				CastE(target)
				PixyOnline = true
				end
			end
		end

		if PixyOnline and myHero:distance_to(target.origin) < Q.range then
			if Ready(SLOT_Q) and not Ready(SLOT_E) then
				pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
				if pred_output.can_cast then
					castPos = pred_output.cast_pos
					spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
				end

				if not Ready(SLOT_E) and not Ready(SLOT_Q) then
					PixyOnline = false
				end
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(Q2.range, mode_health)

	players = game.players
	for _, ally in ipairs(players) do

		if menu:get_value(lulu_harass_use_q) == 1 then
			if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_Q) and not Ready(SLOT_E) and not PixyOnline then
					CastQ(target)
				end
			end
		end

		if menu:get_value(lulu_harass_use_w) == 1 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if ally:distance_to(target.origin) <= ally.attack_range and IsValid(target) and IsKillable(target) and IsValid(ally) then
					if Ready(SLOT_W) and ally:distance_to(target.origin) <= ally.attack_range then
						CastW(ally)
					end
				end
			end
		end

		if menu:get_value(lulu_harass_use_w) == 1 then
			if ally:distance_to(myHero.origin) > Q.range and myHero:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) then
				if Ready(SLOT_W) and ally:distance_to(target.origin) >= ally.attack_range then
					CastW(myHero)
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	minions = game.minions
	for i, target in ipairs(minions) do


		if menu:get_value(lulu_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, myHero) >= menu:get_value(lulu_laneclear_q_min) then
					if Ready(SLOT_Q) then

						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)

						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end

		players = game.players
		for _, ally in ipairs(players) do

			if menu:get_value(lulu_laneclear_use_w) == 1 then
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if ally:distance_to(target.origin) <= W.range and IsValid(target) and IsKillable(target) and IsValid(ally) then
						if Ready(SLOT_W) and ally:distance_to(myHero.origin) <= W.range then
							CastW(ally)
						end
					end
				end
			end

			if menu:get_value(lulu_laneclear_use_w) == 1 then
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if myHero:distance_to(ally.origin) > W.range and target:distance_to(myHero.origin) < W.range and IsValid(target) and IsKillable(target) then
						if Ready(SLOT_W) then
							CastW(myHero)
						end
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
			if menu:get_value(lulu_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= E.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(lulu_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end
	end
end

-- Auto R

local function AutoR()

	players = game.players
	for _, ally in ipairs(players) do

		if Ready(SLOT_R) and menu:get_value(lulu_r_knockup) == 1 then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if GetEnemyCountCicular(R.width, ally) >= menu:get_value(lulu_r_knockup_min) then
					CastR(ally)
				end
			end
		end

		if Ready(SLOT_R) and menu:get_value(lulu_r_knockup) == 1 then
			if GetEnemyCountCicular(R.width, myHero) >= menu:get_value(lulu_r_knockup_min) then
				CastR(myHero)
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	players = game.players
	for _, ally in ipairs(players) do

		if game:is_key_down(menu:get_value(lulu_manual_r_key)) then
			if not ally.is_enemy and ally.object_id ~= myHero.object_id then
				if ally:health_percentage() <= menu:get_value(lulu_manual_r_ally_hp) then
					if Ready(SLOT_R) and ally:distance_to(myHero.origin) <= R.range then
						CastR(ally)
					end
				end
			end
		end

		if game:is_key_down(menu:get_value(lulu_manual_r_key)) then
			if Ready(SLOT_R) and ally:distance_to(myHero.origin) >= R.range then
				CastR(myHero)
			end
		end
	end
end

-- Auto E --

--[[local function AutoE()
	players = game.players
	for _, v in ipairs(players) do
		----------------------------- Ally E--------------------------
		if not v.is_enemy and v.object_id ~= myHero.object_id then
			if menu:get_value(lulu_auto_ally) == 1 and Ready(SLOT_E) then
				if v and myHero:distance_to(v.origin) < E.range and IsValid(v) then
					if v:health_percentage() <= menu:get_value(lulu_auto_ally_hp) then
						if menu:get_value_string("Use E On : "..v.champ_name) == 1 then
							CastE(v)
						end
					end
				end
			end
		end
		--------------------------- Self E -----------------------------
		if Is_Me(v) then
			if menu:get_value(lulu_auto_self) == 1 and Ready(SLOT_E) and IsValid(v) then
				if v:health_percentage() <= menu:get_value(lulu_auto_self_hp) then
					CastE(v)
				end
			end
		end
	end
end]]

-- Anti W Gap

local function on_gap_close(obj, data)

	if IsValid(obj) and menu:get_value(lulu_w_gap) == 1 then
		if myHero:distance_to(obj.origin) <= W.range and Ready(SLOT_W) then
			CastW(obj)
		end
	end
end

-- Anti W Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(lulu_w_interrupt) == 1 then
      if myHero:distance_to(obj.origin) < W.range and Ready(SLOT_W) then
        CastW(obj)
			end
		end
	end
end

--[[local function on_object_created(object, obj_name)
	if obj_name == ("lulufaerieburn") then
		Pix = object
	end
end]]

local function on_buff_active(obj, buff_name)
	if obj:has_buff("lulufaerieburn") then
		Pix = obj
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player


	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(lulu_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(lulu_draw_q_ext) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q2.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(lulu_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 0, 255, 255, 255)
		end
	end

	if menu:get_value(lulu_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 255, 0, 255)
		end

		if menu:get_value(lulu_draw_r_knockup) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(x, y, z, R.width, 255, 255, 0, 255)
			end
		end

	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(lulu_combokey)) and menu:get_value(lulu_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
		QExtended()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
	end

	AutoR()
	AutoKill()
	ManualRCast()
	--AutoE()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
--client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_buff_active", on_buff_active)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
