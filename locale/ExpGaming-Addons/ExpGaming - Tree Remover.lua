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
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
Event.register(defines.events.on_marked_for_deconstruction, function(event)
	if not event.entity.valid then return end
	local player = game.players[event.player_index]
	local entity = event.entity
	-- sets up the temp var value to be used in later sudo functions
	local tree_remover = nil
	if not get_temp_var_data(player.name..'_tree_remover') then
		tree_remover = sudo(function(player,entity)
			if entity.last_user then
				if string_to_rank('reg').power < get_rank(player).power then
					player.print('You are not allowed to do this yet, You require the Regular rank, you must play for at least 3 hours')
					rank_print(player.name..' tryed to deconstruced something.')
					return 1 
				end
				return 0
			elseif get_rank(player).power <= string_to_rank('Donator').power then return 2 end
		end,{player,entity},player.name..'_tree_remover')
	else tree_remover = format_as_temp_var(player.name..'_tree_remover') end
	-- using the temp var stored in tree_remover sudo will take diffrent effects while only running the test once
	sudo(function(entity,tree_remover_data)
		if not event.entity.valid then return end
		local result = tree_remover_data[1]
		if result == 1 then
			entity.cancel_deconstruction('player')
		elseif result == 2 then
			entity.destroy()
		end
	end,{entity,tree_remover})
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits
