--greets players on join

local Event = require 'utils.event' --- @dep utils.event
local greet = 
function(event) 
    local message = {'greetings.greet',{'links.discord'}}
    game.players[event.player_index].print(message)


end



Event.add(defines.events.on_player_joined_game ,greet)