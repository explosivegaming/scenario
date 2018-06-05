--- Description - A small description that will be displayed on the doc
-- @submodule ExpGamingCore.Server
-- @alias Server
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Commands is present
-- @function _comment

--- Runs the given input from the script
-- @command interface
-- @param code The code that will be ran
commands.add_command('interface',{'Server.interface-description'}, {
    ['code']={true,'string-inf'}
}, function(event,args)
    local callback = args.code
    -- looks for spaces, if non the it will prefix the command with return
    if not string.find(callback,'%s') and not string.find(callback,'return') then callback = 'return '..callback end
    -- sets up an env for the command to run in
    local env = {_env=true,}
    if game.player then 
        env.player = game.player
        env.surface = game.player.surface
        env.force = game.player.force
        env.position = game.player.position
        env.entity = game.player.selected
        env.tile = game.player.surface.get_tile(game.player.position)
        if Ranking and Ranking.get_rank then env.rank = Ranking.get_rank(game.player) end
    end
    -- runs the function
    local success, err = Server.interface(callback,false,env)
    -- if there is an error then it will remove the stacktrace and return the error
    if not success and is_type(err,'string') then local _end = string.find(err,':1:') if _end then err = string.sub(err,_end+4) end end
    -- if there is a value returned that is not nill then it will return that value
    if err or err == false then player_return(err) end
end)