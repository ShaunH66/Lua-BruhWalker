if game.local_player.champ_name ~= "Xerath" then
	return
end

-- AutoUpdate
--[[do
    local function AutoUpdate()
		local Version = 1
		local file_name = "XerathToTheXerath.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XerathToTheXerath.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/XerathToTheXerath.lua.version.txt")
        console:log("XearthToTheXearth.Lua Vers: "..Version)
		console:log("XearthToTheXearth.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Xerath v1 successfully loaded.....")
        else
			http:download_file(url, file_name)
            console:log("Sexy XerathToTheXerath Update available.....")
			console:log("Please reload via F5.....")
        end

    end

    AutoUpdate()

end]]

pred:use_prediction()
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player

local Wcast = false
local AutoTime = 0
local AutoAATime = 0
local AAcast = false

local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Ranges

local Q = { range = 1450, delay = .25, width = 140, speed = 0 }
local W = { range = 1000, delay = .25, width = 250, speed = 0 }
local E = { range = 1125, delay = .25, width = 120, speed = 1400 }
local R1 = { range = 3200, delay = .25, width = 200, speed = 0 }
local R2 = { range = 4400, delay = .25, width = 200, speed = 0 }
local R3 = { range = 5600, delay = .25, width = 200, speed = 0 }


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
	p2 = p2.xearthgin or myHero.xearthgin
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.xearthgin
	p1x, p1y, p1z = p1.x, p1.y, p1.z
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
end

local function GetDistanceSqr2(unit, p2)
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.xearthgin
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
    if myHero:distance_to(unit.xearthgin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
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

local function IsQCharging()
	QSpell = spellbook:get_spell_slot(SLOT_Q)
	QData = QSpell.spell_data
	QName = QData.spell_name
	if QName == "xerathq" then
		return true
	end
	return false
end

local function HasQCharged(unit)
	if HasBuff(unit, "XerathArcanopulseChargeUp") then
		return true
	end
	return false
end

local function GetGameTime()
	return tonumber(game.game_time)
end


-- Menu Config

xearth_category = menu:add_category("Shaun's Sexy Xearth")
xearth_enabled = menu:add_checkbox("Enabled", xearth_category, 1)
xearth_combokey = menu:add_keybinder("Combo Mode Key", xearth_category, 32)

xearth_ks_function = menu:add_subcategory("Kill Steal", xearth_category)
xearth_ks_use_q = menu:add_checkbox("Use Q", xearth_ks_function, 1)
xearth_ks_use_w = menu:add_checkbox("Use W", xearth_ks_function, 1)
xearth_ks_use_r = menu:add_checkbox("Use R", xearth_ks_function, 1)

xearth_combo = menu:add_subcategory("Combo", xearth_category)
xearth_combo_use_q = menu:add_checkbox("Use Q", xearth_combo, 1)
xearth_combo_use_w = menu:add_checkbox("Use W", xearth_combo, 1)
xearth_combo_use_e = menu:add_checkbox("Use E", xearth_combo, 1)
xearth_combo_use_r = menu:add_checkbox("Use R", xearth_combo, 1)
xearth_combo_r = menu:add_subcategory("R Combo Settings", xearth_combo)
xearth_combo_r_enemy_hp = menu:add_slider("Use Combo R if Enemy HP is lower than [%]", xearth_combo_r, 1, 100, 50)
xearth_combo_r_my_hp = menu:add_slider("Only Combo R if My HP is Greater than [%]", xearth_combo_r, 1, 100, 20)

xearth_harass = menu:add_subcategory("Harass", xearth_category)
xearth_harass_use_q = menu:add_checkbox("Use Q", xearth_harass, 1)
xearth_harass_use_w = menu:add_checkbox("Use W", xearth_harass, 1)
xearth_harass_min_mana = menu:add_slider("Minimum Mana To Harass", xearth_harass, 1, 500, 50)

xearth_laneclear = menu:add_subcategory("Lane Clear", xearth_category)
xearth_laneclear_use_q = menu:add_checkbox("Use Q", xearth_laneclear, 1)
xearth_laneclear_use_w = menu:add_checkbox("Use W", xearth_laneclear, 1)
xearth_laneclear_min_mana = menu:add_slider("Minimum Mana To Lane Clear", xearth_laneclear, 1, 500, 50)

xearth_jungleclear = menu:add_subcategory("Jungle Clear", xearth_category)
xearth_jungleclear_use_q = menu:add_checkbox("Use Q", xearth_jungleclear, 1)
xearth_jungleclear_use_w = menu:add_checkbox("Use W", xearth_jungleclear, 1)
xearth_jungleclear_min_mana = menu:add_slider("Minimum Mana To jungle Clear", xearth_jungleclear, 1, 500, 50)


xearth_combo_r_options = menu:add_subcategory("R Settings", xearth_category)
xearth_combo_r_set_key = menu:add_keybinder("Semi Manual R Key", xearth_combo_r_options, 65)


xearth_draw = menu:add_subcategory("Drawing Features", xearth_category)
xearth_draw_q = menu:add_checkbox("Draw Q", xearth_draw, 1)
xearth_draw_w = menu:add_checkbox("Draw W", xearth_draw, 1)
xearth_draw_e = menu:add_checkbox("Draw E", xearth_draw, 1)
xearth_draw_r = menu:add_checkbox("Draw R", xearth_draw, 1)
xearth_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill", xearth_draw, 1)
xearth_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", xearth_draw, 1, "Health Bar Damage Is Computed From R, Q, W, E")

-- Damage

--local GetQDmg = getdmg("Q", target, game.myHero, 1)
--local GetWDmg = getdmg("W", target, game.myHero, 1)
--local GetEDmg = getdmg("E", target, game.myHero, 1)
--local GetRDmg = getdmg("R", target, game.myHero, 1)

-- Casting

local function CastQ(unit)
	target = selector:find_target(Q.range, mode_health)

	if target.object_id ~= 0 then
		spellbook:start_charged_spell(SLOT_Q)
		origin = target.origin
		x, y, z = origin.x, origin.y, origin.z
		pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)

		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:release_charged_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
		end
	end
end

local function CastW(unit)
	target = selector:find_target(W.range, mode_health)

	if target.object_id ~= 0 then
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

local function CastE(unit)
	target = selector:find_target(E.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_E) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(E.speed, E.delay, E.range, E.width, target, false, false)

			if pred_output.can_cast then
				castPos = pred_output.cast_pos
				spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

local function CastR1(unit)
	target = selector:find_target(R1.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			if target:health_percentage() <= menu:get_value(xearth_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(xearth_combo_r_my_hp) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(R1.speed, R1.delay, R1.range, R1.width, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_R, R1.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

local function CastR2(unit)
	target = selector:find_target(R2.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			if target:health_percentage() <= menu:get_value(xearth_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(xearth_combo_r_my_hp) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(R2.speed, R2.delay, R2.range, R2.width, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_R, R2.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

local function CastR3(unit)
	target = selector:find_target(R3.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			if target:health_percentage() <= menu:get_value(xearth_combo_r_enemy_hp) then
				if local_player:health_percentage() >= menu:get_value(xearth_combo_r_my_hp) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(R3.speed, R3.delay, R3.range, R3.width, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_R, R3.delay, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
	end
end

-- Combo

local function Combo()

	if menu:get_value(xearth_combo_use_q) == 1 then
		if Ready(SLOT_Q) then
			if not HasQCharged(myHero) then
				CastQ(target)
			end
		end
	end


	if menu:get_value(xearth_combo_use_w) == 1 then
		CastW()
	end

	if menu:get_value(xearth_combo_use_e) == 1 then
		CastE()
	end

	if menu:get_value(xearth_combo_use_r) == 1 then
		CastR1(target)
	end
end

--Harass

--[[local function Harass()
	if menu:get_value(xearth_harass_use_q) == 1 then
		CastQ(target)
	end


	if menu:get_value(xearth_harass_use_w) == 1 then
		CastW(target)
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.xearthgin) <= Q.range and Ready(SLOT_Q) and IsValid(target) then
			if menu:get_value(xearth_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						xearthgin = target.xearthgin
						x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
						spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						orbwalker:reset_aa()
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.xearthgin) <=  W.range and Ready(SLOT_W) and IsValid(target) then
			if menu:get_value(xearth_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						xearthgin = target.xearthgin
						x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
						pred_output = pred:predict(W.speed, W.delay, W.range, W.width, target, false, false)

						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.xearthgin) <= R.range and Ready(SLOT_R) and IsValid(target) then
			if menu:get_value(xearth_ks_use_r) == 1 then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) then
						xearthgin = target.xearthgin
						x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
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

		if menu:get_value(xearth_laneclear_use_q) == 1 and menu:get_value(xearth_lasthit_auto) == 0 then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.xearthgin) < Q.range and IsValid(target) then
				if GetMinionCount(Q.range, target) >= menu:get_value(xearth_laneclear_min_q) then
					if not orbwalker:can_attack() or myHero.attack_range < myHero:distance_to(target.xearthgin) then
						if Ready(SLOT_Q) then
							xearthgin = target.xearthgin
							x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
							spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
						end
					end
				end
			end
		end
		if menu:get_value(xearth_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.xearthgin) < W.range and IsValid(target) then
				if GetMinionCount(W.range, target) >= menu:get_value(xearth_laneclear_min_w) then
					if Ready(SLOT_W) then
						xearthgin = target.xearthgin
						x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
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

		if target.object_id ~= 0 and menu:get_value(xearth_jungleclear_use_q) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.xearthgin) < Q.range and IsValid(target) then
			if Ready(SLOT_Q) then
				xearthgin = target.xearthgin
				x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
				spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
			end
		end
		if target.object_id ~= 0 and menu:get_value(xearth_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.xearthgin) < W.range and IsValid(target) then
			if not Ready(SLOT_Q) then
				if Ready(SLOT_W) then
					xearthgin = target.xearthgin
					x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
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
	target = selector:find_target(R.range, mode_health)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			xearthgin = target.xearthgin
			x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
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
		if myHero:distance_to(target.xearthgin) < attackRange then
			orbwalker:attack_target(target)
		end
	end

	target = selector:find_target(RF.range, mode_health)
	if target.object_id ~= 0 then
		if Ready(SLOT_R) and Ready(SLOT_F) and Ready(SLOT_E) then
			xearthgin = target.xearthgin
			x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
			spellbook:cast_spell(SLOT_F, 0.1, x, y, z)
		end
	end

	if target.object_id ~= 0 then
		if not Ready(SLOT_F) and Ready(SLOT_E) and not HasCastedxearthE(myHero) then
			xearthgin = target.xearthgin
			x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
		end
	end

	if not Ready(SLOT_F) and Ready(SLOT_R) and HasCastedxearthE(myHero) then
		Rtarget = selector:find_target(R.range, mode_health)
		xearthgin = Rtarget.xearthgin
		x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
		pred_output = pred:predict(R.speed, R.delay, R.range, R.width, target, false, false)

		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
		end
	end
end

-- Auto R >= Targets

--[[local function AutoRxTargets()

	local function AutoRxTargets()
	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.xearthgin) <= R.range and Ready(SLOT_R) and IsValid(target) then
			if GetEnemyCount(R.range, myHero) >= menu:get_value(xearth_combo_r_auto_x) then
				if Ready(SLOT_R) then
					xearthgin = target.xearthgin
					x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
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

-- Auto Q last Hit

local function AutoQLastHit(target)
	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.xearthgin) < Q.range and IsValid(target) then
			if GetMinionCount(Q.range, target) >= 1 then
				if GetQDmg(target) > target.health then
					if combo:get_mode() ~= MODE_COMBO and combo:get_mode() ~= MODE_HARASS and not game:is_key_down(menu:get_value(xearth_combokey)) then
						if not orbwalker:can_attack() or myHero.attack_range < myHero:distance_to(target.xearthgin) then
							if Ready(SLOT_Q) then
								xearthgin = target.xearthgin
								x, y, z = xearthgin.x, xearthgin.y, xearthgin.z
								spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
								orbwalker:reset_aa()
							end
						end
					end
				end
			end
		end
	end
end

function on_process_spell(obj, args)
	if Is_Me(obj) then
		if args.spell_name == "xearthQ" or "xearthQ3" or "xearthW" then
			Wcast = false
			AAcast = false
			Target = selector:find_target(myHero.attack_range)
			if Target.object_id ~= 0 and not Ready(SLOT_Q) then
				orbwalker:attack_target(Target)
			end
		end
		if args.spell_name == "xearthBasicAttack" or "xearthBasicAttack2" or "xearthBasicAttack3" or "xearthBasicAttack4" or "xearthCritAttack" or "xearthCritAttack2" or "xearthCritAttack3" or "xearthCritAttack4" then
			AutoTime = game.game_time
			Wcast = true
		end

	if args.spell_name == "xearthBasicAttack" or "xearthBasicAttack2" or "xearthBasicAttack3" or "xearthBasicAttack4" or "xearthCritAttack" or "xearthCritAttack2" or "xearthCritAttack3" or "xearthCritAttack4" then
			AutoAATime = game.game_time
			AAcast = true
		end
	end
end]]


-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
		local_player = game.local_player

		if local_player.object_id ~= 0 then
			origin = local_player.origin
			x, y, z = origin.x, origin.y, origin.z
		end

		if menu:get_value(xearth_draw_q) == 1 then
			--if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
			--end
		end

		if menu:get_value(xearth_draw_w) == 1 then
			if Ready(SLOT_W) then
				renderer:draw_circle(x, y, z, W.range, 0, 0, 255, 255)
			end
		end

		if menu:get_value(xearth_draw_e) == 1 then
			if Ready(SLOT_W) then
				renderer:draw_circle(x, y, z, E.range, 225, 0, 0, 255)
			end
		end

		if menu:get_value(xearth_draw_r) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(x, y, z, R1.range, 225, 0, 0, 255)
			end
		end

		--[[for i, target in ipairs(GetEnemyHeroes()) do
			local fulldmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target) + myHero.total_attack_damage * 2
			if Ready(SLOT_Q) and Ready(SLOT_W) and Ready(SLOT_R) then
				if target.object_id ~= 0 and myHero:distance_to(target.xearthgin) <= 1000 then
					if menu:get_value(xearth_draw_kill) == 1 then
						if fulldmg > target.health and IsValid(target) then
							renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 30, "Full Combo + 2 AA Can Kill Target")
						end
					end
				end
			end
			if menu:get_value(xearth_draw_kill_healthbar) == 1 then
				target:draw_damage_health_bar(fulldmg)
			end
		end
	end

	--[[if menu:get_value(xearth_lasthit_draw) == 1 then
		if menu:get_value(xearth_lasthit_auto) == 1 then
			renderer:draw_text_big_centered(screen_size.width / 2, 0, "Auto Q Only Last Hit Enabled")
		end
	end]]
end

local function on_tick()
	if game:is_key_down(menu:get_value(xearth_combokey)) and menu:get_value(xearth_enabled) == 1 then
		Combo()
	end

	--if combo:get_mode() == MODE_HARASS then
	--	Harass()
	--end

	--if combo:get_mode() == MODE_LANECLEAR then
		--Clear()
		--JungleClear()
	--end

	--if game:is_key_down(menu:get_value(xearth_combo_r_set_key)) then
		--ManualRCast()
	--end

	--[[if menu:get_value(xearth_combo_r_auto) == 1 then
		AutoRxTargets()
	end]]

	--if combo:get_mode() == MODE_LASTHIT and menu:get_value(xearth_lasthit_use) == 1 and menu:get_value(xearth_lasthit_auto) == 0 then
		--AutoQLastHit()
	--end
	--if menu:get_value(xearth_lasthit_auto) == 1 and menu:get_value(xearth_lasthit_use) == 1 then
		--AutoQLastHit()
	--end

	--KillSteal()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
--client:set_event_callback("on_process_spell", on_process_spell)
