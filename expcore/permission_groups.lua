--- Permission group making for factorio so you never have to make one by hand again
-- @author Cooldude2606
-- @module Permissions_Groups
--[[
>>>>Example Group (Allow All)

    -- here we will create an admin group however we do not want them to use the map editor or mess with the permission groups
    Permission_Groups.new_group('Admin') -- this defines a new group called "Admin"
    :allow_all() -- this makes the default to allow any input action unless set other wise
    :disallow{ -- here we disallow the input action we dont want them to use
        'add_permission_group',
        'delete_permission_group',
        'import_permissions_string',
        'map_editor_action',
        'toggle_map_editor'
    }

>>>>Example Group (Disallow All)

    -- here we will create a group that cant do anything but talk in chat
    Permission_Groups.new_group('Restricted') -- this defines a new group called "Restricted"
    :disallow_all() -- this makes the default to disallow any input action unless set other wise
    :allow('write_to_console') -- here we allow them to chat, {} can be used here if we had more than one action

>>>>Functions List (see function for more detail):

]]


local Game = require 'utils.game'
local Event = require 'utils.event'

local Permissions_Groups = {
    groups={}, -- store for the different groups that are created
    _prototype={} -- stores functions that are used on group instances
}

--- Defines a new permission group that can have it actions set in the config
-- @tparam name string the name of the new group
-- @treturn Permissions_Groups._prototype the new group made with function to allow and disallow actions
function Permissions_Groups.new_group(name)
    local group = setmetatable({
        name=name,
        actions={},
        allow_all_actions=true
    },{
        __index= Permissions_Groups._prototype
    })
    Permissions_Groups.groups[name] = group
    return group
end

--- Returns the group with the given name, case sensitive
-- @tparam name string the name of the group to get
-- @treturn ?Permissions_Groups._prototype|nil the group with that name or nil if non found
function Permissions_Groups.get_group_by_name(name)
    return Permissions_Groups.groups[name]
end

--- Returns the group that a player is in
-- @tparam LuaPlayer the player to get the group of can be LuaPlayer name index etc
-- @treturn ?Permissions_Groups._prototype|nil the group with that player or nil if non found
function Permissions_Groups.get_group_from_player(player)
    player = Game.get_player_from_any(player)
    local group = player.permission_group
    if group then
        return Permissions_Groups.groups[group.name]
    end
end

--- Reloads/creates all permission groups and sets them to they configured state
function Permissions_Groups.reload_permissions()
    for _,group in pairs(Permissions_Groups.groups) do
        group:create()
    end
end

--- Removes all permissions from every permission group except for "Default" and any passed as exempt
-- @tparam string|Array<string> any groups that you want to be except, "Default" is always exempt
-- @treturn number the number of groups that had they permissions removed
function Permissions_Groups.lockdown_permissions(exempt)
    local count = 0
    if type(exempt) ~= 'table' then
        exempt = {exempt}
    end
    for _,group in pairs(exempt) do
        if type(group) == 'string' then
            exempt[group:lower()] = true
        elseif type(group) == 'table' then
            exempt[group.name:lower()] = true
        end
    end
    for _,group in pairs(game.permissions.groups) do
        if not exempt[group.name:lower()] and not group.name == 'Default' then
            count = count +1
            for _,action in pairs(defines.input_action) do
                group.set_allows_action(action,false)
            end
        end
    end
    return count
end

--- Sets a player's group to the one given, a player can only have one group at a time
-- @tparam LuaPlayer the player to effect can be LuaPlayer name index etc
-- @tparam string the name of the group to give to the player
-- @treturn boolean true if the player was added successfully, false other wise
function Permissions_Groups.set_player_group(player,group)
    player = Game.get_player_from_any(player)
    local group = Permissions_Groups.get_group_by_name(group)
    if not group or not player then return false end
    group:add_player(player)
    return true
end

--- Sets the allow state of an action for this group, used internally but is safe to use else where
-- @tparam action ?string|defines.input_action the action that you want to set the state of
-- @tparam state boolean the state that you want to set it to, true = allow, false = disallow
-- @treturn Permissions_Groups._prototype returns self so function can be chained
function Permissions_Groups._prototype:set_action(action,state)
    if type(action) == 'string' then
        action = defines.input_action[action]
    end
    self.actions[action] = state
    return self
end

--- Sets an action or actions to be allowed for this group even with disallow_all triggered, Do not use in runtime
-- @tparam string|Array<string> the action or actions that you want to allow for this group
-- @treturn Permissions_Groups._prototype returns self so function can be chained
function Permissions_Groups._prototype:allow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self:set_action(action,true)
    end
    return self
end

--- Sets an action or actions to be disallowed for this group even with allow_all triggered, Do not use in runtime
-- @tparam string|Array<string> the action or actions that you want to disallow for this group
-- @treturn Permissions_Groups._prototype returns self so function can be chained
function Permissions_Groups._prototype:disallow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self:set_action(action,false)
    end
    return self
end

--- Sets the default state for any actions not given to be allowed, useful with :disallow
-- @treturn Permissions_Groups._prototype returns self so function can be chained
function Permissions_Groups._prototype:allow_all()
    self.allow_all_actions = true
    return self
end

--- Sets the default state for any action not given to be disallowed, useful with :allow
-- @treturn Permissions_Groups._prototype returns self so function can be chained
function Permissions_Groups._prototype:disallow_all()
    self.allow_all_actions = false
    return self
end

--- Returns if an input action is allowed for this group
-- @tparam action ?string|defines.input_action the action that you want to test for
-- @treturn boolean true if the group is allowed the action, false other wise
function Permissions_Groups._prototype:is_allowed(action)
    if type(action) == 'string' then
        action = defines.input_action[action]
    end
    local state = self.actions[action]
    if state == nil then
        state = self.allow_all_actions
    end
    return state
end

--- Returns the LuaPermissionGroup that was created with this group object, used internally
-- @treturn LuaPermissionGroup the raw lua permission group
function Permissions_Groups._prototype:get_raw()
    return game.permissions.get_group(self.name)
end

--- Creates or updates the permission group with the configured actions, used internally
-- @treturn LuaPermissionGroup the permission group that was created
function Permissions_Groups._prototype:create()
    local group = self:get_raw()
    if not group then
        group = game.permissions.create_group(self.name)
    end
    for _,action in pairs(defines.input_action) do
        group.set_allows_action(action,self:is_allowed(action))
    end
    return group
end

--- Adds a player to this group
-- @tparam player LuaPlayer the player you want to add to this group can be LuaPlayer name or index etc
-- @treturn boolean true if the player was added successfully, false other wise
function Permissions_Groups._prototype:add_player(player)
    player = Game.get_player_from_any(player)
    local group = self:get_raw()
    if not group or not player then return false end
    group.add_player(player)
    return true
end

--- Removes a player from this group
-- @tparam player LuaPlayer the player you want to remove from this group can be LuaPlayer name or index etc
-- @treturn boolean true if the player was removed successfully, false other wise
function Permissions_Groups._prototype:remove_player(player)
    player = Game.get_player_from_any(player)
    local group = self:get_raw()
    if not group or not player then return false end
    group.remove_player(player)
    return true
end

--- Returns all player that are in this group with the option to filter to online/offline only
-- @tparam[opt] online boolean if nil returns all players, if true online players only, if false returns online players only
-- @treturn table a table of players that are in this group; filtered if online param is given
function Permissions_Groups._prototype:get_players(online)
    local players = {}
    local group = self:get_raw()
    if group then
        if online == nil then
            return group.players
        else
            for _,player in pairs(group.players) do
                if player.connected == online then
                    table.insert(player,player)
                end
            end
        end
    end
    return players
end

--- Prints a message to every player in this group
-- @tparam message string the message that you want to send to the players
-- @treturn number the number of players that received the message
function Permissions_Groups._prototype:print(message)
    local players = self:get_players(true)
    for _,player in pairs(players) do
        player.print(message)
    end
    return #players
end

-- when the game starts it will make the permission groups
Event.on_init(function()
    Permissions_Groups.reload_permissions()
end)

return Permissions_Groups