--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Rocket List',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Shows a list with the curent number of rockets send',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.left('rocket_list','item/rocket-silo','Open a list with rocket milestones',nil,function(player,frame)
	frame.caption = 'Rockets'
	local rockets_send = player.force.get_item_launched("satellite")
	local rocket_time = 'N/A'
	if rockets_send > 1 then rocket_time = tick_to_display_format((game.tick-global.rockets.m1)/rockets_send) end
	frame.add{name='rockets',type='label',caption='Rockets Send: '..rockets_send}
	frame.add{name='time_per',type='label',caption='Time Per Rocket: '..rocket_time}
	frame.add{name='milestones_title',type='label',caption='Rocket Milestones:',style="caption_label_style"}
	local milestones = frame.add{name='milestones',type='flow',direction='vertical'}
	for milestone,time in pairs(global.rockets) do
		local milestone_number = tonumber(milestone:match('%d+'))
		if time == 0 and rockets_send == milestone_number then global.rockets[milestone] = game.tick time = game.tick frame.style.visible = true end
		local time_display = 'N/A' if time > 0 then time_display = tick_to_display_format(time) end
		milestones.add{name=milestone,type='label',caption=milestone_number..': '..time_display}
	end
end)

function get_milestones_times() 
	local to_return = {}
	for milestone,time in pairs(global.rockets) do table.insert(to_return,{tonumber(milestone:match('%d+')),tick_to_display_format(time)}) end
	return to_return
end

Event.register(defines.events.on_rocket_launched, function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'rocket_list',true) end end)
Event.register(-1,function(event) global.rockets = {m1=0,m2=0,m5=0,m10=0,m20=0,m50=0,m100=0,m200=0,m500=0} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits