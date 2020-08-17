--[[-- Gui Module - Autofill
    - Adds a button to enable Autofill
    @gui Autofill
    @alias autofill
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Global = require 'utils.global' --- @dep utils.global
local config = require 'config.gui.autofill' --- @dep config.gui.autofill

--- Table that stores if autofill is enabled or not
local autofill_enabled = {}
Global.register(autofill_enabled, function(tbl)
    autofill_enabled = tbl
end)

--- Button on the top flow used to toggle autofill
local toolbar_autofill_toggle
toolbar_autofill_toggle = Gui.toolbar_button(config.icon, {'autofill.main-tooltip'})
:on_click(function(player)
    local top_flow = Gui.get_top_flow(player)
    local element = top_flow[toolbar_autofill_toggle.name]
    if not autofill_enabled[player.name] then
        autofill_enabled[player.name] = true
        player.print("true")
    else
        autofill_enabled[player.name] = false
        player.print("false")
    end
    Gui.toolbar_button_style(element, autofill_enabled[player.name])
end)