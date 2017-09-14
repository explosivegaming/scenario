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
ExpGui.add_frame.center('readme','README','Click To Open Readme')

ExpGui.add_frame.tab('rules','Rules','Rules on this server','readme',function(player,frame)
    local rules = {
		'Welcome to the Explosive Gaming Community!',
		'',
		'Here are some guidelines to keep this Server fun for everyone:',
		'- Hacking / cheating / abusing bugs will not be tolerated.',
		'- Be polite and use common sense.',
		'- Nobody likes spam. That includes: Chat, Bots, unlimited Chests and Concrete.',
		'- Do not remove stuff without even trying to talk / ask about it.',
		'- Trains: LHD (Left hand drive), no Loops and use them for long distances.',
		'',
		'If you have any questions about the rules, the server or the game in general, feel free to ask. Have Fun!'
		}
	for i, rule in pairs(rules) do frame.add{name=i, type="label", caption=rule, single_line=false}.style.maximal_width=480 end
end)

ExpGui.add_frame.tab('chat','How To Chat','For the people who dont know how to chat','readme',function(player,frame)
    local chat = "Chatting can be difficult for new players because it’s different than other games! It’s very simple, the button you need to press is the “GRAVE/TILDE” key it’s located under the “ESC key”. If you would like to change the key go to your controls tab in options. The key you need to change is “Toggle Lua console” it’s located in the second column 2nd from bottom."
	frame.add{name='chat', type="label", caption={"", chat}, single_line=false}.style.maximal_width=480
end)

ExpGui.add_frame.tab('commands','Commands','Useful commands you can use','readme',function(player,frame)
    local text = "A List of all the commands that you are able to use, other commands may be permitted to higher ranks then yours."
    frame.add{name='intro', type="label", caption=text, single_line=false}.style.maximal_width=480
	frame.add{name='command_table',type='table',colspan=2}
	frame.command_table.add{name='command_title',type='label',caption='Command'}
	frame.command_table.add{name='help_title',type='label',caption='Help Info'}
    for n,command in pairs(get_commands(get_rank(player).name)) do
        frame.command_table.add{name='command_'..n,type='label',caption='/'..command.name}
        frame.command_table.add{name='help_'..n,type='label',caption=command.help,single_line=false}.style.maximal_width=480
    end
end)

ExpGui.add_frame.tab('players','Players','Players that have been on the server','readme',function(player,frame)
    local text = "These are the players who have supported us in the making of this factory. Without you the player we wouldn't have been as far as we are now."
    frame.add{name='intro', type="label", caption=text, single_line=false}.style.maximal_width=480
    local table_area = frame.add{type='flow',name='flow',direction='vertical'}
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
