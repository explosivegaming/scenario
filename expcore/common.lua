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
local Util = require 'util'

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

--- Formats tick into a clean format, denominations from highest to lowest
-- long will use words rather than letters
-- time will use : separates
-- string will return a string not a locale string
-- when a denomination is false it will overflow into the next one
-- @tparam ticks number the number of ticks that represents a time
-- @tparam options table a table of options to use for the format
-- @treturn string a locale string that can be used
function Public.format_time(ticks,options)
    -- Sets up the options
    options = options or {
        days=false,
        hours=true,
        minutes=true,
        seconds=false,
        long=false,
        time=false,
        string=false
    }
    -- Basic numbers that are used in calculations
    local max_days, max_hours, max_minutes, max_seconds = ticks/5184000, ticks/216000, ticks/3600, ticks/60
    local days, hours = max_days, max_hours-math.floor(max_days)*24
    local minutes, seconds = max_minutes-math.floor(max_hours)*60, max_seconds-math.floor(max_minutes)*60
    -- Handles overflow of disabled denominations
    local rtn_days, rtn_hours, rtn_minutes, rtn_seconds = math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds)
    if not options.days then
        rtn_hours = rtn_hours + rtn_days*24
    end
    if not options.hours then
        rtn_minutes = rtn_minutes + rtn_hours*60
    end
    if not options.minutes then
        rtn_seconds = rtn_seconds + rtn_minutes*60
    end
    -- Format options
    local suffix = 'time-symbol-'
    local suffix_2 = '-short'
    if options.long then
        suffix = ''
        suffix_2 = ''
    end
    local div = options.string and ' ' or 'time-format.simple-format-tagged'
    if options.time then
        div = options.string and ':' or 'time-format.simple-format-div'
        suffix = false
    end
    -- Adds formatting
    if suffix ~= false then
        if options.string then
            -- format it as a string
            local long = suffix == ''
            rtn_days = long and rtn_days..' days' or rtn_days..'d'
            rtn_hours = long and rtn_hours..' hours' or rtn_hours..'h'
            rtn_minutes = long and rtn_minutes..' minutes' or rtn_minutes..'m'
            rtn_seconds = long and rtn_seconds..' seconds' or rtn_seconds..'s'
        else
            rtn_days = {suffix..'days'..suffix_2,rtn_days}
            rtn_hours = {suffix..'hours'..suffix_2,rtn_hours}
            rtn_minutes = {suffix..'minutes'..suffix_2,rtn_minutes}
            rtn_seconds = {suffix..'seconds'..suffix_2,rtn_seconds}
        end
    else
        -- weather string or not it has same format
        rtn_days = string.format('%02d',rtn_days)
        rtn_hours = string.format('%02d',rtn_hours)
        rtn_minutes = string.format('%02d',rtn_minutes)
        rtn_seconds = string.format('%02d',rtn_seconds)
    end
    -- The final return is construed
    local rtn
    local append = function(dom,value)
        if dom and options.string then
            rtn = rtn and rtn..div..value or value
        elseif dom then
            rtn = rtn and {div,rtn,value} or value
        end
    end
    append(options.day,rtn_days)
    append(options.hours,rtn_hours)
    append(options.minutes,rtn_minutes)
    append(options.seconds,rtn_seconds)
    return rtn
end

--- Moves items to the position and stores them in the closest entity of the type given
-- @tparam items table items which are to be added to the chests, ['name']=count
-- @tparam[opt=navies] surface LuaSurface the surface that the items will be moved to
-- @tparam[opt={0,0}] position table the position that the items will be moved to {x=100,y=100}
-- @tparam[opt=32] radius number the radius in which the items are allowed to be placed
function Public.move_items(items,surface,position,radius,chest_type)
    chest_type = chest_type or 'iron-chest'
    surface = surface or game.surfaces[1]
    if type(position) ~= 'table' then return end
    if type(items) ~= 'table' then return end
    -- Finds all entities of the given type
    local p = position or {x=0,y=0}
    local r = radius or 32
    local entities = surface.find_entities_filtered{area={{p.x-r,p.y-r},{p.x+r,p.y+r}},name=chest_type} or {}
    local count = #entities
    local current = 1
    -- Makes a new emtpy chest when it is needed
    local function make_new_chest()
        local pos = surface.find_non_colliding_position(chest_type,position,32,1)
        local chest = surface.create_entity{name=chest_type,position=pos,force='neutral'}
        table.insert(entities,chest)
        count = count + 1
        return chest
    end
    -- Function used to round robin the items into all chests
    local function next_chest(item)
        local chest = entities[current]
        if count == 0 then return make_new_chest() end
        if chest.get_inventory(defines.inventory.chest).can_insert(item) then
            -- If the item can be inserted then the chest is returned
            current = current+1
            if current > count then current = 1 end
            return chest
        else
            -- Other wise it is removed from the list
            table.remove(entities,current)
            count = count - 1
        end
    end
    -- Inserts the items into the chests
    local last_chest
    for item_name,item_count in pairs(items) do
        local chest = next_chest{name=item_name,count=item_count}
        if not chest then return error(string.format('Cant move item %s to %s{%s, %s} no valid chest in radius',item.name,surface.name,p.x,p.y)) end
        Util.insert_safe(chest,{[item_name]=item_count})
        last_chest = chest
    end
    return last_chest
end

--[[-- https://github.com/Refactorio/RedMew/blob/9184b2940f311d8c9c891e83429fc57ec7e0c4a2/map_gen/maps/diggy/debug.lua#L31
    Prints a colored value on a location.
    @param value between -1 and 1
    @param surface LuaSurface
    @param position Position {x, y}
    @param scale float
    @param offset float
    @param immutable bool if immutable, only set, never do a surface lookup, values never change
]]
function Public.print_grid_value(value, surface, position, scale, offset, immutable)
    local is_string = type(value) == 'string'
    local color = Colours.white
    local text = value

    if type(immutable) ~= 'boolean' then
        immutable = false
    end

    if not is_string then
        scale = scale or 1
        offset = offset or 0
        position = {x = position.x + offset, y = position.y + offset}
        local r = math.max(1, value) / scale
        local g = 1 - math.abs(value) / scale
        local b = math.min(1, value) / scale

        if (r > 0) then
            r = 0
        end

        if (b < 0) then
            b = 0
        end

        if (g < 0) then
            g = 0
        end

        r = math.abs(r)

        color = { r = r, g = g, b = b}

        -- round at precision of 2
        text = math.floor(100 * value) * 0.01

        if (0 == text) then
            text = '0.00'
        end
    end

    if not immutable then
        local text_entity = surface.find_entity('flying-text', position)

        if text_entity then
            text_entity.text = text
            text_entity.color = color
            return
        end
    end

    surface.create_entity{
        name = 'flying-text',
        color = color,
        text = text,
        position = position
    }.active = false
end

--[[--
    Prints a colored value on a location. When given a color_value and a delta_color,
    will change the color of the text from the base to base + value * delta. This will
    make the color of the text range from 'base_color' to 'base_color + delta_color'
    as the color_value ranges from 0 to 1
    @param value of number to be displayed
    @param surface LuaSurface
    @param position Position {x, y}
    @param offset float position offset
    @param immutable bool if immutable, only set, never do a surface lookup, values never change
    @param color_value float How far along the range of values of colors the value is to be displayed
    @param base_color {r,g,b} The color for the text to be if color_value is 0
    @param delta_color {r,g,b} The amount to correct the base_color if color_value is 1
    @param under_bound {r,g,b} The color to be used if color_value < 0
    @param over_bound {r,g,b} The color to be used if color_value > 1
]]
function Public.print_colored_grid_value(value, surface, position, offset, immutable,
        color_value, base_color, delta_color, under_bound, over_bound)
    local is_string = type(value) == 'string'
    -- default values:
    local color = base_color or Colours.white
    local d_color = delta_color or Colours.black
    local u_color = under_bound or color
    local o_color = over_bound or color

    if (color_value < 0) then
        color = u_color
    elseif (color_value > 1) then
        color = o_color
    else
        color = {
            r = color.r + color_value * d_color.r,
            g = color.g + color_value * d_color.g,
            b = color.b + color_value * d_color.b
        }
    end

    local text = value

    if type(immutable) ~= 'boolean' then
        immutable = false
    end

    if not is_string then
        offset = offset or 0
        position = {x = position.x + offset, y = position.y + offset}

        -- round at precision of 2
        text = math.floor(100 * value) * 0.01

        if (0 == text) then
            text = '0.00'
        end
    end

    if not immutable then
        local text_entity = surface.find_entity('flying-text', position)

        if text_entity then
            text_entity.text = text
            text_entity.color = color
            return
        end
    end

    surface.create_entity{
        name = 'flying-text',
        color = color,
        text = text,
        position = position
    }.active = false
end

function Public.clear_flying_text(surface)
    local entities = surface.find_entities_filtered{name ='flying-text'}
    for _,entity in pairs(entities) do
        if entity and entity.valid then
            entity.destroy()
        end
    end
end

--- Tests if a string contains a given substring.
-- @tparam string s the string to check for the substring
-- @tparam string contains the substring to test for
-- @treturn boolean true if the substring was found in the string
function Public.string_contains(s, contains)
    return s and string.find(s, contains) ~= nil
end

--- Returns the closest match to a key
-- @tparam options table a table of options for the auto complete
-- @tparam input string the input string that will be completed
-- @tparam[opt=false] use_key boolean when true the keys of options will be used as the options
-- @tparam[opt=false] rtn_key boolean when true the the key will be returned rather than the value
-- @return the list item found that matches the input
function Public.auto_complete(options,input,use_key,rtn_key)
    local rtn = {}
    if type(input)~= 'string' then return end
    input = input:lower()
    for key,value in pairs(options) do
        local check = use_key and key or value
        if Public.string_contains(string.lower(check),input) then
            local result = rtn_key and key or value
            table.insert(rtn,result)
        end
    end
    return rtn[1]
end

--- Returns all the keys of a table
-- @tparam tbl table the table to get the keys of
-- @treturn table an array of the table keys
function Public.table_keys(tbl)
    local rtn = {}
    for key,_ in pairs(tbl) do
        table.insert(rtn,key)
    end
    return rtn
end

--- Returns all the values of a table
-- @tparam tbl table the table to get the values of
-- @treturn table an array of the table values
function Public.table_values(tbl)
    local rtn = {}
    for _,value in pairs(tbl) do
        table.insert(rtn,value)
    end
    return rtn
end

--- Returns the list is a sorted way that would be expected by people (this is by key)
-- @tparam table tbl the table to be sorted
-- @treturn table the sorted table
function Public.table_alphanumsort(tbl)
    local o = Public.table_keys(tbl)
    local function padnum(d) local dec, n = string.match(d, "(%.?)0*(.+)")
        return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n) end
    table.sort(o, function(a,b)
        return tostring(a):gsub("%.?%d+",padnum)..("%3d"):format(#b)
           < tostring(b):gsub("%.?%d+",padnum)..("%3d"):format(#a) end)
    local _tbl = {}
    for _,k in pairs(o) do _tbl[k] = tbl[k] end
    return _tbl
end

--- Returns the list is a sorted way that would be expected by people (this is by key) (faster alterative than above)
-- @tparam table tbl the table to be sorted
-- @treturn table the sorted table
function Public.table_keysort(tbl)
    local o = Public.table_keys(tbl,true)
    local _tbl = {}
    for _,k in pairs(o) do _tbl[k] = tbl[k] end
    return _tbl
end

return Public