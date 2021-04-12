if game.local_player.champ_name ~= "Cassiopeia" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 5
		local file_name = "CassioToThePeia.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/CassioToThePeia.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/CassioToThePeia.lua.version.txt")
        console:log("Cassiopeia.Lua Vers: "..Version)
		console:log("Cassiopeia.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Cassiopeia successfully loaded.....")
        else
			http:download_file(url, file_name)
            console:log("Sexy Cassiopeia Update available.....")
			console:log("Please reload via F5.....")
        end

    end

    AutoUpdate()

end

pred:use_prediction()

local myHero = game.local_player
local local_player = game.local_player


local function Ready(spell)
  return spellbook:can_cast(spell)
end

-- Return game data

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

-- Menu Config

Cass_category = menu:add_category("Shaun's Sexy Cassiopeia")
Cass_enabled = menu:add_checkbox("Enabled", Cass_category, 1)
Cass_combokey = menu:add_keybinder("Combo Mode Key", Cass_category, 32)
Cass_internal = menu:add_checkbox("Use Internal Spell Casting", Cass_category, 1)

Cass_ks_function = menu:add_subcategory("Kill Steal", Cass_category)
Cass_ks_use_q = menu:add_checkbox("Use Q", Cass_ks_function, 1)
Cass_ks_use_w = menu:add_checkbox("Use W", Cass_ks_function, 1)
Cass_ks_use_e = menu:add_checkbox("Use E", Cass_ks_function, 1)
Cass_ks_use_r = menu:add_checkbox("Use R", Cass_ks_function, 1)

Cass_lasthit = menu:add_subcategory("Last Hit", Cass_category)
Cass_lasthit_use = menu:add_checkbox("Use E Last Hit", Cass_lasthit, 1)
Cass_lasthit_auto = menu:add_checkbox("Auto E Last Hit", Cass_lasthit, 1)
Cass_lasthit_draw = menu:add_checkbox("Draw Auto E Last Hit", Cass_lasthit, 1)
Cass_lasthit_mana = menu:add_slider("Minimum Mana To E Last Hit", Cass_lasthit, 0, 200, 50)

Cass_combo = menu:add_subcategory("Combo", Cass_category)
Cass_combo_use_q = menu:add_checkbox("Use Q", Cass_combo, 1)
Cass_combo_use_w = menu:add_checkbox("Use W", Cass_combo, 1)
Cass_combo_use_e = menu:add_checkbox("Use E", Cass_combo, 1)
Cass_combo_use_r = menu:add_checkbox("Use R", Cass_combo, 1)
Cass_combo_w_posbuff = menu:add_checkbox("Only W When Q Has Missed and Target Is Not Poisoned", Cass_combo, 1)
Cass_combo_e_posbuff = menu:add_checkbox("Only E Combo When Posion Is Active", Cass_combo, 1)

Cass_harass = menu:add_subcategory("Harass", Cass_category)
Cass_harass_use_q = menu:add_checkbox("Use Q", Cass_harass, 1)
Cass_harass_use_w = menu:add_checkbox("Use W", Cass_harass, 1)
Cass_harass_use_e = menu:add_checkbox("use E", Cass_harass, 1)
Cass_harass_mana = menu:add_slider("Minimum Mana To Harass", Cass_harass, 0, 200, 50)
Cass_harass_posbuff = menu:add_checkbox("Only E Harass When Poison Is Active", Cass_harass, 1)

Cass_laneclear = menu:add_subcategory("Lane Clear", Cass_category)
Cass_laneclear_use_q = menu:add_checkbox("Use Q", Cass_laneclear, 1)
Cass_laneclear_use_w = menu:add_checkbox("Use W", Cass_laneclear, 1)
Cass_laneclear_use_e = menu:add_checkbox("use E", Cass_laneclear, 1)
Cass_laneclear_min_q = menu:add_slider("Minimum Minion Number To Q", Cass_laneclear, 1, 20, 3)
Cass_laneclear_min_w = menu:add_slider("Minimum Minion Number To W", Cass_laneclear, 1, 20, 3)
Cass_laneclear_mana = menu:add_slider("Minimum Mana To Lane Clear", Cass_laneclear, 0, 200, 50)

Cass_jungleclear = menu:add_subcategory("Jungle Clear", Cass_category)
Cass_jungleclear_use_q = menu:add_checkbox("Use Q", Cass_jungleclear, 1)
Cass_jungleclear_use_w = menu:add_checkbox("Use W", Cass_jungleclear, 1)
Cass_jungleclear_use_e = menu:add_checkbox("use E", Cass_jungleclear, 1)
Cass_jungleclear_mana = menu:add_slider("Minimum Mana To jungle Clear", Cass_jungleclear, 0, 200, 50)

Cass_combo_r_options = menu:add_subcategory("R Settings", Cass_category)
Cass_combo_r_set_key = menu:add_keybinder("Semi Manual R Key", Cass_combo_r_options, 65)
Cass_combo_r_enemy_hp = menu:add_slider("Use Combo R if Enemy HP is lower than [%]", Cass_combo_r_options, 1, 100, 50)
Cass_combo_r_my_hp = menu:add_slider("Only Combo R if My HP is Greater than [%]", Cass_combo_r_options, 1, 100, 20)
Cass_combo_r_auto = menu:add_checkbox("Use Auto R", Cass_combo_r_options, 1)
Cass_combo_r_auto_x = menu:add_slider("Number Of Targets To Perform Auto R", Cass_combo_r_options, 1, 5, 3)

Cass_draw = menu:add_subcategory("Drawing Features", Cass_category)
Cass_draw_q = menu:add_checkbox("Draw Q", Cass_draw, 1)
Cass_draw_e = menu:add_checkbox("Draw E", Cass_draw, 1)
Cass_draw_r = menu:add_checkbox("Draw R", Cass_draw, 1)
Cass_lasthit_draw = menu:add_checkbox("Draw Auto E Last Hit", Cass_draw, 1)

-- Dmg Calculations

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function GetQDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_Q).level
  local BonusDmg = myHero.total_attack_damage + (.9 * myHero.ability_power)
  local QDamage = (({75, 110, 145, 180, 215})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = QDamage - 10
  else
			Damage = QDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetWDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_W).level
  local BonusDmg = myHero.total_attack_damage + (0.15 * myHero.ability_power)
  local WDamage = (({75, 25, 30, 35, 40})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = WDamage - 10
  else
			Damage = WDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_E).level
  local BonusDmg = myHero.total_attack_damage + (0.6 * myHero.ability_power)
  local EDamage = (({10, 30, 50, 70, 90})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_magic_damage(Damage)
end

local function GetEDmgLastHit(unit)
	local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_E).level
  local BonusDmg = myHero.total_attack_damage + (0.15 * myHero.ability_power)
  local EDamage = ({20, 25, 30, 35, 40})[level] + BonusDmg
  if HasHealingBuff(unit) then
      Damage = EDamage - 10
  else
			Damage = EDamage
  end
	return unit:calculate_magic_damage(Damage)
end


local function GetRDmg(unit)
  local Damage = 0
  local level = spellbook:get_spell_slot(SLOT_R).level
  local BonusDmg = myHero.total_attack_damage + (0.5 * myHero.ability_power)
  local RDamage = (({150, 250, 350})[level] + BonusDmg)
  if HasHealingBuff(unit) then
      Damage = RDamage - 10
  else
			Damage = RDamage
  end
	return unit:calculate_magic_damage(Damage)
end

-- Casting

local function CastQ(unit)
	target = selector:find_target(850, distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_Q) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

			if pred_output.can_cast then
        castPos = pred_output.cast_pos
        spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end


local function CastW(unit)
	target = selector:find_target(700, distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_W) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

			if pred_output.can_cast then
        castPos = pred_output.cast_pos
        spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

local function CastE(unit)
	target = selector:find_target(700, distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_E) then
			if menu:get_value(Cass_internal) == 0 then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_E, 0.125, x, y, z)
			elseif menu:get_value(Cass_internal) == 1 then
				spellbook:cast_spell_targetted(SLOT_E, target, 0.125)
			end
		end
	end
end

local function CastR(unit)
	target = selector:find_target(825, distance)

	if target.object_id ~= 0 then
		if Ready(SLOT_R) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			pred_output = pred:predict(0, 0.25, 825, 40, target, false, true)

			if pred_output.can_cast then
        castPos = pred_output.cast_pos
        spellbook:cast_spell(SLOT_R, 0.5, castPos.x, castPos.y, castPos.z)
			end
		end
	end
end

-- Combo

local function Combo()
	if menu:get_value(Cass_combo_use_q) == 1 then
		CastQ(target)
	end

	if menu:get_value(Cass_combo_use_w) == 1 and not Ready(SLOT_Q) then
		if menu:get_value(Cass_combo_w_posbuff) == 0 then
		elseif menu:get_value(Cass_combo_w_posbuff) == 1 and not Ready(SLOT_Q) and not HasPoison(target) then
			CastW(target)
		end
	end

	if menu:get_value(Cass_combo_use_e) == 1 then
		if menu:get_value(Cass_combo_e_posbuff) == 0 then
		elseif menu:get_value(Cass_combo_e_posbuff) == 1 and HasPoison(target) then
			CastE(target)
		end
	end

	if menu:get_value(Cass_combo_use_r) == 1 then
		if target:health_percentage() <= menu:get_value(Cass_combo_r_enemy_hp) and local_player:health_percentage() >= menu:get_value(Cass_combo_r_my_hp) then
			if myHero:is_facing(target) and target:is_facing(myHero) then
				CastR(target)
			end
		end
	end
end

--Harass

local function Harass()
	if menu:get_value(Cass_harass_use_q) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) then
			CastQ(target)
		end
	end

	if menu:get_value(Cass_harass_use_w) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) then
			CastW(target)
		end
	end

	if menu:get_value(Cass_harass_use_e) == 1 then
		if local_player.mana >= menu:get_value(Cass_harass_mana) then
			if menu:get_value(Cass_harass_posbuff) == 0 then
				CastE(target)
			elseif menu:get_value(Cass_harass_posbuff) == 1 and HasPoison(target) then
				CastE(target)
			end
		end
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 850 and Ready(SLOT_Q) and IsValid(target) then
			if menu:get_value(Cass_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

						if pred_output.can_cast then
	        		castPos = pred_output.cast_pos
	        		spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 700 and Ready(SLOT_W) and IsValid(target) then
			if menu:get_value(Cass_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

						if pred_output.can_cast then
		        	castPos = pred_output.cast_pos
		        	spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 700 and Ready(SLOT_E) and IsValid(target) then
			if menu:get_value(Cass_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if Ready(SLOT_E) then
						if menu:get_value(Cass_internal) == 0 then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell(SLOT_E, 0.125, x, y, z)
						elseif menu:get_value(Cass_internal) == 1 then
							spellbook:cast_spell_targetted(SLOT_E, target, 0.125)
						end
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 825 and Ready(SLOT_R) and IsValid(target) then
			if menu:get_value(Cass_ks_use_r) == 1 then
				if GetRDmg(target) > target.health then
					if Ready(SLOT_R) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(0, 0.25, 825, 40, target, false, true)

						if pred_output.can_cast then
		        	castPos = pred_output.cast_pos
		        	spellbook:cast_spell(SLOT_R, 0.5, castPos.x, castPos.y, castPos.z)
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

		if menu:get_value(Cass_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 850 and IsValid(target) then
				if GetMinionCount(500, target) >= menu:get_value(Cass_laneclear_min_q) then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if Ready(SLOT_Q) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

							if pred_output.can_cast then
			        	castPos = pred_output.cast_pos
			        	spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z)
							end
						end
					end
				end
			end
		elseif menu:get_value(Cass_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
				if GetMinionCount(500, target) >= menu:get_value(Cass_laneclear_min_w) then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if Ready(SLOT_W) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

							if pred_output.can_cast then
				        castPos = pred_output.cast_pos
				        spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
							end
						end
					end
				end
			end
	 	elseif menu:get_value(Cass_laneclear_use_e) == 1 and Ready(SLOT_E) then
			if menu:get_value(Cass_lasthit_auto) == 0 then
				if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
					if GetMinionCount(500, target) >= 1 then
						if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
							if Ready(SLOT_E) then
								if menu:get_value(Cass_internal) == 0 then
									origin = target.origin
									x, y, z = origin.x, origin.y, origin.z
									spellbook:cast_spell(SLOT_E, 0.125, x, y, z)
								elseif menu:get_value(Cass_internal) == 1 then
									spellbook:cast_spell_targetted(SLOT_E, target, 0.125)
								end
							end
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

		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_q) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.origin) < 850 and IsValid(target) then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if Ready(SLOT_Q) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < 700 and IsValid(target) then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if Ready(SLOT_W) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_e) == 1 and Ready(SLOT_E) and myHero:distance_to(target.origin) < 700 and IsValid(target) then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if Ready(SLOT_E) then
					if menu:get_value(Cass_internal) == 0 then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_E, 0.125, x, y, z)
					elseif menu:get_value(Cass_internal) == 1 then
						spellbook:cast_spell_targetted(SLOT_E, target, 0.125)
					end
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	if myHero:is_facing(target) and target:is_facing(myHero) then
		CastR(target)
	end
end

-- Auto R >= Targets

local function AutoRxTargets()
	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 800 and Ready(SLOT_R) and IsValid(target) then
			if menu:get_value(Cass_combo_r_auto) == 1 and GetEnemyCount(800, myHero) >= menu:get_value(Cass_combo_r_auto_x) then
				if Ready(SLOT_R) then
					if myHero:is_facing(target) and target:is_facing(myHero) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						pred_output = pred:predict(0, 0.25, 825, 40, target, false, true)

						if pred_output.can_cast then
			        castPos = pred_output.cast_pos
			        spellbook:cast_spell(SLOT_R, 0.5, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end
	end
end

-- Auto E last Hit

local function AutoELastHit(target)
	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
			if GetMinionCount(700, target) >= 1 then
				if GetEDmgLastHit(target) > target.health then
					if combo:get_mode() ~= MODE_COMBO and combo:get_mode() ~= MODE_HARASS and not game:is_key_down(menu:get_value(Cass_combokey)) then
						if Ready(SLOT_E) then
							if menu:get_value(Cass_internal) == 0 then
								origin = target.origin
								x, y, z = origin.x, origin.y, origin.z
								spellbook:cast_spell(SLOT_E, 0.125, x, y, z)
							elseif menu:get_value(Cass_internal) == 1 then
								spellbook:cast_spell_targetted(SLOT_E, target, 0.125)
							end
						end
					end
				end
			end
		end
	end
end

-- object returns, draw and tick usage

screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z

		if menu:get_value(Cass_draw_q) == 1 then
			if Ready(SLOT_Q) then
				renderer:draw_circle(x, y, z, 850, 255, 255, 255, 255)
			end
		end

		if menu:get_value(Cass_draw_e) == 1 then
			if Ready(SLOT_E) then
				renderer:draw_circle(x, y, z, 700, 0, 0, 255, 255)
			end
		end

		if menu:get_value(Cass_draw_r) == 1 then
			if Ready(SLOT_R) then
				renderer:draw_circle(x, y, z, 825,225, 0, 0, 255)
			end
		end
	end

	if menu:get_value(Cass_lasthit_draw) == 1 and menu:get_value(Cass_lasthit_auto) == 1 then
		renderer:draw_text(screen_size.width / 2, screen_size.height / 20, "Auto E Only Last Hit Enabled")
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(Cass_combokey)) and menu:get_value(Cass_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(Cass_combo_r_set_key)) then
		ManualRCast()
	end

	if menu:get_value(Cass_combo_r_auto) == 1 then
		AutoRxTargets()
	end

	if combo:get_mode() == MODE_LASTHIT and menu:get_value(Cass_lasthit_use) == 1 and local_player.mana >= menu:get_value(Cass_lasthit_mana) and menu:get_value(Cass_lasthit_auto) == 0 then
		AutoELastHit()
	end
	if menu:get_value(Cass_lasthit_auto) == 1 and local_player.mana >= menu:get_value(Cass_lasthit_mana) then
		AutoELastHit()
	end
	KillSteal()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
