--[[-- Core Module - PlayerData
- A module used to store player data in a central datastore to minimize data requests and saves.
@core PlayerData

@usage-- Adding a colour setting for players
local PlayerData = require 'expcore.player_data'
local PlayerColors = PlayerData.Settings:combine('Color')

-- Set the players color when their data is loaded
PlayerColors:on_load(function(player_name, color)
    local player = game.players[player_name]
    player.color = color
end)

-- Overwrite the saved color with the players current color
PlayerColors:on_save(function(player_name, _)
    local player = game.players[player_name]
    return player.color -- overwrite existing data with the current color
end)

@usage-- Add a playtime statistic for players
local Event = require 'utils.event'
local PlayerData = require 'expcore.player_data'
local Playtime = PlayerData.Statistics:combine('Playtime')

-- When playtime reaches an hour interval tell the player and say thanks
Playtime:on_update(function(player_name, playtime)
    if playtime % 60 == 0 then
        local hours = playtime / 60
        local player = game.players[player_name]
        player.print('Thanks for playing on our servers, you have played for '..hours..' hours!')
    end
end)

-- Update playtime for players, data is only loaded for online players so update_all can be used
Event.add_on_nth_tick(3600, function()
    Playtime:update_all(function(player_name, playtime)
        return playtime + 1
    end)
end)

]]

local Event = require 'utils.event' --- @dep utils.event
local Async = require 'expcore.async' --- @dep expcore.async
local Datastore = require 'expcore.datastore' --- @dep expcore.datastore
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse' --- @dep config.expcore.command_general_parse

--- Stores all the players whos data failed to load
local FailedLoad = {}
global.failed_player_data = FailedLoad
Event.on_load(function()
    FailedLoad = global.failed_player_data
end)

--- Common player data that acts as the root store for player data
local PlayerData = Datastore.connect('PlayerData', true) -- saveToDisk
PlayerData:set_serializer(Datastore.name_serializer) -- use player name

--- Store and enum for the data saving preference
local DataSavingPreference = PlayerData:combine('DataSavingPreference')
local PreferenceEnum = { 'All', 'Statistics', 'Settings', 'Required' }
for k,v in ipairs(PreferenceEnum) do PreferenceEnum[v] = k end
DataSavingPreference:set_default('All')

--- Sets your data saving preference
-- @command set-data-preference
Commands.new_command('set-preference', 'Allows you to set your data saving preference')
:add_param('option', false, 'string-options', PreferenceEnum)
:register(function(player, option)
    DataSavingPreference:set(player, option)
    return {'expcore-data.set-preference', option}
end)

--- Gets your data saving preference
-- @command data-preference
Commands.new_command('preference', 'Shows you what your current data saving preference is')
:register(function(player)
    return {'expcore-data.get-preference', DataSavingPreference:get(player)}
end)

--- Gets your data and writes it to a file
Commands.new_command('save-data', 'Writes all your player data to a file on your computer')
:register(function(player)
    player.print{'expcore-data.get-data'}
    game.write_file('expgaming_player_data.json', game.table_to_json(PlayerData:get(player, {})), false, player.index)
end)

--- Async function called after 10 seconds with no player data loaded
local check_data_loaded = Async.register(function(player)
    local player_data = PlayerData:get(player)
    if not player_data then
        FailedLoad[player.name] = true
        player.print{'expcore-data.data-failed'}
        Datastore.ingest('request', 'PlayerData', player.name, '{"failed_load":true}')
    end
end)

--- When player data loads tell the player if the load had failed previously
PlayerData:on_load(function(player_name, player_data)
    if not player_data or player_data.failed_load then return end
    if FailedLoad[player_name] then
        FailedLoad[player_name] = nil
        game.players[player_name].print{'expcore-data.data-restore'}
    end
end)

--- Remove data that the player doesnt want to have stored
PlayerData:on_save(function(player_name, player_data)
    local dataPreference = DataSavingPreference:get(player_name)
    dataPreference = PreferenceEnum[dataPreference]
    if dataPreference == PreferenceEnum.All then return player_data end

    local saved_player_data = { PlayerRequired = player_data.PlayerRequired, DataSavingPreference = PreferenceEnum[dataPreference] }
    if dataPreference <= PreferenceEnum.Settings then saved_player_data.PlayerSettings = player_data.PlayerSettings end
    if dataPreference <= PreferenceEnum.Statistics then saved_player_data.PlayerStatistics = player_data.PlayerStatistics end

    return saved_player_data
end)

--- Display your data preference when your data loads
DataSavingPreference:on_load(function(player_name, dataPreference)
    game.players[player_name].print{'expcore-data.get-preference', dataPreference or DataSavingPreference.default}
end)

--- Load player data when they join
Event.add(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    PlayerData:request(player)
    Async.wait(600, check_data_loaded, player)
end)

--- Unload player data when they leave
Event.add(defines.events.on_player_left_game, function(event)
    local player = game.players[event.player_index]
    local player_data = PlayerData:get(player)
    if player_data.failed_load then
        FailedLoad[player.name] = nil
        PlayerData:raw_set(player)
    else PlayerData:unload(player) end
end)

----- Module Return -----
return {
    All = PlayerData, -- Root for all of a players data
    Statistics = PlayerData:combine('Statistics'), -- Common place for stats
    Settings = PlayerData:combine('Settings'), -- Common place for settings
    Required = PlayerData:combine('Required'), -- Common place for required data
    DataSavingPreference = DataSavingPreference, -- Stores what data groups will be saved
    PreferenceEnum = PreferenceEnum -- Enum for the allowed options for data saving preference
}