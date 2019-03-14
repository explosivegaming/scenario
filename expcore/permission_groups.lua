local Game = require 'utils.game'
local Event = require 'utils.event'

local Permissions_Groups = {
    groups={}, -- store for the different groups that are created
    _prototype={} -- stores functions that are used on group instances
}

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

function Permissions_Groups.get_group_by_name(name)
    return Permissions_Groups.groups[name]
end

function Permissions_Groups.get_group_from_player(player)
    player = Game.get_player_from_any(player)
    local group = player.permission_group
    if group then
        return Permissions_Groups.groups[group.name]
    end
end

function Permissions_Groups.reload_permissions()
    for _,group in pairs(Permissions_Groups.groups) do
        group:create()
    end
end

function Permissions_Groups.lockdown_permissions(exempt)
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
        if not exempt[group.name:lower()] then
            for _,action in pairs(defines.input_action) do
                group.set_allows_action(action,false)
            end
        end
    end
end

function Permissions_Groups.set_player_group(player,group)
    player = Game.get_player_from_any(player)
    local group = Permissions_Groups.get_group_by_name(group)
    group:add_player(player)
end

function Permissions_Groups._prototype:set_action(action,state)
    if type(action) == 'string' then
        action = defines.input_action[action]
    end
    self.actions[action] = state
    return self
end

function Permissions_Groups._prototype:allow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self:set_action(action,true)
    end
    return self
end

function Permissions_Groups._prototype:disallow(actions)
    if type(actions) ~= 'table' then
        actions = {actions}
    end
    for _,action in pairs(actions) do
        self:set_action(action,false)
    end
    return self
end

function Permissions_Groups._prototype:allow_all()
    self.allow_all_actions = true
    return self
end

function Permissions_Groups._prototype:disallow_all()
    self.allow_all_actions = false
    return self
end

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

function Permissions_Groups._prototype:get_raw()
    return game.permissions.get_group(self.name)
end

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

function Permissions_Groups._prototype:add_player(player)
    player = Game.get_player_from_any(player)
    local group = self:get_raw()
    group.add_player(player)
end

function Permissions_Groups._prototype:remove_player(player)
    player = Game.get_player_from_any(player)
    local group = self:get_raw()
    group.remove_player(player)
end

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

function Permissions_Groups._prototype:print(message)
    local players = self:get_players(true)
    for _,player in pairs(players) do
        player.print(message)
    end
    return #players
end

Event.on_init(function()
    Permissions_Groups.reload_permissions()
end)

return Permissions_Groups