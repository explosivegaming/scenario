--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Player List',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Shows a list with the curent online players',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui.add_frame.left('player_list','entity/player','Toggle Player List','Guest',true,function(player,frame)
	local player_list = frame.add{name="scroll",type = "scroll-pane", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
  player_list.style.maximal_height = 200
	local order = {}
	for _,rank in pairs(global.ranks) do order[rank.name] = {} end
	for _,p in pairs(game.connected_players) do table.insert(order[get_rank(p).name],p) end
	for rank,players in pairs(order) do
		for _,p in pairs(players) do
			local play_time = tick_to_hour(p.online_time)..' H '..(tick_to_min(p.online_time)-60*tick_to_hour(p.online_time))..' M'
			local rank_short_hand = string_to_rank(rank).short_hand
			if rank_short_hand ~= '' then player_list.add{type = "label",  name=p.name, style="caption_label_style", caption=play_time.." - "..p.name..' - '..rank_short_hand}
			else player_list.add{type = "label",  name=p.name, style="caption_label_style", caption=play_time.." - "..p.name} end
			player_list[p.name].style.font_color = string_to_rank(rank).colour
		end
	end
end)

Event.register(defines.events.on_player_joined_game,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
Event.register(defines.events.on_player_left_game,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
Event.register(Event.rank_change,function(event) for _,player in pairs(game.connected_players) do ExpGui.draw_frame.left(player,'player_list',true) end end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits