--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Popup Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Small popups in the top left',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local add_frame = ExpGui.add_frame
local frames = ExpGui.frames
local draw_frame = ExpGui.draw_frame
--used to draw the next popup frame
ExpGui.add_input.button('close_popup','X','Close this Popup',function(player,element) element.parent.destroy() end)
local function get_next_popup(popups,name)
	if name then 
		local flow = popups.add{type='frame',name=name..'_on_click',direction='horizontal',style=mod_gui.frame_style} 
		local frame = flow.add{name='popup_frame',type='flow',direction='vertical'}
		ExpGui.add_input.draw_button(flow,'close_popup') return frame
	end
	local current = 0
	while true do if popups['popup'..current] then current = current+1 else break end end
	local flow = popups.add{type='frame',name='popup'..current,direction='horizontal',style=mod_gui.frame_style} 
	local frame = flow.add{name='popup_frame',type='flow',direction='vertical'}
	ExpGui.add_input.draw_button(flow,'close_popup') 
	return frame
end
--adds a frame to the popup flow
--on_click(player,element)	is what is called when button is clicked if nil no button is made
--event(player,frame,args)
--frame						is where it will be drawn to; args is any info you want to pass in
function add_frame.popup(style,default_display,default_tooltip,on_click,event)
	if not style then error('Popup style requires a name') end
	if not event or type(event) ~= 'function' then error('Popup style requires a draw function') end
	table.insert(frames.popup,{style=style,display=default_display,on_click=on_click,event=event})
	if on_click and type(on_click) == 'function' then
		ExpGui.toolbar.add_button(style,default_display,default_tooltip,draw_frame.popup_button)
	end
end
--draw the popup on_click GUI for the player; do not call manually must use other functions to call
function draw_frame.popup_button(player,element)
	debug_write({'GUI','POPUP-BUTTON'},player.name)
	local frame_data = nil
	for _,frame in pairs(frames.popup) do if element.name == frame.style then frame_data = frame break end end
	local popups = mod_gui.get_frame_flow(player).popups
	if popups[frame_data.style..'_on_click'] then popups[frame_data.style..'_on_click'].destroy() return end
	local frame = get_next_popup(popups,frame_data.style)
	frame_data.on_click(player,frame)
end
--used to draw a popup style can be called at any time; can not be called from a button directly
function draw_frame.popup(style,args)
	local args = args or {}
	local frame_data = nil
	for _,frame in pairs(frames.popup) do if style == frame.style then frame_data = frame break end end
	debug_write({'GUI','POPUP','STYLE'},style)
	debug_write({'GUI','POPUP','ARGS'},args)
	game.write_file('popups.log','\n'..game.tick..' Popup Style: '..style..' Was made with args of: '..table.tostring(args), true, 0)
	for _,player in pairs(game.connected_players) do
		debug_write({'GUI','POPUP','PLAYERS'},player.name)
		local popups = mod_gui.get_frame_flow(player).popups
		local frame = get_next_popup(popups)
		frame_data.event(player,frame,args)
	end
end
--used to make the popup area
Event.register(defines.events.on_player_joined_game,function(event) if not mod_gui.get_frame_flow(game.players[event.player_index]).popups then mod_gui.get_frame_flow(game.players[event.player_index]).add{name='popups',type='flow',direction='vertical'} end end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits