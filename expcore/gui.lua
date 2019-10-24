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
local mod_gui = require 'mod-gui' --- @dep mod-gui

local Gui = {
    --- The current highest uid that is being used, will not increase during runtime
    -- @field uid
    uid = 0,
    --- Contains the uids of the elements that will show on the top flow and the auth function
    -- @table top_elements
    top_elements = {},
    --- Contains the uids of the elements that will show on the left flow and the open on join function
    -- @table left_elements
    left_elements = {},
    --- Table of all the elements which have been registed with the draw function and event handlers
    -- @table defines
    defines = {},
    --- An index used for debuging to find the file where different elements where registered
    -- @table file_paths
    file_paths = {},
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

    -- Add the defination function
    if type(element_define) == 'table' then
        element_define.name = name
        element._draw = function(_,parent)
            return parent.add(element_define)
        end
    else
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
        self._style = function(style)
            for key,value in pairs(style_define) do
                style[key] = value
            end
        end
    else
        self._style = style_define
    end

    -- Return the element so event handers can be accessed
    return self
end

--[[-- Adds an element to be drawn to the top flow when a player joins
@tparam[opt] function authenticator called during toggle or update to decide if the element should be visible
@treturn table the new element define that is used to register events to this element

@usage-- Adding the example button
example_button:add_to_top_flow(function(player)
    -- example button will only show when game time is less than 1 minute
    return player.online_time < 3600
end)

]]
function Gui._prototype_element:add_to_top_flow(authenticator)
    Gui.top_elements[self.name] = authenticator or true
    return self
end

--[[-- Adds an element to be drawn to the left flow when a player joins
@tparam[opt] ?boolean|function open_on_join called during first darw to decide if the element is visible
@treturn table the new element define that is used to register events to this element

@usage-- Adding the example button
example_flow_with_button:add_to_left_flow(true)

]]
function Gui._prototype_element:add_to_left_flow(open_on_join)
    Gui.left_elements[self.name] = open_on_join or false
    return self
end

-- This function is called for event event
local function general_event_handler(event)
    -- Check the element is valid
    local element = event.element
    if not element or not element.valid then
        return
    end

    -- Get the event handler for this element
    local handlers = Gui.defines[element.name]
    local handler = handlers and handlers[event.name]
    if not handler then
        return
    end

    -- Get the player for this event
    local player = game.players[event.player_index]
    if not player or not player.valid then
        return
    end
    event.player = player

    local success, err = pcall(handler,player,element,event)
    if not success then
        error('There as been an error with an event handler for a gui element:\n\t'..err)
    end
end

-- This function returns the event handler adder and registeres the general handler
local function event_handler_factory(event_name)
    Event.add(event_name, general_event_handler)

    return function(self,handler)
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
Gui._prototype_element.on_text_change = event_handler_factory(defines.events.on_gui_text_changed)

--- Called when LuaGuiElement slider value is changed (related to the slider element).
-- @tparam function handler the event handler which will be called
Gui._prototype_element.on_value_changed = event_handler_factory(defines.events.on_gui_value_changed)

--- Top Flow.
-- @section topFlow

--- Button which toggles the top flow elements
-- @element toggle_top_flow
local toggle_top_flow =
Gui.element{
    type = 'button',
    style = 'back_button',
    tooltip = {'gui_util.button_tooltip'}
}
:style{
    width = 18,
    height = 36
}
:on_click(function(player,_,_)
    Gui.toggle_top_flow(player)
end)

--- The style that should be used for buttons on the top flow
-- @field Gui.top_flow_button_style
Gui.top_flow_button_style = mod_gui.button_style

--[[-- Gets the flow which contains the elements for the top flow
@function Gui.get_top_flow(player)
@tparam LuaPlayer player the player that you want to get the flow for
@treturn LuaGuiElement the top element flow

@usage-- Geting your top element flow
local top_flow = Gui.get_top_flow(game.player)

]]
Gui.get_top_flow = mod_gui.get_button_flow

--[[-- Updates the visible states of all the elements on a players top flow
@tparam LuaPlayer player the player that you want to update the flow for

@usage-- Update your flow
Gui.update_top_flow(game.player)

]]
function Gui.update_top_flow(player)
    local top_flow = Gui.get_top_flow(player)
    local toggle_button = top_flow[toggle_top_flow.name]
    local is_visible = toggle_button.style.name == 'back_button'

    -- Set the visible state of all elements in the flow
    for name,authenticator in pairs(Gui.top_elements) do
        -- Ensure the element exists
        local element = top_flow[name]
        if not element then
            element = Gui.defines[name](top_flow)
        end

        -- Set the visible state
        element.visible = is_visible and authenticator(player) or false
    end
end

--[[-- Toggles the visible states of all the elements on a players top flow
@tparam LuaPlayer player the player that you want to toggle the flow for
@tparam[opt] boolean state if given then the state will be set to this state
@treturn boolean the new visible state of the top flow

@usage-- Toggle your flow
Gui.toggle_top_flow(game.player)

@usage-- Open your top flow
Gui.toggle_top_flow(game.player,true)

]]
function Gui.toggle_top_flow(player,state)
    local top_flow = Gui.get_top_flow(player)
    local toggle_button = top_flow[toggle_top_flow.name]
    if state == nil then state = toggle_button.style.name == 'forward_button' end

    -- Set the visible state of all elements in the flow
    for name,authenticator in pairs(Gui.top_elements) do
        top_flow[name].visible = state and authenticator(player) or false
    end

    -- Change the style of the toggle button
    if state then
        toggle_button.style = 'back_button'
        local style = toggle_button.style
        style.height = 36
        style.width = 18
    else
        toggle_button.style = 'forward_button'
        local style = toggle_button.style
        style.height = 20
        style.width = 18
    end

    return state
end

--- Left Flow.
-- @section leftFlow

--- Button which hides the elements in the left flow
-- @element hide_left_flow
local hide_left_flow =
Gui.element{
    type = 'button',
    style = 'back_button',
    tooltip = {'expcore-gui.left-button-tooltip'}
}
:style{
    width = 18,
    height = 36
}
:on_click(function(player,_,_)
    Gui.hide_left_flow(player)
end)

--[[-- Gets the flow which contains the elements for the left flow
@function Gui.get_left_flow(player)
@tparam LuaPlayer player the player that you want to get the flow for
@treturn LuaGuiElement the left element flow

@usage-- Geting your left element flow
local left_flow = Gui.get_left_flow(game.player)

]]
Gui.get_left_flow = mod_gui.get_frame_flow

--[[-- Hides all left elements for a player
@tparam LuaPlayer player the player to hide the elements for

@usage-- Hide your left elements
Gui.hide_left_flow(game.player)

]]
function Gui.hide_left_flow(player)
    local left_flow = Gui.get_left_flow(player)
    local hide_button = left_flow[hide_left_flow.name]

    -- Set the visible state of all elements in the flow
    hide_button.visible = false
    for name,_ in pairs(Gui.left_elements) do
        left_flow[name].visible = false
    end
end

--[[-- Toggles the visible state of all a left element for a player
@tparam LuaPlayer player the player that you want to toggle the element for
@tparam table element_define the element that you want to toggle for the player
@tparam[opt] boolean state if given then the state will be set to this state
@treturn boolean the new visible state of the element

@usage-- Toggle your example button
Gui.toggle_top_flow(game.player,example_flow_with_button)

@usage-- Open your example button
Gui.toggle_top_flow(game.player,example_flow_with_button,true)

]]
function Gui.toggle_left_element(player,element_define,state)
    local left_flow = Gui.get_left_flow(player)
    local hide_button = left_flow[hide_left_flow.name]

    -- Set the visible state
    local element = left_flow[element_define.name]
    if state == nil then state = not element.visible end
    element.visible = state

    -- Check if the hide button should be visible
    local show_hide_button = false
    for name,_ in pairs(Gui.left_elements) do
        if left_flow[name].visible then
            show_hide_button = true
            break
        end
    end
    hide_button.visible = show_hide_button

    return state
end

-- Draw the two flows when a player joins
Event.add(defines.events.on_player_created,function(event)
    local player = game.players[event.player_index]

    -- Draw the top flow
    local top_flow = Gui.get_top_flow(player)
    toggle_top_flow(top_flow)
    Gui.update_top_flow(player)

    -- Draw the left flow
    local left_flow = Gui.get_left_flow(player)
    local hide_left = hide_left_flow(left_flow)

    -- Draw the elements on the left flow
    local show_hide_left = false
    for name,open_on_join in pairs(Gui.left_elements) do
        local left_element = Gui.defines[name](left_flow)

        -- Check if the element should be visible
        local visible = type(open_on_join) == 'boolean' and open_on_join or false
        if type(open_on_join) == 'function' then
            local success, err = pcall(open_on_join,player)
            if not success then
                error('There as been an error with an open on join hander for a gui element:\n\t'..err)
            end
            visible = err
        end

        left_element.visible = visible
        if visible then
            show_hide_left = true
        end
    end

    hide_left.visible = show_hide_left
end)

--- Helper Functions.
-- @section helperFunctions

--[[-- Get the player that owns a gui element
@tparam LuaGuiElement element the element that you want to get the owner of
@treturn LuaPlayer the player that owns this element

@usage-- Geting the owner of an element
local player = Gui.get_player_from_element(element)

]]
function Gui.get_player_from_element(element)
    if not element or not element.valid then return end
    return game.players[element.player_index]
end

--[[-- Will toggle the enabled state of an element or set it to the one given
@tparam LuaGuiElement element the element that you want to toggle the state of
@tparam[opt] boolean state the state that you want to set
@treturn boolean the new enabled state that the element has

@usage-- Toggling the the enabled state
local new_enabled_state = Gui.toggle_enabled_state(element)

]]
function Gui.toggle_enabled_state(element,state)
    if not element or not element.valid then return end
    if state == nil then state = not element.enabled end
    element.enabled = state
    return state
end

--[[-- Will toggle the visible state of an element or set it to the one given
@tparam LuaGuiElement element the element that you want to toggle the state of
@tparam[opt] boolean state the state that you want to set
@treturn boolean the new visible state that the element has

@usage-- Toggling the the visible state
local new_visible_state = Gui.toggle_visible_state(element)

]]
function Gui.toggle_visible_state(element,state)
    if not element or not element.valid then return end
    if state == nil then state = not element.visible end
    element.visible = state
    return state
end

--[[-- Destory a gui element without causing any errors, likly if the element may have already been removed
@tparam LuaGuiElement element the element that you want to remove
@treturn boolean true if the element was valid and has been removed

@usage-- Likely use case for element not existing
Gui.destroy_if_valid(element[child_name])

]]
function Gui.destroy_if_valid(element)
    if not element or not element.valid then return false end
    element.destroy()
    return true
end

--[[-- Draw a flow that has custom element alignments, default is right align
@tparam LuaGuiElement parent the parent element that the alignment flow will be added to
@tparam[opt='right'] string horizontal_align the horizontal alignment of the elements in the flow
@tparam[opt='center'] string vertical_align the vertical alignment of the elements in the flow
@tparam[opt='alignment'] string name the name of the alignment flow
@treturn LuaGuiElement the alignment flow that was created

@usage-- Adding a right align flow
local alignment = Gui.alignment(element,'example_right_alignment')

@usage-- Adding a horizontal center and top align flow
local alignment = Gui.alignment(element,'example_center_top_alignment','center','top')

]]
function Gui.alignment(parent,horizontal_align,vertical_align,name)
    -- Draw the alignment flow
    local alignment =
    parent.add{
        name = name or 'alignment',
        type = 'flow',
    }

    -- Change its style
    local style = alignment.style
    style.padding = {1,2}
    style.vertical_align = vertical_align or 'center'
    style.horizontal_align = horizontal_align or 'right'
    style.vertically_stretchable  = style.vertical_align ~= 'center'
    style.horizontally_stretchable = style.horizontal_align ~= 'center'

    -- Return the flow
    return alignment
end

--[[-- Draw a scroll pane that has a table inside of it
@tparam LuaGuiElement parent the parent element that the scroll table will be added to
@tparam number height the maximum height for the scroll pane
@tparam number column_count the number of columns that the table will have
@tparam[opt='scroll'] string name the name of the scroll pane that is added, the table is always called 'table'
@treturn LuaGuiElement the table that was created

@usage-- Adding a scroll table with max height of 200 and column count of 3
local scroll_table = Gui.scroll_table(element,'example_scroll_table',200,3)

]]
function Gui.scroll_table(parent,height,column_count,name)
    -- Draw the scroll
    local scroll =
    parent.add{
        name = name or 'scroll',
        type = 'scroll-pane',
        direction = 'vertical',
        horizontal_scroll_policy = 'never',
        vertical_scroll_policy = 'auto',
        style = 'scroll_pane_under_subheader'
    }

    -- Change the style of the scroll
    local scroll_style = scroll.style
    scroll_style.padding = {1,3}
    scroll_style.maximal_height = height
    scroll_style.horizontally_stretchable = true

    -- Draw the table
    local scroll_table =
    scroll.add{
        type = 'table',
        name = 'table',
        column_count = column_count
    }

    -- Change the style of the table
    local table_style = scroll_table.style
    table_style.padding = 0
    table_style.cell_padding = 0
    table_style.vertical_align = 'center'
    table_style.horizontally_stretchable = true

    -- Return the scroll table
    return scroll_table
end

--[[-- Used to add a header to a frame, this has the option for a custom right alignment flow for buttons
@tparam LuaGuiElement parent the parent element that the header will be added to
@tparam ?string|Concepts.LocalizedString caption the caption that will be shown on the header
@tparam[opt] ?string|Concepts.LocalizedString tooltip the tooltip that will be shown on the header
@tparam[opt=false] boolean add_alignment when true an alignment flow will be added for buttons
@tparam[opt='header'] string name the name of the header that is being added, the alignment is always called 'alignment'
@treturn LuaGuiElement either the header or the header alignment if add_alignment is true

@usage-- Adding a custom header
local header_alignment = Gui.header(
    element,
    'example_header',
    'Example Caption',
    'Example Tooltip',
    true
)

]]
function Gui.header(parent,caption,tooltip,add_alignment,name)
    -- Draw the header
    local header =
    parent.add{
        name = name or 'header',
        type = 'frame',
        style = 'subheader_frame'
    }

    -- Change the style of the header
    local style = header.style
    style.padding = {2,4}
    style.use_header_filler = false
    style.horizontally_stretchable = true

    -- Draw the caption label
    header.add{
        name = 'header_label',
        type = 'label',
        style = 'heading_1_label',
        caption = caption,
        tooltip = tooltip
    }

    -- Return either the header or the added alignment
    return add_alignment and Gui.alignment(header) or header
end

-- Module return
return Gui