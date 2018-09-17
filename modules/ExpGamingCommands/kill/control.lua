--- A full ranking system for factorio.
-- @module ExpGamingCommands.kill@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game@^4.0.0')

--- Kills a player of a lower rank
-- @command kill
-- @param player the player to be killed
commands.add_command('kill', 'Kills a player. No player name kills yourself.', {
    ['player']={false,'player-rank-alive'}
}, function(event,args)
    local _player = Game.get_player(event)
    local player = args.player
    if player then player.character.die()
    else _player.character.die() end
end).default_admin_only = true
