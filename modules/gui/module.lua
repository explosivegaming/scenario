---- module inserter
-- @addon module

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.module' --- @dep config.module
local Selection = require 'modules.control.selection' --- @dep modules.control.selection
local SelectionModuleArea = 'ModuleArea'

--- align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = {x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y)},
        right_bottom = {x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y)}
    }
end

local module_container

local machine_name = {}

for k, _ in pairs(config.machine) do
    table.insert(machine_name, k)
end

local module_allowed = {
    ['advanced-circuit'] = true,
    ['automation-science-pack'] = true,
    ['battery'] = true,
    ['chemical-science-pack'] = true,
    ['copper-cable'] = true,
    ['copper-plate'] = true,
    ['electric-engine-unit'] = true,
    ['electronic-circuit'] = true,
    ['empty-barrel'] = true,
    ['engine-unit'] = true,
    ['explosives'] = true,
    ['flying-robot-frame'] = true,
    ['iron-gear-wheel'] = true,
    ['iron-plate'] = true,
    ['iron-stick'] = true,
    ['logistic-science-pack'] = true,
    ['low-density-structure'] = true,
    ['lubricant'] = true,
    ['military-science-pack'] = true,
    ['nuclear-fuel'] = true,
    ['plastic-bar'] = true,
    ['processing-unit'] = true,
    ['production-science-pack'] = true,
    ['rocket-control-unit'] = true,
    ['rocket-fuel'] = true,
    ['rocket-part'] = true,
    ['steel-plate'] = true,
    ['stone-brick'] = true,
    ['sulfur'] = true,
    ['sulfuric-acid'] = true,
    ['uranium-fuel-cell'] = true,
    ['utility-science-pack'] = true,
    ['basic-oil-processing'] = true,
    ['advanced-oil-processing'] = true,
    ['coal-liquefaction'] = true,
    ['heavy-oil-cracking'] = true,
    ['light-oil-cracking'] = true,
    ['solid-fuel-from-light-oil'] = true,
    ['solid-fuel-from-petroleum-gas'] = true,
    ['solid-fuel-from-heavy-oil'] = true,
    ['uranium-processing'] = true,
    ['nuclear-fuel-reprocessing'] = true,
    ['kovarex-enrichment-process'] = true
}

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
            if r ~= nil then
                r.destroy{raise_destroy=true}
            end
        end

        local m_current_module = entity.get_module_inventory()

        if m_current_module ~= nil then
            local m_current_module_content = m_current_module.get_contents()

            if m_current_module_content ~= nil then
                for k, m in pairs(m_current_module_content) do
                    player.surface.spill_item_stack(entity.bounding_box.left_top, {name=k, count=m}, true, player.force, false)
                end
            end

            m_current_module.clear()
        end
    end
end

local function apply_module(player, area, machine, module)
    for _, entity in pairs(player.surface.find_entities_filtered{area=area, name=machine, force=player.force}) do
        if config.machine_craft[machine] ~= nil then
            if config.machine_craft[machine] then
                local m_current_recipe = entity.get_recipe()

                if m_current_recipe ~= nil then
                    if module_allowed[m_current_recipe.name] ~= nil then
                        if module_allowed[m_current_recipe.name] then
                            entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=module}
                        end
                    end

                else
                    entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=module}
                end
            end

        else
            entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=module}
        end


    end
end

--- when an area is selected to add protection to the area
Selection.on_selection(SelectionModuleArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)

    if player == nil then
        return
    end

    local frame = Gui.get_left_element(player, module_container)

    for i=1, config.default_module_row_count do
        local m_machine = frame.container.scroll.table['module_mm_' .. i .. '_0'].elem_value

        if m_machine ~= nil then
            local m_module = {}

            for j=1, config.module_slot_max do
                local mmo = frame.container.scroll.table['module_mm_' .. i .. '_' .. j].elem_value

                if mmo ~= nil then
                    if m_module[mmo] == nil then
                        m_module[mmo] = 1
                    else
                        m_module[mmo] = m_module[mmo] + 1
                    end
                end
            end

            if m_module ~= nil then
                clear_module(player, area, m_machine)
                apply_module(player, area, m_machine, m_module)
            end
        end
    end
end)

local function row_set(player, element)
    local frame = Gui.get_left_element(player, module_container)

    if frame.container.scroll.table[element .. '0'].elem_value ~= nil then
        for i=1, config.module_slot_max do
            if i <= game.entity_prototypes[frame.container.scroll.table[element .. '0'].elem_value].module_inventory_size then
                frame.container.scroll.table[element .. i].enabled = true
                frame.container.scroll.table[element .. i].elem_value = config.machine[frame.container.scroll.table[element .. '0'].elem_value]
            else
                frame.container.scroll.table[element .. i].enabled = false
                frame.container.scroll.table[element .. i].elem_value = nil
            end
            frame.container.scroll.table[element .. i].elem_filters = elem_filter.normal
        end
    else
        local mf = elem_filter.normal

        if config.machine_prod_disallow[element.elem_value] ~= nil then
            if config.machine_prod_disallow[element.elem_value] then
                mf = elem_filter.prod
            end
        end

        for i=1, config.module_slot_max do
            frame.container.scroll.table[element .. i].enabled = true
            frame.container.scroll.table[element .. i].elem_filters = mf
            frame.container.scroll.table[element .. i].elem_value = nil
        end
    end
end

local button_apply =
Gui.element{
    name = 'module_b',
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
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, (config.module_slot_max + 2) * 36)
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
