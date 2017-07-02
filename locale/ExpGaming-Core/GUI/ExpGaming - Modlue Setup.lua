--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Explosive Gaming Gui System',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Without this it would not be the same',
	factorio_version='0.15.23',
	show=true
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui = {
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
	--add_player_table
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
--simple function to toggle the visiblly of a frame
function ExpGui.toggleVisable(frame)
	if frame then
		if frame.style.visible == nil then
			frame.style.visible = false 
		else
			frame.style.visible = not frame.style.visible
		end
	end
end
--Please Only Edit Above This Line-----------------------------------------------------------
return credits