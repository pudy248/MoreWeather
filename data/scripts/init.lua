dofile_once( "data/scripts/lib/utilities.lua" )
local init_biome_modifiers = dofile_once( "data/scripts/biome_modifiers.lua")

function OnBiomeConfigLoaded()
	init_biome_modifiers()
end

function OnPlayerDied( player_entity )
	GameDestroyInventoryItems( player_entity )
	GameTriggerGameOver()
end

function OnCountSecrets()
	local secret_flags = {
		"progress_ending0",
		"progress_ending1",
		"progress_ending2",
		"progress_ngplus",
		"progress_orb_evil",
	}

	local total = GameGetOrbCountTotal() + #secret_flags
	local found = 0
	found = found + GameGetOrbCountAllTime()
	for i,it in ipairs(secret_flags) do
		if ( HasFlagPersistent(it) ) then
			found = found + 1
		end
	end

	return total,found
end

