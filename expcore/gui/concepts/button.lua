--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- Clickable elements that fire on_gui_click when clicked.
@element button

@param on_click fired when the player clicks the button
@param on_left_click fired when the player clicks with the left mouse button
@param on_left_click fired when the player clicks with the right mouse button

@tparam ?string|Concepts.LocalisedString caption the message that is shown on the button
@tparam ?string|Concepts.LocalisedString tooltip the tooltip that shows when a player hovers over the button
@tparam Concepts.SpritePath sprite upto three sprites in the order: default, hovered, clicked

@usage-- Making a basic button
local basic_button =
Gui.new_concept('button')
:set_caption('Basic Button')
:set_tooltip('Basic button')
:on_click(function(event)
    event.player.print('You pressed basic button!')
end)

@usage-- Making a sprite button
local sprite_button =
Gui.new_concept('button')
:set_sprite('utility/warning_icon')
:set_tooltip('Sprite button')
:on_click(function(event)
    event.player.print('You pressed sprite button!')
end)

]]

Gui.new_concept()
:save_as('button')

-- Events
:new_event('on_click',defines.events.on_gui_click)
:new_event('on_left_click',defines.events.on_gui_click,function(event)
    return event.mouse_button == defines.mouse_button_type.left
end)
:new_event('on_right_click',defines.events.on_gui_click,function(event)
    return event.mouse_button == defines.mouse_button_type.right
end)

-- Properties
:new_property('tooltip')
:new_property('caption',function(properties,value)
    properties.caption = value
    properties.type = 'button'
end)
:new_property('sprite',function(properties,value,hovered_sprite,clicked_sprite)
    properties.sprite = value
    properties.hovered_sprite = hovered_sprite
    properties.clicked_sprite = clicked_sprite
    properties.type = 'sprite-button'
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Check if it should be a sprite button
    if properties.type == 'sprite-button' then
        -- Draw a sprite button
        element = parent.add{
            name = properties.name,
            type = 'sprite-button',
            sprite = properties.sprite,
            hovered_sprite = properties.hovered_sprite,
            clicked_sprite = properties.clicked_sprite,
            tooltip = properties.tooltip
        }

    else
        -- Draw a button
        element = parent.add{
            name = properties.name,
            type = 'button',
            caption = properties.caption,
            tooltip = properties.tooltip
        }

    end

    return element
end)