-- made by cooldude - this just adds a marker to the map which is removed when the body is removed

Event.register(defines.events.on_player_died, function(event)
    local player = game.players[event.player_index]
    local tag = player.force.add_chart_tag(player.surface,{
        position=player.position,
        text='Death: '..player.name..' ('..tick_to_display_format(event.tick)..')'
    })
    if not global.corpses then global.corpses = {} end
    table.insert(global.corpses,tag)
end)

Event.register(defines.events.on_tick, function(event)
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