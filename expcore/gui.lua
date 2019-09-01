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
:define_draw(function(properties,parent,element)
    -- Note that element might be nil if this is the first draw function
    -- in this case button is a new concept so we know this is the first function and element is nil
    if properties.type == 'button' then
        element = parent.add{
            type = properties.type,
            name = properties.name,
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    else
        element = parent.add{
            type = properties.type,
            name = properties.name,
            sprite = properties.sprite,
            tooltip = properties.tooltip
        }

    end

    -- We must return the element or what we want to be seen as the instance, this is so other draw functions have access to it
    -- for example if our custom button defined a draw function to change the font color to red
    return element
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

Gui.require_concept('frame')
Gui.require_concept('button')
Gui.require_concept('checkbox')
Gui.require_concept('dropdown')
Gui.require_concept('elem_button')
Gui.require_concept('progress_bar')
Gui.require_concept('slider')
Gui.require_concept('textfield')
Gui.require_concept('textbox')

return Gui