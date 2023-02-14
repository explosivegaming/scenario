local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.vlayer' --- @dep config.gui.player_list_actions
local Colors = require 'utils.color_presets' --- @dep utils.color_presets

--[[
344,000
369,000

Power Production:
Peak: 344 k x 60 kW
Average sustained: 344 x 60 kW x 291 / 416

Battery Storage:
369k x 5.0 MJ = ....

Net Power Production:
- 5,000 MW 
]]

local vlayer_container

Gui.left_toolbar_button(
    "item/solar-panel",
    {"vlayer.main-tooltip"},
    vlayer_container,
    function(player)
        return Roles.player_allowed(player, "gui/vlayer")
    end
)

Event.on_nth_tick(60, function()
    end
end)