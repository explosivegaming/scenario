--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local ExpGui = require("ExpGaming - Module Setup")
local toolbar = ExpGui.toolbar
--similar to ExpGui.add_input.button but it also accepts a restriction and button is drawn to the toolbar
function toolbar.add_button(name,default_display,default_tooltip,event)
	if not name then error('Button requires a name') end
	table.insert(toolbar.buttons,name)
	ExpGui.add_input.button(name,default_display,default_tooltip,event)
end
--draw the toolbar to the player only showing buttons within their restriction
function toolbar.draw(player)
	debug_write({'GUI','TOOLBAR'},player.name)
	if not player then error('Need a player to draw to') end
	local toolbar_frame = mod_gui.get_button_flow(player)
	toolbar_frame.clear()
	for _,button in pairs(toolbar.buttons) do
		local rank = ranking.get_player_rank(player)
		if ranking.rank_allowed(ranking.get_player_rank(player),button) then
			debug_write({'GUI','TOOLBAR','ADD'},button)
			ExpGui.add_input.draw_button(toolbar_frame,button)
		end
	end
end
--auto-redraw toolbar after new rank is given
Event.register(Event.rank_change,function(event) toolbar.draw(event.player) end)

return ExpGui