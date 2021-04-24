--[[-- Commands Module - Protection
    - Adds a commands that can add and remove protection
    @commands Protection
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local EntityProtection = require 'modules.control.protection' --- @dep modules.control.protection
local Selection = require 'modules.control.selection' --- @dep modules.control.selection

local SelectionProtectEntity = 'ProtectEntity'
local SelectionProtectArea   = 'ProtectArea'

--- Test if a point is inside an aabb
local function aabb_point_enclosed(point, aabb)
    return point.x >= aabb.left_top.x and point.y >= aabb.left_top.y
        and point.x <= aabb.right_bottom.x and point.y <= aabb.right_bottom.y
end

--- Test if an aabb is inside another aabb
local function aabb_area_enclosed(aabbOne, aabbTwo)
    return aabb_point_enclosed(aabbOne.left_top, aabbTwo)
        and aabb_point_enclosed(aabbOne.right_bottom, aabbTwo)
end

--- Align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = { x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y) },
        right_bottom = { x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y) }
    }
end

--- Toggles entity protection selection
-- @command protect-entity
Commands.new_command('protect-entity', 'Toggles entity protection selection, hold shift to remove protection')
:add_alias('pe')
:register(function(player)
    if Selection.is_selecting(player, SelectionProtectEntity) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionProtectEntity)
        return Commands.success{'expcom-protection.entered-entity-selection'}
    end
end)

--- Toggles area protection selection
-- @command protect-area
Commands.new_command('protect-area', 'Toggles area protection selection, hold shift to remove protection')
:add_alias('pa')
:register(function(player)
    if Selection.is_selecting(player, SelectionProtectArea) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionProtectArea)
        return Commands.success{'expcom-protection.entered-area-selection'}
    end
end)

--- When an area is selected to add protection to entities
Selection.on_selection(SelectionProtectEntity, function(event)
    for _, entity in ipairs(event.entities) do
        EntityProtection.add_entity(entity)
    end
    return Commands.success{'expcom-protection.protected-entities', #event.entities}
end)

--- When an area is selected to remove protection from entities
Selection.on_alt_selection(SelectionProtectEntity, function(event)
    for _, entity in ipairs(event.entities) do
        EntityProtection.remove_entity(entity)
    end
    return Commands.success{'expcom-protection.unprotected-entities', #event.entities}
end)

--- When an area is selected to add protection to the area
Selection.on_selection(SelectionProtectArea, function(event)
    local area = aabb_align_expand(event.area)
    local areas = EntityProtection.get_areas(event.surface)
    for _, next_area in pairs(areas) do
        if aabb_area_enclosed(area, next_area) then
            return Commands.error{'expcom-protection.already-protected'}
        end
    end
    EntityProtection.add_area(event.surface, area)
    return Commands.success{'expcom-protection.protected-area'}
end)

--- When an area is selected to remove protection from the area
Selection.on_alt_selection(SelectionProtectArea, function(event)
    local area = aabb_align_expand(event.area)
    local areas = EntityProtection.get_areas(event.surface)
    for _, next_area in pairs(areas) do
        if aabb_area_enclosed(next_area, area) then
            EntityProtection.remove_area(event.surface, next_area)
            Commands.print{'expcom-protection.unprotected-area'}
        end
    end
end)

--- When there is a repeat offence print it in chat
Event.add(EntityProtection.events.on_repeat_violation, function(event)
    local player_name = format_chat_player_name(event.player_index)
    Roles.print_to_roles_higher('Regular', {'expcom-protection.repeat-offence', player_name, event.entity.localised_name, event.entity.position.x, event.entity.position.y})
end)