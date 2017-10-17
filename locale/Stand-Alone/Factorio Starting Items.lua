--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
Event.register(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
	if event.player_index == 1 then
		player.force.friendly_fire = false
		player.force.chart(player.surface, {{player.position.x - 400, player.position.y - 400}, {player.position.x + 400, player.position.y + 400}})
	end
	if tick_to_min(game.tick) < 60 then
		player.insert{name="iron-plate", count=8}
		player.insert{name="pistol", count=1}
		player.insert{name="firearm-magazine", count=10}
		player.insert{name="burner-mining-drill", count = 1}
		player.insert{name="stone-furnace", count = 1}
	end
end)