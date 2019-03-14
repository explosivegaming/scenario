local Commands = require 'expcore.commands'
require 'config.command_parse_general'
require 'config.command_auth_admin'

Commands.new_command('toggle-cheat-mode','Toggles cheat mode for your player, or another player.')
:add_param('player',true,'player') -- player to toggle chest mode of, can be nil for self
:add_defaults{player=function(player)
    return player -- default is the user using the command
end}
:add_tag('admin_only',true)
:register(function(player,action_player,raw)
    action_player.cheat_mode = not action_player.cheat_mode
end)