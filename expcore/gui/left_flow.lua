--[[-- Core Module - Gui
- Used to define new gui elements and gui event handlers
@module Gui
]]

local Gui = require 'expcore.gui.prototype'
local mod_gui = require 'mod-gui' --- @dep mod-gui

local hide_left_flow = Gui.core_defines.hide_left_flow.name

--- Left Flow.
-- @section leftFlow

--- Contains the uids of the elements that will show on the left flow and the open on join function
-- @table left_elements
Gui.left_elements = {}

--[[-- Gets the flow which contains the elements for the left flow
@function Gui.get_left_flow(player)
@tparam LuaPlayer player the player that you want to get the flow for
@treturn LuaGuiElement the left element flow

@usage-- Geting your left element flow
local left_flow = Gui.get_left_flow(game.player)

]]
Gui.get_left_flow = mod_gui.get_frame_flow

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

--[[-- Button which can be used to toggle a left element, placed on the top flow
@tparam string sprite the sprite that you want to use on the button
@tparam ?string|Concepts.LocalizedString tooltip the tooltip that you want the button to have
@tparam table element_define the element define that you want to be toggled on the left flow
@tparam[opt] function authenticator used to decide if the button should be visible to a player

@usage-- Add a button to toggle a left element
local toolbar_button = Gui.left_toolbar_button('entity/inserter','Nothing to see here',example_flow_with_button,function(player)
    return player.admin
end)

]]
function Gui.left_toolbar_button(sprite,tooltip,element_define,authenticator)
    local button = Gui.element{
        type = 'sprite-button',
        sprite = sprite,
        tooltip = tooltip,
        style = Gui.top_flow_button_style
    }
    :style{
        padding = -2
    }
    :add_to_top_flow(authenticator)

    -- Add on_click handler to handle click events comming from the player
    button:on_click(function(player,_,_)
        local top_flow = Gui.get_top_flow(player)
        local element = top_flow[button.name]
        local visibility_state  = Gui.toggle_left_element(player, element_define)

        -- Raise custom event that tells listening elements if the element has changed visibility by a player clicking
        -- Used in warp gui to handle the keep open logic
        button:raise_custom_event{
            name = Gui.events.on_visibility_changed_by_click,
            element = element,
            state = visibility_state
        }
    end)

    -- Add property to the left flow element with the name of the button
    -- This is for the ability to reverse lookup the button from the left flow element
    element_define.toolbar_button = button.name
    return button
end

--[[-- Draw all the left elements onto the left flow, internal use only
@tparam LuaPlayer player the player that you want to draw the elements for

@usage Draw all the left elements
Gui.draw_left_flow(player)

]]
function Gui.draw_left_flow(player)
    local left_flow = Gui.get_left_flow(player)
    local hide_button = left_flow.gui_core_buttons[hide_left_flow]
    local show_hide_button = false

    for name, open_on_join in pairs(Gui.left_elements) do
        -- Draw the element to the left flow
        local left_element = Gui.defines[name](left_flow)

        -- Check if it should be open by default
        local visible = type(open_on_join) == 'boolean' and open_on_join or false
        if type(open_on_join) == 'function' then
            local success, err = pcall(open_on_join, player)
            if not success then
                error('There as been an error with an open on join hander for a gui element:\n\t'..err)
            end
            visible = err
        end

        -- Set the visible state of the element
        left_element.visible = visible
        show_hide_button = show_hide_button or visible
    end

    hide_button.visible = show_hide_button
end

--[[-- Update the visible state of the hide left button, also draw left elements if not present
@tparam LuaPlayer player the player to update the left flow for
@treturn boolean true if any left element is visible

@usage Check if any left elements are visible
local visible = Gui.update_left_flow(player)

]]
function Gui.update_left_flow(player)
    local left_flow = Gui.get_left_flow(player)
    local hide_button = left_flow.gui_core_buttons[hide_left_flow]
    for name, _ in pairs(Gui.left_elements) do
        local left_element = left_flow[name]
        if left_element.visible then
            hide_button.visible = true
            return true
        end
    end
    return false
end

--[[-- Hides all left elements for a player
@tparam LuaPlayer player the player to hide the elements for

@usage-- Hide your left elements
Gui.hide_left_flow(game.player)

]]
function Gui.hide_left_flow(player)
    local left_flow = Gui.get_left_flow(player)
    local hide_button = left_flow.gui_core_buttons[hide_left_flow]

    -- Set the visible state of all elements in the flow
    hide_button.visible = false
    for name,_ in pairs(Gui.left_elements) do
        left_flow[name].visible = false

        -- Get the assosiated element define
        local element_define = Gui.defines[name]
        local top_flow = Gui.get_top_flow(player)

        -- Check if the the element has a button attached
        if element_define.toolbar_button then
            -- Check if the topflow contains the button
            local button = top_flow[element_define.toolbar_button]
            if button then
                -- Get the button define from the reverse lookup on the element
                local button_define = Gui.defines[element_define.toolbar_button]
                -- Raise the custom event if all of the top checks have passed
                button_define:raise_custom_event{
                    name = Gui.events.on_visibility_changed_by_click,
                    element = button,
                    state = false
                }
            end
        end
    end
end

--[[-- Get the element define that is in the left flow
@tparam LuaPlayer player the player that you want tog et the element for
@tparam table element_define the element that you want to get for the player
@treturn LuaGuiElement the gui element linked to this define in the left flow

@usage-- Get your left element
local frame = Gui.get_left_element(game.player,example_flow_with_button)

]]
function Gui.get_left_element(player,element_define)
    local left_flow = Gui.get_left_flow(player)
    return left_flow[element_define.name]
end

--[[-- Toggles the visible state of a left element for a player
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

    -- Set the visible state
    local element = left_flow[element_define.name]
    if state == nil then state = not element.visible end
    element.visible = state
    Gui.update_left_flow(player)

    return state
end