local Roles = require 'expcore.roles'
local Game = require 'utils.game'
local Global = require 'utils.global'
local move_items = ext_require('expcore.common','move_items')

local Jail = {
    old_roles = {},
    temp_bans = {},
    events = {
        on_player_jailed=script.generate_event_name(),
        on_player_unjailed=script.generate_event_name(),
        on_player_temp_banned=script.generate_event_name(),
        on_player_temp_ban_cleared=script.generate_event_name()
    }
}

Global.register({
    old_roles = Jail.old_roles,
    temp_bans = Jail.temp_bans
},function(tbl)
    Jail.old_roles = tbl.old_roles
    Jail.temp_bans = tbl.temp_bans
end)

local function event_emit(event,player,by_player_name,reason)
    script.raise_event(event,{
        name=event,
        tick=game.tick,
        player_index=player.index,
        by_player_name=by_player_name,
        reason=reason
    })
end

--- Jails a player, this is only the logic there is no output to players
-- @tparam LuaPlayer player the player that will be jailed, must not be in jail
-- @tparam[opt='<server>'] string by_player_name the name of the player doing the action used in logs
-- @treturn the number of roles that were removed, nil if there was an error
function Jail.jail_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if Roles.player_has_role(player,'Jail') then return end
    local old_roles = Roles.get_player_roles(player)
    Jail.old_roles[player.name] = old_roles
    Roles.unassign_player(player,old_roles,by_player_name,true)
    Roles.assign_player(player,'Jail',by_player_name,true)
    event_emit(Jail.events.on_player_jailed,player,by_player_name)
    return #old_roles
end

--- Unjails a player, this is only the logic there is no output to players
-- @tparam LuaPlayer player the player that will be unjailed, must be in jail
-- @tparam[opt='<server>'] string string by_player_name the name of the player who is doing the action
-- @treturn the number of roles that were added, nil if there was an error
function Jail.unjail_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if not Roles.player_has_role(player,'Jail') then return end
    local old_roles = Jail.old_roles[player.name]
    Roles.unassign_player(player,'Jail',by_player_name,true)
    Roles.assign_player(player,old_roles,by_player_name,true)
    event_emit(Jail.events.on_player_unjailed,player,by_player_name)
    return #old_roles
end

--- Temp bans a player which is similar to jail but will store the reason for the action and clears items
-- @tparam LuaPlayer player the player that will be temp baned, must not be temp banned
-- @tparam[opt='<server>'] string by_player_name the name of the player that is doing the action
-- @tparam[opt='None string Given.'] reason the reason that will be stored for this temp ban
-- @treturn boolean true if successful else will return nil
function Jail.temp_ban_player(player,by_player_name,reason)
    player = Game.get_player_from_any(player)
    reason = reason or 'None Given.'
    if not player then return end
    if Jail.temp_bans[player.name] then return end
    Jail.jail_player(player,by_player_name)
    Jail.temp_bans[player.name] = {reason,by_player_name}
    local inv = player.get_main_inventory()
    move_items(inv.get_contents())
    inv.clear()
    event_emit(Jail.events.on_player_temp_banned,player,by_player_name,reason)
    return true
end

--- Removes temp ban from a player, note this does not restore the items
-- @tparam LuaPlayer player the player that will be cleared from temp baned, must be temp banned
-- @tparam[opt='<server>'] string by_player_name the name of the player that is doing the action
-- @treturn boolean true if successful else will return nil
function Jail.clear_temp_ban_player(player,by_player_name)
    player = Game.get_player_from_any(player)
    if not player then return end
    if not Jail.temp_bans[player.name] then return end
    Jail.unjail_player(player,by_player_name)
    Jail.temp_bans[player.name] = nil
    event_emit(Jail.events.on_player_temp_ban_cleared,player,by_player_name)
    return true
end

return Jail