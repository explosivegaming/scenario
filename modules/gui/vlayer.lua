--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local format_number = require('util').format_number --- @dep util
local config = require 'config.vlayer' --- @dep config.vlayer
local vlayer = require 'modules.control.vlayer'

local vlayer_circuit_t = {}
local vlayer_display = {}

for _, v in pairs(config.init_circuit) do
    vlayer_circuit_t[v.name] = v.index
end

for _, v in pairs(config.init_gui) do
    vlayer_display[v.index] = 0
end

local function pos_to_gps_string(pos)
	return '[gps=' .. string.format('%.1f', pos.x) .. ',' .. string.format('%.1f', pos.y) .. ']'
end

local vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, event_trigger, 320)
    local scroll_table_1 = Gui.scroll_table(container, 320, 2, 'vlayer_st_1')

    for _, v in pairs(config.init_gui) do
        if v.type == 'item' then
            scroll_table_1.add{
                type = 'label',
                name = 'vlayer_display_' .. v.index .. 'n',
                caption = '[img=entity/' .. v.name .. '] ' .. v.disp,
                style = 'heading_1_label'
            }

        else
            scroll_table_1.add{
                type = 'label',
                name = 'vlayer_display_' .. v.index .. 'n',
                caption = '[virtual-signal=' .. v.name .. '] ' .. v.disp,
                style = 'heading_1_label'
            }
        end

        scroll_table_1.add{
            type = 'label',
            name = 'vlayer_display_' .. v.index  .. 'c',
            caption = '0',
            style = 'heading_1_label'
        }
    end

    local scroll_table_2 = Gui.scroll_table(container, 320, 2, 'vlayer_st_2')

    local s = scroll_table_2.add{
        type = 'button',
        name = 'vlayer_display_0s',
        caption = 'Add Storage',
        style = 'button'
    }

    local c = scroll_table_2.add{
        type = 'button',
        name = 'vlayer_display_0c',
        caption = 'Add Circuit',
        style = 'button'
    }

    local p = scroll_table_2.add{
        type = 'button',
        name = 'vlayer_display_0p',
        caption = 'Add Power',
        style = 'button'
    }

    local r = scroll_table_2.add{
        type = 'button',
        name = 'vlayer_display_0r',
        caption = 'Remove Special',
        style = 'button'
    }

    s.style.width = 160
    c.style.width = 160
    p.style.width = 160
    r.style.width = 160

    if not (Roles.player_allowed(player, 'gui/vlayer-edit')) then
        s.visible = false
        c.visible = false
        p.visible = false
        r.visible = false
    end

    r.enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function(player)
	return Roles.player_allowed(player, 'gui/vlayer')
end)

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

local function vlayer_convert_chest_storage_input(player)
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
end

local function vlayer_convert_chest_circuit(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local circuit_o = player.surface.create_entity{name='constant-combinator', position=pos, force='neutral'}
        game.print(player.name .. ' built a vlayer circuit on ' .. pos_to_gps_string(pos))
        circuit_o.destructible = false
        circuit_o.minable = false
        circuit_o.operable = true
        circuit_o.last_user = player

        local circuit_oc = circuit_o.get_or_create_control_behavior()

        for _, v in pairs(config.init_circuit) do
            circuit_oc.set_signal(v.index, {signal={type=v.type, name=v.name}, count=0})
        end

        table.insert(vlayer.entity.circuit, circuit_o)
    end
end

local function vlayer_convert_chest_power(player)
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
end

local function vlayer_convert_remove(player)
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
end

Event.add(defines.events.on_gui_click, function(event)
    if event.element.name:sub(1, 15) == 'vlayer_display_' then
        if event.element.name:sub(-2):sub(1, 1) == '0' then
            local frame = Gui.get_left_element(game.players[event.player_index], vlayer_container)

            if event.element.name:sub(-1) == 's' then
                vlayer_convert_chest_storage_input(game.players[event.player_index])
                frame.container['vlayer_st_2'].table['vlayer_display_0s'].enabled = (#vlayer.entity.storage.input < config.interface_limit.storage_input)
                frame.container['vlayer_st_2'].table['vlayer_display_0r'].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)

            elseif event.element.name:sub(-1) == 'c' then
                vlayer_convert_chest_circuit(game.players[event.player_index])
                frame.container['vlayer_st_2'].table['vlayer_display_0c'].enabled = (#vlayer.entity.circuit < config.interface_limit.circuit)
                frame.container['vlayer_st_2'].table['vlayer_display_0r'].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)

            elseif event.element.name:sub(-1) == 'p' then
                vlayer_convert_chest_power(game.players[event.player_index])
                frame.container['vlayer_st_2'].table['vlayer_display_0p'].enabled = (#vlayer.entity.power < config.interface_limit.energy)
                frame.container['vlayer_st_2'].table['vlayer_display_0r'].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)

            elseif event.element.name:sub(-1) == 'r' then
                vlayer_convert_remove(game.players[event.player_index])
                frame.container['vlayer_st_2'].table['vlayer_display_0s'].enabled = (#vlayer.entity.storage.input < config.interface_limit.storage_input)
                frame.container['vlayer_st_2'].table['vlayer_display_0c'].enabled = (#vlayer.entity.circuit < config.interface_limit.circuit)
                frame.container['vlayer_st_2'].table['vlayer_display_0p'].enabled = (#vlayer.entity.power < config.interface_limit.energy)
                frame.container['vlayer_st_2'].table['vlayer_display_0r'].enabled = (#vlayer.entity.storage.input > 0) or (#vlayer.entity.circuit > 0) or (#vlayer.entity.power > 0)
            end
        end
    end
end)

local function role_update_event(event)
    local player = game.players[event.player_index]
    local frame = Gui.get_left_element(player, vlayer_container)
    local visible = Roles.player_allowed(player, 'gui/vlayer-edit')

    frame.container['vlayer_st_2'].table['vlayer_display_0s'].visible = visible
    frame.container['vlayer_st_2'].table['vlayer_display_0c'].visible = visible
    frame.container['vlayer_st_2'].table['vlayer_display_0p'].visible = visible
    frame.container['vlayer_st_2'].table['vlayer_display_0r'].visible = visible
end

Event.add(Roles.events.on_role_assigned, role_update_event)
Event.add(Roles.events.on_role_unassigned, role_update_event)

Event.on_nth_tick(config.update_tick, function(_)
    for _, v in pairs(config.init_gui) do
        if v.type == 'item' then
            vlayer_display[v.index] = format_number(vlayer.storage.item[v.name])

        elseif v.type == 'signal' then
            vlayer_display[v.index] = format_number(vlayer.circuit[vlayer_circuit_t[v.name]].count)
        end
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)

        for _, v in pairs(config.init_gui) do
            frame.container['vlayer_st_1'].table['vlayer_display_' .. v.index .. 'c'].caption = vlayer_display[v.index]
        end
    end
end)
