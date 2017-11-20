--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
define_command('tag',{'tags.help'},{'tag',true},function(player,event,args)
    if player == '<server>' then
        local player = game.players[args[1]]
        local tag = table.concat(args,' ',2)
        if player then
            if args[2] == 'clear' then player.tag = ranking.get_player_rank(player).tag
            else player.tag = ranking.get_player_rank(player).tag..' - '..tag..' '
            end
        else print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
    else
        local tag = table.concat(args,' ',1)
        if args[1] == 'clear' then player.tag = ranking.get_player_rank(player).tag
        elseif string.len(tag) > 20 and not ranking.rank_allowed(ranking.get_player_rank(player),'limitless_tags') then player.print{'tags.invalid-tag'}
        else player.tag = ranking.get_player_rank(player).tag..' - '..tag..' '
        end
    end
end)

