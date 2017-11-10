--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local warp_tiles = {}

local warp_entities = {}

local warp_radius = 2
local spawn_warp_scale = 5
local warp_tile = 'lab-dark-1'
local warp_partern = 'lab-dark-2'
local replace_tile = 'grass'
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}

define_command('warp-point',{'warp-point.help'},{'name'},function(player,event,args)
    if player == '<server>' then
        print('Server cant use this command')
    else
        if global.warp.warps[args[1]] then player.print{'warp-point.used'} return end
        make_way_point(player,args[1])
    end
end

ExpGui.add_input.button('goto-warp-point',{'warp-point.goto-name'},{'warp-point.goto-tooltip'},function(player,element)
    if global.warp.cooldown[player.index] > 0 then player.print{'warp-point.cooldown',global.warp.cooldown[player.index]} end
    local warp = global.warp.warps[element.parent.name]
    player.teleport(warp.surface.find_non_colliding_position("player", warp.position, 32, 1),warp.surface)
    global.warp.cooldown[player.index] = 60
end)

ExpGui.add_input.button('remove-warp-point',{'warp-point.remove-name'},{'warp-point.remove-tooltip'},function(player,element)
    local warp_name = element.parent.name
    remove_warp_point(warp_name)
end)

ExpGui.add_frame.left('warp-points',{'warp-point.name'},{'warp-point.tooltip'},false,function(player,frame)
    if global.warp.can_open[player.index] == false then return end
    local warp_list = frame.add{name="scroll",type = "scroll-pane", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
    warp_list.style.maximal_height = 100
    for name,warp in pairs(global.warp.warps) do
        local flow = warp_list.add{name=name,type='flow',direction='horizontal'}
        flow.add{name='name',type='label',text=name}
        ExpGui.add_input.draw_button(flow,'goto-warp-point')
        if ranking.rank_allowed(ranking.get_player_rank(player),'warp-point') then
            ExpGui.add_input.draw_button(flow,'remove-warp-point')
        end
    end
end)

function remove_warp_point(name)
    if not global.warp.warps[name] then return end
    local surface =  global.warp.warps[name].surface
    local offset = global.warp.warps[name].position
    local tiles = {}
    for x = -warp_radius-2, warp_radius+2 do
        for y = -warp_radius-2, warp_radius+2 do
            if x^2+y^2 < warp_radius^2 then
                table.insert(base_tiles,{name=replace_tile,position={x+offset.x,y+offset.y}})
                local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end
            end
        end
    end
    if global.warp.warps[name].valid then global.warp.warps[name].destroy() end
    global.warp.warps[name] = nil
    for _,player in pairs(game.connected_players) do
        ExpGui.draw_frame.left(player,'warp-points',true)
    end
end

function make_way_point(player,name)
    local surface =  player.surface
    local offset = player.position
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
    local tag = player.force.add_chart_tag(surface,{position={math.floor(player.position.x),math.floor(player.position.y)},text=name,icon={type='item',name=warp_item}})
    global.warp.warps[name] = {tag=tag,surface=surface,position=tag.position}
end

Event.register(defines.events.on_tick,function(event)
    if not (event.tick % 60 == 0) then return end
    for index,time in pairs(global.warps.cooldown) do
        if time > 0 then 
            time = time - 1 
            -- if the cooldown has ran out then tell the player
            if time == 0 then game.players[index].print{'warp-point.cooldown-zreo'} end
        end
    end
    for _,player in pairs(game.connected_players) do
        if player.surface.get_tile(player.position).name == warp_tile or player.surface.get_tile(player.position).name == warp_partern then
            global.warp.can_open[player.index] = true
            player.print{'warp-point.enter'}
        elseif player.position.x^2+player.position.y^2 < (warp_radius*spawn_warp_scale)^2 then -- this makes spawn a warp point
            global.warp.can_open[player.index] = true
            player.print{'warp-point.enter'}
        else
            global.warp.can_open[player.index] = false
            if mod_gui.get_frame_flow(player)['warp-points'] then mod_gui.get_frame_flow(player)['warp-points'].style.visible = false end
        end
    end
end)

Event.register(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local player = game.players[event.player_index]
        local tag = player.force.add_chart_tag(player.surface,{position={0,0},text='Spawn',icon={type='item',name=warp_item}})
        global.warp.warps[name] = {tag=tag,surface=player.surface,position={0,0}}
    end
end)
Event.register(Event.soft_init,function() global.warp = {warps={},can_open={},cooldown={}} end)