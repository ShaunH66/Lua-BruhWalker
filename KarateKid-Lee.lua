if game.local_player.champ_name ~= "LeeSin" then
	return
end

do
    local function AutoUpdate()
		local Version = 0.5
		local file_name = "KarateKid-Lee.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/KarateKid-Lee.lua"
    local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/KarateKid-Lee.lua.version.txt")
    console:log("KarateKid-Lee..lua Vers: "..Version)
		console:log("KarateKid-Lee..Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log(".................Shaun's Sexy LeeSin Successfully Loaded........................")
    else
						http:download_file(url, file_name)
			      console:log("Sexy LeeSin Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
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

local InsecReady = false
local WardCasted = false
local UseControlWard = false
local	UseFlash = false
local TrinketWard = false

local FleeReady = false
local Wfire = false

-- Ranges
local Q = { range = 1200, delay = .25, width = 120, speed = 1800 }
local W = { range = 700, delay = .1, width = 0, speed = 0 }
local E1 = { range = 350, delay = .25, width = 0, speed = 0 }
local E2 = { range = 500, delay = .25, width = 0, speed = 0 }
local R = { range = 375, delay = .25, width = 0, speed = 0 }
local Ward = { range = 625 }

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

function GetDistanceSqr(unit, p2)
	p2 = p2.origin or myHero.origin
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.origin
	p1x, p1y, p1z = p1.x, p1.y, p1.z
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
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

local function TargetHasQ1Buff(unit)
	if unit:has_buff("BlindMonkQOne") then
		return true
	end
	return false
end

local function AllyHasW1(unit)
	if unit:has_buff("blindmonkwoneshield") then
		return true
	end
	return false
end

local function LeeHasW1(unit)
	local spell_slot = spellbook:get_spell_slot(SLOT_W)
	if spell_slot.spell_data.name == "BlindMonkWOne" then
		return true
	end
	return false
end

local function LeeHasW2(unit)
	local spell_slot = spellbook:get_spell_slot(SLOT_W)
	if spell_slot.spell_data.name == "BlindMonkWTwo" then
		return true
	end
	return false
end

local function LeeHasE1(unit)
	local spell_slot = spellbook:get_spell_slot(SLOT_E)
	if spell_slot.spell_data.name == "BlindMonkEOne" then
		return true
	end
	return false
end

local function LeeHasE2(unit)
	local spell_slot = spellbook:get_spell_slot(SLOT_E)
	if spell_slot.spell_data.name == "BlindMonkETwo" then
		return true
	end
	return false
end

local function ControlWardCheck()
  local control_ward = false
  local control_ward_slot = nil
  local inventory = ml.GetItems()
  for _, v in ipairs(inventory) do
    if tonumber(v) == 2055 then
    	local item = local_player:get_item(tonumber(v))
    	if item ~= 0 then
		    control_ward_slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
				if ml.Ready(control_ward_slot) then
					control_ward = true
				end
			end
  	end
  end
  return control_ward, control_ward_slot
end

local function FullComboManReady()
	local spell_slot_q = spellbook:get_spell_slot(SLOT_Q)
	local spell_slot_w = spellbook:get_spell_slot(SLOT_W)
	local spell_slot_r = spellbook:get_spell_slot(SLOT_R)
	local total_spell_cost = spell_slot_q.spell_data.mana_cost + spell_slot_w.spell_data.mana_cost + spell_slot_r.spell_data.mana_cost
	if myHero.mana > total_spell_cost then
		return true
	end
	return false
end

local function LeeInsecReady()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	local control_ward, slot_ward = ControlWardCheck()
	if FullComboManReady() and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and ml.Ready(SLOT_R) and spell_slot.count > 0 and ml.Ready(SLOT_WARD) then
		return true
	end
return false
end

local function LeeInsecReadyControlWard()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	local control_ward, slot_ward = ControlWardCheck()
	if FullComboManReady() and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and ml.Ready(SLOT_R) and spell_slot.count == 0 and control_ward then
		return true
	end
return false
end

local function WardsAmmo()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	if spell_slot.count > 0 then
		return true
	end
return false
end

-- Damage Cals

local function GetQDmg(unit)
	local QDmg = getdmg("Q", unit, myHero, 1) + getdmg("Q", unit, myHero, 2)
	return QDmg
end

local function GetEDmg(unit)
	local EDmg = getdmg("E", unit, myHero, 1)
	return EDmg
end

local function GetRDmg(unit)
	local RDmg = getdmg("R", unit, myHero, 1)
	return RDmg
end

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	lee_category = menu:add_category_sprite("Shaun's Sexy Lee Sin", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	lee_category = menu:add_category("Shaun's Sexy Lee Sin")
end

lee_enabled = menu:add_checkbox("Enabled", lee_category, 1)
lee_combokey = menu:add_keybinder("Combo Mode Key", lee_category, 32)
lee_extra_flee_key = menu:add_keybinder("[Ward] Hop key - To Mouse Position", lee_category, 90)
menu:add_label("Welcome To Shaun's Sexy Lee Sin", lee_category)
menu:add_label("#SummerBodyReadyBaby", lee_category)

lee_ks_function = menu:add_subcategory("Kill Steal", lee_category)
lee_ks_q = menu:add_subcategory("[Q] Settings", lee_ks_function, 1)
lee_ks_use_q = menu:add_checkbox("Use [Q]", lee_ks_q, 1)
lee_ks_use_qr = menu:add_checkbox("Use [R] + [Q2] or [Q2] + [R]", lee_ks_q, 1)
lee_ks_e = menu:add_subcategory("[E] Settings", lee_ks_function, 1)
lee_ks_use_e = menu:add_checkbox("[E]", lee_ks_e, 1)
lee_ks_r = menu:add_subcategory("[R] Settings", lee_ks_function, 1)
lee_ks_use_r = menu:add_checkbox("Use [R]", lee_ks_r, 1)
lee_ks_blacklist = menu:add_subcategory("[Kill Steal] Champ Whitelist", lee_ks_function)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Kill Steal Champ Whitelist: "..tostring(t.champ_name), lee_ks_blacklist, 1)
    end
end

lee_combo = menu:add_subcategory("Combo", lee_category)
lee_combo_q = menu:add_subcategory("[Q] Settings", lee_combo)
lee_combo_use_q1 = menu:add_checkbox("Use [Q1]", lee_combo_q, 1)
lee_combo_use_q2 = menu:add_checkbox("Use [Q2]", lee_combo_q, 1)
lee_combo_use_q1_aa = menu:add_checkbox("Only Use [Q1] Outside AA Range", lee_combo_q, 1)
lee_combo_w = menu:add_subcategory("[W] Settings", lee_combo)
lee_combo_use_wgap = menu:add_checkbox("Use [W] Smart Gap Close", lee_combo_w, 1)
lee_combo_use_w1 = menu:add_checkbox("Use [W1]", lee_combo_w, 1)
lee_combo_use_w2 = menu:add_checkbox("Use [W2]", lee_combo_w, 1)
lee_combo_use_w_hp = menu:add_slider("[W2] IF My [HP] <= Than [%]", lee_combo_w, 1, 100, 30)
lee_combo_e = menu:add_subcategory("[E] Settings", lee_combo)
lee_combo_use_e1 = menu:add_checkbox("Use [E1]", lee_combo_e, 1)
lee_combo_use_e2 = menu:add_checkbox("Use [E2]", lee_combo_e, 1)

lee_harass = menu:add_subcategory("Harass", lee_category)
lee_harass_q = menu:add_subcategory("[Q] Settings", lee_harass)
lee_harass_use_q1 = menu:add_checkbox("Use [Q]", lee_harass_q, 1)
lee_harass_use_q2 = menu:add_checkbox("Use [Q2]", lee_harass_q, 1)
lee_harass_w = menu:add_subcategory("[W] Settings", lee_harass)
lee_harass_use_w1 = menu:add_checkbox("Use [W1]", lee_harass_w, 1)
lee_harass_use_w2 = menu:add_checkbox("Use [W2]", lee_harass_w, 1)
lee_harass_use_w_hp = menu:add_slider("[W2] IF My [HP] <= than [%]", lee_harass_w, 1, 100, 30)
lee_harass_e = menu:add_subcategory("[E] Settings", lee_harass)
lee_harass_use_e1 = menu:add_checkbox("Use [E1]", lee_harass_e, 1)
lee_harass_use_e2 = menu:add_checkbox("Use [E2]", lee_harass_e, 1)
lee_harass_min_mana = menu:add_slider("Minimum Energy [%] To Harass", lee_harass, 1, 100, 20)

lee_laneclear = menu:add_subcategory("Lane Clear", lee_category)
lee_laneclear_use_q = menu:add_subcategory("Use [Q] Settings", lee_laneclear, 1)
lee_laneclear_use_q1 = menu:add_checkbox("Use [Q1]", lee_laneclear_use_q, 1)
lee_laneclear_use_q2 = menu:add_checkbox("Use [Q2]", lee_laneclear_use_q, 1)
lee_laneclear_use_w = menu:add_subcategory("Use [W] Settings", lee_laneclear, 1)
lee_laneclear_use_w1 = menu:add_checkbox("Use [W1]", lee_laneclear_use_w, 1)
lee_laneclear_use_w2 = menu:add_checkbox("Use [W2]", lee_laneclear_use_w, 1)
lee_laneclear_use_w_hp = menu:add_slider("[W2] IF My [HP] <= Than [%]", lee_laneclear_use_w, 1, 100, 30)
lee_laneclear_use_e = menu:add_subcategory("Use [E] Settings", lee_laneclear, 1)
lee_laneclear_use_e1 = menu:add_checkbox("Use [E1]", lee_laneclear_use_e, 1)
lee_laneclear_use_e2 = menu:add_checkbox("Use [E2]", lee_laneclear_use_e, 1)
lee_laneclear_min_mana = menu:add_slider("Minimum Energy [%] To Lane Clear", lee_laneclear, 1, 100, 20)
lee_laneclear_e_min = menu:add_slider("Number Of Minions To Use [E]", lee_laneclear, 1, 10, 3)

lee_jungleclear = menu:add_subcategory("Jungle Clear", lee_category)
lee_jungleclear_use_q = menu:add_subcategory("Use [Q] Settings", lee_jungleclear, 1)
lee_jungleclear_use_q1 = menu:add_checkbox("Use [Q1]", lee_jungleclear_use_q, 1)
lee_jungleclear_use_q2 = menu:add_checkbox("Use [Q2]", lee_jungleclear_use_q, 1)
lee_jungleclear_use_w = menu:add_subcategory("Use [W] Settings", lee_jungleclear, 1)
lee_jungleclear_use_w1 = menu:add_checkbox("Use [W1]", lee_jungleclear_use_w, 1)
lee_jungleclear_use_w2 = menu:add_checkbox("Use [W2]", lee_jungleclear_use_w, 1)
lee_jungleclear_use_w_hp = menu:add_slider("[W2] IF My [HP] <= Than [%]", lee_jungleclear_use_w, 1, 100, 30)
lee_jungleclear_use_e = menu:add_subcategory("Use [E] Settings", lee_jungleclear, 1)
lee_jungleclear_use_e1 = menu:add_checkbox("Use [E1]", lee_jungleclear_use_e, 1)
lee_jungleclear_use_e2 = menu:add_checkbox("Use [E2]", lee_jungleclear_use_e, 1)
lee_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", lee_jungleclear, 1, 100, 20)

lee_extra_insec = menu:add_subcategory("[INSEC] Settings", lee_category)
lee_extra_insec_flash = menu:add_checkbox("Use [Flash] IF No [Ward] Is Available", lee_extra_insec, 1)
lee_insec_key = menu:add_keybinder("[INSEC] Hold Key - Target Nearest To Cursor", lee_extra_insec, 88)
e_table = {}
e_table[1] = "To Allys"
e_table[2] = "To Screen Visable Ally Turret"
e_table[3] = "Extended From Start Position"
lee_insec_direction = menu:add_combobox("[R] INSEC Direction Preference", lee_extra_insec, e_table, 2)
lee_extra_insec_blacklist = menu:add_subcategory("[INSEC] Champ Whitelist", lee_extra_insec)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("[INSEC] Champ Whitelist: "..tostring(t.champ_name), lee_extra_insec_blacklist, 1)
    end
end

lee_w_save = menu:add_subcategory("[W] Auto Shield Ally", lee_category)
lee_w_save_use = menu:add_checkbox("Use [W] Ally Save", lee_w_save, 1)
lee_w_save_hp = menu:add_slider("[W] Ally IF Ally [HP] <= Than [%]", lee_w_save, 1, 100, 30)
lee_w_save_targets = menu:add_slider("Minimum Targets Around Ally >=", lee_w_save, 1, 5, 2)
lee_w_save_hp_blacklist = menu:add_subcategory("[W] Save Ally Whitelist", lee_w_save)
local players = game.players
for _, v in pairs(players) do
    if v and not v.is_enemy then
        menu:add_checkbox("[W] Save Ally Whitelist"..tostring(v.champ_name), lee_w_save_hp_blacklist, 1)
    end
end

lee_extra = menu:add_subcategory("[R] Extra Features", lee_category)
lee_extra_semi_r_key = menu:add_keybinder("[R] Semi Manual Key", lee_extra, 65)
lee_extra_save = menu:add_subcategory("Smart [R] Save Me! Settings", lee_extra)
lee_extra_saveme = menu:add_checkbox("Use Smart [R] Save Me! Usage", lee_extra_save, 1)
lee_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", lee_extra_save, 1, 100, 25)
lee_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", lee_extra_save, 1, 100, 45)

lee_extra_gap = menu:add_subcategory("[R] Anti Gap Closer Settings", lee_extra)
lee_extra_gapclose = menu:add_toggle("[R] Toggle Anti Gap Closer key", 1, lee_extra_gap, 84, true)
lee_extra_gapclose_blacklist = menu:add_subcategory("[R] Anti Gap Closer Champ Whitelist", lee_extra_gap)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(t.champ_name), lee_extra_gapclose_blacklist, 1)
    end
end

lee_extra_int = menu:add_subcategory("[R] Interrupt Major Channel Spells Settings", lee_extra, 1)
lee_extra_interrupt = menu:add_checkbox("Use [R] Interrupt Major Channel Spells", lee_extra_int, 1)
lee_extra_interrupt_blacklist = menu:add_subcategory("[R] Interrupt Champ Whitelist", lee_extra_int)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(t.champ_name), lee_extra_interrupt_blacklist, 1)
    end
end

lee_draw = menu:add_subcategory("The Drawing Features", lee_category)
lee_draw_q = menu:add_checkbox("Draw [Q] Range", lee_draw, 1)
lee_draw_w = menu:add_checkbox("Draw [W] Range", lee_draw, 1)
lee_draw_e = menu:add_checkbox("Draw [E] Range", lee_draw, 1)
lee_draw_r = menu:add_checkbox("Draw [R] Range", lee_draw, 1)
lee_draw_ward = menu:add_checkbox("Draw [Ward Hop] Range", lee_draw, 1)
lee_draw_insec_ready = menu:add_checkbox("Draw [INSEC] Ready Text", lee_draw, 1)
lee_draw_gapclose = menu:add_checkbox("Draw [R] Anti Gap Closer Toggle Text", lee_draw, 1)
lee_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", lee_draw, 1)
lee_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo Colours On Target Health Bar", lee_draw, 1)

local function LeeInsecReadyWithFlash()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	local control_ward, slot_ward = ControlWardCheck()
	if FullComboManReady() and menu:get_value(lee_extra_insec_flash) == 1 and ml.Ready(SLOT_Q) and ml.Ready(SLOT_R) and spell_slot.count == 0 and not control_ward then
		if IsFlashSlotF() and ml.Ready(SLOT_F) then
			return true
		elseif IsFlashSlotD() and ml.Ready(SLOT_D) then
			return true
		end
	end
return false
end


-- Casting

local function CastQ(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, true, true)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastQMonsters(unit)
	pred_output = pred:predict(Q.speed, Q.delay, Q.range, Q.width, unit, false, false)
	if pred_output.can_cast then
		castPos = pred_output.cast_pos
		spellbook:cast_spell(SLOT_Q, Q.delay, castPos.x, castPos.y, castPos.z)
	end
end

local function CastW(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastW2Self()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E1.delay, x, y, z)
end

local function CastR(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

-- Combo

local function Combo()

	target = selector:find_target(1500, mode_health)
	local MyHeroHP = myHero.health/myHero.max_health <= menu:get_value(lee_combo_use_w_hp) / 100

	if menu:get_value(lee_combo_use_q1) == 1 and menu:get_value(lee_combo_use_q1_aa) == 0 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if not TargetHasQ1Buff(target) then
					if ml.Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end

	if menu:get_value(lee_combo_use_q1) == 1 and menu:get_value(lee_combo_use_q1_aa) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > myHero.attack_range then
				if not TargetHasQ1Buff(target) then
					if ml.Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end

	if menu:get_value(lee_combo_use_q2) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= Q.range then
				if TargetHasQ1Buff(target) then
					if ml.Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end
	end

	if menu:get_value(lee_combo_use_w1) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= 500 then
				if MyHeroHP then
					if ml.Ready(SLOT_W) then
						CastW(myHero)
					end
				end
			end
		end
	end

	if menu:get_value(lee_combo_use_w2) == 1 then
		if ml.IsValid(target) and IsKillable(target) then
			if myHero:distance_to(target.origin) <= 500 then
				if MyHeroHP and LeeHasW2(myHero) then
					if ml.Ready(SLOT_W) then
						CastW2Self()
					end
				end
			end
		end
	end

	if menu:get_value(lee_combo_use_e1) == 1 then
		if myHero:distance_to(target.origin) <= E1.range and ml.IsValid(target) and IsKillable(target) then
			if ml.Ready(SLOT_E) then
				CastE()
			end
		end
	end

	if menu:get_value(lee_combo_use_e2) == 1 then
		if myHero:distance_to(target.origin) <= E2.range and ml.IsValid(target) and IsKillable(target) then
			if LeeHasE2(myHero) then
				if ml.Ready(SLOT_E) then
					CastE()
				end
			end
		end
	end
end

-- Combo GapClose

--[[local function ComboGap()

	target = selector:find_target(1500, mode_health)
	local GapRange = 600 + Q.range
	local wards = game.wards
	local players = game.players

	if menu:get_value(lee_combo_use_wgap) == 1 then

		local pred_output = pred:predict(Q.speed, Q.delay, GapRange, Q.width, target, true, true)
		if pred_output.can_cast then
			--local jumppos = ml.Extend(target.origin, myHero.origin, 600)
			Direction = ml.Sub(target.origin, myHero.origin):normalized()
			Position = ml.VectorMag(Direction, Ward.range)
			jumppos = ml.Add(Position, myHero.origin)
			if myHero:distance_to(target.origin) <= GapRange then
				for _, ally in ipairs(players) do
					if myHero:distance_to(ally.origin) <= W.range and EasyDistCompare(jumppos.origin, ally.origin) <= 300 and ml.Ready(SLOT_W) then
						origin = ally.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end

					if ml.Ready(SLOT_W) and ml.Ready(SLOT_WARD) and WardsAmmo() and EasyDistCompare(jumppos.origin, ally.origin) > 300 then
						ComboGapReady = true
					end

					for _, ward in ipairs(wards) do
						if ml.Ready(SLOT_W) and ml.Ready(SLOT_WARD) and ward and EasyDistCompare(jumppos.origin, ward.origin) <= 300 then
							ComboGapReady = true
							ComboGap_Wfire = true
						end
					end

					if ComboGapReady and not ComboGap_Wfire and ml.Ready(SLOT_WARD) then
						if EasyDistCompare(jumppos.origin, myHero.origin) <= Ward.range then
							spellbook:cast_spell(SLOT_WARD, W.delay, jx, jy, jz)
							ComboGap_Wfire = true
						end
					end

					for _, ward in ipairs(wards) do
						if ComboGapReady and ComboGap_Wfire and ml.Ready(SLOT_W) then
							if myHero:distance_to(ward.origin) <= W.range and EasyDistCompare(jumppos.origin, ward.origin) <= 300 then
								origin = ward.origin
								x, y, z = origin.x, origin.y, origin.z
								spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
							end
						end
					end
				end
			end
		end
	end
end]]

-- Harass

local function Harass()

	target = selector:find_target(1500, mode_health)
	local MyHeroHP = myHero.health/myHero.max_health <= menu:get_value(lee_harass_use_w_hp) / 100
	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(lee_harass_min_mana) / 100

	if GrabHarassMana then
		if menu:get_value(lee_harass_use_q1) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= Q.range then
					if not TargetHasQ1Buff(target) then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end

		if menu:get_value(lee_harass_use_q2) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= Q.range then
					if TargetHasQ1Buff(target) then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end

		if menu:get_value(lee_harass_use_w1) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= 500 then
					if MyHeroHP then
						if ml.Ready(SLOT_W) then
							CastW(myHero)
						end
					end
				end
			end
		end

		if menu:get_value(lee_harass_use_w2) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= 500 then
					if MyHeroHP and LeeHasW2(myHero) then
						if ml.Ready(SLOT_W) then
							CastW2Self()
						end
					end
				end
			end
		end

		if menu:get_value(lee_harass_use_e1) == 1 then
			if myHero:distance_to(target.origin) <= E1.range and ml.IsValid(target) and IsKillable(target) then
				if ml.Ready(SLOT_E) then
					CastE()
				end
			end
		end

		if menu:get_value(lee_harass_use_e2) == 1 then
			if myHero:distance_to(target.origin) <= E2.range and ml.IsValid(target) and IsKillable(target) then
				if LeeHasE2(myHero) then
					if ml.Ready(SLOT_E) then
						CastE()
					end
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local QRDmg = GetQDmg(target) + GetRDmg(target)

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(lee_ks_use_q) == 1 then
				if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
					if GetQDmg(target) > target.health then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(lee_ks_use_q) == 1 then
				if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
					if GetQDmg(target) > target.health then
						if ml.Ready(SLOT_Q) and TargetHasQ1Buff(target) then
							CastQ(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(lee_ks_use_qr) == 1 then
				if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
					if QRDmg > target.health then
						if ml.Ready(SLOT_Q) then
							CastQ(target)
						end
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > R.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(lee_ks_use_qr) == 1 then
				if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
					if QRDmg > target.health then
						if ml.Ready(SLOT_Q) and TargetHasQ1Buff(target) and not ml.Ready(SLOT_R) then
							CastQ(target)
						end
					end
				end
			end
		end

		if menu:get_value(lee_ks_use_e) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= E1.range then
					if ml.Ready(SLOT_E) then
						if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
							if GetEDmg(target) > target.health then
								CastE()
							end
						end
					end
				end
			end
		end

		if menu:get_value(lee_ks_use_e) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= E1.range then
					if ml.Ready(SLOT_E) and LeeHasE2(myHero) then
						if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
							if GetEDmg(target) > target.health then
								CastE()
							end
						end
					end
				end
			end
		end

		if menu:get_value(lee_ks_use_qr) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= R.range then
					if ml.Ready(SLOT_R) and TargetHasQ1Buff(target) then
						if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
							if QRDmg > target.health then
								CastR(target)
							end
						end
					end
				end
			end
		end

		if menu:get_value(lee_ks_use_r) == 1 then
			if ml.IsValid(target) and IsKillable(target) then
				if myHero:distance_to(target.origin) <= R.range then
					if ml.Ready(SLOT_R) then
						if menu:get_value_string("Kill Steal Champ Whitelist: "..tostring(target.champ_name)) == 1 then
							if GetRDmg(target) > target.health then
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

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(lee_laneclear_min_mana) / 100
	local MyHeroHP = myHero.health/myHero.max_health <= menu:get_value(lee_laneclear_use_w_hp) / 100
	minions = game.minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 700
		if GrabHarassMana then

			if menu:get_value(lee_laneclear_use_q1) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= Q.range then
						if not TargetHasQ1Buff(target) then
							if ml.Ready(SLOT_Q) and TargetNearMouse then
								CastQMonsters(target)
							end
						end
					end
				end
			end

			if menu:get_value(lee_laneclear_use_q2) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= Q.range then
						if TargetHasQ1Buff(target) then
							if ml.Ready(SLOT_Q) and TargetNearMouse then
								CastQMonsters(target)
							end
						end
					end
				end
			end

			if menu:get_value(lee_laneclear_use_w1) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= 500 then
						if MyHeroHP then
							if ml.Ready(SLOT_W) and TargetNearMouse then
								CastW(myHero)
							end
						end
					end
				end
			end

			if menu:get_value(lee_laneclear_use_w2) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= 500 then
						if MyHeroHP and LeeHasW2(myHero) and TargetNearMouse then
							if ml.Ready(SLOT_W) then
								CastW2Self()
							end
						end
					end
				end
			end

			if menu:get_value(lee_laneclear_use_e1) == 1 then
				if myHero:distance_to(target.origin) <= E1.range and ml.IsValid(target) and IsKillable(target) then
					if ml.Ready(SLOT_E) and GetMinionCount(E1.range, myHero) <= menu:get_value(lee_laneclear_e_min) and TargetNearMouse then
						CastE()
					end
				end
			end

			if menu:get_value(lee_laneclear_use_e2) == 1 then
				if myHero:distance_to(target.origin) <= E2.range and ml.IsValid(target) and IsKillable(target) then
					if LeeHasE2(myHero) then
						if ml.Ready(SLOT_E) and TargetNearMouse then
							CastE()
						end
					end
				end
			end
		end
	end
end


-- Jungle Clear

local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(lee_jungleclear_min_mana) / 100
	local MyHeroHP = myHero.health/myHero.max_health <= menu:get_value(lee_jungleclear_use_w_hp) / 100

	minions = game.jungle_minions
	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 700

		if GrabJungleClearMana then

			if menu:get_value(lee_jungleclear_use_q1) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= Q.range then
						if not TargetHasQ1Buff(target) then
							if ml.Ready(SLOT_Q) and TargetNearMouse then
								CastQMonsters(target)
							end
						end
					end
				end
			end

			if menu:get_value(lee_jungleclear_use_q2) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= Q.range then
						if TargetHasQ1Buff(target) then
							if ml.Ready(SLOT_Q) and TargetNearMouse then
								CastQMonsters(target)
							end
						end
					end
				end
			end

			if menu:get_value(lee_jungleclear_use_w1) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= 500 then
						if MyHeroHP then
							if ml.Ready(SLOT_W) and TargetNearMouse then
								CastW(myHero)
							end
						end
					end
				end
			end

			if menu:get_value(lee_jungleclear_use_w2) == 1 then
				if ml.IsValid(target) and IsKillable(target) then
					if myHero:distance_to(target.origin) <= 500 then
						if MyHeroHP and LeeHasW2(myHero) and TargetNearMouse then
							if ml.Ready(SLOT_W) then
								CastW2Self()
							end
						end
					end
				end
			end

			if menu:get_value(lee_jungleclear_use_e1) == 1 then
				if myHero:distance_to(target.origin) <= E1.range and ml.IsValid(target) and IsKillable(target) then
					if ml.Ready(SLOT_E) and TargetNearMouse then
						CastE()
					end
				end
			end

			if menu:get_value(lee_jungleclear_use_e2) == 1 then
				if myHero:distance_to(target.origin) <= E2.range and ml.IsValid(target) and IsKillable(target) then
					if LeeHasE2(myHero) then
						if ml.Ready(SLOT_E) and TargetNearMouse then
							CastE()
						end
					end
				end
			end
		end
	end
end

-- Auto W Save
local function AutoWSave()

	target = selector:find_target(1500, mode_health)
	players = game.players

	if menu:get_value(lee_w_save_use) == 1 and ml.Ready(SLOT_W) then

		for _, ally in ipairs(players) do
			local AllyHP = ally.health/ally.max_health <= menu:get_value(lee_w_save_hp) / 100
			local _, count = ml.GetEnemyCount(ally.origin, 1500)

			if menu:get_value_string("[W] Save Ally Whitelist"..tostring(ally.champ_name)) == 1 then
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if ally and myHero:distance_to(ally.origin) <= W.range and ml.IsValid(ally) then
						if AllyHP then
							if ml.IsValid(target) and count >= menu:get_value(lee_w_save_targets) then
								if ally:distance_to(target.origin) < target.attack_range then
									CastW(ally)
								end
							end
						end
					end
				end
			end
		end
	end
end


-- Manual R

local function ManualR()

  target = selector:find_target(1500, mode_distance)

  if game:is_key_down(menu:get_value(lee_extra_semi_r_key)) then
    if myHero:distance_to(target.origin) < R.range then
			if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
				CastR(target)
			end
    end
  end
end

-- Manual R

local function RSaveMe()

  target = selector:find_target(1500, mode_distance)
	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(lee_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(lee_extra_saveme_target) / 100

	if menu:get_value(lee_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < R.range then
			if myHero:distance_to(target.origin) < target.attack_range then
				if target:is_facing(myHero) then
					if SaveMeHP and TargetHP then
						if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
							CastR(target)
						end
					end
				end
			end
    end
  end
end

-- Flee
local function Flee()

	local control_ward, control_ward_slot = ControlWardCheck()
	local wards = game.wards
	local players = game.players

	for _, ally in ipairs(players) do
		if myHero:distance_to(ally.origin) <= W.range and ally:distance_to(game.mouse_pos) <= 300 and ml.Ready(SLOT_W) then
			origin = ally.origin
			x, y, z = origin.x, origin.y, origin.z
			spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
		end

		if game:is_key_down(menu:get_value(lee_extra_flee_key)) then
			if ml.Ready(SLOT_W) and ml.Ready(SLOT_WARD) or control_ward and ally:distance_to(game.mouse_pos) > 300 then
				FleeReady = true
			end
		end

		for _, ward in ipairs(wards) do
			if ml.Ready(SLOT_W) and ml.Ready(SLOT_WARD) and ward and ward:distance_to(game.mouse_pos) <= 300 then
				FleeReady = true
				flee_Wfire = true
			end
		end

		if FleeReady and not flee_Wfire and not ml.Ready(SLOT_WARD) and control_ward then
			if myHero:distance_to(game.mouse_pos) <= Ward.range then
				spellbook:cast_spell(control_ward_slot, W.delay, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
				flee_Wfire = true
			end
		end

		if FleeReady and not flee_Wfire and ml.Ready(SLOT_WARD) then
			if myHero:distance_to(game.mouse_pos) <= Ward.range then
				spellbook:cast_spell(SLOT_WARD, W.delay, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
				flee_Wfire = true
			end
		end

		for _, ward in ipairs(wards) do
			if FleeReady and flee_Wfire and ml.Ready(SLOT_W) then
				if myHero:distance_to(ward.origin) <= W.range and ward:distance_to(game.mouse_pos) <= 300 then
					origin = ward.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
				end
			end
		end
	end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(lee_extra_gapclose) then
    if ml.IsValid(obj) then
			if menu:get_value_string("Anti Gap Closer Whitelist: "..tostring(obj.champ_name)) == 1 then
	      if obj:is_facing(myHero) and myHero:distance_to(dash_info.end_pos) < 300 and ml.Ready(SLOT_R) then
	        CastR(obj)
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) then
    if menu:get_value(lee_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
      	if myHero:distance_to(obj.origin) < 300 and ml.Ready(SLOT_R) then
        	CastR(obj)
				end
			end
		end
	end
end

local function INSEC()

	target = selector:find_target(2000, mode_cursor)

	local control_ward, control_ward_slot = ControlWardCheck()
	local players = game.players
	local wards = game.wards
	local turrets = game.turrets

	if menu:get_value_string("[INSEC] Champ Whitelist: "..tostring(target.champ_name)) == 1 then

		if menu:get_value(lee_insec_direction) == 0 then
			for _, ally in ipairs(players) do
				if not ally.is_enemy and ally.object_id ~= myHero.object_id then
					if ml.IsValid(target) and IsKillable(target) then
					 	if ally:distance_to(target.origin) <= 2000 then
							if ml.IsValid(target) and IsKillable(target) then

								if LeeInsecReady() then
									InsecReady = true
									TrinketWard = true
								end

								if LeeInsecReadyControlWard() then
									InsecReady = true
									UseControlWard = true
								end

								if LeeInsecReadyWithFlash() then
									InsecReady = true
									UseFlash = true
								end

								if InsecReady and myHero:distance_to(target.origin) < Q.range and ml.Ready(SLOT_Q) then
									CastQ(target)
								elseif TargetHasQ1Buff(target) and ml.Ready(SLOT_Q) then
									CastQ(target)
								end

								-- Ward INSEC

								if InsecReady and not TrinketWard and control_ward and UseControlWard and not UseFlash and TargetHasQ1Buff(target) then
									if myHero:distance_to(target.origin) < 425 and not WardCasted then
										local wardpos = ml.Extend(ally.origin, target.origin, 200)
										spellbook:cast_spell(control_ward_slot, W.delay, wardpos.x, wardpos.y, wardpos.z)
										if not ml.Ready(control_ward_slot) then
											WardCasted = true
										end
									end
								end

								if InsecReady and TrinketWard and ml.Ready(SLOT_WARD) and not UseFlash and TargetHasQ1Buff(target) then
									if target:distance_to(myHero.origin) <= 425 and not WardCasted then
										local wardpos = ml.Extend(ally.origin, target.origin, 200)
										spellbook:cast_spell(SLOT_WARD, W.delay, wardpos.x, wardpos.y, wardpos.z)
										if not ml.Ready(SLOT_WARD) then
											WardCasted = true
										end
									end
								end

								for _, ward in ipairs(wards) do
									if InsecReady and ward and myHero:distance_to(ward.origin) <= W.range and target:distance_to(ward.origin) < 300 and not UseFlash and ml.Ready(SLOT_W) then
										origin = ward.origin
										x, y, z = origin.x, origin.y, origin.z
										spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
									end

									if InsecReady and myHero:distance_to(target.origin) <= R.range and myHero:distance_to(ward.origin) < 250 and not UseFlash then
										if ml.Ready(SLOT_R) then
											CastR(target)
										end
									end
								end

								-- Flash Casting

								if InsecReady and myHero:distance_to(target.origin) <= 200 and UseFlash then
									local flashpos = ml.Extend(ally.origin, target.origin, 200)
									if IsFlashSlotD() and ml.Ready(SLOT_D) then
										spellbook:cast_spell(SLOT_D, 0.1, flashpos.x, flashpos.y, flashpos.z)
									elseif IsFlashSlotF() and ml.Ready(SLOT_F) then
										spellbook:cast_spell(SLOT_F, 0.1, flashpos.x, flashpos.y, flashpos.z)
									end
								end

								-- R Flash Casting

								if InsecReady and UseFlash and myHero:distance_to(target.origin) <= R.range then
									if IsFlashSlotD() and not ml.Ready(SLOT_D) and ml.Ready(SLOT_R) then
										CastR(target)
									elseif IsFlashSlotF() and not ml.Ready(SLOT_F) and ml.Ready(SLOT_R) then
										CastR(target)
									end
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(lee_insec_direction) == 1 then
			for i, turret in ipairs(turrets) do
				if turret and not turret.is_enemy and turret.is_alive then
					if menu:get_value(lee_insec_direction) == 1 then
						if ml.IsValid(target) and IsKillable(target) then

							if LeeInsecReady() then
								InsecReady = true
								TrinketWard = true
							end

							if LeeInsecReadyControlWard() then
								InsecReady = true
								UseControlWard = true
							end

							if LeeInsecReadyWithFlash() then
								InsecReady = true
								UseFlash = true
							end

							if InsecReady and myHero:distance_to(target.origin) < Q.range and ml.Ready(SLOT_Q) then
								CastQ(target)
							elseif TargetHasQ1Buff(target) and ml.Ready(SLOT_Q) then
								CastQ(target)
							end

							-- Ward INSEC

							if InsecReady and not TrinketWard and control_ward and UseControlWard and not UseFlash and TargetHasQ1Buff(target) then
								if myHero:distance_to(target.origin) < 425 and not WardCasted then
									local wardpos = ml.Extend(turret.origin, target.origin, 200)
									spellbook:cast_spell(control_ward_slot, W.delay, wardpos.x, wardpos.y, wardpos.z)
									if not ml.Ready(control_ward_slot) then
										WardCasted = true
									end
								end
							end

							if InsecReady and TrinketWard and ml.Ready(SLOT_WARD) and not UseFlash and TargetHasQ1Buff(target) then
								if target:distance_to(myHero.origin) <= 425 and not WardCasted then
									local wardpos = ml.Extend(turret.origin, target.origin, 200)
									spellbook:cast_spell(SLOT_WARD, W.delay, wardpos.x, wardpos.y, wardpos.z)
									if not ml.Ready(SLOT_WARD) then
										WardCasted = true
									end
								end
							end

							for _, ward in ipairs(wards) do
								if InsecReady and ward and myHero:distance_to(ward.origin) <= W.range and target:distance_to(ward.origin) < 300 and not UseFlash and ml.Ready(SLOT_W) then
									origin = ward.origin
									x, y, z = origin.x, origin.y, origin.z
									spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
								end

								if InsecReady and myHero:distance_to(target.origin) <= R.range and myHero:distance_to(ward.origin) < 250 and not UseFlash then
									if ml.Ready(SLOT_R) then
										CastR(target)
									end
								end
							end

							-- Flash Casting

							if InsecReady and myHero:distance_to(target.origin) <= 200 and UseFlash then
								local flashpos = ml.Extend(turret.origin, target.origin, 200)
								if IsFlashSlotD() and ml.Ready(SLOT_D) then
									spellbook:cast_spell(SLOT_D, 0.1, flashpos.x, flashpos.y, flashpos.z)
								elseif IsFlashSlotF() and ml.Ready(SLOT_F) then
									spellbook:cast_spell(SLOT_F, 0.1, flashpos.x, flashpos.y, flashpos.z)
								end
							end

							-- R Flash Casting

							if InsecReady and UseFlash and myHero:distance_to(target.origin) <= R.range then
								if IsFlashSlotD() and not ml.Ready(SLOT_D) and ml.Ready(SLOT_R) then
									CastR(target)
								elseif IsFlashSlotF() and not ml.Ready(SLOT_F) and ml.Ready(SLOT_R) then
									CastR(target)
								end
							end
						end
					end
				end
			end
		end

		if menu:get_value(lee_insec_direction) == 2 then
			if ml.IsValid(target) and IsKillable(target) then

				if LeeInsecReady() then
					InsecReady = true
					TrinketWard = true
				end

				if LeeInsecReadyControlWard() then
					InsecReady = true
					UseControlWard = true
				end

				if LeeInsecReadyWithFlash() then
					InsecReady = true
					UseFlash = true
				end

				if InsecReady and myHero:distance_to(target.origin) < Q.range and ml.Ready(SLOT_Q) then
					CastQ(target)
				elseif TargetHasQ1Buff(target) and ml.Ready(SLOT_Q) then
					CastQ(target)
				end

				-- Ward INSEC

				if InsecReady and not TrinketWard and control_ward and UseControlWard and not UseFlash and TargetHasQ1Buff(target) then
					if myHero:distance_to(target.origin) < 425 and not WardCasted then
						local wardpos = ml.Extend(myHero.origin, target.origin, 200)
						spellbook:cast_spell(control_ward_slot, W.delay, wardpos.x, wardpos.y, wardpos.z)
						if not ml.Ready(control_ward_slot) then
							WardCasted = true
						end
					end
				end

				if InsecReady and TrinketWard and ml.Ready(SLOT_WARD) and not UseFlash and TargetHasQ1Buff(target) then
					if target:distance_to(myHero.origin) <= 425 and not WardCasted then
						local wardpos = ml.Extend(myHero.origin, target.origin, 200)
						spellbook:cast_spell(SLOT_WARD, W.delay, wardpos.x, wardpos.y, wardpos.z)
						if not ml.Ready(SLOT_WARD) then
							WardCasted = true
						end
					end
				end

				for _, ward in ipairs(wards) do
					if InsecReady and ward and myHero:distance_to(ward.origin) <= W.range and target:distance_to(ward.origin) < 300 and not UseFlash and ml.Ready(SLOT_W) then
						origin = ward.origin
						x, y, z = origin.x, origin.y, origin.z
						spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
					end

					if InsecReady and myHero:distance_to(target.origin) <= R.range and myHero:distance_to(ward.origin) < 250 and not UseFlash then
						if ml.Ready(SLOT_R) then
							CastR(target)
						end
					end
				end

				-- Flash Casting

				if InsecReady and myHero:distance_to(target.origin) <= 200 and UseFlash then
					local flashpos = ml.Extend(myHero.origin, target.origin, 200)
					if IsFlashSlotD() and ml.Ready(SLOT_D) then
						spellbook:cast_spell(SLOT_D, 0.1, flashpos.x, flashpos.y, flashpos.z)
					elseif IsFlashSlotF() and ml.Ready(SLOT_F) then
						spellbook:cast_spell(SLOT_F, 0.1, flashpos.x, flashpos.y, flashpos.z)
					end
				end

				-- R Flash Casting

				if InsecReady and UseFlash and myHero:distance_to(target.origin) <= R.range then
					if IsFlashSlotD() and not ml.Ready(SLOT_D) and ml.Ready(SLOT_R) then
						CastR(target)
					elseif IsFlashSlotF() and not ml.Ready(SLOT_F) and ml.Ready(SLOT_R) then
						CastR(target)
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

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end

	local myherodraw = game:world_to_screen(justme.x, justme.y, justme.z)

	if menu:get_value(lee_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 0, 255, 255)
		end
	end

  if menu:get_value(lee_draw_w) == 1 then
		if ml.Ready(SLOT_W) then
			renderer:draw_circle(x, y, z, W.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(lee_draw_ward) == 1 then
		if ml.Ready(SLOT_WARD) then
			renderer:draw_circle(x, y, z, Ward.range, 0, 255, 255, 255)
		end
	end

	if menu:get_value(lee_draw_e) == 1  then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E1.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(lee_draw_r) == 1  then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 255, 0, 255)
		end
	end


	local enemydraw = game:world_to_screen(targetvec.x, targetvec.y, targetvec.z)
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetRDmg(target)
		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(lee_draw_kill) == 1 then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid and not InsecReady then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(lee_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end

	if menu:get_value(lee_draw_insec_ready) == 1 then
	 	if LeeInsecReady() or LeeInsecReadyControlWard() and not InsecReady then
		 	renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 50, "Ward [INSEC] Ready!")
	 	end
 	end

 	if menu:get_value(lee_draw_insec_ready) == 1 then
		if LeeInsecReadyWithFlash() and not InsecReady then
			renderer:draw_text_big_centered(myherodraw.x, myherodraw.y + 50, "Flash [INSEC] Ready!")
		end
	end

	if menu:get_value(lee_draw_gapclose) == 1 then
		if menu:get_toggle_state(lee_extra_gapclose) then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle [R] Anti Gap Closer Enabled")
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(lee_combokey)) and menu:get_value(lee_enabled) == 1 then
		Combo()
		--ComboGap()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(lee_extra_semi_r_key)) then
		orbwalker:move_to()
		ManualR()
	end

	if game:is_key_down(menu:get_value(lee_extra_flee_key)) then
		orbwalker:move_to()
		Flee()
	end

	AutoKill()
	RSaveMe()
	AutoWSave()

	if game:is_key_down(menu:get_value(lee_insec_key)) and not LeeInsecReady() and not LeeInsecReadyWithFlash() and not LeeInsecReadyControlWard() and not ml.Ready(SLOT_R) then
		Combo()
		orbwalker:move_to()
		orbwalker:enable_auto_attacks()
	end


	if game:is_key_down(menu:get_value(lee_insec_key)) then
		INSEC()
		orbwalker:move_to()
	end

	if not game:is_key_down(menu:get_value(lee_insec_key)) then
		InsecReady = false
		WardCasted = false
		UseControlWard = false
		UseFlash = false
		TrinketWard = false
	end

	if not game:is_key_down(menu:get_value(lee_extra_flee_key)) then
		flee_Wfire = false
		FleeReady = false
	end

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
