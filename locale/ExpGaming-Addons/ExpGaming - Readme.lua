--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Readme Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The Most Important Gui',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.center('readme','README','Click To Open Readme','Guest')

ExpGui.add_frame.tab('rules','Rules','Rules on this server','Guest','readme',function(player,frame)
    local rules = {
		"Hacking/cheating, exploiting and abusing bugs is not allowed.",
		"Do not disrespect any player in the server (This includes staff).",
		"Do not spam, this includes stuff such as chat spam, item spam, chest spam etc.",
		"Do not laydown concrete with bots without permission.",
		"Do not use active provider chests without permission.",
		"Do not use speakers on global without permission.",
		"Do not remove/move major parts of the factory without permission.",
		"Do not walk in player random direction for no reason(to save map size).",
		"Do not remove stuff just because you don't like it, tell people first.",
		"Do not make train roundabouts. Or any loops of any kind",
		"Trains are Left Hand Drive (LHD) only.",
		"Do not complain about lag, low fps and low ups or other things like that.",
		"Do not ask for rank.",
		"Use common sense and what an admin says goes."}
	for i, rule in pairs(rules) do frame.add{name=i, type="label", caption={"", i ,". ", rule}} end
end)

ExpGui.add_frame.tab('infor','Server Info','More ways to get in contact','Guest','readme',function(player,frame)
    local function format(text_box)
        text_box.style.minimal_width=400
        text_box.read_only = true
	    text_box.word_wrap = true
	    text_box.selectable = true
    end
    frame.add{name=1, type="label", caption={"", "Discord voice and chat server:"}}
	format(frame.add{name=2, type='text-box', text='https://discord.gg/RPCxzgt'})
	frame.add{name=3, type="label", caption={"", "Our forum:"}}
	format(frame.add{name=4, type='text-box', text='https://explosivegaming.nl'})
	frame.add{name=5, type="label", caption={"", "Steam:"}}
	format(frame.add{name=6, type='text-box', text='http://steamcommunity.com/groups/tntexplosivegaming'})
end)

ExpGui.add_frame.tab('chat','How To Chat','For the people who dont know how to chat','Guest','readme',function(player,frame)
    local chat = "Chatting for new players can be difficult because it’s different than other games! It’s very simple, the button you need to press is the “GRAVE/TILDE” key it’s located under the “ESC key”. If you would like to change the key go to your controls tab in options. The key you need to change is “Toggle Lua console” it’s located in the second column 2nd from bottom."
	frame.add{name='chat', type="label", caption={"", chat}, single_line=false}.style.maximal_width=480
end)

ExpGui.add_frame.tab('commands','Commands','Useful commands you can use','Guest','readme',function(player,frame)
    frame.add{name='commandTable',type='table',colspan=2}
    for n,command in pairs(Exp_commands) do
        local temp_restriction = nil
		if type(command[4]) == 'number' then temp_restriction = command[4] end
		local restriction = temp_restriction or string_to_rank(command[4]).power or 0
        if get_rank(player).power > restriction then else
            frame.commandTable.add{name='command_'..n,type='label',caption='/'..command[1]}
            frame.commandTable.add{name='help_'..n,type='label',caption=command[2],single_line=false}.style.maximal_width=480
        end
    end
end)

ExpGui.add_frame.tab('players','Players','Players that have been on the server','Guest','readme',function(player,frame)
    local text = "These are the players who have supported us in the making of this factory. Without you the player we wouldn't have been as far as we are now."
    frame.add{name='intro', type="label", caption=text, single_line=false}.style.maximal_width=480
    local table_area = frame.add{type='flow',name='flow'}
    ExpGui.player_table.draw_filters(player,table_area,{'player_name','online_time','rank'})
    ExpGui.player_table.draw(player,table_area,{{'player_name'},{'online_time'},{'rank'}},table_area)
end)
--Draws the read me gui when a player joins uses a loop hole do so so not recomened
Event.register(defines.events.on_player_joined_game,function(event) 
    local player = game.players[event.player_index]
    if not player.admin and tick_to_min(player.online_time) < 1 then
        local fake_button = {name='readme'}
        ExpGui.draw_frame.center(player,fake_button)
    end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits