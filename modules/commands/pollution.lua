--[[-- Commands Module - Pollution Handle
    - Adds a command that allows modifying pollution
    @commands Pollution Handle
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('poloff', 'Remove pollution')
:set_flag('admin_only')
:register(function(player
)
    for _, player in pairs(game.connected_players) do
    end
    Commands.print{'expcom-repair.result', amount}
end)