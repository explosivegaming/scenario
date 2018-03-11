--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local warp_tiles = {
    {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
    {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
}

local warp_entities = {
    {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
    {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
    {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
}

local warp_radius = 4
local spawn_warp_scale = 5
local warp_tile = 'tutorial-grid'
local warp_limit = 60
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}

local function _warps(reset)
    global.addons = not reset and global.addons or {}
    global.addons.warps = not reset and global.addons.warps or {warps={},cooldowns={}}
    return global.addons.warps
end

local function remove_warp_point(name)
    local warp = _warps().warps[name]
    if not warp then return end
    local surface =  warp.surface
    local offset = warp.position
    local tiles = {}
    local tiles = {}
    for x = -warp_radius-2, warp_radius+2 do
        for y = -warp_radius-2, warp_radius+2 do
            if x^2+y^2 < (warp_radius+1)^2 then
                table.insert(tiles,{name=warp.old_tile,position={x+offset.x,y+offset.y}})
                local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end
            end
        end
    end
    surface.set_tiles(tiles)
    if warp.tag.valid then warp.tag.destroy() end
    _warps().warps[name] = nil
    Gui.left.update('warp-list')
end

local function make_warp_point(position,surface,force,name)
    local warp = _warps().warps[name]
    if warp then return end; warp = nil
    local offset = {x=math.floor(position.x),y=math.floor(position.y)}
    local old_tile = surface.get_tile(offset).name
    local base_tiles = {}
    local tiles = {}
    -- this makes a base plate to make the warp point
    for x = -warp_radius-2, warp_radius+2 do
        for y = -warp_radius-2, warp_radius+2 do
            if x^2+y^2 < warp_radius^2 then
                table.insert(base_tiles,{name=warp_tile,position={x+offset.x,y+offset.y}})
            end
        end
    end
    surface.set_tiles(base_tiles)
    -- this adds the patern and entities
    for _,position in pairs(warp_tiles) do
        table.insert(tiles,{name=warp_tile,position={position[1]+offset.x+global_offset.x,position[2]+offset.y+global_offset.y}})
    end
    surface.set_tiles(tiles)
    for _,entity in pairs(warp_entities) do
        local entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
        entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
    end
    local tag = force.add_chart_tag(surface,{
        position={offset.x+0.5,offset.y+0.5},
        text='Warp: '..name,
        icon={type='item',name=warp_item}
    })
    _warps().warps[name] = {tag=tag,surface=surface,position=tag.position,old_tile=old_tile}
    Gui.left.update('warp-list')
end

commands.add_command('make-warp', 'Make a warp point at your location', {'name',true}, function(event,args)
    if not game.player then return end
    local position = game.player.position
    local name = args.name
    if _warps().warps[name] then player_return({'warp-system.name-used'},defines.text_color.med) return commands.error end
    make_warp_point(position,game.player.surface,game.player.force,name)
end)

local remove_warp = Gui.inputs.add{
    type='button',
    name='remove-warp-point',
    caption='utility/remove',
    tooltip={'warp-system.remove-tooltip'}
}:on_event('click',function(event)
    local name = event.element.parent.name
    remove_warp_point(name)
end)

local go_to_warp = Gui.inputs.add{
    type='button',
    name='go-to-warp-point',
    caption='utility/export_slot',
    tooltip={'warp-system.go-to-tooltip'}
}:on_event('click',function(event)
    local player = Game.get_player(event)
    local cooldown = _warps().cooldowns[event.player_index] or 0
    local warp = _warps().warps[event.element.parent.name]
    if cooldown > 0 then player_return({'warp-system.cooldown',cooldown},nil,event) return end
    if player.vehicle then player.vehicle.set_driver(nil) end
    if player.vehicle then player.vehicle.set_passenger(nil) end
    if player.vehicle then return end
    player.teleport(warp.surface.find_non_colliding_position('player',warp.position,32,1),warp.surface)
    if not Ranking.get_rank(player):allowed('always-warp') then 
        event.element.parent.parent.parent.parent.style.visible = false
        _warps().cooldowns[event.player_index] = warp_limit
    end
end)

Gui.left.add{
    name='warp-list',
    caption='item/'..warp_item,
    tooltip={'warp-system.tooltip'},
    draw=function(frame)
        local player = Game.get_player(frame.player_index)
        frame.caption={'warp-system.name'}
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
        for name,warp in pairs(_warps().warps) do
            if not warp.tag or not warp.tag.valid then
                player.force.add_chart_tag(warp.surface,{
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
            local btn = go_to_warp:draw(_flow)
            btn.style.height = 20
            btn.style.width = 20
            if Ranking.get_rank(player):allowed('make-warp') and name ~= 'Spawn' then
                local btn = remove_warp:draw(_flow)
                btn.style.height = 20
                btn.style.width = 20
            end
        end
        local cooldown = _warps().cooldowns[player.index] or 0
        if cooldown > 0 then frame.style.visible = false return
        elseif Ranking.get_rank(player):allowed('always-warp') then return
        elseif player.surface.get_tile(player.position).name == warp_tile
            and player.surface.name == 'nauvis' 
            then return
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then return
        else frame.style.visible = false end
    end,
    can_open=function(player)
        local cooldown = _warps().cooldowns[player.index] or 0
        if Ranking.get_rank(player):allowed('always-warp') then return true
        elseif player.surface.get_tile(player.position).name == warp_tile
        and player.surface.name == 'nauvis' 
        then return true
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then return true
        elseif cooldown > 0 then return {'warp-system.cooldown',cooldown}
        else return {'warp-system.not-on-warp'} end
    end,
    open_on_join=true
}

Event.register(defines.events.on_tick,function(event)
    if not (event.tick % 60 == 0) then return end
    for index,time in pairs(_warps().cooldowns) do
        if time > 0 then
            _warps().cooldowns[index] = time-1 
            if _warps().cooldowns[index] == 0 then player_return({'warp-system.cooldown-zero'},defines.text_color.low,index) end
        end
    end
end)

Event.register(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    local cooldown = _warps().cooldowns[player.index] or 0
    local tile = player.surface.get_tile(player.position).name
    if not Ranking.get_rank(player):allowed('always-warp') and cooldown == 0 then
        if tile == warp_tile and player.surface.name == 'nauvis' then 
            mod_gui.get_frame_flow(player)['warp-list'].style.visible = true
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then 
            mod_gui.get_frame_flow(player)['warp-list'].style.visible = true
        else mod_gui.get_frame_flow(player)['warp-list'].style.visible = false end
    end
end)

Event.register(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local player = Game.get_player(event)
        player.force.chart(player.surface, {{player.position.x - 20, player.position.y - 20}, {player.position.x + 20, player.position.y + 20}})
        local tag = player.force.add_chart_tag(player.surface,{
            position={0,0},
            text='Warp: Spawn',
            icon={type='item',name=warp_item}
        })
        _warps().warps['Spawn'] = {tag=tag,surface=player.surface,position={0,0}}
    end
end)