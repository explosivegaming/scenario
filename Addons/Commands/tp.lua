--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

commands.add_command('go-to', 'Go to a player\'s location', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    Admin.go_to(player,event)
end)

commands.add_command('bring', 'Bring a player to your location', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    Admin.bring(player,event)
end)
