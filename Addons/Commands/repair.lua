--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

-- these items are not repaired, true means it is blocked
local disallow = {
    ['loader']=true,
    ['fast-loader']=true,
    ['express-loader']=true,
    ['electric-energy-interface']=true,
    ['infinity-chest']=true
}

local const = 100
-- given const = 100: admin+ has unlimited, admin has 100, mod has 50, member has 20

commands.add_command('repair', 'Repairs all destoryed and damaged entites in an area.', {'range'}, function(event,args)
    local range = tonumber(args.range)
    local player = Game.get_player(event)
    local rank = Ranking.get_rank(player)
    local highest_admin_power = Ranking.get_group('Admin').highest.power-1
    local max_range = rank.power-highest_admin_power > 0 and const/(rank.power-highest_admin_power) or nil
    local center = player and player.position or {x=0,y=0}
    if not range or max_range and range > max_range then player_return({'commands.invalid-range',0,math.floor(max_range)}) return commands.error end
    local area = {{center.x-range,center.y-range},{center.x+range,center.y+range}}
    local max_time_to_live = 2^32 - 1
    local sq_range = range^2
    for key, entity in pairs(player.surface.find_entities_filtered({area=area,type='entity-ghost'})) do
        if entity.force == player.force and (entity.position.x-center.x)^2+(entity.position.y-center.y)^2 < sq_range then
            if disallow[entity.ghost_prototype.name] then
                player_return('You have repaired: '..entity.name..' this item is not allowed.',defines.text_color.crit,player)
                Admin.temp_ban(player,'<server>','Attempt To Repair A Banned Item')
                entity.destroy()
            elseif entity.time_to_live ~= max_time_to_live then
                entity.revive() end
        end
    end
    for key, entity in pairs(player.surface.find_entities(area)) do
        if entity.force == player.force and (entity.position.x-center.x)^2+(entity.position.y-center.y)^2 < sq_range and entity.health then entity.health = 10000 end
    end
end)
