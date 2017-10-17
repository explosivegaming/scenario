--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Tree Remover',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Removes trees and stone with use of deconstruction planer',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
local function get_report_info(reporter,player,reason)
	local info = {player=player,total_reports=0,trusted_reports=0,reports=0,reasons={},players={}}
	-- sees if the user as already been reported
	local index = nil; for i,report in pairs(global.reported_users) do if info.player.name == report.player.name then info = report index = i break end end
	-- has the player report this user already
	for _,reporter_name in pairs(info.players) do if reporter.name == reporter_name then return end end
	table.insert(info.players,reporter.name)
	-- updates the report info
	if rank_allowed(ranking.get_player_rank(player),'trusted_reporter') then info.trusted_reports = info.trusted_reports + 1
	else info.reports = info.reports + 1 end
	table.insert(info.reasons,reason)
	info.total_reports = info.trusted_reports + info.reports
	-- inserts the info back into the global reports
	if index then global.reported_users[index] = info
	else table.insert(global.reported_users,info) end
	return info
end

define_command('report','Reports a user, this will be logged and you may be ask about it',{'player','reason',true},function(player,event,args)
	if player == '<server>' then
		print('No reason to use this command, you are the server')
	else
		if rank_allowed(ranking.get_player_rank(player),'rank_changer') then player.print('You have no reason to report, please use rank changer to move player to jail') return end
		local p = game.players[args[1]]
		if not p then player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
		if rank_allowed(ranking.get_player_rank(p),'report_protection') then player.print('This player has report protection and cant be reported') return end
		if p == player then player.print('You can not report yourself') return end
		local reason = table.concat(args,' ',2)
		local info = get_report_info(player,p,reason)
		if not info then player.print('You have already reported this player, vist discord to complain more') return end
		-- prints to players
		if rank_allowed(ranking.get_player_rank(player),'trusted_reporter') then ranking.rank_print(p.name..' has just been reported by a trusted user.','Owner',true)
		else ranking.rank_print(p.name..' has just been reported by a user.','Owner',true) end
		if info.trusted_reports > 0 then ranking.rank_print(p.name..' has been reported '..info.total_reports..' times, if reported by 40% of the server they will be jailed!','Owner',true)
		else ranking.rank_print(p.name..' has been reported '..info.total_reports..' times, if reported by 60% of the server they will be jailed!','Owner',true) end
		ranking.rank_print('To report use /report <player> <reason>','Owner',true)
		-- logs to file
		game.write_file('multi.log','{"type": "USER_REPORT","tick":'..game.tick..',"username":"'..info.player.name..'","by":"'..player.name..'","reason":"'..reason..'"}\n', true, 0)
		-- logic to jail player
		local percent_needed = 0.6; if info.trusted_reports > 0 then percent_needed = 0.4 end
		local players_needed = math.floor(#game.connected_players * percent_needed)
		if info.total_reports >= players_needed then game.write_file('user_reports.log','\n'..game.tick..' '..p.name..' has been jailed', true, 0) server.queue_callback(give_rank,{p,'Jail'}) end
	end
end)

define_command('remove-report','Clears the reports give to a user',{'player','reason',true},function(player,event,args)
	if player == '<server>' then
		local p = game.players[args[1]]
		local reason = table.concat(args,' ',2)
		if not p then print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
		-- test if the player is reported
		local index = nil; for i,report in pairs(global.reported_users) do if p.name == report.player.name then index = i break end end
		if not index then print('This player has no reports') return end
		-- reverts rank and clears report
		ranking.rank_print(p.name..' has been cleared of they reports by: <server>','Owner',true)
		game.write_file('user_reports.log','\n{"type":"USER_REPORT_CLEAR","tick":'..game.tick..',"username":"'..p.name..'","by":"<server>","reason":"'..reason..'"}\n', true, 0)
		global.reported_users[p.name] = nil
		if ranking.get_player_rank(p).name == 'Jail' then server.queue_callback(revert_rank,{p}) end
	else
		local p = game.players[args[1]]
		local reason = table.concat(args,' ',2)
		if not p then player.print('Invaild Player Name,'..args[1]..', try using tab key to auto-complete the name') return end
		-- test if the player is reported
		local index = nil; for i,report in pairs(global.reported_users) do if p.name == report.player.name then index = i break end end
		if not index then player.print('This player has no reports') return end
		-- reverts rank and clears report
		ranking.rank_print(p.name..' has been cleared of they reports by: '..player.name,'Owner',true)
		game.write_file('multi.log','\n{"type":"USER_REPORT_CLEAR","tick":'..game.tick..',"username":"'..p.name..'","by":"'..player.name..'","reason":"'..reason..'"}\n', true, 0)
		global.reported_users[p.name] = nil
		if ranking.get_player_rank(p).name == 'Jail' then server.queue_callback(revert_rank,{p,player}) end
	end
end)
function get_reported_users() return global.reported_users end
Event.register(Event.soft_init,function() global.reported_users = {} end)


