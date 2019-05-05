local Store = require 'expcore.store'

Store.register('force.mining_speed','force',function(force)
    return force.manual_mining_speed_modifier
end,function(force,value)
    force.manual_mining_speed_modifier = value
    game.print(force.name..' how has '..value..' mining speed')
end)

Store.watch('force.mining_speed','player')