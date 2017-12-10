--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local Ranking = {}

-- this function is to avoid errors - see /ranks.lua
function Ranking._form_links()
    return false
end

-- this function is to avoid errors - see /ranks.lua
function Ranking._ranks()
    return {}
end

-- this function is to avoid errors - see /ranks.lua
function Ranking._groups()
    return {}
end

--- Returns a rank object given a player or rank name
-- @usage Ranking.get_rank(game.player)
-- Ranking.get_rank('admin')
-- @param mixed player|player index|player name|rank name|rank|'server'|'root'  what rank to get
-- @treturn table the rank that is linked to mixed
function Ranking.get_rank(mixed)
    local ranks = Ranking._ranks()
    return game.players[mixed] and ranks[game.players[mixed].permission_group.name]
    or mixed.index and game.players[mixed.index] and ranks[mixed.permission_group.name]
    or is_type(mixed,'table') and mixed.group and mixed
    or is_type(mixed,'string') and ranks[string.lower(mixed)] and ranks[string.lower(mixed)]
    or is_type(mixed,'string') and mixed == 'server' and ranks['root']
    or is_type(mixed,'string') and mixed == 'root' and ranks['root']
    or false
    -- ranks[mixed] and ranks[mixed] is to avoid returning nil given any string
end

--- Returns the group object used to sort ranks given group name or see Ranking.get_rank
-- @usage Ranking.get_group(game.player)
-- Ranking.get_group('root')
-- @param mixed player|player index|player name|rank name|rank|'server'|'root'|group name|group what group to get
-- @treturn table the group that is linked to mixed
function Ranking.get_group(mixed)
    local groups = Ranking._groups()
    local rank = Ranking.get_rank(mixed)
    return rank and rank.group
    or is_type(mixed,'table') and mixed.ranks and mixed
    or is_type(mixed,'string') and groups[mixed] and groups[mixed]
    or false
end

--- Prints to all rank of greater/lower power of the rank given
-- @usage Ranking.print('admin','We got a grifer')
-- @param rank_base the rank that acts as the cut off point (rank is always included)
-- @param rtn what do you want to return to the players
-- @tparam bolean below if true rank below base are printed to
function Ranking.print(rank_base,rtn,below)
    local rank_base = Ranking.get_rank(rank_base)
    local ranks = Ranking._ranks()
    if below then
        for power,rank in pairs(ranks) do
            if rank_base.power >= power then rank:print(rtn) end
        end
    else
        for power,rank in pairs(ranks) do
            if rank_base.power <= power then rank:print(rtn) end
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
    local tick = tick or game.tick
    local by_player_name = Game.get_player(by_player).name or game.player and game.player.name or 'server'
    local rank = Ranking.get_rank(rank)
    local player = Game.get_player(player)
    local old_rank = Ranking.get_rank(player)
    local message = 'ranking.rank-down'
    -- messaging
    if old_rank.name == rank.name then return end
    if rank.power < old_rank.power then message = 'ranking.rank-up' end
    game.print{message,player.name,rank.name,by_player_name}
    if not rank.group.name == 'User' then player.print{'ranking.rank-given',rank.name} end
    if not player.tag == old_rank.tag then player.print{'ranking.tag-reset'} end
    -- rank change
    player.permission_group = game.permissions.get_group(rank.name)
    player.tag = rank.tag
    if not old_rank.group.name == 'Jail' then Ranking._presets().old[player.index] = rank.name end
    if Ranking._presets()._event then 
        script.raise_event(Ranking._presets()._event,{
            tick=tick, 
            player=player, 
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



-- this is the base rank object, do not store in global
Ranking._rank = {}

--- Is this rank allowed to open this gui or use this command etc.
-- @usage rank:allowed('server-interface')
-- @tparam teh action to test for
-- @treturn bolean is it allowed
function Ranking._rank:allowed(action)
    return self.allowed[action] or self.is_root or false
end

--- Get all the players in this rank
-- @usage rank:get_players()
-- @tparam bolean online get only online players
-- @treturn table a table of all players in this rank
function Ranking._rank:get_players(online)
    local _return = {}
    if online then
        for _,player in pairs(game.connected_players) do
            if Ranking.get_rank(player).name == self.name then table.insert(_return,player) end
        end
    else
        for _,player in pairs(game.players) do
            if Ranking.get_rank(player).name == self.name then table.insert(_return,player) end
        end
    end
    return _return
end

--- Print a message to all players of this rank
-- @usage rank:print('foo')
-- @param rtn any value you want to return
function Ranking._rank:print(rtn)
    if not Server or not Server._thread then
        for _,player in pairs(self:get_players()) do
            player_return(rtn,player)
        end
    else
        -- using threads to make less lag
        local thread = Server.new_thread{data={rank=self,rtn=rtn}}
        thread.on_event('resolve',function(thread)
            return self.data:get_players(true)
        end)
        thread.on_event('success',function(thread,players)
            for _,player in pairs(players) do
                player_return(rtn,player)
            end
        end)
    end
end
-- this is the base rank object, do not store in global
Ranking._group = {}

return Ranking