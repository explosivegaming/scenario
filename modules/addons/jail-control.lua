local Roles = require 'expcore.roles'
local Game = require 'utils.game'
local Global = require 'utils.global'

local Public = {
    old_roles = {}
}
Global.register(Public.old_roles,function(tbl)
    Public.old_roles=tbl
end)

--- Jails a player, this is only the logic there is no output to players
-- @tparam player LuaPlayer the player that will be jailed, must not be in jail
-- @tparam[opt='<server>'] by_player_name string the name of the player doing the action used in logs
-- @treturn the number of roles that were removed, nil if there was an error
function Public.jail_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if Roles.player_has_role(player,'Jail') then return end
    local old_roles = Role.get_player_roles(player)
    Public.old_roles[player.name] = old_roles
    Roles.unassign_player(player,old_roles,by_player_name,true)
    Roles.assign_player(player,'Jail',by_player_name,true)
    return #old_roles
end

--- Unjails a player, this is only the logic there is no output to players
-- @tparam player LuaPlayer the player that will be unjailed, must be in jail
-- @tparam[opt='<server>'] by_player_name string string the name of the player who is doing the action
-- @treturn the number of roles that were added, nil if there was an error
function Public.unjail_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if not Roles.player_has_role(player,'Jail') then return end
    local old_roles = Public.old_roles[player.name]
    Roles.unassign_player(player,'Jail',by_player_name,true)
    Roles.assign_player(player,old_roles,by_player_name,true)
    return #old_roles
end

return Public