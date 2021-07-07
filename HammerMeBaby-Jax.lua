if game.local_player.champ_name ~= "Jax" then
	return
end

do
    local function AutoUpdate()
		local Version = 1.3
		local file_name = "HammerMeBaby-Jax.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/HammerMeBaby-Jax.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/HammerMeBaby-Jax.lua.version.txt")
        console:log("HammerMeBaby-Jax.lua Vers: "..Version)
		console:log("HammerMeBaby-Jax.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log(".......................................................")
            console:log("..Shaun's Jax Successfully Loaded...")
						console:log(".......................................................")
        else
			http:download_file(url, file_name)
			      console:log("Shaun's Jax Update available.....")
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
local FleeReady = false
local flee_Wfire = false
local FlashCombo = false
local Flash = false
local Blockward = false

-- Ranges

local Q = { range = 700, delay = .1, width = 0, speed = 0 }
local W = { range = 0, delay = .1, width = 0, speed = 0 }
local E = { range = 300, delay = .1, width = 0, speed = 0 }
local R = { range = 0, delay = .1, width = 0, speed = 0 }
local Ward = { range = 630 }
local QFlash = { range = 1100 }

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

local function GetEnemyCount(range, unit)
	count = 0
	for i, hero in ipairs(ml.GetEnemyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit, hero) < Range and ml.IsValid(hero) then
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

local function ControlWardCheck()
  local control_ward = false
  local control_ward_slot = nil
  local inventory = ml.GetItems()
  for _, v in ipairs(inventory) do
    if tonumber(v) == 2055 then
    	local item = local_player:get_item(tonumber(v))
    	if item ~= 0 then
		    control_ward_slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
				control_ward = true
			end
  	end
  end
  return control_ward, control_ward_slot
end

local function SweeperCheck()
  local int = ml.GetItems()
  for _, v in ipairs(int) do
    if tonumber(v) == 3364 then
    	local item = local_player:get_item(tonumber(v))
    	if item ~= 0 then
				return true
			end
  	end
  end
  return false
end

--[[local function SweeperCheck()
	local spell_slot = spellbook:get_spell_slot(SLOT_WARD)
	if spell_slot.spell_data.name == "TrinketSweeperLvl3" then
		return true
	end
	return false
end]]

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

local function FullComboManReady()
	local spell_slot_q = spellbook:get_spell_slot(SLOT_Q)
	local spell_slot_w = spellbook:get_spell_slot(SLOT_W)
	local spell_slot_e = spellbook:get_spell_slot(SLOT_E)
	local total_spell_cost = spell_slot_q.spell_data.mana_cost + spell_slot_w.spell_data.mana_cost + spell_slot_e.spell_data.mana_cost
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

local function JaxHasE1()
  if myHero:has_buff("JaxCounterStrike") then
    return true
  end
  return false
end

local function JaxHasW()
  if myHero:has_buff("JaxEmpowerTwo") then
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

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	jax_category = menu:add_category_sprite("Shaun's Jax", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	jax_category = menu:add_category("Shaun's Jax")
end

jax_enabled = menu:add_checkbox("Enabled", jax_category, 1)
jax_combokey = menu:add_keybinder("Combo Mode Key", jax_category, 32)
jax_extra_flee_key = menu:add_keybinder("[Ward,Minion,Ally,Jungle] Jump", jax_category, 90)
menu:add_label("Shaun's Sexy Jax", jax_category)
menu:add_label("#HammerMeHardBaby", jax_category)

jax_ks_function = menu:add_subcategory("[Kill Steal]", jax_category)
jax_ks_q = menu:add_subcategory("[Q] Settings", jax_ks_function, 1)
jax_ks_use_q = menu:add_checkbox("Use [Q]", jax_ks_q, 1)
jax_ks_w = menu:add_subcategory("[W] Settings", jax_ks_function, 1)
jax_ks_use_w = menu:add_checkbox("Use [W]", jax_ks_w, 1)
jax_ks_e = menu:add_subcategory("[E] Settings", jax_ks_function, 1)
jax_ks_use_e = menu:add_checkbox("Use [E]", jax_ks_e, 1)

jax_combo_selection = menu:add_subcategory("[Combo Selection]", jax_category)
jax_combo = menu:add_subcategory("[Basic Combo]", jax_combo_selection)
jax_combo_q = menu:add_subcategory("[Q] Settings", jax_combo)
jax_combo_use_q = menu:add_checkbox("Use [Q]", jax_combo_q, 1)
jax_combo_use_q_aa = menu:add_checkbox("Only Use [Q] Outside [AA] Range", jax_combo_q, 1)
jax_combo_w = menu:add_subcategory("[W] Settings", jax_combo)
jax_combo_use_w = menu:add_checkbox("Use [W]", jax_combo_w, 1)
jax_combo_e = menu:add_subcategory("[E] Settings", jax_combo)
jax_combo_use_e = menu:add_checkbox("Use [E]", jax_combo_e, 1)

jax_combo_flash = menu:add_subcategory("[Flash Engage Combo]", jax_combo_selection)
jax_combo_flash_key = menu:add_keybinder("[Flash Engage Combo] Key", jax_combo_flash, 88)

jax_combo_qturret = menu:add_toggle("[Q] Target Under Turret Toggle", 1, jax_combo_selection, 84, true)

jax_harass = menu:add_subcategory("[Harass]", jax_category)
jax_harass_q = menu:add_subcategory("[Q] Settings", jax_harass)
jax_harass_use_q = menu:add_checkbox("Use [Q]", jax_harass_q, 1)
jax_harass_w = menu:add_subcategory("[W] Settings", jax_harass)
jax_harass_use_w = menu:add_checkbox("Use [W]", jax_harass_w, 1)
jax_harass_e = menu:add_subcategory("[E] Settings", jax_harass)
jax_harass_use_e = menu:add_checkbox("Use [E]", jax_harass_e, 1)
jax_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", jax_harass, 1, 100, 20)

jax_laneclear = menu:add_subcategory("[Lane Clear]", jax_category)
jax_laneclear_use_q = menu:add_checkbox("Use [Q]", jax_laneclear, 1)
jax_laneclear_use_w = menu:add_checkbox("Use [W]", jax_laneclear, 1)
jax_laneclear_use_e = menu:add_checkbox("Use [E]", jax_laneclear, 1)
jax_laneclear_min_e = menu:add_slider("Minimum Minions To Use [E]", jax_laneclear, 1, 5, 3)
jax_laneclear_min_mana = menu:add_slider("Minimum Mana [%] To Lane Clear", jax_laneclear, 1, 100, 20)

jax_jungleclear = menu:add_subcategory("[Jungle Clear]", jax_category)
jax_jungleclear_use_q = menu:add_checkbox("Use [Q]", jax_jungleclear, 1)
jax_jungleclear_use_w = menu:add_checkbox("Use [W]", jax_jungleclear, 1)
jax_jungleclear_use_e = menu:add_checkbox("Use [E]", jax_jungleclear, 1)
jax_jungleclear_min_mana = menu:add_slider("Minimum Mana [%] To Jungle", jax_jungleclear, 1, 100, 20)

jax_extra = menu:add_subcategory("[Automated] Features", jax_category)
jax_extra_e_number = menu:add_subcategory("Auto [E2] IF Can Stun 'X' Count", jax_extra)
jax_extra_e_number_use = menu:add_checkbox("Use Auto [E2] IF Can Stun", jax_extra_e_number, 1)
jax_extra_e_number_count = menu:add_slider("[E2] IF Can Stun Count", jax_extra_e_number, 1, 5, 3)

jax_extra_r_number = menu:add_subcategory("Auto [R] Targets Around Jax", jax_extra)
jax_extra_r_number_use = menu:add_checkbox("Use Auto [R] Targets Around Jax", jax_extra_r_number, 1)
jax_extra_r_number_hp = menu:add_slider("[R] Targets Around - Jax [HP] %", jax_extra_r_number, 1, 100, 60)
jax_extra_r_number_count = menu:add_slider("Auto [R] Target Count", jax_extra_r_number, 1, 5, 3)

jax_extra_save = menu:add_subcategory("[R] Save Me! Settings", jax_extra)
jax_extra_saveme = menu:add_checkbox("[R] Save Me! Usage", jax_extra_save, 1)
jax_extra_saveme_myhp = menu:add_slider("[R] Save Me! When My HP < [%]", jax_extra_save, 1, 100, 25)
jax_extra_saveme_target = menu:add_slider("[R] Save Me! When Target > [%]", jax_extra_save, 1, 100, 45)

jax_extra_gap = menu:add_subcategory("[E2] Auto Gap Closer Escape", jax_category)
jax_extra_gapclose = menu:add_toggle("[E2] Toggle Gap Closer Escape key", 1, jax_extra_gap, 84, true)
jax_extra_gapclose_blacklist = menu:add_subcategory("[E2] Anti Gap Closer Champ Whitelist", jax_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Gap Closer Escape Whitelist: "..tostring(p.champ_name), jax_extra_gapclose_blacklist, 1)
    end
end

jax_extra_int = menu:add_subcategory("[E2] Interrupt Channels", jax_category, 1)
jax_extra_interrupt = menu:add_checkbox("Use [E2] Interrupt Major Channel Spells", jax_extra_int, 1)
jax_extra_interrupt_blacklist = menu:add_subcategory("[E2] Interrupt Champ Whitelist", jax_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), jax_extra_interrupt_blacklist, 1)
    end
end

jax_draw = menu:add_subcategory("[Drawing] Features", jax_category)
jax_draw_q = menu:add_checkbox("Draw [Q] Range", jax_draw, 1)
jax_draw_e = menu:add_checkbox("Draw [E] Range", jax_draw, 1)
jax_draw_ward = menu:add_checkbox("Draw [Ward] Range", jax_draw, 1)
jax_draw_flash = menu:add_checkbox("Draw [Flash Combo] Max Range", jax_draw, 1)
jax_gap_draw = menu:add_checkbox("Draw Toggle Auto [Stun] Gap Closer", jax_draw, 1)
jax_qturret_draw = menu:add_checkbox("Draw [Q] Target Under Turret Toggle Enabled", jax_draw, 1)
jax_draw_kill = menu:add_checkbox("Draw [Full Combo [Can Kill] Text]", jax_draw, 1)
jax_draw_kill_healthbar = menu:add_checkbox("Draw [Full Combo Damage] On Target Health Bar", jax_draw, 1)


-- Casting

local function CastQ(unit)
	origin = unit.origin
	x, y, z = origin.x, origin.y, origin.z
	spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
end

local function CastW()
	spellbook:cast_spell(SLOT_W, W.delay, x, y, z)
end

local function CastE()
	spellbook:cast_spell(SLOT_E, E.delay, x, y, z)
end

local function CastR()
	spellbook:cast_spell(SLOT_R, R.delay, x, y, z)
end

-- Combo

local function Combo()

	target = selector:find_target(Q.range, mode_health)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_value(jax_combo_use_e) == 1 and not JaxHasE1() and menu:get_toggle_state(jax_combo_qturret) and not IsUnderTurret(target) then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    CastE()
	 	end
 	end

	if menu:get_value(jax_combo_use_e) == 1 and not JaxHasE1() and not menu:get_toggle_state(jax_combo_qturret) then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    CastE()
	 	end
 	end

	if menu:get_value(jax_combo_use_e) == 1 and not JaxHasE1() then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
			CastE()
		end
	end

	if menu:get_value(jax_combo_use_q) == 1 and menu:get_toggle_state(jax_combo_qturret) and not IsUnderTurret(target) then
	  if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(jax_combo_use_q) == 1 and menu:get_value(jax_combo_use_q_aa) == 0 and menu:get_toggle_state(jax_combo_qturret) and not IsUnderTurret(target) then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
			if not orbwalker:can_attack() then
				CastQ(target)
			end
		end
	end

	if menu:get_value(jax_combo_use_q) == 1 and not menu:get_toggle_state(jax_combo_qturret) then
	  if myHero:distance_to(target.origin) <= Q.range and myHero:distance_to(target.origin) > TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(jax_combo_use_q) == 1 and menu:get_value(jax_combo_use_q_aa) == 0 and not menu:get_toggle_state(jax_combo_qturret) then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
			if not orbwalker:can_attack() then
				CastQ(target)
			end
		end
	end

	if menu:get_value(jax_combo_use_w) == 1 then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
			if not orbwalker:can_attack() then
				CastW()
			end
		end
	end
end

local function FlashEngageCombo()

	target = selector:find_target(QFlash.range, mode_health)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if orbwalker:can_attack() and orbwalker:can_move() then
		if myHero:distance_to(target.origin) < TrueAARange then
			orbwalker:attack_target(target)
		end
	end


	if game:is_key_down(menu:get_value(jax_combo_flash_key)) and FullComboManReady() then
		if myHero:distance_to(target.origin) <= QFlash.range and myHero:distance_to(target.origin) > Q.range and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
			if ml.IsValid(target) and IsKillable(target) and not JaxHasE1() then
		    CastE()
				FlashCombo = true
		 	end
	 	end

		if FlashCombo and JaxHasE1() then
			origin = target.origin
			x, y, z = origin.x, origin.y, origin.z

			if IsFlashSlotD() and ml.Ready(SLOT_D) then
				spellbook:cast_spell(SLOT_D, 0.1, x, y, z)
				Flash = true
			elseif IsFlashSlotF() and ml.Ready(SLOT_F) then
				spellbook:cast_spell(SLOT_F, 0.1, x, y, z)
				Flash = true
			end
		end

		if Flash then
		  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and ml.Ready(SLOT_Q) then
		    CastQ(target)
		 	end
	 	end

		if Flash and not ml.Ready(SLOT_Q) then
			if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
				if not orbwalker:can_attack() then
					CastW()
				end
			end
		end
	end
end

--Harass

local function Harass()

	target = selector:find_target(Q.range, mode_health)
	local TrueAARange = myHero.attack_range + myHero.bounding_radius

	if menu:get_value(jax_harass_use_e) == 1 and not JaxHasE1() then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) then
	    CastE()
	 	end
 	end

	if menu:get_value(jax_harass_use_e) == 1 and not JaxHasE1() then
		if myHero:distance_to(target.origin) <= E.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_E) then
			CastE()
		end
	end

	if menu:get_value(jax_harass_use_q) == 1 then
	  if myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
	    CastQ(target)
	 	end
 	end

	if menu:get_value(jax_harass_use_q) == 1 then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_Q) then
			if not orbwalker:can_attack() then
				CastQ(target)
			end
		end
	end

	if menu:get_value(jax_harass_use_w) == 1 then
		if myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_W) then
			if not orbwalker:can_attack() then
				CastW()
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	for i, target in ipairs(ml.GetEnemyHeroes()) do

		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= Q.range and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(jax_ks_use_q) == 1 then
				if GetQDmg(target) > target.health then
					if ml.Ready(SLOT_Q) then
						CastQ(target)
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(jax_ks_use_w) == 1 then
				if GetWDmg(target) > target.health then
					if ml.Ready(SLOT_W) then
						CastW()
					end
				end
			end
		end

		if target.object_id ~= 0 and myHero:distance_to(target.origin) <= TrueAARange and ml.IsValid(target) and IsKillable(target) then
			if menu:get_value(jax_ks_use_e) == 1 then
				if GetEDmg(target) > target.health then
					if ml.Ready(SLOT_E) then
						CastE()
					end
					if JaxHasE1() and ml.Ready(SLOT_E) then
						CastE()
					end
				end
			end
		end
	end
