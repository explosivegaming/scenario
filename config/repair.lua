-- config file for the repair command
return {
    disallow = { -- items in this list will never be repaired
        ['loader']=true,
        ['fast-loader']=true,
        ['express-loader']=true,
        ['electric-energy-interface']=true,
        ['infinity-chest']=true
    },
    max_range=50, -- the max range that can be used with the repair command
    allow_blueprint_repair=false, -- when true will allow blueprints (things not destroyed by biters) to be build instantly using the repair command
    allow_ghost_revive=true, -- when true will allow ghosts (things destroyed by biters) to be build instantly using the repair command
    allow_heal_entities=true -- when true will heal entities to full health that are within range
}