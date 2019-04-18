local Roles = require 'expcore.roles'
local Game = require 'utils.game'
local Global = require 'utils.global'
local move_items = ext_require('expcore.common','move_items')

local Public = {
    old_roles = {},
    temp_bans = {}
}
Global.register({
    Public.old_roles,
    Public.temp_bans
},function(tbl)
    Public.old_roles=tbl[1]
    Public.temp_bans=tbl[2]
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

--- Temp bans a player which is similar to jail but will store the reason for the action and clears items
-- @tparam player LuaPlayer the player that will be temp baned, must not be temp banned
-- @tparam[opt='<server>'] by_player_name string the name of the player that is doing the action
-- @tparam[opt='None Given.'] reason string the reason that will be stored for this temp ban
-- @treturn boolean true if successful else will return nil
function Public.temp_ban_player(player,by_player_name,reason)
    player = Game.get_player_from_any(player)
    reason = reason or 'None Given.'
    if not player then return end
    if Public.temp_bans[player.name] then return end
    Public.jail_player(player,by_player_name)
    Public.temp_bans[player.name] = {reason,by_player_name}
    local inv = player.get_main_inventory()
    move_items(inv.get_contents())
    inv.clear()
    return true
end

--- Removes temp ban from a player, note this does not restore the items
-- @tparam player LuaPlayer the player that will be cleared from temp baned, must be temp banned
-- @tparam[opt='<server>'] by_player_name string the name of the player that is doing the action
-- @treturn boolean true if successful else will return nil
function Public.clear_temp_ban_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if not Public.temp_bans[player.name] then return end
    Public.unjail_player(player,by_player_name)
    Public.temp_bans[player.name] = nil
    return true
end

return Public