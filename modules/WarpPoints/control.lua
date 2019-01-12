--- Creates a warp point system which makes moving around large maps easier.
-- @module WarpPoints@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alias ThisModule

-- Module Require
local Gui = require('ExpGamingCore.Gui')
local Game = require('FactorioStdLib.Game')
local Role -- ExpGamingCore.Role@^4.0.0

-- Local Variables
local warp_tiles = require(module_path..'/src/warp_tiles')
local warp_entities = require(module_path..'/src/warp_entities')

local warp_radius = 4
local spawn_warp_scale = 5
local warp_tile = 'tutorial-grid'
local warp_limit = 60
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}
local warp_min_distance = 25

-- Module Define
local _global = global
local global
local module_verbose = false
local ThisModule = {
    on_init=function(self)
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Command'] then require(module_path..'/src/commands',{self=self,warps=global,warp_min_distance=warp_min_distance}) end
    end
}

-- Global Define
global = _global{
    warps={}, -- 0,0 is always a warp
    cooldowns={}
}

-- Function Define

--- Removes a warp point from the list, and then updates the gui
-- @usage ThisModule.remove_warp_point(name) -- name cant be spawn
-- @tparam string name the name of the warp point
function ThisModule.remove_warp_point(name)
    local warp = global.warps[name]
    if not warp then return end
    local surface =  game.surfaces[warp.surface]
    local offset = warp.position
    local tiles = {}
    -- clears the area where the warp was
    for x = -warp_radius, warp_radius do
        for y = -warp_radius, warp_radius do
            if x^2+y^2 < (warp_radius+1)^2 then
                table.insert(tiles,{name=warp.old_tile,position={x+offset.x,y+offset.y}})
                local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end
            end
        end
    end
    surface.set_tiles(tiles)
    if warp.tag.valid then warp.tag.destroy() end
    global.warps[name] = nil
    ThisModule.Gui()
end

--- Adds a warp point from the list, and then updates the gui
-- @usage ThisModule.make_warp_point({x=10,y=10},surface,force,name)
-- @tparam table position the position of the new warp point
-- @tparam surface surface the surface that the warp point is on
-- @tparam force force the force that the warp point will belong to
-- @tparam string name the name of the warp point to be made
function ThisModule.make_warp_point(position,surface,force,warpName)
    local warp = global.warps[warpName]
    if warp then return end
    local offset = {x=math.floor(position.x),y=math.floor(position.y)}
    local old_tile = surface.get_tile(offset).name
    local base_tiles = {}
    local tiles = {}
    -- this makes a base plate to make the warp point
    for x = -warp_radius, warp_radius do
        for y = -warp_radius, warp_radius do
            if x^2+y^2 < warp_radius^2 then
                table.insert(base_tiles,{name=warp_tile,position={x+offset.x,y+offset.y}})
            end
        end
    end
    surface.set_tiles(base_tiles)
    -- this adds the pattern and entities
    for _,pos in pairs(warp_tiles) do
        table.insert(tiles,{name=warp_tile,position={pos[1]+offset.x+global_offset.x,pos[2]+offset.y+global_offset.y}})
    end
    surface.set_tiles(tiles)
    for _,entity in pairs(warp_entities) do
        entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
        entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
    end
    -- creates a tag on the map for the wap point
    local tag = force.add_chart_tag(surface,{
        position={offset.x+0.5,offset.y+0.5},
        text='Warp: '..warpName,
        icon={type='item',name=warp_item}
    })
    global.warps[warpName] = {tag=tag,surface=surface.index,position=tag.position,old_tile=old_tile}
    local _temp = {Spawn=global.warps.Spawn}
    global.warps.Spawn = nil
    for name,data in pairs(table.keysort(global.warps)) do _temp[name] = data end
    global.warps = _temp
    ThisModule.Gui()
end

local remove_warp = Gui.inputs{
    type='button',
    name='remove-warp-point',
    caption='utility/remove',
    tooltip={'WarpPoints.remove-tooltip'}
}:on_event('click',function(event)
    local name = event.element.parent.name
    ThisModule.remove_warp_point(name)
end)

