if game.local_player.champ_name ~= "Xerath" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.6
		local file_name = "XerathToTheXerath.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XerathToTheXerath.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XearthToTheXearth.lua.version.txt")
        console:log("XerathToTheXerath.Lua Vers: "..Version)
		console:log("XerathToTheXerath.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Xerath v1 successfully loaded.....")
						console:log("--------------------------------------------------------------------")
						console:log("Added Blacklist Ultimate to Kill Steal and Combo R Settings")
						console:log("Changed Semi R Manual To Cursor Targeting")
						console:log("Added E Combo Max Usage Range Slider")
						console:log("Added check for Flash Slot Usage (D/F) for Semi Manual Flash > Q Key")
						console:log("Added E Anti Gap Closer")
						console:log("--------------------------------------------------------------------")
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

pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 1450, delay = .25, width = 140, speed = 0 }
local W = { range = 1000, delay = .25, width = 200, speed = 0 }
local E = { range = 1125, delay = .25, width = 120, speed = 1400 }
local R = { range = 5000, delay = .25, width = 200, speed = 0 }
local FQ = { range = 1850, delay = .75, width = 225, speed = 0 }


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

xerath_category = menu:add_category("Shaun's Sexy Xerath")
xerath_enabled = menu:add_checkbox("Enabled", xerath_category, 1)
xerath_combokey = menu:add_keybinder("Combo Mode Key", xerath_category, 32)

xerath_ks_function = menu:add_subcategory("Kill Steal", xerath_category)
xerath_ks_use_q = menu:add_checkbox("Use Q", xerath_ks_function, 1)
xerath_ks_use_w = menu:add_checkbox("Use W", xerath_ks_function, 1)
xerath_ks_use_r = menu:add_checkbox("Use R", xerath_ks_function, 1)
xerath_ks_use_range = menu:add_slider("Target Greater Than Range To Use R Kill Steal", xerath_ks_function, 1, 5000, 1450)
xerath_ks_r_blacklist = menu:add_subcategory("Ultimate Kill Steal Blacklist", xerath_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use R Kill Steal On: "..tostring(t.champ_name), xerath_ks_r_blacklist, 1)
    end
end

xerath_combo = menu:add_subcategory("Combo", xerath_category)
xerath_combo_use_q = menu:add_checkbox("Use Q", xerath_combo, 1)
xerath_combo_use_w = menu:add_checkbox("Use W", xerath_combo, 1)
xerath_combo_use_e = menu:add_checkbox("Use E", xerath_combo, 1)
xerath_combo_use_e_set = menu:add_subcategory("E Combo Settings", xerath_combo)
xerath_combo_use_e_range = menu:add_slider("E Max Range Usage", xerath_combo_use_e_set, 1, 1125, 1125)
xerath_combo_r = menu:add_subcategory("R Combo Settings", xerath_combo)
xerath_combo_use_r = menu:add_checkbox("Use R", xerath_combo_r, 1)
xerath_combo_use_range = menu:add_slider("Target Greater Than Range To Use R Combo", xerath_combo_r, 1, 5000, 1450)
xerath_combo_r_enemy_hp = menu:add_slider("Use Combo R if Enemy HP is lower than [%]", xerath_combo_r, 1, 100, 40)
xerath_combo_r_my_hp = menu:add_slider("Only Combo R if My HP is Greater than [%]", xerath_combo_r, 1, 100, 20)
xerath_combo_r_blacklist = menu:add_subcategory("Ultimate Combo Blacklist", xerath_combo_r)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Use R Combo On: "..tostring(v.champ_name), xerath_combo_r_blacklist, 1)
    end
end

xerath_harass = menu:add_subcategory("Harass", xerath_category)
xerath_harass_use_q = menu:add_checkbox("Use Q", xerath_harass, 1)
xerath_harass_use_w = menu:add_checkbox("Use W", xerath_harass, 1)
xerath_harass_min_mana = menu:add_slider("Minimum Mana To Harass", xerath_harass, 1, 500, 100)

xerath_laneclear = menu:add_subcategory("Lane Clear", xerath_category)
xerath_laneclear_use_q = menu:add_checkbox("Use Q", xerath_laneclear, 1)
xerath_laneclear_use_w = menu:add_checkbox("Use W", xerath_laneclear, 1)
xerath_laneclear_min_mana = menu:add_slider("Minimum Mana To Lane Clear", xerath_laneclear, 1, 500, 200)
xerath_laneclear_min_q = menu:add_slider("Minimum Minion To Q", xerath_laneclear, 1, 10, 3)
xerath_laneclear_min_w = menu:add_slider("Minimum Minion To W", xerath_laneclear, 1, 10, 3)

xerath_jungleclear = menu:add_subcategory("Jungle Clear", xerath_category)
xerath_jungleclear_use_q = menu:add_checkbox("Use Q", xerath_jungleclear, 1)
xerath_jungleclear_use_w = menu:add_checkbox("Use W", xerath_jungleclear, 1)
xerath_jungleclear_min_mana = menu:add_slider("Minimum Mana To jungle Clear", xerath_jungleclear, 1, 500, 200)

xerath_combo_r_options = menu:add_subcategory("Misc Settings", xerath_category)
xerath_combo_use_gap = menu:add_checkbox("E Anti Gap Closer", xerath_combo_r_options, 1)
xerath_combo_use_inter = menu:add_checkbox("E Interrupt Major Spells", xerath_combo_r_options, 1)
xerath_combo_panic_e_key = menu:add_keybinder("Semi Manual E Key", xerath_combo_r_options, 90)
xerath_combo_r_set_key = menu:add_keybinder("Semi Manual R Key - Enemy Nearest To Cursor", xerath_combo_r_options, 65)
xerath_combo_fq_key = menu:add_keybinder("Semi Manual Flash > Q Key", xerath_combo_r_options, 88)

xerath_draw = menu:add_subcategory("Drawing Features", xerath_category)
xerath_draw_q = menu:add_checkbox("Draw Q", xerath_draw, 1)
xerath_draw_w = menu:add_checkbox("Draw W", xerath_draw, 1)
xerath_draw_e = menu:add_checkbox("Draw E", xerath_draw, 1)
xerath_draw_r = menu:add_checkbox("Draw R", xerath_draw, 1)
xerath_draw_fq = menu:add_checkbox("Draw Flash > Q Range", xerath_draw, 1)
xerath_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", xerath_draw, 1)
xerath_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", xerath_draw, 1, "Health Bar Damage Is Computed From R, Q, W")

-- Casting

local function CastQ(unit)

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

local function CastW(unit)
	target = selector:find_target(W.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_W) and IsValid(target) then
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

local function CastE(unit)
	target = selector:find_target(E.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_E) and IsValid(target) and myHero:distance_to(target.origin) <= menu:get_value(xerath_combo_use_e_range) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, true)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

local function CastR(unit)
	target = selector:find_target(R.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) and myHero:distance_to(target.origin) > menu:get_value(xerath_combo_use_range) then
			if target:health_percentage() <= menu:get_value(xerath_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(xerath_combo_r_my_hp) then
					if menu:get_value_string("Use R Combo On: "..tostring(target.champ_name)) == 1 then
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

-- Combo

local function Combo()

	if menu:get_value(xerath_combo_use_q) == 1 then
		if Ready(SLOT_Q) then
			CastQ(target)
		end
	end

	if menu:get_value(xerath_combo_use_w) == 1 then
		if Ready(SLOT_W) then
			CastW(target)
		end
	end

	if menu:get_value(xerath_combo_use_e) == 1 then
		if Ready(SLOT_E) then
			CastE(target)
		end
	end

	if menu:get_value(xerath_combo_use_r) == 1 then
		if Ready(SLOT_R) then
			CastR(target)
		end
	end

end

--Harass

local function Harass()

	if menu:get_value(xerath_harass_use_q) == 1 then
		if myHero.mana >= menu:get_value(xerath_harass_min_mana) then
			if Ready(SLOT_Q) then
				CastQ(target)
			end
		end
	end

	if menu:get_value(xerath_harass_use_w) == 1 then
		if myHero.mana >= menu:get_value(xerath_harass_min_mana) then
			if Ready(SLOT_W) then
				CastW(target)
			end
		end
	end
end

-- KillSteal

level = spellbook:get_spell_slot(SLOT_R).level
local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		local GetQDmg = getdmg("Q", target, game.myHero, 1)
		local GetWDmg = getdmg("W", target, game.myHero, 1)
		local GetEDmg = getdmg("E", target, game.myHero, 1)
		local GetRDmg = getdmg("R", target, game.myHero, 1)

		local level1dmg = (GetRDmg * 2)
		local level2dmg = (GetRDmg * 3)
		local level3dmg = (GetRDmg * 4)

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) then
			if menu:get_value(xerath_ks_use_q) == 1 then
				if GetQDmg > target.health then
					if Ready(SLOT_Q) then
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
				end
			end
		end


		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and IsValid(target) then
			if menu:get_value(xerath_ks_use_w) == 1 then
				if GetWDmg > target.health then
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

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= R.range and IsValid(target) then
			if menu:get_value(xerath_ks_use_r) == 1 and level > 0 then

				if level == 1 and level1dmg > target.health then
					if myHero:distance_to(target.origin) > menu:get_value(xerath_ks_use_range) and Ready(SLOT_R) then
						if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
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

			if level == 2 and level2dmg > target.health then
				if myHero:distance_to(target.origin) > menu:get_value(xerath_ks_use_range) and Ready(SLOT_R) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
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

			if level == 3 and level3dmg > target.health then
				if myHero:distance_to(target.origin) > menu:get_value(xerath_ks_use_range) and Ready(SLOT_R) then
					if menu:get_value_string("Use R Kill Steal On: "..tostring(target.champ_name)) == 1 then
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

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(xerath_laneclear_use_q) == 1 and myHero.mana >= menu:get_value(xerath_laneclear_min_mana) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= menu:get_value(xerath_laneclear_min_q) then
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
		if menu:get_value(xerath_laneclear_use_w) == 1 and myHero.mana >= menu:get_value(xerath_laneclear_min_mana) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range and IsValid(target) then
				if GetMinionCount(W.range, target) >= menu:get_value(xerath_laneclear_min_w) then
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

		if target.object_id ~= 0 and menu:get_value(xerath_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range and IsValid(target) then
			if myHero.mana >= menu:get_value(xerath_jungleclear_min_mana) then

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

	if target.object_id ~= 0 and menu:get_value(xerath_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range and IsValid(target) then
		if myHero.mana >= menu:get_value(xerath_jungleclear_min_mana) then
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

-- Manual R Cast

local function PanicECast()
	target = selector:find_target(E.range, mode_distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_E) and IsValid(target) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, true)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	target = selector:find_target(R.range, mode_cursor)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) and IsValid(target) then
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
				spellbook:cast_spell(SLOT_F, 0.1, Fx, Fy, Fz)
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

-- Auto R Interrupt

local function on_possible_interrupt(obj, spell_name)
	if IsValid(obj) then
    if menu:get_value(xerath_combo_use_inter) == 1 then
      if myHero:distance_to(obj.origin) < E.range and Ready(SLOT_E) then
        CastE(obj)
			end
		end
	end
end

-- Gap Close

local function on_gap_close(obj, data)

	if IsValid(obj) then
    if menu:get_value(xerath_combo_use_gap) == 1 then
      if myHero:distance_to(obj.origin) < E.range and Ready(SLOT_E) then
        CastE(obj)
			end
		end
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	local target = selector:find_target(Q.range, mode_health)
	local GetQDmg = getdmg("Q", target, game.myHero, 1)
	local GetWDmg = getdmg("W", target, game.myHero, 1)
	local GetEDmg = getdmg("E", target, game.myHero, 1)
	local GetRDmg = getdmg("R", target, game.myHero, 1)


	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	if menu:get_value(xerath_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(xerath_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 0, 0, 255, 255)
		end
	end

	if menu:get_value(xerath_draw_e) == 1 then
		if Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 20, 147, 255)
		end
	end

	if menu:get_value(xerath_draw_r) == 1 then
		if Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 225, 0, 0, 255)
			minimap:draw_circle(x, y, z, R.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(xerath_draw_fq) == 1 then
		if Ready(SLOT_Q) and Ready(SLOT_F) then
			renderer:draw_circle(x, y, z, FQ.range, 255, 255, 0, 255)
		end
	end

	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg + GetWDmg + (GetRDmg * level)
		if Ready(SLOT_Q) and Ready(SLOT_W) and Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range then
				if menu:get_value(xerath_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 30, "Full Combo Can Kill Q > W > R")
					end
				end
			end
		end
		if menu:get_value(xerath_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(xerath_combokey)) and menu:get_value(xerath_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(xerath_combo_r_set_key)) then
		ManualRCast()
	end

	if game:is_key_down(menu:get_value(xerath_combo_fq_key)) then
		FQCast()
	end

	if game:is_key_down(menu:get_value(xerath_combo_panic_e_key)) then
		PanicECast()
	end

	--if not game:is_key_down(menu:get_value(xerath_combokey)) then
	KillSteal()
	--end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_gap_close", on_gap_close)
