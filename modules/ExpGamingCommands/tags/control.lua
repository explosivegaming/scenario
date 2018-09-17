--- A full ranking system for factorio.
-- @module ExpGamingCommands@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game@^0.8.0')
local Ranking -- ExpGamingCore.Ranking@^4.0.0

-- Module Define
local module_verbose = false
local ThisModule = {
    on_init=function()
        if loaded_modules['ExpGamingCore.Ranking@^4.0.0'] then Ranking = require('ExpGamingCore.Ranking@^4.0.0') end
        --code
    end
}

--- Gives you a tag
-- @command tag
-- @param tag the tag you want to have
commands.add_command('tag', 'Give yourself a custom tag. Use "" to have more than one word.', {
    ['tag'] = {true,'string-len',20}
}, function(event,args)
    local player = Game.get_player(event)
    if Ranking then
        local rank = Ranking.get_rank(player)
        player.tag = rank.tag..' - '..args.tag
    else player.tag = args.tag end
    player_return('Your tag has been set. Use /tag-clear to remove your tag')
end)

--- Gives you a tag
-- @command tag
-- @param tag the tag you want to have
commands.add_command('tag-clear', 'Removes a custom tag. Player can be self (/tag-clear self)', {
    ['player'] = {true,'player-rank'}
}, function(event,args)
    local player = args.player
    if Ranking then
        local rank = Ranking.get_rank(player)
        player.tag = rank.tag
    else player.tag = '' end
    player_return('Your tag has been removed.')
end)