local go_to_warp = Gui.inputs{
    type='button',
    name='go-to-warp-point',
    caption='utility/export_slot',
    tooltip={'WarpPoints.go-to-tooltip'}
}:on_event('click',function(event)
    local player = Game.get_player(event)
    local cooldown = global.cooldowns[event.player_index] or 0
    local warp = global.warps[event.element.parent.name]
    if not warp then return end
    if cooldown > 0 then player_return({'WarpPoints.cooldown',cooldown},nil,event) return end
    if player.vehicle then player.vehicle.set_driver(nil) end
    if player.vehicle then player.vehicle.set_passenger(nil) end
    if player.vehicle then return end
    local surface = game.surfaces[warp.surface]
    player.teleport(surface.find_non_colliding_position('player',warp.position,32,1),surface)
    if not Role and not player.admin or Role and not Role.allowed(player,'always-warp') then
        event.element.parent.parent.parent.parent.style.visible = false
        global.cooldowns[event.player_index] = warp_limit
    end
end)

ThisModule.Gui = Gui.left{
    name='warp-list',
    caption='item/'..warp_item,
    tooltip={'WarpPoints.tooltip'},
    draw=function(self,frame)
        local player = Game.get_player(frame.player_index)
        frame.caption={'WarpPoints.name'}
        local warp_list = frame.add{
            type='scroll-pane',
            direction='vertical', 
            vertical_scroll_policy='auto', 
            horizontal_scroll_policy='never'
        }
        warp_list.vertical_scroll_policy = 'auto'
        warp_list.style.maximal_height = 150
        local table = warp_list.add{
            type='table',
            column_count=2
        }
        for name,warp in pairs(global.warps) do
            if not warp.tag or not warp.tag.valid then
                player.force.add_chart_tag(game.surfaces[warp.surface],{
                    position=warp.position,
                    text='Warp: '..name,
                    icon={type='item',name=warp_item}
                })
            end
            table.add{
                type='label',
                caption=name,
                style='caption_label'
            }
            local _flow = table.add{
                type='flow',
                name=name
            }
            local btn = go_to_warp(_flow)
            btn.style.height = 20
            btn.style.width = 20
            if not Role and player.admin and name ~= 'Spawn' or Role and Role.allowed(player,'make-warp') and name ~= 'Spawn' then
                local btn = remove_warp(_flow)
                btn.style.height = 20
                btn.style.width = 20
            end
        end
        local cooldown = global.cooldowns[player.index] or 0
        if cooldown > 0 then frame.style.visible = false return
        elseif not Role and player.admin or Role and Role.allowed(player,'always-warp') then return
        elseif player.surface.get_tile(player.position).name == warp_tile
            and player.surface.name == 'nauvis'
            then return
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then return
        else frame.style.visible = false end
    end,
    can_open=function(player)
        local cooldown = global.cooldowns[player.index] or 0
        if not Role and player.admin or Role and Role.allowed(player,'always-warp') then return true
        elseif player.surface.get_tile(player.position).name == warp_tile
        and player.surface.name == 'nauvis'
        then return true
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then return true
        elseif cooldown > 0 then return {'WarpPoints.cooldown',cooldown}
        else return {'WarpPoints.not-on-warp'} end
    end,
    open_on_join=true
}

-- Event Handlers Define
script.on_event(defines.events.on_tick,function(event)
    if not (event.tick % 60 == 0) then return end
    for index,time in pairs(global.cooldowns) do
        if time > 0 then
            global.cooldowns[index] = time-1
            if global.cooldowns[index] == 0 then player_return({'WarpPoints.cooldown-zero'},defines.textcolor.low,index) end
        end
    end
end)

script.on_event(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    local cooldown = global.cooldowns[player.index] or 0
    local tile = player.surface.get_tile(player.position).name
    if not Role and player.admin or Role and not Role.allowed(player,'always-warp') and cooldown == 0 then
        if tile == warp_tile and player.surface.name == 'nauvis' then
            ThisModule.Gui:open(player)
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then
            ThisModule.Gui:open(player)
        else ThisModule.Gui:close(player) end
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local player = Game.get_player(event)
        player.force.chart(player.surface, {{player.position.x - 20, player.position.y - 20}, {player.position.x + 20, player.position.y + 20}})
        local tag = player.force.add_chart_tag(player.surface,{
            position={0,0},
            text='Warp: Spawn',
            icon={type='item',name=warp_item}
        })
        global.warps['Spawn'] = {tag=tag,surface=player.surface.index,position={x=0,y=0}}
    end
end)

-- Module Return
return ThisModule