if game.local_player.champ_name ~= "Syndra" then
	return
end

do
    local function AutoUpdate()
		local Version = 2.1
		local file_name = "BlueBallsSyndra.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BlueBallsSyndra.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BlueBallsSyndra.lua.version.txt")
        console:log("BlueBallsSyndra.lua Vers: "..Version)
		console:log("BlueBallsSyndra.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("......................................................................")
            console:log("...BlueBalls Syndra Successfully Loaded...")
						console:log("......................................................................")
        else
			http:download_file(url, file_name)
			      console:log("BlueBalls Syndra Update available.....")
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
local BlockW = false
local Interrupt_text = false
local Gapclose_text = false
local e_cast = nil
local tick_count_go = false
local CastQE = false
local qe_cast = nil

-- Ranges

local Q = { range = 800, delay = .25, width = 180, speed = math.huge }
local W = { range = 925, delay = .25, width = 225, speed = math.huge }
local E = { range = 1100, delay = .25, width = 100, speed = math.huge }
local R = { range = 675, delay = .25, width = 0, speed = math.huge }

spellE = {
    range1 = 700,
    range2 = 800,
    angle1 = 40,
    angle2 = 60
}

local Q_input = {
    source = myHero,
    speed = math.huge, range = 1100,
    delay = 0.65, radius = 180,
    collision = {},
    type = "circular", hitbox = false
}

local W_input = {
    source = myHero,
    speed = 1450, range = 950,
    delay = 0.25, radius = 225,
    collision = {},
    type = "circular", hitbox = false
}

local E_input = {
    source = myHero,
    speed = 2500, range = 1100,
    delay = 0.25, angle = 60,
    collision = {"wind_wall"},
    type = "conic", hitbox = false
}

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

-- Ben's Syndra Shite

local function in_list(tab, val)
		for index, value in ipairs(tab) do
				if value == val then
						return true
				end
		end
		return false
end


local ballHolder = {}
local ballTimer = {}
function on_object_created(object, obj_name)
		if obj_name == "Seed" then
				if not in_list(ballHolder, object) then
						table.insert(ballHolder, object)
				end
		end
end

function Size()
		local count = 0
		for _, ball in pairs(ballHolder) do
			count = count + 1
		end
		return count
end

local function GetFirst(tab)
    if tab[0] ~= nil then
        return tab[0]
    else
        return tab[1]
    end
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

local function GetLineTargetCount_pos(StartPos, EndPos, delay, speed, width)
    local castpos = nil
    local count = 0
    for _, ball in pairs(ballHolder) do
        if ball.is_alive and ball:distance_to(local_player.origin) < ERange then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, ball.origin)
            if pointSegment and isOnSegment and (ml.GetDistanceSqr(ball, pointSegment) <= width * width) then
                castpos = ball
                count = count + 1
            end
        end
    end
    if count > 1 then
        count = 1
    end
    return castpos, count
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

local function GetLineTargetCount_Combo(StartPos, EndPos, delay, speed, width)
	local castpos = nil
	for _, ball in pairs(ballHolder) do
		if ball and ball.is_visible and ball.is_alive and ball:distance_to(local_player.origin) < Q.range then
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, ball.origin)
			if pointSegment and isOnSegment and (GetDistanceSqr2(ball.origin, pointSegment) <= width * width) then
				castpos = ball
			end
		end
	end
	return castpos
end

local function AngleNorm(angle)
    if angle < 0 then
        angle = angle + 360
    elseif angle > 360 then
        angle = angle - 360
    end
    return angle
end

local function AngleDelta(angle1, angle2)
    local phi = math.fmod(math.abs(angle1 - angle2), 360)
    local delta = 0
    if phi > 180 then
        delta = 360 - phi
    else
        delta = phi
    end
    return delta
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

