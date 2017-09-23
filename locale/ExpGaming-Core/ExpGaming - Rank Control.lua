--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Explosive Gaming Rank System',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The very core upon which all of the others are based on',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
--Return the rank of a given player
function get_rank(player)
	if player then
		debug_write({'RANK','PLAYER-GET'},player.name)
		for _,rank in pairs(get_ranks()) do
			if player.permission_group == game.permissions.get_group(rank.name) then return rank end
		end
		return string_to_rank_group('User').lowest_rank
	end
end
--Convert the name of a rank into the rank object
function string_to_rank(string)
	if type(string) == 'string' then
		local found_ranks={}
		for _,rank in pairs(get_ranks()) do
			if rank.name:lower() == string:lower() then return rank end
			if rank.name:lower():find(string:lower()) then table.insert(found_ranks,rank) end
		end
		if #found_ranks == 1 then return found_ranks[1] end
	end
end
--converts the name of a group to the group object
function string_to_rank_group(string)
	if type(string) == 'string' then
		local found_groups={}
		for _,group in pairs(get_rank_groups()) do
			if group.name:lower() == string:lower() then return group end
			if group.name:lower():find(string:lower()) then table.insert(found_groups,group) end
		end
		if #found_groups == 1 then return found_groups[1] end
	end
end
-- surches the rank for a certain allow command
function rank_allowed(rank,is_allowed)
	for _,allow in pairs(rank.allow) do
		if allow == is_allowed then return true end
	end
	return false
end
--Send a message to all members of this rank and above, if no rank given default is mod
--inv sends message to all lower ranks rather than higher
function rank_print(msg, rank, inv)
	local rank = string_to_rank(rank) or string_to_rank_group('Moderation').lowest_rank -- default mod or higher
	local inv = inv or false
	debug_write({'RANK','PRINT'},rank.name..': '..msg)
	for _, player in pairs(game.players) do
		--this part uses sudo to soread it other many ticks
		player_rank_power = get_rank(player).power
		if inv then
			sudo(function(player_rank_power,rank)
				if player_rank_power >= rank.power then player.print(('[Everyone]: '..msg)) end
			end,{player_rank_power,rank})
		else
			sudo(function(player_rank_power,rank)
				if player_rank_power <= rank.power then
					if rank.short_hand ~= '' then player.print(('['..(rank.short_hand)..']: '..msg)) else player.print(('[Everyone]: '..msg)) end 
				end
			end,{player_rank_power,rank})
		end
	end
end
--Give the user their new rank and raise the Event.rank_change event
function give_rank(player,rank,by_player)
	local by_player = by_player or 'server'
	local rank = string_to_rank(rank) or rank or string_to_rank_group('User').lowest_rank
	local old_rank = get_rank(player)
	-- to reducse lag if the ranks are all ready given it does not cheak
	if old_rank == rank then return end
	--messaging
	local message = 'demoted'
	if rank.power <= old_rank.power then message = 'promoted' end
	if by_player.name then
		debug_write({'RANK','GIVE'},'player: '..player.name..' by player: '..by_player.name..' new rank: '..rank.name..' old rank: '..old_rank.name)
		rank_print(player.name..' was '..message..' to '..rank.name..' by '..by_player.name,'Guest')
	else
		debug_write({'RANK','GIVE'},'player: '..player.name..' by player: <server> new rank: '..rank.name..' old rank: '..old_rank.name)
		rank_print(player.name..' was '..message..' to '..rank.name..' by <server>','Guest')
	end
	if rank.name ~= string_to_rank_group('User').lowest_rank.name then player.print('You have been given the '..rank.name..' Rank!') end
	if player.tag ~= old_rank.tag and player.tag ~= '' then player.print('Your Tag was reset due to a Rank change') end
	--rank change
	player.permission_group = game.permissions.get_group(rank.name)
	player.tag = get_rank(player).tag
	if old_rank.name ~= 'Jail' then global.old_ranks[player.index]=old_rank.name end
	script.raise_event(Event.rank_change, {player=player, by_player=by_player, new_rank=rank, old_rank=old_rank})
end
--Revert the user's rank to what it was before the lastest change
function revert_rank(player,by_player)
	local rank = string_to_rank(global.old_ranks[player.index])
	give_rank(player,rank,by_player)
end
--Give the player a new rank based on playtime and/or preset ranks
function find_new_rank(player)
	debug_write({'RANK','NEW-RANK','START'},player.name)
	local function loop_preset_rank(players,rank)
		debug_write({'RANK','NEW-RANK','LOOP-PRESET'},rank)
		for _,p in pairs(players) do
			if player.name:lower() == p:lower() then return rank end
		end
	end
	local current_rank = get_rank(player)
	local old_rank = get_rank(player)
	local possible_ranks = {current_rank}
	--Loop through preset ranks only if playtime is less than 5 minutes
	debug_write({'RANK','NEW-RANK','PRESET-CHEAK'},tick_to_min(player.online_time))
	if tick_to_min(player.online_time) < 5 then
		debug_write({'RANK','NEW-RANK','PRESET-START'},player.name)
		for rank,players in pairs(global.preset_ranks) do
			local found_rank = loop_preset_rank(players, rank)
			if found_rank then debug_write({'RANK','NEW-RANK','ADD'},found_rank) table.insert(possible_ranks,string_to_rank(found_rank)) break end
		end
	end
	-- to reduce lag if the player is already higher than any time rank then it does not cheak
	-- also there play time must be higher than the lowest required for a rank
	debug_write({'RANK','NEW-RANK','TIME-CHEAK'},tick_to_min(player.online_time))
	if current_rank.power > global.ranks.highest_timed_rank.power and tick_to_min(player.online_time) >= global.ranks.lowest_timed_rank.time then
		debug_write({'RANK','NEW-RANK','TIME-START'},player.name)
		--Loop through rank times
		for _,rank in pairs(get_ranks()) do
			if rank.time then debug_write({'RANK','NEW-RANK','START'},rank.name..' '..rank.time) end
			if rank.time and tick_to_min(player.online_time) >= rank.time then debug_write({'RANK','NEW-RANK','ADD'},rank.name) table.insert(possible_ranks,rank) end
		end
	end
	--Loop through possible ranks
	debug_write({'RANK','NEW-RANK','JAIL-CHEAK'},current_rank.name)
	if current_rank.name ~='Jail' then 
		debug_write({'RANK','NEW-RANK','GIVE','START'},possible_ranks)
		local highest_rank = possible_ranks[1]
		for _,rank in pairs(possible_ranks) do
			debug_write({'RANK','NEW-RANK','GIVE','POSSIBLE-CHEAK'},rank.name)
			if rank.power < highest_rank.power then highest_rank = rank end
		end
		debug_write({'RANK','NEW-RANK','GIVE','HIGHEST'},highest_rank.name)
		--Give player new rank if availble
		if highest_rank.name == string_to_rank_group('User').lowest_rank.name then
			-- to avoid spam in chat
			debug_write({'RANK','NEW-RANK','GIVE','VIA-SERVER'},player.name..' '..highest_rank.name)
			player.permission_group=game.permissions.get_group('Guest')
			script.raise_event(Event.rank_change, {player=player, by_player='server', new_rank=string_to_rank_group('User').lowest_rank, old_rank=string_to_rank_group('User').lowest_rank})
		else
			debug_write({'RANK','NEW-RANK','GIVE','VIA-GIVE-RANK'},player.name..' '..highest_rank.name)
			if highest_rank ~= current_rank then give_rank(player,highest_rank) end
		end
		debug_write({'RANK','NEW-RANK','GIVE','END'},player.name)
	end
	--Lose ends
	if get_rank(player).power <= string_to_rank_group('Moderation').lowest_rank.power and not player.admin then rank_print(player.name..' needs to be promoted.') end
	if old_rank.name ~= get_rank(player).name then global.old_ranks[player.index]=old_rank.name end
	debug_write({'RANK','NEW-RANK','END'},player.name)
end
-- returns a list with every players current rank, or just the players of the rank given, includes online time
function get_ranked_players(rank)
	local to_return = {}
	for _,player in pairs(game.players) do 
		if not rank or rank == get_rank(player).name then 
			table.insert(to_return,{player.name,tick_to_display_format(player.online_time),get_rank(player).name})
		end
	end
	return to_return
end
--Event handlers  
Event.rank_change = script.generate_event_name()
Event.register(Event.rank_change,function(event)
	debug_write({'RANK','EVENT'},event)
	if event.new_rank == event.old_rank then return end
	if not event.by_player == 'server' then
		game.write_file('rank-change.log','\n'..game.tick..' Player: '..event.player.name..' Was given rank: '..event.new_rank.name..' By: '..event.by_player.name..' Their rank was: '..event.old_rank.name, true, 0)	
	end
end)
Event.register(-1,function()
	debug_write({'RANK','SETUP'},'start')
	global.old_ranks = {} 
	for _,rank in pairs(get_ranks()) do
		debug_write({'RANK','SETUP'},'added: '..rank.name)
		game.permissions.create_group(rank.name)
		for _,toRemove in pairs(rank.disallow) do
			debug_write({'RANK','SETUP'},'blocked: '..toRemove)
			game.permissions.get_group(rank.name).set_allows_action(defines.input_action[toRemove],false)
		end
	end
end)
Event.register(defines.events.on_player_joined_game,function(event) find_new_rank(game.players[event.player_index]) end)
Event.register(-1,function() global.preset_ranks = {} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits