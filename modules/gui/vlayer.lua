--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local format_number = require('util').format_number --- @dep util
local config = require 'config.vlayer' --- @dep config.vlayer
local vlayer = require 'modules.control.vlayer'

local vlayer_container

local function pos_to_gps_string(pos)
	return '[gps=' .. string.format('%.1f', pos.x) .. ',' .. string.format('%.1f', pos.y) .. ']'
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
    caption = '[virtual-signal=signal-P] Peak Production',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_peak_count =
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

local vlayer_gui_display_signal_max_name =
Gui.element{
    type = 'label',
    name = 'vlayer_display_signal_max_name',
    caption = '[virtual-signal=signal-M] Max Battery',
    style = 'heading_1_label'
}:style{
    width = 200
}

local vlayer_gui_display_signal_max_count =
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
    caption = '[virtual-signal=signal-C] Current Battery',
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
    vlayer_gui_display_signal_peak_count(disp)
    vlayer_gui_display_signal_sustained_name(disp)
    vlayer_gui_display_signal_sustained_count(disp)
    vlayer_gui_display_signal_max_name(disp)
    vlayer_gui_display_signal_max_count(disp)
    vlayer_gui_display_signal_current_name(disp)
    vlayer_gui_display_signal_current_count(disp)

    return vlayer_set
end)

local vlayer_gui_control_remove

local vlayer_gui_control_storage =
Gui.element{
    type = 'button',
    caption = 'Add Storage'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local vlayer_storage = player.surface.create_entity{name='logistic-chest-storage', position=pos, force='neutral'}
        game.print(player.name .. ' built a vlayer storage input on ' .. pos_to_gps_string(pos))
        vlayer_storage.destructible = false
        vlayer_storage.minable = false
        vlayer_storage.operable = true
        vlayer_storage.last_user = player
        table.insert(vlayer.entity.storage.input, vlayer_storage)
    end

    element.enabled = (#vlayer.entity.storage.input < config.interface_limit.storage_input)
    element.parent[vlayer_gui_control_remove.name].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)
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
        local circuit_o = player.surface.create_entity{name='constant-combinator', position=pos, force='neutral'}
        game.print(player.name .. ' built a vlayer circuit on ' .. pos_to_gps_string(pos))
        circuit_o.destructible = false
        circuit_o.minable = false
        circuit_o.operable = true
        circuit_o.last_user = player

        local circuit_oc = circuit_o.get_or_create_control_behavior()
        local count = 1

        for kc, vc in pairs(vlayer.circuit.signal) do
            circuit_oc.set_signal(count, {signal={type='virtual', name=kc}, count=vc})
            count = count + 1
        end

        for kc, vc in pairs(vlayer.circuit.item) do
            circuit_oc.set_signal(count, {signal={type='item', name=kc}, count=vc})
            count = count + 1
        end

        table.insert(vlayer.entity.circuit, circuit_o)
    end

    element.enabled = (#vlayer.entity.circuit < config.interface_limit.circuit)
    element.parent[vlayer_gui_control_remove.name].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)
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
        if (player.surface.can_place_entity{name='electric-energy-interface', position=pos})then
            local vlayer_power = player.surface.create_entity{name='electric-energy-interface', position=pos, force='neutral'}
            game.print(player.name .. ' built a vlayer energy interface on ' .. pos_to_gps_string(pos))
            vlayer_power.destructible = false
            vlayer_power.minable = false
            vlayer_power.operable = false
            vlayer_power.last_user = player
            vlayer_power.electric_buffer_size = math.floor(10000000)
            vlayer_power.power_production = math.floor(500000 / 3)
            vlayer_power.power_usage = math.floor(500000 / 3)
            vlayer_power.energy = 0
            table.insert(vlayer.entity.power, vlayer_power)

        else
            player.print('Unable to build vlayer energy entity')
            player.surface.spill_item_stack(pos, {name='steel-chest', count=1}, true, player.force, false)
        end
    end

    element.enabled = (#vlayer.entity.power < config.interface_limit.energy)
    element.parent[vlayer_gui_control_remove.name].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)
end)

vlayer_gui_control_remove =
Gui.element{
    type = 'button',
    caption = 'Remove Special'
}:style{
    width = 160
}:on_click(function(player, element, _)
    local entities = player.surface.find_entities_filtered{name={'logistic-chest-storage', 'constant-combinator', 'electric-energy-interface'}, position=player.position, radius=8, force='neutral', limit=1}

    if (not entities or #entities == 0) then
        player.print('Entity not found')
        return
    end

    for _, entity in pairs(entities) do
        local name = entity.name
        local pos = entity.position
        entity.destroy()

        if name == 'logistic-chest-storage' then
            game.print(player.name .. ' removed a vlayer storage input on ' .. pos_to_gps_string(pos))

            for k, v in pairs(vlayer.entity.storage.input) do
                if v == nil then
                    vlayer.entity.storage.input[k] = nil

                elseif not v.valid then
                    vlayer.entity.storage.input[k] = nil
                end
            end

        elseif name == 'constant-combinator' then
            game.print(player.name .. ' removed a vlayer circuit output on ' .. pos_to_gps_string(pos))

            for k, v in pairs(vlayer.entity.circuit) do
                if v == nil then
                    vlayer.entity.circuit[k] = nil

                elseif not v.valid then
                    vlayer.entity.circuit[k] = nil
                end
            end

        elseif name == 'electric-energy-interface' then
            game.print(player.name .. ' removed a vlayer energy interface on ' .. pos_to_gps_string(pos))

            for k, v in pairs(vlayer.entity.power) do
                if v == nil then
                    vlayer.entity.power[k] = nil

                elseif not v.valid then
                    vlayer.entity.power[k] = nil
                end
            end
        end
    end

    element.parent[vlayer_gui_control_storage.name].enabled = (#vlayer.entity.storage.input < config.interface_limit.storage_input)
    element.parent[vlayer_gui_control_circuit.name].enabled = (#vlayer.entity.circuit < config.interface_limit.circuit)
    element.parent[vlayer_gui_control_power.name].enabled = (#vlayer.entity.power < config.interface_limit.energy)
    element.enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)
end)

local vlayer_control_set =
Gui.element(function(_, parent, name)
    local vlayer_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(vlayer_set, 320, 2, 'disp')

    vlayer_gui_control_storage(disp)
    vlayer_gui_control_circuit(disp)
    vlayer_gui_control_power(disp)
    vlayer_gui_control_remove(disp)

    return vlayer_set
end)

vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local visible = Roles.player_allowed(player, 'gui/vlayer-edit')
    local container = Gui.container(parent, event_trigger, 320)

    vlayer_display_set(container, 'vlayer_st_1')
    vlayer_control_set(container, 'vlayer_st_2')

    local table = container['vlayer_st_2'].table

    table[vlayer_gui_control_storage.name].visible = visible
    table[vlayer_gui_control_circuit.name].visible = visible
    table[vlayer_gui_control_power.name].visible = visible
    table[vlayer_gui_control_remove.name].enabled = false
    table[vlayer_gui_control_remove.name].visible = visible

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function(player)
	return Roles.player_allowed(player, 'gui/vlayer')
end)

local function role_update_event(event)
    local player = game.players[event.player_index]
    local frame = Gui.get_left_element(player, vlayer_container)
    local visible = Roles.player_allowed(player, 'gui/vlayer-edit')

    frame.container['vlayer_st_2'].table[vlayer_gui_control_storage.name].visible = visible
    frame.container['vlayer_st_2'].table[vlayer_gui_control_circuit.name].visible = visible
    frame.container['vlayer_st_2'].table[vlayer_gui_control_power.name].visible = visible
    frame.container['vlayer_st_2'].table[vlayer_gui_control_remove.name].visible = visible
end

Event.add(Roles.events.on_role_assigned, role_update_event)
Event.add(Roles.events.on_role_unassigned, role_update_event)

Event.on_nth_tick(config.update_tick, function(_)
    local vlayer_display = {
        [vlayer_gui_display_item_solar_count.name] = format_number(vlayer.circuit.item['solar-panel']),
        [vlayer_gui_display_item_accumulator_count.name] = format_number(vlayer.circuit.item['accumulator']),
        [vlayer_gui_display_signal_peak_count.name] = format_number(vlayer.circuit.signal['signal-P']),
        [vlayer_gui_display_signal_sustained_count.name] = format_number(vlayer.circuit.signal['signal-S']),
        [vlayer_gui_display_signal_max_count.name] = format_number(vlayer.circuit.signal['signal-M']),
        [vlayer_gui_display_signal_current_count.name] = format_number(vlayer.circuit.signal['signal-C'])
    }

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)
        local table = frame.container['vlayer_st_1'].disp.table

        for k, v in pairs(vlayer_display) do
            table[k].caption = v
        end
    end
end)
