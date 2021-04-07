if game.local_player.champ_name ~= "Cassiopeia" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 1
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

require "PKDamageLib"
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

-- Casting

local function CastQ(unit)
	target = selector:find_target(850, distance)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_Q) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			my_origin = game.local_player.origin
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
		if spellbook:can_cast(SLOT_W) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			my_origin = game.local_player.origin
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
		if spellbook:can_cast(SLOT_E) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell_targetted(SLOT_E, 0.125, target)
		end
	end
end

local function CastR(unit)
	target = selector:find_target(825, distance)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_R) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			my_origin = game.local_player.origin
			pred_output = pred:predict(0, 0.25, 825, 40, target, false, true)

			if pred_output.can_cast then
        castPos = pred_output.cast_pos
        spellbook:cast_spell(SLOT_R, 0.5, castPos.x, castPos.y, castPos.z)

			end
		end
	end
end

-- Menu Config

Cass_category = menu:add_category("Cassiopeia")
Cass_enabled = menu:add_checkbox("Enabled", Cass_category, 1)
Cass_combokey = menu:add_keybinder("Combo Mode Key", Cass_category, 32)
Cass_manualcast_r = menu:add_keybinder("Semi Manual R Key", Cass_category, 65)

Cass_combo = menu:add_subcategory("Kill Steal", Cass_category)
Cass_combo_use_q = menu:add_checkbox("Use Q", Cass_combo, 1)
Cass_combo_use_w = menu:add_checkbox("Use W", Cass_combo, 1)
Cass_combo_use_e = menu:add_checkbox("Use E", Cass_combo, 1)
Cass_combo_use_R = menu:add_checkbox("Use R", Cass_combo, 1)

Cass_AA = menu:add_subcategory("AA Combo Usage", Cass_category)
Cass_AA_use = menu:add_checkbox("Use AA In Combo Mode", Cass_AA, 1)
Cass_AA_level = menu:add_slider("Use AA In Combo >= Level Slider Value", Cass_AA, 1, 18, 6)

Cass_lasthit = menu:add_subcategory("Auto Last Hit", Cass_category)
Cass_lasthit_use = menu:add_checkbox("Use E Auto Last Hit", Cass_lasthit, 1)
Cass_lasthit_mana = menu:add_slider("Minimum Mana To Auto E Last Hit", CCass_lasthit, 1, 18, 6)

Cass_panic_r_usage = menu:add_subcategory("Panic R", Cass_category)
Cass_panic_r = menu:add_checkbox("Use Panic R", Cass_panic_r_usage, 1)
Cass_panic_r_health = menu:add_slider("Use Panic R <= Total Health", Cass_panic_r_usage, 1, 20, 500)

Cass_combo = menu:add_subcategory("Combo", Cass_category)
Cass_combo_use_q = menu:add_checkbox("Use Q", Cass_combo, 1)
Cass_combo_use_w = menu:add_checkbox("Use W", Cass_combo, 1)
Cass_combo_use_e = menu:add_checkbox("Use E", Cass_combo, 1)

Cass_harass = menu:add_subcategory("Harass", Cass_category)
Cass_harass_use_q = menu:add_checkbox("Use Q", Cass_harass, 1)
Cass_harass_use_w = menu:add_checkbox("Use W", Cass_harass, 1)
Cass_harass_use_e = menu:add_checkbox("use E", Cass_harass, 1)
Cass_harass_mana = menu:add_slider("Minimum Mana To Harass", Cass_harass, 0, 200, 50)

Cass_laneclear = menu:add_subcategory("Lane Clear", Cass_category)
Cass_laneclear_use_q = menu:add_checkbox("Use Q", Cass_laneclear, 1)
Cass_laneclear_use_w = menu:add_checkbox("Use W", Cass_laneclear, 1)
Cass_laneclear_use_e = menu:add_checkbox("use E", Cass_laneclear, 1)
Cass_laneclear_mana = menu:add_slider("Minimum Mana To Harass", Cass_laneclear, 0, 200, 50)

Cass_jungleclear = menu:add_subcategory("Jungle Clear", Cass_category)
Cass_jungleclear_use_q = menu:add_checkbox("Use Q", Cass_jungleclear, 1)
Cass_jungleclear_use_w = menu:add_checkbox("Use W", Cass_jungleclear, 1)
Cass_jungleclear_use_e = menu:add_checkbox("use E", Cass_jungleclear, 1)
Cass_jungleclear_mana = menu:add_slider("Minimum Mana To jungle", Cass_jungleclear, 0, 200, 50)

-- Combo AA

local function Combo_AA()
	if menu:get_value(Cass_combo_use_q) == 1 then
		CastQ(target)
	end

	if menu:get_value(Cass_combo_use_w) == 1 then
		CastW(target)
	end

	if menu:get_value(Cass_combo_use_e) == 1 then
		CastE(target)
	end
end

-- Combo No AA

local function Combo_NOAA()
	if menu:get_value(Cass_combo_use_q) == 1 then
		CastQ(target)
	end

	if menu:get_value(Cass_combo_use_w) == 1 then
		CastW(target)
	end

	if menu:get_value(Cass_combo_use_e) == 1 then
		CastE(target)
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
			CastE(target)
		end
	end
end

-- KillSteal

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 850 and Ready(SLOT_Q) and IsValid(target) then

			local QDmg = getdmg("Q", target, game.local_player, 1)
			if QDmg > target.health then
				console:log("Q CAN KILL")
				if Ready(SLOT_Q) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					my_origin = game.local_player.origin
					pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

					if pred_output.can_cast then
	        	castPos = pred_output.cast_pos
	        	spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 700 and Ready(SLOT_W) and IsValid(target) then
			local WDmg = getdmg("W", target, game.local_player, 1)
			if WDmg > target.health then
				console:log("W CAN KILL")
				if Ready(SLOT_W) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					my_origin = game.local_player.origin
					pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

					if pred_output.can_cast then
		        castPos = pred_output.cast_pos
		        spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
					end
				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 700 and Ready(SLOT_E) and IsValid(target) then
			local EDmg = getdmg("E", target, game.local_player, 1)
			if EDmg > target.health then
				console:log("E CAN KILL")
				if Ready(SLOT_E) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell_targetted(SLOT_E, 0.125, target)

				end
			end
		end
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 825 and Ready(SLOT_R) and IsValid(target) then
			local RDmg = getdmg("R", target, game.local_player, 1)
			if RDmg > target.health then
				console:log("R CAN KILL")
				if Ready(SLOT_R) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					my_origin = game.local_player.origin
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

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(Cass_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 850 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if Ready(SLOT_Q) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							my_origin = game.local_player.origin
							pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

							if pred_output.can_cast then
			        	castPos = pred_output.cast_pos
			        	spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z
							end
						end
					end
				end
			end
		end
		if menu:get_value(Cass_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if Ready(SLOT_W) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							my_origin = game.local_player.origin
							pred_output = pred:predict(0, 0.25, 700, 160, target, false, false)

							if pred_output.can_cast then
				        castPos = pred_output.cast_pos
				        spellbook:cast_spell(SLOT_W, 0.25, castPos.x, castPos.y, castPos.z)
							end
						end
					end
				end
			end
		end
		if menu:get_value(Cass_laneclear_use_e) == 1 and Ready(SLOT_E) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(Cass_laneclear_mana) then
						if Ready(SLOT_E) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell_targetted(SLOT_E, 0.125, target)
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
					my_origin = game.local_player.origin
					pred_output = pred:predict(0, 0.25, 850, 75, target, false, false)

					if pred_output.can_cast then
						castPos = pred_output.cast_pos
						spellbook:cast_spell(SLOT_Q, 0.25, castPos.x, castPos.y, castPos.z

					end
				end
			end
		end
		if target.object_id ~= 0 and menu:get_value(Cass_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < 700 and IsValid(target) then
			if local_player.mana >= menu:get_value(Cass_jungleclear_mana) then
				if Ready(SLOT_W) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					my_origin = game.local_player.origin
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
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell_targetted(SLOT_E, 0.125, target)
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	if Ready(SLOT_R)
		CastR(target)
	end
end

-- Panic R Cast

local function PanicRCast()
	if Ready(SLOT_R)
		CastR(target)
	end
end

-- Auto E last Hit

local function AutoELastHit()
	minions = game.minions
	for i, target in ipairs(minions) do
		if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 700 and IsValid(target) then
			if GetMinionCount(500, target) >= 1 then
				if EDmg > target.health then
					if Ready(SLOT_E) then
						origin = target.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell_targetted(SLOT_E, 0.125, target)
					end
				end
			end
		end
	end
end

-- object returns, draw and tick usage

local function on_tick()
	if menu:get_value(Cass_panic_r) == 1 and local_player.Health <= menu:get_value(Cass_panic_r_health) then
		PanicRCast()
	end
end

	if game:is_key_down(menu:get_value(Cass_combokey)) and menu:get_value(Cass_enabled) == 1 then
		if menu:get_value(Cass_AA_use) == 1 then
			if local_player.level <= menu:get_value(Cass_AA_level)
				Combo_AA()
			end
		end
	end

	if game:is_key_down(menu:get_value(Cass_combokey)) and menu:get_value(Cass_enabled) == 1 then
		if menu:get_value(Cass_AA_use) == 0 then
			Combo_NOAA()
			orbwalker:disable_auto_attacks()
		end
	end

	if game:is_key_down(menu:get_value(Cass_combokey)) and menu:get_value(Cass_enabled) == 1 then
		if menu:get_value(Cass_AA_use) == 1 and local_player.level >= menu:get_value(Cass_AA_level) then
			Combo_NOAA()
			orbwalker:disable_auto_attacks()
		end
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(Cass_manualcast_r)) then
		ManualRCast()
	end

	if menu:get_value(Cass_lasthit_use) == 1 and local_player.mana >= menu:get_value(Cass_lasthit_mana) then
		AutoELastHit()
	end

	KillSteal()
end


client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
