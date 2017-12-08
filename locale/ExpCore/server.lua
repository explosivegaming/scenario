--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
-- server allows control over threads and other features the devs missed out
local Server = {}

--- Returns a un-used uuid (better system needed)
-- @usage obj.uuid = Server.new_uuid()
-- @treturn string the new uuid
function Server.new_uuid()
	uuid = tostring(Server._uuid().operator())
	uuid = string.tohex('uuid'..uuid)
	return uuid
end

-- use this to change the location of the server uuids
function Server._uuids(reset)
    global.exp_core = not reset and global.exp_core or {}
    global.exp_core.uuids = not reset and global.exp_core.uuids or game.create_random_generator()
    return global.exp_core.uuids
end

--- Returns either the number of threads or a able of threads
-- @usage Server.threads() -- return {...}
-- Server.threads(true) -- return int
-- @tparam[opt=nil] bolean count true to return the number of threads
-- @return either a list of threads or a number
function Server.threads(count)
    return count and #Server._threads().all or Server._threads().all
end

-- use this to change the location of the server threads
-- all stores the threads indexed uuid, the other three only store the uuid's to index in the all table
function Server._threads(reset)
    global.exp_core = not reset and global.exp_core or {}
    global.exp_core.threads = not reset and global.exp_core.threads or {queue={},on_tick={},timeout={},all={}}
    return global.exp_core.threads
end

-- see thread:create (this was done so thread can remain local)
function Server.new_thread(obj)
    return thread:create(obj)
end

--- Adds a thread into the resolve queue, can be used to lower lag
-- @usage Server.queue_thread(thread) -- return true/false
-- @tparam table the thread to add to the queue must have a resolve function (must be open)
-- @treturn bolean was the thread added
function Server.queue_thread(thread)
    if not thread and not thread.valid and not thread:valid() then return false end
    if not thread._resolve then return false end
    table.insert(Server._threads().queue,thread.uuid)
    return true
end

--- Closes all active threads, can use force if it causes errors
-- @usage Server.close_all_threads()
-- Server.close_all_threads(true) -- use if no force makes errors
-- @tparam bolean with_force use force when closing
function Server.close_all_threads(with_force)
    if not with_force then
        for uuid,thread in pairs(Server.threads()) do
            thread:close()
        end
    end
    Server._threads(true)
end

--- Runs all the theads which have opened with an on_tick event
-- @ussage Server.run_on_tick_threads()
function Server.run_on_tick_threads()
    table.each(Server._threads().on_tick,function(uuid)
        local thread = Server._threads().all[uuid]
        if thread and thread:valid() and thread._on_tick then
            local success, err = pcall(thread._on_tick,thread)
            if not success then error(err) end
        end
    end)
end

--- Checks the timeout on all active timeout threads
-- @ussage Server.check_timeouts()
function Server.check_timeouts()
    table.each(Server._threads().timeout,function(uuid)
        local thread = Server._threads().all[uuid]
        if thread and thread:valid() then
            thread:check_timeout()
        end
    end)
end

--- Given a string or function it will run that function and return any values
-- @usage Server.interface('local x = 1+1 print(x) return x') -- return 2
-- Server.interface('local x = 1+1 print(x)',thread) -- no return
-- @param callback either a function or string which will be ran via pcall
-- @param[opt] thread give a thread for the interface to run on (does not need to be open, but cant use on_resolve)
-- @param[opt] ... any args you want to pass to the function
function Server.interface(callback,thread,...)
    if thread then
        thread:on_resolve(function(callback,...)
            if is_type(callback,'function') then
                pcall(callback,...)
            else 
                pcall(loadstring(callback),...)
            end
        end)
        thread:open()
        Server.queue_thread(thread)
    else
        if is_type(callback,'function') then
            local success, err = pcall(callback,...)
            return success, err
        else 
            local success, err = pcall(loadstring(callback),...)
            return success, err
        end
        return false
    end
end

commands.add_command('server-interface', 'Runs the given input from the script', {'code',true}, function(event,args)
    local callback = args.code
    local success, err = Server.interface(callback)
    player_return(err)
end)

-- thread allows you to run fuinction async to the main game
local thread = {}
thread.__index = thread
thread.uuid = Server.new_uuid
--- Returns a new thread object
-- @usage new_thread = thread:create()
-- @tparam[opt={}] table obj all are opt {timeout=int,name=str,data=any} advanced users can prefix with _function to avoid the on_function functions
-- @treturn table the new thread object
function thread:create(obj)
    local obj = obj or {}
    setmetatable(obj,self)
    obj.uuid = Server.new_uuid()
    return obj
end

--- Test if the thread has all requied parts
-- @usage if thread:valid() then end
-- @treturn bolean is the thread valid
function thread:valid()
    if is_type(self.uuid,'string') and
    is_type(self.opened,'number') and
    is_type(global.exp_core.threads[self.uuid],'table') and
    is_type(self.timeout,'nil') or is_type(self.timeout,'number') and
    is_type(self.name,'nil') or is_type(self.name,'string') and
    is_type(self._close,'nil') or is_type(self._close,'function') and
    is_type(self._timeout,'nil') or is_type(self._timeout,'function') and
    is_type(self._on_tick,'nil') or is_type(self._on_tick,'function') and
    is_type(self._resolve,'nil') or is_type(self._resolve,'function') and
    is_type(self._success,'nil') or is_type(self._success,'function') and
    is_type(self._error,'nil') or is_type(self._error,'function') then
        return true
    end
    return false
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
    -- set the function to run when closed (also called on_timeout)
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
