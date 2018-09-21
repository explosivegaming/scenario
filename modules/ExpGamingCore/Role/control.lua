--- Adds roles where a player can have more than one role
-- @module ExpGamingCore.Role@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/releases/download/v4.0-core/ExpGamingCore.Ranking_4.0.0.zip
-- @alais Role 

-- Module Require
local Group = require('ExpGamingCore.Group@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Local Varibles

-- Module Define
local module_verbose = false
local Role = {
    _prototype={},
    order={},
    flags={},
    actions={},
    roles=setmetatable({},{
        __index=table.autokey,
        __newindex=function(tbl,key,value)
            rawset(tbl,key,Role.define(value))
        end
    }),
    on_init=function()
        --code
    end,
    on_post=function(self)
        -- loads the roles in config
        require(module_path..'/config',{Role=self})
    end
}

-- Global Define
local global = global{
    changes={},
    players={},
    roles={}
}

-- Function Define

-- creates role object
function Role.define(obj) 
    if not type_error(game,nil,'Cant define Role during runtime.') then return end
    if not type_error(obj.name,'string','Role creation is invalid: role.name is not a string') then return end
    if not is_type(obj.short_hand,'string') then obj.short_hand = obj.name:sub(1,3) end
    if not is_type(obj.tag,'string') then obj.tag = '['..obj.short_hand..']' end
    if not type_error(obj.colour,'table','Role creation is invalid: role.colour is not a table') then return end
    if not type_error(obj.allow,'table','Role creation is invalid: role.allow is not a table') then return end
    obj.group = Group.get(obj.group)
    if not type_error(obj.group,'table','Role creation is invalid: role.group is invalid') then return end
    if obj.time and not type_error(obj.time,'number','Role creation is invalid: role.time is not a number') then return end
    verbose('Created Role: '..obj.name)
    setmetatable(obj,{__index=Role._prototype})
    rawset(Role.roles,obj.name,obj)
    table.insert(Role.order,obj.name)
    return obj
end

-- gets all roles of a user or a role by name
function Role.get(mixed)
    local player = Game.get_player(mixed)
    if player then return global.players[player.index] and global.players[player.index] or {} end -- add some thing about default role here
    return Roles.roles[mixed]
end

-- gives a player a role by name or a table of roles
function Role.assign(player,role,no_log)
    local player = Game.get_player(player)
    if not player then error('Invalid player given to Role.assign.',2) return end
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for _,_role in ipairs(role) do ctn=ctn+1 Role.assign(player,_role,true) end 
        if ctn > 0 then if not no_log then table.insert(global.changes[player.index],{'assign',role.name}) end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role given to Role.assign.',2) return end
    -- this acts as a way to provent the global table getting too full
    if not global.changes[player.index] then global.changes[player.index]={} end
    if #global.changes[player.index] > 20 then table.remove(global.changes[player.index],1) end
    if not no_log then table.insert(global.changes[player.index],{'assign',role.name}) end
    return role:add_player(player)
end

-- removes a player from a role by name or a table of roles
function Role.unassign(player,role,no_log)
    local player = Game.get_player(player)
    if not player then error('Invalid player given to Role.unassign.',2) return end
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for _,_role in ipairs(role) do ctn=ctn+1 Role.unassign(player,_role,true) end 
        if ctn > 0 then if not no_log then table.insert(global.changes[player.index],{'unassign',role.name}) end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role given to Role.unassign.',2) return end
    if not global.changes[player.index] then global.changes[player.index]={} end
    -- this acts as a way to provent the global table getting too full
    if #global.changes[player.index] > 20 then table.remove(global.changes[player.index],1) end
    if not no_log then table.insert(global.changes[player.index],{'unassign',role.name}) end
    return role:remove_player(player)
end

-- gets the highest role from a set of options; player can be passed
function Role.highest(options)
    if not type_error(options,'table','Invalid argument to Role.highest, options is not a table of roles.') then return end
    local highest_index = -1
    local highest
    for _,role in pairs(options) do
        local role = Role.get(role)
        if highest_index == -1 or role.index < highest_index then highest_index,highest = role.index,role end
    end
    return highest
end

-- reverts the last change to a user's roles
function Role.revert(player,count)
    local player = Game.get_player(player)
    if not player then error('Invalid player given to Role.revert.',2) return end
    if count and not type_error(count,'number','Invalid argument to Role.revert, count is not a number.') then return end
    local changes = global.changes[player.index] or {}
    if #changes == 0  then error('Player has no role changes logged, can not revert.') end
    local count = count or 1
    local ctn = 0
    if count > #changes then count = #changes end
    for i = 1,count do
        local change = table.remove(changes,1)
        if not change then break end
        if change[1] == 'assign' then Role.unassign(player,change[2],true) end
        if change[1] == 'unassign' then Role.assign(player,change[2],true) end
        ctn=ctn+1
    end
    return ctn
end

-- when a role has the given flag the callback is called, params: player, state
-- all the flags a player has are combined with true as pirority
-- example Role.add_flag('is_admin',function(player,state) player.admin = state end)
function Role.add_flag(flag,callback)
    if not type_error(flag,'string','Invalid argument to Role.add_flag, flag is not a string.') then return end
    if callback and not type_error(callback,'function','Invalid argument to Role.add_flag, callback is not a function.') then return end
    verbose('Added flag: '..flag)
    Role.flags[flag] = callback or true
end

-- tests if mixed (either player or role) has the requested flag
function Role.has_flag(mixed,flag)
    if not type_error(flag,'string','Invalid argument to Role.has_flag, flag is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument to Role.has_flag, mixed is not a role or player.') then return end
    if #roles then for _,role in pairs(roles) do
        if role:has_flag(flag) then return true end
    end elseif roles:has_flag(flag) then return true end
    return false
end

-- allows a table to be made that includes all possible actions and thus can test who is allowed
-- used purly as a way to loop over all actions
function Role.add_action(action)
    if not type_error(action,'string','Invalid argument to Role.add_action, action is not a string.') then return end
    verbose('Added action: '..action)
    table.insert(Role.actions,action)
end

-- returns if mixed (either player or role) is allowed to do this action
function Role.allowed(mixed,action)
    if not type_error(action,'string','Invalid argument to Role.allowed, action is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument to Role.allowed, mixed is not a role or player.') then return end
    if #roles then for _,role in pairs(roles) do
        if role:allowed(flag) then return true end
    end elseif roles:allowed(flag) then return true end
    return false
end

-- prints to this role and all below it or above if inv
function Role.print(role,rtn,colour,inv)
    local role = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument to Role.print, role is invalid.') then return end
    if colour and not type_error(colour,'table','Invalid argument to Role.print, colour is not a table.') then return end
    if inv and not type_error(inv,'boolean','Invalid argument to Role.print, inv is not a boolean.') then return end
    local print = inv or false
    local ctn = 0
    for index,role_name in pairs(Role.roles) do
        if print then ctn=ctn+Role.roles[role_name]:print(rtn,colour) end
        if role_name == role.name then if print then break else print = true end end
    end
    return ctn
end

-- outputs all roles for debug purposes
function Role.debug_output(role,player)
    local player = Game.get_player(player) or game.player
    if not player then error('Invalid player given to Role.debug_output.',2) return end
    local function _output(role)
        local flags = {};for flag in pairs(Role.flags) do if role:has_flag(flag) then table.insert(flags,flag) end end
        local rtn = string.format('%s) %q %s > Group: %q Time: %s Flags: %s',
        role.index,role.name,role.tag,role.group,tostring(role.time),table.concat(flags,','))
        player_return(rtn,role.colour,player)
    end
    if role then
        local role = Role.get(mixed)
        if not type_error(roles,'table','Invalid argument to Role.print, role is invalid.') then return end
        _output(role)
    else for index,role_name in pairs(Role.roles) do _output(Role.roles[role_name]) end end
end

function Role._prototype:has_flag(flag)
    -- if this role has this flag
end

function Role._prototype:allowed(action)
    -- if this role is allowed this action
end

function Role._prototype:get_players(online)
    -- gets all/online players who have this role
end

function Role._prototype:print(rtn,colour)
    -- prints a message to all players with this role
end

function Role._prototype:get_permissions()
    -- runs though Role.actions and returns a list of which this role can do
end

function Role._prototype.add_player(player)
    -- adds a player to this role
end

function Role._prototype.remove_player(player)
    -- removes this role from the player
end

-- Event Handlers Define

-- event call for role updates

-- Module Return
return setmetatable(Role,{__call=function(tbl,...) tbl.define(...) end}) 