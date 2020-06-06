--[[-- Commands Module - Tag
    - Adds a command that allows players to have a custom tag after their name
    @data Tag
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
require 'config.expcore.command_general_parse'
require 'config.expcore.command_role_parse'

--- Stores the tag for a player
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local PlayerTags = PlayerData.Settings:combine('Tag')
PlayerTags:set_metadata{
    permission = 'command/tag'
}

--- When your tag is updated then apply the changes
PlayerTags:on_update(function(player_name, player_tag)
    local player = game.players[player_name]
    if player_tag == nil or player_tag == '' then
        player.tag = ''
    else
        player.tag = '- '..player_tag
    end
end)

--- Sets your player tag.
-- @command tag
-- @tparam string tag the tag that will be after the name, there is a max length
Commands.new_command('tag', 'Sets your player tag.')
:add_param('tag', false, 'string-max-length', 20)
:enable_auto_concat()
:register(function(player, tag)
    PlayerTags:set(player, tag)
end)

--- Clears your tag. Or another player if you are admin.
-- @command tag-clear
-- @tparam[opt=self] LuaPlayer player the player to remove the tag from, nil will apply to self
Commands.new_command('tag-clear', 'Clears your tag. Or another player if you are admin.')
:add_param('player', true, 'player-role')
:set_defaults{player=function(player)
    return player -- default is the user using the command
end}
:register(function(player, action_player)
    if action_player.index == player.index then
        -- no player given so removes your tag
        PlayerTags:remove(action_player)
    elseif Roles.player_allowed(player, 'command/clear-tag/always') then
        -- player given and user is admin so clears that player's tag
        PlayerTags:remove(action_player)
    else
        -- user is not admin and tried to clear another users tag
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)