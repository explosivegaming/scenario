function thisIsATestFunction(...)
    game.print(serpent.line({...}))
end

Event.add(defines.events.on_console_chat,function(event)
    if event.player_index then game.print('Message: '..event.message) end
end)