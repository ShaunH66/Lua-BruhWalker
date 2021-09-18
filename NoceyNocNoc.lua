if game.local_player.champ_name ~= "Nocturne" then
	return
end

do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "NoceyNocNoc.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/NoceyNocNoc.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/NoceyNocNoc.lua.version.txt")
        console:log("NoceyNocNoc.lua Vers: "..Version)
		console:log("NoceyNocNoc.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("....................................................................................")
            console:log("............Shaun's Nocturne Successfully Loaded............")
						console:log("....................................................................................")
        else
			http:download_file(url, file_name)
			      console:log("Nocturne Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end
    end
    AutoUpdate()
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

--Initialization lines:
local ml = require "VectorMath"
pred:use_prediction()
arkpred = _G.Prediction
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player


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

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

local function GetLintargetCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.players
    for _, target in ipairs(players) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and ml.IsValid(target) and target.is_enemy and GetDistanceSqr(local_player, target) < Range then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end


-- No lib Functions Start

function IsKillable(unit)
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

local function GetAllyCountCicular(range, p1)
    count = 0
    players = game.players
    for _, unit in ipairs(players) do
    Range = range * range
        if not unit.is_enemy and GetDistanceSqr2(p1, unit.origin) < Range and ml.IsValid(unit) then
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

local function IsImmobiltarget(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(11) or unit:has_buff_type(21) or unit:has_buff_type(22) or unit:has_buff_type(24) or unit:has_buff_type(29) then
        return true
    end
    return false
end

function HasWPassiveCount(unit)
  if unit:has_buff("nocWDebuff") then
    buff = unit:get_buff("nocWDebuff")
    if buff.count > 0 then
      return buff.count
    end
	end
  return 0
end

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1)
	return QDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg

end

function OverKillCheck()
	target = selector:find_target(E.range, mode_health)
  local QWDMG = GetQDmg(target) + GetWDmg(target)
	if ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
		if QWDMG > target.health then
    	return true
		end
  end
  return false
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	noc_category = menu:add_category_sprite("Shaun's Nocturne", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	noc_category = menu:add_category("Shaun's Nocturne")
end

noc_enabled = menu:add_checkbox("Enabled", noc_category, 1)
noc_combokey = menu:add_keybinder("Combo Mode Key", noc_category, 32)
menu:add_label("Shaun's NoceyNocNoc", noc_category)
menu:add_label("#FlyBy Baby", noc_category)

noc_manual_function = menu:add_subcategory("Semi Manual [R] Settings", noc_category)
noc_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", noc_manual_function, 65)
e_table = {}
e_table[1] = "Lowest Target Health"
e_table[2] = "Closest To Cursor"
target_selection = menu:add_combobox("[Target Selection]", noc_manual_function, e_table, 0)

noc_ark_pred = menu:add_subcategory("[Pred Settings]", noc_category)
noc_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", noc_ark_pred, 1, 99, 50)

noc_ks_function = menu:add_subcategory("[Kill Steal]", noc_category)
noc_ks_q = menu:add_subcategory("[Q] Settings", noc_ks_function, 1)
noc_ks_use_q = menu:add_checkbox("Use [Q]", noc_ks_q, 1)
noc_ks_r = menu:add_subcategory("[R] Smart Settings", noc_ks_function, 1)
noc_ks_use_r = menu:add_checkbox("Use Smart [R]", noc_ks_r, 1)
noc_ks_r_blacklist = menu:add_subcategory("[R] Kill Steal Whitelist", noc_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), noc_ks_r_blacklist, 1)
    end
end

noc_combo = menu:add_subcategory("[Combo]", noc_category)
noc_combo_q = menu:add_subcategory("[Q] Settings", noc_combo)
noc_combo_use_q = menu:add_checkbox("Use [Q]", noc_combo_q, 1)
noc_combo_w = menu:add_subcategory("[W] Settings", noc_combo)
noc_combo_use_w = menu:add_checkbox("Use [W]", noc_combo_w, 1)
noc_combo_e = menu:add_subcategory("[E] Settings", noc_combo)
noc_combo_use_e = menu:add_checkbox("Use [E]", noc_combo_e, 1)

noc_harass = menu:add_subcategory("[Harass]", noc_category)
noc_harass_q = menu:add_subcategory("[Q] Settings", noc_harass)
noc_harass_use_q = menu:add_checkbox("Use [Q]", noc_harass_q, 1)
noc_harass_w = menu:add_subcategory("[W] Settings", noc_harass)
noc_harass_use_w = menu:add_checkbox("Use [W]", noc_harass_w, 1)
noc_harass_e = menu:add_subcategory("[E] Settings", noc_harass)
noc_harass_use_e = menu:add_checkbox("Use [E]", noc_harass_e, 1)
noc_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", noc_harass, 1, 100, 20)

noc_laneclear = menu:add_subcategory("[Lane Clear]", noc_category)
noc_laneclear_use_q = menu:add_checkbox("Use [Q]", noc_laneclear, 1)
noc_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", noc_laneclear, 1, 100, 20)
noc_laneclear_min_q = menu:add_slider("Minimum Minions To Use [Q]", noc_laneclear, 1, 10, 3)

noc_jungleclear = menu:add_subcategory("[Jungle Clear]", noc_category)
noc_jungleclear_use_q = menu:add_checkbox("Use [Q]", noc_jungleclear, 1)
noc_jungleclear_use_e = menu:add_checkbox("Use [E]", noc_jungleclear, 1)
noc_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", noc_jungleclear, 1, 100, 20)

noc_extra_gap = menu:add_subcategory("[E] Anti Gap Closer", noc_category)
noc_extra_gapclose = menu:add_toggle("[E] Toggle Anti Gap Closer key", 1, noc_extra_gap, 84, true)
noc_extra_gapclose_blacklist = menu:add_subcategory("[E] Anti Gap Closer Champ Whitelist", noc_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), noc_extra_gapclose_blacklist, 1)
    end
end

noc_extra_int = menu:add_subcategory("[E] Interrupt Channels", noc_category, 1)
noc_extra_interrupt = menu:add_checkbox("Use [E] Interrupt Major Channel Spells", noc_extra_int, 1)
noc_extra_interrupt_blacklist = menu:add_subcategory("[E] Interrupt Champ Whitelist", noc_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), noc_extra_interrupt_blacklist, 1)
    end
end

noc_draw = menu:add_subcategory("[Drawing] Features", noc_category)
noc_draw_q = menu:add_checkbox("Draw [Q] Range", noc_draw, 1)
noc_draw_e = menu:add_checkbox("Draw [E] Range", noc_draw, 1)
noc_draw_r = menu:add_checkbox("Draw [R] Range", noc_draw, 1)
noc_gap_draw = menu:add_checkbox("Draw Toggle Auto [R] Gap Closer", noc_draw, 1)
noc_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", noc_draw, 1)
noc_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", noc_draw, 1)

-- Ranges

local Q = { range = 1100, delay = .25, radius = 60, speed = math.huge }
local E = { range = 425, tether = 465, delay = .1 }
local rRange = { 2500, 3250, 4000 }

local Q_input = {
    source = myHero,
    speed = Q.speed, range = Q.range,
    delay = Q.delay, radius = Q.radius,
		collision = {"wind_wall"},
    type = "linear", hitbox = false
}

-- Casting

local function CastQ(unit)
	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(noc_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastQClear(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.radius, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W, 0.1, x, y, z)
end

local function CastE(unit)
	spellbook:cast_spell_targetted(SLOT_E, unit, E.delay)
end

local function CastR(unit)
	spellbook:cast_spell_targetted(SLOT_R, unit, 0.25)
end


-- Combo

local function Combo()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	if menu:get_value(noc_combo_use_q) == 1 then
		if ml.IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(qtarget.origin) <= Q.range then
				if ml.Ready(SLOT_Q) then
					CastQ(qtarget)
				end
			end
		end
	end

	if menu:get_value(noc_combo_use_w) == 1 then
		if ml.IsValid(etarget) and IsKillable(etarget) then
			if myHero:distance_to(etarget.origin) <= TrueAA then
				if ml.Ready(SLOT_W) then
					CastW()
				end
			end
		end
	end

	if menu:get_value(noc_combo_use_e) == 1 then
		if ml.IsValid(etarget) and IsKillable(etarget) then
			if myHero:distance_to(etarget.origin) <= E.range then
				if ml.Ready(SLOT_E) then
					CastE(etarget)
				end
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(noc_harass_min_mana) / 100

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	if menu:get_value(noc_harass_use_q) == 1 and GrabHarassMana then
		if ml.IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(qtarget.origin) <= Q.range then
				if ml.Ready(SLOT_Q) then
					CastQ(qtarget)
				end
			end
		end
	end

	if menu:get_value(noc_harass_use_w) == 1 and GrabHarassMana then
		if ml.IsValid(etarget) and IsKillable(etarget) then
			if myHero:distance_to(etarget.origin) <= TrueAA then
				if ml.Ready(SLOT_W) then
					CastW()
				end
			end
		end
	end

	if menu:get_value(noc_harass_use_e) == 1 and GrabHarassMana then
		if ml.IsValid(etarget) and IsKillable(etarget) then
			if myHero:distance_to(etarget.origin) <= E.range then
				if ml.Ready(SLOT_E) then
					CastE(etarget)
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	for i, target in ipairs(ml.GetEnemyHeroes()) do

		if menu:get_value(noc_ks_use_q) == 1 then
			if GetQDmg(target) > target.health then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= Q.range then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end

		local players = game.players
		if menu:get_value(noc_ks_use_r) == 1 then
			for _, ally in ipairs(players) do
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if ml.IsValid(target) and IsKillable(target) then
						if myHero:distance_to(target.origin) <= rRange[spellbook:get_spell_slot(SLOT_R).level] then
							if GetAllyCountCicular(ally.attack_range, target.origin) == 0 then
								if GetRDmg(target) > target.health then
								 	if menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
										if ml.Ready(SLOT_R) then
									  	CastR(target)
										end
									end
			          end
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
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(noc_laneclear_min_mana) / 100

	for i, target in ipairs(minions) do

		if menu:get_value(noc_laneclear_use_q) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and ml.IsValid(target) then
				if GetMinionCount(350, target) >= menu:get_value(noc_laneclear_min_q) then
					if ml.Ready(SLOT_Q) then
						CastQClear(target)
					end
				end
			end
		end
	end
end

-- Jungle Clear

	local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(noc_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(noc_jungleclear_use_q) == 1 then
			if ml.IsValid(target) then
				if GrabJungleClearMana and TargetNearMouse then
					if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and ml.IsValid(target) then
						if ml.Ready(SLOT_Q) then
							pred_output = pred:predict(Q.speed, Q.delay, Q.range, 120, target, false, false)

							if pred_output.can_cast then
								castPos = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
							end
						end
					end
				end
			end
		end

		if menu:get_value(noc_jungleclear_use_e) == 1 then
			if ml.IsValid(target) then
				if GrabJungleClearMana and TargetNearMouse then
					if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 350 and ml.IsValid(target) then
						if ml.Ready(SLOT_E) then
							CastE(target)
						end
					end
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

  if game:is_key_down(menu:get_value(noc_combo_r_set_key)) and menu:get_value(target_selection) == 0 and ml.Ready(SLOT_R) then
		target = selector:find_target(rRange[spellbook:get_spell_slot(SLOT_R).level], mode_health)
    if myHero:distance_to(target.origin) <= rRange[spellbook:get_spell_slot(SLOT_R).level] then
			if ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end

	if game:is_key_down(menu:get_value(noc_combo_r_set_key)) and menu:get_value(target_selection) == 1 and ml.Ready(SLOT_R) then
		target = selector:find_target(rRange[spellbook:get_spell_slot(SLOT_R).level], mode_cursor)
    if myHero:distance_to(target.origin) <= rRange[spellbook:get_spell_slot(SLOT_R).level] then
			if ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end
end


-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(noc_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
				if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) <= E.range and ml.Ready(SLOT_E) then
					CastE(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if ml.IsValid(obj) then
    if menu:get_value(noc_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) <= E.range and ml.Ready(SLOT_E) then
        	CastE(obj)
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

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end


	if menu:get_value(noc_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(noc_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(noc_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, rRange[spellbook:get_spell_slot(SLOT_R).level], 255, 0, 0, 255)
		end
	end

	if menu:get_toggle_state(noc_extra_gapclose) then
		if menu:get_value(noc_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [E] Gap Closer Enabled")
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetRDmg(target)
		if ml.Ready(SLOT_R) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(noc_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(noc_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

end

local function on_tick()

	if game:is_key_down(menu:get_value(noc_combokey)) and menu:get_value(noc_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(noc_combo_r_set_key)) then
		ManualR()
		orbwalker:move_to()
	end

	AutoKill()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
