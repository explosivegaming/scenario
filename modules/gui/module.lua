---- module inserter
-- @addon module

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local config = require 'config.module' --- @dep config.vlayer
local Selection = require 'modules.control.selection' --- @dep modules.control.selection
local SelectionModuleArea = 'ModuleArea'

local module_container
local machine_name = {}
local module_filter = {}
local module_allowed = {}

module_filter.normal = {{
    filter = 'type',
    type = 'module'
}}

module_filter.prod = {{
    filter = 'type',
    type = 'module'
}, {
    filter = 'name',
    name = 'productivity',
    invert = true
}}

for k, _ in pairs(config.machine) do
    table.insert(machine_name, k)
end


for _, r in pairs(game.item_prototypes['productivity-module'].limitations) do
    module_allowed[r] = true
end

--- align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = {x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y)},
        right_bottom = {x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y)}
    }
end

--- when an area is selected to add protection to the area
Selection.on_selection(SelectionModuleArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)
    local frame = Gui.get_left_element(player, module_container)

    -- name, module list, row machine, column module
    local mn = {}
    local m = {}

    for i=1, config.module_row do
        local mma = frame.container.scroll.table['module_mm_' .. i .. '_0'].elem_value

        if mma ~= nil then
            m[mma] = {}

            for j=1, config.module_slot_max do
                local mmo = frame.container.scroll.table['module_mm_' .. i .. '_' .. j].elem_value

                if mmo ~= nil then
                    if m[mma][mmo] == nil then
                        m[mma][mmo] = 1
                    else
                        m[mma][mmo] = m[mma][mmo] + 1
                    end
                end
            end

            if m[mma] ~= nil then
                table.insert(mn, mma)
            end
        end
    end

    local entities = player.surface.find_entities_filtered{area = area, name = mn, force = player.force}

    -- machine current module, machine current recipe
    for _, entity in pairs(entities) do
        local mcm = entity.get_module_inventory()

        -- remove current logistic request
        local machine_module_requested = player.surface.find_entities_filtered{area = {left_top = {x = entity.position.x - 0.1, y = entity.position.y - 0.1}, right_bottom={x = entity.position.x + 0.1, y = entity.position.y + 0.1}}, name = 'item-request-proxy', force = player.force}

        for _, machine_requested in pairs(machine_module_requested) do
            if machine_requested.proxy_target == entity then
                local request = machine_requested.item_requests

                for module_name, _ in pairs(request) do
                    if game.item_prototypes[module_name].type == 'module' then
                        request[module_name] = nil
                    end
                end

                if next(request) == nil then
                    request.destroy()
                else
                    request.item_requests = request
                end
            end
        end

        if mcm ~= nil then
            mcm = mcm.get_contents()

            if mcm ~= m[entity.name] then
                for n, c in pairs(mcm) do
                    player.insert({name=n, count=c})
                end

                mcm.clear()
            end
        end

        local mcr = entity.get_recipe()

        -- insert
        if mcr ~= nil then
            if module_allowed[mcr.name] then
                entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=m[entity.name]}
            end
        else
            entity.surface.create_entity{name='item-request-proxy', target=entity, position=entity.position, force=entity.force, modules=m[entity.name]}
        end
    end
end)

local function row_set(player, element)
    local name = element.name:sub(1, -1 - math.floor(math.log(config.module_slot_max)))

    if element.elem_value ~= nil then
        local frame = Gui.get_left_element(player, module_container)

        for i=1, config.module_slot_max do
            if i <= game.entity_prototypes[element.elem_value].module_inventory_size then
                frame.container.scroll.table[name .. i].enabled = true
                frame.container.scroll.table[name .. i].elem_value = config.machine[element.elem_value].d
            else
                frame.container.scroll.table[name .. i].enabled = false
                frame.container.scroll.table[name .. i].elem_value = nil
            end
            frame.container.scroll.table[name .. i].elem_filters = module_filter.normal
        end
    else
        local frame = Gui.get_left_element(player, module_container)
        local mf = module_filter.normal

        if config.machine[element.elem_value].p == false then
            mf = module_filter.prod
        end

        for i=1, config.module_slot_max do
            frame.container.scroll.table[name .. i].enabled = true
            frame.container.scroll.table[name .. i].elem_filters = mf
            frame.container.scroll.table[name .. i].elem_value = nil
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

    for i=1, config.module_row do
        scroll_table.add{
            name = 'module_mm_' .. i .. '_0',
            type = 'choose-elem-button',
            elem_type = 'entity',
            elem_filters = {{
                filter = 'name',
                name = machine_name
            }},
            style = 'slot_button'
        }

        for j=1, config.module_slot_max do
            scroll_table.add{
                name = 'module_mm_' .. i .. '_' .. j,
                type = 'choose-elem-button',
                elem_type = 'item',
                elem_filters = module_filter.normal,
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
    row_set(game.players[event.player_index], event.element)
end)