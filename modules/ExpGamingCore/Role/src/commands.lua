local Role = Role

commands.add_validation('player-rank',function(value,event) 
    local player,err = commands.validate['player'](value) 
    return err and commands.error(err) 
    or Role.get_highest(player).index > Role.get_highest(event).index and player
    or commands.error{'commands.error-player-rank'} 
end)

commands.add_validation('player-rank-online',function(value,event) 
    local player,err = commands.validate['player-online'](value) 
    if err then return commands.error(err) end
    local player,err = commands.validate['player-rank'](player) 
    if err then return commands.error(err) end
    return player
end)

commands.add_validation('player-rank-alive',function(value,event) 
    local player,err = commands.validate['player-alive'](value) 
    if err then return commands.error(err) end
    local player,err = commands.validate['player-rank'](player) 
    if err then return commands.error(err) end
    return player
end)

commands.add_middleware(function(player_name,command_name,event)
    return Role.allowed(player_name,command_name)
end)