local function SyndraHasW()
  if myHero:has_buff("syndrawtooltip") then
    return true
  end
  return false
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
	local R2Dmg = getdmg("R", unit, myHero, 2)
	local TotalRDmg = (RDmg + (R2Dmg*(3 + Size())))
	return TotalRDmg
end

function OverKillCheck(unit)
  local QWDMG = GetQDmg(unit) + GetWDmg(unit)
	if ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
		if QWDMG > unit.health then
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
	syndra_category = menu:add_category_sprite("BlueBalls Syndra", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	syndra_category = menu:add_category("BlueBalls Syndra")
end

syndra_enabled = menu:add_checkbox("Enabled", syndra_category, 1)
syndra_combokey = menu:add_keybinder("Combo Mode Key", syndra_category, 32)
menu:add_label("BlueBalls Syndra", syndra_category)
menu:add_label("#StopTeasingMyBalls", syndra_category)

syndra_prediction = menu:add_subcategory("[Pred Selection]", syndra_category)
e_table = {}
e_table[1] = "Bruh Internal"
e_table[2] = "Ark Pred"
syndra_pred_useage = menu:add_combobox("[Pred Selection]", syndra_prediction, e_table, 1)

syndra_ark_pred = menu:add_subcategory("[Ark Pred Settings]", syndra_prediction)
syndra_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", syndra_ark_pred, 1, 99, 50)
syndra_w_hitchance = menu:add_slider("[W] Hit Chance [%]", syndra_ark_pred, 1, 99, 50)
syndra_e_hitchance = menu:add_slider("[E] Hit Chance [%]", syndra_ark_pred, 1, 99, 50)

syndra_ks_function = menu:add_subcategory("[Kill Steal]", syndra_category)
syndra_ks_q = menu:add_subcategory("[Q] Settings", syndra_ks_function, 1)
syndra_ks_use_q = menu:add_checkbox("Use [Q]", syndra_ks_q, 1)
syndra_ks_w = menu:add_subcategory("[W] Settings", syndra_ks_function, 1)
syndra_ks_use_w = menu:add_checkbox("Use [W]", syndra_ks_w, 1)
syndra_ks_r = menu:add_subcategory("[R] Smart Settings", syndra_ks_function)
syndra_ks_use_r = menu:add_checkbox("Use [R] With Overkill Check", syndra_ks_r, 1)
syndra_ks_r_blacklist = menu:add_subcategory("[R] Kill Steal Blacklist", syndra_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), syndra_ks_r_blacklist, 1)
    end
end

syndra_combo = menu:add_subcategory("[Combo]", syndra_category)
syndra_combo_q = menu:add_subcategory("[Q] Settings", syndra_combo)
syndra_combo_use_q = menu:add_checkbox("Use [Q]", syndra_combo_q, 1)
syndra_combo_w = menu:add_subcategory("[W] Settings", syndra_combo)
syndra_combo_use_w = menu:add_checkbox("Use [W]", syndra_combo_w, 1)
syndra_combo_e = menu:add_subcategory("[E] Settings", syndra_combo)
syndra_combo_use_e = menu:add_checkbox("Use [E]", syndra_combo_e, 1)

syndra_harass = menu:add_subcategory("[Harass]", syndra_category)
syndra_harass_q = menu:add_subcategory("[Q] Settings", syndra_harass)
syndra_harass_use_q = menu:add_checkbox("Use [Q]", syndra_harass_q, 1)
syndra_harass_w = menu:add_subcategory("[W] Settings", syndra_harass)
syndra_harass_use_w = menu:add_checkbox("Use [W]", syndra_harass_w, 1)
syndra_harass_e = menu:add_subcategory("[E] Settings", syndra_harass)
syndra_harass_use_e = menu:add_checkbox("Use [E]", syndra_harass_e, 1)
syndra_harass_use_auto_q = menu:add_toggle("Toggle Auto [Q] Harass", 1, syndra_harass, 88, true)
syndra_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", syndra_harass, 1, 100, 20)

