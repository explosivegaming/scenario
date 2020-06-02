--[[-- Commands Module - Quickbar
    - Adds a command that allows players to load Quickbar presets
    @data Quickbar
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.preset_player_quickbar' --- @dep config.preset_player_quickbar

--- Stores the quickbar filters for a player
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerFilters = PlayerData.Settings:combine('QuickbarFilters')
PlayerFilters:set_metadata{
    permission = 'command/save-quickbar',
    stringify = function(value)
        if not value then return 'No filters set' end
        local count = 0
        for _ in pairs(value) do count = count + 1 end
        return count..' filters set'
    end
}

--- Loads your quickbar preset
PlayerFilters:on_load(function(player_name, filters)
    if not filters then filters = config[player_name] end
    if not filters then return end
    local player = game.players[player_name]
    for i, item_name in pairs(filters) do
        if item_name ~= nil and item_name ~= '' then
            player.set_quick_bar_slot(i, item_name)
        end
    end
end)

--- Saves your quickbar preset to the script-output folder
-- @command save-quickbar
Commands.new_command('save-quickbar', 'Saves your Quickbar preset items to file')
:add_alias('save-toolbar')
:register(function(player)
    local filters = {}
    for i = 1, 100 do
        local slot = player.get_quick_bar_slot(i)
        if slot ~= nil then
            filters[i] = slot.name
        end
    end

    if next(filters) then
        PlayerFilters:set(player, filters)
    else
        PlayerFilters:remove(player)
    end

    return {'quickbar.saved'}
end)