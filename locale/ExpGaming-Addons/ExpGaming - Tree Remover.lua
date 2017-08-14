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
	sudo(function(event)
		local player = game.players[event.player_index]
		if not event.entity.vaild then return end
		local entity = event.entity
		local last_user = entity.last_user
		if last_user then
			if string_to_rank('reg').power < get_rank(player).power then
				entity.cancel_deconstruction('player')
				player.print('You are not allowed to do this yet, You require the Regular rank, you must play for at least 3 hours')
				rank_print(player.name..' tryed to deconstruced something.')
			end
		elseif get_rank(player).power <= string_to_rank('Donator').power then
			event.entity.destroy()
		end
	end,{event})
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits
