local Commands = require 'expcore.commands'

Commands.new_command('me','Sends an action message in the chat')
:add_param('action',false)
:register(function(player,action,raw)
    game.print(string.format('%s %s',player.name,action))
end)