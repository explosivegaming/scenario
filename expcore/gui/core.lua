--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Game = require 'utils.game' -- @dep utils.game
local resolve_value = ext_require('expcore.common','resolve_value') -- @dep expcore.common
local Prototype = require 'expcore.gui.prototype'

local Gui = {
    concepts = {}
}

--- Concept Control.
-- Functions that act as a landing point for the other funtions
-- @section concept-control

--[[-- Loads a concept from the concepts file
@tparam string concept_name the name of the concept to require
@usage-- Load a base concept
Gui.require_concept('frame') --- @dep Gui.concept.frame
]]
function Gui.require_concept(concept_name)
    require('expcore.gui.concepts.'..concept_name)
end

--[[-- Loads a set of concepts from the styles file
@tparam string style_name the name of the style to require
@usage-- Load a base style
Gui.require_concept('expgaming') --- @dep Gui.style.frame
]]
function Gui.require_style(style_name)
    require('expcore.gui.styles.'..style_name..'.index')
end

--[[-- Gets a gui concept from name, id, or its self
@tparam ?string|number|table name the name, id, or the concept you want to get
@usage-- Getting a gui concept
local button = Gui.get_concept('Button')
]]
function Gui.get_concept(name)
    if not name then return end
    local vtype = type(name)

    if vtype == 'string' then
        return Gui.concepts[name]

    elseif vtype == 'table' then
        if name.draw_callbacks then
            return name
        end

    elseif vtype == 'number' then
        for _,concept in pairs(Gui.concepts) do
            if concept.name == name then
                return concept
            end
        end

    end

end

--[[-- Used to save the concept to the main gui module to allow access from other files
@function Prototype:save_as
@tparam string save_name the new name of the concept
@usage-- Save a concept to allow access in another file
button:save_as('button')
@usage-- Access concept after being saved
Gui.concepts.button
Gui.get_concept('button')
]]
function Prototype:save_as(save_name)
    Gui.concepts[save_name] = self
    return self
end

--[[-- Returns a new gui concept, option to provide a base concept to copy properties and draw functions from
@tparam[opt] ?string|number|table base_concept the concept that you want to copy the details of
@usage-- Making a new button, see module usage
local button = Gui.new_concept('Button')
]]
function Gui.new_concept(base_concept)
    if base_concept then
        base_concept = Gui.get_concept(base_concept) or error('Invalid gui concept "'..tostring(base_concept)..'"',2)
        return base_concept:clone()
    else
        return Prototype:clone()
    end
end

--[[-- Used to draw a concept to a parent element
@tparam ?string|number|table concept the name of the concept that you want to draw
@tparam LuaGuiElement parent the element that will act as a parent for the new element
@treturn LuaGuiElement the element that was created
@usage-- Drawing a new element
Gui.draw_concept('Button',element)
]]
function Gui.draw_concept(concept,parent,...)
    concept = Gui.get_concept(concept) or error('Invalid gui concept "'..tostring(concept)..'"',2)
    return concept:draw(parent,...)
end

--- Element Control.
-- Functions that aim to making working with gui elements easier
-- @section element-control

--[[-- Gets the player who owns this element
@tparam LuaGuiElement element the element that you want to get the player of
@treturn LuaPlayer the player who owns this element
@usage-- Getting the player of an element
local player = Gui.get_player_from_element(element)
]]
function Gui.get_player_from_element(element)
    return Game.get_player_by_index(element.player_index)
end

--[[-- Simple check for if an element is valid
@tparam LuaGuiElement element the element that you want to check is valid
@treturn boolean true if the element is valid
@usage-- Return if not valid
if not Gui.valid(element) then return end
]]
function Gui.valid(element)
    return element and element.valid or false
end

--[[-- Destroies and element if it is valid
@tparam LuaGuiElement element the element that you want to destroy
@treturn boolean true if the element was valid and was destoried
@usage-- Destoring an element
Gui.destroy(element)
]]
function Gui.destroy(element)
    if element and element.valid then
        element.destroy()
        return true
    end
    return false
end

--[[-- Finds and returns a gui element if it is valid from a long chain of element names or concepts
@tparam LuaGuiElement element the root element to start checking from
@tparam ?string|table ... element names or element concepts that point to your element
@treturn[1] boolean if the element was found, failed
@treturn[1] string the path of the element that the search stoped at
@treturn[2] boolean if the element was found, found
@treturn[2] LuaGuiElement the element that was found
@usage-- Getting the center gui
local exists, center = Gui.exists(player,'gui','center')
]]
function Gui.exists(element,...)
    local path = tostring(element.name)
    for _,next_element_name in pairs{...} do
        if type(next_element_name) == 'table' then
            next_element_name = next_element_name.name
        end

        element = element[next_element_name]
        path = path..'.'..tostring(next_element_name)
        if not Gui.valid(element) then
            return false, path
        end
    end
    return true, element
end

--[[-- Checks if a gui element exists or not, if not found will throw an error
@see Gui.exists
@tparam LuaGuiElement element the root element to start checking from
@tparam ?string|table ... element names or element concepts that point to your element
@treturn LuaGuiElement the element that was found
@usage-- Getting the center gui
local exists, center = Gui.find(player,'gui','center')
]]
function Gui.find(element,...)
    local exists, element = Gui.exists(element,...)
    if not exists then
        return error('Could not find element: '..element,2)
    else
        return element
    end
end

--[[-- Toggles the enabled state of an element
@tparam LuaGuiElement element the element that you want to toggle the enabled state of
@treturn boolean the new enabled state of the element
@usage-- Toggle the enabled state of an element
Gui.toggle_enabled(element)
]]
function Gui.toggle_enabled(element)
    if not element or not element.valid then return end
    if not element.enabled then
        element.enabled = true
        return true
    else
        element.enabled = false
        return false
    end
end

--[[-- Toggles the visible state of an element
@tparam LuaGuiElement element the element that you want to toggle the visible state of
@treturn boolean the new visible state of the element
@usage-- Toggle the visible state of an element
Gui.toggle_visible(element)
]]
function Gui.toggle_visible(element)
    if not element or not element.valid then return end
    if not element.visible then
        element.visible = true
        return true
    else
        element.visible = false
        return false
    end
end

--[[-- Sets the padding for a gui element
@tparam LuaGuiElement element the element to set the padding for
@tparam[opt=0] ?number|boolean up the amount of padding on the top, true leaves unchanged
@tparam[opt=0] ?number|boolean down the amount of padding on the bottom, true leaves unchanged
@tparam[opt=0] ?number|boolean left the amount of padding on the left, true leaves unchanged
@tparam[opt=0] ?number|boolean right the amount of padding on the right, true leaves unchanged
@usage-- Remove all padding of an element
Gui.set_padding(element)
@usage-- Remove side padding but keep vertical padding
Gui.set_padding(element,true,true)
@usage-- Remove all padding but set right to 2
Gui.set_padding(element,false,false,false,2)
]]
function Gui.set_padding(element,up,down,left,right)
    local style = element.style
    style.top_padding = up == true and style.top_padding or up or 0
    style.bottom_padding = down == true and style.top_padding or down or 0
    style.left_padding = left == true and style.top_padding or left or 0
    style.right_padding = right == true and style.top_padding or right or 0
end

--[[ Used to check a property exists and if it is a function then call the function
@function Gui.resolve_property
@tparam any value the value that you are testing exists and call if its a function
@tparam LuaGuiElement element the element that is passed to the function if it is a function
@treturn any the value or what it returns if it is a function
@usage-- Getting the default value
local default = Gui.resolve_property(properties.default,element)
if default then
    element.value = default
end
]]
Gui.resolve_property = resolve_value

--- Store Categories.
-- Functions that are common types of categories
-- @section store-categories

--[[-- A categorize function to be used with add_store, each player has their own category
@tparam LuaGuiElement element the element that will be converted to a string
@treturn string the player's name who owns this element
@usage-- Storing data on a per player basis, can be used with instances
Gui.get_concept('CustomButton')
:define_data_store(Gui.categorize_by_player)
]]
function Gui.categorize_by_player(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.name
end

--[[-- A categorize function to be used with add_store, each force has its own category
@tparam LuaGuiElement element the element that will be converted to a string
@treturn string the player's force name who owns this element
@usage-- Storing data on a per force basis, can be used with instances
Gui.get_concept('CustomButton')
:define_data_store(Gui.categorize_by_force)
]]
function Gui.categorize_by_force(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.force.name
end

--[[-- A categorize function to be used with add_store, each surface has its own category
@tparam LuaGuiElement element the element that will be converted to a string
@treturn string the player's surface name who owns this element
@usage-- Storing data on a per surface basis, can be used with instances
Gui.get_concept('CustomButton')
:define_data_store(Gui.categorize_by_surface)
]]
function Gui.categorize_by_surface(element)
    local player = Game.get_player_by_index(element.player_index)
    return player.surface.name
end

return Gui