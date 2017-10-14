--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Auto Message',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='A simple message that is showen in chat every gui update',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local low_ranks_only={
    'Please join us on:',
    'Discord: https://discord.gg/RPCxzgt',
    'Forum: explosivegaming.nl',
    'Steam: http://steamcommunity.com/groups/tntexplosivegaming',
    'To see these links again goto: Info > Links',
    'We also have some custom commands which you can view in: Info > Commands',
    'This includes useful commands such as /tag and /report',
    'Do /help <command> for more info'
}

function auto_message(event)
	if event.player_loop_index < event.players_online then return end
	local low_rank = 'Regular'
	local high_rank = 'Owner'
	sudo(rank_print,{'There are '..#game.connected_players..' players online',high_rank,true})
	sudo(rank_print,{'This map has been on for '..tick_to_display_format(game.tick),high_rank,true})
	for _,message in pairs(low_ranks_only) do
		sudo(rank_print,{message,low_rank,true})
	end
end

Event.register(Event.gui_update,auto_message)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits
