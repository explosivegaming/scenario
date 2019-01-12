--- Adds a thread system and event listening and a admin bypass (recommend to disable /c and use optional /interface)
-- @module ExpGamingCore.Server
-- @alias Server
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')

local Server = {}
local module_verbose = false --true|false

--- Global Table
-- @table global
-- @field all a list of every thread (indexed by uuid)
-- @field queue an index for threads which will be resolved (contains uuids)
-- @field tick an index for threads which will run every tick (contains uuids)
-- @field timeout an index for threads which will timeout (contains uuids)
-- @field events an index of threads based on event ids (contains uuids)
-- @field paused an index of paused threads (contains uuids)
-- @field named  a name index for thread uuids
-- @field print_to contains players that event details will be printed to
-- @field uuid contains the random number generator for the uuid system
local pre_load_uuid = 0
local global = global{
    all={_n=0},
    queue={},
    tick={},
    timeout={},
    events={},
    paused={},
    named={},
    print_to={},
    uuid=0
}

--- Used to generate a new uuid for the thread system
-- @usage local uuid = tostring(Server.uuid) -- calling tostring locks the value
-- @treturn string the new uuid
Server.uuid = add_metatable({},function()
    -- when it is called as a function
    local uuid
    if game then
        global.uuid=global.uuid+1
        uuid=global.uuid+pre_load_uuid
        verbose('Game UUID Increased: '..global.uuid..' ('..uuid..')')
    else
        pre_load_uuid=pre_load_uuid+1
        uuid=pre_load_uuid
        verbose('Load UUID Increased: '..pre_load_uuid..' ('..uuid..')')
    end
    return add_metatable({uuid},nil,function(tbl) return string.format("%x", tostring(tbl[1])) end)
end,function()
    -- when it is treated as a string
    return tostring(Server.uuid())
end)

--- Redirect to the thread index
-- @usage Server.threads -- return #global.all
-- @usage Server.threads -- return global.all
-- @treturn[1] number the number of threads
-- @treturn[2] table table of all threads
Server.threads = setmetatable({},{
    __metatable=false,
    __call=function(tbl) return global.all._n end,
    __len=function(tbl) return global.all._n end,
    __index=function(tbl,key) return rawget(global.all,key) end,
    __newindex=function(tbl,key,value) rawset(global.all,key,value) end,
    __pairs=function(tbl)
        local tbl = global.all
        local function next_pair(tbl,key)
            local k, v = next(tbl, key)
            if type(v) ~= nil and k ~= '_n' then return k,v
            else return next(tbl, k) end
        end
        return next_pair, tbl, nil
    end
})

--- Generates a new thread object
-- @usage Server.new_thread{name='foo',data={}}
-- @tparam table obj the attributes to give to the thread
-- @treturn Server._thread the new thread created
function Server.new_thread(obj) return Server._thread.create(obj) end

--- Used to get a thread via uuid or name (if one is assigned)
-- @usage Server.get_thread('decon') -- return thread
-- @param mixed either a uuid or the name given to a thread
-- @treturn[1] Server._thread the thread by that name or uuid
-- @treturn[2] boolean if false is returned then no thread exists
function Server.get_thread(mixed)
    local threads = global
    if threads.named[mixed] then return threads.all[threads.named[mixed]]
    elseif threads.paused[mixed] then return threads.all[threads.paused[mixed]]
    elseif threads.all[mixed] then return threads.all[mixed]
    else return false end
end

--- Adds a thread into the resolve queue, can be used to lower lag
-- @usage Server.queue_thread(thread) -- return true/false
-- @tparam Server._thread thread_to_queue the thread to be added to the queue, must be open and have a on_resolve function
-- @treturn boolean was it added successfully
function Server.queue_thread(thread_to_queue)
    if not thread_to_queue and not thread_to_queue.valid and not thread_to_queue:valid() then return false end
    if not thread_to_queue._resolve then return false end
    table.insert(global.queue,thread_to_queue.uuid)
    return true
end

--- Closes all active threads, can use force if it causes errors
-- @usage Server.close_all_threads() -- asks all threads to close
-- @usage Server.close_all_threads(true) -- forcefully close all threads
-- @tparam boolean with_force use force when closing
function Server.close_all_threads(with_force)
    if not with_force then
        for uuid,thread in pairs(Server.threads) do thread:close() end
    else global.Server(true) end -- idk why you cant just use global even when global is defined at the top to be overridden
end

--- Runs all the threads which have opened with an on_tick event
-- @usage Server.run_tick_threads()
function Server.run_tick_threads()
    table.each(global.tick,function(uuid)
        local next_thread = Server.get_thread(uuid)
        if next_thread and next_thread:valid() and next_thread._tick then
            local success, err = Manager.sandbox(next_thread._tick,next_thread._env,next_thread)
            if not success then next_thread:error(err) end
        end
    end)
end

--- Checks the timeout on all active timeout threads
-- @usage Server.check_timeouts()
function Server.check_timeouts()
    table.each(global.timeout,function(uuid)
        local next_thread = Server.get_thread(uuid)
        if next_thread and next_thread:valid() then
            next_thread:check_timeout()
        end
    end)
end

--- Used to print event info to a player
-- @usage Server._thread_debuger('Cooldude2606','on_player_died',true) -- will output event info to 'Cooldude2606' for 'on_player_died'
-- @tparam ?name|index|LuaPlayer player the player that the info will be returned to
-- @tparam ?name|index event the event that info will be returned fo
-- @tparam[opt=toggle] boolean state will info be returned, nil to toggle current state 
function Server._thread_debuger(player,event,state)
    player = Game.get_player(player)
    event = tonumber(event) or Manager.event.names[event]
    local print_to = global.print_to
    print_to[player.index] = print_to[player.index] or {}
    if state then print_to[player.index][event] = state
    elseif print_to[player.index][event] then print_to[player.index][event] = false
    else print_to[player.index][event] = true end
end

--- Calls all threads on a certain game event (used with script.on_event)
-- @local Server._thread_handler
-- @usage script.on_event(defines.events,Server._thread_handler) -- adds this handler
-- @tparam table event the event that is called
function Server._thread_handler(event)
    -- returns to players who have set _thread_debuger to true
    table.each(global.print_to,function(print_to,player_index,event)
        if event.name == defines.events.on_tick then return true end
        if print_to[event.name] then
            player_return(event,defines.textcolor.bg,player_index)
        end
    end,event)
    -- gets the thread uuids
    local event_id = event.name
    local threads = global.events[event_id]
    if not threads then return end
    -- loops over the uuids
    table.each(threads,function(uuid)
        local thread = Server.get_thread(uuid)
        if thread and thread:valid() then
            if is_type(thread._events[event_id],'function') then
                -- runs the function in the same env it was created (avoids desyncs)
                local success, err = Manager.sandbox(thread._events[event_id],thread._env,thread,event)
                -- if there is an error it asks the thread to deal with it
                if not success then thread:error(err) end
            end
        end
    end)
end

--[[ cant be used V
--- Adds a event handler to tell threads about events
-- @usage Server.add_thread_handler(defines.event)
-- @tparam number event the event to run the thread handler on`
-- @treturn boolean if the handler was added
function Server.add_thread_handler(event)
    if not is_type(event,'number') then return false end
    local threads = global
    if not threads.events[event] then 
        threads.events[event] = {}
        script.on_event(event,Server._thread_handler)
        return true
    end
    return false
end
]]

--- Acts as a bypass for running functions, can accept a string
-- @usage Server.interface('local x = 1+1 print(x) return x') -- return 2
-- @usage Server.interface('local x = 1+1 print(x)',true) -- will create a thread to run as root (this is the bypass)
-- @tparam ?string|function callback function to be ran
-- @tparam[opt] ?Server._thread|true use_thread run the command on a pre-made thread or let it make its own
-- @tparam[opt] table env run the env to run the command in must have _env key as true to be
-- @param[opt] ... any args you want to pass to the function
-- @treturn[1] boolean if no thread then it will return a true for the success
-- @return[1] if no thread then it will return the value(s) returned by the callback
-- @treturn[2] boolean if no thread then it will return a false for the success
-- @treturn[2] string if no thread then it will return a an err value
function Server.interface(callback,use_thread,env,...)
    if use_thread then
        -- if use_thread is true then it makes a new thread
        if use_thread == true then use_thread = Server.new_thread{data={callback,env,...}} end
        -- creates the resolve function for the thread
        use_thread:on_event('resolve',function(thread)
            local thread_callback = table.remove(thread.data,1)
            thread_callback = is_type(thread_callback,'function') and thread_callback or loadstring(thread_callback)
            local thread_env = table.remove(thread.data,1)
            if is_type(thread_env,'table') and not is_type(thread_env.__self,'userdata') and thread_env._env == true then
                local success, err = Manager.sandbox(thread_callback,thread_env,unpack(thread.data))
                if not success then error(err) end
                return err
            else 
                local success, err = Manager.sandbox(thread_callback,{},env,unpack(thread.data))
                if not success then error(err) end
                return err
            end
        end)
        -- opens the thread and then queues it
        use_thread:open()
        Server.queue_thread(use_thread)
    else
        local _callback = callback
        if not is_type(callback,'function') then
            local rtn, err = loadstring(callback)
            if err then return false, err end
            _callback = rtn
        end
        if is_type(env,'table') and not is_type(env.__self,'userdata') and env._env == true then
            local success, err = Manager.sandbox(_callback,env,...)
            if not success then return success,err
            else return success, unpack(err) end
        else 
            local success, err = Manager.sandbox(_callback,{},env,...)
            if not success then return success,err
            else return success, unpack(err) end
        end
    end
end

--- The class for the server threads, allows ability to run async function
-- @type Thread
-- @alias Server._thread
-- @field name the name that is given to the thread, use for easy later indexing
-- @field timeout the time in ticks that the thread will have before it times out
-- @field reopen when true the thread will reopen itself until set to false, combine with timeout to create a long on_nth_tick wait
-- @field data any data that the thread will be able to access
Server._thread = {}

local _env_metatable = {
    __index=function(tbl,key) if rawget(tbl,'_modules') and tbl._modules[key] then return require(tbl._modules[key]) else return rawget(_G,key) end end
}

--- Returns a new thread object
-- @usage new_thread = thread:create()
-- @tparam[opt={}] table obj all values are opt {timeout=int,name=str,data=any}
-- @treturn Server._thread the new thread object
function Server._thread.create(obj)
    obj = obj or {}
    setmetatable(obj,{__index=Server._thread})
    obj.uuid = tostring(Server.uuid)
    -- creates a variable containing all upvalus for the thread (stops desyncs)
    obj._env = get_upvalues(2)
    obj._env._env = true
    obj._env._ENV = nil -- prevents infinite recursion
    -- removes any modules from the _env to save space in global (less time to serialize)
    obj._env._modules = {}
    for name,value in pairs(obj._env) do
        if is_type(value,'table') and value._moduleName and loaded_modules[value._moduleName] == value then 
            obj._env._modules[name] = value._moduleName obj._env[name] = nil 
        end
    end
    setmetatable(obj._env,_env_metatable)
    local name = obj.name or 'Anon'
    verbose('Created new thread: '..name..' ('..obj.uuid..')')
    return obj
end

--- Opens and queues a thread
-- @usage Server._thread:queue() -- returns true/false
-- @treturn boolean was the thread queued successfully
-- @see Server.queue_thread
function Server._thread:queue()
    self:open()
    return Server.queue_thread(self)
end

--- Test if the thread has all required parts
-- @usage if thread:valid() then end -- basic test for valid
-- @tparam[opt=false] boolean skip_location_check true to skip the location checking
-- @treturn boolean is the thread valid
function Server._thread:valid(skip_location_check)
    skip_location_check = skip_location_check or false
    if is_type(self.uuid,'string') and
    skip_location_check or is_type(self.opened,'number') and
    skip_location_check or is_type(global.all[self.uuid],'table') and
    is_type(self.timeout) or is_type(self.timeout,'number') and
    is_type(self.name) or is_type(self.name,'string') and
    is_type(self._close) or is_type(self._close,'function') and
    is_type(self._timeout) or is_type(self._timeout,'function') and
    is_type(self._tick) or is_type(self._tick,'function') and
    is_type(self._resolve) or is_type(self._resolve,'function') and
    is_type(self._success) or is_type(self._success,'function') and
    is_type(self._error) or is_type(self._error,'function') then
        -- all above must be true to be valid, must accept nil and function
        return true
    end
    return false
end

--- Opens the thread; indexes this thread in the global index
-- @usage thread:open() -- return true
-- @treturn boolean if the thread was opened successfully
function Server._thread:open()
    -- if the thread is valid and not already opened
    if not self:valid(true) or self.opened then return false end
    local uuid = self.uuid
    -- sets the thread to open, this is the tick it was opened
    self.opened = game.tick
    -- creates the global index
    global.all[uuid] = global.all[uuid] or self
    global.all._n = global.all._n+1
    -- indexes the thread in other places if it has more function
    -- if it was paused before (ie did not run any events) then the index is removed from the paused index
    if global.paused[self.name] then global.paused[self.name] = nil end
    -- if it has a timeout or on_tick handler then it is indexed in those indexes
    if is_type(self.timeout,'number') then table.insert(global.timeout,uuid) end
    if is_type(self._tick,'function') then table.insert(global.tick,uuid) end
    -- if the thread is given a name then a index from the name to uuid is made
    if is_type(self.name,'string') then global.named[self.name] = global.named[self.name] or self.uuid end
    -- if there are event handlers then it will loop over them and add them to the event index
    if is_type(self._events,'table') then
        table.each(self._events,function(callback,event,global,uuid)
            -- cant be used V
            --Server.add_thread_handler(event)
            if not global.events[event] then global.events[event] = {} end
            table.insert(global.events[event],uuid)
        end,global,self.uuid)
    end
    local name = self.name or 'Anon'
    verbose('Opened thread: '..name..' ('..self.uuid..')')
    return true
end

--- Inverse of thread:open() - Removes all indexes to this thread, most cases this will cause it to become inaccessible
-- @usage thread:close() -- return true
-- @treturn boolean if the thread had a on_close function
function Server._thread:close()
    local uuid = self.uuid
    local _return = false
    -- if there is a call to the threads on close event, will later return true
    if is_type(self._close,'function') then Manager.sandbox(self._close,self._env,self) _return = true end
    -- will search every possible location for this thread and remove it
    local _,key = table.find(global.queue,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(global.queue,key) end -- queue
    _,key = table.find(global.timeout,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(global.timeout,key) end -- timeouts
    _,key = table.find(global.tick,function(v,k,uuid) return v == uuid end,uuid)
    if key then table.remove(global.tick,key) end -- on_tick
    -- then will look for it in the event handlers and remove it if found
    if is_type(self._events,'table') then
        table.each(self._events,function(callback,event)
            if global.events[event] then
                local _,key = table.find(global.events[event],function(v,k,uuid) return v == uuid end,uuid)
                if key then table.remove(global.events[event],key) end
                -- cant be used V
                --if #global.events[event] == 0 then Event.remove(event,Server.game_event) global.events[event] = nil end
            end
        end)
    end
    -- sets the thread to closed
    self.opened=nil
    -- unless the thread has a name or is assigned to be reopened
    if self.reopen == true then self:open() else
        -- if it has a name but not assigned to reopen then it will become 'paused'
        if is_type(self.name,'string') then global.paused[self.name]=self.uuid
        -- else it will just be wiped from the global index
        else global.all[uuid] = nil global.all._n = global.all._n-1 end
    end
    local name = self.name or 'Anon'
    verbose('Closed thread: '..name..' ('..self.uuid..')')
    return _return
end

--- Trigger the on_resolve function and closes the thread - error and success called based on result of pcall (useful for async)
-- @usage thread:resolve(x,y,z) -- return true
-- @param[opt] ... any arguments you want to pass to the resolve function
-- @treturn boolean true if the thread called on_success or on_error
function Server._thread:resolve(...)
    local _return = false
    -- checks if the resolve handler is still present
    if is_type(self._resolve,'function') then
        local success, err = Manager.sandbox(self._resolve,self._env,self,...)
        if success then
            -- if it was successful then it will attempt to call the success handler
            if is_type(self._success,'function') then
                -- interface is used as a way to delay the success call till the next tick
                Server.interface(function(thread,err)
                    local _success, _err = Manager.sandbox(thread._success,thread._env,thread,err)
                    if not _success then thread:error(_err) end
                end,true,self,err)
                -- later returns true if there was a call to the success handler
                _return = true
            end
            -- if there is an error the thread is asked to deal with it, returns true/false based on result of handler
        else _return = self:error(err) end
    end
    -- closes the thread as it is no longer needed as its command has be ran
    self:close()
    return _return
end

--- Checks the timeout on a thread - if timed out then it calls on_timeout and closes
-- @usage thread:check_timeout() -- return true
-- @treturn boolean if the thread timed out
function Server._thread:check_timeout()
    local _return = false
    -- makes sure the thread is still valid
    if not self:valid() then return false end
    -- checks if the thread has been opened longer than its time out period
    if is_type(self.timeout,'number') and game.tick >= (self.opened+self.timeout) then
        if is_type(self._timeout,'function') then
            -- we do not care if the time out has caused an error as it is in most cases an error in its own right
            Manager.sandbox(self._timeout,self._env,self)
        end
        _return = true
        -- closes the thread to prevent any further event calls
        self:close()
    end
    return _return
end

--- Used to check and raise the error handler of the thread, if not present it raises an error
-- @usage thread:error(err) -- return true
-- @tparam string err the err to be raised
-- @treturn boolean did the thread have an error handler
function Server._thread:error(err)
    local _return = false
    if is_type(self._error,'function') then
        Manager.sandbox(self._error,self._env,self,err)
        _return = true
    else 
        self:close() -- no matter what happens next this thread will be closed
        error('Thread Error (no handler): '..err)
    end
    return _return
end

--- Set function to run then an event is triggered, none of them are 'needed' but you are advised to have at least one
-- @usage thread:on_event('close',function) -- if event is not one below then a game event is used
-- @usage thread_only_events = ['close','timeout','tick','resolve','success','error']
-- @tparam ?string|index event the name of the event that the function should be called on
-- @tparam function callback the function which is called by the event trigger
-- @treturn table returns self so that they can be chained together
function Server._thread:on_event(event,callback)
    local events = {'close','timeout','tick','resolve','success','error'}
    -- searches the above list for the event
    local value = table.find(events,function(v,k,find) return v == string.lower(find) end,event)
    if value and is_type(callback,'function') then
        -- if it is a thread_only_event then it will add it to its core values
        self['_'..value] = callback
    elseif is_type(event,'number') and is_type(callback,'function') then
        -- other wise it is appended to the event index of the thread
        if not self._events then self._events = {} end
        self._events[event] = callback
    end
    -- returns self to allowing chaining of on_event():on_event():on_event() etc..
    return self
end

script.on_event(defines.events.on_tick,function(event)
    -- uses its own on_tick event so that other actions can be tested for
    if event.tick < 10 then return end
    if #global.tick > 0 then Server.run_tick_threads() end -- on tick events
    if #global.timeout > 0 then Server.check_timeouts() end -- timeout checks
    if #global.queue > 0 then -- resolve one thread
        local current_thread = global.all[global.queue[1]]
        if current_thread and current_thread:valid() then current_thread:resolve() end
    end
end)

script.on_load(function(event)
    -- sets up metatable again so that threads continue to work
    for uuid,thread in pairs(Server.threads) do 
        setmetatable(thread,{__index=Server._thread}) 
        setmetatable(thread._env,_env_metatable)
    end
end)

function Server:on_init()
    for name,id in pairs(defines.events) do if not script.get_event_handler(id) then script.on_event(id,Server._thread_handler) end end
    if loaded_modules['ExpGamingCore.Command'] then verbose('ExpGamingCore.Command is installed; Loading commands src') require(module_path..'/src/commands',{Server=Server}) end
end

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

    all on_event functions can be chained from the thread creation rather than use variables eg:
    Server.new_thread{
        name='tree-decon',
        data={}
    }:on_event('tick',function(self) 
        local trees = self.data
        if #trees == 0 then return end
        local tree = table.remove(trees,1)
        if tree.valid then tree.destroy() end
    end):on_event('error',function(self,err)
        -- cant see how this can cause an error
        -- but this is where error handling goes
        -- any event including on_resolve and on_tick can raise this
    end):on_event(defines.events.on_marked_for_deconstruction,function(self,event)
        if event.entity.type == 'tree' then
            table.insert(self.data,event.entity)
        end
    end):open()
]]