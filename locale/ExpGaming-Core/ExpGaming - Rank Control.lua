--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Rank Control Functions',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The Core for the Rank Controls',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
--this will return the rank of the player given
function get_rank(player)
	if player then
		for _,rank in pairs(global.ranks) do
			if player.permission_group == game.permissions.get_group(rank.name) then return rank end
		end
		return string_to_rank('Guest')
	end
end
--this will convert the name of a rank into the rank object
function string_to_rank(string)
	if type(string) == 'string' then
		local Foundranks={}
		for _,rank in pairs(global.ranks) do
			if rank.name:lower() == string:lower() then return rank end
			if rank.name:lower():find(string:lower()) then table.insert(Foundranks,rank) end
		end
		if #Foundranks == 1 then return Foundranks[1] end
	end
end
--this will send a message to all members if this rank and above default is mod rank
function rank_print(msg, rank, inv)
	local rank = string_to_rank(rank) or string_to_rank('Mod') -- default mod or higher
	local inv = inv or false
	for _, player in pairs(game.players) do 
		rankPower = get_rank(player).power
		if inv then 
			if rankPower >= rank.power then 
				player.print(('[Everyone]: '..msg)) 
			end
		else
			if rankPower <= rank.power then
				if rank.shortHand ~= '' then player.print(('['..(rank.shortHand)..']: '..msg)) else player.print(('[Everyone]: '..msg)) end 
			end
		end
	end
end
--this will give the user their new rank and raise the Event.rank_change event
function give_rank(player,rank,by_player)
	local by_player = by_player or 'system'
	local rank = string_to_rank(rank) or rank or string_to_rank('Guest')
	local old_rank = get_rank(player)
	--messaging
	local message = 'demoted'
	if rank.power <= old_rank.power then message = 'promoted' end
	if by_player.name then 
		rank_print(player.name..' was '..message..' to '..rank.name..' by '..by_player.name,'Guest')
	else
		rank_print(player.name..' was '..message..' to '..rank.name..' by <system>','Guest')
	end
	player.print('You Have Been Given The '..rank.name..' Rank!')
	--if for some reason the tag is diffrent to the deafult
	if player.tag ~= old_rank.tag then player.print('Your Tag Was Reset Due To A Rank Change') end
	--rank change
	player.permission_group = game.permissions.get_group(rank.name)
	player.tag = get_rank(player).tag
	if old_rank.name ~= 'Jail' then global.old_ranks[player.index]=old_rank.name end
	script.raise_event(Event.rank_change, {player=player, by_player=by_player, new_rank=rank, old_rank=old_rank})
end
--the user's rank is reverted to what it was before the lastest change
function revert_rank(player,by_player)
	local rank = string_to_rank(global.old_ranks[player.index])
	give_rank(player,rank,by_player)
end
--the player is given a new rank based on playtime and/or preset ranks
function find_new_rank(player)
	local function loop_preset_rank(players,rank)
		for _,p in pairs(players) do
			if player.name:lower() == p:lower() then return rank end
		end
	end
	local current_rank = get_rank(player)
	local old_rank = get_rank(player)
	local possible_ranks = {current_rank}
	--loops though preset ranks
	for rank,players in pairs(global.preset_ranks) do
		local found_rank = loop_preset_rank(players, rank)
		if found_rank then table.insert(possible_ranks,string_to_rank(found_rank)) break end
	end
	--loops though rank times
	for _,rank in pairs(global.ranks) do 
		if rank.time and tick_to_min(player.online_time) >= rank.time then table.insert(possible_ranks,string_to_rank(rank)) end
	end
	--loops though possible ranks
	if current_rank.name ~='Jail' then 
		local highest_rank = possible_ranks[1]
		for _,rank in pairs(possible_ranks) do
			if rank.power < highest_rank.power then highest_rank = rank end
		end
		--gives player new rank if availble
		if highest_rank.name == 'Guest' then
			player.permission_group=game.permissions.get_group('Guest')
		else
			give_rank(player,highest_rank)
		end
	end
	--lose ends
	if get_rank(player).power <= 3 and not player.admin then rank_print(player.name..' needs to be promoted.') end
	if old_rank.name ~= get_rank(player).name then global.old_ranks[player.index]=old_rank.name end
end
--event handlers
Event.rank_change = script.generate_event_name()
Event.register(-1,function() 
	global.old_ranks = {} 
	for _,rank in pairs(global.ranks) do
		game.permissions.create_group(rank.name)
		for _,toRemove in pairs(rank.disallow) do
			game.permissions.get_group(rank.name).set_allows_action(defines.input_action[toRemove],false)
		end
	end
end)
Event.register(defines.events.on_player_joined_game,function(event) find_new_rank(game.players[event.player_index]) end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits