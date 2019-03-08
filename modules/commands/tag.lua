local Commands = require 'expcore.commands'
require 'expcore.common_parse'

Commands.new_command('tag','Sets your player tag.')
:add_param('tag',false,'string-max-length',20) -- new tag for your player max 20 char
:enable_auto_concat()
:register(function(player,tag,raw)
    player.tag = '- '..tag
end)

Commands.new_command('tag-clear','Clears your tag. Or another player if you are admin.')
:add_param('player',true,'player') -- player to remove the tag of, nil to apply to self
:add_defaults{player=function(player)
    return player -- default is the user using the command
end}
:register(function(player,action_player,raw)
    if action_player.index == player.index then
        -- no player given so removes your tag
        action_player.tag = ''
    elseif player.admin then
        -- player given and user is admin so clears that player's tag
        action_player.tag = ''
    else
        -- user is not admin and tried to clear another users tag
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)