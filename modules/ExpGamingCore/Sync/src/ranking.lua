--- Description - A small description that will be displayed on the doc
-- @submodule ExpGamingCore.Sync
-- @alias Sync
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Ranking is present
-- @function _comment
    
--- Used as a redirect to Ranking._base_preset that will set the rank given to a player apon joining
-- @usage Sync.set_ranks{player_name=rank_name,...}
function Sync.set_ranks(...)
    Ranking._base_preset(...)
end

--- Used to get the number of players in each rank and currently online
-- @usage Sync.count_ranks()
-- @treturn table contains the ranks and the players in that rank
function Sync.count_ranks()
    if not game then return {'Offline'} end
    if not Ranking then return {'Ranking module not installed'} end
    local _ranks = {}
    for power,rank in pairs(Ranking._ranks()) do
        local players = rank:get_players()
        for k,player in pairs(players) do players[k] = player.name end
        local online = rank:get_players(true)
        for k,player in pairs(online) do online[k] = player.name end
        _ranks[rank.name] = {players=players,online=online,n_players=#players,n_online=#online}
    end
    return _ranks
end

-- Adds a caption to the info gui that shows the rank given to the player
if Sync.add_to_gui then
    Sync.add_to_gui(function(player,frame)
        return 'You have been assigned the rank \''..Ranking.get_rank(player).name..'\''
    end)
end