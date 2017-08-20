--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Science List',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Shows a list with the amount of science packs made',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local science_packs = {
	{name='science-pack-1',display='Red',made={},time=0},
	{name='science-pack-2',display='Green',made={},time=0},
	{name='science-pack-3',display='Blue',made={},time=0},
	{name='military-science-pack',display='Military',made={},time=0},
	{name='production-science-pack',display='Production',made={},time=0},
	{name='high-tech-science-pack',display='High Tech',made={},time=0},
	{name='space-science-pack',display='Space',made={},time=0}
}

local function update_science_packs()
	for n,pack in pairs(global.science_packs) do
		for _,force in pairs(game.forces) do pack.made[force.name] = force.item_production_statistics.get_input_count(pack.name) end
		pack.time = game.tick
	end
end

ExpGui.add_frame.left('science_list','item/lab','Open a list with the amount of science done','Guest',false,function(player,frame)
	frame.caption = 'Science'
	frame.add{name='total_title',type='label',caption='Total Packs:',style="caption_label_style"}
	frame.add{name='total_flow',type='flow',direction='vertical'}
	frame.add{name='minute_title',type='label',caption='Packs Per Minute:',style="caption_label_style"}
	frame.add{name='minute_flow',type='flow',direction='vertical'}
	for n,pack in pairs(global.science_packs) do
		local ammount_made = player.force.item_production_statistics.get_input_count(pack.name)
		frame.total_flow.add{name=pack.name,type='label',caption=pack.display..': '..ammount_made}
		if not pack.made[player.force.name] then frame.minute_flow.add{name=pack.name,type='label',caption=pack.display..': 0.00'} update_science_packs()
		else frame.minute_flow.add{name=pack.name,type='label',caption=pack.display..': '..string.format('%.2f',(ammount_made-pack.made[player.force.name])/((game.tick-pack.time)/(3600*game.speed)))} end
	end
end)

function get_packs_per_minute()
	local to_return = {}
	for n,pack in pairs(global.science_packs) do table.insert(to_return,{pack.name,string.format('%.2f',(ammount_made-pack.made['player'])/((game.tick-pack.time)/(3600*game.speed)))}) end
	return to_return
end

function get_total_packs()
	local to_return = {}
	for n,pack in pairs(global.science_packs) do table.insert(to_return,{pack.name,game.forces['player'].item_production_statistics.get_input_count(pack.name)}) end
	return to_return
end

Event.register(Event.gui_update,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'science_list',true) end update_science_packs() end)
Event.register(defines.events.on_research_finished, function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'science_list',true) end update_science_packs() end)
Event.register(-1,function() global.science_packs = science_packs end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits