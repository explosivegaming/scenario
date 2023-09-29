local Event = require 'utils.event_core' --- @dep utils.event_core

local function miner_check(event)
    if event.entity.mining_target ~= nil and event.entity.mining_target.valid then
        if event.entity.mining_target.amount > 0 then
            return
        end

        local resources = event.entity.surface.find_entities_filtered{area={{event.entity.position.x - event.entity.prototype.mining_drill_radius, event.entity.position.y - event.entity.prototype.mining_drill_radius}, {event.entity.position.x + event.entity.prototype.mining_drill_radius, event.entity.position.y + event.entity.prototype.mining_drill_radius}}, type='resource'}

        for _, resource in pairs(resources) do
            if resource.amount > 0 then
                -- if any tile in the radius have resources
                return
            end
        end

        if event.entity.to_be_deconstructed(event.entity.force) then
            -- if it is already waiting to be deconstruct
            return

        else
            if event.entity.fluidbox and #event.entity.fluidbox > 0 then
                -- if require fluid to mine
                return
            end

            if next(event.entity.circuit_connected_entities.red) ~= nil or next(event.entity.circuit_connected_entities.green) ~= nil then
                -- connected to circuit network
                return
            end

            if not event.entity.minable then
                -- if it is minable
                return
            end

            if not event.entity.prototype.selectable_in_game then
                -- if it can select
                return
            end

            if event.entity.has_flag('not-deconstructable') then
                -- if it can deconstruct
                return
            end

            event.entity.order_deconstruction(event.entity.force)
        end
    end
end

Event.add(defines.events.on_resource_depleted, miner_check)
