--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

commands.add_command('kill', 'Kills a player, must be either yourself (/kill self) or a person of a lower rank.', {'player'}, function(event,args)
    local _player = Game.get_player(event)
    local player = Game.get_player(args.player)
    if args.player ~= 'self' and not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if args.player == 'self' or _player.name == player.name then
        if _player.character then _player.character.die() else player_return({'commands.dead-player'}) return commands.error end
    elseif Ranking.get_rank(player).power > Ranking.get_rank(_player).power then
        if player.connected then else player_return({'commands.offline-player'}) return commands.error end
        if player.character then player.character.die() else player_return({'commands.dead-player'}) return commands.error end
    else player_return({'commands.unauthorized'}) return commands.error end
end)