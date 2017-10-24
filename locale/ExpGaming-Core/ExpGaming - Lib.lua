--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--Convert ticks to 12H 34M format or 8.97M when less than 10
function tick_to_display_format(tick)
	if tick_to_min(tick) < 10 then
		return string.format('%.2f M',tick/(3600*game.speed))
	else
		return string.format('%d H %d M',tick_to_hour(tick),tick_to_min(tick)-60*tick_to_hour(tick))
	end
end
--Convert ticks into hours based on game speed
function tick_to_hour (tick)
    return math.floor(tick/(216000*game.speed))
end
--Convert ticks into minutes based on game speed
function tick_to_min (tick)
  	return math.floor(tick/(3600*game.speed))
end
--used to make uuids but may be useful else where
function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
--I stole this from somewhere a long time ago but this and the other two functions convert a table into a string
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      "function" == type( v ) and '"cant-display-function"' or
      "userdata" == type( v ) and '"cant-display-userdata"' or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%player][_%player%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end
-- converts a table to json and logs it to a file
function json_log(lua_table,no_log)
  local result, done, only_indexs = {}, {}, true
  for key,value in ipairs(lua_table) do
    done[key] = true
    if type(value) == 'table' then value = table.insert(result,json_log(value,true)) end
    if type(value) == 'string' then json = table.insert(result,'"'..value..'"')
    elseif type(value) == 'number' then table.insert(result,value)
    else table.insert(result,key..':null') end
  end
  for key,value in pairs(lua_table) do
    if not done[key] then
      only_indexs = false
      if type(value) == 'table' then table.insert(result,json_log(value,true)) end
      if type(value) == 'string' then table.insert(result,key..':"'..value..'"')
      elseif type(value) == 'number' then table.insert(result,key..':'..value)
      else table.insert(result,key..':null') end
    end
  end
  if only_indexs then
    if no_log then return "["..table.concat(result,",").."]"
    else game.write_file('multi.log',"["..table.concat(result,",").."]\n",true,0) end
  else
    if no_log then return "{"..table.concat(result,",").."}"
    else game.write_file('multi.log',"{"..table.concat(result,",").."}\n",true,0) end
  end
end
-- allows a simple way to debug code; idenitys = {'string1','string2'}; string will be writen to file; no_trigger dissables the trigger useful for on_tick events
function debug_write(idenitys,string,no_trigger)
  if global.exp_core.debug.state then
    if type(string) == 'table' then string = table.tostring(string)
    elseif type(string) ~= 'string' then string = tostring(string) end
    if not no_trigger or global.exp_core.debug.triggered then game.write_file('debug.log', '\n['..table.concat(idenitys, " " )..'] '..string, true, 0) end
    if not no_trigger then global.exp_core.debug.triggered = true end
  end
end
Event.register(defines.events.on_tick,function() debug_write({'NEW TICK'},game.tick,true) end)
Event.register(Event.soft_init,function() global.exp_core.debug={state=false,triggered=false,force=false} end)