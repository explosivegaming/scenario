--[[-- Control Module - Jail
    - Adds a way to jail players and temp ban players.
    @control Jail
    @alias Jail

    @usage
    -- import the module from the control modules
    local Jail = require 'modules.control.jail' --- @dep modules.control.jail

    -- This will move 'MrBiter' to the jail role and remove all other roles from them
    -- the player name and reason are only so they can be included in the event for user feedback
    Jail.jail_player('MrBiter', 'Cooldude2606', 'Likes biters too much')

    -- This will give 'MrBiter' all his roles back and remove him from jail
    -- again as above the player name is only used in the event for user feedback
    Jail.unjail_player('MrBiter', 'Cooldude2606')

    -- Temp ban works the same as jail but will store the reason and move the players items to spawn
    -- this is meant to be used as a more permiment jail but not as strong as a ban
    Jail.temp_ban_player('MrBiter', 'Cooldude2606', 'Likes biters too much')
]]

local Roles = require 'expcore.roles' --- @dep expcore.roles
local Game = require 'utils.game' --- @dep utils.game
local Global = require 'utils.global' --- @dep utils.global
local move_items = _C.move_items --- @dep expcore.common

local valid_player = Game.get_player_from_any
local assign_roles = Roles.assign_player
local unassign_roles = Roles.unassign_player
local has_role = Roles.player_has_role
local get_roles = Roles.get_player_roles

local Jail = {
    old_roles = {},
    temp_bans = {},
    events = {
        --- When a player is assigned to jail
        -- @event on_player_jailed
        -- @tparam number player_index the index of the player who was jailed
        -- @tparam string by_player_name the name of the player who jailed the other player
        -- @tparam string reason the reason that the player was jailed
        on_player_jailed=script.generate_event_name(),
        --- When a player is unassigned from jail
        -- @event on_player_unjailed
        -- @tparam number player_index the index of the player who was unjailed
        -- @tparam string by_player_name the name of the player who unjailed the other player
        on_player_unjailed=script.generate_event_name(),
        --- When a player is temp banned
        -- @event on_player_temp_banned
        -- @tparam number player_index the index of the player who was temp banned
        -- @tparam string by_player_name the name of the player who temp banned the other player
        -- @tparam string reason the reason that the player was temp banned
        on_player_temp_banned=script.generate_event_name(),
        --- When a temp ban is removed from a player
        -- @event on_player_untemp_banned
        -- @tparam number player_index the index of the player who was untemp banned
        -- @tparam string by_player_name the name of the player who untemp banned the other player
        on_player_untemp_banned=script.generate_event_name()
    }
}

local old_roles = Jail.old_roles
local temp_bans = Jail.temp_bans
Global.register({
    old_roles = old_roles,
    temp_bans = temp_bans
}, function(tbl)
    Jail.old_roles = tbl.old_roles
    Jail.temp_bans = tbl.temp_bans
    old_roles = Jail.old_roles
    temp_bans = Jail.temp_bans
end)

--- Used to emit the jail related events
-- @tparam number event the name of the event that will be emited
-- @tparam LuaPlayer player the player who is being acted on
-- @tparam string by_player_name the player who is doing the action
-- @tparam string reason the reason for the action (jail and tempban only)
local function event_emit(event, player, by_player_name, reason)
    script.raise_event(event, {
        name=event,
        tick=game.tick,
        player_index=player.index,
        by_player_name=by_player_name,
        reason=reason
    })
end

--- Jail.
-- Functions related to jail
-- @section jail-functions

--- Checks if the player is currently in jail
-- @tparam LuaPlayer player the player to check if they are in jail
-- @treturn boolean whether the player is currently in jail
function Jail.is_jailed(player)
    return has_role(player, 'Jail')
end

--- Moves a player to jail and removes all other roles
-- @tparam LuaPlayer player the player who will be jailed
-- @tparam string by_player_name the name of the player who is doing the jailing
-- @tparam[opt='Non given.'] string reason the reason that the player is being jailed
-- @treturn boolean wheather the user was jailed successfully
function Jail.jail_player(player, by_player_name, reason)
    player = valid_player(player)
    if not player then return end
    if not by_player_name then return end

    reason = reason or 'Non given.'

    if has_role(player, 'Jail') then return end
    local roles = get_roles(player)
    old_roles[player.name] = roles

    assign_roles(player, 'Jail', by_player_name, nil, true)
    unassign_roles(player, roles, by_player_name, nil, true)

    event_emit(Jail.events.on_player_jailed, player, by_player_name, reason)

    return true
end

--- Moves a player out of jail and restores all roles previously removed
-- @tparam LuaPlayer player the player that will be unjailed
-- @tparam string by_player_name the name of the player that is doing the unjail
-- @treturn boolean whether the player was unjailed successfully
function Jail.unjail_player(player, by_player_name)
    player = valid_player(player)
    if not player then return end
    if not by_player_name then return end

    if not has_role(player, 'Jail') then return end
    local roles = old_roles[player.name] or {}

    assign_roles(player, roles, by_player_name, nil, true)
    unassign_roles(player, 'Jail', by_player_name, nil, true)

    event_emit(Jail.events.on_player_unjailed, player, by_player_name)

    return true
end

--- Temp ban.
-- Functions related to temp ban
-- @section temp-ban-functions

--- Checks if a player is temp banned
-- @tparam LuaPlayer player the player to check if they are temp banned
-- @treturn boolean whether the player is temp banned
function Jail.is_temp_banned(player)
    player = valid_player(player)
    if not player then return end
    return temp_bans[player.name] ~= nil
end

--- Temp bans a player by moving them to jail, clearing all other roles, storing the reason, and moving their items to spawn
-- @tparam LuaPlayer player the player that will be temp banned
-- @tparam string by_player_name the name of the player who is doing the temp ban
-- @tparam[opt='Non given.'] string reason the reason that the player is being temp banned
-- @treturn boolean whether the player was successfully temp banned
function Jail.temp_ban_player(player, by_player_name, reason)
    player = valid_player(player)
    if not player then return end
    if not by_player_name then return end

    reason = reason or 'Non given.'

    if temp_bans[player.name] then return end
    temp_bans[player.name] = {reason, by_player_name}

    if not has_role(player, 'Jail') then
        local roles = get_roles(player)
        old_roles[player.name] = roles

        assign_roles(player, 'Jail', by_player_name, nil, true)
        unassign_roles(player, roles, by_player_name, nil, true)
    end

    local inv = player.get_main_inventory()
    move_items(inv.get_contents())
    inv.clear()

    event_emit(Jail.events.on_player_temp_banned, player, by_player_name, reason)

    return true
end

--- Rrmoves a player from temp ban by clearing the stored reason, removing them from jail, and restoring previous roles
-- @tparam LuaPlayer player the player who is being removed from temp ban
-- @tparam string by_player_name the name of the player who is doing the untemp ban
-- @treturn boolean whether the player was successfully removed
function Jail.untemp_ban_player(player, by_player_name)
    player = valid_player(player)
    if not player then return end
    if not by_player_name then return end

    if not temp_bans[player.name] then return end
    temp_bans[player.name] = nil

    if has_role(player, 'Jail') then
        local roles = old_roles[player.name]

        assign_roles(player, roles, by_player_name, nil, true)
        unassign_roles(player, 'Jail', by_player_name, nil, true)
    end

    event_emit(Jail.events.on_player_untemp_banned, player, by_player_name)

    return true
end

return Jail