--- This file contains all the different settings for the autofill system and gui
-- @config Autofill

local table = require 'overrides.table' --- @dep overrides.table

local ammo = 'ammo'
local fuel = 'fuel'
local shell = 'shell'

local car = 'car'
local tank = 'tank'
local spidertron = 'spidertron'
local locomotive = 'locomotive'
local gun_turret = 'gun-turret'
local burner_mining_drill = 'burner-mining-drill'
local stone_furnace = 'stone-furnace'
local steel_furnace = 'steel-furnace'

local config = {
	-- General config
	icon = 'item/piercing-rounds-magazine', --- @setting icon that will be used for the toolbar
	categories = {
		ammo = ammo,
		fuel = fuel,
		shell = shell
	},
	entities = {
		car = car,
		tank = tank,
		spidertron = spidertron,
		locomotive = locomotive,
		gun_turret = gun_turret,
		burner_mining_drill = burner_mining_drill,
		stone_furnace = stone_furnace,
		steel_furnace = steel_furnace
	},
	default_entities = {}
}

local default_autofill_item_settings = {
	{
		category = config.categories.ammo,
		entity = {config.entities.car, config.entities.tank, config.entities.gun_turret},
		type = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
		name = 'uranium-rounds-magazine',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.car, config.entities.tank, config.entities.gun_turret},
		type = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
		name = 'piercing-rounds-magazine',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.car, config.entities.tank, config.entities.gun_turret},
		type = {defines.inventory.car_ammo, defines.inventory.turret_ammo},
		name = 'firearm-magazine',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.tank},
		type = {defines.inventory.car_ammo},
		name = 'flamethrower-ammo',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.shell,
		entity = {config.entities.tank},
		type = {defines.inventory.car_ammo},
		name = 'cannon-shell',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.shell,
		entity = {config.entities.tank},
		type = {defines.inventory.car_ammo},
		name = 'explosive-cannon-shell',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.shell,
		entity = {config.entities.tank},
		type = {defines.inventory.car_ammo},
		name = 'uranium-cannon-shell',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.shell,
		entity = {config.entities.tank},
		type = {defines.inventory.car_ammo},
		name = 'explosive-uranium-cannon-shell',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.spidertron},
		type = {defines.inventory.car_ammo},
		name = 'rocket',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.spidertron},
		type = {defines.inventory.car_ammo},
		name = 'explosive-rocket',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.ammo,
		entity = {config.entities.spidertron},
		type = {defines.inventory.car_ammo},
		name = 'atomic-bomb',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.fuel,
		entity = {config.entities.car, config.entities.tank, config.entities.locomotive, config.entities.burner_mining_drill, config.entities.stone_furnace, config.entities.steel_furnace},
		type = {defines.inventory.fuel},
		name = 'nuclear-fuel',
		amount = 1,
		enabled = false
	},
	{
		category = config.categories.fuel,
		entity = {config.entities.car, config.entities.tank, config.entities.locomotive, config.entities.burner_mining_drill, config.entities.stone_furnace, config.entities.steel_furnace},
		type = {defines.inventory.fuel},
		name = 'rocket-fuel',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.fuel,
		entity = {config.entities.car, config.entities.tank, config.entities.locomotive, config.entities.burner_mining_drill, config.entities.stone_furnace, config.entities.steel_furnace},
		type = {defines.inventory.fuel},
		name = 'solid-fuel',
		amount = 10,
		enabled = false
	},
	{
		category = config.categories.fuel,
		entity = {config.entities.car, config.entities.tank, config.entities.locomotive, config.entities.burner_mining_drill, config.entities.stone_furnace, config.entities.steel_furnace},
		type = {defines.inventory.fuel},
		name = 'coal',
		amount = 10,
		enabled = false
	}
}

local function get_items_by_type(entity, type)
	local items = entity.items
	for _, item in pairs(default_autofill_item_settings) do
		if table.contains(item.entity, entity.entity) then
			if table.contains(item.type, type) then
				items[item.name] = {
					entity = entity.entity,
					category = item.category,
					type = type,
					name = item.name,
					amount = item.amount,
					enabled = item.enabled
				}
			end
		end
	end
	return items
end

local default_entities = config.default_entities

local function generate_default_setting(entity_name, type, enabled)
	if not default_entities[entity_name] then
		default_entities[entity_name] = {
			entity = entity_name,
			enabled = enabled,
			items = {}
		}
	end
	get_items_by_type(default_entities[entity_name], type)
end

generate_default_setting(config.entities.car, defines.inventory.fuel, true)
generate_default_setting(config.entities.car, defines.inventory.car_ammo, true)

generate_default_setting(config.entities.locomotive, defines.inventory.fuel, true)

generate_default_setting(config.entities.tank, defines.inventory.fuel, true)
generate_default_setting(config.entities.tank, defines.inventory.car_ammo, true)

generate_default_setting(config.entities.spidertron, defines.inventory.car_ammo, true)

generate_default_setting(config.entities.gun_turret, defines.inventory.turret_ammo, true)

generate_default_setting(config.entities.burner_mining_drill, defines.inventory.fuel, true)

generate_default_setting(config.entities.stone_furnace, defines.inventory.fuel, true)

generate_default_setting(config.entities.steel_furnace, defines.inventory.fuel, true)

-- Cleanup temporary table
default_autofill_item_settings = nil

return config