if game.local_player.champ_name ~= "Ezreal" then
	return
end

UpdateDraw = false
local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark Prediction Library Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end

local file_name = "Evade.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Evade.lua"
   http:download_file(url, file_name)
   console:log("Ark Evade Downloaded")
   console:log("Please Reload with F5")
   UpdateDraw = true
end

if not file_manager:file_exists("PKDamageLib.lua") then
	local file_name = "PKDamageLib.lua"
	local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"
	http:download_file(url, file_name)
	UpdateDraw = true
end

if not file_manager:file_exists("ShaunPrediction.lua") then
	local file_name = "ShaunPrediction.lua"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ShaunPrediction.lua"
	http:download_file(url, file_name)
	UpdateDraw = true
end

do
    local function AutoUpdate()
		local Version = 3.1
		local file_name = "ProPlay-Ezreal.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Ezreal.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/ProPlay-Ezreal.lua.version.txt")
        console:log("ProPlay-Ezreal.Lua Vers: "..Version)
		console:log("ProPlay-Ezreal.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
			console:log("ProPlay Ezreal Successfully Loaded..")
        else
			http:download_file(url, file_name)
			console:log("ProPlay Ezreal Update Available..")
			UpdateDraw = true
        end
    end
    AutoUpdate()
end

pred:use_prediction()
require "PKDamageLib"
require "DreamPred"
--require "DynastyPred"
DreamTS = require("DreamTS")
--ShaunTS = require("Shaunyboi-TS")
ShaunPred = require "ShaunPrediction"
arkpred = _G.Prediction
myHero = game.local_player
screen_size = game.screen_size

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:directory_exists("Shaun's Sexy Common") then
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	ezreal_category = menu:add_category_sprite("Shaun's ProPlay Ezreal", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	ezreal_category = menu:add_category("Shaun's ProPlay Ezreal")
end

ezreal_enabled = menu:add_checkbox("Enabled", ezreal_category, 1)
q_nocol_toggle = menu:add_toggle("Toggle [Q] No Collision Check", 1, ezreal_category, 65, false)
semi_manual_r = menu:add_keybinder("Semi Manual [R] Key - Closest To Cursor", ezreal_category, 90)

pred_settings = menu:add_subcategory("Prediction Selection & Settings", ezreal_category)
pred_table = {}
pred_table[1] = "Dream Prediction"
pred_table[2] = "Ark Prediction"
pred_table[3] = "Shaun Prediction"
prediction_choice = menu:add_dropdown("Pred Selection", pred_settings, pred_table, 0)

shaun_pred = menu:add_subcategory("Shaun Pred Hit Chance", pred_settings)
shaun_pred_hitchance = menu:add_slider("Hit Chance", shaun_pred, 1, 100, 40)

dream_pred_hc = menu:add_subcategory("Dream Pred Hit Chance", pred_settings)
p_castrate = {}
p_castrate[1] = "Slow Cast Rate"
p_castrate[2] = "Fast Cast Rate"
p_castrate[3] = "Very Slow"
p_rate = menu:add_dropdown("Cast Rate Selection", dream_pred_hc, p_castrate, 0)

ark_pred_hc = menu:add_subcategory("Ark Pred Hit Chance", pred_settings)
hitchance_q = menu:add_slider("[Q] Hit Chance %", ark_pred_hc, 1, 100, 50)
hitchance_w = menu:add_slider("[W] Non Collision Hit Chance %", ark_pred_hc, 1, 100, 50)
hitchance_w_col = menu:add_slider("[W] Collision Hit Chance %", ark_pred_hc, 1, 100, 70)

TS =
   DreamTS(
	ezreal_category,
   {
        Damage = DreamTS.Damages.AD
   }
)

spells = menu:add_subcategory("Spell Options", ezreal_category)
q_harass = menu:add_checkbox("Use [Q] Harass", spells, 1)
q_laneclear = menu:add_checkbox("Use [Q] In Lane Clear", spells, 1)
q_laneclear_harass = menu:add_checkbox("Target Enemies While In Last Hit Lane Clear Mode", spells, 1)
menu:add_label("Holding Mouse 1 = Fast Clear", spells)
menu:add_label("Not Holding Mouse 1 = Last Hit",spells)
q_jungleclear = menu:add_checkbox("Use [Q] + [W] Jungle Clear", spells, 1)
w_level = menu:add_slider("Start Using [W] >= Level", spells, 0, 18, 0)
w_aa_overkill = menu:add_slider("Number Of [AA] To Consider To Stop Using [W] In Overkill Calculations", spells, 0, 10, 3)
draws = menu:add_subcategory("Drawing Options", ezreal_category)
q_draw = menu:add_checkbox("Draw [Q] Range", draws, 1)
draw_prediction_choice = menu:add_checkbox("Draw Prediction Selection Text", draws, 1)

local function Ready(spell)
  return spellbook:can_cast(spell)
end

local function EpicMonster(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder"
		or unit.champ_name == "SRU_Dragon_Chemtech"
		or unit.champ_name == "SRU_Dragon_Hextech" then
		return true
	else
		return false
	end
end

function ValidTarget(object, distance)
    return object and object.is_valid and object.is_enemy and
    not object:has_buff("SionPassiveZombie") and
    not object:has_buff("FioraW") and
    not object:has_buff("sivire") and
    not object:has_buff("nocturneshroudofdarkness") and
    object.is_alive and not object:has_buff_type(18) and
    (not distance or object:distance_to(myHero.origin) <= distance)
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

q = {
    source = myHero,
    speed = 2000, range = 1180,
    delay = 0.25, radius = 60,
    collision = {"minion", "wind_wall", "enemy_hero"},
    type = "linear", hitbox = true
}

q_nocol = {
    source = myHero,
    speed = 2000, range = 1180,
    delay = 0.25, radius = 60,
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

w = {
    source = myHero,
	speed = 1700, range = 1000,
    delay = 0.25, radius = 70,
    collision = {"minion", "wind_wall", "enemy_hero"},
    type = "linear", hitbox = true
}

w_nocol = {
    source = myHero,
	speed = 1700, range = 1000,
    delay = 0.25, radius = 70,
    collision = {"wind_wall", "enemy_hero"},
    type = "linear", hitbox = true
}

QDream = {
	type = "linear",
	delay = 0.25,
	speed = 2000,
	range = 1180,
	width = 120,
	collision = {
		["Wall"] = true,
		["Hero"] = true,
		["Minion"] = true
	},
}

QDream_nocol = {
	type = "linear",
	delay = 0.25,
	speed = 2000,
	range = 1180,
	width = 120,
	collision = {
		["Wall"] = true,
		["Hero"] = false,
		["Minion"] = false
	},
}


WDream = {
	type = "linear",
	delay = 0.25,
	speed = 1700,
	range = 1000,
	width = 140,
	collision = {
		["Wall"] = true,
		["Hero"] = true,
		["Minion"] = true
	},
}

WDream_nocol = {
	type = "linear",
	delay = 0.25,
	speed = 1700,
	range = 1000,
	width = 140,
	collision = {
		["Wall"] = true,
		["Hero"] = true,
		["Minion"] = false
	},
}

RDream = {
	type = "linear",
	delay = 1,
	speed = 2000,
	range = 8000,
	width = 320,
	collision = {
		["Wall"] = true,
		["Hero"] = false,
		["Minion"] = false
	},
}

firstload = false
local gametimegrab = game.game_time + 20
local function on_draw()

	if not menu:get_value(ezreal_enabled) == 1 then return end

	if UpdateDraw then
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2, "ProPlay Ezreal Update Available... Press F5")
	end	

	if myHero.is_on_screen and not UpdateDraw and not firstload then
		local countdown = gametimegrab - game.game_time
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2, "Lane Clear Mouse Toggle Options")
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2 + 40, "Holding Mouse 1 = Fast Lane")
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2 + 80, "Not Holding Mouse 1 = Last Hit")
		renderer:draw_text_big_centered(screen_size.width / 2, screen_size.height / 2 + 120 , tostring(math.floor(countdown)))
		if game.game_time > gametimegrab then
			firstload = true
		end
	 end

	if myHero.is_alive then
		if menu:get_value(q_draw) == 1 and Ready(SLOT_Q) then
			renderer:draw_circle(myHero.origin.x, myHero.origin.y, myHero.origin.z, 1150, 255, 255, 255, 255)
		end
	end

	if menu:get_value(draw_prediction_choice) == 1 then
		if menu:get_value(prediction_choice) == 0 then
			if menu:get_value(p_rate) == 1 then
				renderer:draw_text_centered(screen_size.width / 2, 0, "Using Dream Pred")
				renderer:draw_text_centered(screen_size.width / 2, 15, "Fast Spell Cast Selected")
			else
				renderer:draw_text_centered(screen_size.width / 2, 0, "Using Dream Pred")
				renderer:draw_text_centered(screen_size.width / 2, 15, "Slow Spell Cast Selected")
			end
		elseif menu:get_value(prediction_choice) == 1 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Using Ark Pred")
		elseif menu:get_value(prediction_choice) == 2 then
			renderer:draw_text_centered(screen_size.width / 2, 0, "Using Shaun Pred")
		end
	end

    if menu:get_toggle_state(q_nocol_toggle) then
        renderer:draw_text_centered(screen_size.width / 2, 30, "Toggle [Q] No Collision Check Enabled")
    end

	if combo:get_mode() == 3 then
		if not isMouseButtonDown then 
			renderer:add_indicator("Last Hit Lane Clear Active", 255, 255, 255)
		elseif isMouseButtonDown then
			renderer:add_indicator("Fast Hit Lane Clear Active", 255, 255, 255)
		end
	end
end

cast = false
local function weaving()
	cast = true
end

windup_end_time = 0
local function on_process_spell(obj, args)
	if obj == myHero and args.is_autoattack then
		delay = 0.20 + (game.ping / 2000)
		client:delay_action(weaving, delay)
	end

    if obj == myHero and not args.is_autoattack then
        windup_end_time = args.cast_time + args.cast_delay
    end
end

castw_done = false
local function on_cast_done(args)
	if args.spell_name == "EzrealW" then
		castw_done = true
		cast = false
	end
	if args.spell_name == "EzrealQ" then
		castw_done = false
		cast = false
	end
end

isMouseButtonDown = false
function on_wnd_proc(msg, wparam)
    if msg == 513 and wparam == 1 then
        isMouseButtonDown = true
    elseif msg == 514 and wparam == 0 then
        isMouseButtonDown = false
    end
end

local function Check_PredRates(pred)
	if pred then
		if menu:get_value(p_rate) == 0 and pred.rates["slow"] then
			return true
		elseif menu:get_value(p_rate) == 1 and pred.rates["instant"] then
			return true
        elseif menu:get_value(p_rate) == 2 and pred.rates["very slow"] then
			return true
		end
	end
	return false
end

local function SemiManualR()
    local r_target, pred_result = TS:GetTarget(RDream, myHero, nil, nil, TS.Modes["Closest To Mouse"])

    if Ready(SLOT_R) and r_target and ValidTarget(r_target, RDream.range) then
        local rpred = _G.DreamPred.GetPrediction(r_target, RDream, myHero)
        if rpred and Check_PredRates(rpred) then 
            local p = rpred.castPosition
            spellbook:cast_spell(SLOT_R, RDream.delay, p.x, p.y, p.z)
        end
    end
end

q_hc = 0
w_hc = 0
w_hc_col = 0
target_q_output = nil
a = nil
local function on_tick_always()
	if not menu:get_value(ezreal_enabled) == 1 then return end

	m = myHero.mana/myHero.max_mana >= 10 / 100
	hm = myHero.mana/myHero.max_mana >= 20 / 100

	q_hc = menu:get_value(hitchance_q) / 100
	w_hc = menu:get_value(hitchance_w) / 100
	w_hc_col = menu:get_value(hitchance_w_col) / 100
    shaun_hc = menu:get_value(shaun_pred_hitchance) / 100
    target_q_output, preds = TS:GetTarget(QDream, myHero)
    --target_q_output = ShaunTS:SelectTarget(q, true)

	if menu:get_value(prediction_choice) == 1 then
		if target_q_output then
			a = target_q_output
			output_q = arkpred:get_prediction(q, a)
			output_w = arkpred:get_prediction(w, a)
			output_w_nocol = arkpred:get_prediction(w_nocol, a)
			inv_w = arkpred:get_invisible_duration(a)
			inv_q = arkpred:get_invisible_duration(a)
			QDmg = getdmg("Q", a, myHero, 1)
			AADmg = getdmg("AA", a, myHero, 2)
			Overkill_Dmg = QDmg + (AADmg * menu:get_value(w_aa_overkill))
		end

	elseif (menu:get_value(prediction_choice) == 0 or menu:get_value(prediction_choice) == 2) then
		if target_q_output then
			QDmg = getdmg("Q", target_q_output, myHero, 1)
			AADmg = getdmg("AA", target_q_output, myHero, 2)
			Overkill_Dmg = QDmg + (AADmg * menu:get_value(w_aa_overkill))
		end
		a = selector:find_target(1180, mode_health)
		if a then
            output_w_nocol = arkpred:get_prediction(w_nocol, a)
		    inv_w = arkpred:get_invisible_duration(a)
			a_QDmg = getdmg("Q", a, myHero, 1)
			a_AADmg = getdmg("AA", a, myHero, 2)
			a_Overkill_Dmg = a_QDmg + (a_AADmg * menu:get_value(w_aa_overkill))
		end
	end

    local pause_logic = (windup_end_time < game.game_time)
	if Ready(SLOT_W) and combo:get_mode() == 1 and myHero.level >= menu:get_value(w_level) and pause_logic then
		-- IF dream pred enable - Q uses TS pred return, keep TS target for W then recalucate W Pred within Dream pred separately to magnet target
		if menu:get_value(prediction_choice) == 0 then
            if Ready(SLOT_Q) and ValidTarget(target_q_output, WDream.range) and Overkill_Dmg < target_q_output.health then
                if not myHero:is_in_autoattack_range(target_q_output) then
                    local wpred = _G.DreamPred.GetPrediction(target_q_output, WDream, myHero)
                    if wpred and Check_PredRates(wpred) then 
                        local p = wpred.castPosition
                        spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
                    end
                end
            end
			-- Ark Pred for no collision W within Dream Pred if target is in aa range - check for aa for max dps
			if cast and ValidTarget(a, WDream.range) and output_w_nocol.hit_chance >= w_hc and inv_w < 0.125 then
				if a_Overkill_Dmg < a.health and myHero:is_in_autoattack_range(a) then
					local p = output_w_nocol.cast_pos
					spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
				end
			end

		elseif menu:get_value(prediction_choice) == 1 then
			-- Ark Pred Casting
			if Ready(SLOT_Q) and ValidTarget(a, w.range) and Overkill_Dmg < a.health then
				if output_w.hit_chance >= w_hc and inv_w < 0.125 then
					if not myHero:is_in_autoattack_range(a) then
						local p = output_w.cast_pos
						spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
					end
				end
				if cast and output_w_nocol.hit_chance >= w_hc_col and inv_w < 0.125 then
					if myHero:is_in_autoattack_range(a) then
						local p = output_w_nocol.cast_pos
						spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
					end
				end
			end

		elseif menu:get_value(prediction_choice) == 2 then
            -- Shaun Pred Casting
            if Ready(SLOT_Q) and ValidTarget(target_q_output, WDream.range) and Overkill_Dmg < target_q_output.health then
                if not myHero:is_in_autoattack_range(target_q_output) then
                    local wpred = ShaunPred:calculatePrediction(target_q_output, WDream, myHero)
                    if wpred and wpred.hitChance >= shaun_hc then
                        local p = wpred.castPos
                        spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
                    end
                end
            end
			-- Ark Pred for no collision W within Dream Pred if target is in aa range - check for aa for max dps
			if cast and ValidTarget(a, WDream.range) and output_w_nocol.hit_chance >= w_hc and inv_w < 0.125 then
				if a_Overkill_Dmg < a.health and myHero:is_in_autoattack_range(a) then
					local p = output_w_nocol.cast_pos
					spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
				end
			end
        end
	end

    -- Q no col disabled

    local pause_logic = (windup_end_time < game.game_time)
	if Ready(SLOT_Q) and combo:get_mode() == 1 and not menu:get_toggle_state(q_nocol_toggle) and ValidTarget(target_q_output, 1180) and pause_logic then
		-- Dream Pred Casting
		if menu:get_value(prediction_choice) == 0 then
            if not myHero:is_in_autoattack_range(target_q_output) then
                local qpred = _G.DreamPred.GetPrediction(target_q_output, QDream, myHero)
                if qpred and Check_PredRates(qpred) then 
                    local p = qpred.castPosition
                    spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                end
            elseif cast and myHero:is_in_autoattack_range(target_q_output) then
                local qpred = _G.DreamPred.GetPrediction(target_q_output, QDream, myHero)
                if qpred and Check_PredRates(qpred) then 
                    local p = qpred.castPosition
                    spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                end
            end

		elseif menu:get_value(prediction_choice) == 1 then
			-- Ark Pred Casting
			if output_q.hit_chance >= q_hc and inv_q < 0.125 then
				if not myHero:is_in_autoattack_range(a) then
					local p = output_q.cast_pos
					spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
				elseif cast and myHero:is_in_autoattack_range(a) then
					local p = output_q.cast_pos
					spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
				end
			end

		elseif menu:get_value(prediction_choice) == 2 then
            -- Shaun Pred Casting
            if not myHero:is_in_autoattack_range(target_q_output) then
                local qpred = ShaunPred:calculatePrediction(target_q_output, QDream, myHero)
                if qpred and qpred.hitChance >= shaun_hc then
                    local p = qpred.castPos
                    spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                end
            elseif cast and myHero:is_in_autoattack_range(target_q_output) then
                local qpred = ShaunPred:calculatePrediction(target_q_output, QDream, myHero)
                if qpred and qpred.hitChance >= shaun_hc then
                    local p = qpred.castPos
                    spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                end
            end
        end
	end

    -- Q no col enabled

    local pause_logic = (windup_end_time < game.game_time)
    if Ready(SLOT_Q) and combo:get_mode() == 1 and menu:get_toggle_state(q_nocol_toggle) and pause_logic then
        target_q_nocol, preds = TS:GetTarget(QDream_nocol, myHero)
        --target_q_output = ShaunTS:SelectTarget(q, false)
		-- Dream Pred Casting
        if target_q_nocol and ValidTarget(target_q_nocol, 1180) then
            if menu:get_value(prediction_choice) == 0 then
                if not myHero:is_in_autoattack_range(target_q_nocol) then
                    local qpred = _G.DreamPred.GetPrediction(target_q_nocol, QDream_nocol, myHero)
                    if qpred and Check_PredRates(qpred) then 
                        local p = qpred.castPosition
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                elseif cast and myHero:is_in_autoattack_range(target_q_nocol) then
                    local qpred = _G.DreamPred.GetPrediction(target_q_nocol, QDream_nocol, myHero)
                    if qpred and Check_PredRates(qpred) then 
                        local p = qpred.castPosition
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                end

            elseif menu:get_value(prediction_choice) == 1 then
                -- Ark Pred Casting
                output_q_nocol = arkpred:get_prediction(q_nocol, target_q_nocol)
                if output_q_nocol.hit_chance >= q_hc and inv_q < 0.125 then
                    if not myHero:is_in_autoattack_range(target_q_nocol) then
                        local p = output_q_nocol.cast_pos
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    elseif cast and myHero:is_in_autoattack_range(target_q_nocol) then
                        local p = output_q_nocol.cast_pos
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                end

            elseif menu:get_value(prediction_choice) == 2 then
                -- Shaun Pred Casting
                if not myHero:is_in_autoattack_range(target_q_nocol) then
                    local qpred = ShaunPred:calculatePrediction(target_q_output, QDream_nocol, myHero)
                    if qpred and qpred.hitChance >= shaun_hc then
                        local p = qpred.castPos
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                elseif cast and myHero:is_in_autoattack_range(target_q_nocol) then
                    local qpred = ShaunPred:calculatePrediction(target_q_output, QDream_nocol, myHero)
                    if qpred and qpred.hitChance >= shaun_hc then
                        local p = qpred.castPos
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                end
            end
        end
	end

    local pause_logic = (windup_end_time < game.game_time)
	if Ready(SLOT_Q) and combo:get_mode() == 2 and menu:get_value(q_harass) == 1 and hm and not myHero.is_winding_up and pause_logic then
		if menu:get_value(prediction_choice) == 0 then
			if ValidTarget(target_q_output, 1180) then 
				local qpred = _G.DreamPred.GetPrediction(target_q_output, QDream, myHero)
				if qpred and Check_PredRates(qpred) then 
					local p = qpred.castPosition
					spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
				end
			end

		elseif menu:get_value(prediction_choice) == 1 then
			if ValidTarget(a, 1180) and output_q and output_q.hit_chance >= q_hc and inv_q < 0.125 then
				local p = output_q.cast_pos
				spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
			end

		elseif menu:get_value(prediction_choice) == 2 then
            if ValidTarget(target_q_output, 1180) then 
                local qpred = ShaunPred:calculatePrediction(target_q_output, QDream, myHero)
				if qpred and qpred.hitChance >= shaun_hc then
                    local p = qpred.castPos
                    spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                end
			end
        end
	end
    
    local pause_logic = (windup_end_time < game.game_time)
	if Ready(SLOT_Q) and menu:get_value(q_laneclear) == 1 and combo:get_mode() == 3 and m and pause_logic then
		if not isMouseButtonDown then
			for _, a in ipairs(game.minions) do
				if ValidTarget(a, q.range) and not myHero:is_in_autoattack_range(a) then
					qdmg = getdmg("Q", a, myHero, 1)
					b = vec3.new(a.origin.x, a.origin.y, a.origin.z)
					c = arkpred:get_collision(q, b, a)
					if next(c) == nil then
						health = arkpred:get_health_prediction(a, 0.5, 0)
						if health > 0 and qdmg > health then
							pred_output = pred:predict(q.speed, q.delay, q.range, q.radius * 2, a, false, false)
							if pred_output.can_cast then
								local p = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
							end
						end
					end		
				end
			end

			if menu:get_value(q_laneclear_harass) == 1 and ValidTarget(target_q_output, 1180) and not IsUnderTurret(myHero) then
                if menu:get_value(prediction_choice) == 2 then
                    -- Shaun Pred Casting
                    local qpred = ShaunPred:calculatePrediction(target_q_output, QDream, myHero)
                    if qpred and qpred.hitChance >= shaun_hc then
                        local p = qpred.castPos
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                else
                    local qpred = _G.DreamPred.GetPrediction(target_q_output, QDream, myHero)
                    if qpred and Check_PredRates(qpred) then 
                        local p = qpred.castPosition
                        spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
                    end
                end
			end

		elseif isMouseButtonDown then
			a = selector:find_target_minion(q.range)
			pred_output = pred:predict(q.speed, q.delay, q.range, q.radius * 2, a, false, false)
			if ValidTarget(a, q.range) and pred_output.can_cast then
				local p = pred_output.cast_pos
				spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
			end
		end

		if combo:get_mode() == 3 and menu:get_value(q_jungleclear) == 1 and m then 
			for _, jm in ipairs(game.jungle_minions) do
				if ValidTarget(jm, q.range) then
					if Ready(SLOT_W) and EpicMonster(jm) then
						pred_output = pred:predict(w.speed, w.delay, w.range, w.radius * 2, jm, false, false)
						if pred_output.can_cast then
							local p = pred_output.cast_pos
							spellbook:cast_spell(SLOT_W, 0.25, p.x, p.y, p.z)
						end
					end

					if Ready(SLOT_Q) then
						if EpicMonster(jm) and castw_done then
							NearMouse = jm:distance_to(game.mouse_pos) <= 700
							pred_output = pred:predict(q.speed, q.delay, q.range, q.radius * 2, jm, false, false)
							if NearMouse and pred_output.can_cast then
								local p = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
							end
						elseif not EpicMonster(jm) or not Ready(SLOT_W) then
							NearMouse = jm:distance_to(game.mouse_pos) <= 700
							pred_output = pred:predict(q.speed, q.delay, q.range, q.radius * 2, jm, false, false)
							if NearMouse and pred_output.can_cast then
								local p = pred_output.cast_pos
								spellbook:cast_spell(SLOT_Q, 0.25, p.x, p.y, p.z)
							end
						end
					end
				end
			end
		end
	end
	
	if cast and combo:get_mode() ~= 1 then
		cast = false
	end

    if game:is_key_down(menu:get_value(semi_manual_r)) then
        SemiManualR()
    end
end

client:set_event_callback("on_tick_always", on_tick_always)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_process_spell", on_process_spell)
client:set_event_callback("on_cast_done", on_cast_done)
client:set_event_callback("on_wnd_proc", on_wnd_proc)