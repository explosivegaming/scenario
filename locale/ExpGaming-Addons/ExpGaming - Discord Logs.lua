--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--we have other lines located in user report, temp-ban and rank control
Event.register(defines.events.on_console_command,function(event)
	local command = event.command
	local args = {}
	if event.parameters then for word in event.parameters:gmatch('%S+') do table.insert(args,word) end end
	local colours = {
		info='#36F2FF',
		alert='#0',
		low='#2dc42d',
		med='#ffe242',
		high='#ff5400',
		crit='#FF0000'
	}
	local data = {type=string.upper(command),tick=game.tick,online=#game.connected_players}
	data.by = event.player_index > 0 and game.players[event.player_index].name or '<server>'
	if command == 'ban' then
		data.colour = colours.crit
		data.username = args[1]
		data.reason = table.concat(args,' ',2)
	elseif command == 'unban' then
		data.colour = colours.low
		data.username = args[1]
	elseif command == 'mute' then
		data.colour = colours.med
		data.username = args[1]
	elseif command == 'unmute' then
		data.colour = colours.low
		data.username = args[1]
	elseif command == 'kick' then
		data.colour = colours.med
		data.username = args[1]
		data.reason = table.concat(args,' ',2)
	elseif command == 'promote' then
		data.colour = colours.info
		data.username = args[1]
	elseif command == 'demote' then
		data.colour = colours.info
		data.username = args[1]
	elseif command == 'config' then
		data.colour = colours.info
		data.reason = table.concat(args,' ',1)
	elseif command == 'purge' then
		data.colour = colours.med
		data.username = args[1]
	elseif command == 'banlist' then
		data.colour = colours.alert
		data.reason = table.concat(args,' ',1)
	else return end
	data.username = data.username or data.by
	data.onlineMods=0; for _,player in pairs(game.connected_players) do if ranking.get_player_rank(player).power <= ranking.string_to_rank_group('Moderation').lowest_rank.power then data.onlineMods=data.onlineMods+1 end end
	json_log(data)
end)