end

-- Lane Clear

local function Clear()

	local GrabLaneClearMana = myHero.mana/myHero.max_mana >= menu:get_value(jax_laneclear_min_mana) / 100

	minions = game.minions
	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650
		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(jax_laneclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < Q.range then
				if GrabLaneClearMana and ml.Ready(SLOT_Q) and TargetNearMouse then
					CastQ(target)
				end
			end
		end

		if menu:get_value(jax_laneclear_use_w) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < TrueAARange then
				if GrabLaneClearMana and ml.Ready(SLOT_W) and TargetNearMouse then
					if not orbwalker:can_attack() then
						CastW()
					end
				end
			end
		end

		if menu:get_value(jax_laneclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and ml.Ready(SLOT_E) then
				if GetMinionCount(E.range, myHero) >= menu:get_value(jax_laneclear_min_e) and not JaxHasE1() then
					CastE()
				end
				if GetMinionCount(E.range, myHero) >= menu:get_value(jax_laneclear_min_e) and JaxHasE1() then
					CastE()
				end
			end
		end
	end
end

-- Jungle Clear

	local function JungleClear()

	local GrabJungleClearMana = myHero.mana/myHero.max_mana >= menu:get_value(jax_jungleclear_min_mana) / 100
	minions = game.jungle_minions

	for i, target in ipairs(minions) do
		local TargetNearMouse = target:distance_to(game.mouse_pos) <= 650
		local TrueAARange = myHero.attack_range + myHero.bounding_radius

		if menu:get_value(jax_jungleclear_use_q) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < 650 and ml.Ready(SLOT_Q) then
				if GrabJungleClearMana and TargetNearMouse then
					CastQ(target)
				end
			end
		end

		if menu:get_value(jax_jungleclear_use_w) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < TrueAARange then
				if not orbwalker:can_attack() then
					if GrabJungleClearMana and ml.Ready(SLOT_W) and TargetNearMouse then
						CastW()
					end
				end
			end
		end

		if menu:get_value(jax_jungleclear_use_e) == 1 then
			if ml.IsValid(target) and target.object_id ~= 0 and target.is_enemy and myHero:distance_to(target.origin) < E.range and ml.Ready(SLOT_E) then
				if GrabJungleClearMana and TargetNearMouse and not JaxHasE1() then
					CastE()
				end
				if GrabJungleClearMana and TargetNearMouse and JaxHasE1() then
					CastE()
				end
			end
		end
	end
end

-- Auto R

local function AutoR()

  if menu:get_value(jax_extra_r_number_use) == 1 then
		if ml.IsValid(target) and ml.Ready(SLOT_R) and myHero:health_percentage() <= menu:get_value(jax_extra_r_number_hp) then
			if GetEnemyCount(500, myHero) >= menu:get_value(jax_extra_r_number_count) then
				CastR()
			end
    end
  end
end

-- Auto E

local function AutoE()

  if menu:get_value(jax_extra_e_number_use) == 1 then
		if ml.IsValid(target) and ml.Ready(SLOT_E) then
			if GetEnemyCount(E.range, myHero) >= menu:get_value(jax_extra_e_number_count) then
				if JaxHasE1() then
					CastE()
				end
			end
    end
  end
end

-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(jax_extra_gapclose) then
		if ml.IsValid(obj) then
			if menu:get_value_string("Gap Closer Escape Whitelist: "..tostring(obj.champ_name)) == 1 then
				if myHero:distance_to(obj.origin) < E.range and myHero:distance_to(dash_info.end_pos) >= E.range and ml.Ready(SLOT_E) and JaxHasE1() then
					CastE()
				end
			end
		end
	end
end

-- Interrupt

local function on_possible_interrupt(obj, spell_name)

	if ml.IsValid(obj) then
		if menu:get_value(jax_extra_interrupt) == 1 then
			if menu:get_value_string("Interrupt Whitelist: "..tostring(obj.champ_name)) == 1 then
		   	if myHero:distance_to(obj.origin) < E.range and ml.Ready(SLOT_E) and JaxHasE1() then
					CastE()
				end
			end
		end
	end
end

-- R Save me

local function RSaveMe()

  target = selector:find_target(Q.range, mode_distance)

	local SaveMeHP = myHero.health/myHero.max_health <= menu:get_value(jax_extra_saveme_myhp) / 100
	local TargetHP = target.health/target.max_health >= menu:get_value(jax_extra_saveme_target) / 100

	if menu:get_value(jax_extra_saveme) == 1 then
    if myHero:distance_to(target.origin) < 500 then
			if myHero:distance_to(target.origin) < target.attack_range then
				if SaveMeHP and TargetHP then
					if target:is_facing(myHero) then
						if ml.IsValid(target) and IsKillable(target) and ml.Ready(SLOT_R) then
							CastR()
						end
					end
				end
			end
    end
  end
end

local function Flee()

	local control_ward, control_ward_slot = ControlWardCheck()
	local wards = game.wards
	local players = game.players
	local minions = game.minions
	local jungles = game.jungle_minions

	for _, ally in ipairs(players) do
		for _, minion in ipairs(minions) do
			for _, jungle in ipairs(jungles) do
				if myHero:distance_to(ally.origin) <= Q.range and ally:distance_to(game.mouse_pos) <= 100 and ml.Ready(SLOT_Q) and ally.object_id ~= myHero.object_id then
					origin = ally.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					Blockward = true
				end
				if myHero:distance_to(minion.origin) <= Q.range and minion:distance_to(game.mouse_pos) <= 100 and ml.Ready(SLOT_Q) then
					origin = minion.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					Blockward = true
				end
				if myHero:distance_to(jungle.origin) <= Q.range and jungle:distance_to(game.mouse_pos) <= 100 and ml.Ready(SLOT_Q) then
					origin = jungle.origin
					x, y, z = origin.x, origin.y, origin.z
					spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
					Blockward = true
				end
			end
		end
	end

	for _, ward in ipairs(wards) do
		if not Blockward and ml.Ready(SLOT_Q) and ward and ward:distance_to(game.mouse_pos) <= 100 then
			if ward:distance_to(myHero.origin) <= Q.range then
				origin = ward.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
			end
		end
	end

	if game:is_key_down(menu:get_value(jax_extra_flee_key)) then
		if not Blockward and ml.Ready(SLOT_Q) and ml.Ready(SLOT_WARD) or control_ward then
			FleeReady = true
		end
	end

	if FleeReady and not flee_Wfire and control_ward and control_ward_slot then
		if not ml.Ready(SLOT_WARD) or SweeperCheck() then
			if myHero:distance_to(game.mouse_pos) <= Ward.range and ml.Ready(SLOT_Q) then
				spellbook:cast_spell(control_ward_slot, 0.25, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
				if not ml.Ready(control_ward_slot) then
					flee_Wfire = true
				end
			end
		end
	end

	if FleeReady and not flee_Wfire and not SweeperCheck() then
		if myHero:distance_to(game.mouse_pos) <= Ward.range and ml.Ready(SLOT_Q) then
			spellbook:cast_spell(SLOT_WARD, Q.delay, game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z)
			if not ml.Ready(SLOT_WARD) then
				flee_Wfire = true
			end
		end
	end

	for _, ward in ipairs(wards) do
		if FleeReady and flee_Wfire and ml.Ready(SLOT_Q) then
			if myHero:distance_to(ward.origin) <= Q.range and ward:distance_to(game.mouse_pos) <= 100 then
				origin = ward.origin
				x, y, z = origin.x, origin.y, origin.z
				spellbook:cast_spell(SLOT_Q, Q.delay, x, y, z)
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


	if menu:get_value(jax_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(jax_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(jax_draw_ward) == 1 then
		renderer:draw_circle(x, y, z, Ward.range, 255, 0, 255, 255)
	end

	if menu:get_value(jax_draw_flash) == 1 then
		renderer:draw_circle(x, y, z, QFlash.range, 0, 255, 255, 255)
	end

	if menu:get_toggle_state(jax_extra_gapclose) then
		if menu:get_value(jax_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [E2] Gap Closer Escape Enabled")
		end
	end

	if menu:get_toggle_state(jax_combo_qturret) then
		if menu:get_value(jax_qturret_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 20, "Toggle [Q] Target Under Turret Enabled")
		end
	end

	for i, target in ipairs(ml.GetEnemyHeroes()) do
		local fulldmg = GetQDmg(target) + GetEDmg(target) + GetWDmg(target)
		if ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and target.object_id ~= 0 and myHero:distance_to(target.origin) <= 1500 then
			if menu:get_value(jax_draw_kill) == 1 and target.is_on_screen then
				if fulldmg > target.health and ml.IsValid(target) then
					if enemydraw.is_valid then
						renderer:draw_text_big_centered(enemydraw.x, enemydraw.y, "Can Kill Target!")
					end
				end
			end
		end

		if ml.IsValid(target) and menu:get_value(jax_draw_kill_healthbar) == 1 then
			target:draw_damage_health_bar(fulldmg)
		end
	end
end

local function on_tick()

	if game:is_key_down(menu:get_value(jax_combokey)) and menu:get_value(jax_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if combo:get_mode() == MODE_LANECLEAR then
		Clear()
		JungleClear()
	end

	if game:is_key_down(menu:get_value(jax_extra_flee_key)) then
		Flee()
		orbwalker:move_to()
	end

	if not game:is_key_down(menu:get_value(jax_extra_flee_key)) then
		FleeReady = false
		flee_Wfire = false
		control_ward = false
		control_ward_slot = nil
		Blockward = false
	end

	if not game:is_key_down(menu:get_value(jax_combo_flash_key)) then
		FlashCombo = false
		Flash = false
	end

	if game:is_key_down(menu:get_value(jax_combo_flash_key)) then
		FlashEngageCombo()
		orbwalker:move_to()
	end

	AutoE()
	AutoR()
	AutoKill()
	RSaveMe()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
