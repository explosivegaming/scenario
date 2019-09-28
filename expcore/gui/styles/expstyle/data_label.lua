--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' -- @dep expcore.gui

Gui.require_concept 'label' -- @dep gui.concept.frame

local right_align =
Gui.new_concept('alignment')

--[[-- A label pair which has a static label and a data label which can be changed
@see Gui.label
@element data_label
@usage-- Concept Structure
-- Root
--> [data_label] - the static label
--> [properties.data_name] - the data label which can be updated
Gui.new_concept('data_label')
:set_data_label_name('game_ticks')
:set_data_caption('0')
:set_data_format(function(concept,element,data,...)
    -- This is used with update_data_element and update_from_parent
    local caption = tostirng('data')
    local tooltip = 'This game has beeing running for: '..caption..' ticks'
    return caption, tooltip
end)
]]

local data_label =
Gui.new_concept('label')
:save_as('data_label')
:new_property('data_label_name')
:new_property('data_caption')
:new_property('data_tooltip')
:new_property('data_format',nil,function(concept,element,data,...)
    return tostring(data)
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Make the label right aligned
    local data_name = properties.data_label_name or properties.name..'_data'
    local right_align_element = right_align:draw(parent,data_name)

    -- Add a new label
    local data_label_element =
    right_align_element.add{
        name = 'data_label'
    }

    -- Get the data caption
    local caption = Gui.resolve_property(properties.data_caption,element)
    if caption then
        data_label_element.caption = caption
    end

    -- Get the data tooltip
    local tooltip = Gui.resolve_property(properties.data_tooltip,element)
    if tooltip then
        data_label_element.tooltip = tooltip
    end

    return data_label_element
end)

--[[-- Updates the caption and tooltip of the data label using the data format function
@tparam LuaGuiElement element the data label element that you want to update
@tparam any data the data that you want to pass to the format function
@usage-- Updating the data to the current game tick
data_label:update_data_element(element,game.tick)
]]
function data_label:update_data_element(element,data,...)
    local caption, tooltip = self.properties.data_format(self,element,data,...)
    if caption then
        element.caption = caption
    end
    if tooltip then
        element.tooltip = tooltip
    end
end

--[[-- Updates the caption and tooltip of the data label using the data format function, given the parent of the data label
@tparam LuaGuiElement parent the parent element to the data label element that you want to update
@tparam any data the data that you want to pass to the format function
@usage-- Updating the data to the current game tick
data_label:update_from_parent(parent,game.tick)
]]
function data_label:update_from_parent(parent,data,...)
    local properties = self.properties
    local data_name = properties.data_label_name or properties.name..'_data'
    local element = parent[data_name] and parent[data_name].data_label or error('Data label is not a child of this element element',2)

    local caption, tooltip = properties.data_format(self,element,data,...)
    if caption then
        element.caption = caption
    end
    if tooltip then
        element.tooltip = tooltip
    end
end