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
        if thread and thread:valid() and thread._tick then
            local success, err = pcall(thread._tick,thread)
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
    if not string.find(callback,'%s') and not string.find(callback,'return') then callback = 'return '..callback end
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
-- @tparam bolean skip_location_check true to skip the location check
-- @treturn bolean is the thread valid
function thread:valid(skip_location_check)
    if is_type(self.uuid,'string') and
    is_type(self.opened,'number') and
    skip_location_check or is_type(Server._threads().all[self.uuid],'table') and
    is_type(self.timeout,'nil') or is_type(self.timeout,'number') and
    is_type(self.name,'nil') or is_type(self.name,'string') and
    is_type(self._close,'nil') or is_type(self._close,'function') and
    is_type(self._timeout,'nil') or is_type(self._timeout,'function') and
    is_type(self._tick,'nil') or is_type(self._tick,'function') and
    is_type(self._resolve,'nil') or is_type(self._resolve,'function') and
    is_type(self._success,'nil') or is_type(self._success,'function') and
    is_type(self._error,'nil') or is_type(self._error,'function') then
        return true
    end
    return false
end

--- Opens the thread by storing it in a place the server object can find it
-- @usage thread:open() -- return true
-- @treturn bolean if the thread was opened
function thread:open()
    if not self:valid(true) then return false end
    local threads = Server._threads()
    local uuid = self.uuid
    threads.all[uuid] = self
    if is_type(self.timeout,'number') then table.insert(threads.timeout,uuid) end
    if is_type(self._tick,'function') then table.insert(threads.on_tick,uuid) end
    return true
end

--- Inverse of thread:open() - it removes the thread and calles on_close
-- @usage thread:close() -- return true
-- @treturn bolean if the thread had a on_close function
function thread:close()
    local threads = Server._threads()
    local uuid = self.uuid
    local _return = false
    if is_type(self._close,'function') then pcall(self._close) _return = true end
    local value,key = table.find(threads.queue,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.queue,key) end
    local value,key = table.find(threads.timeout,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.timeout,key) end
    local value,key = table.find(threads.on_tick,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.on_tick,key) end
    table.remove(threads.all,uuid)
    return _return
end

--- Trigger the on_resolve function and closes the thread - error and success called based on result of pcall (useful for async)
-- @usage thread:resolve(x,y,z) -- return true
-- @param[opt] ... any arguments you want to pass to the resolve function
-- @treturn bolean true if the thread called on_success or on_error
function thread:resolve(...)
    local _return = false
    if is_type(self._resolve,'function') then 
        local success, err = pcall(self._resolve,...)
        if success then
            if is_type(self._success,'function') then
                pcall(self._success,err)
                _return = true
            end
        else
            if is_type(self._error,'function') then
                pcall(self._error,err)
                _return = true
            end
        end
    end
    self:close()
    return _return
end

--- Checks the timeout on a thread - if timedout then it calles on_timeout and closes
-- @usage thread:check_timeout() -- return true
-- @treturn bolean if the thread timedout
function thread:check_timeout()
    local _return = false
    if not self:valid() then return false end
    if is_type(self.timeout,'number') and game.tick >= (self.opened+self.timeout) then
        if is_type(self._timeout,'function') then
            pcall(self._timeout)
        end
        _return = true
        self:close()
    end
    return _return
end

--- Set function to run then an event is called on a thread, none of them are 'needed' but you are advised to have atleast one
-- @usage thread:on_event('close',function) -- return true
-- events = ['close','timeout','tick','resolve','success','error']
-- @tparam string event the name of the event that it is called on
-- @tparam function callback the function which is called on the event
-- @treturn was the function added
function thread:on_event(event,callback)
    local events = ['close','timeout','tick','resolve','success','error']
    local value = table.find(threads.queue,function(v,k,find) return v == string.lower(find) end,event)
    if value and is_type(callback,'function') then
        self['_'..value] = callback
        return true
    end
    return false
end
