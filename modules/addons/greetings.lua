--- Greets players on join
-- @addon greetings

local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.event
local config = require 'config.join_messages' --- @dep config.join_messages
local Global = require 'utils.global' --- @dep utils.global
require 'overrides.table'

Global.register(config,function(tbl)
    config = tbl
end)

local greet =
function(event)
    local player = Game.get_player_by_index(event.player_index)
    local custom_message = config[player.name]
    if custom_message then
        game.print(custom_message,player.color)
    else
        player.print{'greetings.greet',{'links.discord'}}
    end

end

Event.add(defines.events.on_player_joined_game, greet)