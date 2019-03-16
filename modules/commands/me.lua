local Commands = require 'expcore.commands'

Commands.new_command('me','Sends an action message in the chat')
:add_param('action',false) -- action that is done by the player, just text its meaningless
:enable_auto_concat()
:register(function(player,action,raw)
    local player_name = player and player.name or '<Server>'
    game.print(string.format('* %s %s *',player_name,action),player.chat_color)
end)