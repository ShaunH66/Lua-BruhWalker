if game.local_player.champ_name ~= "Lissandra" then
	return
end

do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "IceyBabyLissandra.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/IceyBabyLissandra.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/IceyBabyLissandra.lua.version.txt")
        console:log("IceyBabyLissandra.lua Vers: "..Version)
		console:log("IceyBabyLissandra.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("....................................................................................")
            console:log("............Shaun's IceyBaby Lissandra Successfully Loaded............")
						console:log("....................................................................................")
        else
			http:download_file(url, file_name)
			      console:log("IceyBaby Lissandra Update available.....")
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


-- Ranges

local Q = { range = 760, delay = .25, width = 150, speed = 2200 }
local W = { range = 450, delay = .25 }
local E = { range = 1025, delay = .25 }
local R = { range = 550, delay = .375 }

local Q_input = {
    source = myHero,
    speed = Q.speed, range = Q.range,
    delay = Q.delay, radius = (Q.width / 2),
		collision = {"wind_wall"},
    type = "linear", hitbox = true
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
  if unit:has_buff("lissWDebuff") then
    buff = unit:get_buff("lissWDebuff")
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
	liss_category = menu:add_category_sprite("IceyBaby Lissandra", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	liss_category = menu:add_category("Shaun's IceyBaby Lissandra")
end

liss_enabled = menu:add_checkbox("Enabled", liss_category, 1)
liss_combokey = menu:add_keybinder("Combo Mode Key", liss_category, 32)
menu:add_label("Shaun's IceyBaby Lissandra", liss_category)
menu:add_label("#Cold & Sexy", liss_category)

liss_ark_pred = menu:add_subcategory("[Pred Settings]", liss_category)
liss_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", liss_ark_pred, 1, 99, 50)

liss_ks_function = menu:add_subcategory("[Kill Steal]", liss_category)
liss_ks_q = menu:add_subcategory("[Q] Settings", liss_ks_function, 1)
liss_ks_use_q = menu:add_checkbox("Use [Q]", liss_ks_q, 1)
liss_ks_w = menu:add_subcategory("[W] Settings", liss_ks_function, 1)
liss_ks_use_w = menu:add_checkbox("Use [W]", liss_ks_w, 1)
liss_ks_r = menu:add_subcategory("[R] Settings", liss_ks_function, 1)
liss_ks_use_r = menu:add_checkbox("Use [R]", liss_ks_r, 1)
liss_ks_use_combo_r = menu:add_checkbox("Use Smart Combo [R]", liss_ks_r, 1)
liss_ks_r_blacklist = menu:add_subcategory("[R] Kill Steal Whitelist", liss_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), liss_ks_r_blacklist, 1)
    end
end

liss_combo = menu:add_subcategory("[Combo]", liss_category)
liss_combo_q = menu:add_subcategory("[Q] Settings", liss_combo)
liss_combo_use_q = menu:add_checkbox("Use [Q]", liss_combo_q, 1)
liss_combo_w = menu:add_subcategory("[W] Settings", liss_combo)
liss_combo_use_w = menu:add_checkbox("Use [W]", liss_combo_w, 1)

liss_harass = menu:add_subcategory("[Harass]", liss_category)
liss_harass_q = menu:add_subcategory("[Q] Settings", liss_harass)
liss_harass_use_q = menu:add_checkbox("Use [Q]", liss_harass_q, 1)
liss_harass_w = menu:add_subcategory("[W] Settings", liss_harass)
liss_harass_use_w = menu:add_checkbox("Use [W]", liss_harass_w, 1)
liss_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", liss_harass, 1, 100, 20)

liss_laneclear = menu:add_subcategory("[Lane Clear]", liss_category)
liss_laneclear_use_q = menu:add_checkbox("Use [Q]", liss_laneclear, 1)
liss_laneclear_use_w = menu:add_checkbox("Use [W]", liss_laneclear, 1)
liss_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", liss_laneclear, 1, 100, 20)
liss_laneclear_min_q = menu:add_slider("Minimum Minions To Use [Q]", liss_laneclear, 1, 10, 3)
liss_laneclear_min_w = menu:add_slider("Minimum Minions To Use [W]", liss_laneclear, 1, 10, 3)

liss_jungleclear = menu:add_subcategory("[Jungle Clear]", liss_category)
liss_jungleclear_use_q = menu:add_checkbox("Use [Q]", liss_jungleclear, 1)
liss_jungleclear_use_w = menu:add_checkbox("Use [W]", liss_jungleclear, 1)
liss_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", liss_jungleclear, 1, 100, 20)

liss_extra = menu:add_subcategory("[R] Features", liss_category)
liss_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", liss_extra, 90)
liss_extra_save = menu:add_subcategory("[R] Save Me! Settings", liss_extra)
liss_extra_saveme = menu:add_checkbox("[R] Save Me! Usage", liss_extra_save, 1)
liss_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", liss_extra_save, 1, 100, 25)
liss_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", liss_extra_save, 1, 100, 45)

liss_extra_gap = menu:add_subcategory("[R] Anti Gap Closer", liss_category)
liss_extra_gapclose = menu:add_toggle("[R] Toggle Anti Gap Closer key", 1, liss_extra_gap, 84, true)
liss_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", liss_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), liss_extra_gapclose_blacklist, 1)
    end
end

liss_extra_int = menu:add_subcategory("[R] Interrupt Channels", liss_category, 1)
liss_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", liss_extra_int, 1)
liss_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", liss_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), liss_extra_interrupt_blacklist, 1)
    end
end

liss_draw = menu:add_subcategory("[Drawing] Features", liss_category)
liss_draw_q = menu:add_checkbox("Draw [Q] Range", liss_draw, 1)
liss_draw_e = menu:add_checkbox("Draw [E] Range", liss_draw, 1)
liss_draw_w = menu:add_checkbox("Draw [W] Range", liss_draw, 1)
liss_draw_r = menu:add_checkbox("Draw [R] Range", liss_draw, 1)
liss_gap_draw = menu:add_checkbox("Draw Toggle Auto [R] Gap Closer", liss_draw, 1)
liss_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", liss_draw, 1)
liss_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", liss_draw, 1)

-- Casting

local function CastQ(unit)
	local output = arkpred:get_prediction(Q_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(liss_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
	end
end

local function CastW()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastR(unit)
	spellbook:cast_spell_targetted(SLOT_R, unit, R.delay)
end


-- Combo

local function Combo()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	wtarget = selector:find_target(W.range, mode_health)

	if menu:get_value(liss_combo_use_q) == 1 then
		if ml.IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(qtarget.origin) <= Q.range then
				if ml.Ready(SLOT_Q) then
					CastQ(qtarget)
				end
			end
		end
	end

	if menu:get_value(liss_combo_use_w) == 1 then
		if ml.IsValid(wtarget) and IsKillable(wtarget) then
			if myHero:distance_to(wtarget.origin) <= W.range then
				if ml.Ready(SLOT_W) then
					CastW()
				end
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(liss_harass_min_mana) / 100

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	wtarget = selector:find_target(W.range, mode_health)

	if menu:get_value(liss_harass_use_q) == 1 and GrabHarassMana then
		if ml.IsValid(qtarget) and IsKillable(qtarget) then
			if myHero:distance_to(qtarget.origin) <= Q.range then
				if ml.Ready(SLOT_Q) then
					CastQ(qtarget)
				end
			end
		end
	end

	if menu:get_value(liss_harass_use_w) == 1 and GrabHarassMana then
		if ml.IsValid(wtarget) and IsKillable(wtarget) then
			if myHero:distance_to(wtarget.origin) <= W.range then
				if ml.Ready(SLOT_W) then
					CastW()
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local TotalQDmg = GetQDmg(target) + GetWDmg(target)
		local TotalComboDmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target)

		if menu:get_value(liss_ks_use_q) == 1 then
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

		if menu:get_value(liss_ks_use_w) == 1 then
			if GetWDmg(target) > target.health then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= W.range then
						if ml.Ready(SLOT_W) then
							CastW()
						end
					end
				end
			end
		end

		if menu:get_value(liss_ks_use_combo_r) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= R.range then
					if TotalComboDmg > target.health then
					 	if menu:get_value_string("Use [R] Kill Steal On: "..tostring(target.champ_name)) == 1 then
							if ml.Ready(SLOT_R) and ml.Ready(SLOT_W) then
						  	CastR(target)
							end
						end
          end
			  end
		  end
    end

		if menu:get_value(liss_ks_use_r) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= R.range then
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

-- Lane Clear

local function Clear()

	minions = game.minions
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(liss_laneclear_min_mana) / 100

	for i, target in ipairs(minions) do

		if menu:get_value(liss_laneclear_use_q) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and ml.IsValid(target) then
				if GetMinionCount(350, target) >= menu:get_value(liss_laneclear_min_q) then
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

		if menu:get_value(liss_laneclear_use_w) == 1 and GrabLaneClearMana then
			if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < W.range and ml.IsValid(target) then
				if GetMinionCount(400, myHero) >= menu:get_value(liss_laneclear_min_w) then
					if ml.Ready(SLOT_W) then
						CastW()
					end
				end
			end
		end
	end
end

-- Jungle Clear

	local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(liss_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650

		if menu:get_value(liss_jungleclear_use_q) == 1 then
			if ml.IsValid(target) then
				if GrabJungleClearMana and TargetNearMouse then
					if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range and ml.IsValid(target) then
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
		end

		if menu:get_value(liss_jungleclear_use_w) == 1 then
			if ml.IsValid(target) then
				if GrabJungleClearMana and TargetNearMouse then
					if target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 350 and ml.IsValid(target) then
						if ml.Ready(SLOT_W) then
							CastW()
						end
					end
				end
			end
		end
	end
end

-- Manual R

local function ManualR()

	target = selector:find_target(R.range, mode_health)

  if game:is_key_down(menu:get_value(liss_combo_r_set_key)) and ml.Ready(SLOT_R) then
    if myHero:distance_to(target.origin) <= R.range then
			if ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
    end
  end
end

local function RSaveMe()

  target = selector:find_target(R.range, mode_distance)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius
	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(liss_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(liss_extra_saveme_target) / 100

	if menu:get_value(liss_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) <= R.range then
			if target:is_facing(myHero) then
				if SaveMeHP and TargetHP then
					if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
						CastR(myHero)
					end
				end
			end
    end
  end
end


-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(liss_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
				if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) <= R.range and ml.Ready(SLOT_R) then
					CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if ml.IsValid(obj) then
    if menu:get_value(liss_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) <= R.range and ml.Ready(SLOT_R) then
        	CastR(obj)
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


	if menu:get_value(liss_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(liss_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(liss_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 255, 0, 255)
		end
	end


	if menu:get_value(liss_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	if menu:get_toggle_state(liss_extra_gapclose) then
		if menu:get_value(liss_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [R] Gap Closer Enabled")
		end
	end

	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetWDmg(target) + GetRDmg(target)
		if ml.Ready(SLOT_R) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(liss_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(liss_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

end

local function on_tick()

	if game:is_key_down(menu:get_value(liss_combokey)) and menu:get_value(liss_enabled) == 1 and not KSQ then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(liss_combo_r_set_key)) then
		ManualR()
		orbwalker:move_to()
	end

	AutoKill()
	RSaveMe()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
