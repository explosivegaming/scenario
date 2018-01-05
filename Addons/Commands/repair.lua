--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local const = 100
-- given const = 100: admin+ has unlimited, admin has 100, mod has 50, member has 20

commands.add_command('repair', 'Repairs all destoryed and damaged entites in an area', {'range'}, function(event,args)
    local range = tonumber(args.range)
    local rank = Ranking.get_rank(event)
    local highest_admin_power = Ranking.get_group('Admin').highest.power-1
    local max_range = rank.power-highest_admin_power > 0 and const/(rank.power-highest_admin_power) or nil
    local center = Game.get_player(event) and Game.get_player(event).position or {x=0,y=0}
    if not range or max_range and range > max_range then player_return({'commands.invalid-range',0,math.floor(max_range)}) return commands.error end
    for x = -range-2, range+2 do
        for y = -range-2, range+2 do
            if x^2+y^2 < range^2 then
                for key, entity in pairs(player.surface.find_entities_filtered({area={{x,y},{x+1,y+1}},type ='entity-ghost'})) do entity.revive() end
                for key, entity in pairs(player.surface.find_entities({{x,y},{x+1,y+1}})) do if entity.health then entity.health = 10000 end end
            end
        end
    end
end)