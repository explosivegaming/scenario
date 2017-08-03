--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Admin Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='AA gui to help the server admins',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local force_modifiers = {
	--{{'effects to change',...},'Display Name',tech modifier}
	{{'manual_mining_speed_modifier'},'Mining Speed'},
	{{'manual_crafting_speed_modifier'},'Crafting Speed'},
	{{'character_running_speed_modifier'},'Running Speed'},
	{{'character_build_distance_bonus','character_reach_distance_bonus'},'Player Reach'},
	{{'worker_robots_speed_modifier','worker_robots_storage_bonus'},'Bot Boost',{'worker-robot-speed','worker-robot-storage'}}
}

local player_modifiers = {
	--{{'effects to change',...},'Display Name',tech modifier}
	{{'character_mining_speed_modifier'},'Mining Speed'},
	{{'character_crafting_speed_modifier'},'Crafting Speed'},
	{{'character_running_speed_modifier'},'Running Speed'},
	{{'character_build_distance_bonus','character_reach_distance_bonus'},'Reach'},
	{{'character_health_bonus'},'Health'}
}

ExpGui.add_frame.center('admin','Admin','A few admin only things','Admin',{{'commands','Admin'}})

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
	table.add{type='label',name=name..'_name',caption=name}
	table.add{name=name..'__x1', type='radiobutton',state=get_state(name,player,is_player,1)}
    table.add{name=name..'__x1.5', type='radiobutton',state=get_state(name,player,is_player,1.5)}
	table.add{name=name..'__x2', type='radiobutton',state=get_state(name,player,is_player,2)}
	table.add{name=name..'__x3', type='radiobutton',state=get_state(name,player,is_player,3)}
	table.add{name=name..'__x5', type='radiobutton',state=get_state(name,player,is_player,5)}
	table.add{name=name..'__x10', type='radiobutton',state=get_state(name,player,is_player,10)}
end

ExpGui.add_frame.tab('force_modifiers','Force Modifiers','Some Force Modifiers','Admin','admin',function(player,frame)
    frame.add{type = 'flow', name= 'flow',direction = 'horizontal'}
    local table = frame.add{name='modifiers_table', type='table', colspan=7}
    table.add{name='force_modifier_name', type='label', caption='Name'}
    table.add{name='x1', type='label', caption='x1'}
    table.add{name='x1.5', type='label', caption='x1.5'}
	table.add{name='x2', type='label', caption='x2'}
	table.add{name='x3', type='label', caption='x3'}
	table.add{name='x5', type='label', caption='x5'}
	table.add{name='x10', type='label', caption='x10'}
    for _,modifier in pairs(force_modifiers) do add_moddifier(table,modifier[2],player.force,false) end
end)

ExpGui.add_frame.tab('player_modifiers','Player Modifiers','Some Player Modifiers','Admin','admin',function(player,frame)
    frame.add{type = 'flow', name= 'flow',direction = 'horizontal'}
    local table = frame.add{name='modifiers_table', type='table', colspan=7}
    table.add{name='player_modifier_name', type='label', caption='Name'}
    table.add{name='x1', type='label', caption='x1'}
    table.add{name='x1.5', type='label', caption='x1.5'}
	table.add{name='x2', type='label', caption='x2'}
	table.add{name='x3', type='label', caption='x3'}
	table.add{name='x5', type='label', caption='x5'}
	table.add{name='x10', type='label', caption='x10'}
    for _,modifier in pairs(player_modifiers) do add_moddifier(table,modifier[2],player,true) end
end)

Event.register(defines.events.on_gui_click, function(event)
	local element = event.element
	local player = game.players[event.player_index]
	local force = game.forces['player']
	if element.valid and element.type == 'radiobutton' and element.parent.name == 'modifiers_table' then
		-- getting all info needed
		local modifier_name = element.name:match('.+__x'):sub(0,-4)
		local slected = tonumber(element.name:match('__x.+'):sub(4))
		local is_player = false
		if element.parent.player_modifier_name then is_player = true end
		local modifier = nil
		local old_slected = nil
		if is_player then 
			for _,m in pairs(player_modifiers) do if m[2] == modifier_name then 
				modifier = m
				old_slected = global.modifiers.players[player.index][modifier_name]
				global.modifiers.players[player.index][modifier_name] = slected
			break end end
		else 
			for _,m in pairs(force_modifiers) do if m[2] == modifier_name then 
				modifier = m 
				old_slected = global.modifiers.force[modifier_name]
				global.modifiers.force[modifier_name] = slected
			break end end
		end
		-- setting the new value
		game.print(modifier_name..' '..slected..' '..old_slected..' '..tostring(is_player))
		for n,effect in pairs(modifier[1]) do
			local base = nil
			local temp_slected = nil
			if modifier[3] and modifier[3][n] then
				game.print(n..' '..modifier[3][n])
				if global.modifiers.base[modifier[3][n]] == 'Set 0' then
					base = 1 
					temp_slected=slected-1
				else
					base = global.modifiers.base[modifier[3][n]]
					game.print(global.modifiers.base[modifier[3][n]])
				end
			else 
				if is_player then 
					base = player[effect]/old_slected 
				else 
					base = force[effect]/old_slected 
				end
				if base == 0 then 
					modifier[3] = {effect} 
					global.modifiers.base[effect] = 'Set 0'
					base = 1
					temp_slected=slected-1
				end
			end
			base = base or 0
			temp_slected = temp_slected or slected
			local new_value = base*temp_slected
			game.print('base: '..tostring(base))
			game.print(base..' '..temp_slected)
			game.print(new_value)
			if is_player then player[effect] = new_value else force[effect] = new_value end
		end
		-- re drawing the tab
		local button = element.parent.parent.parent.tab_bar_scroll.tab_bar
		if is_player then button = button.player_modifiers else button = button.force_modifiers end
		ExpGui.draw_frame.tab(player,button)
	end
end)

Event.register(defines.events.on_research_finished, function(event)
	local research = event.research
	for _,effect in pairs(research.effects) do
		if not global.modifiers.base[effect.type] and effect.modifier then global.modifiers.base[effect.type] = effect.modifier
		elseif effect.modifier then global.modifiers.base[effect.type] = global.modifiers.base[effect.type] + effect.modifier end
	end
end)

Event.register(-1,function() global.modifiers = {force={},base={},players={}} end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits