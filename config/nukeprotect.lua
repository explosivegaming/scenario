return {
	[tostring(defines.inventory.character_ammo)] = {
		["atomic-bomb"] = true
	}, -- @setting ammo The items to not allow in the player's ammo inventory
	[tostring(defines.inventory.character_armor)] = {}, -- @setting armor The items to not allow in the player's armor inventory
	[tostring(defines.inventory.character_guns)] = {}, -- @setting gun The items to not allow in the player's gun inventory
	[tostring(defines.inventory.character_main)] = {
		["atomic-bomb"] = true
	}, -- @setting main The items to not allow in the player's main inventory
	ignore_permisison = "bypass-nukeprotect", -- @setting ignore_permisison The permission that nukeprotect will ignore
	ignore_admins = true, -- @setting ignore_admins Ignore admins, true by default. Allows usage outside of the roles module
}
