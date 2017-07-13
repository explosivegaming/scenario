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
ExpGui.add_frame.left('rocket_list','item/rocket-silo','Open a list with rocket milestones','Guest',false,function(player,frame)
	frame.caption = 'Rockets'
	local rockets_send = player.force.get_item_launched("satellite")
	frame.add{name='time_per',type='label',caption='Time Per Rocket: '..''}
	for milestone,time in pairs (global.rockets) do
		local milestone = tonumber(milestone:sub(2))
		
	end
end)

Event.register(-1,function(event) global.rockets = {m1=nil,m2=nil,m5=nil,m10=nil,m20=nil,m50=nil,m100=nil,m200=nil,m500=nil} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits