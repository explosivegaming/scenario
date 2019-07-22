local DebugView = require 'modules.gui.debug.main_view' --- @dep modules.gui.debug.main_view
local Commands = require 'expcore.commands' --- @dep expcore.commands

Commands.new_command('debug','Opens the debug pannel for viewing tables.')
:register(function(player,raw)
    DebugView.open_dubug(player)
end)