syndra_laneclear = menu:add_subcategory("[Lane Clear]", syndra_category)
syndra_laneclear_use_q = menu:add_checkbox("Use [Q]", syndra_laneclear, 1)
syndra_laneclear_use_w = menu:add_checkbox("Use [W]", syndra_laneclear, 1)
syndra_laneclear_use_e = menu:add_checkbox("Use [E]", syndra_laneclear, 1)
syndra_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", syndra_laneclear, 1, 100, 20)

syndra_jungleclear = menu:add_subcategory("[Jungle Clear]", syndra_category)
syndra_jungleclear_use_q = menu:add_checkbox("Use [Q]", syndra_jungleclear, 1)
syndra_jungleclear_use_w = menu:add_checkbox("Use [W]", syndra_jungleclear, 1)
syndra_jungleclear_use_e = menu:add_checkbox("Use [E]", syndra_jungleclear, 1)
syndra_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", syndra_jungleclear, 1, 100, 20)

syndra_extra = menu:add_subcategory("[Automated] Features", syndra_category)
syndra_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", syndra_extra, 90)
syndra_combo_qe_set_key = menu:add_keybinder("Semi Manual [Stun] Key - [Q+E] To Cursor Position", syndra_extra, 65)
syndra_immobile_stun = menu:add_checkbox("Auto [Stun] Immobile Targets ", syndra_extra, 1)
syndra_extra_save = menu:add_subcategory("Smart [E] Save Me! Settings", syndra_extra)
syndra_extra_saveme = menu:add_checkbox("Use Smart [E] Save Me! Usage", syndra_extra_save, 1)
syndra_extra_saveme_myhp = menu:add_slider("[E] Save Me! When My HP < [%]", syndra_extra_save, 1, 100, 25)
syndra_extra_saveme_target = menu:add_slider("[E] Save Me! When Target > [%]", syndra_extra_save, 1, 100, 45)

syndra_extra_gap = menu:add_subcategory("[Stun] Anti Gap Closer", syndra_category)
syndra_extra_gapclose = menu:add_toggle("[Stun] Toggle Anti Gap Closer key", 1, syndra_extra_gap, 84, true)
syndra_extra_gapclose_blacklist = menu:add_subcategory("[Stun] Anti Gap Closer Champ Whitelist", syndra_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), syndra_extra_gapclose_blacklist, 1)
    end
end

syndra_extra_int = menu:add_subcategory("[Stun] Interrupt Channels", syndra_category, 1)
syndra_extra_interrupt = menu:add_checkbox("Use [Stun] Interrupt Major Channel Spells", syndra_extra_int, 1)
syndra_extra_interrupt_blacklist = menu:add_subcategory("[Stun] Interrupt Champ Whitelist", syndra_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), syndra_extra_interrupt_blacklist, 1)
    end
end

syndra_draw = menu:add_subcategory("[Drawing] Features", syndra_category)
syndra_draw_q = menu:add_checkbox("Draw [Q] Range", syndra_draw, 1)
syndra_draw_w = menu:add_checkbox("Draw [W] Range", syndra_draw, 1)
syndra_draw_r = menu:add_checkbox("Draw [R] Range", syndra_draw, 1)
syndra_draw_e = menu:add_checkbox("Draw [QE Stun] Max Range", syndra_draw, 1)
syndra_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Harass", syndra_draw, 1)
syndra_gap_draw = menu:add_checkbox("Draw Toggle Auto [Stun] Gap Closer", syndra_draw, 1)
syndra_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", syndra_draw, 1)
syndra_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", syndra_draw, 1)


-- Casting

local function CastQ(unit)

	if menu:get_value(syndra_pred_useage) == 0 then
		if not pred_output.can_cast then
			e_cast = nil
			qe_cast = nil
		end
		pred_output = pred:predict(Q.speed, Q.delay, E.range, Q.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
			e_cast = (client:get_tick_count() + 900)
			qe_cast = (client:get_tick_count() + 1)
			BlockW = true
			CastQE = true
		end
	end

	if menu:get_value(syndra_pred_useage) == 1 then
		local output = arkpred:get_aoe_prediction(Q_input, unit)
	  local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance < menu:get_value(syndra_q_hitchance) / 100 then
			e_cast = nil
			qe_cast = nil
		end

		if output.hit_chance >= menu:get_value(syndra_q_hitchance) / 100 and inv < 0.125 then
			local p = output.cast_pos
	    spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
			e_cast = (client:get_tick_count() + 900)
			qe_cast = (client:get_tick_count() + 1)
			BlockW = true
			CastQE = true
		end
	end
end

local function CastQMouse()
	qe_cast = nil
	spellbook:cast_spell(SLOT_Q, Q.delay, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
	qe_cast = (client:get_tick_count() + 1)
	CastQE = true
end

local function CastW(unit)
	if menu:get_value(syndra_pred_useage) == 0 then
		pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(syndra_pred_useage) == 1 then
		local output = arkpred:get_aoe_prediction(W_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		if output.hit_chance >= menu:get_value(syndra_w_hitchance) / 100 and inv < 0.125 then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_W, W.delay, p.x, p.y, p.z)
		end
	end
end

local function CastE(unit)

	if menu:get_value(syndra_pred_useage) == 0 then
		pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
		end
	end

	if menu:get_value(syndra_pred_useage) == 1 then
		local output = arkpred:get_prediction(E_input, unit)
		local inv = arkpred:get_invisible_duration(unit)
		local immobile = arkpred:get_immobile_duration(unit)
		if output.hit_chance >= menu:get_value(syndra_e_hitchance) / 100 and inv < 0.125 then
			local p = output.cast_pos
			spellbook:cast_spell(SLOT_E, E.delay, p.x, p.y, p.z)
		end
	end
end

local function CastEQuick(target)
	pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastEMouse()
	spellbook:cast_spell(SLOT_E, E.delay, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
end

local function CastR(unit)
	spellbook:cast_spell_targetted(SLOT_R, unit, R.delay)
end

-- Combo

local function Combo()

	if ml.Ready(SLOT_E) then
		target = selector:find_target(E.range, mode_health)
	end

	if not ml.Ready(SLOT_E) then
		target = selector:find_target(W.range, mode_health)
	end

	if menu:get_value(syndra_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= E.range and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
			if ml.IsValid(target) and IsKillable(target) then
				CastQ(target)
			end
		end
		if CastQE and qe_cast ~= nil and client:get_tick_count() > qe_cast then
			CastE(target)
		end
	end

	if menu:get_value(syndra_combo_use_q) == 1 and menu:get_value(syndra_combo_use_e) == 0 then
		if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(syndra_combo_use_q) == 1 and not CastQE then
	  if myHero:distance_to(target.origin) <= E.range and myHero:distance_to(target.origin) > Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(syndra_combo_use_q) == 1 and not CastQE then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	for _, ball in pairs(ballHolder) do
		if menu:get_value(syndra_combo_use_w) == 1 then
			if myHero:distance_to(ball.origin) <= W.range and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
		    if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
					origin = ball.origin
			    x, y, z = origin.x, origin.y, origin.z
			    spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
	    	end
			end
	  end

		minions = game.minions
		for i, minion in ipairs(minions) do
			if menu:get_value(syndra_combo_use_w) == 1 then
				if myHero:distance_to(ball.origin) > W.range and myHero:distance_to(minion.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				  if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
						origin = minion.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end
				end
		  end
		end

		jungle_minions = game.jungle_minions
		for i, jungle in ipairs(jungle_minions) do
			if menu:get_value(syndra_combo_use_w) == 1 and not EpicMonster(jungle) then
				if myHero:distance_to(ball.origin) > W.range and myHero:distance_to(jungle.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				  if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
						origin = jungle.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end
				end
		  end
		end

		if menu:get_value(syndra_combo_use_w) == 1 then
			if SyndraHasW() and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
			  if ml.Ready(SLOT_W) then
				  CastW(target)
				end
			end
	 	end
	end

	if menu:get_value(syndra_combo_use_e) == 1 and not CastQE then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
			if ml.Ready(SLOT_E) then
				local castposs = GetLineTargetCount_Combo(myHero.origin, target.origin, 0.25, 2500, 60)
	 			if castposs then
	 				eorigin = castposs.origin
	 				ex, ey, ez = eorigin.x, eorigin.y, eorigin.z
	 				spellbook:cast_spell(SLOT_E, E.delay, ex, ey, ez)
				end
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_harass_min_mana) / 100

	if ml.Ready(SLOT_E) then
		target = selector:find_target(E.range, mode_health)
	end

	if not ml.Ready(SLOT_E) then
		target = selector:find_target(W.range, mode_health)
	end

	if menu:get_value(syndra_harass_use_e) == 1 and GrabHarassMana then
		if myHero:distance_to(target.origin) <= E.range and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
			if ml.IsValid(target) and IsKillable(target) then
				CastQ(target)
			end
		end
		if CastQE and qe_cast ~= nil and client:get_tick_count() > qe_cast then
			CastE(target)
		end
	end

	if menu:get_value(syndra_harass_use_q) == 1 and not CastQE and GrabHarassMana then
	  if myHero:distance_to(target.origin) <= E.range and myHero:distance_to(target.origin) > Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(syndra_harass_use_q) == 1 and not CastQE and GrabHarassMana then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(syndra_harass_use_q) == 1 and menu:get_value(syndra_harass_use_e) == 0 and GrabHarassMana then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	for _, ball in pairs(ballHolder) do
		if menu:get_value(syndra_harass_use_w) == 1 and GrabHarassMana then
			if myHero:distance_to(ball.origin) <= W.range and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
		    if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
					origin = ball.origin
			    x, y, z = origin.x, origin.y, origin.z
			    spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
	    	end
			end
	  end

		minions = game.minions
		for i, minion in ipairs(minions) do
			if menu:get_value(syndra_harass_use_w) == 1 and GrabHarassMana then
				if myHero:distance_to(ball.origin) > W.range and myHero:distance_to(minion.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				  if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
						origin = minion.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end
				end
		  end
		end

		jungle_minions = game.jungle_minions
		for i, jungle in ipairs(jungle_minions) do
			if menu:get_value(syndra_harass_use_w) == 1 and not EpicMonster(jungle) and GrabHarassMana then
				if myHero:distance_to(ball.origin) > W.range and myHero:distance_to(jungle.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				  if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() and not BlockW then
						origin = jungle.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end
				end
		  end
		end

		if menu:get_value(syndra_harass_use_w) == 1 and GrabHarassMana then
			if SyndraHasW() and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
			  if ml.Ready(SLOT_W) then
				  CastW(target)
				end
			end
	 	end
	end

	if menu:get_value(syndra_harass_use_e) == 1 and not CastQE and GrabHarassMana then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) then
			if ml.Ready(SLOT_E) then
				local castposs = GetLineTargetCount_Combo(myHero.origin, target.origin, 0.25, 2500, 60)
	 			if castposs then
	 				eorigin = castposs.origin
	 				ex, ey, ez = eorigin.x, eorigin.y, eorigin.z
	 				spellbook:cast_spell(SLOT_E, E.delay, ex, ey, ez)
				end
			end
		end
	end
end

-- Auto Q Harass

local function AutoQHarass()

	target = selector:find_target(Q.range, mode_health)

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_harass_min_mana) / 100

	if menu:get_toggle_state(syndra_harass_use_auto_q) and menu:get_value(syndra_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= 780 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if ml.Ready(SLOT_Q) and GrabHarassMana and not IsUnderTurret(myHero) then
				pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
				if pred_output.can_cast then
					castPos = pred_output.cast_pos
					spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(syndra_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if ml.Ready(SLOT_Q) then
						pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, target, false, false)
						if pred_output.can_cast then
							castPos = pred_output.cast_pos
							spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
						end
					end
				end
			end
		end

		for _, ball in pairs(ballHolder) do
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(syndra_ks_use_w) == 1 then
					if GetWDmg(target) > target.health then
						if ml.Ready(SLOT_W) and not SyndraHasW() then
							CastW(ball)
						end
					end
				end
			end

			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= W.range and ml.IsValid(target) and IsKillable(target) then
				if menu:get_value(syndra_ks_use_w) == 1 then
					if GetWDmg(target) > target.health then
						if ml.Ready(SLOT_W) and SyndraHasW() then
							CastW(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(syndra_ks_use_r) == 1 then
				if myHero:distance_to(target.origin) <= R.range then
					if GetRDmg(target) > target.health then
						if not OverKillCheck(target) then
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

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(syndra_laneclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabLaneClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					local BestPos, MostHit = GetBestCircularFarmPos(target, Q.range, 50)
					if BestPos then
						spellbook:cast_spell(SLOT_Q, Q.delay, BestPos.x, BestPos.y, BestPos.z)
					end
				end
			end
		end

		if menu:get_value(syndra_laneclear_use_w) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if not SyndraHasW() then
					if GrabLaneClearMana and ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and TargetNearMouse then
						worigin = target.origin
						wx, wy, wz = worigin.x, worigin.y, worigin.z
						spellbook:cast_spell(SLOT_W, W.delay, wx, wy, wz)
					end
				end
			end
		end

		if menu:get_value(syndra_laneclear_use_w) == 1 then
			if SyndraHasW() and worigin then
				if GrabLaneClearMana and ml.Ready(SLOT_W) and TargetNearMouse then
					spellbook:cast_spell(SLOT_W, W.delay, wx, wy, wz)
				end
			end
		end

		if menu:get_value(syndra_laneclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabLaneClearMana and not ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) and TargetNearMouse then
					CastE(target)
				end
			end
		end
	end
end

-- Jungle Clear

	local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(syndra_jungleclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and ml.Ready(SLOT_Q) then
				local BestPos, MostHit = GetBestCircularJungPos(target, Q.range, 50)
				if BestPos then
					if GrabJungleClearMana and TargetNearMouse then
						spellbook:cast_spell(SLOT_Q, Q.delay, BestPos.x, BestPos.y, BestPos.z)
					end
				end
			end
		end

		if menu:get_value(syndra_jungleclear_use_w) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range then
				if not SyndraHasW() then
					if GrabJungleClearMana and ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and TargetNearMouse then
						worigin = target.origin
		        wx, wy, wz = worigin.x, worigin.y, worigin.z
		        spellbook:cast_spell(SLOT_W, W.delay, wx, wy, wz)
					end
				end
			end
		end

		if menu:get_value(syndra_jungleclear_use_w) == 1 then
			if SyndraHasW() and worigin then
				if GrabJungleClearMana and ml.Ready(SLOT_W) and TargetNearMouse then
				  spellbook:cast_spell(SLOT_W, W.delay, wx, wy, wz)
				end
			end
		end

		if menu:get_value(syndra_jungleclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabJungleClearMana and not ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) and TargetNearMouse then
					CastE(target)
				end
			end
		end
	end
end

local function AutoStunImmobileTarget()

	target = selector:find_target(E.range, mode_health)

	if StunManaCheck() then
	  if menu:get_value(syndra_immobile_stun) == 1 then
			if IsImmobileTarget(target) then
				if StunManaCheck() then
					if myHero:distance_to(target.origin) <= E.range and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
						if ml.IsValid(target) and IsKillable(target) then
							CastQ(target)
						end
					end
					if CastQE and qe_cast ~= nil and client:get_tick_count() > qe_cast then
						CastE(target)
					end
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

	target = selector:find_target(R.range, mode_health)

  if game:is_key_down(menu:get_value(syndra_combo_r_set_key)) then
    if myHero:distance_to(target.origin) < R.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

local function ManualQE()

	if StunManaCheck() then
	  if game:is_key_down(menu:get_value(syndra_combo_qe_set_key)) then
			if ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
				CastQMouse()
			end
			if CastQE and qe_cast ~= nil and client:get_tick_count() > qe_cast then
				CastEMouse()
			end
		end
	end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(syndra_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
				if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) < 500 and myHero:distance_to(obj.origin) < 500 and ml.Ready(SLOT_E) then
					CastE(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) and StunManaCheck() then
		if menu:get_value(syndra_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
		   	if myHero:distance_to(obj.origin) < 500 and ml.Ready(SLOT_E) then
					CastE(obj)
				end
			end
		end
	end
end

-- R Save me

local function ESaveMe()

  target = selector:find_target(Q.range, mode_distance)

	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(syndra_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(syndra_extra_saveme_target) / 100

	if menu:get_value(trist_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < 500 then
			if myHero:distance_to(target.origin) < target.attack_range then
				if target:is_facing(myHero) then
					if SaveMeHP and TargetHP then
						if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
							CastE(target)
						end
					end
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

	local medraw = game:world_to_screen(justme.x, justme.y, justme.z)
	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end


	if menu:get_value(syndra_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(syndra_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(syndra_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(syndra_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	if menu:get_value(syndra_auto_q_draw) == 1 then
		if menu:get_value(syndra_harass_use_q) == 1 then
			if menu:get_toggle_state(syndra_harass_use_auto_q) then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [Q] Harass Enabled")
			end
		end
	end

	if menu:get_toggle_state(syndra_extra_gapclose) then
		if menu:get_value(syndra_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 30, "Toggle Auto [Stun] Gap Closer Enabled")
		end
	end

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetWDmg(target) + GetRDmg(target)
		if ml.Ready(SLOT_R) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(syndra_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid and not InsecReady then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(syndra_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_active_spell(obj, active_spell)

	if Is_Me(obj) then
		if active_spell.spell_name == "SyndraE" then
		end
	end
end

--[[local timer, health = 0, 0

local function on_process_spell(unit, args)
    if unit ~= game.local_player or timer >
        args.cast_time - 1 then return end
    timer = args.cast_time
end]]

local function on_tick()

	--[[for _, unit in ipairs(game.players) do
		if unit.champ_name:find("Practice") then
			if unit.is_valid and unit.is_enemy and
				unit.is_alive and unit.is_visible and health ~=
				unit.health and game.game_time - timer < 1 then
				local delay = game.game_time - timer - 0.0167
				console:log(tostring(delay))
				health = unit.health
			end
		end
	end]]

	for index, ball in pairs(ballHolder) do
			if not ball.is_alive then
					table.remove(ballHolder, index)
			end
	end

	if game:is_key_down(menu:get_value(syndra_combokey)) and menu:get_value(syndra_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if not game:is_key_down(menu:get_value(syndra_combokey)) then
		AutoQHarass()
		AutoStunImmobileTarget()
	end

	if BlockW and e_cast ~= nil and client:get_tick_count() > e_cast then
		BlockW = false
	end


	if CastQE and not ml.Ready(SLOT_E) and qe_cast ~= nil and client:get_tick_count() > qe_cast then
		CastQE = false
		qe_cast = nil
	end


	if game:is_key_down(menu:get_value(syndra_combo_qe_set_key)) then
		ManualQE()
		orbwalker:move_to()
	end

	ManualR()
	AutoKill()

end

--client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_active_spell", on_active_spell)
