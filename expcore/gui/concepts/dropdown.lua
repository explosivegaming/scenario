--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'
local array_insert = ext_require('expcore.common','array_insert')

--[[-- The basic dropdown element
@element dropdown
@param on_selection_change fired when the selected value is changed
@tparam ?string|Conepts.LocalisedString default_selection the option which is selected by default
@tparam boolean use_list_box when true a list box will be used rather than a dropdown menu
@tparam ?nil|table static_items when called with a table the values will be added as items for the dropdown, if called with nil then all items are cleared
@tparam function dynamic_items the given function will be called to return a list of items and optional start index to add items to the dropdown when it is first drawn
@usage-- Making a basic dropdown
local static_dropdown =
Gui.clone_concept('dropdown','static_dropdown')
:set_static_items{'Option 1','Option 2','Option 3'}
:on_selection_change(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Static dropdown is now: '..value)
end)
@usage-- Making a dropdown with dynamic items, example is name of online players
local dynamic_dropdown =
Gui.clone_concept('dropdown','dynamic_dropdown')
:set_dynamic_items(function(element)
    local items = {}

    for _,player in pairs(game.connected_players) do
        items[#items+1] = player.name
    end

    return items
end)
:on_selection_change(function(event)
    local value = Gui.get_dropdown_value(event.element)
    event.player.print('Dynamic dropdown is now: '..value)
end)
]]
Gui.new_concept('dropdown')
:new_event('on_selection_change',defines.events.on_gui_selection_state_changed)
:new_property('default_selection')
:new_property('use_list_box',false)
:new_property('static_items',nil,function(properties,value,start_index)
    if not value then
        properties.items = {}
    end

    if type(value) ~= 'table' then
        value = {value}
    end

    local items = properties.items
    if not items then
        properties.items = value
        return
    end

    array_insert(items,start_index,value)
end)
:new_property('dynamic_items',nil,function(properties,value)
    if type(value) ~= 'function' then
        error('Dynamic items must be a function')
    end

    local items = properties.dynamic_items
    if not items then
        properties.dynamic_items = {value}
        return
    end

    items[#items+1] = value
end)
:define_draw(function(properties,parent,element,new_items)
    local items = new_items or {}
    array_insert(items,1,properties.items or {})

    element = parent.add{
        name = properties.name,
        type = properties.use_list_box and 'list-box' or 'drop-down',
        items = items
    }

    if properties.dynamic_items then
        for _,callback in pairs(properties.dynamic_items) do
            local dynamic_items, start_index = callback(element)
            Gui.add_dropdown_items(element,start_index,dynamic_items)
        end
    end

    if properties.default_selection then
        local default = properties.default_selection
        if type(default) == 'function' then
            default = default(element)
        end

        Gui.set_dropdown_value(element,default)
    end

    return element
end)

--- Dropdowns.
-- functions used with dropdowns
-- @section dropdowns

--[[-- Selects the index of a dropdown with this value
@tparam LuaGuiElement element the dropdown that you want to set the selection for
@tparam ?string|Conepts.LocalisedString value the value that you want selected
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
@treturn ?string|Conepts.LocalisedString the value that is currently selected
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