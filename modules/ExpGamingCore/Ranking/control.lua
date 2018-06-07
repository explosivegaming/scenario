--- A full ranking system for factorio.
-- @module ExpGamingCore.Ranking
-- @alias Ranking
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
local Ranking = {}
local module_verbose = false --true|false

--- Global Table
-- @table global
-- @field old contains the previous rank a use had before a rank change
-- @field preset contains the preset ranks that users will recive apon joining
-- @field last_change contains the name of the player who last had there rank chagned
local global = global{old={},preset={},last_change=nil}

--- Called when there is a rank change for a user
-- @event rank_change
-- @field name the rank id
-- @field tick the tick which the event was raised on
-- @field player_index the player whos rank was changed
-- @field by_player_index the player who changed the rank, 0 means server
-- @field new_rank the name of the rank that was given
-- @field old_rank the name of the rank the player had
script.generate_event_name('rank_change')

--- Outputs as a string all the ranks and the loaded order
-- @usage Ranking.output_ranks(player) -- prints to player
-- @tparam[opt=server] ?player_name|player_index|LuaPlayer player the player that the info will be printed to, nil will print to server
-- @todo show inheritance of ranks
function Ranking.output_ranks(player)
    local player = Game.get_player(player) or game.player or nil
    local function output(rank)
        local admin = 'No'; if rank.is_root then admin = 'Root' elseif rank.is_admin then admin = 'Yes' end
        local rtn = string.format('%s) %q %s > Admin: %s Group: %q AFK: %s Time: %s',
        rank.power,rank.name,rank.tag,admin,rank.group,tostring(rank.base_afk_time),tostring(rank.time))
        player_return(rtn,rank.colour,player)
    end
    local function recur(_rank)
        for name,rank in pairs(_rank.children) do output(Ranking.ranks[rank]) end
        for name,rank in pairs(_rank.children) do recur(Ranking.ranks[rank]) end
    end
    local root = Ranking.get_rank(Ranking.meta.root)
    output(root)
    recur(root)
end

--- Contains the location of all the ranks, readonly during runtime
-- @table Ranking.ranks
Ranking.ranks = setmetatable({},{
    __metatable=false,
    __index=table.autokey,
    __newindex=function(tbl,key,value) if game then error('Can not create new ranks during runtime',2) else rawset(tbl,key,value) end end,
    __len=function(tbl)
        local rtn = 0
        for name,rank in pairs(tbl) do
            rtn=rtn+1
        end
        return rtn
    end
})

--- Contains the location of all the rank groups, readonly during runtime
-- @table Ranking.ranks
Ranking.groups = setmetatable({},{
    __metatable=false,
    __index=table.autokey,
    __newindex=function(tbl,key,value) if game then error('Can not create new rank groups during runtime',2) else rawset(tbl,key,value) end end,
    __len=function(tbl)
        local rtn = 0
        for name,rank in pairs(tbl) do
            rtn=rtn+1
        end
        return rtn
    end
})

--- Contains some meta data about the ranks
-- @table Ranking.meta
-- @field default this is the name of the default rank
-- @field root this is the name of the root rank
-- @field time_ranks a list of all ranks which have a time requirement
-- @field time_highest the power of the highest rank that has a time requirement
-- @field time_lowest the lowest amount of time required for a time rank
Ranking.meta = setmetatable({},{
    __metatable=false,
    __call=function(tbl)
        local count = 0
        rawset(tbl,'time_ranks',{})
        for name,rank in pairs(Ranking.ranks) do
            count=count+1
            if not rawget(tbl,'default') and rank.is_default then rawset(tbl,'default',rank.name) end
            if not rawget(tbl,'root') and rank.is_root then rawset(tbl,'root',rank.name) end
            if rank.time then
                table.insert(tbl.time_ranks,rank.name)
                if not rawget(tbl,'time_highest') or rank.power < tbl.time_highest then if rank.power then rawset(tbl,'time_highest',rank.power) end end
                if not rawget(tbl,'time_lowest') or rank.time < tbl.time_lowest then rawset(tbl,'time_lowest',rank.time) end
            end
        end
        rawset(tbl,'rank_count',count)
        if not rawget(tbl,'default') then error('No default rank') end
        if not rawget(tbl,'root') then error('No root rank') end
    end,
    __index=function(tbl,key)
        tbl()
        return rawget(tbl,key)
    end,
    __newindex=function() error('Ranking metadata is read only',2) end
})

--- Used to set the prset ranks that will be given to players
-- @usage Ranking._base_preset{name=rank_name,nameTwo=rank_name_two} -- sets player name to have rank rank_name on join
-- @tparam table ranks table of player names with the player name as the key and rank name as the value 
function Ranking._base_preset(ranks)
    if not is_type(ranks,'table') then error('Ranking._base_preset was not given a table',2) end
    global.preset = ranks
end

--- Returns a rank object given a player or rank name
-- @usage Ranking.get_rank(game.player) -- returns player's rank
-- @usage Ranking.get_rank('admin') -- returns rank by the name of admin
-- @tparam ?player|player_index|player_name|rank_name|Ranking._rank|'server'|'root' mixed what rank to get
-- @treturn[1] table the rank that is linked to mixed
-- @treturn[2] nil there was no rank found 
function Ranking.get_rank(mixed)
    if not mixed then return error('Ranking.get_rank recived no paramerters') end
    local ranks = Ranking.ranks
    local _return = false
    if is_type(mixed,'table') then
        -- is it a player, then get player rank; if it is a rank then return the rank
        if mixed.index then _return = game.players[mixed.index] and ranks[mixed.permission_group.name] or nil
        else _return = mixed.group and mixed or nil end
    else
        -- if it is a player name/index, then get player rank; if it is a rank name, get that rank; if it is server or root; return root rank; else nil
        _return = game and game.players[mixed] and ranks[game.players[mixed].permission_group.name]
        or table.autokey(ranks,mixed) and table.autokey(ranks,mixed)
        or string.contains(mixed,'server') and Ranking.get_rank(Ranking.meta.root)
        or string.contains(mixed,'root') and Ranking.get_rank(Ranking.meta.root)
        or nil
    end
    return _return
end

--- Returns the group object used to sort ranks given group name or rank
-- @usage Ranking.get_group(game.player) -- returns player's rank group
-- @usage Ranking.get_group('root') -- returns group by name of root
-- @tparam ?player|player_index|player_name|rank_name|rank|'server'|'root'|group_name|group mixed what group to get
-- @see Ranking.get_rank
-- @treturn[1] table the group that is linked to mixed
-- @treturn[2] nil there was no rank group found 
function Ranking.get_group(mixed)
    if not mixed then return error('Ranking.get_group recived no paramerters') end
    local groups = Ranking.groups
    local rank = Ranking.get_rank(mixed)
    -- if it is a table see if it is a group, return the group; if it is a string, return group by that name; if there is a rank found, return the ranks group
    return is_type(mixed,'table') and not mixed.__self and mixed.ranks and mixed
    or is_type(mixed,'string') and table.autokey(groups,mixed)
    or rank and rank.group
    or nil
end

--- Prints to all rank of greater/lower power of the rank given
-- @usage Ranking.print('admin','We got a grifer')
-- @todo change to use parent and child ranks rather than power
-- @tparam ?Ranking._rank|pointerToRank rank_base the rank that acts as the cut off point (rank is always included)
-- @param rtn what do you want to return to the players
-- @tparam[opt=defines.color.white] defines.color colour the colour that will be used to print
-- @tparam[opt=false] boolean below if true print to children rather than parents
function Ranking.print(rank_base,rtn,colour,below)
    local colour = colour or defines.color.white
    local rank_base = Ranking.get_rank(rank_base)
    local ranks = Ranking._ranks()
    if below then
        for power,rank in pairs(ranks) do
            if rank_base.power <= power then rank:print(rtn,colour,true) end
        end
    else
        for power,rank in pairs(ranks) do
            if rank_base.power >= power then rank:print(rtn,colour) end
        end
    end
end

--- Gives a user a rank
-- @usage Ranking.give_rank(1,'admin')
-- @tparam ?LuaPlayer|pointerToPlayer player the player to give the rank to
-- @tparam[opt=default] ?Ranking._rank|pointerToRank rank the rank to give to the player
-- @tparam[opt='server'] ?LuaPlayer|pointerToPlayer by_player the player who is giving the rank
-- @tparam[opt=game.tick] number tick the tick that the rank is being given on, used as pass though
function Ranking.give_rank(player,rank,by_player,tick)
    local print_colour = defines.textcolor.info
    local tick = tick or game.tick
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or game.player and game.player.name or is_type(by_player,'string') and by_player or 'server'
    local rank = Ranking.get_rank(rank) or Ranking.get_rank(Ranking.meta.default)
    local player = Game.get_player(player) or error('No player given to Ranking.give_rank',2)
    local old_rank = Ranking.get_rank(player) or Ranking.get_rank(Ranking.meta.default)
    local message = 'ranking.rank-down'
    -- messaging
    if old_rank.name == rank.name then return end
    if rank.power < old_rank.power then message = 'ranking.rank-up' player.play_sound{path='utility/achievement_unlocked'}
    else player.play_sound{path='utility/game_lost'} end
    if player.online_time > 60 or by_player_name ~= 'server' then game.print({message,player.name,rank.name,by_player_name},print_colour) end
    if rank.group ~= 'User' then player_return({'ranking.rank-given',rank.name},print_colour,player) end
    if player.tag ~= old_rank.tag then player_return({'ranking.tag-reset'},print_colour,player) end
    -- rank change
    player.permission_group = game.permissions.get_group(rank.name)
    player.tag = rank.tag
    if old_rank.group ~= 'Jail' then global.old[player.index] = old_rank.name end
    player.admin = rank.is_admin or false
    player.spectator = rank.is_spectator or false
    local by_player_index = by_player_name == 'server' and 0 or Game.get_player(by_player_name).index
    script.raise_event(defines.events.rank_change,{
        name=defines.events.rank_change,
        tick=tick, 
        player_index=player.index, 
        by_player_index=by_player_index, 
        new_rank=rank.name, 
        old_rank=old_rank.name
    })
    -- logs to file if rank is chagned after first join
    if player.online_time > 60 then
        game.write_file('ranking-change.json',
            table.json({
                tick=tick,
                play_time=player.online_time,
                player_name=player.name,
                by_player_name=by_player_name,
                new_rank=rank.name,
                old_rank=old_rank.name
            })..'\n'
        , true, 0)
    end
end

--- Revert the last change to a players rank
-- @usage Ranking.revert(1) -- reverts the rank of player with index 1
-- @tparam ?LuaPlayer|pointerToPlayer player the player to revert the rank of
-- @param[opt=nil] by_player the player who is doing the revert
function Ranking.revert(player,by_player)
    local player = Game.get_player(player)
    Ranking.give_rank(player,global.old[player.index],by_player)
end

--- Given that the player has a rank in the preset table it is given; also will attempt to promote players if a time requirement is met
-- @usage Ranking.find_preset(1) -- attemps to find the preset for player with index 1
-- @tparam ?LuaPlayer|pointerToPlayer player the player to test for an auto rank
-- @tparam[opt=nil] number tick the tick it happens on
function Ranking.find_preset(player,tick)
    local presets = global.preset
    local meta_data = Ranking.meta
    local default = Ranking.get_rank(meta_data.default)
    local player = Game.get_player(player)
    local current_rank = Ranking.get_rank(player) or {power=-1,group='not jail'}
    local ranks = {default}
    -- users in rank group jail are ingroned
    if current_rank.group == 'Jail' then return end
    -- looks in preset table for player name
    if presets[string.lower(player.name)] then
        local rank = Ranking.get_rank(presets[string.lower(player.name)])
        table.insert(ranks,rank)
    end
    -- if the player mets check requirements then play time is checked
    if current_rank.power > meta_data.time_highest and tick_to_min(player.online_time) > meta_data.time_lowest then
        for _,rank_name in pairs(meta_data.time_ranks) do
            local rank = Ranking.get_rank(rank_name)
            if tick_to_min(player.online_time) > rank.time then
                table.insert(ranks,rank)
            end
        end
    end
    -- if the new rank is closer to root then it is the new rank
    local _rank = current_rank
    for _,rank in pairs(ranks) do
        if rank.power < _rank.power or _rank.power == -1 then _rank = rank end
    end
    -- this new rank is given to the player
    if _rank.name == current_rank.name then return end
    if _rank.name == default.name then
        player.tag = _rank.tag
        player.permission_group = game.permissions.get_group(_rank.name)
    else
        Ranking.give_rank(player,_rank,nil,tick)
    end
end

--- The class for the ranks
-- @type Rank
-- @alias Ranking._rank
-- @field name the name that is given to the rank, must be unique
-- @field short_hand the shorter way of displaying this rank, can be used by other modules
-- @field tag the tag that player in this rank will be given
-- @field colour the colour that modules should display this rank as in guis
-- @field parent the name of the rank that permissions are inherited from, allow comes from children, disallow given to children
-- @field base_afk_time a relative number that the rank should be given that other modules can use for relitive importance
-- @field time the time that is requied for this rank to be given, can be nil for manal only
-- @field allow a list of permissions that this rank is allowed
-- @field disallow a list of acctions that is blocked by the ingame permission system
-- @field is_default will be given to all players if no other rank is set for them
-- @field is_admin will promote player to ingame admin if flag set (will auto demote if not set)
-- @field is_spectator will auto set the spectator option for the player (will cleat option if not set)
-- @field is_root rank is always allowed all action, when present in root group will become the root child that all ranks are indexed from
Ranking._rank = {}
    
--- Is this rank allowed to open this gui or use this command etc.
-- @usage rank:allowed('interface') -- does the rank have permision for 'interface'
-- @tparam teh action to test for
-- @treturn boolean is it allowed
function Ranking._rank:allowed(action)
    return self.allow[action] or self.is_root or false
end

--- Get all the players in this rank
-- @usage rank:get_players()
-- @tparam[opt=false] boolean online get only online players
-- @treturn table a table of all players in this rank
function Ranking._rank:get_players(online)
    local players = game.permissions.get_group(self.name).players
    local _return = {}
    if online then
        for _,player in pairs(players) do if player.connected then table.insert(_return,player) end end
    else _return = players end
    return _return
end

--- Print a message to all players of this rank
-- @usage rank:print('foo') -- prints to all members of this rank
-- @param rtn any value you want to return
-- @tparam[opt=defines.color.white] define.color colour the colour that will be used to print
-- @tparam[opt=false] boolean show_default weather to use the default rank name for the print, used as a pass though
function Ranking._rank:print(rtn,colour,show_default)
    local colour = colour or defines.color.white
    local default = Ranking.get_rank(Ranking.meta.default)
    for _,player in pairs(self:get_players(true)) do
        if self.name == default.name or show_default then player_return({'ranking.all-rank-print',rtn},colour,player)
        else player_return({'ranking.rank-print',self.name,rtn},colour,player) end
    end
end

--- Allows for a clean way to edit rank objects
-- @usage rank:edit('allow',{'interface'}) -- allows this rank to use 'interface'
-- @tparam string key the key to edit, often allow or disallow
-- @param value the new value to be set
function Ranking._rank:edit(key,value)
    if game then return end
    verbose('Edited Rank: '..self.group..'/'..self.name..'/'..key)
    if key == 'disallow' then self.disallow = table.merge(self.disallow,value,true)
    elseif key == 'allow' then self.allow = table.merge(self.allow,value)
    else self[key] = value end
end

--- The class for the rank groups, the way to allow modules to idex a group that is always present, ranks will always look to there group as a parent
-- @type Group
-- @alias Ranking._group
-- @field name the name that is given to the rank group, must be unique
-- @field parent the name of the group that permissions are inherited from
-- @field allow a list of permissions that this rank is allowed
-- @field disallow a list of acctions that is blocked by the ingame permission system
Ranking._group = {}

--- Creates a new group
-- @usage Ranking._group:create{name='root'} -- returns group with name root
-- @tparam table obj the fields for this object
-- @treturn Ranking._group returns the object to allow chaining
function Ranking._group:create(obj)
    if game then return end
    if not is_type(obj.name,'string') then error('Group creationg is invalid',2) end
    verbose('Created Group: '..obj.name)
    setmetatable(obj,{__index=Ranking._group})
    obj.ranks = {}
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    Ranking.groups[obj.name] = obj
    return obj
end
    
