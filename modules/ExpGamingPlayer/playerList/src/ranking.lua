local Ranking = require('ExpGamingCore.Ranking@^4.0.0')

return function()
    local rtn = {}
    for _,rank in pairs(Ranking.ranks) do
        table.insert(rtn,{rank.colour,rank.short_hand,rank:get_players(true),rank:allowed('no-report')})
    end
    return rtn
end