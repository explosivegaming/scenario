--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local function fullscreen(cam,state)
    local player = game.players[cam.player_index]
    if state then
        cam.style.visible = false
        mod_gui.get_button_flow(player).style.visible = false
        global.map_store.players[player.index] = player.character
        player.set_controller{type=defines.controllers.ghost}
        player.teleport(cam.position,global.map_store.surface)
        local left = mod_gui.get_frame_flow(player)
        for _,frame_data in pairs(ExpGui.frames.left) do
            if left[frame_data.name] and frame_data.name ~= 'map-changes' then left[frame_data.name].style.visible = false end
        end
        player.gui.center.clear()
    else
        cam.style.visible = true
        mod_gui.get_button_flow(player).style.visible = true
        if global.map_store.players[player.index].valid then 
            player.teleport(cam.position,global.map_store.players[player.index].surface)
            player.set_controller{type=defines.controllers.character,character=global.map_store.players[player.index]}
        else
            player.teleport(cam.position,game.surfaces['nauvis'])
            player.create_character()
        end
        global.map_store.players[player.index] = nil
        local left = mod_gui.get_frame_flow(player)
        for _,frame_data in pairs(ExpGui.frames.left) do
            if left[frame_data.name] then left[frame_data.name].style.visible = frame_data.vis end
        end
    end
end

local function draw_entity(event)
    if not event.entity.last_user or event.entity.name == 'entity-ghost' then return end
    local entity = event.entity
    local player = game.players[event.player_index]
    local surface = global.map_store.surface
    local entity = {name=entity.name,position=entity.position,type=entity.type,direction=entity.direction,force=player.force}
    if surface.can_place_entity(entity) then
        surface.create_entity(entity).last_user = player
    else
        for _,destroy in pairs(surface.find_entities_filtered{position=entity.position}) do destroy.destroy() end
        local entity = surface.create_entity(entity)
        entity.last_user = player
        entity.active = false
    end
end

local function draw_ghosts(cam)
    local surface = global.map_store.surface
    local offset = cam.position
    local player = game.players[cam.player_index]
    local ghosts = nil
    if player.surface == surface then
    ghosts = global.map_store.players[player.index].surface.find_entities_filtered{area={{offset.x-50,offset.y-50},{offset.x+50,offset.y+50}},force=player.force}
    else ghosts = player.surface.find_entities_filtered{area={{offset.x-5,offset.y-5},{offset.x+5,offset.y+5}},force=player.force} end
    for _,entity in pairs(ghosts) do
        if entity.name ~= 'player' then
            local entity_name = entity.name == 'entity-ghost' and entity.ghost_name or entity.name
            local ghost = {name='entity-ghost',position=entity.position,inner_name=entity_name,direction=entity.direction,force=player.force}
            if surface.can_place_entity(ghost) then
                surface.create_entity(ghost).time_to_live = 59
            end
        end
    end
end

local function make_grid(offset)
    local surface = global.map_store.surface
    local set_tiles = {}
    for x = -5,5 do
        for y = -5,5 do
            if (x+math.floor(offset.x)+y+math.floor(offset.y))%2 == 0 then
                table.insert(set_tiles,{name='lab-dark-1',position={x+offset.x,y+offset.y}})
            else 
                table.insert(set_tiles,{name='lab-dark-2',position={x+offset.x,y+offset.y}})
            end
        end
    end
    surface.set_tiles(set_tiles,false)
end

local function draw_cam(player,cam_root)
    local cam = cam_root.cam
    if not cam then 
        cam = cam_root.add{type='camera',position={0,0},name='cam',surface_index=global.map_store.surface.index}
        cam.style.minimal_width = 200
        cam.style.minimal_height = 200
    end
    cam.position = player.position
    global.map_store.open_cams[player.index] = cam
    make_grid(player.position)
end

ExpGui.add_frame.left('map-changes','item/satellite','Allows you to see map changes',false,function(player,frame)
    frame.caption = ''
    draw_cam(player,frame)
    frame.add{type='checkbox',name='entitys',state=false,caption='View Entitys'}
    frame.add{type='checkbox',name='full-screen',state=false,caption='Full Screen Mode'}
end)

Event.register(defines.events.on_gui_click, function(event)
	local element = event.element
    if element.valid and element.type == 'checkbox' and element.name == 'full-screen' and element.parent.name == 'map-changes' then
        fullscreen(global.map_store.open_cams[event.player_index],element.state)
    end
end)

Event.register(defines.events.on_player_mined_entity,draw_entity)
Event.register(defines.events.on_player_rotated_entity,draw_entity)

Event.register(defines.events.on_tick,function(event) 
    for _,cam in pairs(global.map_store.open_cams) do
        if not cam.parent.style.visible then return end
        cam.position = game.players[cam.player_index].position
        if event.tick % 60 == 0 then
            make_grid(cam.position)
            if cam.parent.entitys.state then
                draw_ghosts(cam)
            end
        end
    end
end)

Event.register(Event.soft_init,function() 
    global.map_store = {open_cams={},players={},surface=game.create_surface('map-store',{width = 2, height = 2})}
    game.forces['player'].ghost_time_to_live = 60
    global.map_store.surface.daytime = 1
    global.map_store.surface.freeze_daytime = true
end)