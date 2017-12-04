--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local ore_prob = {['stone']=0.02,['iron-ore']=0.07,['copper-ore']=0.12,['coal']=0.14,['crude-oil']=0.15,['uranium-ore']=0.151,['tree-02']=0.25,['water']=0.35,['base']=0.60}
local tile_prob ={['out-of-map']=0.05,['dirt']=0.20,['grass']=0.65,['sand']=0.75,['red-desert']=0.78,['water-green']=0.80,['deepwater']=1.00}

local hexs = {
    middle_ore = {
      {-16,4},{-16,5},{-16,6},{-16,7},{-16,8},{-16,9},{-16,10},{-16,11},{-16,12},{-16,13},{-16,14},{-16,15},
      {-15,0},{-15,1},{-15,2},{-15,3},{-15,4},{-15,5},{-15,6},{-15,7},{-15,8},{-15,9},{-15,10},{-15,11},{-15,12},{-15,13},{-15,14},{-15,15},
      {-14,0},{-14,1},{-14,2},{-14,3},{-14,4},{-14,5},{-14,6},{-14,7},{-14,8},{-14,9},{-14,10},{-14,11},{-14,12},{-14,13},{-14,14},{-14,15},
      {-13,-4},{-13,-3},{-13,-2},{-13,-1},{-13,0},{-13,1},{-13,2},{-13,3},{-13,4},{-13,5},{-13,6},{-13,7},{-13,8},{-13,9},{-13,10},{-13,11},{-13,12},{-13,13},{-13,14},{-13,15},
      {-12,-4},{-12,-3},{-12,-2},{-12,-1},{-12,0},{-12,1},{-12,2},{-12,3},{-12,4},{-12,5},{-12,6},{-12,7},{-12,8},{-12,9},{-12,10},{-12,11},{-12,12},{-12,13},{-12,14},{-12,15},
      {-11,-6},{-11,-5},{-11,-4},{-11,-3},{-11,-2},{-11,-1},{-11,0},{-11,1},{-11,2},{-11,3},{-11,4},{-11,5},{-11,6},{-11,7},{-11,8},{-11,9},{-11,10},{-11,11},{-11,12},{-11,13},{-11,14},{-11,15},
      {-10,-6},{-10,-5},{-10,-4},{-10,-3},{-10,-2},{-10,-1},{-10,0},{-10,1},{-10,2},{-10,3},{-10,4},{-10,5},{-10,6},{-10,7},{-10,8},{-10,9},{-10,10},{-10,11},{-10,12},{-10,13},{-10,14},{-10,15},
      {-9,-6},{-9,-5},{-9,-4},{-9,-3},{-9,-2},{-9,-1},{-9,0},{-9,1},{-9,2},{-9,3},{-9,4},{-9,5},{-9,6},{-9,7},{-9,8},{-9,9},{-9,10},{-9,11},{-9,12},{-9,13},{-9,14},{-9,15},
      {-8,-6},{-8,-5},{-8,-4},{-8,-3},{-8,-2},{-8,-1},{-8,0},{-8,1},{-8,2},{-8,3},{-8,4},{-8,5},{-8,6},{-8,7},{-8,8},{-8,9},{-8,10},{-8,11},{-8,12},{-8,13},{-8,14},{-8,15},
      {-7,-6},{-7,-5},{-7,-4},{-7,-3},{-7,-2},{-7,-1},{-7,0},{-7,1},{-7,2},{-7,3},{-7,4},{-7,5},{-7,6},{-7,7},{-7,8},{-7,9},{-7,10},{-7,11},{-7,12},{-7,13},{-7,14},{-7,15},
      {-6,-6},{-6,-5},{-6,-4},{-6,-3},{-6,-2},{-6,-1},{-6,0},{-6,1},{-6,2},{-6,3},{-6,4},{-6,5},{-6,6},{-6,7},{-6,8},{-6,9},{-6,10},{-6,11},{-6,12},{-6,13},{-6,14},{-6,15},
      {-5,-6},{-5,-5},{-5,-4},{-5,-3},{-5,-2},{-5,-1},{-5,0},{-5,1},{-5,2},{-5,3},{-5,4},{-5,5},{-5,6},{-5,7},{-5,8},{-5,9},{-5,10},{-5,11},{-5,12},{-5,13},{-5,14},{-5,15},
      {-4,-6},{-4,-5},{-4,-4},{-4,-3},{-4,-2},{-4,-1},{-4,0},{-4,1},{-4,2},{-4,3},{-4,4},{-4,5},{-4,6},{-4,7},{-4,8},{-4,9},{-4,10},{-4,11},{-4,12},{-4,13},{-4,14},{-4,15},
      {-3,-6},{-3,-5},{-3,-4},{-3,-3},{-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{-3,3},{-3,4},{-3,5},{-3,6},{-3,7},{-3,8},{-3,9},{-3,10},{-3,11},{-3,12},{-3,13},{-3,14},{-3,15},
      {-2,-6},{-2,-5},{-2,-4},{-2,-3},{-2,-2},{-2,-1},{-2,0},{-2,1},{-2,2},{-2,3},{-2,4},{-2,5},{-2,6},{-2,7},{-2,8},{-2,9},{-2,10},{-2,11},{-2,12},{-2,13},{-2,14},{-2,15},
      {-1,-6},{-1,-5},{-1,-4},{-1,-3},{-1,-2},{-1,-1},{-1,0},{-1,1},{-1,2},{-1,3},{-1,4},{-1,5},{-1,6},{-1,7},{-1,8},{-1,9},{-1,10},{-1,11},{-1,12},{-1,13},{-1,14},{-1,15},
      {0,-6},{0,-5},{0,-4},{0,-3},{0,-2},{0,-1},{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{0,9},{0,10},{0,11},{0,12},{0,13},{0,14},{0,15},
      {1,-6},{1,-5},{1,-4},{1,-3},{1,-2},{1,-1},{1,0},{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{1,9},{1,10},{1,11},{1,12},{1,13},{1,14},{1,15},
      {2,-6},{2,-5},{2,-4},{2,-3},{2,-2},{2,-1},{2,0},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{2,9},{2,10},{2,11},{2,12},{2,13},{2,14},{2,15},
      {3,-6},{3,-5},{3,-4},{3,-3},{3,-2},{3,-1},{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8},{3,9},{3,10},{3,11},{3,12},{3,13},{3,14},{3,15},
      {4,-6},{4,-5},{4,-4},{4,-3},{4,-2},{4,-1},{4,0},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{4,8},{4,9},{4,10},{4,11},{4,12},{4,13},{4,14},{4,15},
      {5,-6},{5,-5},{5,-4},{5,-3},{5,-2},{5,-1},{5,0},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8},{5,9},{5,10},{5,11},{5,12},{5,13},{5,14},{5,15},
      {6,-6},{6,-5},{6,-4},{6,-3},{6,-2},{6,-1},{6,0},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{6,8},{6,9},{6,10},{6,11},{6,12},{6,13},{6,14},{6,15},
      {7,-6},{7,-5},{7,-4},{7,-3},{7,-2},{7,-1},{7,0},{7,1},{7,2},{7,3},{7,4},{7,5},{7,6},{7,7},{7,8},{7,9},{7,10},{7,11},{7,12},{7,13},{7,14},{7,15},
      {8,-6},{8,-5},{8,-4},{8,-3},{8,-2},{8,-1},{8,0},{8,1},{8,2},{8,3},{8,4},{8,5},{8,6},{8,7},{8,8},{8,9},{8,10},{8,11},{8,12},{8,13},{8,14},{8,15},
      {9,-6},{9,-5},{9,-4},{9,-3},{9,-2},{9,-1},{9,0},{9,1},{9,2},{9,3},{9,4},{9,5},{9,6},{9,7},{9,8},{9,9},{9,10},{9,11},{9,12},{9,13},{9,14},{9,15},
      {10,-6},{10,-5},{10,-4},{10,-3},{10,-2},{10,-1},{10,0},{10,1},{10,2},{10,3},{10,4},{10,5},{10,6},{10,7},{10,8},{10,9},{10,10},{10,11},{10,12},{10,13},{10,14},{10,15},
      {11,-4},{11,-3},{11,-2},{11,-1},{11,0},{11,1},{11,2},{11,3},{11,4},{11,5},{11,6},{11,7},{11,8},{11,9},{11,10},{11,11},{11,12},{11,13},{11,14},{11,15},
      {12,-4},{12,-3},{12,-2},{12,-1},{12,0},{12,1},{12,2},{12,3},{12,4},{12,5},{12,6},{12,7},{12,8},{12,9},{12,10},{12,11},{12,12},{12,13},{12,14},{12,15},
      {13,0},{13,1},{13,2},{13,3},{13,4},{13,5},{13,6},{13,7},{13,8},{13,9},{13,10},{13,11},{13,12},{13,13},{13,14},{13,15},
      {14,0},{14,1},{14,2},{14,3},{14,4},{14,5},{14,6},{14,7},{14,8},{14,9},{14,10},{14,11},{14,12},{14,13},{14,14},{14,15},
      {15,4},{15,5},{15,6},{15,7},{15,8},{15,9},{15,10},{15,11},{15,12},{15,13},{15,14},{15,15},
      --{16,4},{16,5},{16,6},{16,7},{16,8},{16,9},{16,10},{16,11},{16,12},{16,13},{16,14},{16,15},
    },
    middle_tiles = {
      {"out-of-map",-16,-16},{"out-of-map",-15,-16},{"out-of-map",-14,-16},{"out-of-map",-13,-16},
      {"out-of-map",-12,-16},{"out-of-map",-11,-16},{"out-of-map",-10,-16},{"out-of-map",-9,-16},
      {"out-of-map",-8,-16},{"out-of-map",-7,-16},{"out-of-map",-6,-16},{"out-of-map",-5,-16},
      {"out-of-map",-4,-16},{"out-of-map",-3,-16},{"out-of-map",-2,-16},{"out-of-map",-1,-16},
      {"out-of-map",0,-16},{"out-of-map",1,-16},{"out-of-map",2,-16},{"out-of-map",3,-16},
      {"out-of-map",4,-16},{"out-of-map",5,-16},{"out-of-map",6,-16},{"out-of-map",7,-16},
      {"out-of-map",8,-16},{"out-of-map",9,-16},{"out-of-map",10,-16},{"out-of-map",11,-16},
      {"out-of-map",12,-16},{"out-of-map",13,-16},{"out-of-map",14,-16},{"out-of-map",15,-16},
      --{"out-of-map",16,-16},{"out-of-map",16,-15},{"out-of-map",16,-14},{"out-of-map",16,-13},
    },
    side_ore = {
      {-16,-16},{-16,-15},{-16,-14},{-16,-13},{-16,-12},{-16,-11},{-16,-10},{-16,-9},{-16,-8},{-16,-7},{-16,-6},{-16,-5},{-16,-4},{-16,-3},{-16,-2},{-16,-1},{-16,0},{-16,1},{-16,2},{-16,3},{-16,4},{-16,5},
      {-15,-16},{-15,-15},{-15,-14},{-15,-13},{-15,-12},{-15,-11},{-15,-10},{-15,-9},{-15,-8},{-15,-7},{-15,-6},{-15,-5},{-15,-4},{-15,-3},{-15,-2},{-15,-1},{-15,0},{-15,1},{-15,2},{-15,3},{-15,4},{-15,5},
      {-14,-16},{-14,-15},{-14,-14},{-14,-13},{-14,-12},{-14,-11},{-14,-10},{-14,-9},{-14,-8},{-14,-7},{-14,-6},{-14,-5},{-14,-4},{-14,-3},{-14,-2},{-14,-1},{-14,0},{-14,1},{-14,2},{-14,3},{-14,4},{-14,5},
      {-13,-16},{-13,-15},{-13,-14},{-13,-13},{-13,-12},{-13,-11},{-13,-10},{-13,-9},{-13,-8},{-13,-7},{-13,-6},{-13,-5},{-13,-4},{-13,-3},{-13,-2},{-13,-1},{-13,0},{-13,1},{-13,2},{-13,3},{-13,4},{-13,5},
      {-12,-16},{-12,-15},{-12,-14},{-12,-13},{-12,-12},{-12,-11},{-12,-10},{-12,-9},{-12,-8},{-12,-7},{-12,-6},{-12,-5},{-12,-4},{-12,-3},{-12,-2},{-12,-1},{-12,0},{-12,1},{-12,2},{-12,3},{-12,4},{-12,5},
      {-11,-16},{-11,-15},{-11,-14},{-11,-13},{-11,-12},{-11,-11},{-11,-10},{-11,-9},{-11,-8},{-11,-7},{-11,-6},{-11,-5},{-11,-4},{-11,-3},{-11,-2},{-11,-1},{-11,0},{-11,1},{-11,2},{-11,3},{-11,4},{-11,5},
      {-10,-16},{-10,-15},{-10,-14},{-10,-13},{-10,-12},{-10,-11},{-10,-10},{-10,-9},{-10,-8},{-10,-7},{-10,-6},{-10,-5},{-10,-4},{-10,-3},{-10,-2},{-10,-1},{-10,0},{-10,1},{-10,2},{-10,3},{-10,4},{-10,5},
      {-9,-16},{-9,-15},{-9,-14},{-9,-13},{-9,-12},{-9,-11},{-9,-10},{-9,-9},{-9,-8},{-9,-7},{-9,-6},{-9,-5},{-9,-4},{-9,-3},{-9,-2},{-9,-1},{-9,0},{-9,1},{-9,2},{-9,3},{-9,4},{-9,5},
      {-8,-16},{-8,-15},{-8,-14},{-8,-13},{-8,-12},{-8,-11},{-8,-10},{-8,-9},{-8,-8},{-8,-7},{-8,-6},{-8,-5},{-8,-4},{-8,-3},{-8,-2},{-8,-1},{-8,0},{-8,1},{-8,2},{-8,3},{-8,4},{-8,5},
      {-7,-16},{-7,-15},{-7,-14},{-7,-13},{-7,-12},{-7,-11},{-7,-10},{-7,-9},{-7,-8},{-7,-7},{-7,-6},{-7,-5},{-7,-4},{-7,-3},{-7,-2},{-7,-1},{-7,0},{-7,1},{-7,2},{-7,3},{-7,4},{-7,5},
      {-6,-16},{-6,-15},{-6,-14},{-6,-13},{-6,-12},{-6,-11},{-6,-10},{-6,-9},{-6,-8},{-6,-7},{-6,-6},{-6,-5},{-6,-4},{-6,-3},{-6,-2},{-6,-1},{-6,0},{-6,1},{-6,2},{-6,3},{-6,4},{-6,5},
      {-5,-16},{-5,-15},{-5,-14},{-5,-13},{-5,-12},{-5,-11},{-5,-10},{-5,-9},{-5,-8},{-5,-7},{-5,-6},{-5,-5},{-5,-4},{-5,-3},{-5,-2},{-5,-1},{-5,0},{-5,1},{-5,2},{-5,3},
      {-4,-16},{-4,-15},{-4,-14},{-4,-13},{-4,-12},{-4,-11},{-4,-10},{-4,-9},{-4,-8},{-4,-7},{-4,-6},{-4,-5},{-4,-4},{-4,-3},{-4,-2},{-4,-1},{-4,0},{-4,1},{-4,2},{-4,3},
      {-3,-16},{-3,-15},{-3,-14},{-3,-13},{-3,-12},{-3,-11},{-3,-10},{-3,-9},{-3,-8},{-3,-7},{-3,-6},{-3,-5},{-3,-4},{-3,-3},{-3,-2},{-3,-1},
      {-2,-16},{-2,-15},{-2,-14},{-2,-13},{-2,-12},{-2,-11},{-2,-10},{-2,-9},{-2,-8},{-2,-7},{-2,-6},{-2,-5},{-2,-4},{-2,-3},{-2,-2},{-2,-1},
      {-1,-16},{-1,-15},{-1,-14},{-1,-13},{-1,-12},{-1,-11},{-1,-10},{-1,-9},{-1,-8},{-1,-7},{-1,-6},{-1,-5},
      {0,-16},{0,-15},{0,-14},{0,-13},{0,-12},{0,-11},{0,-10},{0,-9},{0,-8},{0,-7},{0,-6},{0,-5},
      {1,-16},{1,-15},{1,-14},{1,-13},{1,-12},{1,-11},{1,-10},{1,-9},
      {2,-16},{2,-15},{2,-14},{2,-13},{2,-12},{2,-11},{2,-10},{2,-9},
      {3,-16},{3,-15},{3,-14},{3,-13},
      {4,-16},{4,-15},{4,-14},{4,-13},
      {11,12},{11,13},{11,14},{11,15},
      {12,12},{12,13},{12,14},{12,15},
      {13,8},{13,9},{13,10},{13,11},{13,12},{13,13},{13,14},{13,15},
      {14,8},{14,9},{14,10},{14,11},{14,12},{14,13},{14,14},{14,15},
      {15,4},{15,5},{15,6},{15,7},{15,8},{15,9},{15,10},{15,11},{15,12},{15,13},{15,14},{15,15},
      --{16,4},{16,5},{16,6},{16,7},{16,8},{16,9},{16,10},{16,11},{16,12},{16,13},{16,14},{16,15},
    },
    side_tiles = {
      {"out-of-map",-16,15},{"out-of-map",-15,15},{"out-of-map",-14,15},{"out-of-map",-13,15},
      {"out-of-map",-12,15},{"out-of-map",-11,15},{"out-of-map",-10,15},{"out-of-map",-9,15},
      {"out-of-map",-8,15},{"out-of-map",-7,15},{"out-of-map",-6,15},{"out-of-map",-5,15},
      {"out-of-map",-4,15},{"out-of-map",-3,15},{"out-of-map",-2,15},{"out-of-map",-1,15},
      {"out-of-map",0,12},{"out-of-map",0,13},{"out-of-map",0,14},{"out-of-map",0,15},
      {"out-of-map",1,12},{"out-of-map",1,13},{"out-of-map",1,14},{"out-of-map",1,15},
      {"out-of-map",2,8},{"out-of-map",2,9},{"out-of-map",2,10},{"out-of-map",2,11},
      {"out-of-map",3,8},{"out-of-map",3,9},{"out-of-map",3,10},{"out-of-map",3,11},
      {"hazard-concrete-right",4,4},{"hazard-concrete-right",4,5},{"out-of-map",4,6},{"out-of-map",4,7},
      {"hazard-concrete-right",5,4},{"hazard-concrete-right",5,5},{"out-of-map",5,6},{"out-of-map",5,7},
      {"concrete",6,0},{"concrete",6,1},{"concrete",6,2},{"concrete",6,3},
      {"concrete",7,0},{"concrete",7,1},{"concrete",7,2},{"concrete",7,3},
      {"out-of-map",8,-4},{"out-of-map",8,-3},{"hazard-concrete-right",8,-2},{"hazard-concrete-right",8,-1},
      {"out-of-map",9,-4},{"out-of-map",9,-3},{"hazard-concrete-right",9,-2},{"hazard-concrete-right",9,-1},
      {"out-of-map",10,-8},{"out-of-map",10,-7},{"out-of-map",10,-6},{"out-of-map",10,-5},
      {"out-of-map",11,-8},{"out-of-map",11,-7},{"out-of-map",11,-6},{"out-of-map",11,-5},
      {"out-of-map",12,-12},{"out-of-map",12,-11},{"out-of-map",12,-10},{"out-of-map",12,-9},
      {"out-of-map",13,-12},{"out-of-map",13,-11},{"out-of-map",13,-10},{"out-of-map",13,-9},
      {"out-of-map",14,-16},{"out-of-map",14,-15},{"out-of-map",14,-14},{"out-of-map",14,-13},
      {"out-of-map",15,-16},{"out-of-map",15,-15},{"out-of-map",15,-14},{"out-of-map",15,-13},
      --{"out-of-map",16,-16},
    },
    tile_small = {
      {2,12},
      {4,8},{4,12},
      {6,4},{6,8},{6,12},
      {8,0},{8,4},{8,8},{8,12},
      {10,-4},{10,0},{10,4},{10,8},{10,12},
      {12,-8},{12,-4},{12,0},{12,4},{12,8},{12,12},{14,-12},
      {14,-8},{14,-4},{14,0},{14,4},{14,8},{14,12},
    },
    tile_big = {
      {-16,-16},{-16,-12},{-16,-8},{-16,-4},{-16,0},{-16,4},{-16,8},{-16,12},
      {-14,-16},{-14,-12},{-14,-8},{-14,-4},{-14,0},{-14,4},{-14,8},{-14,12},
      {-12,-16},{-12,-12},{-12,-8},{-12,-4},{-12,0},{-12,4},{-12,8},{-12,12},
      {-10,-16},{-10,-12},{-10,-8},{-10,-4},{-10,0},{-10,4},{-10,8},{-10,12},
      {-8,-16},{-8,-12},{-8,-8},{-8,-4},{-8,0},{-8,4},{-8,8},{-8,12},
      {-6,-16},{-6,-12},{-6,-8},{-6,-4},{-6,0},{-6,4},{-6,8},{-6,12},
      {-4,-16},{-4,-12},{-4,-8},{-4,-4},{-4,0},{-4,4},{-4,8},{-4,12},
      {-2,-16},{-2,-12},{-2,-8},{-2,-4},{-2,0},{-2,4},{-2,8},{-2,12},
      {0,-16},{0,-12},{0,-8},{0,-4},{0,0},{0,4},{0,8},
      {2,-16},{2,-12},{2,-8},{2,-4},{2,0},{2,4},
      {4,-16},{4,-12},{4,-8},{4,-4},{4,0},
      {6,-16},{6,-12},{6,-8},{6,-4},
      {8,-16},{8,-12},{8,-8},
      {10,-16},{10,-12},
      {12,-16},
    },
    tile_full = {
      {-16,-16},{-16,-12},{-16,-8},{-16,-4},{-16,0},{-16,4},{-16,8},{-16,12},
      {-14,-16},{-14,-12},{-14,-8},{-14,-4},{-14,0},{-14,4},{-14,8},{-14,12},
      {-12,-16},{-12,-12},{-12,-8},{-12,-4},{-12,0},{-12,4},{-12,8},{-12,12},
      {-10,-16},{-10,-12},{-10,-8},{-10,-4},{-10,0},{-10,4},{-10,8},{-10,12},
      {-8,-16},{-8,-12},{-8,-8},{-8,-4},{-8,0},{-8,4},{-8,8},{-8,12},
      {-6,-16},{-6,-12},{-6,-8},{-6,-4},{-6,0},{-6,4},{-6,8},{-6,12},
      {-4,-16},{-4,-12},{-4,-8},{-4,-4},{-4,0},{-4,4},{-4,8},{-4,12},
      {-2,-16},{-2,-12},{-2,-8},{-2,-4},{-2,0},{-2,4},{-2,8},{-2,12},
      {0,-16},{0,-12},{0,-8},{0,-4},{0,0},{0,4},{0,8},{0,12},
      {2,-16},{2,-12},{2,-8},{2,-4},{2,0},{2,4},{2,8},{2,12},
      {4,-16},{4,-12},{4,-8},{4,-4},{4,0},{4,4},{4,8},{4,12},
      {6,-16},{6,-12},{6,-8},{6,-4},{6,0},{6,4},{6,8},{6,12},
      {8,-16},{8,-12},{8,-8},{8,-4},{8,0},{8,4},{8,8},{8,12},
      {10,-16},{10,-12},{10,-8},{10,-4},{10,0},{10,4},{10,8},{10,12},
      {12,-16},{12,-12},{12,-8},{12,-4},{12,0},{12,4},{12,8},{12,12},
      {14,-16},{14,-12},{14,-8},{14,-4},{14,0},{14,4},{14,8},{14,12},
    },
}

local function make_borders(surface,hex_type,center,inverter)
    local tiles = {}
    for _,tile in pairs(hexs[hex_type..'tiles']) do
        table.insert(tiles,{name=tile[1],
        position={
            (tile[2]*inverter.x)+center.x+inverter.ox,
            (tile[3]*inverter.y)+center.y+inverter.oy}
        })
    end
    surface.set_tiles(tiles,false)
end

local function make_ore_base(surface,hex_type,center,inverter)
    for _,entity in ipairs(surface.find_entities_filtered{type="resource", area={{center.x-16,center.y-16},{center.x+16,center.y+16}}}) do entity.destroy() end
    for _,entity in ipairs(surface.find_entities_filtered{type="tree", area={{center.x-16,center.y-16},{center.x+16,center.y+16}}}) do entity.destroy() end
    for _,entity in ipairs(surface.find_entities_filtered{force="enemy", area={{center.x-16,center.y-16},{center.x+16,center.y+16}}}) do entity.destroy() end
    for _,ore in pairs(hexs[hex_type..'ore']) do
        local entity={
          name='stone',
          position={
            (ore[1]*inverter.x)+center.x+inverter.ox,
            (ore[2]*inverter.y)+center.y+inverter.oy
          }
        }
        if surface.can_place_entity(entity) then
            surface.create_entity(entity)
        end
    end
end


local function get_hex_areas(hex_type,center,inverter)
    local function area_one(top_left)
        return {top_left,{top_left[1]+22,top_left[2]+22}}
    end
    local function area_two(top_left)
        return {top_left,{top_left[1]+5,top_left[2]+12}}
    end
    -- this part is quite hard coded
    local left_top = {x=center.x-16,y=center.y-16}
    if inverter.x == 1 and inverter.y == 1 and hex_type == 'side_' then
        return area_one{left_top.x+0,left_top.y+0}, area_two{left_top.x+27,left_top.y+20}
    elseif inverter.x == 1 and inverter.y == -1 and hex_type == 'side_' then
        return area_one{left_top.x+0,left_top.y+10}, area_two{left_top.x+27,left_top.y+0}
    elseif inverter.x == -1 and inverter.y == 1 and hex_type == 'side_' then
        return area_one{left_top.x+10,left_top.y+0}, area_two{left_top.x-0,left_top.y+20}
    elseif inverter.x == -1 and inverter.y == -1 and hex_type == 'side_' then
        return area_one{left_top.x+10,left_top.y+10}, area_two{left_top.x-0,left_top.y+0}
    elseif inverter.x == 1 and inverter.y == 1 and hex_type == 'middle_' then
        return {{center.x-16,center.y-15}, {center.x+16,center.y+16}}
    elseif inverter.x == 1 and inverter.y == -1 and hex_type == 'middle_' then
        return {{center.x-16,center.y-16} ,{center.x+16,center.y+15}}
    end
end

local function get_hex_names(hex_type,center,inverter)
    local chunk_size = 32
    if inverter.x == 1 and inverter.y == 1 and hex_type == 'side_' then
        return (center.x+chunk_size*0)..(center.y+chunk_size*0),(center.x+chunk_size*2)..(center.y+chunk_size*1)
    elseif inverter.x == 1 and inverter.y == -1 and hex_type == 'side_' then
        return (center.x+chunk_size*0)..(center.y+chunk_size*1),(center.x+chunk_size*2)..(center.y+chunk_size*0)
    elseif inverter.x == -1 and inverter.y == 1 and hex_type == 'side_' then
        return (center.x+chunk_size*1)..(center.y+chunk_size*0),(center.x+chunk_size*0)..(center.y+chunk_size*1)
    elseif inverter.x == -1 and inverter.y == -1 and hex_type == 'side_' then
        return (center.x+chunk_size*1)..(center.y+chunk_size*1),(center.x+chunk_size*0)..(center.y+chunk_size*0)
    elseif inverter.x == 1 and inverter.y == 1 and hex_type == 'middle_' then
        return (center.x+chunk_size*1)..(center.y+chunk_size*1)
    elseif inverter.x == 1 and inverter.y == -1 and hex_type == 'middle_' then
        return (center.x+chunk_size*1)..(center.y+chunk_size*0)
    end
end

local function make_tiles(surface,hex_name,center,area,inverter)
    local function make_2_by_4(surface,tiles,item,top_left,inverter)
        for x = 0,1 do
            for y = 0,3 do
                local tilepos = {
                    x = (top_left[1] + x),
                    y = (top_left[2] + y),
                }
                if surface.get_tile(tilepos).name ~= 'out-of-map' then
                    table.insert(tiles,{name=item,position=tilepos})
                end
            end
        end
    end
    global.hexs[hex_name] = global.hexs[hex_name] or {}
    global.hexs[hex_name].tile = global.hexs[hex_name].tile or math.random()
    if hex_name == '1616' then
        global.hexs[hex_name].tile = 0.6 --always start on grass.
    end
    for item,chance in pairs(tile_prob) do
        if global.hexs[hex_name].tile <= chance then
            local tiles = {}
            if area.left_top then
                for x = area.left_top.x, area.right_bottom.x-1 do
                    for y = area.left_top.y, area.right_bottom.y-1 do
                        if surface.get_tile(x,y).name ~= 'out-of-map' then
                            table.insert(tiles,{name=item,position={x,y}})
                        end
                    end
                end
            else
                for _,position in pairs(area) do
                    local tilesetpos = {
                        center.x + (position[1]-(2*inverter.ox))*inverter.x,
                        center.y + (position[2]-(4*inverter.oy))*inverter.y,
                    }
                    make_2_by_4(surface,tiles,item,tilesetpos,inverter)
                end
            end
            surface.set_tiles(tiles,false)
            return
        end
    end
end

local function make_ore(surface,hex_name,area)
    global.hexs[hex_name] = global.hexs[hex_name] or {}
    global.hexs[hex_name].ore = global.hexs[hex_name].ore or math.random()
    local ores = surface.find_entities_filtered{type="resource", area=area}
    local distance = math.sqrt((area[1][1]^2)+(area[1][2]^2))
    for item,chance in pairs(ore_prob) do
        if hex_name == '1616' then
            break
        elseif global.hexs[hex_name].ore <= chance then
            if item == 'water' then
                local tiles = {}
                for _,entity in ipairs(ores) do 
                    local position = entity.position
                    entity.destroy()
                    table.insert(tiles,{name='water',position=position})
                end
                surface.set_tiles(tiles)
            elseif item == 'base' then
                if distance > 500 then
                    for _,entity in ipairs(ores) do 
                        local position = entity.position
                        entity.destroy()
                        local name = "spitter-spawner"
                        if math.random() < 0.5 then name = "biter-spawner" end
                        if math.random() < 0.1 and surface.can_place_entity{name=name,position=position} then
                            surface.create_entity{position=surface.find_non_colliding_position(name,position,20,1),name=name,force="enemy"}
                        end
                    end
                else
                    for _,entity in ipairs(ores) do entity.destroy() end
                end
                return
            elseif item == 'crude-oil' or item == 'tree-02' then
                for _,entity in ipairs(ores) do 
                    local position = entity.position
                    entity.destroy()
                    if item == 'tree-02' and math.random() < 0.2 or math.random() < 0.1 and surface.can_place_entity{name=item,position=position} then
                        surface.create_entity{name=item,position=position}
                    end
                end
            else
                for _,entity in ipairs(ores) do 
                    local position = entity.position
                    entity.destroy()
                    surface.create_entity{name=item,position=position,amount=1+math.floor(50*math.sqrt(math.sqrt(distance)*math.random()))}
                end
            end
            return
        end
    end
    for _,entity in ipairs(ores) do entity.destroy() end
end

Event.register(defines.events.on_chunk_generated,function(event)
    if not global.hexs then global.hexs = {} end
    if not event.surface == game.surfaces[1] then return end
    local surface = game.surfaces[1]
    -- assign all the varibles
    local left_top = event.area.left_top
    local right_bottom = event.area.right_bottom
    local center = {x=left_top.x+16,y=left_top.y+16}
    local chunk_x = left_top.x/32
    local chunk_y = left_top.y/32
    local hex_type = ''
    local inverter = {x=1,y=1,ox=0,oy=0}
    -- y axis invert
    if (chunk_y) % 2 == 0 then
        --nothing changes
    elseif (chunk_y) % 2 == 1 then
        inverter.y = -1
        inverter.oy = -1
    end
    -- x axis invert  also type
    if (chunk_x) % 3 == 0 then
        hex_type='side_'
    elseif (chunk_x) % 3 == 1 then
        hex_type='middle_'
    elseif (chunk_x) % 3 == 2 then
        hex_type='side_'
        inverter.x = -1
        inverter.ox =-1
    end
	
	-- work out replace stone area
    local area_one, area_two = get_hex_areas(hex_type,center,inverter)
    local hex_one, hex_two = get_hex_names(hex_type,center,inverter)
	
	-- make tiles before plaxing dummy stone, inaccessible tiles could affect stone, convert tiles first
	if hex_two then 
        make_tiles(surface,hex_one,center,hexs.tile_big,inverter)
        make_tiles(surface,hex_two,center,hexs.tile_small,inverter)
    else
        make_tiles(surface,hex_one,center,event.area,inverter)
    end
	
    -- make hex_type
    make_borders(surface,hex_type,center,inverter)
    make_ore_base(surface,hex_type,center,inverter)
    
    -- replace the stone
    if hex_two then 
        make_ore(surface,hex_one,area_one)
        make_ore(surface,hex_two,area_two)
    else
        make_ore(surface,hex_one,area_one)
    end
end)

--[[
local player_offset = {0,-1}
local tiles = {}
local player = game.player
player.teleport({math.floor(player.position.x),math.floor(player.position.y)})
offset = {x=player.position.x+player_offset[1],y=player.position.y+player_offset[2]}
for x = -16,16 do
    for y = -16,16 do
        local tile = player.surface.get_tile(x+offset.x,y+offset.y)
        if tile.name == 'out-of-map' or tile.name == 'hazard-concrete-left' or tile.name == 'hazard-concrete-right' or tile.name == 'concrete' then
            game.print(x+offset.x..' '..y+offset.y)
            table.insert(tiles,{tile.name,x+player_offset[1],y+player_offset[2]})
        end
    end
end
game.write_file('test.data',table.tostring(tiles))
]]

--[[
local player_offset = {0,-1}
local tiles = {}
local player = game.player
player.teleport({math.floor(player.position.x),math.floor(player.position.y)})
offset = {x=player.position.x+player_offset[1],y=player.position.y+player_offset[2]}
for x = -16,16 do
    for y = -16,16 do
        local tile = player.surface.get_tile(x+offset.x,y+offset.y)
        if tile.name == 'concrete' then
            game.print(x+offset.x..' '..y+offset.y)
            table.insert(tiles,{x+player_offset[1],y+player_offset[2]})
        end
    end
end
game.write_file('test.data',table.tostring(tiles))
]]

--[[
local player_offset = {0,-1}
local ore = {}
local player = game.player
player.teleport({math.floor(player.position.x),math.floor(player.position.y)})
offset = {x=player.position.x+player_offset[1],y=player.position.y+player_offset[2]}
for x = -16,16 do
    for y = -16,16 do
        local entity = player.surface.find_entity('stone',{x+offset.x+0.5,y+offset.y+0.5})
        if entity then
            game.print(x+offset.x..' '..y+offset.y)
            table.insert(ore,{x+player_offset[1],y+player_offset[2]})
        end
    end
end
game.write_file('test.data',table.tostring(ore))
]]