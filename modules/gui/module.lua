---- module inserter
-- @gui Module

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.module' --- @dep config.module
local Selection = require 'modules.control.selection' --- @dep modules.control.selection
local SelectionModuleArea = 'ModuleArea'

--- align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = {
            x = math.floor(aabb.left_top.x),
            y = math.floor(aabb.left_top.y)
        },
        right_bottom = {
            x = math.ceil(aabb.right_bottom.x),
            y = math.ceil(aabb.right_bottom.y)
        }
    }
end

local module_container
local machine_name = {}

for k, _ in pairs(config.machine) do
    table.insert(machine_name, k)
end

local elem_filter = {
    name = {{
        filter = 'name',
        name = machine_name
    }},
    normal = {{
        filter = 'type',
        type = 'module'
    }},
    prod = {{
        filter = 'type',
        type = 'module'
    }, {
        filter = 'name',
        name = 'productivity',
        invert = true
    }}
}

local function clear_module(player, area, machine)
    for _, entity in pairs(player.surface.find_entities_filtered{area=area, name=machine, force=player.force}) do
        for _, r in pairs(player.surface.find_entities_filtered{position=entity.position, name='item-request-proxy', force=player.force}) do
            if r then
                r.destroy{raise_destroy=true}
            end
        end

        local m_current_module = entity.get_module_inventory()

        if m_current_module then
            local m_current_module_content = m_current_module.get_contents()

            if m_current_module_content then
                for k, m in pairs(m_current_module_content) do
                    player.surface.spill_item_stack(entity.bounding_box.left_top, {name=k, count=m}, true, player.force, false)
                end
            end

            m_current_module.clear()
        end
    end
end

local function apply_module(player, area, machine, modules)
    for _, entity in pairs(player.surface.find_entities_filtered{area=area, name=machine, force=player.force}) do
        local m_current_recipe = entity.get_recipe()

        if m_current_recipe then
            if config.module_allowed[m_current_recipe.name] then
                entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=modules['n']}
                entity.last_user = player

            else
                entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=modules['p']}
                entity.last_user = player
            end

        else
            entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=modules['n']}
            entity.last_user = player
        end
    end
end

--- when an area is selected to add protection to the area
Selection.on_selection(SelectionModuleArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)
    local frame = Gui.get_left_element(player, module_container)
    local table = frame.container.scroll.table

    for i=1, config.default_module_row_count do
        local mma = table['module_mm_' .. i .. '_0'].elem_value

        if mma then
            local mm = {
                ['n'] = {},
                ['p'] = {}
            }

            for j=1, game.entity_prototypes[mma].module_inventory_size, 1 do
                local mmo = table['module_mm_' .. i .. '_' .. j].elem_value

                if mmo then
                    if mm['n'][mmo] then
                        mm['n'][mmo] = mm['n'][mmo] + 1
                        mm['p'][mmo] = mm['p'][mmo] + 1

                    else
                        mm['n'][mmo] = 1
                        mm['p'][mmo] = 1
                    end
                end
            end

            for k, v in pairs(mm['p']) do
                if k:find('productivity') then
                    mm['p'][k:gsub('productivity', 'effectivity')] = v
                    mm['p'][k] = nil
                end
            end

            if mm then
                clear_module(player, area, mma)
                apply_module(player, area, mma, mm)
            end
        end
    end
end)

local function row_set(player, element)
    local frame = Gui.get_left_element(player, module_container)
    local table = frame.container.scroll.table

    if table[element .. '0'].elem_value then
        for i=1, config.module_slot_max do
            if i <= game.entity_prototypes[table[element .. '0'].elem_value].module_inventory_size then
                table[element .. i].enabled = true
                table[element .. i].elem_value = config.machine[table[element .. '0'].elem_value].module

            else
                table[element .. i].enabled = false
                table[element .. i].elem_value = nil
            end

            table[element .. i].elem_filters = elem_filter.normal
        end

    else
        local mf = elem_filter.normal

        if not config.machine[element.elem_value].prod then
            mf = elem_filter.prod
        end

        for i=1, config.module_slot_max do
            table[element .. i].enabled = true
            table[element .. i].elem_filters = mf
            table[element .. i].elem_value = nil
        end
    end
end

local button_apply =
Gui.element{
    type = 'button',
    caption = 'Apply',
    style = 'button'
}:on_click(function(player)
    if Selection.is_selecting(player, SelectionModuleArea) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionModuleArea)
    end
end)

module_container =
Gui.element(function(definition, parent)
    local container = Gui.container(parent, definition.name, (config.module_slot_max + 2) * 36)
    Gui.header(container, 'Module Inserter', '', true)

    local scroll_table = Gui.scroll_table(container, (config.module_slot_max + 2) * 36, config.module_slot_max + 1)

    for i=1, config.default_module_row_count do
        scroll_table.add{
            name = 'module_mm_' .. i .. '_0',
            type = 'choose-elem-button',
            elem_type = 'entity',
            elem_filters = elem_filter.name,
            style = 'slot_button'
        }

        for j=1, config.module_slot_max do
            scroll_table.add{
                name = 'module_mm_' .. i .. '_' .. j,
                type = 'choose-elem-button',
                elem_type = 'item',
                elem_filters = elem_filter.normal,
                style = 'slot_button'
            }
        end
    end

    button_apply(container)

    return container.parent
end)
:static_name(Gui.unique_static_name)
:add_to_left_flow()

Gui.left_toolbar_button('item/productivity-module-3', {'module.main-tooltip'}, module_container, function(player)
	return Roles.player_allowed(player, 'gui/module')
end)

Event.add(defines.events.on_gui_elem_changed, function(event)
    if event.element.name:sub(1, 10) == 'module_mm_' then
        if event.element.name:sub(-1) == '0' then
            row_set(game.players[event.player_index], 'module_mm_' .. event.element.name:sub(-3):sub(1, 1) .. '_')
        end
    end
end)
