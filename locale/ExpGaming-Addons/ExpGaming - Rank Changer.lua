--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Rank Changer',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Allows players to set the ranks of those below them.',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_input.button('close_rank_gui','Close','Close this gui',function(player,element) element.parent.parent.destroy() end)
ExpGui.add_input.button('give_rank','Give Rank','Give the above player the above rank',function(player,element)
	local p = game.players[element.parent.parent.input_table.player_dropdown.items[element.parent.parent.input_table.player_dropdown.selected_index]]
	local rank = string_to_rank(element.parent.parent.input_table.rank_dropdown.items[element.parent.parent.input_table.rank_dropdown.selected_index])
	if not rank or not p then player.print('Invalid Player') return end
	give_rank(p,rank,player)
	element.parent.parent.destroy()
end)

ExpGui.add_frame.center('rank_changer','Edit Ranks','Allows you to edit players ranks','Mod',{},function(player,frame)
	frame.add{name='label',type='label',caption='Edit Players Ranks Below You',style="caption_label_style"}
	local inputs = frame.add{name='input_table',type='table',colspan=2}
	inputs.add{name='player_lable',type='label',caption='Player: '}
	inputs.add{name='player_dropdown',type='drop-down'}
	for _,p in pairs(game.connected_players) do 
		if get_rank(player).power < get_rank(p).power then
			inputs.player_dropdown.add_item(p.name)
		end
	end
	if not inputs.player_dropdown.items[1] then inputs.player_dropdown.add_item('No Vaild Players Online') end
	inputs.player_dropdown.selected_index = 1
	inputs.add{name='rank_lable',type='label',caption='Rank: '}
	inputs.add{name='rank_dropdown',type='drop-down'}
	for _,rank in pairs(global.ranks) do 
		if get_rank(player).power < rank.power then
			inputs.rank_dropdown.add_item(rank.name)
		end
	end
	inputs.rank_dropdown.selected_index = 1
	frame.add{type='flow',name='flow'}
	ExpGui.add_input.draw_button(frame.flow,'give_rank')
	ExpGui.add_input.draw_button(frame.flow,'close_rank_gui')
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits