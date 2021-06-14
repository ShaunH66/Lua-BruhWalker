if game.local_player.champ_name ~= "Varus" then
	return
end

--[[do
    local function AutoUpdate()
		local Version = 0.5
		local file_name = "SixPackVarus.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SixPackVarus.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SixPackVarus.lua.version.txt")
        console:log("BlueBallsvarus.lua Vers: "..Version)
		console:log("BlueBallsvarus.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".......................................................")
            			console:log("..Shaun's Varus Successfully Loaded...")
						console:log(".......................................................")
        else
			http:download_file(url, file_name)
			      		console:log("SixPack Varus Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end
    end
    AutoUpdate()
end]]

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
require "PKDamageLib"

local myHero = game.local_player
local local_player = game.local_player

-- Ranges

local Q = { range = 1595, delay = .1, width = 140, speed = 1900 }
local W = { range = 0, delay = .1, width = 0, speed = 0 }
local E = { range = 925, delay = .25, width = 300, speed = math.huge }
local R = { range = 1370, delay = .25, width = 240, speed = 1500, tether = 650 }


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

local function GetLineTargetCount(source, aimPos, delay, speed, width)
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

local function IsKillable(unit)
	if unit:has_buff_type(15) or unit:has_buff_type(17) or unit:has_buff("sionpassivezombie") then
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

local function StunManaCheck()
	local spell_slot_q = spellbook:get_spell_slot(SLOT_Q)
	local spell_slot_e = spellbook:get_spell_slot(SLOT_E)
	local total_spell_cost = spell_slot_q.spell_data.mana_cost + spell_slot_e.spell_data.mana_cost
	if myHero.mana > total_spell_cost then
		return true
	end
	return false
end

local function IsImmobileTarget(unit)
    if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(10) or unit:has_buff_type(11) or unit:has_buff_type(21) or unit:has_buff_type(22) or unit:has_buff_type(24) or unit:has_buff_type(29) then
        return true
    end
    return false
end

function HasWPassiveCount(unit)
    if unit:has_buff("varuswdebuff") then
        buff = unit:get_buff("varuswdebuff")
        if buff.count > 0 then
            return buff.count
        end
    end
    return 0
end

local function TrueAARange()
  local TrueAARange = myHero.attack_range + myHero.bounding_radius
    return TrueAARange
  end
  return 0
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
	varus_category = menu:add_category_sprite("SixPack Varus", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	varus_category = menu:add_category("SixPack Varus")
end

varus_enabled = menu:add_checkbox("Enabled", varus_category, 1)
varus_combokey = menu:add_keybinder("Combo Mode Key", varus_category, 32)
varus_combo_q_set_key = menu:add_keybinder("[Q] Key - Closest To Mouse Position Target", varus_extra, 65)
menu:add_label("SixPack Varus", varus_category)
menu:add_label("#NotLegDayBro", varus_category)

varus_ks_function = menu:add_subcategory("[Kill Steal]", varus_category)
varus_ks_q = menu:add_subcategory("[Q] Settings", varus_ks_function, 1)
varus_ks_use_q = menu:add_checkbox("Use [Q]", varus_ks_q, 1)
varus_ks_e = menu:add_subcategory("[E] Settings", varus_ks_function, 1)
varus_ks_use_e = menu:add_checkbox("Use [E]", varus_ks_e, 1)
varus_ks_smart = menu:add_subcategory("[Combo] KS Smart Settings", varus_ks_function)
varus_ks_use_smart = menu:add_checkbox("Use [Combo] KS", varus_ks_smart, 1)
varus_ks_r_blacklist = menu:add_subcategory("[Combo] Kill Steal Blacklist", varus_ks_smart)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [Combo] Kill Steal On: "..tostring(t.champ_name), varus_ks_r_blacklist, 1)
    end
end

varus_combo = menu:add_subcategory("[Combo]", varus_category)
varus_combo_q = menu:add_subcategory("[Q] Settings", varus_combo)
varus_combo_use_q = menu:add_checkbox("Use [Q] Inside [AA] range", varus_combo_q, 1)
varus_combo_min_stacks = menu:add_slider("Minimum [W] Stacks To Use [Q]", varus_combo_q, 0, 5, 2)
varus_combo_w = menu:add_subcategory("[W] Settings", varus_combo)
varus_combo_use_w = menu:add_checkbox("Use [W]", varus_combo_w, 1)
varus_combo_e = menu:add_subcategory("[E] Settings", varus_combo)
varus_combo_use_e = menu:add_checkbox("Use [E]", varus_combo_e, 1)
varus_combo_min_e_stacks = menu:add_slider("Minimum [W] Stacks To Use [E]", varus_combo_e, 0, 5, 4)
varus_combo_e_aa = menu:add_checkbox("Only Use [E] Outside [AA] Range", varus_combo_e, 0)

varus_harass = menu:add_subcategory("[Harass]", varus_category)
varus_harass_q = menu:add_subcategory("[Q] Settings", varus_harass)
varus_harass_use_q = menu:add_checkbox("Use [Q]", varus_harass_q, 1)
varus_harass_use_q = menu:add_checkbox("Use [Q] Inside [AA] range", varus_harass_q, 1)
varus_harass_min_stacks = menu:add_slider("Minimum [W] Stacks To Use [Q]", varus_harass_q, 0, 5, 2)
varus_harass_w = menu:add_subcategory("[W] Settings", varus_harass)
varus_harass_use_w = menu:add_checkbox("Use [W]", varus_harass_w, 1)
varus_harass_e = menu:add_subcategory("[E] Settings", varus_harass)
varus_harass_use_e = menu:add_checkbox("Use [E]", varus_harass_e, 1)
varus_harass_min_e_stacks = menu:add_slider("Minimum [W] Stacks To Use [E]", varus_harass_e, 0, 5, 4)
varus_harass_e_aa = menu:add_checkbox("Only Use [E] Outside [AA] Range", varus_harass_e, 0)
varus_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", varus_harass, 1, 100, 20)

varus_laneclear = menu:add_subcategory("[Lane Clear]", varus_category)
varus_laneclear_use_q = menu:add_checkbox("Use [Q]", varus_laneclear, 1)
varus_laneclear_use_w = menu:add_checkbox("Use [W]", varus_laneclear, 1)
varus_laneclear_use_e = menu:add_checkbox("Use [E]", varus_laneclear, 1)
varus_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", varus_laneclear, 1, 100, 20)
varus_laneclear_min_e = menu:add_slider("Minimum Minions To Use [E]", varus_laneclear, 1, 10, 3)

varus_jungleclear = menu:add_subcategory("[Jungle Clear]", varus_category)
varus_jungleclear_use_q = menu:add_checkbox("Use [Q]", varus_jungleclear, 1)
varus_jungleclear_use_w = menu:add_checkbox("Use [W]", varus_jungleclear, 1)
varus_jungleclear_use_e = menu:add_checkbox("Use [E]", varus_jungleclear, 1)
varus_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", varus_jungleclear, 1, 100, 20)

varus_extra = menu:add_subcategory("[Automated] Features", varus_category)
varus_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", varus_extra, 90)
varus_immobile_stun = menu:add_checkbox("Auto [Q] Immobile Targets ", varus_extra, 1)
varus_auto_r_hit = menu:add_slider("Minimum Targets Hit To Use Auto [R]", varus_extra, 1, 5, 3)

varus_extra_gap = menu:add_subcategory("[R] Anti Gap Closer", varus_category)
varus_extra_gapclose = menu:add_toggle("[R] Toggle Anti Gap Closer key", 1, varus_extra_gap, 84, true)
varus_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", varus_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), varus_extra_gapclose_blacklist, 1)
    end
end

varus_draw = menu:add_subcategory("[Drawing] Features", varus_category)
varus_draw_q = menu:add_checkbox("Draw [Q] Range", varus_draw, 1)
varus_draw_w = menu:add_checkbox("Draw [W] Range", varus_draw, 1)
varus_draw_e = menu:add_checkbox("Draw [E] Range", varus_draw, 1)
varus_draw_r = menu:add_checkbox("Draw [R] Range", varus_draw, 1)
varus_gap_draw = menu:add_checkbox("Draw Toggle Auto [R] Gap Closer", varus_draw, 1)
varus_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", varus_draw, 1)
varus_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", varus_draw, 1)


-- Casting

local function CastW()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE(unit)
	pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastR(unit)
	pred_output = pred:predict(R.speed, R.delay, R.range, R.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()

	local TrueAA = TrueAARange()

	target = selector:find_target(TrueAA, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	if menu:get_value(varus_combo_use_q) == 1 and ml.Ready(SLOT_Q) then
	  if myHero:distance_to(target.origin) <= TrueAA and HasWPassiveCount(target) >= menu:get_value(varus_combo_min_stacks) and ml.IsValid(target) and IsKillable(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				10 + 8
				time_differential = (game.game_time - qTime)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				qtarget = selector:find_target(range, mode_health)
				if qtarget.object_id ~= 0 then
					if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
						origin = qtarget.origin
						pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if target.object_id ~= 0 then
					if ml.Ready(SLOT_Q) then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end

	if menu:get_value(varus_combo_use_w) == 1 and ml.Ready(SLOT_W) then
		if myHero:distance_to(target.origin) <= TrueAA and ml.IsValid(target) and IsKillable(target) then
			CastW()
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and ml.Ready(SLOT_E) then
		if menu:get_value(varus_combo_e_aa) == 1 and myHero:distance_to(etarget.origin) <= E.range and myHero:distance_to(etarget.origin) >= TrueAA and HasWPassiveCount(etarget) >= menu:get_value(varus_combo_min_e_stacks) then
			if ml.IsValid(etarget) and IsKillable(etarget)
				CastE(etarget)
			end
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and ml.Ready(SLOT_E) then
		if menu:get_value(varus_combos_e_aa) == 0 and myHero:distance_to(etarget.origin) <= E.range and HasWPassiveCount(etarget) >= menu:get_value(varus_combo_min_e_stacks) then
			if ml.IsValid(etarget) and IsKillable(etarget)
				CastE(etarget)
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(varus_harass_min_mana) / 100

	local TrueAA = TrueAARange()

	target = selector:find_target(TrueAA, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	if menu:get_value(varus_harass_use_q) == 1 and ml.Ready(SLOT_Q) and GrabHarassMana then
	  if myHero:distance_to(target.origin) <= TrueAA and HasWPassiveCount(target) >= menu:get_value(varus_combo_min_stacks) and ml.IsValid(target) and IsKillable(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				10 + 8
				time_differential = (game.game_time - qTime)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				qtarget = selector:find_target(range, mode_health)
				if qtarget.object_id ~= 0 then
					if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
						origin = qtarget.origin
						pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if target.object_id ~= 0 then
					if ml.Ready(SLOT_Q) then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end

	if menu:get_value(varus_harasso_use_w) == 1 and ml.Ready(SLOT_W) and GrabHarassMana then
		if myHero:distance_to(target.origin) <= TrueAA and ml.IsValid(target) and IsKillable(target) then
			CastW()
		end
	end

	if menu:get_value(varus_harass_use_e) == 1 and ml.Ready(SLOT_E) and GrabHarassMana then
		if menu:get_value(varus_harass_e_aa) == 1 and myHero:distance_to(etarget.origin) <= E.range and myHero:distance_to(etarget.origin) >= TrueAA and HasWPassiveCount(etarget) >= menu:get_value(varus_harass_min_e_stacks) then
			if ml.IsValid(etarget) and IsKillable(etarget)
				CastE(etarget)
			end
		end
	end

	if menu:get_value(varus_harass_use_e) == 1 and ml.Ready(SLOT_E) and GrabHarassMana then
		if menu:get_value(varus_harass_e_aa) == 0 and myHero:distance_to(etarget.origin) <= E.range and HasWPassiveCount(etarget) >= menu:get_value(varus_harass_min_e_stacks) then
			if ml.IsValid(etarget) and IsKillable(etarget)
				CastE(etarget)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do

		if menu:get_value(varus_ks_use_q) == 1 then
			if GetQDmg(target) > target.health then
				if ml.Ready(SLOT_Q) then
					if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
						Charge_buff = local_player:get_buff("VarusQ")
						if Charge_buff.is_valid then
							max_range = 825 + 70 + ((1.25 / 0.25) * 140)
							10 + 8
							time_differential = (game.game_time - qTime)
							if time_differential < 1.25 then
								range = 825 + 70 + (time_differential * (140 / 0.25))
							else
								range = max_range
							end
							qtarget = selector:find_target(range, mode_health)
							if qtarget.object_id ~= 0 then
								if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
									origin = qtarget.origin
									pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
									if pred_output.can_cast then
										cast_pos = pred_output.cast_pos
										spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
									end
								end
							end
						else
							--target = selector:find_target(1595, mode_health)
							if target.object_id ~= 0 then
								if ml.Ready(SLOT_Q) then
									spellbook:start_charged_spell(SLOT_Q)
								end
							end
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(varus_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if ml.Ready(SLOT_E) then
						CastE(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(varus_ks_use_r) == 1 then
				if myHero:distance_to(target.origin) <= R.range then
					if GetRDmg(target) > target.health then
				  	if menu:get_value_string("Use [Combo] Kill Steal On: "..tostring(target.champ_name)) == 1 then
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

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(varus_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(varus_laneclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 600 then
				if GrabLaneClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					Charge_buff = local_player:get_buff("VarusQ")
					if Charge_buff.is_valid then
						max_range = 825 + 70 + ((1.25 / 0.25) * 140)
						10 + 8
						time_differential = (game.game_time - qTime)
						if time_differential < 1.25 then
							range = 825 + 70 + (time_differential * (140 / 0.25))
						else
							range = max_range
						end
						qtarget = selector:find_target(range, mode_health)
						if qtarget.object_id ~= 0 then
							if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
								origin = qtarget.origin
								pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
								if pred_output.can_cast then
									cast_pos = pred_output.cast_pos
									spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
								end
							end
						end
					else
						--target = selector:find_target(1595, mode_health)
						if target.object_id ~= 0 then
							if ml.Ready(SLOT_Q) then
								spellbook:start_charged_spell(SLOT_Q)
							end
						end
					end
				end
			end
		end

		if menu:get_value(varus_laneclear_use_w) == 1 and ml.Ready(SLOT_W) then
			if TargetNearMouse and GrabLaneClearMana then
				if myHero:distance_to(target.origin) <= myHero.attack_range then
					CastW()
				end
			end
		end

		if menu:get_value(varus_laneclear_use_e) == 1 and ml.Ready(SLOT_E) then
			if TargetNearMouse and GrabLaneClearMana then
				local BestPos, MostHit = GetBestCircularFarmPos(target, 600, E.range / 2)
				if BestPos and MostHit then
					if MostHit >= menu:get_value(varus_laneclear_min_e) then
						spellbook:cast_spell(SLOT_E, E.delay, BestPos.x, BestPos.y, BestPos.z)
					end
				end
			end
		end
	end
end

-- Jungle Clear

	local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(varus_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(varus_jungleclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 600 then
				if GrabJungleClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					Charge_buff = local_player:get_buff("VarusQ")
					if Charge_buff.is_valid then
						max_range = 825 + 70 + ((1.25 / 0.25) * 140)
						10 + 8
						time_differential = (game.game_time - qTime)
						if time_differential < 1.25 then
							range = 825 + 70 + (time_differential * (140 / 0.25))
						else
							range = max_range
						end
						qtarget = selector:find_target(range, mode_health)
						if qtarget.object_id ~= 0 then
							if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
								origin = qtarget.origin
								pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
								if pred_output.can_cast then
									cast_pos = pred_output.cast_pos
									spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
								end
							end
						end
					else
						--target = selector:find_target(1595, mode_health)
						if target.object_id ~= 0 then
							if ml.Ready(SLOT_Q) then
								spellbook:start_charged_spell(SLOT_Q)
							end
						end
					end
				end
			end
		end

		if menu:get_value(varus_jungleclear_use_w) == 1 and ml.Ready(SLOT_W) then
			if TargetNearMouse and GrabJungleClearMana then
				if myHero:distance_to(target.origin) <= myHero.attack_range then
					CastW()
				end
			end
		end

		if menu:get_value(varus_jungleclear_use_e) == 1 and ml.Ready(SLOT_E) then
			if myHero:distance_to(target.origin) < 600 then
				if TargetNearMouse and GrabJungleClearMana then
					local BestPos, MostHit = GetBestCircularFarmPos(target, 600, E.range / 2)
					if BestPos and MostHit then
						spellbook:cast_spell(SLOT_E, E.delay, BestPos.x, BestPos.y, BestPos.z)
					end
				end
			end
		end
	end
end

local function AutoQImmobileTarget()

	target = selector:find_target(Q.range, mode_health)

	if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
		if ml.Ready(SLOT_Q) and IsImmobileTarget(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				10 + 8
				time_differential = (game.game_time - qTime)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				qtarget = selector:find_target(range, mode_health)
				if qtarget.object_id ~= 0 then
					if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
						origin = qtarget.origin
						pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if target.object_id ~= 0 then
					if ml.Ready(SLOT_Q) then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

	target = selector:find_target(R.range, mode_health)

  if game:is_key_down(menu:get_value(varus_combo_r_set_key)) and ml.Ready(SLOT_R) then
    if myHero:distance_to(target.origin) < R.range then
			if ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end
end

-- Auto R 'X' Targets

local function AutoRxTargets()

	target = selector:find_target(1500, mode_health)

  if ml.Ready(SLOT_R) and ml.IsValid(target) and IsKillable(target) then
    if myHero:distance_to(target.origin) < R.range then
			local _, count = ml.GetEnemyCount(target.origin, 580)
			if count >= menu:get_value(varus_auto_r_hit) then
				CastR(target)
			end
    end
  end
end

local function ManualQ()

	target = selector:find_target(Q.range, mode_health)

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) then
		if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
			if ml.Ready(SLOT_Q) and IsImmobileTarget(target) then
				Charge_buff = local_player:get_buff("VarusQ")
				if Charge_buff.is_valid then
					max_range = 825 + 70 + ((1.25 / 0.25) * 140)
					10 + 8
					time_differential = (game.game_time - qTime)
					if time_differential < 1.25 then
						range = 825 + 70 + (time_differential * (140 / 0.25))
					else
						range = max_range
					end
					qtarget = selector:find_target(range, mode_health)
					if qtarget.object_id ~= 0 then
						if ml.Ready(SLOT_Q) and ml.IsValid(qtarget) then
							origin = qtarget.origin
							pred_output = pred:predict(1900, 0, range, 140, qtarget, false, false)
							if pred_output.can_cast then
								cast_pos = pred_output.cast_pos
								spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
							end
						end
					end
				else
					target = selector:find_target(1595, mode_health)
					if target.object_id ~= 0 then
						if ml.Ready(SLOT_Q) then
							spellbook:start_charged_spell(SLOT_Q)
						end
					end
				end
			end
		end
	end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(varus_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
				if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) < 500 and myHero:distance_to(obj.origin) < 500 and ml.Ready(SLOT_R) then
					CastR(obj)
				end
			end
		end
	end
end

-- buff checks

local function on_buff_active(obj, buff_name)
	if Is_Me(obj) then
		if buff_name == "VarusQLaunch" then
			qCharge = true
			qTime = game.game_time
		end
	end
end

local function on_buff_end(obj, buff_name)
	if Is_Me(obj) then
		if buff_name == "VarusQLaunch" then
			qCharge = false
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


	if menu:get_value(varus_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(varus_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(varus_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(varus_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	if menu:get_toggle_state(varus_extra_gapclose) then
		if menu:get_value(varus_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 30, "Toggle Auto [R] Gap Closer Enabled")
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetWDmg(target) + GetRDmg(target)
		if ml.Ready(SLOT_R) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(varus_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(varus_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(varus_combokey)) and menu:get_value(varus_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if not game:is_key_down(menu:get_value(varus_combokey)) then
		AutoQImmobileTarget()
	end

	if game:is_key_down(menu:get_value(varus_combo_r_set_key)) then
		ManualR()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) then
		ManualQ()
		orbwalker:move_to()
	end

	AutoKill()
	AutoRxTargets()


end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_buff_active", on_buff_active)
client:set_event_callback("on_buff_end", on_buff_end)
