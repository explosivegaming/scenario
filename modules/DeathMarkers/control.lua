--- Adds markers to the map when a player dies and removes it when the body is removed.
-- @module DeathMarkers@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
local global = global{
    corpses={}
}

-- Event Handlers Define
script.on_event(defines.events.on_player_died, function(event)
    local player = game.players[event.player_index]
    local tag = player.force.add_chart_tag(player.surface,{
        position=player.position,
        text='Death: '..player.name..' ('..tick_to_display_format(event.tick)..')'
    })
    if not global.corpses then global.corpses = {} end
    table.insert(global.corpses,tag)
end)

script.on_event(defines.events.on_tick, function(event)
    if (game.tick%3600) ~= 0 then return end
    if not global.corpses then global.corpses = {} end
    local key = 1
    while key <= #global.corpses do
        local tag = global.corpses[key]
        if not tag or not tag.valid then table.remove(global.corpses,key) else
            if not tag.target then 
                local entity = tag.surface.find_entity('character-corpse',tag.position)
                if entity then tag.target = entity
                else tag.destroy() table.remove(global.corpses,key) key=key-1 end
            elseif not tag.target.valid then tag.destroy() table.remove(global.corpses,key) key=key-1 end
        end
        key=key+1
    end
end)

-- Module Return
return ThisModule