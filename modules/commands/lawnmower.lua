--[[-- Commands Module - Lawnmower
    - Adds a command that clean up biter corpse and nuclear hole
    @commands Lawnmower
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('lawnmower', 'Clean up biter corpse and nuclear hole')
:add_param('range', false, 'integer-range', 1, 200)
:register(function(player, range)
    player.surface.destroy_decoratives({position=player.position, radius=range})
    
	local entities = player.surface.find_entities_filtered{position=player.position, radius=range, type='corpse'}
    
	for _, entity in pairs(entities) do
		if not ((entity.name == 'transport-caution-corpse') or (entity.name == 'invisible-transport-caution-corpse')) then
			entity.destroy()
		end
	end

	for x=player.position.x - range, player.position.x + range do
		for y=player.position.y - range, player.position.y + range do
			if player.surface.get_tile(x, y).name == 'nuclear-ground' then
				player.surface.set_tiles({{name='grass-1', position={x, y}}})
			end
		end
	end

    return Commands.success
end)
