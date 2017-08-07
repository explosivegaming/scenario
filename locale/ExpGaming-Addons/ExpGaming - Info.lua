--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Info Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Shows all server info and help',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.center('info','Info','All useful information about the server is here','Guest',{{'commands','Guest'}})

ExpGui.add_frame.tab('links','Links','More ways to get in contact','Guest','info',function(player,frame)
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
	frame.add{name=7, type="label", caption={"", "Patreon:"}}
	format(frame.add{name=8, type='text-box', text='https://www.patreon.com/badgamernl'})
end)

ExpGui.add_frame.tab('servers','Other Servers','All the other server we have','Guest','info',function(player,frame)
    local servers = {
		{'Public','A place for all players, this map reset every 24H'},
		{'Standard','Before you play make sure you understand the game, reset every 48H'},
		{'Pro','A pure mega base server, reset every 7 days and a password is needed to join'},
		{'Modded','A modded server not much to say, just down load the mods to play'},
		{'Events','Some Times we hold events, may require a password'}
		}
	frame.add{name=i, type="label", caption='Welcome to the Explosive Gaming Community!', single_line=false}.style.maximal_width=480
	for i, server in pairs(servers) do 
		frame.add{name=i, type="label", caption='S'..i..' - '..server[1], single_line=false}.style.maximal_width=480
		frame.add{name=i..'description', type="label", caption=server[2], single_line=false}.style.maximal_width=480  
	end
end)

ExpGui.add_frame.tab('credit','Script Credit','Who made all of the diffrent parts of the script','Guest','info',function(player,frame)
    local text = "To give credit to all the people who helped to make this soft compoents"
    frame.add{name='intro', type="label", caption=text, single_line=false}.style.maximal_width=480
	frame.add{name='credit_table',type='table',colspan=3}
	frame.credit_table.add{name='name_title',type='label',caption='Script Name'}
	frame.credit_table.add{name='dev_title',type='label',caption='Developer Name'}
    frame.credit_table.add{name='description_title',type='label',caption='Description'}
    for n,credit in pairs(global.credits) do
        if credit.show then
            frame.credit_table.add{name='name_'..n,type='label',caption=credit.name}
            frame.credit_table.add{name='dev_'..n,type='label',caption=credit.dev}
            frame.credit_table.add{name='des_'..n,type='label',caption=credit.description,single_line=false}.style.maximal_width=480
        end
    end
    frame.horizontal_scroll_policy = 'always'
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits