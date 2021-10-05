
--[[do
    local function AutoUpdate()
		local Version = 0.1
		local file_name = "QuakeSoundsByTheLegendShaunyboi.lua"
		local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/QuakeSoundsByTheLegendShaunyboi.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/QuakeSoundsByTheLegendShaunyboi.lua.version.txt")
        console:log("QuakeSoundsByTheLegendShaunyboi.lua Vers: "..Version)
		console:log("QuakeSoundsByTheLegendShaunyboi.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
						console:log("....................................................................................")
            console:log("............Shaun's Quake Sounds By Successfully Loaded............")
						console:log("....................................................................................")
        else
			http:download_file(url, file_name)
			      console:log("UglyMansounds Update available.....")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
						console:log("---------------------------------")
						console:log("Please Reload via F5!............")
        end
    end
    AutoUpdate()
end]]

if not file_manager:file_exists("MaleFirstKillSound.wav") then
	local file_name = "MaleFirstKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleFirstKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("FemaleFirstKillSound.wav") then
	local file_name = "FemaleFirstKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleFirstKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("MaleSecondKillSound.wav") then
	local file_name = "MaleSecondKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleSecondKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("FemaleSecondKillSound.wav") then
	local file_name = "FemaleSecondKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleSecondKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("MaleThirdKillSound.wav") then
	local file_name = "MaleThirdKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleThirdKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("FemaleThirdKillSound.wav") then
	local file_name = "FemaleThirdKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleThirdKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("MaleForthKillSound.wav") then
	local file_name = "MaleForthKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MaleForthKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("FemaleForthKillSound.wav") then
	local file_name = "FemaleForthKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemaleForthKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("MalePentaKillSound.wav") then
	local file_name = "MalePentaKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/MalePentaKillSound.wav"
	http:download_file(url, file_name)
end

if not file_manager:file_exists("FemalePentaKillSound.wav") then
	local file_name = "FemalePentaKillSound.wav"
	local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/FemalePentaKillSound.wav"
	http:download_file(url, file_name)
	console:log("ALL SOUNDS ARE DOWNLOADED PLEASE PRESS F5")
	console:log("LOVE YOU ALL")
end


--Initialization lines:

local myHero = game.local_player
local local_player = game.local_player

local kill_1 = false
local kill_2 = false
local kill_3 = false
local kill_4 = false
local kill_5 = false

-- Menu Config

if not file_manager:directory_exists("Shaun's Sexy Common") then
  file_manager:create_directory("Shaun's Sexy Common")
end

if file_manager:file_exists("Shaun's Sexy Common//Logo.png") then
	sounds_category = menu:add_category_sprite("Shaun's Quake Sounds", "Shaun's Sexy Common//Logo.png")
else
	http:download_file("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Common/Logo.png", "Shaun's Sexy Common//Logo.png")
	sounds_category = menu:add_category("Shaun's Quake Sounds")
end

sounds_enabled = menu:add_checkbox("Enabled", sounds_category, 1)
menu:add_label("Shaun's Quake Kill Sounds", sounds_category)
menu:add_label("#Loveyou", sounds_category)

sounds_selector = menu:add_subcategory("[Sounds Features]", sounds_category)
sounds_selector_1 = menu:add_subcategory("[First Kill Sound] Settings", sounds_selector)
sounds_selector_use_male_1 = menu:add_checkbox("Use [Male]", sounds_selector_1, 1)
sounds_selector_use_female_1 = menu:add_checkbox("Use [Female]", sounds_selector_1, 1)
ssounds_selector_2 = menu:add_subcategory("[Second Kill Sound] Settings", sounds_selector)
sounds_selector_use_male_2 = menu:add_checkbox("Use [Male]", sounds_selector_2, 1)
sounds_selector_use_female_2 = menu:add_checkbox("Use [Female]", sounds_selector_2, 1)
ssounds_selector_3 = menu:add_subcategory("[Third Kill Sound] Settings", sounds_selector)
sounds_selector_use_male_3 = menu:add_checkbox("Use [Male]", sounds_selector_3, 1)
sounds_selector_use_female_3 = menu:add_checkbox("Use [Female]", sounds_selector_3, 1)
ssounds_selector_4 = menu:add_subcategory("[Forth Kill Sound] Settings", sounds_selector)
sounds_selector_use_male_4 = menu:add_checkbox("Use [Male]", sounds_selector_4, 1)
sounds_selector_use_female_4 = menu:add_checkbox("Use [Female]", sounds_selector_4, 1)
ssounds_selector_5 = menu:add_subcategory("[Penta Kill Sound] Settings", sounds_selector)
sounds_selector_use_male_5 = menu:add_checkbox("Use [Male]", sounds_selector_5, 1)
sounds_selector_use_female_5 = menu:add_checkbox("Use [Female]", sounds_selector_5, 1)


local function on_kda_updated(kill, death, assist)

	if menu:get_value(sounds_enabled) == 1 then

		if kill and not kill_1 and not kill_2 and not kill_3 and not kill_4 and not kill_5 then
			local startTime_kill_1 = os.time()
			local endTime_kill_1 = startTime_kill_1+10
			if menu:get_value(sounds_selector_use_male_1) then
				client:play_sound(MaleFirstKillSound.wav)
			elseif menu:get_value(sounds_selector_use_female_1) then
				client:play_sound(FemaleFirstKillSound.wav)
			end
			kill_1 = true
		end

		if kill_1 and os.time() >= endTime_kill_1 then
			if not kill_2 and not kill_3 and not kill_4 and not kill_5 then
				kill_1 = false
			end
		end

		-----------------------------------------------------------------------------------

		if kill and kill_1 and not kill_2 and not kill_3 and not kill_4 and not kill_5 then
			local startTime_kill_2 = os.time()
			local endTime_kill_2 = startTime_kill_2+10
			if menu:get_value(sounds_selector_use_male_2) then
				client:play_sound(MaleSecondKillSound.wav)
			elseif menu:get_value(sounds_selector_use_female_2) then
				client:play_sound(FemaleSecondKillSound.wav)
			end
			kill_2 = true
		end

		if kill_2 and os.time() >= endTime_kill_2 then
			if not kill_3 and not kill_4 and not kill_5 then
				kill_2 = false
				kill_1 = false
			end
		end

		-----------------------------------------------------------------------------------

		if kill and kill_1 and kill_2 and not kill_3 and not kill_4 and not kill_5 then
			local startTime_kill_3 = os.time()
			local endTime_kill_3 = startTime_kill_3+10
			if menu:get_value(sounds_selector_use_male_3) then
				client:play_sound(MaleThirdKillSound.wav)
			elseif menu:get_value(sounds_selector_use_female_3) then
				client:play_sound(FemaleThirdKillSound.wav)
			end
			kill_3 = true
		end

		if kill_3 and os.time() >= endTime_kill_3 then
			if not kill_4 and not kill_5 then
				kill_3 = false
				kill_2 = false
				kill_1 = false
			end
		end

		-----------------------------------------------------------------------------------

		if kill and kill_1 and kill_2 and kill_3 and not kill_4 and not kill_5 then
			local startTime_kill_4 = os.time()
			local endTime_kill_4 = startTime_kill_4+30
			if menu:get_value(sounds_selector_use_male_4) then
				client:play_sound(MaleForthKillSound.wav)
			elseif menu:get_value(sounds_selector_use_female_4) then
				client:play_sound(FemaleForthKillSound.wav)
			end
			kill_4 = true
		end
		end
		if kill_4 and os.time() >= endTime_kill_4 then
			if not kill_5 then
				kill_4 = false
				kill_3 = false
				kill_2 = false
				kill_1 = false
			end
		end

		-----------------------------------------------------------------------------------

		if kill and kill_1 and kill_2 and kill_3 and kill_4 and not kill_5 then
			if menu:get_value(sounds_selector_use_male_5) then
				client:play_sound(MalePentaKillSound.wav)
			elseif menu:get_value(sounds_selector_use_female_5) then
				client:play_sound(FemalePentaKillSound.wav)
			end
			kill_5 = true

			kill_4 = false
			kill_3 = false
			kill_2 = false
			kill_1 = false
			kill_5 = false
		end

		-----------------------------------------------------------------------------------

		if death then
			kill_5 = false
			kill_4 = false
			kill_3 = false
			kill_2 = false
			kill_1 = false
		end
	end
end

end

client:set_event_callback("on_kda_updated", on_kda_updated)
