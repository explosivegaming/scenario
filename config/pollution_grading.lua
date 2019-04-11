-- This controls how pollution is viewed on the map
return {
    reference_point = {x=0,y=0}, -- where pollution is read from
    max_scalar = 0.5, -- the scale between true max and max
    min_scalar = 0.17, -- the scale between the lowest max and min
    update_delay = 15 -- time in minutes between view updates
}