--- Adds some commonly used functions used in many modules
-- @author cooldude2606
--[[
>>>>Functions List (see function for more detail):
    Common.type_check(value,test_type) --- Compare types faster for faster validation of prams
    Common.type_check_error(value,test_type,error_message,level) --- Raises an error if the value is of the incorrect type
    Common.param_check(value,test_type,param_name,param_number) --- Raises an error when the value is the incorrect type, uses a consistent error message format

    Common.player_return(value,colour,player) --- Will return a value of any type to the player/server console, allows colour for in-game players
    Common.write_json(path,tbl) --- Writes a table object to a file in json format

    Common.opt_require(path) --- Calls a require that will not error if the file is not found
    Common.ext_require(path,...) --- Calls a require and returns only the keys given, file must return a table

    Common.format_time(ticks,options) --- Formats tick into a clean format, denominations from highest to lowest

    Common.move_items(items,surface,position,radius,chest_type) --- Moves items to the position and stores them in the closest entity of the type given

    Common.print_grid_value(value, surface, position, scale, offset, immutable) --- Prints a colored value on a location.
    Common.print_colored_grid_value(value, surface, position, offset, immutable,
        color_value, base_color, delta_color, under_bound, over_bound) --- Prints a colored value on a location. with extra settings.
    Common.clear_flying_text(surface) --- Clears all flying text entites on a surface

    Common.string_contains(s, contains) --- Tests if a string contains a given substring.

    Common.extract_keys(tbl,...) --- Extracts certain keys from a table
    Common.enum(tbl) --- Converts a table to an enum
    Common.auto_complete(options,input,use_key,rtn_key) --- Returns the closest match to the input
    Common.table_keys(tbl) --- Returns all the keys of a table
    Common.table_values(tbl) --- Returns all the values of a table
    Common.table_alphanumsort(tbl) --- Returns the list is a sorted way that would be expected by people (this is by key)
    Common.table_keysort(tbl) --- Returns the list is a sorted way that would be expected by people (this is by key) (faster alterative than above)

    Common.format_chat_colour(message,color) --- Returns a message with valid chat tags to change its colour
    Common.format_chat_colour_localized(message,color) --- Returns a message with valid chat tags to change its colour, using localization
    Common.format_chat_player_name(player,raw_string) --- Returns the players name in the players color
]]

local Colours = require 'resources.color_presets'
local Game = require 'utils.game'
local Util = require 'util'
require 'utils.table'
require 'utils.math'

local Common = {}

--- Compare types faster for faster validation of params
-- @usage type_check('foo','string') -- return true
-- @usage type_check('foo') -- return false
-- @tparam any value the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if not given then it tests for nil
-- @treturn boolean is v of type test_type
function Common.type_check(value,test_type)
    return test_type and value and type(value) == test_type or not test_type and not value or false
end

--- Raises an error if the value is of the wrong type
-- @usage type_check_error('foo','number','Value must be a number') -- will raise error "Value must be a number"
-- @tparam any value the value that you want to test the type of
-- @tparam string test_type the type that the value should be
-- @tparam string error_message the error message that is returned
-- @tparam number level the level to call the error on (level = 1 means the caller)
-- @treturn boolean true if no error was called
function Common.type_check_error(value,test_type,error_message,level)
    level = level and level+1 or 2
    return Common.test_type(value,test_type) or error(error_message,level)
end

--- Raises an error when the value is the incorrect type, uses a consistent error message format
-- @usage param_check('foo','number','repeat_count',2) -- will raise error "Invalid param #02 given to <anon>; repeat_count is not of type number"
-- @tparam any value the value that you want to test the type of
-- @tparam string test_type the type that the value should be
-- @tparam string param_name the name of the param
-- @tparam number param_number the number param it is
-- @treturn boolean true if no error was raised
function Common.param_check(value,test_type,param_name,param_number)
    if not Common.test_type(value,test_type) then
        local function_name = debug.getinfo(2,'n').name or '<anon>'
        local error_message = string.format('Invalid param #%2d given to %s; %s is not of type %s',param_number,function_name,param_name,test_type)
        return error(error_message,3)
    end
    return true
end

--- Will return a value of any type to the player/server console, allows colour for in-game players
-- @usage player_return('Hello, World!') -- returns 'Hello, World!' to game.player or server console
-- @usage player_return('Hello, World!','green') -- returns 'Hello, World!' to game.player with colour green or server console
-- @usage player_return('Hello, World!',nil,player) -- returns 'Hello, World!' to the given player
-- @param value any value of any type that will be returned to the player or console
-- @tparam[opt=defines.colour.white] ?defines.color|string colour the colour of the text for the player, ignored when printing to console
-- @tparam[opt=game.player] LuaPlayer player  the player that return will go to, if no game.player then returns to server
function Common.player_return(value,colour,player)
    colour = Common.type_check(colour,'table') and colour or Colours[colour] ~= Colours.white and Colours[colour] or Colours.white
    player = player or game.player
    -- converts the value to a string
    local returnAsString
    if Common.type_check(value,'table') or type(value) == 'userdata' then
        if Common.type_check(value.__self,'userdata') or type(value) == 'userdata' then
            -- value is userdata
            returnAsString = 'Cant Display Userdata'
        elseif Common.type_check(value[1],'string') and string.find(value[1],'.+[.].+') and not string.find(value[1],'%s') then
            -- value is a locale string
            returnAsString = value
        elseif getmetatable(value) ~= nil and not tostring(value):find('table: 0x') then
            -- value has a tostring meta method
            returnAsString = tostring(value)
        else
            -- value is a table
            returnAsString = table.inspect(value,{depth=5,indent=' ',newline='\n'})
        end
    elseif Common.type_check(value,'function') then
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

--- Writes a table object to a file in json format
-- @tparam string path the path of the file to write include / to use dir
-- @tparam table tbl the table that will be converted to a json string and wrote to file
function Common.write_json(path,tbl)
    game.write_file(path,game.table_to_json(tbl)..'\n',true,0)
end

--- Calls a require that will not error if the file is not found
-- @usage local file = opt_require('file.not.present') -- will not cause any error
-- @tparam string path the path that you want to require
-- @return the returns from that file or nil, error if not loaded
function Common.opt_require(path)
    local success, rtn = pcall(require,path)
    if success then return rtn
    else return nil,rtn end
end

--- Calls a require and returns only the keys given, file must return a table
-- @usage local extract, param_check = ext_require('expcore.common','extract','param_check')
-- @tparam string path the path that you want to require
-- @tparam string ... the name of the keys that you want returned
-- @return the keys in the order given
function Common.ext_require(path,...)
    local rtn = require(path)
    if type(rtn) ~= 'table' then
        error('File did not return a table, can not extract keys.',2)
    end
    return Common.extract_keys(rtn,...)
end

--- Formats tick into a clean format, denominations from highest to lowest
-- long will use words rather than letters
-- time will use : separates
-- string will return a string not a locale string
-- when a denomination is false it will overflow into the next one
-- @tparam number ticks the number of ticks that represents a time
-- @tparam table options table a of options to use for the format
-- @treturn string a locale string that can be used
function Common.format_time(ticks,options)
    -- Sets up the options
    options = options or {
        days=false,
        hours=true,
        minutes=true,
        seconds=false,
        long=false,
        time=false,
        string=false,
        null=false
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
    -- Creates the null time format, does not work with long
    if options.null and not options.long then
        rtn_days='--'
        rtn_hours='--'
        rtn_minutes='--'
        rtn_seconds='--'
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
    elseif not options.null then
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
-- @tparam table items items which are to be added to the chests, ['name']=count
-- @tparam[opt=navies] LuaSurface surface the surface that the items will be moved to
-- @tparam[opt={0,0}] table position the position that the items will be moved to {x=100,y=100}
-- @tparam[opt=32] number radius the radius in which the items are allowed to be placed
-- @tparam[opt=iron-chest] string chest_type the chest type that the items should be moved into
function Common.move_items(items,surface,position,radius,chest_type)
    chest_type = chest_type or 'iron-chest'
    surface = surface or game.surfaces[1]
    if position and type(position) ~= 'table' then return end
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
function Common.print_grid_value(value, surface, position, scale, offset, immutable)
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
function Common.print_colored_grid_value(value, surface, position, offset, immutable,
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

--- Clears all flying text entites on a surface
-- @tparam LuaSurface surface the surface to clear
function Common.clear_flying_text(surface)
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
function Common.string_contains(s, contains)
    return s and string.find(s, contains) ~= nil
end

--- Extracts certain keys from a table
-- @usage local key_three, key_one = extract({key_one='foo',key_two='bar',key_three=true},'key_three','key_one')
-- @tparam table tbl table the which contains the keys
-- @tparam string ... the names of the keys you want extracted
-- @return the keys in the order given
function Common.extract_keys(tbl,...)
    local values = {}
    for _,key in pairs({...}) do
        table.insert(values,tbl[key])
    end
    return unpack(values)
end

--- Converts a table to an enum
-- @tparam table tbl table the that will be converted
-- @treturn table the new table that acts like an enum
function Common.enum(tbl)
    local rtn = {}
    for k,v in pairs(tbl) do
        if type(k) ~= 'number' then
            rtn[v]=k
        end
    end
    for k,v in pairs(tbl) do
        if type(k) == 'number' then
            table.insert(rtn,v)
        end
    end
    for k,v in pairs(rtn) do
        rtn[v]=k
    end
    return rtn
end

--- Returns the closest match to the input
-- @tparam table options table a of options for the auto complete
-- @tparam string input string the input that will be completed
-- @tparam[opt=false] boolean use_key when true the keys of options will be used as the options
-- @tparam[opt=false] boolean rtn_key when true the the key will be returned rather than the value
-- @return the list item found that matches the input
function Common.auto_complete(options,input,use_key,rtn_key)
    local rtn = {}
    if type(input) ~= 'string' then return end
    input = input:lower()
    for key,value in pairs(options) do
        local check = use_key and key or value
        if Common.string_contains(string.lower(check),input) then
            local result = rtn_key and key or value
            table.insert(rtn,result)
        end
    end
    return rtn[1]
end

--- Returns all the keys of a table
-- @tparam table tbl table the to get the keys of
-- @treturn table an array of the table keys
function Common.table_keys(tbl)
    local rtn = {}
    for key,_ in pairs(tbl) do
        table.insert(rtn,key)
    end
    return rtn
end

--- Returns all the values of a table
-- @tparam table tbl table the to get the values of
-- @treturn table an array of the table values
function Common.table_values(tbl)
    local rtn = {}
    for _,value in pairs(tbl) do
        table.insert(rtn,value)
    end
    return rtn
end

--- Returns the list is a sorted way that would be expected by people (this is by key)
-- @tparam table tbl the table to be sorted
-- @treturn table the sorted table
function Common.table_alphanumsort(tbl)
    local o = Common.table_keys(tbl)
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
function Common.table_keysort(tbl)
    local o = Common.table_keys(tbl,true)
    local _tbl = {}
    for _,k in pairs(o) do _tbl[k] = tbl[k] end
    return _tbl
end

--- Returns a message with valid chat tags to change its colour
-- @tparam string message the message that will be in the output
-- @tparam table color a color which contains r,g,b as its keys
-- @treturn string the message with the color tags included
function Common.format_chat_colour(message,color)
    color = color or Colours.white
    local color_tag = '[color='..math.round(color.r,3)..','..math.round(color.g,3)..','..math.round(color.b,3)..']'
    return string.format('%s%s[/color]',color_tag,message)
end

--- Returns a message with valid chat tags to change its colour, using localization
-- @tparam ?string|table message the message that will be in the output
-- @tparam table color a color which contains r,g,b as its keys
-- @treturn table the message with the color tags included
function Common.format_chat_colour_localized(message,color)
    color = color or Colours.white
    color = math.round(color.r,3)..','..math.round(color.g,3)..','..math.round(color.b,3)
    return {'color-tag',color,message}
end

--- Returns the players name in the players color
-- @tparam LuaPlayer player the player to use the name and color of
-- @tparam[opt=false] boolean raw_string when true a is returned rather than a localized string
-- @treturn table the players name with tags for the players color
function Common.format_chat_player_name(player,raw_string)
    player = Game.get_player_from_any(player)
    local player_name = player and player.name or '<Server>'
    local player_chat_colour = player and player.chat_color or Colours.white
    if raw_string then
        return Common.format_chat_colour(player_name,player_chat_colour)
    else
        return Common.format_chat_colour_localized(player_name,player_chat_colour)
    end
end

return Common