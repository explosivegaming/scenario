--[[-- Core Module - Gui
- Used to define new gui elements and gui event handlers
@core Gui
@alias Gui

@usage-- Defining a button that prints the player's name
local example_button =
Gui.element{
    type = 'button',
    caption = 'Example Button'
}
:on_click(function(player,element,event)
    player.print(player.name)
end)

@usage-- Defining a button with a custom style
local example_button =
Gui.element{
    type = 'button',
    caption = 'Example Button'
}
:style{
    height = 25,
    width = 100
}
:on_click(function(player,element,event)
    player.print(player.name)
end)

@usage-- Defining a button using a custom function
local example_flow_with_button =
Gui.element(function(event_trigger,parent)
    -- Add the flow the button is in
    local flow =
    parent.add{
        name = 'example_flow',
        type = 'flow'
    }

    -- Get the players name
    local player = game.players[parent.player_index]
    local player_name = player.name

    -- Add the button
    local element =
    flow.add{
        name = event_trigger,
        type = 'button',
        caption = 'Example Button: '..player_name
    }

    -- Set the style of the button
    local style = element.style
    style.height = 25
    style.width = 100]
    style.font_color = player.color

    -- Return the element
    return element
end)
:on_click(function(player,element,event)
    player.print(player.name)
end)

@usage-- Drawing an element
local exmple_button_element = example_button(parent)
local example_flow_with_button = example_flow_with_button(parent)

]]

local Event = require 'utils.event' --- @dep utils.event

local Gui = {
    --- The current highest uid that is being used, will not increase during runtime
    -- @field uid
    uid = 0,
    --- An index of the element deinfes which are used by the core gui system
    -- @table core_defines
    core_defines = {},
    --- Table of all the elements which have been registed with the draw function and event handlers
    -- @table defines
    defines = {},
    --- Table of all custom events that are used by element defines, used to avoid conflicts
    -- @table events
    events = {},
    --- An index used for debuging to find the file where different elements where registered
    -- @table file_paths
    file_paths = {},
    --- An index used for debuging to show more data on element defines
    -- @table debug_info
    debug_info = {},
    --- The element prototype which is returned from Gui.element
    -- @table _prototype_element
    _prototype_element = {},
    --- The prototype metatable applied to new element defines
    -- @table _mt_element
    _mt_element = {
        __call = function(self,parent,...)
            local element = self._draw(self.name,parent,...)
            if self._style then self._style(element.style,element,...) end
            return element
        end
    }
}

Gui._mt_element.__index = Gui._prototype_element

--- Element Define.
-- @section elementDefine

--[[-- Base function used to define new elements, can be used with a table or with a function
@tparam ?table|function element_define used to define how the element is draw, using a table is the simplist way of doing this
@treturn table the new element define that is used to register events to this element

@usage-- Defining an element with a table
local example_button =
Gui.element{
    type = 'button',
    caption = 'Example Button'
}

@usage-- Defining an element with a function
local example_flow_with_button =
Gui.element(function(event_trigger,parent,...)
    -- Add the flow the button is in
    local flow =
    parent.add{
        name = 'example_flow',
        type = 'flow'
    }

    -- Add the button
    local element =
    flow.add{
        name = event_trigger,
        type = 'button',
        caption = 'Example Button'
    }

    -- Set the style of the button
    local style = element.style
    style.height = 25
    style.width = 100

    -- Return the element
    return element
end)

]]
function Gui.element(element_define)
    -- Set the metatable to allow access to register events
    local element = setmetatable({}, Gui._mt_element)

    -- Increment the uid counter
    local uid = Gui.uid + 1
    Gui.uid = uid
    local name = tostring(uid)
    element.name = name
    Gui.debug_info[name] = { draw = 'None', style = 'None', events = {} }

    -- Add the defination function
    if type(element_define) == 'table' then
        Gui.debug_info[name].draw = element_define
        element_define.name = name
        element._draw = function(_,parent)
            return parent.add(element_define)
        end
    else
        Gui.debug_info[name].draw = 'Function'
        element._draw = element_define
    end

    -- Add the define to the base module
    local file_path = debug.getinfo(2, 'S').source:match('^.+/currently%-playing/(.+)$'):sub(1, -5)
    Gui.file_paths[name] = file_path
    Gui.defines[name] = element

    -- Return the element so event handers can be accessed
    return element
end

--[[-- Extension of Gui.element when using the table method, values applied after the element is drawn
@tparam ?table|function style_define used to define how the style is applied, using a table is the simplist way of doing this
@treturn table the new element define that is used to register events to this element

@usage-- Setting the height and width of the example button
local example_button =
Gui.element{
    type = 'button',
    caption = 'Example Button'
}
:style{
    height = 25,
    width = 100
}

@usage-- Using a function to set the style
local example_button =
Gui.element{
    type = 'button',
    caption = 'Example Button'
}
:style(function(style,element,...)
    local player = game.players[element.player_index]
    style.height = 25
    style.width = 100
    style.font_color = player.color
end)

]]
function Gui._prototype_element:style(style_define)
    -- Add the defination function
    if type(style_define) == 'table' then
        Gui.debug_info[self.name].style = style_define
        self._style = function(style)
            for key,value in pairs(style_define) do
                style[key] = value
            end
        end
    else
        Gui.debug_info[self.name].style = 'Function'
        self._style = style_define
    end

    -- Return the element so event handers can be accessed
    return self
end

--[[-- Set the handler to be called on a custom event, only one handler can be used
@tparam string event_name the name of the event you want to handler to be called on
@tparam function handler the handler that you want to be called when the event is raised
@treturn table the element define so more handleres can be registered

@usage Print the player name when my_custom_event is raised
element_deinfe:on_custom_event('my_custom_event', function(event)
    event.player.print(player.name)
end)

]]
function Gui._prototype_element:on_custom_event(event_name,handler)
    table.insert(Gui.debug_info[self.name].events,event_name)
    Gui.events[event_name] = event_name
    self[event_name] = handler
    return self
end

--[[-- Raise the handler which is attached to any event; external use should be limited to custom events
@tparam table event the event table bassed to the handler, must include fields: name, element
@treturn table the element define so more events can be raised

@usage Raising a custom event
element_define:raise_custom_event{
    name = 'my_custom_event',
    element = element
}

]]
function Gui._prototype_element:raise_custom_event(event)
    -- Check the element is valid
    local element = event.element
    if not element or not element.valid then
        return self
    end

    -- Get the event handler for this element
    local handler = self[event.name]
    if not handler then
        return self
    end

    -- Get the player for this event
    local player_index = event.player_index or element.player_index
    local player = game.players[player_index]
    if not player or not player.valid then
        return self
    end
    event.player = player

    local success, err = pcall(handler,player,element,event)
    if not success then
        error('There as been an error with an event handler for a gui element:\n\t'..err)
    end
    return self
end

-- This function is used to register a link between element define events and the events in the factorio api
local function event_handler_factory(event_name)
    Event.add(event_name, function(event)
        local element = event.element
        if not element or not element.valid then return end
        local element_define = Gui.defines[element.name]
        element_define:raise_custom_event(event)
    end)

    return function(self,handler)
        table.insert(Gui.debug_info[self.name].events,debug.getinfo(1, "n").name)
        self[event_name] = handler
        return self
    end
end

--- Element Events.
-- @section elementEvents

--- Called when the player opens a GUI.
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_opened = event_handler_factory(defines.events.on_gui_opened)

--- Called when the player closes the GUI they have open.
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_closed = event_handler_factory(defines.events.on_gui_closed)

--- Called when LuaGuiElement is clicked.
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_click = event_handler_factory(defines.events.on_gui_click)

--- Called when a LuaGuiElement is confirmed, for example by pressing Enter in a textfield.
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_confirmed = event_handler_factory(defines.events.on_gui_confirmed)

--- Called when LuaGuiElement checked state is changed (related to checkboxes and radio buttons).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_checked_changed = event_handler_factory(defines.events.on_gui_checked_state_changed)

--- Called when LuaGuiElement element value is changed (related to choose element buttons).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_elem_changed = event_handler_factory(defines.events.on_gui_elem_changed)

--- Called when LuaGuiElement element location is changed (related to frames in player.gui.screen).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_location_changed = event_handler_factory(defines.events.on_gui_location_changed)

--- Called when LuaGuiElement selected tab is changed (related to tabbed-panes).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_tab_changed = event_handler_factory(defines.events.on_gui_selected_tab_changed)

--- Called when LuaGuiElement selection state is changed (related to drop-downs and listboxes).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_selection_changed = event_handler_factory(defines.events.on_gui_selection_state_changed)

--- Called when LuaGuiElement switch state is changed (related to switches).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_switch_changed = event_handler_factory(defines.events.on_gui_switch_state_changed)

--- Called when LuaGuiElement text is changed by the player.
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_text_changed = event_handler_factory(defines.events.on_gui_text_changed)

--- Called when LuaGuiElement slider value is changed (related to the slider element).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_value_changed = event_handler_factory(defines.events.on_gui_value_changed)

-- Module return
return Gui