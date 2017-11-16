--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--set up to run other code and events
require("mod-gui")
Event = require("locale/StdLib/event")
--this is the main code that starts the softmod
Event.soft_init = script.generate_event_name()
local function init() if not global.soft_init then global.exp_core = {} script.raise_event(Event.soft_init,{tick=game.tick}) global.soft_init = true end end
Event.register(defines.events.on_player_joined_game,init)
Event.register(defines.events.on_tick,init)
Event.register(-1,init)
--below 'game.tick/(3600*game.speed)) % 15 == 0' raises the gui_update event every 15 minutes - feel free to change the update time
Event.gui_update = script.generate_event_name()
Event.register(defines.events.on_tick, function(event)
	if (event.tick/(3600*game.speed)) % 15 == 0 then
		-- updates the guis for every player (if gui is linked to gui_update)
		local online_players = #game.connected_players
		for i,player in pairs(game.connected_players) do 
			script.raise_event(Event.gui_update,{tick=event.tick,player=player,player_loop_index=i,players_online=online_players})
		end
	elseif ((event.tick/(3600*game.speed))+(15/2))% 15 == 0 then
		-- this is the system to auto rank players
		for i,player in pairs(game.connected_players) do
			server.queue_callback(ranking.find_new_rank,{player,event.tick})
		end
	end
end)
--loads core files
ranking,ExpGui,server = unpack(require("locale/ExpGaming-Core/file-header"))
--loads all the other scripts
require("locale/Stand-Alone/file-header")
require("locale/ExpGaming-Addons/file-header")
--call from command maker
load_commands()