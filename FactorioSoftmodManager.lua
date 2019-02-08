--- Factorio Softmod Manager
-- @module FSM
-- @alias Manager
-- @author Cooldude2606
-- @usage Manager = require("FactorioSoftmodManager")
local moduleIndex = require("/modules/index")
local Manager = {}

-- this is a constant that is used to represent the server
SERVER = setmetatable({index=0,name='<server>',online_time=0,afk_time=0,print=print,admin=true,valid=true,__self={}},{__index=function(tbl,key) if type(game.players[1][key]) == 'function' then return function() end else return nil end end})

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
    -- if ran in a module the the global moduleName is present
    local rtn = type(rtn) == table and serpent.line(rtn) or tostring(rtn)
    if moduleName then rtn='['..moduleName..'] '..rtn
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
    __call=function(tbl,default,metatable_src)
        -- creates varible link to global and module information, use of a metatable is for already formed globals
        local Global = _G.global
        local metatable = getmetatable(metatable_src)
        local moduleName = type(default) == 'string' and default or metatable and metatable._moduleName or moduleName
        local module_path = type(default) == 'string' and Manager.loadModules.__load[default] or metatable and metatable._module_path or module_path
        -- if there is no name or path then it will return and unedited version of global
        if not module_path or not moduleName then return _G.global end
        -- edits the link to global to be the corrected dir, path varible is also created
        local path = 'global'
        for dir in module_path:gmatch('%a+') do
            path = path..'.'..dir
            if not rawget(Global,dir) then Manager.verbose('Added Global Dir: '..path) rawset(Global,dir,{}) end
            Global = rawget(Global,dir)
        end
        -- the default value is set if there was a default given
        if type(default) == 'table' then Manager.verbose('Default global has been set for: global'..string.sub(module_path:gsub('/','.')),2) rawset(rawget(tbl,'__defaults'),tostring(moduleName),default) end
        -- if the default value is true then it will reset the global to its default
        if default == true and rawget(rawget(tbl,'__defaults'),tostring(moduleName)) then 
            Manager.verbose('Reset Global Dir to default: '..path)
            -- cant set it to be equle otherwise it will lose its global propeity 
            local function deepcopy(tbl) if type(tbl) ~= 'table' then return tbl end local rtn = {} for key,value in pairs(tbl) do rtn[key] = deepcopy(value) end return rtn end
            for key,value in pairs(Global) do rawset(Global,key,nil) end
            for key,value in pairs(rawget(rawget(tbl,'__defaults'),tostring(moduleName))) do rawset(Global,key,deepcopy(value)) end
        end
        -- the metatable is remade if not already present
        metatable = metatable or {
            __call=function(tbl,default) return Manager.global(default,tbl) end,
            __index=function(tbl,key) return rawget(Manager.global(nil,tbl),key) or moduleIndex[key] and Manager.global(key) end,
            __newindex=function(tbl,key,value) rawset(Manager.global(nil,tbl),key,value) end,
            __pairs=function(tbl)
                local tbl = Manager.global(nil,tbl)
                local function next_pair(tbl,k)
                    k, v = next(tbl, k)
                    if type(v) ~= nil then return k,v end
                end
                return next_pair, tbl, nil
            end,
            _module_path=module_path,_moduleName=moduleName
        }
        return setmetatable(Global,metatable)
    end,
    __index=function(tbl,key) return rawget(tbl(),key) or rawget(_G.global,key) or moduleIndex[key] and Manager.global(key) end,
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
    loaded_modules={}, -- this is over riden later
    module_verbose=false,
    module_exports=false,
    _no_error_verbose=true
},{
    __metatable=false,
    __index=ReadOnlyManager,
    __call=function(tbl,callback,env,...)
        if type(callback) == 'function' then 
            -- creates a new sandbox env
            local sandbox = tbl()
            local env = type(env) == 'table' and env or {}
            local _G_mt = getmetatable(_G)
            -- creates a new ENV where it will look in the provided env then the sand box and then _G, new indexes saved to sandbox
            local tmp_env = setmetatable({},{__index=function(tbl,key) return env[key] or sandbox[key] or rawget(_G,key) end,newindex=sandbox})
            tmp_env._ENV = tmp_env
            tmp_env._G_mt = _G_mt
            -- sets the upvalues for the function
            local i = 1
            while true do
                local name, value = debug.getupvalue(callback,i)
                if not name then break else if not value and tmp_env[name] then debug.setupvalue(callback,i,tmp_env[name]) end end
                i=i+1
            end
            -- runs the callback
            setmetatable(_G,{__index=tmp_env,newindex=sandbox})
            local rtn = {pcall(callback,...)}
            local success = table.remove(rtn,1)
            setmetatable(_G,_G_mt)
            -- this is to allow modules to be access with out the need of using Mangaer[name] also keeps global clean
            if success then return success, rtn, sandbox
            else return success, rtn[1], sandbox end
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
    __index=function(tbl,key) return tbl(key,nil,true) end,
    __call=function(tbl,path,env,mute,noLoad) 
        local raw_require = rawget(tbl,'__require')
        local env = env or {}
        -- runs in a sand box becuase sandbox everything
        local success, data = Manager.sandbox(raw_require,env,path)
        -- if there was no error then it assumed the path existed and returns the data
        if success then return unpack(data)
        else
            if type(path) ~= 'string' then error('Path supplied must be a string; got: '..type(path),2) return end
            local override = {}
            local softmod = override
            local path = path:find('@') and path:sub(1,path:find('@')-1) or path
            -- tries to load the module from the modeul index
            if moduleIndex[path] and not noLoad or Manager.loadModules.__load[path] then softmod = Manager.loadModules[path] end
            -- will then look for any submodules if there are any; only once every module is loaded
            for moduleName,subpath in pairs(moduleIndex) do
                if moduleName:find(path) == 1 and moduleName ~= path then 
                    local start, _end = moduleName:find(path)
                    local subname = moduleName:sub(_end+2)
                    -- does not add the module if it is a subsubmodule; or the key already exitsts
                    if not softmod then softmod = {} end
                    if not subname:find('.',nil,true) and not softmod[subname] then softmod[subname] = Manager.require(moduleName,nil,true,true) end
                end
            end
            -- if there is any keys in the softmod it is returned else the errors with the require error
            if override ~= softmod then return softmod end
            if mute then return false else error(data,2) end
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
Manager.loadModules = setmetatable({
    __load=setmetatable({},{__call=function(self,moduleName)
        -- check to provent multiple calls
        if self[moduleName] then return end
        self[moduleName] = true
        self = Manager.loadModules
        -- loads the module and its dependices if there are not loaded
        local load = moduleIndex[moduleName]
        if not load then return end
        local path = table.remove(load,1)
        Manager.verbose('Loading module: "'..moduleName..'"; path: '..path)
        -- loads the parent module
        if moduleName:find('.',nil,true) then
            local revModuleName = moduleName:reverse()
            local start, _end = revModuleName:find('.',nil,true)
            local parentName = revModuleName:sub(_end+1):reverse()
            Manager.verbose('Loading module parent: "'..parentName..'" for: "'..moduleName..'"; path: '..path)
            self.__load(parentName)
        end
        -- loads the dependices
        Manager.verbose('Loading module dependices for: "'..moduleName..'"; path: '..path)
        for _,depName in pairs(load) do self.__load(depName) end
        self.__load[moduleName] = path
        -- runs the module in a sandbox env
        local success, module, sandbox = Manager.sandbox(Manager.require.__require,{moduleName=setupModuleName(moduleName),module_path=path},path..'/control')
        -- extracts the module into a global index table for later use
        if success then
            -- verbose to notifie of any globals that were attempted to be created
            local globals = ''
            for key,value in pairs(sandbox) do globals = globals..key..', ' end
            if globals ~= '' then Manager.verbose('Globals caught in "'..moduleName..'": '..globals:sub(1,-3),'errorCaught') end
            Manager.verbose('Successfully loaded: "'..moduleName..'"; path: '..path)
            -- if it is not a table or nil then it will set up a metatable on it
            local currentType = type(rawget(self,moduleName))
            if currentType ~= 'nil' and currentType ~= 'table' then
                -- if it is a function then it is still able to be called even if more keys are going to be added
                -- if it is a string then it will act like one; if it is a number well thats too many metatable indexs
                self[moduleName] = setmetatable({__old=self[moduleName]},{
                    __call=function(self,...) if type(self.__old) == 'function' then self.__old(...) else return self.__old end end,
                    __tostring=function(self) return self.__old end,
                    __concat=function(self,val) return self.__old..val end
                })
            end
            -- if you prefere module_exports can be used rather than returning the module
            local appendAs = sandbox.module_exports or table.remove(module,1)
            if not self[moduleName] then self[moduleName] = appendAs -- if nil it just sets the value
            else for key,value in pairs(appendAs) do self[moduleName][key] = value end end -- else it appends the new values
            -- if there is a module by this name in _G ex table then it will be indexed to the new module
            if rawget(_G,moduleName) and type(rawget(self,moduleName)) == 'table' then setmetatable(rawget(_G,moduleName),{__index=self[moduleName]}) end
            if type(rawget(self,moduleName)) == 'table' then self[moduleName]._module_path = path self[moduleName]._moduleName = moduleName end
            -- loads the submodule for this softmod
            Manager.verbose('Loading submodules for: "'..moduleName..'"; path: '..path)
            for subModName,_ in pairs(moduleIndex) do
                if subModName:find(moduleName) == 1 and subModName ~= moduleName then self.__load(subModName) end
            end
        else
            Manager.verbose('Failed load: "'..moduleName..'"; path: '..path..' ('..module..')','errorCaught')
            for event_name,callbacks in pairs(Manager.event) do Manager.verbose('Removed Event Handler: "'..moduleName..'/'..Manager.event.names[event_name],'eventRegistered') callbacks[moduleName] = nil end
        end
    end}),
    __init=setmetatable({},{__call=function(self,moduleName)
        -- check to provent multiple calls
        if self[moduleName] or not Manager.loadModules.__load[moduleName] then return end
        self[moduleName] = true
        self = Manager.loadModules
        -- calls on_init for each module
        -- looks for init so that init or on_init can be used
        local data = self[moduleName]
        if type(data) == 'table' and data.init and data.on_init == nil then data.on_init = data.init data.init = nil end
        if type(data) == 'table' and data.on_init and type(data.on_init) == 'function' then
            Manager.verbose('Initiating module: "'..moduleName..'"')
            local success, err = Manager.sandbox(data.on_init,{moduleName=setupModuleName(moduleName),module_path=Manager.loadModules.__load[tostring(moduleName)]},data)
            if success then
                Manager.verbose('Successfully Initiated: "'..moduleName..'"')
            else
                Manager.verbose('Failed Initiation: "'..moduleName..'" ('..err..')','errorCaught')
            end
            -- clears the init function so it cant be used in runtime
            data.on_init = nil
        end
    end}),
    __post=setmetatable({},{__call=function(self,moduleName)
        -- check to provent multiple calls
        if self[moduleName] or not Manager.loadModules.__init[moduleName] then return end
        self[moduleName] = true
        self = Manager.loadModules
        -- calls on_post for each module
        -- looks for post so that post or on_post can be used
        local data = self[moduleName]
        if type(data) == 'table' and data.post and data.on_post == nil then data.on_post = data.post data.post = nil end
        if type(data) == 'table' and data.on_post and type(data.on_post) == 'function' then
            Manager.verbose('Post for module: "'..moduleName..'"')
            local success, err = Manager.sandbox(data.on_post,{moduleName=setupModuleName(moduleName),module_path=Manager.loadModules.__load[tostring(moduleName)]},data)
            if success then
                Manager.verbose('Successful post: "'..moduleName..'"')
            else
                Manager.verbose('Failed post: "'..moduleName..'" ('..err..')','errorCaught')
            end
            -- clears the post function so it cant be used in runtime
            data.on_post = nil
        end
    end})
    },
    {
        __metatable=false,
        __index=function(self,moduleName)
            -- will load one module if it is not already loaded, will not init during load state or post
            self.__load(moduleName)
            if (ReadOnlyManager.currentState == 'moduleLoad') then return end
            self.__init(moduleName)
            if (ReadOnlyManager.currentState == 'moduleInit') then return end
            self.__post(moduleName)
            return rawget(self,moduleName)
        end,
        __call=function(self)
            -- goes though the index looking for modules to load
            ReadOnlyManager.currentState = 'moduleLoad'
            for moduleName,path in pairs(moduleIndex) do self.__load(moduleName) end
            -- runs though all loaded modules looking for on_init function; all other modules have been loaded use this to load extra code based on opttial dependies
            ReadOnlyManager.currentState = 'moduleInit'
            for moduleName,path in pairs(self) do 
                if moduleName ~= '__load' and moduleName ~= '__init' and moduleName ~= '__post' then self.__init(moduleName) end
            end
            -- runs though all loaded modules looking for on_post function; all other modules have been loaded and inited, do not load extra code in this time only altar your own data
            ReadOnlyManager.currentState = 'modulePost'
            for moduleName,path in pairs(self) do 
                if moduleName ~= '__load' and moduleName ~= '__init' and moduleName ~= '__post' then self.__post(moduleName) end
            end
            ReadOnlyManager.currentState = 'moduleEnv'
        end,
        __len=function(tbl)
            -- counts the number of loaded modules
            local rtn = 0
            for key,value in pairs(tbl) do
                rtn = rtn + 1
            end
            return rtn-3
        end,
        __tostring=function(tbl)
            -- a concat of all the loaded modules
            local rtn = 'Load Modules: '
            for key,value in pairs(tbl) do
                if key ~= '__load' and key ~= '__init' and key ~= '__post' then rtn=rtn..key..', ' end
            end
            return rtn:sub(1,-3)
        end
    }
)
Manager.sandbox.loaded_modules = Manager.loadModules

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
    end,
    in_pcall=function(level)
        local level = level and level+1 or 2
        while true do
            if not debug.getinfo(level) then return false end
            if debug.getinfo(level).name == 'pcall' then return level end
            level=level+1
        end
    end
},{
    __metatalbe=false,
    __call=function(tbl,err,...)
        -- if no params then return the error constant
        if err == nil then return rawget(tbl,'__error_const') end
        -- if the error constant is given crash game
        if err == rawget(tbl,'__error_const') then Manager.verbose('Force Crash','errorCaught') rawset(tbl,'__crash',true) rawget(tbl,'__error_call')('Force Crash',2) end
        -- other wise treat the call as if its been passed an err string
        if not _no_error_verbose or Manager.currentState ~= 'moduleEnv' then Manager.verbose('An error has occurred: '..err,'errorCaught') end
        if #tbl > 0 then
            -- there is at least one error handler loaded; loops over the error handlers
            for handler_name,callback in pairs(tbl) do
                local success, err = pcall(callback,err,...)
                if not success then Manager.verbose('Error handler: "'..handler_name..'" failed to run ('..err..')','errorCaught') end
                -- if the error constant is returned from the handler then crash the game
                if err == rawget(tbl,'__error_const') then Manager.verbose('Force Stop by: '..handler_name,'errorCaught') rawset(tbl,'__crash',true) rawget(tbl,'__error_call')('Force Stop by: '..handler_name) end
            end
        elseif game then
            -- there are no handlers loaded so it will print to the game if loaded
            Manager.verbose('No error handlers loaded; Default game print used','errorCaught')
            game.print(err)
        else
            -- all else fails it will crash the game with the error code
            Manager.verbose('No error handlers loaded; Game not loaded; Forced crash: '..err,'errorCaught')
            rawset(tbl,'__crash',true)
            rawget(tbl,'__error_call')(err,2)
        end
        local args = {...}
        local trace = args[1] and type(args[1]) == 'number' and args[1]+1 or 2
        if tbl.in_pcall(2) then rawget(tbl,'__error_call')(err,trace) end
    end,
    __index=function(tbl,key)
        -- this allows the __error_handler to be called from many different names
        if type(key) ~= 'string' then return end
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
            if k == '__error_call' or k == '__error_const' or k == '__error_handler' or k == '__crash' or k == 'in_pcall' then return next_pair(tbl,k) end
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
    events=defines.events,
    error_cache={}
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
        local event_functions = tbl.__events[event_name]
        if type(event_functions) == 'table' then
            for moduleName,callback in pairs(event_functions) do
                -- loops over the call backs and which module it is from
                if type(callback) ~= 'function' then error('Invalid Event Callback: "'..event_name..'/'..moduleName..'"') end
                local success, err = Manager.sandbox(callback,{moduleName=setupModuleName(moduleName),module_path=Manager.loadModules.__load[tostring(moduleName)]},new_callback,...)
                if not success then 
                    local cache = tbl.error_cache
                    local error_message = 'Event Failed: "'..moduleName..'/'..tbl.names[event_name]..'" ('..err..')'
                    if not cache[error_message] then Manager.verbose(error_message,'errorCaught') error(error_message) end
                    if tbl.names[event_name] == 'on_tick' then 
                        if not cache[error_message] then cache[error_message] = {game.tick,1} end
                        if cache[error_message][1] >= game.tick-10 then cache[error_message] = {game.tick,cache[error_message][2]+1}
                        else cache[error_message] = nil end
                        if cache[error_message] and cache[error_message][2] > 100 then
                            Manager.verbose('There was an error happening every tick for 100 ticks, the event handler has been removed!','errorCaught')
                            event_functions[moduleName] = nil
                        end
                    end
                end
                -- if stop constant is returned then stop further processing
                if err == rawget(tbl,'__stop') then Manager.verbose('Event Haulted By: "'..moduleName..'"','errorCaught') break end
            end
        end
    end,
    __newindex=function(tbl,key,value)
        -- handles the creation of new event handlers
        if type(value) ~= 'function' and type(value) ~= nil then error('Attempted to set a non function value to an event',2) end
        -- checks for a global module name that is present
        local moduleName = moduleName or 'FSM'
        -- converts the key to a number index for the event
        Manager.verbose('Added Handler: "'..tbl.names[key]..'"','eventRegistered')
        -- checks that the event has a valid table to store callbacks; if its not valid it will creat it and register a real event handler
        if not rawget(rawget(tbl,'__events'),key) then
            if key == -1 or key == -2 then -- this already has a handler
            elseif key < 0  then rawget(tbl,tbl.names[key])(function(...) tbl(key,...) end) 
            else rawget(tbl,'__event')(key,function(...) tbl(key,...) end) end
            rawset(rawget(tbl,'__events'),key,{}) end
        -- adds callback to Manager.event.__events[event_id][moduleName]
        rawset(rawget(rawget(tbl,'__events'),key),tostring(moduleName),value)
    end,
    __index=function(tbl,key)
        -- few redirect key
        local redirect={register=tbl,dispatch=tbl,remove=function(event_id) tbl[event_name]=nil end}
        if rawget(redirect,key) then return rawget(redirect,key) end
        -- proforms different look ups depentding weather the current module has an event handler registered
        if moduleName then
            -- first looks for the event callback table and then under the module name; does same but converts the key to a number; no handler regisered so returns the converted event id
            return rawget(rawget(tbl,'__events'),key) and rawget(rawget(rawget(tbl,'__events'),key),tostring(moduleName))
            or rawget(rawget(tbl,'__events'),rawget(tbl,'names')[key]) and rawget(rawget(rawget(tbl,'__events'),rawget(tbl,'names')[key]),tostring(moduleName)) 
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
            -- if it is a number then it will first look in the cache
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
            -- returns the value from the cache after being loaded in
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
    Manager.verbose('____________________| SubStart: script.on_init |____________________')
    setmetatable(global,Manager.global.__global)
    local names = {}
    for name,default in pairs(Manager.global.__defaults) do table.insert(names,name) end
    Manager.verbose('Global Tables: '..table.concat(names,', '))
    for name,default in pairs(Manager.global.__defaults) do global(name)(true) end
    Manager.event(-1,...) 
    Manager.verbose('____________________| SubStop: script.on_init |____________________')
end)

script.on_load(function(...)
    Manager.verbose('____________________| SubStart: script.on_load |____________________')
    setmetatable(global,Manager.global.__global)
    local names = {}
    for name,default in pairs(Manager.global.__defaults) do table.insert(names,name) end
    Manager.verbose('Global Tables: '..table.concat(names,', '))
    --for name,default in pairs(Manager.global.__defaults) do Manager.verbose('Global '..name..' = '..serpent.line(Manager.global(name))) end
    Manager.event(-2,...)
    Manager.verbose('____________________| SubStop: script.on_load |____________________')
end)
--over rides for the base values; can be called though Event
Event=setmetatable({},{__call=Manager.event,__index=function(tbl,key) return Manager.event[key] or script[key] or error('Invalid Index To Table Event') end})
script.mod_name = setmetatable({},{__index=_G.moduleName})
script.on_event=Manager.event
script.raise_event=Manager.event
script.on_init=function(callback) Manager.event(-1,callback) end
script.on_load=function(callback) Manager.event(-2,callback) end
script.on_configuration_changed=function(callback) Manager.event(-3,callback) end
script.get_event_handler=function(event_name) return type(Manager.event[event_name]) == 'function' and Manager.event[event_name] or nil end
script.generate_event_name=function(event_name) local event_id = Manager.event.__generate() local event_name = event_name or event_id Manager.event.events[event_name]=event_id return event_id end
-- to do set up nth tick

return ReadOnlyManager