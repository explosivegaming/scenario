--- Adds an inventory search that is proformed on a random player every 15 seconds
-- @module ExpGamingPlayer.inventorySearch@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Admin = require('ExpGamingAdmin')
local Game = require('FactorioStdLib.Game')
local Role -- ExpGamingCore.Role@^4.0.0

-- Local Varibles
-- removed from none admin ranks, no further action
local low_items = {
    'loader',
    'fast-loader',
    'express-loader',
    'small-plane',
    'player-port',
    'coin',
    'programmable-speaker',
    'logistic-chest-active-provider'
}

-- removed for admin and non-admin ranks, gives warnings to non-admins
local med_items = {
    'railgun',
    'railgun-dart',
    'belt-immunity-equipment'
}

-- temp-ban for any rank, this is a very hard enforcement, admin ranks lose rank
local high_items = {
    'electric-energy-interface',
    'infinity-chest'
}

-- inventories which are searched
local inventorys = {
    defines.inventory.player_main,
    defines.inventory.player_quickbar,
    defines.inventory.player_trash
}

local _root_tree = {low_items=low_items,med_items=med_items,high_items=high_items}

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Role'] then Role = require('ExpGamingCore.Role') end
    end
}

-- Function Define
local function take_action(player,item_name,category)
    if category == 'low_items' then player_return({'ExpGamingPlayer-inventorySearch.low',item_name},defines.textcolor.med,player)
    elseif category == 'med_items' then player_return({'ExpGamingPlayer-inventorySearch.med',item_name},defines.textcolor.high,player) Admin.give_warning(player,'<server>','Found A Banned Item',5)
    elseif category == 'high_items' then player_return({'ExpGamingPlayer-inventorySearch.high',item_name},defines.textcolor.crit,player) Admin.temp_ban(player,'<server>','Found A Banned Item')
    else return end
end

function ThisModule.search_player(player)
    for category,items in pairs(_root_tree) do
        if not Role or category ~= 'low_items' and not Role.allowed(player,'admin-items') then
            for _,_inventory in pairs(inventorys) do
                local inventory = player.get_inventory(_inventory)
                if inventory then
                    for _,item in pairs(items) do
                        local found = inventory.remove(item)
                        if found > 0 then take_action(player,item,category) end
                    end
                end
            end
        end
    end
end

-- Event Handlers Define
script.on_event(defines.events.on_tick,function(event)
    if (game.tick%900) == 0 then
        local players = game.connected_players
        if #players == 0 then return end
        local player = players[math.random(#players)]
        if Role and Role.allowed(player,'all-items') then return end
        ThisModule.search_player(player)
    end
end)

-- Module Return
return setmetatable(ThisModule,{
    __call=function(self,...) self.search_player(...) end
})