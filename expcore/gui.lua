--[[-- Core Module - Gui
    @core Gui
    @alias Gui

@usage-- Making the base button concept
local button =
Gui.new_concept('Button')
:new_event('on_click',defines.events.on_gui_click)
:new_property('tooltip')
:new_property('caption',nil,function(properties,value)
    properties.caption = value
    properties.sprite = nil
    properties.type = 'button'
end)
:new_property('sprite',nil,function(properties,value)
    properties.image = value
    properties.caption = nil
    properties.type = 'sprite-button'
end)

@usage-- Makeing a alternative button based on the first
local custom_button =
button:clone('CustomButton')
:new_event('on_admin_clicked',defines.events.on_gui_click,function(event)
    return event.player.admin -- only raise custom event when an admin clicks the button
end)
:set_caption('Custom Button')
:set_tooltip('Only admins can press this button')
:on_click(function(event)
    if not event.player.admin then
        event.player.print('You must be admin to use this button')
    end
end)
:on_admin_clicked(function(event)
    -- Yes i know this can just be an if else but its an example
    game.print(event.player.name..' pressed my admin button')
end)

@usage-- Drawing a concept
custom_button:draw(game.player.gui.left)
]]

local Gui = require 'expcore.gui.core'

return Gui