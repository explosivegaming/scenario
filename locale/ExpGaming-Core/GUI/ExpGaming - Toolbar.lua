--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='A Very Useful Toolbar',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Some simple functions that help to control the toolbar',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local toolbar = ExpGui.toolbar
--similar to ExpGui.add_input.button but it also accepts a restriction and button is drawn to the toolbar
function toolbar.add_button(name,default_display,default_tooltip,restriction,event)
	local restriction = restriction or 0
	if not name then error('Button requires a name') end
	table.insert(toolbar.buttons,{name,restriction})
	ExpGui.add_input.button(name,default_display,default_tooltip,event)
end
--draw the toolbar to the player only showing buttons within their restriction
function toolbar.draw(player)
	if not player then error('Need a player to draw to') end
	local toolbar_frame = mod_gui.get_button_flow(player)
	toolbar_frame.clear()
	for _,button in pairs(toolbar.buttons) do
		local rank = get_rank(player)
		local temp_restriction = nil
		if type(button.restriction) == 'number' then temp_restriction = button.restriction end
		local restriction = temp_restriction or string_to_rank(button.restriction).power or 0
		if restriction >= rank.power then
			ExpGui.add_input.draw_button(toolbar_frame,button.name)
		end
	end
end
--auto-redraw toolbar after new rank is given
Event.register(Event.rank_change,function(event) toolbar.draw(event.player) end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits