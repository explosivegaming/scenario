--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Control',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Core Factorio File',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
require("mod-gui")
credit_loop(require("locale/StdLib/event"))
credit_loop(require("locale/file-header"))

Event.register(-1,function() global.credits = credits end)

--temp
ExpGui.add_frame.center('Test','Test','A Simple Gui',5)
ExpGui.add_frame.tab('testing','Long Tab','Just Like any other',5,'Test',function(player,tab) for i=0,100 do tab.add{type='label',name=i,caption=player.name} end end)
ExpGui.add_frame.tab('just_a_tab','A Tab','Just Like any other',5,'Test',function(player,tab) tab.add{type='label',name='temp',caption=player.name} end)
ExpGui.add_frame.left('left_test','Player Name','Just Like any other',5,function(player,frame) for i=0,10 do frame.add{type='label',name=i,caption=player.name..'\n'} end end)
ExpGui.add_frame.popup('Message','Message','Just A ToolTip',5,function(player,frame) frame.add{name='TEST',type='label',caption=player.name} end,function(player,frame,args) frame.add{name='Message',type='label',caption=args[1]..' '..args[2]} end)
