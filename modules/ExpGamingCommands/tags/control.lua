--- A full ranking system for factorio.
-- @module ExpGamingCommands.kill
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Ranking = require('ExpGamingCore.Ranking')

--- Gives you a tag
-- @command tag
-- @param tag the tag you want to have
commands.add_command('tag', 'Give yourself a custom tag. Use "" to have more than one word.', {
    ['tag'] = {true,'string-len',20}
}, function(event,args)
    local player = Game.get_player(event)
    local rank = Ranking.get_rank(player)
    player.tag = rank.tag..' - '..args.tag
    player_return('Your tag has been set. Use /tag-clear to remove your tag')
end)

--- Gives you a tag
-- @command tag
-- @param tag the tag you want to have
commands.add_command('tag-clear', 'Removes a custom tag. Player can be self (/tag-clear self)', {
    ['player'] = {true,'player-rank'}
}, function(event,args)
    local player = args.player
    local rank = Ranking.get_rank(player)
    player.tag = rank.tag
    player_return('Your tag has been removed.')
end)
