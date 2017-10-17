--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Task List',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Shows a task with the curent tasks set by players',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
local function draw_standard(player,frame)
	frame.clear()
	local table = frame.add{type='table',name='task_table',colspan=2}
	for n,task in pairs(get_tasks()) do
		table.add{type='label',name=n..'_number',caption=n..'.'}
		table.add{type='label',name=n..'_task',caption=task}
	end
	if rank_allowed(ranking.get_player_rank(player),'edit_tasks') then ExpGui.add_input.draw_button(frame,'enter_edit') end
end

local function draw_edit_mode(player,frame)
	frame.clear()
	local table = frame.add{type='table',name='task_table',colspan=3}
	for n,task in pairs(global.tasks.players[player.index]) do
		table.add{type='label',name=n..'_number',caption=n..'.'}
		table.add{type='text-box',name=n..'_task',text=task}.style.minimal_width=250
		table.add{type='flow',name=n..'flow'}
		ExpGui.add_input.draw_button(table[n..'flow'],'remove')
	end
	frame.add{type='flow',name='button_flow',direction='horizontal'}
	ExpGui.add_input.draw_button(frame.button_flow,'save')
	ExpGui.add_input.draw_button(frame.button_flow,'exit')
	ExpGui.add_input.draw_button(frame.button_flow,'add_task')
end

ExpGui.add_input.button('add_task','Add','Add a new task',function(player,element)
	for n,task in pairs(global.tasks.players[player.index]) do global.tasks.players[player.index][n] = element.parent.parent.task_table[n..'_task'].text end
	table.insert(global.tasks.players[player.index],'')
	draw_edit_mode(player,element.parent.parent)
end)

ExpGui.add_input.button('remove','X','Remove this task',function(player,element)
	for n,task in pairs(global.tasks.players[player.index]) do global.tasks.players[player.index][n] = element.parent.parent.parent.task_table[n..'_task'].text end
	local n = tonumber(element.parent.name:match('%d+'))
	table.remove(global.tasks.players[player.index],n)
	draw_edit_mode(player,element.parent.parent.parent)
end)

ExpGui.add_input.button('exit','Exit','Returns to stanard view without saving',function(player,element)
	draw_standard(player,element.parent.parent)
end)

ExpGui.add_input.button('save','Save','Press to save any changes (will update for other users)',function(player,element)
	local temp_list = {}
	for n,task in pairs(global.tasks.players[player.index]) do
		global.tasks.players[player.index][n] = element.parent.parent.task_table[n..'_task'].text
		if global.tasks.players[player.index][n]:match('%S') then table.insert(temp_list,global.tasks.players[player.index][n]) end
	end
	global.tasks.server = {table.unpack(temp_list)}
	for _,p in pairs(game.connected_players) do ExpGui.draw_frame.left(p,'task_list',true) end
end)

ExpGui.add_input.button('enter_edit','Press To Edit','Press to edit the current tasks',function(player,element)
	global.tasks.players[player.index] = {table.unpack(global.tasks.server)}
	draw_edit_mode(player,element.parent)
end)

ExpGui.add_frame.left('task_list','item/inserter','Toggle Task List',true,function(player,frame)
	frame.caption = 'Task List'
	draw_standard(player,frame)
end)

function get_tasks() return global.tasks.server end
Event.register(Event.rank_change,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'task_list',true) end end)
Event.register(Event.soft_init,function() global.tasks = {server={'Power','Starter base for red science','Plans for main base','Work on building main smelters','Green science in starter base'},players={}} end)

