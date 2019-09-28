--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' -- @dep expcore.gui

Gui.require_concept 'label' -- @dep gui.concept.frame

local right_align =
Gui.new_concept('alignment')

--[[-- A label triplet which has a static label, a data label which can be changed, and a unit label
@see Gui.label
@see data_label
@element unit_label
@usage-- Concept Structure
-- Root
--> [unit_label] - the static label
--> [properties.data_name] - the data label which can be updated
--> [properties.data_name..'_unit'] - the data label unit which can be updated
Gui.new_concept('unit_label')
:set_data_label_name('game_ticks')
:set_data_caption('0')
:set_data_unit('ticks')
:set_data_format(function(concept,element,data,...)
    -- This is used with update_data_element and update_from_parent
    local caption = tostirng(data)
    local unit = data > 1 and 'ticks' or 'tick'
    local tooltip = 'This game has beeing running for: '..caption..' ticks'
    return caption, unit, tooltip
end)
]]

local unit_label =
Gui.new_concept('data_label')
:save_as('unit_label')
:new_property('data_label_name')
:new_property('data_caption')
:new_property('data_tooltip')
:new_property('data_unit')
:new_property('data_format',nil,function(concept,element,data,...)
    local base_unit = concept.properties.data_unit
    local caption = tostring(data)
    local unit = data == 1 and base_unit or base_unit..'s'
    return caption, unit
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Get the unit data
    local unit = Gui.resolve_property(properties.data_unit,element)

    -- Add the unit label
    parent.add{
        name = element.name..'_unit',
        caption = unit or '',
        tooltip = element.tooltip
    }

    return element
end)

--[[-- Updates the caption and tooltip and unit of the data label using the data format function
@tparam LuaGuiElement element the unit label element that you want to update
@tparam any data the data that you want to pass to the format function
@usage-- Updating the data to the current game tick
unit_label:update_data_element(element,game.tick)
]]
function unit_label:update_data_element(element,data,...)
    local caption, unit, tooltip = self.properties.data_format(self,element,data,...)
    local unit_element = element.parent.parent[element.name..'_unit']
    if caption then
        element.caption = caption
    end
    if tooltip then
        element.tooltip = tooltip
        unit_element.tooltip = tooltip
    end
    if unit then
        unit_element.caption = unit
    end
end

--[[-- Updates the caption and tooltip and unit of the unit label using the data format function, given the parent of the unit label
@tparam LuaGuiElement parent the parent element to the unit label element that you want to update
@tparam any data the data that you want to pass to the format function
@usage-- Updating the data to the current game tick
unit_label:update_from_parent(parent,game.tick)
]]
function unit_label:update_from_parent(parent,data,...)
    local properties = self.properties
    local data_name = properties.data_label_name or properties.name..'_data'
    local element = parent[data_name] and parent[data_name].data_label or error('Data label is not a child of this element element',2)
    local unit_element = parent[data_name..'_unit']

    local caption, unit, tooltip = properties.data_format(self,element,data,...)
    if caption then
        element.caption = caption
    end
    if tooltip then
        element.tooltip = tooltip
        unit_element.tooltip = tooltip
    end
    if unit then
        unit_element.caption = unit
    end
end