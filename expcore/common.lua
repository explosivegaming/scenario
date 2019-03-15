local Colours = require 'resources.color_presets'
local Game = require 'utils.game'

local Public = {}

--- Compare types faster for faster validation of prams
-- @usage is_type('foo','string') -- return true
-- @usage is_type('foo') -- return false
-- @param v the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if not given then it tests for nil
-- @treturn boolean is v of type test_type
function Public.type_check(value,test_type)
    return test_type and value and type(value) == test_type or not test_type and not value or false
end

--- Raises an error if invalid type is given
-- @tparam value any the value that you want to test the type of
-- @tparam test_type string the type that the value should be
-- @tparam error_message string the error message that is returned
-- @tparam level number the level to call the error on (level = 1 means the caller)
-- @treturn boolean true if no error was called
function Public.type_check_error(value,test_type,error_message,level)
    level = level and level+1 or 2
    return Public.test_type(value,test_type) or error(error_message,level)
end

--- Raises an error with type error with a consistent error message
-- @tparam value any the value that you want to test the type of
-- @tparam test_type string the type that the value should be
-- @tparam param_name string the name of the param
-- @tparam param_number number the number param it is
-- @treturn boolean true if no error was raised
function Public.param_check(value,test_type,param_name,param_number)
    if not Public.test_type(value,test_type) then
        local function_name = debug.getinfo(2,'n').name or '<anon>'
        local error_message = string.format('Invalid param #%2d given to %s; %s is not of type %s',param_number,function_name,param_name,test_type)
        return error(error_message,3)
    end
    return true
end

--- Extracts certain keys from a table
-- @tparam tbl table the table which contains the keys
-- @tparam ... string the names of the keys you want extracted
-- @return the keys in the order given
function Public.extract_keys(tbl,...)
    local values = {}
    for _,key in pairs({...}) do
        table.insert(values,tbl[key])
    end
    return unpack(values)
end

--- Will return a value of any type to the player/server console, allows colour for in-game players
-- @usage player_return('Hello, World!') -- returns 'Hello, World!' to game.player or server console
-- @usage player_return('Hello, World!','green') -- returns 'Hello, World!' to game.player with colour green or server console
-- @usage player_return('Hello, World!',nil,player) -- returns 'Hello, World!' to the given player
-- @param value any value of any type that will be returned to the player or console
-- @tparam[opt=defines.colour.white] ?defines.color|string colour the colour of the text for the player, ignored when printing to console
-- @tparam[opt=game.player] LuaPlayer player  the player that return will go to, if no game.player then returns to server
function Public.player_return(value,colour,player)
    colour = Public.type_check(colour,'table') and colour or Colours[colour] ~= Colours.white and Colours[colour] or Colours.white
    player = player or game.player
    -- converts the value to a string
    local returnAsString
    if Public.type_check(value,'table') then
        if Public.type_check(value.__self,'userdata') then
            -- value is userdata
            returnAsString = 'Cant Display Userdata'
        elseif Public.type_check(value[1],'string') and string.find(value[1],'.+[.].+') and not string.find(value[1],'%s') then
            -- value is a locale string
            returnAsString = value
        elseif getmetatable(value) ~= nil and not tostring(value):find('table: 0x') then
            -- value has a tostring meta method
            returnAsString = tostring(value)
        else
            -- value is a table
            returnAsString = serpent.block(value)
        end
    elseif Public.type_check(value,'function') then
        -- value is a function
        returnAsString = 'Cant Display Functions'
    else returnAsString = tostring(value) end
    -- returns to the player or the server
    if player then
        -- allows any valid player identifier to be used
        player = Game.get_player_from_any(player)
        if not player then error('Invalid Player given to player_return',2) end
        -- plays a nice sound that is different to normal message sound
        player.play_sound{path='utility/scenario_message'}
        player.print(returnAsString,colour)
    else rcon.print(returnAsString) end
end

--- Calls a require that will not error if the file is not found
-- @tparam path string the path that you want to require
-- @return the returns from that file or nil, error if not loaded
function Public.opt_require(path)
    local success, rtn = pcall(require,path)
    if success then return rtn
    else return nil,rtn end
end

--- Calls a require and returns only the keys given, file must return a table
-- @tparam path string the path that you want to require
-- @tparam ... string the name of the keys that you want returned
-- @return the keys in the order given
function Public.ext_require(path,...)
    local rtn = require(path)
    if type(rtn) ~= 'table' then
        error('File did not return a table, can not extract keys.',2)
    end
    return Public.extract_keys(rtn,...)
end

return Public