--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Server Interface',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='A way of talking with the server with out breaking achevements',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
--this command is just a way or using loadstring from in game while keeping achevements
Event.register(defines.events.on_player_joined_game,function()
	if commands.commands['server-interface'] then return end
	commands.add_command('server-interface','<command>  #2#',function(event)
		if event.player_index then
			local by_player = game.players[event.player_index]
			if get_rank(by_player).power > 2 then by_player.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			if event.parameter then else by_player.print('Invaid Input, /server-interface <command>') return end
			local returned,value = pcall(loadstring(event.parameter)) 
			if type(value) == 'table' then game.write_file('log.txt', '\n Ran by: '..by_player.name..'\n Code: '..event.parameter..'\n $£$ '..table.to_string(value), true, 0) by_player.print(table.to_string(value))
			else game.write_file('log.txt', '\n Ran by: '..by_player.name..'\n Code: '..event.parameter..'\n $£$ '..tostring(value), true, 0) by_player.print(value) end
		else 
			if event.parameter then else print('Invaid Input, /server-interface <command>') return end
			local returned,value = pcall(loadstring(event.parameter)) 
			if type(value) == 'table' then game.write_file('log.txt', '\n Ran by: <server> \n Code: '..event.parameter..'\n $£$ '..table.to_string(value), true, 0) print(table.to_string(value))
			else game.write_file('log.txt', '\n Ran by: <server> \n Code: '..event.parameter..'\n $£$ '..tostring(value), true, 0) print(value) end
		end
	end)
end)
--this is used when changing permsion groups when the person does not have permsion to
function sudo(command,args) table.insert(global.sudo,{fun=command,var=args}) end
--runs one sudo command every second if one is present
Event.register(defines.events.on_tick, function(event) 
	if game.tick % 60 == 0 and global.sudo and #global.sudo > 0 then 
		command=table.remove(global.sudo)
		if command and command.fun and type(command.fun) == 'function' then
			local args = command.var or {}
			command.fun(args[1],args[2],args[3],args[4],args[5],args[6]) 
		end
	end
end)
Event.register(-1,function() global.sudo = {} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits