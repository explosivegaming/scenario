
local Event = require 'utils.event' --- @dep utils.event
local Datastore = require 'expcore.datastore' --- @dep expcore.datastore
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse' --- @dep config.expcore.command_general_parse

--- Common player data that acts as the root store for player data
local PlayerData = Datastore.connect('PlayerData', true) -- saveToDisk
PlayerData:set_serializer(Datastore.name_serializer) -- use player name

--- Store and enum for the data saving preference
local DataSavingPreference = PlayerData:combine('DataSavingPreference')
local PreferenceEnum = { 'All', 'Statistics', 'Settings', 'Required' }
for k,v in ipairs(PreferenceEnum) do PreferenceEnum[v] = k end

--- Sets your data saving preference
-- @command set-data-preference
Commands.new_command('set-data-preference', 'Allows you to set your data saving preference')
:add_param('option', false, 'string-options', PreferenceEnum)
:register(function(player, option)
    DataSavingPreference:set(player, option)
    return {'expcore-data.set-preference', option}
end)

--- Gets your data saving preference
-- @command data-preference
Commands.new_command('data-preference', 'Shows you what your current data saving preference is')
:register(function(player)
    return {'expcore-data.get-preference', DataSavingPreference:get(player, 'All')}
end)

--- Remove data that the player doesnt want to have stored
PlayerData:on_save(function(player_name, player_data)
    local dataPreference = DataSavingPreference:get(player_name, 'All')
    dataPreference = PreferenceEnum[dataPreference]
    if dataPreference == PreferenceEnum.All then return player_data end

    local saved_player_data = { PlayerRequired = player_data.PlayerRequired, DataSavingPreference = PreferenceEnum[dataPreference] }
    if dataPreference <= PreferenceEnum.Settings then saved_player_data.PlayerSettings = player_data.PlayerSettings end
    if dataPreference <= PreferenceEnum.Statistics then saved_player_data.PlayerStatistics = player_data.PlayerStatistics end

    return saved_player_data
end)

--- Display your data preference when your data loads
DataSavingPreference:on_load(function(player_name, dataPreference)
    game.players[player_name].print{'expcore-data.get-preference', dataPreference or 'All'}
end)

--- Load player data when they join
Event.add(defines.events.on_player_joined_game, function(event)
    PlayerData:request(game.players[event.player_index])
end)

--- Unload player data when they leave
Event.add(defines.events.on_player_left_game, function(event)
    PlayerData:unload(game.players[event.player_index])
end)

----- Module Return -----
return {
    All = PlayerData, -- Root for all of a players data
    Statistics = PlayerData:combine('PlayerStatistics'), -- Common place for stats
    Settings = PlayerData:combine('PlayerSettings'), -- Common place for settings
    Required = PlayerData:combine('PlayerRequired'), -- Common place for required data
    DataSavingPreference = DataSavingPreference, -- Stores what data groups will be saved
    PreferenceEnum = PreferenceEnum -- Enum for the allowed options for data saving preference
}