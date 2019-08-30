--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic button element
@element button
@param on_click fired when the player clicks the button
@param on_left_click fired when the player clicks with the left mouse button
@param on_left_click fired when the player clicks with the right mouse button
@tparam ?string|Concepts.LocalisedString caption the message that is shown on the button
@tparam ?string|Concepts.LocalisedString tooltip the tooltip that shows when a player hovers over the button
@tparam SpritePath sprite upto three sprites in the order: default, hovered, clicked
@usage-- Making a basic button
local basic_button =
Gui.clone_concept('button','basic_button')
:set_caption('Basic Button')
:set_tooltip('Basic button')
:on_click(function(event)
    event.player.print('You pressed basic button!')
end)
@usage-- Making a sprite button
local sprite_button =
Gui.clone_concept('button','sprite_button')
:set_sprite('utility/warning_icon')
:set_tooltip('Sprite button')
:on_click(function(event)
    event.player.print('You pressed sprite button!')
end)
]]
Gui.new_concept('button')
:new_event('on_click',defines.events.on_gui_click)
:new_event('on_left_click',defines.events.on_gui_click,function(event)
    return event.mouse_button == defines.mouse_button_type.left
end)
:new_event('on_right_click',defines.events.on_gui_click,function(event)
    return event.mouse_button == defines.mouse_button_type.right
end)
:new_property('tooltip')
:new_property('caption',nil,function(properties,value)
    properties.caption = value
    properties.type = 'button'
end)
:new_property('sprite',nil,function(properties,value,hovered_sprite,clicked_sprite)
    properties.sprite = value
    properties.hovered_sprite = hovered_sprite
    properties.clicked_sprite = clicked_sprite
    properties.type = 'sprite-button'
end)
:define_draw(function(properties,parent,element)
    if properties.type == 'button' then
        element = parent.add{
            name = properties.name,
            type = properties.type,
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    else
        element = parent.add{
            name = properties.name,
            type = properties.type,
            sprite = properties.sprite,
            hovered_sprite = properties.hovered_sprite,
            clicked_sprite = properties.clicked_sprite,
            tooltip = properties.tooltip
        }

    end

    return element
end)