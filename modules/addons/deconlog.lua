--- Log certain actions into a file when events are triggered
-- @addon Deconlog

local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local format_time = _C.format_time
local config = require 'config.deconlog' --- @dep config.deconlog

local filepath = "log/decon.log"

local function add_log(data)
	game.write_file(filepath, data .. "\n", true, 0) -- write data
end
local function get_secs ()
	return format_time(game.tick, { hours = true, minutes = true, seconds = true, string = true })
end
local function pos_tostring (pos)
	return tostring(pos.x) .. "," .. tostring(pos.y)
end

Event.on_init(function()
	game.write_file(filepath, "\n", false, 0) -- write data
end)

if config.decon_area then
	Event.add(defines.events.on_player_deconstructed_area, function (e)
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		add_log(get_secs() .. "," .. player.name .. ",decon_area," .. pos_tostring(e.area.left_top) .. "," .. pos_tostring(e.area.right_bottom))
	end)
end

if config.built_entity then
	Event.add(defines.events.on_built_entity, function (e)
		if not e.player_index then return end
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		local ent = e.created_entity
		add_log(get_secs() .. "," .. player.name .. ",built_entity," .. ent.name .. "," .. pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
	end)
end

if config.mined_entity then
	Event.add(defines.events.on_player_mined_entity, function (e)
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		local ent = e.entity
		add_log(get_secs() .. "," .. player.name .. ",mined_entity," .. ent.name .. "," .. pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
	end)
end

if config.fired_rocket then
	Event.add(defines.events.on_player_ammo_inventory_changed, function (e)
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
		local item = ammo_inv[player.character.selected_gun_index]
		if not item or not item.valid or not item.valid_for_read then return end
		if item.name == "rocket" then
			add_log(get_secs() .. "," .. player.name .. ",shot-rocket," .. pos_tostring(player.position) .. "," .. pos_tostring(player.shooting_state.position))
		end
	end)
end

if config.fired_explosive_rocket then
	Event.add(defines.events.on_player_ammo_inventory_changed, function (e)
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
		local item = ammo_inv[player.character.selected_gun_index]
		if not item or not item.valid or not item.valid_for_read then return end
		if item.name == "explosive-rocket" then
			add_log(get_secs() .. "," .. player.name .. ",shot-explosive-rocket," .. pos_tostring(player.position) .. "," .. pos_tostring(player.shooting_state.position))
		end
	end)
end

if config.fired_nuke then
	Event.add(defines.events.on_player_ammo_inventory_changed, function (e)
		local player = game.get_player(e.player_index)
		if Roles.player_has_flag(player, "deconlog-bypass") then return end
		local ammo_inv = player.get_inventory(defines.inventory.character_ammo)
		local item = ammo_inv[player.character.selected_gun_index]
		if not item or not item.valid or not item.valid_for_read then return end
		if item.name == "atomic-bomb" then
			add_log(get_secs() .. "," .. player.name .. ",shot-nuke," .. pos_tostring(player.position) .. "," .. pos_tostring(player.shooting_state.position))
		end
	end)
end
