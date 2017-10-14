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
	description='Handles all GUI inputs',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
--Please Only Edit Below This Line-----------------------------------------------------------
local add_input = ExpGui.add_input
local inputs = ExpGui.inputs
--allows defining of new buttons;;name  how to call button;;default_display  what is shown on the button;;default_tooltip  the tooltip display;;event  function(player,element) that runs on click
function add_input.button(name,default_display,default_tooltip,event)
	if not name then error('Button requires a name') end
	table.insert(inputs.buttons,{name=name,display=default_display,tooltip=default_tooltip,event=event})
end
--allows defining of text box inputs;;name  how to call button;;default_display  what is shown on the button;;event  function(player,element) that runs on text change
function add_input.text(name,default_display,event)
	if not name then error('Text Filed requires a name') end
	table.insert(inputs.text,{name=name,display=default_display,event=event})
end
--draws the button into a gui;;frame  the frame to draw to;;name  name of button to draw;;display(opptinal) overrides the default;;tooltip(opptinal) overrides the default
function add_input.draw_button(frame,name,display,tooltip)
	if not frame or not frame.valid then error('No frame to draw to') end
	if not name then error('No button to draw') end
	debug_write({'GUI','INPUT'},name)
	for _,button in pairs(inputs.buttons) do
		if button.name == name then
			local display = display or button.display or button.name
			local tooltip = tooltip or button.tooltip
			if frame.gui.is_valid_sprite_path(display) then
				frame.add{name=name, type = "sprite-button", sprite=display, tooltip=tooltip, style = mod_gui.button_style}
			else
				frame.add{name=name, type = "button", caption=display, tooltip=tooltip, style = mod_gui.button_style}
			end return
		end
	end
	error('No Button by the name of '..name)
end
--draws the text into a gui;;frame  the frame to draw to;;name  name of button to draw;;display(opptinal) overrides the default;;tooltip(opptinal) overrides the default
function add_input.draw_text(frame,name,display)
	if not frame or not frame.valid then error('No frame to draw to') end
	if not name then error('No text filed to draw') end
	debug_write({'GUI','INPUT'},name)
	for _,text in pairs(inputs.text) do
		if text.name == name then
			local display = display or text.display or text.name
			frame.add{name=name, type='textfield'}
			frame[name].caption=display
			break
		end
	end
end
--the magic behind the buttons
Event.register(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
	if event.element.type == 'button' or event.element.type == 'sprite-button' then
		for _,button in pairs(inputs.buttons) do
			if button.name == event.element.name then
				if button.event then button.event(player,event.element) else ranking.rank_print('Button without Function '..button.name,'Mod') end break
			end
		end
	end
end)
--the magic behind the text inputs
Event.register(defines.events.on_gui_text_changed, function(event)
  local player = game.players[event.player_index]
	for _,text in pairs(inputs.text) do
		if text.name == event.element.name then
			if text.event then text.event(player,event.element) end break
		end
	end
end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits