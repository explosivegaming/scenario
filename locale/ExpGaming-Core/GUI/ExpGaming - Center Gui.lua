--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Center Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The main GUI in the center',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local add_frame = ExpGui.add_frame
local frames = ExpGui.frames
local draw_frame = ExpGui.draw_frame
--Add a frame in the center
--tabs {{name,restriction},{...}}	is a list that can contain already defined tabs
--event(player,element)				is an option to have a custom GUI in the center
function add_frame.center(name,default_display,default_tooltip,restriction,tabs,event)
	if not name then error('Frame requires a name') end
	local tabs = tabs or {}
	table.insert(frames.center,{name,default_display,tabs,event})
	ExpGui.toolbar.add_button(name,default_display,default_tooltip,restriction,draw_frame.center)
end
--Define a tab; frame is needed as every tab must be used once; event(player,tab) is the draw function
function add_frame.tab(name,default_display,default_tooltip,restriction,frame,event)
	if not name then error('Tab requires a name') end
	if not frame then error('Tab requires a frame') end
	table.insert(frames.tabs,{name,default_display,frame,event})
	for _,f in pairs(frames.center) do if f[1] == frame then table.insert(f[3],{name,restriction}) end end
	ExpGui.add_input.button(name,default_display,default_tooltip,draw_frame.tab)
end
--Draw the center GUI for the player; do not call manually, must use other functions to call
ExpGui.add_input.button('close_center','Close','Close this GUI',function(player,element) element.parent.parent.parent.destroy() end)
function draw_frame.center(player,element)
	local frame_data = nil
	for _,frame in pairs(frames.center) do if element.name == frame[1] then frame_data = frame break end end
	if player.gui.is_valid_sprite_path(frame_data[2]) then frame_data[2] = frame_data[1] end
	if player.gui.center[frame_data[1]] then player.gui.center.clear() return else player.gui.center.clear() end
	local frame = player.gui.center.add{name=frame_data[1],type='frame',caption=frame_data[2],direction='vertical',style=mod_gui.frame_style}
	if frame_data[4] and type(frame_data[4]) == 'function' then frame_data[4](player,frame) return end
	local tab_bar_scroll = frame.add{type = "scroll-pane", name= "tab_bar_scroll", vertical_scroll_policy="never", horizontal_scroll_policy="always"}
	local tab_bar = tab_bar_scroll.add{type='flow',direction='horizontal',name='tab_bar'}
	local tab = frame.add{type = "scroll-pane", name= "tab", vertical_scroll_policy="auto", horizontal_scroll_policy="never"}
	for n,t in pairs(frame_data[3]) do
		local temp_restriction = nil
		if type(t[2]) == 'number' then temp_restriction = t[2] end
		local restriction = temp_restriction or string_to_rank(t[2]).power or 0
		if restriction >= get_rank(player).power then ExpGui.add_input.draw_button(tab_bar,t[1]) end 
	end
	draw_frame.tab(player,tab_bar[frame_data[3][1][1]])
	ExpGui.add_input.draw_button(tab_bar,'close_center')
	tab.style.minimal_height = 300
	tab.style.maximal_height = 300
	tab.style.minimal_width = 500
	tab.style.maximal_width = 500
	tab_bar_scroll.style.minimal_height = 60
	tab_bar_scroll.style.maximal_height = 60
	tab_bar_scroll.style.minimal_width = 500
	tab_bar_scroll.style.maximal_width = 500
	player.gui.center.add{type='frame',name='temp'}.destroy()--recenter the GUI
end
--Draw the tab into the center GUI for the player; do not call manually, must use other functions to call
function draw_frame.tab(player,element)
	for _,btn in pairs(element.parent.children) do if btn.name == 'close_center' or btn.name == element.name then
		btn.style.font_color = {r = 255, g = 255, b = 255,a=255}
	else 
		btn.style.font_color = {r = 100, g = 100, b = 100,a=255}
	end end
	element.parent.parent.parent.tab.clear()
	for _,tab in pairs(frames.tabs) do if element.name == tab[1] then tab[4](player,element.parent.parent.parent.tab) break end end
end

Event.register(Event.rank_change,function(event) event.player.gui.center.clear() end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits