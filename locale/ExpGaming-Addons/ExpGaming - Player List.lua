--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--this function will update the player list for all players
local function loop_all_players()
	global.player_list.next_update = 0
	for _,player in pairs(game.connected_players) do
		ExpGui.draw_frame.left(player,'player_list',true)
	end
end

ExpGui.add_frame.left('player_list','entity/player',{'player-list.tooltip'},true,function(player,frame)
	--draws the player list
	frame.caption = ''
	local player_list = frame.add{name="scroll",type = "scroll-pane", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
  	player_list.style.maximal_height = 200
	--creating the order the players are drawn in
	--first get the uuid for the player list order
	local player_list_order_uuid = server.get_uuid('player_list_order')
	-- then test if it has data if it does not then run a callback to output to this uuid
	if not server.get_uuid_data(player_list_order_uuid) then
		server.queue_callback(function()
			local order = {}
			for _,rank_name in pairs(ranking.get_ranks('name')) do order[rank_name] = {} end
			for _,p in pairs(game.connected_players) do table.insert(order[ranking.get_player_rank(p).name],p) end
			return order
		end,{},player_list_order_uuid)
	end
	--puts names onto player list
	-- passing the uuid into a callback will return its data to the call back
	server.queue_callback(function(player_list,player_list_order)
		if not player_list.valid then return end
		debug_write({'PLAYER LIST','ORDER'},player_list_order)
		for rank_name,players in pairs(player_list_order) do
			debug_write({'PLAYER LIST','RANK'},rank_name)
			local rank = ranking.string_to_rank(rank_name)
			local rank_short_hand = rank.short_hand
			local rank_colour = rank.colour
			for _,p in pairs(players) do
				local play_time = tick_to_display_format(p.online_time)
				if rank_short_hand ~= '' then player_list.add{type = "label",  name=p.name, style="caption_label_style", caption={'player-list.format',play_time,p.name,rank_short_hand}}
				else player_list.add{type = "label",  name=p.name, style="caption_label_style", caption=play_time.." - "..p.name} end
				player_list[p.name].style.font_color = rank_colour
			end
		end
	end,{player_list,player_list_order_uuid})
end)

local update_delay = 10
Event.register(Event.soft_init,function(event) global.player_list = {list={},next_update=event.tick} end)
Event.register(defines.events.on_tick,function(event) if global.player_list.next_update > 0 and global.player_list.next_update < event.tick then loop_all_players() end end)
Event.register(defines.events.on_player_joined_game,function(event) global.player_list.next_update = event.tick+update_delay end)
Event.register(defines.events.on_player_left_game,function(event) global.player_list.next_update = event.tick+update_delay end)
Event.register(Event.rank_change,function(event) global.player_list.next_update = event.tick+update_delay end)
Event.register(Event.gui_update,function(event) ExpGui.draw_frame.left(event.player,'player_list',true) end)