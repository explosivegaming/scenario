--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local ExpGui = require("ExpGaming - Module Setup")
local add_frame = ExpGui.add_frame
local frames = ExpGui.frames
local draw_frame = ExpGui.draw_frame
--left GUIs are always present and only have their visibility toggled
--Add a frame to the left bar; event(player,frame) must be present for left GUIs as there is no default
--vis should be true or false based on the player join game state of the GUI
function add_frame.left(name,default_display,default_tooltip,vis,event)
	if not name then error('Frame requires a name') end
	if not event or type(event) ~= 'function' then error('Frame requires a draw function') end
	local vis = vis or false
	frames.left[name] = {name=name,display=default_display,event=event,vis=vis}
	ExpGui.toolbar.add_button(name,default_display,default_tooltip,draw_frame.left)
end
--draw the left GUI for the player; called via script, only call manually when update is true and element is the name of the GUI
function draw_frame.left(player,element,update)
	debug_write({'GUI','LEFT'},player.name)
	local frame = nil
	local frame_data = nil
	local left = mod_gui.get_frame_flow(player)
	debug_write({'GUI','LEFT','UPDATE'},update)
	if not update then
		-- either toggels visabilty or makes the gui
		frame_data = frames.left[element.name]
		if left[frame_data.name] then ExpGui.toggle_visible(left[frame_data.name]) return end
		frame = left.add{name=frame_data.name,type='frame',caption=frame_data.display,direction='vertical',style=mod_gui.frame_style}
	else
		-- only clears the gui
		frame_data = frames.left[element]
		frame = left[frame_data.name]
	end
	-- draws the gui elements
	if frame then frame.clear() frame_data.event(player,frame) end
end
--used to load all left GUIs
Event.register(defines.events.on_player_joined_game,function(event)
	local player = game.players[event.player_index]
	for _,frame_data in pairs(frames.left) do
		local left = mod_gui.get_frame_flow(player)
		if left[frame_data.name] then
			-- if it has been made already then it updates it
			ExpGui.draw_frame.left(player,frame_data.name,true)
		else
			-- makes the gui if its not made
			ExpGui.draw_frame.left(player,{name=frame_data.name})
			frame.style.visible = frame_data.vis
		end
	end
end)
--resets visabilty of guis on rank change
Event.register(Event.rank_change,function(event)
	for _,frame_data in pairs(frames.left) do
		local left = mod_gui.get_frame_flow(event.player)
		if left[frame_data.name] then left[frame_data.name].style.visible = frame_data.vis end
	end
end)

return ExpGui