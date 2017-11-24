--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local hexs = {
    upper_left = {{"out-of-map",0,30},{"out-of-map",0,31},{"out-of-map",1,30},{"out-of-map",1,31},{"out-of-map",2,30},{"out-of-map",2,31},{"out-of-map",3,30},{"out-of-map",3,31},{"out-of-map",4,30},{"out-of-map",4,31},
    {"out-of-map",5,30},{"out-of-map",5,31},{"out-of-map",6,30},{"out-of-map",6,31},{"out-of-map",7,30},{"out-of-map",7,31},{"out-of-map",8,30},{"out-of-map",8,31},{"out-of-map",9,30},{"out-of-map",9,31},
    {"out-of-map",10,30},{"out-of-map",10,31},{"out-of-map",11,30},{"out-of-map",11,31},{"out-of-map",12,30},{"out-of-map",12,31},{"out-of-map",13,30},{"out-of-map",13,31},{"out-of-map",14,30},{"out-of-map",14,31},
    {"out-of-map",15,30},{"out-of-map",15,31},{"out-of-map",16,27},{"out-of-map",16,28},{"out-of-map",16,29},{"out-of-map",16,30},{"out-of-map",16,31},{"out-of-map",17,27},{"out-of-map",17,28},{"out-of-map",17,29},
    {"out-of-map",17,30},{"out-of-map",17,31},{"out-of-map",18,23},{"out-of-map",18,24},{"out-of-map",18,25},{"out-of-map",18,26},{"out-of-map",19,23},{"out-of-map",19,24},{"out-of-map",19,25},{"out-of-map",19,26},
    {"hazard-concrete-right",20,19},{"hazard-concrete-right",20,20},{"out-of-map",20,21},{"out-of-map",20,22},{"hazard-concrete-right",21,19},{"hazard-concrete-right",21,20},{"out-of-map",21,21},{"out-of-map",21,22},{"concrete",22,15},{"concrete",22,16},
    {"concrete",22,17},{"concrete",22,18},{"concrete",23,15},{"concrete",23,16},{"concrete",23,17},{"concrete",23,18},{"out-of-map",24,11},{"out-of-map",24,12},{"hazard-concrete-right",24,13},{"hazard-concrete-right",24,14},
    {"out-of-map",25,11},{"out-of-map",25,12},{"hazard-concrete-right",25,13},{"hazard-concrete-right",25,14},{"out-of-map",26,7},{"out-of-map",26,8},{"out-of-map",26,9},{"out-of-map",26,10},{"out-of-map",27,7},{"out-of-map",27,8},
    {"out-of-map",27,9},{"out-of-map",27,10},{"out-of-map",28,3},{"out-of-map",28,4},{"out-of-map",28,5},{"out-of-map",28,6},{"out-of-map",29,3},{"out-of-map",29,4},{"out-of-map",29,5},{"out-of-map",29,6},
    {"out-of-map",30,-1},{"out-of-map",30,0},{"out-of-map",30,1},{"out-of-map",30,2},{"out-of-map",31,-1},{"out-of-map",31,0},{"out-of-map",31,1},{"out-of-map",31,2},
    {"out-of-map",32,-1}},

    upper_middle = {{"out-of-map",0,-1},{"out-of-map",1,-1},{"out-of-map",2,-1},{"out-of-map",3,-1},{"out-of-map",4,-1},{"out-of-map",5,-1},{"out-of-map",6,-1},{"out-of-map",7,-1},{"out-of-map",8,-1},{"out-of-map",9,-1},
    {"out-of-map",10,-1},{"out-of-map",11,-1},{"out-of-map",12,-1},{"out-of-map",13,-1},{"out-of-map",14,-1},{"out-of-map",15,-1},{"out-of-map",16,-1},{"out-of-map",17,-1},{"out-of-map",18,-1},{"out-of-map",19,-1},
    {"out-of-map",20,-1},{"out-of-map",21,-1},{"out-of-map",22,-1},{"out-of-map",23,-1},{"out-of-map",24,-1},{"out-of-map",25,-1},{"out-of-map",26,-1},{"out-of-map",27,-1},{"out-of-map",28,-1},{"out-of-map",29,-1},
    {"out-of-map",30,-1},{"out-of-map",31,-1},{"out-of-map",32,-1},{"out-of-map",32,0},{"out-of-map",32,1},
    {"out-of-map",32,2}},

    upper_right = {{"out-of-map",0,-1},{"out-of-map",0,0},{"out-of-map",0,1},{"out-of-map",0,2},{"out-of-map",1,-1},{"out-of-map",1,0},{"out-of-map",1,1},{"out-of-map",1,2},{"out-of-map",2,3},{"out-of-map",2,4},
    {"out-of-map",2,5},{"out-of-map",2,6},{"out-of-map",3,3},{"out-of-map",3,4},{"out-of-map",3,5},{"out-of-map",3,6},{"out-of-map",4,7},{"out-of-map",4,8},{"out-of-map",4,9},{"out-of-map",4,10},
    {"out-of-map",5,7},{"out-of-map",5,8},{"out-of-map",5,9},{"out-of-map",5,10},{"out-of-map",6,11},{"out-of-map",6,12},{"hazard-concrete-left",6,13},{"hazard-concrete-left",6,14},{"out-of-map",7,11},{"out-of-map",7,12},
    {"hazard-concrete-left",7,13},{"hazard-concrete-left",7,14},{"concrete",8,15},{"concrete",8,16},{"concrete",8,17},{"concrete",8,18},{"concrete",9,15},{"concrete",9,16},{"concrete",9,17},{"concrete",9,18},
    {"hazard-concrete-left",10,19},{"hazard-concrete-left",10,20},{"out-of-map",10,21},{"out-of-map",10,22},{"hazard-concrete-left",11,19},{"hazard-concrete-left",11,20},{"out-of-map",11,21},{"out-of-map",11,22},{"out-of-map",12,23},{"out-of-map",12,24},
    {"out-of-map",12,25},{"out-of-map",12,26},{"out-of-map",13,23},{"out-of-map",13,24},{"out-of-map",13,25},{"out-of-map",13,26},{"out-of-map",14,27},{"out-of-map",14,28},{"out-of-map",14,29},{"out-of-map",14,30},
    {"out-of-map",14,31},{"out-of-map",15,27},{"out-of-map",15,28},{"out-of-map",15,29},{"out-of-map",15,30},{"out-of-map",15,31},{"out-of-map",16,30},{"out-of-map",16,31},{"out-of-map",17,30},{"out-of-map",17,31},
    {"out-of-map",18,30},{"out-of-map",18,31},{"out-of-map",19,30},{"out-of-map",19,31},{"out-of-map",20,30},{"out-of-map",20,31},{"out-of-map",21,30},{"out-of-map",21,31},{"out-of-map",22,30},{"out-of-map",22,31},
    {"out-of-map",23,30},{"out-of-map",23,31},{"out-of-map",24,30},{"out-of-map",24,31},{"out-of-map",25,30},{"out-of-map",25,31},{"out-of-map",26,30},{"out-of-map",26,31},{"out-of-map",27,30},{"out-of-map",27,31},
    {"out-of-map",28,30},{"out-of-map",28,31},{"out-of-map",29,30},{"out-of-map",29,31},{"out-of-map",30,30},{"out-of-map",30,31},{"out-of-map",31,30},{"out-of-map",31,31},
    {"out-of-map",32,30}},

    lower_left = {{"out-of-map",0,-1},{"out-of-map",1,-1},{"out-of-map",2,-1},{"out-of-map",3,-1},{"out-of-map",4,-1},{"out-of-map",5,-1},{"out-of-map",6,-1},{"out-of-map",7,-1},{"out-of-map",8,-1},{"out-of-map",9,-1},
    {"out-of-map",10,-1},{"out-of-map",11,-1},{"out-of-map",12,-1},{"out-of-map",13,-1},{"out-of-map",14,-1},{"out-of-map",15,-1},{"out-of-map",16,-1},{"out-of-map",16,0},{"out-of-map",16,1},{"out-of-map",16,2},
    {"out-of-map",17,-1},{"out-of-map",17,0},{"out-of-map",17,1},{"out-of-map",17,2},{"out-of-map",18,3},{"out-of-map",18,4},{"out-of-map",18,5},{"out-of-map",18,6},{"out-of-map",19,3},{"out-of-map",19,4},
    {"out-of-map",19,5},{"out-of-map",19,6},{"out-of-map",20,7},{"out-of-map",20,8},{"hazard-concrete-left",20,9},{"hazard-concrete-left",20,10},{"out-of-map",21,7},{"out-of-map",21,8},{"hazard-concrete-left",21,9},{"hazard-concrete-left",21,10},
    {"concrete",22,11},{"concrete",22,12},{"concrete",22,13},{"concrete",22,14},{"concrete",23,11},{"concrete",23,12},{"concrete",23,13},{"concrete",23,14},{"hazard-concrete-left",24,15},{"hazard-concrete-left",24,16},
    {"out-of-map",24,17},{"out-of-map",24,18},{"hazard-concrete-left",25,15},{"hazard-concrete-left",25,16},{"out-of-map",25,17},{"out-of-map",25,18},{"out-of-map",26,19},{"out-of-map",26,20},{"out-of-map",26,21},{"out-of-map",26,22},
    {"out-of-map",27,19},{"out-of-map",27,20},{"out-of-map",27,21},{"out-of-map",27,22},{"out-of-map",28,23},{"out-of-map",28,24},{"out-of-map",28,25},{"out-of-map",28,26},{"out-of-map",29,23},{"out-of-map",29,24},
    {"out-of-map",29,25},{"out-of-map",29,26},{"out-of-map",30,27},{"out-of-map",30,28},{"out-of-map",30,29},{"out-of-map",30,30},{"out-of-map",31,27},{"out-of-map",31,28},{"out-of-map",31,29},{"out-of-map",31,30},
    {"out-of-map",32,30}},

    lower_middle = {{"out-of-map",0,30},{"out-of-map",1,30},{"out-of-map",2,30},{"out-of-map",3,30},{"out-of-map",4,30},{"out-of-map",5,30},{"out-of-map",6,30},{"out-of-map",7,30},{"out-of-map",8,30},{"out-of-map",9,30},
    {"out-of-map",10,30},{"out-of-map",11,30},{"out-of-map",12,30},{"out-of-map",13,30},{"out-of-map",14,30},{"out-of-map",15,30},{"out-of-map",16,30},{"out-of-map",17,30},{"out-of-map",18,30},{"out-of-map",19,30},
    {"out-of-map",20,30},{"out-of-map",21,30},{"out-of-map",22,30},{"out-of-map",23,30},{"out-of-map",24,30},{"out-of-map",25,30},{"out-of-map",26,30},{"out-of-map",27,30},{"out-of-map",28,30},{"out-of-map",29,30},
    {"out-of-map",30,30},{"out-of-map",31,30},{"out-of-map",32,27},{"out-of-map",32,28},{"out-of-map",32,29},
    {"out-of-map",32,30}},

    lower_right = {{"out-of-map",0,27},{"out-of-map",0,28},{"out-of-map",0,29},{"out-of-map",0,30},{"out-of-map",1,27},{"out-of-map",1,28},{"out-of-map",1,29},{"out-of-map",1,30},{"out-of-map",2,23},{"out-of-map",2,24},
    {"out-of-map",2,25},{"out-of-map",2,26},{"out-of-map",3,23},{"out-of-map",3,24},{"out-of-map",3,25},{"out-of-map",3,26},{"out-of-map",4,19},{"out-of-map",4,20},{"out-of-map",4,21},{"out-of-map",4,22},
    {"out-of-map",5,19},{"out-of-map",5,20},{"out-of-map",5,21},{"out-of-map",5,22},{"hazard-concrete-right",6,15},{"hazard-concrete-right",6,16},{"out-of-map",6,17},{"out-of-map",6,18},{"hazard-concrete-right",7,15},{"hazard-concrete-right",7,16},
    {"out-of-map",7,17},{"out-of-map",7,18},{"concrete",8,11},{"concrete",8,12},{"concrete",8,13},{"concrete",8,14},{"concrete",9,11},{"concrete",9,12},{"concrete",9,13},{"concrete",9,14},
    {"out-of-map",10,7},{"out-of-map",10,8},{"hazard-concrete-right",10,9},{"hazard-concrete-right",10,10},{"out-of-map",11,7},{"out-of-map",11,8},{"hazard-concrete-right",11,9},{"hazard-concrete-right",11,10},{"out-of-map",12,3},{"out-of-map",12,4},
    {"out-of-map",12,5},{"out-of-map",12,6},{"out-of-map",13,3},{"out-of-map",13,4},{"out-of-map",13,5},{"out-of-map",13,6},{"out-of-map",14,-1},{"out-of-map",14,0},{"out-of-map",14,1},{"out-of-map",14,2},
    {"out-of-map",15,-1},{"out-of-map",15,0},{"out-of-map",15,1},{"out-of-map",15,2},{"out-of-map",16,-1},{"out-of-map",17,-1},{"out-of-map",18,-1},{"out-of-map",19,-1},{"out-of-map",20,-1},{"out-of-map",21,-1},
    {"out-of-map",22,-1},{"out-of-map",23,-1},{"out-of-map",24,-1},{"out-of-map",25,-1},{"out-of-map",26,-1},{"out-of-map",27,-1},{"out-of-map",28,-1},{"out-of-map",29,-1},{"out-of-map",30,-1},
    {"out-of-map",31,-1}}
}

