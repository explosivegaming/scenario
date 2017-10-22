--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local force_modifiers = {
	--{display,{{effect,base,offset},{...}}} - if ofset 0 does not work try -1
	{{'admin-gui.modifier-mining'},{{'manual_mining_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-crafting'},{{'manual_crafting_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-running'},{{'character_running_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-reach'},{{'character_build_distance_bonus',6,-1},{'character_reach_distance_bonus',6,-1}}},
	{{'admin-gui.modifier-bot'},{{'worker_robots_speed_modifier','worker-robot-speed',0},{'worker_robots_storage_bonus','worker-robot-storage',0}}}
}

local player_modifiers = {
	--{display,{{effect,base,offset},{...}}} - if ofset 0 does not work try -1 and base to 1
	{{'admin-gui.modifier-mining'},{{'character_mining_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-crafting'},{{'character_crafting_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-running'},{{'character_running_speed_modifier',1,-1}}},
	{{'admin-gui.modifier-reach'},{{'character_build_distance_bonus',6,-1},{'character_reach_distance_bonus',6,-1}}},
	{{'admin-gui.modifier-health'},{{'character_health_bonus',250,-1}}}
}

local states={1,1.25,1.5,2,3,5,7.5,10}

ExpGui.add_frame.center('admin',{'admin-gui.name'},{'admin-gui.tooltip'},{'commands'})

local function get_state(name,player,is_player,value)
	if is_player then
		if not global.modifiers.players[player.index] then global.modifiers.players[player.index] = {} end
		if not global.modifiers.players[player.index][name] then global.modifiers.players[player.index][name] = 1 end
		if global.modifiers.players[player.index][name] == value then return true else return false end
	else
		if not global.modifiers.force[name] then global.modifiers.force[name] = 1 end
		if global.modifiers.force[name] == value then return true else return false end
	end
end

local function add_moddifier(table,name,player,is_player) --player can be a force
	table.add{type='label',name=name..'_name',caption={name}}
	for _,state in pairs(states) do
		table.add{name=name..'__x'..state, type='radiobutton',state=get_state(name,player,is_player,state)}
    end
end

ExpGui.add_frame.tab('force_modifiers',{'admin-gui.tab-force-modifiers'},{'admin-gui.tab-force-modifiers-tooltip'},'admin',function(player,frame)
    frame.add{type = 'flow', name= 'flow',direction = 'horizontal'}
    local table = frame.add{name='modifiers_table', type='table', colspan=#states+1}
    table.add{name='force_modifier_name', type='label', caption={'admin-gui.modifier-name-capion'}}
	for _,state in pairs(states) do table.add{name='x'..state, type='label', caption='x'..state} end
    for _,modifier in pairs(force_modifiers) do add_moddifier(table,modifier[1][1],player.force,false) end
end)

ExpGui.add_frame.tab('player_modifiers',{'admin-gui.tab-player-modifiers'},{'admin-gui.tab-player-modifiers-tooltip'},'admin',function(player,frame)
    frame.add{type = 'flow', name= 'flow',direction = 'horizontal'}
    local table = frame.add{name='modifiers_table', type='table', colspan=#states+1}
    table.add{name='player_modifier_name', type='label', caption={'admin-gui.modifier-name-capion'}}
    for _,state in pairs(states) do table.add{name='x'..state, type='label', caption='x'..state} end
    for _,modifier in pairs(player_modifiers) do add_moddifier(table,modifier[1][1],player,true) end
end)

Event.register(defines.events.on_gui_click, function(event)
	local element = event.element
	local player = game.players[event.player_index]
	local force = game.forces['player']
	if element.valid and element.type == 'radiobutton' and element.parent.name == 'modifiers_table' then
		-- getting all info needed
		local modifier_name = element.name:match('.+__x'):sub(0,-4)
		local slected = tonumber(element.name:match('__x.+'):sub(4))
		local is_player = false; if element.parent.player_modifier_name then is_player = true end
		local modifier = nil
		if is_player then 
			for _,m in pairs(player_modifiers) do if m[1][1] == modifier_name then 
				modifier = m
				global.modifiers.players[player.index][modifier_name] = slected
			break end end
		else 
			for _,m in pairs(force_modifiers) do if m[1][1] == modifier_name then 
				modifier = m 
				global.modifiers.force[modifier_name] = slected
			break end end
		end
		-- setting the new value
		for n,effect in pairs(modifier[2]) do
			local base = global.modifiers.base[effect[2]] or effect[2]
			if type(base) ~= 'number' then base = 1 end
			local new_value = base*(slected+effect[3])
			if is_player then player[effect[1]] = new_value else force[effect[1]] = new_value end
		end
		-- redrawing the tab
		local button = element.parent.parent.parent.tab_bar_scroll.tab_bar
		if is_player then button = button.player_modifiers else button = button.force_modifiers end
		ExpGui.draw_frame.tab(player,button)
	end
end)
-- sets the bases for modifiers that can be researched
Event.register(defines.events.on_research_finished, function(event)
	local research = event.research
	for _,effect in pairs(research.effects) do
		if not global.modifiers.base[effect.type] and effect.modifier then global.modifiers.base[effect.type] = effect.modifier
		elseif effect.modifier then global.modifiers.base[effect.type] = global.modifiers.base[effect.type] + effect.modifier end
	end
end)
-- sets the value back onto an player after death
Event.register(defines.events.on_player_respawned, function(event)
	local player = game.players[event.index]
	if not global.modifiers.players[player.index] then return end
	for _,modifier_name in pairs(global.modifiers.players[player.index]) do
		local modifier = nil; for _,m in pairs(player_modifiers) do if m[1][1] == modifier_name then modifier = m break end end
		for n,effect in pairs(modifier[2]) do
			local base = global.modifiers.base[effect[2]] or effect[2]
			if type(base) ~= 'number' then base = 1 end
			local new_value = base*(slected+effect[3])
			player[effect[1]] = new_value
		end
	end
end)

Event.register(Event.soft_init,function() global.modifiers = {force={},base={},players={}} end)