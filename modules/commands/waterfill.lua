--- Adds a waterfill
-- @addon Virtual Waterfill

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'
local Selection = require 'modules.control.selection' --- @dep modules.control.selection
local SelectionConvertArea = 'ConvertArea'

--- Align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = {x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y)},
        right_bottom = {x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y)}
    }
end

Commands.new_command('waterfill', 'Change tile to water')
:register(function(player)
    local inv = player.get_main_inventory()

    if (inv.get_item_count('cliff-explosives')) == 0 then
        return player.print{'vlayer.waterfill-cliff'}
    end

    if Selection.is_selecting(player, SelectionConvertArea) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionConvertArea)
        return Commands.success{'vlayer.entered-area-selection'}
    end

    return Commands.success
end)

--- When an area is selected to add protection to the area
Selection.on_selection(SelectionConvertArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)

    local entities = player.surface.find_entities_filtered{area=area, name='steel-chest'}
    local tiles_to_make = {}
    local inv = player.get_main_inventory()
    inv = inv.get_item_count('cliff-explosives')

    for _, entity in pairs(entities) do
        if inv >= 1 then
            if entity.get_inventory(defines.inventory.chest).is_empty() then
                if (player.position.x ~= entity.position.x) and (player.position.y ~= entity.position.y) then
                    entity.destroy()
                    table.insert(tiles_to_make, {name='water-mud', position=entity.position})
                else
                    player.print{'vlayer.waterfill-distance'}
                end
            end

            inv = inv - 1
        else
            break
        end
    end

    event.surface.set_tiles(tiles_to_make)
end)