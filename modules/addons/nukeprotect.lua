--- Disable new players from having certain items in their inventory, most commonly nukes
-- @addon Nukeprotect

local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.nukeprotect' --- @dep config.nukeprotect
local move_items_stack = _C.move_items_stack --- @dep expcore.common

Event.add(defines.events.on_player_ammo_inventory_changed, function(event)
	local player = game.get_player(event.player_index)

	-- if the player has perms to be ignored, then they should be
	if config.ignore_permisison and Roles.player_allowed(player, config.ignore_permisison) then return end

	local inv = player.get_inventory(defines.inventory.character_ammo)

	for i = 1, #inv do
		local item = inv[i]
		if item.valid and item.valid_for_read and config.ammo[item.name] then
			player.print({ "nukeprotect.ammo", { "item-name." .. item.name } })
			move_items_stack({ item })
		end
	end
end)

Event.add(defines.events.on_player_armor_inventory_changed, function(event)
	local player = game.get_player(event.player_index)

	-- if the player has perms to be ignored, then they should be
	if config.ignore_permisison and Roles.player_allowed(player, config.ignore_permisison) then return end

	local inv = player.get_inventory(defines.inventory.character_armor)

	for i = 1, #inv do
		local item = inv[i]
		if item.valid and item.valid_for_read and config.armor[item.name] then
			player.print({ "nukeprotect.armor", { "item-name." .. item.name } })
			move_items_stack({ item })
		end
	end
end)

Event.add(defines.events.on_player_gun_inventory_changed, function(event)
	local player = game.get_player(event.player_index)

	-- if the player has perms to be ignored, then they should be
	if config.ignore_permisison and Roles.player_allowed(player, config.ignore_permisison) then return end

	local inv = player.get_inventory(defines.inventory.character_guns)

	for i = 1, #inv do
		local item = inv[i]
		if item.valid and item.valid_for_read and config.gun[item.name] then
			player.print({ "nukeprotect.gun", { "item-name." .. item.name } })
			move_items_stack({ item })
		end
	end
end)

Event.add(defines.events.on_player_main_inventory_changed, function(event)
	local player = game.get_player(event.player_index)

	-- if the player has perms to be ignored, then they should be
	if config.ignore_permisison and Roles.player_allowed(player, config.ignore_permisison) then return end

	local inv = player.get_inventory(defines.inventory.character_main)

	for i = 1, #inv do
		local item = inv[i]
		if item.valid and item.valid_for_read and config.main[item.name] then
			player.print({ "nukeprotect.main", { "item-name." .. item.name } })
			move_items_stack({ item })
		end
	end
end)
