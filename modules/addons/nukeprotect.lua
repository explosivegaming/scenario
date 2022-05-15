--- Disable new players from having certain items in their inventory, most commonly nukes
-- @addon Nukeprotect

local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.nukeprotect' --- @dep config.nukeprotect
local move_items_stack = _C.move_items_stack --- @dep expcore.common


local function check_items(player, type)
	-- if the player has perms to be ignored, then they should be
	if config.ignore_permisison and Roles.player_allowed(player, config.ignore_permisison) then return end
	-- if the players
	if config.ignore_admins and player.admin then return end

	local inventory = player.get_inventory(type)
	for i = 1, #inventory do
		local item = inventory[i]
		if item.valid and item.valid_for_read and config[tostring(type)][item.name] then
			player.print({ "nukeprotect.found", { "item-name." .. item.name } })
			-- insert the items into the table so all items are transferred at once
			move_items_stack({ item })
		end
	end
end

if table_size(config[tostring(defines.inventory.character_ammo)]) > 0 then
	Event.add(defines.events.on_player_ammo_inventory_changed, function(event)
		local player = game.get_player(event.player_index)

		check_items(player, defines.inventory.character_ammo)
	end)
end

if table_size(config[tostring(defines.inventory.character_armor)]) > 0 then
	Event.add(defines.events.on_player_armor_inventory_changed, function(event)
		local player = game.get_player(event.player_index)

		check_items(player, defines.inventory.character_armor)
	end)
end

if table_size(config[tostring(defines.inventory.character_guns)]) > 0 then
	Event.add(defines.events.on_player_gun_inventory_changed, function(event)
		local player = game.get_player(event.player_index)

		check_items(player, defines.inventory.character_guns)
	end)
end

if table_size(config[tostring(defines.inventory.character_main)]) > 0 then
	Event.add(defines.events.on_player_main_inventory_changed, function(event)
		local player = game.get_player(event.player_index)

		check_items(player, defines.inventory.character_main)
	end)
end
