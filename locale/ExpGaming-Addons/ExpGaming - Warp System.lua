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
    {"small-lamp",-3,-2},{"small-lamp",-3,2},{"small-lamp",3,-2},{"small-lamp",3,2},
    {"small-lamp",-2,-3},{"small-lamp",2,-3},{"small-lamp",-2,3},{"small-lamp",2,3},
    {"small-electric-pole",-3,-3},{"small-electric-pole",3,3},{"small-electric-pole",-3,3},{"small-electric-pole",3,-3}
}

local warp_radius = 4
local spawn_warp_scale = 5
local warp_tile = 'lab-dark-1'
local warp_partern = 'lab-dark-2'
local warp_limit = 60
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}

define_command('warp-point',{'warp-point.help'},{'name',true},function(player,event,args)
    if player == '<server>' then
        print('Server cant use this command')
    else
        if global.warp.warps[table.concat(args,' ',1)] then player.print{'warp-point.used'} return end
        make_way_point(player,table.concat(args,' ',1))
    end
end) 

ExpGui.add_input.button('goto-warp-point',{'warp-point.goto-name'},{'warp-point.goto-tooltip'},function(player,element)
    if global.warp.can_open[player.index] == false then player.print{"warp-point.on-pad"} mod_gui.get_frame_flow(player)['warp-points'].style.visible = false return end
    if global.warp.cooldown[player.index] and global.warp.cooldown[player.index] > 0 then player.print{'warp-point.cooldown',global.warp.cooldown[player.index]} return end
    local warp = global.warp.warps[element.parent.name]
    if not warp.tag or not warp.tag.valid then warp.tag = player.force.add_chart_tag(warp.surface,{position=warp.position,text='Warp: '..element.parent.name,icon={type='item',name=warp_item}}) end
    player.teleport(warp.surface.find_non_colliding_position("player", warp.position, 32, 1),warp.surface)
    if not ranking.rank_allowed(ranking.get_player_rank(player),'free-warp') then element.parent.parent.parent.parent.style.visible = false global.warp.cooldown[player.index] = warp_limit end
end)

ExpGui.add_input.button('remove-warp-point',{'warp-point.remove-name'},{'warp-point.remove-tooltip'},function(player,element)
    local warp_name = element.parent.name
    remove_warp_point(warp_name)
end) 

ExpGui.add_frame.left('warp-points',('item/'..warp_item),{'warp-point.tooltip'},false,function(player,frame)
    frame.caption = {'warp-point.name'}
    local warp_list = frame.add{name="scroll",type = "scroll-pane", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
    warp_list.style.maximal_height = 100
    local table = warp_list.add{name="table",type='table',colspan=2}
    for name,warp in pairs(global.warp.warps) do
        if not warp.tag or not warp.tag.valid then warp.tag = player.force.add_chart_tag(warp.surface,{position=warp.position,text='Warp: '..name,icon={type='item',name=warp_item}}) end
        table.add{name='warp_'..name,style="caption_label_style",type='label',caption=name}
        local flow = table.add{name=name,type='flow',direction='horizontal'}
        ExpGui.add_input.draw_button(flow,'goto-warp-point')
        if ranking.rank_allowed(ranking.get_player_rank(player),'warp-point') and name ~= 'Spawn' then
            ExpGui.add_input.draw_button(flow,'remove-warp-point')
        end
    end
end)

function remove_warp_point(name)
    if not global.warp.warps[name] then return end
    local warp = global.warp.warps[name]
    local surface =  warp.surface
    local offset = warp.position
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
    global.warp.warps[name] = nil
    for _,player in pairs(game.connected_players) do
        ExpGui.draw_frame.left(player,'warp-points',true)
    end
end

function make_way_point(player,name)
    local surface =  player.surface
    local offset = {x=math.floor(player.position.x),y=math.floor(player.position.y)}
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
        table.insert(tiles,{name=warp_partern,position={position[1]+offset.x+global_offset.x,position[2]+offset.y+global_offset.y}})
    end
    surface.set_tiles(tiles)
    for _,entity in pairs(warp_entities) do
        local entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
        entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
    end
    -- this adds the warp point to the map
    local tag = player.force.add_chart_tag(surface,{position={offset.x+0.5,offset.y+0.5},text='Warp: '..name,icon={type='item',name=warp_item}})
    global.warp.warps[name] = {tag=tag,surface=surface,position=tag.position,old_tile=old_tile}
    for _,player in pairs(game.connected_players) do
        ExpGui.draw_frame.left(player,'warp-points',true)
    end
end

Event.register(defines.events.on_tick,function(event)
    if not (event.tick % 60 == 0) then return end
    for index,time in pairs(global.warp.cooldown) do
        if time > 0 then
            global.warp.cooldown[index] = time-1 
            if global.warp.cooldown[index] == 0 then game.players[index].print{'warp-point.cooldown-zero'} end
        end
    end
    for _,player in pairs(game.connected_players) do
        if player.surface.get_tile(player.position).name == warp_tile or player.surface.get_tile(player.position).name == warp_partern then
            if global.warp.can_open[player.index] ~= true then player.print{'warp-point.enter'} end
            global.warp.can_open[player.index] = true
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then -- this makes spawn a warp point
            if global.warp.can_open[player.index] ~= true and player.online_time > 100 then player.print{'warp-point.enter'} end
            global.warp.can_open[player.index] = true
        elseif not ranking.rank_allowed(ranking.get_player_rank(player),'free-warp') then
            global.warp.can_open[player.index] = false
            if mod_gui.get_frame_flow(player)['warp-points'].style.visible == true then player.print{"warp-point.on-pad"} mod_gui.get_frame_flow(player)['warp-points'].style.visible = false end
        end
    end
end)

Event.register(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local player = game.players[event.player_index]
        player.force.chart(player.surface, {{player.position.x - 20, player.position.y - 20}, {player.position.x + 20, player.position.y + 20}})
        local tag = player.force.add_chart_tag(player.surface,{position={0,0},text='Warp: Spawn',icon={type='item',name=warp_item}})
        global.warp.warps['Spawn'] = {tag=tag,surface=player.surface,position={0,0}}
    end
end)
Event.register(Event.soft_init,function() global.warp = {warps={},can_open={},cooldown={}} end)