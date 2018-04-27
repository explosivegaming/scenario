--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

commands.add_command('report', 'Reports a player.', {'player','reason',true}, function(event,args)
    local _player = Game.get_player(event)
    local player = Game.get_player(args.player)
    local reason = args.reason
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    if Ranking.get_rank(player):allowed('no-report') then player_return({'reports.cant-report',args.player}) return commands.error end
    for _,report in pairs(global.addons.reports.reports) do if report[1] == _player.name then player_return({'reports.cant-report',args.player}) return commands.error end end
    for _,report in pairs(global.addons.reports.varified) do if report[1] == _player.name then player_return({'reports.cant-report',args.player}) return commands.error end end
    Admin.report(player,event.player_index,reason)
end)

commands.add_command('warn', 'Gives a player a warnings', {'player','reason',true}, function(event,args)
    local player = Game.get_player(args.player)
    local reason = args.reason
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    if Ranking.get_rank(player):allowed('no-report') then player_return({'reports.cant-report',args.player}) return commands.error end
    Admin.give_warning(player,event.player_index,reason)
end)

commands.add_command('jail', 'Jails a player', {'player','reason',true}, function(event,args)
    local player = Game.get_player(args.player)
    local reason = args.reason
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Ranking.get_rank(player):allowed('no-report') then player_return({'reports.cant-report',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'commands.cant-report-ban',args.player}) return commands.error end
    Admin.jail(player,event.player_index,reason)
end)

commands.add_command('unjail', 'Returns the players old rank', {'player',true}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'commands.cant-report-ban',args.player}) return commands.error end
    Ranking.revert(player,event.player_index)
end)

commands.add_command('temp-ban', 'Temporarily ban a player.', {'player','reason',true}, function(event,args)
    local player = Game.get_player(args.player)
    local reason = args.reason
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.temp_ban(player,event.player_index,reason)
end)

commands.add_command('clear-inv', 'Clears the player\'s invetory', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.move_inventory(player)
end)

commands.add_command('clear-warings', 'Clears the warnings on a player.', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.clear_warings(player,event.player_index)
end)

commands.add_command('clear-reports', 'Clears the reports on a player.', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.clear_reports(player,event.player_index)
end)

commands.add_command('clear-all', 'Clears reports and reports and removes temp-ban', {'player'}, function(event,args)
    local player = Game.get_player(args.player)
    if not player then player_return({'commands.invalid-player',args.player}) return commands.error end
    Admin.clear_player(player,event.player_index)
end)
