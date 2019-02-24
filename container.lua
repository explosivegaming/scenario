local Container = {
    files={}, -- file paths which get loaded
    -- these will become globals that are used to keep softmod modules working together
    handlers={
        --event
        --global
        --error=error
        --logging=log
        --debug
        --tableToString=serpent.line
    },
    _raw={}, -- any values that are replaced by handlers are moved here
    _loaded={},
    defines={
        errorLoad='ERRLOAD', -- error when loading a file
        errorNotFound='ERRNOTFOUND', -- error when file not found
        logAlways=0, -- will always be logged
        logBasic=1, -- should be logged but not required
        logDebug=2, -- longer logs of debugging
        logEvents=3, -- logs which take place very often such as frequent event triggers if no other filters
        logVerbose=4, -- basically a log of any thing useful
        logAll=5 -- what ever is left to log weather you see a current need or not
    },
    -- to prevent desyncs during on_load any change to the following must be updated
    -- example: runtime change to logLevel must be applied during on_load to avoid desyncs
    safeError=true, -- when true then errors are logged not raised
    debug=false, -- if debug functions are triggered see Container.inDebug
    logLevel=1 -- what level of details is given by logs
}

function Container.log(level,...)
    if level <= Container.logLevel then Container.stdout(...) end
end
function Container.stdout(...)
    local msg = ''
    for _,value in pairs({...}) do
        msg = msg..' '..Container.tostring(value)
    end
    if Container.handlers.logging then
        Container.handlers.logging(msg)
    else
        log(msg)
    end
end

function Container.error(...)
    if Container.safeError then Container.stdout('ERROR',...) else Container.stderr(...) end
end
function Container.stderr(type,...)
    local msg = 'ERROR: '..tostring(type)
    for _,value in pairs({...}) do
        msg = msg..' '..Container.tostring(value)
    end
    if Container.handlers.error then
        Container.handlers.error(msg)
    else
        error(msg)
    end
end

function Container.type(value,test)
    if not test then return type(value) end
    return value and type(value) == test
end

function Container.isLocaleString(locale)
    if Container.type(locale,'table') then
        local _string = locale[1]
        -- '.+[.].+' this is a check for the key value pair
        -- '%s' this is a check for any white space
        return Container.type(_string,'string') and _string:find('.+[.].+') and not _string:find('%s')
    end
    return false
end

function Container.isUserdata(userdata)
    if Container.type(userdata,'table') then
        return Container.type(userdata.__self,'userdata')
    end
    return false
end

function Container.tostring(value)
    local _type = type(value)
    if _type == 'table' then
        if Container.isUserdata(value) then
            -- the value is userdata
            return '<USERDATA>'
        elseif getmetatable(rtn) ~= nil and not tostring(rtn):find('table: 0x') then
            -- the value is a table but contains the metamethod __tostring
            return tostring(value)
        else
            -- the value is a table
            if Container.handlers.tableToString then
                return Container.handlers.tableToString(value)
            else
                return serpent.line(value)
            end
        end
    elseif Container.type(value,'function') then
        -- the value is a function and the function name is given
        local name = debug.getinfo(value,'n').name or 'ANON'
        return '<FUNCTION:'..name..'>'
    else
        -- all other values: number, string and boolean tostring is save to use
        return tostring(value)
    end
end

--- Sandboxs a function into the container and the given env, will load upvalues if provied in the given env
-- @usage container:sandbox(print,{},'hello from the sandbox')
-- @tparam callback function the function that will be run in the sandbox
-- @tparam env table the env which the function will run in, place upvalues in this table
-- @param[opt] any args you want to pass to the function
-- @treturn boolean did the function run without error
-- @treturn string|table returns error message or the returns from the function
-- @treturn table returns back the env as new values may have been saved
function Container.sandbox(callback,env,...)
    -- creates a sandbox env which will later be loaded onto _G
    local sandbox_env = setmetatable(env,{
        __index=function(tbl,key)
                return rawget(_G,key)
        end
    })
    sandbox_env._ENV = sandbox_env
    sandbox_env._MT_G = getmetatable(_G)
    -- sets any upvalues on the callback
    local i = 1
    while true do
        local name, value = debug.getupvalue(callback,i)
        if not name then break end
        if not value and sandbox_env[name] then
            debug.setupvalue(callback,i,sandbox_env[name])
        end
        i=i+1
    end
    -- adds the sandbox to _G
    setmetatable(_G,{__index=sandbox_env,__newindex=sandbox_env})
    local rtn = {pcall(callback,...)}
    local success = table.remove(rtn,1)
    setmetatable(_G,_MT_G)
    -- returns values from the callback, if error then it returns the error
    if success then return success, rtn, sandbox_env
    else return success, rtn[1], sandbox_env end
end

function Container.loadFile(filePath)
    if Container._loaded[filePath] then return Container._loaded[filePath] end
    local success,file = pcall(require,filePath)
    if not success then return Container.error(Container.defines.errorLoad,filePath,file) end
    -- if the file was not found then it returns an error from require which does not trip pcall, tested for here
    if Container.type(file,'string') and file:find('no such file') then
        -- tries with modules. appended to the front of the path and .control on the end
        local success,_file = pcall(require,'modules.'..filePath..'.control')
        if not success then return Container.error(Container.defines.errorLoad,filePath,_file) end
        -- again tests for the error not caught by pcall
        if Container.type(_file,'string') and _file:find('no such file') then return Container.error(Container.defines.errorNotFound,filePath) end
        Container.log(Container.defines.logDebug,'Loaded file:',filePath)
        Container._loaded[filePath] = _file
        return _file
    end
    Container.log(Container.defines.logDebug,'Loaded file:',filePath)
    Container._loaded[filePath] = file
    return file
end

function Container.loadHandlers()
    Container.log(Container.defines.logAlways,'Loading Container Handlers')
    for key,value in pairs(Container.handlers) do
        if Container.type(value,'string') then
            -- if it is a string then it is treated as a file path
            Container.handlers[key] = Container.loadFile(value)
        end
        if _G[key] then
            -- if the key exists then it is moved to _raw before being over ridden
            Container._raw[key] = _G[key]
            -- it is also moved to _R for global access
            if not _R then _R = {} end
            _R[key] = _G[key]
        end
        rawset(_G,key,Container.handlers[key])
    end
end

function Container.loadFiles()
    Container.log(Container.defines.logAlways,'Loading Container Files')
    for _,filePath in pairs(Container.files) do
        Container.loadFile(filePath)
    end
end

function Container.initFiles()
    Container.log(Container.defines.logAlways,'Initiating Container Files')
    for filePath,file in pairs(Container._loaded) do
        if file.on_init then
            file.on_init()
            Container.log(Container.defines.logDebug,'Initiated file:',filePath)
        end
    end
end

function Container.postFiles()
    Container.log(Container.defines.logAlways,'POSTing Container Files')
    for filePath,file in pairs(Container._loaded) do
        if file.on_post then
            file.on_post()
            Container.log(Container.defines.logDebug,'POSTed file:',filePath)
        end
    end
end

return Container