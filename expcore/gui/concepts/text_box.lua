--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A multi-line text box that supports selection and copy-paste.
@element text_box

@param on_text_changed fired when the text within the text box is changed

@tparam ?string|Concepts.LocalisedString tooltip the tooltip that shows when a player hovers over the text box
@tparam ?string|function default the default text that will appear in the text box, or a function that returns it
@tparam defines.rich_text_setting rich_text how this element handles rich text
@tparam boolean clear_on_rmb if the text box will be cleared and forcused on a right click
@tparam boolean is_selectable when true the text inside the box can be selected
@tparam boolean has_word_wrap when true the text will wrap onto the next line if it reachs the end
@tparam boolean is_read_only when true the text inside the box can not be edited by the player

@usage-- Making a text box
local basic_text_box =
Gui.new_concept('text_box')
:set_default('I am the text that will show in the text box')

@usage-- Making a text box which can be edited
local editible_text_box =
Gui.new_concept('text_box')
:set_is_read_only(false)
:set_default('I am the text that will show in the text box')
:on_confirmation(function(event)
    event.player.print('Editible text box is now: '..event.element.text)
end)

]]

Gui.new_concept()
:save_as('text_box')

-- Events
:new_event('on_text_changed',defines.events.on_gui_text_changed)

-- Properties
:new_property('tooltip')
:new_property('default')
:new_property('rich_text')
:new_property('clear_on_rmb',nil,false)
:new_property('is_selectable',nil,true)
:new_property('has_word_wrap',nil,true)
:new_property('is_read_only',nil,true)

-- Draw
:define_draw(function(properties,parent,element)
    local default = properties.default
    local text = type(default) == 'string' and default or nil

    -- Draw a text box
    element = parent.add{
        name = properties.name,
        type = 'text-box',
        tooltip = properties.tooltip,
        clear_and_focus_on_right_click = properties.clear_on_rmb,
        text = text
    }

    -- Set options for text box
    element.selectable = properties.is_selectable
    element.word_wrap = properties.has_word_wrap
    element.read_only = properties.is_read_only

    -- If there is a default, set it
    default = Gui.resolve_property(default,element)
    if default and default ~= text then
        element.text = default
    end

    -- Change rich text setting if present
    local rich_text = properties.rich_text
    if rich_text then
        element.style.rich_text_setting = rich_text
    end

    return element
end)