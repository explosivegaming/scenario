--- Adds some commonly used functions used in many modules
-- @author cooldude2606
-- @module Public
--[[
>>>>Functions List (see function for more detail):
    Public.type_check(value,test_type) --- Compare types faster for faster validation of prams
    Public.type_check_error(value,test_type,error_message,level) --- Raises an error if the value is of the incorrect type
    Public.param_check(value,test_type,param_name,param_number) --- Raises an error when the value is the incorrect type, uses a consistent error message format

    Public.extract_keys(tbl,...) --- Extracts certain keys from a table

    Public.player_return(value,colour,player) --- Will return a value of any type to the player/server console, allows colour for in-game players

    Public.opt_require(path) --- Calls a require that will not error if the file is not found
    Public.ext_require(path,...) --- Calls a require and returns only the keys given, file must return a table
]]

local Colours = require 'resources.color_presets'
local Game = require 'utils.game'

local Public = {}

--- Compare types faster for faster validation of params
-- @usage type_check('foo','string') -- return true
-- @usage type_check('foo') -- return false
-- @param v the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if not given then it tests for nil
-- @treturn boolean is v of type test_type
function Public.type_check(value,test_type)
    return test_type and value and type(value) == test_type or not test_type and not value or false
end

--- Raises an error if the value is of the wrong type
-- @usage type_check_error('foo','number','Value must be a number') -- will raise error "Value must be a number"
-- @tparam value any the value that you want to test the type of
-- @tparam test_type string the type that the value should be
-- @tparam error_message string the error message that is returned
-- @tparam level number the level to call the error on (level = 1 means the caller)
-- @treturn boolean true if no error was called
function Public.type_check_error(value,test_type,error_message,level)
    level = level and level+1 or 2
    return Public.test_type(value,test_type) or error(error_message,level)
end

--- Raises an error when the value is the incorrect type, uses a consistent error message format
-- @usage param_check('foo','number','repeat_count',2) -- will raise error "Invalid param #02 given to <anon>; repeat_count is not of type number"
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
-- @usage local key_three, key_one = extract({key_one='foo',key_two='bar',key_three=true},'key_three','key_one')
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
-- @usage local file = opt_require('file.not.present') -- will not cause any error
-- @tparam path string the path that you want to require
-- @return the returns from that file or nil, error if not loaded
function Public.opt_require(path)
    local success, rtn = pcall(require,path)
    if success then return rtn
    else return nil,rtn end
end

--- Calls a require and returns only the keys given, file must return a table
-- @useage local extract, param_check = ext_require('expcore.common','extract','param_check')
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

--- Formats ticks into a time format - this is alot of work and will do later
-- time denominations: D,H,M,S,T days,hours,minutes,seconds,ticks
-- time prefixes (minutes as example): %m,%m,%M,%MM just the value, value with short tag, value with long tag
-- adding a number after the prefix AND denomination will show that many decimal palaces
-- examples: '%H %M' => '0H 0M'; '%MM and %SS3' => '0 Minutes and 0.000 Seconds'
function Public.format_time(ticks,format)
    local has_days, has_hours, has_minutes, has_seconds, has_ticks = false,false,false,false,false
    local max_days, max_hours = ticks/5184000, ticks/216000
    local max_minutes, max_seconds, max_ticks = ticks/3600, ticks/60, ticks
    local days, hours = max_days, max_hours-math.floor(max_days)*5184000
    local minutes, seconds = max_minutes-math.floor(max_hours)*216000, max_seconds-math.floor(max_minutes)*3600
    local tags = {}
    return 'Use format_time_simple currently WIP'
end

--- Formats tick into a time format, this format is predefined to either H:M:S; HH MM SS or H Hours M Minutes S seconds
-- seconds are not required to be shown with option show_seconds = false, true to show them, default false
-- show_sub_seconds will show three decimal places for the seconds
-- long_format will use words rather than letters
-- tagged is default to true when false it will remove all letters and use :
-- @tparam ticks number the number of ticks that represents a time
-- @tparam options table a table of options to use for the format
function Public.format_time_simple(ticks,options)
    -- Sets up the options
    options = {
        show_seconds = options.show_seconds or false,
        show_sub_seconds = options.show_sub_seconds or false,
        long_format = options.long_format or false,
        tagged = options.tagged or true
    }
    -- Basic numbers that are used in calculations
    local max_hours, max_minutes, max_seconds = ticks/216000, ticks/3600, ticks/60
    local hours, minutes, seconds = max_hours, max_minutes-math.floor(max_hours)*216000, max_seconds-math.floor(max_minutes)*3600
    -- Format options
    local suffix = 'time-format.short-'
    if options.long_format then
        suffix = 'time-format.long-'
    end
    local div = 'time-format.simple-format-tagged'
    if options.tagged then
        div = 'time-format.simple-format-div'
        suffix = false
    end
    -- The returned numbers in the right format
    local rtn_hours, rtn_minutes, rtn_seconds = math.floor(hours), math.floor(minutes), math.floor(seconds)
    if suffix then
        rtn_hours = {suffix..'hours',rtn_hours}
        rtn_minutes = {suffix..'minutes',rtn_minutes}
        if options.show_sub_seconds then
            rtn_seconds = {suffix..'seconds',string.format('%d03',seconds)}
        else
            rtn_seconds = {suffix..'seconds',rtn_seconds}
        end
    end
    -- The final return is construed
    local rtn = {div,rtn_hours,rtn_minutes}
    if options.show_seconds then
        rtn = {div,rtn,rtn_seconds}
    end
    return rtn
end

return Public