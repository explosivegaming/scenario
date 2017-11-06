--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
function auto_message(event)
	if event and event.player_loop_index < event.players_online then return end
	local low_rank = 'Regular'
	local high_rank = 'Owner'
	server.queue_callback(ranking.rank_print,{{'auto-message.players-online',#game.connected_players},high_rank,true})
	server.queue_callback(ranking.rank_print,{{'auto-message.map-time',tick_to_display_format(game.tick)},high_rank,true})
	for i = 1,8 do -- if you know a way to set this limit from the locale file please tell me :)
		server.queue_callback(ranking.rank_print,{{'auto-message.line-'..tostring(i)},low_rank,true})
	end
end

Event.register(Event.gui_update,auto_message)