--- Adds roles where a player can have more than one role
-- @module ExpGamingCore.Role@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais Role 

-- Module Require
local Group = require('ExpGamingCore.Group@^4.0.0')
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Local Varibles
local role_change_event_id = script.generate_event_name('on_role_change')

-- Module Define
local module_verbose = false
local Role = {
    _prototype={},
    order={},
    flags={},
    actions={},
    preassign={},
    meta={times={},groups={},count=0},
    roles=setmetatable({},{
        __index=table.autokey,
        __newindex=function(tbl,key,value)
            rawset(tbl,key,Role.define(value))
        end
    }),
    on_init=function(self)
        if loaded_modules['ExpGamingCore.Server@^4.0.0'] then require('ExpGamingCore.Server@^4.0.0').add_module_to_interface('Role','ExpGamingCore.Role') end
        if loaded_modules['ExpGamingCore.Command@^4.0.0'] then require(module_path..'/src/commands',{self=self}) end
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
            if role.is_timed then self.meta.times[role.name] = {index,role.time} end
            if not self.meta.groups[role.group.name] then self.meta.groups[role.group.name] = {lowest=index,highest=index} end
            if self.meta.groups[role.group.name].highest > index then self.meta.groups[role.group.name].highest = index end
            if self.meta.groups[role.group.name].lowest < index then self.meta.groups[role.group.name].lowest = index end
            if previous then setmetatable(previous.allow,{__index=role.allow}) end
            self.meta.count = self.meta.count+1
            role.index = index
            previous = role
        end
        if previous then setmetatable(previous.allow,{__index=function(tbl,key) return false end})
        else error('Invalid roles, no roles to load.') end
    end
}

-- Global Define
local global = global{
    change_chache_length=15,
    changes={},
    latest_change={},
    preassign={},
    players={},
    roles={}
}

-- Function Define

--- Used to set default roles for players who join
-- @usage Role.set_preassign{name={roles}}
function Role.set_preassign(tbl) if game then global.pressign = tbl else Role.preassign = tbl end end

--- Defines a new instance of a role
-- @usage Role.define{name='Root',short_hand='Root',tag='[Root]',group='Root',colour={r=255,b=255,g=255},is_root=true,allow={}} -- returns new role
-- @usage Role{name='Root',short_hand='Root',tag='[Root]',group='Root',colour={r=255,b=255,g=255},is_root=true,allow={}} -- returns new role
-- @tparam table obj contains the strings: name,short_hand,tag a table called allow a table called colour and a pointer to a permission group
-- @treturn Role the role which has been made
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
    obj.connected_players = setmetatable({self=obj,connected=true},Role._prototype.players_mt)
    obj.players = setmetatable({self=obj},Role._prototype.players_mt)
    rawset(Role.roles,obj.name,obj)
    table.insert(Role.order,obj.name)
    return obj
end

--- Used to get the role of a player or the role by name
-- @usage Role.get('foo') -- returns group foo
-- @usage Role.get(player) -- returns group of player
-- @tparam ?LuaPlayer|pointerToPlayer|string mixed can either be the name of the role or a player indenifier
-- @treturn table the group which was found or nil
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

--- Used to place a player into a role(s)
-- @usage Role.assign(player,'Root')
-- @usage Role.assign(player,{'Root','Foo'})
-- @tparam ?LuaPlayer|pointerToPlayer player the player to assign the role to
-- @tparam ?string|role|table the role to add the player to, if its a table then it will act recursly though the table
-- @tparam[opt='<server>'] ?LuaPlayer|pointerToPlayer by_player the player who assigned the roles to the player
-- @tparam[opt] table batch this is used internally to provent multiple event calls, conatins {role_index_in_batch,batch}
-- @treturn boolean was the player assigned the roles
function Role.assign(player,role,by_player,batch)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.assign.',2) return end
    verbose('Assigning Roles: '..serpent.line(role)..' to: '..player.name)
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for n,_role in ipairs(role) do ctn=ctn+1 Role.assign(player,_role,by_player,{n,role}) end 
        if ctn > 0 then if not batch then table.insert(global.changes[player.index],{'assign',role}) global.latest_change = {player.index,'assign',role} end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role #2 given to Role.assign.',2) return end
    -- this acts as a way to provent the global table getting too full
    if not global.changes[player.index] then global.changes[player.index]={} end
    if #global.changes[player.index] > global.change_chache_length then table.remove(global.changes[player.index],1) end
    if not batch then table.insert(global.changes[player.index],{'assign',role.name}) global.latest_change = {player.index,'assign',role.name} end
    return role:add_player(player,by_player,batch)
end

--- Used to remove a player from a role(s)
-- @usage Role.unassign(player,'Root')
-- @tparam ?LuaPlayer|pointerToPlayer player the player to unassign the role to
-- @tparam ?string|role|table role the role to remove the player from, if its a table then it will act recursly though the table
-- @tparam[opt='<server>'] ?LuaPlayer|pointerToPlayer by_player the player who unassigned the roles from the player
-- @tparam[opt] table batch this is used internally to provent multiple event calls
-- @treturn boolean was the player unassigned the roles
function Role.unassign(player,role,by_player,batch)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.unassign.',2) return end
    verbose('Assigning Roles: '..serpent.line(role)..' to: '..player.name)
    -- this loops over a table of role if given; will return if ipairs returns, else will asume it was ment to be a role and error
    if is_type(role,'table') and not role.name then 
        local ctn = 0 
        for n,_role in ipairs(role) do ctn=ctn+1 Role.unassign(player,_role,by_player,{n,role}) end  
        if ctn > 0 then if not batch then table.insert(global.changes[player.index],{'unassign',role}) global.latest_change = {player.index,'unassign',role} end return end 
    end
    local role = Role.get(role)
    if not role then error('Invalid role #2 given to Role.unassign.',2) return end
    if not global.changes[player.index] then global.changes[player.index]={} end
    -- this acts as a way to provent the global table getting too full
    if #global.changes[player.index] > global.change_chache_length then table.remove(global.changes[player.index],1) end
    if not batch then table.insert(global.changes[player.index],{'unassign',role.name}) global.latest_change = {player.index,'unassign',role.name} end
    return role:remove_player(player,by_player,batch)
end

--- Returns the highest role given in a list, if a player is passed then it returns the highest role of the player
-- @usage Role.get_highest{'Root','Admin','Mod'} -- retuns Root (given that root is highest)
-- @usage Role.get_highest(player) -- returns the players highest role
-- @tparam ?table|LuaPlayer|pointerToPlayer options table of options or a player
-- @treturn role the highest role given in the options
function Role.get_highest(options)
    local player = Game.get_player(options)
    if player then options = Role.get(player) end
    if not type_error(options,'table','Invalid argument #1 to Role.get_highest, options is not a table of roles.') then return end
    local highest_index = -1
    local highest
    for _,role_name in pairs(options) do
        local role = Role.get(role_name)
        if not role then error('Invalid role inside options: '..serpent.line(role_name)) return end
        if highest_index == -1 or role.index < highest_index then highest_index,highest = role.index,role end
    end
    return highest
end

--- Uses the change chache to revert changes to players roles
-- @usage Role.revert(player) -- reverts the last change to the players roles
-- @tparam ?LuaPlayer|pointerToPlayer player the player to revert the changes of
-- @tparam[opt] ?LuaPlayer|pointerToPlayer the player who proformed the role revert
-- @tparam[opt=1] count the number of reverts to do, if 0 all changes chached are reverted
-- @treturn number the number of changes that occured
function Role.revert(player,by_player,count)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Role.revert.',2) return end
    if count and not type_error(count,'number','Invalid argument #2 to Role.revert, count is not a number.') then return end
    local changes = global.changes[player.index] or {}
    if #changes == 0  then error('Player has no role changes logged, can not revert.') end
    local count = count or 1
    local ctn = 0
    if count > #changes or count == 0 then count = #changes end
    for i = 1,count do
        local change = table.remove(changes)
        if not change then break end
        if change[1] == 'assign' then Role.unassign(player,change[2],by_player,true) end
        if change[1] == 'unassign' then Role.assign(player,change[2],by_player,true) end
        ctn=ctn+1
    end
    return ctn
end

--- Adds a flag which can be set on roles; these flags act as a quick way to access general role changes
-- @usage Role.add_flag('is_admin',function(player,state) player.admin = state end) -- the function is passed player and if the flag is true or false
-- @tparam string flag the name of the falg that is being added
-- @tparam[opt] function callback the function(player,state) which is called when a player loses or gains a flag, if nil no function is called
function Role.add_flag(flag,callback)
    if not type_error(flag,'string','Invalid argument #1 to Role.add_flag, flag is not a string.') then return end
    if callback and not type_error(callback,'function','Invalid argument #2 to Role.add_flag, callback is not a function.') then return end
    verbose('Added flag: '..flag)
    Role.flags[flag] = callback or true
end

--- Checks if a player or role has the requested flag, if player all roles of player are checked (true has pirortiy)
-- @usage Role.has_flag(role,'is_admin') -- returns true if this role has is_admin set
-- @tparam role|LuaPlayer|pointerToPlayer mixed the player or role that will be tested
-- @tparam string flag the flag to test for
-- @treturn boolean if the flag was true or false, false if nil
function Role.has_flag(mixed,flag)
    if not type_error(flag,'string','Invalid argument #2 to Role.has_flag, flag is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument #1 to Role.has_flag, mixed is not a role or player.') then return end
    if #roles > 0 then for _,role in pairs(roles) do
        if role:has_flag(flag) then return true end
    end elseif roles:has_flag(flag) then return true end
    return false
end

--- Adds a action to be used by the role system
-- @usage Role.add_action('foo')
-- @tparam string action the name of the action that will be added
function Role.add_action(action)
    if not type_error(action,'string','Invalid argument #1 to Role.add_action, action is not a string.') then return end
    verbose('Added action: '..action)
    table.insert(Role.actions,action)
end

--- Checks if a player or role is allowed the requested action, if player all roles of player are checked (true has pirortiy)
-- @usage Role.allowed(role,'foo') -- returns true if this role is allowed 'foo'
-- @tparam ?role|LuaPlayer|pointerToPlayer mixed the player or role that will be tested
-- @tparam string action the action to test for
-- @treturn boolean if the action is allowed for the player or role
function Role.allowed(mixed,action)
    if not type_error(action,'string','Invalid argument #2 to Role.allowed, action is not a string.') then return end 
    local roles = Role.get(mixed)
    if not type_error(roles,'table','Invalid argument #1 to Role.allowed, mixed is not a role or player.') then return end
    if #roles > 0 then for _,role in pairs(roles) do
        if role:allowed(action) then return true end
    end elseif roles:allowed(action) then return true end
    return false
end

--- Prints to all roles and players of those roles which are greater than the given role (or if inv then all below)
-- @usage Role.print('Admin','Hello, World!') -- returns the number of players who recived the message
-- @tparam ?role|string role the role which acts as the turning point of the print (always included regardless of inv value)
-- @param rtn the value that will be returned to the players
-- @tparam[opt] table colour the colour that you want the message printed in
-- @tparam[opt=false] boolean inv true to print to roles below, false to print to roles above
-- @treturn number the number of players who recived the message 
function Role.print(role,rtn,colour,inv)
    local role = Role.get(role)
    if not type_error(role,'table','Invalid argument #1 to Role.print, role is invalid.') then return end
    if colour and not type_error(colour,'table','Invalid argument #3 to Role.print, colour is not a table.') then return end
    if inv and not type_error(inv,'boolean','Invalid argument #4 to Role.print, inv is not a boolean.') then return end
    local message = inv and {'ExpGamingCore-Role.default-print',rtn} or {'ExpGamingCore-Role.print',role.name,rtn}
    local print = inv or false
    local ctn = 0
    for index,_role in pairs(Role.roles) do
        if print or _role == role then ctn=ctn+_role:print(message,colour) end
        if _role == role then if print then break else print = true end end
    end
    return ctn
end

--- Prints all registed roles and there important infomation (debug)
-- @tparam[opt] ?role|string the role to print the info of, if nil then all roles are printed in order of power
-- @tparam[opt=game.player] ?LuaPlayer|pointerToPlayer the player to print the info to, default the player who ran command
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

--- Used to test if a role has a flag set
-- @usage role:has_flag('is_admin') -- returns true if the role has the flag 'is_admin'
-- @tparam string flag the flag to test for
-- @treturn boolean true if the flag is set else false
function Role._prototype:has_flag(flag)
    if not self_test(self,'role','has_flag') then return end
    if not type_error(flag,'string','Invalid argument #1 to role:has_flag, flag is not a string.') then return end
    return self[flag] or false
end

--- Used to test if a role is allowed an action
-- @usage role:allowed('foo') -- returns true if the role is allowed 'foo'
-- @tparam string action the action to test for
-- @treturn boolean true if the action is allowed else false
function Role._prototype:allowed(action)
    if not self_test(self,'role','allowed') then return end
    if not type_error(action,'string','Invalid argument #1 to role:allowed, action is not a string.') then return end
    if self.is_antiroot then return false end
    return self.allow[action] or self.is_root or false -- still include is_root exception flag
end

--- Returns the players who have this role
-- @usage role:get_player() -- returns table of players
-- @usage role.players -- returns table of players
-- @usage role.connected_players -- returns table of online players
-- @tparam[opt] boolean online if true only returns online players
function Role._prototype:get_players(online)
    if not self_test(self,'role','get_players') then return end
    if online and not type_error(online,'boolean','Invalid argument #1 to role:get_players, online is not a boolean.') then return end
    if not global.roles[self.name] then global.roles[self.name] = {} end
    if self.is_default then if online then return game.connected_players else return game.players end end
    local rtn = {}
    for _,player_index in pairs(global.roles[self.name]) do
        local player = game.players[player_index]
        if player and not online or player.connected then table.insert(rtn,player) end
    end
    return rtn
end

-- this is used to create a connected_players table
Role._prototype.players_mt = {
    __call=function(tbl) return tbl.self:get_players(tbl.connected) end,
    __pairs=function(tbl) 
        local players = tbl.self:get_players(tbl.connected) 
        local function next_pair(tbl,k)
            k, v = next(players, k)
            if v then return k,v end
        end
        return next_pair, players, nil
    end,
    __ipairs=function(tbl) 
        local players = tbl.self:get_players(tbl.connected) 
        local function next_pair(tbl,k)
            k, v = next(players, k)
            if v then return k,v end
        end
        return next_pair, players, nil
    end
}


--- Prints a message to all players who have this role
-- @usage role:print('Hello, World!') -- retuns number of players who recived the message
-- @param rtn the message to print to the players
-- @tparam[opt] table colour the colour to print the message in
-- @treturn number the number of players who recived the message
function Role._prototype:print(rtn,colour)
    if not self_test(self,'role','print') then return end
    if colour and not type_error(colour,'table','Invalid argument #2 to Role.print, colour is not a table.') then return end
    local ctn = 0
    for _,player in pairs(self:get_players(true)) do ctn=ctn+1 player_return(rtn,colour,player) end
    return ctn
end

--- Returns a table that describes all the permissions and which this role is allowed
-- @usage role:get_permissions() -- retuns table of permissions
-- @treturn table a table of permisions, only includes ones which were defined with Role.add_action
function Role._prototype:get_permissions()
    if not self_test(self,'role','get_permissions') then return end
    local rtn = {}
    for _,action in pairs(Role.actions) do rtn[action] = self:allowed(action) end
    return rtn
end

--- Adds a player to this role (players can have more than one role)
-- @usage role:add_player(player)
-- @tparam ?LuaPlayer|PointerToPlayer player the player to add
-- @tparam[opt] ?LuaPlayer|PointerToPlayer by_player the player who ran the command
-- @tparam[opt] table batch this is used internally to provent multiple event calls
function Role._prototype:add_player(player,by_player,batch)
    if not self_test(self,'role','add_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to role:add_player.',2) return end
    local by_player = Game.get_player(by_player) or SERVER
    if not global.roles[self.name] then global.roles[self.name] = {} end
    if not global.players[player.index] then global.players[player.index] = {} end
    local highest = Role.get_highest(player) or Role.meta.default
    for _,player_index in pairs(global.roles[self.name]) do if player_index == player.index then return end end
    table.insert(global.roles[self.name],player.index)
    table.insert(global.players[player.index],self.name)
    script.raise_event(role_change_event_id,{
        name=role_change_event_id,
        tick=game.tick,
        player_index=player.index,
        by_player_index=by_player.index,
        old_highest=highest.name,
        role_name=self.name,
        batch=batch and batch[2] or {self.name},
        batch_index=batch and batch[1] or 1,
        effect='assign'
    })
end

--- Removes a player from this role (players can have more than one role)
-- @usage role:remove_player(player)
-- @tparam ?LuaPlayer|PointerToPlayer player the player to remove
-- @tparam[opt] ?LuaPlayer|PointerToPlayer by_player the player who ran the command
-- @tparam[opt] table batch this is used internally to provent multiple event calls
function Role._prototype:remove_player(player,by_player,batch)
    if not self_test(self,'role','add_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to role:remove_player.',2) return end
    local by_player = Game.get_player(by_player) or SERVER
    if not global.roles[self.name] then global.roles[self.name] = {} end
    if not global.players[player.index] then global.players[player.index] = {} end
    local highest = Role.get_highest(player) or Role.meta.default
    local index = 0
    for _index,player_index in pairs(global.roles[self.name]) do if player_index == player.index then index=_index break end end
    table.remove(global.roles[self.name],index)
    for _index,role_name in pairs(global.players[player.index]) do if role_name == self.name then index=_index break end end
    table.remove(global.players[player.index],index)
    script.raise_event(role_change_event_id,{
        name=role_change_event_id,
        tick=game.tick,
        player_index=player.index,
        by_player_index=by_player.index,
        old_highest=highest.name,
        role_name=self.name,
        batch=batch and batch[2] or {self.name},
        batch_index=batch and batch[1] or 1,
        effect='unassign'
    })
end

-- Event Handlers Define
script.on_event(role_change_event_id,function(event)
    -- varible init
    local player = Game.get_player(event)
    local by_player = Game.get_player(event.by_player_index) or SERVER
    local role = Role.get(event.role_name)    
    local highest = Role.get_highest(player)
    if not highest then Role.meta.default:add_player(player) highest = Role.meta.default end
    -- gets the falgs the player currently has
    for flag,callback in pairs(Role.flags) do if is_type(callback,'function') then callback(player,Role.has_flag(player,flag)) end end
    -- assign new tag and group of highest role
    Group.assign(player,highest.group)
    local old_highest_tag = Role.get(event.old_highest).tag or ''
    local start, _end = string.find(player.tag,old_highest_tag,1,true)
    if start and old_highest_tag ~= highest.tag then player.tag = string.sub(player.tag,0,start-1)..highest.tag..string.sub(player.tag,_end+1) end
    if not start then player.tag = highest.tag player_return({'ExpGamingCore-Role.tag-reset'},nil,player) end
    if player.online_time > 60 then
        -- send a message to other players
        if event.batch_index == 1 then
            local names = {}
            for _,name in pairs(event.batch) do local role = Role.get(name) if role then table.insert(names,role.name) end end
            if event.effect == 'assign' then
                if not role.is_jail then player.play_sound{path='utility/achievement_unlocked'} end
                game.print{'ExpGamingCore-Role.default-print',{'ExpGamingCore-Role.assign',player.name,table.concat(names,', '),by_player.name}}
            else 
                player.play_sound{path='utility/game_lost'}
                game.print{'ExpGamingCore-Role.default-print',{'ExpGamingCore-Role.unassign',player.name,table.concat(names,', '),by_player.name}}
            end
        end
        -- log change to file
        game.write_file('role-change.json',
            table.json({
                tick=game.tick,
                effect=event.effect,
                role_name=role.name,
                player_name=player.name,
                by_player_name=by_player.name,
                play_time=player.online_time,
                highest_role_name=highest.name,
                old_highest=event.highest,
                batch_count=#event.batch,
                batch_index=event.batch_index
            })..'\n'
        , true, 0)
    end
end)

script.on_event(defines.events.on_player_joined_game,function(event)
    local player = Game.get_player(event)
    local highest = Role.get_highest(player) or Role.meta.default
    Group.assign(player,highest.group)
    player.tag=highest.tag
    if global.preassign[player.name:lower()] then Role.assign(player,global.preassign[player.name:lower()]) end
    if Role.preassign[player.name:lower()] then Role.assign(player,Role.preassign[player.name:lower()]) end
end)

script.on_event(defines.events.on_tick,function(event)
    if game.tick%(3600*5) ~= 0 then return end -- every 5 minutes
    for role_name, time in pairs(Role.meta.times) do
        for _,player in pairs(game.connected_players) do
            local highest = Role.get_highest(player)
            if highest.index > time[1] and (player.online_time) > time[2] then Role.assign(player,role_name) end
        end
    end
end)

-- Module Return
-- calling will attempt to define a new role
return setmetatable(Role,{__call=function(tbl,...) tbl.define(...) end}) 