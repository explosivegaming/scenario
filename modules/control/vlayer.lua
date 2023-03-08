--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.vlayer
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'
local format_number = require('util').format_number

if not config.enabled then
    return
end

global.vlayer = {}
global.vlayer.storage = {}
global.vlayer.storage.item = {}
global.vlayer.storage.input = {}
global.vlayer.power = {}
global.vlayer.power.entity = {}
global.vlayer.power.energy = 0
global.vlayer.power.circuit = {}

global.vlayer.storage.item['solar-panel'] = 0
global.vlayer.storage.item['accumulator'] = 0

local function vlayer_power_handle()
    --[[
    25,000 / 416 s
    昼      208秒	ソーラー効率100%
    夕方	83秒	1秒ごとにソーラー発電量が約1.2%ずつ下がり、やがて0%になる
    夜	    41秒	ソーラー発電量が0%になる
    朝方	83秒	1秒ごとにソーラー発電量が約1.2%ずつ上がり、やがて100%になる
    
    0.75    Day     12,500  208s
    0.25    Sunset  5,000   83s
    0.45    Night   2,500   41s
    0.55    Sunrise 5,000   83s
    ]]

    local vlayer_power_capacity_total = math.floor((global.vlayer.storage.item['accumulator'] * 5000000 + config.energy_base_limit * #global.vlayer.power.entity) / 2)
    local vlayer_power_capacity = math.floor(vlayer_power_capacity_total / #global.vlayer.power.entity)

    if config.always_day then
        global.vlayer.power.energy = global.vlayer.power.energy + math.floor(global.vlayer.storage.item['solar-panel'] * 60000 / config.update_tick)
    else
        local tick = game.tick % 25000

        if tick <= 5000 or tick > 17500 then
            global.vlayer.power.energy = global.vlayer.power.energy + math.floor(global.vlayer.storage.item['solar-panel'] * 60000 / config.update_tick)
    
        elseif tick <= 10000 then
            global.vlayer.power.energy = global.vlayer.power.energy + math.floor(global.vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * (1 - ((tick - 5000) / 5000)))
    
        elseif (tick > 12500) and (tick <= 17500) then
            global.vlayer.power.energy = global.vlayer.power.energy + math.floor(global.vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * ((tick - 5000) / 5000))
        end
    end

    if config.battery_limit then
        if global.vlayer.power.energy > vlayer_power_capacity_total then
            global.vlayer.power.energy = vlayer_power_capacity_total
        end
    end

    for k, v in pairs(global.vlayer.power.entity) do
        if (v.power == nil) or (not v.power.valid)then
            global.vlayer.power.entity[k] = nil
        else
            v.power.electric_buffer_size = vlayer_power_capacity
            v.power.power_production = math.floor(vlayer_power_capacity / 60)
            v.power.power_usage = math.floor(vlayer_power_capacity / 60)
            local energy_average = math.floor((v.power.energy + global.vlayer.power.energy) / 2)

            if global.vlayer.power.energy < vlayer_power_capacity then
                v.power.energy = energy_average
                global.vlayer.power.energy = energy_average
            elseif v.power.energy < vlayer_power_capacity then
                local energy_change = vlayer_power_capacity - v.power.energy

                if energy_change < global.vlayer.power.energy then
                    v.power.energy = v.power.energy + energy_change
                    global.vlayer.power.energy = global.vlayer.power.energy - energy_change
                else
                    v.power.energy = v.power.energy + global.vlayer.power.energy
                    global.vlayer.power.energy = 0
                end
            end
        end
    end
end

local function vlayer_storage_handle()
    for k, v in pairs(global.vlayer.storage.input) do
        if ((v.storage == nil) or (not v.storage.valid)) then
            global.vlayer.storage.input[k] = nil
        else
            local chest = v.storage.get_inventory(defines.inventory.chest)

            for item_name, count in pairs(chest.get_contents()) do
                if (global.vlayer.storage.item[item_name] ~= nil) then
                    global.vlayer.storage.item[item_name] = global.vlayer.storage.item[item_name] + count
                    chest.remove({name=item_name, count=count})
                end
            end
        end
    end
end

local function vlayer_circuit_handle()
    for k, v in pairs(global.vlayer.power.circuit) do
        if (v.input == nil) or (v.output == nil) or (not v.input.valid) or (not v.output.valid) then
            global.vlayer.power.circuit[k] = nil
        else
            local circuit_i = v.input.get_or_create_control_behavior()
            circuit_i.set_signal(1, {signal={type='virtual', name='signal-P'}, count=1})
            circuit_i.set_signal(2, {signal={type='virtual', name='signal-S'}, count=1})
            circuit_i.set_signal(3, {signal={type='virtual', name='signal-M'}, count=1})
            circuit_i.set_signal(4, {signal={type='virtual', name='signal-C'}, count=1})
            circuit_i.set_signal(5, {signal={type='virtual', name='signal-D'}, count=1})
            circuit_i.set_signal(6, {signal={type='virtual', name='signal-T'}, count=1})
            circuit_i.set_signal(7, {signal={type='item', name='solar-panel'}, count=1})
            circuit_i.set_signal(8, {signal={type='item', name='accumulator'}, count=1})

            local circuit_o = v.output.get_or_create_control_behavior()
            circuit_o.set_signal(1, {signal={type='virtual', name='signal-P'}, count=(math.floor(global.vlayer.storage.item['solar-panel'] * 0.06) % 1000000000)})
            circuit_o.set_signal(2, {signal={type='virtual', name='signal-S'}, count=(math.floor(global.vlayer.storage.item['solar-panel'] * 873 / 20800) % 1000000000)})
            circuit_o.set_signal(3, {signal={type='virtual', name='signal-M'}, count=((global.vlayer.storage.item['accumulator'] * 5) % 1000000000)})
            circuit_o.set_signal(4, {signal={type='virtual', name='signal-C'}, count=((global.vlayer.power.energy / 1000000) % 1000000000)})
            circuit_o.set_signal(5, {signal={type='virtual', name='signal-D'}, count=(math.floor(game.tick / 25000))})
            circuit_o.set_signal(6, {signal={type='virtual', name='signal-T'}, count=(game.tick % 25000)})
            circuit_o.set_signal(7, {signal={type='item', name='solar-panel'}, count=(global.vlayer.storage.item['solar-panel'] % 1000000000)})
            circuit_o.set_signal(8, {signal={type='item', name='accumulator'}, count=(global.vlayer.storage.item['accumulator'] % 1000000000)})
        end
    end
end

local function vlayer_handle()
    vlayer_power_handle()
    vlayer_storage_handle()
    vlayer_circuit_handle()
end

local function vlayer_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=16, name='steel-chest', force=player.force}
    
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

    return {x=math.floor(pos.x),y=math.floor(pos.y)}
end

local function vlayer_convert_chest_storage_input(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local vlayer_storage = player.surface.create_entity{name='logistic-chest-storage', position={pos.x, pos.y}, force='neutral'}
        vlayer_storage.destructible = false
        vlayer_storage.minable = false
        vlayer_storage.operable = true
        vlayer_storage.last_user = player
    
        table.insert(global.vlayer.storage.input, {storage=vlayer_storage})
    end
end

local function vlayer_convert_chest_power(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if (player.surface.can_place_entity{name='electric-energy-interface', position=pos}) and (player.surface.can_place_entity{name='constant-combinator', position={x=pos.x+1, y=pos.y}}) then
            local vlayer_power = player.surface.create_entity{name='electric-energy-interface', position=pos, force='neutral'}
            vlayer_power.destructible = false
            vlayer_power.minable = false
            vlayer_power.operable = false
            vlayer_power.last_user = player
            vlayer_power.electric_buffer_size = math.floor(config.energy_base_limit / 2)
            vlayer_power.power_production = math.floor(config.energy_base_limit / 60)
            vlayer_power.power_usage = math.floor(config.energy_base_limit / 60)
            vlayer_power.energy = 0
            
            table.insert(global.vlayer.power.entity, {power=vlayer_power})
        else
            player.print('Unable to build energy entity')
        end
    end
end

local function vlayer_convert_chest_circuit(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local circuit_i = player.surface.create_entity{name='constant-combinator', position=pos, force='neutral'}
        circuit_i.destructible = false
        circuit_i.minable = false
        circuit_i.operable = true
        circuit_i.last_user = player
        circuit_i.get_or_create_control_behavior().set_signal(1, {signal={type='virtual', name='signal-P'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(2, {signal={type='virtual', name='signal-S'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(3, {signal={type='virtual', name='signal-M'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(4, {signal={type='virtual', name='signal-C'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(5, {signal={type='virtual', name='signal-D'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(6, {signal={type='virtual', name='signal-T'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(7, {signal={type='item', name='solar-panel'}, count=1})
        circuit_i.get_or_create_control_behavior().set_signal(8, {signal={type='item', name='accumulator'}, count=1})
        
        local circuit_o = player.surface.create_entity{name='constant-combinator', position={x=pos.x+1, y=pos.y}, force='neutral'}
        circuit_o.destructible = false
        circuit_o.minable = false
        circuit_o.operable = true
        circuit_o.last_user = player

        table.insert(global.vlayer.power.circuit, {input=circuit_i, output=circuit_o})
    end
end

local function vlayer_convert_remove(player)
    local entities = player.surface.find_entities_filtered{name={'electric-energy-interface', 'constant-combinator', 'logistic-chest-storage'}, position=player.position, radius=16, force={'neutral'}}

    if (#entities == 0) then
        player.print('Entity not found')
        return
    end

    for i=1, #entities do
        local entity = player.surface.get_closest(player.position, entities)

        if (entity) then
            if (entity.name == 'electric-energy-interface') then
                global.vlayer.power.energy = global.vlayer.power.energy + entity.energy
                entity.energy = 0
            end

            entity.destroy()
            player.print('Entity removed')
        end
    end
end

local button_power =
Gui.element{
    name = 'power_button',
    type = 'button',
    caption = 'Power Entity',
    style = 'button'
}:on_click(function(player)
    if #global.vlayer.power.entity < config.interface_limit.energy then
        vlayer_convert_chest_power(player)
    else
        player.print('Max limit reached')
    end
end)

local button_storage_input =
Gui.element{
    name = 'storage_input_button',
    type = 'button',
    caption = 'Storage Input',
    style = 'button'
}:on_click(function(player)
    if #global.vlayer.storage.input < config.interface_limit.storage_input then
        vlayer_convert_chest_storage_input(player)
    else
        player.print('Max limit reached')
    end
end)

local button_circuit =
Gui.element{
    name = 'circuit_button',
    type = 'button',
    caption = 'Circuit',
    style = 'button'
}:on_click(function(player)
    if #global.vlayer.power.circuit < config.interface_limit.circuit then
        vlayer_convert_chest_circuit(player)
    else
        player.print('Max limit reached')
    end
end)

local button_remove =
Gui.element{
    name = 'remove_button',
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

    Gui.header(container, 'VLAYER', '', true)
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
        caption = 'MW',
        style = 'heading_1_label'
    }
    
    scroll_table.add{
        name = 'power_production_peak_display_title',
        type = 'label',
        caption = '[virtual-signal=signal-P] Peak',
        style = 'heading_1_label'
    }
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
        button_power(scroll_table)
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

Commands.new_command('personal-battery-recharge', 'Recharge Player Battery with vlayer')
:add_param('amount', 'number-range', 0.2, 1)
:register(function(player, amount)
    local armor = player.get_inventory(defines.inventory.character_armor)[1].grid

    if armor.battery_capacity < amount then
        for i=1, #armor.equipment do
            if armor.equipment[i].energy < (armor.equipment[i].max_energy * amount) then
                local energy_required = (armor.equipment[i].max_energy * amount) - armor.equipment[i].energy

                if global.vlayer.power.energy >= energy_required then
                    armor.equipment[i].energy = armor.equipment[i].max_energy * amount
                    global.vlayer.power.energy = global.vlayer.power.energy - energy_required
                else
                    armor.equipment[i].energy = armor.equipment[i].energy + global.vlayer.power.energy
                    global.vlayer.power.energy = 0
                end
            end
        end
    end

    return Commands.success
end)

Commands.new_command('waterfill', 'Change tile to water')
:register(function(player)
    local inv = player.get_main_inventory()
    
    if (inv.get_item_count('cliff-explosives')) >= 1 then
        local pos = vlayer_convert_chest(player)

        if (pos) then
            if math.abs(player.position.x - pos.x) > 2 and math.abs(player.position.y - pos.y) > 2 then
                player.surface.set_tiles({{name='water-mud', position=pos}})
                inv.remove({name='cliff-explosives', count=1})
            else
                player.print{'vlayer.waterfill-distance'}
            end
        end
    else
        player.print{'vlayer.waterfill-cliff'}
    end

    return Commands.success
end)

Event.on_nth_tick(config.update_tick, function()
    vlayer_handle()

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, vlayer_container)
        local container = frame.container
        
        container.scroll.table.solar_panel_display_count.caption = format_number(global.vlayer.storage.item['solar-panel'])
        container.scroll.table.accumulator_display_count.caption = format_number(global.vlayer.storage.item['accumulator'])
        
        container.scroll.table.power_production_peak_display_count.caption = format_number(math.floor(global.vlayer.storage.item['solar-panel'] * 0.06))
        container.scroll.table.power_production_sustained_display_count.caption = format_number(math.floor(global.vlayer.storage.item['solar-panel'] * 873 / 20800))
        
        container.scroll.table.battery_max_display_count.caption = format_number(math.floor((global.vlayer.storage.item['accumulator'] * 5) + ((config.energy_base_limit / 1000000) * #global.vlayer.power.entity) / 2))
        container.scroll.table.battery_current_display_count.caption = format_number(math.floor(global.vlayer.power.energy / 1000000))
    end
end)