Event.register(defines.events.on_chunk_generated,function(event)
    local top_left = event.area.left_top
    local chunk_x = top_left.x/32
    local chunk_y = top_left.y/32
    local hex = ''
    -- y axis
    if (chunk_y) % 2 == 0 then
        hex='upper_'
    elseif (chunk_y) % 2 == 1 then
        hex='lower_'
    end
    -- x axis
    if (chunk_x) % 3 == 0 then
        hex=hex..'left'
    elseif (chunk_x) % 3 == 1 then
        hex=hex..'middle'
    elseif (chunk_x) % 3 == 2 then
        hex=hex..'right'
    end
    -- make hex
    local tiles = {}
    for _,tile in pairs(hexs[hex]) do
        table.insert(tiles,{name=tile[1],position={tile[2]+top_left.x,tile[3]+top_left.y}})
    end
    event.surface.set_tiles(tiles)
end)

--[[
local player_offset = {0,-1}
local tiles = {}
local player = game.player
player.teleport({math.floor(player.position.x),math.floor(player.position.y)})
offset = {x=player.position.x+player_offset[1],y=player.position.y+player_offset[2]}
for x = 0,32 do
    for y = 0,32 do
        local tile = player.surface.get_tile(x+offset.x,y+offset.y)
        if tile.name == 'out-of-map' or tile.name == 'hazard-concrete-left' or tile.name == 'hazard-concrete-right' or tile.name == 'concrete' then
            game.print(x+offset.x..' '..y+offset.y)
            table.insert(tiles,{tile.name,x+player_offset[1],y+player_offset[2]})
        end
    end
end
game.write_file('test.data',table.tostring(tiles))
]]