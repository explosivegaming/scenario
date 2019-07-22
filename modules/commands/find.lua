local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore-commands.parse_general'

Commands.new_command('find-on-map','Find a player on your map.')
:add_param('player',false,'player-online') -- the player to find on the map
:add_alias('find','zoom-to')
:register(function(player,action_player,raw)
    local position = action_player.position
    player.zoom_to_world(position,1.75)
    return Commands.success -- prevents command complete message from showing
end)