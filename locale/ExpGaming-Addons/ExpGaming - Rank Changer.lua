--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_input.button('close_rank_gui',{'expgui.close-button'},{'expgui.close-button-tooltip'},function(player,element) element.parent.parent.destroy() end)
ExpGui.add_input.button('give_rank',{'ingame-rank-changer.button-give-rank'},{'ingame-rank-changer.button-give-rank-tooltip'},function(player,element)
	local input_table = element.parent.parent.input_table
	local p = input_table.player_dropdown.items[input_table.player_dropdown.selected_index]
	if type(p) == 'table' then p = nil else p = game.players[p] end
	local rank = ranking.string_to_rank(input_table.rank_dropdown.items[input_table.rank_dropdown.selected_index])
	if not rank or not p then player.print('Invalid Player') return end
	ranking.give_rank(p,rank,player)
	element.parent.parent.destroy()
end)

ExpGui.add_frame.center('rank_changer',{'ingame-rank-changer.name'},{'ingame-rank-changer.tooltip'},{},function(player,frame)
	frame.add{name='label',type='label',caption={'ingame-rank-changer.info-caption'},style="caption_label_style"}
	local player_rank_power = ranking.get_player_rank(player).power
	local inputs = frame.add{name='input_table',type='table',colspan=2}
	-- player drop down
	inputs.add{name='player_lable',type='label',caption={'ingame-rank-changer.player-caption'}}
	inputs.add{name='player_dropdown',type='drop-down'}
	for _,p in pairs(game.connected_players) do 
		if player_rank_power < ranking.get_player_rank(p).power and not global.temp_bans[p.name] then
			inputs.player_dropdown.add_item(p.name)
		end
	end
	if not inputs.player_dropdown.items[1] then inputs.player_dropdown.add_item({'ingame-rank-changer.no-player-caption'}) end
	inputs.player_dropdown.selected_index = 1
	-- rank drop down
	inputs.add{name='rank_lable',type='label',caption={'ingame-rank-changer.rank-caption'}}
	inputs.add{name='rank_dropdown',type='drop-down'}
	for _,rank in pairs(ranking.get_ranks()) do 
		if player_rank_power < rank.power then
			inputs.rank_dropdown.add_item(rank.name)
		end
	end
	inputs.rank_dropdown.selected_index = 1
	-- buttons
	frame.add{type='flow',name='flow'}
	ExpGui.add_input.draw_button(frame.flow,'give_rank')
	ExpGui.add_input.draw_button(frame.flow,'close_rank_gui')
end)

