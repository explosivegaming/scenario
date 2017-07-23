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
	description='Removes tress and stone with use of deconstruction planer',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
Event.register(defines.events.on_marked_for_deconstruction, function(event)
	local player = game.players[event.player_index]
	if get_rank(player).power > string_to_rank('reg').power then
    	if event.entity.type ~= 'tree' and event.entity.type ~= 'simple-entity' then
			event.entity.cancel_deconstruction('player')
			player.print('You are not allowed to do this yet, play for player bit longer.')
			rank_print(player.name..' tryed to deconstruced something')
    	end
  	elseif event.entity.type == 'tree' or event.entity.type == 'simple-entity' and get_rank(player).power <= string_to_rank('Donator').power then
    	event.entity.destroy()
	end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits