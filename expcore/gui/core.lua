--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

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

return Gui