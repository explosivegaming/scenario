
-- this was just taken from some where
-- /interface local base_spawn = 1.2 local chunk_delta = ((player.position.x)^2)+((player.position.y)^2)  local scale=math.abs(chunk_delta)/((4*32)^2) return {scale=scale,min=base_spawn*scale,max=(base_spawn*scale)+scale}

Event.register(defines.events.on_chunk_generated,function(event)
    local areas = {
        --[[
        ["very-low"] = 2*32,
        ["low"] = 3*32,
        ["normal"] = 4*32,
        ["high"] = 6*32,
        ["very-high"] = 8*32
        ]]
        -- due it it being round and not squre i have added two extra chunks
        ["very-low"] = 4*32,
        ["low"] = 5*32,
        ["normal"] = 6*32,
        ["high"] = 8*32,
        ["very-high"] = 10*32 
    }
	local surface = game.surfaces[1]
    local enemies = surface.count_entities_filtered{area=event.area, force= "enemy"}
    local starting_area = areas[surface.map_gen_settings.starting_area]
    local chunk_delta = ((event.area.left_top.x+15)^2)+((event.area.left_top.y+15)^2)
    local scale = math.abs(chunk_delta)/(starting_area^2)
    
    if scale > 1 then
        local base_spawn = 1.1
        local min = base_spawn*scale
        local max = min+scale
		local spawns = math.abs(math.random(min,max)-enemies)
		
		for i = 0, spawns do
			local position  = {event.area.left_top.x+math.random(31), event.area.left_top.y+math.random(31)}
			local name = "spitter-spawner"
			
			if math.random() < 0.2 then
				name = "small-worm-turret" 
				if math.random() < scale/32 then
					name = "big-worm-turret" 
				elseif math.random() < scale/16 then
					name = "medium-worm-turret"
				end
			elseif math.random() < 0.5 then
				name =  "biter-spawner"
			end
			
			local pos = surface.find_non_colliding_position(name,position,64,2)
			if pos ~= nil and surface.can_place_entity{name=name,position=pos} then
				surface.create_entity{position=pos,name=name,force="enemy"}
			else
				break
			end
		end
	end
end)