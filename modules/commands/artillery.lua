--[[-- Commands Module - Artillery Remote
    - Adds commands that select enemy base in range
    @commands Artillery Remote
]]

local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Commands = require 'expcore.commands' --- @dep expcore.commands
local Selection = require 'modules.control.selection' --- @dep modules.control.selection

local SelectionAttackArea   = 'AttackArea'
local enemy_forces = {}

Event.add(defines.events.on_player_created, function(event)
    if event.player_index ~= 1 then return end
    local player = game.players[event.player_index]

    for _, force in pairs(game.forces) do
        if player.force.is_enemy(force) then
            table.insert(enemy_forces, force)
        end
    end
end)

--- Align an aabb to the grid by expanding it
local function aabb_align_expand(aabb)
    return {left_top = {x = math.floor(aabb.left_top.x), y = math.floor(aabb.left_top.y)}, right_bottom = {x = math.ceil(aabb.right_bottom.x), y = math.ceil(aabb.right_bottom.y)}}
end

Commands.new_command('auto-artillery-remote', 'Select all enemy in the area')
:add_alias('aar')
:register(function(player)
    if Selection.is_selecting(player, SelectionAttackArea) then
        Selection.stop(player)
    else
        Selection.start(player, SelectionAttackArea)    
        return Commands.success
    end
end)

--- When an area is selected to
Selection.on_selection(SelectionAttackArea, function(event)
    local area = aabb_align_expand(event.area)
    local player = game.get_player(event.player_index)
    
    for x=area.left_top.x, area.right_bottom.x do
        for y=area.left_top.x, area.right_bottom.y do
            local enemies = game.surface.find_entities_filtered{type={'turret', 'unit-spawner'}, position=position, radius=radius, force=enemy_forces}

            for _, target in pairs(enemies) do
                if string.find(turret.name, "worm") then
                    surface.create_entity{name = 'artillery-flare', position=target, force=player.force, frame_speed=0, vertical_speed=0, height=0, movement={0, 0}}
                end
            end
        end
    end

    game.print{'expcom-aar.set', #enemies}
end)
