--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- removed from none admin ranks, no further action
local low_items = {
    'loader',
    'fast-loader',
    'express-loader',
    'small-plane',
    'player-port',
    'coin',
    'programmable-speaker'
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

local inventorys = {
    defines.inventory.player_main,
    defines.inventory.player_quickbar,
    defines.inventory.player_trash
}

local _root_tree = {low_items=low_items,med_items=med_items,high_items=high_items}

local function take_action(player,item_name,category)
    if category == 'low_items' then player_return({'inventory-search.low',item_name},defines.text_color.med,player)
    elseif category == 'med_items' then player_return({'inventory-search.med',item_name},defines.text_color.high,player) Admin.give_warning(player,'<server>','Found A Banned Item',5)
    elseif category == 'high_items' then player_return({'inventory-search.high',item_name},defines.text_color.crit,player) Admin.temp_ban(player,'<server>','Found A Banned Item')
    else return end
end

function search_player(player)
    for category,items in pairs(_root_tree) do
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

Event.register({defines.events.on_player_main_inventory_changed,defines.events.on_player_quickbar_inventory_changed},function(event)
    local player = Game.get_player(event)
    if player and player.name == 'freek18' then search_player(player) end
end)

Event.register(defines.events.on_tick,function(event)
    if (game.tick%900) == 0 then
        local players = game.connected_players
        if #players == 0 then return end
        local player = players[math.random(#players)]
        search_player(player)
    end
end)