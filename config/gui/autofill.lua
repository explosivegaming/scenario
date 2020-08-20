--- This file contains all the different settings for the autofill system and gui
-- @config Autofill

return {
	-- General config
	icon = 'item/piercing-rounds-magazine', --- @setting icon that will be used for the toolbar
	entities = {
		['car'] = {
			{
				type = 'fuel',
				inventory = defines.inventory.fuel,
				enabled = true
			},
			{
				type = 'ammo',
				inventory = defines.inventory.car_ammo,
				enabled = true
			}
		},
		['locomotive'] = {
			{
				type = 'fuel',
				inventory = defines.inventory.fuel,
				enabled = true
			}
		},
		['tank'] = {
			{
				type = 'fuel',
				inventory = defines.inventory.fuel,
				enabled = true
			},
			{
				type = 'ammo',
				inventory = defines.inventory.car_ammo,
				enabled = true
			}
		},
		['gun-turret'] = {
			{
				type = 'ammo',
				inventory = defines.inventory.turret_ammo,
				enabled = true
			}
		}
	},
	default_settings = {
		{
			type = 'ammo',
			inventories = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
			item = 'uranium-rounds-magazine',
			amount = 10,
			enabled = false
		},
		{
			type = 'ammo',
			inventories = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
			item = 'piercing-rounds-magazine',
			amount = 10,
			enabled = false
		},
		{
			type = 'ammo',
			inventories = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
			item = 'firearm-magazine',
			amount = 10,
			enabled = false
		},
		{
			type = 'fuel',
			inventories = {defines.inventory.fuel},
			item = 'nuclear-fuel',
			amount = 1,
			enabled = false
		},
		{
			type = 'fuel',
			inventories = {defines.inventory.fuel},
			item = 'rocket-fuel',
			amount = 10,
			enabled = false
		},
		{
			type = 'fuel',
			inventories = {defines.inventory.fuel},
			item = 'solid-fuel',
			amount = 10,
			enabled = false
		},
		{
			type = 'fuel',
			inventories = {defines.inventory.fuel},
			item = 'coal',
			amount = 10,
			enabled = false
		}
	}
}