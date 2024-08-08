--[[-- Addon Logging
    @addon Logging
]]

local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.logging' --- @dep config.logging

local function add_log(data)
	game.write_file(config.file_name, data .. '\n', true, 0)
end

Event.add(defines.events.on_rocket_launched, function(event)
    if config.rocket_launch_display[event.rocket.force.rockets_launched] then
        add_log('[ROCKET] ' .. event.rocket.force.rockets_launched .. ' rockets launched')
    end
end)

Event.add(defines.events.on_pre_player_died, function(event)
    if event.cause then
        if event.cause.type == 'character' then
            add_log('[DEATH] ' .. game.players[event.player_index].name .. ' died because of ' .. (game.players[event.cause.player.index].name or ' unknown reason'))

        else
            add_log('[DEATH] ' .. game.players[event.player_index].name .. ' died because of ' .. (event.cause.name or ' unknown reason'))
        end

    else
        add_log('[DEATH] ' .. game.players[event.player_index].name .. ' died because of unknown reason')
	end
end)

Event.add(defines.events.on_research_finished, function(event)
    if event.by_script then
        return
    end

    if (event.research.level - 1) == 0 then
        add_log('[RES] ' .. string.match(event.research.name, '^(.-)%-%d+$'):gsub('-', ' ') .. ' has been researched')

    else
        add_log('[RES] ' .. string.match(event.research.name, '^(.-)%-%d+$'):gsub('-', ' ') .. ' at level ' .. (event.research.level - 1) .. ' has been researched')
    end
end)

Event.add(defines.events.on_player_joined_game, function(event)
    add_log('[JOIN] ' .. game.players[event.player_index].name .. ' joined the game')
end)

Event.add(defines.events.on_player_left_game, function(event)
    add_log('[LEAVE] ' .. game.players[event.player_index].name .. (config.disconnect_reason[event.reason] or config.disconnect_reason[defines.disconnect_reason.quit]))
end)
