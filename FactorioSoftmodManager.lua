--- Factorio Softmod Manager
-- @module FSM
-- @alias Manager
-- @author Cooldude2606
-- @usage Manager = require("FactorioSoftmodManager")
local moduleIndex = require("/modules/index")
local Manager = {}

--- Setup for metatable of the Manager to force read only nature
-- @usage Manager() -- runs Manager.loadModdules()
-- @usage Manager[name] -- returns module by that name
-- @usage tostring(Manager) -- returns formated list of loaded modules
local ReadOnlyManager = setmetatable({},{
    __metatable=false,
    __index=function(tbl,key)
        -- first looks in manager and then looks in mander.loadModules
        return rawget(Manager,key) ~= nil and rawget(Manager,key) or rawget(Manager.loadModules,key)
    end,
    __call=function(tbl)
        -- if there are no modules loaded then it loads them
        if #tbl.loadModules == 0 then
            tbl.loadModules()
        end
    end,
    __newindex=function(tbl,key,value)
        -- provents the changing of any key that is not currentState
        if key == 'currentState' then
            -- provides a verbose that is always emited describing the change in state
            Manager.verbose(string.rep('__',10)..'| Start: '..value..' |'..string.rep('__',10),true)
            Manager.verbose('The verbose state is now: '..tostring(Manager.setVerbose[value]),true) 
            rawset(Manager,key,value)
        else error('Manager is read only please use included methods',2)  end
    end,
    __tostring=function(tbl)
        -- acts as a redirect
        return tostring(Manager.loadModules)
    end
})

local function setupModuleName(name)
    -- creates a table that acts like a string but is read only
    return setmetatable({},{
        __index=function(tbl,key) return name end,
        __newindex=function(tbl,key,value) error('Module Name Is Read Only') end,
        __tostring=function(tbl) return name end,
        __concat=function(val1,val2) return type(val1) == 'string' and val1..name or name..val2 end,
        __metatable=false,
    })
end

Manager.currentState = 'selfInit'
-- selfInit > moduleLoad > moduleInit > modulePost > moduleEnv

--- Default output for the verbose
-- @usage Manager.verbose('Hello, World!')
-- @tparam string rtn the value that will be returned though verbose output
Manager._verbose = function(rtn)
    -- creates one file per game, ie clears file on reset
    if game and Manager.setVerbose._output ~= true then Manager.setVerbose._output=true game.write_file('verbose.log',rtn)
    elseif game then game.write_file('verbose.log','\n'..rtn,true) end
    -- standard print and log, _log is a version of log which is ln1 of control.lua for shorter log lines
    if print then print(rtn) end
    if _log then _log(rtn) end
end

--- Used to call the output of the verbose when the current state allows it
-- @usage Manager.verbose('Hello, World!')
-- @tparam string rtn the value that will be returned though verbose output
-- @tparam string action is used to decide which verbose this is error || event etc
Manager.verbose = function(rtn,action)
    local settings = Manager.setVerbose
    local state = Manager.currentState
    if Manager.error and state == Manager.error.__crash then return end
    -- if ran in a module the the global module_name is present
    local rtn = type(rtn) == table and serpent.line(rtn) or tostring(rtn)
    if module_name then rtn='['..module_name..'] '..rtn
    else rtn='[FSM] '..rtn end
    -- module_verbose is a local override for a file, action is used in the manager to describe an extra type, state is the current state
    -- if action is true then it will always trigger verbose
    if module_verbose or (action and (action == true or settings[action])) or (not action and settings[state]) then
        if type(settings.output) == 'function' then
            -- calls the output function, not pcalled as if this fails some thing is very wrong
            settings.output(rtn)
        else
            error('Verbose set for: '..state..' but output can not be called',2)
        end
    end
end

