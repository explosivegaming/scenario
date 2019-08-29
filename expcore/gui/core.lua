--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

--- Core.
-- Functions that act as a landing point for the other funtions
-- @section core

local Game = require 'utils.game' -- @dep utils.game
local Prototype = require 'expcore.gui.prototype'

local Gui = {
    concepts = {}
}

--[[-- Loads a concept from the concepts file, used internally
@tparam string concept the name of the concept to require
@usage-- Load a base concept
Gui.require_concept('frame')
]]
function Gui.require_concept(concept)
    require('expcore.gui.concepts.'..concept)
end

--[[-- Gets the gui concept with this name
@tparam string name the name of the concept that you want to get
@usage-- Getting a gui concept
local button = Gui.get_concept('Button')
]]
function Gui.get_concept(name)
    return Gui.concepts[name] or error('Gui concept "'..name..'" is not defind',2)
end

--[[-- Used internally to save concept names to the core gui module
@function Prototype:change_name
@tparam[opt=self.name] string new_name the new name of the concept
@usage-- Internal Saving
-- this is never needed to be done, internal use only!
local button = Gui.get_concept('Button')
button:change_name('Not Button')
]]
function Prototype:change_name(new_name)
    if new_name then
        Gui.concepts[self.name] = nil
        self.name = new_name
        self.properties.name = new_name
    end

    Gui.concepts[self.name] = self
    return self
end

--[[-- Returns a new gui concept with no properties or events
@tparam string name the name that you want this concept to have
@usage-- Making a new concept, see module usage
local button = Gui.new_concept('Button')
]]
function Gui.new_concept(name)
    if Gui.concepts[name] then
        error('Gui concept "'..name..'" is already defind',2)
    end

    return Prototype:clone(name)
end

--[[-- Making anew concept based on the properties and drawing of another
@tparam string name the name of the concept that you want as the base
@tparam string new_name the name that you want the new concept to have
@usage-- Making a new concept from another, see module usage
local custom_button = Gui.clone_concept('Button','CustomButton')
]]
function Gui.clone_concept(name,new_name)
    local concept = Gui.concepts[name] or error('Gui concept "'..name..'" is not defind',2)

    if Gui.concepts[new_name] then
        error('Gui concept "'..new_name..'" is already defind',2)
    end

    return concept:clone(new_name)
end

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