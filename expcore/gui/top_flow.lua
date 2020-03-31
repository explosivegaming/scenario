--[[-- Core Module - Gui
- Controls the elements on the top flow
@module Gui
]]

local Gui = require 'expcore.gui.prototype'
local mod_gui = require 'mod-gui' --- @dep mod-gui

local hide_top_flow = Gui.core_defines.hide_top_flow.name
local show_top_flow = Gui.core_defines.show_top_flow.name

--- Top Flow.
-- @section topFlow

--- Contains the uids of the elements that will shown on the top flow and their auth functions
-- @table top_elements
Gui.top_elements = {}

--- The style that should be used for buttons on the top flow
-- @field Gui.top_flow_button_style
Gui.top_flow_button_style = mod_gui.button_style

--- The style that should be used for buttons on the top flow when their flow is visible
-- @field Gui.top_flow_button_visible_style
Gui.top_flow_button_visible_style = 'menu_button_continue'

--[[-- Gets the flow refered to as the top flow, each player has one top flow
@function Gui.get_top_flow(player)
@tparam LuaPlayer player the player that you want to get the flow for
@treturn LuaGuiElement the top element flow

@usage-- Geting your top flow
local top_flow = Gui.get_top_flow(game.player)

]]
Gui.get_top_flow = mod_gui.get_button_flow

--[[-- Sets an element define to be drawn to the top flow when a player joins, includes optional authenticator
@tparam[opt] function authenticator called during toggle or update to decide weather the element should be visible
@treturn table the new element define to allow event handlers to be registered

@usage-- Adding an element to the top flow on join
example_button:add_to_top_flow(function(player)
    -- example button will only be shown if the player is an admin
    -- note button will not update its state when player.admin is changed Gui.update_top_flow must be called for this
    return player.admin
end)

]]
function Gui._prototype_element:add_to_top_flow(authenticator)
    Gui.top_elements[self.name] = authenticator or true
    return self
end

--[[-- Updates the visible state of all the elements on the players top flow, uses authenticator
@tparam LuaPlayer player the player that you want to update the top flow for

@usage-- Update your top flow
Gui.update_top_flow(game.player)

]]
function Gui.update_top_flow(player)
    local top_flow = Gui.get_top_flow(player)
    local hide_button = top_flow[hide_top_flow]
    local is_visible = hide_button.visible

    -- Set the visible state of all elements in the flow
    for name, authenticator in pairs(Gui.top_elements) do
        -- Ensure the element exists
        local element = top_flow[name]
        if not element then
            element = Gui.defines[name](top_flow)
        end

        -- Set the visible state
        element.visible = is_visible and authenticator(player) or false
    end
end

--[[-- Toggles the visible state of all the elements on a players top flow, effects all elements
@tparam LuaPlayer player the player that you want to toggle the top flow for
@tparam[opt] boolean state if given then the state will be set to this
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

--[[-- Get the element define that is in the top flow, use in events without an element refrence
@tparam LuaPlayer player the player that you want to get the element for
@tparam table element_define the element that you want to get
@treturn LuaGuiElement the gui element linked to this define for this player

@usage-- Get your top element
local button = Gui.get_top_element(game.player, example_button)

]]
function Gui.get_top_element(player, element_define)
    local top_flow = Gui.get_top_flow(player)
    return top_flow[element_define.name]
end

--[[-- Creates a button on the top flow with consistent styling
@tparam string sprite the sprite that you want to use on the button
@tparam ?string|Concepts.LocalizedString tooltip the tooltip that you want the button to have
@tparam[opt] function authenticator used to decide if the button should be visible to a player

@usage-- Add a button to the toolbar
local toolbar_button =
Gui.left_toolbar_button('entity/inserter', 'Nothing to see here', function(player)
    return player.admin
end)

]]
function Gui.toolbar_button(sprite,tooltip,authenticator)
    return Gui.element{
        type = 'sprite-button',
        sprite = sprite,
        tooltip = tooltip,
        style = Gui.top_flow_button_style
    }
    :style{
        minimal_width = 36,
        height = 36,
        padding = -2
    }
    :add_to_top_flow(authenticator)
end

--[[-- Styles a top flow button depending on the state given
@tparam LuaGuiElement button the button element to style
@tparam boolean state The state the button is in

@usage-- Sets the button to the visible style
Gui.toolbar_button_style(button, true)

@usage-- Sets the button to the hidden style
Gui.toolbar_button_style(button, false)

]]
function Gui.toolbar_button_style(button, state)
    if state then
        button.style = Gui.top_flow_button_visible_style
    else
        button.style = Gui.top_flow_button_style
    end
    button.style.minimal_width = 36
    button.style.height = 36
    button.style.padding = -2
end