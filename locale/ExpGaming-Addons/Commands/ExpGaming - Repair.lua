--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('repair',{'repair.help'},{'range'},function(player,event,args)
    if player == '<server>' then
        for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end
		for key, entity in pairs(game.surfaces[1].find_entities()) do if entity.health then entity.health = 10000 end end
    else
        if args[1] == 'all' then 
            if not ranking.rank_allowed(ranking.get_player_rank(player),'adv_repair') then player.print{'commands.unauthorized'} return end
            for key, entity in pairs(game.surfaces[1].find_entities_filtered({type = "entity-ghost"})) do entity.revive() end
            for key, entity in pairs(game.surfaces[1].find_entities()) do if entity.health then entity.health = 10000 end end return
        elseif tonumber(args[1]) and tonumber(args[1]) < 50 and tonumber(args[1]) > 0 then
            local range = tonumber(args[1])
            local pos = player.position
            for key, entity in pairs(game.surfaces[1].find_entities_filtered({area={{pos.x-range,pos.y-range},{pos.x+range,pos.y+range}},type = "entity-ghost"})) do entity.revive() end
			for key, entity in pairs(game.surfaces[1].find_entities({{pos.x-range,pos.y-range},{pos.x+range,pos.y+range}})) do if entity.health then entity.health = 10000 end end return
        else player.print{'repai.invalid-range'}
        end
    end
end)