--- Main logic for allowing verbose at different stages though out the script
-- @function Manager.setVerbose
-- @usage Manager.setVerbose{output=log}
-- @tparam newTbl settings the table that will be searched for settings to be updated
-- @usage Manager.setVerbose[setting] -- returns the value of that setting
-- @usage tostring(Manager.setVerbose) -- returns a formated list of the current settings
Manager.setVerbose = setmetatable(
    --- Different verbose settings used for setVerbose
    -- @table Manager.verboseSettings
    -- @tfield boolean selfInit called while the manager is being set up
    -- @tfield boolean moduleLoad when a module is required by the manager
    -- @tfield boolean moduleInit when and within the initation of a module
    -- @tfield boolean modulePost when and within the post of a module
    -- @tfield boolean moduleEnv during module runtime, this is a global option set within each module(module_verbose=true ln:1) for fine control
    -- @tfield boolean eventRegistered when a module registers its event handlers
    -- @tfield boolean errorCaught when an error is caught during runtime
    -- @tfield function output can be: print || log || or other function
    -- @field _output a constant value that can used to store output data
    {
        selfInit=true,
        moduleLoad=false,
        moduleInit=false,
        modulePost=false,
        moduleEnv=false,
        eventRegistered=false,
        errorCaught=true,
        output=Manager._verbose,
        _output={}
    },
    {
        __metatable=false,
        __call=function(tbl,settings)
            -- does not allow any new keys, but will override any existing ones
            for key,value in pairs(settings) do
                if rawget(tbl,key) ~= nil then
                    Manager.verbose('Verbose for: "'..key..'" has been set to: '..tostring(value))
                    rawset(tbl,key,value)
                end
            end
        end,
        __newindex=function(tbl,key,value)
            -- stops creationg of new keys
            error('New settings cannot be added during runtime',2)
        end,
        __index=function(tbl,key)
            -- will always return a value, never nil
            return rawget(tbl,key) or false
        end,
        __tostring=function(tbl)
            -- a simple concat function for the settings
            local rtn = ''
            for key,value in pairs(tbl) do
                if type(value) == 'boolean' then
                    rtn=rtn..key..': '..tostring(value)..', '
                end
            end
            return rtn:sub(1,-3)
        end
    }
)
-- call to verbose to show start up, will always be present
Manager.verbose(string.rep('__',10)..'| Start: selfInit |'..string.rep('__',10),true)
Manager.verbose('The verbose state is: '..tostring(Manager.setVerbose.selfInit),true)

--- Used to avoid conflicts in the global table
-- @usage global[key] -- used like the normal global table
-- @usage global{'foo','bar'} -- sets the default value
-- @usage global(true) -- restores global to default
-- @usage global(mopdule_name) -- returns that module's global
-- @tparam[opt={}] ?table|string|true if table then the default for the global, if a string then the module to get the global of, if true then reset the global to default
-- @treturn table the new global table for that module
Manager.global=setmetatable({__defaults={},__global={
    __call=function(tbl,default) return Manager.global(default) end,
    __index=function(tbl,key) return rawget(Manager.global(),key) or tbl(key) end,
    __newindex=function(tbl,key,value) rawset(Manager.global(),key,value) end,
    __pairs=function(tbl)
        local tbl = Manager.global()
        local function next_pair(tbl,k)
            k, v = next(tbl, k)
            if type(v) ~= nil then return k,v end
        end
        return next_pair, tbl, nil
    end
}},{
    __call=function(tbl,default,tbl2)
        local global = _G.global
        local tbl2 = type(tbl2) == 'table' and getmetatable(tbl2) or nil
        local module_name = type(default) == 'string' and default or tbl2 and tbl2.name or module_name
        local module_path = type(default) == 'string' and moduleIndex[default] or tbl2 and tbl2.path or module_path
        if not module_path or not module_name then return _G.global end
        if type(default) == 'table' then Manager.verbose('Default global has been set for: global'..module_path:gsub('/','.')) rawset(rawget(tbl,'__defaults'),tostring(module_name),default) end
        local path = 'global'
        local new_dir = false
        for dir in module_path:gmatch('%a+') do
            path = path..'.'..dir
            if not rawget(global,dir) then new_dir=true Manager.verbose('Added Global Dir: '..path) rawset(global,dir,{}) end
            global = rawget(global,dir)
        end
        if (new_dir or default == true) and rawget(rawget(tbl,'__defaults'),tostring(module_name)) then 
            Manager.verbose('Set Global Dir: '..path..' to its default')
            -- cant set it to be equle otherwise it will lose its global propeity 
            local function deepcopy(tbl) if type(tbl) ~= 'table' then return tbl end local rtn = {} for key,value in pairs(tbl) do rtn[key] = deepcopy(value) end return rtn end
            for key,value in pairs(global) do rawset(global,key,nil) end
            for key,value in pairs(rawget(rawget(tbl,'__defaults'),tostring(module_name))) do rawset(global,key,deepcopy(value)) end
        end
        return setmetatable(global,{
            __call=function(tbl,default) return Manager.global(default,tbl) end,
            __index=function(tbl,key) return rawget(Manager.global(),key) or tbl(key) end,
            path=module_path,name=module_name
        })
    end,
    __index=function(tbl,key) return rawget(tbl(),key) or rawget(_G.global,key) or tbl(key) end,
    __newindex=function(tbl,key,value) rawset(tbl(),key,value) end,
    __pairs=function(tbl)
        local tbl = Manager.global()
        local function next_pair(tbl,k)
            k, v = next(tbl, k)
            if type(v) ~= nil then return k,v end
        end
        return next_pair, tbl, nil
    end
})
setmetatable(global,Manager.global.__global)

