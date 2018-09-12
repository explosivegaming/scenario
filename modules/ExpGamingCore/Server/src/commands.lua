--- Adds a thread system and event listening and a admin bypass (recommend to disable /c and use optional /interface)
-- @submodule ExpGamingCore.Server
-- @alias Server
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

--- This file will be loaded when ExpGamingCore.Commands is present
-- @function _comment

local Game = require('FactorioStdLib.Game')
local Server = Server

Server.interfaceCallbacks = {}
function Server.add_to_interface(loadAs,callback) Server.interfaceCallbacks[loadAs] = callback end

function Server.add_module_to_interface(loadAs,moduleName,version)
    local moduleName = _G.moduleName or version and moduleName..'@'..version or moduleName or nil
    if not moduleName then error('No module name supplied for: '..loadAs,2) return end
    Server.add_to_interface(loadAs,function() return require(moduleName) end)
end
Server.add_module_to_interface('Server','ExpGamingCore.Server')

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
    end
    -- adds custom callbacks to the interface
    for name,callback in pairs(Server.interfaceCallbacks) do env[name] = callback() end
    -- runs the function
    local success, err = Server.interface(callback,false,env)
    -- if there is an error then it will remove the stacktrace and return the error
    if not success and is_type(err,'string') then local _end = string.find(err,':1:') if _end then err = string.sub(err,_end+4) end end
    -- if there is a value returned that is not nill then it will return that value
    if err or err == false then player_return(err) end
end)