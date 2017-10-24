--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
-- Mainly used as a plan for how the gui is stored also as a header for the credit
local ExpGui = {
	add_frame={
	--center
	--tab
	--left
	--popup
	},
	draw_frame={
	--center
	--tab
	--left
	--popup
	},
	add_input={
	--button
	--text
	--draw_button
	--draw_text
	},
	toolbar={
		buttons={}
		--draw
		--add_button
		},
	player_table={
		filters={}
	--draw
	--draw_filters
	--get_filters
	--player_match
	},
	inputs={
		buttons={},
		text={}
	},
	frames={
		center={},
		tabs={},
		left={},
		popup={}
	}
}
--simple function to toggle the visibility of a frame
function ExpGui.toggle_visible(frame)
	if frame then
		if frame.style.visible == nil then
			frame.style.visible = false 
		else
			frame.style.visible = not frame.style.visible
		end
	end
end
--Please Only Edit Above This Line-----------------------------------------------------------
return ExpGui