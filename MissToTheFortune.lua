if game.local_player.champ_name ~= "MissFortune" then
	return
end

-- AutoUpdate
do
    local function AutoUpdate()
		local Version = 6.2
		local file_name = "MissToTheFortune.lua"
		local url = "http://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/MissToTheFortune.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/MissToTheFortune.lua.version.txt")
        console:log("MissFortune.Lua Vers: "..Version)
		console:log("MissFortune.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("Sexy Miss Fortune v6.2 successfully loaded.....")
        else
			http:download_file(url, file_name)
            console:log("Sexy Miss Fortune Update available.....")
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

-- Menu Config

MF_category = menu:add_category("Sexy Miss Fortune")
MF_enabled = menu:add_checkbox("Enabled", MF_category, 1)
MF_combokey = menu:add_keybinder("Combo Key", MF_category, 32)
MF_manualcast_r = menu:add_keybinder("Semi Manual R Key (Hold To Block Kill Steal)", MF_category, 65)

MF_combo = menu:add_subcategory("Combo", MF_category)
MF_combo_use_q = menu:add_checkbox("Use Q", MF_combo, 1)
MF_combo_use_w = menu:add_checkbox("Use W", MF_combo, 1)
MF_combo_use_e = menu:add_checkbox("Use E", MF_combo, 1)

MF_harass = menu:add_subcategory("Harass", MF_category)
MF_harass_use_q = menu:add_checkbox("Use Q", MF_harass, 1)
MF_harass_use_w = menu:add_checkbox("Use W", MF_harass, 1)
MF_harass_use_e = menu:add_checkbox("use E", MF_harass, 1)
MF_harass_Q_Bounce = menu:add_checkbox("Use Q Bounce", MF_harass, 1)
MF_harass_mana = menu:add_slider("Minimum Mana To Harass", MF_harass, 1, 200, 50)

MF_killsteal = menu:add_subcategory("Kill Steal", MF_category)
MF_ks = menu:add_checkbox("Q Kill Steal Enabled", MF_killsteal, 1)

MF_laneclear = menu:add_subcategory("Lane Clear", MF_category)
MF_laneclear_use_q = menu:add_checkbox("Use Q", MF_laneclear, 1)
MF_laneclear_use_w = menu:add_checkbox("Use W", MF_laneclear, 1)
MF_laneclear_use_e = menu:add_checkbox("use E", MF_laneclear, 0)
MF_laneclear_mana = menu:add_slider("Minimum Mana To Lane Clear", MF_laneclear, 1, 200, 50)

MF_jungleclear = menu:add_subcategory("Jungle Clear", MF_category)
MF_jungleclear_use_q = menu:add_checkbox("Use Q", MF_jungleclear, 1)
MF_jungleclear_use_w = menu:add_checkbox("Use W", MF_jungleclear, 1)
MF_jungleclear_use_e = menu:add_checkbox("use E", MF_jungleclear, 0)
MF_jungleclear_mana = menu:add_slider("Minimum Mana To jungle Clear", MF_jungleclear, 1, 200, 50)

MF_draw = menu:add_subcategory("Draw Features", MF_category)
MF_draw_q = menu:add_checkbox("Draw Q Range", MF_draw, 1)
MF_draw_e = menu:add_checkbox("Use E Range", MF_draw, 1)
MF_draw_r = menu:add_checkbox("use R Range", MF_draw, 1)
MF_drawcombo_enable = menu:add_checkbox("Draw AD/AP Combo Text", MF_draw, 1)

-- Casting

local function CastQ(unit)
	target = selector:find_target(650, distance)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_Q) then
			if not orbwalker:can_attack() then
				spellbook:cast_spell_targetted(SLOT_Q, target, 0.25)
				orbwalker:reset_aa()
			end
		end
	end
end

local function CastW(unit)
	target = selector:find_target(650, distance)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_W) then
			spellbook:cast_spell(SLOT_W, 0.25)
		end
	end
end

local function CastE(unit)
	target = selector:find_target(1000, distance)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_E) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell(SLOT_E, 0.25, x, y, z)
		end
	end
end

local function CastR(unit)
	target = selector:find_target(1400, health)

	if target.object_id ~= 0 then
		if spellbook:can_cast(SLOT_R) then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell(SLOT_R, 0.25, x, y, z)
		end
	end
end

-- Combo AD

local function Combo_AD()
	if menu:get_value(MF_combo_use_q) == 1 then
		CastQ(target)
	end

	if menu:get_value(MF_combo_use_w) == 1 then
		CastW(target)
	end

	if menu:get_value(MF_combo_use_e) == 1 then
		CastE(target)
	end
end

-- Combo AP

local function Combo_AP()
	if menu:get_value(MF_combo_use_e) == 1 then
		CastE(target)
	end

	if menu:get_value(MF_combo_use_w) == 1 then
		CastW(target)
	end

	if menu:get_value(MF_combo_use_q) == 1 then
		CastQ(target)
	end
end

--Harass

local function Harass()
	if menu:get_value(MF_harass_use_q) == 1 then
		if local_player.mana >= menu:get_value(MF_harass_mana) then
			CastQ(target)
		end
	end
	if menu:get_value(MF_harass_use_w) == 1 then
		if local_player.mana >= menu:get_value(MF_harass_mana) then
			CastW(target)
		end
	end

	if menu:get_value(MF_harass_use_e) == 1 then
		if local_player.mana >= menu:get_value(MF_harass_mana) then
			CastE(target)
		end
	end
end

-- Harass Q Bounce

local function Harras_Bounce_Q()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(MF_harass_Q_Bounce) == 1 and Ready(SLOT_Q) then
			if local_player.mana >= menu:get_value(MF_harass_mana) then
				if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 650 and IsValid(target) then
					if GetMinionCount(500, target) >= 1 then
						if GetEnemyCount(500, target) >= 1 then
							if Ready(SLOT_Q) then
								spellbook:cast_spell_targetted(SLOT_Q, target, 0.25)
								orbwalker:reset_aa()
							end
						end
					end
				end
			end
		end
	end
end

-- KillSteal

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function GetQDmgAD(unit)
    local Damage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local BonusDmg = myHero.total_attack_damage + (.35 * myHero.ability_power)
    local QADDamage = (({20, 40, 60, 80, 100})[level] + BonusDmg)
    if HasHealingBuff(unit) then
      Damage = QADDamage - 10
    else
			Damage = QADDamage
    end
		return unit:calculate_magic_damage(Damage)
end

local function KillSteal()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 650 and Ready(SLOT_Q) and IsValid(target) then

			if GetQDmgAD(target) > target.health then
				spellbook:cast_spell_targetted(SLOT_Q, target, 0.25)
				orbwalker:reset_aa()
			end
		end
	end
end

-- Lane Clear

local function Clear()
	minions = game.minions
	for i, target in ipairs(minions) do

		if menu:get_value(MF_laneclear_use_q) == 1 and Ready(SLOT_Q) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 650 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(MF_laneclear_mana) then
						if Ready(SLOT_Q) then
							if not orbwalker:can_attack() then
								spellbook:cast_spell_targetted(SLOT_Q, target, 0.25)
								orbwalker:reset_aa()
							end
						end
					end
				end
			end
		end
		if menu:get_value(MF_laneclear_use_w) == 1 and Ready(SLOT_W) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 650 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(MF_laneclear_mana) then
						if Ready(SLOT_W) then
							spellbook:cast_spell(SLOT_W, 0.25)
						end
					end
				end
			end
		end
		if menu:get_value(MF_laneclear_use_e) == 1 and Ready(SLOT_E) then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 800 and IsValid(target) then
				if GetMinionCount(500, target) >= 1 then
					if local_player.mana >= menu:get_value(MF_laneclear_mana) then
						if Ready(SLOT_E) then
							origin = target.origin
							x, y, z = origin.x, origin.y, origin.z
							spellbook:cast_spell(SLOT_E, 0.25, x, y, z)
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

		if target.object_id ~= 0 and menu:get_value(MF_jungleclear_use_q) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.origin) < 650 and IsValid(target) then
			if local_player.mana >= menu:get_value(MF_jungleclear_mana) then
				if Ready(SLOT_Q) then
					if not orbwalker:can_attack() then
						spellbook:cast_spell_targetted(SLOT_Q, target, 0.25)
						orbwalker:reset_aa()
					end
				end
			end
		end
		if target.object_id ~= 0 and menu:get_value(MF_jungleclear_use_w) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < 650 and IsValid(target) then
			if local_player.mana >= menu:get_value(MF_jungleclear_mana) then
				if Ready(SLOT_W) then
					spellbook:cast_spell(SLOT_W, 0.25)
				end
			end
		end
		if target.object_id ~= 0 and menu:get_value(MF_jungleclear_use_e) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < 800 and IsValid(target) then
			if local_player.mana >= menu:get_value(MF_jungleclear_mana) then
				if Ready(SLOT_E) then
					origin = target.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_E, 0.25, x, y, z)
				end
			end
		end
	end
end

-- Manual R Cast

local function ManualRCast()
	if Ready(SLOT_R) then
		CastR(target)
	end
end

-- object returns, draw and tick usage

local attack_damage = local_player.total_attack_damage
local ability_power = local_player.ability_power
screen_size = game.screen_size

local function on_draw()
	local_player = game.local_player

	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z

		if menu:get_value(MF_draw_q) == 1 and Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, 650, 255, 255, 255, 255)
		end

		if menu:get_value(MF_draw_e) == 1 and Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, 1000, 0, 0, 255, 255)
		end

		if menu:get_value(MF_draw_r) == 1 and Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, 1400, 225, 0, 0, 255)
		end
	end

	if menu:get_value(MF_drawcombo_enable) == 1 then
		if local_player.total_attack_damage >= local_player.ability_power then
			renderer:draw_text(screen_size.width / 2, 0, "AD Combo")
			else
			renderer:draw_text(screen_size.width / 2, 0, "AP Combo")

		end
	end
end

local function on_tick()
	if game:is_key_down(menu:get_value(MF_combokey)) and menu:get_value(MF_enabled) == 1 then
		if local_player.total_attack_damage >= local_player.ability_power then
			Combo_AD()
			else
			Combo_AD()
		end
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
		Harras_Bounce_Q()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(MF_manualcast_r)) then
		ManualRCast()
	end

	KillSteal()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
