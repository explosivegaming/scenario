--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.left('player_list','entity/player',{'player-list.tooltip'},true,function(player,frame)
	--draws the player list
	frame.caption = ''
	local player_list = frame.add{name="scroll",type = "scroll-pane", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
  	player_list.style.maximal_height = 200
	--creating the order the players are drawn in
	local player_list_order = nil
	if not server.get_uuid_data('player_list_order') then
		player_list_order = server.queue_callback(function()
			local order = {}
			for _,rank_name in pairs(ranking.get_ranks('name')) do order[rank_name] = {} end
			for _,p in pairs(game.connected_players) do table.insert(order[ranking.get_player_rank(p).name],p) end
			return order
		end,{},'player_list_order')
	else player_list_order = server.get_uuid('player_list_order') end
	--puts names onto player list
	server.queue_callback(function(player_list,player_list_order)
		if not player_list.valid then return end
		local order = player_list_order.data[1]
		server.refresh_uuid(player_list_order.temp_var_name)
		for rank,players in pairs(order) do
			local rank_object = ranking.string_to_rank(rank)
			local rank_short_hand = rank_object.short_hand
			local rank_colour = rank_object.colour
			for _,p in pairs(players) do
				local play_time = tick_to_display_format(p.online_time)
				if rank_short_hand ~= '' then player_list.add{type = "label",  name=p.name, style="caption_label_style", caption=play_time.." - "..p.name..' - '..rank_short_hand}
				else player_list.add{type = "label",  name=p.name, style="caption_label_style", caption=play_time.." - "..p.name} end
				player_list[p.name].style.font_color = rank_colour
			end
		end
	end,{player_list,player_list_order})
end)

Event.register(defines.events.on_player_joined_game,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
Event.register(defines.events.on_player_left_game,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
Event.register(Event.rank_change,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
Event.register(Event.gui_update,function(event) ExpGui.draw_frame.left(event.player,'player_list',true) end)