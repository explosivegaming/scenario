--- Adds linked chest into the game
-- @addon Linked Chest

local Global = require 'utils.global' --- @dep utils.global
local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
-- local Event = require 'utils.event' --- @dep utils.event
-- local format_number = require('util').format_number --- @dep util

local linked = {}
Global.register(linked, function(tbl)
    linked = tbl
end)

linked.chest = {}
linked.belt = {}

local linked_container

local function linked_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=6, name='steel-chest', force=player.force, limit=1}

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

local function linked_chest_create(surface, pos, player)
    local linked_storage = surface.create_entity{name='linked-chest', position=pos, force='neutral'}
    linked_storage.destructible = false
    linked_storage.minable = false
    linked_storage.operable = true
    linked_storage.last_user = player

    table.insert(linked.chest, linked_storage)
end

local function linked_chest_remove(surface, pos, player)
    local entities = surface.find_entities_filtered{name={'linked-chest'}, position=pos, radius=6, force='neutral', limit=1}

    if (not entities or #entities == 0) then
        player.print('Entity not found')
        return
    end

    for _, entity in pairs(entities) do
        entity.destroy()

        for k, v in pairs(linked.chest) do
            if v == nil then
                linked.chest[k] = nil

            elseif not v.valid then
                linked.chest[k] = nil
            end
        end
    end
end

--[[
local function linked_belt_create(surface, pos, player)
    local linked_belt = surface.create_entity{name='linked-belt', position=pos, force='neutral'}
    linked_belt.destructible = false
    linked_belt.minable = false
    linked_belt.operable = true
    linked_belt.last_user = player
    table.insert(linked.belt, linked_belt)
end

local function linked_belt_remove(surface, pos, player)
    local entities = surface.find_entities_filtered{name={'linked-belt'}, position=pos, radius=6, force='neutral', limit=1}

    if (not entities or #entities == 0) then
        player.print('Entity not found')
        return
    end

    for _, entity in pairs(entities) do
        entity.destroy()

        for k, v in pairs(linked.belt) do
            if v == nil then
                linked.belt[k] = nil

            elseif not v.valid then
                linked.belt[k] = nil
            end
        end
    end
end
]]

local linked_gui_control_storage_add =
Gui.element{
    type = 'button',
    caption = 'Add Linked Chest'
}:style{
    width = 160
}:on_click(function(player, _, _)
    local pos = linked_convert_chest(player)

    if (pos) then
        linked_chest_create(player.surface, pos, player)
    end
end)

local linked_gui_control_storage_remove =
Gui.element{
    type = 'button',
    caption = 'Remove Linked Chest'
}:style{
    width = 160
}:on_click(function(player, _, _)
    linked_chest_remove(player.surface, player.position, player)
end)

--[[
local linked_gui_control_belt_add =
Gui.element{
    type = 'button',
    caption = 'Add Linked Belt'
}:style{
    width = 160
}:on_click(function(player, _, _)
    local pos = linked_convert_chest(player)

    if (pos) then
        linked_belt_create(player.surface, pos, player)
    end
end)

local linked_gui_control_belt_remove =
Gui.element{
    type = 'button',
    caption = 'Remove Linked Belt'
}:style{
    width = 160
}:on_click(function(player, element, _)
    linked_belt_remove(player.surface, player.position, player)
end)
]]

local linked_control_set =
Gui.element(function(_, parent, name)
    local linked_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(linked_set, 320, 2, 'disp')

    linked_gui_control_storage_add(disp)
    linked_gui_control_storage_remove(disp)
    --[[
    linked_gui_control_belt_add(disp)
    linked_gui_control_belt_remove(disp)
    ]]

    return linked_set
end)

linked_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 320)

    linked_control_set(container, 'linked_st')

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/linked-chest', 'Linked GUI', linked_container, function(player)
	return Roles.player_allowed(player, 'gui/linked')
end)
