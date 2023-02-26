local Event = require 'utils.event_core' --- @dep utils.event_core
local config = require 'config.miner' --- @dep config.miner

local function auto_handle(event)
    local entities = event.entity.surface.find_entities_filtered{area={{event.entity.position.x-1, event.entity.position.y-1}, {event.entity.position.x+1, event.entity.position.y+1}}, type='mining-drill'}

    if #entities == 0 then
        return
    end

    for _, entity in pairs(entities) do
        if ((math.abs(entity.position.x - event.entity.position.x) < entity.prototype.mining_drill_radius) and (math.abs(entity.position.y - event.entity.position.y) < entity.prototype.mining_drill_radius)) then
            if entity.mining_target ~= nil and entity.mining_target.valid then
                if entity.mining_target.amount > 0 then
                    return
                end

                local resources = entity.surface.find_entities_filtered{area={{entity.position.x - entity.prototype.mining_drill_radius, entity.position.y - entity.prototype.mining_drill_radius}, {entity.position.x + entity.prototype.mining_drill_radius, entity.position.y + entity.prototype.mining_drill_radius}}, type='resource'}

                for _, resource in pairs(resources) do
                    if resource.amount > 0 then
                        return
                    end
                end

                if entity.to_be_deconstructed(entity.force) then
                    return
                else
                    if entity.fluidbox and #entity.fluidbox > 0 then
                        return
                    end

                    if next(drill.circuit_connected_entities.red) ~= nil or next(drill.circuit_connected_entities.green) ~= nil then
                        -- Connected to Circuit Network
                        return
                    end

                    if not entity.minable then
                        return
                    end

                    if not entity.prototype.selectable_in_game then
                        return
                    end
                    
                    if entity.has_flag('not-deconstructable') then
                        return
                    end

                    entity.order_deconstruction(entity.force)
                end
            end
        end
    end
end

if config.enabled then
    Event.add(defines.events.on_resource_depleted, function(event)
        auto_handle(event)
    end)
end