--- Creates a sand box envorment and runs a callback in that sand box; provents global pollution
-- @function Manager.sandbox
-- @usage Manager.sandbox(callback) -- return sandbox, success, other returns from callback
-- @tparam function callback the function that will be ran in the sandbox
-- @param[opt] env any other params that the function will use
-- @usage Manager.sandbox() -- returns and empty sandbox
-- @usage Manager.sandbox[key] -- returns the sand box value in that key
Manager.sandbox = setmetatable({
    -- can not use existing keys of _G
    verbose=Manager.verbose,
    loaded_modules=ReadOnlyManager,
    module_verbose=false,
    module_exports=false
},{
    __metatable=false,
    __index=ReadOnlyManager,
    __call=function(tbl,callback,env,...)
        if type(callback) == 'function' then 
            -- creates a new sandbox env
            local sandbox = tbl()
            local env = type(env) == 'table' and env or type(env) ~= 'nil' and {env} or {}
            -- new indexs are saved into sandbox and if _G does not have the index then look in sandbox
            local old_mt = getmetatable(_G) or {}
            setmetatable(env,{__index=sandbox})
            setmetatable(_G,{__index=env,__newindex=sandbox})
            -- runs the callback
            local rtn = {pcall(callback,...)}
            local success = table.remove(rtn,1)
            -- this is to allow modules to be access with out the need of using Mangaer[name] also keeps global clean
            setmetatable(_G,old_mt)
            if success then return sandbox, success, rtn
            else return sandbox, success, rtn[1] end
        else return setmetatable({},{__index=tbl}) end
    end
})

