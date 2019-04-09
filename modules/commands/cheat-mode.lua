local Commands = require 'expcore.commands'
require 'config.command_parse_general'

Commands.new_command('toggle-cheat-mode','Toggles cheat mode for your player, or another player.')
:add_param('player',true,'player') -- player to toggle chest mode of, can be nil for self
:set_defaults{player=function(player)
    return player -- default is the user using the command
end}
:set_flag('admin_only',true)
:register(function(player,action_player,raw)
    action_player.cheat_mode = not action_player.cheat_mode
end)