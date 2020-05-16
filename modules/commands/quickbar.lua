--[[-- Commands Module - Quickbar
    - Adds a command that allows players to load Quickbar presets
    @commands LoadQuickbar
    @commands SaveQuickbar
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Game = require 'utils.game' --- @dep utils.game
local config = require 'config.preset_player_quickbar' --- @dep config.preset_player_quickbar


--- Loads your quickbar preset
-- @command load-quickbar
Commands.new_command('load-quickbar','Loads your preset Quickbar items')
:register(function(player)
    if config[player.name] then
        local custom_quickbar = config[player.name]
        for i, item_name in pairs(custom_quickbar) do
          if item_name ~= nil and item_name ~= '' then
            player.set_quick_bar_slot(i, item_name)
          end
        end
    else
        Commands.error('Quickbar preset not found')
    end
end)

--- Saves your quickbar preset to the script-output folder
-- @command save-quickbar
Commands.new_command('save-quickbar','Saves your Quickbar preset items to file')
:register(function(player)
    local quickbar_names = {}
    for i=1, 100 do
        local slot = player.get_quick_bar_slot(i)
        if slot ~= nil then
            table.insert(quickbar_names, slot.name)
        else
            table.insert(quickbar_names, "")
        end
    end
    game.write_file("quickbar_preset.txt", game.table_to_json(quickbar_names), false)
    Commands.print("Quickbar saved to local script-output folder")
end)
