if game.local_player.champ_name ~= "Syndra" then
	return
end

--[[do
    local function AutoUpdate()
		local Version = 1
		local file_name = "BlueBallsSyndra.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BlueBallsSyndra.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/BlueBallsSyndra.lua.version.txt")
        console:log("OhAysyndrasa.lua Vers: "..Version)
		console:log("OhAysyndrasa.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".......................................................")
						console:log(".......................................................")
            console:log("...Shaun's & Bens Sexy Syndra v1 Successfully Loaded...")
						console:log(".......................................................")
						console:log(".......................................................")
        else
			http:download_file(url, file_name)
			      console:log("Sexy Syndra Update available.....")
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

local Q = { range = 800, delay = .25, width = 180, speed = math.huge }
local QE = { range = 1200, delay = .25, width = 60, speed = math.huge }
local W = { range = 925, delay = .25, width = 225, speed = math.huge }
local R = { range = 675 delay = .25, width = 0, speed = math.huge }

spellE = {
    range1 = 700,
    range2 = 800,
    angle1 = 40,
    angle2 = 60
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

-- Ben's Syndra Shite

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
            if pointSegment and isOnSegment and (vec3m.GetDistanceSqr(ball, pointSegment) <= width * width) then
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
        if target.object_id ~= 0 and vec3m.IsValid(target) and target.is_enemy and GetDistanceSqr(local_player, target) < Range then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (vec3m.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
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

local function AutoECastPos(balls, champs)
    local main_table = {}
    local set = {}
    for index, ball in pairs(balls) do
        set.ball = champs[index]
        local inner_max = {}
        local inner_min = {}
        local center_ball = ball
        level = spellbook:get_spell_slot(SLOT_E).level
        if level == 5 then
            ERange = 60
        else
            ERange = 40
        end
        local delta_x = ball.origin.x - local_player.origin.x
        local delta_z = ball.origin.z - local_player.origin.z
        local angle = vec3m.R2D(math.atan2(delta_z, delta_x)) + 180
        local max_angle = AngleNorm(angle + ERange)
        local min_angle = AngleNorm(angle - ERange)
        for _, ball2 in pairs(balls) do
            if ball2 ~= center_ball then
                local delta_x = ball2.origin.x - local_player.origin.x
                local delta_z = ball2.origin.z - local_player.origin.z
                local angle2 = vec3m.R2D(math.atan2(delta_z, delta_x)) + 180
                if angle + ERange > 360 then
                    if angle2 < (ERange - (360 - angle)) then
                        table.insert(inner_min, ball2)
                    end
                else
                    if angle2 > min_angle and angle2 < angle then
                        table.insert(inner_min, ball2)
                    end
                end
                if angle - ERange < 0 then
                    if angle2 > (360 - (ERange - angle)) then
                        table.insert(inner_max, ball2)
                    end
                else
                    if angle2 < max_angle and angle2 > angle then
                        table.insert(inner_max, ball2)
                    end
                end
            end
        end
        table.insert(inner_max, center_ball)
        table.insert(inner_min, center_ball)
        table.insert(main_table, inner_max)
        table.insert(main_table, inner_min)
    end
    local size = 0
    local max_balls = {}
    for _, balls in pairs(main_table) do
        if #balls > size then
            size = #balls
        end
    end
    for index, balls in pairs(main_table) do
        if #balls == size then
            table.insert(max_balls, balls)
        end
    end
    local final_average_dist = 9999
    local final_ball_pairs = {}
    if #max_balls[1] > 1 then
        for _, ball_pairs in pairs(max_balls) do
            local champ_dist_avg = 0
            for _, ball in pairs(ball_pairs) do
                champ = set.ball
                champ_distance = local_player:distance_to(champ.origin)
                champ_dist_avg = champ_dist_avg + champ_distance
            end
            champ_dist_avg = (champ_dist_avg / #ball_pairs)
            if champ_dist_avg < final_average_dist then
                final_average_dist = champ_dist_avg
                final_ball_pairs = ball_pairs
            end
        end
    end
    return final_ball_pairs
end

-- No lib Functions Start

function IsKillable(unit)
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

function EasyDistCompare(p1, p2)
  p2x, p2y, p2z = p2.x, p2.y, p2.z
  p1x, p1y, p1z = p1.x, p1.y, p1.z
  local dx = p1x - p2x
  local dz = (p1z or p1y) - (p2z or p2y)
  return math.sqrt(dx*dx + dz*dz)
end

function GetMinionCount(range, unit)
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

function MinionsAround(pos, range)
    local Count = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

function GetBestCircularFarmPos(unit, range, radius)
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

function Ballcount()
    local count = 0
    for _, in pairs(ballHolder) do
        count = count + 1
    end
    return count
end

function SyndraHasW()
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
	return (RDmg + (R2Dmg*(3 + BallCount())))
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	syndra_category = menu:add_category_sprite("BlueBall Syndra", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/BS.png", "Shaun's Sexy Common//Logo.png")
	syndra_category = menu:add_category("BlueBalls Syndra")
end

syndra_enabled = menu:add_checkbox("Enabled", syndra_category, 1)
syndra_combokey = menu:add_keybinder("Combo Mode Key", syndra_category, 32)
menu:add_label("BS Presents: BlueBalls Syndra", syndra_category)
menu:add_label("#StopTeasingMe", syndra_category)

syndra_ks_function = menu:add_subcategory("Kill Steal", syndra_category)
syndra_ks_q = menu:add_subcategory("[Q] Settings", syndra_ks_function, 1)
syndra_ks_use_q = menu:add_checkbox("Use [Q]", syndra_ks_q, 1)
syndra_ks_w = menu:add_subcategory("[W] Settings", syndra_ks_function, 1)
syndra_ks_use_w = menu:add_checkbox("Use [W]", syndra_ks_w, 1)
syndra_ks_e = menu:add_subcategory("[QE] Settings", syndra_ks_function, 1)
syndra_ks_use_e = menu:add_checkbox("Use Stun [QE]", syndra_ks_e, 1)
syndra_ks_r = menu:add_subcategory("[R] Settings", syndra_ks_function)
syndra_ks_use_r = menu:add_checkbox("Use [R]", syndra_ks_r, 1)
syndra_ks_r_blacklist = menu:add_subcategory("[R] Kill Steal Blacklist", syndra_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), syndra_ks_r_blacklist, 1)
    end
end

syndra_combo = menu:add_subcategory("Combo", syndra_category)
syndra_combo_q = menu:add_subcategory("[Q] Settings", syndra_combo)
syndra_combo_use_q = menu:add_checkbox("Use [Q]", syndra_combo_q, 1)
syndra_combo_w = menu:add_subcategory("[W] Settings", syndra_combo)
syndra_combo_use_w = menu:add_checkbox("Use [W]", syndra_combo_w, 1)
syndra_combo_e = menu:add_subcategory("[E] Settings", syndra_combo)
syndra_combo_use_e = menu:add_checkbox("Use [E]", syndra_combo_e, 1)
syndra_combo_r = menu:add_subcategory("[R] Smart Settings", syndra_combo)
syndra_combo_use_r = menu:add_checkbox("Use Smart [R]", syndra_combo_r, 1)
syndra_combo_r_blacklist = menu:add_subcategory("[R] Combo Blacklist", syndra_combo_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Combo On: "..tostring(t.champ_name), syndra_combo_r_blacklist, 1)
    end
end

syndra_harass = menu:add_subcategory("Harass", syndra_category)
syndra_harass_q = menu:add_subcategory("[Q] Settings", syndra_harass)
syndra_harass_use_q = menu:add_checkbox("Use [Q]", syndra_harass_q, 1)
syndra_harass_use_auto_q = menu:add_toggle("Toggle Auto [Q] Harass", 1, syndra_harass_q, 88, true)
syndra_harass_w = menu:add_subcategory("[W] Settings", syndra_harass)
syndra_harass_use_w = menu:add_checkbox("Use [W]", syndra_harass_w, 1)
syndra_harass_e = menu:add_subcategory("[E] Settings", syndra_harass)
syndra_harass_use_e = menu:add_checkbox("Use [E]", syndra_harass_e, 1)
syndra_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", syndra_harass, 1, 100, 20)

syndra_extra = menu:add_subcategory("Sexy Automated Features", syndra_category)
syndra_extra_r = menu:add_subcategory("[R] Settings", syndra_extra)
syndra_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", syndra_extra_r, 90)
syndra_extra_qe = menu:add_subcategory("[QE] Settings", syndra_extra)
syndra_combo_qe_set_key = menu:add_keybinder("Semi Manual [Stun] Key - Closest To Mouse Position", syndra_extra_qe, 65)
syndra_auto_e_gap = menu:add_checkbox("Auto [Stun] - Gap Closing Targets", syndra_extra_qe, 1)
syndra_auto_e_interrupt = menu:add_checkbox("Auto [Stun] - Interrupt Major Channel Spells", syndra_extra_qe, 1)
syndra_auto_w = menu:add_checkbox("Auto [Stun] - Immobilised Targets", syndra_extra_qe, 1)
Syndra_autoe_hits = menu:add_slider("Minimum Targets To Auto [Stun]", syndra_extra_qe, 1, 5, 3)

syndra_laneclear = menu:add_subcategory("Lane Clear", syndra_category)
syndra_laneclear_use_q = menu:add_checkbox("Use [Q]", syndra_laneclear, 1)
syndra_laneclear_use_w = menu:add_checkbox("Use [W]", syndra_laneclear, 1)
syndra_laneclear_use_e = menu:add_checkbox("Use [E]", syndra_laneclear, 1)
syndra_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", syndra_laneclear, 1, 100, 20)
syndra_laneclear_q_min = menu:add_slider("Number Of Minions To Use [Q]", syndra_laneclear, 1, 10, 3)
syndra_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", syndra_laneclear, 1, 10, 3)

syndra_jungleclear = menu:add_subcategory("Jungle Clear", syndra_category)
syndra_jungleclear_use_q = menu:add_checkbox("Use [Q]", syndra_jungleclear, 1)
syndra_jungleclear_use_w = menu:add_checkbox("Use [W]", syndra_jungleclear, 1)
syndra_jungleclear_use_e = menu:add_checkbox("Use [E]", syndra_jungleclear, 1)
syndra_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", syndra_jungleclear, 1, 100, 20)

syndra_draw = menu:add_subcategory("The Drawing Features", syndra_category)
syndra_draw_q = menu:add_checkbox("Draw [Q] Range", syndra_draw, 1)
syndra_draw_w = menu:add_checkbox("Draw [W] Range", syndra_draw, 1)
syndra_draw_r = menu:add_checkbox("Draw [R] Range", syndra_draw, 1)
syndra_draw_qe = menu:add_checkbox("Draw [QE] Max Range", syndra_draw, 1)
syndra_auto_q_draw = menu:add_checkbox("Draw Toggle Auto [Q] Harass", syndra_draw, 1)
syndra_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", syndra_draw, 1)
syndra_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", syndra_draw, 1, "Health Bar Damage Is Computed From R > Q > W")


-- Casting

local function CastQ()
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW(unit)
	pred_output = pred:predict(W.speed, W.delay, W.range, W.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_W, W.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastE()
	pred_output = pred:predict(E.speed, E.delay, E.range, E.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_E, E.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastQE()
	pred_output = pred:predict(QE.speed, QE.delay, QE.range, QE.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_QE, QE.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastR(unit)
	spellbook:cast_spell_targetted(SLOT_R, unit, R.delay)
end

-- Combo

local function Combo()

	target = selector:find_target(QE.range, mode_health)

	function Combo()
	  target = selector:find_target(1500, mode_health)

	  if ml.Ready(SLOT_Q) then
	    if myHero:distance_to(target.origin) <= 1150 then
	      CastQ(target)
	    end
	  end

	  for _, ball in pairs(ballHolder) do
	    if myHero:distance_to(ball.origin) < 950 then
	      if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() then
	        origin = ball.origin
	        x, y, z = origin.x, origin.y, origin.z
	        spellbook:cast_spell(SLOT_W, 0.25, x, y, z)
	      end
	    end
	  end

	  if ml.Ready(SLOT_W) and SyndraHasW() then
	    origin = target.origin
	    x, y, z = origin.x, origin.y, origin.z
	    spellbook:cast_spell(SLOT_W, 0.25, x, y, z)
	  end

	  if not ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    origin = target.origin
	    x, y, z = origin.x, origin.y, origin.z
	    spellbook:cast_spell(SLOT_E, 0.25, x, y, z)
	  end
	end


	if menu:get_value(syndra_combo_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ()
			end
		end
	end

	if menu:get_value(syndra_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= W.range then
	     	if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end

	if menu:get_value(syndra_combo_use_e) == 1 then
		if myHero:distance_to(target.origin) <= QE.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and Ready(SLOT_E) then
				CastQ()
				CastE()
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(QE.range, mode_health)
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_harass_min_mana) / 100


	if menu:get_value(syndra_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) then
				CastQ()
			end
		end
	end

	if menu:get_value(syndra_harass_use_w) == 1 then
		if myHero:distance_to(target.origin) IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= W.range then
	     	if Ready(SLOT_W) then
					CastW(target)
				end
			end
		end
	end

	if menu:get_value(syndra_harass_use_e) == 1 then
		if myHero:distance_to(target.origin) <= QE.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and Ready(SLOT_E) then
				CastQ()
				CastE()
			end
		end
	end
end

-- Auto Q Harass

local function AutoQHarass()

	target = selector:find_target(Q.range, mode_health)

	if menu:get_toggle_state(syndra_harass_use_auto_q) and menu:get_value(syndra_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if Ready(SLOT_Q) and not IsUnderTurret(myHero) then
				CastQ(target)
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(GetEnemyHeroes()) do

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and IsValid(target) and IsKillable(target) then
			if menu:get_value(syndra_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= menu:get_value(syndra_ks_w_range) and IsValid(target) and IsKillable(target) then
			if menu:get_value(syndra_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if Ready(SLOT_W) then
						CastW(target)
					end
				end
			end
		end

		local QWDmg = GetQDmg(target) + GetWDmg(target)

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= rRange[spellbook:get_spell_slot(SLOT_R).level] and IsValid(target) and IsKillable(target) then
			if menu:get_value(syndra_ks_use_r) == 1 then
				if myHero:distance_to(target.origin) > Q.range then
					if not IsUnderTurret(target) and HasPassiveBuff(target) then
        		if QWDmg > target.health and GetEnemyCountCicular(1500, target.origin) <= 2 then
				  		if menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
								if Ready(SLOT_R) and spellbook:get_spell_slot(SLOT_Q).can_cast then
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

		if menu:get_value(syndra_laneclear_use_q) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GetMinionCount(Q.range, myHero) >= menu:get_value(syndra_laneclear_q_min) then
					if GrabLaneClearMana and Ready(SLOT_Q) then
						CastQ()
					end
				end
			end
		end

		if menu:get_value(syndra_laneclear_use_e) == 1 then
			if IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < AA.range then
				if GetMinionCount(AA.range, myHero) >= menu:get_value(syndra_laneclear_e_min) then
					if GrabLaneClearMana and Ready(SLOT_E) then
            CastE()
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local Q = { range = 800, delay = .1, width = 180, speed = math.huge }
	local function CastQ(unit)
		pred_output = pred:predict(Q.speed, Q.delay, 1150, Q.width, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_Q, 0.1, castPos.x, castPos.y, castPos.z)
		end
	end

	local function JungleClear()

		minions = game.jungle_minions
		for i, target in ipairs(minions) do
	  	if myHero:distance_to(target.origin) <= 800 and ml.Ready(SLOT_Q) then
	      CastQ(target)
	    end

	    if myHero:distance_to(target.origin) < 950 then
	      if ml.Ready(SLOT_W) and not ml.Ready(SLOT_Q) and not SyndraHasW() then
	        worigin = target.origin
	        wx, wy, wz = worigin.x, worigin.y, worigin.z
	        spellbook:cast_spell(SLOT_W, 0.25, wx, wy, wz)
	      end
	    end

	    if ml.Ready(SLOT_W) and SyndraHasW() then
	      --origin = target.origin
	      --x, y, z = origin.x, origin.y, origin.z
	      spellbook:cast_spell(SLOT_W, 0.25, wx, wy, wz)
	    end
	  end
	end

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(syndra_jungleclear_min_mana) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do

		if target.object_id ~= 0 and menu:get_value(syndra_jungleclear_use_q) == 1 and myHero:distance_to(target.origin) < Q.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_Q) then
					CastQ()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(syndra_jungleclear_use_e) == 1 and myHero:distance_to(target.origin) < AA.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_E) then
          CastE()
				end
			end
		end

		if target.object_id ~= 0 and menu:get_value(syndra_jungleclear_use_w) == 1 and myHero:distance_to(target.origin) < W.range then
			if IsValid(target) then
				if GrabJungleClearMana and Ready(SLOT_W) then
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

-- Auto W

local function ManualR()
  target = selector:find_target(R.range, mode_health)

  if game:is_key_down(menu:get_value(syndra_combo_r_set_key)) then
    if myHero:distance_to(target.origin) < R.range then
			if IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end
end

-- Auto E

function AutoE()
    cast_pos_table = {}
    ball_table = {}
    champ_table = {}
    hit_req = menu:get_value(Syndra_autoe_hits)
    ball_hit_count = 0
    players = game.players
    for _, target in ipairs(players) do
        if target:distance_to(local_player.origin) < 1100 then
            cast_pos, ball_count = GetLineTargetCount_pos(local_player.origin, target.origin, 0.25, 2500, 100 / 2)
            if ball_count > 0 then
                table.insert(cast_pos_table, cast_pos.origin)
                table.insert(ball_table, cast_pos)
                table.insert(champ_table, target)
                ball_hit_count = ball_hit_count + 1
            end
        end
    end
    if ball_hit_count >= hit_req then
        ball_list = AutoECastPos(ball_table, champ_table)
        if next(ball_list) ~= nil then
            x_table = {}
            z_table = {}
            for _, pos in ipairs(ball_list) do
                table.insert(x_table, pos.origin.x)
                table.insert(z_table, pos.origin.z)
            end
            x = 0
            count_x = 0
            for i, value in ipairs(x_table) do
                x = x + value
                count_x = count_x + 1
            end
            x_avg = (tonumber(x) / count_x)
            z = 0
            count_z = 0
            for i, value in ipairs(z_table) do
                z = z + value
                count_z = count_z + 1
            end
            z_avg = (tonumber(z) / count_z)
            new_cast_pos = vec3.new(x_avg, 0, z_avg)
            renderer:draw_circle(new_cast_pos.x, new_cast_pos.y, new_cast_pos.z, 50, 0, 255, 0, 255)
            if vec3m.Ready(SLOT_E) then
                spellbook:cast_spell(SLOT_E, 0.25, new_cast_pos.x, new_cast_pos.y, new_cast_pos.z)
            end
        end
    end
end

-- Gap Close

local function on_gap_close(obj, data)

	if menu:get_value(syndra_auto_e_gap) == 1 then
    if IsValid(obj) then
      if myHero:distance_to(obj.origin) < myHero.attack_range and Ready(SLOT_E) then
        CastE()
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
	end

	if menu:get_value(syndra_draw_q) == 1 then
		if Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

  if menu:get_value(syndra_draw_w) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(syndra_draw_qe) == 1 then
		if Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, QE.range, 255, 0, 255, 255)
		end
	end

	if menu:get_value(syndra_draw_r) == 1 then
		if Ready(SLOT_R) then
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

	for i, target in ipairs(GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target)
		if Ready(SLOT_R) then
			if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1000 then
				if menu:get_value(syndra_draw_kill) == 1 then
					if fulldmg > target.health and IsValid(target) then
						renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 20 + 50, "Can Kill Target")
					end
				end
			end
		end
		if menu:get_value(syndra_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if spellbook:get_spell_slot(SLOT_E).level == 5 then
			ERange = spellE.range2
	else
			ERange = spellE.range1
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

	ManualR()
  ManualQE()
	AutoKill()
	AutoQHarass()
	AutoE()

	for index, ball in pairs(ballHolder) do
			if not ball.is_alive then
					table.remove(ballHolder, index)
					table.remove(ballTimer, index)
			end
	end


end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_gap_close", on_gap_close)
