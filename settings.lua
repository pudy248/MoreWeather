dofile("data/scripts/lib/mod_settings.lua")

function mod_setting_bool_custom(mod_id, gui, in_main_menu, im_id, setting)
	local value = ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))
	local text = setting.ui_name .. " - " .. GameTextGet(value and "$option_on" or "$option_off")

	if GuiButton(gui, im_id, mod_setting_group_x_offset, 0, text) then
		ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), not value, false)
	end

	mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
end

function mod_setting_change_callback(mod_id, gui, in_main_menu, setting, old_value, new_value)
	if new_value == nil or new_value == "" or tonumber(new_value) == nil then
		ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), "", false)
		ModSettingSet(mod_setting_get_id(mod_id, setting), "0")
		return
	end
	local max = tonumber(setting.max_value) or 4294967296
	if tonumber(new_value) > max then
		ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), tostring(max), false)
		ModSettingSet(mod_setting_get_id(mod_id, setting), tostring(max))
	end
end

local mod_id = "MoreWeather"

local base_settings = {
    {
        key = "rain_chance",
		category = "general",
        name = "Rain chance",
        description = "Chance for there to be rain of any type.",
		default = "0.3",
		max_value = "1",
    },

    {
        key = "rain_duration",
		category = "general",
        name = "Base rain duration (min)",
        description = "The number of minutes rain will continue. Some rain materials have different times.",
		default = "10",
		max_value = "1440",
    },

    {
        key = "rain_amount",
		category = "general",
        name = "Rain quantity",
        description = "Multiplier to the quantity of all rains.",
		default = "1",
    },
}

mod_settings = {}

local spoilerified = true
local frameNumActual = 0
local randomize_interval = 2

function scramble_text(text)
	local chars = "ABCDEFGHJKMNOQRSTUVWXYZ@@@###%%%&&&" --omitted due to char width: abcdefghijklmnopqrstuvwxyz ILP 
	local retstr = "";
	for i = 1,text:len(),1 do
		local number = math.random(#chars)
		retstr = retstr .. chars:sub(number, number)
	end
	return retstr
end

function populate_mod_settings()
    function mod_settings_entry(attributes)
        local spoiler = (attributes.category == "secret" and spoilerified)
        local name = spoiler and scramble_text(attributes.name) or attributes.name
        local default = attributes.default
        local description = spoiler and scramble_text(attributes.description) or attributes.description

        return {
            id = attributes.key,
            ui_name = name .. " ",
            ui_description = description,
            value_default = default,
			max_value = attributes.max_value,
			allowed_characters = "0123456789.",
			change_fn = mod_setting_change_callback,
            scope = MOD_SETTING_SCOPE_RUNTIME,
        }
    end

	mod_settings = {}

	general_settings = {
		category_id = "general_settings",
		ui_name = "General Settings",
		ui_description = "Global configurations and et cetera.",
		settings = {}
	}
	common_rains = {
		category_id = "common_rains",
		ui_name = "Common Rains",
		ui_description = "Run-of-the-mill standard rains.",
		settings = {}
	}
	rare_rains = {
		category_id = "rare_rains",
		ui_name = "Rare Rains",
		ui_description = "You won't see these very often.",
		settings = {}
	}
    secret_rains = {
        category_id = "secret_rains",
        ui_name = "Secret Rains",
        ui_description = "Looking at these might ruin the fun!",
        settings = {
            {
                id = "reveal_spoilers",
                ui_name = "Reveal spoilers",
                ui_description = "Thank you Dexter for the spoiler code help!",
                ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
                    if GuiButton(gui, im_id, mod_setting_group_x_offset, 0, "[Reveal spoilers]") then
						spoilerified = not spoilerified
                    end
                end,
                not_setting = true,
            },
        }
    }

    for _, attributes in ipairs(base_settings) do
        local active_group = 
			attributes.category == "common" and common_rains.settings or
			attributes.category == "rare" and rare_rains.settings or
			attributes.category == "secret" and secret_rains.settings or 
			general_settings.settings
        table.insert(active_group, mod_settings_entry(attributes))
    end
    
    dofile("mods/MoreWeather/weather.lua")

    for _, attributes in ipairs(weather_config_s) do
        local active_group = 
			attributes.settings.category == "common" and common_rains.settings or
			attributes.settings.category == "rare" and rare_rains.settings or
			attributes.settings.category == "secret" and secret_rains.settings or 
			general_settings.settings
        table.insert(active_group, mod_settings_entry(attributes.settings))
    end
    for _, attributes in ipairs(weather_config_l) do
        local active_group = 
			attributes.settings.category == "common" and common_rains.settings or
			attributes.settings.category == "rare" and rare_rains.settings or
			attributes.settings.category == "secret" and secret_rains.settings or 
			general_settings.settings
        table.insert(active_group, mod_settings_entry(attributes.settings))
    end
    

    table.insert(mod_settings, general_settings)
    table.insert(mod_settings, common_rains)
    table.insert(mod_settings, rare_rains)
    table.insert(mod_settings, secret_rains)
end

function ModSettingsUpdate(init_scope)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	frameNumActual = frameNumActual + 1
	if frameNumActual % randomize_interval == 0 then
		populate_mod_settings()
	end
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end

populate_mod_settings()