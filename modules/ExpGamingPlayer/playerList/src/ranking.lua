local Ranking = require('ExpGamingCore.Ranking')

return function()
    local rtn = {}
    for _,rank in pairs(Ranking.ranks) do
        table.insert(rtn,{rank.colour,rank.short_hand,rank:get_players(true))
    end
    return rtn
end