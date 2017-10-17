--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Tree Remover',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Removes trees and stone with use of deconstruction planer',
	factorio_version='0.15.23',
	show=true
	}}

--Please Only Edit Below This Line-----------------------------------------------------------
Event.register(defines.events.on_marked_for_deconstruction, function(event)
	if not event.entity.valid then return end
	local player = game.players[event.player_index]
	local entity = event.entity
	-- sets up the temp var value to be used in later sudo functions
	local tree_remover = nil
	if not server.get_uuid_data(player.name..'_tree_remover') then
		tree_remover = server.queue_callback(function(player)
			if not rank_allowed(ranking.get_player_rank(player),'decon') then return 1
			elseif rank_allowed(ranking.get_player_rank(player),'tree_remover') then return 2 
			else return 0 end
		end,{player},player.name..'_tree_remover')
	else tree_remover = server.get_uuid(player.name..'_tree_remover') end
	-- using the temp var stored in tree_remover sudo will take diffrent effects while only running the test once
	server.queue_callback(function(entity,tree_remover)
		if not entity.valid then return end
		local result = tree_remover.data[1]
		server.refresh_uuid(tree_remover.temp_var_name)
		local printed = nil; if type(server.get_uuid_data(player.name..'_tree_remover_printed')) == 'table' then printed = server.get_uuid_data(player.name..'_tree_remover_printed')[1] end
		if result == 1 and entity.last_user then
			entity.cancel_deconstruction('player')
			if printed ~= true then
				debug_write({'TREE-REMOVER'},printed)
				player.print('You are not allowed to do this yet, You require the Regular rank, you must play for at least 3 hours')
				ranking.rank_print(player.name..' tryed to deconstruced something.')
			end return true
		elseif result == 2 and not entity.last_user then
			entity.destroy()
		end
		if printed == true then return true end
	end,{entity,tree_remover},player.name..'_tree_remover_printed')

end)


