--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Explosive Gaming Server Interface',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='A way of talking with the server with out breaking achievements',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
--this command is just a way or using loadstring from in game while keeping achievements
define_command('server-interface','For use of the highest staff only',{'command',true},'admin',function(player,event,args)
	if player == '<server>' then
		local returned,value = pcall(loadstring(event.parameter)) 
		if type(value) == 'table' then game.write_file('log.txt', '\n Ran by: <server> \n Code: '..event.parameter..'\n $£$ '..table.to_string(value), true, 0) print(table.to_string(value))
		else game.write_file('log.txt', '\n Ran by: <server> \n Code: '..event.parameter..'\n $£$ '..tostring(value), true, 0) print(value) end
	else
		local returned,value = pcall(loadstring(event.parameter)) 
		if type(value) == 'table' then game.write_file('log.txt', '\n Ran by: '..player.name..'\n Code: '..event.parameter..'\n $£$ '..table.to_string(value), true, 0) player.print(table.to_string(value))
		else game.write_file('log.txt', '\n Ran by: '..player.name..'\n Code: '..event.parameter..'\n $£$ '..tostring(value), true, 0) player.print(value) end
	end
end)
--this is used when changing permission groups when the person does not have permsion to, can also be used to split a large event accross multiple ticks
local commands_per_iteration = 50 --number of sudo commands ran every sudo iteration
local ticks_per_iteration = 1 --the number of ticks break before the next sudo iteration
function sudo(command,args) table.insert(global.sudo,{fun=command,var=args}) end
--runs at most five sudo commands every five ticks if one is present
Event.register(defines.events.on_tick, function(event)
	if game.tick % ticks_per_iteration == 0 and global.sudo and #global.sudo > 0 then
		local length = nil
		if #global.sudo > commands_per_iteration then length = commands_per_iteration else length = #global.sudo end
		for i = 1,length do
			command=table.remove(global.sudo)
			if command and command.fun and type(command.fun) == 'function' then
				local args = command.var or {}
				command.fun(unpack(args))
			end
		end
	end
end)
Event.register(-1,function() global.sudo = {} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits