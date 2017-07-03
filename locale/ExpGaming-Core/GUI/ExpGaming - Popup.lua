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
ExpGui.add_input.button('close_popup','X','Close This Popup',function(player,element) element.parent.destroy() end)
local function get_next_popup(popups,name)
	if name then 
		local flow = popups.add{type='flow',name=name..'_on_click',direction='horizontal'} 
		local frame = flow.add{name='popup_frame',type='frame',direction='vertical'}
		ExpGui.add_input.draw_button(flow,'close_popup') return frame
	end
	local current = #popups.children
	for _,p in pairs(popups.children) do
		if p.name == 'popup'..current then current = current+1 else
		local flow = popups.add{type='flow',name='popup'..current,direction='horizontal'} 
		local frame = flow.add{name='popup_frame',type='frame',direction='vertical'}
		ExpGui.add_input.draw_button(flow,'close_popup') return frame end
	end
	if #popups.children == 0 then 
		local flow = popups.add{type='flow',name='popup'..current,direction='horizontal'} 
		local frame = flow.add{name='popup_frame',type='frame',direction='vertical'}
		ExpGui.add_input.draw_button(flow,'close_popup') return frame end
end
--adds a frame to the popup flow;restriction is the power need to use the on_click function
--on_click(player,element) is what is called when button is clicked if nil no button is made
--event(player,frame,args) frame is where it will be drawen to; args is any infor you want to pass in
function add_frame.popup(style,default_display,default_tooltip,restriction,on_click,event)
	if not style then error('Popup style requires a name') end
	if not event or type(event) ~= 'function' then error('Popup style requires a draw function') end
	local restriction = restriction or 0
	table.insert(frames.popup,{style,default_display,on_click,event})
	if on_click and type(on_click) == 'function' then
		ExpGui.toolbar.add_button(style,default_display,default_tooltip,restriction,draw_frame.popup_button)
	end
end
--draw the popup on_click gui for the player; do not call manuley must use other functions to call
function draw_frame.popup_button(player,element)
	local frame_data = nil
	for _,frame in pairs(frames.popup) do if element.name == frame[1] then frame_data = frame break end end
	local popups = mod_gui.get_frame_flow(player).popups or mod_gui.get_frame_flow(player).add{name='popups',type='flow',direction='vertical'}
	if popups[frame_data[1]..'_on_click'] then popups[frame_data[1]..'_on_click'].destroy() return end
	local frame = get_next_popup(popups,frame_data[1])
	frame_data[3](player,frame)
end
--used to draw a popup style can be called at any time; can not be called from a button directly
function draw_frame.popup(style,args)
	local args = args or {}
	local frame_data = nil
	for _,frame in pairs(frames.popup) do if style == frame[1] then frame_data = frame break end end
	for _,player in pairs(game.connected_players) do
		local popups = mod_gui.get_frame_flow(player).popups or mod_gui.get_frame_flow(player).add{name='popups',type='flow',direction='vertical'}
		local frame = get_next_popup(popups)
		frame_data[4](player,frame,args)
	end
end
--Please Only Edit Above This Line-----------------------------------------------------------
return credits