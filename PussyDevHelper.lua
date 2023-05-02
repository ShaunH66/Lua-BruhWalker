-- [ AutoUpdate ]
local Version = 2
do  
    local function AutoUpdate()
		--console:clear()
		local file_name = "PussyDevHelper.lua"
		local url = "http://raw.githubusercontent.com/Astraanator/test/main/Champions/PussyDevHelper.lua"        
        local web_version = http:get("http://raw.githubusercontent.com/Astraanator/test/main/Champions/PussyDevHelper.version")
		if tonumber(web_version) ~= Version then
			http:download_file(url, file_name)
        end   
    end
	
    local function Check()
		if not file_manager:directory_exists("PussyFolder") then
			file_manager:create_directory("PussyFolder")
		end	

		if file_manager:directory_exists("PussyFolder") then
			if not file_manager:file_exists("PussyFolder/PkMenu.png") then
				local file_name = "PussyFolder/PkMenu.png"
				local url = "https://raw.githubusercontent.com/Astraanator/test/main/Images/PkMenu.png"   	
				http:download_file(url, file_name)
			end	
		end			
    end		
    
	AutoUpdate()
	Check()
end

local Window1 = {x = game.screen_size.width * 0.5, y = game.screen_size.height * 0.5}
local AllowMove1 = nil
local Window2 = {x = game.screen_size.width * 0.6, y = game.screen_size.height * 0.6}
local AllowMove2 = nil
local Window3 = {x = game.screen_size.width * 0.4, y = game.screen_size.height * 0.4}
local AllowMove3 = nil
local Window4 = {x = game.screen_size.width * 0.3, y = game.screen_size.height * 0.3}
local AllowMove4 = nil
local Window5 = {x = game.screen_size.width * 0.2, y = game.screen_size.height * 0.2}
local AllowMove5 = nil
local Window6 = {x = game.screen_size.width * 0.7, y = game.screen_size.height * 0.7}
local AllowMove6 = nil
local Window7 = {x = game.screen_size.width * 0.8, y = game.screen_size.height * 0.8}
local AllowMove7 = nil
local Window8 = {x = game.screen_size.width * 0.1, y = game.screen_size.height * 0.1}
local AllowMove8 = nil
local Window9 = {x = game.screen_size.width * 0.55, y = game.screen_size.height * 0.55}
local AllowMove9 = nil

local myHero = game.local_player
local SpellTarget = nil
local ActiveSpell = nil
local Missle = nil
local Particles = {}
local Objects = {}
local length1 = 240
local length2 = 240
local length3 = 240

local function GetDistanceSqr(unit, p2)
	p2 = p2.origin or myHero.origin	
	p2x, p2y, p2z = p2.x, p2.y, p2.z
	p1 = unit.origin
	p1x, p1y, p1z = p1.x, p1.y, p1.z	
	local dx = p1x - p2x
	local dz = (p1z or p1y) - (p2z or p2y)
	return dx*dx + dz*dz
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and not unit.is_enemy and unit.object_id ~= myHero.object_id then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end	
	return _EnemyHeroes
end	

local function GetObject()
	local objects = {}
	
	for i, Ally in ipairs(GetAllyHeroes()) do
	Range = 2000 * 2000
		if Ally.object_id ~= 0 and GetDistanceSqr(myHero, Ally) < Range then
			table.insert(objects, Ally)
		end
	end	

	for i, Enemy in ipairs(GetEnemyHeroes()) do
	Range = 2000 * 2000
		if Enemy.object_id ~= 0 and GetDistanceSqr(myHero, Enemy) < Range then
			table.insert(objects, Enemy)
		end
	end	

	table.insert(objects, myHero)
	return objects
end

local function NearestAlly()
	local Ally = nil
	for i, hero in ipairs(GetAllyHeroes()) do
		if hero.object_id ~= 0 then
			if Ally == nil then 
				if hero:distance_to(game.mouse_pos) <= 2000 then
					Ally = hero
				end					
			elseif hero:distance_to(game.mouse_pos) <= 2000 and Ally ~= hero and hero:distance_to(game.mouse_pos) < Ally:distance_to(game.mouse_pos) then
				Ally = hero
			end
		end	
	end
	return Ally
end

local function IsInStatusBox(pt, pos)
	if pos == 1 then
		return pt.x >= Window1.x and pt.x <= Window1.x + 240
			and pt.y >= Window1.y and pt.y <= Window1.y + 115
	elseif pos == 2 then
		return pt.x >= Window2.x and pt.x <= Window2.x + 240
			and pt.y >= Window2.y and pt.y <= Window2.y + #myHero.buffs*15
	elseif pos == 3 then
		local enemy = selector:find_target(2000, mode_cursor)
		return pt.x >= Window3.x and pt.x <= Window3.x + 240
			and pt.y >= Window3.y and pt.y <= Window3.y + #enemy.buffs*15
	elseif pos == 4 then
		local Ally = NearestAlly()
		if Ally then
			return pt.x >= Window4.x and pt.x <= Window4.x + 240
				and pt.y >= Window4.y and pt.y <= Window4.y + #Ally.buffs*15
		end		
	elseif pos == 5 then
		return pt.x >= Window5.x and pt.x <= Window5.x + 280
			and pt.y >= Window5.y and pt.y <= Window5.y + 280
	elseif pos == 6 then
		return pt.x >= Window6.x and pt.x <= Window6.x + 280
			and pt.y >= Window6.y and pt.y <= Window6.y + 115
	elseif pos == 7 then
		return pt.x >= Window7.x and pt.x <= Window7.x + 280
			and pt.y >= Window7.y and pt.y <= Window7.y + 175
	elseif pos == 8 then
		if #Objects > 0 then
			return pt.x >= Window8.x and pt.x <= Window8.x + 280
				and pt.y >= Window8.y and pt.y <= Window8.y + #Objects*15	
		end		
	elseif pos == 9 then
		if #Particles > 0 then
			return pt.x >= Window9.x and pt.x <= Window9.x + 280
				and pt.y >= Window9.y and pt.y <= Window9.y + #Particles*15	
		end	
	end	
end

PussyDev_category = menu:add_category_sprite("Developer-Helper", "PussyFolder/PkMenu.png")
menu:add_label("Version "..tonumber(Version), PussyDev_category)

misc1 = menu:add_subcategory("Buffs", PussyDev_category)
menu:add_label("Detect Enemy/Ally near Mouse", misc1)
misc1_name1 =  menu:add_checkbox("Buff-Names <<MyHero>>", misc1, 0)
misc1_name2 =  menu:add_checkbox("Buff-Names <<Enemy>>", misc1, 0)
misc1_name3 =  menu:add_checkbox("Buff-Names <<Ally>>", misc1, 0)

misc2 = menu:add_subcategory("Item Slots", PussyDev_category)
misc2_name1 =  menu:add_checkbox("Item-Id <<MyHero>>", misc2, 0)

misc3 = menu:add_subcategory("Spell Data "..game.local_player.champ_name, PussyDev_category)
menu:add_label("Please activate only one Spell", misc3)
misc3_name1 =  menu:add_checkbox("Q", misc3, 0)
misc3_name2 =  menu:add_checkbox("W", misc3, 0)
misc3_name3 =  menu:add_checkbox("E", misc3, 0)
misc3_name4 =  menu:add_checkbox("R", misc3, 0)

misc4 = menu:add_subcategory("Active Spell", PussyDev_category)
menu:add_label("Select Object-Hero via Left-MouseButton", misc4)
misc4_name1 =  menu:add_checkbox("Active-Spell-Data", misc4, 0)

misc5 = menu:add_subcategory("Missle Data", PussyDev_category)
menu:add_label("Select Object-Hero via Left-MouseButton", misc5)
misc5_name1 =  menu:add_checkbox("Object-Missle-Data", misc5, 0)

misc6 = menu:add_subcategory("Object Data", PussyDev_category)
misc6_name1 =  menu:add_checkbox("Object-Names around MousePos", misc6, 0)
misc6_range = menu:add_slider("Detect-Range around MousePos", misc6, 100, 2000, 600)

misc7 = menu:add_subcategory("Particle Data", PussyDev_category)
misc7_name1 =  menu:add_checkbox("Particle-Names around MousePos", misc7, 0)
misc7_range = menu:add_slider("Detect-Range around MousePos", misc7, 100, 2000, 600)



local function OnWndMsg(msg, wparam)
	if menu:get_value(misc2_name1) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 1) then
			AllowMove1 = {x = Window1.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window1.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove1 = nil
		end
	end	
	
	if menu:get_value(misc1_name1) == 1	or menu:get_value(misc1_name2) == 1 or menu:get_value(misc1_name3) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 2) then
			AllowMove2 = {x = Window2.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window2.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove2 = nil
		end
	end	

	if menu:get_value(misc1_name2) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 3) then
			AllowMove3 = {x = Window3.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window3.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove3 = nil
		end
	end		
	
	if menu:get_value(misc1_name3) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 4) then
			AllowMove4 = {x = Window4.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window4.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove4 = nil
		end
	end

	if menu:get_value(misc3_name1) == 1 or menu:get_value(misc3_name2) == 1 or menu:get_value(misc3_name3) == 1 or menu:get_value(misc3_name4) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 5) then
			AllowMove5 = {x = Window5.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window5.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove5 = nil
		end
	end

	if menu:get_value(misc4_name1) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 6) then
			AllowMove6 = {x = Window6.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window6.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove6 = nil
		end
	end
	
	if menu:get_value(misc5_name1) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 7) then
			AllowMove7 = {x = Window7.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window7.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove7 = nil
		end
	end

	if menu:get_value(misc6_name1) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 8) then
			AllowMove8 = {x = Window8.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window8.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove8 = nil
		end
	end	
	
	if menu:get_value(misc7_name1) == 1 then
		if game:is_key_down(1) and IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 9) then
			AllowMove9 = {x = Window9.x - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x, y = Window9.y - game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y}
		else
			AllowMove9 = nil
		end
	end		
	
	if menu:get_value(misc4_name1) == 1 or menu:get_value(misc5_name1) == 1 then
		for i, Object in ipairs(GetObject()) do
			if msg == 513 and Object:distance_to(game.mouse_pos) <= 150 then
				SpellTarget = Object
			end
		end	
	end	
end

--black = 23, 23, 23, 255
--red = 220, 20, 60, 255
--blue = 0, 191, 255, 255
--green = 50, 205, 50, 255
--white = 255, 255, 255, 255
--yellow = 225, 255, 0, 255	


local function DrawSpellInfo(Slot)
	
	local Spell = spellbook:get_spell_slot(Slot)
	local Key
	if Slot == SLOT_Q then
		Key = "Slot-Q"
	elseif Slot == SLOT_W then
		Key = "Slot-W"	
	elseif Slot == SLOT_E then
		Key = "Slot-E"
	elseif Slot == SLOT_R then
		Key = "Slot-R"		
	end
	
	if AllowMove5 then 
		Window5 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove5.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove5.y}
	end

	renderer:draw_rect(Window5.x, Window5.y, 280, 280, 23, 23, 23, 150)
	renderer:draw_text(Window5.x + 30, Window5.y+5, "Level: "..Spell.level, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+20, "Count: "..Spell.count, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+35, "Cd: "..Spell.cooldown, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+50, "Current-Cd: "..Spell.current_cooldown, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+65, "Current-Cd2: "..Spell.current_cooldown2, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+80, "Current-Cd3: "..Spell.current_cooldown3, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+95, "Ammo-Recharge-Time: "..Spell.spell_data.ammo_recharge_time, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+110, "Used-Ammo: "..Spell.spell_data.ammo_used, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+125, "Max-Ammo: "..Spell.spell_data.max_ammo, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+140, "Cast-Range: "..Spell.spell_data.cast_range, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+155, "Cast-Radius: "..Spell.spell_data.cast_radius, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+170, "Second-Cast-Radius: "..Spell.spell_data.cast_radius_secondary, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+185, "SpellData-Cd: "..Spell.spell_data.cooldown, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+200, "Effect-Amount: "..Spell.spell_data.effect_amount, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+215, "Increased-Damage: "..Spell.spell_data.increased_damage, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+230, "Root-Duration: "..Spell.spell_data.root_duration, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+245, "Missile-Speed: "..Spell.spell_data.missile_speed, 0, 191, 255, 255)
	renderer:draw_text(Window5.x + 30, Window5.y+260, "Width: "..Spell.spell_data.width, 0, 191, 255, 255)	

	if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 5) then
		renderer:draw_rect(Window5.x, Window5.y-30, 280, 30, 225, 255, 0, 255)
		renderer:draw_text(Window5.x + 30, Window5.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
	else
		renderer:draw_rect(Window5.x, Window5.y-30, 280, 30, 225, 255, 0, 255)
		renderer:draw_text(Window5.x + 30, Window5.y - 22, Key.." //// "..Spell.spell_data.spell_name, 220, 20, 60, 255)			
	end	
end

local function on_draw()
	--console:log(tostring(myHero:get_buff("Tantrum").is_valid))
	

------------------------ITEMS-----------------------------------------------------------------	
										
	if menu:get_value(misc2_name1) == 1 then 
		if AllowMove1 then 
			Window1 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove1.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove1.y}
		end			
		
		renderer:draw_rect(Window1.x, Window1.y, 240, 115, 23, 23, 23, 150)
		renderer:draw_text(Window1.x + 30, Window1.y+5, "Slot 1: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+20, "Slot 2: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+35, "Slot 3: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+50, "Slot 5: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+65, "Slot 6: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+80, "Slot 7: ", 0, 191, 255, 255)
		renderer:draw_text(Window1.x + 30, Window1.y+95, "WardSlot: ", 0, 191, 255, 255)
		for _, v in ipairs(myHero.items) do
			if v.slot == 1 then
				renderer:draw_text(Window1.x + 150, Window1.y+5, "Id = "..v.item_id, 50, 205, 50, 255)
			end		
			if v.slot == 2 then
				renderer:draw_text(Window1.x + 150, Window1.y+20, "Id = "..v.item_id, 50, 205, 50, 255)				
			end
			if v.slot == 3 then
				renderer:draw_text(Window1.x + 150, Window1.y+35, "Id = "..v.item_id, 50, 205, 50, 255)				
			end
			if v.slot == 4 then
				renderer:draw_text(Window1.x + 150, Window1.y+50, "Id = "..v.item_id, 50, 205, 50, 255)				
			end
			if v.slot == 5 then
				renderer:draw_text(Window1.x + 150, Window1.y+65, "Id = "..v.item_id, 50, 205, 50, 255)				
			end
			if v.slot == 6 then
				renderer:draw_text(Window1.x + 150, Window1.y+80, "Id = "..v.item_id, 50, 205, 50, 255)					
			end
			if v.slot == 7 then
				renderer:draw_text(Window1.x + 150, Window1.y+95, "Id = "..v.item_id, 50, 205, 50, 255)					
			end		
		end
		
		if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 1) then
			renderer:draw_rect(Window1.x, Window1.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window1.x + 30, Window1.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
		else
			renderer:draw_rect(Window1.x, Window1.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window1.x + 30, Window1.y - 22, myHero.champ_name.." Items", 220, 20, 60, 255)			
		end
	end
	
----------------------------BUFFS--------------------------------------------------------------------------------
	
	if menu:get_value(misc1_name1) == 1 then		
		local InfoStream = {}
		
		if AllowMove2 then 
			Window2 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove2.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove2.y}
		end
		
		renderer:draw_rect(Window2.x, Window2.y, length1, #myHero.buffs*15, 23, 23, 23, 150)
		
		for i, buff in ipairs(myHero.buffs) do
			if buff.is_valid then
				if string.len(buff.name)*7 > length1 then
					length1 = string.len(buff.name)*7
				end			
				table.insert(InfoStream, buff.name)
			end
		end
		
		local Line = table.concat(InfoStream, "\n")
		renderer:draw_text(Window2.x + 30, Window2.y+5, Line, 0, 191, 255, 255)		

		if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 2) then
			renderer:draw_rect(Window2.x, Window2.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window2.x + 30, Window2.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
		else
			renderer:draw_rect(Window2.x, Window2.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window2.x + 30, Window2.y - 22, myHero.champ_name.." Buffs", 220, 20, 60, 255)		
		end	
	end
	
	if menu:get_value(misc1_name2) == 1 then
		local InfoStream = {}
		local enemy = selector:find_target(2000, mode_cursor)
		if enemy.object_id ~= 0 then
			if AllowMove3 then 
				Window3 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove3.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove3.y}
			end
			
			renderer:draw_rect(Window3.x, Window3.y, length2, #enemy.buffs*15, 23, 23, 23, 150)
			
			for i, buff in ipairs(enemy.buffs) do
				if buff.is_valid then
					if string.len(buff.name)*7 > length2 then
						length2 = string.len(buff.name)*7
					end
					table.insert(InfoStream, buff.name)
				end
			end
			
			local Line = table.concat(InfoStream, "\n")
			renderer:draw_text(Window3.x + 30, Window3.y+5, Line, 0, 191, 255, 255)		

			if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 3) then
				renderer:draw_rect(Window3.x, Window3.y-30, 240, 30, 225, 255, 0, 255)
				renderer:draw_text(Window3.x + 30, Window3.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
			else
				renderer:draw_rect(Window3.x, Window3.y-30, 240, 30, 225, 255, 0, 255)
				renderer:draw_text(Window3.x + 30, Window3.y - 22, enemy.champ_name.." Buffs", 220, 20, 60, 255)		
			end
		end	
	end
	
	if menu:get_value(misc1_name3) == 1 then
		local InfoStream = {}
		local enemy = NearestAlly()
		if enemy then
		
			if AllowMove4 then 
				Window4 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove4.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove4.y}
			end
			
			renderer:draw_rect(Window4.x, Window4.y, length3, #enemy.buffs*15, 23, 23, 23, 150)
			
			for i, buff in ipairs(enemy.buffs) do
				if buff.is_valid then
					if string.len(buff.name)*7 > length3 then
						length3 = string.len(buff.name)*7
					end				
					table.insert(InfoStream, buff.name)
				end
			end
			
			local Line = table.concat(InfoStream, "\n")
			renderer:draw_text(Window4.x + 30, Window4.y+5, Line, 0, 191, 255, 255)		

			if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 4) then
				renderer:draw_rect(Window4.x, Window4.y-30, 240, 30, 225, 255, 0, 255)
				renderer:draw_text(Window4.x + 30, Window4.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
			else
				renderer:draw_rect(Window4.x, Window4.y-30, 240, 30, 225, 255, 0, 255)
				renderer:draw_text(Window4.x + 30, Window4.y - 22, enemy.champ_name.." Buffs", 220, 20, 60, 255)		
			end
		end	
	end

----------------------------------SPELL-------------------------------------------------------------------------

	if menu:get_value(misc3_name1) == 1 then
		DrawSpellInfo(SLOT_Q)
	end
	
	if menu:get_value(misc3_name2) == 1 then
		DrawSpellInfo(SLOT_W)
	end

	if menu:get_value(misc3_name3) == 1 then
		DrawSpellInfo(SLOT_E)
	end

	if menu:get_value(misc3_name4) == 1 then
		DrawSpellInfo(SLOT_R)
	end	

----------------------------------ACTIVE-SPELL-------------------------------------------------------------------------
	
	if menu:get_value(misc4_name1) == 1 then
		if SpellTarget and SpellTarget.object_id ~= 0 and ActiveSpell then
			if AllowMove6 then 
				Window6 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove6.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove6.y}
			end

			renderer:draw_rect(Window6.x, Window6.y, 280, 115, 23, 23, 23, 150)
			renderer:draw_text(Window6.x + 30, Window6.y+5, "Name: "..ActiveSpell.spell_name, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+20, "Target-Id: "..ActiveSpell.target_id, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+35, "Slot: "..ActiveSpell.slot, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+50, "Level: "..ActiveSpell.level, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+65, "Cooldown: "..ActiveSpell.cooldown, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+80, "Cast-Delay: "..ActiveSpell.cast_delay, 0, 191, 255, 255)
			renderer:draw_text(Window6.x + 30, Window6.y+95, "Attack-Delay: "..ActiveSpell.attack_delay, 0, 191, 255, 255)
			--renderer:draw_text(Window6.x + 30, Window6.y+110, "Is-AutoAttack: "..ActiveSpell.is_autoattack, 0, 191, 255, 255)	

			if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 6) then
				renderer:draw_rect(Window6.x, Window6.y-30, 280, 30, 225, 255, 0, 255)
				renderer:draw_text(Window6.x + 30, Window6.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
			else
				renderer:draw_rect(Window6.x, Window6.y-30, 280, 30, 225, 255, 0, 255)
				renderer:draw_text(Window6.x + 30, Window6.y - 22, "ActiveSpell: "..SpellTarget.champ_name, 220, 20, 60, 255)			
			end				
		end
	end
	
----------------------------------MISSLE-DATA-------------------------------------------------------------------------	
	
	if menu:get_value(misc5_name1) == 1 then
		if SpellTarget and SpellTarget.object_id ~= 0 and Missle then
			if AllowMove7 then 
				Window7 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove7.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove7.y}
			end

			renderer:draw_rect(Window7.x, Window7.y, 280, 175, 23, 23, 23, 150)
			renderer:draw_text(Window7.x + 30, Window7.y+5, "Name: "..Missle.name, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+20, "Target-Id: "..Missle.target_id, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+35, "Level: "..Missle.level, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+50, "Cast-Range: "..Missle.spell_data.cast_range, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+65, "Cast-Radius: "..Missle.spell_data.cast_radius, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+80, "Second-Cast-Radius: "..Missle.spell_data.cast_radius_secondary, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+95, "Effect-Amount: "..Missle.spell_data.effect_amount, 0, 191, 255, 255)	
			renderer:draw_text(Window7.x + 30, Window7.y+110, "Increased-Damage: "..Missle.spell_data.increased_damage, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+125, "Root-Duration: "..Missle.spell_data.root_duration, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+140, "Missile-Speed: "..Missle.spell_data.missile_speed, 0, 191, 255, 255)
			renderer:draw_text(Window7.x + 30, Window7.y+155, "Missle-Width: "..Missle.spell_data.width, 0, 191, 255, 255)			

			if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 7) then
				renderer:draw_rect(Window7.x, Window7.y-30, 280, 30, 225, 255, 0, 255)
				renderer:draw_text(Window7.x + 30, Window7.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
			else
				renderer:draw_rect(Window7.x, Window7.y-30, 280, 30, 225, 255, 0, 255)
				renderer:draw_text(Window7.x + 30, Window7.y - 22, "MissleData: "..SpellTarget.champ_name, 220, 20, 60, 255)			
			end				
		end
	end

----------------------------------OBJECT-NAMES-------------------------------------------------------------------------	

	if menu:get_value(misc6_name1) == 1 then
		renderer:draw_circle(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z, menu:get_value(misc6_range), 0, 137, 110, 255)
		local InfoStream = {}
		
		if AllowMove8 then 
			Window8 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove8.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove8.y}
		end
		
		
		
		for i, object in ipairs(Objects) do
			if object and object.object_id ~= 0 and object:distance_to(game.mouse_pos) <= menu:get_value(misc6_range) then			
				table.insert(InfoStream, object.object_name)
				renderer:draw_circle(object.origin.x, object.origin.y, object.origin.z, 50, 0, 137, 110, 255)
			else
				table.remove(Objects, i)
			end
		end
		
		renderer:draw_rect(Window8.x, Window8.y, 280, #InfoStream*15, 23, 23, 23, 150)
		
		local Line = table.concat(InfoStream, "\n")
		renderer:draw_text(Window8.x + 30, Window8.y+5, Line, 0, 191, 255, 255)		

		if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 8) then
			renderer:draw_rect(Window8.x, Window8.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window8.x + 30, Window8.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
		else
			renderer:draw_rect(Window8.x, Window8.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window8.x + 30, Window8.y - 22, "Objects", 220, 20, 60, 255)		
		end	
	end
	
	if menu:get_value(misc7_name1) == 1 then
		renderer:draw_circle(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z, menu:get_value(misc7_range), 0, 137, 110, 255)
		local InfoStream = {}
		
		if AllowMove9 then 
			Window9 = {x = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).x + AllowMove9.x, y = game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z).y + AllowMove9.y}
		end
		
		particles = game.particles			
		for _, v in ipairs(particles) do
			if v.object_id ~= 0 and v.is_on_screen and v:distance_to(game.mouse_pos) <= menu:get_value(misc7_range) then
				origin = v.origin
				screen_pos = game:world_to_screen(origin.x, origin.y, origin.z)
				
				if screen_pos.is_valid then
					table.insert(InfoStream, v.object_name)
					renderer:draw_circle(origin.x, origin.y, origin.z, 50, 0, 137, 110, 255)
				end
			end
		end	

		renderer:draw_rect(Window9.x, Window9.y, 280, #InfoStream*15, 23, 23, 23, 150)
		
		local Line = table.concat(InfoStream, "\n")
		renderer:draw_text(Window9.x + 30, Window9.y+5, Line, 0, 191, 255, 255)		

		if IsInStatusBox(game:world_to_screen(game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z), 9) then
			renderer:draw_rect(Window9.x, Window9.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window9.x + 30, Window9.y - 22, "Left MouseButton move Box", 220, 20, 60, 255)
		else
			renderer:draw_rect(Window9.x, Window9.y-30, 240, 30, 225, 255, 0, 255)
			renderer:draw_text(Window9.x + 30, Window9.y - 22, "Particles", 220, 20, 60, 255)		
		end	
	end	
end

local function on_active_spell(obj, active_spell)   			
	if menu:get_value(misc4_name1) == 1 then
		if obj and obj.object_id ~= 0 and obj == SpellTarget then	
			if active_spell.valid then
				ActiveSpell = active_spell
			end	
		end
	end	
end

local function on_object_created(object, obj_name)	
	if menu:get_value(misc6_name1) == 1 then
		if object and object.object_id ~= 0 and object:distance_to(game.mouse_pos) <= menu:get_value(misc6_range) then	
			table.insert(Objects, object)	
		end
	end

	if menu:get_value(misc5_name1) == 1 then
		if SpellTarget and object and object.is_valid and object.is_missile and object.missile_data.owner_id  == SpellTarget.object_id then	
			Missle = object.missile_data	
		end
	end	
end

client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_active_spell", on_active_spell)
client:set_event_callback("on_wnd_proc", OnWndMsg)
client:set_event_callback("on_draw", on_draw)