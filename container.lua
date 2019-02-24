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
    defines={
        errorLoad='ERRLOAD', -- error when loading a file
        errorNotFound='ERRNOTFOUND', -- error when file not found
        logAlways=0, -- will always be logged
        logBasic=1, -- should be logged but not required
        logDebug=2, -- longer logs of debugging
        logEvents=3, -- logs which take place very often such as frequent event triggers if no other filters
        logVerbose=4, -- basically a log of any thing useful
        logMax=5 -- what ever is left to log weather you see a current need or not
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
    local msg = 'ERROR: '..type
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

function Container.loadFile(filePath)
    local success,file = pcall(require,filePath)
    if not success then return Container.error(Container.defines.errorLoad,file) end
    if not file then return Container.error(Container.defines.errorNotFound) end
    Container.log(Container.defines.logDebug,'Loaded file:',filePath)
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

return Container