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
Server.thread = {}
Server.thread.__index = Server.thread

--- Returns a un-used uuid (better system needed)
-- @usage obj.uuid = Server.new_uuid()
-- @treturn string the new uuid
function Server.new_uuid()
	local uuid = tostring(Server._uuid()())
	uuid = string.to_hex('uuid'..uuid)
	return uuid
end

-- use this to change the location of the server uuids
function Server._uuid(reset)
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
    global.exp_core.threads = not reset and global.exp_core.threads or {queue={},tick={},timeout={},events={},all={},paused={},named={}}
    return global.exp_core.threads
end

-- see thread:create (this was done so thread can remain local)
function Server.new_thread(obj)
    return Server.thread:create(obj)
end

--- Used to get a thread via it's uuid or by name if one is given
-- @usage Server.get_thread('decon') -- return thread
-- @param mixed either a uuid or the name given to a thread
-- @treturn table the thread by that name or uuid
function Server.get_thread(mixed)
    local threads = Server._threads()
    if threads.named[mixed] then return threads.all[threads.named[mixed]]
    elseif threads.paused[mixed] then return threads.all[threads.paused[mixed]]
    elseif threads.all[mixed] then return threads.all[mixed]
    else return false end
end

--- Adds a thread into the resolve queue, can be used to lower lag
-- @usage Server.queue_thread(thread) -- return true/false
-- @tparam table the thread to add to the queue must have a resolve function (must be open)
-- @treturn bolean was the thread added
function Server.queue_thread(thread_to_queue)
    if not thread_to_queue and not thread_to_queue.valid and not thread_to_queue:valid() then return false end
    if not thread_to_queue._resolve then return false end
    table.insert(Server._threads().queue,thread_to_queue.uuid)
    return true
end

--- Closes all active threads, can use force if it causes errors
-- @usage Server.close_all_threads()
-- Server.close_all_threads(true) -- use if no force makes errors
-- @tparam bolean with_force use force when closing
function Server.close_all_threads(with_force)
    if not with_force then
        for uuid,next_thread in pairs(Server.threads()) do
            next_thread:close()
        end
    else
        Server._threads(true)
    end
end

--- Runs all the theads which have opened with an on_tick event
-- @ussage Server.run_tick_threads()
function Server.run_tick_threads()
    table.each(Server._threads().tick,function(uuid)
        local next_thread = Server.get_thread(uuid)
        if next_thread and next_thread:valid() and next_thread._tick then
            local success, err = pcall(next_thread._tick,next_thread)
            if not success then next_thread:error(err) end
        end
    end)
end

--- Checks the timeout on all active timeout threads
-- @ussage Server.check_timeouts()
function Server.check_timeouts()
    table.each(Server._threads().timeout,function(uuid)
        local next_thread = Server.get_thread(uuid)
        if next_thread and next_thread:valid() then
            next_thread:check_timeout()
        end
    end)
end

--- Calles all threads on a certain game event (used with script.on_event)
-- @tparam table event the event that is called
function Server._thread_handler(event)
    local event_id = event.name
    local threads = Server._threads().events[event_id]
    if not threads then return end
    table.each(threads,function(uuid)
        local next_thread = Server.get_thread(uuid)
        if next_thread and next_thread:valid() then
            if is_type(next_thread._events[event_id],'function') then
                local success, err = pcall(next_thread._events[event_id],next_thread,event)
                if not success then next_thread:error(err) end
            end
        end
    end)
end

for _,event in pairs(defines.events) do Event.register(event,Server._thread_handler) end

--[[ cant be used V
--- Adds a event handler to tell threads about events
-- @usage Server.add_thread_handler(defines.event)
-- @tparam number event the event to run the thread handler on
-- @treturn bolean if the handler was added
function Server.add_thread_handler(event)
    if not is_type(event,'number') then return false end
    local threads = Server._threads()
    if not threads.events[event] then 
        threads.events[event] = {}
        Event.register(event,Server._thread_handler)
        return true
    end
    return false
end
]]

--- Given a string or function it will run that function and return any values
-- @usage Server.interface('local x = 1+1 print(x) return x') -- return 2
-- Server.interface('local x = 1+1 print(x)',thread) -- no return
-- @param callback either a function or string which will be ran via pcall
-- @param[opt] use_thread give a thread for the interface to run on (does not need to be open, but cant use on_resolve)
-- @param[opt] ... any args you want to pass to the function
function Server.interface(callback,use_thread,...)
    if use_thread then
        use_thread:on_resolve(function(callback,...)
            if is_type(callback,'function') then
                pcall(callback,...)
            else 
                pcall(loadstring(callback),...)
            end
        end)
        use_thread:open()
        Server.queue_thread(use_thread)
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
--- Returns a new thread object
-- @usage new_thread = thread:create()
-- @tparam[opt={}] table obj all are opt {timeout=int,name=str,data=any} advanced users can prefix with _function to avoid the on_function functions
-- @treturn table the new thread object
function Server.thread:create(obj)
    local obj = obj or {}
    setmetatable(obj,Server.thread)
    obj.uuid = Server.new_uuid()
    return obj
end

--- Test if the thread has all requied parts
-- @usage if thread:valid() then end
-- @tparam bolean skip_location_check true to skip the location check
-- @treturn bolean is the thread valid
function Server.thread:valid(skip_location_check)
    local skip_location_check = skip_location_check or false
    if is_type(self.uuid,'string') and
    skip_location_check or is_type(self.opened,'number') and
    skip_location_check or is_type(Server._threads().all[self.uuid],'table') and
    is_type(self.timeout) or is_type(self.timeout,'number') and
    is_type(self.name) or is_type(self.name,'string') and
    is_type(self._close) or is_type(self._close,'function') and
    is_type(self._timeout) or is_type(self._timeout,'function') and
    is_type(self._tick) or is_type(self._tick,'function') and
    is_type(self._resolve) or is_type(self._resolve,'function') and
    is_type(self._success) or is_type(self._success,'function') and
    is_type(self._error) or is_type(self._error,'function') then
        return true
    end
    return false
end

--- Opens the thread by storing it in a place the server object can find it
-- @usage thread:open() -- return true
-- @treturn bolean if the thread was opened
function Server.thread:open()
    if not self:valid(true) or self.opened then return false end
    local threads = Server._threads()
    local uuid = self.uuid
    self.opened = game.tick
    threads.all[uuid] = threads.all[uuid] or self
    if is_type(self.timeout,'number') then table.insert(threads.timeout,uuid) end
    if is_type(self._tick,'function') then table.insert(threads.tick,uuid) end
    if is_type(self.name,'string') then threads.named[self.name] = threads.named[self.name] or self.uuid end
    if is_type(self._events,'table') then 
        table.each(self._events,function(callback,event,threads,uuid)
            -- cant be used V
            --Server.add_thread_handler(event)
            if not threads.events[event] then threads.events[event] = {} end
            table.insert(threads.events[event],uuid)
        end,threads,self.uuid)
    end
    return true
end

--- Inverse of thread:open() - it removes the thread and calles on_close
-- @usage thread:close() -- return true
-- @treturn bolean if the thread had a on_close function
function Server.thread:close()
    local threads = Server._threads()
    local uuid = self.uuid
    local _return = false
    if is_type(self._close,'function') then pcall(self._close,self) _return = true end
    local value,key = table.find(threads.queue,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.queue,key) end
    local value,key = table.find(threads.timeout,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.timeout,key) end
    local value,key = table.find(threads.tick,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(threads.tick,key) end
    if is_type(self._events,'table') then
        table.each(self._events,function(callback,event)
            if threads.events[event] then
                local value,key = table.find(threads.events[event],function(v,k,uuid) return v == uuid end,uuid)
                if key then table.remove(threads.events[event],key) end
                -- cant be used V
                --if #threads.events[event] == 0 then Event.remove(event,Server.game_event) threads.events[event] = nil end
            end
        end)
    end
    if is_type(self.name,'string') then threads.paused[self.name] = self.uuid self.opened = nil
    else table.remove(threads.all,uuid) end
    return _return
end

--- Trigger the on_resolve function and closes the thread - error and success called based on result of pcall (useful for async)
-- @usage thread:resolve(x,y,z) -- return true
-- @param[opt] ... any arguments you want to pass to the resolve function
-- @treturn bolean true if the thread called on_success or on_error
function Server.thread:resolve(...)
    local _return = false
    if is_type(self._resolve,'function') then 
        local success, err = pcall(self._resolve,...)
        if success then
            if is_type(self._success,'function') then
                pcall(self._success,self,err)
                _return = true
            end
        else
            _return = self:error(err)
        end
    end
    self:close()
    return _return
end

--- Checks the timeout on a thread - if timedout then it calles on_timeout and closes
-- @usage thread:check_timeout() -- return true
-- @treturn bolean if the thread timedout
function Server.thread:check_timeout()
    local _return = false
    if not self:valid() then return false end
    if is_type(self.timeout,'number') and game.tick >= (self.opened+self.timeout) then
        if is_type(self._timeout,'function') then
            pcall(self._timeout,self)
        end
        _return = true
        self:close()
    end
    return _return
end

--- Rasies an error on this thread
-- @usage thread:error(err) -- return true
-- @param err the err to be rasied
-- @treturn bolean did the thread handdle the error
function Server.thread:error(err)
    local _return = false
    if is_type(self._error,'function') then
        pcall(self._error,self,err)
        _return = true
    else
        error(err)
    end
    return _return
end
--- Set function to run then an event is called on a thread, none of them are 'needed' but you are advised to have atleast one
-- @usage thread:on_event('close',function) -- return true
-- events = ['close','timeout','tick','resolve','success','error']
-- if event is a number then it is asumed to be a game event
-- @tparam string event the name of the event that it is called on
-- @tparam function callback the function which is called on the event
-- @treturn was the function added
function Server.thread:on_event(event,callback)
    local events = {'close','timeout','tick','resolve','success','error'}
    local value = table.find(events,function(v,k,find) return v == string.lower(find) end,event)
    if value and is_type(callback,'function') then
        self['_'..value] = callback
        return true
    elseif is_type(event,'number') and is_type(callback,'function') then
        if not self._events then self._events = {} end
        self._events[event] = callback
        return true
    end
    return false
end

Event.register(defines.events.on_tick,function(event)
    local threads = Server._threads()
    if #threads.tick > 0 then Server.run_tick_threads() end
    if #threads.timeout > 0 then Server.check_timeouts() end
    if #threads.queue > 0 then 
        local current_thread = threads.all[threads.queue[1]]
        if current_thread and current_thread:valid() then current_thread:resolve() end
    end
end)

Event.register(-2,function(event)
    local threads = Server.threads()
    for uuid,thread in pairs(threads) do
        setmetatable(thread,Server.thread)
    end
end)

return Server
--[[
    Thread Example: 

    local thread = Server.new_thread{name='tree-decon',data={}}
    -- user thread:on_event('tick') rather than thread:on_event(defines.events.on_tick) as it makes less lag
    thread:on_event('tick',function(self) 
        local trees = self.data
        if #trees == 0 then return end
        local tree = table.remove(trees,1)
        if tree.valid then tree.destroy() end
    end)
    thread:on_event('error',function(self,err)
        -- cant see how this can cause an error
        -- but this is where error handling goes
        -- any event including on_resolve and on_tick can raise this
    end)
    thread:on_event(defines.events.on_marked_for_deconstruction,function(self,event)
        if event.entity.type == 'tree' then
            table.insert(self.data,event.entity)
        end
    end)
    thread:open()

    local thread = Server.new_thread{name='print-place',data={}}
    thread:on_event(defines.events.on_built_entity,function(self,event)
        game.print('Events')
    end)
    thread:open()
]]