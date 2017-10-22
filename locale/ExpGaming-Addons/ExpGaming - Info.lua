--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.center('info','Info','All useful information about the server is here',{name='commands'})

ExpGui.add_frame.tab('links','Links','More ways to get in contact','info',function(player,frame)
	local links={
		'https://discord.me/explosivegaming',
		'https://explosivegaming.nl',
		'http://steamcommunity.com/groups/tntexplosivegaming',
		'https://www.patreon.com/badgamernl'
	}
    local function format(text_box)
        text_box.style.minimal_width=400
        text_box.read_only = true
	    text_box.word_wrap = true
	    text_box.selectable = true
    end
	for i = 1,4 do
    	frame.add{name=i..'caption', type="label", caption={'info-gui.link-caption-'..tostring(i)}}
		format(frame.add{name=i..'link', type='text-box',text=links[i]})
	end
end)

ExpGui.add_frame.tab('servers','Other Servers','All the other server we have','info',function(player,frame)
	frame.add{name='message', type="label", caption={'info-gui.welcome-message'}, single_line=false}.style.maximal_width=480
	for i = 1,5 do 
		frame.add{name=i..'name', type="label", caption={'info-gui.server-format',tostring(i),{'info-gui.name-s'..tostring(i)}}, single_line=false}.style.maximal_width=480
		frame.add{name=i..'description', type="label", caption={'info-gui.description-s'..tostring(i)}, single_line=false}.style.maximal_width=480  
	end
end)