--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local Exp_commands = {}
--Used mainly by the code to convert the inputs into a string
local function command_inputs_to_string(command)
	local str_inputs = ''
	for _,input in pairs(command.inputs) do
		if input == true then break end
		str_inputs = str_inputs..'<'..input..'> '
	end
	return str_inputs
end
--Can be used to ensure the right number of inputs are given
local function get_command_args(event,command,allow_invaild)
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
	local help = help or {'commands.no-help'}
	local inputs = inputs or {true}
	if not event or type(event) ~= 'function' then error('Command requires a function') end
	Exp_commands[name]={name=name,help=help,inputs=inputs,event=event}
end
--The magic for the commands. It is a hard bit of code so GL; but it will call the command event have some sanitisaion of the input
local function load_command(command)
	--is the command all ready loaded
	if commands.commands[command.name] then return end
	--start loading command
	global.exp_core.commands[command.name] = command
	debug_write({'COMMAND','LOAD'},command.name)
	--add command to game
	debug_write({'COMMAND','LOAD'},command)
	commands.add_command(command.name,{'commands.help-format',command_inputs_to_string(command),command.help},function(event)
		--gets the command data
		local command_data = global.exp_core.commands[event.name]
		debug_write({'COMMAND','RUN','START'},command.name)
		debug_write({'COMMAND','RUN','PLAYER-INDEX'},event.player_index)
		if event.player_index then
			--player ran command so authoriz it
			local player = game.players[event.player_index]
			if not ranking.rank_allowed(ranking.get_player_rank(player),command.name) then
				debug_write({'COMMAND','RUN','ALLOWED'},false)
				player.print({'commands.unauthorized'})
				game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Failed to use command (Unauthorized): '..command.name..' With args of: '..table.tostring(get_command_args(event,command,true)), true, 0)
				return 
			end
			--start prossessing command inputs, check if valid
			debug_write({'COMMAND','RUN','ALLOWED'},true)
			local args = get_command_args(event,command)
			debug_write({'COMMAND','RUN','ARGS'},args)
			if args == 'Invalid' then 
				player.print({'commands.invalid-inputs',command.name,command_inputs_to_string(command)})
				game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Failed to use command (Invalid Args): '..command.name..' With args of: '..table.tostring(get_command_args(event,command,true)), true, 0)
				return
			end
			--run the callback function of the command
			debug_write({'COMMAND','RUN','FUNCTION'},command.name)
			command.event(player,event,args)
			player.print({'commands.command-ran'})
			game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Used command: '..command.name..' With args of: '..table.tostring(args), true, 0)	
		else
			--server ran command so skip authorizion
			local args = get_command_args(event,command)
			if args == 'Invalid' then print('Invalid Input, /'..command.name..' '..command_inputs_to_string(command)) return end
			debug_write({'COMMAND','RUN','ARGS'},args)
			--run the callback function of the command
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
	for command_name,command in pairs(global.exp_core.commands) do
		if ranking.rank_allowed(ranking.string_to_rank(rank),command_name) then table.insert(to_return,command) end
	end
	return to_return
end
Event.register(Event.soft_init,function() global.exp_core.commands = {} for command_name,command in pairs(Exp_commands) do load_command(command) end end)
Event.register(defines.events.on_player_joined_game,function() for command_name,command in pairs(Exp_commands) do load_command(command) end end)