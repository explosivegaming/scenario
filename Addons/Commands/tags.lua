--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local const = 20
-- this is the max lenth of a tag

commands.add_command('tag', 'Give yourself a custom tag. Use /tag-clear self to remove tag', {'tag',true}, function(event,args)
    local player = Game.get_player(event)
    local rank = Ranking.get_rank(player)
    if string.len(args.tag) > const then player_return({'commands.invalid-length',const}) return commands.error end
    player.tag = rank.tag..' - '..args.tag
end)

commands.add_command('tag-clear', 'Removes a custom tag. Player can be self (/tag-clear self)', {'player'}, function(event,args)
    local _player = Game.get_player(event)
    local _rank = Ranking.get_rank(_player)
    local player = Game.get_player(args.player)
    local rank = Ranking.get_rank(player)
    if args.player ~= 'self' and not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if  args.player == 'self' or _player.name == player.name then _player.tag = _rank.tag
    elseif _rank.power < rank.power then player.tag = rank.tag
    else player_return({'commands.unauthorized'}) return commands.error end
end)
