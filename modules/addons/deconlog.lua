local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles

local filepath = "log/decon.log"

local function add_log(data)
	game.write_file(filepath, data .. "\n", true, 0) -- write data
end
local function get_secs ()
	return tostring(math.floor(game.tick / 60)) .. ","
end
local function pos_tostring (pos)
	return tostring(pos.x) .. "," .. tostring(pos.y)
end

Event.on_init(function()
	game.write_file(filepath, "\n", false, 0) -- write data
end)

Event.add(defines.events.on_player_deconstructed_area, function (e)
	local player = game.get_player(e.player_index)
	if Roles.player_has_flag(player, "deconlog-bypass") then return end
	add_log(get_secs() .. player.name .. ",decon_area," .. pos_tostring(e.area.left_top) .. "," .. pos_tostring(e.area.right_bottom))
end)

Event.add(defines.events.on_built_entity, function (e)
	if not e.player_index then return end
	local player = game.get_player(e.player_index)
	if Roles.player_has_flag(player, "deconlog-bypass") then return end
	local ent = e.created_entity
	add_log(get_secs() .. player.name .. ",built_entity," .. ent.name .. "," .. pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
end)


Event.add(defines.events.on_player_mined_entity, function (e)
	local player = game.get_player(e.player_index)
	if Roles.player_has_flag(player, "deconlog-bypass") then return end
	local ent = e.entity
	add_log(get_secs() .. player.name .. ",mined_entity," .. ent.name .. "," .. pos_tostring(ent.position) .. "," .. tostring(ent.direction) .. "," .. tostring(ent.orientation))
end)