--- Allows access to modules via require and collections are returned as one object
-- @function Manager.require
-- @usage local Module = Manager.require(ModuleName)
-- @usage local Module = Manager.require[ModuleName]
-- @usage local SrcData = Manager.require(path)
-- @treturn table the module that was required, one object containg submodules for a 
Manager.require = setmetatable({
    __require=require
},{
    __metatable=false,
    __index=function(tbl,key) return tbl(key) end,
    __call=function(tbl,path,env) 
        local raw_require = rawget(tbl,'__require')
        local env = env or {}
        -- runs in a sand box becuase sandbox everything
        local sandbox, success, data = Manager.sandbox(raw_require,env,path)
        -- if there was no error then it assumed the path existed and returns the data
        if success then return data
        else
            -- else it assums the path was a module name and checks index for the module
            if moduleIndex[path] then return rawget(Manager.loadModules,path) end
            -- if its not listed then it tries to remove a version tag and tries again
            local path_no_version = path.find('@') and path:sub(1,path:find('@')-1) or path
            if moduleIndex[path_no_version] then return rawget(Manager.loadModules,path_no_version) end
            -- still no then it will look for all modules that include this one in the name (like a collection)
            local collection = {}
            for module_name,path in pairs(moduleIndex) do
                if module_name:find(path_no_version) then 
                    local start, _end = module_name:find(path_no_version)
                    collection[module_name:sub(_end)] = rawget(Manager.loadModules,module_name)
                end
            end
            -- if there is any keys in the collection the collection is returned else the errors with the require error
            for _ in pairs(collection) do return collection end
            error(data,2)
        end
    end
})
require = Manager.require

