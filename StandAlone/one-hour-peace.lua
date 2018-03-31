local function switch_display(peace)
    if peace and not global.peace then
        global.peace = true
        for _,player in pairs(game.connected_players) do
            mod_gui.get_frame_flow(player).time.title.caption = 'Time Left:'
        end
        game.forces['enemy'].set_cease_fire('player',true)
        game.surfaces['nauvis'].peaceful_mode = true
    elseif not pease and global.peace then
        global.peace = false
        for _,player in pairs(game.connected_players) do
            mod_gui.get_frame_flow(player).time.title.caption = 'Time Survived:'
        end
        game.forces['enemy'].set_cease_fire('player',false)
        game.surfaces['nauvis'].peaceful_mode = false
    end
end

Event.register(-1,function(event) 
    global.time_left = 216000 
    global.time_passed = 0 
    global.peace = true
    game.forces['enemy'].set_cease_fire('player',true)
    game.surfaces['nauvis'].peaceful_mode = true
end)

Event.register(defines.events.on_player_joined_game,function(event)
	local player = game.players[event.player_index]
	if mod_gui.get_frame_flow(player).time then return end
	local frame = mod_gui.get_frame_flow(player).add{type='frame',name='time',direction='vertical',style=mod_gui.frame_style}
	frame.add{type='label',name='title',caption='Time Left:',style='caption_label'}
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

Event.register(defines.events.on_tick,function(event)
    local t = 0
    if global.time_left > 0 then
        global.time_left = global.time_left-1
        t = global.time_left
    else
        switch_display(false)
        global.time_passed = global.time_passed+1
        t = global.time_passed
    end
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