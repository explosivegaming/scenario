--[[-- Commands Module - Artillery
    - Adds a command that help shot artillery
    @commands Artillery
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'
local Selection = require 'modules.control.selection' --- @dep modules.control.selection
local SelectionArtyArea = 'ArtyArea'

--- align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {
        left_top = {x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y)},
        right_bottom = {x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y)}
    }
end

--- when an area is selected to add protection to the area
Selection.on_selection(SelectionArtyArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)

    if player == nil then
        return
    end

    local count = 0

    for _, e in pairs(player.surface.find_entities_filtered({area=area, type={'unit-spawner', 'turret'}, force='enemy'})) do
        player.surface.create_entity{name='artillery-flare', position=e.position, force=player.force, life_time=30, movement={0, 0}, height=0, vertical_speed=0, frame_speed=0}
        count = count + 1

        if count > 800 then
            break
        end
    end
end)

Commands.new_command('artillery-target-remote', 'Artillery Target Remote')
:register(function(player)
    if Selection.is_selecting(player, SelectionArtyArea) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionArtyArea)
    end

    return Commands.success
end)
