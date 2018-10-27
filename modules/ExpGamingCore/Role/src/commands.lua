local Role = self

commands.add_validation('player-rank',function(value,event) 
    local player,err = commands.validate['player'](value) 
    if err then return commands.error(err) end
    local rtn = Role.get_highest(player).index > Role.get_highest(event).index and player or nil
    if not rtn then return commands.error{'ExpGamingCore_Command.error-player-rank'} end return rtn
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

commands.add_middleware(function(player,command_name,event)
    return Role.allowed(player,command_name)
end)