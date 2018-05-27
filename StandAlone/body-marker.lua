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
    for key,tag in pairs(global.corpses) do
        if not tag.valid then global.corpses[key] = nil return end
        if not tag.target then tag.target = tag.surface.find_entity('character-corpse',tag.position) or nil end
        if not tag.target or not tag.target.valid then tag.destroy() global.corpses[key] = nil return end
    end
end)