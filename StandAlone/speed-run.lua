require("mod-gui")
script.on_event(defines.events.on_player_joined_game,function(event)
	local player = game.players[event.player_index]
	if mod_gui.get_frame_flow(player).time then return end
	local frame = mod_gui.get_frame_flow(player).add{type='frame',name='time',direction='vertical',style=mod_gui.frame_style}
	frame.add{type='label',name='title',caption='Speed Run:',style='caption_label'}
	local table = frame.add{type='table',name='table',column_count=7}
	table.style.horizontal_spacing = 5
	table.add{type='label',name='hours',caption='hours'}
	table.add{type='label',name='sep1',caption=' : '}
	table.add{type='label',name='minutes',caption='minutes'}
	table.add{type='label',name='sep2',caption=' : '}
	table.add{type='label',name='seconds',caption='seconds'}
	table.add{type='label',name='sep3',caption=' : '}
	table.add{type='label',name='ticks',caption='ticks'}
end)

script.on_event(defines.events.on_tick,function(event)
	if game.forces['player'].get_item_launched("satellite") > 0 then return end
	local t = event.tick
	local times = {math.floor(t/216000),math.floor(t/3600),math.floor(t/60),string.format('%.2f',t/60)}
	times = {string.format("%02d",times[1]),string.format("%02d",times[2]-times[1]*60),string.format("%02d",times[3]-times[2]*60),times[4]:sub(-2,-1)}
	for _,player in pairs(game.connected_players) do
		local table = mod_gui.get_frame_flow(player).time.table
		table.hours.caption = times[1]
		table.minutes.caption = times[2]
		table.seconds.caption = times[3]
		table.ticks.caption = times[4]
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	player.insert{name="iron-plate", count=8}
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
	player.insert{name="burner-mining-drill", count = 1}
	player.insert{name="stone-furnace", count = 1}
	player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
	if (#game.players <= 1) then
	  game.show_message_dialog{text = {"msg-intro"}}
	else
	  player.print({"msg-intro"})
	end
  end)
  
  script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.players[event.player_index]
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
  end)
  
  script.on_event(defines.events.on_rocket_launched, function(event)
	local force = event.rocket.force
	if event.rocket.get_item_count("satellite") == 0 then
	  if (#game.players <= 1) then
		game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
	  else
		for index, player in pairs(force.players) do
		  player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
		end
	  end
	  return
	end
	if not global.satellite_sent then
	  global.satellite_sent = {}
	end
	if global.satellite_sent[force.name] then
	  global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
	else
	  game.set_game_state{game_finished=true, player_won=true, can_continue=true}
	  global.satellite_sent[force.name] = 1
	end
	for index, player in pairs(force.players) do
	  if player.gui.left.rocket_score then
		player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
	  else
		local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
		frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
		frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
	  end
	end
  end)
  