--- Loads the modules that are present in the index list
-- @function Manager.loadModules
-- @usage Manager.loadModules() -- loads all moddules in the index list
-- @usage #Manager.loadModules -- returns the number of modules loaded
-- @usage tostring(Manager.loadModules) -- returns a formatted list of all modules loaded
-- @usage pairs(Manager.loadModules) -- loops over the loaded modules moduleName, module
Manager.loadModules = setmetatable({},
    {
        __metatable=false,
        __call=function(tbl)
            -- ReadOnlyManager used to trigger verbose change
            ReadOnlyManager.currentState = 'moduleLoad'
            -- goes though the index looking for modules
            for module_name,path in pairs(moduleIndex) do
                Manager.verbose('Loading module: "'..module_name..'"; path: '..path)
                -- runs the module in a sandbox env
                local sandbox, success, module = Manager.sandbox(Manager.require.__require,{module_name=setupModuleName(module_name),module_path=path},path..'/control')
                -- extracts the module into a global index table for later use
                if success then
                    -- verbose to notifie of any globals that were attempted to be created
                    local globals = ''
                    for key,value in pairs(sandbox) do globals = globals..key..', ' end
                    if globals ~= '' then Manager.verbose('Globals caught in "'..module_name..'": '..globals:sub(1,-3),'errorCaught') end
                    Manager.verbose('Successfully loaded: "'..module_name..'"; path: '..path)
                    -- sets that it has been loaded and adds to the loaded index
                    -- if you prefere module_exports can be used rather than returning the module
                    if type(tbl[module_name]) == 'nil' then
                        -- if it is a new module then creat the new index
                        if string.find(module_name,'GlobalLib') then
                            Manager.verbose('Extracting GlobalLib: '..module_name)
                            -- if it is named GlobalLib then it will be auto extracted into _G
                            if sandbox.module_exports and type(sandbox.module_exports) == 'table'
                            then for key,value in pairs(sandbox.module_exports) do _G[key] = value end
                            else for key,value in pairs(table.remove(module,1)) do _G[key] = value end end
                        else
                            if sandbox.module_exports and type(sandbox.module_exports) == 'table'
                            then tbl[module_name] = sandbox.module_exports
                            else tbl[module_name] = table.remove(module,1) end
                        end
                    elseif type(tbl[module_name]) == 'table' then
                        -- if this module adds onto an existing one then append the keys
                        if sandbox.module_exports and type(sandbox.module_exports) == 'table'
                        then for key,value in pairs(sandbox.module_exports) do tbl[module_name][key] = value end
                        else for key,value in pairs(table.remove(module,1)) do tbl[module_name][key] = value end end
                    else
                        -- if it is a function then it is still able to be called even if more keys are going to be added
                        -- if it is a string then it will act like one; if it is a number well thats too many metatable indexs
                        tbl[module_name] = setmetatable({__old=tbl[module_name]},{
                            __call=function(tbl,...) if type(tbl.__old) == 'function' then tbl.__old(...) else return tbl.__old end end,
                            __tostring=function(tbl) return tbl.__old end,
                            __concat=function(tbl,val) return tbl.__old..val end
                        })
                        -- same as above for adding the keys to the table
                        if sandbox.module_exports and type(sandbox.module_exports) == 'table'
                        then for key,value in pairs(sandbox.module_exports) do tbl[module_name][key] = value end
                        else for key,value in pairs(table.remove(module,1)) do tbl[module_name][key] = value end end
                    end
                    -- if there is a module by this name in _G ex table then it will be indexed to the new module
                    if rawget(_G,module_name) and type(tbl[module_name]) == 'table' then setmetatable(rawget(_G,module_name),{__index=tbl[module_name]}) end
                else
                    Manager.verbose('Failed load: "'..module_name..'"; path: '..path..' ('..module..')','errorCaught')
                    for event_name,callbacks in pairs(Manager.event) do Manager.verbose('Removed Event Handler: "'..module_name..'/'..Manager.event.names[event_name],'eventRegistered') callbacks[module_name] = nil end
                end
            end
            -- new state for the manager to allow control of verbose
            ReadOnlyManager.currentState = 'moduleInit'
            -- runs though all loaded modules looking for on_init function; all other modules have been loaded use this to load extra code based on opttial dependies
            for module_name,data in pairs(tbl) do
                -- looks for init so that init or on_init can be used
                if type(data) == 'table' and data.init and data.on_init == nil then data.on_init = data.init data.init = nil end
                if type(data) == 'table' and data.on_init and type(data.on_init) == 'function' then
                    Manager.verbose('Initiating module: "'..module_name..'"')
                    local sandbox, success, err = Manager.sandbox(data.on_init,{module_name=setupModuleName(module_name),module_path=moduleIndex[tostring(module_name)]},data)
                    if success then
                        Manager.verbose('Successfully Initiated: "'..module_name..'"')
                    else
                        Manager.verbose('Failed Initiation: "'..module_name..'" ('..err..')','errorCaught')
                    end
                    -- clears the init function so it cant be used in runtime
                    data.on_init = nil
                end
            end
            -- new state for the manager to allow control of verbose
            ReadOnlyManager.currentState = 'modulePost'
            -- runs though all loaded modules looking for on_post function; all other modules have been loaded and inited, do not load extra code in this time only altar your own data
            for module_name,data in pairs(tbl) do
                -- looks for post so that post or on_post can be used
                if type(data) == 'table' and data.post and data.on_post == nil then data.on_post = data.post data.post = nil end
                if type(data) == 'table' and data.on_post and type(data.on_post) == 'function' then
                    Manager.verbose('Post for module: "'..module_name..'"')
                    local sandbox, success, err = Manager.sandbox(data.on_post,{module_name=setupModuleName(module_name),module_path=moduleIndex[tostring(module_name)]},data)
                    if success then
                        Manager.verbose('Successful post: "'..module_name..'"')
                    else
                        Manager.verbose('Failed post: "'..module_name..'" ('..err..')','errorCaught')
                    end
                    -- clears the post function so it cant be used in runtime
                    data.on_post = nil
                end
            end
            -- this could also be called runtime
            ReadOnlyManager.currentState = 'moduleEnv'
        end,
        __len=function(tbl)
            -- counts the number of loaded modules
            local rtn = 0
            for key,value in pairs(tbl) do
                rtn = rtn + 1
            end
            return rtn
        end,
        __tostring=function(tbl)
            -- a concat of all the loaded modules
            local rtn = 'Load Modules: '
            for key,value in pairs(tbl) do
                    rtn=rtn..key..', '
            end
            return rtn:sub(1,-3)
        end
    }
)

--- A more detailed replacement for the lua error function to allow for handlers to be added; repleaces default error so error can be used instead of Manager.error
-- @function Manager.error
-- @usage Manager.error(err) -- calls all error handlers that are set or if none then prints to game and if that fails crashs game
-- @usage Manager.error() -- returns an error constant that can be used to crash game
-- @usage Manager.error(Manager.error()) -- crashs the game
-- @usage Manager.error.addHandler(name,callback) -- adds a new handler if handler returns Manager.error() then game will crash
-- @tparam[2] ?string|fucntion err the string to be passed to handlers; if a function it will register a handler
-- @tparam[2] function callback if given the err param will be used to given the handler a name
-- @usage Manager.error[name] -- returns the handler of that name if present
-- @usage #Manager.error -- returns the number of error handlers that are present
-- @usage pairs(Manager.error) -- loops over only the error handlers handler_name,hander
Manager.error = setmetatable({
    __crash=false,
    __error_call=error,
    __error_const={},
    __error_handler=function(handler_name,callback)
        -- when handler_name is a string it is expeced that callback is a function; other wise handler_name must be a function
        if type(handler_name) == 'string' and type(callback) == 'function' then Manager.error[handler_name]=callback
        elseif type(handler_name) == 'function' then table.insert(Manager.error,handler_name)
        else Manager.error('Handler is not a function',2) end
    end
},{
    __metatalbe=false,
    __call=function(tbl,err,...)
        -- if no params then return the error constant
        if err == nil then return rawget(tbl,'__error_const') end
        -- if the error constant is given crash game
        if err == rawget(tbl,'__error_const') then Manager.verbose('Force Stop','errorCaught') rawget(tbl,'__error_call')('Force Stop',2) end
        -- other wise treat the call as if its been passed an err string
        Manager.verbose('An error has occurred: '..err,'errorCaught')
        if #tbl > 0 then
            -- there is at least one error handler loaded; loops over the error handlers
            for handler_name,callback in pairs(tbl) do
                local success, err = pcall(callback,err,...)
                if not success then Manager.verbose('Error handler: "'..handler_name..'" failed to run ('..err..')','errorCaught') end
                -- if the error constant is returned from the handler then crash the game
                if err == rawget(tbl,'__error_const') then Manager.verbose('Force Stop by: '..handler_name,'errorCaught') rawget(tbl,'__error_call')('Force Stop by: '..handler_name) end
            end
        elseif game then
            -- there are no handlers loaded so it will print to the game if loaded
            Manager.verbose('No error handlers loaded; Default game print used','errorCaught')
            game.print(err)
        else
            -- all else fails it will crash the game with the error code
            Manager.verbose('No error handlers loaded; Game not loaded; Forced crash: '..err,'errorCaught')
            rawget(tbl,'__error_call')(err,2)
        end
    end,
    __index=function(tbl,key)
        -- this allows the __error_handler to be called from many different names
        if key:lower() == 'addhandler' or key:lower() == 'sethandler' or key:lower() == 'handler' or key:lower() == 'register' then return rawget(tbl,'__error_handler')
        else rawget(tbl,'__error_call')('Invalid index for error handler; please use build in methods.') end
    end,
    __newindex=function(tbl,key,value)
        -- making a new index adds it as a handler
        if type(value) == 'function' then 
            Manager.verbose('Added Error Handler: "'..key..'"','eventRegistered')
            rawset(tbl,key,value)
        end
    end,
    __len=function(tbl)
        -- counts the number of handlers there are
        local rtn=0
        for handler_name,callback in pairs(tbl) do
            rtn=rtn+1
        end
        return rtn
    end,
    __pairs=function(tbl)
        -- will not return any of the three core values as part of pairs
        local function next_pair(tbl,k)
            local v
            k, v = next(tbl, k)
            if k == '__error_call' or k == '__error_const' or k == '__error_handler' or k == '__crash' then return next_pair(tbl,k) end
            if type(v) == 'function' then return k,v end
        end
        return next_pair, tbl, nil
    end
})
-- overrides the default error function
error=Manager.error

-- event does work a bit differnt from error, and if event breaks error is the fallback

--- Event handler that modules can use, each module can register one function per event
-- @function Manager.event
-- @usage Manager.event[event_name] = callback -- sets the callback for that event
-- @usage Manager.event[event_name] = nil -- clears the callback for that event
-- @usage Manager.event(event_name,callback) -- sets the callback for that event
-- @usage Manager.event[event_name] -- returns the callback for that event or the event id if not registered
-- @usage Manager.event(event_name) -- runs all the call backs for that event
-- @tparam ?int|string event_name that referes to an event
-- @tparam function callback the function that will be set for that event
-- @usage Manager.event() -- returns the stop value for the event proccessor, if returned during an event will stop all other callbacks
-- @usage #Manager.event -- returns the number of callbacks that are registered
-- @usage pairs(Manager.events) -- returns event_id,table of callbacks
Manager.event = setmetatable({
    __stop={},
    __events={},
    __event=script.on_event,
    __generate=script.generate_event_name,
    __get_handler=script.get_event_handler,
    __raise=script.raise_event,
    __init=script.on_init,
    __load=script.on_load,
    __config=script.on_configuration_changed,
    events=defines.events
},{
    __metatable=false,
    __call=function(tbl,event_name,new_callback,...)
        if Manager.error.__crash then Manager.error.__error_call('No error handlers loaded; Game not loaded; Forced crash: '..tostring(Manager.error.__crash)) end
        -- if no params then return the stop constant
        if event_name == nil then return rawget(tbl,'__stop') end
        -- if the event name is a table then loop over each value in that table
        if type(event_name) == 'table' then
            for key,_event_name in pairs(event_name) do tbl(_event_name,new_callback,...) end return
        end
        -- convert the event name to a number index
        event_name = tonumber(event_name) or tbl.names[event_name]
        -- if there is a callback present then set new callback rather than raise the event
        if type(new_callback) == 'function' then
            Manager.event[event_name] = new_callback return
        end
        -- other wise raise the event and call every callback; no use of script.raise_event due to override
        if type(tbl[event_name]) == 'table' then
            for module_name,callback in pairs(tbl[event_name]) do
                -- loops over the call backs and which module it is from
                if type(callback) ~= 'function' then error('Invalid Event Callback: "'..event_name..'/'..module_name..'"') end
                local sandbox, success, err = Manager.sandbox(callback,{module_name=setupModuleName(module_name),module_path=moduleIndex[tostring(module_name)]},new_callback,...)
                if not success then Manager.verbose('Event Failed: "'..module_name..'/'..tbl.names[event_name]..'" ('..err..')','errorCaught') error('Event Failed: "'..module_name..'/'..tbl.names[event_name]..'" ('..err..')') end
                -- if stop constant is returned then stop further processing
                if err == rawget(tbl,'__stop') then Manager.verbose('Event Haulted By: "'..module_name..'"','errorCaught') break end
            end
        end
    end,
    __newindex=function(tbl,key,value)
        -- handles the creation of new event handlers
        if type(value) ~= 'function' and type(value) ~= nil then error('Attempted to set a non function value to an event',2) end
        -- checks for a global module name that is present
        local module_name = module_name or 'FSM'
        -- converts the key to a number index for the event
        Manager.verbose('Added Handler: "'..tbl.names[key]..'"','eventRegistered')
        -- checks that the event has a valid table to store callbacks; if its not valid it will creat it and register a real event handler
        if not rawget(rawget(tbl,'__events'),key) then
            if key == -1 or key == -2 then -- this already has a handler
            elseif key < 0  then rawget(tbl,tbl.names[key])(function(...) tbl(key,...) end) 
            else rawget(tbl,'__event')(key,function(...) tbl(key,...) end) end
            rawset(rawget(tbl,'__events'),key,{}) end
        -- adds callback to Manager.event.__events[event_id][module_name]
        rawset(rawget(rawget(tbl,'__events'),key),tostring(module_name),value)
    end,
    __index=function(tbl,key)
        -- few redirect key
        local redirect={register=tbl,dispatch=tbl,remove=function(event_id) tbl[event_name]=nil end}
        if rawget(redirect,key) then return rawget(redirect,key) end
        -- proforms different look ups depentding weather the current module has an event handler registered
        if module_name then
            -- first looks for the event callback table and then under the module name; does same but converts the key to a number; no handler regisered so returns the converted event id
            return rawget(rawget(tbl,'__events'),key) and rawget(rawget(rawget(tbl,'__events'),key),tostring(module_name))
            or rawget(rawget(tbl,'__events'),rawget(tbl,'names')[key]) and rawget(rawget(rawget(tbl,'__events'),rawget(tbl,'names')[key]),tostring(module_name)) 
            or rawget(tbl,'names')[key]
        else
            -- if there is no module present then it will return the full list of regisered handlers; or other wise the converted event id
            return rawget(rawget(tbl,'__events'),key) or rawget(rawget(tbl,'__events'),rawget(tbl,'names')[key]) or rawget(tbl,'names')[key]
        end
    end,
    __len=function(tbl)
        -- counts every handler that is regised not just the the number of events with handlers
        local rtn=0
        for event,callbacks in pairs(tbl) do
            for module,callback in pairs(callbacks) do
                rtn=rtn+1
            end
        end
        return rtn
    end,
    __pairs=function(tbl)
        -- will loops over the event handlers and not Manager.event
        local function next_pair(tbl,k)
            k, v = next(rawget(tbl,'__events'), k)
            if type(v) == 'table' then return k,v end
        end
        return next_pair, tbl, nil
    end
})

