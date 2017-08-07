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
	for _,input in pairs(command[3]) do
		if input == true then break end
		str_inputs = str_inputs..'<'..input..'> '
	end
	return str_inputs
end
--Can be used to ensure the right number of inputs are given
function get_command_args(event,command)
	if not event.parameter then if #command[3] > 0 then return 'Invalid' else return end end
	local args = {}
	for word in event.parameter:gmatch('%S+') do table.insert(args,word) end
	if command[3][#command[3]] == true then
		if #args < #command[3]-1 then return 'Invalid' end
	else 
		if #args ~= #command[3] then return 'Invalid' end 
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
	table.insert(Exp_commands,{name,help,inputs,restriction,event})
end
--The magic for the commands. It is a hard bit of code so GL; but it will call the command event have some sanitisaion of the input
function load_command(command)
	if commands.commands[command[1]] then return end
	commands.add_command(command[1],command_inputs_to_string(command)..command[2],function(event)
		local command_data = nil
		for _,command_d in pairs(Exp_commands) do if event.name == command_d[1] then command_data = command_d break end end
		if event.player_index then
			local player = game.players[event.player_index]
			local temp_restriction = nil
			if type(command[4]) == 'number' then temp_restriction = command[4] end
			local restriction = temp_restriction or string_to_rank(command[4]).power or 0
			if get_rank(player).power > restriction then player.print('401 - Unauthorized: Access is denied due to invalid credentials') return end
			local args = get_command_args(event,command)
			if args == 'Invalid' then player.print('Invalid Input, /'..command[1]..' '..command_inputs_to_string(command)) return end
			command[5](player,event,args)
			player.print('Command Complete')
		else
			local args = get_command_args(event,command)
			if args == 'Invalid' then print('Invalid Input, /'..command[1]..' '..command_inputs_to_string(command)) return end
			command[5]('<server>',event)
			print('Command Complete')
		end
	end)
end

Event.register(-1,function() global.commands = Exp_commands end)
Event.register(defines.events.on_player_joined_game,function() for _,command in pairs(Exp_commands) do load_command(command) end end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits