dofile_once( "data/scripts/lib/utilities.lua" )

local snowfall_chance = 1 / 12
local rainfall_chance = tonumber(ModSettingGet("MoreWeather.rain_chance"))
local rain_duration_on_run_start = tonumber(ModSettingGet("MoreWeather.rain_duration")) * 60 * 60

local RAIN_TYPE_NONE = 0
local RAIN_TYPE_SNOW = 1
local RAIN_TYPE_LIQUID = 2

-- weather impl

local function pick_random_from_table_backwards_2( t, rnd )
	local result = nil
	local len = #t

	for i=len,1, -1 do
		if random_next( rnd, 0.0, 1.0 ) <= tonumber(ModSettingGet("MoreWeather." .. t[i].data.rain_material) or 0) then
			result = t[i].data
			break
		end
	end

	if result == nil then
		result = t[1].data
	end

	return result
end

local weather = nil

function weather_init( year, month, day, hour, minute )
	local rnd = random_create( 7893434, 3458934 )
	local rnd_time = random_create( hour+day, hour+day+1 )
    dofile("mods/MoreWeather/weather.lua")

	-- pick weather type
	local snows1 = ( month >= 12 )
	local snows2 = ( month <= 2 )
	local snows = (snows1 or snows2) and (random_next( rnd_time, 0.0, 1.0 ) <= snowfall_chance) -- snow is based on real world time
	local rains = (not snows) and (random_next( rnd, 0.0, 1.0 ) <= rainfall_chance) 			-- rain is based on world seed

	weather = { }
	local rain_type = RAIN_TYPE_NONE
	if snows then
		rain_type = RAIN_TYPE_SNOW
		weather = pick_random_from_table_backwards_2( weather_config_s, rnd_time )
		-- apply effects from biome_modifiers.lua
		apply_modifier_if_has_none( "hills", "FREEZING" )
		apply_modifier_if_has_none( "mountain_left_entrance", "FREEZING" )
		apply_modifier_if_has_none( "mountain_left_stub", "FREEZING" )
		apply_modifier_if_has_none( "mountain_right", "FREEZING" )
		apply_modifier_if_has_none( "mountain_right_stub", "FREEZING" )
		apply_modifier_if_has_none( "mountain_tree", "FREEZING" )
		apply_modifier_if_has_none( "mountain_tree", "FREEZING" )
		apply_modifier_from_data( "mountain_lake", biome_modifier_cosmetic_freeze ) -- FREEZING the lake is a bad idea. it glitches the fish and creates unnatural ice formations
	elseif rains then
		rain_type = RAIN_TYPE_LIQUID
		weather = pick_random_from_table_backwards_2( weather_config_l, rnd )
	end

	-- init weather struct
	weather.hour = hour
	weather.day = day
	weather.rain_type = rain_type

	-- make it foggy and cloudy if stuff is falling from the sky, randomize rain type
	if weather.rain_type == RAIN_TYPE_NONE then
		weather.fog = 0.0
		weather.clouds = 0.0
	else
		weather.fog = random_next( rnd, 0.3, 0.85 )
		weather.clouds = math.max( weather.fog, random_next( rnd, 0.0, 1.0 ) )
		weather.rain_draw_long = random_next( rnd, 0.0, 1.0 ) <= (weather.rain_draw_long_chance or 1)
		weather.rain_particles = random_next( rnd, weather.rain_particles_min, weather.rain_particles_max )
	end

	-- set world state
	local world_state_entity = GameGetWorldStateEntity()
	edit_component( world_state_entity, "WorldStateComponent", function(comp,vars)
		vars.fog_target_extra = weather.fog
		vars.rain_target_extra = weather.clouds
	end)
end

function weather_check_duration()
	return (weather.rain_duration < 0) or (GameGetFrameNum() < weather.rain_duration * rain_duration_on_run_start)
end

function OnWorldInitialized()
    --???
end

function OnWorldPreUpdate()
	if GameIsIntroPlaying() then
		return
	end
    local year,month,day,hour,minute = GameGetDateAndTimeUTC()

	if weather == nil or weather.hour ~= hour or weather.day ~= day then
		weather_init( year, month, day, hour, minute )
	end

	if weather.rain_type == RAIN_TYPE_SNOW and weather_check_duration() then
		GameEmitRainParticles( weather.rain_particles * tonumber(ModSettingGet("MoreWeather.rain_amount")), 1024, weather.rain_material, 30, 60, 10, false, weather.rain_draw_long )
	end
	
	if weather.rain_type == RAIN_TYPE_LIQUID and weather_check_duration() then
		GameEmitRainParticles( weather.rain_particles * tonumber(ModSettingGet("MoreWeather.rain_amount")), 1024, weather.rain_material, 200, 220, 200, true, weather.rain_draw_long )
	end
end
