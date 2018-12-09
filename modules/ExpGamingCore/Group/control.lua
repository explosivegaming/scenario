--- Adds a system to manage and auto-create permission groups.
-- @module ExpGamingCore@Group
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais Group 

-- Module Require
local Game = require('FactorioStdLib.Game')

-- Module Define
local module_verbose = false

--- Used as an interface for factorio permissions groups
-- @type Group
-- @field _prototype the prototype of this class
-- @field groups a table of all groups, includes auto complete on the indexing
local Group = {
    _prototype = {},
    groups = setmetatable({},{
        __index=table.autokey,
        __newindex=function(tbl,key,value)
            rawset(tbl,key,Group.define(value))
        end
    }),
    on_init = function()
        if loaded_modules['ExpGamingCore.Server'] then require('ExpGamingCore.Server') end
    end,
    on_post = function(self)
        -- creats a root role that the server can use
        self{name='Root',disallow={}}
        -- loads the groups in config
        require(module_path..'/config',{Group=self})
    end
}

-- Function Define

--- Defines a new instance of a group
-- @usage Group.define{name='foo',disallow={'edit_permission_group','delete_permission_group','add_permission_group'}} -- returns new group
-- @usage Group{name='foo',disallow={'edit_permission_group','delete_permission_group','add_permission_group'}} -- returns new group
-- @tparam table obj contains string name and table disallow of defines.input_action
-- @treturn Group the group which has been made
function Group.define(obj)
    if not type_error(game,nil,'Cant define Group during runtime.') then return end
    if not type_error(obj.name,'string','Group creation is invalid: group.name is not a string') then return end
    if not type_error(obj.disallow,'table','Group creation is invalid: group.disallow is not a table') then return end
    verbose('Created Group: '..obj.name)
    setmetatable(obj,{__index=function(tbl,key) return Group._prototype[key] or game and game.permissions.get_group(tbl.name)[key] or nil end})
    obj.connected_players = setmetatable({self=obj},Group._prototype.connected_players_mt)
    rawset(Group.groups,obj.name,obj)
    return obj
end

--- Used to get the group of a player or the group by name
-- @usage Group.get('foo') -- returns group foo
-- @usage Group.get(player) -- returns group of player
-- @tparam ?LuaPlayer|pointerToPlayer|string mixed can either be the name or raw group of a group or a player indenifier
-- @treturn table the group which was found or nil
function Group.get(mixed)
    if is_type(mixed,'table') and mixed.name then mixed = mixed.name end
    if game and Game.get_player(mixed) then mixed = Game.get_player(mixed).permission_group.name end
    local rtn = Group.groups[mixed]
    if not rtn and game and is_type(mixed,'string') and game.permissions.get_group(mixed) then
        rtn = setmetatable({disallow={},name=mixed},{
            __index=function(tbl,key) return Group._prototype[key] or game and game.permissions.get_group(tbl.name)[key] or nil end
        })
        rtn.connected_players = setmetatable({self=rtn},Group._prototype.connected_players_mt)
    end
    return rtn
end

--- Used to place a player into a group
-- @usage Group.assign(player,group)
-- @tparam ?LuaPlayer|pointerToPlayer player the player to assign the group to
-- @tparam ?string|LuaPermissionGroup the group to add the player to
-- @treturn boolean was the player assigned
function Group.assign(player,group)
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to Group.assign.',2) return end
    local group = Group.get(group)
    if not group then error('Invalid group #2 given to Group.assign.',2) return end
    return group:add_player(player)
end

--- Used to get the factorio permission group linked to this group
-- @usage group:get_raw() -- returns LuaPermissionGroup of this group
-- @treturn LuaPermissionGroup the factorio group linked to this group
function Group._prototype:get_raw()
    if not self_test(self,'group','get_raw') then return end
    local _group = game.permissions.get_group(self.name)
    if not _group or _group.valid == false then error('No permissions group found, please to not remove groups with /permissions',2) return end
    return setmetatable({},{__index=_group})
end

--- Used to add a player to this group
-- @usage group:add_player(player) -- returns true if added
-- @tparam ?LuaPlayer|pointerToPlayer player the player to add to the group
-- @treturn boolean if the player was added
function Group._prototype:add_player(player)
    if not self_test(self,'group','add_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to group.add_player.',2) return end
    local raw_group = self:get_raw()
    return raw_group.add_player(player)
end

--- Used to remove a player from this group
-- @usage group:remove_player(player) -- returns true if removed
-- @tparam ?LuaPlayer|pointerToPlayer player the player to remove from the group
-- @treturn boolean if the player was removed
function Group._prototype:remove_player(player)
    if not self_test(self,'group','remove_player') then return end
    local player = Game.get_player(player)
    if not player then error('Invalid player #1 given to group.remove_player.',2) return end
    local raw_group = self:get_raw()
    return raw_group.remove_player(player)
end

--- Gets all players in this group
-- @usage group:get_players() -- returns table of players
-- @usage group.players -- returns table of players
-- @usage group.connected_players -- returns table of online players
-- @tparam[opt=false] boolean online if true returns only online players
-- @treturn table table of players
function Group._prototype:get_players(online)
    if not self_test(self,'group','get_players') then return end
    if online and not type_error(online,'boolean','Invalid argument #1 to group:get_players, online is not a boolean.') then return end
    local raw_group = self:get_raw()
    local rtn = {}
    if online then for _,player in pairs(raw_group.players) do if player.connected then table.insert(rtn,player) end end end
    return online and rtn or raw_group.players
end

-- this is used to create a connected_players table
Group._prototype.connected_players_mt = {
    __call=function(tbl) return tbl.self:get_players(true) end,
    __pairs=function(tbl) 
        local players = tbl.self:get_players(true) 
        local function next_pair(tbl,k)
            k, v = next(players, k)
            if v then return k,v end
        end
        return next_pair, players, nil
    end,
    __ipairs=function(tbl) 
        local players = tbl.self:get_players(true) 
        local function next_pair(tbl,k)
            k, v = next(players, k)
            if v then return k,v end
        end
        return next_pair, players, nil
    end
}

--- Prints a message or value to all online players in this group
-- @usage group.print('Hello, World!')
-- @param rtn any value you wish to print, string not required
-- @param colour the colour to print the message in
-- @treturn number the number of players who recived the message
function Group._prototype:print(rtn,colour)
    if not self_test(self,'group','print') then return end
    if colour and not type_error(colour,'table','Invalid argument #2 to group:print, colour is not a table.') then return end
    local players = self:get_players()
    local ctn = 0
    for _,player in pairs(players) do if player.connected then player_return(rtn,colour,player) ctn=ctn+1 end end
    return ctn
end

-- Event Handlers Define

-- creates all permission groups and links them
script.on_event('on_init',function(event)
    for name,group in pairs(Group.groups) do
		local _group = game.permissions.create_group(name)
        verbose('Created Permission Group: '..name)
        local count = 0
        for _,to_remove in pairs(group.disallow) do
            count=count+1
			_group.set_allows_action(defines.input_action[to_remove],false)
        end
        verbose('Disalowed '..count..' input actions.')
    end
end)

-- Module Return
-- calling will attempt to define a new group
return setmetatable(Group,{__call=function(tbl,...) tbl.define(...) end})