--- Adds a function to clear a players inventoy and move the items to spawn.
-- @module ExpGamingAdmin.ClearInventory@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin')
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Function Define
local inventorys = {
    defines.inventory.player_main,
    defines.inventory.player_quickbar,
    defines.inventory.player_trash,
    defines.inventory.player_guns,
    defines.inventory.player_ammo,
    defines.inventory.player_armor
}

function Admin.move_item_to_spawn(item,surface,chests)
    local chests = chests or surface.find_entities_filtered{area={{-10,-10},{10,10}},name='iron-chest'} or {}
    local chest = nil
    while not chest or not chest.get_inventory(defines.inventory.chest).can_insert(item) do
        chest = table.remove(chests,1)
        if not chest then chest = surface.create_entity{
            name='iron-chest',
            position=surface.find_non_colliding_position('iron-chest',{0,0},32,1)
        } end
    end
    chest.get_inventory(defines.inventory.chest).insert(item)
    table.insert(chests,chest)
    return chests
end

function Admin.move_inventory(player)
    local player = Game.get_player(player)
    if not player then return end
    local chests = player.surface.find_entities_filtered{area={{-10,-10},{10,10}},name='iron-chest'} or {}
    for _,_inventory in pairs(inventorys) do
        local inventory = player.get_inventory(_inventory)
        if inventory then
            for item,count in pairs(inventory.get_contents()) do
                local item = {name=item,count=count}
                chests = Admin.move_item_to_spawn(item,player.surface,chests)
            end
            inventory.clear()
        end
    end
end

Admin.add_action('Clear Inventory',Admin.move_inventory)
-- Module Return
return ThisModule 