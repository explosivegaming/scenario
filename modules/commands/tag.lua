--[[-- Commands Module - Tag
    - Adds a command that allows players to have a custom tag after their name
    @commands Tag
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
require 'config.expcore-commands.parse_general'
require 'config.expcore-commands.parse_roles'

--- Sets your player tag.
-- @command tag
-- @tparam string tag the tag that will be after the name, there is a max length
Commands.new_command('tag','Sets your player tag.')
:add_param('tag',false,'string-max-length',20)
:enable_auto_concat()
:register(function(player,tag,raw)
    player.tag = '- '..tag
end)

--- Clears your tag. Or another player if you are admin.
-- @command tag-clear
-- @tparam[opt=self] LuaPlayer player the player to remove the tag from, nil will apply to self
Commands.new_command('tag-clear','Clears your tag. Or another player if you are admin.')
:add_param('player',true,'player-role')
:set_defaults{player=function(player)
    return player -- default is the user using the command
end}
:register(function(player,action_player,raw)
    if action_player.index == player.index then
        -- no player given so removes your tag
        action_player.tag = ''
    elseif Roles.player_allowed(player,'command/clear-tag/always') then
        -- player given and user is admin so clears that player's tag
        action_player.tag = ''
    else
        -- user is not admin and tried to clear another users tag
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)