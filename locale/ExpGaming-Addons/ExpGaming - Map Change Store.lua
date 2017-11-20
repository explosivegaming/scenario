--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
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
    make_grid(player.position)
end

Event.register(Event.soft_init,function() 
    global.map_store = {open_cams={},players={},surface=game.create_surface('map-store',{width = 2, height = 2})}
    global.map_store.surface.daytime = 1
    global.map_store.surface.freeze_daytime = true
end)