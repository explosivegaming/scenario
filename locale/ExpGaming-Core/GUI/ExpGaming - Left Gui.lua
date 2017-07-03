--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Left Gui',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='A simple way to add toggle menus to the left',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local add_frame = ExpGui.add_frame
local frames = ExpGui.frames
local draw_frame = ExpGui.draw_frame
--left guis are always present and only have their visabilty toggled
--adds a frame to the left bar; event(player,frame) must be present for left guis as there is no default
function add_frame.left(name,default_display,default_tooltip,restriction,event)
	if not name then error('Frame requires a name') end
	if not event or type(event) ~= 'function' then error('Frame requires a draw function') end
	table.insert(frames.left,{name,default_display,event})
	ExpGui.toolbar.add_button(name,default_display,default_tooltip,restriction,draw_frame.left)
end
--draw the left gui for the player; do not call manuley must use other functions to call
function draw_frame.left(player,element)
	local frame_data = nil
	for _,frame in pairs(frames.left) do if element.name == frame[1] then frame_data = frame break end end
	local left = mod_gui.get_frame_flow(player)
	if left[frame_data[1]] then ExpGui.toggleVisable(left[frame_data[1]]) return end
	local frame = left.add{name=frame_data[1],type='frame',capption=frame_data[2],direction='vertical'}
	frame_data[3](player,frame)
end
--Please Only Edit Above This Line-----------------------------------------------------------
return credits