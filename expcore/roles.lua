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

local function emit_player_roles_updated(player,type,roles,by_player_name)
    by_player_name = game.player and game.player.name or by_player_name or '<server>'
    local event = Roles.player_role_assigned
    if type == 'unassign' then
        event = Roles.player_role_unassigned
    end
    local by_player = Game.get_player_from_any(by_player_name)
    local by_player_index = by_player and by_player.index or 0
    local role_names = {}
    for _,role in pairs(roles) do
        role = Roles.get_role_from_any(role)
        if role then
            table.insert(role_names,role.name)
        end
    end
    game.print({'expcore-roles.game-message-'..type,player.name,table.concat(role_names,', '),by_player_name},Colours.cyan)
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
        roles_changed=roles
    }..'\n',true,0)
end

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

function Roles.debug()
    local output = ''
    for index,role_name in pairs(Roles.config.order) do
        local role = Roles.config.roles[role_name]
        local color = role.custom_color or Colours.white
        color = string.format('[color=%d,%d,%d]',color.r,color.g,color.b)
        output = output..string.format('\n%s %s) %s',color,index,serpent.line(role))
    end
    return output
end

function Roles.get_role_by_name(name)
    return Roles.config.roles[name]
end

function Roles.get_role_by_order(index)
    local name = Roles.config.order[index]
    return Roles.config.roles[name]
end

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

function Roles.assign_player(player,roles,by_player_name)
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
    emit_player_roles_updated(player,'assign',roles,by_player_name)
end

function Roles.unassign_player(player,roles,by_player_name)
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
    emit_player_roles_updated(player,'unassign',roles,by_player_name)
end

function Roles.override_player_roles(roles)
    Roles.config.players = roles
end

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

function Roles.define_role_order(order)
    Roles.config.order = {}
    for _,role in ipairs(order) do
        if type(role) == 'table' and role.name then
            table.insert(Roles.config.order,role.name)
        else
            table.insert(Roles.config.order,role)
        end
    end
    for index,role in pairs(Roles.config.order) do
        role = Roles.config.roles[role]
        role.index = index
        local parent = Roles.config.roles[role.parent]
        if parent then
            setmetatable(role.allowed_actions,{__index=parent.allowed_actions})
        end
    end
end

function Roles.define_flag_trigger(name,callback)
    Roles.config.flags[name] = callback -- this can desync if there are upvalues
end

function Roles.set_default(name)
    local role = Roles.config.roles[name]
    if not role then return end
    Roles.config.internal.default = name
end

function Roles.set_root(name)
    local role = Roles.config.roles[name]
    if not role then return end
    Roles.config.internal.root = name
end

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

function Roles._prototype:set_allow_all(state)
    self.allow_all_actions = not not state
    return self
end

function Roles._prototype:allow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self.allowed_actions[action]=true
    end
    return self
end

function Roles._prototype:disallow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self.allowed_actions[action]=false
    end
    return self
end

function Roles._prototype:is_allowed(action)
    local is_root = Roles.config.internal.root.name == self.name
    return self.allowed_actions[action] or self.allow_all_actions or is_root
end

function Roles._prototype:set_flag(name,value)
    self.flags[name] = value
    return self
end

function Roles._prototype:clear_flags()
    self.flags = {}
    return self
end

function Roles._prototype:has_flag(name)
    return self.flags[name] or false
end

function Roles._prototype:set_custom_tag(tag)
    self.custom_tag = tag
    return self
end

function Roles._prototype:set_custom_color(color)
    if type(color) ~= 'table' then
        color = Colours[color]
    end
    self.custom_color = color
    return self
end

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

function Roles._prototype:set_parent(role)
    self.parent = role
    role = Roles.get_role_from_any(role)
    if not role then return self end
    setmetatable(self.allowed_actions, {__index=role.allowed_actions})
    return self
end

function Roles._prototype:set_auto_promote_condition(callback)
    self.auto_promote_condition = callback
    return self
end

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

function Roles._prototype:print(message)
    local players = self:get_players(true)
    for _,player in pairs(players) do
        player.print(message)
    end
    return #players
end

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
    local highest
    local roles = Roles.get_player_roles(player)
    for _,role in pairs(roles) do
        if not highest or role.index < highest.index then
            highest = role
        end
    end
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

Event.add(Roles.player_role_assigned,role_update)
Event.add(Roles.player_role_unassigned,role_update)
Event.add(defines.events.on_player_joined_game,role_update)
Event.on_nth_tick(300,function()
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

return Roles