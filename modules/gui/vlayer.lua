--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.vlayer
local format_number = require('util').format_number
local vlayer = require 'modules.control.vlayer'

local vlayer_container
local vlayer_display = {}

local function pos_to_gps_string(pos)
	return '[gps=' .. tostring(pos.x) .. ',' .. tostring(pos.y) .. ']'
end

for i=1, #config.gui.content do
    if config.gui.content[i].type == 'item' or config.gui.content[i].type == 'signal' then
        vlayer_display[i] = {
            type = config.gui.content[i].type,
            name = config.gui.content[i].name,
            count = 0
        }
    end
end

local function vlayer_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=8, name='steel-chest', force=player.force}
    if (not entities or (#entities == 0)) then
        return nil
    end
    local target_chest = player.surface.get_closest(player.position, entities)
    if (not target_chest) then
        player.print('No Steel Chest Detected')
        return nil
    end
    if (not target_chest.get_inventory(defines.inventory.chest).is_empty()) then
        player.print('Chest is not emptied')
        return nil
    end
    local pos = target_chest.position
    if (not target_chest.destroy()) then
        player.print('Unable to convert chest')
        return nil
    end
    return {x=math.floor(pos.x), y=math.floor(pos.y)}
end

local function vlayer_convert_chest_storage_input(player)
    local pos = vlayer_convert_chest(player)
    if (pos) then
        local vlayer_storage = player.surface.create_entity{name='logistic-chest-storage', position={pos.x, pos.y}, force='neutral'}
        game.print(player.name .. ' built a vlayer input on ' .. pos_to_gps_string(pos))
        vlayer_storage.destructible = false
        vlayer_storage.minable = false
        vlayer_storage.operable = true
        vlayer_storage.last_user = player
        table.insert(vlayer.storage.input, {storage=vlayer_storage})
    end
end

local function vlayer_convert_chest_power(player)
    local pos = vlayer_convert_chest(player)
    if (pos) then
        if (player.surface.can_place_entity{name='electric-energy-interface', position=pos}) and (player.surface.can_place_entity{name='constant-combinator', position={x=pos.x+1, y=pos.y}}) then
            local vlayer_power = player.surface.create_entity{name='electric-energy-interface', position=pos, force='neutral'}
            game.print(player.name .. ' built a vlayer energy interface on ' .. pos_to_gps_string(pos))
            vlayer_power.destructible = false
            vlayer_power.minable = false
            vlayer_power.operable = false
            vlayer_power.last_user = player
            vlayer_power.electric_buffer_size = math.floor(config.energy_base_limit / 2)
            vlayer_power.power_production = math.floor(config.energy_base_limit / 60)
            vlayer_power.power_usage = math.floor(config.energy_base_limit / 60)
            vlayer_power.energy = 0
            table.insert(vlayer.power.entity, {power=vlayer_power})
        else
            player.print('Unable to build energy entity')
        end
    end
end

local function vlayer_convert_chest_circuit(player)
    local pos = vlayer_convert_chest(player)
    if (pos) then
        local circuit_i = player.surface.create_entity{name='constant-combinator', position=pos, force='neutral'}
        game.print(player.name .. ' built a vlayer circuit on ' .. pos_to_gps_string(pos))
        circuit_i.destructible = false
        circuit_i.minable = false
        circuit_i.operable = true
        circuit_i.last_user = player
        local circuit_ii = circuit_i.get_or_create_control_behavior()
        circuit_ii.set_signal(1, {signal={type='virtual', name='signal-P'}, count=1})
        circuit_ii.set_signal(2, {signal={type='virtual', name='signal-S'}, count=1})
        circuit_ii.set_signal(3, {signal={type='virtual', name='signal-M'}, count=1})
        circuit_ii.set_signal(4, {signal={type='virtual', name='signal-C'}, count=1})
        circuit_ii.set_signal(5, {signal={type='virtual', name='signal-D'}, count=1})
        circuit_ii.set_signal(6, {signal={type='virtual', name='signal-T'}, count=1})
        circuit_ii.set_signal(7, {signal={type='virtual', name='signal-L'}, count=1})
        circuit_ii.set_signal(8, {signal={type='virtual', name='signal-1'}, count=1})
        circuit_ii.set_signal(9, {signal={type='virtual', name='signal-2'}, count=1})      
        circuit_ii.set_signal(10, {signal={type='item', name='solar-panel'}, count=1})
        circuit_ii.set_signal(11, {signal={type='item', name='accumulator'}, count=1})
        local circuit_o = player.surface.create_entity{name='constant-combinator', position={x=pos.x+1, y=pos.y}, force='neutral'}
        circuit_o.destructible = false
        circuit_o.minable = false
        circuit_o.operable = true
        circuit_o.last_user = player
        table.insert(vlayer.power.circuit, {input=circuit_i, output=circuit_o})
    end
end

local function vlayer_convert_remove(player)
    local entities = player.surface.find_entities_filtered{name={'electric-energy-interface', 'constant-combinator', 'logistic-chest-storage'}, position=player.position, radius=5, force={'neutral'}}
    if (not entities or #entities == 0) then
        player.print('Entity not found')
        return
    end
    for i=1, #entities do
        if (entities[i].name == 'electric-energy-interface') then
            vlayer.power.energy = vlayer.power.energy + entities[i].energy
            entities[i].energy = 0
        end
        local vlayer_print_short = {
            ['electric-energy-interface'] = 'energy interface',
            ['constant-combinator'] = 'circuit',
            ['logistic-chest-storage'] = 'input'
        }
        game.print(player.name .. ' removed a vlayer ' .. vlayer_print_short[entities[i].name] .. ' on ' .. pos_to_gps_string(entities[i].pos))
        entities[i].destroy()
    end
end

local function vlayer_gui_update()
    local button_power_enabled = #vlayer.power.entity >= config.interface_limit.energy
    local button_storage_input_enabled = #vlayer.storage.input >= config.interface_limit.storage_input
    local button_circuit_enabled = #vlayer.power.circuit >= config.interface_limit.circuit
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)
        frame.container.scroll.table['button_1'].enabled = button_power_enabled
        frame.container.scroll.table['button_2'].enabled = button_storage_input_enabled
        frame.container.scroll.table['button_3'].enabled = button_circuit_enabled
    end
end

local button_power =
Gui.element{
    name = 'button_1',
    type = 'button',
    caption = 'Power Entity',
    style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_power(player)
    vlayer_gui_update()
end)

local button_storage_input =
Gui.element{
    name = 'button_2',
    type = 'button',
    caption = 'Storage Input',
    style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_storage_input(player)
    vlayer_gui_update()
end)

local button_circuit =
Gui.element{
    name = 'button_3',
    type = 'button',
    caption = 'Circuit',
    style = 'button'
}:on_click(function(player)
    vlayer_convert_chest_circuit(player)
    vlayer_gui_update()
end)

local button_remove =
Gui.element{
    name = 'button_4',
    type = 'button',
    caption = 'Remove',
    style = 'button'
}:on_click(function(player)
    vlayer_convert_remove(player)
    vlayer_gui_update()
end)

vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, event_trigger, 300)
    Gui.header(container, 'VLAYER', '', true)
    local scroll_table = Gui.scroll_table(container, 300, 2)
    for i=1, #config.gui.content do
        scroll_table.add{
            name = 'vlayer_display_' .. i,
            caption = config.gui.content[i].title,
            type = config.gui.type,
            style = config.gui.style
        }
    end
    button_power(scroll_table)
    button_storage_input(scroll_table)
    button_circuit(scroll_table)
    button_remove(scroll_table)
    if not (Roles.player_allowed(player, 'gui/vlayer-edit')) then
        scroll_table['vlayer_display_' .. #config.gui.content - 1].visible = false
        scroll_table['vlayer_display_' .. #config.gui.content].visible = false
        scroll_table['button_1'].visible = false
        scroll_table['button_2'].visible = false
        scroll_table['button_3'].visible = false
        scroll_table['button_4'].visible = false
    end
    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function(player)
	return Roles.player_allowed(player, 'gui/vlayer')
end)

Event.on_nth_tick(config.update_tick, function()
    for _, v in pairs(vlayer_display) do
        if v.type == 'item' then
            v.count = format_number(vlayer.storage.item[v.name])
        elseif v.type == 'signal' then
            v.count = format_number(vlayer.circuit.output[v.name].count)
        end
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)

        for k, v in pairs(vlayer_display) do
            frame.container.scroll.table['vlayer_display_' .. k].caption = v.count
        end
    end
end)
