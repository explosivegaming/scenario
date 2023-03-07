--[[-- Commands Module - Cheat Mode
    - Adds a command that allows players to enter cheat mode
    @commands Cheat-Mode
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

--- Toggles cheat mode for your player, or another player.
-- @command toggle-cheat-mode
-- @tparam[opt=self] LuaPlayer player player to toggle chest mode of, can be nil for self
Commands.new_command('toggle-cheat-mode', 'Toggles cheat mode for your player, or another player.')
:add_param('player', true, 'player')
:set_defaults{player=function(player)
    return player -- default is the user using the command
end}
:set_flag('admin_only')
:register(function(_, player)
    player.cheat_mode = not player.cheat_mode
    return Commands.success
end)

Commands.new_command('toggle-all-research', 'Toggles all research for your force.')
:set_flag('admin_only')
:register(function(_, _)
    game.player.force.research_all_technologies()
    return Commands.success
end)

Commands.new_command('toggle-always-day', 'Toggles always day in surface')
:set_flag('admin_only')
:register(function(_, _)
    game.player.surface.always_day = not game.player.surface.always_day
    return Commands.success
end)

Commands.new_command('kill-all-biter', 'Kill all biter (only)')
:set_flag('admin_only')
:register(function(_, _)
    game.forces["enemy"].kill_all_units()
    return Commands.success
end)

