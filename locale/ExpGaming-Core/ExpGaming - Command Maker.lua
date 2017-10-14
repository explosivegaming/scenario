--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Explosive Gaming Custom Commands',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows ease to making custom commands in game',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local Exp_commands = {}
--Used mainly by the code to convert the inputs into a string
function command_inputs_to_string(command)
	local str_inputs = ''
	for _,input in pairs(command.inputs) do
		if input == true then break end
		str_inputs = str_inputs..'<'..input..'> '
	end
	return str_inputs
end
--Can be used to ensure the right number of inputs are given
function get_command_args(event,command,allow_invaild)
	local args = {}
	if not event.parameter then 
		if #command.inputs > 0 then 
			if allow_invaild then return args end
			return 'Invalid'
		end
		return args
	end
	for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
	if allow_invaild then return args end
	if command.inputs[#command.inputs] == true then
		if #args < #command.inputs-1 then return 'Invalid' end
	else 
		if #args ~= #command.inputs then return 'Invalid' end 
	end return args
end
--name			is what is used in /command 
--help			is the help info given
--inputs		is a list i.e. {'name','message',true} the last value being true opposed to a string allows a variable number of words for the last input i.e. message can be multiple words long
--event(player,event,args) if the function that will be ran on the command use
function define_command(name,help,inputs,event)
	if not name then error('Command requires a name') end
	local help = help or 'No Help Given'
	local inputs = inputs or {true}
	if not event or type(event) ~= 'function' then error('Command requires a function') end
	table.insert(Exp_commands,{name=name,help=help,inputs=inputs,event=event})
end
--The magic for the commands. It is a hard bit of code so GL; but it will call the command event have some sanitisaion of the input
function load_command(command)
	if commands.commands[command.name] then return end
	debug_write({'COMMAND','LOAD'},command.name)
	game.write_file('commands.log','\n'..game.tick..' Loaded Command: '..command.name, true, 0)
	commands.add_command(command.name,command_inputs_to_string(command)..command.help,function(event)
		local command_data = nil
		for _,command_d in pairs(Exp_commands) do if event.name == command_d[1] then command_data = command_d break end end
		debug_write({'COMMAND','RUN','START'},command.name)
		debug_write({'COMMAND','RUN','PLAYER-INDEX'},event.player_index)
		if event.player_index then
			local player = game.players[event.player_index]
			if not rank_allowed(get_rank(player),command.name) then
				debug_write({'COMMAND','RUN','ALLOWED'},false)
				player.print('401 - Unauthorized: Access is denied due to invalid credentials')
				game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Failed to use command (Unauthorized): '..command.name..' With args of: '..table.tostring(get_command_args(event,command,true)), true, 0)
				return 
			end
			debug_write({'COMMAND','RUN','ALLOWED'},true)
			local args = get_command_args(event,command)
			debug_write({'COMMAND','RUN','ARGS'},args)
			if args == 'Invalid' then 
				player.print('Invalid Input, /'..command.name..' '..command_inputs_to_string(command)) return 
				game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Failed to use command (Invalid Args): '..command.name..' With args of: '..table.tostring(get_command_args(event,command,true)), true, 0)
			end
			debug_write({'COMMAND','RUN','FUNCTION'},command.name)
			command.event(player,event,args)
			player.print('Command Complete')
			game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Used command: '..command.name..' With args of: '..table.tostring(args), true, 0)	
		else
			local args = get_command_args(event,command)
			if args == 'Invalid' then print('Invalid Input, /'..command.name..' '..command_inputs_to_string(command)) return end
			debug_write({'COMMAND','RUN','ARGS'},args)
			debug_write({'COMMAND','RUN','FUNCTION'},command.name)
			command.event('<server>',event,args)
			print('Command Complete')
			game.write_file('commands.log','\n'..game.tick..' Player: <server> Used command: '..command.name..' With args of: '..table.tostring(args), true, 0)
		end
		debug_write({'COMMAND','RUN','END'},command.name,true)
	end)
end
-- returns all the commands in a certain rank restriction
function get_commands(rank)
	local rank = rank or 'Owner'
	local to_return = {}
	for _,command in pairs(global.commands) do
		if rank_allowed(string_to_rank(rank),command.name) then table.insert(to_return,command) end
	end
	return to_return
end
Event.register(-1,function() global.commands = Exp_commands for _,command in pairs(Exp_commands) do load_command(command) end end)
Event.register(defines.events.on_player_joined_game,function() for _,command in pairs(Exp_commands) do load_command(command) end end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits