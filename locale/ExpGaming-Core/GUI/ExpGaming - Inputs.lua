--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='Gui Input Handler',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='Handles all gui inputs',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local add_input = ExpGui.add_input
local inputs = ExpGui.inputs
--allows defining of new buttons;;name  how to call button;;default_display  what is showen on the button;;default_tooltip  the tooltip display;;event  function(player,element) that runs on click
function add_input.button(name,default_display,default_tooltip,event)
	if not name then error('Button requires a name') end
	table.insert(inputs.buttons,{name,default_display,default_tooltip,event})
end
--allows defining of text box inputs;;name  how to call button;;default_display  what is showen on the button;;event  function(player,element) that runs on text change
function add_input.text(name,default_display,event)
	if not name then error('Text Filed requires a name') end
	table.insert(inputs.text,{name,default_display,event})
end
--draws the button into a gui;;frame  the frame to draw to;;name  name of button to draw;;display(opptinal) overides the default;;tooltip(opptinal) overides the default
function add_input.draw_button(frame,name,display,tooltip)
	if not frame or not frame.valid then error('No frame to draw to') end
	if not name then error('No button to draw') end
	for _,btn in pairs(inputs.buttons) do
		if btn[1] == name then
			local display = display or btn[2] or btn[1]
			local tooltip = tooltip or btn[3]
			if frame.gui.is_valid_sprite_path(display) then
				frame.add{name=name, type = "sprite-button", sprite=display, tooltip=tooltip, style = mod_gui.button_style}
			else
				frame.add{name=name, type = "button", caption=display, tooltip=tooltip, style = mod_gui.button_style}
			end return
		end
	end
	error('No Button By The Name Of '..name)
end
--draws the text into a gui;;frame  the frame to draw to;;name  name of button to draw;;display(opptinal) overides the default;;tooltip(opptinal) overides the default
function add_input.draw_text(frame,name,display)
	if not frame or not frame.valid then error('No frame to draw to') end
	if not name then error('No text filed to draw') end
	for _,text in pairs(inputs.text) do
		if text[1] == name then
			local display = display or text[2] or text[1]
			frame.add{name=name, type='textfield', text=display}
			break
		end
	end
end
--the magic behind the buttons
Event.register(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
	if event.element.type == 'button' or event.element.type == 'sprite-button' then
		for _,btn in pairs(inputs.buttons) do
			if btn[1] == event.element.name then
				if btn[4] then btn[4](player,event.element) else rank_print('Button Without Function '..btn[1],'Mod') end break
			end
		end
	end
end)
--the magic behind the text inputs
Event.register(defines.events.on_gui_text_changed, function(event)
  local player = game.players[event.player_index]
	for _,text in pairs(inputs.text) do
		if text[1] == event.element.name then
			if text[3] then text[3](player,event.element) end break
		end
	end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits