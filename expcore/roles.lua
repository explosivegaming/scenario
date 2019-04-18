--- Factorio role system to manage custom permissions
-- @author Cooldude2606
-- @module Commands
--[[
>>>>Using Role System (Frontend):
    When a map first starts you will want to define on mass all the players you expect to join and the roles to give them:
    Roles.override_player_roles{
        Cooldude2606 = {'Owner','Admin','Member'},
        NotCooldude2606 = {'Member'}
    }

    Once the game is running you still want to be able to give role and remove them which is when you would use:
    Roles.assign_player(player,'Admin',by_player_name) -- this will give the "Admin" role to the player
    Roles.unassign_player(player,{'Admin','Moderator'},by_player_name) -- this will remove "Admin" and "Moderator" role in one go

>>>>Using Role System (Backend):
    To comparer two players you can comparer the index of they highest roles, can be used when you want to allow a "write" down type system:
    Roles.get_player_highest_role(playerOne).index < Roles.get_player_highest_role(playerTwo).index -- remember that less means a higher role

    Listing all of a players roles can also be useful which is when you would want to use:
    Roles.get_player_roles(player) -- the return is an array that can be looped over however this is not in particular order

    Finally you may want to test if a player has a certain role, flag or action allowed which is when you would use:
    Roles.player_has_role(player,'Admin') -- you can provide a role name if you only want a name based system
    Roles.player_has_flag(player,'is_donator') -- your roles can be grouped together with flags such as is_donator
    Roles.player_allowed(player,'game modifiers') -- or you can have an action based system where each action is something the player can do

>>>>Example Flag Define:
    Flags can be used to group multiple roles and actions under one catch all, for example if you want a piece of code to only
    be active for your donators then you would add a "is_donator" flag to all your donator roles and then in the code test if
    a player has that tag present:

    -- give you donators a speed boost when they join; these functions aren't required but can be useful
    Roles.define_flag_trigger('is_donator',function(player,state)
        if state then
            player.character_running_speed_modifier = 1.5
        else
            player.character_running_speed_modifier = 1
        end
    end)

    -- then on all your donator roles you would add
    Roles.new_role('Donator')
    :set_flag('is_donator')

    -- and in your code you would test for
    if Roles.player_has_flag(player,'is_donator') then
        -- some donator only code
    end

>>>>Example Role Define:
    You can't use a role system without any roles so first you must define your roles; each role has a minimum of a name with
    the option for a shorthand:
    Roles.new_role('Administrator','Admin')

    Next you will want to add any extras you want to have, such as a tag, colour, permission group or any custom flags:
    Roles.new_role('Administrator','Admin')
    :set_custom_tag('[Admin]')
    :set_custom_color('red') -- this can be {r=0,g=0,b=0} or a predefined value
    :set_permission_group('Staff') -- a second argument can be added if you have not used the custom permission group config
    :set_flag('is_admin')

    You will then want to decide if you want to allow all actions, this should of course be used sparely:
    Roles.new_role('Administrator','Admin')
    ...extras...
    :set_allow_all()

    If you dont do this want this as i would advise you do then you will want to define what the role can do; this comes with
    an optional inheritance system if you like those sort of things in which case disallow may also be of some use to you:
    Roles.new_role('Administrator','Admin')
    ...extras...
    :set_parent('Moderator') -- the admin can do anything that a moderator can do
    :allow{ -- these actions can be anything just try to keep them without conflicts
        'command/kill',
        'gui/game settings'
    }

    Here is what the finished admin role would look like:
    Roles.new_role('Administrator','Admin')
    :set_custom_tag('[Admin]')
    :set_custom_color('red')
    :set_permission_group('Staff')
    :set_flag('is_admin')
    :set_parent('Moderator')
    :allow{
        'command/kill',
        'gui/game settings'
    }

>>>>Example System Define:
    Once all roles are defined these steps must be done to ensure the system is ready to use, this includes setting a default
    role, assigning a root (all permission) role that the server/system will use and the linier order that the roles fall into:

    Roles.set_default('Guest')
    Roles.set_root('System')

    Roles.define_role_order{
        'System',
        'Administrator',
        'Moderator',
        'Donator',
        'Guest'
    }

    Just remember that in this example all these roles have not been defined; so make sure all your roles that are used are defined
    before hand; a config file on load is useful for this to ensure that its loaded before the first player even joins.

>>>>Functions List (see function for more detail):
    Roles.debug() --- Returns a string which contains all roles in index order displaying all data for them

    Roles.print_to_roles(roles,message) --- Prints a message to all players in the given roles, may send duplicate message however factorio blocks spam
    Roles.print_to_roles_higher(role,message) --- Prints a message to all players who have the given role or one which is higher (excluding default)
    Roles.print_to_roles_lower(role,message) --- Prints a message to all players who have the given role or one which is lower (excluding default)

    Roles.get_role_by_name(name) --- Get a role for the given name
    Roles.get_role_by_order(index) --- Get a role with the given order index
    Roles.get_role_from_any(any) --- Gets a role from a name,index or role object (where it is just returned)
    Roles.get_player_roles(player) --- Gets all the roles of the given player, this will always contain the default role
    Roles.get_player_highest_role(player) --- Gets the highest role which the player has, can be used to compeer one player to another

    Roles.assign_player(player,roles,by_player_name,silent) --- Gives a player the given role(s) with an option to pass a by player name used in the log
    Roles.unassign_player(player,roles,by_player_name,silent) --- Removes a player from the given role(s) with an option to pass a by player name used in the log
    Roles.override_player_roles(roles) --- Overrides all player roles with the given table of roles, useful to mass set roles on game start

    Roles.player_has_role(player,search_role) --- A test for weather a player has the given role
    Roles.player_has_flag(player,flag_name) --- A test for weather a player has the given flag true for at least one of they roles
    Roles.player_allowed(player,action) --- A test for weather a player has at least one role which is allowed the given action

    Roles.define_role_order(order) --- Used to set the role order, higher in the list is better, must be called at least once in config
    Roles.define_flag_trigger(name,callback) --- Defines a new trigger for when a tag is added or removed from a player
    Roles.set_default(name) --- Sets the default role which every player will have, this needs to be called at least once
    Roles.set_root(name) --- Sets the root role which will always have all permissions, any server actions act from this role

    Roles.new_role(name,short_hand) --- Defines a new role and returns the prototype to allow configuration

    Roles._prototype:set_allow_all(state) --- Sets the default allow state of the role, true will allow all actions
    Roles._prototype:allow(actions) --- Sets the allow actions for this role, actions in this list will be allowed for this role
    Roles._prototype:disallow(actions) --- Sets the disallow actions for this role, will prevent actions from being allowed regardless of inheritance
    Roles._prototype:is_allowed(action) --- Test for if a role is allowed the given action, mostly internal see Roles.player_allowed

    Roles._prototype:set_flag(name,value) --- Sets the state of a flag for a role, flags can be used to apply effects to players
    Roles._prototype:clear_flags() --- Clears all flags from this role, individual flags can be removed with set_flag(name,false)
    Roles._prototype:has_flag(name) --- A test for if the role has a flag set

    Roles._prototype:set_custom_tag(tag) --- Sets a custom player tag for the role, can be accessed by other code
    Roles._prototype:set_custom_color(color) --- Sets a custom colour for the role, can be accessed by other code
    Roles._prototype:set_permission_group(name,use_factorio_api) --- Sets the permission group for this role, players will be moved to the group of they highest role
    Roles._prototype:set_parent(role) --- Sets the parent for a role, any action not in allow or disallow will be looked for in its parents
    Roles._prototype:set_auto_promote_condition(callback) --- Sets an auto promote condition that is checked every 5 seconds, if true is returned then the player will recive the role
    Roles._prototype:set_block_auto_promote(state) --- Sets the role to not allow players to have auto promote effect them, useful to keep people locked to a punishment

    Roles._prototype:add_player(player,skip_check,skip_event) --- Adds a player to this role, players can have more than one role at a time, used internally see Roles.assign
    Roles._prototype:remove_player(player,skip_check,skip_event) --- Removes a player from this role, players can have more than one role at a time, used internally see Roles.unassign
    Roles._prototype:get_players(online) --- Returns an array of all the players who have this role, can be filtered by online status
    Roles._prototype:print(message) --- Will print a message to all players with this role
]]

local Game = require 'utils.game'
local Global = require 'utils.global'
local Event = require 'utils.event'
local Groups = require 'expcore.permission_groups'
local Colours = require 'resources.color_presets'

local Roles = {
    config={
        order={}, -- Contains the order of the roles, lower index is better
        roles={}, -- Contains the raw info for the roles, indexed by role name
        flags={}, -- Contains functions that run when a flag is added/removed from a player
        internal={}, -- Contains all internally accessed roles, such as root, default
        players={}
    },
    player_role_assigned=script.generate_event_name(),
    player_role_unassigned=script.generate_event_name(),
    _prototype={}
}

--- When global is loaded it will have the metatable re-assigned to the roles
Global.register(Roles.config,function(tbl)
    Roles.config = tbl
    for _,role in pairs(Roles.config.roles) do
        setmetatable(role,{__index=Roles._prototype})
        local parent = Roles.config.roles[role.parent]
        if parent then
            setmetatable(role.allowed_actions, {__index=parent.allowed_actions})
        end
    end
end)

--- Internal function used to trigger a few different things when roles are changed
-- this is the raw internal trigger as the other function is called at other times
-- there is a second half called role_update which triggers after the event call, it also is called when a player joins
local function emit_player_roles_updated(player,type,roles,by_player_name,skip_game_print)
    by_player_name = game.player and game.player.name or by_player_name or '<server>'
    local by_player = Game.get_player_from_any(by_player_name)
    local by_player_index = by_player and by_player.index or 0
    -- get the event id from the type of emit
    local event = Roles.player_role_assigned
    if type == 'unassign' then
        event = Roles.player_role_unassigned
    end
    -- convert the roles to objects and get the names of the roles
    local role_names = {}
    for index,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        if role then
            roles[index] = role
            table.insert(role_names,role.name)
        end
    end
    -- output to all the different locations: game print, player sound, event trigger and role log
    if not skip_game_print then
        game.print({'expcore-roles.game-message-'..type,player.name,table.concat(role_names,', '),by_player_name},Colours.cyan)
    end
    if type == 'assign' then
        player.play_sound{path='utility/achievement_unlocked'}
    else
        player.play_sound{path='utility/game_lost'}
    end
    script.raise_event(event,{
        name=Roles.player_roles_updated,
        tick=game.tick,
        player_index=player.index,
        by_player_index=by_player_index,
        roles=roles
    })
    game.write_file('log/roles.log',game.table_to_json{
        player_name=player.name,
        by_player_name=by_player_name,
        type=type,
        roles_changed=role_names
    }..'\n',true,0)
end

--- Returns a string which contains all roles in index order displaying all data for them
-- @treturn string the debug output string
function Roles.debug()
    local output = ''
    for index,role_name in pairs(Roles.config.order) do
        local role = Roles.config.roles[role_name]
        local color = role.custom_color or Colours.white
        color = string.format('[color=%d,%d,%d]',color.r,color.g,color.b)
        output = output..string.format('\n%s %s) %s[/color]',color,index,serpent.line(role))
    end
    return output
end

--- Prints a message to all players in the given roles, may send duplicate message however factorio blocks spam
-- @tparam roles table a table of roles which to send the message to
-- @tparam message string the message to send to the players
function Roles.print_to_roles(roles,message)
    for _,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        if role then role:print(message) end
    end
end

--- Prints a message to all players who have the given role or one which is higher (excluding default)
-- @tparam role string the name of the role to send the message to
-- @tparam message string the message to send to the players
function Roles.print_to_roles_higher(role,message)
    role = Roles.get_role_from_any(role)
    if not role then return end
    local roles = {}
    for index,role_name in pairs(Roles.config.order) do
        if index <= role.index and role_name ~= Roles.config.internal.default then
            table.insert(roles,role_name)
        end
    end
    Roles.print_to_roles(roles,message)
end

--- Prints a message to all players who have the given role or one which is lower (excluding default)
-- @tparam role string the name of the role to send the message to
-- @tparam message string the message to send to the players
function Roles.print_to_roles_lower(role,message)
    role = Roles.get_role_from_any(role)
    if not role then return end
    local roles = {}
    for index,role_name in pairs(Roles.config.order) do
        if index >= role.index and role_name ~= Roles.config.internal.default then
            table.insert(roles,role_name)
        end
    end
    Roles.print_to_roles(roles,message)
end

--- Get a role for the given name
-- @tparam name string the name of the role to get
-- @treturn Roles._prototype the role with that name or nil
function Roles.get_role_by_name(name)
    return Roles.config.roles[name]
end

--- Get a role with the given order index
-- @tparam index number the place in the oder list of the role to get
-- @treturn Roles._prototype the role with that index in the order list or nil
function Roles.get_role_by_order(index)
    local name = Roles.config.order[index]
    return Roles.config.roles[name]
end

--- Gets a role from a name,index or role object (where it is just returned)
-- nb: this function is used for the input for most outward facing functions
-- @tparam any ?number|string|table the value used to find the role
-- @treturn Roles._prototype the role that was found or nil see above
function Roles.get_role_from_any(any)
    local tany = type(any)
    if tany == 'number' or tonumber(any) then
        any = tonumber(any)
        return Roles.get_role_by_order(any)
    elseif tany == 'string' then
        return Roles.get_role_by_name(any)
    elseif tany == 'table' then
        return Roles.get_role_by_name(any.name)
    end
end

--- Gets all the roles of the given player, this will always contain the default role
-- @tparam player LuaPlayer the player to get the roles of
-- @treturn table a table where the values are the roles which the player has
function Roles.get_player_roles(player)
    player = Game.get_player_from_any(player)
    if not player then return end
    local roles = Roles.config.players[player.name] or {}
    local default = Roles.config.roles[Roles.config.internal.default]
    local rtn = {default}
    for _,role_name in pairs(roles) do
        table.insert(rtn,Roles.config.roles[role_name])
    end
    return rtn
end

--- Gets the highest role which the player has, can be used to compeer one player to another
-- @tparam player LuaPlayer the player to get the highest role of
-- @treturn the role with the highest order index which this player has
function Roles.get_player_highest_role(player)
    local roles = Roles.get_player_roles(player)
    if not roles then return end
    local highest
    for _,role in pairs(roles) do
        if not highest or role.index < highest.index then
            highest = role
        end
    end
    return highest
end

--- Gives a player the given role(s) with an option to pass a by player name used in the log
-- @tparam player LuaPlayer the player that will be assigned the roles
-- @tparam role table a table of roles that the player will be given, can be one role and can be role names
-- @tparam[opt=<server>] by_player_name string the name of the player that will be shown in the log
-- @tparam[opt=false] silent boolean when true there will be no game message printed
function Roles.assign_player(player,roles,by_player_name,silent)
    player = Game.get_player_from_any(player)
    if not player then return end
    if type(roles) ~= 'table' or roles.name then
        roles = {roles}
    end
    for _,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        if role then
            role:add_player(player,false,true)
        end
    end
    emit_player_roles_updated(player,'assign',roles,by_player_name,silent)
end

--- Removes a player from the given role(s) with an option to pass a by player name used in the log
-- @tparam player LuaPlayer the player that will have the roles removed
-- @tparam roles table a table of roles to be removed from the player, can be one role and can be role names
-- @tparam[opt=<server>] by_player_name string the name of the player that will be shown in the logs
-- @tparam[opt=false] silent boolean when true there will be no game message printed
function Roles.unassign_player(player,roles,by_player_name,silent)
    player = Game.get_player_from_any(player)
    if not player then return end
    if type(roles) ~= 'table' or roles.name then
        roles = {roles}
    end
    for _,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        if role then
            role:remove_player(player,false,true)
        end
    end
    emit_player_roles_updated(player,'unassign',roles,by_player_name,silent)
end

--- Overrides all player roles with the given table of roles, useful to mass set roles on game start
-- @tparam roles table a table which is indexed by case sensitive player names and has the value of a table of role names
function Roles.override_player_roles(roles)
    Roles.config.players = roles
end

--- A test for weather a player has the given role
-- @tparam player LuaPlayer the player to test the roles of
-- @tparam search_role ?string|number|table a pointer to the role that is being searched for
-- @treturn boolean true if the player has the role, false otherwise, nil for errors
function Roles.player_has_role(player,search_role)
    local roles = Roles.get_player_roles(player)
    if not roles then return end
    search_role = Roles.get_role_from_any(search_role)
    if not search_role then return end
    for _,role in pairs(roles) do
        if role.name == search_role.name then return true end
    end
    return false
end

--- A test for weather a player has the given flag true for at least one of they roles
-- @tparam player LuaPlayer the player to test the roles of
-- @tparam flag_name string the name of the flag that is being looked for
-- @treturn boolean true if the player has at least one role which has the flag set to true, false otherwise, nil for errors
function Roles.player_has_flag(player,flag_name)
    local roles = Roles.get_player_roles(player)
    if not roles then return end
    for _,role in pairs(roles) do
        if role:has_flag(flag_name) then
            return true
        end
    end
    return false
end

--- A test for weather a player has at least one role which is allowed the given action
-- @tparam player LuaPlayer the player to test the roles of
-- @tparam action string the name of the action that is being tested for
-- @treturn boolean true if the player has at least one role which is allowed this action, false otherwise, nil for errors
function Roles.player_allowed(player,action)
    local roles = Roles.get_player_roles(player)
    if not roles then return end
    for _,role in pairs(roles) do
        if role:is_allowed(action) then
            return true
        end
    end
    return false
end

--- Used to set the role order, higher in the list is better, must be called at least once in config
-- nb: function also re links parents due to expected position in the config file
-- @tparam order table a table which is keyed only by numbers (start 1) and values are roles in order with highest first
function Roles.define_role_order(order)
    -- Clears and then rebuilds the order table
    Roles.config.order = {}
    for _,role in ipairs(order) do
        if type(role) == 'table' and role.name then
            table.insert(Roles.config.order,role.name)
        else
            table.insert(Roles.config.order,role)
        end
    end
    -- Re-links roles to they parents as this is called at the end of the config
    for index,role in pairs(Roles.config.order) do
        role = Roles.config.roles[role]
        role.index = index
        local parent = Roles.config.roles[role.parent]
        if parent then
            setmetatable(role.allowed_actions,{__index=parent.allowed_actions})
        end
    end
end

--- Defines a new trigger for when a tag is added or removed from a player
-- @tparam name string the name of the flag which the roles will have
-- @tparam callback function the function that is called when roles are assigned
-- flag param - player - the player that has had they roles changed
-- flag param - state - the state of the flag, aka if the flag is present
function Roles.define_flag_trigger(name,callback)
    Roles.config.flags[name] = callback -- this can desync if there are upvalues
end

--- Sets the default role which every player will have, this needs to be called at least once
-- @tparam name string the name of the default role
function Roles.set_default(name)
    local role = Roles.config.roles[name]
    if not role then return end
    Roles.config.internal.default = name
end

--- Sets the root role which will always have all permissions, any server actions act from this role
-- @tparam name string the name of the root role
function Roles.set_root(name)
    local role = Roles.config.roles[name]
    if not role then return end
    role:set_allow_all(true)
    Roles.config.internal.root = name
end

--- Defines a new role and returns the prototype to allow configuration
-- @tparam name string the name of the new role, must be unique
-- @tparam[opt=name] shirt_hand string the shortened version of the name
-- @treturn Roles._prototype the start of the config chain for this role
function Roles.new_role(name,short_hand)
    if Roles.config.roles[name] then return error('Role name is non unique') end
    local role = setmetatable({
        name=name,
        short_hand=short_hand or name,
        allowed_actions={},
        allow_all_actions=false,
        flags={}
    },{__index=Roles._prototype})
    Roles.config.roles[name] = role
    return role
end

--- Sets the default allow state of the role, true will allow all actions
-- @tparam[opt=true] strate boolean true will allow all actions
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_allow_all(state)
    if state == nil then state = true end
    self.allow_all_actions = not not state -- not not forces a boolean value
    return self
end

--- Sets the allow actions for this role, actions in this list will be allowed for this role
-- @tparam actions table indexed with numbers and is an array of action names, order has no effect
-- @treturn Roles._prototype allows chaining
function Roles._prototype:allow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self.allowed_actions[action]=true
    end
    return self
end

--- Sets the disallow actions for this role, will prevent actions from being allowed regardless of inheritance
-- @tparam actions table indexed with numbers and is an array of action names, order has no effect
-- @treturn Roles._prototype allows chaining
function Roles._prototype:disallow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self.allowed_actions[action]=false
    end
    return self
end

--- Test for if a role is allowed the given action, mostly internal see Roles.player_allowed
-- @tparam action string the name of the action to test if it is allowed
-- @treturn boolean true if action is allowed, false otherwise
function Roles._prototype:is_allowed(action)
    local is_root = Roles.config.internal.root.name == self.name
    return self.allowed_actions[action] or self.allow_all_actions or is_root
end

--- Sets the state of a flag for a role, flags can be used to apply effects to players
-- @tparam name string the name of the flag to set the value of
-- @tparam[opt=true] value boolean the state to set the flag to
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_flag(name,value)
    if value == nil then value = true end
    self.flags[name] = not not value -- not not forces a boolean value
    return self
end

--- Clears all flags from this role, individual flags can be removed with set_flag(name,false)
-- @treturn Roles._prototype allows chaining
function Roles._prototype:clear_flags()
    self.flags = {}
    return self
end

--- A test for if the role has a flag set
-- @tparam name string the name of the flag to test for
-- @treturn boolean true if the flag is set, false otherwise
function Roles._prototype:has_flag(name)
    return self.flags[name] or false
end

--- Sets a custom player tag for the role, can be accessed by other code
-- @tparam tag string the value that the tag will be
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_custom_tag(tag)
    self.custom_tag = tag
    return self
end

--- Sets a custom colour for the role, can be accessed by other code
-- @tparam color ?string|table can either be and rgb colour table or the name of a colour defined in the presets
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_custom_color(color)
    if type(color) ~= 'table' then
        color = Colours[color]
    end
    self.custom_color = color
    return self
end

--- Sets the permission group for this role, players will be moved to the group of they highest role
-- @tparam name string the name of the permission group to have players moved to
-- @tparam[opt=false] use_factorio_api boolean when true the custom permission group module is ignored
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_permission_group(name,use_factorio_api)
    if use_factorio_api then
        self.permission_group = {true,name}
    else
        local group = Groups.get_group_by_name(name)
        if not group then return end
        self.permission_group = name
    end
    return self
end

--- Sets the parent for a role, any action not in allow or disallow will be looked for in its parents
-- nb: this is a recursive action, and changing the allows and disallows will effect all children roles
-- @tparam role string the name of the role that will be the parent; has imminent effect if role is already defined
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_parent(role)
    self.parent = role
    role = Roles.get_role_from_any(role)
    if not role then return self end
    setmetatable(self.allowed_actions, {__index=role.allowed_actions})
    return self
end

--- Sets an auto promote condition that is checked every 5 seconds, if true is returned then the player will recive the role
-- nb: this is one way, failing false after already gaining the role will not revoke the role
-- @tparam callback function receives only one param which is player to promote, return true to promote the player
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_auto_promote_condition(callback)
    self.auto_promote_condition = callback
    return self
end

--- Sets the role to not allow players to have auto promote effect them, useful to keep people locked to a punishment
-- @tparam[opt=true] state boolean when true the players with this role will not be auto promoted
-- @treturn Roles._prototype allows chaining
function Roles._prototype:set_block_auto_promote(state)
    if state == nil then state = true end
    self.block_auto_promote = not not state -- forces a boolean value
    return self
end

--- Adds a player to this role, players can have more than one role at a time, used internally see Roles.assign
-- @tparam player LuaPlayer the player that will be given this role
-- @tparam skip_check boolean when true player will be taken as the player name (use when player has not yet joined)
-- @tparam skip_event boolean when true the event emit will be skipped, this is used internally with Roles.assign
-- @treturn boolean true if the player was added successfully
function Roles._prototype:add_player(player,skip_check,skip_event)
    player = Game.get_player_from_any(player)
    -- Check the player is valid, can be skipped but a name must be given
    if not player then
        if skip_check then
            player = {name=player}
        else
            return false
        end
    end
    -- Add the role name to the player's roles
    local player_roles = Roles.config.players[player.name]
    if player_roles then
        for _,role_name in pairs(player_roles) do
            if role_name == self.name then return false end
        end
        table.insert(player_roles,self.name)
    else
        Roles.config.players[player.name] = {self.name}
    end
    -- Emits event if required
    if not skip_event then
        emit_player_roles_updated(player,'assign',{self})
    end
    return true
end

--- Removes a player from this role, players can have more than one role at a time, used internally see Roles.unassign
-- @tparam player LuaPlayer the player that will lose this role
-- @tparam skip_check boolean when true player will be taken as the player name (use when player has not yet joined)
-- @tparam skip_event boolean when true the event emit will be skipped, this is used internally with Roles.unassign
-- @treturn boolean true if the player was removed successfully
function Roles._prototype:remove_player(player,skip_check,skip_event)
    player = Game.get_player_from_any(player)
    -- Check the player is valid, can be skipped but a name must be given
    if not player then
        if skip_check then
            player = {name=player}
        else
            return false
        end
    end
    -- Remove the role from the players roles
    local player_roles = Roles.config.players[player.name]
    local rtn = false
    if player_roles then
        for index,role_name in pairs(player_roles) do
            if role_name == self.name then
                table.remove(player_roles,index)
                rtn = true
                break
            end
        end
        if #player_roles == 0 then
            Roles.config.players[player.name] = nil
        end
    end
    -- Emits event if required
    if not skip_event then
        emit_player_roles_updated(player,'unassign',{self})
    end
    return rtn
end

--- Returns an array of all the players who have this role, can be filtered by online status
-- @tparam[opt=nil] online boolean when given will filter by this online state, nil will return all players
-- @treturn table all the players who have this role, indexed order is meaningless
function Roles._prototype:get_players(online)
    local players = {}
    -- Gets all players that have this role
    for player_name,player_roles in pairs(Roles.config.players) do
        for _,role_name in pairs(player_roles) do
            if role_name == self.name then
                table.insert(players,player_name)
            end
        end
    end
    -- Convert the player names to LuaPlayer
    for index,player_name in pairs(players) do
        players[index] = Game.get_player_from_any(player_name)
    end
    -- Filter by online if param is defined
    if online == nil then
        return players
    else
        local filtered = {}
        for _,player in pairs(players) do
            if player.connected == online then
                table.insert(filtered,player)
            end
        end
        return filtered
    end
end

--- Will print a message to all players with this role
-- @tparam message string the message that will be printed to the players
-- @treturn number the number of players who received the message
function Roles._prototype:print(message)
    local players = self:get_players(true)
    for _,player in pairs(players) do
        player.print(message)
    end
    return #players
end

--- Used internally to be the first trigger on an event change, would be messy to include this in 4 different places
local function role_update(event)
    local player = Game.get_player_by_index(event.player_index)
    -- Updates flags given to the player
    for flag,callback in pairs(Roles.config.flags) do
        local state = Roles.player_has_flag(player,flag)
        local success,err = pcall(callback,player,state)
        if not success then
            log{'expcore-roles.error-log-format-flag',flag,err}
        end
    end
    -- Updates the players permission group
    local highest = Roles.get_player_highest_role(player)
    if highest.permission_group then
        if highest.permission_group[1] then
            local group = game.permissions.get_group(highest.permission_group[2])
            if group then
                group.add_player(player)
            end
        else
            Groups.set_player_group(player,highest.permission_group)
        end
    end
end

--- When a player joined or has a role change then the update is triggered
Event.add(Roles.player_role_assigned,role_update)
Event.add(Roles.player_role_unassigned,role_update)
Event.add(defines.events.on_player_joined_game,role_update)
-- Every 60 seconds the auto promote check is preformed
Event.on_nth_tick(3600,function()
    local promotes = {}
    for _,player in pairs(game.connected_players) do
        for _,role in pairs(Roles.config.roles) do
            if role.auto_promote_condition then
                local success,err = pcall(role.auto_promote_condition,player)
                if not success then
                    log{'expcore-roles.error-log-format-promote',role.name,err}
                else
                    if err == true and not Roles.player_has_role(player,role) then
                        if promotes[player.name] then
                            table.insert(promotes[player.name],role.name)
                        else
                            promotes[player.name] = {role.name}
                        end
                    end
                end
            end
        end
    end
    for player_name,roles in pairs(promotes) do
        Roles.assign_player(player_name,roles)
    end
end)

-- Return Roles
return Roles