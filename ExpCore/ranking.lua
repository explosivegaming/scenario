--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local Ranking = {}
defines.events.rank_change = script.generate_event_name()
Ranking._rank = {}
Ranking._group = {}
-- this function is to avoid errors - see /ranks.lua
function Ranking._ranks(names)
    return {}
end

-- this function is to avoid errors - see /ranks.lua
function Ranking._groups(names)
    return {}
end

-- this function is to avoid errors - see /ranks.lua
function Ranking._meta()
    return {}
end

-- this function is to avoid errors - see addons/playerRanks.lua
function Ranking._base_preset(table)
    Ranking._presets().current = table
end

-- this returns a global list
function Ranking._presets()
    if not global.exp_core then global.exp_core = {} end
    if not global.exp_core.ranking then global.exp_core.ranking = {meta=Ranking._meta(),old={},current={}} end
    return global.exp_core.ranking
end

--- Returns a rank object given a player or rank name
-- @usage Ranking.get_rank(game.player)
-- Ranking.get_rank('admin')
-- @param mixed player|player index|player name|rank name|rank|'server'|'root'  what rank to get
-- @treturn table the rank that is linked to mixed
function Ranking.get_rank(mixed)
    if not mixed then return false end
    local ranks = Ranking._ranks(true)
    local _return = false
    if is_type(mixed,'table') then
        if mixed.index then
            _return = game.players[mixed.index] and ranks[mixed.permission_group.name] or false
        else
            _return = mixed.group and mixed or false
        end
    else
        _return = game.players[mixed] and ranks[game.players[mixed].permission_group.name]
        or table.autokey(ranks,mixed) and table.autokey(ranks,mixed)
        or string.contains(mixed,'server') and Ranking.get_rank(Ranking._presets().meta.root)
        or string.contains(mixed,'root') and Ranking.get_rank(Ranking._presets().meta.root)
        or false
    end
    return _return
end

--- Returns the group object used to sort ranks given group name or see Ranking.get_rank
-- @usage Ranking.get_group(game.player)
-- Ranking.get_group('root')
-- @param mixed player|player index|player name|rank name|rank|'server'|'root'|group name|group what group to get
-- @treturn table the group that is linked to mixed
function Ranking.get_group(mixed)
    if not mixed then return false end
    local groups = Ranking._groups(true)
    local rank = Ranking.get_rank(mixed)
    return rank and rank.group
    or is_type(mixed,'table') and mixed.ranks and mixed
    or is_type(mixed,'string') and table.autokey(groups,mixed) and table.autokey(groups,mixed)
    or false
end

--- Prints to all rank of greater/lower power of the rank given
-- @usage Ranking.print('admin','We got a grifer')
-- @param rank_base the rank that acts as the cut off point (rank is always included)
-- @param rtn what do you want to return to the players
-- @tparam bolean below if true rank below base are printed to
function Ranking.print(rank_base,rtn,colour,below)
    local colour = colour or defines.color.white
    local rank_base = Ranking.get_rank(rank_base)
    local ranks = Ranking._ranks()
    if below then
        for power,rank in pairs(ranks) do
            if rank_base.power >= power then rank:print(rtn,colour) end
        end
    else
        for power,rank in pairs(ranks) do
            if rank_base.power <= power then rank:print(rtn,colour) end
        end
    end
end

--- Gives a user a rank
-- @usage Ranking.give_rank(1,'admin')
-- @param player the player to give the rank to
-- @param rank the rank to give to the player
-- @param[opt='server'] by_player the player who is giving the rank
-- @param[opt=game.tick] tick the tick that the rank is being given on
function Ranking.give_rank(player,rank,by_player,tick)
    local print_colour = defines.text_color.info
    local tick = tick or game.tick
    local by_player_name = Game.get_player(by_player) and Game.get_player(by_player).name or game.player and game.player.name or 'server'
    local rank = Ranking.get_rank(rank) or Ranking.get_rank(Ranking._presets().meta.default)
    local player = Game.get_player(player) or error('No Player To Give Rank')
    local old_rank = Ranking.get_rank(player) or Ranking.get_rank(Ranking._presets().meta.default)
    local message = 'ranking.rank-down'
    -- messaging
    if old_rank.name == rank.name then return end
    if rank.power < old_rank.power then message = 'ranking.rank-up' player.play_sound{path='utility/achievement_unlocked'}
    else player.play_sound{path='utility/game_lost'} end
    game.print({message,player.name,rank.name,by_player_name},print_colour)
    if rank.group.name ~= 'User' then player_return({'ranking.rank-given',rank.name},print_colour,player) end
    if player.tag ~= old_rank.tag then player_return({'ranking.tag-reset'},print_colour,player) end
    -- rank change
    player.permission_group = game.permissions.get_group(rank.name)
    player.tag = rank.tag
    if not old_rank.group.name == 'Jail' then Ranking._presets().old[player.index] = rank.name end
    player.admin = rank.is_admin or false
    if defines.events.rank_change then 
        script.raise_event(defines.events.rank_change,{
            name=defines.events.rank_change,
            tick=tick, 
            player_index=player.index, 
            by_player_name=by_player_name, 
            new_rank=rank, 
            old_rank=old_rank
        }) 
    end
end

--- Revert the last change to a players rank
-- @usage Ranking.revert(1)
-- @param player the player to revert the rank of
-- @param[opt=nil] by_player the player who is doing the revert
function Ranking.revert(player,by_player)
    local player = Game.get_player(player)
    Ranking.give_rank(player,Ranking._presets().old[player.index],by_player)
end

--- Given the player has a rank in the preset table it is given
-- @usage Ranking.find_preset(1)
-- @param player the player to test for an auto rank
-- @tparam[opt=nil] tick the tick it happens on
function Ranking.find_preset(player,tick)
    local presets = Ranking._presets().current
    local meta_data = Ranking._presets().meta
    local default = Ranking.get_rank(meta_data.default)
    local player = Game.get_player(player)
    local current_rank = Ranking.get_rank(player) or {power=-1,group={name='not jail'}}
    local ranks = {default}
    if current_rank.group.name == 'Jail' then return end
    if presets[string.lower(player.name)] then
        local rank = Ranking.get_rank(presets[string.lower(player.name)])
        if current_rank.power >= rank.power then return end
        table.insert(ranks,rank)
    end
    if current_rank.power < meta_data.time_highest and tick_to_min(player.online_time) > meta_data.time_lowest then
        for _,rank_name in pairs(meta_data.time_ranks) do
            local rank = Ranking.get_rank(rank_name)
            if tick_to_min(player.online_time) > rank.time then
                table.insert(ranks,rank)
            end
        end
    end
    local _rank = nil
    for _,rank in pairs(ranks) do
        if rank.power < current_rank.power or current_rank.power == -1 then _rank = rank end
    end
    if _rank then
        if _rank.name == default.name then
            player.tag = _rank.tag
            player.permission_group = game.permissions.get_group(_rank.name)
        else
            Ranking.give_rank(player,_rank,nil,tick)
        end
    end
end

-- this is the base rank object, do not store in global

--- Is this rank allowed to open this gui or use this command etc.
-- @usage rank:allowed('server-interface')
-- @tparam teh action to test for
-- @treturn bolean is it allowed
function Ranking._rank:allowed(action)
    return self.allow[action] or self.is_root or false
end

--- Get all the players in this rank
-- @usage rank:get_players()
-- @tparam bolean online get only online players
-- @treturn table a table of all players in this rank
function Ranking._rank:get_players(online)
    local players = game.permissions.get_group(rank.name).players
    local _return = {}
    if online then
        for _,player in pairs(players) do
            if player.connected then table.insert(_return,player) end
        end
    else
        _return = players
    end
    return _return
end

--- Print a message to all players of this rank
-- @usage rank:print('foo')
-- @param rtn any value you want to return
function Ranking._rank:print(rtn,colour)
    local colour = colour or defines.color.white
    local meta_data = Ranking._presets().meta
    local default = Ranking.get_rank(meta_data.default)
    if not Server or not Server._thread then
        for _,player in pairs(self:get_players()) do
            if thread.data.rank.name == thread.data.default then
                player_return({'ranking.all-rank-print',rtn},colour,player)
            else
                player_return({'ranking.rank-print',self.name,rtn},colour,player)
            end
        end
    else
        -- using threads to make less lag
        Server.new_thread{
            data={rank=self,rtn=rtn,default=default.name}
        }:on_event('resolve',function(thread)
            return thread.data.rank:get_players(true)
        end):on_event('success',function(thread,players)
            for _,player in pairs(players) do
                if thread.data.rank.name == thread.data.default then
                    player_return({'ranking.all-rank-print',thread.data.rtn},colour,player)
                else
                    player_return({'ranking.rank-print',thread.data.rank.name,thread.data.rtn},colour,player)
                end
            end
        end):queue()
    end
end

-- this is used to edit a group once made key is what is being edited and set_value makes it over ride the current value
-- see Addons/playerRanks for examples
function Ranking._rank:edit(key,set_value,value)
    if game then return end
    if set_value then self[key] = value return end
    if key == 'disallow' then
        self.disallow = table.merge(self.disallow,value,true)
    elseif key == 'allow' then
        self.allow = table.merge(self.allow,value)
    end
    Ranking._update_rank(self)
end

-- this is the base group object, do not store in global, these cant be used in game

-- this makes a new group 
-- {name='root',allow={},disallow={}}
function Ranking._group:create(obj)
    if game then return end
    if not is_type(obj.name,'string') then return end
    setmetatable(obj,{__index=Ranking._group})
    self.index = #Ranking._groups(names)+1
    obj.ranks = {}
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    Ranking._add_group(obj)
    return obj
end
    
-- this makes a new rank in side this group 
-- {name='Root',short_hand='Root',tag='[Root]',time=nil,colour=defines.colors.white,allow={},disallow={}}
-- if the rank is given power then it is given that place realative to the highest rank in that group,if no power then it is added to the end
function Ranking._group:add_rank(obj)
    if game then return end
    if not is_type(obj.name,'string') or
    not is_type(obj.short_hand,'string') or
    not is_type(obj.tag,'string') or
    not is_type(obj.colour,'table') then return end
    setmetatable(obj,{__index=Ranking._rank})
    obj.group = self
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    obj.power = obj.power and self.highest and self.highest.power+obj.power or obj.power or self.lowest and self.lowest.power+1 or nil
    setmetatable(obj.allow,{__index=self.allow})
    setmetatable(obj.disallow,{__index=self.disallow})
    Ranking._add_rank(obj,obj.power)
    Ranking._set_rank_power()
    table.insert(self.ranks,obj)
    if not self.highest or obj.power < self.highest.power then self.highest = obj end
    if not self.lowest or obj.power > self.lowest.power then self.lowest = obj end
end

-- this is used to edit a group once made key is what is being edited and set_value makes it over ride the current value
-- see Addons/playerRanks for examples
function Ranking._group:edit(key,set_value,value)
    if game then return end
    if set_value then self[key] = value return end
    if key == 'disallow' then
        self.disallow = table.merge(self.disallow,value,true)
    elseif key == 'allow' then
        self.allow = table.merge(self.allow,value)
    end
    Ranking._update_group(self)
end

Event.register(defines.events.on_player_joined_game,function(event)
    Ranking.find_preset(event.player_index)
end)

Event.register(-1,function(event)
    for power,rank in pairs(Ranking._ranks()) do
		local perm = game.permissions.create_group(rank.name)
		for _,toRemove in pairs(rank.disallow) do
			perm.set_allows_action(defines.input_action[toRemove],false)
		end
	end
end)

Event.register(defines.events.on_tick,function(event)
    if ((event.tick/(3600*game.speed))+(15/2))% 15 == 0 then
        -- this is the system to auto rank players
        if not Server or not Server._thread then
            for _,player in pairs(game.connected_players) do
                Ranking.find_preset(player,tick)
            end
        else
            Server.new_thread{
                data={players=game.connected_players}
            }:on_event('tick',function(thread)
                if #thread.data.players == 0 then thread:close() return end
                local player = table.remove(thread.data.players,1)
                Ranking.find_preset(player,tick)
            end):open()
        end
	end
end)

return Ranking