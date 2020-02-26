--[[-- Core Module - Gui
- Used to define new gui elements and gui event handlers
@module Gui
]]

local Gui = require 'expcore.gui.prototype'
local mod_gui = require 'mod-gui' --- @dep mod-gui

local hide_top_flow = Gui.core_defines.hide_top_flow.name
local show_top_flow = Gui.core_defines.show_top_flow.name

--- Top Flow.
-- @section topFlow

--- Contains the uids of the elements that will show on the top flow and the auth function
-- @table top_elements
Gui.top_elements = {}

--- The style that should be used for buttons on the top flow
-- @field Gui.top_flow_button_style
Gui.top_flow_button_style = mod_gui.button_style

--- The style that should be used for buttons on the top flow where the flow it opens is visible
-- @field Gui.top_flow_button_visible_style
Gui.top_flow_button_visible_style = 'menu_button_continue'

--[[-- Gets the flow which contains the elements for the top flow
@function Gui.get_top_flow(player)
@tparam LuaPlayer player the player that you want to get the flow for
@treturn LuaGuiElement the top element flow

@usage-- Geting your top element flow
local top_flow = Gui.get_top_flow(game.player)

]]
Gui.get_top_flow = mod_gui.get_button_flow

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

--[[-- Updates the visible states of all the elements on a players top flow
@tparam LuaPlayer player the player that you want to update the flow for

@usage-- Update your flow
Gui.update_top_flow(game.player)

]]
function Gui.update_top_flow(player)
    local top_flow = Gui.get_top_flow(player)
    local hide_button = top_flow[hide_top_flow]
    local is_visible = hide_button.visible

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
    -- Get the top flow and hide button
    local top_flow = Gui.get_top_flow(player)
    if state == nil then state = not top_flow.visible end

    -- Change the visiblty of the flow
    local left_flow = Gui.get_left_flow(player)
    local show_button = left_flow.gui_core_buttons[show_top_flow]
    show_button.visible = not state
    top_flow.visible = state

    return state
end