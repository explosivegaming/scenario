--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
-- server allows control over threads and other features the devs missed out
local server = {}

--- Returns a un-used uuid (better system needed)
-- @usage obj.uuid = server.new_uuid()
-- @treturn string the new uuid
function server.new_uuid()
	uuid = tostring(global.exp_core.uuids.operator())
	uuid = string.tohex('uuid'..uuid)
	return uuid
end

--- Returns either the number of threads or a able of threads
-- @usage server.threads() -- {...}
-- server.threads(true) -- int
-- @tparam[opt=nil] bolean count true to return the number of threads
-- @return either a list of threads or a number
function server.threads(count)
    return count and #global.exp_core.threads.all or global.exp_core.threads.all
end

function server.queue_thread(thread)
    -- adds a thread the the queue to be resolved
end

function server.close_all_threads(with_force)
    -- closes all threads, if with_force then it sets all threads to nil (no on_close event)
end

function server.run_on_tick_threads()
    -- runs the on tick function for all threads
end

function server.check_timeouts()
    -- checks the timeout status on all threads with timeout
end

function server.interface(callback)
    -- runs a function from a string and returns any errors or values
end

-- thread allows you to run fuinction async to the main game
local thread = {}
thread.__index = thread
--- Returns a new thread object
-- @usage new_thread = thread:create()
-- @tparam[opt={}] table obj all are opt {timeout=int,name=str,data=any} advanced users can prefix with _function to avoid the on_function functions
-- @treturn table the new thread object
function thread:create(obj)
    local obj = obj or {}
    setmetatable(obj,self)
    obj.uuid = server.new_uuid()
    return obj
end

function thread:valid()
    -- tests if the thread is valid and stored
end

function thread:open()
    -- adds the thread to global.exp_core.threads
end

function thread:close()
    -- removes the thread from global.exp_core.threads
end

function thread:resolve(args)
    -- runs the thread callback and closes
end

function thread:check_timeout()
    -- checks if the thread should time out
end

function thread:on_close(callback)
    -- set the function to run when closed (does not include timeout)
end

function thread:on_timeout(callback)
    -- set the function to run if the function times out
end

function thread:on_tick(callback)
    -- set the function to run every tick
end

function thread:on_resolve(callback)
    -- set the function to run when resolve is called 
end

function thread:on_success(callback)
    -- set the function to run if resolve gives no error
end

function thread:on_error(callback)
    -- set the function to run if if resolve gives an error
end

Event.register(Event.soft_init,function() 
    -- all stores the threads by uuid, the other three only store the uuid's to index in the all table
    global.exp_core.threads = {queue={},on_tick={},timeout={},all={}} 
    global.exp_core.uuids = game.create_random_generator() 
end)
