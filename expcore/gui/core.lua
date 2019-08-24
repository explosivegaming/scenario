--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

--- Core.
-- Functions that act as a landing point for the other funtions
-- @section core

local Event = require 'utils.event' -- @dep utils.event
local Prototype = require 'expcore.gui.prototype'

local Gui = {
    concepts = {}
}

function Gui.new_concept(name)
    if Gui.concepts[name] then
        error('Gui concept "'..name..'" is already defind',2)
    end

    local concept = Prototype:clone(name)
    Gui.concepts[name] = concept

    return concept
end

function Gui.get_concept(name)
    return Gui.concepts[name] or error('Gui concept "'..name..'" is not defind',2)
end

function Gui.clone_concept(name,new_name)
    local concept = Gui.concepts[name] or error('Gui concept "'..name..'" is not defind',2)

    if Gui.concepts[name] then
        error('Gui concept "'..name..'" is already defind',2)
    end

    local new_concept = concept:clone(new_name)
    Gui.concepts[new_name] = new_concept

    return new_concept
end

return Gui