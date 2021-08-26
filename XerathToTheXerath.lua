if game.local_player.champ_name ~= "Xerath" then
	return
end

do
    local function AutoUpdate()
		local Version = 2.4
		local file_name = "XerathToTheXerath.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XerathToTheXerath.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XerathToTheXerath.lua.version.txt")
        console:log("XerathToTheXerath.lua Vers: "..Version)
				console:log("XerathToTheXerath.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Xerath Successfully Loaded.....")

        else
			http:download_file(url, file_name)
            console:log("Sexy Xerath Update available.....")
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
local level = spellbook:get_spell_slot(SLOT_R).level


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 1450, delay = .25, width = 140, speed = 0 }
local W = { range = 1000, delay = .25, width = 200, speed = 0 }
local E = { range = 1125, delay = .25, width = 120, speed = 1400 }
local R = { range = 5000, delay = .25, width = 200, speed = 0 }
local FQ = { range = 1850, delay = .75, width = 225, speed = 0 }

local W_input = {
    source = myHero,
    speed = math.huge, range = 1000,
    delay = 0.8, radius = 250,
    collision = {},
    type = "circular", hitbox = false
}

local E_input = {
    source = myHero,
    speed = 1400, range = 1125,
    delay = 0.25, radius = 60,
    collision = {"minion", "wind_wall"},
    type = "linear", hitbox = true
}

local R_input = {
    source = myHero,
    speed = math.huge, range = 5000,
    delay = 0.7, radius = 200,
    collision = {},
    type = "circular", hitbox = false
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

local function GetDistanceSqr2(unit, p2)
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.origin
	p1x, p1y, p1z = p1.x, p1.y, p1.z
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
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

local function IsQCharging(unit)
	if HasBuff(unit, "xerathqvfx") then
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

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	Xerath_category = menu:add_category_sprite("Shaun's Sexy Xerath", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	Xerath_category = menu:add_category("Shaun's Sexy Xerath")
end

Xerath_enabled = menu:add_checkbox("Enabled", Xerath_category, 1)
Xerath_combokey = menu:add_keybinder("Combo Mode Key", Xerath_category, 32)
menu:add_label("Shaun's Sexy Xerath", Xerath_category)
menu:add_label("#LetMeTickleYouWithMyBolts", Xerath_category)

Xerath_prediction = menu:add_subcategory("[Pred Selection]", Xerath_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
Xerath_pred_useage = menu:add_combobox("[Pred Selection]", Xerath_prediction, e_table, 1)

Xerath_ark_pred = menu:add_subcategory("[Ark Pred Settings]", Xerath_prediction)
Xerath_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", Xerath_ark_pred, 1, 99, 50)
Xerath_w_hitchance = menu:add_slider("[W] Hit Chance [%]", Xerath_ark_pred, 1, 99, 50)
Xerath_e_hitchance = menu:add_slider("[E] Hit Chance [%]", Xerath_ark_pred, 1, 99, 50)
Xerath_r_hitchance = menu:add_slider("[R] Hit Chance [%]", Xerath_ark_pred, 1, 99, 50)

Xerath_ks_function = menu:add_subcategory("[Kill Steal]", Xerath_category)
Xerath_ks_use_q = menu:add_checkbox("Use [Q]", Xerath_ks_function, 1)
Xerath_ks_use_w = menu:add_checkbox("Use [W]", Xerath_ks_function, 1)
Xerath_ks_use_r = menu:add_checkbox("Use [R]", Xerath_ks_function, 1)
Xerath_ks_use_range = menu:add_slider("Target Greater Than Range To Use [R] Kill Steal", Xerath_ks_function, 1, 5000, 1450)
Xerath_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Whitelist", Xerath_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), Xerath_ks_r_blacklist, 1)
    end
end

Xerath_combo = menu:add_subcategory("[Combo]", Xerath_category)
Xerath_combo_use_q = menu:add_checkbox("Use [Q]", Xerath_combo, 1)
Xerath_combo_use_w = menu:add_checkbox("Use [W]", Xerath_combo, 1)
Xerath_combo_use_e = menu:add_checkbox("Use [E]", Xerath_combo, 1)
Xerath_combo_use_e_set = menu:add_subcategory("[E] Combo Settings", Xerath_combo)
Xerath_combo_use_e_range = menu:add_slider("[E] Max Range Usage", Xerath_combo_use_e_set, 1, 1125, 1125)
Xerath_combo_r = menu:add_subcategory("[R] Combo Settings", Xerath_combo)
Xerath_combo_use_r = menu:add_checkbox("Use [R]", Xerath_combo_r, 1)
Xerath_combo_use_range = menu:add_slider("Target Greater Than Range To Use [R] Combo", Xerath_combo_r, 1, 5000, 1450)
Xerath_combo_r_enemy_hp = menu:add_slider("Use Combo [R] if Enemy HP is lower than [%]", Xerath_combo_r, 1, 100, 40)
Xerath_combo_r_my_hp = menu:add_slider("Only Combo [R] if My HP is Greater than [%]", Xerath_combo_r, 1, 100, 20)
Xerath_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Whitelist", Xerath_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), Xerath_combo_r_blacklist, 1)
    end
end

Xerath_harass = menu:add_subcategory("[Harass]", Xerath_category)
Xerath_harass_use_q = menu:add_checkbox("Use [Q]", Xerath_harass, 1)
Xerath_harass_use_w = menu:add_checkbox("Use [W]", Xerath_harass, 1)
Xerath_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", Xerath_harass, 1, 100, 20)

Xerath_laneclear = menu:add_subcategory("[Lane Clear]", Xerath_category)
Xerath_laneclear_use_q = menu:add_checkbox("Use [Q]", Xerath_laneclear, 1)
Xerath_laneclear_use_w = menu:add_checkbox("Use [W]", Xerath_laneclear, 1)
Xerath_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", Xerath_laneclear, 1, 100, 20)
Xerath_laneclear_min_q = menu:add_slider("Minimum Minion To [Q]", Xerath_laneclear, 1, 10, 3)
Xerath_laneclear_min_w = menu:add_slider("Minimum Minion To [W]", Xerath_laneclear, 1, 10, 3)

Xerath_jungleclear = menu:add_subcategory("[Jungle Clear]", Xerath_category)
Xerath_jungleclear_use_q = menu:add_checkbox("Use [Q]", Xerath_jungleclear, 1)
Xerath_jungleclear_use_w = menu:add_checkbox("Use [W]", Xerath_jungleclear, 1)
Xerath_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To jungle Clear", Xerath_jungleclear, 1, 100, 20)

Xerath_combo_r_options = menu:add_subcategory("[Misc Settings]", Xerath_category)
Xerath_combo_use_gap = menu:add_checkbox("[E] Anti Gap Closer", Xerath_combo_r_options, 1)
Xerath_combo_use_inter = menu:add_checkbox("[E] Interrupt Major Spells", Xerath_combo_r_options, 1)
Xerath_combo_panic_e_key = menu:add_keybinder("Semi Manual [E] Key", Xerath_combo_r_options, 90)
Xerath_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key - Enemy Nearest To Cursor", Xerath_combo_r_options, 65)
Xerath_combo_fq_key = menu:add_keybinder("Semi Manual Flash > [Q] Key", Xerath_combo_r_options, 88)

Xerath_draw = menu:add_subcategory("[Drawing Features]", Xerath_category)
Xerath_draw_q = menu:add_checkbox("Draw [Q]", Xerath_draw, 1)
Xerath_draw_w = menu:add_checkbox("Draw [W]", Xerath_draw, 1)
Xerath_draw_e = menu:add_checkbox("Draw [E]", Xerath_draw, 1)
Xerath_draw_r = menu:add_checkbox("Draw [R]", Xerath_draw, 1)
Xerath_draw_fq = menu:add_checkbox("Draw Flash > [Q] Range", Xerath_draw, 1)
Xerath_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", Xerath_draw, 1)
Xerath_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", Xerath_draw, 1, "Health Bar Damage Is Computed From R, Q, W")

-- Casting

local function CastQ(unit)

	if menu:get_value(Xerath_pred_useage) == 0 then
		Charge_buff = local_player:get_buff("xerathqvfx")
		if Charge_buff.is_valid then
			local diff = game.game_time - Charge_buff.start_time
			local range = 750 + ((650 / 1.5) * diff)

			if range > 1400 then
				range = 1400
			end

			target = selector:find_target(range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) and IsValid(target) then
					origin = target.origin
					pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

					if pred_output.can_cast then
						cast_pos = pred_output.cast_pos
						spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
					end
				end
			end
		else
			target = selector:find_target(Q.range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end
	end

	if menu:get_value(Xerath_pred_useage) == 1 then
		Charge_buff = local_player:get_buff("xerathqvfx")
		if Charge_buff.is_valid then
			local diff = game.game_time - Charge_buff.start_time
			local range1 = 750 + ((650 / 1.5) * diff)

			if range1 > 1400 then
				range1 = 1400
			end

			target = selector:find_target(range1, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) and IsValid(target) then
					local Q_input = {
					    source = myHero,
					    speed = math.huge, range = range1,
					    delay = 0.6, radius = 80,
					    collision = {"wind_wall"},
					    type = "linear", hitbox = true
					}
					local output = arkpred:get_prediction(Q_input, target)
				  local inv = arkpred:get_invisible_duration(target)
					if output.hit_chance >= menu:get_value(Xerath_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
						local p = output.cast_pos
						spellbook:release_charged_spell(SLOT_Q, 0.35, p.x, p.y, p.z)
					end
				end
			end
		else
			target = selector:find_target(Q.range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end
	end
end

local function CastW(unit)

	if menu:get_value(Xerath_pred_useage) == 0 then
		pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)

		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(Xerath_pred_useage) == 1 then
		local output = arkpred:get_aoe_prediction(W_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(Xerath_w_hitchance) / 100 and inv < (W_input.delay / 2) then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		end
	end
end

local function CastE(unit)

	if menu:get_value(Xerath_pred_useage) == 0 then
		pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, true)

		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(Xerath_pred_useage) == 1 then
		local output = arkpred:get_prediction(E_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(Xerath_e_hitchance) / 100 and inv < (E_input.delay / 2) then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, p.x, p.y, p.z)
		end
	end
end

local function CastR(unit)

	if menu:get_value(Xerath_pred_useage) == 0 then
		pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)

		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(Xerath_pred_useage) == 1 then
		local output = arkpred:get_aoe_prediction(R_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(Xerath_r_hitchance) / 100 and inv < (R_input.delay / 2) then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_R, E.delay, p.x, p.y, p.z)
		end
	end
end

-- Combo

local function Combo()

	target = selector:find_target(R.range, mode_health)

	if menu:get_value(Xerath_combo_use_w) == 1 then
		if Ready(SLOT_W) and IsValid(target) and myHero:distance_to(target.origin) <= W.range then
			CastW(target)
		end
	end

	if menu:get_value(Xerath_combo_use_q) == 1 then
		if Ready(SLOT_Q) and myHero:distance_to(target.origin) <= Q.range then
			CastQ(target)
		end
	end

	if menu:get_value(Xerath_combo_use_e) == 1 then
		if Ready(SLOT_E) and IsValid(target) and myHero:distance_to(target.origin) <= menu:get_value(Xerath_combo_use_e_range) then
			CastE(target)
		end
	end

	if menu:get_value(Xerath_combo_use_r) == 1 then
		if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) > menu:get_value(Xerath_combo_use_range) and GetEnemyCount(myHero.attack_range, myHero) <= 0 then
			if target:health_percentage() <= menu:get_value(Xerath_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(Xerath_combo_r_my_hp) then
					if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
						CastR(target)
					end
				end
			end
		end
	end
end

--Harass

local function Harass()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(Xerath_harass_min_mana) / 100

	target = selector:find_target(R.range, mode_health)

	if menu:get_value(Xerath_harass_use_w) == 1 then
		if GrabMana then
			if Ready(SLOT_W) and IsValid(target) and myHero:distance_to(target.origin) <= W.range then
				CastW(target)
			end
		end
	end

	if menu:get_value(Xerath_harass_use_q) == 1 then
		if GrabMana then
			if Ready(SLOT_Q) and myHero:distance_to(target.origin) <= Q.range then
				CastQ(target)
			end
		end
	end
end

-- Jungle Clear

local function JungleClear()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(Xerath_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(Xerath_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if GrabMana then

				Charge_buff = local_player:get_buff("xerathqvfx")
				if Charge_buff.is_valid then
					local diff = game.game_time - Charge_buff.start_time
					local range = 750 + ((650 / 1.5) * diff)

					if range > 1400 then
						range = 1400
					end

					if target.object_id ~= 0 then
						if Ready(SLOT_Q) and IsValid(target) then
							origin = target.origin
							pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

							if pred_output.can_cast then
								cast_pos = pred_output.cast_pos
								spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
							end
						end
					end
				else
					if target.object_id ~= 0 then
						if Ready(SLOT_Q) then
							spellbook:start_charged_spell(SLOT_Q)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(Xerath_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range and IsValid(target) then
			if GrabMana then
				if Ready(SLOT_W) then
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

local function PanicECast()
	target = selector:find_target(E.range, mode_distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_E) and IsValid(target) then
			CastE(target)
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	target = selector:find_target(R.range, mode_cursor)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) then
			CastR(target)
		end
	end
end

-- Manual F > Q

local function FQCast()

	if IsFlashSlotF() then

		Charge_buff = local_player:get_buff("xerathqvfx")
		if Charge_buff.is_valid then
			local diff = game.game_time - Charge_buff.start_time
			local range = 750 + ((650 / 1.5) * diff)


			if range > 1400 then
				range = 1400
				Ftarget = selector:find_target(FQ.range, mode_health)
				origin = Ftarget.origin
				Fx, Fy, Fz = origin.x, origin.y, origin.z
				if Ready(SLOT_F) then
					spellbook:cast_spell(SLOT_F, 0.1, Fx, Fy, Fz)
				end
			end

			target = selector:find_target(range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) and IsValid(target) then
					origin = target.origin
					pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

					if pred_output.can_cast then
						cast_pos = pred_output.cast_pos
						if not Ready(SLOT_F) then
							spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			end
		else
			target = selector:find_target(FQ.range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end

	else

		Charge_buff = local_player:get_buff("xerathqvfx")
		if Charge_buff.is_valid then
			local diff = game.game_time - Charge_buff.start_time
			local range = 750 + ((650 / 1.5) * diff)


			if range > 1400 then
				range = 1400
				Ftarget = selector:find_target(FQ.range, mode_health)
				origin = Ftarget.origin
				Fx, Fy, Fz = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_D, 0.1, Fx, Fy, Fz)
			end

			target = selector:find_target(range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) and IsValid(target) then
					origin = target.origin
					pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

					if pred_output.can_cast then
						cast_pos = pred_output.cast_pos
						if not Ready(SLOT_D) then
							spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			end
		else
			target = selector:find_target(FQ.range, mode_health)
			if target.object_id ~= 0 then
				if Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		local GetQDmg = getdmg("Q", target, game.myHero, 1)
		local GetWDmg = getdmg("W", target, game.myHero, 1)
		local GetEDmg = getdmg("E", target, game.myHero, 1)
		local GetRDmg = getdmg("R", target, game.myHero, 1)

		local level1dmg = (GetRDmg * 2)
		local level2dmg = (GetRDmg * 3)
		local level3dmg = (GetRDmg * 4)

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if menu:get_value(Xerath_ks_use_q) == 1 then
				if GetQDmg > target.health then
					if Ready(SLOT_Q) then
						if menu:get_value(Xerath_pred_useage) == 0 then
							Charge_buff = local_player:get_buff("xerathqvfx")
							if Charge_buff.is_valid then
								local diff = game.game_time - Charge_buff.start_time
								local range = 750 + ((650 / 1.5) * diff)

								if range > 1400 then
									range = 1400
								end

								target = selector:find_target(range, mode_health)
								if target.object_id ~= 0 then
									if Ready(SLOT_Q) and IsValid(target) then
										origin = target.origin
										pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

										if pred_output.can_cast then
											cast_pos = pred_output.cast_pos
											spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
										end
									end
								end
							else
								target = selector:find_target(Q.range, mode_health)
								if target.object_id ~= 0 then
									if Ready(SLOT_Q) then
										spellbook:start_charged_spell(SLOT_Q)
									end
								end
							end
						end

						if menu:get_value(Xerath_pred_useage) == 1 then
							Charge_buff = local_player:get_buff("xerathqvfx")
							if Charge_buff.is_valid then
								local diff = game.game_time - Charge_buff.start_time
								local range1 = 750 + ((650 / 1.5) * diff)

								if range1 > 1400 then
									range1 = 1400
								end

								target = selector:find_target(range1, mode_health)
								if target.object_id ~= 0 then
									if Ready(SLOT_Q) and IsValid(target) then
										local Q_input = {
										    source = myHero,
										    speed = math.huge, range = range1,
										    delay = 0.6, radius = 80,
										    collision = {"wind_wall"},
										    type = "linear", hitbox = true
										}
										local output = arkpred:get_prediction(Q_input, target)
									  local inv = arkpred:get_invisible_duration(target)
										if output.hit_chance >= menu:get_value(Xerath_q_hitchance) / 100 and inv < 0.125 then
											local p = output.cast_pos
											spellbook:release_charged_spell(SLOT_Q, 0.35, p.x, p.y, p.z)
										end
									end
								end
							else
								target = selector:find_target(Q.range, mode_health)
								if target.object_id ~= 0 then
									if Ready(SLOT_Q) then
										spellbook:start_charged_spell(SLOT_Q)
									end
								end
							end
						end
					end
				end
			end
		end


		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) then
			if menu:get_value(Xerath_ks_use_w) == 1 then
				if GetWDmg > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) then
			if menu:get_value(Xerath_ks_use_r) == 1 and level > 0 then

				if level == 1 and level1dmg > target.health then
					if myHero:distance_to(target.origin) > menu:get_value(Xerath_ks_use_range) and Ready(SLOT_R) then
						if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
							CastR(target)
						end
					end
				end
			end

			if level == 2 and level2dmg > target.health then
				if myHero:distance_to(target.origin) > menu:get_value(Xerath_ks_use_range) and Ready(SLOT_R) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
						CastR(target)
					end
				end
			end

			if level == 3 and level3dmg > target.health then
				if myHero:distance_to(target.origin) > menu:get_value(Xerath_ks_use_range) and GetEnemyCount(myHero.attack_range, myHero) <= 0 and Ready(SLOT_R) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
						CastR(target)
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local GrabMana = myHero.mana/myHero.max_mana >= menu:get_value(Xerath_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(Xerath_laneclear_use_q) == 1 and GrabMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= menu:get_value(Xerath_laneclear_min_q) then
					if Ready(SLOT_Q) then
						Charge_buff = local_player:get_buff("xerathqvfx")
						if Charge_buff.is_valid then
							local diff = game.game_time - Charge_buff.start_time
							local range = 750 + ((650 / 1.5) * diff)

							if range > 1400 then
								range = 1400
							end

							if target.object_id ~= 0 then
								if Ready(SLOT_Q) and IsValid(target) then
									origin = target.origin
									pred_output = pred:predict(0, 0.6, range, 95, target, false, false)

									if pred_output.can_cast then
										cast_pos = pred_output.cast_pos
										spellbook:release_charged_spell(SLOT_Q, 0.35, cast_pos.x, cast_pos.y, cast_pos.z)
									end
								end
							end
						else
							if target.object_id ~= 0 then
								if Ready(SLOT_Q) then
									spellbook:start_charged_spell(SLOT_Q)
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(Xerath_laneclear_use_w) == 1 and GrabMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range and IsValid(target) then
				if GetMinionCount(W.range, target) >= menu:get_value(Xerath_laneclear_min_w) then
					if Ready(SLOT_W) then
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

-- Auto R Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(Xerath_combo_use_inter) == 1 then
      if myHero:distance_to(obj.origin) < E.range and Ready(SLOT_E) then
        CastE(obj)
			end
		end
	end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_value(Xerath_combo_use_gap) == 1 then
    if Ready(SLOT_E) and IsValid(obj) and obj.is_enemy then
	    if myHero:distance_to(dash_info.end_pos) < E.range and myHero:distance_to(obj.origin) < E.range and obj:is_facing(myHero) then
	      CastE(obj)
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
	local GetQDmg = getdmg("Q", target, game.myHero, 1)
	local GetWDmg = getdmg("W", target, game.myHero, 1)
	local GetEDmg = getdmg("E", target, game.myHero, 1)
	local GetRDmg = getdmg("R", target, game.myHero, 1)


	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(Xerath_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(Xerath_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 0, 0, 255, 255)
		end
	end

	if menu:get_value(Xerath_draw_e) == 1 then
		if Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 20, 147, 255)
		end
	end

	if menu:get_value(Xerath_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 225, 0, 0, 255)
			minimap:draw_circle(x, y, z, R.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(Xerath_draw_fq) == 1 then
		if Ready(SLOT_Q) and Ready(SLOT_F) then
			renderer:draw_circle(x, y, z, FQ.range, 255, 255, 0, 255)
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg + GetWDmg + (GetRDmg * level)
		if Ready(SLOT_Q) and Ready(SLOT_W) and Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range then
				if menu:get_value(Xerath_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						if enemydraw.is_valid then
							renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target")
						end
					end
				end
			end
		end
		if IsValid(target) and menu:get_value(Xerath_draw_kill_healthbar) == 1 then
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

	level = spellbook:get_spell_slot(SLOT_R).level


	if game:is_key_down(menu:get_value(Xerath_combokey)) and menu:get_value(Xerath_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(Xerath_combo_r_set_key)) then
		ManualRCast()
	end

	if game:is_key_down(menu:get_value(Xerath_combo_fq_key)) then
		FQCast()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(Xerath_combo_panic_e_key)) then
		PanicECast()
	end


	AutoKill()

end

client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_dash", on_dash)
