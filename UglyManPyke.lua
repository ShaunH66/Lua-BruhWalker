if game.local_player.champ_name ~= "Pyke" then
	return
end

--[[do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "UglyManPyke.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/UglyManPyke.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/UglyManPyke.lua.version.txt")
        console:log("UglyManPyke.lua Vers: "..Version)
		console:log("UglyManPyke.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("....................................................................................")
            console:log("............Shaun's UglyMan Pyke Successfully Loaded............")
						console:log("....................................................................................")
        else
			http:download_file(url, file_name)
			      console:log("UglyManPyke Update available.....")
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

local function MyHeroQCharge()
	if myHero:has_buff("PykeQ") then
		return true
	end
	return false
end

local function TargetQBuff(unit)
	if unit:has_buff("PykeQMelee") then
		return true
	end
	return false
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

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	pyke_category = menu:add_category_sprite("Shaun's UglyMan Pyke", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	pyke_category = menu:add_category("Shaun's UglyMan Pyke")
end

pyke_enabled = menu:add_checkbox("Enabled", pyke_category, 1)
pyke_combokey = menu:add_keybinder("Combo Mode Key", pyke_category, 32)
menu:add_label("Shaun's UglyMan Pyke", pyke_category)
menu:add_label("#Ugly & Pykey", pyke_category)

manual_r = menu:add_subcategory("Semi Manual [R] Settings", pyke_category)
pyke_combo_r_set_key = menu:add_keybinder("Semi Manual [R] Key", manual_r, 65)
e_table = {}
e_table[1] = "Lowest Target Health"
e_table[2] = "Closest To Cursor"
target_selection = menu:add_combobox("[Target Selection]", manual_r, e_table, 0)

pyke_ark_pred = menu:add_subcategory("[Pred Settings]", pyke_category)
pyke_q_hitchance = menu:add_slider("[Q] Hit Chance [%]", pyke_ark_pred, 1, 99, 50)
pyke_e_hitchance = menu:add_slider("[E] Hit Chance [%]", pyke_ark_pred, 1, 99, 50)
pyke_r_hitchance = menu:add_slider("[R] Hit Chance [%]", pyke_ark_pred, 1, 99, 50)

pyke_ks_function = menu:add_subcategory("[Kill Steal]", pyke_category)
pyke_ks_q = menu:add_subcategory("[Q] Settings", pyke_ks_function, 1)
pyke_ks_use_q = menu:add_checkbox("Use [Q]", pyke_ks_q, 1)
pyke_ks_r = menu:add_subcategory("[R] Settings", pyke_ks_function, 1)
pyke_ks_use_r = menu:add_checkbox("Use [R]", pyke_ks_r, 1)
pyke_ks_use_combo_r = menu:add_checkbox("Use Smart Combo [R]", pyke_ks_r, 1)
pyke_ks_r_blacklist = menu:add_subcategory("[R] Kill Steal Whitelist", pyke_ks_r)
local players = game.players
for _, t in pairs(players) do
    if t and t.is_enemy then
        menu:add_checkbox("Use [R] Kill Steal On: "..tostring(t.champ_name), pyke_ks_r_blacklist, 1)
    end
end

pyke_combo = menu:add_subcategory("[Combo]", pyke_category)
pyke_combo_q = menu:add_subcategory("[Q] Settings", pyke_combo)
pyke_combo_use_q = menu:add_checkbox("Use [Q]", pyke_combo_e, 1)
pyke_combo_e = menu:add_subcategory("[E] Settings", pyke_combo)
pyke_combo_use_e = menu:add_checkbox("Use [E]", pyke_combo_e, 1)

pyke_harass = menu:add_subcategory("[Harass]", pyke_category)
pyke_harass_q = menu:add_subcategory("[Q] Settings", pyke_harass)
pyke_harass_use_q = menu:add_checkbox("Use [Q]", pyke_harass_q, 1)
pyke_harass_e = menu:add_subcategory("[E] Settings", pyke_harass)
pyke_harass_use_e = menu:add_checkbox("Use [E]", pyke_harass_w, 1)
pyke_harass_min_mana = menu:add_slider("Minimum Mana [%] To Harass", pyke_harass, 1, 100, 20)

pyke_extra_gap = menu:add_subcategory("[E] Anti Gap Closer", pyke_category)
pyke_extra_gapclose = menu:add_toggle("[E] Toggle Anti Gap Closer key", 1, pyke_extra_gap, 84, true)
pyke_extra_gapclose_blacklist = menu:add_subcategory("[E] Anti Gap Closer Champ Whitelist", pyke_extra_gap)
local players = game.players
for _, p in pairs(players) do
    if p and p.is_enemy then
        menu:add_checkbox("Anti Gap Closer Whitelist: "..tostring(p.champ_name), pyke_extra_gapclose_blacklist, 1)
    end
end

pyke_extra_int = menu:add_subcategory("[E] Interrupt Channels", pyke_category, 1)
pyke_extra_interrupt = menu:add_checkbox("Use [E] Interrupt Major Channel Spells", pyke_extra_int, 1)
pyke_extra_interrupt_blacklist = menu:add_subcategory("[E] Interrupt Champ Whitelist", pyke_extra_int)
local players = game.players
for _, v in pairs(players) do
    if v and v.is_enemy then
        menu:add_checkbox("Interrupt Whitelist: "..tostring(v.champ_name), pyke_extra_interrupt_blacklist, 1)
    end
end

pyke_draw = menu:add_subcategory("[Drawing] Features", pyke_category)
pyke_draw_q = menu:add_checkbox("Draw [Q] Range", pyke_draw, 1)
pyke_draw_e = menu:add_checkbox("Draw [E] Range", pyke_draw, 1)
pyke_draw_r = menu:add_checkbox("Draw [R] Range", pyke_draw, 1)
pyke_gap_draw = menu:add_checkbox("Draw Toggle Auto [E] Gap Closer", pyke_draw, 1)
pyke_draw_kill = menu:add_checkbox("Draw Full Combo Can Kill Text", pyke_draw, 1)
pyke_draw_kill_healthbar = menu:add_checkbox("Draw Full Combo On Target Health Bar", pyke_draw, 1)

-- Ranges

local Q = { range = 1000, delay = .25, radius = 70, speed = 1700 }
local W = { delay = .1 }
local E = { range = 550, delay = .25, radius = 65, speed = 500 }
local R = { range = 750, delay = .0.5, radius = 250, speed = 1000 }

local E_input = {
		source = myHero,
		speed = E.speed, range = E.range,
		delay = E.delay, radius = E.radius,
		collision = {},
		type = "linear", hitbox = true
}

local R_input = {
    source = myHero,
    speed = R.speed, range = R.range,
    delay = R.delay, radius = R.radius,
    collision = {},
    type = "circular", hitbox = false
}

-- Casting

local function CastE(unit)
	local output = arkpred:get_prediction(E_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(pyke_e_hitchance) / 100 and inv < (E_input.delay / 2) then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_E, E.delay, p.x, p.y, p.z)
	end
end

local function CastR(unit)
	local output = arkpred:get_prediction(R_input, unit)
	local inv = arkpred:get_invisible_duration(unit)
	if output.hit_chance >= menu:get_value(pyke_r_hitchance) / 100 and inv < (R_input.delay / 2) then
		local p = output.cast_pos
		spellbook:cast_spell(SLOT_R, R.delay, p.x, p.y, p.z)
	end
end


-- Combo

local function Combo()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	Charge_buff = local_player:get_buff("PykeQ")
	if Charge_buff.is_valid then
		local diff = game.game_time - Charge_buff.start_time
	  if diff <= 0.4 then
	    diff = 0
	  else
	    diff = diff - 0.4
	  end
	  local range1 = 400 + ((116.67 / 0.1) * diff)
	  if range1 > 1100 then
	     range1 = 1100
	  end

		target = selector:find_target(range1, mode_health)
		if target.object_id ~= 0 then
			if ml.Ready(SLOT_Q) and IsValid(target) then
				local Q_input = {
				    source = myHero,
				    speed = Q.speed, range = range1,
				    delay = Q.delay, radius = Q.radius,
						collision = {"minion", "wind_wall"},
				    type = "linear", hitbox = true
				}
				local output = arkpred:get_prediction(Q_input, target)
			  local inv = arkpred:get_invisible_duration(target)
				if output.hit_chance >= menu:get_value(pyke_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
					local p = output.cast_pos
					spellbook:release_charged_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
				end
			end
		end
	else
		if menu:get_value(pyke_combo_use_q) == 1 then
			target = selector:find_target(Q.range, mode_health)
			if target.object_id ~= 0 then
				if ml.Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end
	end

	if menu:get_value(pyke_combo_use_e) == 1 then
		if ml.IsValid(etarget) and IsKillablee(etarget) and not MyHeroQCharge() then
			if myHero:distance_to(etarget.origin) <= E.range then
				if myHero:distance_to(etarget.origin) > 100 and myHero:distance_to(etarget.origin) <= 400 then
					if ml.Ready(SLOT_E) then
						CastE(etarget)
					end
				end
			end
		end
	end
end

--Harass

local function Harass()

	local GrabHarassMana = myHero.mana/myHero.max_mana >= menu:get_value(pyke_harass_min_mana) / 100

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	qtarget = selector:find_target(Q.range, mode_health)
	etarget = selector:find_target(E.range, mode_health)

	Charge_buff = local_player:get_buff("PykeQ")
	if Charge_buff.is_valid then
		local diff = game.game_time - Charge_buff.start_time
	  if diff <= 0.4 then
	    diff = 0
	  else
	    diff = diff - 0.4
	  end
	  local range1 = 400 + ((116.67 / 0.1) * diff)
	  if range1 > 1100 then
	     range1 = 1100
	  end

		target = selector:find_target(range1, mode_health)
		if target.object_id ~= 0 then
			if ml.Ready(SLOT_Q) and IsValid(target) then
				local Q_input = {
				    source = myHero,
				    speed = Q.speed, range = range1,
				    delay = Q.delay, radius = Q.radius,
						collision = {"minion", "wind_wall"},
				    type = "linear", hitbox = true
				}
				local output = arkpred:get_prediction(Q_input, target)
			  local inv = arkpred:get_invisible_duration(target)
				if output.hit_chance >= menu:get_value(pyke_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
					local p = output.cast_pos
					spellbook:release_charged_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
				end
			end
		end
	else
		if menu:get_value(pyke_harass_use_q) == 1 and GrabHarassMana then
			target = selector:find_target(Q.range, mode_health)
			if target.object_id ~= 0 then
				if ml.Ready(SLOT_Q) then
					spellbook:start_charged_spell(SLOT_Q)
				end
			end
		end
	end

	if menu:get_value(pyke_harass_use_e) == 1 and GrabHarassMana and not MyHeroQCharge() then
		if ml.IsValid(etarget) and IsKillablee(etarget) then
			if myHero:distance_to(etarget.origin) <= E.range then
				if myHero:distance_to(etarget.origin) > 100 and myHero:distance_to(etarget.origin) <= 400 then
					if ml.Ready(SLOT_E) then
						CastE(etarget)
					end
				end
			end
		end
	end
end

-- KillSteal

local function AutoKill()

	local TrueAA = myHero.attack_range + myHero.bounding_radius
	for i, target in ipairs(ml.GetEnemyHeroes()) do

		Charge_buff = local_player:get_buff("PykeQ")
		if Charge_buff.is_valid then
			local diff = game.game_time - Charge_buff.start_time
		  if diff <= 0.4 then
		    diff = 0
		  else
		    diff = diff - 0.4
		  end
		  local range1 = 400 + ((116.67 / 0.1) * diff)
		  if range1 > 1100 then
		     range1 = 1100
		  end

			target = selector:find_target(range1, mode_health)
			if target.object_id ~= 0 then
				if ml.Ready(SLOT_Q) and IsValid(target) then
					local Q_input = {
					    source = myHero,
					    speed = Q.speed, range = range1,
					    delay = Q.delay, radius = Q.radius,
							collision = {"minion", "wind_wall"},
					    type = "linear", hitbox = true
					}
					local output = arkpred:get_prediction(Q_input, target)
				  local inv = arkpred:get_invisible_duration(target)
					if output.hit_chance >= menu:get_value(pyke_q_hitchance) / 100 and inv < (Q_input.delay / 2) then
						local p = output.cast_pos
						spellbook:release_charged_spell(SLOT_Q, Q.delay, p.x, p.y, p.z)
					end
				end
			end
		else
			if menu:get_value(pyke_ks_use_q) == 1 and GetQDmg(target) > target.health then
				target = selector:find_target(Q.range, mode_health)
				if target.object_id ~= 0 then
					if ml.Ready(SLOT_Q) then
						spellbook:start_charged_spell(SLOT_Q)
					end
				end
			end
		end

		if menu:get_value(pyke_ks_use_r) == 1 then
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

-- Manual R

local function ManualRCast()


	if menu:get_value(target_selection) == 0 then
		target = selector:find_target(R.range, mode_health)
		if myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
		end
	end

	if menu:get_value(target_selection) == 1 then
		target = selector:find_target(R.range, mode_cursor)
		if myHero:distance_to(target.origin) <= R.range then
			if Ready(SLOT_R) and ml.IsValid(target) and IsKillable(target) then
				CastR(target)
			end
		end
	end
end


-- Gap Close

local function on_dash(obj, dash_info)

	if menu:get_toggle_state(pyke_extra_gapclose) then
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
    if menu:get_value(pyke_extra_interrupt) == 1 then
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

	if myHero.object_id ~= 0 then
		origin = myHero.origin
		x, y, z = origin.x, origin.y, origin.z
	end


	if menu:get_value(pyke_draw_q) == 1 then
		if ml.Ready(SLOT_Q) then
			renderer:draw_circle(x, y, z, Q.range, 255, 255, 255, 255)
		end
	end

	if menu:get_value(pyke_draw_e) == 1 then
		if ml.Ready(SLOT_E) then
			renderer:draw_circle(x, y, z, E.range, 255, 255, 0, 255)
		end
	end

	if menu:get_value(pyke_draw_r) == 1 then
		if ml.Ready(SLOT_R) then
			renderer:draw_circle(x, y, z, R.range, 255, 0, 0, 255)
		end
	end

	if menu:get_toggle_state(pyke_extra_gapclose) then
		if menu:get_value(pyke_gap_draw) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Toggle Auto [E] Gap Closer Enabled")
		end
	end

end

local function on_tick()

	if game:is_key_down(menu:get_value(pyke_combokey)) and menu:get_value(pyke_enabled) == 1 then
		Combo()
	end

	if combo:get_mode() == MODE_HARASS then
		Harass()
	end

	if game:is_key_down(menu:get_value(pyke_combo_r_set_key)) then
		ManualRCast()
		orbwalker:move_to()
	end

	AutoKill()

end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_dash", on_dash)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
