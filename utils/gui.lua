local Global = require 'utils.global' --- @dep utils.global
local ExpGui = require 'expcore.gui' --- @dep expcore.gui

local Gui = {}
local data = {}

Global.register(
    data,
    function(tbl)
        data = tbl
    end
)

function Gui.uid_name()
    local new_element = ExpGui.element()
    return new_element.name
end

-- Associates data with the LuaGuiElement. If data is nil then removes the data
function Gui.set_data(element, value)
    data[element.player_index * 0x100000000 + element.index] = value
end

-- Gets the Associated data with this LuaGuiElement if any.
function Gui.get_data(element)
    return data[element.player_index * 0x100000000 + element.index]
end

-- Removes data associated with LuaGuiElement and its children recursively.
function Gui.remove_data_recursively(element)
    Gui.set_data(element, nil)

    local children = element.children

    if not children then
        return
    end

    for _, child in ipairs(children) do
        if child.valid then
            Gui.remove_data_recursively(child)
        end
    end
end

function Gui.remove_children_data(element)
    local children = element.children

    if not children then
        return
    end

    for _, child in ipairs(children) do
        if child.valid then
            Gui.set_data(child, nil)
            Gui.remove_children_data(child)
        end
    end
end

function Gui.destroy(element)
    Gui.remove_data_recursively(element)
    element.destroy()
end

function Gui.clear(element)
    Gui.remove_children_data(element)
    element.clear()
end

local function handler_factory(event_name)
    return function(element_name, handler)
        local element = ExpGui.defines[element_name]
        if not element then return end
        element[event_name](element, function(_, _,event)
            handler(event)
        end)
    end
end

-- Register a handler for the on_gui_checked_state_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_checked_state_changed = handler_factory('on_checked_changed')

-- Register a handler for the on_gui_click event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_click = handler_factory('on_click')

-- Register a handler for the on_gui_closed event for a custom LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_custom_close = handler_factory('on_closed')

-- Register a handler for the on_gui_elem_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_elem_changed = handler_factory('on_elem_changed')

-- Register a handler for the on_gui_selection_state_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_selection_state_changed = handler_factory('on_selection_changed')

-- Register a handler for the on_gui_text_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_text_changed = handler_factory('on_text_changed')

-- Register a handler for the on_gui_value_changed event for LuaGuiElements with element_name.
-- Can only have one handler per element name.
-- Guarantees that the element and the player are valid when calling the handler.
-- Adds a player field to the event table.
Gui.on_value_changed = handler_factory('on_value_changed')

--- Returns the flow where top elements can be added and will be effected by google visibility
-- For the toggle to work it must be registed with Gui.allow_player_to_toggle_top_element_visibility(element_name)
-- @tparam LuaPlayer player pointer to the player who has the gui
-- @treturn LuaGuiElement the top element flow
Gui.get_top_element_flow = ExpGui.get_top_flow

return Gui