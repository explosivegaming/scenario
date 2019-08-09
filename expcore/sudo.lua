--[[-- Core Module - Sudo
    - An extention of task and token to allow a single require to register and run functions bypassing all permissions.
    @core Sudo
    @alias Sudo

    @usage
    -- To use sudo you must register the allowed functions when the files are loaded, often this will just be giving access to
    -- some functions within a module if you expect that some parts may be blocked by in game permissions or a custom system you have made

    -- This will be blocked if the current player (from a command or gui) is not admin
    local function make_admin(player)
        player.admin = true
    end

    -- Here we give sudo access to the function under the name "make-admin"
    Sudo.register('make-admin',make_admin)

    -- This will allow us to bypass this by running one tick later outside of any player scope
    Sudo.run('make-admin',game.player)
]]
local Task = require 'utils.task' --- @dep utils.task
local Token = require 'utils.token' --- @dep utils.token

local Sudo = {
    tokens={}
}

local internal_run =
Token.register(function(params)
    local func = Token.get(params.token)
    func(unpack(params.params))
end)

--- Registers a new callback under the given name, used to avoid desyncs
-- @tparam string name the name that will be used to call this function
-- @tparam function callback the function that will be called by this name
function Sudo.register(name,callback)
    if _LIFECYCLE == 8 then
        error('Calling Sudo.register after on_init() or on_load() has run is a desync risk.', 2)
    end

    if Sudo.tokens[name] then
        error(name..' is already registered',2)
    end

    Sudo.tokens[name] = Token.register(callback)
end

--- Gets the function that is registered under the given name
-- @tparam string name the name of the function you want to get
function Sudo.get(name)
    local token = Sudo.tokens[name]
    return token and Token.get(token)
end

--- Runs the function that is registered under the given name, you may supply any number of params as needed
-- @tparam string name the name of the function you want to run
-- @tparam[opt] any ... the other params that you want to pass to your function
function Sudo.run(name,...)
    local token = Sudo.tokens[name]

    if not token then
        error('Sudo does not have access to run "'..tostring(name)..'" please make sure it is registered to sudo',2)
    end

    Task.set_timeout_in_ticks(1, internal_run, {
        token = token,
        params = {...}
    })
end

return setmetatable(Sudo,{
    __call = function(self,...)
        self.run(...)
    end
})