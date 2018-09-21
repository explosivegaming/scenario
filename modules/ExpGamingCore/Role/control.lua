--- Adds roles where a player can have more than one role
-- @module ExpGamingCore.Role@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/releases/download/v4.0-core/ExpGamingCore.Ranking_4.0.0.zip
-- @alais Role 

-- Module Require
local Group = require('ExpGamingCore.Group@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Local Varibles
local role_change_event_id = script.generate_event_name()

-- Module Define
local module_verbose = false
local Role = {
    _prototype={},
    order={},
    flags={},
    actions={},
    meta={},
    roles=setmetatable({},{
        __index=table.autokey,
        __newindex=function(tbl,key,value)
            rawset(tbl,key,Role.define(value))
        end
    }),
    on_init=function()
        if loaded_modules['ExpGamingCore.Server@^4.0.0'] then require('ExpGamingCore.Server@^4.0.0').add_module_to_interface('Role','ExpGamingCore.Role') end
    end,
    on_post=function(self)
        -- loads the roles in config
        require(module_path..'/config',{Role=self})
        -- joins role allows into a chain
        local previous
        for index,role_name in pairs(self.order) do
            local role = self.get(role_name)
            if not role then error('Invalid role name in order listing: '..role_name) return end
            if role.is_default then self.meta.default = role end
            if previous then setmetatable(previous.allow,{__index=role.allow}) end
            role.index = index
            previous = role
        end
        if previous then setmetatable(previous.allow,{__index=function(tbl,key) return false end})
        else error('Invalid roles, no roles to load.') end
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
    local player = game and Game.get_player(mixed)
    if player then 
        local rtn = {}
        if not global.players[player.index] then return Role.meta.default and {Role.meta.default} or {} end
        for _,role in pairs(global.players[player.index]) do table.insert(rtn,Role.get(role)) end
        return rtn
    elseif is_type(mixed,'table') and mixed.group then return mixed
    elseif is_type(mixed,'string') then return Role.roles[mixed] end
end

-- gives a player a role by name or a table of roles
function Role.assign(player,role,no_log)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.assign.',2) return end
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for _,_role in ipairs(role) do ctn=ctn+1 Role.assign(player,_role,true) end 
        if ctn > 0 then if not no_log then table.insert(global.changes[player.index],{'assign',role.name}) end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role #2 given to Role.assign.',2) return end
    -- this acts as a way to provent the global table getting too full
    if not global.changes[player.index] then global.changes[player.index]={} end
    if #global.changes[player.index] > 20 then table.remove(global.changes[player.index],1) end
    if not no_log then table.insert(global.changes[player.index],{'assign',role.name}) end
    return role:add_player(player)
end

-- removes a player from a role by name or a table of roles
function Role.unassign(player,role,no_log)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.unassign.',2) return end
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for _,_role in ipairs(role) do ctn=ctn+1 Role.unassign(player,_role,true) end 
        if ctn > 0 then if not no_log then table.insert(global.changes[player.index],{'unassign',role.name}) end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role #2 given to Role.unassign.',2) return end
    if not global.changes[player.index] then global.changes[player.index]={} end
    -- this acts as a way to provent the global table getting too full
    if #global.changes[player.index] > 20 then table.remove(global.changes[player.index],1) end
    if not no_log then table.insert(global.changes[player.index],{'unassign',role.name}) end
    return role:remove_player(player)
end

-- gets the highest role from a set of options; player can be passed
function Role.get_highest(options)
    local player = Game.get_player(options)
    if player then options = Role.get(player) end
    if not type_error(options,'table','Invalid argument #1 to Role.highest, options is not a table of roles.') then return end
    local highest_index = -1
    local highest
    for _,role_name in pairs(options) do
        local role = Role.get(role_name)
        if not role then error('Invalid role inside options: '..serpent.line(role_name)) return end
        if highest_index == -1 or role.index < highest_index then highest_index,highest = role.index,role end
    end
    return highest
end

-- reverts the last change to a user's roles
function Role.revert(player,count)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.revert.',2) return end
    if count and not type_error(count,'number','Invalid argument #2 to Role.revert, count is not a number.') then return end
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
    if not type_error(flag,'string','Invalid argument #1 to Role.add_flag, flag is not a string.') then return end
    if callback and not type_error(callback,'function','Invalid argument #2 to Role.add_flag, callback is not a function.') then return end
    verbose('Added flag: '..flag)
    Role.flags[flag] = callback or true
end

-- tests if mixed (either player or role) has the requested flag
function Role.has_flag(mixed,flag)
    if not type_error(flag,'string','Invalid argument #2 to Role.has_flag, flag is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument #1 to Role.has_flag, mixed is not a role or player.') then return end
    if #roles then for _,role in pairs(roles) do
        if role:has_flag(flag) then return true end
    end elseif roles:has_flag(flag) then return true end
    return false
end

-- allows a table to be made that includes all possible actions and thus can test who is allowed
-- used purly as a way to loop over all actions
function Role.add_action(action)
    if not type_error(action,'string','Invalid argument #1 to Role.add_action, action is not a string.') then return end
    verbose('Added action: '..action)
    table.insert(Role.actions,action)
end

-- returns if mixed (either player or role) is allowed to do this action
function Role.allowed(mixed,action)
    if not type_error(action,'string','Invalid argument #2 to Role.allowed, action is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument #1 to Role.allowed, mixed is not a role or player.') then return end
    if #roles then for _,role in pairs(roles) do
        if role:allowed(action) then return true end
    end elseif roles:allowed(action) then return true end
    return false
end

-- prints to this role and all below it or above if inv
function Role.print(role,rtn,colour,inv)
    local role = Role.get(role)
    if not type_error(role,'table','Invalid argument #1 to Role.print, role is invalid.') then return end
    if colour and not type_error(colour,'table','Invalid argument #3 to Role.print, colour is not a table.') then return end
    if inv and not type_error(inv,'boolean','Invalid argument #4 to Role.print, inv is not a boolean.') then return end
    local print = inv or false
    local ctn = 0
    for index,_role in pairs(Role.roles) do
        if print or _role == role then ctn=ctn+_role:print(rtn,colour) end
        if _role == role then if print then break else print = true end end
    end
    return ctn
end

-- outputs all roles for debug purposes
function Role.debug_output(role,player)
    local player = Game.get_player(player) or game.player
    if not player then error('Invalid player #2 given to Role.debug_output.',2) return end
    local function _output(_role)
        local flags = {};for flag in pairs(Role.flags) do if _role:has_flag(flag) then table.insert(flags,flag) end end
        local rtn = string.format('%s) %q-%q || Tag: %s Short Hand: %q Time: %s Flags: %s',
        _role.index,_role.group.name,_role.name,_role.tag,_role.short_hand,tostring(_role.time),table.concat(flags,', '))
        player_return(rtn,_role.colour,player)
    end
    if role then
        local role = Role.get(mixed)
        if not type_error(roles,'table','Invalid argument #1 to Role.print, role is invalid.') then return end
        _output(role)
    else for index,_role in pairs(Role.roles) do _output(_role) end end
end

-- returns true if this role has this flag set
function Role._prototype:has_flag(flag)
    if not self_test(self,'role','has_flag') then return end
    if not type_error(flag,'string','Invalid argument #1 to role:has_flag, flag is not a string.') then return end
    return self[flag] or false
end

-- returns true if the rank is allowed, indexing with metatables for inheraitance
function Role._prototype:allowed(action)
    if not self_test(self,'role','allowed') then return end
    if not type_error(action,'string','Invalid argument #1 to role:allowed, action is not a string.') then return end
    return self.allow[action] or self.is_root or false -- still include is_root exception flag
end

-- gets the players in this role and online only if online is true
function Role._prototype:get_players(online)
    if not self_test(self,'role','get_players') then return end
    if online and not type_error(online,'boolean','Invalid argument #1 to role:get_players, online is not a boolean.') then return end
    if not global.roles[self.name] then global.roles[self.name] = {} end
    local rtn = {}
    for _,player_index in pairs(global.roles[self.name]) do
        local player = game.players[player_index]
        if player and not online or player.connected then table.insert(rtn,player) end
    end
    return rtn
end

-- prints a message to all players with this role
function Role._prototype:print(rtn,colour)
    if not self_test(self,'role','print') then return end
    if colour and not type_error(colour,'table','Invalid argument #2 to Role.print, colour is not a table.') then return end
    local ctn = 0
    for _,player in pairs(self:get_players(true)) do ctn=ctn+1 player_return(rtn,colour,player) end
    return ctn
end

-- runs though Role.actions and returns a list of which this role can do
function Role._prototype:get_permissions()
    if not self_test(self,'role','get_permissions') then return end
    local rtn = {}
    for _,action in pairs(Role.actions) do rtn[action] = self:allowed(action) end
    return rtn
end

-- adds a player to this role
function Role._prototype:add_player(player,by_player)
    if not self_test(self,'role','add_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to role:add_player.',2) return end
    local by_player = Game.get_player(by_player)
    if not by_player then by_player = {name='<server>',index=0} end
    if not global.roles[self.name] then global.roles[self.name] = {} end
    if not global.players[player.index] then global.players[player.index] = {} end
    local highest = Role.get_highest(player) or Role.meta.default
    table.insert(global.roles[self.name],player.index)
    table.insert(global.players[player.index],self.name)
    script.raise_event(role_change_event_id,{
        name=role_change_event_id,
        tick=game.tick,
        player_index=player.index,
        by_player_index=by_player.index,
        old_highest=highest.name,
        role_name=self.name,
        effect='assign'
    })
end

-- removes a player from this role
function Role._prototype:remove_player(player,by_player)
    if not self_test(self,'role','add_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to role:remove_player.',2) return end
    local by_player = Game.get_player(by_player) or {name='<server>',index=0}
    if not global.roles[self.name] then global.roles[self.name] = {} end
    if not global.players[player.index] then global.players[player.index] = {} end
    local highest = Role.get_highest(player) or Role.meta.default
    local index = 0
    for _index,player_index in pairs(global.roles[self.name]) do if player_index == player.index then index=_index break end end
    table.remove(global.roles[self.name],index)
    for _index,role_name in pairs(global.players[player.index]) do if role_name == self.name then index=_index break end end
    table.insert(global.players[player.index],index)
    script.raise_event(role_change_event_id,{
        name=role_change_event_id,
        tick=game.tick,
        player_index=player.index,
        by_player_index=by_player.index,
        old_highest=highest.name,
        role_name=self.name,
        effect='unassign'
    })
end

-- Event Handlers Define
script.on_event(role_change_event_id,function(event)
    -- varible init
    local player = Game.get_player(event)
    local by_player = Game.get_player(event.by_player_index) or {name='<server>',index=0}
    local role = Role.get(event.role_name)
    local highest = Role.get_highest(player)
    -- assign new tag and group of highest role
    Group.assign(player,highest.group) 
    player.tag = highest.tag
    -- play a sound to the player
    if event.effect == 'assign' and not role.is_jail then player.play_sound{path='utility/achievement_unlocked'} 
    else player.play_sound{path='utility/game_lost'} end
    if player.online_time > 60 then
        -- send a message to other players
        if event.effect == 'assign' then game.print(player.name..' was assigned the new role: '..role.name)
        else game.print(player.name..' was unassigned the role: '..role.name) end
        -- log change to file
        game.write_file('ranking-change.json',
            table.json({
                tick=game.tick,
                play_time=player.online_time,
                player_name=player.name,
                by_player_name=by_player.name,
                role_name=role.name,
                highest_role_name=highest.name,
                effect=event.effect
            })..'\n'
        , true, 0)
    end
end)

-- Module Return
return setmetatable(Role,{__call=function(tbl,...) tbl.define(...) end}) 