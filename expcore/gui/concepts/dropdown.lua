--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'
local array_insert = ext_require('expcore.common','array_insert')

--[[-- A drop down list of other elements.
@element dropdown

@param on_selection_changed fired when the selected value is changed

@tparam ?string|Concepts.LocalisedString|function default the option which is selected by default, or a function which returns the default
@tparam boolean use_list_box when true a list box will be used rather than a dropdown menu
@tparam ?nil|table static_items when called with a table the values will be added as items for the dropdown, if called with nil then all items are cleared
@tparam function dynamic_items the given function will be called to return a list of items and optional start index to add items to the dropdown when it is first drawn

    @usage-- Making a basic dropdown
local static_dropdown =
Gui.new_concept('dropdown')
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_changed(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Static dropdown is now: '..value)
end)

@usage-- Making a dropdown with dynamic items, example is name of online players
local dynamic_dropdown =
Gui.new_concept('dropdown')
:set_dynamic_items(function(element)
    local items = {}
    for _,player in pairs(game.connected_players) do
        items[#items+1] = player.name
    end
    return items
end)
:on_selection_changed(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Dynamic dropdown is now: '..value)
end)

]]

Gui.new_concept()
:save_as('dropdown')

-- Events
:new_event('on_selection_changed',defines.events.on_gui_selection_state_changed)

-- Properties
:new_property('default')
:new_property('use_list_box',nil,false)
:new_property('static_items',function(properties,value,start_index)
    -- Clear all items if value is nil
    if not value then
        properties.items = {}
    end

    -- Convert value to a table
    if type(value) ~= 'table' then
        value = {value}
    end

    -- If there are no items then set and return
    local items = properties.items
    if not items then
        properties.items = value
        return
    end

    -- Otherwise insert into the array
    array_insert(items,start_index,value)
end)
:new_property('dynamic_items',function(properties,value)
    -- Check that a function value was given
    if type(value) ~= 'function' then
        error('Dynamic items must be a function')
    end

    -- If no dynamic items then set and return
    local items = properties.dynamic_items
    if not items then
        properties.dynamic_items = {value}
        return
    end

    -- Otherwise append to the end
    items[#items+1] = value
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a dropdown
    element = parent.add{
        name = properties.name,
        type = properties.use_list_box and 'list-box' or 'drop-down',
        items = properties.items
    }

    -- If there are dynamic items then add them
    if properties.dynamic_items then
        for _,callback in pairs(properties.dynamic_items) do
            local dynamic_items, start_index = callback(element)
            Gui.add_dropdown_items(element,start_index,dynamic_items)
        end
    end

    -- If there is a default, select it
    local default = Gui.resolve_property(properties.default,element)
    if default then
        Gui.set_dropdown_value(element,default)
    end

    return element
end)

--- Dropdowns.
-- functions used with dropdowns
-- @section dropdowns

--[[-- Selects the index of a dropdown with this value
@tparam LuaGuiElement element the dropdown that you want to set the selection for
@tparam ?string|Concepts.LocalisedString value the value that you want selected
@treturn boolean if an item with this value was found
@usage-- Selecting the item with the value 'foo'
Gui.set_dropdown_value(element,'foo')
]]
function Gui.set_dropdown_value(element,value)
    for index, item in pairs(element.items) do
        if item == value then
            element.selected_index = index
            return true
        end
    end
    return false
end

--[[-- Gets the selected item value of a dropdown
@tparam LuaGuiElement element the dropdown that you want the selected value of
@treturn ?string|Concepts.LocalisedString the value that is currently selected
@usage-- Getting the selected value
local selected_value = Gui.get_dropdown_value(element)
]]
function Gui.get_dropdown_value(element)
    return element.items[element.selected_index]
end

--[[-- Adds the given items into the list of items for this dropdown
@tparam LuaGuiElement element the dropdown that you want to add the items to
@tparam[opt] number start_index the index at which the items will be added, if not given appened to the end
@tparam table new_items the list of new items that you want to add
@treturn table the list of items that the element now has
@usage-- Add the items 'foo' and 'bar' to the end
Gui.add_dropdown_items(element,{'foo','bar'})
@usage-- Add the items 'foo' and 'bar' to the start
Gui.add_dropdown_items(element,1,{'foo','bar'})
]]
function Gui.add_dropdown_items(element,start_index,new_items)
    if not new_items then
        new_items = start_index
        start_index = nil
    end

    local items = element.items
    element.items = array_insert(items,start_index,new_items)

    return items
end