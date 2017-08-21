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
function get_command_args(event,command)
	if not event.parameter then if #command.inputs > 0 then return 'Invalid' else return end end
	local args = {}
	for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
	if command.inputs[#command.inputs] == true then
		if #args < #command.inputs-1 then return 'Invalid' end
	else 
		if #args ~= #command.inputs then return 'Invalid' end 
	end return args
end
--name			is what is used in /command 
--help			is the help info given
--inputs		is a list i.e. {'name','message',true} the last value being true opposed to a string allows a variable number of words for the last input i.e. message can be multiple words long
--restriction	is the lowest rank that can use the command
--event(player,event,args) if the function that will be ran on the command use
function define_command(name,help,inputs,restriction,event)
	if not name then error('Command requires a name') end
	local help = help or 'No Help Given'
	local inputs = inputs or {true}
	local restriction = restriction or 0
	if not event or type(event) ~= 'function' then error('Command requires a function') end
	table.insert(Exp_commands,{name=name,help=help,inputs=inputs,restriction=restriction,event=event})
end
--The magic for the commands. It is a hard bit of code so GL; but it will call the command event have some sanitisaion of the input
function load_command(command)
	if commands.commands[command.name] then return end
	game.write_file('commands.log','\n'..game.tick..' Loaded Command: '..command.name, true, 0)
	commands.add_command(command.name,command_inputs_to_string(command)..command.help,function(event)
		local command_data = nil
		for _,command_d in pairs(Exp_commands) do if event.name == command_d[1] then command_data = command_d break end end
		if event.player_index then
			local player = game.players[event.player_index]
			local temp_restriction = nil
			if type(command.restriction) == 'number' then temp_restriction = command.restriction end
			local restriction = temp_restriction or string_to_rank(command.restriction).power or 0
			if get_rank(player).power > restriction then 
				player.print('401 - Unauthorized: Access is denied due to invalid credentials')
				game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Failed to use command: '..command.name..' With args of: '..table.to_string(args), true, 0)
				return 
			end
			local args = get_command_args(event,command)
			if args == 'Invalid' then player.print('Invalid Input, /'..command.name..' '..command_inputs_to_string(command)) return end
			command.event(player,event,args)
			player.print('Command Complete')
			game.write_file('commands.log','\n'..game.tick..' Player: '..player.name..' Used command: '..command.name..' With args of: '..table.to_string(args), true, 0)
		else
			local args = get_command_args(event,command)
			if args == 'Invalid' then print('Invalid Input, /'..command.name..' '..command_inputs_to_string(command)) return end
			command.event('<server>',event,args)
			print('Command Complete')
			game.write_file('commands.log','\n'..game.tick..' Player: <server> Used command: '..command.name..' With args of: '..table.to_string(args), true, 0)
		end
	end)
end
-- returns all the commands in a certain rank restriction
function get_commands(rank)
	local rank = rank or 'Owner'
	local to_return = {}
	for _,command in pairs(global.commands) do
		local temp_restriction = nil
		if type(command.restriction) == 'number' then temp_restriction = command.restriction end
		local restriction = temp_restriction or string_to_rank(command.restriction).power or 0
		if restriction > string_to_rank(rank).power then table.insert(to_return,command) end
	end
	return to_return
end
Event.register(-1,function() global.commands = Exp_commands end)
Event.register(defines.events.on_player_joined_game,function() for _,command in pairs(Exp_commands) do load_command(command) end end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits