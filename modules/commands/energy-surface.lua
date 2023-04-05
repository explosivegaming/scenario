--- Commands for the energy surface module
-- @commands EnergySurface

local Commands = require 'expcore.commands' --- @dep expcore.commands
local EnergySurface = require 'modules.control.energy-surface' --- @dep modules.control.nergy-surface


Commands.new_command('spawn-energy-surface-input', 'Spawns a storage chest that will input into the energy surface')
:register(function(player)
    local position = player.surface.find_non_colliding_position('logistic-chest-storage', player.position, 10, 1)
    EnergySurface.spawn_input_chest(player.surface, position)
    return Commands.success -- prevents command complete message from showing
end)


-- Command to teleport to the energy surface
Commands.new_command('energy-surface', 'Teleports you to the energy surface')
:register(function(player)
    if EnergySurface.surface_index == player.surface.index then
        player.teleport({0, 0}, game.surfaces['nauvis'].index)
    else
        player.teleport({0, 0}, EnergySurface.surface_index)
    end
end)