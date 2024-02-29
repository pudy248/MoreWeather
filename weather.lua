weather_config_l = {}
weather_config_s = {}
--amount+ are optional
local function register_weather(material, chance, category, ui_name, desc, amount_mul, duration_mul, is_snow)
    local entry = {
        data = {
            rain_material = material,
            rain_particles_min = not amount_mul and 1 or amount_mul[1],
            rain_particles_max = not amount_mul and 4 or amount_mul[2],
            rain_duration = duration_mul or 0.5
        },
        settings = {
            key = material,
            category = category,
            name = ui_name,
            description = desc,
            default = tostring(chance),
        }
    }
    if is_snow then
        weather_config_s[#weather_config_s+1] = entry
    else
        weather_config_l[#weather_config_l+1] = entry
    end
end

--Snows
register_weather("snow", 1.0, "common", "Snow", "White and fluffy.", nil, -1, 1)
register_weather("slush", 0.25, "common", "Slush", "Grey and sad.", {3, 5}, -1, 1)

--Real rains
register_weather("water", 1.0, "common", "Water", "Wet.", {10, 15}, nil)
register_weather("radioactive_liquid", 0.5, "common", "Toxic sludge", "Painful.", {10, 15}, nil)
register_weather("blood", 0.4, "common", "Blood", "The gods are anemic.", {10, 15}, nil)
register_weather("oil", 0.3, "common", "Oil", "Environmental catastrophe.", nil, nil)
register_weather("blood_fungi", 0.2, "common", "Fungus blood", "The smell makes you woozy.", {10, 15}, nil)
register_weather("acid", 0.1, "common", "Acid", "Very painful.", {10, 15}, nil)
register_weather("slime", 0.1, "common", "Slime", "Sticky.", nil, nil)
register_weather("alcohol", 0.1, "common", "Whiskey", "A hiisi's dream.", nil, nil)
register_weather("lava", 0.1, "common", "Lava", "Fire and brimstone.", nil, nil)

register_weather("magic_liquid_berserk", 0.05, "rare", "Berserkium", "The gods (and everyone else) are very angry.", nil, nil)
register_weather("magic_liquid_polymorph", 0.04, "rare", "Polymorphine", "You feel a sense of danger.", nil, nil)
register_weather("magic_liquid_teleportation", 0.03, "rare", "Teleportatium", "It must have teleported into the clouds.", nil, nil)
register_weather("magic_liquid_charm", 0.03, "rare", "Pheromone", "Love is in the air.", nil, nil)
register_weather("magic_liquid_invisibility", 0.02, "rare", "Invisibilium", "It's perfectly clear out, not a cloud in the sky!", nil, nil)
register_weather("magic_liquid_faster_levitation_and_movement", 0.02, "rare", "Hastium", "It seems to be falling faster than normal rain.", nil, nil)
register_weather("magic_liquid_random_polymorph", 0.01, "rare", "Chaotic Polymorphine", "You feel a sense of dangerous opportunity.", nil, nil)
register_weather("material_darkness", 0.01, "rare", "Ominous Liquid", "The spiders love it.", nil, nil)

register_weather("gold", 0.005, "secret", "Finite Riches", "A reasonable amount of wealth is falling from the sky.", nil, nil)
register_weather("void_liquid", 0.003, "secret", "Void", "It can even cause rain underground! Air and soil aren't too different.", nil, nil)
register_weather("midas", 0.002, "secret", "Infinite Riches", "The Sampo has been made obsolete by strange weather phenomena.", nil, nil)
register_weather("diamond", 0.002, "secret", "Endless Sparkles", "They're very pretty to look at, if nothing else. Don't tell De Beers.", {20, 30}, nil)
register_weather("urine", 0.001, "secret", "Humiliation", "Golden showers, of the wrong sort.", nil, nil)
register_weather("material_rainbow", 0.001, "secret", "Rainbows", "The colors make you feel a sense of pride.", nil, nil)
register_weather("magic_liquid_hp_regeneration", 0.0005, "secret", "Fountain of Youth", "Good luck!", nil, nil)
register_weather("just_death", 0.0005, "secret", "Just Death", "Good luck!!", nil, nil)

-- Mod appends here!
