--- Adds some common functions used though out all ExpGaming modules
-- @module ExpGamingLib
-- @alias ExpLib
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local Color = require('FactorioStdLib.Color')

local module_verbose = false -- there is no verbose in this file so true will do nothing
local ExpLib = {}

--- Loads a table into _G even when sandboxed; will not overwrite values or append to tables; will not work during runtime to avoid desyncs
-- @usage unpack_to_G{key1='foo',key2='bar'}
-- @tparam table tbl table to be unpacked
function ExpLib.unpack_to_G(tbl)
    if not type(tbl) == 'table' or game then return end
    for key,value in pairs(tbl) do
        if not _G[key] then rawset(_G,key,value) end
    end
end

--- Used to get the current ENV with all _G keys removed; useful when saving function to global
-- @usage get_env() returns current ENV with _G keys removed
-- @treturn table the env table with _G keys removed
-- @warning does not work from console
function ExpLib.get_env()
    local level = 2
    local env = setmetatable({},{__index=_G})
    while true do
        if not debug.getinfo(level-1) then break end
        local i = 1
        while true do
            local name, value = debug.getlocal(level,i)
            if not name then break else env[name] = value end
            i=i+1
        end
        level=level+1
        if debug.getinfo(level-1).namewhat == 'global' then break end
    end
    return env
end

--- Creats a table that will act like a string and a function
-- @usage add_metatable({},function) -- returns table
-- @tparam table tbl the table that will have its metatable set
-- @tparam[opt=tostring] function callback the function that will be used for the call
-- @tparam[opt=table.tostring] ?function|string string a function that resolves to a string or a string
-- @treturn table the new table with its metatable set
function ExpLib.add_metatable(tbl,callback,string)
    if not ExpLib.is_type(tbl,'table') then error('No table given to add_metatable',2) end
    local callback = ExpLib.is_type(callback,'function') and callback or tostring
    local string = ExpLib.is_type(string,'function') and string or ExpLib.is_type(string,'string') and function() return string end or table.tostring
    return setmetatable(tbl,{
        __tostring=string,
        __concat=function(val1,val2) return type(val1) == 'string' and val1..string() or string()..val2 end,
        __call=callback
    })
end

--- Compear types faster for faster valadation of prams
-- @usage is_type('foo','string') -- return true
-- @usage is_type('foo') -- return false
-- @param v the value to be tested
-- @tparam[opt=nil] string test_type the type to test for if not given then it tests for nil
-- @treturn bolean is v of type test_type
function ExpLib.is_type(v,test_type)
    return test_type and v and type(v) == test_type or not test_type and not v or false 
end

--- Will return a value of any type to the player/server console, allows colour for in-game players
-- @usage player_return('Hello, World!') -- returns 'Hello, World!' to game.player or server console
-- @usage player_return('Hello, World!','green') -- returns 'Hello, World!' to game.player with colour green or server console
-- @usage player_return('Hello, World!',nil,player) -- returns 'Hello, World!' to the given player
-- @param rtn any value of any type that will be returned to the player or console
-- @tparam[opt=defines.colour.white] ?defines.color|string colour the colour of the text for the player, ingroned when printing to console
-- @tparam[opt=game.player] LuaPlayer player  the player that return will go to, if no game.player then returns to server
function ExpLib.player_return(rtn,colour,player)
    local colour = ExpLib.is_type(colour,'table') and colour or defines.textcolor[colour] ~= defines.color.white and defines.textcolor[colour] or defines.color[colour]
    local player = player or game.player
    local function _return(callback,rtn)
        if ExpLib.is_type(rtn,'table') then 
            -- test for: userdata, locale string, table with __tostring meta method, any other table
            if ExpLib.is_type(rtn.__self,'userdata') then callback('Cant Display Userdata',colour)
            elseif ExpLib.is_type(rtn[1],'string') and string.find(rtn[1],'.+[.].+') and not string.find(rtn[1],'%s') then callback(rtn,colour)
            elseif getmetatable(rtn) ~= nil and not tostring(rtn):find('table: 0x') then callback(tostring(rtn),colour)
            else callback(table.tostring(rtn),colour) end
            -- test for: function
        elseif ExpLib.is_type(rtn,'function') then callback('Cant Display Functions',colour)
        -- else just call tostring
        else callback(tostring(rtn),colour) end
    end
    if player then
        -- allows any vaild player identifier to be used
        local player = Game.get_player(player)
        if not player then error('Invalid Player given to player_return',2) end
        -- plays a nice sound that is different to normal message sound
        player.play_sound{path='utility/scenario_message'}
        _return(player.print,rtn)
    else _return(rcon.print,rtn) end
end

--- Convert ticks to hours
-- @usage tick_to_hour(216001) -- return 1
-- @tparam number tick tick to convert to hours
-- @treturn number the number of whole hours from this tick
function ExpLib.tick_to_hour(tick)
    if not ExpLib.is_type(tick,'number') then return 0 end
    if not game then return math.floor(tick/216000) end
    return math.floor(tick/(216000*game.speed))
end

--- Convert ticks to minutes
-- @usage tick_to_hour(3601) -- return 1
-- @tparam number tick tick to convert to minutes
-- @treturn number the number of whole minutes from this tick
function ExpLib.tick_to_min (tick)
    if not ExpLib.is_type(tick,'number') then return 0 end
    if not game then return math.floor(tick/3600) end
    return math.floor(tick/(3600*game.speed))
end

--- Converts a tick into a clean format for end user
-- @usage tick_to_display_format(3600) -- return '1.00 M'
-- @usage tick_to_display_format(234000) -- return '1 H 5 M'
-- @tparam number tick the tick to convert
-- @treturn string the formated string
function ExpLib.tick_to_display_format(tick)
    if not ExpLib.is_type(tick,'number') then return '0H 0M' end
    if ExpLib.tick_to_min(tick) < 10 then
        if not game then return math.floor(tick/3600) end
		return string.format('%.2f M',tick/(3600*game.speed))
	else
        return string.format('%d H %d M',
            ExpLib.tick_to_hour(tick),
            ExpLib.tick_to_min(tick)-60*ExpLib.tick_to_hour(tick)
        )
	end
end

--- Used as a way to view the structure of a gui, used for debuging
-- @usage Gui_tree(root) returns all children of gui recusivly
-- @tparam LuaGuiElement root the root to start the tree from
-- @treturn table the table that describes the gui
function ExpLib.gui_tree(root)
    if not ExpLib.is_type(root,'table') or not root.valid then error('Invalid Gui Element given to gui_tree',2) end
    local tree = {}
    for _,child in pairs(root.children) do
        if #child.children > 0 then
            if child.name then tree[child.name] = ExpLib.gui_tree(child)
            else table.insert(tree,ExpLib.gui_tree(child)) end
        else
            if child.name then tree[child.name] = child.type
            else table.insert(tree,child.type) end
        end
    end
    return tree
end

--- Extents the table class
-- @type table
-- @alias table

--- Returns a value in a form able to be read as a value, any value to string
-- @usage table.val_to_str{a='foo'} -- return '"foo"'
-- @param v value to convert
-- @treturn string the converted value
function table.val_to_str(v)
    if "string" == type( v ) then
        v = string.gsub(v,"\n","\\n")
        if string.match(string.gsub(v,"[^'\"]",""),'^"+$') then
            return "'"..v.."'"
        end
        return '"'..string.gsub(v,'"', '\\"' )..'"'
    else
        return "table" == type( v) and table.tostring(v) or
        "function" == type(v) and '"cant-display-function"' or
        "userdata" == type(v) and '"cant-display-userdata"' or
        tostring(v)
    end
end

--- Returns a value in a form able to be read as a key, any key to string
-- @usage table.val_to_str{a='foo'} -- return '["a"]'
-- @param k key to convert
-- @treturn string the converted key
function table.key_to_str (k)
    if "string" == type(k) and string.match(k,"^[_%player][_%player%d]*$") then
        return k
    else
        return "["..table.val_to_str(k).."]"
    end
end

--- Returns a table in a form able to be read as a table
-- @usage table.tostring{k1='foo',k2='bar'} -- return '{["k1"]="foo",["k2"]="bar"}'
-- @tparam table tbl table to convert
-- @treturn string the converted table
function table.tostring(tbl)
    if type(tbl) ~= 'table' then return tostring(tbl) end
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
      table.insert(result,table.val_to_str(v))
      done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
            table.key_to_str(k).."="..table.val_to_str(v))
        end
    end
    return "{"..table.concat(result,",") .."}"
end

--- Simmilar to table.tostring but converts a lua table to a json one
-- @usage talbe.json{k1='foo',k2='bar'} -- return '{"k1":"foo","k2":"bar"}'
-- @tparam table lua_table the table to convert
-- @treturn string the table in a json format
function table.json(lua_table)
    local result, done, only_indexs = {}, {}, true
    for key,value in ipairs(lua_table) do
        done[key] = true
        if type(value) == 'table' then table.insert(result,table.json(value,true))
        elseif type(value) == 'string' then table.insert(result,'"'..value..'"')
        elseif type(value) == 'number' then table.insert(result,value)
        elseif type(value) == 'boolean' then table.insert(result,tostring(value))
        else table.insert(result,'null') 
        end
    end
    for key,value in pairs(lua_table) do
      if not done[key] then
        only_indexs = false
        if type(value) == 'table' then table.insert(result,'"'..key..'":'..table.json(value,true))
        elseif type(value) == 'string' then table.insert(result,'"'..key..'":"'..value..'"')
        elseif type(value) == 'number' then table.insert(result,'"'..key..'":'..value)
        elseif type(value) == 'boolean' then table.insert(result,'"'..key..'":'..tostring(value))
        else table.insert(result,'"'..key..'":null') 
        end
      end
    end
    if only_indexs then return "["..table.concat(result,",").."]"
    else return "{"..table.concat(result,",").."}" 
    end
end

--- Returns the closest match to a key
-- @usage table.autokey({foo=1,bar=2},'f') -- return 1 
-- @tparam table tbl the table that will be searched
-- @tparam string str the string that will be looked for in the keys
function table.autokey(tbl,str)
    local _return = {}
    for key,value in pairs(tbl) do
        if string.contains(string.lower(key),string.lower(str)) then table.insert(_return,value) end
    end
    return _return[1] or false
end

--- Returns the list is a sorted way that would be expected by people (this is by key)
-- @usage tbl = table.alphanumsort(tbl)
-- @tparam table tbl the table to be sorted
-- @treturn table the sorted table
function table.alphanumsort(tbl)
    local o = table.keys(tbl)
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
-- @usage tbl = table.alphanumsort(tbl)
-- @tparam table tbl the table to be sorted
-- @treturn table the sorted table
function table.keysort(tbl)
    local o = table.keys(tbl,true)
    local _tbl = {}
    for _,k in pairs(o) do _tbl[k] = tbl[k] end
    return _tbl
end

-- because this is marked as GlobalLib it will be auto extracted into _G
return ExpLib