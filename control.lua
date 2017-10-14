--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script - do not remove.
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
--set up to run other code and events
require("mod-gui")
credit_loop(require("locale/StdLib/event"))
--this is the main code that starts the softmod
Event.soft_init = script.generate_event_name()
local function init() if not global.soft_init then script.raise_event(Event.soft_init,{tick=game.tick}) global.soft_init = true global.credits = credits end end
Event.register(defines.events.on_player_joined_game,init)
Event.register(defines.events.on_tick,init)
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
			sudo(find_new_rank,{player,event.tick})
		end
	end
end)
--loads all the other scripts
credit_loop(require("locale/file-header"))