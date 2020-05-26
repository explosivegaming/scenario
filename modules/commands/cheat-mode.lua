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
end)