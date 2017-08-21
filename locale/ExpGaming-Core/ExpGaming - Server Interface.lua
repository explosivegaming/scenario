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
		if type(value) == 'table' then game.write_file('server-interface.log', '\n'..game.tick..' Ran by: <server>  Code: '..event.parameter..'\n Returned: '..table.to_string(value), true, 0) print(table.to_string(value))
		else game.write_file('server-interface.log', '\n'..game.tick..' Ran by: <server> Code: '..event.parameter..'\n Returned: '..tostring(value), true, 0) print(value) end
	else
		local returned,value = pcall(loadstring(event.parameter)) 
		if type(value) == 'table' then game.write_file('server-interface-players.log', '\n'..game.tick..' Ran by: '..player.name..' Code: '..event.parameter..'\n Returned: '..table.to_string(value), true, 0) player.print(table.to_string(value))
		else game.write_file('server-interface-players.log', '\n'..game.tick..' Ran by: '..player.name..' Code: '..event.parameter..'\n Returned: '..tostring(value), true, 0) player.print(value) end
	end
end)
--this is used when changing permission groups when the person does not have permsion to, can also be used to split a large event accross multiple ticks
local commands_per_iteration = 50 --number of sudo commands ran every sudo iteration
local ticks_per_iteration = 1 --the number of ticks break before the next sudo iteration
local temp_var_time = 1000/commands_per_iteration*ticks_per_iteration --temp vars allow sudo funnctions to share data
function sudo(command,args,custom_return_name)
	if type(command) == 'function' then
		local args = args or {}
		local return_name = custom_return_name or tostring(game.tick)..tostring(command)..tostring(#global.sudo.commands)
		table.insert(global.sudo.commands,{fun=command,args=args,return_name=return_name})	
		return {sudo='sudo-temp-var',name=return_name}
	end 
end
--turns a string into the temp var format so that it can be used
function format_as_temp_var(string)
	refresh_temp_var(string)
	return {sudo='sudo-temp-var',name=tostring(string)}
end
--update the time on a temp var or add it as a new one
function refresh_temp_var(name,value,offset)
	local offset = offset or temp_var_time
	if global.sudo.temp_varibles[name] then
		global.sudo.temp_varibles[name].remove_time = game.tick+offset
	else
		global.sudo.temp_varibles[name] = {data=value,remove_time=game.tick+offset}
	end
end
-- gets the data stored in a temp varible
function get_temp_var_data(var) 
	local to_return = nil
	if global.sudo.temp_varibles[var] then to_return = global.sudo.temp_varibles[var].data
	elseif var.name and global.sudo.temp_varibles[var.name] then to_return = global.sudo.temp_varibles[var.name].data end
	return to_return 
end
-- returns the lenth of the temp varible list and command queue, is string is true then it is retured as a string
function get_sudo_info(string) 
	local lenth = 0
	for _,v in pairs(global.sudo.temp_varibles) do lenth = lenth + 1 end
	if string then return 'At game tick: '..game.tick..' Queue Lenth: '..#global.sudo.commands..' Number of temp vars: '..lenth
	else return {tick=game.tick,commands=#global.sudo.commands,temp_varibles=#global.sudo.temp_varibles} end 
end
--sudo main loop
Event.register(defines.events.on_tick, function(event)
	-- runs the commands in sudo
	if game.tick % ticks_per_iteration == 0 and global.sudo.commands and #global.sudo.commands > 0 then
		local length = nil
		if #global.sudo.commands > commands_per_iteration then length = commands_per_iteration else length = #global.sudo.commands end
		-- runs the right number of commands as set
		for i = 1,length do
			local command=table.remove(global.sudo.commands,1)
			if command and command.fun and type(command.fun) == 'function' then
				local args = {}
				-- retrives and temp varibles
				for n,value in pairs(command.args) do
					if type(value) == 'list' and value.sudo == 'sudo-temp-var' then args[n] = global.sudo.temp_varibles[value.name].data
					else args[n] = value end
				end
				-- makes new temp value and runs command
				local returns = {command.fun(unpack(args))} or {}
				refresh_temp_var(command.return_name,returns)
			end
		end
	end
	-- removes old temp varibles
	for name,data in pairs(global.sudo.temp_varibles) do
		if data.remove_time >= game.tick then global.sudo.temp_varibles[name] = nil end
	end
end)
Event.register(-1,function() global.sudo = {commands={},temp_varibles={}} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits