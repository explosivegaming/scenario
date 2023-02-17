local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.vlayer' --- @dep config.gui.player_list_actions
local Colors = require 'utils.color_presets' --- @dep utils.color_presets
local format_number = require('util').format_number

--[[
Item Count:
Solar Panel: 344,000
Accumulator: 369,000

Power Production:
Peak: 344 k x 60 kW
Average sustained: 344 x 60 kW x 291 / 416

Battery Storage:
369k x 5.0 MJ = ....

Net Power Production:
- 5,000 MW 
]]

function vlayer_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=16, name="steel-chest", force=player.force}
    
    if (not entities or (#entities == 0)) then
        return nil
    end
        
    local target_chest = player.surface.get_closest(player.position, entities)

    if (not target_chest) then
        player.print("No Steel Chest Detected")
        return nil
    end

    if (not target_chest.get_inventory(defines.inventory.chest).is_empty()) then
        player.print("Chest is not emptied")
        return nil
    end

    local pos = target_chest.position

    if (not target_chest.destroy()) then
        player.print("Unable to convert chest")
        return nil
    end

    return {x=math.floor(pos.x),y=math.floor(pos.y)}
end

function vlayer_convert_chest_storage_input(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local vlayer_storage = player.surface.create_entity{name="logistic-chest-storage", position={pos.x, pos.y}, force="neutral"}
        vlayer_storage.destructible = false
        vlayer_storage.minable = false
        vlayer_storage.last_user = player
    
        table.insert(global.phi.vlayer.storage.input, {type="INPUT", storage=vlayer_storage})
        return true
    end

    return false
end

function vlayer_convert_chest_power_input(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if (player.surface.can_place_entity{name="electric-energy-interface", position=pos}) and 
            (player.surface.can_place_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}}) then
                local vlayer_power = player.surface.create_entity{name="electric-energy-interface", position=pos, force="neutral"}
                vlayer_power.destructible = false
                vlayer_power.minable = false
                vlayer_power.operable = false
                vlayer_power.last_user = player
                vlayer_power.electric_buffer_size = global.phi.vlayer.power.limit.input
                vlayer_power.power_production = 0
                vlayer_power.power_usage = 0
                vlayer_power.energy = 0
            
                local vlayer_circuit = player.surface.create_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}, force="neutral"}
                vlayer_circuit.destructible = false
                vlayer_circuit.minable = false
                vlayer_circuit.operable = true
                vlayer_circuit.last_user = player
                vlayer_circuit.get_or_create_control_behavior().set_signal(1, {signal={type="virtual", name="signal-C"}, count=1})
            
                table.insert(global.phi.vlayer.power.input, {power=vlayer_power, circuit=vlayer_circuit})
            return true

        else
            player.print("Unable to build energy input")
        end
    end

    return false
end

function vlayer_convert_chest_power_output(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if (player.surface.can_place_entity{name="electric-energy-interface", position=pos}) and 
            (player.surface.can_place_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}}) then
                local vlayer_power = player.surface.create_entity{name="electric-energy-interface", position=pos, force="neutral"}
                vlayer_power.destructible = false
                vlayer_power.minable = false
                vlayer_power.operable = false
                vlayer_power.last_user = player
                vlayer_power.electric_buffer_size = global.phi.vlayer.power.limit.output
                vlayer_power.power_production = 0
                vlayer_power.power_usage = 0
                vlayer_power.energy = 0
            
                local vlayer_circuit = player.surface.create_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}, force="neutral"}
                vlayer_circuit.destructible = false
                vlayer_circuit.minable = false
                vlayer_circuit.operable = false
                vlayer_circuit.last_user = player
            
                table.insert(global.phi.vlayer.power.output, {power=vlayer_power, circuit=vlayer_circuit})
            return true

        else
            player.print("Unable to build energy output")
        end
    end

    return false
end


function vlayer_convert_chest_circuit(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local circuit_i = player.surface.create_entity{name="constant-combinator", position=pos, force="neutral"}
        circuit_i.destructible = false
        circuit_i.minable = false
        circuit_i.last_user = player
        circuit_i.get_or_create_control_behavior().set_signal(1, {signal={type="virtual", name="signal-P"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(2, {signal={type="virtual", name="signal-S"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(3, {signal={type="virtual", name="signal-B"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(4, {signal={type="virtual", name="signal-C"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(5, {signal={type="virtual", name="signal-T"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(6, {signal={type="virtual", name="signal-D"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(7, {signal={type="item", name="solar-panel"}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(8, {signal={type="item", name="accumulator"}, count=1})
        
        local circuit_o = player.surface.create_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}, force="neutral"}
        circuit_o.destructible = false
        circuit_o.minable = false
        circuit_o.operable = false
        circuit_o.last_user = player

        table.insert(global.phi.vlayer.power.circuit, {input=circuit_i, output=circuit_o})
    end
end

function vlayer_convert_remove(player)
    local entities = player.surface.find_entities_filtered{name={"electric-energy-interface", "constant-combinator", "logistic-chest-storage"}, position=player.position, radius=16, force={"neutral"}}

    if (#entities == 0) then
        player.print("Entity not found")
        return
    end

    local entity = player.surface.get_closest(player.position, entities)

    if (entity) then
        -- entity.last_user can also be used
        if (player.admin) then
            --[[
            local name = entity.name

            if (name == "electric-energy-interface") then
                if (entity.electric_buffer_size == global.phi.vlayer.power.limit.input) then
                    -- global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + 0
                else
            ]]
            
            entity.destroy()
            player.print("Entity removed")

        else
            player.print("You are not allowed to remove the enity")
        end

    else
        player.print("Entity not found")
    end
end

local button_power_input =
Gui.Element{
  type = 'button',
  caption = 'Power Input',
  style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_power_input(player)
end)

local button_power_output =
Gui.Element{
  type = 'button',
  caption = 'Power Output',
  style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_power_output(player)
end)

local button_storage_input =
Gui.Element{
  type = 'button',
  caption = 'Storage Input',
  style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_storage_input(player)
end)

local button_circuit =
Gui.Element{
  type = 'button',
  caption = 'Circuit',
  style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_circuit(player)
end)

local button_remove =
Gui.Element{
  type = 'button',
  caption = 'Remove',
  style = 'button'
}:on_click(function(player)
    vlayer_convert_remove(player)
end)

local vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, event_trigger, 300)

    local header = Gui.header(container, 'VLAYER', '', true)
    local scroll_table = Gui.scroll_table(container, 300, 2)

    scroll_table.add{
        name = 'vlayer_1_display_title',
        type = 'label',
        caption = 'STORAGE',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'vlayer_2_display_title',
        type = 'label',
        caption = '',
        style = 'heading_1_label'
    }

    scroll_table.add{
        name = 'solar_panel_display_title',
        type = 'label',
        caption = '[img=entity/solar-panel] Solar Panel',
        style = 'heading_1_label'
    }
    local solar_panel_display_count =
    scroll_table.add{
        name = 'solar_panel_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'accumulator_display_title',
        type = 'label',
        caption = '[img=entity/accumulator] Accumulator',
        style = 'heading_1_label'
    }
    local accumulator_display_count =
    scroll_table.add{
        name = 'accumulator_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }

    scroll_table.add{
        name = 'vlayer_3_display_title',
        type = 'label',
        caption = 'Power Production',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'vlayer_4_display_title',
        type = 'label',
        caption = 'KW',
        style = 'heading_1_label'
    }
    
    scroll_table.add{
        name = 'power_production_peak_display_title',
        type = 'label',
        caption = '[virtual-signal=signal-P] Peak',
        style = 'heading_1_label'
    }
    local power_production_peak_display_count =
    scroll_table.add{
        name = 'power_production_peak_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'power_production_sustained_display_title',
        type = 'label',
        caption = '[virtual-signal=signal-S] Sustained',
        style = 'heading_1_label'
    }
    local power_production_sustained_display_count =
    scroll_table.add{
        name = 'power_production_sustained_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }

    scroll_table.add{
        name = 'vlayer_5_display_title',
        type = 'label',
        caption = 'Battery',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'vlayer_6_display_title',
        type = 'label',
        caption = 'MJ',
        style = 'heading_1_label'
    }
    
    scroll_table.add{
        name = 'battery_max_display_title',
        type = 'label',
        caption = '[virtual-signal=signal-M] Max',
        style = 'heading_1_label'
    }
    local battery_max_display_count =
    scroll_table.add{
        name = 'battery_max_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }
    scroll_table.add{
        name = 'battery_current_display_title',
        type = 'label',
        caption = '[virtual-signal=signal-C] Current',
        style = 'heading_1_label'
    }
    local battery_current_display_count =
    scroll_table.add{
        name = 'battery_current_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }

    if Roles.player_allowed(player, 'vlayer-2') then
        scroll_table.add{
            name = 'vlayer_7_display_title',
            type = 'label',
            caption = 'Convert',
            style = 'heading_1_label'
        }
        scroll_table.add{
            name = 'vlayer_8_display_title',
            type = 'label',
            caption = '',
            style = 'heading_1_label'
        }
        button_power_input(scroll_table)
        button_power_output(scroll_table)
        button_storage_input(scroll_table)
        button_circuit(scroll_table)
        button_remove(scroll_table)
    end

    -- Return the external container
    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function (player)
	return Roles.player_allowed(player, 'vlayer-1')
end)

Event.on_nth_tick(60, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, player_list_container)
        local container = frame.container
        
        container.scroll.table.solar_panel_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'])
        container.scroll.table.accumulator_display_count.caption = format_number(global.phi.vlayer.storage.item['accumulator'])
        
        container.scroll.table.power_production_peak_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'] * 60)
        container.scroll.table.power_production_sustained_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'] * 4365 / 104)
        
        container.scroll.table.battery_max_display_count.caption = format_number(global.phi.vlayer.storage.item['accumulator'] * 5)
        container.scroll.table.battery_current_display_count.caption = format_number(math.floor(global.phi.vlayer.power.energy / 1000000))
    end
end)
