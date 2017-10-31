--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--for each item the key is the name and the value is the count given
local items = {
	['iron-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 8 else return (made*3)/math.pow(tick_to_min(game.tick),2) end end,
	['copper-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*2)/math.pow(tick_to_min(game.tick),2) end end,
	['electronic-circuit']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*1)/math.pow(tick_to_min(game.tick),2) end end,
	['iron-gear-wheel']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return (made*1)/math.pow(tick_to_min(game.tick),2) end end,
	['steel-plate']=function(player,made) if tick_to_min(game.tick) < 5 then return 0 else return(made*0.5)/math.pow(tick_to_min(game.tick),2) end end,
	['pistol']=function(player,made) if player.force.item_production_statistics.get_input_count('submachine-gun') > 5 then return 0 else return 1 end end,
	['submachine-gun']=function(player,made) if made > 5 then return 1 else return 0 end end,	
	['firearm-magazine']=function(player,made) if player.force.item_production_statistics.get_input_count('piercing-rounds-magazine') > 100 then return 0 else return 10 end end,
	['piercing-rounds-magazine']=function(player,made) if made > 100 then return 10 else return 0 end end,	
	['light-armor']=function(player,made) if made > 5 and player.force.item_production_statistics.get_input_count('heavy-armor') <= 5 then return 1 else return 0 end end,
	['heavy-armor']=function(player,made) if made > 5 then return 1 else return 0 end end,
	['burner-mining-drill']=function(player,made) if tick_to_min(game.tick) < 5 then return 4 else return 0 end end,
	['stone-furnace']=function(player,made) if tick_to_min(game.tick) < 5 then return 4 else return 0 end end,
	['iron-axe']=function(player,made) if made > 5 and player.force.item_production_statistics.get_input_count('steel-axe') <= 5 then return 1 else return 0 end end,
	['steel-axe']=function(player,made) if made > 5 then return 1 else return 0 end end
}
Event.register(defines.events.on_player_created, function(event)
  	local player = game.players[event.player_index]
	if event.player_index == 1 then
		player.force.friendly_fire = false
		player.force.chart(player.surface, {{player.position.x - 400, player.position.y - 400}, {player.position.x + 400, player.position.y + 400}})
	end
	for item,count in pairs(items) do
		if type(count) == 'function' then count = math.floor(count(player,player.force.item_production_statistics.get_input_count(item))) end
		if count > 0 then player.insert{name=item, count=count} end
	end
end)