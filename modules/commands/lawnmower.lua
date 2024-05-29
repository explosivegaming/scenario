--[[-- Commands Module - Lawnmower
    - Adds a command that clean up biter corpse and nuclear hole
    @commands Lawnmower
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('lawnmower', 'Clean up biter corpse, decoratives and nuclear hole')
:add_param('range', false, 'integer-range', 1, 200)
:register(function(player, range)
	local tile_to_do = {}

    player.surface.destroy_decoratives({position=player.position, radius=range})

	local entities = player.surface.find_entities_filtered{position=player.position, radius=range, type='corpse'}

	for _, entity in pairs(entities) do
		if (entity.name ~= 'transport-caution-corpse' and entity.name ~= 'invisible-transport-caution-corpse') then
			entity.destroy()
		end
	end

	local tiles = player.surface.find_tiles_filtered{position=player.position, radius=range, name={'nuclear-ground'}}

	for _, tile in pairs(tiles) do
		table.insert(tile_to_do, {name='grass-1', position=tile.position})
	end

	player.surface.set_tiles(tile_to_do)

    return Commands.success
end)
