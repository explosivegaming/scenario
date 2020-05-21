
local Event = require 'utils.event' --- @dep utils.event
local Datastore = require 'expcore.datastore' --- @dep expcore.datastore
local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse' --- @dep config.expcore.command_general_parse

--- Common player data that acts as the root store for player data
local PlayerData = Datastore.connect('PlayerData', true) -- saveToDisk
PlayerData:set_serializer(Datastore.name_serializer) -- use player name

--- Store and enum for the data collection policy
local DataCollectionPolicy = PlayerData:combine('DataCollectionPolicy')
local PolicyEnum = { 'All', 'Tracking', 'Settings', 'Required' }
for k,v in ipairs(PolicyEnum) do PolicyEnum[v] = k end

--- Sets your data collection policy
-- @command set-data-policy
Commands.new_command('set-data-policy', 'Allows you to set your data collection policy')
:add_param('option', false, 'string-options', PolicyEnum)
:register(function(player, option)
    DataCollectionPolicy:set(player, option)
    return {'expcore-data.set-policy', option}
end)

--- Gets your data collection policy
-- @command data-policy
Commands.new_command('data-policy', 'Shows you what your current data collection policy is')
:register(function(player)
    return {'expcore-data.get-policy', DataCollectionPolicy:get(player, 'All')}
end)

--- Remove data that the player doesnt want to have stored
PlayerData:on_save(function(player_name, player_data)
    local collectData = DataCollectionPolicy:get(player_name, 'All')
    collectData = PolicyEnum[collectData]
    if collectData == PolicyEnum.All then return player_data end

    local saved_player_data = { PlayerRequired = player_data.PlayerRequired, DataCollectionPolicy = PolicyEnum[collectData] }
    if collectData <= PolicyEnum.Settings then saved_player_data.PlayerSettings = player_data.PlayerSettings end
    if collectData <= PolicyEnum.Tracking then saved_player_data.PlayerTracking = player_data.PlayerTracking end

    return saved_player_data
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
    Tracking = PlayerData:combine('PlayerTracking'), -- Common place for tracing stats
    Settings = PlayerData:combine('PlayerSettings'), -- Common place for settings
    Required = PlayerData:combine('PlayerRequired'), -- Common place for required data
    DataCollectionPolicy = DataCollectionPolicy, -- Stores what data groups will be saved
    PolicyEnum = PolicyEnum -- Enum for the allowed options for the data collection policy
}