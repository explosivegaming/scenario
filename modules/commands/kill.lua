local Commands = require 'expcore.commands'
local Roles = require 'expcore.roles'
require 'config.command_parse_general'

Commands.new_command('kill','Kills yourself or another player.')
:add_param('player',true,'player-alive') -- the player to kill, must be alive to be valid
:set_defaults{player=function(player)
    -- default is the player unless they are dead
    if player.character and player.character.health > 0 then
        return player
    end
end}
:register(function(player,action_player,raw)
    if not action_player then
        -- can only be nil if no player given and the user is dead
        return Commands.error{'exp-commands.kill-already-dead'}
    end
    if player == action_player then
        action_player.character.die()
    elseif Roles.player_allowed(player,'command/kill/always') then
        local player_highest = Roles.get_player_highest_role(player)
        local action_player_highest = Roles.get_player_highest_role(action_player)
        if player_highest.index < action_player_highest.index then
            action_player.character.die()
        else
            return Commands.error{'expcore-roles.command-error-higher-role',action_player.name}
        end
    else
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)