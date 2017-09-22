--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/XSsBV6b

The credit below may be used by another script do not remove.
]]
local credits = {{
	name='ExpGaming - Lib',
	owner='Explosive Gaming',
	dev='Cooldude2606',
	description='A few basic functions used by scripts',
	factorio_version='0.15.23',
	show=false
	}}
local function credit_loop(reg) for _,cred in pairs(reg) do table.insert(credits,cred) end end
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
      "function" == type( v ) and '"cant_display_function"' or
      "userdata" == type( v ) and '"cant_display_userdata"' or
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
-- allows a simple way to debug code
function debug_write(idenitys,string)
  if global.debug then
    if type(string) == 'table' then string = table.tostring(string)
    elseif type(string) ~= 'string' then string = tostring(string) end
    game.write_file('debug.log', '\n['..table.concat(idenitys, " " )..'] '..string, true, 0)
  end
end
Event.register(defines.events.on_tick,function() debug_write({'NEW TICK'},game.tick) end)
Event.register(-1,function() global.debug = false end)
--Please Only Edit Above This Line-----------------------------------------------------------
return credits