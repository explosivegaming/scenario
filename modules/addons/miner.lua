local Event = require 'utils.event_core' --- @dep utils.event_core

local function miner_check(entity, event)
    if ((math.abs(entity.position.x - event.entity.position.x) < entity.prototype.mining_drill_radius) and (math.abs(entity.position.y - event.entity.position.y) < entity.prototype.mining_drill_radius)) then
        if entity.mining_target ~= nil and entity.mining_target.valid then
            if entity.mining_target.amount > 0 then
                return
            end

            local resources = entity.surface.find_entities_filtered{area={{entity.position.x - entity.prototype.mining_drill_radius, entity.position.y - entity.prototype.mining_drill_radius}, {entity.position.x + entity.prototype.mining_drill_radius, entity.position.y + entity.prototype.mining_drill_radius}}, type='resource'}

            for _, resource in pairs(resources) do
                if resource.amount > 0 then
                    -- if any tile in the radius have resources
                    return
                end
            end

            if entity.to_be_deconstructed(entity.force) then
                -- if it is already waiting to be deconstruct
                return
            else
                if entity.fluidbox and #entity.fluidbox > 0 then
                    -- if require fluid to mine
                    return
                end

                if next(entity.circuit_connected_entities.red) ~= nil or next(entity.circuit_connected_entities.green) ~= nil then
                    -- connected to circuit network
                    return
                end

                if not entity.minable then
                    -- if it is minable
                    return
                end

                if not entity.prototype.selectable_in_game then
                    -- if it can select
                    return
                end

                if entity.has_flag('not-deconstructable') then
                    -- if it can deconstruct
                    return
                end

                entity.order_deconstruction(entity.force)
            end
        end
    end
end

Event.add(defines.events.on_resource_depleted, function(event)
    local entities = event.entity.surface.find_entities_filtered{area={{event.entity.position.x-1, event.entity.position.y-1}, {event.entity.position.x+1, event.entity.position.y+1}}, type='mining-drill'}

    if #entities == 0 then
        return
    end

    for _, entity in pairs(entities) do
        miner_check(entity, event)
    end
end)
