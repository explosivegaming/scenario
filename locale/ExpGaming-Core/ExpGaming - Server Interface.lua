--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local server = {}
--this command is just a way or using loadstring from in game while keeping achievements
define_command('server-interface',{'server.server-command-help'},{'command',true},function(player,event,args)
	if player == '<server>' then
		local returned,value = pcall(loadstring(event.parameter)) 
		if type(value) == 'table' then game.write_file('server-interface.log', '\n'..game.tick..' Ran by: <server>  Code: '..event.parameter..'\n Returned: '..table.tostring(value), true, 0) print(table.tostring(value))
		else game.write_file('server-interface.log', '\n'..game.tick..' Ran by: <server> Code: '..event.parameter..'\nReturned: '..tostring(value), true, 0) print(value) end
	else
		local returned,value = pcall(loadstring(event.parameter)) 
		if type(value) == 'table' then game.write_file('server-interface-players.log', '\n'..game.tick..' Ran by: '..player.name..' Code: '..event.parameter..'\n Returned: '..table.tostring(value), true, 0) player.print(table.tostring(value))
		else game.write_file('server-interface-players.log', '\n'..game.tick..' Ran by: '..player.name..' Code: '..event.parameter..'\nReturned: '..tostring(value), true, 0) player.print(tostring(value)) end
	end
end)
--runs a server interface command with debug on and does not return any values to the user
define_command('debug',{'server.debug-command-help'},{'command',true},function(player,event,args)
	global.exp_core.debug.state = true
	debug_write({'START'},game.tick..' '..event.parameter)
	global.exp_core.debug.triggered = false
	local returned,value = pcall(loadstring(event.parameter))
	if global.exp_core.debug.triggered and #global.exp_core.server.callback_queue == 0 then debug_write({'END'},game.tick) global.exp_core.debug.state = false end
end)
--runs the preset callback with the uuid
define_command('socket',{'server.socket-command-help'},{'uuid','args'},function(player,event,args)
	if global.exp_core.server.callbacks[args[1]] then
		server.queue_callback(global.exp_core.server.callbacks[args[1]],{unpack(args,2)},args[1])
	end
end)
--this is used when changing permission groups when the person does not have permsion to, can also be used to split a large event accross multiple ticks
local commands_per_iteration = 50 --number of callback commands ran every callback iteration
local ticks_per_iteration = 1 --the number of ticks break before the next callback iteration
local temp_var_time = 1000/commands_per_iteration*ticks_per_iteration --temp vars allow callback funnctions to share data
--adds a callback and saves code to a file
function server.emit(code, callback)
	if type(callback) == 'function' then
		local uuid = server.add_callback(callback)
		game.write_file('socket.data','{ "type":  "JS", "id": "' .. uuid .. '", "code": "' .. code .. '" }\n', true, 0)
	end
end
--adds a call back that can be ran with a command
function server.add_callback(callback,uuid)
	if type(callback) == 'function' then
		local args = args or {}
		local uuid = uuid or server.get_uuid(callback)
		debug_write({'callback','ADD'},uuid)
		table.insert(global.exp_core.server.callbacks,{fun=callback,uuid=uuid})
		server.refresh_uuid(uuid)
		return uuid
	end 
end
--adds a call back function to the queue uuid can be provided
function server.queue_callback(callback,args,uuid)
	if type(callback) == 'function' then
		local args = args or {}
		local uuid = uuid or server.get_uuid(callback)
		debug_write({'CALLBACK','QUEUE'},uuid)
		table.insert(global.exp_core.server.callback_queue,{fun=callback,args=args,uuid=uuid})
		server.refresh_uuid(uuid)
		return uuid
	end 
end
-- clears all temp values and call backs in queue
function server.clear_callbacks()
	global.exp_core.server = {callback_queue={},callbacks={},temp_varibles={}}
end
-- converts any value into the uuid the script will use
function server.get_uuid(var)
	if type(var) == 'string' then uuid = var..tostring(#global.exp_core.server.callback_queue)
	else uuid = tostring(var)..tostring(#global.exp_core.server.callback_queue) end
	server.refresh_uuid(uuid)
	return string.tohex('uuid'..uuid)
end
--update the time on a temp var or add it as a new one
function server.refresh_uuid(uuid,data,offset)
	local offset = offset or temp_var_time
	if global.exp_core.server.temp_varibles[uuid] and not data then
		global.exp_core.server.temp_varibles[uuid].remove_time = game.tick+offset
	else
		local data = data or 'temp-var-temp-value'
		global.exp_core.server.temp_varibles[uuid] = {data=data,remove_time=game.tick+offset}
	end
end
-- gets the data stored in a temp varible
function server.get_uuid_data(uuid)
	if global.exp_core.server.temp_varibles[uuid] then 
		server.refresh_uuid(uuid)
		debug_write({'callback','TEMP-VAR'},uuid) 
		return global.exp_core.server.temp_varibles[uuid].data
	end return nil
end
-- returns the lenth of the temp varible list and command queue, is string is true then it is retured as a string
function server.get_callback_queue_info(string) 
	local lenth = 0
	for _,v in pairs(global.exp_core.server.temp_varibles) do lenth = lenth + 1 end
	if string then return {'server.callback-info',game.tick,#global.exp_core.server.callback_queue,lenth}
	else return {tick=game.tick,commands=#global.exp_core.server.callback_queue,temp_varibles=#global.exp_core.server.temp_varibles} end 
end
--callback main loop
Event.register(defines.events.on_tick, function(event)
	--used with debug command will stop debuging once atleast one message is send to file and there are no commands in callback
	if global.exp_core.debug.state and global.exp_core.debug.triggered and #global.exp_core.server.callback_queue == 0 then debug_write({'END'},game.tick) global.exp_core.debug.state = global.exp_core.debug.focre end
	-- runs the commands in callback
	debug_write({'CALLBACK'},server.get_callback_queue_info(true),true)
	if game.tick % ticks_per_iteration == 0 and global.exp_core.server.callback_queue and #global.exp_core.server.callback_queue > 0 then
		-- gets the number of call backs to run
		local length = nil
		if #global.exp_core.server.callback_queue > commands_per_iteration then length = commands_per_iteration else length = #global.exp_core.server.callback_queue end
		-- runs the right number of commands as set
		for i = 1,length do
			local callback=table.remove(global.exp_core.server.callback_queue,1)
			if callback and callback.fun and type(callback.fun) == 'function' then
				local args = {}
				-- retrives any temp varibles
				for n,value in pairs(callback.args) do
					if type(value) == 'string' and global.exp_core.server.temp_varibles[value] 
					then args[n] = server.get_uuid_data(value)
					else args[n] = value end
				end
				-- makes new temp value and runs command
				local returns = {callback.fun(unpack(args))} or {}
				server.refresh_uuid(callback.uuid,returns)
			end
		end
	end
	-- removes old temp varibles
	for uuid,data in pairs(global.exp_core.server.temp_varibles) do
		if data.remove_time <= game.tick then global.exp_core.server.temp_varibles[uuid] = nil end
	end
end)
Event.register(Event.soft_init,function() global.exp_core.server = {callback_queue={},callbacks={},temp_varibles={}} end)
return server