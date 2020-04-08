--- Gives players random colours when they join, also applies preset colours to those who have them
-- @addon Player-Colours

local Colours = require 'utils.color_presets' --- @dep utils.color_presets
local Game = require 'utils.game' --- @dep utils.game
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.preset_player_colours' --- @dep config.preset_player_colours
local Global = require 'utils.global' --- @dep utils.global
require 'overrides.table'

Global.register(config,function(tbl)
    config = tbl
end)

Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    local color = 'white'
    if config.players[player.name] then
        color = config.players[player.name]
    else
        while config.disallow[color] do
            color = table.get_random_dictionary_entry(Colours,true)
        end
        color = Colours[color]
    end
    color = {r=color.r/255,g=color.g/255,b=color.b/255,a=0.5}
    player.color = color
    player.chat_color = color
end)