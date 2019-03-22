local Commands = require 'expcore.commands'
require 'config.command_parse_general'

Commands.new_command('kill','Kills yourself or another player.')
:add_param('player',true,'player-alive') -- the player to kill, must be alive to be valid
:add_defaults{player=function(player)
    -- default is the player unless they are dead
    if player.character and player.character.health > 0 then
        return player
    end
end}
:add_tag('admin_only',true)
:register(function(player,action_player,raw)
    if not action_player then
        -- can only be nil if no player given and the user is dead
        return Commands.error{'exp-commands.kill-already-dead'}
    end
    action_player.character.die()
end)