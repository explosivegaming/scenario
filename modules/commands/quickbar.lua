--[[-- Commands Module - Quickbar
    - Adds a command that allows players to load Quickbar presets
    @commands LoadQuickbar
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Game = require 'utils.game' --- @dep utils.game
local config = require 'config.preset_player_quickbar' --- @dep config.preset_player_quickbar
require 'config.expcore.command_general_parse'


--- Loads your quickbar preset
-- @command load-quickbar
Commands.new_command('load-quickbar','Loads your preset Quickbar items')
:register(function(player)
    if config[player.name] then
        local custom_quickbar = config[player.name]
        for i, item_name in ipairs(custom_quickbar) do
          player.set_quick_bar_slot(i, item_name)
        end
    else
        Commands.error('Quickbar preset not found')
    end
end)
