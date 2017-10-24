--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
Event.register(defines.events.on_marked_for_deconstruction, function(event)
	-- varible setup
	if not event.entity.valid then return end
	local player = game.players[event.player_index]
	local entity = event.entity
	-- get the uuid and data
	local tree_remover_uuid = server.get_uuid(player.name..'_tree_remover')
	if not server.get_uuid_data(tree_remover_uuid) then
		tree_remover = server.queue_callback(function(player)
			if not ranking.rank_allowed(ranking.get_player_rank(player),'decon') then return 1
			elseif ranking.rank_allowed(ranking.get_player_rank(player),'tree_remover') then return 2 
			else return 0 end
		end,{player},tree_remover_uuid)
	end
	-- run the main tree remover and get the uuid
	-- the printed varible is recicive as a way to chain the commands together
	local printed_uuid = server.get_uuid(player.name..'_tree_remover_printed')
	server.queue_callback(function(entity,tree_remover,printed)
		if not entity.valid then return end
		-- tree remover is the function above either 0,1,2
		if tree_remover == 1 and entity.last_user then
			entity.cancel_deconstruction('player')
			-- if it has not already printed then print
			if printed ~= true then
				debug_write({'TREE-REMOVER'},printed)
				player.print{'tree-remover.player-print'}
				ranking.rank_print({'tree-remover.rank-print',player.name})
			end return true
		elseif tree_remover == 2 and not entity.last_user then
			entity.destroy()
		end
		if printed == true then return true end
	end,{entity,tree_remover_uuid,printed_uuid},printed_uuid)
end)


