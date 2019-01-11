--- A full ranking system for factorio.
-- @module ExpGamingCommands.cheatMode@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- Toggles cheat mode for a player
-- @command cheat-mode
-- @param[opt] player the player to toggle if nil then the player using the command
commands.add_command('cheat-mode', 'Toggles cheat mode for a player', {
    ['player']={false,'player'}
}, function(event,args)
    local player = args.player or game.player
    if player.cheat_mode == true then player.cheat_mode = false else player.cheat_mode = true end
end).default_admin_only = true