--- Sub set to Manger.event and acts as a coverter between event_name and event_id
-- @table Manager.event.names
-- @usage Manager.event[event_name]
rawset(Manager.event,'names',setmetatable({},{
    __index=function(tbl,key)
        if type(key) == 'number' or tonumber(key) then
            -- if it is a number then it will first look in the chache
            if rawget(tbl,key) then return rawget(tbl,key) end
            -- if it is a core event then it will simply return
            if key == -1 then rawset(tbl,key,'__init')
            elseif key == -2 then rawset(tbl,key,'__load')
            elseif key == -3 then rawset(tbl,key,'__config')
            else
                -- if it is not a core event then it does a value look up on Manager.events aka defines.events
                for event,id in pairs(rawget(Manager.event,'events')) do
                    if id == key then rawset(tbl,key,event) end
                end
            end
            -- returns the value from the chache after being loaded in
            return rawget(tbl,key)
            -- if it is a string then no reverse look up is required
        else
            if key == 'on_init' or key == 'init' or key == '__init' then return -1
            elseif key == 'on_load' or key == 'load' or key == '__load' then return -2
            elseif key == 'on_configuration_changed' or key == 'configuration_changed' or key == '__config' then return -3
            else return rawget(rawget(Manager.event,'events'),key) end
        end
    end
}))

script.on_init(function(...)
    setmetatable(global,Manager.global.__global)
    Manager.event(-1,...) 
end)

script.on_load(function(...)
    setmetatable(global,Manager.global.__global)
    Manager.event(-2,...)
end)
--over rides for the base values; can be called though Event
Event=setmetatable({},{__call=Manager.event,__index=function(tbl,key) return Manager.event[key] or script[key] or error('Invalid Index To Table Event') end})
script.mod_name = setmetatable({},{__index=_G.module_name})
script.on_event=Manager.event
script.raise_event=Manager.event
script.on_init=function(callback) Manager.event(-1,callback) end
script.on_load=function(callback) Manager.event(-2,callback) end
script.on_configuration_changed=function(callback) Manager.event(-3,callback) end
script.get_event_handler=function(event_name) return type(Manager.event[event_name]) == 'function' and Manager.event[event_name] or nil end
script.generate_event_name=function(event_name) local event_id = Manager.event.__generate() local event_name = event_name or event_id Manager.event.events[event_name]=event_id return event_id end
-- to do set up nth tick

return ReadOnlyManager