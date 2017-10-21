--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.left('rocket_list','item/rocket-silo',{'rocket-gui.tooltip'},nil,function(player,frame)
	frame.caption = {'rocket-gui.name'}
	-- basic info
	local rockets_send = player.force.get_item_launched("satellite")
	local rocket_time = {'rocket-gui.na'}
	if rockets_send > 1 then rocket_time = tick_to_display_format((game.tick-global.rockets.m1)/rockets_send) end
	frame.add{name='rockets',type='label',caption={'rocket-gui.send',rockets_send}}
	frame.add{name='time_per',type='label',caption={'rocket-gui.time',rocket_time}}
	-- milestones
	frame.add{name='milestones_title',type='label',caption={'rocket-gui.milestones'},style="caption_label_style"}
	local milestones = frame.add{name='milestones',type='flow',direction='vertical'}
	for _,milestone in pairs(get_milestones_times()) do
		-- check if a new mile stone is reached
		if milestone.time == 0 and rockets_send == milestone.number then 
			global.rockets['m'..milestone.number] = game.tick 
			milestone.time = game.tick 
			frame.style.visible = true 
		end
		-- time and output
		local time_display = {'rocket-gui.na'}; if milestone.time > 0 then time_display = tick_to_display_format(milestone.time) end
		milestones.add{name=milestone,type='label',caption={'rocket-gui.milestones-format',tostring(milestone.number),time_display}}
	end
end)

function get_milestones_times() 
	local to_return = {}
	for milestone,time in pairs(global.rockets) do table.insert(to_return,{number=tonumber(milestone:match('%d+')),time=time}) end
	return to_return
end

Event.register(defines.events.on_rocket_launched, function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'rocket_list',true) end end)
Event.register(Event.soft_init,function(event) global.rockets = {m1=0,m2=0,m5=0,m10=0,m20=0,m50=0,m100=0,m200=0,m500=0} end)

