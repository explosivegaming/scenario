--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Setup for the Gui Object',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='The very fondation of the Gui System',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
ExpGui = {
	add_frame={
	--center
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
		left={},
		popup={}
	}
}
--Please Only Edit Above This Line-----------------------------------------------------------
return credits