--- Creats a new rank with this group as its group
-- @usage group:add_rank{name='root'} -- returns self
-- @tparam table obj the fields for this object
-- @treturn Ranking._group returns the object to allow chaining
function Ranking._group:add_rank(obj)
    if game then return end
    if not is_type(obj.name,'string') or
    not is_type(obj.short_hand,'string') or
    not is_type(obj.tag,'string') or
    not is_type(obj.colour,'table') then error('Rank creation is invalid',2) end
    verbose('Created Rank: '..obj.name)
    setmetatable(obj,{__index=Ranking._rank})
    obj.group = self.name
    obj.children = {}
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    table.insert(self.ranks,obj.name)
    Ranking.ranks[obj.name] = obj
    return self
end

--- Allows for a clean way to edit rank group objects
-- @usage group:edit('allow',{'interface'}) -- allows this rank to use 'interface'
-- @tparam string key the key to edit, often allow or disallow
-- @param value the new value to be set
function Ranking._group:edit(key,value)
    if game then return end
    verbose('Edited Group: '..self.name..'/'..key)
    if key == 'disallow' then self.disallow = table.merge(self.disallow,value,true)
    elseif key == 'allow' then self.allow = table.merge(self.allow,value)
    else self[key] = value end
end

script.on_event('on_player_joined_game',function(event)
    Ranking.find_preset(event.player_index)
end)

script.on_event('on_init',function(event)
    for name,rank in pairs(Ranking.ranks) do
		local perm = game.permissions.create_group(name)
		for _,toRemove in pairs(rank.disallow) do
			perm.set_allows_action(defines.input_action[toRemove],false)
		end
	end
end)

script.on_event('on_tick',function(event)
    if (((event.tick+10)/(3600*game.speed))+(15/2))% 15 == 0 then
        -- this is the system to auto rank players
        for _,player in pairs(game.connected_players) do
            Ranking.find_preset(player,tick)
        end
    end
end)

_G.Ranking = Ranking
verbose('Loading rank core...')
require(module_path..'/src/core')
verbose('Loading rank configs...')
require(module_path..'/src/config')
_G.Ranking = nil

function Ranking:on_init()
    if loaded_modules.Server then verbose('ExpGamingCore.Server is installed; Loading server src') require(module_path..'/src/server') end
end

function Ranking:on_post()
    -- other modules can creat ranks during init and this will then set up the meta data
    -- sets up the power system, the lower the power the closer to root, root is 0
    -- there must be a rank with is_root flag set and one rank with is_default flag set, if multiple found then first found is used
    local root = Ranking.get_rank(Ranking.meta.root)
    root:edit('power',0)
    -- asigning of children
    verbose('Creating Rank Tree')
    for name,rank in pairs(Ranking.ranks) do
        if rank ~= root then
            if not rank.parent then error('Rank has no parent: "'..name..'"') end
            if not Ranking.ranks[rank.parent] then error('Invalid parent rank: "'..rank.parent..'"') end
            table.insert(Ranking.ranks[rank.parent].children,name)
            Ranking.ranks[rank.parent]:edit('allow',rank.allow)
            rank:edit('disallow',Ranking.ranks[rank.parent].disallow)
        end
    end
    -- asigning of powers
    -- @todo need a better system for non liner rank trees
    verbose('Assigning Rank Powers')
    local power = 1
    local function set_powers(rank)
        for _,name in pairs(rank.children) do
            Ranking.ranks[name]:edit('power',power)
            power=power+1
        end
        for _,name in pairs(rank.children) do set_powers(Ranking.ranks[name]) end
    end
    set_powers(root)
    -- asigning group meta data
    verbose('Creating Rank-Group Relationship')
    for name,group in pairs(Ranking.groups) do
        if name ~= 'Root' then
            if not group.parent then error('Group has no parent: "'..name..'"') end
            if not Ranking.groups[group.parent] then error('Invalid parent rank: "'..group.parent..'"') end
            Ranking.groups[group.parent]:edit('allow',group.allow)
            group:edit('disallow',Ranking.groups[group.parent].disallow)
        end
        for _,name in pairs(group.ranks) do
            local rank = Ranking.ranks[name]
            rank:edit('disallow',group.disallow)
            rank:edit('allow',group.allow)
            if not group.highest or Ranking.ranks[group.highest].power > rank.power then group.highest = rank.name end
            if not group.lowest or Ranking.ranks[group.highest].power < rank.power then group.lowest = rank.name end
        end
    end
end

return Ranking