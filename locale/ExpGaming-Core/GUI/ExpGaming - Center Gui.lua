--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local ExpGui = require("ExpGaming - Module Setup")
local add_frame = ExpGui.add_frame
local frames = ExpGui.frames
local draw_frame = ExpGui.draw_frame
--Add a frame in the center
--tabs {{name},{...}}	is a list that can contain already defined tabs
--event(player,element)				is an option to have a custom GUI in the center
function add_frame.center(name,default_display,default_tooltip,tabs,event)
	if not name then error('Frame requires a name') end
	local tabs = tabs or {}
	frames.center[name] = {name=name,display=default_display,tabs=tabs,event=event}
	ExpGui.toolbar.add_button(name,default_display,default_tooltip,draw_frame.center)
end
--Define a tab; frame is needed as every tab must be used once; event(player,tab) is the draw function
function add_frame.tab(name,default_display,default_tooltip,frame,event)
	if not name then error('Tab requires a name') end
	if not frame then error('Tab requires a frame') end
	frames.tabs[name] = {name=name,display=default_display,frame=frame,event=event}
	table.insert(frames.center[frame].tabs,name)
	ExpGui.add_input.button(name,default_display,default_tooltip,draw_frame.tab)
end
--Draw the center GUI for the player; do not call manually, must use other functions to call
ExpGui.add_input.button('close_center',{'expgui.close-button'},{'expgui.close-button-tooltip'},function(player,element) element.parent.parent.parent.destroy() end)
function draw_frame.center(player,element)
	local frame_data = frames.center[element.name]
	debug_write({'GUI','CENTER'},player.name..' '..frame_data.name)
	--setup so nothing will break (name is set as caption if display a sprite)
	if type(frame_data.display) == 'string' and player.gui.is_valid_sprite_path(frame_data.display) then frame_data.display = frame_data.name end
	if player.gui.center[frame_data.name] then player.gui.center.clear() return else player.gui.center.clear() end
	-- start drawing
	local frame = player.gui.center.add{name=frame_data.name,type='frame',caption=frame_data.display,direction='vertical',style=mod_gui.frame_style}
	if frame_data.event and type(frame_data.event) == 'function' then frame_data.event(player,frame) return end
	-- if a custom draw is not set then it will do the default
	local tab_bar_scroll = frame.add{type = "scroll-pane", name= "tab_bar_scroll", vertical_scroll_policy="never", horizontal_scroll_policy="always"}
	local tab_bar = tab_bar_scroll.add{type='flow',direction='horizontal',name='tab_bar'}
	local tab = frame.add{type = "scroll-pane", name= "tab", vertical_scroll_policy="auto", horizontal_scroll_policy="never"}
	-- draw tabs buttons for allowed tabs
	local first_tab = nil
	for n,tab_name in pairs(frame_data.tabs) do 
		if ranking.rank_allowed(ranking.get_player_rank(player),tab_name..'_tab') then
			first_tab = first_tab or tab_name
			debug_write({'GUI','CENTER','ADD'},tab_name) 
			ExpGui.add_input.draw_button(tab_bar,tab_name) 
		end
	end
	draw_frame.tab(player,tab_bar[first_tab])
	ExpGui.add_input.draw_button(tab_bar,'close_center')
	--sets the size of the gui
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
	debug_write({'GUI','CENTER','OPEN-TAB'},element.name)
	for _,btn in pairs(element.parent.children) do if btn.name == 'close_center' or btn.name == element.name then
		btn.style.font_color = {r = 255, g = 255, b = 255,a=255}
	else 
		btn.style.font_color = {r = 100, g = 100, b = 100,a=255}
	end end
	element.parent.parent.parent.tab.clear()
	frames.tabs[element.name].event(player,element.parent.parent.parent.tab)
end

Event.register(Event.rank_change,function(event) event.player.gui.center.clear() end)

return ExpGui