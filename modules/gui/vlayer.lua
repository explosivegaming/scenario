--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local format_number = require('util').format_number --- @dep util
local config = require 'config.vlayer' --- @dep config.vlayer
local vlayer = require 'modules.control.vlayer'

local vlayer_container

local function format_energy(amount, unit)
    if amount < 1 then
        return '0 ' .. unit
    end

    local suffix = ''
    local suffix_list = {
        ['T'] = 1000000000000,
        ['G'] = 1000000000,
        ['M'] = 1000000,
        ['k'] = 1000
    }

    for letter, limit in pairs (suffix_list) do
        if math.abs(amount) >= limit then
            amount = string.format('%.1f', amount / limit)
            suffix = letter
            break
        end
    end

    local formatted, k = amount

    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')

        if (k == 0) then
            break
        end
    end

    return formatted .. ' ' .. suffix .. unit
end

local function vlayer_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=8, name='steel-chest', force=player.force, limit=1}

    if (not entities or #entities == 0) then
        player.print('No steel chest detected')
        return
    end

    local entity = entities[1]
    local pos = entity.position

    if (not entity.get_inventory(defines.inventory.chest).is_empty()) then
        player.print('Chest is not emptied')
        return nil
    end

    entity.destroy()
    return {x=string.format('%.1f', pos.x), y=string.format('%.1f', pos.y)}
end

local vlayer_gui_display_item_solar_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_item_solar_name',
    caption = '[img=entity/solar-panel] Solar Panel',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_item_solar_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_item_solar_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_gui_display_item_accumulator_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_item_accumulator_name',
    caption = '[img=entity/accumulator] Accumulator',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_item_accumulator_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_item_accumulator_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_gui_display_signal_peak_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_peak_name',
    caption = '[virtual-signal=signal-P] Current Production',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_production_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_peak_solar_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_gui_display_signal_sustained_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_sustained_name',
    caption = '[virtual-signal=signal-S] Sustained Production',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_sustained_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_sustained_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_gui_display_signal_capacity_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_max_name',
    caption = '[virtual-signal=signal-C] Battery Capacity',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_capacity_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_max_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_gui_display_signal_current_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_current_name',
    caption = '[virtual-signal=signal-E] Battery Charge',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_current_count =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_current_count',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 120
}

local vlayer_display_set =
Gui.element(function(_, parent, name)
    local vlayer_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(vlayer_set, 320, 2, 'disp')

    vlayer_gui_display_item_solar_name(disp)
    vlayer_gui_display_item_solar_count(disp)
    vlayer_gui_display_item_accumulator_name(disp)
    vlayer_gui_display_item_accumulator_count(disp)
    vlayer_gui_display_signal_peak_name(disp)
    vlayer_gui_display_signal_production_count(disp)
    vlayer_gui_display_signal_sustained_name(disp)
    vlayer_gui_display_signal_sustained_count(disp)
    vlayer_gui_display_signal_capacity_name(disp)
    vlayer_gui_display_signal_capacity_count(disp)
    vlayer_gui_display_signal_current_name(disp)
    vlayer_gui_display_signal_current_count(disp)

    return vlayer_set
end)

local vlayer_gui_control_remove

local function pos_to_gps_string(pos)
	return '[gps=' .. string.format('%.1f', pos.x) .. ',' .. string.format('%.1f', pos.y) .. ']'
end

local vlayer_gui_control_storage_input =
Gui.element{
    type = 'button',
    caption = 'Add Input Storage'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        vlayer.create_input_interface(player.surface, pos, player)
        game.print(player.name .. ' built a vlayer storage input on ' .. pos_to_gps_string(pos))
    end

    element.enabled = (vlayer.get_interface_counts().storage_input < config.interface_limit.storage_input)
end)

local vlayer_gui_control_storage_output =
Gui.element{
    type = 'button',
    caption = 'Add Output Storage'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        vlayer.create_output_interface(player.surface, pos, player)
        game.print(player.name .. ' built a vlayer storage output on ' .. pos_to_gps_string(pos))
    end

    element.enabled = (vlayer.get_interface_counts().storage_output < config.interface_limit.storage_output)
end)

local vlayer_gui_control_circuit =
Gui.element{
    type = 'button',
    caption = 'Add Circuit'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        vlayer.create_circuit_interface(player.surface, pos, player)
        game.print(player.name .. ' built a vlayer circuit on ' .. pos_to_gps_string(pos))
    end

    element.enabled = (vlayer.get_interface_counts().circuit < config.interface_limit.circuit)
end)

local vlayer_gui_control_power =
Gui.element{
    type = 'button',
    caption = 'Add Power'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if vlayer.create_energy_interface(player.surface, pos, player) then
            game.print(player.name .. ' built a vlayer energy interface on ' .. pos_to_gps_string(pos))
        else
            player.print('Unable to build vlayer energy entity')
        end
    end

    element.enabled = (vlayer.get_interface_counts().energy < config.interface_limit.energy)
end)

vlayer_gui_control_remove =
Gui.element{
    type = 'button',
    caption = 'Remove Special'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local interface_type, interface_position = vlayer.remove_closest_interface(player.surface, player.position, 4)
    if not interface_type then
        return player.print('Interface not found in range, please move closer')
    end

    local interfaces = vlayer.get_interface_counts()
    game.print(player.name .. ' removed a vlayer ' .. interface_type .. ' on ' .. pos_to_gps_string(interface_position))
    element.parent[vlayer_gui_control_storage_input.name].enabled = (interfaces.storage_input < config.interface_limit.storage_input)
    element.parent[vlayer_gui_control_storage_output.name].enabled = (interfaces.storage_output < config.interface_limit.storage_output)
    element.parent[vlayer_gui_control_circuit.name].enabled = (interfaces.circuit < config.interface_limit.circuit)
    element.parent[vlayer_gui_control_power.name].enabled = (interfaces.energy < config.interface_limit.energy)
end)

local vlayer_control_set =
Gui.element(function(_, parent, name)
    local vlayer_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(vlayer_set, 320, 2, 'disp')

    local interfaces = vlayer.get_interface_counts()
    vlayer_gui_control_storage_input(disp).enabled = (interfaces.storage_input < config.interface_limit.storage_input)
    vlayer_gui_control_storage_output(disp).enabled = (interfaces.storage_output < config.interface_limit.storage_output)
    vlayer_gui_control_circuit(disp).enabled = (interfaces.circuit < config.interface_limit.circuit)
    vlayer_gui_control_power(disp).enabled = (interfaces.energy < config.interface_limit.energy)
    vlayer_gui_control_remove(disp)

    return vlayer_set
end)

vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, event_trigger, 320)

    vlayer_display_set(container, 'vlayer_st_1')
    vlayer_control_set(container, 'vlayer_st_2')

    local table = container['vlayer_st_2'].disp.table
    local visible = Roles.player_allowed(player, 'gui/vlayer-edit')

    table[vlayer_gui_control_storage_input.name].visible = visible
    table[vlayer_gui_control_storage_output.name].visible = visible
    table[vlayer_gui_control_circuit.name].visible = visible
    table[vlayer_gui_control_power.name].visible = visible
    table[vlayer_gui_control_remove.name].visible = visible
    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function(player)
	return Roles.player_allowed(player, 'gui/vlayer')
end)

local function role_update_event(event)
    local player = game.players[event.player_index]
    local visible = Roles.player_allowed(player, 'gui/vlayer-edit')
    local frame = Gui.get_left_element(player, vlayer_container)
    local table = frame.container['vlayer_st_2'].disp.table

    table[vlayer_gui_control_storage_input.name].visible = visible
    table[vlayer_gui_control_storage_output.name].visible = visible
    table[vlayer_gui_control_circuit.name].visible = visible
    table[vlayer_gui_control_power.name].visible = visible
    table[vlayer_gui_control_remove.name].visible = visible
end

Event.add(Roles.events.on_role_assigned, role_update_event)
Event.add(Roles.events.on_role_unassigned, role_update_event)

Event.on_nth_tick(config.update_tick_gui, function(_)
    local stats = vlayer.get_statistics()
    local items = vlayer.get_items()
    local vlayer_display = {
        [vlayer_gui_display_item_solar_count.name] = format_number(items['solar-panel']),
        [vlayer_gui_display_item_accumulator_count.name] = format_number(items['accumulator']),
        [vlayer_gui_display_signal_production_count.name] = format_energy(stats.energy_production, 'W'),
        [vlayer_gui_display_signal_sustained_count.name] = format_energy(stats.energy_sustained, 'W'),
        [vlayer_gui_display_signal_capacity_count.name] = format_energy(stats.energy_capacity, 'J'),
        [vlayer_gui_display_signal_current_count.name] = format_energy(stats.energy_storage, 'J'),
    }

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)
        local table = frame.container['vlayer_st_1'].disp.table

        for k, v in pairs(vlayer_display) do
            table[k].caption = v
        end
    end
end)
