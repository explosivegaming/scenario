--- A full ranking system for factorio.
-- @submodule ExpGamingCore.Ranking
-- @alias Ranking
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Server is present
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')
local Server = require('ExpGamingCore.Server')
local Ranking = Ranking

--- Print a message to all players of this rank
-- @usage rank:print('foo') -- prints to all members of this rank
-- @param rtn any value you want to return
-- @tparam[opt=defines.color.white] define.color colour the colour that will be used to print
-- @tparam[opt=false] boolean show_default weather to use the default rank name for the print, used as a pass though
function Ranking._rank:print(rtn,colour,show_default)
    local colour = colour or defines.color.white
    local default = Ranking.get_rank(Ranking.meta.default)
    Server.new_thread{
        data={rank=self,rtn=rtn,default=default.name,all=show_default}
    }:on_event('resolve',function(thread)
        return thread.data.rank:get_players(true)
    end):on_event('success',function(thread,players)
        for _,player in pairs(players) do
            if thread.data.rank.name == thread.data.default or thread.data.all then
                player_return({'ranking.all-rank-print',thread.data.rtn},colour,player)
            else
                player_return({'ranking.rank-print',thread.data.rank.name,thread.data.rtn},colour,player)
            end
        end
    end):queue()
end

script.on_event('on_tick',function(event)
    if (((event.tick+10)/(3600*game.speed))+(15/2))% 15 == 0 then
        Server.new_thread{
            data={players=game.connected_players}
        }:on_event('tick',function(thread)
            if #thread.data.players == 0 then thread:close() return end
            local player = table.remove(thread.data.players,1)
            Ranking.find_preset(player,tick)
        end):open()
    end
end)

Server.add_to_interface('rank',function() return Ranking.get_rank(game.player) end)
Server.add_module_to_interface('Ranking','ExpGamingCore.Ranking')