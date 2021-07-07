if game.local_player.champ_name ~= "Varus" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.3
		local file_name = "SixPackVarus.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SixPackVarus.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/SixPackVarus.lua.version.txt")
        console:log("SixPackVarus.lua Vers: "..Version)
		console:log("SixPackVarus.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("....................................................................................")
            console:log("............Shaun's Varus Successfully Loaded............")
						console:log("....................................................................................")
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
local qCharge = false
local qTime = nil
local qComplete = false
local KSQ = false
local FlashR = false

-- Ranges

local Q = { range = 1595, delay = .1, width = 140, speed = 1900 }
local W = { range = 0, delay = .1, width = 0, speed = 0 }
local E = { range = 925, delay = .25, width = 300, speed = math.huge }
local R = { range = 1370, delay = .25, width = 240, speed = 1500, tether = 650 }
local FlashRDraw = { range = 1760 }


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
  if unit:has_buff("VarusWDebuff") then
    buff = unit:get_buff("VarusWDebuff")
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

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	return WDmg
end

local function GetWDmg(unit)
	local WDmg = getdmg("W", unit, myHero, 1)
	local WStackDmg = getdmg("W", unit, myHero, 2)
	local TotalWDmg = WDmg + (WStackDmg*HasWPassiveCount(unit))
	return TotalWDmg
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
menu:add_label("Shaun's Sexy SixPack Varus", varus_category)
menu:add_label("#NeverLegDayBro", varus_category)

varus_manual_q = menu:add_subcategory("Semi Manual [Q] Features", varus_category)
varus_combo_q_set_key = menu:add_keybinder("Semi Manual [Q] Key", varus_manual_q, 65)
e_table = {}
e_table[1] = "Target Health"
e_table[2] = "Target Closest To Mouse"
varus_q_selector = menu:add_combobox("Manual [Q] Target Selector", varus_manual_q, e_table, 0)

varus_ks_function = menu:add_subcategory("[Kill Steal]", varus_category)
varus_ks_q = menu:add_subcategory("[Q] + [W] Settings", varus_ks_function, 1)
varus_ks_use_q = menu:add_checkbox("Use [Q] + [W]", varus_ks_q, 1)
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
varus_combo_use_q = menu:add_checkbox("Use [Q]", varus_combo_q, 1)
varus_combo_min_stacks = menu:add_slider("Minimum [W] Stacks To Use [Q]", varus_combo_q, 0, 3, 3)
varus_combo_w = menu:add_subcategory("[W] Settings", varus_combo)
varus_combo_use_w = menu:add_checkbox("Use [W]", varus_combo_w, 1)
varus_combo_e = menu:add_subcategory("[E] Settings", varus_combo)
varus_combo_use_e = menu:add_checkbox("Use [E]", varus_combo_e, 1)
varus_combo_min_e_stacks = menu:add_slider("Minimum [W] Stacks To Use [E]", varus_combo_e, 0, 3, 3)
varus_combo_e_aa = menu:add_checkbox("Only Use [E] Outside [AA] Range", varus_combo_e, 0)
varus_combo_use_e_first = menu:add_checkbox("Open Combo With [E]", varus_combo_e, 0)

varus_harass = menu:add_subcategory("[Harass]", varus_category)
varus_harass_q = menu:add_subcategory("[Q] Settings", varus_harass)
varus_harass_use_q = menu:add_checkbox("Use [Q]", varus_harass_q, 1)
varus_harass_min_stacks = menu:add_slider("Minimum [W] Stacks To Use [Q]", varus_harass_q, 0, 3, 2)
varus_harass_w = menu:add_subcategory("[W] Settings", varus_harass)
varus_harass_use_w = menu:add_checkbox("Use [W]", varus_harass_w, 1)
varus_harass_e = menu:add_subcategory("[E] Settings", varus_harass)
varus_harass_use_e = menu:add_checkbox("Use [E]", varus_harass_e, 1)
varus_harass_min_e_stacks = menu:add_slider("Minimum [W] Stacks To Use [E]", varus_harass_e, 0, 3, 2)
varus_harass_e_aa = menu:add_checkbox("Only Use [E] Outside [AA] Range", varus_harass_e, 0)
varus_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", varus_harass, 1, 100, 20)

varus_laneclear = menu:add_subcategory("[Lane Clear]", varus_category)
varus_laneclear_use_q = menu:add_checkbox("Use [Q]", varus_laneclear, 1)
varus_laneclear_use_e = menu:add_checkbox("Use [E]", varus_laneclear, 1)
varus_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", varus_laneclear, 1, 100, 20)
varus_laneclear_min_e = menu:add_slider("Minimum Minions To Use [E]", varus_laneclear, 1, 10, 3)

varus_jungleclear = menu:add_subcategory("[Jungle Clear]", varus_category)
varus_jungleclear_use_q = menu:add_checkbox("Use [Q]", varus_jungleclear, 1)
varus_jungleclear_use_e = menu:add_checkbox("Use [E]", varus_jungleclear, 1)
varus_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", varus_jungleclear, 1, 100, 20)

varus_extra = menu:add_subcategory("[R] Features", varus_category)
varus_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", varus_extra, 90)
varus_combo_flashr_key = menu:add_keybinder("[R] Flash Key", varus_extra, 88)
varus_auto_r_hit_use = menu:add_checkbox("Use Auto Chain [R]", varus_extra, 1)
varus_auto_r_hit = menu:add_slider("Minimum Chain [R] Targets", varus_extra, 1, 5, 3)
varus_auto_r_range = menu:add_slider("[R] Max Usage Distance", varus_extra, 1, 1370, 1250)

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
varus_draw_e = menu:add_checkbox("Draw [E] Range", varus_draw, 1)
varus_draw_r = menu:add_checkbox("Draw [R] Range", varus_draw, 1)
varus_draw_rflash = menu:add_checkbox("Draw [R] Flash Range", varus_draw, 1)
varus_Immobile_draw = menu:add_checkbox("Draw [Immobile] Target Text", varus_draw, 1)
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

local function CastRFlash(unit)

	pred_output = pred:predict(R.speed, R.delay, FlashRDraw.range, R.width, unit, false, false)
	if pred_output.can_cast and ml.Ready(SLOT_R) then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, castPos.x, castPos.y, castPos.z)
	end
end

-- Combo

local function Combo()

	local TrueAA = myHero.attack_range + myHero.bounding_radius

	target = selector:find_target(Q.range, mode_health)

	if menu:get_value(varus_combo_use_q) == 1 then
	  if ml.IsValid(target) and IsKillable(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid and qCharge then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				time_differential = (game.game_time - qTime)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				target = selector:find_target(range, mode_health)
				if target.object_id ~= 0 then
					if ml.IsValid(target) then
						origin = target.origin
						pred_output = pred:predict(1900, 0, range, 140, target, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if HasWPassiveCount(target) >= menu:get_value(varus_combo_min_stacks) then
					if ml.Ready(SLOT_Q) and not qCharge then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end

	if menu:get_value(varus_combo_use_w) == 1 and ml.Ready(SLOT_W) and qCharge then
		if ml.IsValid(target) and IsKillable(target) then
			CastW()
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and ml.Ready(SLOT_E) and not ml.Ready(SLOT_Q) then
		if menu:get_value(varus_combo_e_aa) == 1 and myHero:distance_to(target.origin) <= E.range and myHero:distance_to(target.origin) >= TrueAA and HasWPassiveCount(target) >= menu:get_value(varus_combo_min_e_stacks) then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and ml.Ready(SLOT_E) and HasWPassiveCount(target) <= 0 then
		if menu:get_value(varus_combo_e_aa) == 1 and myHero:distance_to(target.origin) <= E.range and myHero:distance_to(target.origin) >= TrueAA then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and ml.Ready(SLOT_E) and not ml.Ready(SLOT_Q) then
		if menu:get_value(varus_combo_e_aa) == 0 and myHero:distance_to(target.origin) <= E.range and HasWPassiveCount(target) >= menu:get_value(varus_combo_min_e_stacks) then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(varus_combo_use_e) == 1 and menu:get_value(varus_combo_use_e_first) == 1 and ml.Ready(SLOT_E) and HasWPassiveCount(target) <= 0 then
		if menu:get_value(varus_combo_e_aa) == 0 and myHero:distance_to(target.origin) <= E.range then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(varus_harass_min_mana) / 100

	local TrueAA = myHero.attack_range + myHero.bounding_radius

	target = selector:find_target(Q.range, mode_health)

	if menu:get_value(varus_harass_use_q) == 1 then
	  if ml.IsValid(target) and IsKillable(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid and qCharge then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				time_differential = (game.game_time - qTime)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				target = selector:find_target(range, mode_health)
				if target.object_id ~= 0 then
					if ml.IsValid(target) then
						origin = target.origin
						pred_output = pred:predict(1900, 0, range, 140, target, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if GrabHarassMana and HasWPassiveCount(target) >= menu:get_value(varus_harass_min_stacks) then
					if ml.Ready(SLOT_Q) and not qCharge then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end

	if menu:get_value(varus_harass_use_w) == 1 and ml.Ready(SLOT_W) and qCharge and GrabHarassMana then
		if ml.IsValid(target) and IsKillable(target) then
			CastW()
		end
	end

	if menu:get_value(varus_harass_use_e) == 1 and ml.Ready(SLOT_E) and not ml.Ready(SLOT_Q) and GrabHarassMana then
		if menu:get_value(varus_harass_e_aa) == 1 and myHero:distance_to(target.origin) <= E.range and myHero:distance_to(target.origin) >= TrueAA and HasWPassiveCount(target) >= menu:get_value(varus_harass_min_e_stacks) then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end

	if menu:get_value(varus_harass_use_e) == 1 and ml.Ready(SLOT_E) and not ml.Ready(SLOT_Q) and GrabHarassMana then
		if menu:get_value(varus_harass_e_aa) == 0 and myHero:distance_to(target.origin) <= E.range and HasWPassiveCount(target) >= menu:get_value(varus_harass_min_e_stacks) then
			if ml.IsValid(target) and IsKillable(target) then
				CastE(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	local TotalQDmg = GetWDmg(target) + GetQDmg(target)
	local TotalComboDmg = GetWDmg(target) + GetQDmg(target) + GetRDmg(target)
	for i, target in ipairs(ml.GetEnemyHeroes()) do

		if menu:get_value(varus_ks_use_q) == 1 then
			if TotalQDmg > target.health then
				--if ml.Ready(SLOT_Q) then
					if ml.IsValid(target) and IsKillable(target) then
						Charge_buff = local_player:get_buff("VarusQ")
						if Charge_buff.is_valid and qCharge then
							max_range = 825 + 70 + ((1.25 / 0.25) * 140)
							time_differential = (game.game_time - qTime)
							if time_differential < 1.25 then
								range = 825 + 70 + (time_differential * (140 / 0.25))
							else
								range = max_range
							end
							target = selector:find_target(range, mode_health)
							if target.object_id ~= 0 then
								if ml.Ready(SLOT_Q) and ml.IsValid(target) then
									origin = target.origin
									pred_output = pred:predict(1900, 0, range, 140, target, false, false)
									if pred_output.can_cast then
										cast_pos = pred_output.cast_pos
										spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
									end
								end
							end
						else
							--target = selector:find_target(1595, mode_health)
							if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
								if ml.Ready(SLOT_Q) then
									KSQ = true
									spellbook:start_charged_spell(SLOT_Q)
								end
							end
						end
					end
				--end
			end
		end

		if menu:get_value(varus_ks_use_q) == 1 and ml.Ready(SLOT_W) and qCharge then
			if TotalQDmg > target.health and ml.IsValid(target) and IsKillable(target) then
				CastW()
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
			if menu:get_value(varus_ks_use_smart) == 1 then
				if myHero:distance_to(target.origin) <= 700 then
					if TotalComboDmg > target.health then
				  	if menu:get_value_string("Use [Combo] Kill Steal On: "..tostring(target.champ_name)) == 1 then
							if ml.Ready(SLOT_R) and ml.Ready(SLOT_Q) then
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
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy then
				if GrabLaneClearMana and TargetNearMouse then
					Charge_buff = local_player:get_buff("VarusQ")
					if Charge_buff.is_valid and qCharge then
						max_range = 825 + 70 + ((1.25 / 0.25) * 140)
						time_differential = (game.game_time - qTime)
						if time_differential < 1.25 then
							range = 825 + 70 + (time_differential * (140 / 0.25))
						else
							range = max_range
						end
						if target.object_id ~= 0 then
							if ml.Ready(SLOT_Q) and ml.IsValid(target) then
								origin = target.origin
								pred_output = pred:predict(1900, 0, range, 140, target, false, false)
								if pred_output.can_cast then
									cast_pos = pred_output.cast_pos
									spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
								end
							end
						end
					else
						--target = selector:find_target(1595, mode_health)
						if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 900 then
							local qBestPos, qMostHit = GetBestCircularFarmPos(target, 900, Q.width)
							if qBestPos and qMostHit >= 2 then
								if ml.Ready(SLOT_Q) then
									spellbook:start_charged_spell(SLOT_Q)
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(varus_laneclear_use_e) == 1 and ml.Ready(SLOT_E) then
			if TargetNearMouse and GrabLaneClearMana and target.object_id ~= 0 and target.is_enemy then
				local BestPos, MostHit = GetBestCircularFarmPos(target, 600, E.width / 2)
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
			if ml.IsValid(target) then
				if GrabJungleClearMana and TargetNearMouse then
					Charge_buff = local_player:get_buff("VarusQ")
					if Charge_buff.is_valid and qCharge then
						max_range = 825 + 70 + ((1.25 / 0.25) * 140)
						time_differential = (game.game_time - qTime)
						if time_differential < 1.25 then
							range = 825 + 70 + (time_differential * (140 / 0.25))
						else
							range = max_range
						end
						if target.object_id ~= 0 then
							if ml.Ready(SLOT_Q) and ml.IsValid(target) then
								origin = target.origin
								pred_output = pred:predict(1900, 0, range, 140, target, false, false)
								if pred_output.can_cast then
									cast_pos = pred_output.cast_pos
									spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
								end
							end
						end
					else
						--target = selector:find_target(1595, mode_health)
						if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 600 then
							if ml.Ready(SLOT_Q) then
								spellbook:start_charged_spell(SLOT_Q)
							end
						end
					end
				end
			end
		end

		if menu:get_value(varus_jungleclear_use_e) == 1 and ml.Ready(SLOT_E) and target.object_id ~= 0 and target.is_enemy then
			if myHero:distance_to(target.origin) < 600 then
				if TargetNearMouse and GrabJungleClearMana then
					local BestPos, MostHit = GetBestCircularJungPos(target, 600, E.width / 2)
					if BestPos and MostHit then
						spellbook:cast_spell(SLOT_E, E.delay, BestPos.x, BestPos.y, BestPos.z)
					end
				end
			end
		end
	end
end

local function AutoQImmobiltarget()

	target = selector:find_target(Q.range, mode_health)

	if ml.IsValid(target) and IsKillable(target) then
		if IsImmobiltarget(target) then
			Charge_buff = local_player:get_buff("VarusQ")
			if Charge_buff.is_valid and qCharge then
				max_range = 825 + 70 + ((1.25 / 0.25) * 140)
				time_differential = (game.game_time - qTime - 1)
				if time_differential < 1.25 then
					range = 825 + 70 + (time_differential * (140 / 0.25))
				else
					range = max_range
				end
				target = selector:find_target(range, mode_health)
				if target.object_id ~= 0 then
					if ml.Ready(SLOT_Q) and ml.IsValid(target) then
						origin = target.origin
						pred_output = pred:predict(1900, 0, range, 140, target, false, false)
						if pred_output.can_cast then
							cast_pos = pred_output.cast_pos
							spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
						end
					end
				end
			else
				--target = selector:find_target(1595, mode_health)
				if myHero:distance_to(target.origin) < Q.range then
					if ml.Ready(SLOT_Q) then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end
	end
	if ml.Ready(SLOT_W) and IsImmobiltarget(target) and qCharge then
		if ml.IsValid(target) and IsKillable(target) then
			CastW()
		end
	end
end

-- Manual R

local function ManualR()

	target = selector:find_target(1500, mode_health)

  if game:is_key_down(menu:get_value(varus_combo_r_set_key)) and ml.Ready(SLOT_R) then
    if myHero:distance_to(target.origin) <= R.range and myHero:distance_to(target.origin) <= menu:get_value(varus_auto_r_range) then
			if ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end
end

-- R > Flash

local function RFlash()

	target = selector:find_target(FlashRDraw.range, mode_health)

  if game:is_key_down(menu:get_value(varus_combo_flashr_key)) and ml.Ready(SLOT_R) then
    if myHero:distance_to(target.origin) <= FlashRDraw.range then
			if ml.IsValid(target) and IsKillable(target) then
				origin = target.origin
				x, y, z = origin.x, origin.y, origin.z

				if IsFlashSlotD() and ml.Ready(SLOT_D) then
					spellbook:cast_spell(SLOT_D, 0.1, x, y, z)
					FlashR = true
					f_cast = client:get_tick_count() + 1
				elseif IsFlashSlotF() and ml.Ready(SLOT_F) then
					spellbook:cast_spell(SLOT_F, 0.1, x, y, z)
					FlashR = true
					f_cast = client:get_tick_count() + 1
				end
			end
		end
	end
	if FlashR and f_cast ~= nil and client:get_tick_count() > f_cast then
		CastRFlash(target)
  end
end

-- Auto R 'X' Targets

local function AutoRxTargets()

	target = selector:find_target(1500, mode_health)

	if menu:get_value(varus_auto_r_hit_use) == 1 then
	  if ml.Ready(SLOT_R) and ml.IsValid(target) and IsKillable(target) then
	    if myHero:distance_to(target.origin) <= R.range and myHero:distance_to(target.origin) <= menu:get_value(varus_auto_r_range) then
				local _, count = ml.GetEnemyCount(target.origin, 590)
				if count >= menu:get_value(varus_auto_r_hit) then
					CastR(target)
				end
			end
    end
  end
end

local function ManualQ()

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) and menu:get_value(varus_q_selector) == 0 then
		target = selector:find_target(Q.range, mode_health)
		if ml.IsValid(target) then
			--if ml.Ready(SLOT_Q) then
				Charge_buff = local_player:get_buff("VarusQ")
				if Charge_buff.is_valid and qCharge then
					max_range = 825 + 70 + ((1.25 / 0.25) * 140)
					time_differential = (game.game_time - qTime - 1)
					if time_differential < 1.25 then
						range = 825 + 70 + (time_differential * (140 / 0.25))
					else
						range = max_range
					end
					target = selector:find_target(range, mode_health)
					if target.object_id ~= 0 then
						if ml.Ready(SLOT_Q) and ml.IsValid(target) then
							origin = target.origin
							pred_output = pred:predict(1900, 0, range, 140, target, false, false)
							if pred_output.can_cast then
								cast_pos = pred_output.cast_pos
								spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
							end
						end
					end
				else
					target = selector:find_target(1595, mode_health)
					if myHero:distance_to(target.origin) < Q.range then
						if ml.Ready(SLOT_Q) then
							spellbook:start_charged_spell(SLOT_Q)
						end
					end
				end
			--end
		end
	end

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) and menu:get_value(varus_q_selector) == 1 then
		target = selector:find_target(Q.range, mode_cursor)
		if ml.IsValid(target) then
			-- ml.Ready(SLOT_Q) then
				Charge_buff = local_player:get_buff("VarusQ")
				if Charge_buff.is_valid and qCharge  then
					max_range = 825 + 70 + ((1.25 / 0.25) * 140)
					time_differential = (game.game_time - qTime - 1)
					if time_differential < 1.25 then
						range = 825 + 70 + (time_differential * (140 / 0.25))
					else
						range = max_range
					end
					target = selector:find_target(range, mode_cursor)
					if target.object_id ~= 0 then
						if ml.Ready(SLOT_Q) and ml.IsValid(target) then
							origin = target.origin
							pred_output = pred:predict(1900, 0, range, 140, target, false, false)
							if pred_output.can_cast then
								cast_pos = pred_output.cast_pos
								spellbook:release_charged_spell(SLOT_Q, 0, cast_pos.x, cast_pos.y, cast_pos.z)
							end
						end
					end
				else
					target = selector:find_target(1595, mode_cursor)
					if myHero:distance_to(target.origin) < Q.range then
						if ml.Ready(SLOT_Q) then
							spellbook:start_charged_spell(SLOT_Q)
						end
					end
				end
			--end
		end
	end

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) and ml.Ready(SLOT_W) and qCharge then
		if ml.IsValid(target) and IsKillable(target) then
			CastW()
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
			qTime = game.game_time
			qCharge = true
			qComplete = true
		end
	end
end

local function on_buff_end(obj, buff_name)
	if Is_Me(obj) then
		if buff_name == "VarusQLaunch" then
			qComplete = false
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

	if menu:get_value(varus_draw_rflash) == 1 then
		if ml.Ready(SLOT_R) then
			if IsFlashSlotD() or IsFlashSlotF() and ml.Ready(SLOT_D) then
				renderer:draw_circle(x, y, z, FlashRDraw.range, 255, 0, 255, 255)
			end
		end
	end

	if menu:get_toggle_state(varus_extra_gapclose) then
		if menu:get_value(varus_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [R] Gap Closer Enabled")
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetEDmg(target) + GetRDmg(target)
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

	--[[if IsImmobiltarget(target) and ml.Ready(SLOT_Q) and myHero:distance_to(target.origin) < Q.range then
		if menu:get_value(varus_Immobile_draw) == 1 then
			if enemydraw.is_valid and target.is_on_screen then
				renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Immobile Target Using [Q]")
			end
		end
	end]]

end

local function on_tick()

	if game:is_key_down(menu:get_value(varus_combokey)) and menu:get_value(varus_enabled) == 1 and not KSQ then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS and not KSQ then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	--[[if not game:is_key_down(menu:get_value(varus_combokey)) then
		AutoQImmobiltarget()
	end]]

	if game:is_key_down(menu:get_value(varus_combo_r_set_key)) then
		ManualR()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(varus_combo_q_set_key)) then
		ManualQ()
		orbwalker:move_to()
	end

	if game:is_key_down(menu:get_value(varus_combo_flashr_key)) then
		RFlash()
		orbwalker:move_to()
	end

	if not game:is_key_down(menu:get_value(varus_combo_flashr_key)) and f_cast ~= nil and client:get_tick_count() > f_cast then
		FlashR = false
		f_cast = nil
	end

	AutoKill()

	AutoRxTargets()

	if not qComplete and not ml.Ready(SLOT_Q) then
		qCharge = false
		qTime = nil
		KSQ = false
	end

	if not myHero.is_alive then
		qCharge = false
		qTime = nil
		KSQ = false
	end


end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_buff_active", on_buff_active)
client:set_event_callback("on_buff_end", on_buff_end)
